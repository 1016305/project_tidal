extends Node3D

signal weapon_fired
#weapon instantion
#handles weapon swapping and meshinstance generation
@export var weapon_type : weapons:
	set(value):
		weapon_type = value
#temporary bool -> remove in future
var is_firing: bool = false
var is_reloading: bool = false

var start_pos : Vector3
var start_rot : Vector3
var mouse_movement: Vector2
var current_ammo: int



var raycast_test = preload("res://scenes/weapons/weapon_extra/raycast_test.tscn")
@onready var fire_delay: Timer = $fire_delay
@onready var muzzle_flare: Node3D = $muzzle_flare


var decal_size
var muzzle_flare_pos #not directly accessed, but i leave it here as a reminder bc im stupid


func _input(event):
	#get mouse input for the weapon sway
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _ready() -> void:
	Global.player_weapon = self
	#idk man sometimes it shits itself and this stops the initialisation before its not ready
	if not is_node_ready():
		await ready
	load_weapon()
	await get_tree().process_frame
	Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)

func _physics_process(delta: float) -> void:
	sway_weapon(delta)
	Global.debug.add_property("Current Weapon", weapon_type.name, 1)
	Global.debug.add_property("Weapon Position", position, 1)
	Global.debug.add_property("Mouse Movement", mouse_movement, 1)
	if get_child(0):
		change_weapon_fov(weapon_type.fov_slider)
	if Input.is_action_pressed("attack_1"):
		is_firing = true
	else: is_firing = false
	return_weapon_to_start_pos(delta)
	#commented this bitch out for the recoil stuff. not sure if it's importante
	#position = weapon_type.position

func sway_weapon(delta):
	#clamp mouse movement
	mouse_movement = mouse_movement.clamp(weapon_type.sway_min, weapon_type.sway_max)
	#lerp weapon pos based on mouse movement
	position.x = lerp(position.x, start_pos.x - (mouse_movement.x * weapon_type.sway_ammount_position) * delta, weapon_type.sway_speed_position)
	position.y = lerp(position.y, start_pos.y + (mouse_movement.y * weapon_type.sway_ammount_position) * delta, weapon_type.sway_speed_position)
	#lerp weapon pos based on movement input
	if Input.is_action_pressed("left"):
		position.x = lerp(position.x, start_pos.x - weapon_type.drift_max * delta, weapon_type.drift_speed)
	elif Input.is_action_pressed("right"):
		position.x = lerp(position.x, start_pos.x + weapon_type.drift_max * delta, weapon_type.drift_speed)
	#lerp rotation same
	rotation_degrees.y = lerp(rotation_degrees.y, start_rot.y + (mouse_movement.x * weapon_type.sway_ammount_rotation) * delta, weapon_type.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, start_rot.x + (mouse_movement.y * weapon_type.sway_ammount_rotation * 0.5) * delta, weapon_type.sway_speed_rotation)
	mouse_movement = lerp(mouse_movement, Vector2.ZERO, delta * 0.8)

func change_weapon_fov(fov):
	#adjust the weapon fov at runtime
	#gets the shader variable and adjusts it realtime
	if get_child(0) is MeshInstance3D and weapon_type.uses_shader:
		var a = get_child(0)
		if a.get_active_material(0).get_shader_parameter('viewmodel_fov') != fov:
			var shader_material : ShaderMaterial
			for c in get_children():
				if c is MeshInstance3D:
					shader_material = c.get_active_material(0)
					shader_material.set_shader_parameter('viewmodel_fov', fov)

func load_weapon():
	#load a new meshinstance3d as the first parent and assign first index of the mesh array
	#change_weapon_fov(weapon_type.fov_slider)
	start_pos = weapon_type.position
	start_rot = weapon_type.rotation
	#check if the weapon has multiple meshes
	for i in weapon_type.mesh:
			var newmesh = MeshInstance3D.new()
			newmesh.mesh = i
			newmesh.position = Vector3.ZERO
			newmesh.rotation_degrees = Vector3.ZERO
			newmesh.scale = Vector3.ONE
			newmesh.scale = weapon_type.scale
			newmesh.cast_shadow = 0
			add_child(newmesh)
	position = weapon_type.position
	rotation_degrees = weapon_type.rotation
	fire_delay.wait_time = weapon_type.weapon_rate_of_fire
	decal_size = weapon_type.weapon_decal_size
	muzzle_flare.position = weapon_type.muzzle_flare_pos
	current_ammo = weapon_type.weapon_current_ammo
	Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_max_ammo)
	
func unload_weapon():
	for child in get_children():
		if child is MeshInstance3D:
			child.queue_free()

func _on_player_swap_weapons(wep: Variant) -> void:
	unload_weapon()
	print("swap")
	weapon_type = wep
	load_weapon()

func shoot(delta):
	if fire_delay.is_stopped() and weapon_type.weapon_current_ammo != 0:
		emit_signal('weapon_fired')
		shoot_sounds()
		fire_delay.start()
		weapon_type.weapon_current_ammo -= weapon_type.ammo_per_shot
		Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)
		var result = weapon_spread()
		weapon_recoil(delta)
		if result: 
			test_raycast(result.get("position"),result.get("normal"),result.get("collider"))
			if get_node(result.get("collider").get_path()) is Enemy:
				var guy_you_shot = get_node(result.get("collider").get_path())
				damage_enemy(guy_you_shot)
	if weapon_type.weapon_current_ammo <= 0:
		reload()
	
func test_raycast(ray_pos,ray_nrm,ray_col):
	var instance = raycast_test.instantiate()
	get_node(ray_col.get_path()).add_child(instance)
	instance.size = Vector3(decal_size,decal_size,decal_size)
	instance.global_position = ray_pos
	instance.look_at(instance.global_transform.origin + ray_nrm,Vector3.UP)
	instance.rotate_object_local(Vector3(1,0,0), 90)
	if instance != null:
		await get_tree().create_timer(5).timeout
		var fade = get_tree().create_tween()
		fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	if instance != null:
		instance.queue_free()
	
func damage_enemy(enemy):
	enemy.take_damage(weapon_type.weapon_damage)

func weapon_recoil(delta):
	#position = Vector3.UP
	#retunr to pos lerp
	var target_position = lerp(weapon_type.recoil_max, start_pos, 0.5 *delta)
	#recoil lerp
	var current_position = lerp(position, weapon_type.recoil_max, weapon_type.recoil_speed*delta)
	#randomise recoil a bit. maybe add the ranges to the weapon script
	target_position = start_pos+(Vector3(0,0,0.1)+Vector3(randf_range(-0.01,0.01),randf_range(-0.01,0.01),randf_range(-0.02,0.03)))
	position = lerp(position,target_position, weapon_type.recoil_speed*delta)

func return_weapon_to_start_pos(delta):
	position = lerp(position,start_pos, 0.7*delta)

func shoot_sounds():
	var current_sound = weapon_type.shoot_sounds[randf_range(0,len(weapon_type.shoot_sounds))]
	var newplayer = AudioStreamPlayer3D.new()
	newplayer.stream = current_sound
	newplayer.pitch_scale = randf_range(0.9,1.1)
	add_child(newplayer)
	newplayer.play(0.0)
	await newplayer.finished
	newplayer.queue_free()
	
func reload():
	if weapon_type.weapon_reserve_ammo != 0 and !is_reloading:
		is_reloading = !is_reloading
		Global.player_is_reloading.emit()
		await get_tree().create_timer(3).timeout
		if weapon_type.weapon_reserve_ammo >= weapon_type.weapon_max_ammo:
			weapon_type.weapon_reserve_ammo -= (weapon_type.weapon_max_ammo - weapon_type.weapon_current_ammo) 
			weapon_type.weapon_current_ammo = weapon_type.weapon_max_ammo
		else:
			weapon_type.weapon_current_ammo = weapon_type.weapon_reserve_ammo
			weapon_type.weapon_reserve_ammo = 0
		Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)
		is_reloading = !is_reloading

func weapon_spread():
	var camera = Global.main_camera
	var space_state = camera.get_world_3d().direct_space_state
	
	var _screen_center = get_viewport().size /2 # vector 2 of 1/2 the screen resolution (center of screen)
	var screen_center = Vector2(_screen_center) # converts pervious from vector2i to vector2
	var screen_y_half = screen_center.y
	screen_center.y = get_viewport().size.y/3 * 1.6 # offset to account for the croshair not being centered
	#here is where you do the bloom calculations
	var screen_space_bloom = screen_y_half * weapon_type.bloom #ensures that weapon accuracy isnt dependant on window resolution.
	screen_center += Vector2(randf_range(-screen_space_bloom,screen_space_bloom),randf_range(-screen_space_bloom,screen_space_bloom))
	
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	return result

extends Node3D

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

var time: float = 0.0
var bloom_variance: float = 0.0

var is_dead: bool = false

var raycast_test = preload("res://scenes/weapons/weapon_extra/raycast_test.tscn")
@onready var fire_delay: Timer = $fire_delay
@onready var muzzle_flare: Node3D = $muzzle_flare
@onready var fire_sounds: AkEvent3D = $fire_sounds


var decal_size
var muzzle_flare_pos #not directly accessed, but i leave it here as a reminder bc im stupid


func _input(event):
	#get mouse input for the weapon sway
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _ready() -> void:
	Global.player_weapon = self
	Global.player_died.connect(player_dead)
	Global.player_respawned.connect(player_dead)
	is_dead = false
	#idk man sometimes it shits itself and this stops the initialisation before its not ready
	if not is_node_ready():
		await ready
	load_weapon()
	await get_tree().process_frame
	Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)

func _physics_process(delta: float) -> void:
	if !is_dead:
		sway_weapon(delta)
		bob_weapon(delta)
		Global.debug.add_property("Current Weapon", weapon_type.name, 1)
		Global.debug.add_property("Weapon Position", position, 1)
		Global.debug.add_property("Mouse Movement", mouse_movement, 1)
		if get_child(0):
			change_weapon_fov(weapon_type.fov_slider)
		return_weapon_to_start_pos(delta)
		bloom(delta)
	if Input.is_action_pressed("attack_1"):
		is_firing = true
	else: is_firing = false
	#refresh_weapon()
	#commented this bitch out for the recoil stuff. not sure if it's importante
	#position = weapon_type.position

func sway_weapon(delta):
	#clamp mouse movement
	mouse_movement = mouse_movement.clamp(weapon_type.sway_min, weapon_type.sway_max)
	#lerp weapon pos based on mouse movement
	#lerp weapon pos based on movement input
	if Input.is_action_pressed("forward"):
		position.z = lerp(position.z, start_pos.z - -weapon_type.push_in_ammount * delta, weapon_type.drift_speed * 0.5)
	elif Input.is_action_pressed("backward"):
		position.z = lerp(position.z, start_pos.z - weapon_type.push_in_ammount * delta, weapon_type.drift_speed)
	if Input.is_action_pressed("left"):
		position.x = lerp(position.x, start_pos.x - weapon_type.drift_max * delta, weapon_type.drift_speed)
	elif Input.is_action_pressed("right"):
		position.x = lerp(position.x, start_pos.x + weapon_type.drift_max * delta, weapon_type.drift_speed)
	#lerp rotation same
	rotation_degrees.y = lerp(rotation_degrees.y, start_rot.y + (mouse_movement.x * weapon_type.sway_ammount_rotation) * delta, weapon_type.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, start_rot.x + (mouse_movement.y * weapon_type.sway_ammount_rotation * 0.5) * delta, weapon_type.sway_speed_rotation)
	mouse_movement = lerp(mouse_movement, Vector2.ZERO, delta * 0.8)
	
	#hold weapon closer/further depending on player's head pitch
	position.z += (-Global.player.player_head.rotation.x*0.008)

func bob_weapon(delta):
	# sin(time * frequency)*amplitude
	if Global.player.is_moving:
		time += delta
		var vertical_bob = sin(time*(weapon_type.vertical_bob_frequency*2 if Global.player.is_running else weapon_type.vertical_bob_frequency)) * weapon_type.vertical_bob_amplitude
		var horizontal_bob = sin(time*(weapon_type.horizontal_bob_frequency*2 if Global.player.is_running else weapon_type.horizontal_bob_frequency)) * weapon_type.horizontal_bob_amplitude
		position.y += vertical_bob / 10
		position.x += horizontal_bob /10
	else:
		time = 0.0

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
	if weapon_type.mesh != null:
		for i in weapon_type.mesh:
				var newmesh = MeshInstance3D.new()
				newmesh.mesh = i
				newmesh.position = Vector3.ZERO
				newmesh.rotation_degrees = Vector3.ZERO
				newmesh.scale = Vector3.ONE
				newmesh.scale = weapon_type.scale
				newmesh.cast_shadow = 0
				newmesh.set_layer_mask_value(2,true)
				newmesh.set_layer_mask_value(1,false)
				add_child(newmesh)
	if weapon_type.lhand != null:
		var l_hand_model = MeshInstance3D.new()
		l_hand_model.mesh = weapon_type.lhand
		l_hand_model.scale = weapon_type.lhand_scl
		l_hand_model.position = weapon_type.lhand_pos
		l_hand_model.rotation = weapon_type.lhand_rot
		l_hand_model.cast_shadow = 0
		l_hand_model.set_layer_mask_value(2,true)
		l_hand_model.set_layer_mask_value(1,false)
		add_child(l_hand_model)
	if weapon_type.rhand != null:
		var r_hand_model = MeshInstance3D.new()
		r_hand_model.mesh = weapon_type.rhand
		r_hand_model.scale = weapon_type.rhand_scl
		r_hand_model.position = weapon_type.rhand_pos
		r_hand_model.rotation = weapon_type.rhand_rot
		r_hand_model.cast_shadow = 0
		r_hand_model.set_layer_mask_value(2,true)
		r_hand_model.set_layer_mask_value(1,false)
		add_child(r_hand_model)
	
	position = weapon_type.position
	rotation_degrees = weapon_type.rotation
	fire_delay.wait_time = weapon_type.weapon_rate_of_fire
	decal_size = weapon_type.weapon_decal_size
	muzzle_flare.position = weapon_type.muzzle_flare_pos
	current_ammo = weapon_type.weapon_current_ammo
	Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_max_ammo)
	fire_sounds.event = weapon_type.shoot_sounds
	
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
		Global.weapon_fired.emit()
		shoot_sounds()
		fire_delay.start()
		weapon_type.weapon_current_ammo -= weapon_type.ammo_per_shot
		Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)
		var result_enemy = weapon_spread(delta,2)
		var result_world = weapon_spread(delta,1)
		weapon_recoil(delta)
		if result_enemy: 
			test_raycast(result_enemy.get("position"),result_enemy.get("normal"),result_enemy.get("collider"))
			if get_node(result_enemy.get("collider").get_path()) is GenericHitbox:
				var part_shot = get_node(result_enemy.get("collider").get_path()) 
				part_shot.on_hit(weapon_type.weapon_damage)
				#print(result_enemy)
			if get_node(result_enemy.get("collider").get_path()) is Heatsink:
				var part_shot = get_node(result_enemy.get("collider").get_path()) 
				part_shot.take_damage(weapon_type.weapon_damage)
		if result_world: 
			test_raycast(result_world.get("position"),result_world.get("normal"),result_world.get("collider"))
				#var guy_you_shot = get_node(result.get("collider").get_path())
				#guy_you_shot.on_hit()
	if weapon_type.weapon_current_ammo <= 0:
		reload()
	
func test_raycast(ray_pos,ray_nrm,ray_col):
	var instance = raycast_test.instantiate()
	get_node(ray_col.get_path()).add_child(instance)
	instance.size = Vector3(decal_size,decal_size,decal_size)
	instance.global_position = ray_pos
	instance.look_at(instance.global_transform.origin + ray_nrm,Vector3.UP)
	instance.rotate_object_local(Vector3(1,0,0), 90)
	await get_tree().create_timer(5).timeout
	if instance != null:
		var fade = get_tree().create_tween()
		fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	if instance != null:
		instance.queue_free()
	
func damage_enemy(enemy):
	enemy.take_damage(weapon_type.weapon_damage)
	print("Damaged enemy for ", weapon_type.weapon_damage, " damage")

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
	position.x = lerp(position.x, start_pos.x - (mouse_movement.x * weapon_type.sway_ammount_position) * delta, weapon_type.sway_speed_position)
	position.y = lerp(position.y, start_pos.y + (mouse_movement.y * weapon_type.sway_ammount_position) * delta, weapon_type.sway_speed_position)
	position.z = lerp(position.z, start_pos.z + (mouse_movement.y * weapon_type.sway_ammount_position) * delta, weapon_type.sway_speed_position)

func shoot_sounds():
	
	fire_sounds.post_event()
	
func reload():
	if weapon_type.weapon_reserve_ammo != 0 and !is_reloading:
		is_reloading = !is_reloading
		Global.player_is_reloading.emit()
		await get_tree().create_timer(weapon_type.weapon_reload_time).timeout
		var pending_ammo = weapon_type.weapon_max_ammo - weapon_type.weapon_current_ammo
		
		if pending_ammo < weapon_type.weapon_reserve_ammo:
			weapon_type.weapon_reserve_ammo -= pending_ammo
			weapon_type.weapon_current_ammo = weapon_type.weapon_max_ammo
		else:
			weapon_type.weapon_current_ammo += weapon_type.weapon_reserve_ammo
			weapon_type.weapon_reserve_ammo = 0
		Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)
		is_reloading = !is_reloading

func weapon_spread(delta,mask):
	var camera = Global.main_camera
	var space_state = camera.get_world_3d().direct_space_state
	
	var _screen_center = get_viewport().size /2 # vector 2 of 1/2 the screen resolution (center of screen)
	var screen_center = Vector2(_screen_center) # converts pervious from vector2i to vector2
	var screen_y_half = screen_center.y
	screen_center.y = get_viewport().size.y/3 * 1.6 # offset to account for the croshair not being centered
	#here is where you do the bloom calculations
	var screen_space_bloom = screen_y_half * (weapon_type.accuracy + bloom(delta)) #ensures that weapon accuracy isnt dependant on window resolution.
	screen_center += Vector2(randf_range(-screen_space_bloom,screen_space_bloom),randf_range(-screen_space_bloom,screen_space_bloom))
	
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collision_mask = mask
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	return result

func add_ammo(ammo):
	weapon_type.weapon_reserve_ammo += ammo
	Global.ammo_update.emit(weapon_type.weapon_current_ammo, weapon_type.weapon_reserve_ammo)

func bloom(delta):
	if is_firing:
		bloom_variance = lerp(bloom_variance,weapon_type.bloom, weapon_type.bloom_time * delta)
		return bloom_variance
	else:
		bloom_variance = lerp(bloom_variance,0.0,(weapon_type.bloom_time*3)*delta)
		return bloom_variance
	if Global.player.is_moving:
		if Global.player.is_running:
			return bloom_variance + (weapon_type.move_accuracy_loss*2)
		else:
			return bloom_variance + weapon_type.move_accuracy_loss

#func add_ammo(ammo_to_add):
	#weapon_type.

func player_dead():
	is_dead = !is_dead


func refresh_weapon():
	unload_weapon()
	load_weapon()

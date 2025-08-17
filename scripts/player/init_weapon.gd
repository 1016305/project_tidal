extends Node3D

#weapon instantion
#handles weapon swapping and meshinstance generation
@export var weapon_type : weapons:
	set(value):
		weapon_type = value
#temporary bool -> remove in future
var isshadered: bool = true

var start_pos : Vector3
var start_rot : Vector3
var mouse_movement: Vector2



func _input(event):
	#get mouse input for the weapon sway
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func _ready() -> void:
	#idk man sometimes it shits itself and this stops the initialisation before its not ready
	if not is_node_ready():
		await ready
	load_weapon()

func _physics_process(delta: float) -> void:
	sway_weapon(delta)
	Global.debug.add_property("Current Weapon", weapon_type.name, 1)
	Global.debug.add_property("Weapon Position", position, 1)
	Global.debug.add_property("Mouse Movement", mouse_movement, 1)
	if get_child(0):
		#print(get_child(0))
		change_weapon_fov(weapon_type.fov_slider)
	
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
			add_child(newmesh)
			print("mesh loaded")
	position = weapon_type.position
	rotation_degrees = weapon_type.rotation
	
func unload_weapon():
	for child in get_children():
		child.queue_free()


func _on_player_swap_weapons(wep: Variant) -> void:
	unload_weapon()
	print("swap")
	weapon_type = wep
	load_weapon()

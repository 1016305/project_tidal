extends Node3D

@export_category("Weapon Sway")
@export var sway_min: Vector2 = Vector2(-20.0,-20.0)
@export var sway_max: Vector2 = Vector2(20.0,20.0)
@export_range(0,0.2,0.01) var sway_speed_position: float = 0.07
@export_range(0,0.2,0.01) var sway_speed_rotation: float = 0.1
@export_range(0,0.25,0.01) var sway_ammount_position: float = 0.1
@export_range(0,50,0.1) var sway_ammount_rotation: float = 30.0
@export_range(0,50,0.1) var drift_max: float = 0.5
@export_range(0,0.5,0.01) var drift_speed: float = 0.1
@export_category("Viewmodel FOV")
@export_range(0,150,0.1) var fov_slider = 75.0

var start_pos : Vector3 #
var start_rot : Vector3 #

var mouse_movement: Vector2 #
func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
func _ready() -> void:
	start_pos = position
	start_rot = rotation

func _physics_process(delta: float) -> void:
	sway_weapon(delta)
	Global.debug.add_property("Weapon Position", position, 1)
	Global.debug.add_property("Mouse Movement", mouse_movement, 1)
	change_weapon_fov(fov_slider)
	
func sway_weapon(delta):
	#clamp mouse movement
	mouse_movement = mouse_movement.clamp(sway_min, sway_max)
	#lerp weapon pos based on mouse movement
	position.x = lerp(position.x, start_pos.x - (mouse_movement.x * sway_ammount_position) * delta, sway_speed_position)
	position.y = lerp(position.y, start_pos.y + (mouse_movement.y * sway_ammount_position) * delta, sway_speed_position)
	#lerp weapon pos based on movement input
	if Input.is_action_pressed("left"):
		position.x = lerp(position.x, start_pos.x - drift_max * delta, drift_speed)
	elif Input.is_action_pressed("right"):
		position.x = lerp(position.x, start_pos.x + drift_max * delta, drift_speed)
	#lerp rotation same
	rotation_degrees.y = lerp(rotation_degrees.y, start_rot.y + (mouse_movement.x * sway_ammount_rotation) * delta, sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, start_rot.x + (mouse_movement.y * sway_ammount_rotation * 0.5) * delta, sway_speed_rotation)
	mouse_movement = lerp(mouse_movement, Vector2.ZERO, delta * 0.8)
	
	
func change_weapon_fov(fov):
	if get_child(0) is MeshInstance3D:
		var a = get_child(0)
		if a.get_active_material(0).get_shader_parameter('viewmodel_fov') != fov:
			var shader_material : ShaderMaterial
			for c in get_children():
				if c is MeshInstance3D:
					shader_material = c.get_active_material(0)
					shader_material.set_shader_parameter('viewmodel_fov', fov)
	

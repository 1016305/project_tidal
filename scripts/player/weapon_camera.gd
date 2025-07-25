extends Camera3D

@export var main_camera : Node3D

func _process(delta: float) -> void:
	global_transform = main_camera.global_transform
	#fov = main_camera.fov

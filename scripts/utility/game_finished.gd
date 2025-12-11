extends Area3D

var blocker_pos: Vector3 = Vector3(-0.302,1.328,13.057)
@export var blocker: CSGBox3D
@export var the_door: Node3D

func _on_body_entered(body: Node3D) -> void:
	blocker.position = blocker_pos
	the_door.close_door()
	

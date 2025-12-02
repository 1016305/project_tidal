extends Area3D
@onready var csg_cylinder_3d: CSGCylinder3D = $CSGCylinder3D


func _on_body_entered(body: Node3D) -> void:
	if body == Global.player:
		csg_cylinder_3d.height += 0.2

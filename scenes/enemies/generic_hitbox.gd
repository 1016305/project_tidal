class_name GenericHitbox extends StaticBody3D

@export var parent: DumbEnemy
@export_enum ("Head","Body","Arm") var bodypart: String = "Body"

func on_hit(damage):
	parent.check_body_part(bodypart,damage)

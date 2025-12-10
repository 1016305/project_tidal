extends Node3D

@export_enum("Arena","Canyon","FirstTower","SecondTower","ThirdTower") var new_atmos: String
@export_enum("Arena","Canyon","FirstTower","SecondTower","ThirdTower") var old_atmos: String
@onready var atmos: Node3D = $"../../Atmos"

@onready var old: CollisionShape3D = $AmbOld/CollisionShape3D
@onready var new: CollisionShape3D = $AmbNew/CollisionShape3D2


func _on_amb_old_body_entered(body: Node3D) -> void:
	if body == Global.player:
		Wwise.set_switch("AmbienceController",old_atmos,atmos.ak_event_3d)
		print("switched atmosevent to ",old_atmos)

func _on_amb_new_body_entered(body: Node3D) -> void:
	if body == Global.player:
		Wwise.set_switch("AmbienceController",new_atmos,atmos.ak_event_3d)
		print("switched atmosevent to ",new_atmos)

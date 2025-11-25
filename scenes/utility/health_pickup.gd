extends Node3D

@export var health_ammount: int = 25

func heal_player():
	if Global.player.current_health < Global.player.max_health:
		Global.player.heal(health_ammount)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		heal_player()
		queue_free()

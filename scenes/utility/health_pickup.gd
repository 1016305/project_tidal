extends Node3D

@export var health_ammount: int = 25
@onready var ak_event_3d: AkEvent3D = $AkEvent3D

func heal_player():
	ak_event_3d.post_event()
	if Global.player.current_health < Global.player.max_health:
		Global.player.heal(health_ammount)
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		heal_player()
		

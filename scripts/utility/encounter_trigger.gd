extends Area3D

@export var encounter:EnemyEncounter

func _on_body_entered(body: Node3D) -> void:
	if body == Global.player:
		encounter.set_encounter()
		queue_free()

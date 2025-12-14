extends Area3D

var is_done: bool = false
@export var boss_encounter: EnemyEncounter
func _on_body_entered(body: Node3D) -> void:
	if !is_done:
		if body == Global.player:
			print("player is activating boss arena")
			Global.begin_boss.emit()
			is_done = true
			boss_encounter.set_encounter()
			queue_free()

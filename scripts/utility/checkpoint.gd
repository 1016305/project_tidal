extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body == Global.player:
		Global.current_checkpoint_manager.save_checkpoint()
		queue_free()

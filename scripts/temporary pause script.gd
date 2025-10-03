extends Node3D

func _process(delta: float) -> void:
	test_pause()

func test_pause():
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

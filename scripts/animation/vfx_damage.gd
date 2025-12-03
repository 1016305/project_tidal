extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func on_start():
	animation_player.play("start")
	
func on_end():
	animation_player.play("end")
	await get_tree().create_timer(0.6).timeout

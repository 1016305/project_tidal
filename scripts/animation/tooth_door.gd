extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_3d: Area3D = $Area3D
var has_played: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("hello")
	if !has_played:
		animation_player.play("top_door_move")
		has_played = false

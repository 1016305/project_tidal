extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		print("switcha")
		Wwise.set_switch("FootstepsTerrain","Grass",Global.player.ak_footsteps)


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body == Global.player:
		print("switchb")
		Wwise.set_switch("FootstepsTerrain","Metal",Global.player.ak_footsteps)

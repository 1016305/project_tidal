extends ColorRect

func _ready() -> void:
	Global.player_died.connect(show_death_mask)
	Global.player_respawned.connect(hide_death_mask)
	hide_death_mask()
	
func show_death_mask():
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	await tween.tween_property(self, "color", Color(0,0,0,1), 2).finished
	await get_tree().create_timer(1).timeout
	Global.current_checkpoint_manager.respawn_player()
	
func hide_death_mask():
	color = Color(0,0,0,0)

extends TextureRect

var val: float = 0
var tween1
var tween2
func _ready() -> void:
	Global.player_was_hit.connect(animate_vignette)
	Global.player_died.connect(death_vignette)
	Global.player_respawned.connect(hide_vignette)
	visible = !visible
	
func animate_vignette():
	if tween1 != null and tween2 != null:
		tween1.stop()
		tween2.stop()
	visible = true
	tween1 = create_tween()
	await tween1.tween_property(self, "modulate:a", 0.8, 0.1).finished
	tween2 = create_tween()
	await tween2.tween_property(self, "modulate:a", 0, 3).finished
	visible = false

func death_vignette():
	if tween1 != null and tween2 != null:
		tween1.stop()
		tween2.stop()
	visible = true
	tween1 = create_tween()
	await tween1.tween_property(self, "modulate:a", 0.8, 0.1).finished

func hide_vignette():
	visible=false

extends Control

func _ready() -> void:
	Global.pause_toggle.connect(toggle_ui)
	
func toggle_ui():
	visible = !visible

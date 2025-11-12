extends Control

@onready var main: VBoxContainer = $Main
@onready var but_start: Button = $Main/Button
@onready var but_options: Button = $Main/Button2
@onready var but_exit: Button = $Main/Button3
@onready var options: VBoxContainer = $Options
const world = preload("res://scenes/cutscene.tscn")

	
##Main Menu buttons
func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(world)

func _on_options_pressed() -> void:
	main.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()


##Options Menu buttons
func _on_back_pressed() -> void:
	options.visible = false
	main.visible = true

func _on_volume_changed(value: float) -> void:
	Global.emit_signal("volume", value)


func _on_mouse_sensitivity(value: float) -> void:
	Global.emit_signal("get_mouse_sens", value)

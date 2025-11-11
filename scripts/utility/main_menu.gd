extends Control

@onready var main: VBoxContainer = $Main
@onready var but_start: Button = $VBoxContainer/Button
@onready var but_options: Button = $VBoxContainer/Button2
@onready var but_exit: Button = $VBoxContainer/Button3
@onready var options: VBoxContainer = $Options
const world = preload("res://scenes/level_1_test_scene.tscn")

	
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

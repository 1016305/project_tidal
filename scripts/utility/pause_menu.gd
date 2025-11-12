extends Control

var toggle_menu: bool = false
@onready var pause_main: VBoxContainer = $pause_main
@onready var options: VBoxContainer = $Options


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()

func pause():
	get_tree().paused = !get_tree().paused
	visible = !visible
	Global.pause_toggle.emit()
	toggle_menu = !toggle_menu
	if toggle_menu:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		

func _on_resume_pressed() -> void:
	pause()

func _on_options_pressed() -> void:
	pause_main.visible = !pause_main.visible
	options.visible = !options.visible

func _on_back_pressed() -> void:
	pause_main.visible = !pause_main.visible
	options.visible = !options.visible

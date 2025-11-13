extends Control

var toggle_menu: bool = false
@onready var pause_main: VBoxContainer = $pause_main
@onready var options: VBoxContainer = $Options
@onready var vol_slider: HSlider = $Options/Volume/HSlider
@onready var sen_slider: HSlider = $Options/Sensitivity/HSlider2


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()

func pause():
	pull_data_from_global_singleton()
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

func pull_data_from_global_singleton():
	if Global._volume != null:
		vol_slider.value = Global._volume
	if Global._mouse_sens != null:
		sen_slider.value = Global._mouse_sens


func _on_volume_slider_value_changed(value: float) -> void:
	Global.emit_signal("volume", value)
	
func _on_sens_slider_value_changed(value: float) -> void:
	Global.emit_signal("get_mouse_sens", value)

extends Control

var toggle_menu: bool = false
@onready var pause_main: VBoxContainer = $pause_main
@onready var options: VBoxContainer = $Options

@onready var sen_slider: HSlider = $Options/Sensitivity/HSlider2

##Sliders
#master
@onready var vol_slider: HSlider = $Options/Volume/HSlider
@onready var music_slider: HSlider = $Options/VBoxContainer2/HBoxContainer/HSlider
@onready var sfx_slider: HSlider = $"Options/VBoxContainer2/SFX Volume/HSlider2"
@onready var dialogue_slider: HSlider = $"Options/VBoxContainer2/Dialogue Volume/HSlider3"

func _ready() -> void:
	set_slider_values()

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
		Wwise.suspend(false)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Wwise.wakeup_from_suspend()
		

func set_slider_values():
	vol_slider.value = Global.master_volume
	music_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume 
	dialogue_slider.value = Global.dialogue_volume

func _on_resume_pressed() -> void:
	pause()

func _on_options_pressed() -> void:
	pause_main.visible = !pause_main.visible
	options.visible = !options.visible

func _on_back_pressed() -> void:
	pause_main.visible = !pause_main.visible
	options.visible = !options.visible

func pull_data_from_global_singleton():
	if Global._mouse_sens != null:
		sen_slider.value = Global._mouse_sens


func _on_volume_slider_value_changed(value: float) -> void:
		master_volume_slider(value)
	
func _on_sens_slider_value_changed(value: float) -> void:
	Global.emit_signal("get_mouse_sens", value)

func _on_exit_pressed() -> void:
	get_tree().quit()

func master_volume_slider(volume):
	Wwise.set_rtpc_value("MasterVolume", volume, null)
	Global.master_volume = volume

func sfx_volume_slider(volume):
	Wwise.set_rtpc_value("SFXVolume", volume, null)
	Global.sfx_volume = volume

func dialogue_volume_slider(volume):
	Wwise.set_rtpc_value("DialogueVolume", volume, null)
	Global.dialogue_volume = volume
	
func music_volume_slider(volume):
	Wwise.set_rtpc_value("MusicVolume", volume, null)
	Global.music_volume = volume

func _on_musicvol_slider_value_changed(value: float) -> void:
	music_volume_slider(value)


func _on_sfxvol_slider_value_changed(value: float) -> void:
	sfx_volume_slider(value)


func _on_dialogue_slider_value_changed(value: float) -> void:
	dialogue_volume_slider(value)

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


func _on_mouse_sensitivity(value: float) -> void:
	Global.emit_signal("get_mouse_sens", value)
	

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
	
func _on_master_vol_slider_value_changed(value: float) -> void:
	master_volume_slider(value)

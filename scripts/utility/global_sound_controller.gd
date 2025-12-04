class_name GlobalSounds extends Node3D


var SFX = {
	&"UI_CLICK": WwiseEvent.new()
}
#@export_category("First Tower")
#@export var ship_wreckage: WwiseEvent
#@export var console_hum: WwiseEvent
#@export var tooth_door: WwiseEvent
#@export var buttons: WwiseEvent
#@export var light_sequence: WwiseEvent
#
#enum Sounds{e_shipwreckage,e_consolehum,e_toothdoor,e_buttons,e_light_sequence}
#var picksound: Sounds = Sounds.e_shipwreckage
#
#const SOUND_DICT = {Sounds.e_shipwreckage:ship_wreckage}
#
#func _ready() -> void:
	#Global.sound_manager = self
	#Global.sound_manager_assigned.emit()

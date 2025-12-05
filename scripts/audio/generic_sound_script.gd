@tool
class_name GenericSoundScript extends Node3D
var SOUNDS_TABLE = preload("res://scripts/utility/sounds_table.tres")
var global_sound_controller: Node3D
@onready var ak_event_3d: AkEvent3D = $AkEvent3D
@export var event: StringName
var active_event: WwiseEvent

func _validate_property(property:Dictionary) -> void:
	if property.name == 'event':
		property["hint"] = PROPERTY_HINT_ENUM_SUGGESTION
		SOUNDS_TABLE = load("res://scripts/utility/sounds_table.tres")
		property["hint_string"] = ",".join(PackedStringArray(SOUNDS_TABLE.data.keys()))

func play():
	#fix refresh error and this will return a wwise event which can be posted
	#SOUNDS_TABLE = load("res://scripts/utility/sounds_table.tres")
	active_event = SOUNDS_TABLE.data.get(event)
	ak_event_3d.event = active_event
	if active_event != null:
		active_event.post(self)
		ak_event_3d
		print("playing sounds")

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	play()

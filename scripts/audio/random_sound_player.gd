extends Node3D

@onready var random_sound_player: AkEvent3D = $AkEvent3D
@export var random_event: WwiseEvent

func _ready() -> void:
	#When our script is loaded, it will select the event from the @export variable
	#and assign it to the AKEvent3D's event. We are teeling it what event it should
	#play when it is called.
	random_sound_player.event = random_event

func play_sound():
	random_sound_player.post(self)

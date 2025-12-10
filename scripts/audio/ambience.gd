extends Node3D
@onready var ak_event_3d: AkEvent3D = $AkEvent3D

func _ready() -> void:
	ak_event_3d.post_event()

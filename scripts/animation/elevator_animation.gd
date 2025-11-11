class_name Elevator extends Node

@onready var animation_player: AnimationPlayer = $"../../Elevator_lights/AnimationPlayer"
@onready var interaction_component: InteractionComponent = $"../Interaction Component"



var parent
var has_played: bool = false
func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	
func _physics_process(delta: float) -> void:
	pass
	
func connect_parent():
	parent.connect("interact", Callable(self, "elevator_animation"))
	
func elevator_animation():
	if !has_played:
		animation_player.play("button_press")
		animation_player.play("elevator_move_down")
		has_played = true
		Global.player.reparent(self, true)
		interaction_component.is_used = true

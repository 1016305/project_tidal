class_name Elevator extends Node

@export var animation_player: AnimationPlayer
@onready var interaction_component: InteractionComponent = $"../Interaction Component"
@export var button_noise: WwiseEvent
var active: bool = false



var parent
var has_played: bool = false
var attach: bool = false
func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	
func _physics_process(delta: float) -> void:
	attach_player_to_elevator(delta)
	
func connect_parent():
	parent.connect("interact", Callable(self, "elevator_animation"))
	
func elevator_animation():
	if active:
		if !has_played:
			animation_player.play("button_press")
			button_noise.post(self)
			animation_player.queue("elevator_move_down")
			has_played = true
			Global.player.reparent(self, true)
			interaction_component.is_used = true
			attach = true

func attach_player_to_elevator(delta):
	if attach:
		Global.player.position.y = get_parent().get_parent().position.y

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "elevator_move_down":
		attach = false
		active = false


func _on_big_door_turn_lights_on() -> void:
	active = true

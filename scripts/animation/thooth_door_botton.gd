class_name BigDoor extends Node
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var animation_player2: AnimationPlayer = $"../../../control_panel_Imported/StaticBody3D_buttonLP/AnimationPlayer"
@onready var interact_component: InteractionComponent = $"../InteractComponent"
@onready var omni_light_3d: OmniLight3D = $"../../../control_panel_Imported/StaticBody3D_buttonLP/OmniLight3D"
@export var door_sound : WwiseEvent
@export var button_sound: WwiseEvent
signal turn_lights_on


var parent
var has_played: bool = false
func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(connect_parent)
	
func _physics_process(delta: float) -> void:
	if has_played or omni_light_3d.light_energy < 0.01:
		light_lerp(delta)
	
func connect_parent():
	parent.connect("interact", Callable(self, "door_animation"))
	
func door_animation():
	if !has_played:
		button_sound.post(self)
		door_sound.post(self)
		interact_component.is_used = true
		animation_player.play("top_door_move")
		animation_player2.play("button_push")
		has_played = true
		emit_signal("turn_lights_on")

		
func light_lerp(delta):
	omni_light_3d.light_energy = lerp(omni_light_3d.light_energy, 0.0, 3.0 * delta)

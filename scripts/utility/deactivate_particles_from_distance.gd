extends GPUParticles3D

var player
var delay: bool = false
@export var max_distance: float = 20

func _ready() -> void:
	await Global.player_is_assigned

func _physics_process(delta: float) -> void:
	disable_when_player_is_far()

func disable_when_player_is_far():
	if Global.player != null:
		if position.distance_to(Global.player.position) > max_distance:
			if self.emitting:
				self.emitting = false
		else:
			if !self.emitting:
				self.emitting = true

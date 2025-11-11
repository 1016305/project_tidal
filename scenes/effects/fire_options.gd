@tool
extends Node3D

@onready var fire: CPUParticles3D = $CPUParticles3D

@export var fx_scale: float
	
func _process(delta: float) -> void:
	fire.scale_amount_max = fx_scale
	fire.scale_amount_min = fx_scale
	
	
	
	

extends Node3D

@onready var weapon: Node3D = $".."

var flash_time

@onready var light: OmniLight3D = $OmniLight3D
@onready var particle: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	weapon.weapon_fired.connect(add_muzzle_flash)
	flash_time = weapon.weapon_type.weapon_rate_of_fire
	pass

func add_muzzle_flash():
	light.visible = true
	particle.emitting = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false

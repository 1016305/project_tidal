extends Node3D

@onready var weapon: Node3D = $".."

var flash_time

@onready var light: OmniLight3D = $OmniLight3D
@onready var particle: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	Global.weapon_fired.connect(add_muzzle_flash)
	flash_time = weapon.weapon_type.weapon_rate_of_fire
	pass

func add_muzzle_flash():
	var brightness = randf_range(0.6,1.5)
	var light_color = Color.from_rgba8(randf_range(250,255),randf_range(181,186),randf_range(39,43))
	light.light_energy = brightness
	light.light_color = light_color
	
	
	light.visible = true
	particle.emitting = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false

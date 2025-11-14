@tool
extends Node3D

@onready var fire: CPUParticles3D = $CPUParticles3D
@export var fire_billboard: bool = false
@export var smoke_billboard: bool = true
@export_enum ("0","1","2") var collision_modes: String = "1"
@export var fx_scale: float
	
func _process(delta: float) -> void:
	fire.scale_amount_max = fx_scale
	fire.scale_amount_min = fx_scale
	do_fire_billboard()
	do_smoke_billboard()
	do_smoke_particle_collision()
	
func do_fire_billboard():
	if fire_billboard:
		if !self.get_child(0).get_material_override().get_shader_parameter("billboard"):
			self.get_child(0).get_material_override().set_shader_parameter("billboard", true)
	else:
		if self.get_child(0).get_material_override().get_shader_parameter("billboard"):
			self.get_child(0).get_material_override().set_shader_parameter("billboard", false)
			
func do_smoke_billboard():
	if smoke_billboard:
		if !self.get_child(1).draw_pass_1.get_material().get_shader_parameter("billboard"):
			self.get_child(1).draw_pass_1.get_material().set_shader_parameter("billboard", true)
	else:
		if self.get_child(1).draw_pass_1.get_material().get_shader_parameter("billboard"):
			self.get_child(1).draw_pass_1.get_material().set_shader_parameter("billboard", false)

func do_smoke_particle_collision():
	if self.get_child(1).get_process_material().collision_mode != int(collision_modes):
		self.get_child(1).get_process_material().collision_mode = int(collision_modes)

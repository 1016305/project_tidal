class_name Heatsink extends StaticBody3D

var heatsink_hp
var heatsink_max_hp
var is_dead: bool = false
var stop: bool = false
signal heatsink_finished
@export var model: MeshInstance3D
@onready var heatsink_anim: AnimationPlayer = $"../Heatsink_Anim"
@onready var timer: Timer = $"../Timer"
@export var broken_var: MeshInstance3D
@export var lights: Array[OmniLight3D]
@export var explosion_pos: Node3D
const VFX_EXPLOSION = preload("res://scenes/effects/vfx_explosion.tscn")
const FIRE_BILL = preload("res://scenes/effects/fire_bill.tscn")
func take_damage(damage):
	if !is_dead:
		heatsink_hp -= damage
		heatsink_hp_color()
		print("heatsink was shot for ", damage, " damage.")
		if heatsink_hp <= 0:
			is_dead = true
			death_behaviour()

func heatsink_hp_color():
	#current color is 1,1,1. max hp is 100, so we want to make the G and B values = 100-currenthp
	var mat = model.get_surface_override_material(0)
	var new_val = heatsink_hp/heatsink_max_hp
	mat.emission = Color(1,new_val,new_val) #1-(heatsink_hp/heatsink_max_hp)
	model.material_override = mat
	for light in lights:
		light.light_color = Color(1,new_val,new_val)

func heatsink_expose(time):
	heatsink_anim.play("expose_heatsink")
	timer.wait_time = time
	timer.start()
	await timer.timeout
	heatsink_anim.play("retract_heatsink")
	timer.wait_time = 1
	await timer.timeout
	get_parent().get_parent().get_parent().heatsinks_done.emit()

func death_behaviour():
	if !stop:
		stop = !stop
		var explosion = VFX_EXPLOSION.instantiate()
		var smoke = FIRE_BILL.instantiate()
		get_parent().get_parent().add_child(explosion)
		get_parent().get_parent().add_child(smoke)
		smoke.global_position = explosion_pos.global_position
		smoke.global_position += Vector3.DOWN
		explosion.global_position = explosion_pos.global_position
		print("Kaboom! Heatsink destroyed")
		get_parent().get_parent().get_parent().heatsink_destroyed(self)
		broken_var.visible = true
		get_parent().queue_free()
		#this should be an explosion, and a replacement of the heatsink model with the destroyed variant (maybe smoke too?)
		#but for now queue_free is sufficient
		#this should also pass a value to the boss parent to indicate taht this heatsink is no longer functional
func other_heatsink_died():
	if !is_dead:
		timer.stop()
		heatsink_anim.play("retract_heatsink")

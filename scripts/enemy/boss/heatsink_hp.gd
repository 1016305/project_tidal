class_name Heatsinky extends StaticBody3D

var heatsink_hp
var heatsink_max_hp
var is_dead: bool = false
var stop: bool = false
signal heatsink_finished
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var heatsink_anim: AnimationPlayer = $Heatsink_anim
@onready var timer: Timer = $Timer

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
	var mat = StandardMaterial3D.new()
	var new_val = heatsink_hp/heatsink_max_hp
	mat.albedo_color = Color(1,new_val,new_val) #1-(heatsink_hp/heatsink_max_hp)
	csg_box_3d.material_override = mat

func heatsink_expose(time):
	heatsink_anim.play("expose_heatsink")
	timer.wait_time = time
	timer.start()
	await timer.timeout
	heatsink_anim.play("retract_heatsink")
	timer.wait_time = 1
	await timer.timeout
	get_parent().heatsinks_done.emit()

func death_behaviour():
	if !stop:
		stop = !stop
		print("Kaboom! Heatsink destroyed")
		get_parent().heatsink_destroyed(self)
		queue_free()
		#this should be an explosion, and a replacement of the heatsink model with the destroyed variant (maybe smoke too?)
		#but for now queue_free is sufficient
		#this should also pass a value to the boss parent to indicate taht this heatsink is no longer functional
func other_heatsink_died():
	timer.stop()
	heatsink_anim.play("retract_heatsink")

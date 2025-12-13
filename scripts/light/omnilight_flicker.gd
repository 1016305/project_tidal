@tool
extends OmniLight3D

#Max brightness of the light
@export var max_light_energy: float
#Mix brightness of the light
@export var min_light_energy: float
#How fast it will flicker
@export var flicker_speed: float
var random_time: float
var b_time: bool = true


func _process(delta: float) -> void:
	do_time()
	light_energy = lerp(light_energy, random_time, flicker_speed)
	
func do_time():
	if b_time:
		b_time = false
		random_time = randf_range(min_light_energy,max_light_energy)
		await get_tree().create_timer(0.1).timeout
		b_time = true
		
	
	

extends Node3D

@export var left_lights: Array[MeshInstance3D]
@export var right_lights: Array[MeshInstance3D]
var is_active: bool = false

func _ready() -> void:
	turn_off_all_lights(left_lights)
	turn_off_all_lights(right_lights)


func turn_off_all_lights(light_array):
	for u in light_array:
		for i in u.get_children():
			i.visible = false

func turn_on_all_lights(light_array):
	for u in light_array:
		await get_tree().create_timer(1).timeout
		for i in u.get_children():
			print("turned off light " + str(i))
			i.visible = true


func _on_big_door_turn_lights_on() -> void:
	is_active = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if is_active:
		turn_on_all_lights(left_lights)
		turn_on_all_lights(right_lights)
		is_active = false

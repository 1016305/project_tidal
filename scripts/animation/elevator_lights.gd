extends Node3D

@export var omni_lights: Array[OmniLight3D]
@export var spotlights: Array[SpotLight3D]
@export var red_light: OmniLight3D
@export var elevator_material: StandardMaterial3D
@onready var interaction_component: InteractionComponent = $"../StaticBody3D2/Interaction Component"


func _ready() -> void:
	lights_off()
	

func lights_on():
	for light in omni_lights:
		light.light_energy = 1
	for light in spotlights:
		light.light_energy = 16
	red_light.light_energy = 1.597
	elevator_material.emission_enabled = true
	interaction_component.is_used = false

func lights_off():
	for light in omni_lights:
		light.light_energy = 0
	for light in spotlights:
		light.light_energy = 0
	red_light.light_energy = 0
	elevator_material.emission_enabled = false


func _on_door_button_pressed() -> void:
	print("bingus")
	lights_on()

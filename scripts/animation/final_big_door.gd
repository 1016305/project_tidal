extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
#rightlights
@onready var omni_light_3d_3: OmniLight3D = $Cube_002/OmniLight3D3
@onready var omni_light_3d_4: OmniLight3D = $Cube_002/OmniLight3D4
@onready var spot_light_3d_2: SpotLight3D = $Cube_002/SpotLight3D2
#leftlights
@onready var omni_light_3d_2: OmniLight3D = $Cube_001/OmniLight3D2
@onready var spot_light_3d: SpotLight3D = $Cube_001/SpotLight3D
@onready var omni_light_3d: OmniLight3D = $Cube_001/OmniLight3D
#cubes
@onready var cube_001: MeshInstance3D = $Cube_001
@onready var cube_002: MeshInstance3D = $Cube_002
const CREDITS = preload("res://scenes/credits.tscn")

func open_door():
	print("door detects signal")
	turn_on_lights()
	await get_tree().create_timer(2).timeout
	animation_player.play("open_big_door")

func close_door():
	animation_player.play("close_big_door")
	await animation_player.animation_finished
	Global.blur_scene.slow_fade_to_black()
	await get_tree().create_timer(4).timeout
	Global.load_fresh_scene()

func turn_on_lights():
	omni_light_3d_3.visible = true
	omni_light_3d_4.visible = true
	spot_light_3d_2.visible = true
	omni_light_3d_2.visible = true
	omni_light_3d.visible = true
	spot_light_3d.visible = true

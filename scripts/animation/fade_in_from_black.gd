extends Control

@onready var color_rect: ColorRect = $ColorRect
var color_transparent: Color = Color(0,0,0,0)
@export var lerp_speed: float = 0.1

func _ready() -> void:
	wait_a_bit()
	

func _physics_process(delta: float) -> void:
	color_rect.color = lerp(color_rect.color, color_transparent, delta * lerp_speed)
	kill_when_good()

func kill_when_good():
	if color_rect.color.a < 0.01:
		print("fade in delete")
		queue_free()
		
func wait_a_bit():
	await get_tree().create_timer(0.1).timeout
	Global.main_camera.intro_blur_and_exposure()

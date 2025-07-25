extends SubViewport

var screen_size: Vector2

func _ready() -> void:
	#assigns viewport resolution to current window resolution
	screen_size= get_window().size
	size = screen_size

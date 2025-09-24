extends Control
@export var dot_radius = 1.0
@export var dot_color = Color.WHITE
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	var screen = get_viewport().get_visible_rect().size
	texture_rect.position.y = screen.y/3 * 1.6
	

extends CenterContainer
@export var dot_radius = 1.0
@export var dot_color = Color.WHITE

func _ready() -> void:
	var screen = get_viewport().get_visible_rect().size
	position.y = screen.y/3 * 1.6
	
func _draw():
	draw_circle(Vector2(0,0),dot_radius,dot_color)
##whole thing to be rewritten. each weapon will have a custom reticle

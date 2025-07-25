extends CenterContainer
@export var dot_radius = 1.0
@export var dot_color = Color.WHITE

	
func _draw():
	draw_circle(Vector2(0,0),dot_radius,dot_color)

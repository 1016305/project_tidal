extends CenterContainer

@onready var label: VBoxContainer = $"../VBoxContainer"


@onready var line_2d: Line2D = $Line2D
@onready var reticle: CenterContainer = $"../reticle"

var screen: Vector2
func _ready() -> void:
	Global.connect("interact_focus",Callable(self, "show_interact_message"))
	Global.connect("interact_unfocus",Callable(self, "hide_interact_message"))
	refresh_ui("nada")
	

func show_interact_message(comp):
	refresh_ui(comp)
	line_2d.visible = true
	label.visible = true
	
func hide_interact_message():
	line_2d.visible = false
	label.visible = false

func refresh_ui(comp):
	screen = get_viewport().get_visible_rect().size
	var screen_pos = Vector2(screen.x/2,screen.y)
	screen_pos.y = screen_pos.y/3 * 1.56
	line_2d.position = screen_pos
	line_2d.scale = Vector2(percentage(0.01,screen.x),percentage(0.01,screen.x))
	print(line_2d.scale)
	label.position = Vector2(screen_pos.x + screen_pos.x/15,screen_pos.y)
	label.get_child(0).text = comp

	

func percentage(part,whole) -> float:
	return (part * whole) / 100

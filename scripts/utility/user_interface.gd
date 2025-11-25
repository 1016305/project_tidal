extends Control
@onready var damage_indicator: TextureRect = $"Damage Indicator"

func _ready() -> void:
	Global.pause_toggle.connect(toggle_ui)
	damage_indicator.texture.width = get_viewport().get_visible_rect().size.x
	damage_indicator.texture.height = get_viewport().get_visible_rect().size.y
	damage_indicator.texture.fill_from = Vector2(0.5,0.5)
	
func toggle_ui():
	visible = !visible

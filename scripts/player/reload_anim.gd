extends CenterContainer
@onready var reload_label: Label = $"reload label"

func _ready() -> void:
	Global.player_is_reloading.connect(show_reload_message)
	
func show_reload_message():
	reload_label.visible = true
	await get_tree().create_timer(3).timeout
	reload_label.visible = false

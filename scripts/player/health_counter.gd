extends Container
var init: bool = false
@onready var health: Label = $health


func _ready() -> void:
	Global.player_health.connect(handle_health_update)

func handle_health_update(current_health:int, max_health:int):
	var amcn: String = str(current_health) + '|' + str(max_health)
	health.text = amcn

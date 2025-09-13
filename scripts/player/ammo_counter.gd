extends Container
var weapon: Node
var init: bool = false
@onready var ammo: Label = $ammo

func _ready() -> void:
	Global.ammo_update.connect(handle_ammo_update)

func handle_ammo_update(current_ammo:int, max_ammo:int):
	var amcn: String = str(current_ammo) + '|' + str(max_ammo)
	ammo.text = amcn

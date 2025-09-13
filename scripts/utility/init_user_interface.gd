extends Control

@onready var weapon = get_tree().get_root().get_node("weapon")

func _ready() -> void:
	print(weapon)
	#weapon.connect('update_ammo',handle_ammo_update)

func _process(delta: float) -> void:
	#updates the display text (label) every time a shot is fired
	pass

func handle_ammo_update():
	print("SHOT FIRED")

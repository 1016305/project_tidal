extends Node

var debug
#main camera
var main_camera
#player weapon
var player_weapon
#player
var player
signal player_is_assigned

signal ammo_update(current_ammo:int, max_ammo:int)
signal player_is_reloading

signal player_health(current_health:int, max_health:int)

signal interact_focus(message)
signal interact_unfocus

signal pause_toggle

##Settings that can be adjusted
signal get_mouse_sens(sens:float)
signal set_mouse_sens(sens:float)

var _mouse_sens
signal volume(vol:float)


func _ready() -> void:
	self.get_mouse_sens.connect(store_sens)
	self.player_is_assigned.connect(update_sensitivity)
#debug singleton
func store_sens(val):
	_mouse_sens = val
	emit_signal('set_mouse_sens', val)
func update_sensitivity():
	if _mouse_sens != null:
		Global.player.mouse_sens_multiplier = _mouse_sens

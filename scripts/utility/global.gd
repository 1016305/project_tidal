extends Node

var debug
#main camera
var main_camera
#player weapon
var player_weapon
#player
var player

var current_checkpoint_manager
var sound_manager
signal sound_manager_assigned

var current_encounter
signal player_is_assigned

signal ammo_update(current_ammo:int, max_ammo:int)
signal player_is_reloading
signal weapon_fired
signal player_was_hit
signal player_was_healed
signal player_died
signal checkpoint_reached
signal player_respawned

signal player_health(current_health:int, max_health:int)

signal interact_focus(message)
signal interact_unfocus

signal pause_toggle

signal enemy_hit_something(body)
signal enemy_died(enemy)
signal alert_encounter

signal begin_boss
##Settings that can be adjusted
signal get_mouse_sens(sens:float)
signal set_mouse_sens(sens:float)

var _mouse_sens
var _volume
signal volume(vol:float)
var sfx_volume = 100
var dialogue_volume = 100
var music_volume = 100
var master_volume = 50

signal boss_is_dead


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

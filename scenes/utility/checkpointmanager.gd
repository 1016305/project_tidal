extends Node3D

var player_position
var player_health
var player_ammo_c_1
var player_ammo_r_1

var has_checkpoint_been_saved: bool = false

func _ready() -> void:
	Global.current_checkpoint_manager = self

func save_checkpoint():
	Global.checkpoint_reached.emit()
	player_position = Global.player.global_position
	player_health = Global.player.current_health
	player_ammo_c_1 = Global.player_weapon.weapon_type.weapon_current_ammo
	player_ammo_r_1 = Global.player_weapon.weapon_type.weapon_current_ammo
	has_checkpoint_been_saved = true

func respawn_player():
	if has_checkpoint_been_saved:
		Global.player_respawned.emit()
		Global.player.player_head.position = Vector3(0,0.8,0)
		Global.player.player_head.rotation = Vector3(0,0,0)
		Global.player.global_position = player_position
		Global.player.current_health = player_health
		Global.player_weapon.weapon_type.weapon_current_ammo = player_ammo_c_1
		Global.player_weapon.weapon_type.weapon_current_ammo = player_ammo_r_1
		Global.player.main_weapon_node.position = Vector3(0,0,0)
	else:
		get_tree().reload_current_scene()

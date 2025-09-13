extends Node
#debug singleton
var debug
#main camera
var main_camera
#player weapon
var player_weapon
#player
var player

signal ammo_update(current_ammo:int, max_ammo:int)
signal player_is_reloading

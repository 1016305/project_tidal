extends Node3D

@export var model: Mesh
@export var ammo_to_refill: float = 10
@onready var ak_event_3d: AkEvent3D = $AkEvent3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		var player_available = Global.player_weapon.weapon_type.weapon_max_reserve - Global.player_weapon.weapon_type.weapon_reserve_ammo
		if ammo_to_refill <= player_available:
			print('added ',ammo_to_refill," to the player's weapon")
			Global.player_weapon.add_ammo(ammo_to_refill)
			ak_event_3d.post_event()
			queue_free()
		elif player_available == 0:
			print("added no ammo to the player's weapon")
		else:
			ammo_to_refill -= player_available
			print('added ',player_available," to the player's weapon")
			ak_event_3d.post_event()
			Global.player_weapon.add_ammo(player_available)
		#if the ammo pickup is greater than the player can hold
		

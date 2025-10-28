extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.get_distance_to_player() <= actor.enemy_type.melee_distance:
		if actor.enemy_type.enemy_state != "Melee":
			actor.enemy_type.enemy_state == "Melee"
			print("engage melee")
			return SUCCESS
		else:
			return FAILURE
	else:
		return FAILURE

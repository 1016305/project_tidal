extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.get_distance_to_player() <= actor.enemy_type.melee_distance:
		return SUCCESS
	else:
		actor.enemy_type.enemy_state == "Cover"
		return FAILURE

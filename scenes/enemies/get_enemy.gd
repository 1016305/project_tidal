extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.has_player_ref and actor.get_distance_to_player() <= 5:
		return SUCCESS
	else:
		return FAILURE

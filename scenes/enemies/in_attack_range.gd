extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.get_distance_to_player() <= 2:
		return SUCCESS
	else:
		return FAILURE

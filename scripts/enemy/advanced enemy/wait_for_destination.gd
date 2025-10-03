extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.get_distance_to_target() <= 0.5:
		return SUCCESS
	else:
		return RUNNING

extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.cover_state != "Moving To Cover":
		return SUCCESS
	else:
		return FAILURE

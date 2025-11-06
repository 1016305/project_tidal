extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.cover_state != "In Cover":
		actor.enemy_type.cover_state = "Moving to Cover"
		return SUCCESS
	else:
		return FAILURE

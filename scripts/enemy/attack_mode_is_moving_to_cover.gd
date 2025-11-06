extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.cover_state == "Moving To Cover" and actor.enemy_type.enemy_state == "Attack":
		return SUCCESS
	else:
		return FAILURE

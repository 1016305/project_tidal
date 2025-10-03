extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.patrol_type == 'Sequence':
		return SUCCESS
	else:
		return FAILURE

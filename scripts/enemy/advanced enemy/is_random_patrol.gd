extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.patrol_type == 'Random Patrol':
		return SUCCESS
	else:
		return FAILURE

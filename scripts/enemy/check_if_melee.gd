extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.enemy_state == "Melee":
		return SUCCESS
	else:
		return FAILURE

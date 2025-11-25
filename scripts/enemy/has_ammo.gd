extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.weapon_current_ammo > 0:
		return SUCCESS
	else:
		return FAILURE

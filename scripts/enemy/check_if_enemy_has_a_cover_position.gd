extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.current_cover != null:
		print("enemy does NOT have a cover position")
		return FAILURE
	else:
		print("enemy DOES have a cover position")
		return SUCCESS

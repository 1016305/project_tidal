extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.find_cover(false,true):
		actor.update_target_location(actor.enemy_type.current_cover)
		print("found good cover *+")
		return SUCCESS
	else:
		print("did not find cover, searching again with expanded parameters")
		return FAILURE

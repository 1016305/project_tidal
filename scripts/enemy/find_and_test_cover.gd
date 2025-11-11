extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.find_cover(false,false):
		actor.update_target_location(actor.enemy_type.current_cover)
		actor.enemy_type.cover_state = "Moving To Cover"
		print("found good cover")
		return SUCCESS
	else:
		print("did not find cover, searching again")
		return FAILURE

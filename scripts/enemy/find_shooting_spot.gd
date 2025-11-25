extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.find_cover(true,false):
		actor.update_target_location(actor.enemy_type.current_cover)
		actor.enemy_type.cover_state = "Moving to Cover"
		print("Found a spot to shoot from")
		return SUCCESS
	else:
		print("Did not find a spot to shoot from")
		return FAILURE

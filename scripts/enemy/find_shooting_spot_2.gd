extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.find_cover(true,true):
		actor.update_target_location(actor.enemy_type.current_cover)
		print("Found a spot to shoot from+*")
		return SUCCESS
	else:
		print("Did not find a spot to shoot from+*")
		return FAILURE

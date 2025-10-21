extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.test_found_cover(actor.enemy_type.current_cover, false, false):
		print("yes cover is still good")
		return SUCCESS
	else:
		print("no i can see the player")
		return FAILURE

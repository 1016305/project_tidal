extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.update_target_location(actor.get_random_spot())
	return SUCCESS

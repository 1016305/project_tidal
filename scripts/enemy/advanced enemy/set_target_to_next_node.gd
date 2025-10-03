extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.update_target_location(actor.next_target_in_sequence())
	return SUCCESS

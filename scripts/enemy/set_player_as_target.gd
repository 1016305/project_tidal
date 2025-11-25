extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.update_target_location(actor.player.position)
	print("plaer is target")
	return SUCCESS

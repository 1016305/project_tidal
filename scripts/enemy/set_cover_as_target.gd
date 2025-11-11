extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.update_target_location(actor.enemy_type.current_cover)
	print("attempting to set cover as target")
	return SUCCESS

extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.enemy_type.cover_state = "Moving To Cover"
	return SUCCESS

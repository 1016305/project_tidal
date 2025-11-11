extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.enemy_type.enemy_state = "Cover"
	actor.enemy_type.cover_state = "Not in Cover"
	return SUCCESS

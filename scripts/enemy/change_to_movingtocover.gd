extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.enemy_type.enemy_state = "MovingToCover"

	return SUCCESS

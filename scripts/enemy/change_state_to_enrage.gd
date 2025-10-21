extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.enemy_type.enemy_state = "Enrage"
	print("cannot find spot to move, enrage")
	return SUCCESS

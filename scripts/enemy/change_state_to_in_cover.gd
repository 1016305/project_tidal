extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	#actor.enemy_type.enemy_state = "Attack"
	actor.enemy_type.cover_state = "In Cover"
	print("BRUH")
	return SUCCESS

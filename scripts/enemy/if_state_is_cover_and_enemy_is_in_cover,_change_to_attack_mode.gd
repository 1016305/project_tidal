extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.enemy_type.enemy_state == "Cover":
		if actor.enemy_type.cover_state == "In Cover":
			actor.enemy_type.enemy_state = "Attack"
			print("enemy state: ", actor.enemy_type.enemy_state)
			return SUCCESS
		else:
			return FAILURE
	else:
		return FAILURE
			

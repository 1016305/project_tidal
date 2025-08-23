extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.die()
	return SUCCESS

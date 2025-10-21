extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.find_cover(false,true):
		print("looking for cover under standard params")
		return SUCCESS
	else:
		print("did not find cover, searching again with expanded parameters")
		return FAILURE

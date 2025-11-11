extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	var diceroll = randi_range(0,1)
	if diceroll == 0:
		#set target as old cover
		print("target is the old cover")
		return SUCCESS
	if diceroll == 1:
		#a new cover will be selected
		print("target is the new cover")
		return FAILURE
	else:
		return FAILURE

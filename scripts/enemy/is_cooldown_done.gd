extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.shoot_cooldown.is_stopped():
		print("time stopped")
		actor.shoot_cooldown.start()
		return SUCCESS
	else:
		return FAILURE

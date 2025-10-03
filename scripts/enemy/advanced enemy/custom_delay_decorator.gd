extends DelayDecorator

var first_time: bool = true

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if first_time:
		wait_time = 0.5 #enemies will always start with the idle delay. this just skips it for the initial run. 0.5s to account for loading
		first_time = !first_time
	else:
		wait_time = actor.enemy_type.patrol_wait_time
	return super.tick(actor,_blackboard)

extends DelayDecorator

var first_time: bool = true

func tick(actor:Node, _blackboard:Blackboard) -> int:
	wait_time = randf_range(1,5)
	return super.tick(actor,_blackboard)

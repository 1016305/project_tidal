extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if !actor.is_player_in_view_range():
		return SUCCESS
	if !actor.can_see_player():
		return SUCCESS
	else:
		actor.enemy_type.enemy_state = "Cover"
		return FAILURE

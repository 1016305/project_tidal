extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.shoot(actor.enemy_type.weapon_rate_of_fire * actor.enemy_type.moving_rof_penalty, actor.enemy_type.weapon_accuracy * actor.enemy_type.moving_acc_penalty)
	return SUCCESS

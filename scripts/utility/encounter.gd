class_name EnemyEncounter extends Node3D

var is_done: bool = false
@export var wave: Array[DumbEnemy]
var enemies_killed: int = 0
enum WhatNext{DoThing1,DoThing2,DoThing3,DoThing4}
@export var end_encounter_action: WhatNext

func _ready() -> void:
	Global.current_encounter = self
	Global.enemy_died.connect(enemy_died)
	Global.alert_encounter.connect(alert_all_enemies_in_encounter)

func _physics_process(delta: float) -> void:
	if enemies_killed >= wave.size():
		encounter_clear()
		
func encounter_clear():
	if !is_done:
		is_done = !is_done
		for enemy in wave:
			enemy.queue_free()
		print(end_encounter_action)

func enemy_died(enemy):
	if wave.has(enemy):
		enemies_killed +=1

func alert_all_enemies_in_encounter():
	for fella in wave:
		fella.global_alert()

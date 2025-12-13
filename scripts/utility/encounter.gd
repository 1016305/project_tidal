class_name EnemyEncounter extends Node3D

var is_done: bool = false
@export var wave: Array[DumbEnemy]
var enemies_killed: int = 0
var enemies_alerted: bool = false
enum WhatNext{DoThing1,DoThing2,DoThing3,DoThing4}
@export var end_encounter_action: WhatNext
@export var is_boss: bool = false
const DUMB_ENEMY = preload("res://scenes/enemies/dumb_enemy.tscn")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !is_boss:
		check_wave_progress()
	if Input.is_action_just_pressed("test_damage"):
		kill_all_enemies()
		
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
	if !enemies_alerted:
		for fella in wave:
			if fella != null:
				fella.global_alert()
		enemies_alerted = true

func check_wave_progress():
	if enemies_killed >= wave.size():
		encounter_clear()

func set_encounter():
	Global.current_encounter = self
	Global.enemy_died.connect(enemy_died)
	Global.alert_encounter.connect(alert_all_enemies_in_encounter)

func spawn_enemy(pos):
	var new_enemy = DUMB_ENEMY.instantiate()
	get_tree().root.add_child(new_enemy)
	new_enemy.set_state_to_attack()
	new_enemy.origin_override = true
	new_enemy.origin_override_coord = Vector3(-366,-128,-973)
	new_enemy.global_position = pos
	wave.append(new_enemy)

func check_alive_enemies(limit) -> bool:
	var e = 0
	for fella in wave:
		if fella != null:
			if fella.dead_bool:
				e+=1
	print("Enemies in array: ",wave.size())
	print("Enemies dead: ",e)
	if e >= wave.size() - limit:
		return true
	else:
		return false

func kill_all_enemies():
	print("kill jester")
	for fella in wave:
		if fella != null:
			print("fella killed")
			fella.current_hp = 0

class_name Enemy extends CharacterBody3D
#enemy ai npc main script
#all the shit they can do is stored in here ok
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var speed: float = 5
var _target = Vector3(19,0,-5)
#set player ref to self until it can be loaded form the singleton. prevebnts crashing
var player_ref = self
var has_player_ref: bool = false
var player_loc: Vector3
var health: float = 100
var is_dead: bool = false

func _ready() -> void:
	update_target_location(_target)
func _physics_process(delta: float) -> void:
	get_player_ref()
	player_loc = get_player_location()
	move_to_point()
	move_and_slide()

func get_random_spot() -> Vector3:
	var random_pos = Vector3(randf_range(-10,10),0,randf_range(-10,10))
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, random_pos)
	return here

func move_to_point():
	var cur_pos = global_transform.origin
	var next_pos = agent.get_next_path_position()
	var new_vel = (next_pos - cur_pos).normalized() * speed
	velocity = new_vel
	_target.y = position.y

func toggle_navigation(b: bool):
	if b:
		speed = 5
	else:
		speed = 0

func get_distance_to_target() -> float:
	return agent.distance_to_target()

func get_player_location() -> Vector3:
	return player_ref.global_position

func get_distance_to_player() -> float:
	return global_position.distance_to(player_loc)

func get_player_ref():
	if !has_player_ref:
		if player_ref == self:
			if Global.player == null:
				has_player_ref = false
			elif Global.player != null:
				player_ref = Global.player
				has_player_ref = true
				
func update_target_location(target):
	agent.set_target_position(target)

func take_damage(dmg):
	health -= dmg
	if health <= 0:
		is_dead = true
func die():
	var mat = mesh.get_active_material(0)
	mat.albedo_color = Color.RED

class_name Advanced_Enemy extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D

@export var enemy_type: advanced_test_enemy

var origin: Vector3
var target = Vector3.ZERO

var look_target_location: Vector3
var look_target_rotation: Basis
var rotation_lerp: float = 0.0

var enable_navigation: bool = true
var current_sequence_target: int = 0
var next_target: int
var await_frame = false
var speed: float

func _ready() -> void:
	#sanity checks
	force_map()
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")
	speed = enemy_type.move_speed

	if enemy_type == null:
		print('Please assign an enemy type, or create a new one.')
	if enemy_type.patrol_type == '':
		print('Invalid or none patrol type selected.')
	store_origin()
	set_target_from_first_node()

func _physics_process(delta: float) -> void:
	move_to_point()
	move_and_slide()
	handle_gravity(delta)
	face_target(delta)

#----------------------------------------------------------------------#

#godot hates beehave when it falls the process too fast
func dump_first_physics_frame():
	await get_tree().physics_frame
	set_physics_process(true)
	await_frame = true

#force a map refresh. why is this a function? good question
func force_map():
	NavigationServer3D.map_force_update(agent.get_navigation_map())

func store_origin():
	origin = global_position

#----------------------------------------------------------------------#

func handle_gravity(delta):
	if not is_on_floor():
		velocity += Vector3(0,-15,0) * delta

#------------STOLEN FROM VICTORKARP.COM--------------------------------#
#https://victorkarp.com/godot-engine-rotating-a-character-with-transform-basis-slerp/
#i still suck at rotating shit. this was the best solution i could find

func set_target_location(new_target: Vector3):
	look_target_location = new_target
	rotation_lerp = 0

func rotate_player(delta):
	set_target_location(agent.get_next_path_position())
	if rotation_lerp < 1:
		rotation_lerp += delta * enemy_type.rotate_speed
	elif rotation_lerp > 1:
		rotation_lerp = 1
	transform.basis = transform.basis.slerp(look_target_rotation, rotation_lerp).orthonormalized()
	
func face_target(delta):
	look_target_location.y = transform.origin.y
	if look_target_location != transform.origin:
		look_target_rotation = transform.looking_at(look_target_location,Vector3.UP).basis
		rotate_player(delta)

#----------------------END STOLEN FROM VICTORKARP.COM------------------#

func set_target_from_first_node():
	if enemy_type.patrol_points != null:
		target = get_node(enemy_type.patrol_points[0])

		pass
	else:
		print("No targets set.")

#gets a random spot within the range of the navmesh -> within the set patrol range
func get_random_spot() -> Vector3:
	if await_frame:
		var random_pos = Vector3(randf_range(-enemy_type.random_patrol_range,enemy_type.random_patrol_range),0,randf_range(-enemy_type.random_patrol_range,enemy_type.random_patrol_range))
		var map = agent.get_navigation_map()
		var here = NavigationServer3D.map_get_closest_point(map, random_pos)
		print(here)
		return here
	else:
		return position

func next_target_in_sequence() -> Vector3:
	var number_of_points = len(enemy_type.patrol_points) - 1
	if next_target < number_of_points:
		next_target+=1
	else:
		next_target = 0
	print(next_target)
	var node = get_node(enemy_type.patrol_points[next_target])

	#print(node.position)
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, node.position) #node.position when using the other nodes
	return here
	
func random_target_in_sequence() -> Vector3:
	var number_of_points = len(enemy_type.patrol_points) - 1
	var rand_next = 0
	if rand_next == current_sequence_target:
		rand_next = randi_range(0,number_of_points)
	var node = get_node(enemy_type.patrol_points[rand_next])
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, node.position) #node.position when using the other nodes
	return here

#moves the agen to the target point
func move_to_point():
	var cur_pos = global_transform.origin
	var next_pos = agent.get_next_path_position()
	var new_vel = (next_pos - cur_pos).normalized() * speed
	velocity = new_vel

#toggles whether or not the agent can move
func toggle_navigation(b: bool):
	if b:
		speed = enemy_type.move_speed
	else:
		speed = 0

#changes the target location to one specified
func update_target_location(target):
	agent.set_target_position(target)

#returns distance to target
func get_distance_to_target() -> float:
	return agent.distance_to_target()

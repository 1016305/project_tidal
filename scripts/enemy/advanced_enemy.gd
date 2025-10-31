class_name Advanced_Enemy extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@export var enemy_type: advanced_test_enemy
@onready var melee_raycast: RayCast3D = $MeleeRaycast
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var shoot_cooldown: Timer = $"Shoot Cooldown"
var last_state
var flip_state: bool = false

var origin: Vector3
var target = Vector3.ZERO
var player

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
	Global.player_is_assigned.connect(assign_player)
	shoot_cooldown.wait_time = enemy_type.weapon_rate_of_fire
	print(enemy_type.enemy_state)

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
	combat_check()
	melee_check()
	test_damage()
	debug()
	#print(enemy_type.enemy_state)

#----------------------------------------------------------------------#
func assign_player():
	player = Global.player

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
	
func get_player():
	if player == null:
		player = Global.player

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
		var random_pos = origin + random_vector(enemy_type.min_random_patrol_range, enemy_type.max_random_patrol_range)
		var map = agent.get_navigation_map()
		var here = NavigationServer3D.map_get_closest_point(map, random_pos)
		print(here)
		return here
	else:
		return position

#select the next node in the node group
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

#select a random node in the node group
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

#returns distance to player without resetting the target
func get_distance_to_player() -> float:
	return position.distance_to(player.position)

func get_direction_from_angle(angle_in_degrees: float) -> Vector3:
	var angle_in_rad = deg_to_rad(angle_in_degrees)
	var dir = Vector3(0,sin(angle_in_rad),cos(angle_in_rad))
	return dir

func is_player_in_view_range() -> bool:
	if position.distance_to(player.position) < enemy_type.view_radius:
		return true
	else:
		return false

func can_see_player() -> bool:
		#var direction_to_player: Vector3 = (player.position - position).normalized()
		#var angle = position.signed_angle_to(direction_to_player,transform.basis.z)
		#var angle = transform.basis.z.angle_to(direction_to_player)
	var dir: Vector3 = global_position.direction_to(player.global_position)
	var angle: float = global_transform.basis.z.signed_angle_to(dir, Vector3.UP)
	angle = abs(rad_to_deg(angle))
	#directly in front of the enemy is 180. directly behind them is 0. L and R both sign 90
	if angle > 180 - enemy_type.view_angle_degrees/2 and is_player_in_view_range():
		return true
	else:
		return false

func player_alert_distance() -> bool:
	if position.distance_to(player.position) < enemy_type.alert_proximity_range:
		return true
	else:
		return false

func combat_check():
	if can_see_player() or player_alert_distance() and enemy_type.enemy_state == "Idle":
		enemy_type.enemy_state = "Cover"

func melee_check():
	if get_distance_to_player() <= enemy_type.melee_distance:
		if enemy_type.enemy_state != "Melee":
			enemy_type.enemy_state = "Melee"

func enemy_alert():
	var randy = randi_range(0,2)
	if randy == 0:
		enemy_type.enemy_state = "Cover"
	elif randy == 1:
		enemy_type.enemy_state = "Attack"
	elif randy == 2:
		enemy_type.enemy_state = "Melee"

func melee():
	melee_raycast.target_position = Vector3(0,0,-enemy_type.melee_range)
	if melee_raycast.get_collider() == player:
		player.damage(enemy_type.melee_damage)

func take_damage(dmg):
	enemy_type.health -= dmg
	if enemy_type.health <= 0:
		enemy_type.enemy_state = "Dead"

## Bool: Should the enemy see the player from cover? Bool: Are we using the expanded targeting parameters?
func find_cover(should_see_player, expanded_parameters) -> bool:
	#get a random position, and target it on the navmesh
	var random_pos = position + random_vector(enemy_type.min_seek_cover_range,enemy_type.max_seek_cover_range)
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, random_pos)
	print("cover is: ", here)
	print("target is: ", agent.target_position)
	var midpoint = collider.shape.height/2
	var uhere = here + Vector3(0,midpoint,0) #needs to be half the height of the collision shape, could potentially changed based on enemy type tho
	#if test_found_cover(enemy_type.current_cover,should_see_player,expanded_parameters):
	enemy_type.current_cover = here
	if test_found_cover(uhere,should_see_player,expanded_parameters) == true or false:
		return test_found_cover(uhere,should_see_player,expanded_parameters)
	else:
		return false

func test_found_cover(where_cover, should_see_player, expanded_parameters):
	#raycast from the potential find cover spot to where the player is, return result
	#copied from the shoot script so whatever
	#this checks if all the conditions are met as well
	var origin = where_cover
	var end = player.player_head.global_position
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	var can_reach = agent.is_target_reachable()
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		print(collision.collider)
		if collision.collider == player and should_see_player:
			if targeting_parameters(expanded_parameters) and can_reach:
				return true
			else:
				return false
		elif collision.collider != player and !should_see_player:
			if targeting_parameters(expanded_parameters) and can_reach:
				return true
			else:
				return false
		else:
			return false

func targeting_parameters(expanded_parameters) -> bool:
	#if the target meets all the conditions, return true
	var too_close_player
	var too_far_player
	var too_close_enemy
	#check if enemy is too close
	if enemy_type.current_cover.distance_to(player.position) < enemy_type.min_cover_dist_p if !expanded_parameters else enemy_type.min_cover_dist_p * 1.5:
		too_close_player = true
	else:
		too_close_player = false
	#check if enemy is too far
	if enemy_type.current_cover.distance_to(player.position) > enemy_type.max_cover_dist_p if !expanded_parameters else enemy_type.min_cover_dist_p * 1.5:
		too_far_player = true
	else:
		too_far_player = false
	if !too_close_player and !too_far_player:
		print("THIS POSITION IS VALID")
		return true
	else:
		print("too close to player? ", too_close_player)
		print("too far from player? ", too_far_player)
		return false
	#check if other enemies are too close

func shoot():
	#var target = player.position
	shoot_cooldown.start()
	await get_tree().create_timer(0.1).timeout
	var origin = position + Vector3(0,1,0)
	var end = player.player_head.global_position
	end += Vector3(randf_range(-enemy_type.weapon_accuracy,enemy_type.weapon_accuracy),randf_range(-enemy_type.weapon_accuracy,enemy_type.weapon_accuracy),randf_range(-enemy_type.weapon_accuracy,enemy_type.weapon_accuracy))
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	test_draw_ray(collision)
	if collision:
		if collision.collider == player:
			print("shot the player")
	#get player position from player
	#add random variance to position via enemy accuracy
	#shoot raycast at player
	
func test_draw_ray(collision):
	#trying to use this to visualise the fuckass raycast
	var poly = CSGPolygon3D.new() #poly needs path
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	poly.position += Vector3.UP
	poly.scale = Vector3(0.2,0.2,1)
	poly.mode = CSGPolygon3D.MODE_DEPTH
	poly.depth = get_distance_to_player()
	if collision.collider == player:
		poly.material = mat
	add_child(poly)
	poly.look_at(player.player_head.global_position)
	await get_tree().create_timer(1).timeout
	poly.queue_free()

#random 2d unit vector within range given. taken from u/angelonit on reddit
#additional instruction for 3d random unit vector from cameron
func random_vector(min,max) -> Vector3:
	var theta: float = randf() * 2 * PI
	#var phi: float = randf_range((PI/2),(-PI/2)
	var newvec: Vector3 = Vector3(cos(theta),0,sin(theta)) * sqrt(randf_range(min,max))
	#var newvec: Vector3 = Vector3((cos(theta) * sin(phi)),(cos(phi)), (sin(theta) * sin(phi))) * sqrt(randf_range(min,max)
	return newvec

func test_damage():
	if Input.is_action_just_pressed("test_damage"):
		#shoot()
		#find_cover(false,false)
		#agent.target_position = enemy_type.current_cover
		pass
func debug():
	Global.debug.add_property('Enemy Main State', enemy_type.enemy_state, 1)
	Global.debug.add_property('Enemy Cover State', enemy_type.cover_state, 1)

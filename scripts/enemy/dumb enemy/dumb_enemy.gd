class_name DumbEnemy extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var shoot_delay_timer: Timer = $shoot_delay
@onready var melee_raycast: RayCast3D = $melee_raycast
@onready var cover_timer: Timer = $cover_timer
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var origin: Vector3
var await_frame: bool
var player
const BULLET = preload("res://scenes/enemies/bullet.tscn")
signal shooting_done

@export_category("Primary Logic")
enum States{None,Idle,Alert,Attack,MoveToCover,Cover,MoveFromCover,Melee,Dead}
@export var current_state: States
@export var max_hp: int = 50
@export var current_hp: int
@export var speed: float = 5
@export var rotation_speed  = 4
##Set this to true for the enemy to look at their patrol path destination, set to false to look at the player.
@export var do_look_at_target: bool = true
var look_target_location: Vector3
var look_target_rotation: Basis
var rotation_lerp: float = 0.0

@export_category("Secondary Logic | Alert Conditions")
##How close the player can get to the enemy before the enemy is alerted, no matter where the enemy is looking.
@export var abs_alert_distance: float = 3.5
##Enemy FOV view cone
@export var view_angle_degrees: float = 90
##Enemy FOV view distance
@export var view_radius: float = 20
## How far away the enemy can be from the player before they hear their shots
@export var gunshot_alert_dist: float = 30

@export_category("Secondary Logic | Alert")
var alert_bool: bool = false

@export_category("Secondary Logic | Patrol")
enum PatrolStates{RandomPatrol,Sequence,RandomSequence}
##Control the current patrol behaviours.
@export var current_patrol_state: PatrolStates
##Minimum distance from the origin that the enemy can travel
@export var random_patrol_min_dist: float = 0
##maximum distance from the origin that the enemy can travel
@export var random_patrol_max_dist: float = 50
##Array of patrol point nodes the enemy will travel between
@export var patrol_points: Array[NodePath]
##How long the enemy will wait before going to the next patrol point.
@export var wait_time: float = 2
var patrol_bool: bool = false
var next_target: int = 1

@export_category("Secondary Logic | Attack")
var has_shot: bool = false
## Rate of fire in rounds per min
@export var rate_of_fire: float = 120 
## Accuracy of the enemy per shot
@export var accuracy: float = 1
## Minimum number of shots per volley
@export var shots_fired_min: float = 1
## Maximum number of shots per volley
@export var shots_fired_max: float = 10
## Min damage range dealt by this enemy
@export var min_damage: float = 5
## Max damage range dealt by this enemy
@export var max_damage: float = 10
var shots_taken: int = 0

@export_category("Secondary Logic | Find Cover")
## Minimum distance in which to search for cover
@export var min_cover_search: float = 1
## Maximum distance in which to search for cover
@export var max_cover_search: float = 50
## Number of attempts to find cover
@export var find_cover_attempts: int = 10
var current_cover: Vector3
var move_to_cover_bool: bool = false

@export_category("Secondary Logic | In Cover")
## Minimum time (sec) the enemy will spend in cover
@export var cover_time_min: float = 1
## Maximum time (sec) the enemy will spend in cover
@export var cover_time_max: float = 5
var in_cover: bool = false

@export_category("Secondary Logic | Out of Cover")
## Number of attempts to find an area where the player cna be seen
var find_ground_attempts: int = 10
var move_to_ground_bool = false

@export_category("Secondary Logic | Melee")
## How close the player must be before the enemy decides to go into melee mode
@export var melee_aggro_dist: float = 5
## Enemy melee range
@export var melee_range: float = 2
## The minimum melee damage the enemy deals
@export var min_melee_damage: float = 10
## The maximum melee damage the enemy deals
@export var max_melee_damage: float = 15
## How long after the enemy stop moving until it melees the player (seconds)
@export var melee_delay: float = 0.3
## How long after the melee until the enemy moves again #maybe this is replaced with an animation?
@export var melee_cooldown: float = 1
var melee_bool: bool = false
var last_state: States

@export_category("Secondary Logic | Death and Damage")
var dead_bool: bool = false

var debug_bool: bool = false

func _ready() -> void:
	Global.player_is_assigned.connect(assign_player)
	Global.enemy_hit_something.connect(enemy_hit_something)
	Global.weapon_fired.connect(alert_from_weapon_fire)
	force_map()
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")
	origin = global_position
	shoot_delay_timer.wait_time = 60/rate_of_fire
	melee_raycast.target_position = Vector3(0,0,-melee_range)
	current_hp = max_hp
	animation_player.play("idle_animation")

func _physics_process(delta: float) -> void:
	main_behaviour()
	move_and_slide()
	move_to_point()
	face_target(delta)
	handle_gravity(delta)
	death_check()
	debug()

func main_behaviour():
	if await_frame:
		match current_state:
			States.None:
				the_big_alert_check()
			States.Idle:
				idle_behavior()
				the_big_alert_check()
			States.Alert:
				alert()
			States.Attack:
				attack()
				melee_check()
			States.MoveToCover:
				move_to_cover(find_cover_attempts,false)
				melee_check()
			States.Cover:
				cover()
				see_player()
				melee_check()
			States.MoveFromCover:
				move_from_cover(find_ground_attempts,true)
				melee_check()
			States.Melee:
				melee()
				melee_check()
			States.Dead:
				dead()

## Idle behaviours
func idle_behavior():
	match current_patrol_state:
		PatrolStates.RandomPatrol:
			if !patrol_bool:
				patrol_bool = !patrol_bool
				agent.set_target_position(get_random_spot())
				await agent.navigation_finished
				await get_tree().create_timer(wait_time).timeout
				patrol_bool = !patrol_bool
		PatrolStates.Sequence:
			if !patrol_bool:
				patrol_bool = !patrol_bool
				agent.set_target_position(next_target_in_sequence())
				await agent.navigation_finished
				await get_tree().create_timer(wait_time).timeout
				patrol_bool = !patrol_bool
		PatrolStates.RandomSequence:
			if !patrol_bool:
				patrol_bool = !patrol_bool
				agent.set_target_position(random_target_in_sequence())
				await agent.navigation_finished
				await get_tree().create_timer(wait_time).timeout
				patrol_bool = !patrol_bool

#returns random position on unit circle scaled within the min/max range
func get_random_spot() -> Vector3:
	var random_pos = origin + random_vector(random_patrol_min_dist, random_patrol_max_dist)
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, random_pos)
	return here

#cycles through the array of patrol nodes
func next_target_in_sequence() -> Vector3:
	var number_of_points = len(patrol_points) - 1
	if next_target < number_of_points:
		next_target+=1
	else:
		next_target = 0
	var node = get_node(patrol_points[next_target])

	#print(node.position)
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, node.position) #node.position when using the other nodes
	return here
	
#select a random node in the node group
func random_target_in_sequence() -> Vector3:
	var number_of_points = len(patrol_points) - 1
	var rand_next = 0
	if rand_next == next_target:
		rand_next = randi_range(0,number_of_points)
	var node = get_node(patrol_points[rand_next])
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, node.position) #node.position when using the other nodes
	return here

## Alert Detection Behaviours
#check for alert range
func the_big_alert_check():
	if is_player_too_close():
		current_state = States.Alert
	elif can_see_player():
		current_state = States.Alert

func is_player_too_close():
	if position.distance_to(player.position) < abs_alert_distance:
		return true
	else:
		return false

func can_see_player():
	var dir: Vector3 = global_position.direction_to(player.global_position)
	var angle: float = global_transform.basis.z.signed_angle_to(dir, Vector3.UP)
	angle = abs(rad_to_deg(angle))
	#directly in front of the enemy is 180. directly behind them is 0. L and R both sign 90
	if angle > 180 - view_angle_degrees/2 and is_player_in_view_range():
		return true
	else:
		return false

func is_player_in_view_range() -> bool:
	if position.distance_to(player.position) < view_radius:
		return true
	else:
		return false

## Alert Behhaviours
func alert():
	if !alert_bool:
		alert_bool = !alert_bool
		#stop moving
		agent.target_position = position
		#face the player
		do_look_at_target = false
		#play a little animation
		##This is where you call the alert animation
		var mat = mesh.get_surface_override_material(0)
		var tween = get_tree().create_tween()
		tween.tween_property(mat, "albedo_color", Color.YELLOW, 2)
		await tween.finished
		var shoot_or_cover = randi_range(1,20)
		if shoot_or_cover % 2 == 0:
			current_state = States.Attack
			print(shoot_or_cover)
		else:
			current_state = States.MoveToCover
			print(shoot_or_cover)

		#play a little sound or two
		#emit a signal to alert all the enemies of the enounter

## Attack Behaviours
func attack():
	#stand still
	agent.target_position = position
	#shoot at player rand(x) number of times
	shoot_loop(randi_range(shots_fired_min,shots_fired_max),(60/rate_of_fire))
	#change to MovingToCover

func shoot_loop(i,rate):
	#if !has_shot:
		#has_shot = !has_shot
		#var u:int = i
		#if u <=0:
			#current_state = States.MoveToCover
			#return
		#else:
			#alternate_shoot()
			#get_tree().create_timer(rate).timeout.connect(shoot_loop.bindv([u-1,rate]))
			#print("u is: ",u)
			
	if !has_shot:
		shoot_delay_timer.start()
		has_shot = !has_shot
		for u in range(i):
			alternate_shoot()
			print(u, "/", i)
			await shoot_delay_timer.timeout
		print("shooting done. changing to cover")
		current_state = States.MoveToCover
		has_shot = !has_shot
		shoot_delay_timer.stop()

func alternate_shoot():
	var active_bullet = BULLET.instantiate()
	get_tree().root.add_child(active_bullet)
	var end = Vector3(randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy))
	var rotaty: Vector3 = Vector3(rotation.x, rotation.y + end.y, rotation.z + end.z)
	active_bullet.rotation = rotaty
	active_bullet.position = global_position
	active_bullet.position += Vector3(-sin(deg_to_rad(rotation_degrees.y)),0 , -cos(deg_to_rad(rotation_degrees.y))) * 2

func shoot(accuracy):
	var origin = position + Vector3(0,1,0)
	var end = player.player_head.global_position
	end += Vector3(randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy))
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	test_draw_ray(collision)
	print("shot was fired")
	if collision:
		if collision.collider == player:
			print("shot hit the player")
	#get player position from player
	#add random variance to position via enemy accuracy
	#shoot raycast at player
	
func test_draw_ray(collision):
	#trying to use this to visualise the fuckass raycast
	var poly = CSGPolygon3D.new() #poly needs path
	var mat = StandardMaterial3D.new()
	var mat2 = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat2.albedo_color = Color.GREEN
	poly.position += Vector3.UP
	poly.scale = Vector3(0.2,0.2,1)
	poly.mode = CSGPolygon3D.MODE_DEPTH
	poly.depth = position.distance_to(player.position)
	if collision:
		if collision.collider == player:
			poly.material = mat
		else:
			poly.material = mat2
	add_child(poly)
	poly.look_at(player.player_head.global_position)
	await get_tree().create_timer(1).timeout
	poly.queue_free()
	
func enemy_hit_something(body):
	if body == player:
		player.damage(randi_range(min_damage,max_damage))
		#print("I hit the player")
	#print("I hit the ",body)

## Go to cover behaviour
#temp function kill it
func move_to_cover(attempts,see_player):
	if !move_to_cover_bool:
		move_to_cover_bool = !move_to_cover_bool
		#here we need to run "find cover" x number of times until it returns true. if it still returns false, get the position of the last cover and move there anyway
		find_cover_loop(attempts,see_player)
		await agent.target_reached
		current_state = States.Cover
		move_to_cover_bool = !move_to_cover_bool

func find_cover_loop(i,see_player):
	for u in range(i):
		print("performing search ",u," for cover")
		if find_cover(see_player):
			print("Found cover on search number ",u)
			break
	agent.set_target_position(current_cover)
	#do_look_at_target = true

# get a random spot on the navmesh, and check if the play has line of sight
func find_cover(see_player):
	var random_pos =  position + random_vector(min_cover_search,max_cover_search)
	var map = agent.get_navigation_map()
	var here = NavigationServer3D.map_get_closest_point(map, random_pos)
	var midpoint = collider.shape.height/2
	here = here + Vector3(0,midpoint,0) #makes the target point half the height of the enemy collider. crappy estimation of line of sight
	current_cover = here
	return test_cover(here, see_player)

func test_cover(where, should_see_player) -> bool:
	var origin = where
	var end = player.player_head.global_position
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	var can_reach = agent.is_target_reachable()
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		if collision.collider == player:
			if should_see_player:
				print("I should see the player, and I can see the player.")
				return true
			else:
				print("I should not see the player, but I can.")
				return false
		elif collision.collider != player:
			if should_see_player:
				print("I should see the player, but I cannot.")
				return false
			else:
				print("I should not see the player, and a cannot.")
				return true
		else:
			print("Collision did not hit a player or anything else.")
			return false
	else:
		print("Collision did not hit anything.")
		return false

## Cover Behaviours
func cover():
	if !in_cover:
		in_cover = !in_cover
		cover_timer.wait_time = randf_range(cover_time_min,cover_time_max)
		cover_timer.start()
		await cover_timer.timeout
		if test_cover(position,true):
			current_state = States.Attack
		else:
			current_state = States.MoveFromCover
		in_cover = !in_cover
func see_player():
	if in_cover:
		if test_cover(position,true):
			cover_timer.stop()
			cover_timer.emit_signal("timeout")
	
## Move from cover behaviour
func move_from_cover(attempts,see_player):
	if !move_to_ground_bool:
		move_to_ground_bool = !move_to_ground_bool
		#here we need to run "find cover" x number of times until it returns true. if it still returns false, get the position of the last cover and move there anyway
		find_cover_loop(attempts,see_player)
		await agent.target_reached
		current_state = States.Attack
		move_to_ground_bool = !move_to_ground_bool

## Melee Behaviours
	#all non idle or alert should have this check!
	#if player is within x distance do melee stuff
	#if not, go to last state
func melee_check():
	if position.distance_to(player.position) <= melee_aggro_dist:
		if current_state != States.Melee:
			last_state = current_state
			current_state = States.Melee
	else:
		if current_state == States.Melee:
			current_state = last_state

func melee():
	if !melee_bool:
		melee_bool = !melee_bool
		agent.target_position = player.position
		if position.distance_to(player.position) <= melee_range:
			agent.target_position = position
			await get_tree().create_timer(melee_delay).timeout
			if melee_raycast.get_collider() == player:
				player.damage(randi_range(min_melee_damage,max_melee_damage))
				await get_tree().create_timer(melee_cooldown).timeout
				melee_bool = !melee_bool
			else:
				melee_bool = !melee_bool
		else:
			melee_bool = !melee_bool
## Death and damage functions

func take_damage(damage):
	current_hp-=damage
	if current_state == States.Idle:
		current_state = States.Alert

func death_check():
	if current_hp <= 0:
		current_state = States.Dead
func dead():
	if !dead_bool:
		dead_bool = !dead_bool
		agent.target_position = position
			#var mat = mesh.get_surface_override_material(0)
			#var tween = get_tree().create_tween()
			#tween.tween_property(mat, "albedo_color", Color.RED, 2)
			#await tween.finished
		queue_free()
##additional functions
#------------STOLEN FROM VICTORKARP.COM--------------------------------#
#https://victorkarp.com/godot-engine-rotating-a-character-with-transform-basis-slerp/
#i still suck at rotating shit. this was the best solution i could find

func alert_from_weapon_fire():
	if current_state == States.Idle:
		if position.distance_to(player.position) <= gunshot_alert_dist:
			current_state = States.Alert

func set_look_target_location(new_target: Vector3):
	look_target_location = new_target
	rotation_lerp = 0

func rotate_enemy(delta):
	if do_look_at_target:
		set_look_target_location(agent.get_next_path_position())
	if !do_look_at_target:
		set_look_target_location(player.position)
	if rotation_lerp < 1:
		rotation_lerp += delta * rotation_speed
	elif rotation_lerp > 1:
		rotation_lerp = 1
	transform.basis = transform.basis.slerp(look_target_rotation, rotation_lerp).orthonormalized()
	
func face_target(delta):
	look_target_location.y = transform.origin.y
	if look_target_location != transform.origin:
		look_target_rotation = transform.looking_at(look_target_location,Vector3.UP).basis
		rotate_enemy(delta)

#----------------------END STOLEN FROM VICTORKARP.COM------------------#

func handle_gravity(delta):
	if not is_on_floor():
		velocity += Vector3(0,-15,0) * delta

#ready commands
func assign_player():
	if player == null:
		player = Global.player
func force_map():
	NavigationServer3D.map_force_update(agent.get_navigation_map())

func dump_first_physics_frame():
	await get_tree().physics_frame
	set_physics_process(true)
	await_frame = true

#random 2d unit vector within range given. taken from u/angelonit on reddit
#additional instruction for 3d random unit vector from cameron
func random_vector(min,max) -> Vector3:
	var theta: float = randf() * 2 * PI
	#var phi: float = randf_range((PI/2),(-PI/2)
	var newvec: Vector3 = Vector3(cos(theta),0,sin(theta)) * sqrt(randf_range(min,max))
	#var newvec: Vector3 = Vector3((cos(theta) * sin(phi)),(cos(phi)), (sin(theta) * sin(phi))) * sqrt(randf_range(min,max)
	return newvec
	
func move_to_point():
	var cur_pos = global_transform.origin
	var next_pos = agent.get_next_path_position()
	var new_vel = (next_pos - cur_pos).normalized() * speed
	velocity = new_vel

func debug():
	Global.debug.add_property('Enemy Main State', States.keys()[current_state], 1)

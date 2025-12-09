class_name DumbEnemy extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var shoot_delay_timer: Timer = $shoot_delay
@onready var melee_raycast: RayCast3D = $melee_raycast
@onready var cover_timer: Timer = $cover_timer
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var bullet_spawn_point: Node3D = $enemy_body/body_unwrapped/Rarm0_unwrapped/Rarm1_unwrapped/bullet_spawn_point
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var saw_spin: AnimationPlayer = $SawSpin
@onready var stop_trying: Timer = $stop_trying

##DELETEME
@export var monitor: bool = false


var origin: Vector3
var await_frame: bool
const BULLET = preload("res://scenes/enemies/bullet.tscn")
signal shooting_done
var rotate_at_all: bool = true

@export_category("Sound Effects")
var do_bark: bool = false
var do_idle_bark: bool = false
## Combat barks will pick a random number of seconds before playing. This is the lower bound.
@export var combat_bark_min_interval: float = 3
## Combat barks will pick a random number of seconds before playing. This is the upper bound.
@export var combat_bark_max_interval: float = 5
@export var combat_barks: WwiseEvent
@export var shooting_sounds: WwiseEvent
@export var hovering_sounds: WwiseEvent
@export var alert_sounds: WwiseEvent
@export var melee_sounds: WwiseEvent
@export var death_sounds: WwiseEvent
## Idle barks will pick a random number of seconds before playing. This is the lower bound.
@export var idle_bark_min_interval: float = 3
## Idle barks will pick a random number of seconds before playing. This is the upper bound.
@export var idle_bark_max_interval: float = 5
@export var idle_sounds: WwiseEvent

@onready var soundhole: AkEvent3D = $soundhole


@export_category("Primary Logic")
enum States{None,Idle,Alert,Attack,MoveToCover,Cover,MoveFromCover,Melee,Dead}
@export var current_state: States = States.Idle
@export var max_hp: int = 100
@export var current_hp: int
@export var speed: float = 5
@export var rotation_speed  = 4
##Set this to true for the enemy to look at their patrol path destination, set to false to look at the player.
@export var do_look_at_target: bool = true
var look_target_location: Vector3
var look_target_rotation: Basis
var rotation_lerp: float = 0.0
@export var origin_override: bool = false
@export var origin_override_coord: Vector3

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
var attack_bool: bool = false
var has_shot: bool = false
## Rate of fire in rounds per min
@export var rate_of_fire: float = 120 
## Accuracy of the enemy per shot. Adds the look_at() rotation to the unit vector based on this number. tl;dr 1 is if u have a baby stevie wonder an ak47, 0 is dead on
@export var accuracy: float = 0.1
## Minimum number of shots per volley
@export var shots_fired_min: float = 1
## Maximum number of shots per volley
@export var shots_fired_max: float = 10
## Min damage range dealt by this enemy
@export var min_damage: float = 5
## Max damage range dealt by this enemy
@export var max_damage: float = 10
## How fast the bullets move. Default = 20
@export var projectile_speed: float = 20
var shots_taken: int = 0

@export_category("Secondary Logic | Find Cover")
## Minimum distance in which to search for cover
@export var min_cover_search: float = 1
## Maximum distance in which to search for cover
@export var max_cover_search: float = 50
## Number of attempts to find cover
@export var find_cover_attempts: int = 20
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
@export var melee_delay: float = 1.4
## How long after the melee until the enemy moves again #maybe this is replaced with an animation?
@export var melee_cooldown: float = 1
var melee_bool: bool = false
var last_state: States

@export_category("Secondary Logic | Death and Damage")
@export var hitboxes: Array[CollisionShape3D]
var dead_bool: bool = false

## Respawn Stuff
var stored_current_position
var stored_current_rotation
var stored_current_state
var stored_current_hp


var debug_bool: bool = false

func _ready() -> void:
	current_state = States.Idle
	Global.player_is_assigned.connect(assign_player)
	Global.enemy_hit_something.connect(enemy_hit_something)
	Global.weapon_fired.connect(alert_from_weapon_fire)
	Global.checkpoint_reached.connect(store_data)
	Global.player_respawned.connect(load_data)
	force_map()
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")
	playsound(hovering_sounds)
	if origin_override:
		origin = origin_override_coord
	else:
		origin = global_position
	shoot_delay_timer.wait_time = 60/rate_of_fire
	melee_raycast.target_position = Vector3(0,0,-melee_range)
	current_hp = max_hp
	animation_player.play("idle_animation")
	saw_spin.play("saw_spin")
	saw_spin.speed_scale = 2
	print(name," ",origin)

func _physics_process(delta: float) -> void:
	main_behaviour()
	move_and_slide()
	move_to_point()
	face_target(delta)
	handle_gravity(delta)
	death_check()
	debug()
	if dead_bool:
		if current_state != States.Dead:
			current_state = States.Dead
	if !dead_bool:
		do_combat_barks()
		do_idle_barks()

func main_behaviour():
	if await_frame:
		match current_state:
			States.None:
				the_big_alert_check()
			States.Idle:
				idle_behavior()
				the_big_alert_check()
			States.Alert:
				if !dead_bool:
					alert()
			States.Attack:
				if !dead_bool:
					attack()
					melee_check()
			States.MoveToCover:
				if !dead_bool:
					move_to_cover(find_cover_attempts,false)
					melee_check()
			States.Cover:
				if !dead_bool:
					cover()
					see_player()
					melee_check()
			States.MoveFromCover:
				if !dead_bool:
					move_from_cover(find_ground_attempts,true)
					melee_check()
			States.Melee:
				if !dead_bool:
					melee()
					melee_check()
			States.Dead:
				if !dead_bool:
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
	print(name," ", here)
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
	var here = NavigationServer3D.map_get_closest_point(map, node.global_position) #node.position when using the other nodes
	print(node.global_position)
	return here

## Alert Detection Behaviours
#check for alert range
func the_big_alert_check():
	if is_player_too_close():
		current_state = States.Alert
	elif can_see_player():
		current_state = States.Alert

func is_player_too_close():
	if position.distance_to(Global.player.position) < abs_alert_distance:
		return true
	else:
		return false

func can_see_player():
	var dir: Vector3 = global_position.direction_to(Global.player.global_position)
	var angle: float = global_transform.basis.z.signed_angle_to(dir, Vector3.UP)
	angle = abs(rad_to_deg(angle))
	#directly in front of the enemy is 180. directly behind them is 0. L and R both sign 90
	if angle > 180 - view_angle_degrees/2 and is_player_in_view_range():
		return true
	else:
		return false

func is_player_in_view_range() -> bool:
	if position.distance_to(Global.player.position) < view_radius:
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
		playsound(alert_sounds)
		if Global.current_encounter != null:
			Global.alert_encounter.emit()
		await get_tree().create_timer(randf_range(0.2,0.5)).timeout
		animation_player.stop()
		print("stop on 318")
		animation_player.play("alert")
		print("play alert 1")
		await get_tree().create_timer(randf_range(3.08,3.5)).timeout
		if !dead_bool:
			animation_player.play("idle_animation")
			print("play idle 2")
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
	##animation_player.play("shoot")
	##print("play shoot 3")
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
			if current_state != States.Attack:
				break
			else:
				animation_player.play("shoot")##
				alternate_shoot()
				await shoot_delay_timer.timeout
		
		
		has_shot = !has_shot
		shoot_delay_timer.stop()
		if !dead_bool and current_state != States.Melee:
			current_state = States.MoveToCover

func alternate_shoot():
	if !dead_bool:
		playsound(shooting_sounds)
		var active_bullet = BULLET.instantiate()
		active_bullet.damage = randi_range(min_damage,max_damage)
		active_bullet.speed = projectile_speed
		get_tree().root.add_child(active_bullet)
		var end = Vector3(randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy))
		##var rotaty: Vector3 = Vector3(rotation.x, rotation.y + end.y, rotation.z + end.z) 
		##active_bullet.rotation = rotaty
		#active_bullet.look_at(Global.player.player_head.position)
		#active_bullet.rotate(Vector3(1,0,0),90)
		active_bullet.position = bullet_spawn_point.global_position
		active_bullet.position += Vector3(-sin(deg_to_rad(rotation_degrees.y)),0 , -cos(deg_to_rad(rotation_degrees.y))) * 2
		active_bullet.look_at(Global.player.player_head.global_position)
		active_bullet.rotation += end

func shoot(accuracy):
	var origin = position + Vector3(0,1,0)
	var end = Global.player.player_head.global_position
	end += Vector3(randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy),randf_range(-accuracy,accuracy))
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	test_draw_ray(collision)
	print("shot was fired")
	if collision:
		if collision.collider == Global.player:
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
	poly.depth = position.distance_to(Global.player.position)
	if collision:
		if collision.collider == Global.player:
			poly.material = mat
		else:
			poly.material = mat2
	add_child(poly)
	poly.look_at(Global.player.player_head.global_position)
	await get_tree().create_timer(1).timeout
	poly.queue_free()


func enemy_hit_something(body):
	if body == Global.player:
		Global.player.damage(randi_range(min_damage,max_damage))
		#print("I hit the player")
	#print("I hit the ",body)

## Go to cover behaviour
#temp function kill it
func move_to_cover(attempts,see_player):
	if !move_to_cover_bool:
		move_to_cover_bool = !move_to_cover_bool
		animation_player.play("idle_animation")
		#here we need to run "find cover" x number of times until it returns true. if it still returns false, get the position of the last cover and move there anyway
		find_cover_loop(attempts,see_player)
		await agent.navigation_finished
		current_state = States.Cover
		move_to_cover_bool = !move_to_cover_bool

func find_cover_loop(i,see_player):
	for u in range(i):
		if find_cover(see_player):
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
	var _origin = where
	var end = Global.player.player_head.global_position
	var query = PhysicsRayQueryParameters3D.create(_origin,end)
	var can_reach = agent.is_target_reachable()
	query.collide_with_bodies = true
	query.exclude = [self]
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		if collision.collider == Global.player:
			if should_see_player:
				return true
			else:
				return false
		elif collision.collider != Global.player:
			if should_see_player:
				return false
			else:
				return true
		else:
			return false
	else:
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
		stop_trying.wait_time = 7
		stop_trying.start()
		await agent.target_reached
		stop_trying.stop()
		current_state = States.Attack
		move_to_ground_bool = !move_to_ground_bool

## Melee Behaviours
	#all non idle or alert should have this check!
	#if player is within x distance do melee stuff
	#if not, go to last state
func melee_check():
	if position.distance_to(Global.player.position) <= melee_aggro_dist:
		if current_state != States.Melee:
			last_state = current_state
			current_state = States.Melee
	else:
		if current_state == States.Melee:
			current_state = last_state

func melee():
	if !melee_bool:
		melee_bool = !melee_bool
		agent.target_position = Global.player.position
		if position.distance_to(Global.player.position) <= melee_range:
			agent.target_position = position
			animation_player.stop()
			print("stop on 545")
			animation_player.play("melee")
			playsound(melee_sounds)
			print("play melee 5")
			await get_tree().create_timer(1.3).timeout
			if melee_raycast.get_collider() == Global.player:
				Global.player.damage(randi_range(min_melee_damage,max_melee_damage))
				await get_tree().create_timer(melee_cooldown).timeout
				melee_bool = !melee_bool
			else:
				await get_tree().create_timer(melee_cooldown).timeout
				melee_bool = !melee_bool
		else:
			melee_bool = !melee_bool
## Death and damage functions

func check_body_part(bodypart,damage):
	if !dead_bool:
		if bodypart == "Head":
			take_damage(damage * 1.2)
		elif bodypart == "Body":
			take_damage(damage)
		elif bodypart == "Arm":
			take_damage(damage * 0.8)

func take_damage(damage):
	current_hp-=damage
	if current_state == States.Idle:
		current_state = States.Alert

func death_check():
	if current_hp <= 0:
		current_state = States.Dead
func dead():
	if !dead_bool:
		dead_bool = true
		agent.target_position = position
		speed = 0
		rotate_at_all = false
		animation_player.stop()
		print("stop on 589")
		animation_player.play("death")
		print("play death 7")
		saw_spin.stop()
		kill_all_sounds()
		await get_tree().create_timer(1.9).timeout
		animation_player.pause()
		
		await get_tree().create_timer(2).timeout
		self.collision_mask = 0
			#var mat = mesh.get_surface_override_material(0)
			#var tween = get_tree().create_tween()
			#tween.tween_property(mat, "albedo_color", Color.RED, 2)
			#await tween.finished
		Global.enemy_died.emit(self)
		#queue_free()
func kill_all_sounds():
	#idle sounds hovering sounds combat barks
	soundhole.event = idle_sounds
	soundhole.stop_event()
	soundhole.event = hovering_sounds
	soundhole.stop_event()
	soundhole.event = combat_barks
	soundhole.stop_event()
	soundhole.event = death_sounds
	soundhole.post_event()
##additional functions
func alert_from_weapon_fire():
	if current_state == States.Idle:
		if position.distance_to(Global.player.position) <= gunshot_alert_dist:
			current_state = States.Alert
#------------STOLEN FROM VICTORKARP.COM--------------------------------#
#https://victorkarp.com/godot-engine-rotating-a-character-with-transform-basis-slerp/
#i still suck at rotating shit. this was the best solution i could find

func set_look_target_location(new_target: Vector3):
	look_target_location = new_target
	rotation_lerp = 0

func rotate_enemy(delta):
	if do_look_at_target:
		set_look_target_location(agent.get_next_path_position())
	if !do_look_at_target:
		set_look_target_location(Global.player.position)
	if rotation_lerp < 1:
		rotation_lerp += delta * rotation_speed
	elif rotation_lerp > 1:
		rotation_lerp = 1
	transform.basis = transform.basis.slerp(look_target_rotation, rotation_lerp).orthonormalized()
	
func face_target(delta):
	if rotate_at_all:
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
	if Global.player == null:
		pass
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

func global_alert():
	current_state = States.Alert
	
## Checkpoint stuff
func store_data():
	stored_current_position = position
	stored_current_rotation = rotation
	stored_current_state = current_state
	stored_current_hp = current_hp
	
func load_data():
	position = stored_current_position
	rotation = stored_current_rotation
	current_state = stored_current_state
	current_hp = stored_current_hp
	
func change_state(state:States):
	last_state = current_state
	current_state = state
	
func playsound(sound:WwiseEvent):
	if sound != null:
		soundhole.event = sound
		soundhole.post_event()
		
func stopsound(sound:WwiseEvent):
	if sound != null:
		soundhole.stop_event()
		
func debug():
	if monitor:
		Global.debug.add_property('Enemy_State', States.keys()[current_state], 1)

func do_combat_barks():
	if current_state != States.None or current_state != States.Idle or current_state != States.Alert or current_state != States.Dead:
		if !do_bark:
			do_bark = true
			playsound(combat_barks)
			await get_tree().create_timer(randf_range(combat_bark_min_interval,combat_bark_max_interval)).timeout
			do_bark = false
			
func do_idle_barks():
	if current_state == States.Idle:
		if !do_idle_bark:
			do_idle_bark = true
			playsound(idle_sounds)
			await get_tree().create_timer(randf_range(idle_bark_min_interval,idle_bark_max_interval)).timeout

func _on_stop_trying_timeout() -> void:
	current_state = States.Attack

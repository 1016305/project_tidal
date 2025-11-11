extends CharacterBody3D

#player controller
#contains all camera and movement script

#player nodes
@onready var player_head: Node3D = $stand_collider/player_head
@onready var camera: Camera3D = $stand_collider/player_head/camera
@onready var flashlight: SpotLight3D = $stand_collider/player_head/camera/flashlight

@onready var stand_collider: CollisionShape3D = $stand_collider
@onready var _original_capsule_height = $stand_collider.shape.height
@export var interact_distance : float = 2
var interact_result

#player movement adjustable variables
var mouse_sens = 0.3
var player_jump_height = 5
var player_crouch_height = 0.8
var crouch_jump_add = player_crouch_height * 0.1 
var current_fov = FOV_MIN
const FOV_MIN = 90.0
const FOV_MAX = 110.0
const FOV_LERP_SPEED = 5.0

#player speed modifiers
const _WALK_SPEED = 6.0 #static but put here for clarity
const WALK_SPEED = 1
const CROUCH_SPEED = 0.2
const RUN_SPEED = 1.5 #RETURN TO 1.5

#player health variables
var current_health: int = 100
var max_health: int = 100

#player movement internal variables
var current_speed = 6.0: set = _set_current_speed, get = _get_current_speed
var input_dir = Vector3.ZERO
var direction = Vector3.ZERO
var move_drag_speed = 15 #speed to use if movement includes drag/dampening
const MAX_LOOK_X = 85
const MIN_LOOK_X = -85
const NEW_GRAVITY = Vector3(0, -15, 0)
const CROUCH_CAM_SPEED = 8.0
var move_drag = 0.05

#player movement states
var is_moving: bool = false
var is_jumping: bool = false
var is_crouching: bool = false
var is_mouse_hidden: bool = false
var is_running: bool = false
var is_falling: bool = false

#player weapon states
var weapon_a: bool = true
var weapon_b: bool = false
var wep_a = preload("res://models/weapons/assault_rifle/assault_rifle_weapon.tres")
var wep_b = preload("res://models/weapons/cube_test_weapon/test_cube_weapon.tres")
@onready var main_weapon_node: Node3D = $stand_collider/player_head/camera/weapon_rig/weapon
signal swap_weapons(wep)

##temporary remove me pls
@onready var enemyscene = preload("res://scenes/enemies/test_enemy.tscn")

func _ready() -> void:
	Global.player = self
	Global.player_is_assigned.emit()
	camera.fov = FOV_MIN
	Global.main_camera = camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.player_health.emit(current_health,max_health)
	

#unhandled input process
#uses mouse to handle rotation
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !is_mouse_hidden:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		player_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(MIN_LOOK_X), deg_to_rad(MAX_LOOK_X))
		player_head.rotation.y = 0 # clamp rotation of head to 0 otherwise overreach causes control inversion during lean

#main physics process
#contains all movement related functions
func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_move(delta)
	handle_sprint(delta)
	handle_jump()
	toggle_mouse()
	handle_head_roll(input_dir, delta)
	handle_crouch(delta)
	check_jump_and_fall()
	test_change_weapon()
	move_and_slide()
	shoot(delta)
	reload()
	toggle_flashlight()
	interact_cast()
	if Input.is_action_just_pressed("interact"):
		interact()
	
	take_damage_test()
	#I cannot fathom why this only works here. Probably part of some insidious component of move_and_slide
	#If you move this ANYWHERE it will fuck up the checks for moving. I will not put this into its own
	#method. It is a monument to all our sins.
	if velocity.length() < 0.01:
		is_moving = false
	elif !input_dir:
		is_moving = false
	else:
		is_moving = true
		
	player_debug()
	spawn_test_enemy()

func handle_gravity(delta):
	#gravities the player so they're always goin down down
	if not is_on_floor():
		velocity += NEW_GRAVITY * delta

func handle_move(delta):
	#handles movement. input form input manager
	input_dir = Input.get_vector("left","right","forward","backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #Without move drag/dampening.
	#direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * move_drag_speed) # includes move drag/dampening. Use if no edge friciton
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _get_current_speed(), 3 * delta)
		velocity.z = lerp(velocity.z, direction.z * _get_current_speed(), 3 * delta)
	else:
		if !is_on_floor():
			velocity = lerp(velocity, Vector3.ZERO, 0.005)
			#velocity.z = lerp(velocity.z, 0.0, move_drag/2)	
		else:
			velocity = lerp(velocity, Vector3.ZERO, 0.1)
			#velocity.z = lerp(velocity.z, 0.0, move_drag)

func handle_jump():
	#handles jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = player_jump_height
	if is_jumping and is_crouching:
		_set_current_speed(CROUCH_SPEED)

func check_jump_and_fall():
	#controls the state machine. currently not used but could be good to differentiate between jumping and falling
	if velocity.y > 0:
		is_jumping = true
		is_falling = false
	elif velocity.y < 0:
		is_jumping = false
		is_falling = true
	else:
		is_jumping = false
		is_falling = false
	
func handle_crouch(delta):
	# Handle crouch. Player speed is reduced. Source-like crouch jumping behaviour from https://www.youtube.com/@MajikayoGames
	var was_crouched_last_frame = is_crouching
	var _crouch_cam_speed = CROUCH_CAM_SPEED
	#crouch and uncrouch toggle. this is just for the checks and states
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		if is_on_floor(): #Waits to adjust the player's speed until they hit the floor
			is_running = false
			_set_current_speed(CROUCH_SPEED)
	elif is_crouching and not self.test_move(self.global_transform, Vector3(0, player_crouch_height, 0)): #checks if the player has enough room to uncrouch
		is_crouching = false
		_set_current_speed(WALK_SPEED)
		_crouch_cam_speed*=2.5
	#some bullshit i found that mimics the source jump
	var translate_y_if_possible := 0.0
	if was_crouched_last_frame != is_crouching and not is_on_floor(): #was player on floor last frame?
		translate_y_if_possible = crouch_jump_add if is_crouching else -crouch_jump_add #if the player was not on the floor add a small value, subtract otherwise
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new() #this estimates the jump and predicts any collisions that might occur before adding extra height
		self.test_move(self.global_transform, Vector3(0, translate_y_if_possible,0),result)
		self.position.y+= result.get_travel().y #adds the additional y to the jump, makes it floatier
	#moves the camera and adjusts the shape of the collider to fit the crouch
	player_head.position = lerp(player_head.position, Vector3(0, (0.8 - player_crouch_height if is_crouching else 0.8),0), _crouch_cam_speed * delta)
	stand_collider.shape.height = lerp(stand_collider.shape.height, (_original_capsule_height - player_crouch_height if is_crouching else _original_capsule_height), _crouch_cam_speed * delta)
	stand_collider.position.y = lerp(stand_collider.position.y, (stand_collider.shape.height / 2), _crouch_cam_speed * delta)

func handle_head_roll(dir, delta):
	#rolls the camera along z axis in response to strafing
	if dir:
		camera.rotation.z = lerp(camera.rotation.z, -deg_to_rad(dir.x * 1.3), 8 * delta)
		camera.rotation.z = clamp(camera.rotation.z, deg_to_rad(-10), deg_to_rad(10))
	else:
		camera.rotation.z = lerp(camera.rotation.z, 0.0, 12 * delta)

func toggle_mouse():
	if Input.is_action_just_pressed("toggle_mouse_visible"):
		if !is_mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_mouse_hidden = true
		elif is_mouse_hidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_mouse_hidden = false
			
func handle_sprint(delta):
	fov_change(delta, FOV_MIN, FOV_MAX)
	if Input.is_action_pressed("sprint") and !is_crouching and is_moving:
		is_running = true
		_set_current_speed(RUN_SPEED)
	else:
		is_running = false
		if is_crouching:
			_set_current_speed(CROUCH_SPEED) #fuckass solution, kinda half baked. cant source jump sprint with this but prevents crouch hopping.
		else:
			_set_current_speed(WALK_SPEED)

func fov_change(delta, minfov, maxfov):
		if is_running and is_moving:
			camera.fov = lerp(camera.fov, maxfov, FOV_LERP_SPEED * delta)
			camera.position.z = lerp(camera.position.z, -0.5, FOV_LERP_SPEED * delta)
		else:
			camera.fov = lerp(camera.fov, minfov, (FOV_LERP_SPEED * 3) *delta)
			camera.position.z = lerp(camera.position.z, 0.0, (FOV_LERP_SPEED * 3) * delta)

func interact_cast():
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().get_visible_rect().size / 2
	screen_center.y = screen_center.y/3 * 1.6
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)
	var current_cast_result = result.get("collider")
	if current_cast_result != interact_result:
		if interact_result and interact_result.has_user_signal("unfocused"):
			interact_result.emit_signal("unfocused")
		interact_result = current_cast_result
		if interact_result and interact_result.has_user_signal("focused"):
			interact_result.emit_signal("focused")

func interact():
	if interact_result != null and interact_result.has_user_signal("interact"):
		interact_result.emit_signal("interact")

##Weapon stuff. Move to another script when convenient
func test_change_weapon():
	if Input.is_action_pressed("test_swap_to_weapon_a"):
		if weapon_a:
			return
		if !weapon_a:
			weapon_a = !weapon_a
			weapon_b = !weapon_b
			emit_signal('swap_weapons',wep_a)
			print('swapped to a')
	if Input.is_action_pressed("test_swap_to_weapon_b"):
		if weapon_b:
			return
		if !weapon_b:
			weapon_a = !weapon_a
			weapon_b = !weapon_b
			emit_signal('swap_weapons',wep_b)
			print('swapped to b')

func shoot(delta):
	if Input.is_action_pressed("attack_1"):
		Global.player_weapon.shoot(delta)
func reload():
	if Input.is_action_pressed("reload"):
		Global.player_weapon.reload()

func toggle_flashlight():
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible

##Getters and Setters
#Player damage and health
func damage(damage):
	current_health -= damage
	if current_health < 0:
		current_health = 0
	Global.player_health.emit(current_health,max_health)
	print("Took ", damage, " damage")
	death_check()
	
func heal(health):
	current_health += health
	
func death_check():
	if current_health <= 0:
		print("player is dead")


#External function to adjust/call player speed from multiple fucntions. Adds edge friction modifier.
func _set_current_speed(speedmod):
	current_speed = _WALK_SPEED * speedmod
func _get_current_speed():
	return current_speed
	
##Debug Info
func player_debug():

	Global.debug.add_property('Is Moving',is_moving,1)
	Global.debug.add_property('Is Crouching',is_crouching,1)
	Global.debug.add_property('Is Jumping',is_jumping,1)
	Global.debug.add_property('Is Falling', is_falling, 1)
	Global.debug.add_property('Is Running',is_running,1)
	Global.debug.add_property('Current Velocity ABS', velocity.abs().snappedf(0.01), 1)
	Global.debug.add_property('Current Velocity', velocity.snappedf(0.01), 1)
	Global.debug.add_property('Player Head Pitch', player_head.rotation.x, 1)
	Global.debug.add_property('Player Location', position, 1)

func spawn_test_enemy():
	if Input.is_action_just_pressed("spawn_test_enemy"):
		var new_enemy = enemyscene.instantiate()
		new_enemy.position = Vector3(3.4,1.5,1.2)
		get_tree().root.add_child(new_enemy)
		
func take_damage_test():
	if Input.is_action_just_pressed("test_damage"):
		damage(randi_range(6,8))

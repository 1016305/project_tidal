extends CharacterBody3D

#player controller
#contains all camera and movement script

#player nodes
@onready var player_head: Node3D = $stand_collider/player_head
@onready var camera: Camera3D = $stand_collider/player_head/camera

@onready var stand_collider: CollisionShape3D = $stand_collider
@onready var _original_capsule_height = $stand_collider.shape.height

#player movement adjustable variables
var mouse_sens = 0.3
var player_jump_height = 5
var player_crouch_height = 0.8
var crouch_jump_add = player_crouch_height * 0.1 

#player speed modifiers
const _WALK_SPEED = 6.0 #static but put here for clarity
const WALK_SPEED = 1
const CROUCH_SPEED = 0.2
const RUN_SPEED = 1.5


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

#unhandled input process
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
        player_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
        player_head.rotation.x = clamp(player_head.rotation.x, deg_to_rad(MIN_LOOK_X), deg_to_rad(MAX_LOOK_X))
        player_head.rotation.y = 0 # clamp rotation of head to 0 otherwise overreach causes control inversion during lean

#main physics process
#contains all movement related functions
func _physics_process(delta: float) -> void:
    var was_on_floor = is_on_floor()
    handle_gravity(delta)
    handle_move(delta)
    handle_jump()
    toggle_mouse()
    handle_crouch(delta)
    move_and_slide()

func handle_gravity(delta):
    #gravities the player so they're always goin down down
    if not is_on_floor():
        velocity += NEW_GRAVITY * delta

func handle_move(delta):
    input_dir = Input.get_vector("left","right","forward","backward")
    direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #Without move drag/dampening.
    #direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * move_drag_speed) # includes move drag/dampening. Use if no edge friciton
    
    if direction:
        is_moving = true
        velocity.x = lerp(velocity.x, direction.x * _get_current_speed(), 3 * delta)
        velocity.z = lerp(velocity.z, direction.z * _get_current_speed(), 3 * delta)
    else:
        is_moving = false
        if !is_on_floor():
            velocity = lerp(velocity, Vector3.ZERO, 0.005)
            #velocity.z = lerp(velocity.z, 0.0, move_drag/2)
            
        else:
            velocity = lerp(velocity, Vector3.ZERO, 0.1)
            #velocity.z = lerp(velocity.z, 0.0, move_drag)

func handle_jump():
    if Input.is_action_just_pressed("jump") and is_on_floor():
        is_jumping = true
        print('jump')
        velocity.y = player_jump_height
    else:
        is_jumping = false

func handle_crouch(delta):
    # Handle crouch. Player speed is reduced. Source-like crouch jumping behaviour from https://www.youtube.com/@MajikayoGames
    var was_crouched_last_frame = is_crouching
    var _crouch_cam_speed = CROUCH_CAM_SPEED
    #crouch and uncrouch toggle. this is just for the checks and states
    if Input.is_action_pressed("crouch"):
        is_crouching = true
        if is_on_floor(): #Waits to adjust the player's speed until they hit the floor
            #is_sprinting = false
            _set_current_speed(CROUCH_SPEED)
    elif is_crouching and not self.test_move(self.global_transform, Vector3(0, player_crouch_height, 0)): #checks if the player has enough room to uncrouch
        is_crouching = false
        _set_current_speed(WALK_SPEED)
        _crouch_cam_speed*=2.5
    #some bullshit i found that mimics the source jump
    var translate_y_if_possible := 0
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

func toggle_mouse():
    if Input.is_action_just_pressed("toggle_mouse_visible"):
        if !is_mouse_hidden:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            is_mouse_hidden = true
        elif is_mouse_hidden:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            is_mouse_hidden = false
##Getters and Setters

#External function to adjust/call player speed from multiple fucntions. Adds edge friction modifier.
func _set_current_speed(speedmod):
    current_speed = _WALK_SPEED * speedmod
func _get_current_speed():
    return current_speed

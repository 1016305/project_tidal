class_name Boss extends Node3D

enum Phases{Dormant,Start,Phase1,Phase2,Phase3,Phase4,Dead}
@export var current_phase = Phases
var previous_phase
signal heatsinks_done
const VFXDAMAGE = preload("res://scenes/effects/vfx_damage.tscn")
const VFX_EXPLOSION = preload("res://scenes/effects/vfx_explosion.tscn")
var vfx
@onready var rotatebitch: Node3D = $RotateBitch
@onready var firing_thing: AnimationPlayer = $FiringThing
@onready var startup_sequence: AnimationPlayer = $"startup sequence"
@export var encounter: EnemyEncounter
@export var spawn_enemies_here: Array[Node3D]

#@onready var eye: CSGSphere3D = $CSGSphere3D
@onready var rotate_me: MeshInstance3D = $"Icosphere"
@onready var laser_tube: MeshInstance3D = $"Icosphere/Main gun/Laser Tube"
@onready var draw_from_here: Node3D = $"Icosphere/Main gun/DrawFromHere"
@onready var draw_to_here: Node3D = $"Icosphere/Main gun/ToHere"
@onready var player_damage_tick: Timer = $player_damage_tick
@export var the_door: Node3D

@export_category("Flare")
@export var left_lights: Array[OmniLight3D]
@export var right_lights: Array[OmniLight3D]
@export var startup_lights_l: Array[OmniLight3D]
@export var startup_lights_r: Array[OmniLight3D]

@export_category("Sounds")
@export var combat_barks: WwiseEvent
@export var death: WwiseEvent
@export var hit_barks: WwiseEvent
@export var intro_sounds: WwiseEvent
@export var movement: WwiseEvent
@export var weapon_fire: WwiseEvent

@export_category("Primary Logic")
@export var heatsinks_array: Array[Heatsink]
@export var heatsink_start_hp: float = 100
@export var damage: float = 10
@export var damage_tick: float = 1
var aim_at_player: bool = false
var doing_damage: bool = false
var shoot_location: Vector3 
var target_pos: Vector3
var shoot_damage_time: float #this should be equal to the animation time for the laserblast
var heatsinks_remaining = 4
var rotation_speed: float = 3


@export_category("Secondary Logic | Dormant")
var dormant_bool: bool = false

@export_category("Secondary Logic | Start")
var start_bool: bool = false

@export_category("Secondary Logic | Phase 1")
var ph1_bool: bool = false
## How long the gun will aim at the player before initating firing sequence
@export var ph1_aim_time: float = 3
## How long after locking in/stopping rotation the gun will wait before firing
@export var ph1_shoot_wait = 2
## How long the gun will fire for
@export var ph1_shoot_time = 5
## How long after firing before the heatsinks open
@export var ph1_heatsink_delay = 2
## How long the heatsinks will remain open for
@export var ph1_damage_phase_time = 5

@export_category("Secondary Logic | Phase 2")
var ph2_bool: bool = false
## How long the gun will aim at the player before initating firing sequence
@export var ph2_aim_time: float = 3
## How long after locking in/stopping rotation the gun will wait before firing
@export var ph2_shoot_wait = 2
## How long the gun will fire for
@export var ph2_shoot_time = 5
## How long after firing before the heatsinks open
@export var ph2_heatsink_delay = 2
## How long the heatsinks will remain open for
@export var ph2_damage_phase_time = 5

@export_category("Secondary Logic | Phase 3")
var ph3_bool: bool = false
## How long the gun will aim at the player before initating firing sequence
@export var ph3_aim_time: float = 3
## How long after locking in/stopping rotation the gun will wait before firing
@export var ph3_shoot_wait = 2
## How long the gun will fire for
@export var ph3_shoot_time = 5
## How long after firing before the heatsinks open
@export var ph3_heatsink_delay = 2
## How long the heatsinks will remain open for
@export var ph3_damage_phase_time = 5
## How long to wait between shots
@export var ph3_next_shot_wait: float = 1

@export_category("Secondary Logic | Phase 4")
var ph4_bool: bool = false
## How long the gun will aim at the player before initating firing sequence
@export var ph4_aim_time: float = 3
## How long after locking in/stopping rotation the gun will wait before firing
@export var ph4_shoot_wait = 2
## How long the gun will fire for
@export var ph4_shoot_time = 5
## How long after firing before the heatsinks open
@export var ph4_heatsink_delay = 2
## How long the heatsinks will remain open for
@export var ph4_damage_phase_time = 5
## How long to wait between shots
@export var ph4_next_shot_wait: float = 1

@export_category("Secondary Logic | Death")
var dead_bool: bool = false
@onready var deathanimation: AnimationPlayer = $deathanimation
@export var explode_point_1: Node3D
@export var explode_point_2: Node3D
@export var explode_point_3: Node3D


func _ready() -> void:
	Global.begin_boss.connect(boss_start)
	current_phase = Phases.Dormant
	set_heatsink_hp()
	player_damage_tick.wait_time = damage_tick
	vfx = VFXDAMAGE.instantiate()
	add_child(vfx)
	startup_sequence.play("RESET")

func _physics_process(delta: float) -> void:
	main_behaviour()
	slow_rotate(delta)
	sphere_cast()
	#eye_look_at_player()
	debug()
	
func main_behaviour():
	match current_phase:
		Phases.Dormant:
			pass
		Phases.Start:
			startup_animation()
		Phases.Phase1:
			phase_1()
		Phases.Phase2:
			phase_2()
		Phases.Phase3:
			phase_3()
		Phases.Phase4:
			phase_4()
		Phases.Dead:
			dead()

func boss_start():
	print("should change the phase")
	current_phase = Phases.Start

func switch_phase(new_phase:String):
	previous_phase = current_phase
	current_phase = Phases[new_phase]

func startup_animation():
	if !start_bool:
		start_bool = true
		startup_sequence.play("startup")
		startup_lights(startup_lights_l)
		startup_lights(startup_lights_r)
		await startup_sequence.animation_finished
		switch_phase("Phase1")

func phase_1():
	if !ph1_bool:
		print("begin phase 1")
		ph1_bool = true
		aim_at_player = true
		await get_tree().create_timer(ph1_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		lights(left_lights,ph1_shoot_wait)
		lights(right_lights,ph1_shoot_wait)
		await get_tree().create_timer(ph1_shoot_wait).timeout
		#play sound effect (early?) charge up sound effect warns player that shooting will happen soon
		# maybe use an animated cylinder whose scale extends forwards to shoot? and just check collisions?
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph1_shoot_time)
		await get_tree().create_timer(ph1_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph1_heatsink_delay).timeout
		open_all_heatsinks(ph1_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph1_bool = false
		
		# the heatsinks will expose for the player to shoot
		# they will retract after a few seconds
		# they boss will repeat this behaviour until the first heatsink is destroyed
		
func phase_2():
	if !ph2_bool:
		print("begin phase 2")
		ph2_bool = true
		aim_at_player = true
		await get_tree().create_timer(ph2_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		lights(left_lights,ph2_shoot_wait)
		lights(right_lights,ph2_shoot_wait)
		await get_tree().create_timer(ph2_shoot_wait).timeout

		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph2_shoot_time)
		await get_tree().create_timer(ph2_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph2_heatsink_delay).timeout
		open_all_heatsinks(ph2_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph2_bool = false

func phase_3():
	if !ph3_bool:
		ph3_bool = !ph3_bool
		if encounter.check_alive_enemies(1):
			encounter.spawn_enemy(spawn_enemies_here[0].global_position)
			encounter.spawn_enemy(spawn_enemies_here[2].global_position)
			encounter.spawn_enemy(spawn_enemies_here[3].global_position)
			encounter.spawn_enemy(spawn_enemies_here[5].global_position)
		aim_at_player = true
		await get_tree().create_timer(ph3_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		lights(left_lights,ph3_shoot_wait)
		lights(right_lights,ph3_shoot_wait)
		await get_tree().create_timer(ph3_shoot_wait).timeout
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph3_shoot_time)
		await get_tree().create_timer(ph3_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph3_next_shot_wait).timeout
		
		aim_at_player = true
		await get_tree().create_timer(ph3_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		lights(left_lights,ph3_shoot_wait)
		lights(right_lights,ph3_shoot_wait)
		await get_tree().create_timer(ph3_shoot_wait).timeout
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph3_shoot_time)
		await get_tree().create_timer(ph3_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		
		await get_tree().create_timer(ph3_heatsink_delay).timeout
		open_all_heatsinks(ph3_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph3_bool = false

func phase_4():
	if !ph4_bool:
		ph4_bool = !ph4_bool
		if encounter.check_alive_enemies(2):
			encounter.spawn_enemy(spawn_enemies_here[0].global_position)
			encounter.spawn_enemy(spawn_enemies_here[1].global_position)
			encounter.spawn_enemy(spawn_enemies_here[2].global_position)
			encounter.spawn_enemy(spawn_enemies_here[3].global_position)
			encounter.spawn_enemy(spawn_enemies_here[4].global_position)
			encounter.spawn_enemy(spawn_enemies_here[5].global_position)

		aim_at_player = true
		await get_tree().create_timer(ph4_aim_time).timeout
		shoot_location = Global.player.position
		lights(left_lights,ph4_shoot_wait)
		lights(right_lights,ph4_shoot_wait)
		await get_tree().create_timer(ph4_shoot_wait).timeout
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph4_shoot_time)
		aim_at_player = false
		await get_tree().create_timer(ph4_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph4_next_shot_wait).timeout
		
		aim_at_player = true
		await get_tree().create_timer(ph4_aim_time).timeout
		shoot_location = Global.player.position
		
		lights(left_lights,ph4_shoot_wait)
		lights(right_lights,ph4_shoot_wait)
		await get_tree().create_timer(ph4_shoot_wait).timeout
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph4_shoot_time)
		aim_at_player = false
		await get_tree().create_timer(ph4_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph4_next_shot_wait).timeout
		
		aim_at_player = true
		await get_tree().create_timer(ph4_aim_time).timeout
		shoot_location = Global.player.position
		
		lights(left_lights,ph4_shoot_wait)
		lights(right_lights,ph4_shoot_wait)
		await get_tree().create_timer(ph4_shoot_wait).timeout
		print("Shooting! KaBLAM")
		firing_thing.play("rear_recoil")
		shoot(ph4_shoot_time)
		aim_at_player = false
		await get_tree().create_timer(ph4_shoot_time).timeout
		lights_off(left_lights)
		lights_off(right_lights)
		await get_tree().create_timer(ph4_next_shot_wait).timeout
		
		await get_tree().create_timer(ph4_heatsink_delay).timeout
		open_all_heatsinks(ph3_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph4_bool = false

func dead():
	if !dead_bool:
		dead_bool = true
		encounter.kill_all_enemies()
		await get_tree().create_timer(1).timeout
		deathanimation.play("death_animation")
		await deathanimation.animation_finished
		print("boss says animation is finished")
		print("emitting the signal")
		the_door.open_door()

func open_all_heatsinks(time):
	for h in heatsinks_array:
		if h != null:
			h.heatsink_expose(time)

func set_heatsink_hp():
	for h in heatsinks_array:
		if h != null:
			h.heatsink_hp = heatsink_start_hp
			h.heatsink_max_hp = heatsink_start_hp

#func eye_look_at_player():
#	if Global.player != null:
#		eye.look_at(Global.player.player_head.global_position)

func shoot(time):
	#do lights and charge up sound effect
	#unhide cylinder with cool effect on it
	#animate cylinder to stretch to cast point
	draw_to_here.position.x = draw_from_here.position.distance_to(Global.player.position)
	var origin = draw_from_here.global_position
	var end = (draw_to_here.global_position - origin) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 1
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	var pos = result.get("position")
	var stretch_distance = laser_tube.global_position.distance_to(pos)
	laser_tube.visible = true
	var tween = create_tween()
	tween.tween_property(laser_tube,"scale",Vector3(laser_tube.scale.x,stretch_distance,laser_tube.scale.z),0.8)
	await tween.finished
	#spherecast will constantly fire while the player is inside it
	target_pos = pos
	doing_damage = true
	vfx.on_start()
	await get_tree().create_timer(time).timeout
	vfx.on_end()
	doing_damage = false
	laser_tube.scale = Vector3(laser_tube.scale.x,0.01,laser_tube.scale.z)
	laser_tube.visible = false
	
	#do sphere cast at cast point and spawn a sphere of the same radius
	#damage player
	#wait
	
func sphere_cast():
	#the box is actually a sphere, it is placed at the position of the end of the raycast, and then 
	#its transfrom is used to target the shapecast.
	#the sphere is also used to visualise the sgapecast
	if doing_damage:
		# CSGSphere used to copy the translation because i fucking hate shapecasts
		var box = CSGSphere3D.new()
		box.visible = false
		box.radius = 4.0
		box.use_collision = false
		add_child(box)
		box.global_position = target_pos# + Vector3.UP
		
		vfx.global_position = box.global_position
		var shape_rid = PhysicsServer3D.sphere_shape_create()
		var radius = 4.0
		var mask = 1
		PhysicsServer3D.shape_set_data(shape_rid,radius)
		var shapecast = PhysicsShapeQueryParameters3D.new()
		shapecast.collide_with_bodies = true
		shapecast.shape_rid = shape_rid
		shapecast.transform = box.global_transform
		shapecast.collision_mask = mask
		#shapecast.margin = 2
		var result = get_world_3d().direct_space_state.intersect_shape(shapecast)
		for i in result:
			if i.get("collider") == Global.player:
				damage_player(damage)
		PhysicsServer3D.free_rid(shape_rid)
		box.queue_free()

func rotate_and_shit():
	rotatebitch.look_at(Global.player.global_position)

func slow_rotate(delta):
	rotate_and_shit()
	if aim_at_player:
		var a = Quaternion(rotate_me.transform.basis.orthonormalized())
		var b = Quaternion(rotatebitch.transform.basis.orthonormalized())
		rotate_me.basis = a.slerp(b,rotation_speed*delta)

func debug():
	Global.debug.add_property("Boss Phase", Phases.keys()[current_phase], 1)
	Global.debug.add_property("Start Bool", start_bool, 1)

func change_state():
	current_phase = return_phase_from_heatsinks()

func return_phase_from_heatsinks():
	if heatsinks_remaining == 4:
		return Phases.Phase1
	elif heatsinks_remaining == 3:
		return Phases.Phase2
	elif heatsinks_remaining == 2:
		return Phases.Phase3
	elif heatsinks_remaining == 1:
		return Phases.Phase4
	elif heatsinks_remaining == 0:
		return Phases.Dead

func test_draw_ray(pos):
	#trying to use this to visualise the fuckass raycast
	var poly = CSGPolygon3D.new() #poly needs path
	var mat = StandardMaterial3D.new()
	var mat2 = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat2.albedo_color = Color.GREEN
	poly.position += laser_tube.position
	poly.scale = Vector3(0.2,0.2,1)
	poly.mode = CSGPolygon3D.MODE_DEPTH
	poly.depth = laser_tube.position.distance_to(pos)
	add_child(poly)
	poly.look_at(pos)
	await get_tree().create_timer(1).timeout
	poly.queue_free()

func heatsink_destroyed(heatsink:Heatsink):
	print("the boss registers the destructioj of the heatsink")
	print("heatsink ",heatsink," was destroyed")
	for h in heatsinks_array:
		if h != null:
			h.other_heatsink_died()
	heatsinks_array.erase(heatsink)
	heatsinks_remaining -= 1
	change_state()

func startup_lights(lightsarray):
	for i in lightsarray:
		await get_tree().create_timer(1).timeout
		i.visible = true

func lights(lightsarray,aimtime):
	var interval = aimtime/lightsarray.size()
	# time needs to be phase's charge up time divided by number of lights (5)
	for i:OmniLight3D in lightsarray:
		await get_tree().create_timer(interval).timeout
		i.visible = true
		
func lights_off(lightsarray):
	for i:OmniLight3D in lightsarray:
		i.visible = false

func damage_player(damage):
	if player_damage_tick.is_stopped():
		player_damage_tick.start()
		Global.player.damage(damage)
		
func death_explosions():
	var exp1 = VFX_EXPLOSION.instantiate()
	var exp2 = VFX_EXPLOSION.instantiate()
	var exp3 = VFX_EXPLOSION.instantiate()
	get_tree().root.add_child(exp1)
	exp1.global_position = explode_point_1.global_position
	get_tree().root.add_child(exp2)
	exp2.global_position = explode_point_2.global_position
	get_tree().root.add_child(exp3)
	exp3.global_position = explode_point_3.global_position

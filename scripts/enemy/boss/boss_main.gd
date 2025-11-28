class_name Boss extends Node3D

enum Phases{Dormant,Start,Phase1,Phase2,Phase3,Phase4,Dead}
@export var current_phase = Phases
var previous_phase
signal heatsinks_done

@onready var rotatebitch: Node3D = $rotatebitch
@onready var eye: CSGSphere3D = $CSGSphere3D
@onready var rotate_me: CSGSphere3D = $"CSGBox3D/CSGBox3D/CSGBox3D/Rotate Me"
##Heatsinks



@export_category("Primary Logic")
@export var heatsinks_array: Array[Heatsink]
@export var heatsink_start_hp: float = 100
var aim_at_player: bool = false
var shoot_location: Vector3 
var shoot_damage_time: float #this should be equal to the animation time for the laserblast
var heatsinks_remaining = 4
var rotation_speed: float = 3


@export_category("Secondary Logic | Dormant")
var dormant_bool: bool = false

@export_category("Secondary Logic | Start")
var start_bool: bool = false

@export_category("Secondary Logic | Phase 1")
var ph1_bool: bool = false
@export var ph1_aim_time: float = 3
@export var ph1_shoot_cooldown = 5
@export var ph1_damage_phase_time = 5

@export_category("Secondary Logic | Phase 2")
var ph2_bool: bool = false
@export var ph2_aim_time: float = 3
@export var ph2_shoot_cooldown = 5
@export var ph2_damage_phase_time = 5


func _ready() -> void:
	Global.begin_boss.connect(boss_start)
	current_phase = Phases.Dormant
	set_heatsink_hp()

func _physics_process(delta: float) -> void:
	main_behaviour()
	slow_rotate(delta)
	eye_look_at_player()
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
			pass
		Phases.Phase4:
			pass
		Phases.Dead:
			pass

func boss_start():
	print("should change the phase")
	current_phase = Phases.Start

func switch_phase(new_phase:String):
	previous_phase = current_phase
	current_phase = Phases[new_phase]

func startup_animation():
	if !start_bool:
		start_bool = true
		#lets do some animation
		print("Rarrgh here is the boss he's so threatening isnt he")
		await get_tree().create_timer(3).timeout
		print("The animation is complete, and the boss is goign to start attacking now.")
		#this has all the animation for the boss's startup
		await get_tree().create_timer(1).timeout
		print("Starting phase 1")
		switch_phase("Phase1")

func phase_1():
	if !ph1_bool:
		print("begin phase 1")
		ph1_bool = true
		aim_at_player = true
		await get_tree().create_timer(ph1_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		#play sound effect (early?) charge up sound effect warns player that shooting will happen soon
		# maybe use an animated cylinder whose scale extends forwards to shoot? and just check collisions?
		print("Shooting! KaBLAM")
		await get_tree().create_timer(2).timeout
		open_all_heatsinks(ph1_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph1_bool = false
		
		# the heatsinks will expose for the player to shoot
		# they will retract after a few seconds
		# they boss will repeat this behaviour until the first heatsink is destroyed
		
func phase_2():
	if !ph2_bool:
		print("Congratulations, the phase advancement works!")
		print("begin phase 2")
		ph2_bool = true
		aim_at_player = true
		await get_tree().create_timer(ph1_aim_time).timeout
		shoot_location = Global.player.position
		aim_at_player = false
		#play sound effect (early?) charge up sound effect warns player that shooting will happen soon
		# maybe use an animated cylinder whose scale extends forwards to shoot? and just check collisions?
		print("Shooting! KaBLAM")
		await get_tree().create_timer(2).timeout
		open_all_heatsinks(ph1_damage_phase_time)
		await self.heatsinks_done
		print("phase complete, restarting")
		ph1_bool = false

func open_all_heatsinks(time):
	for h in heatsinks_array:
		if h != null:
			h.heatsink_expose(time)

func set_heatsink_hp():
	for h in heatsinks_array:
		if h != null:
			h.heatsink_hp = heatsink_start_hp
			h.heatsink_max_hp = heatsink_start_hp

func eye_look_at_player():
	if Global.player != null:
		eye.look_at(Global.player.player_head.global_position)

func rotate_and_shit():
	rotatebitch.look_at(Global.player.position)

func slow_rotate(delta):
	rotate_and_shit()
	if aim_at_player:
		var a = Quaternion(rotate_me.transform.basis)
		var b = Quaternion(rotatebitch.transform.basis)
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

func heatsink_destroyed(heatsink:Heatsink):
	print("the boss registers the destructioj of the heatsink")
	print("heatsink ",heatsink," was destroyed")
	for h in heatsinks_array:
		if h != null:
			h.other_heatsink_died()
	heatsinks_array.erase(heatsink)
	heatsinks_remaining -= 1
	change_state()

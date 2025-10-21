class_name advanced_test_enemy extends Resource
@export_category("Main enemy stats")
@export var health: int = 100
@export var ammo: int = 100
@export var max_ammo: int = 100
@export var move_speed: float = 5
@export var rotate_speed: float = 5

@export_category("Behaviour peramaters")
##Enemy state flags. By default should be IDLE with every spawned enemy.
@export_enum("Idle", "Cover", "Attack", "Enrage", "Melee", "Dead") var enemy_state: String = "Idle"
##Random patrol: Enemy will find a random spot nearby and walk to it.
##Sequence: Enemy will work through a list of nodes, going to each one individually.
##Random sequence: Enemy will pick a random node from the list and travel there.
@export_enum("Random Patrol","Sequence","Random Sequence") var patrol_type: String
##How long the enemy wait before heading to the next patrol point. !!CURRENTLY NOT FUNCTIONAL. I DONT KNOW HOW TO SET THE DELAY TIME THROUGH SCRIPT YET. ONLY VIA EDITOR!!

@export_category("Patrol perameters")
@export var patrol_wait_time: float = 0.0
##How far from the enemy's origin the enemy will randomly patrol.
@export var random_patrol_range: float = 0.0
##Array of points the enemy will patrol to.
@export var patrol_points: Array[NodePath]
##How close the player can get before the enmy is alerted.

@export_category("View cone and alert perameters")
@export var alert_proximity_range: float = 0.0
##Enemy FOV view cone
@export var view_angle_degrees: float = 90
##Enemy FOV view distance
@export var view_radius: float = 20

@export_category("Melee perameters")
##If the player is within this range, the enemy will attempt to move to the player for a melee attack.
@export var melee_distance: float = 5
##If the player is within this range, the enemy will attempt its melee attack.
@export var melee_range: float = 1.3
##Enemy melee damage
@export var melee_damage: float = 10

@export_category("Cover perameters")
##Minimum distance from the player when finding cover
@export var min_cover_dist_p: float = 0
##Maximum distance from the player when finding cover
@export var max_cover_dist_p: float = 0
##Range in which the enemy will seek cover
@export var seek_cover_range: float = 10
##If the initial tests fail, the expanded perameters multiply by this value
@export var fail_attempt_multiplier: float = 1.2
##Currently stored cover position. Exposed so this may be manually set for encounter creation.
@export var current_cover: Vector3

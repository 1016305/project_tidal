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
@export_enum("Not In Cover","Moving To Cover","In Cover") var cover_state: String = "Not In Cover"

##Random patrol: Enemy will find a random spot nearby and walk to it.
##Sequence: Enemy will work through a list of nodes, going to each one individually.
##Random sequence: Enemy will pick a random node from the list and travel there.
@export_enum("Random Patrol","Sequence","Random Sequence") var patrol_type: String
##How long the enemy wait before heading to the next patrol point. !!CURRENTLY NOT FUNCTIONAL. I DONT KNOW HOW TO SET THE DELAY TIME THROUGH SCRIPT YET. ONLY VIA EDITOR!!

@export_category("Patrol perameters")
@export var patrol_wait_time: float = 0.0
##Minimum distance the patrol will attempt to find from the origin.
@export var min_random_patrol_range: float = 0.0
##Maximum distance the patrol will attempt to find from the origin.
@export var max_random_patrol_range: float = 0.0
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
##Minimum range in which the enemy will seek cover
@export var min_seek_cover_range: float = 0
##Maximum range in which the enemy will seek cover
@export var max_seek_cover_range: float = 0
##If the initial tests fail, the expanded perameters multiply by this value
@export var fail_attempt_multiplier: float = 1.2
##Currently stored cover position. Exposed so this may be manually set for encounter creation.
@export var current_cover: Vector3

@export_category("Enemy Weapon")
##How much damage the enemy will deal to the player.
@export var weapon_damage: int = 0
##How much variance from the initial damage value.
@export var weapon_damage_variance: int = 0
##How much ammo the enemy weapon can hold in a single magazine. (All enemies have infinite reserves)
@export var weapon_max_ammo: int = 0
##How much ammo the enemy is currently holding in its weapon.
@export var weapon_current_ammo: int = 0
##The time (seconds) between the enemy's shots.
@export var weapon_rate_of_fire: float = 0
##The rate of fire penalty to the enemy's weapon when moving. Multiplied by the rate of fire.
@export var moving_rof_penalty: float = 0
##How accurate the weapon is when shooting at the player
@export var weapon_accuracy: float = 0
##The accuracy penalty to the enemy's weapon when moving. Multiplied by the accuracy.
@export var moving_acc_penalty: float = 0

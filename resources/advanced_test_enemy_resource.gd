class_name advanced_test_enemy extends Resource

@export var health: int = 100
@export var ammo: int = 100
@export var max_ammo: int = 100
@export var move_speed: float = 5
@export var rotate_speed: float = 5
##Random patrol: Enemy will find a random spot nearby and walk to it.
##Sequence: Enemy will work through a list of nodes, going to each one individually.
##Random sequence: Enemy will pick a random node from the list and travel there.
@export_enum("Random Patrol","Sequence","Random Sequence") var patrol_type: String
##How long the enemy wait before heading to the next patrol point. !!CURRENTLY NOT FUNCTIONAL. I DONT KNOW HOW TO SET THE DELAY TIME THROUGH SCRIPT YET. ONLY VIA EDITOR!!
@export var patrol_wait_time: float = 0.0
##How far from the enemy's origin the enemy will randomly patrol.
@export var random_patrol_range: float = 0.0
##Array of points the enemy will patrol to.
@export var patrol_points: Array[NodePath]
##How close the player can get before the enmy is alerted.
@export var alert_proximity_range: float = 0.0
##Enemy FOV view cone
@export var view_angle_degrees: float = 90
##Enemy FOV view distance
@export var view_radius: float = 20

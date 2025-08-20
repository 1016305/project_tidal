class_name weapons extends Resource

##custom resource for weapons; imported from the testfile
@export var name: StringName
@export_category("Weapon Orientation")
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3
@export_category('Visual Settings')
@export var mesh: Array[Mesh]
## Adjustable position for the weapon's muzzle flare
@export var muzzle_flare_pos: Vector3

@export_category("Weapon Stats")
## Measured in seconds between shots
@export var weapon_rate_of_fire: float
@export var weapon_damage: float
## Adjustable decal size to better fit the weapons.
@export var weapon_decal_size: float

@export_category("Weapon Sway")
@export var sway_min: Vector2 = Vector2(-20.0,-20.0)
@export var sway_max: Vector2 = Vector2(20.0,20.0)
@export_range(0,0.2,0.01) var sway_speed_position: float = 0.07
@export_range(0,0.2,0.01) var sway_speed_rotation: float = 0.1
@export_range(0,0.25,0.01) var sway_ammount_position: float = 0.1
@export_range(0,50,0.1) var sway_ammount_rotation: float = 30.0
@export_range(0,50,0.1) var drift_max: float = 0.5
@export_range(0,0.5,0.01) var drift_speed: float = 0.1
@export_category("Viewmodel FOV")
@export var uses_shader: bool = false
@export_range(0,150,0.1) var fov_slider = 75.0

@export_category("Weapon Recoil")
@export var recoil_max: Vector3
@export var recoil_speed: float

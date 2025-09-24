class_name weapons extends Resource

#custom resource for weapons; imported from the testfile
## Weapon's referenced name
@export var name: StringName
## Position,scale,orientation of the weapon
@export_category("Weapon Orientation")
## Position on screen
@export var position: Vector3
## Rotation on screen (usually rotated inward a tiny bit (Y AXIS))
@export var rotation: Vector3
## Visual scale of weapon on the screen
@export var scale: Vector3
## Meshes and materials
@export_category('Visual Settings')
## All meshes used to render the weapon
@export var mesh: Array[Mesh]
## Adjustable position for the weapon's muzzle flare. Note: this is slightly broken sue to the weapon shader's behaviour. Need to fix.
@export var muzzle_flare_pos: Vector3

@export_category("Crosshair")
@export var crosshair: Texture2D

@export_category("Weapon Stats")
## Measured in seconds between shots
@export var weapon_rate_of_fire: float
@export var weapon_damage: float
## Adjustable decal size to better fit the weapons.
@export var weapon_decal_size: float

## Variables for the procedural weapon sway
@export_category("Weapon Sway")
@export var sway_min: Vector2 = Vector2(-20.0,-20.0)
@export var sway_max: Vector2 = Vector2(20.0,20.0)
@export_range(0,0.2,0.01) var sway_speed_position: float = 0.07
@export_range(0,0.2,0.01) var sway_speed_rotation: float = 0.1
@export_range(0,0.25,0.01) var sway_ammount_position: float = 0.1
@export_range(0,50,0.1) var sway_ammount_rotation: float = 30.0
@export_range(0,50,0.1) var drift_max: float = 0.5
@export_range(0,0.5,0.01) var drift_speed: float = 0.1
@export_range(0,5,0.1) var push_in_ammount: float = 0.1

@export_category("Weapon Bob")
@export var do_weapon_bob: bool = true
@export_range(-50,50,0.01) var horizontal_bob_amplitude: float = 0.0
@export_range(-50,50,0.01) var vertical_bob_amplitude: float = 0.0
@export_range(-50,50,0.01) var horizontal_bob_frequency: float = 0.0
@export_range(-50,50,0.01) var vertical_bob_frequency: float = 0.0

##Variables speak to the shader to get the FOV
@export_category("Viewmodel FOV")
@export var uses_shader: bool = false
@export_range(0,150,0.1) var fov_slider = 75.0

## Variables for the procedural weapon recoil
@export_category("Weapon Recoil")
@export var recoil_max: Vector3
@export var recoil_speed: float
## How accurate the weapon is, relative to the center of the screen. Best suited for low values. AR default is 0.04
@export var bloom: float

## Variables for the weapon's sound effects
@export_category("Weapon Sounds")
@export var shoot_sounds: Array[AudioStream]

##Variables for the weapon's ammo counter
@export_category("Ammo")
##Maximum in weapon's magazine
@export var weapon_max_ammo: int
##Current in weapon's magazine
@export var weapon_current_ammo: int
##Ammo consumed per shot
@export var ammo_per_shot: int
##Current reserve ammo the weapon contains
@export var weapon_reserve_ammo: int
##Maximum reserve ammo the weapon can hold. Should be a multiple of the weapon's magazine maximum.
@export var weapon_max_reserve: int

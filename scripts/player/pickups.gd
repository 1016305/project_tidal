class_name pickups extends Resource

##Type of resource to pick up
@export_enum("Health","Ammo","Other") var pickup_type: String

@export_enum("None","Assault Rifle", "Pistol") var weapon_type: String

@export var value: int

@export var model: Mesh

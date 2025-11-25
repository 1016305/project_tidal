class_name Bullet extends Node3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var area_3d: Area3D = $StaticBody3D/Area3D
var direction
var speed = 20
var damage = 0

func _ready() -> void:
	destroy_me()

func _physics_process(delta: float) -> void:
	bullet_move(delta)
	
func bullet_move(delta):
	position += -global_transform.basis.z * (speed * delta)

func destroy_me():
	await get_tree().create_timer(3).timeout
	self.queue_free()

func rotate_to_target(target):
	look_at(target)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		Global.player.damage(damage)
		queue_free()

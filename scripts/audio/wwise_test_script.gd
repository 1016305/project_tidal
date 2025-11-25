extends Area3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var event : WwiseEvent

func _ready() -> void:
	body_entered.connect(self.on_body_entered)
	
func on_body_entered(no):
	#print("test")
	event.post(self)

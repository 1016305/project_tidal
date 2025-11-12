extends Label

@export var master_value: HSlider

func _physics_process(delta: float) -> void:
	self.text = str(master_value.value)

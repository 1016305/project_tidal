class_name InteractionComponent extends Node

var parent
@export var is_used: bool = false
@export var message: String  = "interact"

func _ready() -> void:
	parent = get_parent()
	connect_parent()
	
func _physics_process(delta: float) -> void:
	pass

func in_range():
	if !is_used:
		var comp: String = "Press E to " + message
		print(comp)
		Global.emit_signal("interact_focus",comp)
		
func not_in_range():
		Global.emit_signal("interact_unfocus")
	
func on_interact():
	if !is_used:
		print(parent.name)

func connect_parent():
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interact")
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interact", Callable(self, "on_interact"))

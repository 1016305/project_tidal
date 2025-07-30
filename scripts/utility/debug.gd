#controls the debug panel. singleton can be accessed globally to add more elements to the panel
extends PanelContainer

var property
var fps: String
@onready var property_container: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	#hide on load
	visible = false
	Global.debug = self

func _input(event):
	#toggle panel
	if event.is_action_pressed("debug"):
		visible = !visible

func _process(delta):
	if visible:
		get_fps(delta)
		add_property("FPS",fps, 1 )

func add_property(title: String, value, order):
	#function to add elemetns to debug menu
	var target #hold label node being generated
	target = property_container.find_child(title,true,false) #check if property with same name already exists
	if !target:
		target = Label.new() #if none matching, create label
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": "  + str(value) #will update text if already found
		property_container.move_child(target,order) #move elements around in the menu

func get_fps(delta):
	#more reliable than the default method, as this updates every frame
	var _fps
	_fps = "%0.2f" % (1.0/delta) #get fps with 2 decimal points
	if ProjectSettings.get_setting('display/window/vsync/vsync_mode') == 1:
		_fps = _fps + ' [VSYNC ON]'
	elif ProjectSettings.get_setting('display/window/vsync/vsync_mode') == 2:
		_fps = _fps + ' [VSYNC ADAPTIVE]' 
	elif ProjectSettings.get_setting('display/window/vsync/vsync_mode') == 3:
		_fps = _fps + ' [VSYNC MAILBOX]'
	fps = _fps
	#print(fps)

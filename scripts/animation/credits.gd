extends Control

@onready var skip: Label = $PanelContainer/Label
@onready var video: VideoStreamPlayer = $VideoStreamPlayer

const _tex = preload("res://materials/shaders/loadingbar.tres")
var tex
var transparent: Color = Color(1,1,1,0)
@onready var timer: Timer = $Timer
@onready var skiptimer: Timer = $skiptimer
var tween
var t = 0
var t2 = 0
var skip_held: bool = false
var timer_out: bool = false

func _physics_process(delta: float) -> void:
	move_loading_bar(delta)
	hide_loading_bar(delta)
	show_loading_bar(delta)
	if Input.is_action_pressed("jump"):
		skip_held = true
		timer_out = false
		if skiptimer.is_stopped():
			skiptimer.start()
	else:
		skip_held = false
	if Input.is_action_just_released("jump"):
		skiptimer.stop()
		print("skiptimer stop")
	
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	tex = _tex.texture.gradient
	video.play()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or Input.is_action_pressed("jump"):
		if tween:
			tween.stop()
		show_skip_button()
		timer.start()
	if Input.is_action_just_pressed("jump"):
		timer_out = false

func hide_skip_button():
		tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(skip, "theme_override_colors/font_color", Color(1,1,1,0), 1)
func show_skip_button():
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(skip, "theme_override_colors/font_color", Color(1,1,1,1), 0.1)
	
func _on_timer_timeout() -> void:
	hide_skip_button()
	timer_out = true

func move_loading_bar(delta):
	if skip_held:
		t = lerpf(t,1.0,delta * 0.7)
		tex.set_offset(1,t)
		tex.set_offset(2,(t+0.05))

	if !skip_held:
		t = lerpf(t,0.0,delta * 0.7)
		tex.set_offset(1,t)
		tex.set_offset(2,(t+0.05))

func hide_loading_bar(delta):
	if !skip_held:
		var nu = tex.get_color(1)
		t2 = lerpf(nu.a,0,delta*0.9)
		tex.set_color(1, Color(1,1,1,t2))
		#tex.set_color(1, Color(1,1,1,0.658))
func show_loading_bar(delta):
	if skip_held:
		var nu = tex.get_color(1)
		t2 = lerpf(nu.a,0.658,delta*0.9)
		tex.set_color(1, Color(1,1,1,t2))

func _on_skiptimer_timeout() -> void:
	video.stop()
	get_tree().quit()

func _on_video_stream_player_finished() -> void:
	get_tree().quit()

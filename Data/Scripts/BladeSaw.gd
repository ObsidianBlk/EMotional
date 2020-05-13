extends KinematicBody2D

export var degrees_per_second:float = 180.0
export var ease_in:float = 0.2
export var ease_out:float = 0.4
export var active:bool = true setget _set_active

var _easing_in = false
var _easing_out = false
var _easing = 0.0
var _running = false


func _set_active(b):
	if active != b:
		if active:
			_easing_out = true
			_easing = ease_out
		else:
			_easing_in = true
			_easing = ease_in
		active = b

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	if active and _easing == 0.0:
		_running = true

func _physics_process(delta):
	if _easing_in or _easing_out:
		_easing -= delta
		if _easing <= 0.0:
			_running = _easing_in
			_easing_in = false
			_easing_out = false
			_easing = 0.0
		else:
			var adj
			if _easing_in:
				adj = 1.0 - (_easing / ease_in)
			else:
				adj = 1.0 - (_easing / ease_out)
			rotate(deg2rad(degrees_per_second * adj * delta))
	if _running:
		rotate(deg2rad(degrees_per_second * delta))


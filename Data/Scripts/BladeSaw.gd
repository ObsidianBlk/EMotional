extends KinematicBody2D

export var degrees_per_second:float = 180.0
export var ease_in:float = 0.2
export var ease_out:float = 0.4
export var active:bool = true setget _set_active

var _easing_in = false
var _easing_out = false
var _easing = 0.0
var _running = false

var _volume_on = 0
var _pitch_on = 1.0


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
	_volume_on = $audio.volume_db
	_pitch_on = $audio.pitch_scale
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
			if not _running:
				$audio.stop()
			$audio.volume_db = _volume_on
			$audio.pitch_scale = _pitch_on
		else:
			if not $audio.playing:
				$audio.play()
			var adj
			var vol
			if _easing_in:
				adj = 1.0 - (_easing / ease_in)
				vol = adj
			else:
				vol = (_easing / ease_out)
				adj = vol
			$audio.volume_db = (-80 + ((_volume_on + 80) * vol))
			$audio.pitch_scale = 0.1 + ((_pitch_on - 0.1) * vol)
			rotate(deg2rad(degrees_per_second * adj * delta))
	elif _running:
		if not $audio.playing:
			$audio.play()
		rotate(deg2rad(degrees_per_second * delta))


extends Node2D
# The code in this script was adapted from Game Endeavor on YouTube
# https://www.youtube.com/watch?v=_DAvzzJMko8

# NOTE: This script and associated scene assumes it's parented to a camera object!

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var _amplitude = 0
var _priority = 0
onready var _camera = get_parent()


func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	if priority >= _priority:
		_priority = priority
		_amplitude = amplitude
		$Duration.wait_time = duration
		$Frequency.wait_time = 1/float(frequency)
		
		$Duration.start()
		$Frequency.start()
		
		_shake()

func _interpolate_to(v):
	$Shake.interpolate_property(_camera, "offset", _camera.offset, v, $Frequency.wait_time, TRANS, EASE)
	$Shake.start()

func _shake():
	_interpolate_to(Vector2(
		rand_range(-_amplitude, _amplitude),
		rand_range(-_amplitude, _amplitude)
	))


func _on_Frequency_timeout():
	_shake()


func _on_Duration_timeout():
	_interpolate_to(Vector2())
	$Frequency.stop()
	$Duration.stop()
	_priority = 0

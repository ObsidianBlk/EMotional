extends StaticBody2D


const OPENED_POSITION = Vector2(-47, 0)
const CLOSED_POSITION = Vector2(-6, 0)
const POSITION_DIFF = 41

export var color:Color
export var transition_rate = 0.75

var _control_state = 0 # 0 = No-OP | 1 = Open | 2 = Close


func _ready():
	set_color(color)

func set_color(c):
	$Doorway/Glow.pulse_color = c

func is_opening():
	if $Tween.is_active():
		return _control_state == 1
	return false

func is_closing():
	if $Tween.is_active():
		return _control_state == 2
	return false

func open():
	var t = transition_rate
	var cdiff = ($Doorway.position - OPENED_POSITION).length()
	if cdiff > 0.001:
		t = transition_rate * (cdiff / POSITION_DIFF)
	$Tween.interpolate_property($Doorway, "position", $Doorway.position, OPENED_POSITION, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Audio.play()
	_control_state = 1

func close():
	var t = transition_rate
	var cdiff = ($Doorway.position - CLOSED_POSITION).length()
	if cdiff > 0.001:
		t = transition_rate * (cdiff / POSITION_DIFF)
	$Tween.interpolate_property($Doorway, "position", $Doorway.position, CLOSED_POSITION, t, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Audio.play()
	_control_state = 2

func stop():
	$Tween.stop($Doorway, "position")
	$Audio.stop()
	_control_state = 0

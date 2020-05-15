extends Node2D


export var color:Color
export var transition_rate = 0.75

var _body = null
var _triggered = false


func _dominant_color():
	if color.r > color.g and color.r > color.b:
		return "r"
	if color.g > color.r and color.g > color.b:
		return "g"
	if color.b > color.r and color.b > color.g:
		return "b"
	return "n"

func _ready():
	$LeftDoor.set_color(color)
	$LeftDoor.transition_rate = transition_rate
	$RightDoor.set_color(color)
	$RightDoor.transition_rate = transition_rate
	set_process(true)

func _process(delta):
	if _body == null or _triggered:
		return
	var mood = _body.get_mood()
	var dc = _dominant_color()
	if (dc == "r" and mood.is_aggressive()) or \
	(dc == "g" and mood.is_needie()) or \
	(dc == "b" and mood.is_content()) or \
	(dc == "n" and mood.is_neutral()):
		_triggered = true
		open()

func open():
	$LeftDoor.open()
	$RightDoor.open()

func close():
	$LeftDoor.close()
	$RightDoor.close()

func stop():
	$LeftDoor.stop()
	$RightDoor.stop()



func _on_Area2D_body_entered(body):
	if _body == null and body.is_in_group("Player"):
		_body = body
		_triggered = false


func _on_Area2D_body_exited(body):
	if body == _body:
		_body = null
		_triggered = false
		close()

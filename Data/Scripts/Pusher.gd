tool
extends Node2D

const PUSH_VEC_DEFAULT = Vector2(0.0, -1.0)

export var pulse_color:Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_color
export(float, 0, 400) var push_force = 128
export(float, 0, 1.0) var push_frequency = 0.2
export(float, -180.0, 180) var push_angle = 0 setget _set_angle

var _bodies = []
var _delay = 1.1

func _set_angle(a):
	push_angle = a
	$Body.rotation_degrees = push_angle

func _set_color(c):
	pulse_color = c
	for i in range(6):
		get_node("Body/PulseArrow" + String(i + 1)).set_color(pulse_color)
	$Body/Particles.process_material.color = c

func _dominant_color(c):
	if c.r > c.g and c.r > c.b:
		return "r"
	elif c.g > c.r and c.g > c.b:
		return "g"
	elif c.b > c.r and c.b > c.g:
		return "b"
	return "n"

func _ready():
	set_process(true)
	for i in range(6):
		get_node("Body/PulseArrow" + String(i + 1)).set_color(pulse_color)


func _rim_match(body):
	if body.has_method("get_rim_color"):
		var rdc = _dominant_color(body.get_rim_color())
		var dc = _dominant_color(pulse_color)
		print ("RIM: ", rdc, " | Push: ", dc)
		if (rdc == dc):
			return true
	return false

func _process(delta):
	if _bodies.size() > 0 and _delay >= push_frequency:
		_delay = 0.0
		var v = PUSH_VEC_DEFAULT.rotated(deg2rad(push_angle))
		for i in range(_bodies.size()):
			if _rim_match(_bodies[i]):
				_bodies[i].apply_central_impulse(v * push_force)
	else:
		_delay = min(1.1, _delay + delta)

func _has_body(body):
	for i in range(_bodies.size()):
		if _bodies[i] == body:
			return i
	return -1

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and _has_body(body) < 0:
		_bodies.append(body)


func _on_Area2D_body_exited(body):
	var id = _has_body(body)
	if (id >= 0):
		_bodies.remove(id)

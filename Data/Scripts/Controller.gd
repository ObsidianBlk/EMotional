extends RigidBody2D

export var max_distance = 64
export var max_tangential_accel = 32
export var max_travel_time = 2.0
export var push_force = 128

var body_radius = 0
var mouse_position = Vector2.ZERO
var mouse_down = false
var push = false
var traveling = 0;


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	body_radius = $CollisionShape2D.shape.radius


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
	if Input.is_action_just_pressed("ButtonA"):
		mouse_down = true
	elif Input.is_action_just_released("ButtonA"):
		mouse_down = false
		push = true


func _physics_process(delta):
	if mouse_down:
		return # We don't follow the mouse or move the squiq when mouse is down.
		
	var distance = clamp(mouse_position.x - position.x, -max_distance, max_distance)
	var dpercent = abs(distance / max_distance)
	if push:
		push = false
		traveling = max_travel_time
		var v_direction = (position - mouse_position).normalized()
		apply_central_impulse(v_direction * dpercent * push_force)
	elif traveling > 0:
		traveling -= delta
	else:
		if abs(distance) > body_radius:
			$Particles.process_material.tangential_accel = dpercent * max_tangential_accel;
			apply_central_impulse(Vector2(distance * delta, 0))
		else:
			$Particles.process_material.tangential_accel = 0


func _process(delta):
	update()

func _draw():
	if mouse_down:
		var distance = min(position.distance_to(mouse_position), max_distance)
		var v_direction = (position - mouse_position).normalized().rotated(-rotation)
		var v_start = v_direction * body_radius
		var v_end = v_direction * distance
		var v_tipA = v_end - (v_direction.rotated(deg2rad(30)) * min(distance, 16))
		var v_tipB = v_end - (v_direction.rotated(-deg2rad(30)) * min(distance, 16))
		var c_line = Color(0.25, 1.0, 0.0)
		draw_line(v_start, v_end, c_line)
		draw_line(v_end, v_tipA, c_line)
		draw_line(v_end, v_tipB, c_line)

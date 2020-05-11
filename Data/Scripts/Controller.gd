extends RigidBody2D

const COLLISION_MINOR_SPEED_THRESHOLD = 8
const COLLISION_MAJOR_SPEED_THRESHOLD = 32
const COLLISION_TIMEDT_THRESHOLD = 0.1

# The maximum distance from the player in which the mouse will adjust the push force.
# at max_mouse_distance the full base_push_force <+ modifiers> will be applied.
export var max_mouse_distance = 256 setget _set_max_mouse_distance

# The maximum the mouse can be from the player before player becomes "uncomfortable"
# (adjusted by mood)
export var max_comfort_distance = 10 setget _set_max_comfort_distance

# The base tangential acceleration that will be applied to the particles to give the
# player the illusion it's trying to move on it's own. This is just effects things visually (ATM)
export var base_tangential_accel = 32 setget _set_base_tangential_accel

# The base force applied when being pushed.
export var base_push_force = 128 setget _set_base_push_force


# Mood = r: <aggression>, g: <neediness>, b: <contentment>
# <aggression> Affects how strong a players push is and how strong the player's collision with the world will be.
# <neediness> Affects how quickly and strongly the player will follow the mouse
# <contentment> Affects how slowly mood color is shifted back to neutral and widens comfort distance
var mood = Color.black

var neutral_rim = Color(0.9, 0.9, 0.9, 1.0)

var mouse_position = Vector2.ZERO
var mouse_down = false
var push = false

var in_air = true
var air_time = 0
var last_speed = 0


func set_colors(prime, alt):
	if alt.r != alt.g or alt.r != alt.b:
		# only change the rim if there's a single dominant color.
		$Sprite.material.set_shader_param("rim_color", alt);
		$Particles.process_material.color = alt
	
	if prime.r != prime.g or prime.r != prime.b: # Only adjust mood if not all values are the same.
		# Even if not all the same, there must be a single dominant color for mood to be adjusted.
		if prime.r > prime.g and prime.r > prime.b:
			adjust_mood(Color(0.25, 0.0, 0.0, 1.0))
		if prime.g > prime.r and prime.g > prime.b:
			adjust_mood(Color(0.0, 0.25, 0.0, 1.0))
		if prime.b > prime.r and prime.b > prime.g:
			adjust_mood(Color(0.0, 0.0, 0.25, 1.0));

func get_colors():
	return {
		"prime": $Sprite.material.get_shader_param("cell_color"),
		"alt": $Sprite.material.get_shader_param("rim_color")
	};

func adjust_mood(mc):
	mood.r = clamp(mood.r + mc.r, 0.0, 1.0)
	mood.g = clamp(mood.g + mc.g, 0.0, 1.0)
	mood.b = clamp(mood.b + mc.b, 0.0, 1.0)
	$Sprite.material.set_shader_param("cell_color", mood);

func get_tangential_acceleration():
	return base_tangential_accel

func get_push_force():
	return base_push_force

func get_discomfort():
	pass

func get_body_radius():
	return $CollisionShape2D.shape.radius

func _set_max_mouse_distance(v):
	var br = $CollisionShape2D.shape.radius
	max_mouse_distance = max(br * 2, v)

func _set_max_comfort_distance(v):
	var br = $CollisionShape2D.shape.radius
	max_comfort_distance = max(br, v)

func _set_base_tangential_accel(v):
	base_tangential_accel = max(1.0, v)

func _set_base_push_force(v):
	base_push_force = max(1.0, v)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	$Sprite.material.set_shader_param("rim_color", neutral_rim);
	$Particles.process_material.color = neutral_rim


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = get_global_mouse_position()
	if Input.is_action_just_pressed("ButtonA"):
		mouse_down = true
	elif Input.is_action_just_released("ButtonA"):
		mouse_down = false
		push = true


func _shift_mood(delta):
	# This should shift the mood color back to black.
	# called py the _physics_process method (I could use the _process method, but I don't
	# want to possibly mix timings)
	pass

func _physics_process(delta):
	if mouse_down:
		return # We don't follow the mouse or move the squiq when mouse is down.
		
	if push:
		push = false
		var v_direction = (position - mouse_position).normalized()
		apply_central_impulse(v_direction * abs(v_direction.length()) * get_push_force())
	elif in_air:
		air_time += delta
	else:
		var distance = clamp(mouse_position.x - position.x, -max_mouse_distance, max_mouse_distance)
		var dpercent = distance / max_mouse_distance
		if abs(distance) > get_body_radius():
			var v_horizontal = Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY_VECTOR).rotated(deg2rad(-90))
			$Particles.process_material.tangential_accel = dpercent * get_tangential_acceleration();
			apply_central_impulse(v_horizontal * distance * delta)
		else:
			$Particles.process_material.tangential_accel = 0
	
	last_speed = linear_velocity.length()
	#print(last_speed)
	


func _process(delta):
	update()

func _draw():
	if mouse_down:
		var distance = min(position.distance_to(mouse_position), max_mouse_distance)
		var v_direction = (position - mouse_position).normalized().rotated(-rotation)
		var v_start = v_direction * get_body_radius()
		var v_end = v_direction * distance
		var v_tipA = v_end - (v_direction.rotated(deg2rad(30)) * min(distance, 16))
		var v_tipB = v_end - (v_direction.rotated(-deg2rad(30)) * min(distance, 16))
		var c_line = Color(0.25, 1.0, 0.0)
		draw_line(v_start, v_end, c_line)
		draw_line(v_end, v_tipA, c_line)
		draw_line(v_end, v_tipB, c_line)



func _on_Player_body_entered(body):
	in_air = false
	#print(linear_velocity)
	if air_time > COLLISION_TIMEDT_THRESHOLD:
		var lvlen = linear_velocity.length()
		if lvlen >= COLLISION_MINOR_SPEED_THRESHOLD and lvlen < COLLISION_MAJOR_SPEED_THRESHOLD:
			print("ooOF")
		elif lvlen >= COLLISION_MAJOR_SPEED_THRESHOLD:
			print("Oooooch!")
	air_time = 0


func _on_Player_body_exited(body):
	in_air = true

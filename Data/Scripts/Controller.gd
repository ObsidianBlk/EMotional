extends RigidBody2D

const COLLISION_MINOR_SPEED_THRESHOLD = 150
const COLLISION_MAJOR_SPEED_THRESHOLD = 400
const COLLISION_TIMEDT_THRESHOLD = 0.1

const ANIM_RATE_DEFAULT = 3.5
const ANIM_RATE_AGGRESSIVE = 6.0
const ANIM_RATE_CONTENT = 1.0

# The maximum distance from the player in which the mouse will adjust the push force.
# at max_mouse_distance the full base_push_force <+ modifiers> will be applied.
var max_mouse_distance = 256

# The maximum the mouse can be from the player before player becomes "uncomfortable"
var max_comfort_distance = 10

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
			adjust_mood(0.25, 0.0, 0.0)
		if prime.g > prime.r and prime.g > prime.b:
			adjust_mood(0.0, 0.25, 0.0)
		if prime.b > prime.r and prime.b > prime.g:
			adjust_mood(0.0, 0.0, 0.25)

func get_colors():
	return {
		"prime": $Sprite.material.get_shader_param("cell_color"),
		"alt": $Sprite.material.get_shader_param("rim_color")
	};

func adjust_mood(r, g, b):
	mood.r = clamp(mood.r + r, 0.0, 1.0)
	mood.g = clamp(mood.g + g, 0.0, 1.0)
	mood.b = clamp(mood.b + b, 0.0, 1.0)
	$Sprite.material.set_shader_param("cell_color", mood);
	
	if is_aggressive():
		$Sprite.material.set_shader_param("cell_energy", ANIM_RATE_AGGRESSIVE)
	elif is_content():
		$Sprite.material.set_shader_param("cell_energy", ANIM_RATE_CONTENT)
	else:
		$Sprite.material.set_shader_param("cell_energy", ANIM_RATE_DEFAULT)

func is_aggressive():
	return mood.r > mood.g and mood.r > mood.b

func is_needie():
	return mood.g > mood.r and mood.g > mood.b

func is_content():
	return mood.b > mood.r and mood.b > mood.g

func get_tangential_acceleration():
	return get_discomfort_adjustment(base_tangential_accel)

func get_push_force():
	var dist = (position - mouse_position).length() - get_body_radius()
	if dist <= 0.0:
		return 0.0
		
	var push = base_push_force * (dist / (max_mouse_distance))
	if mood.r > mood.b:
		if mood.r > 0.1 and mood.r < 0.5:
			push *= 1.25
		elif mood.r >= 0.5:
			push *= 1.5
		elif is_aggressive():
			push *= 2
	elif mood.b > mood.r:
		if mood.b > 0.1 and mood.b < 0.5:
			push *= 0.75
		elif mood.b >= 0.5:
			push *= 0.5
	return push

func get_discomfort_adjustment(v):
	return v * mood.g

func get_body_radius():
	return $CollisionShape2D.shape.radius

func _set_base_tangential_accel(v):
	base_tangential_accel = max(1.0, v)

func _set_base_push_force(v):
	base_push_force = max(1.0, v)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	max_comfort_distance = $CollisionShape2D.shape.radius
	$Sprite.material.set_shader_param("rim_color", neutral_rim);
	$Particles.process_material.color = neutral_rim


func _input(event):
	if Input.is_action_just_pressed("ButtonA"):
		mouse_down = true
	elif Input.is_action_just_released("ButtonA"):
		mouse_down = false
		push = true


func _shift_mood(delta):
	var nr = 0.0
	var ng = 0.0
	var nb = 0.0
	
	if in_air:
		if last_speed >= COLLISION_MINOR_SPEED_THRESHOLD:
			if last_speed >= COLLISION_MAJOR_SPEED_THRESHOLD:
				nr += 0.1
			else:
				nr += 0.05
		else:
			nr -= 0.1
			nb += 0.05
	
	# first handle red (aggression)
	if mood.r > 0:
		if mood.b > 0.0:
			if mood.b >= mood.r * 0.5:
				nr += -0.1
			if mood.b < mood.r * 0.5:
				nr += -0.05
			if mood.r > mood.b:
				nr += 0.05
	nr *= delta
	
	
	# Then handle green <neediness>
	# green <neediness> is based on how far the mouse is from the player. The greater the distance
	# the more <neediness> grows. This can be affected by <contentment> and <aggression> as well.
	var mdist = (position - mouse_position).length()
	if not in_air:
		if is_content():
			if mdist <= max_comfort_distance:
				ng += -0.1
			elif mdist < (max_mouse_distance * 0.5):
				ng += -0.05
		elif is_needie():
			if mdist <= max_comfort_distance:
				ng += -0.05
			elif mdist >= (max_mouse_distance * 0.5):
				ng += 0.1
			else:
				ng += 0.05
		elif is_aggressive():
			# If player is <aggressive>, then neediness is kinda forgotten about.
			if mood.r > 0.25 and mood.r < 0.5:
				ng += -0.05
			elif mood.r >= 0.5:
				ng += -0.15
		else:
			if mdist > max_comfort_distance:
				ng += 0.05
	ng *= delta
	
	
	# Finally handle blue <contentment>
	# If red <aggression> is half as high or more than blue <contentment>, then contentment goes down.
	if mood.r >= mood.b * 0.5:
		nb += -0.1
	elif mood.g > 0.0:
		nb += -0.025
	if mdist < max_comfort_distance:
		nb += 0.015
	else:
		nb += -0.1
	nb *= delta
	
	# Finalize changes!
	adjust_mood(nr, ng, nb)


func _physics_process(delta):
	mouse_position = get_global_mouse_position()
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
		if !is_content() and abs(distance) > get_body_radius():
			var v_horizontal = Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY_VECTOR).rotated(deg2rad(-90))
			$Particles.process_material.tangential_accel = dpercent * get_tangential_acceleration();
			apply_central_impulse(v_horizontal * get_discomfort_adjustment(distance) * delta)
		else:
			$Particles.process_material.tangential_accel = 0
	_shift_mood(delta)
	last_speed = linear_velocity.length()
	


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
		#var lvlen = linear_velocity.length()
		#print("Last Speed: ", last_speed)
		if last_speed >= COLLISION_MINOR_SPEED_THRESHOLD and last_speed < COLLISION_MAJOR_SPEED_THRESHOLD:
			adjust_mood(0.1, 0.0, -0.1)
			$Camera/ScreenShake.start()
		elif last_speed >= COLLISION_MAJOR_SPEED_THRESHOLD:
			adjust_mood(0.25, 0.0, -0.25)
			$Camera/ScreenShake.start(0.4, 15, 24)
	air_time = 0


func _on_Player_body_exited(body):
	in_air = true

extends RigidBody2D

const COLLISION_MINOR_SPEED_THRESHOLD = 150
const COLLISION_MAJOR_SPEED_THRESHOLD = 400
const COLLISION_TIMEDT_THRESHOLD = 0.1

export var max_stamina = 1000
export var stamina_regen_per_sec = 125

# The base tangential acceleration that will be applied to the particles to give the
# player the illusion it's trying to move on it's own. This is just effects things visually (ATM)
export var base_tangential_accel = 32 setget _set_base_tangential_accel

# The base force applied when being pushed.
export var base_push_force = 64 setget _set_base_push_force
export var push_stamina_cost = 100


var current_stamina = max_stamina

# The maximum distance from the player in which the mouse will adjust the push force.
# at max_mouse_distance the full base_push_force <+ modifiers> will be applied.
var max_mouse_distance = 128
var neutral_rim = Color(0.9, 0.9, 0.9, 1.0)

var mouse_position = Vector2.ZERO
var mouse_down = false
var push = false

var in_air = true
var air_time = 0
var last_speed = 0


func set_colors(prime, alt):
	$Sprite.material.set_shader_param("rim_color", alt);
	$Particles.process_material.color = alt
	if alt.r > alt.g and alt.r > alt.b:
		_set_color_collision_mask(1)
	elif alt.g > alt.r and alt.g > alt.b:
		_set_color_collision_mask(2)
	elif alt.b > alt.r and alt.b > alt.g:
		_set_color_collision_mask(3)
	else:
		# This should reset all of the collision masks to ON!
		_set_color_collision_mask(0)
	
	$Mood.adjust_mood_from_color(prime)

func get_colors():
	return {
		"prime": $Sprite.material.get_shader_param("cell_color"),
		"alt": $Sprite.material.get_shader_param("rim_color")
	};

func get_tangential_acceleration():
	return base_tangential_accel * $Mood.get_need()

func get_push_force():
	var dist = (position - mouse_position).length() - get_body_radius()
	if dist <= 0.0:
		return 0.0
		
	var push = base_push_force * (dist / (max_mouse_distance))
	var agg = $Mood.get_aggression()
	var con = $Mood.get_contentment()
	if agg > con:
		if agg > 0.1 and agg < 0.5:
			push *= 1.25
		elif agg >= 0.5:
			push *= 1.5
		elif $Mood.is_aggressive():
			push *= 2
	elif con > agg:
		if con > 0.1 and con < 0.5:
			push *= 0.75
		elif con >= 0.5:
			push *= 0.5
	return push


func get_body_radius():
	return $CollisionShape2D.shape.radius

func get_mood():
	return $Mood


func _set_color_collision_mask(id):
	set_collision_mask_bit(10, true)
	set_collision_mask_bit(11, true)
	set_collision_mask_bit(12, true)
	if id >= 1 and id <= 3:
		set_collision_mask_bit(9 + id, false)


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
	if Input.is_action_just_pressed("ButtonA"):
		mouse_down = true
	elif Input.is_action_just_released("ButtonA"):
		mouse_down = false
		if current_stamina >= push_stamina_cost:
			current_stamina -= push_stamina_cost
			push = true


func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	if mouse_down:
		return # We don't follow the mouse or move the squiq when mouse is down.
		
	if push:
		push = false
		var v_direction = (position - mouse_position).normalized()
		apply_central_impulse(v_direction * v_direction.length() * get_push_force())
	elif in_air:
		air_time += delta
	else:
		var distance = clamp(mouse_position.x - position.x, -max_mouse_distance, max_mouse_distance)
		var dpercent = distance / max_mouse_distance
		if !$Mood.is_content() and abs(distance) > get_body_radius():
			var v_horizontal = Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY_VECTOR).rotated(deg2rad(-90))
			$Particles.process_material.tangential_accel = dpercent * get_tangential_acceleration();
			apply_central_impulse(v_horizontal * distance * $Mood.get_need() * delta)
		else:
			$Particles.process_material.tangential_accel = 0
	$Mood.shift_mood(delta, in_air, last_speed, (position - mouse_position).length())
	last_speed = linear_velocity.length()
	
	current_stamina += stamina_regen_per_sec * delta
	if current_stamina > max_stamina:
		current_stamina = max_stamina
	


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
			$Mood.adjust_mood(0.1, 0.0, -0.1)
			$Camera/ScreenShake.start()
		elif last_speed >= COLLISION_MAJOR_SPEED_THRESHOLD:
			$Mood.adjust_mood(0.25, 0.0, -0.25)
			$Camera/ScreenShake.start(0.4, 15, 24)
	air_time = 0


func _on_Player_body_exited(body):
	in_air = true

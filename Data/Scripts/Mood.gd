extends Node2D

const ANIM_RATE_DEFAULT = 3.5
const ANIM_RATE_AGGRESSIVE = 6.0
const ANIM_RATE_CONTENT = 1.0

const EXCITEMENT_MIN_SPEED = 150
const EXCITEMENT_MAX_SPEED = 350

# Mood = r: <aggression>, g: <neediness>, b: <contentment>
# <aggression> Affects how strong a players push is and how strong the player's collision with the world will be.
# <neediness> Affects how quickly and strongly the player will follow the mouse
# <contentment> Affects how slowly mood color is shifted back to neutral and widens comfort distance
var _mood = Color.black

onready var _spr = get_parent().get_node("Sprite")
onready var _body_radius = get_parent().get_node("CollisionShape2D").shape.radius

func reset_mood():
	_mood = Color.black
	_spr.material.set_shader_param("cell_color", _mood);

func adjust_mood(r, g, b):
	_mood.r = clamp(_mood.r + r, 0.0, 1.0)
	_mood.g = clamp(_mood.g + g, 0.0, 1.0)
	_mood.b = clamp(_mood.b + b, 0.0, 1.0)
	_spr.material.set_shader_param("cell_color", _mood);
	
	if is_aggressive():
		_spr.material.set_shader_param("cell_energy", ANIM_RATE_AGGRESSIVE)
	elif is_content():
		_spr.material.set_shader_param("cell_energy", ANIM_RATE_CONTENT)
	else:
		_spr.material.set_shader_param("cell_energy", ANIM_RATE_DEFAULT)

func adjust_mood_from_color(c):
	if c.r != c.g or c.r != c.b: # Only adjust mood if not all values are the same.
		# Even if not all the same, there must be a single dominant color for mood to be adjusted.
		if c.r > c.g and c.r > c.b:
			adjust_mood(0.25, 0.0, 0.0)
		if c.g > c.r and c.g > c.b:
			adjust_mood(0.0, 0.25, 0.0)
		if c.b > c.r and c.b > c.g:
			adjust_mood(0.0, 0.0, 0.25)

func is_aggressive():
	return _mood.r > _mood.g and _mood.r > _mood.b

func is_needie():
	return _mood.g > _mood.r and _mood.g > _mood.b

func is_content():
	return _mood.b > _mood.r and _mood.b > _mood.g

func is_neutral():
	return not is_aggressive() and not is_needie() and not is_content()

func get_aggression():
	return _mood.r

func get_need():
	return _mood.g

func get_contentment():
	return _mood.b

func get_comfort_distance():
	return get_parent().get_node("CollisionShape2D").shape.radius * 2.1

func get_mood_color():
	return _mood

func _agg_shift(in_air, speed):
	var v = -0.1 # By default, aggression is always lowering
	
	if in_air and speed >= EXCITEMENT_MIN_SPEED and speed <= EXCITEMENT_MAX_SPEED:
			v = 0.1 # If in the air, going at an "exciting" speed, aggression rises!
	elif is_aggressive():
		v = -0.05 # Otherwise, if we're dominantly aggressive, slow aggression cooldown.
		if speed > 1.0 and _mood.r * 0.5 > _mood.b and _mood.r * 0.5 > _mood.g:
			v = 0.0 # But, if we're moving and our aggression is more than twice the other emotions, don't cooldown at all.
	return v

func _need_shift(in_air, distance):
	var v = -0.1
	if in_air:
		# Decrease neediness faster while in air, as "player" is giving attension (in the air) or
		# otherwise excited!!
		v = -0.25
	else:
		var cdist = get_comfort_distance()
		if distance > cdist:
			v = 0.1
			if distance > cdist * 8.0:
				v = 0.25
	return v

func _con_shift(in_air, speed, distance):
	var v = -0.1
	if in_air and speed < EXCITEMENT_MIN_SPEED:
		v = 0.1
		if is_aggressive(): # Assuming aggression hasn't taken over...
			v = 0.05 # Levitating in the air is nice!
	else:
		var cdist = get_comfort_distance()
		if distance <= cdist:
			v = 0.1 # It's nice when the player is nearby
			if is_needie():
				v = 0.05 # My neediness is slowing my contentment.
		elif is_aggressive():
			v = -0.25 # If aggressive, reduce contentment a lot.
	return v

func shift_mood(delta, in_air, speed, distance):
	adjust_mood(
		_agg_shift(in_air, speed) * delta,
		_need_shift(in_air, distance) * delta,
		_con_shift(in_air, speed, distance) * delta
	)

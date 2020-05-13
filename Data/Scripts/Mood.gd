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

func get_aggression():
	return _mood.r

func get_need():
	return _mood.g

func get_contentment():
	return _mood.b

func get_comfort_distance():
	return get_parent().get_node("CollisionShape2D").shape.radius * 1.1

func get_mood_color():
	return _mood

func shift_mood(delta, in_air, speed, distance):
	var nr = 0.0
	var ng = 0.0
	var nb = 0.0
	
	if in_air:
		if speed >= EXCITEMENT_MIN_SPEED:
			if speed >= EXCITEMENT_MAX_SPEED:
				nr += 0.1
			else:
				nr += 0.05
		else:
			nr -= 0.1
			nb += 0.05
	
	# first handle red (aggression)
	if _mood.r > 0:
		if _mood.b > 0.0:
			if _mood.b >= _mood.r * 0.5:
				nr += -0.1
			if _mood.b < _mood.r * 0.5:
				nr += -0.05
			if _mood.r > _mood.b:
				nr += 0.05
	nr *= delta
	
	
	# Then handle green <neediness>
	# green <neediness> is based on how far the mouse is from the player. The greater the distance
	# the more <neediness> grows. This can be affected by <contentment> and <aggression> as well.
	var cdist = get_comfort_distance()
	if not in_air:
		if is_content():
			if distance <= cdist:
				ng += -0.1
			elif distance < (cdist * 0.5):
				ng += -0.05
		elif is_needie():
			if distance <= cdist:
				ng += -0.05
			elif distance >= (cdist * 0.5):
				ng += 0.1
			else:
				ng += 0.05
		elif is_aggressive():
			# If player is <aggressive>, then neediness is kinda forgotten about.
			if _mood.r > 0.25 and _mood.r < 0.5:
				ng += -0.05
			elif _mood.r >= 0.5:
				ng += -0.15
		else:
			if distance > cdist:
				ng += 0.05
	ng *= delta
	
	
	# Finally handle blue <contentment>
	# If red <aggression> is half as high or more than blue <contentment>, then contentment goes down.
	if _mood.r >= _mood.b * 0.5:
		nb += -0.1
	elif _mood.g > 0.0:
		nb += -0.025
	if distance < cdist:
		nb += 0.015
	else:
		nb += -0.1
	nb *= delta
	
	# Finalize changes!
	adjust_mood(nr, ng, nb)

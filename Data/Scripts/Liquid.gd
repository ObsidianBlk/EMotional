#tool
extends Sprite

export var liquid_body_color:Color setget _set_liquid_body_color, _get_liquid_body_color
export var liquid_surface_color:Color setget _set_liquid_surface_color, _get_liquid_surface_color


func _set_liquid_body_color(c):
	material.set_shader_param("liquid_color_main", c)

func _get_liquid_body_color():
	return material.get_shader_param("liquid_color_main")

func _set_liquid_surface_color(c):
	material.set_shader_param("liquid_color_surface", c)
	$Splash.process_material.color = c

func _get_liquid_surface_color():
	return material.get_shader_param("liquid_color_surface")

func _ready():
	material.set_shader_param("sprite_scale", scale)
	#$Splash.process_material.color = material.get_shader_param("liquid_color_surface")
	if scale.x != 0 and scale.y != 0:
		$Splash.scale = Vector2(1/scale.x, 1/scale.y)
	set_process(true)


func _process(delta):
	pass


func _on_Trigger_body_entered(body):
	
	if scale.x != 0:
		var bpos = body.get_global_transform().origin
		var spos = get_global_transform().origin
		var delta = bpos.x - spos.x
		
		$Splash.position.x = (delta * (1/scale.x))
		$Splash.emitting = true 
	
	if (body.has_method("set_colors")):
		body.set_colors(
			material.get_shader_param("liquid_color_main"),
			material.get_shader_param("liquid_color_surface")
		)

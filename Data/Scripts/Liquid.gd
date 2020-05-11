extends Sprite

func _ready():
	material.set_shader_param("sprite_scale", scale)
	set_process(true)


func _process(delta):
	pass


func _on_Trigger_body_entered(body):
	if (body.has_method("set_colors")):
		body.set_colors(
			material.get_shader_param("liquid_color_main"),
			material.get_shader_param("liquid_color_surface")
		)

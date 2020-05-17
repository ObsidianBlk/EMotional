shader_type canvas_item;

uniform float rot_speed:hint_range(-6.0, 6.0) = 1.0;

void fragment(){
	float ri = TIME * rot_speed;
	
	mat2 rm = mat2(
		vec2(sin(ri), -cos(ri)),
		vec2(cos(ri), sin(ri))
	);
	vec2 pos = rm * (UV - vec2(0.5, 0.5));
	pos = pos + vec2(0.5, 0.5);
	
	COLOR = texture(TEXTURE, pos);
}
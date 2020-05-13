shader_type canvas_item;

uniform vec4 primary_color:hint_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform float fade_offset:hint_range(0.0, 0.5) = 0.1;

float ramp(float v, float f_min, float f_max){
	float res = (v - f_min) / (f_max - f_min);
	return max(0.0, min(res, 1.0));
}

void fragment(){
	float mask = length(vec2(0.5, 0.5) - (UV.xy));
	float fade = 1.0 - ramp(mask, fade_offset, 0.5);
	if (mask > 0.5){
		mask = 0.0;
	} else {mask = 1.0;}
	
	if (mask == 1.0){
		COLOR = vec4(primary_color.rgb, fade);	
	} else {
		COLOR = vec4(primary_color.rgb, mask);
	}
}
shader_type canvas_item;

uniform vec2 sprite_scale = vec2(1.0, 1.0);
uniform float distortion : hint_range(0.1, 100.0) = 8.0;

uniform vec4 liquid_color_main : hint_color = vec4(0.1, 0.2, 0.8, 0.25);
uniform vec4 liquid_color_surface : hint_color = vec4(0.1, 0.2, 1.0, 0.5);
uniform float liquid_surface_thickness : hint_range(0.0, 1.0) = 0.2;

uniform float wave_amp : hint_range(-1.0, 1.0) = 0.25;
uniform float wave_freq : hint_range(0.0, 1.0) = 1.0;
uniform float wave_scale :hint_range(0.0, 10.0) = 1.0;


float rand(vec2 p){
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 p){
	vec2 i = floor(p);
	vec2 f = fract(p);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - (2.0 * f));
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float ramp(float v, float f_min, float f_max){
	float res = (v - f_min) / (f_max - f_min);
	return max(0.0, min(1.0, res));
}

vec2 wavey_y(vec2 p, float time) {
	float dy = wave_amp * sin(wave_freq * (p.x * liquid_surface_thickness) * time);
	//return vec2(dx, dy);
	return vec2(p.x, p.y + dy);
}


void fragment(){
	vec2 noise1 = UV * sprite_scale * distortion;
	vec2 noise2 = UV * (sprite_scale * distortion) + 4.0;
	
	vec2 motion1 = vec2(TIME * 0.3, TIME * -0.4);
	vec2 motion2 = vec2(TIME * 0.1, TIME * 0.5);
	
	vec2 distort1 = vec2(noise(noise1 + motion1), noise(noise2 + motion1)) - vec2(0.5);
	vec2 distort2 = vec2(noise(noise1 + motion2), noise(noise2 + motion2)) - vec2(0.5);
	
	vec2 dsum = (distort1 + distort2) / 60.0;
	
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV + dsum);
	
	color = mix(color, liquid_color_main, 0.3);
	color.rgb = mix(vec3(0.5), color.rgb, 1.4);
	
	float near_top = 1.0 - clamp((UV.y + dsum.y) / (liquid_surface_thickness / sprite_scale.y), 0.0, 1.0);
	color = mix(color, liquid_color_surface, near_top);
	
	float tedge_lower = 0.6;
	float tedge_upper = tedge_lower + 0.1;
	if (near_top > tedge_lower){
		color.a = 0.0;
		if (near_top < tedge_upper){
			color.a = (tedge_upper - near_top) / (tedge_upper - tedge_lower);
		}
	}
	
	COLOR = color;
}
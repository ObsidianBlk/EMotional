shader_type canvas_item;

uniform float rimWidth : hint_range(1.0, 3.0) = 2.0;
uniform vec4 rim_color : hint_color;
uniform vec4 cell_color : hint_color;
uniform float fisheye_power = 2.0;
uniform float wave_amp : hint_range(-1.0, 1.0) = 0.25;
uniform float wave_freq : hint_range(0.0, 1.0) = 0.25;
uniform float wave_scale :hint_range(0.0, 10.0) = 1.0;

vec2 random2(vec2 p){
	return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);	
}

float ramp(float v, float f_min, float f_max){
	float res = (v - f_min) / (f_max - f_min);
	return max(0.0, min(res, 1.0));
}

float CellularNoise(vec2 vUV, float scale, float time){
	// Code modified from...
	// https://thebookofshaders.com/12/
	vec2 st = vUV * scale;
	//st.x = vres.x/vres.y;
	
	vec2 i_st = floor(st);
	vec2 f_st = fract(st);
	
	float min_dist = 1.0;
	
	for (int y = -1; y <= 1; y++){
		for (int x = -1; x <= 1; x++){
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = random2(i_st + neighbor);
			point = 0.5 + (0.5 * sin(time + (6.2831 * point)));	
			float dist = length((neighbor + point) - f_st);
			min_dist = min(min_dist, dist);
		}	
	}
	
	return min_dist;
}


vec2 fisheye(vec2 p) {
	// Function borrowed and slightly modified from...
	// https://gist.github.com/henriquelalves/989fdd72e10c90091188
	p *= 2.0;
	p -= vec2(1.0, 1.0);
	if (length(p) >= 1.5){return p;}
	//return p;
	if(p.x > 0.0){
		float angle = p.y / p.x;
		float theta = atan(angle);
		float radius = length(p);
		radius = pow(radius, fisheye_power);
		
		p.x = radius * cos(theta);
		p.y = radius * sin(theta);
	} else {
		float angle = p.y / p.x;
		float theta = atan(angle);
		float radius = length(p);
		radius = pow(radius, fisheye_power);
		
		p.y = radius * sin(-theta);
		p.x = radius * cos(theta);
		p.x = - p.x;
	}
	
	
	return 0.5 * (p + vec2(1.0,1.0));
}

vec2 wavey(vec2 p, float time) {
	float dx = wave_amp * sin(wave_freq * (p.y * wave_scale) * time);
	float dy = wave_amp * cos(wave_freq * (p.x * wave_scale) * time);
	//return vec2(dx, dy);
	return vec2(p.x + dx, p.y + dy);
}


void fragment(){
	float n = ramp(CellularNoise(wavey(fisheye(UV.xy), TIME), 5.0, TIME), 0.2, 0.9);
	float rim = length(vec2(0.5, 0.5) - (UV.xy));
	float mask = 1.0;
	if (rim > 0.5){
		rim  = 0.0;
		mask = 0.0;
	}
	vec4 r_color = rim_color;
	rim = ramp(pow(rim, 4.0 - rimWidth), 0.125, 0.5);
	
	vec4 color = vec4(((cell_color.rgb * 0.5) + (texture(SCREEN_TEXTURE, wavey(SCREEN_UV, TIME*2.0)).rgb * 0.5)) * n, n);
	if (mask > 0.0){
		if (rim >= 0.9 || rim > n){
			color = color + vec4(rim_color.rgb * rim, rim);
		}
	} else {
		color.a = 0.0;	
	}
		
	COLOR = color;
}
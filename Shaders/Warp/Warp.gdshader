shader_type spatial;
render_mode blend_add, unshaded;

uniform vec3 override_color: source_color = vec3(0.0, 0.0, 0.0);
uniform sampler2D noise_tex;

uniform vec2 resolution = vec2(100.0, 100.0);
uniform float speed: hint_range(0.1, 4.0, 0.1) = 1.0;
uniform int octaves: hint_range(1, 10, 1) = 5;
uniform float frecuency_modifier: hint_range(0.1, 4.0, 0.1) = 1.8;
uniform float amplitude_modifier: hint_range(0.1, 10.0, 0.1) = 1.6;
uniform float time_shift: hint_range(0.01, 2.0, 0.1) = 0.7;
uniform float zoom: hint_range(1.0, 20.0, 0.1) = 5.0;

vec3 sample_noise(vec2 uv) {
	return texture(noise_tex, uv).rgb * 2.5 - 1.0;
}

vec2 warp(vec2 uv, float time) {
	float frecuency = 1.0;
	float amplitude = 1.0;
	float shift = 1.0;
	for(int i = 0; i < octaves; ++i) {
		uv += vec2(cos(uv.y * frecuency + (time * shift)), sin(uv.x * frecuency + time * shift)) / amplitude;
		frecuency *= frecuency_modifier;
		amplitude *= amplitude_modifier;
		shift *= time_shift;
	}
	return uv;
}

vec3 base_color(vec2 uv, float time) {
	vec3 base_noise = sample_noise(uv);
	vec3 colored_noise = vec3(base_noise * override_color);
	return colored_noise;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float time = TIME * speed;
	
	vec2 uv = UV;
	uv.x *= resolution.x / resolution.y;
	uv *= zoom;
	uv = warp(uv, time);
	
	vec3 color = base_color(uv, time);
	
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

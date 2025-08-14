shader_type spatial;

uniform vec3 water_color : source_color;
uniform float uv_scale : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float time_scale : hint_range(0.0, 10.0, 0.1) = 10.0;
uniform sampler2D water_normal_noise;
uniform float sun_highlights_time : hint_range(0.0, 10.0, 0.1) = 10.0;
uniform sampler2D sun_highlights;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform float color_ratio : hint_range(0.0, 1.0, 0.1) = 0.5;

uniform vec2 abberation_r;
uniform vec2 abberation_g;
uniform vec2 abberation_b;

uniform sampler2D depth_texture : hint_depth_texture;
uniform float depth_distance : hint_range(0.0, 10.0, 0.1) = 0.5;

varying vec4 world_uv;

vec3 soft_light(vec3 base, vec3 blend)
{
	vec3 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base *(1.0 - 2.0 * blend),
		sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}
void vertex()
{
	world_uv = MODEL_MATRIX * vec4(VERTEX, 1.0);
}
void fragment() {
	
	// depth
	float depth_r = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_r, 1.0);
	world.xyz /= world.w;
	float depth_blend = smoothstep(world.z + depth_distance, world.z, VERTEX.z);
	
	vec2 _uv = UV * uv_scale;
	
	_uv.x += sin(TIME * time_scale + (_uv.x + _uv.y)* 25.0) * 0.01;
	_uv.y += cos(TIME * time_scale + (_uv.x - _uv.y)* 25.0) * 0.01;
	
	vec2 _suv = SCREEN_UV;
	
	_suv.x += sin(TIME * time_scale + (_suv.x + _suv.y)* 25.0) * 0.01;
	_suv.y += cos(TIME * time_scale + (_suv.x - _suv.y)* 25.0) * 0.01;
	
	float r = texture(sun_highlights, _uv + abberation_r + TIME * sun_highlights_time).r;
	float g = texture(sun_highlights, _uv + abberation_g + TIME * sun_highlights_time).g;
	float b = texture(sun_highlights, _uv + abberation_b + TIME * sun_highlights_time).b;
	
	vec3 blended = soft_light(texture(screen_texture, _suv).rgb, vec3(r,g,b).rgb);
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	ALBEDO = mix(blended * depth_blend, water_color, color_ratio);
	
	NORMAL_MAP = texture(water_normal_noise, _uv).rgb;
	NORMAL *= 0.5;
	ROUGHNESS = 0.1;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

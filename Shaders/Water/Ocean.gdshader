shader_type spatial;

global uniform vec3 ocean_pPosition; 

uniform vec3 water_color : source_color;
uniform float uv_scale : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float time_scale : hint_range(0.0, 10.0, 0.1) = 10.0;
uniform sampler2D water_normal_noise;
uniform float sun_highlights_time : hint_range(0.0, 10.0, 0.1) = 10.0;
uniform sampler2D sun_highlights;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

//depth values
uniform sampler2D depth_texture : hint_depth_texture;
uniform float depth_distance : hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float beers_law : hint_range(0.0, 1.0, 0.1) = 12.0;
uniform float water_transparency : hint_range(0.0, 1.0, 0.1) = 0.0;

//refraction values
uniform float refraction_strength : hint_range(0.0, 8.0, 0.001) = 0.5;

varying vec3 world_position;
varying float vertex_distance;
varying float vertex_distance_clamped;



vec3 soft_light(vec3 base, vec3 blend)
{
	vec3 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * base *(1.0 - 2.0 * blend),
		sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}

void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vertex_distance = distance(world_position, ocean_pPosition);
	vertex_distance = clamp(vertex_distance, 0.0, 85.0);
	vertex_distance_clamped = vertex_distance / 85.0;
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
	
//refraction
	vec3 normalmap = texture(water_normal_noise, _uv).rgb;
	vec3 ref_normalmap = normalmap * 2.0;
	vec3 ref_normal = mix(NORMAL, TANGENT * ref_normalmap + BINORMAL * ref_normalmap + NORMAL * ref_normalmap, 1.0);
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction_strength;
	
	float depth_clean = textureLod(depth_texture,SCREEN_UV, 0.0).r;
	float depth = texture(depth_texture, ref_ofs, 0.0).r;
	
	vec3 screen = textureLod(screen_texture, ref_ofs, 0.0).rgb;
	
	vec3 refraction_texture = textureLod(screen_texture, ref_ofs, ROUGHNESS * 2.0).rgb;
	
	
	ALBEDO = mix(screen * depth_blend, refraction_texture, water_transparency * depth_blend);
	NORMAL_MAP = normalmap;
	NORMAL *= 0.5;
	ROUGHNESS = 0.1;
}

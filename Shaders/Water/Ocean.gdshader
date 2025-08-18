shader_type spatial;

global uniform vec3 ocean_pPosition;

uniform float uv_scale : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float time_scale : hint_range(0.0, 10.0, 0.1) = 10.0;
uniform sampler2D water_normal_noise;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

//depth values
uniform sampler2D depth_texture : hint_depth_texture;
uniform vec3 color_deep : source_color = vec3(0.11,0.29,0.33); // Deep depth color
uniform vec3 color_shallow : source_color = vec3(0.0,0.47,0.76); // Shallow depth color
uniform float depth_distance : hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float water_transparency : hint_range(0.0, 1.0, 0.1) = 0.0;

//refraction values
uniform float refraction_strength : hint_range(0.0, 8.0, 0.001) = 0.5;

varying vec3 world_position;
varying float vertex_distance;
varying float vertex_distance_clamped;


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

	// Depth
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, DEPTH);
	vec3 ndc_clean =  vec3(SCREEN_UV * 2.0 -1.0, depth_clean);

	vec4 view =  INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z + VERTEX.z;

	vec3 refraction_texture;
	if(linear_depth < 0.00001)
	{
		refraction_texture = textureLod(screen_texture, SCREEN_UV, ROUGHNESS * 2.0).rgb;
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc_clean, 1.0);
	}
	else{
		refraction_texture = textureLod(screen_texture, ref_ofs, ROUGHNESS * 2.0).rgb;
		world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	}

	vec3 screen = textureLod(screen_texture, ref_ofs, 0.0).rgb;

	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend).rgb;
	vec3 final_color = mix(depth_color * screen, refraction_texture, water_transparency * depth_blend);

	ALBEDO = final_color;
	NORMAL_MAP = normalmap;
	NORMAL *= 0.5;
	ROUGHNESS = 0.1;
}

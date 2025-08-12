shader_type spatial;

uniform float speed : hint_range(-1,1) = 0.0;

//colors
uniform sampler2D noise1; //add Godot noise here
uniform sampler2D noise2; //add Godot noise here
uniform sampler2D normalmap : hint_normal; //add Godot noise here, enable as_normalmap
uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable;
uniform vec4 color : source_color;
uniform vec4 edge_color : source_color;

//foam
uniform float edge_scale = 0.25;
uniform float near = 0.1;
uniform float far = 100.0;

//waves
uniform vec2 wave_strengh = vec2(0.5, 0.25);
uniform vec2 wave_frequency = vec2(12.0, 12.0);
uniform vec2 time_factor = vec2(1.0, 2.0);



float rim(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}


float waves(vec2 pos, float time){
	return (wave_strengh.y * sin(pos.y * wave_frequency.y + time * time_factor.y)) + (wave_strengh.x * sin(pos.x * wave_frequency.x + time * time_factor.x));
}


void vertex(){
	VERTEX.y += waves(VERTEX.xy, TIME);
}


void fragment(){
	float time = TIME * speed;
	vec3 n1 = texture(noise1, UV + time).rgb;
	vec3 n2 = texture(noise2, UV - time * 0.2).rgb;
	vec3 normal_map = vec3(n1.xy + n2.xy, 0.0);
	
	vec2 uv_movement = UV * 4.0;
	uv_movement += TIME * speed * 4.0;
	
	float sum = (n1.r + n2.r) - 1.0;
	
	float z_depth = rim(texture(screen_texture, SCREEN_UV).x);
	float z_pos = rim(FRAGCOORD.z);
	float diff = z_depth - z_pos;
	
	vec2 displacement = vec2(sum * 0.05);
	diff += displacement.x * 50.0;
	
	
	vec4 col = mix(edge_color, color, step(edge_scale, diff));
	
	vec4 alpha = vec4(1.0);
	alpha = texture(screen_texture, SCREEN_UV + displacement);
	
	
	float fin = 0.0;
	if (sum > 0.0 && sum < 0.4) fin = 0.1;
	if (sum > 0.4 && sum < 0.8) fin = 0.0;
	if (sum > 0.8) fin = 1.0;
	
	NORMAL_MAP_DEPTH = 1.0;
	normal_map.z = sqrt(max(0.0, 1.0 - dot(normal_map.xy, normal_map.xy)));
	NORMAL = normalize(mix(NORMAL, TANGENT * normal_map.x + BINORMAL * normal_map.y + NORMAL * normal_map.z, NORMAL_MAP_DEPTH));
	
	vec2 distorted_uv = SCREEN_UV - normal_map.xy * 0.25 / length(VERTEX);
	ALBEDO = vec3(fin) + mix(alpha.rgb, col.rgb, color.a) + texture(screen_texture,distorted_uv).rgb;
	
	NORMAL_MAP = texture(normalmap, uv_movement).rgb;
	ROUGHNESS = 0.0;
	SPECULAR = 0.0;
}
shader_type spatial;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform sampler2D random;
//replace noise random for player position
uniform vec3 player_pos;
varying vec3 final_displace;
varying vec3 worldPos;

void vertex() {
	worldPos = (MODELVIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec3 result = worldPos - texture(random, UV + TIME).xyz;
	
	float final_leng = length(result);
	
	result = result * vec3(1,0,1);
	result = normalize(result);
	result = (vec4(result,1.0) * MODELVIEW_MATRIX).xyz;
	result = result * UV.y;
	vec3 area = result * smoothstep(10,0,final_leng);
	
	VERTEX = VERTEX + area ;
	
	
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xy / noiseScale).rgb;
	ALBEDO = mix(color,color2,UV.y) * mix(color, color2, noiseLevel.r);
	if(!FRONT_FACING)
	{
		NORMAL = -NORMAL;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

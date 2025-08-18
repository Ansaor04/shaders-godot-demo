shader_type sky;

uniform vec3 sky_color : source_color;
uniform vec3 horizon_color : source_color;
uniform sampler2D skyTexture;
void sky() {
	vec3 finalColor = mix(horizon_color, sky_color,CURRENT_RENDERER);
	vec3 hdr_skycolor = texture(skyTexture,vec2(SKY_COORDS.x + TIME / 100.0, SKY_COORDS.y)).rgb;
	COLOR = hdr_skycolor * finalColor;
}

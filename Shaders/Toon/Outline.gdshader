shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform float size : hint_range(1.0, 1.5, 0.01) = 1.02;
uniform vec4 mainColor : source_color = vec4(0.22, 0.22, 0.22, 1);

void vertex() {
	VERTEX *= size;
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = mainColor.rgb;
	ALPHA = mainColor.a;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

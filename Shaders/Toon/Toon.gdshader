shader_type spatial;
uniform vec3 mainColor : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = mainColor;
}

void light() {
	float nDotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	nDotL = smoothstep(0.01, 0.03, nDotL);
	
	vec3 addedCam = normalize(VIEW + LIGHT);
	float vDotL = clamp(dot(NORMAL, addedCam), 0.0, 1.0);
	vDotL = pow(vDotL, 40);
	vDotL = smoothstep(0.06, 0.1, vDotL);
	
	float rimLight = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	rimLight = pow(1.0 - rimLight, 12) * nDotL;
	rimLight = smoothstep(0.01, 0.02, rimLight);
	
	vec3 result = vec3(nDotL) + rimLight;
	DIFFUSE_LIGHT += result;
	SPECULAR_LIGHT += vDotL;
}

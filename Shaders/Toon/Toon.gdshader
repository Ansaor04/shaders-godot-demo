shader_type spatial;
uniform vec3 mainColor : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = mainColor;
}

float CalculateRimLight(vec3 normal, vec3 view, float nDotL)
{
	float rimLight = clamp(dot(normal, view), 0.0, 1.0);
	rimLight = pow(1.0 - rimLight, 12) * nDotL;
	rimLight = smoothstep(0.01, 0.02, rimLight);
	return rimLight;
}

float CalculateSpecular(vec3 view, vec3 light, vec3 normal)
{
	vec3 addedCam = normalize(view + light);
	float vDotL = clamp(dot(normal, addedCam), 0.0, 1.0);
	vDotL = pow(vDotL, 40);
	vDotL = smoothstep(0.06, 0.1, vDotL);
	return vDotL;
}

void light() {
	float nDotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	nDotL = smoothstep(0.01, 0.03, nDotL);
	
	float rimLight = CalculateRimLight(NORMAL, VIEW, nDotL);
	float specular = CalculateSpecular(VIEW, LIGHT, NORMAL);
	
	vec3 result = vec3(nDotL) + rimLight;
	DIFFUSE_LIGHT += result;
	SPECULAR_LIGHT += specular;
}

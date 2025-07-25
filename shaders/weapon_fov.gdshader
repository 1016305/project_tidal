shader_type spatial;

uniform float viewmodel_fov = 75.0f;



void vertex() {

    float onetanfov = 1.0f / tan(0.5f * (viewmodel_fov * PI / 180.0f));

    float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;

    // modify projection matrix

    PROJECTION_MATRIX[1][1] = -onetanfov;

    PROJECTION_MATRIX[0][0] = onetanfov / aspect;



    // draws the viewmodel over everything (disable if you want dof near on viewmodel)

    POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.xyz, 1.0);

    POSITION.z = mix(POSITION.z, 0, 0.999);

}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

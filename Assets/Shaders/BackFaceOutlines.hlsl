#ifndef BACKFACEOUTLINES_INCLUDED
#define BACKFACEOUTLINES_INCLUDED

// Data from the meshes
struct OutlineInput
{
	float4 positionOS       : POSITION; // Position in object space
	float3 normalOS         : NORMAL; // Normal vector in object space
#ifdef USE_PRECALCULATED_OUTLINE_NORMALS_ON
	float3 smoothNormalOS   : TEXCOORD1; // Calculated "smooth" normals to extrude along in object space
#endif
};

// Output from the vertex function and input to the fragment function
struct OutlineOutput
{
	float4 positionCS   : SV_POSITION; // Position in clip space
};

float3 Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation)
{
	Rotation = radians(Rotation);

	float s = sin(Rotation);
	float c = cos(Rotation);
	float one_minus_c = 1.0 - c;
	
	Axis = normalize(Axis);

	float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
							one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
							one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
							};

	return mul(rot_mat,  In);
}

OutlineOutput Vertex(OutlineInput input)
{
	OutlineOutput output = (OutlineOutput)0;

	float3 normalOS;
	#ifdef USE_PRECALCULATED_OUTLINE_NORMALS_ON
		normalOS = input.smoothNormalOS;
	#else
		normalOS = input.normalOS;
	#endif

	float3 posWS = TransformObjectToWorld(input.positionOS.xyz);
	float3 normalWS = TransformObjectToWorldNormal(normalOS);

	// Extrude the world space position along a normal vector
	posWS = posWS + normalWS * _OutlineThickness;
	// Convert this position to world and clip space
	#if defined(MAKE_FLAT_ON)
		posWS = Rotate_About_Axis_Degrees_float(posWS, _FlatRotationAxis, _FlatRotationDegrees);
		float3 flatVector = float3(0, posWS.y - _FlatHeight, 0);
		posWS -= flatVector;
	#endif
	output.positionCS = TransformWorldToHClip(posWS);
	
	return output;
}

float4 Fragment(OutlineOutput input) : SV_Target
{
	return _OutlineColor;
}

#endif
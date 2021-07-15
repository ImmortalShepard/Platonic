#ifndef BACKFACEOUTLINES_INCLUDED
#define BACKFACEOUTLINES_INCLUDED

// Data from the meshes
struct OutlineInput
{
	float4 positionOS       : POSITION; // Position in object space
	float3 normalOS         : NORMAL; // Normal vector in object space
#ifdef USE_PRECALCULATED_OUTLINE_NORMALS
	float3 smoothNormalOS   : TEXCOORD1; // Calculated "smooth" normals to extrude along in object space
#endif
};

// Output from the vertex function and input to the fragment function
struct OutlineOutput
{
	float4 positionCS   : SV_POSITION; // Position in clip space
};

OutlineOutput Vertex(OutlineInput input)
{
	OutlineOutput output = (OutlineOutput)0;

	float3 normalOS;
#ifdef USE_PRECALCULATED_OUTLINE_NORMALS
	normalOS = input.smoothNormalOS;
#else
	normalOS = input.normalOS;
#endif

#ifdef USE_SCREEN_SPACE_THICKNESS
	float4 clipPosition = TransformObjectToHClip(input.positionOS.xyz);
	float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, normalOS));

	float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * _Thickness * clipPosition.w * 200;
	clipPosition.xy += offset;
	output.positionCS = clipPosition;
#else
	float3 posWS = TransformObjectToWorld(input.positionOS.xyz);
	float3 normalWS = TransformObjectToWorldNormal(normalOS);

	// Extrude the world space position along a normal vector
	posWS = posWS + normalWS * _Thickness;
	// Convert this position to world and clip space
	output.positionCS = TransformWorldToHClip(posWS);
#endif
	
	return output;
}

float4 Fragment(OutlineOutput input) : SV_Target
{
	return _Color;
}

#endif
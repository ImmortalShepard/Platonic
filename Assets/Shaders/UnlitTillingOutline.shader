Shader "Custom/UnlitTillingOutline"
{

    Properties
    {
        _Thickness("Thickness", Range(-1.0, 1.0)) = 0.02
		[HDR]_Color("Outline Color", Color) = (0,0,0,1)
		_ID("Stencil ID", int) = 1

		// If enabled, this shader will use "smoothed" normals stored in TEXCOORD1 to extrude along
		[Toggle(USE_PRECALCULATED_OUTLINE_NORMALS)]_PrecalculateNormals("Use UV1 normals", Float) = 0

        [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        [MainColor][HDR] _BaseColor("Color", Color) = (1, 1, 1, 1)
        _BlendRatio("Blend Ratio", Float) = 0

        _ViewDirection("View Direction", Vector) = (0,-1,0,0)
        [Toggle]_UseViewDirection("Use View Direction", Float) = 0
    }

    SubShader
    {
        Tags {"RenderType" = "Opaque" "UniversalMaterialType" = "Unlit" "RenderPipeline" = "UniversalPipeline" "ShaderModel"="4.5"}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        #pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x

        #pragma multi_compile_instancing

        CBUFFER_START(UnityPerMaterial)
        float _Thickness;
        float4 _Color;
        int _ID;
        float _PrecalculateNormals;
        float4 _BaseMap_ST;
        float4 _BaseColor;
        float _BlendRatio;
        float3 _ViewDirection;
        float _UseViewDirection;
        CBUFFER_END

        //SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);

        ENDHLSL

        Pass
        {
            Name "Unlit"

            Stencil
			{
				Ref [_ID]
				Comp always
				Pass replace
				ZFail keep
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _USEVIEWDIRECTION_ON

            struct VertexInput
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float PositiveSign(float number)
            {
                if (number >= 0)
                {
                    return 1;
                }
                return -1;
            }

            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.position = TransformObjectToHClip(i.position.xyz);
                
                float3 worldPosition = GetAbsolutePositionWS(TransformObjectToWorld(i.position.xyz));
                float3 viewDirection;
                #if defined(_USEVIEWDIRECTION_ON)
                    viewDirection = _ViewDirection;
                #else
                    viewDirection = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
                #endif

                float3 projected = worldPosition - viewDirection * dot(worldPosition, viewDirection);

                float uvX = projected.x;
                float uvY = length(float2(projected.y, projected.z)) * PositiveSign(projected.z);

                o.uv = TRANSFORM_TEX(float2(uvX, uvY),_BaseMap);

                return o;
            }

            float4 frag(VertexOutput i) : SV_TARGET
            {
                float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                return saturate(baseTex + float4(_BlendRatio, _BlendRatio, _BlendRatio, 0)) * _BaseColor;
            }

            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags {"LightMode" = "Outline"}

            Cull Off
            Stencil
			{
				Ref [_ID]
				Comp notequal
				Fail keep
				Pass replace
			}

            HLSLPROGRAM

			// Register our material keywords
			#pragma shader_feature USE_PRECALCULATED_OUTLINE_NORMALS

            // Register our functions
			#pragma vertex Vertex
			#pragma fragment Fragment

			// Include our logic file
			#include "BackFaceOutlines.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }
}

Shader "Custom/UnlitOutline"
{

    Properties
    {
        _Thickness("Thickness", Range(-1.0, 1.0)) = 0.02
		[HDR]_Color("Outline Color", Color) = (0, 0, 0, 1)
		_ID("Stencil ID", int) = 1

		// If enabled, this shader will use "smoothed" normals stored in TEXCOORD1 to extrude along
		[Toggle(USE_PRECALCULATED_OUTLINE_NORMALS)]_PrecalculateNormals("Use UV1 normals", Float) = 0

        [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        [MainColor]   _BaseColor("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags {"RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel"="4.5"}

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
        float4 _BaseColor;
        CBUFFER_END

        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);

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

            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.position = TransformObjectToHClip(i.position.xyz);
                o.uv = i.uv;
                return o;
            }

            float4 frag(VertexOutput i) : SV_TARGET
            {
                float4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                return baseTex * _BaseColor;
            }

            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags {"LightMode" = "Outline"}

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
    }
}

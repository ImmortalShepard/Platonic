Shader "Custom/UnlitOutline"
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

        [Toggle(_ALPHATEST_ON)] _EnableAlphaTest("Enable Alpha Cutoff", Float) = 0.0
		_Cutoff ("Alpha Cutoff", Float) = 0.5
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
        float4 _BaseColor;
        float _Cutoff;
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

        // UsePass "Universal Render Pipeline/Lit/ShadowCaster"
		// Note, you can do this, but it will break batching with the SRP Batcher currently due to the CBUFFERs not being the same.
		// So instead, we'll define the pass manually :
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			// Required to compile gles 2.0 with standard srp library
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x gles
			//#pragma target 4.5

			// Material Keywords
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
            
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

			// Note if we want to do any vertex displacment, we'll need to change the vertex function :
			/*
			//  e.g. 
			#pragma vertex vert

			Varyings vert(Attributes input) {
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);

				// Example Displacement
				input.positionOS += float4(0, _SinTime.y, 0, 0);

				output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
				output.positionCS = GetShadowPositionHClip(input);
				return output;
			}*/

			// Using the ShadowCasterPass means we also need _BaseMap, _BaseColor and _Cutoff shader properties.
			// Also including them in cbuffer, with the exception of _BaseMap as it's a texture.

			ENDHLSL
		}
    }
}

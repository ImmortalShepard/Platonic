// Example Shader for Universal RP
// Written by @Cyanilux
// https://cyangamedev.wordpress.com/urp-shader-code/
Shader "Custom/UnlitShaderExample"
{
	Properties
    {
		_BaseMap ("Example Texture", 2D) = "white" {}
		_BaseColor ("Example Colour", Color) = (0, 0.66, 0.73, 1)

        [Toggle(_ALPHATEST_ON)] _EnableAlphaTest("Enable Alpha Cutoff", Float) = 0.0
		_Cutoff ("Alpha Cutoff", Float) = 0.5
	}
	SubShader
    {
		Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
		
		HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			float4 _BaseColor;
            float _Cutoff;
			CBUFFER_END
		ENDHLSL
		
		Pass
        {
			Name "Example"
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			struct Attributes
            {
				float4 positionOS	: POSITION;
				float2 uv		: TEXCOORD0;
				float4 color		: COLOR;
			};
			
			struct Varyings
            {
				float4 positionCS 	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float4 color		: COLOR;
			};
			
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);
			
			Varyings vert(Attributes IN)
            {
				Varyings OUT;
				
				VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
				OUT.positionCS = positionInputs.positionCS;
				// Or this :
				//OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
				OUT.color = IN.color;
				return OUT;
			}
			
			half4 frag(Varyings IN) : SV_Target {
				half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
				
				return baseMap * _BaseColor * IN.color;
			}
			ENDHLSL
		}

        // UsePass "Universal Render Pipeline/Lit/ShadowCaster"
		// Note, you can do this, but it will break batching with the SRP Batcher currently due to the CBUFFERs not being the same.
		// So instead, we'll define the pass manually :
		Pass
        {
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

        // Similarly, we should have a DepthOnly pass.
		// UsePass "Universal Render Pipeline/Lit/DepthOnly"
		// Again, since the cbuffer is different it'll break batching with the SRP Batcher.

		// The DepthOnly pass is very similar to the ShadowCaster but doesn't include the shadow bias offsets.
		// I believe Unity uses this pass when rendering the depth of objects in the Scene View.
		// But for the Game View / actual camera Depth Texture it renders fine without it.
		// It's possible that it could be used in Forward Renderer features though, so we should probably still include it.
		Pass
        {
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

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
            
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			
			//#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			// Note, the Lit shader that URP provides uses this, but it also handles the cbuffer which we already have.
			// We could change the shader to use their cbuffer, but we can also just do this :
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

			// Again, using the DepthOnlyPass means we also need _BaseMap, _BaseColor and _Cutoff shader properties.
			// Also including them in cbuffer, with the exception of _BaseMap as it's a texture.

			ENDHLSL
		}
	}
}


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

        [KeywordEnum(X, Y, Z)] _Axis1("Axis1", Float) = 0
        [KeywordEnum(X, Y, Z)] _Axis2("Axis2", Float) = 1
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
        float4 _BaseMap_ST;
        float4 _BaseColor;
        float _BlendRatio;
        float _Axis1;
        float _Axis2;
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

            #pragma shader_feature_local _AXIS1_X _AXIS1_Y _AXIS1_Z
            #pragma shader_feature_local _AXIS2_X _AXIS2_Y _AXIS2_Z

            #if defined(_AXIS1_X) && defined(_AXIS2_X)
                #define AXIS_XX
            #elif defined(_AXIS1_X) && defined(_AXIS2_Y)
                #define AXIS_XY
            #elif defined(_AXIS1_X) && defined(_AXIS2_Z)
                #define AXIS_XZ
            #elif defined(_AXIS1_Y) && defined(_AXIS2_X)
                #define AXIS_YX
            #elif defined(_AXIS1_Y) && defined(_AXIS2_Y)
                #define AXIS_YY
            #elif defined(_AXIS1_Y) && defined(_AXIS2_Z)
                #define AXIS_YZ
            #elif defined(_AXIS1_Z) && defined(_AXIS2_X)
                #define AXIS_ZX
            #elif defined(_AXIS1_Z) && defined(_AXIS2_Y)
                #define AXIS_ZY
            #elif defined(_AXIS1_Z) && defined(_AXIS2_Z)
                #define AXIS_ZZ
            #endif

            struct VertexInput
            {
                float4 position : POSITION;
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;   
                float2 uv : TEXCOORD0;
            };

            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.position = TransformObjectToHClip(i.position.xyz);
                float3 absoluteWorldPosition = GetAbsolutePositionWS(TransformObjectToWorld(i.position.xyz));
                #if defined(AXIS_XX)
                    o.uv = absoluteWorldPosition.xx;
                #elif defined(AXIS_XY)
                    o.uv = absoluteWorldPosition.xy;
                #elif defined(AXIS_XZ)
                    o.uv = absoluteWorldPosition.xz;
                #elif defined(AXIS_YX)
                    o.uv = absoluteWorldPosition.yx;
                #elif defined(AXIS_YY)
                    o.uv = absoluteWorldPosition.yy;
                #elif defined(AXIS_YZ)
                    o.uv = absoluteWorldPosition.yz;
                #elif defined(AXIS_ZX)
                    o.uv = absoluteWorldPosition.zx;
                #elif defined(AXIS_ZY)
                    o.uv = absoluteWorldPosition.zy;
                #elif defined(AXIS_ZZ)
                    o.uv = absoluteWorldPosition.zz;
                #else
                    o.uv = float2(0,0);
                #endif
                o.uv = TRANSFORM_TEX(o.uv, _BaseMap);
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
    }
}

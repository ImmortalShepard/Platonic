Shader "Custom/LitGridTillingFlatOutline"
{
    Properties
    {
        [NoScaleOffset]_Texture("Texture", 2D) = "white" {}
        _Tilling("Tilling", Vector) = (1, 1, 0, 0)
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        [HDR]_Color("Color", Color) = (1, 1, 1, 1)
        _BlendRatio("Blend Ratio", Range(0, 1)) = 0
        _ViewDirection("View Direction", Vector) = (0, -1, 0, 0)
        _FlatHeight("Flat Height", Float) = 0.001
        _FlatRotationAxis("Flat Rotation Axis", Vector) = (1, 0, 0, 0)
        _FlatRotationDegrees("Flat Rotation Degrees", Float) = 45
        _GridSize("Grid Size", Float) = 0.5
        _GridLineSize("Grid Line Size", Float) = 0.02
        _GridOffset("Grid Offset", Vector) = (0, 0, 0, 0)
        [HDR]_GridColor("Grid Color", Color) = (0, 0, 0, 1)
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle]USE_VIEW_DIRECTION("Use View Direction", Float) = 0
        [Toggle]MAKE_FLAT("Make Flat", Float) = 0

        _OutlineThickness("Outline Thickness", Float) = 0.1
        [HDR]_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _ID("ID", Int) = 0
        [Toggle]USE_PRECALCULATED_OUTLINE_NORMALS("Use Precalculated Ouline Normals", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "Outline"
            }

            // Render State
            Cull Off
            Blend One Zero
            ZTest LEqual
            ZWrite On

            Stencil
            {
                Ref [_ID]
                Comp notequal
                Fail keep
                Pass replace
            }

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma shader_feature_local _ MAKE_FLAT_ON
        #pragma shader_feature_local _ USE_PRECALCULATED_OUTLINE_NORMALS_ON

        #if defined(MAKE_FLAT_ON) && defined(USE_PRECALCULATED_OUTLINE_NORMALS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(USE_PRECALCULATED_OUTLINE_NORMALS_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 viewDirectionWS;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 lightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 sh;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 fogFactorAndVertexLight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp3 : TEXCOORD3;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 interp4 : TEXCOORD4;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp5 : TEXCOORD5;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp6 : TEXCOORD6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp7 : TEXCOORD7;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _UV_fe644f5ff0384eb198680f20e81984cc_Out_0 = IN.uv1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_b09264dba3234c0db97684105afcb99a_Out_1 = TransformObjectToWorldDir((_UV_fe644f5ff0384eb198680f20e81984cc_Out_0.xyz).xyz);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_PRECALCULATED_OUTLINE_NORMALS_ON)
            float3 _UsePrecalculatedOulineNormals_46ec9cf6d1854f49b5d8eccb31b5c46d_Out_0 = _Transform_b09264dba3234c0db97684105afcb99a_Out_1;
            #else
            float3 _UsePrecalculatedOulineNormals_46ec9cf6d1854f49b5d8eccb31b5c46d_Out_0 = IN.WorldSpaceNormal;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_c7962152ccb24559a7c4e21b22f45a82_Out_0 = _OutlineThickness;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_bfa1a01f2278483cac2dd442d843c54c_Out_2;
            Unity_Multiply_float(_UsePrecalculatedOulineNormals_46ec9cf6d1854f49b5d8eccb31b5c46d_Out_0, (_Property_c7962152ccb24559a7c4e21b22f45a82_Out_0.xxx), _Multiply_bfa1a01f2278483cac2dd442d843c54c_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Add_2fd3c58c0946456590caea523a7ffba6_Out_2;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Multiply_bfa1a01f2278483cac2dd442d843c54c_Out_2, _Add_2fd3c58c0946456590caea523a7ffba6_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(_Add_2fd3c58c0946456590caea523a7ffba6_Out_2, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e843406b6f2047cfaae51663b1fb6e70_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2fd3c58c0946456590caea523a7ffba6_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e843406b6f2047cfaae51663b1fb6e70_Out_1;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalWS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_f18f45da83044870bf2beff2f0be111f_Out_0 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_00b6f137b569440981229d628d3a1b37_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = _Vector3_00b6f137b569440981229d628d3a1b37_Out_0;
            #else
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = IN.WorldSpaceNormal;
            #endif
            #endif
            surface.BaseColor = (_Property_f18f45da83044870bf2beff2f0be111f_Out_0.xyz);
            surface.NormalWS = _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.uv1 =                         input.uv1;
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif



        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            Stencil
            {
                Ref [_ID]
                Comp always
                Pass replace
                ZFail keep
            }

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 viewDirectionWS;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 lightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 sh;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 fogFactorAndVertexLight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp3 : TEXCOORD3;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 interp4 : TEXCOORD4;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp5 : TEXCOORD5;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp6 : TEXCOORD6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp7 : TEXCOORD7;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }

        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }

        struct Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025
        {
        };

        void SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(float Vector1_85c55723d9834bc8ae46c6a98fe13b10, float Vector1_62b294273be6446697298fa8ac134c00, float Vector1_3c59b7ed572644c5998c3e38963e8ee6, Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 IN, out float Out_Vector4_1)
        {
            float _Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0 = Vector1_85c55723d9834bc8ae46c6a98fe13b10;
            float _Property_956f6a66821048539f91c21a077f5ac8_Out_0 = Vector1_62b294273be6446697298fa8ac134c00;
            float _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2;
            Unity_Divide_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2);
            float _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1;
            Unity_Floor_float(_Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2, _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1);
            float _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2;
            Unity_Multiply_float(_Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2);
            float _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2;
            Unity_Subtract_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2, _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2);
            float _Property_d2a58bd098b14661a348886bbe47acf1_Out_0 = Vector1_3c59b7ed572644c5998c3e38963e8ee6;
            float _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
            Unity_Comparison_LessOrEqual_float(_Subtract_19dd944d00524959aa68be8269b61ed4_Out_2, _Property_d2a58bd098b14661a348886bbe47acf1_Out_0, _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2);
            Out_Vector4_1 = _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        struct Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348
        {
        };

        void SG_GridUVCheck_294d007a503d6d2499de026b4f678348(float2 Vector2_5a56dbf35cba4d4c8a3192a95b776eb9, float Vector1_0a171b7c60dc451dab7b2e69064f24eb, float2 Vector2_d630f5a030b148be8aa8b746e507f89a, float Vector1_7845b62507cb41e1bdeb7da05ba77e88, Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 IN, out float Out_Vector4_1)
        {
            float2 _Property_fb6173b513a2442dae002a71d714fb8a_Out_0 = Vector2_5a56dbf35cba4d4c8a3192a95b776eb9;
            float2 _Property_8e21231b95494bfd917e2a63f0311bab_Out_0 = Vector2_d630f5a030b148be8aa8b746e507f89a;
            float2 _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2;
            Unity_Subtract_float2(_Property_fb6173b513a2442dae002a71d714fb8a_Out_0, _Property_8e21231b95494bfd917e2a63f0311bab_Out_0, _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2);
            float _Split_68957bd604ac408cb4f40d11f10462e0_R_1 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[0];
            float _Split_68957bd604ac408cb4f40d11f10462e0_G_2 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[1];
            float _Split_68957bd604ac408cb4f40d11f10462e0_B_3 = 0;
            float _Split_68957bd604ac408cb4f40d11f10462e0_A_4 = 0;
            float _Property_f9707b40612141e28e92f98117aabb47_Out_0 = Vector1_0a171b7c60dc451dab7b2e69064f24eb;
            float _Property_82c6c275ad2e4dec864b44c81809a340_Out_0 = Vector1_7845b62507cb41e1bdeb7da05ba77e88;
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_b8e7d6fe4086451eb52139a6851ccac4;
            float _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_R_1, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1);
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_ad0e839ef18848968002cfbf3e540a4c;
            float _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_G_2, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_ad0e839ef18848968002cfbf3e540a4c, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1);
            float _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
            Unity_Or_float(_GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1, _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2);
            Out_Vector4_1 = _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Blend_Multiply_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = Base * Blend;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float4(float4 In, out float4 Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalWS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_e4769ac03187485fb020eb7088c295ed_Out_0 = _ViewDirection;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_VIEW_DIRECTION_ON)
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = _Property_e4769ac03187485fb020eb7088c295ed_Out_0;
            #else
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = -1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2;
            Unity_DotProduct_float3(IN.AbsoluteWorldSpacePosition, _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2;
            Unity_Multiply_float(_UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, (_DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2.xxx), _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2, _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ede1224a4ca84032bf4b1df871e93e70_R_1 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[0];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_G_2 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[1];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_B_3 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[2];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4;
            float3 _Combine_c544d0baf46547c886465113721b8dc2_RGB_5;
            float2 _Combine_c544d0baf46547c886465113721b8dc2_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_G_2, _Split_ede1224a4ca84032bf4b1df871e93e70_B_3, 0, 0, _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4, _Combine_c544d0baf46547c886465113721b8dc2_RGB_5, _Combine_c544d0baf46547c886465113721b8dc2_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Length_48a21bd606b84dd8809be4bbd711831d_Out_1;
            Unity_Length_float2(_Combine_c544d0baf46547c886465113721b8dc2_RG_6, _Length_48a21bd606b84dd8809be4bbd711831d_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1;
            Unity_Sign_float(_Split_ede1224a4ca84032bf4b1df871e93e70_B_3, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2;
            Unity_Multiply_float(_Length_48a21bd606b84dd8809be4bbd711831d_Out_1, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_25e50631448749efbb0da292180556ac_RGBA_4;
            float3 _Combine_25e50631448749efbb0da292180556ac_RGB_5;
            float2 _Combine_25e50631448749efbb0da292180556ac_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_R_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2, 0, 0, _Combine_25e50631448749efbb0da292180556ac_RGBA_4, _Combine_25e50631448749efbb0da292180556ac_RGB_5, _Combine_25e50631448749efbb0da292180556ac_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0 = _GridSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_d8a6657237b7495786fadc1e73d14d81_Out_0 = _GridOffset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_30cda5be8c7d404e9658c018ae46e704_Out_0 = _GridLineSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 _GridUVCheck_8e141dc40edd45cf86f9583be61f0601;
            float _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1;
            SG_GridUVCheck_294d007a503d6d2499de026b4f678348(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0, _Property_d8a6657237b7495786fadc1e73d14d81_Out_0, _Property_30cda5be8c7d404e9658c018ae46e704_Out_0, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0 = UnityBuildTexture2DStructNoScale(_Texture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0 = _Tilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0 = _Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3;
            Unity_TilingAndOffset_float(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0, _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0 = SAMPLE_TEXTURE2D(_Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.tex, _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.samplerstate, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_R_4 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.r;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_G_5 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.g;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_B_6 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.b;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_A_7 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0 = IsGammaSpace() ? LinearToSRGB(_GridColor) : _GridColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_3fb6c7796dd34604bc473fd730674b8f_R_1 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[0];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_G_2 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[1];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_B_3 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[2];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_A_4 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2;
            Unity_Blend_Multiply_float4(_SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _Split_3fb6c7796dd34604bc473fd730674b8f_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3;
            Unity_Branch_float4(_GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0 = _BlendRatio;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4;
            float3 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5;
            float2 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6;
            Unity_Combine_float(_Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, 0, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Add_a65535dcb45144b5b19ae02c22841015_Out_2;
            Unity_Add_float4(_Branch_cf6de22576ad412293d963d30af6cdc8_Out_3, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Add_a65535dcb45144b5b19ae02c22841015_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1;
            Unity_Saturate_float4(_Add_a65535dcb45144b5b19ae02c22841015_Out_2, _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2;
            Unity_Blend_Multiply_float4(_Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1, _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0, _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_00b6f137b569440981229d628d3a1b37_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = _Vector3_00b6f137b569440981229d628d3a1b37_Out_0;
            #else
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = IN.WorldSpaceNormal;
            #endif
            #endif
            surface.BaseColor = (_Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2.xyz);
            surface.NormalWS = _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 viewDirectionWS;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 lightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 sh;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 fogFactorAndVertexLight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp3 : TEXCOORD3;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 interp4 : TEXCOORD4;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp5 : TEXCOORD5;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp6 : TEXCOORD6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp7 : TEXCOORD7;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }

        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }

        struct Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025
        {
        };

        void SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(float Vector1_85c55723d9834bc8ae46c6a98fe13b10, float Vector1_62b294273be6446697298fa8ac134c00, float Vector1_3c59b7ed572644c5998c3e38963e8ee6, Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 IN, out float Out_Vector4_1)
        {
            float _Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0 = Vector1_85c55723d9834bc8ae46c6a98fe13b10;
            float _Property_956f6a66821048539f91c21a077f5ac8_Out_0 = Vector1_62b294273be6446697298fa8ac134c00;
            float _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2;
            Unity_Divide_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2);
            float _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1;
            Unity_Floor_float(_Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2, _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1);
            float _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2;
            Unity_Multiply_float(_Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2);
            float _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2;
            Unity_Subtract_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2, _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2);
            float _Property_d2a58bd098b14661a348886bbe47acf1_Out_0 = Vector1_3c59b7ed572644c5998c3e38963e8ee6;
            float _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
            Unity_Comparison_LessOrEqual_float(_Subtract_19dd944d00524959aa68be8269b61ed4_Out_2, _Property_d2a58bd098b14661a348886bbe47acf1_Out_0, _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2);
            Out_Vector4_1 = _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        struct Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348
        {
        };

        void SG_GridUVCheck_294d007a503d6d2499de026b4f678348(float2 Vector2_5a56dbf35cba4d4c8a3192a95b776eb9, float Vector1_0a171b7c60dc451dab7b2e69064f24eb, float2 Vector2_d630f5a030b148be8aa8b746e507f89a, float Vector1_7845b62507cb41e1bdeb7da05ba77e88, Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 IN, out float Out_Vector4_1)
        {
            float2 _Property_fb6173b513a2442dae002a71d714fb8a_Out_0 = Vector2_5a56dbf35cba4d4c8a3192a95b776eb9;
            float2 _Property_8e21231b95494bfd917e2a63f0311bab_Out_0 = Vector2_d630f5a030b148be8aa8b746e507f89a;
            float2 _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2;
            Unity_Subtract_float2(_Property_fb6173b513a2442dae002a71d714fb8a_Out_0, _Property_8e21231b95494bfd917e2a63f0311bab_Out_0, _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2);
            float _Split_68957bd604ac408cb4f40d11f10462e0_R_1 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[0];
            float _Split_68957bd604ac408cb4f40d11f10462e0_G_2 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[1];
            float _Split_68957bd604ac408cb4f40d11f10462e0_B_3 = 0;
            float _Split_68957bd604ac408cb4f40d11f10462e0_A_4 = 0;
            float _Property_f9707b40612141e28e92f98117aabb47_Out_0 = Vector1_0a171b7c60dc451dab7b2e69064f24eb;
            float _Property_82c6c275ad2e4dec864b44c81809a340_Out_0 = Vector1_7845b62507cb41e1bdeb7da05ba77e88;
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_b8e7d6fe4086451eb52139a6851ccac4;
            float _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_R_1, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1);
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_ad0e839ef18848968002cfbf3e540a4c;
            float _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_G_2, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_ad0e839ef18848968002cfbf3e540a4c, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1);
            float _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
            Unity_Or_float(_GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1, _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2);
            Out_Vector4_1 = _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Blend_Multiply_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = Base * Blend;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float4(float4 In, out float4 Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalWS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_e4769ac03187485fb020eb7088c295ed_Out_0 = _ViewDirection;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_VIEW_DIRECTION_ON)
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = _Property_e4769ac03187485fb020eb7088c295ed_Out_0;
            #else
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = -1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2;
            Unity_DotProduct_float3(IN.AbsoluteWorldSpacePosition, _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2;
            Unity_Multiply_float(_UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, (_DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2.xxx), _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2, _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ede1224a4ca84032bf4b1df871e93e70_R_1 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[0];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_G_2 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[1];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_B_3 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[2];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4;
            float3 _Combine_c544d0baf46547c886465113721b8dc2_RGB_5;
            float2 _Combine_c544d0baf46547c886465113721b8dc2_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_G_2, _Split_ede1224a4ca84032bf4b1df871e93e70_B_3, 0, 0, _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4, _Combine_c544d0baf46547c886465113721b8dc2_RGB_5, _Combine_c544d0baf46547c886465113721b8dc2_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Length_48a21bd606b84dd8809be4bbd711831d_Out_1;
            Unity_Length_float2(_Combine_c544d0baf46547c886465113721b8dc2_RG_6, _Length_48a21bd606b84dd8809be4bbd711831d_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1;
            Unity_Sign_float(_Split_ede1224a4ca84032bf4b1df871e93e70_B_3, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2;
            Unity_Multiply_float(_Length_48a21bd606b84dd8809be4bbd711831d_Out_1, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_25e50631448749efbb0da292180556ac_RGBA_4;
            float3 _Combine_25e50631448749efbb0da292180556ac_RGB_5;
            float2 _Combine_25e50631448749efbb0da292180556ac_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_R_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2, 0, 0, _Combine_25e50631448749efbb0da292180556ac_RGBA_4, _Combine_25e50631448749efbb0da292180556ac_RGB_5, _Combine_25e50631448749efbb0da292180556ac_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0 = _GridSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_d8a6657237b7495786fadc1e73d14d81_Out_0 = _GridOffset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_30cda5be8c7d404e9658c018ae46e704_Out_0 = _GridLineSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 _GridUVCheck_8e141dc40edd45cf86f9583be61f0601;
            float _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1;
            SG_GridUVCheck_294d007a503d6d2499de026b4f678348(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0, _Property_d8a6657237b7495786fadc1e73d14d81_Out_0, _Property_30cda5be8c7d404e9658c018ae46e704_Out_0, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0 = UnityBuildTexture2DStructNoScale(_Texture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0 = _Tilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0 = _Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3;
            Unity_TilingAndOffset_float(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0, _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0 = SAMPLE_TEXTURE2D(_Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.tex, _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.samplerstate, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_R_4 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.r;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_G_5 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.g;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_B_6 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.b;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_A_7 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0 = IsGammaSpace() ? LinearToSRGB(_GridColor) : _GridColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_3fb6c7796dd34604bc473fd730674b8f_R_1 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[0];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_G_2 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[1];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_B_3 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[2];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_A_4 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2;
            Unity_Blend_Multiply_float4(_SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _Split_3fb6c7796dd34604bc473fd730674b8f_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3;
            Unity_Branch_float4(_GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0 = _BlendRatio;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4;
            float3 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5;
            float2 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6;
            Unity_Combine_float(_Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, 0, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Add_a65535dcb45144b5b19ae02c22841015_Out_2;
            Unity_Add_float4(_Branch_cf6de22576ad412293d963d30af6cdc8_Out_3, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Add_a65535dcb45144b5b19ae02c22841015_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1;
            Unity_Saturate_float4(_Add_a65535dcb45144b5b19ae02c22841015_Out_2, _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2;
            Unity_Blend_Multiply_float4(_Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1, _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0, _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2, 1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_00b6f137b569440981229d628d3a1b37_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = _Vector3_00b6f137b569440981229d628d3a1b37_Out_0;
            #else
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = IN.WorldSpaceNormal;
            #endif
            #endif
            surface.BaseColor = (_Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2.xyz);
            surface.NormalWS = _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_NORMAL_WS
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_TANGENT_WS
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentWS;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 interp1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalWS;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_00b6f137b569440981229d628d3a1b37_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = _Vector3_00b6f137b569440981229d628d3a1b37_Out_0;
            #else
            float3 _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0 = IN.WorldSpaceNormal;
            #endif
            #endif
            surface.NormalWS = _MakeFlat_15a66a5e097346b0ab04ed10790f004e_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        float3 unnormalizedNormalWS = input.normalWS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        #endif



        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        #endif



        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 uv2 : TEXCOORD2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }

        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }

        struct Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025
        {
        };

        void SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(float Vector1_85c55723d9834bc8ae46c6a98fe13b10, float Vector1_62b294273be6446697298fa8ac134c00, float Vector1_3c59b7ed572644c5998c3e38963e8ee6, Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 IN, out float Out_Vector4_1)
        {
            float _Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0 = Vector1_85c55723d9834bc8ae46c6a98fe13b10;
            float _Property_956f6a66821048539f91c21a077f5ac8_Out_0 = Vector1_62b294273be6446697298fa8ac134c00;
            float _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2;
            Unity_Divide_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2);
            float _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1;
            Unity_Floor_float(_Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2, _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1);
            float _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2;
            Unity_Multiply_float(_Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2);
            float _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2;
            Unity_Subtract_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2, _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2);
            float _Property_d2a58bd098b14661a348886bbe47acf1_Out_0 = Vector1_3c59b7ed572644c5998c3e38963e8ee6;
            float _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
            Unity_Comparison_LessOrEqual_float(_Subtract_19dd944d00524959aa68be8269b61ed4_Out_2, _Property_d2a58bd098b14661a348886bbe47acf1_Out_0, _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2);
            Out_Vector4_1 = _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        struct Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348
        {
        };

        void SG_GridUVCheck_294d007a503d6d2499de026b4f678348(float2 Vector2_5a56dbf35cba4d4c8a3192a95b776eb9, float Vector1_0a171b7c60dc451dab7b2e69064f24eb, float2 Vector2_d630f5a030b148be8aa8b746e507f89a, float Vector1_7845b62507cb41e1bdeb7da05ba77e88, Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 IN, out float Out_Vector4_1)
        {
            float2 _Property_fb6173b513a2442dae002a71d714fb8a_Out_0 = Vector2_5a56dbf35cba4d4c8a3192a95b776eb9;
            float2 _Property_8e21231b95494bfd917e2a63f0311bab_Out_0 = Vector2_d630f5a030b148be8aa8b746e507f89a;
            float2 _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2;
            Unity_Subtract_float2(_Property_fb6173b513a2442dae002a71d714fb8a_Out_0, _Property_8e21231b95494bfd917e2a63f0311bab_Out_0, _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2);
            float _Split_68957bd604ac408cb4f40d11f10462e0_R_1 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[0];
            float _Split_68957bd604ac408cb4f40d11f10462e0_G_2 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[1];
            float _Split_68957bd604ac408cb4f40d11f10462e0_B_3 = 0;
            float _Split_68957bd604ac408cb4f40d11f10462e0_A_4 = 0;
            float _Property_f9707b40612141e28e92f98117aabb47_Out_0 = Vector1_0a171b7c60dc451dab7b2e69064f24eb;
            float _Property_82c6c275ad2e4dec864b44c81809a340_Out_0 = Vector1_7845b62507cb41e1bdeb7da05ba77e88;
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_b8e7d6fe4086451eb52139a6851ccac4;
            float _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_R_1, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1);
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_ad0e839ef18848968002cfbf3e540a4c;
            float _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_G_2, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_ad0e839ef18848968002cfbf3e540a4c, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1);
            float _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
            Unity_Or_float(_GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1, _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2);
            Out_Vector4_1 = _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Blend_Multiply_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = Base * Blend;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float4(float4 In, out float4 Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_e4769ac03187485fb020eb7088c295ed_Out_0 = _ViewDirection;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_VIEW_DIRECTION_ON)
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = _Property_e4769ac03187485fb020eb7088c295ed_Out_0;
            #else
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = -1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2;
            Unity_DotProduct_float3(IN.AbsoluteWorldSpacePosition, _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2;
            Unity_Multiply_float(_UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, (_DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2.xxx), _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2, _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ede1224a4ca84032bf4b1df871e93e70_R_1 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[0];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_G_2 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[1];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_B_3 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[2];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4;
            float3 _Combine_c544d0baf46547c886465113721b8dc2_RGB_5;
            float2 _Combine_c544d0baf46547c886465113721b8dc2_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_G_2, _Split_ede1224a4ca84032bf4b1df871e93e70_B_3, 0, 0, _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4, _Combine_c544d0baf46547c886465113721b8dc2_RGB_5, _Combine_c544d0baf46547c886465113721b8dc2_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Length_48a21bd606b84dd8809be4bbd711831d_Out_1;
            Unity_Length_float2(_Combine_c544d0baf46547c886465113721b8dc2_RG_6, _Length_48a21bd606b84dd8809be4bbd711831d_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1;
            Unity_Sign_float(_Split_ede1224a4ca84032bf4b1df871e93e70_B_3, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2;
            Unity_Multiply_float(_Length_48a21bd606b84dd8809be4bbd711831d_Out_1, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_25e50631448749efbb0da292180556ac_RGBA_4;
            float3 _Combine_25e50631448749efbb0da292180556ac_RGB_5;
            float2 _Combine_25e50631448749efbb0da292180556ac_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_R_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2, 0, 0, _Combine_25e50631448749efbb0da292180556ac_RGBA_4, _Combine_25e50631448749efbb0da292180556ac_RGB_5, _Combine_25e50631448749efbb0da292180556ac_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0 = _GridSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_d8a6657237b7495786fadc1e73d14d81_Out_0 = _GridOffset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_30cda5be8c7d404e9658c018ae46e704_Out_0 = _GridLineSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 _GridUVCheck_8e141dc40edd45cf86f9583be61f0601;
            float _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1;
            SG_GridUVCheck_294d007a503d6d2499de026b4f678348(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0, _Property_d8a6657237b7495786fadc1e73d14d81_Out_0, _Property_30cda5be8c7d404e9658c018ae46e704_Out_0, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0 = UnityBuildTexture2DStructNoScale(_Texture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0 = _Tilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0 = _Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3;
            Unity_TilingAndOffset_float(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0, _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0 = SAMPLE_TEXTURE2D(_Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.tex, _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.samplerstate, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_R_4 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.r;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_G_5 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.g;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_B_6 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.b;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_A_7 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0 = IsGammaSpace() ? LinearToSRGB(_GridColor) : _GridColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_3fb6c7796dd34604bc473fd730674b8f_R_1 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[0];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_G_2 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[1];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_B_3 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[2];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_A_4 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2;
            Unity_Blend_Multiply_float4(_SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _Split_3fb6c7796dd34604bc473fd730674b8f_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3;
            Unity_Branch_float4(_GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0 = _BlendRatio;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4;
            float3 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5;
            float2 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6;
            Unity_Combine_float(_Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, 0, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Add_a65535dcb45144b5b19ae02c22841015_Out_2;
            Unity_Add_float4(_Branch_cf6de22576ad412293d963d30af6cdc8_Out_3, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Add_a65535dcb45144b5b19ae02c22841015_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1;
            Unity_Saturate_float4(_Add_a65535dcb45144b5b19ae02c22841015_Out_2, _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2;
            Unity_Blend_Multiply_float4(_Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1, _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0, _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2, 1);
            #endif
            surface.BaseColor = (_Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ USE_VIEW_DIRECTION_ON
        #pragma shader_feature_local _ MAKE_FLAT_ON

        #if defined(USE_VIEW_DIRECTION_ON) && defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(USE_VIEW_DIRECTION_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(MAKE_FLAT_ON)
            #define KEYWORD_PERMUTATION_2
        #else
            #define KEYWORD_PERMUTATION_3
        #endif


            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMALMAP 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define _NORMAL_DROPOFF_WS 1
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_NORMAL
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define ATTRIBUTES_NEED_TANGENT
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        #define VARYINGS_NEED_POSITION_WS
        #endif

            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 tangentOS : TANGENT;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 positionWS;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 WorldSpaceBiTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 ObjectSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 AbsoluteWorldSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 interp0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };

            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Texture_TexelSize;
            float2 _Tilling;
            float2 _Offset;
            float4 _Color;
            float _BlendRatio;
            float3 _ViewDirection;
            float _FlatHeight;
            float3 _FlatRotationAxis;
            float _FlatRotationDegrees;
            float _GridSize;
            float _GridLineSize;
            float2 _GridOffset;
            float4 _GridColor;
            float _OutlineThickness;
            float4 _OutlineColor;
            int _ID;
            CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);

            // Graph Functions
            
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
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

            Out = mul(rot_mat,  In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Sign_float(float In, out float Out)
        {
            Out = sign(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Floor_float(float In, out float Out)
        {
            Out = floor(In);
        }

        void Unity_Comparison_LessOrEqual_float(float A, float B, out float Out)
        {
            Out = A <= B ? 1 : 0;
        }

        struct Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025
        {
        };

        void SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(float Vector1_85c55723d9834bc8ae46c6a98fe13b10, float Vector1_62b294273be6446697298fa8ac134c00, float Vector1_3c59b7ed572644c5998c3e38963e8ee6, Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 IN, out float Out_Vector4_1)
        {
            float _Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0 = Vector1_85c55723d9834bc8ae46c6a98fe13b10;
            float _Property_956f6a66821048539f91c21a077f5ac8_Out_0 = Vector1_62b294273be6446697298fa8ac134c00;
            float _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2;
            Unity_Divide_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2);
            float _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1;
            Unity_Floor_float(_Divide_96f59abf4f6843a8b2fb74ada1ca15f8_Out_2, _Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1);
            float _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2;
            Unity_Multiply_float(_Floor_91e6787d4cb64466b5b2fac1c6d4a101_Out_1, _Property_956f6a66821048539f91c21a077f5ac8_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2);
            float _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2;
            Unity_Subtract_float(_Property_8d692d7a3bd447a99f8b5eef437acf39_Out_0, _Multiply_cbad36e59e394e9a9b23e90f795c469f_Out_2, _Subtract_19dd944d00524959aa68be8269b61ed4_Out_2);
            float _Property_d2a58bd098b14661a348886bbe47acf1_Out_0 = Vector1_3c59b7ed572644c5998c3e38963e8ee6;
            float _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
            Unity_Comparison_LessOrEqual_float(_Subtract_19dd944d00524959aa68be8269b61ed4_Out_2, _Property_d2a58bd098b14661a348886bbe47acf1_Out_0, _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2);
            Out_Vector4_1 = _Comparison_81ba0050a83e424e99b21c02327d5dfc_Out_2;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        struct Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348
        {
        };

        void SG_GridUVCheck_294d007a503d6d2499de026b4f678348(float2 Vector2_5a56dbf35cba4d4c8a3192a95b776eb9, float Vector1_0a171b7c60dc451dab7b2e69064f24eb, float2 Vector2_d630f5a030b148be8aa8b746e507f89a, float Vector1_7845b62507cb41e1bdeb7da05ba77e88, Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 IN, out float Out_Vector4_1)
        {
            float2 _Property_fb6173b513a2442dae002a71d714fb8a_Out_0 = Vector2_5a56dbf35cba4d4c8a3192a95b776eb9;
            float2 _Property_8e21231b95494bfd917e2a63f0311bab_Out_0 = Vector2_d630f5a030b148be8aa8b746e507f89a;
            float2 _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2;
            Unity_Subtract_float2(_Property_fb6173b513a2442dae002a71d714fb8a_Out_0, _Property_8e21231b95494bfd917e2a63f0311bab_Out_0, _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2);
            float _Split_68957bd604ac408cb4f40d11f10462e0_R_1 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[0];
            float _Split_68957bd604ac408cb4f40d11f10462e0_G_2 = _Subtract_c86e7a2a84c841e6ace00653ee9c4c00_Out_2[1];
            float _Split_68957bd604ac408cb4f40d11f10462e0_B_3 = 0;
            float _Split_68957bd604ac408cb4f40d11f10462e0_A_4 = 0;
            float _Property_f9707b40612141e28e92f98117aabb47_Out_0 = Vector1_0a171b7c60dc451dab7b2e69064f24eb;
            float _Property_82c6c275ad2e4dec864b44c81809a340_Out_0 = Vector1_7845b62507cb41e1bdeb7da05ba77e88;
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_b8e7d6fe4086451eb52139a6851ccac4;
            float _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_R_1, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4, _GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1);
            Bindings_GridCheck_7e9bb100a3d60a94f94589ab30823025 _GridCheck_ad0e839ef18848968002cfbf3e540a4c;
            float _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1;
            SG_GridCheck_7e9bb100a3d60a94f94589ab30823025(_Split_68957bd604ac408cb4f40d11f10462e0_G_2, _Property_f9707b40612141e28e92f98117aabb47_Out_0, _Property_82c6c275ad2e4dec864b44c81809a340_Out_0, _GridCheck_ad0e839ef18848968002cfbf3e540a4c, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1);
            float _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
            Unity_Or_float(_GridCheck_b8e7d6fe4086451eb52139a6851ccac4_OutVector4_1, _GridCheck_ad0e839ef18848968002cfbf3e540a4c_OutVector4_1, _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2);
            Out_Vector4_1 = _Or_b916cb2784d64a6582f6bc7ebadae8e8_Out_2;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Blend_Multiply_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = Base * Blend;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float4(float4 In, out float4 Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0 = _FlatRotationAxis;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0 = _FlatRotationDegrees;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.AbsoluteWorldSpacePosition, _Property_f67616b49efb49a395d991e36d5c2f7d_Out_0, _Property_a8d31893f5104bb3bdc008c6144d0a2f_Out_0, _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_R_1 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[0];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[1];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_B_3 = _RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3[2];
            float _Split_ef2a24bdf255433eb88306bcde4fe4aa_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0 = _FlatHeight;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2;
            Unity_Subtract_float(_Split_ef2a24bdf255433eb88306bcde4fe4aa_G_2, _Property_6c2e69a260844c7a91bd51ff7e3517cc_Out_0, _Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0 = float3(0, 1, 0);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2;
            Unity_Multiply_float((_Subtract_68df9f007bd44fea9df06041fa7120a9_Out_2.xxx), _Vector3_8dfc68ab95c4422a8396dc15f0376486_Out_0, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2;
            Unity_Subtract_float3(_RotateAboutAxis_45b701f026d44f0b9e1314efc1fcdb63_Out_3, _Multiply_6b6ee4a2652a4675b8cdc3048866c2f2_Out_2, _Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Subtract_08c11516e1dc412b903dfeba38607cd4_Out_2.xyz));
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(MAKE_FLAT_ON)
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = _Transform_e0ad5d78a2ae4d5fa740c2e72daa7f9a_Out_1;
            #else
            float3 _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0 = IN.ObjectSpacePosition;
            #endif
            #endif
            description.Position = _MakeFlat_48f396b624134ea9bc2f3c47a31041ed_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Property_e4769ac03187485fb020eb7088c295ed_Out_0 = _ViewDirection;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            #if defined(USE_VIEW_DIRECTION_ON)
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = _Property_e4769ac03187485fb020eb7088c295ed_Out_0;
            #else
            float3 _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0 = -1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2;
            Unity_DotProduct_float3(IN.AbsoluteWorldSpacePosition, _UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, _DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2;
            Unity_Multiply_float(_UseViewDirection_2608c469ad394b9992f097284919b99f_Out_0, (_DotProduct_ed4a360a7a57420c95960f83990050e4_Out_2.xxx), _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float3 _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2;
            Unity_Subtract_float3(IN.AbsoluteWorldSpacePosition, _Multiply_85385482bb3846f5a7552ac6c824f094_Out_2, _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_ede1224a4ca84032bf4b1df871e93e70_R_1 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[0];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_G_2 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[1];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_B_3 = _Subtract_1bc7b4078bde43a480621eb2d19ce011_Out_2[2];
            float _Split_ede1224a4ca84032bf4b1df871e93e70_A_4 = 0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4;
            float3 _Combine_c544d0baf46547c886465113721b8dc2_RGB_5;
            float2 _Combine_c544d0baf46547c886465113721b8dc2_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_G_2, _Split_ede1224a4ca84032bf4b1df871e93e70_B_3, 0, 0, _Combine_c544d0baf46547c886465113721b8dc2_RGBA_4, _Combine_c544d0baf46547c886465113721b8dc2_RGB_5, _Combine_c544d0baf46547c886465113721b8dc2_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Length_48a21bd606b84dd8809be4bbd711831d_Out_1;
            Unity_Length_float2(_Combine_c544d0baf46547c886465113721b8dc2_RG_6, _Length_48a21bd606b84dd8809be4bbd711831d_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1;
            Unity_Sign_float(_Split_ede1224a4ca84032bf4b1df871e93e70_B_3, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2;
            Unity_Multiply_float(_Length_48a21bd606b84dd8809be4bbd711831d_Out_1, _Sign_3a9dd5cc2c7d401abf60568356686fa9_Out_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_25e50631448749efbb0da292180556ac_RGBA_4;
            float3 _Combine_25e50631448749efbb0da292180556ac_RGB_5;
            float2 _Combine_25e50631448749efbb0da292180556ac_RG_6;
            Unity_Combine_float(_Split_ede1224a4ca84032bf4b1df871e93e70_R_1, _Multiply_3a12640e60a9408d9c50ff83d67b70dd_Out_2, 0, 0, _Combine_25e50631448749efbb0da292180556ac_RGBA_4, _Combine_25e50631448749efbb0da292180556ac_RGB_5, _Combine_25e50631448749efbb0da292180556ac_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0 = _GridSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_d8a6657237b7495786fadc1e73d14d81_Out_0 = _GridOffset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_30cda5be8c7d404e9658c018ae46e704_Out_0 = _GridLineSize;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            Bindings_GridUVCheck_294d007a503d6d2499de026b4f678348 _GridUVCheck_8e141dc40edd45cf86f9583be61f0601;
            float _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1;
            SG_GridUVCheck_294d007a503d6d2499de026b4f678348(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_3ee427d04e2f408aac838c37ac2b2d1c_Out_0, _Property_d8a6657237b7495786fadc1e73d14d81_Out_0, _Property_30cda5be8c7d404e9658c018ae46e704_Out_0, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601, _GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            UnityTexture2D _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0 = UnityBuildTexture2DStructNoScale(_Texture);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0 = _Tilling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0 = _Offset;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float2 _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3;
            Unity_TilingAndOffset_float(_Combine_25e50631448749efbb0da292180556ac_RG_6, _Property_26f81c3a8e7b47ef923406f69667d74a_Out_0, _Property_70dc0c9ec432462bbacdd2bd304dbb2e_Out_0, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0 = SAMPLE_TEXTURE2D(_Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.tex, _Property_900549e618014d46a7aa4b8400b8cd4b_Out_0.samplerstate, _TilingAndOffset_881168c7b48240938ea9f413d8f014b6_Out_3);
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_R_4 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.r;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_G_5 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.g;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_B_6 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.b;
            float _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_A_7 = _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0 = IsGammaSpace() ? LinearToSRGB(_GridColor) : _GridColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Split_3fb6c7796dd34604bc473fd730674b8f_R_1 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[0];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_G_2 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[1];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_B_3 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[2];
            float _Split_3fb6c7796dd34604bc473fd730674b8f_A_4 = _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2;
            Unity_Blend_Multiply_float4(_SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Property_5f4aa42568f74facb8a0fc03902bafec_Out_0, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _Split_3fb6c7796dd34604bc473fd730674b8f_A_4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3;
            Unity_Branch_float4(_GridUVCheck_8e141dc40edd45cf86f9583be61f0601_OutVector4_1, _Blend_6fb1d10a173e4923b5c6c51b2ee9cfd0_Out_2, _SampleTexture2D_0fd870835aa44780b67f6d4b50de6b40_RGBA_0, _Branch_cf6de22576ad412293d963d30af6cdc8_Out_3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0 = _BlendRatio;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4;
            float3 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5;
            float2 _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6;
            Unity_Combine_float(_Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, _Property_bbe3c70cde1d42edba6694b747ffbc19_Out_0, 0, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGB_5, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RG_6);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Add_a65535dcb45144b5b19ae02c22841015_Out_2;
            Unity_Add_float4(_Branch_cf6de22576ad412293d963d30af6cdc8_Out_3, _Combine_6d0dc3aeb5ce416b848b18e29ac082f7_RGBA_4, _Add_a65535dcb45144b5b19ae02c22841015_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1;
            Unity_Saturate_float4(_Add_a65535dcb45144b5b19ae02c22841015_Out_2, _Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
            float4 _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2;
            Unity_Blend_Multiply_float4(_Saturate_e2c66aff0a8045cfb3c5c91605f527f8_Out_1, _Property_c1801e9519f64f7f936a670ecbe7136e_Out_0, _Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2, 1);
            #endif
            surface.BaseColor = (_Blend_ca36642131a449a0b5e02aa1653d0ca4_Out_2.xyz);
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceNormal =           input.normalOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceTangent =          input.tangentOS.xyz;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.ObjectSpacePosition =         input.positionOS;
        #endif

        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
        #endif


            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3)
        output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
        #endif

        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}
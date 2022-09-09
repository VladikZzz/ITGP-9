Shader "Custom/VladosShader"
{
     Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _SpecularStrength("SpecularStrength", Range(0, 64)) = 8
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float _Specular;

            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f output;
                output.vertex = TransformObjectToHClip(v.vertex.xyz);
                output.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                output.normal = TransformObjectToWorldNormal(v.normal);
                return output;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 ambient = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                Light light = GetMainLight();
                float NdotL = dot(i.normal, light.direction);
                float intensity = saturate(NdotL);
                float4 diffuse = intensity * ambient;
                float3 viewDir = UNITY_MATRIX_IT_MV[2].xyz;
                float3 halfDir = normalize(light.direction + viewDir);
                float specAngle = max(dot(halfDir, i.normal), 0.0);
                float4 specular = pow(specAngle, 16);
                
                return (diffuse + specular) * float4(light.color, 1);
            }
            ENDHLSL
        }
    }
}
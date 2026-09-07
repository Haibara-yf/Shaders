Shader "Unlit/burning"
{
    Properties//是否提交成功
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        [HDR]_EdgeColor("EdgeColor",color) = (1,1,1,1)
        _BurningRange("BurningRange",float) = 0.2
        _EdgeRange("EdgeRange",float) = 0.1
        [HDR]_BurningColor("BurningColor",color) = (1,1,1,1)
        _BurningValue("BurningValue",float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 posOS : POSITION;
                float2 uv     : TEXCOORD0;
                float2 uv2    : TEXCOORD1;
            };

            struct VS2PSData
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 posWS : TEXCOORD2;
                float4 posCS : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float  _EdgeRange;
            float  _BurningRange;
            float4 _BurningColor;
            float  _BurningValue;
            float4 _EdgeColor;
            
            VS2PSData vert (MeshData input)
            {
                VS2PSData output;
                output.posCS = UnityObjectToClipPos(input.posOS);
                output.uv = input.uv;
                output.uv2 = input.uv2;
                output.posWS = mul(unity_ObjectToWorld,input.posOS).xyz;
                return output;
            }

            float4 frag (VS2PSData input) : SV_Target
            {
                float2 uv = TRANSFORM_TEX(input.uv2,_MainTex);
                float4 BaseMap = tex2D(_MainTex,uv);
                float4 NoiseMap = tex2D(_NoiseTex,uv);

                float test = input.posWS.y - _BurningValue - NoiseMap.r;

                clip(test);
                float t = smoothstep(0, _BurningRange, test);
                return lerp(_BurningColor, BaseMap, t);
            }
            ENDCG
        }
    }
}

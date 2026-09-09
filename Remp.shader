Shader "Unlit/WriteShader"
{
    Properties
    {
        _MatCap("matcap",2D) = "white"{}
        _ColorMap("ColorMap",2D) = "white"{}
        _Material("Material",2D) = "white"{}
        _black("black",2D) = "white"{}
        _blackIntensity("blackIntensity",float) = 5;
        _MatCapIntensity("MapCapIntensity",float) = 5;
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 world_normal : TEXCOORD1;
                float3 world_Pos : TEXCOORD2;
            };

            sampler2D _MatCap; float4 _MatCap_ST;
            sampler2D _ColorMap; float4 _ColorMap_ST;
            sampler2D _Material; float4 _Material_ST;
            sampler2D _black; float4 _black_ST;
            float _blackIntensity;
            float _MatCapIntensity;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Material);
                float3 WorldNormal = mul(v.normal, (float3x3)unity_ObjectToWorld);
                o.world_normal = WorldNormal;
                o.world_Pos = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.world_normal);
                float3 normal_view = mul(UNITY_MATRIX_V,float4(worldNormal,0.0)).xyz;
                float2 MatCap_uv = (normal_view + float2(1.0,1.0))*0.5;
                float4 MatCap_color = tex2D(_MatCap,MatCap_uv)*_MatCapIntensity;
                float4 MatCap_Outline = tex2D(_black,MatCap_uv);              
                float4 Material_Color = tex2D(_Material,i.uv);
                float3 View_Dir = normalize(_WorldSpaceCameraPos.xyz-i.world_Pos);
                float NdotV = saturate(dot(i.world_normal,View_Dir));
                float fresnel = 1-NdotV;
                float2 Color_uv = float2(fresnel,0.5);
                float4 Ramp_Color = tex2D(_ColorMap,Color_uv);
                float4 combine_Color = MatCap_color*Material_Color*Ramp_Color+MatCap_Outline*_blackIntensity;
                return combine_Color;
            }
            ENDCG
        }
    }
}

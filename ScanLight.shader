Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _outcolor("Outcolor",color) = (1,0,0,1)
        _innercolor("innercolor",color) = (1,0,0,1)
        _outColorIntensity("outColorIntensity",float) = 1
        _speed("speed",float) = 1
        _outlineIntensity("outlineIntensity",float) = 1
        _emission("emission",float) = 1
        _LightPower("LightPower",float) = 1
    }
    SubShader
    {
       Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
        Cull Back
        Blend SrcAlpha One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                float3 world_Normal :TEXCOORD1;
                float3 WorldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _outcolor;
            float4 _innercolor;
            float _outColorIntensity;
            float _speed;
            float _outlineIntensity;
            float _emission;
            float _LightPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 Normal_world = UnityObjectToWorldNormal(v.normal);
                o.WorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.world_Normal = Normal_world;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.world_Normal);
                float2 light_uv = i.WorldPos.xy+float2(_Time.y*_speed,_Time.y*_speed);
                float3 view_Dir = normalize(_WorldSpaceCameraPos.xyz-i.WorldPos);
                float NdotV = saturate(dot(worldNormal,view_Dir));
                float frensel = 1-NdotV;
                float outlinepower = pow(frensel,_outlineIntensity);
                float final_Frensel = saturate(outlinepower*_emission);
                float4 final_color = lerp(_innercolor,_outcolor,final_Frensel);
                float4 col = tex2D(_MainTex,light_uv)*_LightPower;
                float4 final_final_color = col + final_color;
                return float4(final_final_color.xyz,final_Frensel);
            }
            ENDCG
        }
    }
}

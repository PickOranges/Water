Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG)", 2D) = "black" {} // tex2: flow vector
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #include "Flow.cginc"

        sampler2D _MainTex, _FlowMap;

        struct Input
        {
            float2 uv_MainTex;
        };


        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2 - 1;  // disturb. can be pos or neg, thus we make the value in range of [-1,1].
            //fixed4 c = tex2D (_MainTex, FlowUV(IN.uv_MainTex, flowVector, _Time.y)) * _Color;
            
            
            float3 uvw = FlowUVW(IN.uv_MainTex, flowVector, _Time.y);
            fixed4 c = tex2D (_MainTex, uvw.xy) * uvw.z * _Color;
            o.Albedo = c.rgb;
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

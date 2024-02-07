Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        [NoScaleOffset] _FlowMap ("Flow (RG,  A noise)", 2D) = "black" {} // tex3: flow vector, with perlin noise on alpha channel

        // jump control via slider bar, note the jump of uv offset should not greater than 0.5, 
        // because the period is 1, offset 0.5 is too coarse.
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25

        // fine-tuning params
        _Tiling ("Tiling", Float) = 1  // scaling factor of uv-coord
        _Speed ("Speed", Float) = 1    // scaling factor of t
        _FlowStrength ("Flow Strength", Float) = 1  // scaling factor of flow vector, i.e. distortion
        _FlowOffset ("Flow Offset", Float) = 0
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
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2 - 1; 
            flowVector *= _FlowStrength;

            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
            float time = _Time.y * _Speed  + noise;
            float2 jump = float2(_UJump, _VJump);
			
            float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector, jump, _FlowOffset, _Tiling, time, false);
			float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector, jump, _FlowOffset, _Tiling, time, true);

            fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
			fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

            fixed4 c = (texA + texB) * _Color;
            o.Albedo = c.rgb;
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

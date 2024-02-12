Shader "Custom/DirectionalFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

		[NoScaleOffset] _MainTex ("Deriv (AG) Height (B)", 2D) = "black" {}
		[NoScaleOffset] _FlowMap ("Flow (RG)", 2D) = "black" {}

        // fine-tuning params
        _Tiling ("Tiling", Float) = 1  // scaling factor of uv-coord
        _Speed ("Speed", Float) = 1    // scaling factor of t
        _FlowStrength ("Flow Strength", Float) = 1  // scaling factor of flow vector, i.e. distortion
        _HeightScale ("Height Scale, Constant", Float) = 0.25
        _HeightScaleModulated ("Height Scale, Modulated", Float) = 0.75
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #include "../T1/Flow.cginc"

        sampler2D _MainTex, _FlowMap;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Tiling, _Speed, _FlowStrength;
        float _HeightScale, _HeightScaleModulated;

        float3 UnpackDerivativeHeight (float4 textureData) {
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 - 1;
            return dh;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
        	float time = _Time.y * _Speed;
			float2 uvFlow = DirectionalFlowUV(IN.uv_MainTex, float2(0, 1), _Tiling, time);

			float3 dh = UnpackDerivativeHeight(tex2D(_MainTex, uvFlow));
			fixed4 c = dh.z * dh.z * _Color;
			o.Albedo = c;
			o.Normal = normalize(float3(-dh.xy, 1));
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

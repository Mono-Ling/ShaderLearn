Shader "Unlit/WaterVertexAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Amplitude("Amplitude",Float) = 2
        _Frequency("Frequency",Float) = 1
        _InveWaveLength("InveWaveLength",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Amplitude;
            float _Frequency;
            float _InveWaveLength;

            v2f vert (appdata_base v)
            {
                v2f o;
                v.vertex.x += sin(_Time.y * _Frequency + v.vertex.z*_InveWaveLength)*_Amplitude;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex,i.uv) * _Color;
                return color;
            }
            ENDCG
        }
    }
}

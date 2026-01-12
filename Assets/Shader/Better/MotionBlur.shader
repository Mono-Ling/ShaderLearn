Shader "Unlit/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurPower("Blur Power",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        ZWrite Off
        Cull Off
        ZTest Always

        CGINCLUDE
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurPower;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
        ENDCG

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB

            fixed4 fragRGB (v2f i) : SV_Target
            {
                return fixed4(tex2D(_MainTex,i.uv).rgb,_BlurPower);
            }
            ENDCG
        }

        Pass
        {
            Blend One Zero
            ColorMask A
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA

            fixed4 fragA (v2f i) : SV_Target
            {
                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }
    Fallback Off
}

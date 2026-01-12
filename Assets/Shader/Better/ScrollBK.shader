Shader "Unlit/ScrollBK"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex("Second Texure",2D) = "white" {}
        _SpeedU("Speed U",float) = 0
        _SpeedV("Speed V",float) = 0
        _Blend("Blend",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque""IgnoreProjector"="True""Queue"="Transparent" }
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
            sampler2D _SecondTex;
            float4 _MainTex_ST;
            float _SpeedU;
            float _SpeedV;
            float _Blend;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = frac(i.uv + float2(_Time.y * _SpeedU,_Time.y * _SpeedV));
                fixed4 color1 = tex2D(_MainTex,uv);
                fixed4 color2 =tex2D(_SecondTex,uv);
                fixed4 color = lerp(color1,color2,_Blend);
                return color;
            }
            ENDCG
        }
    }
}

Shader "Unlit/BrightnessStaturationContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //亮度
        _Brightness("Brightness",Float) = 1
        //饱和度
        _Staturation("Staturation",Float) = 1
        //对比度
        _Contrast("Contrast",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Staturation;
            float _Contrast;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy *_MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderColor = tex2D(_MainTex,i.uv);
                //亮度处理
                fixed3 color = renderColor.rgb * _Brightness;
                //饱和度处理
                fixed L = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722;
                fixed3 LColor = fixed3(L,L,L);
                color = lerp(LColor,color,_Staturation);
                //对比度处理
                fixed3 rvgColor = fixed3(0.5,0.5,0.5);
                color  = lerp( rvgColor,color, _Contrast);

                return fixed4(color, renderColor.a);
            }
            ENDCG
        }
    }
    Fallback Off
}

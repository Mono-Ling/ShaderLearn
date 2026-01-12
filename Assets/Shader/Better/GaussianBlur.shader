Shader "Unlit/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSpread("Blur Spread",Float) = 0.5
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
                half2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            float _BlurSpread;

            fixed4 frag (v2f i) : SV_Target
            {
                float weight[3] = {0.4026 , 0.2442  ,0.0545};
                fixed3 sum = tex2D(_MainTex,i.uv[0]) * weight[0];
                for(int j = 1; j < 3 ; j++)
                {
                    sum += tex2D(_MainTex,i.uv[j*2-1]) * weight[1];
                    sum += tex2D(_MainTex,i.uv[j*2]) * weight[2];
                }
                return fixed4(sum,1);
            }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vertHorizontal
            #pragma fragment frag


            v2f vertHorizontal (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv + half2( _MainTex_TexelSize.x * 0 ,0) * _BlurSpread;
                o.uv[1] = uv + half2( _MainTex_TexelSize.x * 1 ,0) * _BlurSpread;
                o.uv[2] = uv - half2( _MainTex_TexelSize.x * 1 ,0) * _BlurSpread;
                o.uv[3] = uv + half2( _MainTex_TexelSize.x * 2 ,0) * _BlurSpread;
                o.uv[4] = uv - half2( _MainTex_TexelSize.x * 2 ,0) * _BlurSpread;
                return o;
            }

            ENDCG
        }
        
        Pass
        {
            CGPROGRAM

            #pragma vertex vertVertical
            #pragma fragment frag

            v2f vertVertical (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv + half2(0 , _MainTex_TexelSize.y * 0) * _BlurSpread;
                o.uv[1] = uv + half2(0 , _MainTex_TexelSize.y * 1) * _BlurSpread;
                o.uv[2] = uv - half2(0 , _MainTex_TexelSize.y * 1) * _BlurSpread;
                o.uv[3] = uv + half2(0 , _MainTex_TexelSize.y * 2) * _BlurSpread;
                o.uv[4] = uv - half2(0 , _MainTex_TexelSize.y * 2) * _BlurSpread;
                return o;
            }

            ENDCG
        }
    }
    Fallback Off
}

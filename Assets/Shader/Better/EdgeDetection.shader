Shader "Unlit/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor("Edge Color",Color) = (1,1,1,1)
        _BKExtent("BK Extent",Range(0,1)) = 1
        _BKColor("BK Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            fixed4 _EdgeColor;
            float _BKExtent;
            fixed4 _BKColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                return o;
            }

            fixed Calcluminance(fixed4 color)
            {
                return 0.2126*color.r + 0.7152*color.g + 0.0722*color.b;
            }

            half Sobel(half2 uv[9])
            {
                half Gx[9] = {-1,-2,-1,
                               0, 0, 0,
                               1, 2, 1};
                half Gy[9] = {-1,0,1,
                              -2,0,2,
                              -1,0,1};
               half edgeX = 0;
               half edgeY = 0;
               for(int i=0;i<9;i++)
               {
                   edgeX += Calcluminance(tex2D(_MainTex,uv[i])) * Gx[i];
                   edgeY += Calcluminance(tex2D(_MainTex,uv[i])) * Gy[i];
               }
               return abs(edgeX) + abs(edgeY);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderColor = tex2D(_MainTex,i.uv[4]);
                fixed G = Sobel(i.uv);
                fixed3 initColor = lerp(renderColor,_EdgeColor,G);
                fixed3 onlyEdgeColor = lerp(_BKColor,_EdgeColor,G);
                fixed3 color = lerp( initColor,onlyEdgeColor,_BKExtent);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback Off
}

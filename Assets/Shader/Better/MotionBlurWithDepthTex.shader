Shader "Unlit/MotionBlurWithDepthTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurOffset("Blur Offset",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off
        Cull Off
        ZTest Always

        Pass
        {
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
            float4x4 _ClipToWorldMatrix;
            float4x4 _OldWorldToClipMatrix;
            float _BlurOffset;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
                depth = Linear01Depth(depth);
                float4 nowClipPos = float4(i.uv.x*2-1,i.uv.y*2-1,depth*2-1,1);
                float4 worldPos = mul(_ClipToWorldMatrix,nowClipPos);
                float4 oldClipPos = mul(_OldWorldToClipMatrix,worldPos);
                oldClipPos/=oldClipPos.w;
                float2 moveVector = nowClipPos.xy - oldClipPos.xy;
                moveVector /= 2;

                float2 uv = i.uv;
                float4 color = float4(0,0,0,0);
                for(int j = 0 ; j < 3 ; j++)
                {
                    color += tex2D( _MainTex,uv);
                    uv += moveVector*_BlurOffset;
                }
                color/=3;
                return fixed4(color.rgb,1);
            }
            ENDCG
        }
    }
    Fallback Off
}

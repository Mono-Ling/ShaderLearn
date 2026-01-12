Shader "Unlit/EdgeDetectionDepthNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DepthThreshold("Depth Threshold",Range(0,1)) = 1
        _NormalThreshold("Normal Threshold",Range(0,1)) = 1
        _UVOffset("UV Offset",Float) = 1
        _EdgeColor("Edge Color",Color) = (1,1,1,1)
        _DepthSensitivity("Depth Sensitivity",Range(0,1)) = 1
        _NormalSensitivity("Normal Sensitivity",Range(0,1)) = 1
        _DepthInterval("Depth Interval",Range(0,1)) = 1
        _NormalInterval("Noamal Interval",Range(0,1)) = 1
        _BKPower("BK Power",Range(0,1)) = 1
        _BKColor("BK Color",Color) = (1,1,1,1)
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
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _DepthThreshold;
            float _NormalThreshold;
            float _UVOffset;
            fixed4 _EdgeColor;
            sampler2D _CameraDepthNormalsTexture;
            float _DepthSensitivity;
            float _NormalSensitivity;
            float _DepthInterval;
            float _NormalInterval;
            float _BKPower;
            fixed4 _BKColor;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv + half2(0,0) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[1] = uv + half2(1,1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[2] = uv + half2(-1,-1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[3] = uv + half2(-1,1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[4] = uv + half2(1,-1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[5] = uv + half2(0,1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[6] = uv + half2(0,-1) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[7] = uv + half2(-1,0) * _MainTex_TexelSize.xy * _UVOffset;
                o.uv[8] = uv + half2(1,0) * _MainTex_TexelSize.xy * _UVOffset;
                return o;
            }

            half Comparison(float4 point1,float4 point2)
            {
                float3 normal1 = point1.xyz;
                float depth1 = point1.w;
                float3 normal2 = point2.xyz;
                float depth2 = point2.w;
                float diffNormal = (1 - abs(dot(normalize(normal1),normalize(normal2))))*_NormalSensitivity;
                float diffDepth = abs(depth1-depth2)*_DepthSensitivity;
                float normalNum = smoothstep(_NormalThreshold,min(_NormalThreshold+_NormalInterval,1),diffNormal);
                float depthNum = smoothstep(_DepthThreshold,min(_DepthThreshold+_DepthInterval,1),diffDepth);
                return (normalNum+depthNum)/(_DepthSensitivity+_NormalSensitivity);
                //return (diffNormal>_NormalThreshold|| diffDepth>_DepthThreshold) ? 1 : 0;
                //half2 diffNormal = abs(normal1 - normal2) * _NormalSensitivity;
                //int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
                //float diffDepth = abs(depth1-depth2) * _DepthSensitivity;
                //int isSameDepth = diffDepth < 0.1 * depth1;
                //return isSameDepth*isSameNormal ? 0 : 1;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 points[8];
                for(int j = 1; j < 9; j++)
                {
                    float depth;
                    float3 normal;
                    float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv[j]);
                    DecodeDepthNormal(depthNormal, depth, normal);
                    points[j-1] = float4(normal, depth);
                }
                half num1 = max(Comparison(points[0],points[1]),Comparison(points[2],points[3]));
                half num2 = max(Comparison(points[4],points[5]),Comparison(points[6],points[7]));
                float num = max(num1,num2);
                fixed4 renderColor = tex2D(_MainTex,i.uv[0]);
                renderColor = lerp(renderColor,_BKColor,_BKPower);
                fixed3 color = lerp(renderColor,_EdgeColor,num);
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback Off
}

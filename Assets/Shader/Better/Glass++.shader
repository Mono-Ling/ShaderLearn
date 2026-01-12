Shader "Unlit/Glass++"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _CubemapTex("Cubemap Texture",Cube) = "white" {}
        _Reflectivity("Reflectivit",Range(0,1)) = 1
        _Distortion("Distortion",Range(0,10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        GrabPass{}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;//MainTexUV && BumpTexUV
                float4 TBN_wPos0 : TEXCOORD1;
                float4 TBN_wPos1 : TEXCOORD2;
                float4 TBN_wPos2:  TEXCOORD3;
                //float3 wPos : TEXCOORD4;
                float4 screenPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _GrabTexture;
            samplerCUBE _CubemapTex;
            float _Reflectivity;
            float _Distortion;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 wPos = mul( unity_ObjectToWorld,v.vertex);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent);
                float3 wBitangent = cross(normalize( wNormal),normalize( wTangent)) * v.tangent.w;
                float3x3 TBN = transpose(float3x3(wTangent,wBitangent,wNormal));
                o.screenPos = ComputeGrabScreenPos(o.pos);
                //o.wPos = wPos;
                //o.TBN = TBN;
                o.TBN_wPos0.xyz = float4( TBN[0],wPos.x);
                o.TBN_wPos1.xyz = float4( TBN[1],wPos.y);
                o.TBN_wPos2.xyz = float4( TBN[2],wPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float3x3 TBN = i.TBN;
                float3 wPos = float3(i.TBN_wPos0.w,i.TBN_wPos1.w,i.TBN_wPos2.w);
                float3 wViewDir = normalize( UnityWorldSpaceViewDir(wPos));
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                float3 tangentNormal = UnpackNormal(packedNormal);

                float3 wNormal = float3(dot(tangentNormal , i.TBN_wPos0.xyz),
                                        dot(tangentNormal , i.TBN_wPos1.xyz),
                                        dot(tangentNormal , i.TBN_wPos2.xyz));
                //反射
                float3 wReflectDir = reflect(-wViewDir,wNormal);
                fixed4 reflectColor = texCUBE(_CubemapTex,wReflectDir) * texColor;
                //折射
                float2 offset = tangentNormal.xy  * _Distortion;
                i.screenPos.xy = offset * i.screenPos.z + i.screenPos.xy;
                float2 screenUV = i.screenPos.xy/i.screenPos.w;
                fixed4 refractColor = tex2D(_GrabTexture,screenUV);
                //菲涅尔反射率Schiick近似等式
                fixed R = _Reflectivity + (1- _Reflectivity)* pow(1-dot(normalize(wNormal),normalize(wViewDir)),5);
                fixed4 color = lerp( refractColor,reflectColor,R);
                return color;
            }
            ENDCG
        }
    }
}

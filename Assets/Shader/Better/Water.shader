Shader "Unlit/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _CubeMapTex ("Cubemap Texture", Cube) = "white" { }
        _Distortion ("Distortion", Range(0, 10)) = 1
        _WaveXSpeed ("Wave X Speed", Range(0, 5)) = 1
        _WaveYSpeed ("Wave Y Speed", Range(0, 5)) = 1
        _Reflectivity("Reflectivit",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        GrabPass { }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 uv : TEXCOORD0;//xy:_MainTex uv, zw:BumpMap uv
                float4 vertex : SV_POSITION;
                float3x3 TBN : TEXCOORD1;
                float3 wPos : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            sampler2D _GrabTexture;
            float4 _BumpMap_ST;
            float _Distortion;
            float _WaveXSpeed;
            float _WaveYSpeed;
            float _Reflectivity;
            samplerCUBE _CubeMapTex;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 wBitangent = cross(wNormal, wTangent) * v.tangent.w;
                o.TBN = transpose(float3x3(wTangent, wBitangent, wNormal));
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);
                float3 bump1 = UnpackNormal(tex2D(_BumpMap, i.uv.zw + speed));
                float3 bump2 = UnpackNormal(tex2D(_BumpMap, i.uv.zw - speed));
                float3 bumpNormal = normalize(bump1 + bump2);
                float3 worldNormal = normalize(mul(i.TBN, bumpNormal));
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.wPos);
                //∑¥…‰
                float3 reflectDir =  reflect(-viewDir, worldNormal);
                float4 reflectColor = texCUBE(_CubeMapTex, reflectDir) * tex2D(_MainTex, i.uv.xy + speed);
                //’€…‰
                float2 offset = worldNormal.xz * _Distortion;
                i.screenPos.xy = i.screenPos.z * offset + i.screenPos.xy;
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                fixed4 grabColor = tex2D(_GrabTexture, screenUV);
                
               fixed R = _Reflectivity + (1- _Reflectivity)* pow(1-dot(normalize(worldNormal),normalize(viewDir)),5);
                fixed4 color = reflectColor *   R + grabColor * (1- R);
                return color;
            }
            ENDCG
        }
    }
}

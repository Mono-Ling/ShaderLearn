Shader "Unlit/Reflective"
{
    Properties
    {
        _CubeMap("Cube Map",Cube)="white"{}
        _ReflectColor("Reflect Color",Color) = (1,1,1,1)
        _MainColor("Main Color",Color) = (1,1,1,1)
        _Reflectivity("Reflectivit",Range(0,1))=1
        _SpecularColor("Specular Color",Color) = (1,1,1,1)
        _SpecularNum("Specular Power",Range(0,500)) = 100
        _SpecularPower("Specular Power",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"  }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD0;
                float3 wReflect : TEXCOORD1;
                float3 wBinormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            samplerCUBE _CubeMap;
            float4 _MainColor;
            float4 _ReflectColor;
            float _Reflectivity;
            float4 _SpecularColor;
            float _SpecularPower;
            float _SpecularNum;

            fixed3 KajiaKaySpecular(in float3 binormal,in float3 wPos,in float3 lightDir)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
                float3 halfDir = normalize(viewDir+lightDir);
                float TdotH = dot(binormal,halfDir);
                float TsinH = sqrt (1.0- TdotH * TdotH);
                fixed specular= _LightColor0.rgb*_SpecularColor.rgb * pow(TsinH,_SpecularNum);
                return specular* _SpecularPower;
            }
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 wViewDir = normalize(_WorldSpaceCameraPos.xyz - o.wPos);
                float3 wTangent = UnityObjectToWorldDir(v.tangent);
                o.wBinormal = cross( wTangent,o.wNormal) * v.tangent.w;
                o.wReflect = reflect(-wViewDir,o.wNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                 #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.wPos);
                #endif
                fixed3 cubemapColor = texCUBE(_CubeMap,i.wReflect).rgb * _ReflectColor.rgb;
                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * (dot(i.wNormal,lightDir)*0.5+0.5);
                fixed3 specular = KajiaKaySpecular(normalize(i.wBinormal),i.wPos,lightDir);
                UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + (lerp(diffuse,cubemapColor,_Reflectivity)+specular) * atten;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    Fallback"Reflective/VertexLit"
}

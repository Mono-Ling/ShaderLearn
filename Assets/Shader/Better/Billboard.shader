Shader "Unlit/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _VerticalBillboarding("Vertical Billboarding",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True" }
        LOD 100

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcColor OneMinusSrcColor
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
            fixed4 _Color;
            fixed _VerticalBillboarding;

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 center = float3(0,0,0);
                float3 normal = normalize(mul(unity_WorldToObject , float4(_WorldSpaceCameraPos,1))-center);
                normal.y *= _VerticalBillboarding;
                normal = normalize(normal);
                float3 up = normal.y > 0.999 ? float3(0,0,1) : float3(0,1,0);
                float3 right = normalize(cross(up,normal));
                up =  normalize(cross( normal,right));
                float3 offset = v.vertex - center;
                v.vertex.xyz = center + normal * offset.z + right * offset.x + up * offset.y;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex,i.uv);
                color.rgb *= _Color.rgb;
                return color;
            }
            ENDCG
        }
    }
}

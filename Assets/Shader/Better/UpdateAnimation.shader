Shader "Unlit/UpdateAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rows("Rows",int) = 8
        _Columns("Columns",int) = 8
        _Speed("Speed",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue"="Transparent" }
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
            float4 _MainTex_ST;
            float _Rows;
            float _Columns;
            float _Speed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + v.texcoord.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half Index = floor(_Time.y * _Speed) % (_Rows * _Columns);
                float2 framUV = float2( Index % _Columns / _Columns,1 - (floor(Index / _Columns )+1)/ _Rows);
                float2 size = float2(1 / _Columns,1 / _Rows);
                fixed4 color =  tex2D(_MainTex,i.uv * size + framUV);
                return color;
            }
            ENDCG
        }
    }
}

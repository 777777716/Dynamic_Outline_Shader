Shader "ImageEffect/_Outline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_alpha("透明度", Float) = 0.2
        _sideX ("sideX", float) = 0.01
        _sideY ("sideY", float) = 0.01
		_Color ("Tint", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags 
		{ 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
        }

		Cull Off 
        Lighting Off 
        ZWrite Off 
        Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed _sideX = 0.1; 
			fixed _sideY = 0.1; 
			fixed _alpha;

			struct a2v
			{
				half4 vertex   : POSITION;
                fixed4 color    : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half4 vertex        : SV_POSITION;
				half2 texcoord      : TEXCOORD0;
				fixed4 color         : COLOR;
			};

			v2f vert (a2v i)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, i.vertex); 
				o.texcoord = i.texcoord;
                o.color = i.color;
				return o;
			}
		
			static const fixed cosArray[12] = {1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5, 0, 0.5, 0.866};  
			static const fixed sinArray[12] = {0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5}; 

			fixed getAlpha(half2 texcoord, int index)
			{
				return tex2D (_MainTex, texcoord + half2(_sideX * cosArray[index], _sideY * sinArray[index])).a;
			}

			fixed4 frag (v2f i) : COLOR
			{
				//根据时间确定当前描边宽度
				fixed tempX = _sideX;
				_sideX *= _SinTime.w;
				fixed tempY = _sideY;
				_sideY *= _SinTime.w;
				
				fixed alpha = 0;
				//部分硬件不支持for
				alpha += getAlpha(i.texcoord, 0);
				alpha += getAlpha(i.texcoord, 1);
				alpha += getAlpha(i.texcoord, 2);
				alpha += getAlpha(i.texcoord, 3);
				alpha += getAlpha(i.texcoord, 4);
				alpha += getAlpha(i.texcoord, 5);
				alpha += getAlpha(i.texcoord, 6);
				alpha += getAlpha(i.texcoord, 7);
				alpha += getAlpha(i.texcoord, 8);
				alpha += getAlpha(i.texcoord, 9);
				alpha += getAlpha(i.texcoord, 10);
				alpha += getAlpha(i.texcoord, 11);
				
				//复位
				_sideX = tempX;
				_sideY = tempY;

				//统一透明度
				alpha = (alpha > 1 ? 1 : alpha) * _alpha;

				fixed4 outColor = tex2D(_MainTex, i.texcoord) * i.color;
				outColor.a = (1 - outColor.a) * alpha + outColor.a;

                return outColor; 
			}
			ENDCG
		}
	}
}

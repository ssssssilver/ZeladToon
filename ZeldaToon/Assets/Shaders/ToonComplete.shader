Shader "Custom/ZeldaToon"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Gloss("Gloss", range(1,100)) = 32
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1		
	}
	SubShader
	{
		Pass
		{
			//向前渲染 只接收环境光与直线光照
			Tags{"LightMode" = "ForwardBase" "PassFlags" = "OnlyDirectional"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;	
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Gloss;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);		
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				TRANSFER_SHADOW(o)
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.worldNormal);
				float3 viewDir = normalize(i.viewDir);
				float NdotL = dot(_WorldSpaceLightPos0, normal);
				//获取阴影衰减 0是在阴影中 
				float shadow = SHADOW_ATTENUATION(i);
				//让光暗部分隔开但过渡平滑化
				float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);	
				// 与默认直线光线相乘混合强度
				float4 light = lightIntensity * _LightColor0;

				//------计算高光部分
				// 获取半角向量
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);
				float specularIntensity = pow(NdotH * lightIntensity, _Gloss*_Gloss);
				//让高光过渡部分平滑
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;				
				//-------

				// -------内边缘高光部分
				float rimDot = 1 - dot(viewDir, normal);
				// We only want rim to appear on the lit side of the surface,
				// so multiply it by NdotL, raised to a power to smoothly blend it.
				//让边缘高光只出现在边边处
				float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				//平滑交界处
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;

				float4 col = tex2D(_MainTex, i.uv);

				//float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*_AmbientColor.rgb;

				return (light + _AmbientColor + specular + rim) * _Color * col;
			}
			ENDCG
		}

		// Shadow casting support.
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
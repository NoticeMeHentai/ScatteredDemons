// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TFA/Particles/FogParticles"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_FogParticle("FogParticle", 2D) = "white" {}
		_NoiseDither("NoiseDither", 2D) = "white" {}
		_Holeradius("Hole radius", Range( -0.05 , 0.25)) = 0
		_FogDispersion("FogDispersion", Range( 0 , 0.5)) = 0.4
		_PatternSpeed("PatternSpeed", Vector) = (0.1,0.05,0,0)
		_CurrentAlpha("_CurrentAlpha", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	Category 
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off 
			ZWrite Off
			ZTest LEqual
			
			Pass {
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"
				#include "UnityStandardBRDF.cginc"


				#include "UnityCG.cginc"

				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_OUTPUT_STEREO
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
				};
				
				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform sampler2D_float _CameraDepthTexture;
				uniform float _InvFade;
				uniform sampler2D _FogParticle;
				uniform float4 _FogParticle_ST;
				uniform float2 _PatternSpeed;
				uniform sampler2D _NoiseDither;
				uniform float4 _NoiseDither_TexelSize;
				uniform float _Holeradius;
				uniform float3 _RefLabyrinthPosMain;
				uniform float _FogDispersion;
				uniform float _RefLabyrinthPosSub1Distance;
				uniform float3 _RefLabyrinthPosSub1;
				uniform float _CurrentAlpha;
				inline float DitherNoiseTex( float4 screenPos, sampler2D noiseTexture, float4 noiseTexelSize )
				{
					float dither = tex2Dlod( noiseTexture, float4( screenPos.xy * _ScreenParams.xy * noiseTexelSize.xy, 0, 0 ) ).g;
					float ditherRate = noiseTexelSize.x * noiseTexelSize.y;
					dither = ( 1 - ditherRate ) * dither + ditherRate;
					return dither;
				}
				

				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
					float4 screenPos = ComputeScreenPos(ase_clipPos);
					o.ase_texcoord3 = screenPos;
					float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.ase_texcoord4.xyz = ase_worldPos;
					
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord4.w = 0;

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					float2 uv_FogParticle = i.texcoord.xy * _FogParticle_ST.xy + _FogParticle_ST.zw;
					float4 tex2DNode35 = tex2D( _FogParticle, uv_FogParticle );
					float4 screenPos = i.ase_texcoord3;
					float4 ase_screenPosNorm = screenPos/screenPos.w;
					ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
					float mulTime181 = _Time.y * 0.1;
					float4 appendResult182 = (float4(sin( ( mulTime181 * _PatternSpeed ) ) , 0.0 , 0.0));
					float4 ScreenSpaceOffset186 = ( ase_screenPosNorm + appendResult182 );
					float4 ditherCustomScreenPos29 = ScreenSpaceOffset186;
					float dither29 = DitherNoiseTex( ditherCustomScreenPos29, _NoiseDither, _NoiseDither_TexelSize);
					float3 ase_worldPos = i.ase_texcoord4.xyz;
					float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
					ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
					float3 ViewDir93 = ase_worldViewDir;
					float3 WorldCameraPos94 = _WorldSpaceCameraPos;
					float3 WorldPosPlayer170 = _RefLabyrinthPosMain;
					float3 normalizeResult11 = normalize( ( WorldCameraPos94 - WorldPosPlayer170 ) );
					float dotResult32 = dot( ViewDir93 , normalizeResult11 );
					float smoothstepResult21 = smoothstep( 0.0 , -0.1 , ( _Holeradius - acos( dotResult32 ) ));
					float FogDispersion84 = _FogDispersion;
					float3 WorldPosition95 = ase_worldPos;
					float3 normalizeResult13 = normalize( ( WorldPosPlayer170 - WorldPosition95 ) );
					float dotResult16 = dot( ViewDir93 , normalizeResult13 );
					float smoothstepResult22 = smoothstep( 0.0 , FogDispersion84 , ( acos( dotResult16 ) - ( 0.85 * UNITY_PI ) ));
					dither29 = step( dither29, max( ( 1.0 - ( ( 1.0 - smoothstepResult21 ) * smoothstepResult22 ) ) , step( (WorldPosition95).y , (WorldPosPlayer170).y ) ) );
					float MainTorchMask192 = dither29;
					float4 ditherCustomScreenPos157 = ScreenSpaceOffset186;
					float dither157 = DitherNoiseTex( ditherCustomScreenPos157, _NoiseDither, _NoiseDither_TexelSize);
					float lerpResult159 = lerp( 0.25 , -0.05 , _RefLabyrinthPosSub1Distance);
					float3 normalizeResult131 = normalize( ( WorldCameraPos94 - _RefLabyrinthPosSub1 ) );
					float dotResult133 = dot( ViewDir93 , normalizeResult131 );
					float smoothstepResult143 = smoothstep( 0.0 , -0.1 , ( lerpResult159 - acos( dotResult133 ) ));
					float3 normalizeResult134 = normalize( ( _RefLabyrinthPosSub1 - WorldPosition95 ) );
					float dotResult137 = dot( ViewDir93 , normalizeResult134 );
					float smoothstepResult145 = smoothstep( 0.0 , FogDispersion84 , ( acos( dotResult137 ) - ( 0.85 * UNITY_PI ) ));
					dither157 = step( dither157, max( ( 1.0 - ( ( 1.0 - smoothstepResult143 ) * smoothstepResult145 ) ) , step( (WorldPosition95).y , _RefLabyrinthPosSub1.y ) ) );
					float SubTorch1193 = dither157;
					float ParticleMask194 = tex2DNode35.a;
					float FinalMask199 = ( MainTorchMask192 * SubTorch1193 * ParticleMask194 * _CurrentAlpha );
					float4 appendResult34 = (float4(tex2DNode35.r , tex2DNode35.g , tex2DNode35.b , FinalMask199));
					

					fixed4 col = appendResult34;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG 
			}
		}	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=15700
287;103;1224;635;1384.505;236.9426;3.213851;True;False
Node;AmplifyShaderEditor.CommentaryNode;87;-7108.791,-408.2002;Float;False;506.0244;949.7378;;11;84;94;95;91;50;93;90;89;177;181;184;Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;35;-1328.181,731.9092;Float;True;Property;_FogParticle;FogParticle;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;128;-5181.866,1264.317;Float;False;2400.289;1452.679;;27;156;155;154;153;152;150;149;148;147;146;145;144;143;142;140;139;138;137;136;135;134;133;132;131;130;129;159;SubTorch1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-5243.557,-698.7556;Float;False;2400.289;1452.679;;27;12;13;10;11;32;33;15;17;21;23;24;26;28;16;18;19;20;22;25;27;85;122;123;124;125;126;167;MainTorch;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-964.6316,852.269;Float;False;199;FinalMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;136.7977,325.1827;Float;False;192;MainTorchMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-2037.71,1310.063;Float;False;SubTorch1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-2566.463,1458.501;Float;False;186;ScreenSpaceOffset;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-677.5988,-1024.526;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;500.0198,408.0225;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;123.184,481.9183;Float;False;194;ParticleMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-549.5038,871.3939;Float;False;104;Debug;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;91;-7083.299,-363.4934;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-662.1517,-538.5091;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;187;-2224.011,174.0889;Float;False;186;ScreenSpaceOffset;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;7;-885.5988,-720.5257;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;719.7057,431.8693;Float;False;FinalMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;148;-4130.867,1910.037;Float;True;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-678.9252,739.2529;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;177;-7028.069,246.3672;Float;False;Property;_PatternSpeed;PatternSpeed;4;0;Create;True;0;0;False;0;0.1,0.05;0.1,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-1590.888,143.2468;Float;False;MainTorchMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;27;-3344.203,-174.5632;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;149;-3476.604,1586.012;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;29;-1931.818,128.2137;Float;False;2;True;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;140.7469,406.7529;Float;False;193;SubTorch1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-6891.086,-363.0385;Float;False;ViewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;191;-6625.625,197.5587;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DitheringNode;157;-2309.664,1314.964;Float;False;2;True;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-3302.556,-483.9301;Float;True;Property;_NoiseDither;NoiseDither;1;0;Create;True;0;0;False;0;670db8c4dd6f5ae49b479749ed4493ab;670db8c4dd6f5ae49b479749ed4493ab;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector3Node;8;-6823.774,701.5793;Float;False;Global;_RefLabyrinthPosMain;_RefLabyrinthPosMain;6;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;163;-6417.865,767.0969;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-7098.416,80.81253;Float;False;Property;_FogDispersion;FogDispersion;3;0;Create;True;0;0;False;0;0.4;0.4;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;181;-7032.974,171.0431;Float;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;90;-7096.729,-224.9458;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-6847.086,-228.0385;Float;False;WorldCameraPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-6815.746,193.4898;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;216;170.5123,571.7968;Float;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;165;-6955.963,874.9313;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-6116.109,155.9819;Float;False;ScreenSpaceOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;183;-6455.953,-7.991058;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;169;-6750.994,876.1492;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-3538.296,-377.0603;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;133;-4493.664,1870.367;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;166;-6605.437,859.7057;Float;False;FLOAT3;4;0;FLOAT;0.1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-6881.086,-89.03851;Float;False;WorldPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;89;-7095.161,-77.21667;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;180;-6232.021,133.9034;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-6225.52,761.2424;Float;False;WorldPosPlayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;-6433.194,171.768;Float;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-4351.995,2378.075;Float;False;93;ViewDir;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-6820.345,87.39435;Float;False;FogDispersion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1566.277,-436.7439;Float;False;Debug;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1041.168,919.5883;Float;False;ParticleMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-4565.908,2513.524;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;12;-4627.599,550.4512;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ACosOpNode;33;-4369.831,-122.8897;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;16;-4145.575,430.4728;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;135;-4308.14,1840.183;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-4735.862,1588.399;Float;False;Global;_RefLabyrinthPosSub1Distance;_RefLabyrinthPosSub1Distance;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;32;-4555.355,-92.7049;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;134;-4298.564,2507.797;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;146;-3833.606,1567.273;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-5102.924,2150.467;Float;False;94;WorldCameraPos;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-5069.128,2521.614;Float;False;95;WorldPosition;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;13;-4360.255,544.7242;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-5159.591,12.80264;Float;False;94;WorldCameraPos;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;129;-5101.387,2258.406;Float;False;Global;_RefLabyrinthPosSub1;_RefLabyrinthPosSub1;6;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;152;-4825.933,1803.365;Float;False;93;ViewDir;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;131;-4645.173,1973.697;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-4887.624,-159.707;Float;False;93;ViewDir;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-5272.044,307.8847;Float;False;170;WorldPosPlayer;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;130;-4807.953,2010.448;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-5189.646,587.8493;Float;False;95;WorldPosition;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-4852.221,81.16801;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-4586.523,-374.3324;Float;False;Property;_Holeradius;Hole radius;2;0;Create;True;0;0;False;0;0;0;-0.05;0.25;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-3895.298,-395.799;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;11;-4706.864,10.6245;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-3784.627,2561.579;Float;False;84;FogDispersion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;126;-4796.981,324.4397;Float;False;False;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;167;-4850.209,183.9076;Float;False;False;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3721.588,-385.1188;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-3828.849,461.0885;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;145;-3512.648,2482.988;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-3659.896,1577.953;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-4509.885,425.4028;Float;False;93;ViewDir;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;150;-3273.127,1725.167;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;139;-3928.699,2372.699;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;156;-4819.784,2399.312;Float;False;False;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;25;-4203.558,87.96494;Float;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;18;-4064.889,511.0191;Float;False;1;0;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;159;-4383.919,1541.313;Float;False;3;0;FLOAT;0.25;False;1;FLOAT;-0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-3846.319,586.5059;Float;False;84;FogDispersion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ACosOpNode;19;-3989.391,430.6268;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;144;-3767.157,2424.161;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;137;-4084.884,2372.545;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;138;-3985.197,2492.092;Float;False;1;0;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;140;-4186.85,1592.022;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;22;-3574.34,519.9157;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-4248.541,-371.0504;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-4072.191,-400.3495;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;143;-4010.499,1562.723;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;215;131.4457,661.7707;Float;False;Property;_CurrentAlpha;_CurrentAlpha;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;-411.8666,747.2348;Float;False;True;2;Float;ASEMaterialInspector;0;6;TFA/Particles/FogParticles;0b6a9f8b4f707c74ca64c0be8e590de0;0;0;SubShader 0 Pass 0;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;True;2;False;-1;True;True;True;True;False;0;False;-1;False;True;2;False;-1;True;3;False;-1;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;0;False;False;False;False;False;False;False;False;False;True;0;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;193;0;157;0
WireConnection;195;0;196;0
WireConnection;195;1;197;0
WireConnection;195;2;198;0
WireConnection;195;3;215;0
WireConnection;199;0;195;0
WireConnection;148;0;156;0
WireConnection;148;1;129;2
WireConnection;34;0;35;1
WireConnection;34;1;35;2
WireConnection;34;2;35;3
WireConnection;34;3;200;0
WireConnection;192;0;29;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;149;0;147;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;29;2;187;0
WireConnection;93;0;91;0
WireConnection;191;0;184;0
WireConnection;157;0;150;0
WireConnection;157;1;28;0
WireConnection;157;2;188;0
WireConnection;163;0;8;0
WireConnection;163;1;166;0
WireConnection;94;0;90;0
WireConnection;184;0;181;0
WireConnection;184;1;177;0
WireConnection;186;0;180;0
WireConnection;169;0;165;0
WireConnection;26;0;24;0
WireConnection;133;0;152;0
WireConnection;133;1;131;0
WireConnection;166;2;169;0
WireConnection;95;0;89;0
WireConnection;180;0;183;0
WireConnection;180;1;182;0
WireConnection;170;0;8;0
WireConnection;182;0;191;0
WireConnection;84;0;50;0
WireConnection;104;0;29;0
WireConnection;194;0;35;4
WireConnection;132;0;129;0
WireConnection;132;1;155;0
WireConnection;12;0;171;0
WireConnection;12;1;125;0
WireConnection;33;0;32;0
WireConnection;16;0;123;0
WireConnection;16;1;13;0
WireConnection;135;0;133;0
WireConnection;32;0;122;0
WireConnection;32;1;11;0
WireConnection;134;0;132;0
WireConnection;146;0;143;0
WireConnection;13;0;12;0
WireConnection;131;0;130;0
WireConnection;130;0;154;0
WireConnection;130;1;129;0
WireConnection;10;0;124;0
WireConnection;10;1;171;0
WireConnection;23;0;21;0
WireConnection;11;0;10;0
WireConnection;126;0;125;0
WireConnection;167;0;171;0
WireConnection;24;0;23;0
WireConnection;24;1;22;0
WireConnection;20;0;19;0
WireConnection;20;1;18;0
WireConnection;145;0;144;0
WireConnection;145;2;142;0
WireConnection;147;0;146;0
WireConnection;147;1;145;0
WireConnection;150;0;149;0
WireConnection;150;1;148;0
WireConnection;139;0;137;0
WireConnection;156;0;155;0
WireConnection;25;0;126;0
WireConnection;25;1;167;0
WireConnection;159;2;136;0
WireConnection;19;0;16;0
WireConnection;144;0;139;0
WireConnection;144;1;138;0
WireConnection;137;0;153;0
WireConnection;137;1;134;0
WireConnection;140;0;159;0
WireConnection;140;1;135;0
WireConnection;22;0;20;0
WireConnection;22;2;85;0
WireConnection;17;0;15;0
WireConnection;17;1;33;0
WireConnection;21;0;17;0
WireConnection;143;0;140;0
WireConnection;43;0;34;0
ASEEND*/
//CHKSM=142DCBD90E62347139921EF300B7E9D62B4C5DC2
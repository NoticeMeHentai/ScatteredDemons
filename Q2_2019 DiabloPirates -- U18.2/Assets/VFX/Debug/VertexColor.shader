// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Debug/VertexColor"
{
	Properties
	{
		[Toggle]_R_Channel("R_Channel", Float) = 0
		[Toggle]_G_Channel("G_Channel", Float) = 0
		[Toggle]_B_Channel("B_Channel", Float) = 0
		[Toggle]_A_Channel("A_Channel", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 vertexColor : COLOR;
		};

		uniform float _R_Channel;
		uniform float _G_Channel;
		uniform float _B_Channel;
		uniform float _A_Channel;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 appendResult6 = (float4(lerp(0.0,i.vertexColor.r,_R_Channel) , lerp(0.0,i.vertexColor.g,_G_Channel) , lerp(0.0,i.vertexColor.b,_B_Channel) , lerp(0.0,i.vertexColor.a,_A_Channel)));
			o.Emission = appendResult6.xyz;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15700
0;45;482;278;1045.804;-13.59659;1.249777;True;False
Node;AmplifyShaderEditor.RangedFloatNode;3;-943.0733,-125.286;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;1;-1044.137,16.54489;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;9;-690.6864,157.3802;Float;False;Property;_B_Channel;B_Channel;2;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;11;-698.3663,305.4196;Float;False;Property;_A_Channel;A_Channel;3;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;7;-688.1236,-115.734;Float;False;Property;_R_Channel;R_Channel;0;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;8;-704.1778,32.58737;Float;False;Property;_G_Channel;G_Channel;1;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-366.6776,105.6945;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Hidden/Debug/VertexColor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;3;0
WireConnection;9;1;1;3
WireConnection;11;0;3;0
WireConnection;11;1;1;4
WireConnection;7;0;3;0
WireConnection;7;1;1;1
WireConnection;8;0;3;0
WireConnection;8;1;1;2
WireConnection;6;0;7;0
WireConnection;6;1;8;0
WireConnection;6;2;9;0
WireConnection;6;3;11;0
WireConnection;0;2;6;0
ASEEND*/
//CHKSM=16189EB29E6AF54DFA044E3E2B053C19F1E85E19
Includes = {
	"cw/camera.fxh"
	"jomini/jomini_flat_border.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_fog_of_war.fxh"
	"standardfuncsgfx.fxh"
}

VertexStruct VS_OUTPUT_PDX_BORDER
{
	float4 Position : PDX_POSITION;
	float3 WorldSpacePos : TEXCOORD0;
	float2 UV : TEXCOORD1;
};


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_BORDER"
		Output = "VS_OUTPUT_PDX_BORDER"
		Code
		[[			
			PDX_MAIN
			{
				VS_OUTPUT_PDX_BORDER Out;
				
				float3 position = Input.Position;
				position.y = lerp( position.y, FlatMapHeight, FlatMapLerp );
				position.y += _HeightOffset;
				
				Out.WorldSpacePos = position;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( position, 1.0 ) );
				Out.UV = Input.UV;
			
				return Out;
			}
		]]
	}
}


PixelShader =
{	
	TextureSampler BorderTexture
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	
	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( BorderTexture, Input.UV );
				
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.a *= _Alpha;
				
				return Diffuse;
			}
		]]
	}
	
	MainCode PixelShaderWar
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( BorderTexture, Input.UV );
				
				float vPulseFactor = saturate( smoothstep( 0.0f, 1.0f, 0.4f + sin( GlobalTime * 2.5f ) * 0.25f ) );
				Diffuse.rgb = saturate( Diffuse.rgb * vPulseFactor );
				
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.a *= _Alpha;
				
				return Diffuse;
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	# MOD(map-skybox)
	DepthBias = -20000
	SlopeScaleDepthBias = 0
	# END MOD
}

DepthStencilState DepthStencilState
{
	# MOD(map-skybox)
	DepthEnable = yes
	DepthWriteEnable = no
	# END MOD
	StencilEnable = yes
	# MOD(map-skybox)
	FrontStencilFunc = greater_equal
	# END MOD
	StencilRef = 1
}


Effect PdxBorder
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect PdxBorderWar
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderWar"
}

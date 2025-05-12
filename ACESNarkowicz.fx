// Reshade port of luminance ACES curve by Krzysztof Narkowicz.
// Base code sourced from Krzysztof Narkowicz's blog at https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
// by Jace Regenbrecht

uniform float ACESN_A <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 5.00;
	ui_label = "A value";
> = 2.51;

uniform float ACESN_B <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "B value";
> = 0.03;

uniform float ACESN_C <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 5.00;
	ui_label = "C value";
> = 2.43;

uniform float ACESN_D <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "D value";
> = 0.59;

uniform float ACESN_E <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 1.00;
	ui_label = "E value";
> = 0.14;

uniform float ACESN_Exp <
	ui_type = "drag";
	ui_min = 1.00; ui_max = 20.00;
	ui_label = "Exposure";
> = 1.0;

uniform float ACESN_Gamma <
	ui_type = "drag";
	ui_min = 1.00; ui_max = 3.00;
	ui_label = "Gamma value";
	ui_tooltip = "Most monitors/images use a value of 2.2. Setting this to 1 disables the pre-tonemapping degamma of the game image, causing a washed out effect.";
> = 2.2;

uniform bool IsScRGB <
    ui_type = "checkbox";
    ui_label = "Use scRGB";
    ui_tooltip = "Enable this if the input is in scRGB (linear color space).";
> = false;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "ReShade.fxh"

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float3 ConvertToLinear(float3 color)
{
    // Convert sRGB to linear
    return pow(color, float3(2.2, 2.2, 2.2));
}

float3 ConvertToSRGB(float3 color)
{
    // Convert linear to sRGB
    return pow(color, float3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2));
}

float3 aces_main_nark(float4 pos : SV_Position, float2 texcoord : TexCoord ) : COLOR
{
    float3 texColor = tex2D(ReShade::BackBuffer, texcoord ).rgb;

    // Convert to linear color space if input is sRGB
    if (!IsScRGB)
    {
        texColor = ConvertToLinear(texColor);
    }

    // Apply exposure adjustment
    texColor *= ACESN_Exp;

    // ACES tone mapping
    texColor = saturate((texColor * (ACESN_A * texColor + ACESN_B)) / (texColor * (ACESN_C * texColor + ACESN_D) + ACESN_E));

    // Convert back to sRGB if needed
    if (!IsScRGB)
    {
        texColor = ConvertToSRGB(texColor);
    }

    return texColor;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


technique ACESNarkowicz
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = aces_main_nark;
	}
}

// Reshade port of luminance ACES curve by Krzysztof Narkowicz.
// Modified to support scRGB, sRGB, and HDR10 PQ.

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

uniform float MaxLuminance <
    ui_type = "drag";
    ui_min = 100.0; ui_max = 10000.0;
    ui_label = "Max Luminance (nits)";
    ui_tooltip = "Maximum display luminance for HDR10.";
> = 1000.0;

uniform int ColorSpace <
    ui_type = "combo";
    ui_label = "Input Color Space";
    ui_items = "sRGB\0scRGB\0HDR10 PQ\0";
> = 0; // 0 = sRGB, 1 = scRGB, 2 = HDR10 PQ

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "ReShade.fxh"

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Constants for PQ (ST 2084) transfer function
static const float m1 = 0.1593017578125; // (2610 / 4096) / 4
static const float m2 = 78.84375;        // (2523 / 4096) * 128
static const float c1 = 0.8359375;       // 3424 / 4096
static const float c2 = 18.8515625;      // (2413 / 4096) * 32
static const float c3 = 18.6875;         // (2392 / 4096) * 32

// Convert PQ-encoded value to linear luminance
float3 PQToLinear(float3 color)
{
    float3 Y = pow(max(color, 0.0), 1.0 / m2);
    return pow(max((Y - c1) / (c2 - c3 * Y), 0.0), 1.0 / m1) * MaxLuminance;
}

// Convert linear luminance to PQ-encoded value
float3 LinearToPQ(float3 color)
{
    float3 Y = pow(color / MaxLuminance, m1);
    return pow((c1 + c2 * Y) / (1.0 + c3 * Y), m2);
}

// Convert sRGB to linear
float3 ConvertToLinear(float3 color)
{
    return pow(color, float3(2.2, 2.2, 2.2));
}

// Convert linear to sRGB
float3 ConvertToSRGB(float3 color)
{
    return pow(color, float3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2));
}

float3 aces_main_nark(float4 pos : SV_Position, float2 texcoord : TexCoord) : COLOR
{
    float3 texColor = tex2D(ReShade::BackBuffer, texcoord).rgb;

    // Handle input color space
    if (ColorSpace == 0) // sRGB
    {
        texColor = ConvertToLinear(texColor);
    }
    else if (ColorSpace == 2) // HDR10 PQ
    {
        texColor = PQToLinear(texColor);
    }

    // Apply exposure adjustment
    texColor *= ACESN_Exp;

    // ACES tone mapping
    texColor = saturate((texColor * (ACESN_A * texColor + ACESN_B)) / (texColor * (ACESN_C * texColor + ACESN_D) + ACESN_E));

    // Handle output color space
    if (ColorSpace == 0) // sRGB
    {
        texColor = ConvertToSRGB(texColor);
    }
    else if (ColorSpace == 2) // HDR10 PQ
    {
        texColor = LinearToPQ(texColor);
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

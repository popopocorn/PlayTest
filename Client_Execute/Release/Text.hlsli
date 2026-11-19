Texture2D<float4> gFontAtlas : register(t6);
SamplerState gFontSampler : register(s1);

struct VS_TEXT_INPUT
{
    float2 position : POSITION;
    float2 uv : TEXCOORD;
    float4 color : COLOR;
};

struct VS_TEXT_OUTPUT
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD;
    float4 color : COLOR;
};

VS_TEXT_OUTPUT VSText(VS_TEXT_INPUT input)
{
    VS_TEXT_OUTPUT output;

    output.position = float4(input.position, 0.0f, 1.0f);
    output.uv = input.uv;
    output.color = input.color;

    return output;
}

float4 PSText(VS_TEXT_OUTPUT input) : SV_TARGET
{
    float coverage = gFontAtlas.Sample(gFontSampler, input.uv).r;

    clip(coverage - 0.001f);

    float4 outputColor = input.color;
    outputColor.a *= coverage;

    return outputColor;
}
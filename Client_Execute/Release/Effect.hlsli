#ifndef EFFECT_HLSLI
#define EFFECT_HLSLI

#include "common.hlsli"

struct VS_EFFECT_INPUT
{
    float3 position : POSITION;
    float2 uv : TEXCOORD0;

    float3 instPosition : INST_POSITION;
    float instProgress : INST_PROGRESS;
    float2 instSize : INST_SIZE;
    float3 instRight : INST_RIGHT;
    float3 instUp : INST_UP;
    float4 instColor : INST_COLOR;
};

struct VS_EFFECT_OUTPUT
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
    float2 localUV : TEXCOORD1;
    float progress : TEXCOORD2;
    float4 effectColor : COLOR0;
};

VS_EFFECT_OUTPUT VSEffect(VS_EFFECT_INPUT input)
{
    VS_EFFECT_OUTPUT output;

    float3 centerW = input.instPosition;
    float progress = input.instProgress;

    float3 vRight = normalize(input.instRight);
    float3 vUp = normalize(input.instUp);

    float3 posW = centerW
                + (input.position.x * input.instSize.x * vRight)
                + (input.position.y * input.instSize.y * vUp);

    output.position = mul(mul(float4(posW, 1), gmtxView), gmtxProjection);

    int numCols = 7;
    int numRows = 6;
    int totalFrames = numCols * numRows;

    int currentFrame = clamp((int) (progress * totalFrames), 0, totalFrames - 1);

    int col = currentFrame % numCols;
    int row = currentFrame / numCols;

    float uvWidth = 1.0f / numCols;
    float uvHeight = 1.0f / numRows;

    float cropX = uvWidth * 0.05f;
    float cropY = uvHeight * 0.05f;

    float minU = (col * uvWidth) + cropX;
    float maxU = ((col + 1) * uvWidth) - cropX;

    float minV = (row * uvHeight) + cropY;
    float maxV = ((row + 1) * uvHeight) - cropY;

    output.uv = float2(
        lerp(minU, maxU, input.uv.x),
        lerp(minV, maxV, input.uv.y)
    );

    output.localUV = input.uv;
    output.progress = progress;
    output.effectColor = input.instColor;

    return output;
}

float4 PSEffect(VS_EFFECT_OUTPUT input) : SV_TARGET
{
    float4 color = gtxtAlbedoTexture.Sample(gssClamp, input.uv);

    float brightness = max(color.r, max(color.g, color.b));

    if (brightness < 0.035f)
        discard;

    float alpha = saturate((brightness - 0.035f) / 0.24f);
    alpha = pow(alpha, 0.85f);

    float3 tint = input.effectColor.rgb;
    float brightnessScale = input.effectColor.a;

    color.rgb = pow(saturate(color.rgb), 0.75f);
    color.rgb *= tint;
    color.rgb *= 2.7f * brightnessScale;

    float3 maxColor;
    maxColor.r = 1.0f * brightnessScale;
    maxColor.g = min(0.95f, max(0.72f, tint.g * 1.24f)) * brightnessScale;
    maxColor.b = min(0.80f, max(0.36f, tint.b * 1.80f)) * brightnessScale;

    color.rgb = min(color.rgb, maxColor);
    color.a = alpha;

    float tailFade = smoothstep(1.0f, 0.68f, input.progress);
    color.a *= tailFade;

    return color;
}

#endif
//debug.hlsli
#include "common.hlsli"

struct VS_DEBUG_INPUT
{
    float3 position : POSITION;
};

struct VS_DEBUG_OUTPUT
{
    float4 position : SV_POSITION;
};

VS_DEBUG_OUTPUT VSDebug(VS_DEBUG_INPUT input)
{
    VS_DEBUG_OUTPUT output;
    float4 positionW = mul(float4(input.position, 1.0f), gmtxGameObject);
    float4 positionV = mul(positionW, gmtxView);
    output.position = mul(positionV, gmtxProjection);
    return output;
}

float4 PSDebug(VS_DEBUG_OUTPUT input) : SV_TARGET
{
    return float4(0.0f, 1.0f, 0.0f, 1.0f);
}

float4 PSLootBox(VS_DEBUG_OUTPUT input) : SV_TARGET
{
    return float4(0.1f, 0.35f, 1.0f, 1.0f);
}
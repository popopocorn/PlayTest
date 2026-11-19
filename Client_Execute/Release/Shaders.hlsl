#ifndef SHADERS_HLSL
#define SHADERS_HLSL

#include "common.hlsli"
#include "light.hlsli"

// VS / PS entry points


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//#define _WITH_VERTEX_LIGHTING


VS_STANDARD_OUTPUT VSStandard(VS_STANDARD_INPUT input)
{
	VS_STANDARD_OUTPUT output;

	output.positionW = mul(float4(input.position, 1.0f), gmtxGameObject).xyz;
	output.normalW = mul(input.normal, (float3x3)gmtxGameObject);
	output.tangentW = mul(input.tangent, (float3x3)gmtxGameObject);
	output.bitangentW = mul(input.bitangent, (float3x3)gmtxGameObject);
	output.position = mul(mul(float4(output.positionW, 1.0f), gmtxView), gmtxProjection);
	output.uv = input.uv;

	return(output);
}

VS_VIEW_OUTPUT VSView(VS_VIEW_INPUT input)
{
    VS_VIEW_OUTPUT output;

    float4 positionW = mul(float4(input.position, 1.0f), gmtxGameObject);
    output.position = mul(mul(positionW, gmtxView), gmtxProjection);

    return output;
}


PS_GBUFFER_OUTPUT PSStandard(VS_STANDARD_OUTPUT input) : SV_Target
{
    PS_GBUFFER_OUTPUT output;
    
    float4 cAlbedoColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
    if (gnTexturesMask & MATERIAL_ALBEDO_MAP)
        cAlbedoColor = gtxtAlbedoTexture.Sample(gssWrap, input.uv);

    float4 cSpecularColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    if (gnTexturesMask & MATERIAL_SPECULAR_MAP)
        cSpecularColor = gtxtSpecularTexture.Sample(gssWrap, input.uv);

    float4 cNormalColor = float4(0.5f, 0.5f, 1.0f, 1.0f);
    if (gnTexturesMask & MATERIAL_NORMAL_MAP)
        cNormalColor = gtxtNormalTexture.Sample(gssWrap, input.uv);

    float4 cMetallicColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    if (gnTexturesMask & MATERIAL_METALLIC_MAP)
        cMetallicColor = gtxtMetallicTexture.Sample(gssWrap, input.uv);

    float4 cEmissionColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    if (gnTexturesMask & MATERIAL_EMISSION_MAP)
        cEmissionColor = gtxtEmissionTexture.Sample(gssWrap, input.uv);

    float3 normalW = normalize(input.normalW);

    if (gnTexturesMask & MATERIAL_NORMAL_MAP)
    {
        float3 tangentW = normalize(input.tangentW);
        float3 bitangentW = normalize(input.bitangentW);
        float3 normalT = normalize(cNormalColor.xyz * 2.0f - 1.0f);

        normalW = normalize(normalT.x * tangentW + normalT.y * bitangentW + normalT.z * normalW);
    }

    float specStrength = dot(cSpecularColor.rgb, float3(0.333f, 0.333f, 0.333f));
    float metalStrength = dot(cMetallicColor.rgb, float3(0.333f, 0.333f, 0.333f));
    
    output.Color = cAlbedoColor;
    output.Normal = float4(normalW * 0.5f + 0.5f, 1.0f);
    
    float emissiveStrength = dot(cEmissionColor.rgb, float3(0.333f, 0.333f, 0.333f));
    output.Material = float4(specStrength, metalStrength, emissiveStrength,
                         saturate(gMaterial.m_cSpecular.a / 256.0f));
    return output;
}

VS_STANDARD_OUTPUT VSSkinnedAnimationStandard(VS_SKINNED_STANDARD_INPUT input)
{
	VS_STANDARD_OUTPUT output;

	float4x4 mtxVertexToBoneWorld = (float4x4)0.0f;
	for (int i = 0; i < MAX_VERTEX_INFLUENCES; i++)
	{
//		mtxVertexToBoneWorld += input.weights[i] * gpmtxBoneTransforms[input.indices[i]];
		mtxVertexToBoneWorld += input.weights[i] * mul(gpmtxBoneOffsets[input.indices[i]], gpmtxBoneTransforms[input.indices[i]]);
	}
	output.positionW = mul(float4(input.position, 1.0f), mtxVertexToBoneWorld).xyz;
	output.normalW = mul(input.normal, (float3x3)mtxVertexToBoneWorld).xyz;
	output.tangentW = mul(input.tangent, (float3x3)mtxVertexToBoneWorld).xyz;
	output.bitangentW = mul(input.bitangent, (float3x3)mtxVertexToBoneWorld).xyz;

//	output.positionW = mul(float4(input.position, 1.0f), gmtxGameObject).xyz;

	output.position = mul(mul(float4(output.positionW, 1.0f), gmtxView), gmtxProjection);
	output.uv = input.uv;

	return(output);
}

float4 PSView(VS_VIEW_OUTPUT input) : SV_TARGET
{
    return float4(0.0f, 0.0f, 0.0f, 0.0f);
}

VS_UI_OUTPUT VSUI(VS_UI_INPUT input)
{
    VS_UI_OUTPUT output;
    output.position = mul(float4(input.position, 1.0f), gmtxGameObject);
    output.uv = input.uv;
    
    return output;
}

float4 PSUI(VS_UI_OUTPUT input) : SV_Target
{
    float4 cAlbedoColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    
    cAlbedoColor = gtxtAlbedoTexture.Sample(gssWrap, input.uv);
    
    return cAlbedoColor;
}

// 안개 오버레이용 셰이더
struct VS_FOG_OVERLAY_OUTPUT
{
    float4 position : SV_POSITION;
};

VS_FOG_OVERLAY_OUTPUT VSFogOverlay(uint nVertexID : SV_VertexID)
{
    VS_FOG_OVERLAY_OUTPUT output;

    float2 positions[3] =
    {
        float2(-1.0f, -1.0f),
        float2(-1.0f, 3.0f),
        float2(3.0f, -1.0f)
    };

    output.position = float4(positions[nVertexID], 0.0f, 1.0f);
    return output;
}

float4 PSFogOverlay(VS_FOG_OVERLAY_OUTPUT input) : SV_TARGET
{
    return float4(0.0f, 0.0f, 0.0f, 0.5f);
}

VS_SKYBOX_CUBEMAP_OUTPUT VSSkyBox(VS_SKYBOX_CUBEMAP_INPUT input)
{
	VS_SKYBOX_CUBEMAP_OUTPUT output;

	output.position = mul(mul(mul(float4(input.position, 1.0f), gmtxGameObject), gmtxView), gmtxProjection);
	output.positionL = input.position;

	return(output);
}

float4 PSSkyBox(VS_SKYBOX_CUBEMAP_OUTPUT input) : SV_TARGET
{
	float4 cColor = gtxtSkyCubeTexture.Sample(gssClamp, input.positionL);

	return(cColor);
}

float4 PSLaser(VS_STANDARD_OUTPUT input) : SV_TARGET
{
    return float4(1.0f, 0.0f, 0.0f, 1.0f);
}

float4 PSThroughPlayer(VS_STANDARD_OUTPUT input) : SV_TARGET
{
    float4 c = float4(1.0f, 0.9f, 0.2f, 0.35f);

    float3 normalW = normalize(input.normalW);
    float ndl = saturate(dot(normalW, normalize(float3(0.3f, 0.8f, 0.2f))));
    c.rgb *= lerp(0.8f, 1.1f, ndl);

    return c;
}
VS_UI_OUTPUT VSFullScreen(VS_UI_INPUT input)
{
    VS_UI_OUTPUT output;
    output.position = float4(input.position, 1.0f);
    output.uv = input.uv;
    return output;
}
float4 PSFullScreen(VS_UI_OUTPUT input) :SV_Target
{
    float4 cAlbedoColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    
    cAlbedoColor = FullScreenTexture.Sample(gssWrap, input.uv);
    
    return cAlbedoColor;
}

float4 PSLighting(VS_UI_OUTPUT input):SV_Target
{
    float4 albedoSample = ColorTexture.Sample(gssWrap, input.uv);
    float4 normalSample = NormalTexture.Sample(gssWrap, input.uv);
    float4 materialSample = MaterialTexture.Sample(gssWrap, input.uv);

    // 깊이는 보간하면 안 되므로 픽셀 단위 Load
    float depth = DepthTexture.Load(int3(input.position.xy, 0)).r;
    bool bBackground = (depth >= 1.0f);   // 지오메트리 없음 (클리어 값 1.0)
    float3 positionW = ReconstructWorldPosition(input.uv, depth);

    if (bBackground)
        return float4(albedoSample.rgb, 1.0f);
    
    GBufferSurface s;
    s.positionW = positionW;
    s.normalW = normalize(normalSample.xyz * 2.0f - 1.0f);
    s.albedo = albedoSample.rgb;
    s.specStrength = materialSample.r;
    s.shininess = max(materialSample.a * 256.0f, 8.0f); 

    float emissiveStrength = materialSample.b;

    float viewDepth = mul(float4(positionW, 1.0f), gmtxView).z;
    float shadow = CalcShadowFactor(positionW, viewDepth);

    
    float3 finalColor = DeferredLighting(s, shadow);

    
    finalColor += s.albedo * emissiveStrength * 0.08f;

    
    finalColor = finalColor / (finalColor + float3(0.65f, 0.65f, 0.65f));
    finalColor *= 1.25f;

    return float4(saturate(finalColor), 1.0f);
}

#endif // SHADERS_HLSL
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

//수정 전 셰이더(플레이어 모델 색깔 이상)
//float4 PSStandard(VS_STANDARD_OUTPUT input) : SV_TARGET
//{
//    float4 cAlbedoColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
//    if (gnTexturesMask & MATERIAL_ALBEDO_MAP)
//        cAlbedoColor = gtxtAlbedoTexture.Sample(gssWrap, input.uv);

//    float4 cSpecularColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
//    if (gnTexturesMask & MATERIAL_SPECULAR_MAP)
//        cSpecularColor = gtxtSpecularTexture.Sample(gssWrap, input.uv);

//    float4 cNormalColor = float4(0.5f, 0.5f, 1.0f, 1.0f);
//    if (gnTexturesMask & MATERIAL_NORMAL_MAP)
//        cNormalColor = gtxtNormalTexture.Sample(gssWrap, input.uv);

//    float4 cMetallicColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
//    if (gnTexturesMask & MATERIAL_METALLIC_MAP)
//        cMetallicColor = gtxtMetallicTexture.Sample(gssWrap, input.uv);

//    float4 cEmissionColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
//    if (gnTexturesMask & MATERIAL_EMISSION_MAP)
//        cEmissionColor = gtxtEmissionTexture.Sample(gssWrap, input.uv);

//    float3 normalW = normalize(input.normalW);

//    if (gnTexturesMask & MATERIAL_NORMAL_MAP)
//    {
//        float3 tangentW = normalize(input.tangentW);
//        float3 bitangentW = normalize(input.bitangentW);
//        float3 normalT = normalize(cNormalColor.xyz * 2.0f - 1.0f);

//        normalW = normalize(
//            normalT.x * tangentW +
//            normalT.y * bitangentW +
//            normalT.z * normalW
//        );
//    }

//    /*
//    float4 posView = mul(float4(input.positionW, 1.0f), gmtxView);
//    float viewDepth = posView.z;
//    float shadowFactor = CalcShadowFactor(input.positionW, viewDepth);

//    float3 lightColor = max(Lighting(input.positionW, normalW, gvCameraPosition).rgb, 0.0f);

//    float softenedShadow = lerp(0.45f, 1.0f, shadowFactor);

//    float3 ambient = float3(0.035f, 0.04f, 0.04f);

//    float3 lightingTerm = ambient + (lightColor * softenedShadow * 0.75f);

//    float luminance = dot(cAlbedoColor.rgb, float3(0.299f, 0.587f, 0.114f));
//    float darkBoost = lerp(1.95f, 1.00f, smoothstep(0.08f, 0.42f, luminance));

//    float3 finalColor = cAlbedoColor.rgb * lightingTerm * darkBoost;

//    float specStrength = dot(cSpecularColor.rgb, float3(0.333f, 0.333f, 0.333f));
//    float metalStrength = dot(cMetallicColor.rgb, float3(0.333f, 0.333f, 0.333f));

//    float highlightStrength = saturate(specStrength * 0.12f + metalStrength * 0.08f);
//    finalColor += lightColor * softenedShadow * highlightStrength;

//    finalColor += cEmissionColor.rgb * 0.08f;

//    return float4(saturate(finalColor), cAlbedoColor.a);//*/
    
    
//    ///* 
//    float4 cColor = cAlbedoColor + cSpecularColor + cMetallicColor + cEmissionColor;


//    float4 posView = mul(float4(input.positionW, 1.0f), gmtxView);
//    float viewDepth = posView.z;


//    float shadowFactor = CalcShadowFactor(input.positionW, viewDepth);

//    float4 cIllumination = Lighting(input.positionW, normalW, gvCameraPosition);

//    cIllumination.rgb *= shadowFactor;

//    return lerp(cColor, cIllumination, 0.5f);
//    //*/
//}


float4 PSStandard(VS_STANDARD_OUTPUT input) : SV_TARGET
{
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

    float4 posView = mul(float4(input.positionW, 1.0f), gmtxView);
    float viewDepth = posView.z;

    float shadowFactor = CalcShadowFactor(input.positionW, viewDepth);

    float softenedShadow = lerp(0.45f, 1.0f, shadowFactor);

    float3 lightColor = Lighting(input.positionW, normalW, gvCameraPosition).rgb;
    lightColor = max(lightColor, 0.0f);

    lightColor *= 0.55f;
    lightColor = min(lightColor, float3(1.15f, 1.15f, 1.15f));

    float3 ambient = float3(0.22f, 0.22f, 0.22f);
    float3 lightingTerm = ambient + lightColor * softenedShadow;

    float3 finalColor = cAlbedoColor.rgb * lightingTerm;

    float specStrength = dot(cSpecularColor.rgb, float3(0.333f, 0.333f, 0.333f));
    float metalStrength = dot(cMetallicColor.rgb, float3(0.333f, 0.333f, 0.333f));

    float highlightStrength = saturate(specStrength * 0.06f + metalStrength * 0.04f);
    finalColor += lightColor * softenedShadow * highlightStrength;

    finalColor += cEmissionColor.rgb * 0.08f;

    finalColor = finalColor / (finalColor + float3(0.65f, 0.65f, 0.65f));
    finalColor *= 1.25f;

    return float4(saturate(finalColor), cAlbedoColor.a);
}

VS_STANDARD_OUTPUT VSSkinnedAnimationStandard(VS_SKINNED_STANDARD_INPUT input)
{
	VS_STANDARD_OUTPUT output;

	//output.positionW = float3(0.0f, 0.0f, 0.0f);
	//output.normalW = float3(0.0f, 0.0f, 0.0f);
	//output.tangentW = float3(0.0f, 0.0f, 0.0f);
	//output.bitangentW = float3(0.0f, 0.0f, 0.0f);
	//matrix mtxVertexToBoneWorld;
	//for (int i = 0; i < MAX_VERTEX_INFLUENCES; i++)
	//{
	//	mtxVertexToBoneWorld = mul(gpmtxBoneOffsets[input.indices[i]], gpmtxBoneTransforms[input.indices[i]]);
	//	output.positionW += input.weights[i] * mul(float4(input.position, 1.0f), mtxVertexToBoneWorld).xyz;
	//	output.normalW += input.weights[i] * mul(input.normal, (float3x3)mtxVertexToBoneWorld);
	//	output.tangentW += input.weights[i] * mul(input.tangent, (float3x3)mtxVertexToBoneWorld);
	//	output.bitangentW += input.weights[i] * mul(input.bitangent, (float3x3)mtxVertexToBoneWorld);
	//}
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
#endif // SHADERS_HLSL
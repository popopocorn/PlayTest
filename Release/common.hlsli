
#ifndef COMMON_HLSLI
#define COMMON_HLSLI




#define MAX_LIGHTS			16 
#define MAX_MATERIALS		16 

#define POINT_LIGHT			1
#define SPOT_LIGHT			2
#define DIRECTIONAL_LIGHT	3

#define _WITH_LOCAL_VIEWER_HIGHLIGHTING
#define _WITH_THETA_PHI_CONES

struct LIGHT
{
    float4 m_cAmbient;
    float4 m_cDiffuse;
    float4 m_cSpecular;
    float3 m_vPosition;
    float m_fFalloff;
    float3 m_vDirection;
    float m_fTheta; //cos(m_fTheta)
    float3 m_vAttenuation;
    float m_fPhi; //cos(m_fPhi)
    bool m_bEnable;
    int m_nType;
    float m_fRange;
    float padding;
};

cbuffer cbLights : register(b4)
{
    LIGHT gLights[MAX_LIGHTS];
    float4 gcGlobalAmbientLight;
    int gnLights;
};


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//

#define MATERIAL_ALBEDO_MAP			0x01
#define MATERIAL_SPECULAR_MAP		0x02
#define MATERIAL_NORMAL_MAP			0x04
#define MATERIAL_METALLIC_MAP		0x08
#define MATERIAL_EMISSION_MAP		0x10
#define MATERIAL_DETAIL_ALBEDO_MAP	0x20
#define MATERIAL_DETAIL_NORMAL_MAP	0x40

struct VS_STANDARD_INPUT
{
    float3 position : POSITION;
    float2 uv : TEXCOORD;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
    float3 bitangent : BITANGENT;
};

struct VS_UI_INPUT
{
    float3 position : POSITION;
    float2 uv : TEXCOORD;
};
struct VS_UI_OUTPUT
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD;
};

struct VS_VIEW_INPUT
{
    float3 position : POSITION;
};

struct VS_VIEW_OUTPUT
{
    float4 position : SV_POSITION;
};

struct VS_STANDARD_OUTPUT
{
    float4 position : SV_POSITION;
    float3 positionW : POSITION;
    float3 normalW : NORMAL;
    float3 tangentW : TANGENT;
    float3 bitangentW : BITANGENT;
    float2 uv : TEXCOORD;
};

struct MATERIAL
{
    float4 m_cAmbient;
    float4 m_cDiffuse;
    float4 m_cSpecular; //a = power
    float4 m_cEmissive;
};

cbuffer cbCameraInfo : register(b1)
{
    matrix gmtxView : packoffset(c0);
    matrix gmtxProjection : packoffset(c4);
    float3 gvCameraPosition : packoffset(c8);
};

cbuffer cbGameObjectInfo : register(b2)
{
    matrix gmtxGameObject : packoffset(c0);
    MATERIAL gMaterial : packoffset(c4);
    uint gnTexturesMask : packoffset(c8);
};


Texture2D gtxtAlbedoTexture : register(t6);
Texture2D gtxtSpecularTexture : register(t7);
Texture2D gtxtNormalTexture : register(t8);
Texture2D gtxtMetallicTexture : register(t9);
Texture2D gtxtEmissionTexture : register(t10);
Texture2D gtxtDetailAlbedoTexture : register(t11);
Texture2D gtxtDetailNormalTexture : register(t12);

SamplerState gssWrap : register(s0);



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
#define MAX_VERTEX_INFLUENCES			4
#define SKINNED_ANIMATION_BONES			256


cbuffer cbBoneOffsets : register(b7)
{
    float4x4 gpmtxBoneOffsets[SKINNED_ANIMATION_BONES];
};

cbuffer cbBoneTransforms : register(b8)
{
    float4x4 gpmtxBoneTransforms[SKINNED_ANIMATION_BONES];
};

struct VS_SKINNED_STANDARD_INPUT
{
    float3 position : POSITION;
    float2 uv : TEXCOORD;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
    float3 bitangent : BITANGENT;
    int4 indices : BONEINDEX;
    float4 weights : BONEWEIGHT;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
Texture2D gtxtTerrainBaseTexture : register(t1);
Texture2D gtxtTerrainDetailTexture : register(t2);

struct VS_TERRAIN_INPUT
{
    float3 position : POSITION;
    float4 color : COLOR;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
};

struct VS_TERRAIN_OUTPUT
{
    float4 position : SV_POSITION;
    float4 color : COLOR;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
};



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
struct VS_SKYBOX_CUBEMAP_INPUT
{
    float3 position : POSITION;
};

struct VS_SKYBOX_CUBEMAP_OUTPUT
{
    float3 positionL : POSITION;
    float4 position : SV_POSITION;
};

TextureCube gtxtSkyCubeTexture : register(t13);
SamplerState gssClamp : register(s1);

Texture2DArray shadowMap : register(t14);
SamplerComparisonState shadowSampler : register(s2);

cbuffer cbShadowInfo : register(b9)
{
    matrix gmtxLightView[4];
    matrix gmtxLightProjection[4];
    float4 gfCascadeSplits; // x,y,z,w = cascade 0~3 far
};

int GetCascadeIndex(float depth)
{
    if (depth < gfCascadeSplits.x)
        return 0;
    if (depth < gfCascadeSplits.y)
        return 1;
    if (depth < gfCascadeSplits.z)
        return 2;
    return 3;
}

float CalcShadowFactor(float3 positionW, float viewDepth)
{
    int cascadeIndex = GetCascadeIndex(viewDepth);
    
    float4 posLight = mul(float4(positionW, 1.0f), gmtxLightView[cascadeIndex]);
    posLight = mul(posLight, gmtxLightProjection[cascadeIndex]);
    
    float2 shadowUV;
    shadowUV.x = posLight.x / posLight.w * 0.5f + 0.5f;
    shadowUV.y = -posLight.y / posLight.w * 0.5f + 0.5f;

    float currentDepth = posLight.z / posLight.w;
    
    if (shadowUV.x < 0.0f || shadowUV.x > 1.0f ||
        shadowUV.y < 0.0f || shadowUV.y > 1.0f)
        return 1.0f;

    // 1. 그림자 맵의 해상도를 가져와 1픽셀(Texel)의 크기를 구합니다.
    uint width, height, elements, levels;
    shadowMap.GetDimensions(0, width, height, elements, levels);
    float dx = 1.0f / (float) width;
    float dy = 1.0f / (float) height;

    // 2. 주변 3x3 영역의 그림자 값을 누적할 변수
    float percentLit = 0.0f;

    // 3x3 픽셀 오프셋 배열 (현재 픽셀을 중심으로 주변 8방향)
    const float2 offsets[9] =
    {
        float2(-dx, -dy), float2(0.0f, -dy), float2(dx, -dy),
        float2(-dx, 0.0f), float2(0.0f, 0.0f), float2(dx, 0.0f),
        float2(-dx, dy), float2(0.0f, dy), float2(dx, dy)
    };

    // 3. 루프를 돌며 9번 텍스처를 샘플링하고 더합니다.
    // [unroll] 속성을 달아주면 컴파일러가 루프를 풀어줘서 성능에 유리합니다.
    [unroll]
    for (int i = 0; i < 9; ++i)
    {
        percentLit += shadowMap.SampleCmpLevelZero(
            shadowSampler,
            float3(shadowUV + offsets[i], cascadeIndex),
            currentDepth - 0.0015f);
    }

    // 4. 샘플링한 횟수(9)만큼 나누어 평균(퍼센트)을 냅니다.
    return percentLit / 9.0f;
}

#endif // COMMON_HLSLI
#define PARTICLE_BILLBOARD_CAMERA_FACING 0
#define PARTICLE_BILLBOARD_VELOCITY_ALIGNED 1

#define PARTICLE_FRAME_FIXED 0
#define PARTICLE_FRAME_SEQUENTIAL 1
#define PARTICLE_FRAME_RANDOM_SELECTED 2

struct GPUParticle
{
    float3 position;
    float age;

    float3 velocity;
    float lifeTime;

    float3 acceleration;
    float spawnDelay;

    float2 startSize;
    float2 endSize;

    float4 startColor;
    float4 endColor;

    float rotation;
    float angularVelocity;
    float sizeScale;
    uint textureId;

    uint billboardMode;
    uint frameMode;
    uint firstFrame;
    uint frameCount;

    uint renderGroup;
    uint alive;
    uint padding0;
    uint padding1;
};

cbuffer CameraConstants : register(b0)
{
    matrix gmtxView;
    matrix gmtxProjection;
    float3 gvCameraPosition;
    float gCameraPadding;
};

cbuffer ParticleGraphicsConstants : register(b1)
{
    uint gTextureWidth;
    uint gTextureHeight;
    uint gAtlasColumns;
    uint gAtlasRows;

    uint gFrameWidth;
    uint gFrameHeight;
    uint gBorderX;
    uint gBorderY;

    uint gSpacingX;
    uint gSpacingY;
    uint gValidFrameCount;
    uint gRenderGroup;

    float gInverseTextureWidth;
    float gInverseTextureHeight;
    uint gGraphicsPadding0;
    uint gGraphicsPadding1;
};

StructuredBuffer<GPUParticle> gParticles : register(t0);
StructuredBuffer<uint> gRenderIndices : register(t1);

Texture2D<float4> gParticleTexture : register(t2);
SamplerState gParticleSampler : register(s0);

struct VS_PARTICLE_OUTPUT
{
    float4 positionH : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR0;
};

static const float2 gQuadPositions[6] =
{
    float2(-0.5f, 0.5f),
    float2(0.5f, 0.5f),
    float2(0.5f, -0.5f),

    float2(-0.5f, 0.5f),
    float2(0.5f, -0.5f),
    float2(-0.5f, -0.5f)
};

static const float2 gQuadUVs[6] =
{
    float2(0.0f, 0.0f),
    float2(1.0f, 0.0f),
    float2(1.0f, 1.0f),

    float2(0.0f, 0.0f),
    float2(1.0f, 1.0f),
    float2(0.0f, 1.0f)
};

void BuildCameraFacingBasis(float3 particlePosition, out float3 right, out float3 up, out float3 forward)
{
    forward = gvCameraPosition - particlePosition;

    if (dot(forward, forward) < 0.000001f)
    {
        forward = float3(0.0f, 0.0f, 1.0f);
    }
    else
    {
        forward = normalize(forward);
    }

    float3 referenceUp = float3(0.0f, 1.0f, 0.0f);

    if (abs(dot(referenceUp, forward)) > 0.999f)
    {
        referenceUp = float3(0.0f, 0.0f, 1.0f);
    }

    right = normalize(cross(referenceUp, forward));
    up = normalize(cross(forward, right));
}

void BuildVelocityAlignedBasis(GPUParticle particle, out float3 right, out float3 up, out float3 forward)
{
    BuildCameraFacingBasis(particle.position, right, up, forward);

    float3 projectedVelocity = particle.velocity - forward * dot(particle.velocity, forward);

    if (dot(projectedVelocity, projectedVelocity) < 0.000001f)
    {
        return;
    }

    up = normalize(projectedVelocity);
    right = cross(up, forward);

    if (dot(right, right) < 0.000001f)
    {
        BuildCameraFacingBasis(particle.position, right, up, forward);
        return;
    }

    right = normalize(right);
    up = normalize(cross(forward, right));
}

uint ResolveParticleFrame(GPUParticle particle, float lifeProgress)
{
    uint validFrameCount = max(gValidFrameCount, 1);
    uint frameCount = max(particle.frameCount, 1);
    uint frameIndex = particle.firstFrame;

    if (particle.frameMode == PARTICLE_FRAME_SEQUENTIAL)
    {
        uint frameOffset = min((uint) (lifeProgress * frameCount), frameCount - 1);
        frameIndex += frameOffset;
    }

    return min(frameIndex, validFrameCount - 1);
}

float2 ResolveParticleUV(uint frameIndex, float2 quadUV)
{
    uint atlasColumns = max(gAtlasColumns, 1);
    uint frameColumn = frameIndex % atlasColumns;
    uint frameRow = frameIndex / atlasColumns;

    float frameLeft = (float) gBorderX + (float) frameColumn * ((float) gFrameWidth + (float) gSpacingX);
    float frameTop = (float) gBorderY + (float) frameRow * ((float) gFrameHeight + (float) gSpacingY);

    float2 minimumPixel = float2(frameLeft + 0.5f, frameTop + 0.5f);
    float2 maximumPixel = float2(
        frameLeft + max((float) gFrameWidth - 0.5f, 0.5f),
        frameTop + max((float) gFrameHeight - 0.5f, 0.5f)
    );

    float2 atlasPixel = lerp(minimumPixel, maximumPixel, quadUV);

    return float2(
        atlasPixel.x * gInverseTextureWidth,
        atlasPixel.y * gInverseTextureHeight
    );
}

VS_PARTICLE_OUTPUT VSParticle(uint vertexId : SV_VertexID, uint instanceId : SV_InstanceID)
{
    VS_PARTICLE_OUTPUT output;

    uint particleIndex = gRenderIndices[instanceId];
    GPUParticle particle = gParticles[particleIndex];

    float lifeTime = max(particle.lifeTime, 0.0001f);
    float lifeProgress = saturate(max(particle.age, 0.0f) / lifeTime);

    float2 particleSize = lerp(particle.startSize, particle.endSize, lifeProgress);
    particleSize *= particle.sizeScale;

    float4 particleColor = lerp(particle.startColor, particle.endColor, lifeProgress);

    float3 right;
    float3 up;
    float3 forward;

    if (particle.billboardMode == PARTICLE_BILLBOARD_VELOCITY_ALIGNED)
    {
        BuildVelocityAlignedBasis(particle, right, up, forward);
    }
    else
    {
        BuildCameraFacingBasis(particle.position, right, up, forward);
    }

    float sineRotation;
    float cosineRotation;

    sincos(particle.rotation, sineRotation, cosineRotation);

    float3 rotatedRight = right * cosineRotation + up * sineRotation;
    float3 rotatedUp = up * cosineRotation - right * sineRotation;

    float2 localPosition = gQuadPositions[vertexId];

    // 회전 여부와 관계없이 쿼드의 아래쪽 중앙을 particle.position에 고정한다.
    float3 billboardCenter = particle.position;
    billboardCenter += rotatedUp * (particleSize.y * 0.5f);

    float3 worldPosition = billboardCenter;
    worldPosition += rotatedRight * localPosition.x * particleSize.x;
    worldPosition += rotatedUp * localPosition.y * particleSize.y;

    float4 positionView = mul(float4(worldPosition, 1.0f), gmtxView);
    output.positionH = mul(positionView, gmtxProjection);

    uint frameIndex = ResolveParticleFrame(particle, lifeProgress);

    output.uv = ResolveParticleUV(frameIndex, gQuadUVs[vertexId]);
    output.color = particleColor;

    return output;
}

float4 PSParticle(VS_PARTICLE_OUTPUT input) : SV_TARGET
{
    float4 textureColor = gParticleTexture.Sample(gParticleSampler, input.uv);
    float4 finalColor = textureColor * input.color;

    clip(finalColor.a - 0.002f);

    return finalColor;
}
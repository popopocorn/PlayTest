#define MAX_GPU_PARTICLES 4096
#define PARTICLE_RENDER_GROUP_COUNT 5
#define PARTICLE_SELECTED_FRAME_CAPACITY 16

#define PARTICLE_COUNTER_ALIVE_0 0
#define PARTICLE_COUNTER_ALIVE_1 1
#define PARTICLE_COUNTER_DEAD 2
#define PARTICLE_COUNTER_SPAWN_REQUEST 3
#define PARTICLE_COUNTER_RENDER_BASE 4

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

struct ParticleSpawnRequest
{
    float3 position;
    uint burstCount;

    float3 direction;
    float coneAngleDegrees;

    float3 acceleration;
    float speedMin;

    float speedMax;
    float lifeTimeMin;
    float lifeTimeMax;
    float spawnDelayMin;

    float spawnDelayMax;
    float rotationMin;
    float rotationMax;
    float angularVelocityMin;

    float angularVelocityMax;
    float sizeScaleMin;
    float sizeScaleMax;
    uint textureId;

    float2 startSize;
    float2 endSize;

    float4 startColor;
    float4 endColor;

    uint frameMode;
    uint firstFrame;
    uint frameCount;
    uint loopAnimation;

    uint selectedFrameCount;
    uint billboardMode;
    uint renderGroup;
    uint blendMode;

    uint selectedFrames[PARTICLE_SELECTED_FRAME_CAPACITY];
};

struct ParticleDrawArguments
{
    uint vertexCountPerInstance;
    uint instanceCount;
    uint startVertexLocation;
    uint startInstanceLocation;
};

cbuffer ParticleComputeConstants : register(b0)
{
    float gDeltaTime;
    float gTotalTime;
    uint gSpawnRequestCount;
    uint gInputAliveBufferIndex;

    uint gOutputAliveBufferIndex;
    uint gRandomSeed;
    uint gMaxParticles;
    uint gSpawnRequestBaseIndex;
};

StructuredBuffer<ParticleSpawnRequest> gSpawnRequests : register(t0);

RWStructuredBuffer<GPUParticle> gParticles : register(u0);
RWStructuredBuffer<uint> gAliveIndices0 : register(u1);
RWStructuredBuffer<uint> gAliveIndices1 : register(u2);
RWStructuredBuffer<uint> gDeadIndices : register(u3);
RWStructuredBuffer<uint> gCounters : register(u4);

RWStructuredBuffer<uint> gRenderExplosionAlpha : register(u5);
RWStructuredBuffer<uint> gRenderExplosionAdditive : register(u6);
RWStructuredBuffer<uint> gRenderShotgunAdditive : register(u7);
RWStructuredBuffer<uint> gRenderRifleAdditive : register(u8);
RWStructuredBuffer<uint> gRenderRifleAlpha : register(u9);

RWStructuredBuffer<ParticleDrawArguments> gDrawArguments : register(u10);

uint HashUint(uint value)
{
    value ^= value >> 16;
    value *= 0x7feb352d;
    value ^= value >> 15;
    value *= 0x846ca68b;
    value ^= value >> 16;

    return value;
}

float Random01(inout uint randomState)
{
    randomState = HashUint(randomState + 0x9e3779b9);
    return float(randomState & 0x00ffffff) / 16777216.0f;
}

float RandomRange(inout uint randomState, float minimumValue, float maximumValue)
{
    return lerp(minimumValue, maximumValue, Random01(randomState));
}

bool TryReserveCounter(uint counterIndex, uint capacity, out uint reservedIndex)
{
    [loop]
    for (uint attempt = 0; attempt < 64; ++attempt)
    {
        uint currentValue = gCounters[counterIndex];

        if (currentValue >= capacity)
        {
            reservedIndex = 0;
            return false;
        }

        uint originalValue;
        InterlockedCompareExchange(gCounters[counterIndex], currentValue, currentValue + 1, originalValue);

        if (originalValue == currentValue)
        {
            reservedIndex = currentValue;
            return true;
        }
    }

    reservedIndex = 0;
    return false;
}

bool PopDeadIndex(out uint particleIndex)
{
    [loop]
    for (uint attempt = 0; attempt < 64; ++attempt)
    {
        uint currentDeadCount = gCounters[PARTICLE_COUNTER_DEAD];

        if (currentDeadCount == 0)
        {
            particleIndex = 0;
            return false;
        }

        uint originalValue;
        InterlockedCompareExchange(gCounters[PARTICLE_COUNTER_DEAD], currentDeadCount, currentDeadCount - 1, originalValue);

        if (originalValue == currentDeadCount)
        {
            particleIndex = gDeadIndices[currentDeadCount - 1];
            return true;
        }
    }

    particleIndex = 0;
    return false;
}

void PushDeadIndex(uint particleIndex)
{
    uint deadSlot;

    if (TryReserveCounter(PARTICLE_COUNTER_DEAD, gMaxParticles, deadSlot))
    {
        gDeadIndices[deadSlot] = particleIndex;
    }
}

bool AppendAliveIndex(uint particleIndex)
{
    uint aliveCounterIndex = (gOutputAliveBufferIndex == 0) ? PARTICLE_COUNTER_ALIVE_0 : PARTICLE_COUNTER_ALIVE_1;
    uint aliveSlot;

    if (!TryReserveCounter(aliveCounterIndex, gMaxParticles, aliveSlot))
    {
        return false;
    }

    if (gOutputAliveBufferIndex == 0)
    {
        gAliveIndices0[aliveSlot] = particleIndex;
    }
    else
    {
        gAliveIndices1[aliveSlot] = particleIndex;
    }

    return true;
}

uint GetInputAliveIndex(uint listIndex)
{
    if (gInputAliveBufferIndex == 0)
    {
        return gAliveIndices0[listIndex];
    }

    return gAliveIndices1[listIndex];
}

void AppendRenderIndex(uint renderGroup, uint particleIndex)
{
    if (renderGroup >= PARTICLE_RENDER_GROUP_COUNT)
    {
        return;
    }

    uint renderCounterIndex = PARTICLE_COUNTER_RENDER_BASE + renderGroup;
    uint renderSlot;

    if (!TryReserveCounter(renderCounterIndex, gMaxParticles, renderSlot))
    {
        return;
    }

    switch (renderGroup)
    {
        case 0:
            gRenderExplosionAlpha[renderSlot] = particleIndex;
            break;

        case 1:
            gRenderExplosionAdditive[renderSlot] = particleIndex;
            break;

        case 2:
            gRenderShotgunAdditive[renderSlot] = particleIndex;
            break;

        case 3:
            gRenderRifleAdditive[renderSlot] = particleIndex;
            break;

        case 4:
            gRenderRifleAlpha[renderSlot] = particleIndex;
            break;
    }

    uint unusedValue;
    InterlockedMax(gDrawArguments[renderGroup].instanceCount, renderSlot + 1, unusedValue);
}

float3 BuildDirectionInCone(float3 axis, float coneAngleDegrees, inout uint randomState)
{
    float axisLengthSquared = dot(axis, axis);

    if (axisLengthSquared < 0.000001f)
    {
        axis = float3(0.0f, 1.0f, 0.0f);
    }
    else
    {
        axis = normalize(axis);
    }

    float maximumAngle = radians(clamp(coneAngleDegrees, 0.0f, 180.0f));
    float minimumCosine = cos(maximumAngle);
    float cosineTheta = lerp(1.0f, minimumCosine, Random01(randomState));
    float sineTheta = sqrt(saturate(1.0f - cosineTheta * cosineTheta));
    float phi = Random01(randomState) * 6.28318530718f;

    float3 referenceAxis = (abs(axis.y) < 0.999f) ? float3(0.0f, 1.0f, 0.0f) : float3(1.0f, 0.0f, 0.0f);
    float3 right = normalize(cross(referenceAxis, axis));
    float3 up = normalize(cross(axis, right));

    float3 resultDirection = right * (cos(phi) * sineTheta);
    resultDirection += up * (sin(phi) * sineTheta);
    resultDirection += axis * cosineTheta;

    return normalize(resultDirection);
}

[numthreads(1, 1, 1)]
void CSResetParticleFrame(uint3 dispatchThreadId : SV_DispatchThreadID)
{
    if (dispatchThreadId.x != 0)
    {
        return;
    }

    uint outputAliveCounterIndex = (gOutputAliveBufferIndex == 0) ? PARTICLE_COUNTER_ALIVE_0 : PARTICLE_COUNTER_ALIVE_1;

    gCounters[outputAliveCounterIndex] = 0;
    gCounters[PARTICLE_COUNTER_SPAWN_REQUEST] = gSpawnRequestCount;

    [unroll]
    for (uint renderGroup = 0; renderGroup < PARTICLE_RENDER_GROUP_COUNT; ++renderGroup)
    {
        gCounters[PARTICLE_COUNTER_RENDER_BASE + renderGroup] = 0;

        ParticleDrawArguments drawArguments;
        drawArguments.vertexCountPerInstance = 6;
        drawArguments.instanceCount = 0;
        drawArguments.startVertexLocation = 0;
        drawArguments.startInstanceLocation = 0;

        gDrawArguments[renderGroup] = drawArguments;
    }
}

[numthreads(256, 1, 1)]
void CSUpdateParticles(uint3 dispatchThreadId : SV_DispatchThreadID)
{
    uint inputAliveCounterIndex = (gInputAliveBufferIndex == 0) ? PARTICLE_COUNTER_ALIVE_0 : PARTICLE_COUNTER_ALIVE_1;
    uint inputAliveCount = min(gCounters[inputAliveCounterIndex], gMaxParticles);
    uint aliveListIndex = dispatchThreadId.x;

    if (aliveListIndex >= inputAliveCount)
    {
        return;
    }

    uint particleIndex = GetInputAliveIndex(aliveListIndex);

    if (particleIndex >= gMaxParticles)
    {
        return;
    }

    GPUParticle particle = gParticles[particleIndex];

    if (particle.alive == 0)
    {
        return;
    }

    float previousAge = particle.age;
    particle.age += gDeltaTime;

    if (particle.lifeTime <= 0.0f || particle.age >= particle.lifeTime)
    {
        particle.alive = 0;
        gParticles[particleIndex] = particle;
        PushDeadIndex(particleIndex);
        return;
    }

    float activeDeltaTime = 0.0f;

    if (particle.age > 0.0f)
    {
        activeDeltaTime = (previousAge < 0.0f) ? min(gDeltaTime, particle.age) : gDeltaTime;
    }

    if (activeDeltaTime > 0.0f)
    {
        particle.velocity += particle.acceleration * activeDeltaTime;
        particle.position += particle.velocity * activeDeltaTime;
        particle.rotation += particle.angularVelocity * activeDeltaTime;
    }

    if (!AppendAliveIndex(particleIndex))
    {
        particle.alive = 0;
        gParticles[particleIndex] = particle;
        PushDeadIndex(particleIndex);
        return;
    }

    gParticles[particleIndex] = particle;

    if (particle.age >= 0.0f)
    {
        AppendRenderIndex(particle.renderGroup, particleIndex);
    }
}

[numthreads(64, 1, 1)]
void CSSpawnParticles(uint3 dispatchThreadId : SV_DispatchThreadID)
{
    uint requestListIndex = dispatchThreadId.x;

    if (requestListIndex >= gSpawnRequestCount)
    {
        return;
    }

    uint requestBufferIndex = gSpawnRequestBaseIndex + requestListIndex;
    ParticleSpawnRequest request = gSpawnRequests[requestBufferIndex];

    uint burstCount = min(request.burstCount, gMaxParticles);

    for (uint burstIndex = 0; burstIndex < burstCount; ++burstIndex)
    {
        uint particleIndex;

        if (!PopDeadIndex(particleIndex))
        {
            break;
        }

        uint randomState = HashUint(gRandomSeed ^ requestBufferIndex * 747796405u ^ burstIndex * 2891336453u);

        GPUParticle particle;
        particle.position = request.position;

        float spawnDelay = RandomRange(randomState, request.spawnDelayMin, request.spawnDelayMax);
        particle.age = -max(spawnDelay, 0.0f);

        float3 particleDirection = BuildDirectionInCone(request.direction, request.coneAngleDegrees, randomState);
        float speed = RandomRange(randomState, request.speedMin, request.speedMax);

        particle.velocity = particleDirection * speed;
        particle.lifeTime = max(RandomRange(randomState, request.lifeTimeMin, request.lifeTimeMax), 0.0001f);

        particle.acceleration = request.acceleration;
        particle.spawnDelay = spawnDelay;

        particle.startSize = request.startSize;
        particle.endSize = request.endSize;

        particle.startColor = request.startColor;
        particle.endColor = request.endColor;

        particle.rotation = RandomRange(randomState, request.rotationMin, request.rotationMax);
        particle.angularVelocity = RandomRange(randomState, request.angularVelocityMin, request.angularVelocityMax);
        particle.sizeScale = RandomRange(randomState, request.sizeScaleMin, request.sizeScaleMax);
        particle.textureId = request.textureId;

        particle.billboardMode = request.billboardMode;
        particle.frameMode = request.frameMode;
        particle.firstFrame = request.firstFrame;
        particle.frameCount = max(request.frameCount, 1);

        if (request.frameMode == PARTICLE_FRAME_RANDOM_SELECTED && request.selectedFrameCount > 0)
        {
            uint selectedFrameCount = min(request.selectedFrameCount, PARTICLE_SELECTED_FRAME_CAPACITY);
            uint selectedFrameIndex = min(uint(Random01(randomState) * selectedFrameCount), selectedFrameCount - 1);

            particle.frameMode = PARTICLE_FRAME_FIXED;
            particle.firstFrame = request.selectedFrames[selectedFrameIndex];
            particle.frameCount = 1;
        }

        particle.renderGroup = request.renderGroup;
        particle.alive = 1;
        particle.padding0 = 0;
        particle.padding1 = 0;

        if (!AppendAliveIndex(particleIndex))
        {
            particle.alive = 0;
            gParticles[particleIndex] = particle;
            PushDeadIndex(particleIndex);
            break;
        }

        gParticles[particleIndex] = particle;

        if (particle.age >= 0.0f)
        {
            AppendRenderIndex(particle.renderGroup, particleIndex);
        }
    }
}
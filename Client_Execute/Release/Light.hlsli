//--------------------------------------------------------------------------------------

//#define _WITH_REFLECT
#ifndef LIGHT_HLSLI
#define LIGHT_HLSLI

#include "common.hlsli"

// lighting functions
struct GBufferSurface
{
    float3 positionW;
    float3 normalW;
    float3 albedo;
    float specStrength;
    float shininess;
};

float3 DeferredLightTerm(int i, GBufferSurface s, float3 vToCamera, float3 vToLight, float fAtten)
{
    float ndl = saturate(dot(s.normalW, vToLight));
    float3 h = normalize(vToCamera + vToLight);
    float spec = (ndl > 0.0f) ? pow(saturate(dot(s.normalW, h)), s.shininess) : 0.0f;

    float3 c = gLights[i].m_cAmbient.rgb * s.albedo
             + gLights[i].m_cDiffuse.rgb * ndl * s.albedo
             + gLights[i].m_cSpecular.rgb * spec * s.specStrength;
    return c * fAtten;
}

float3 DeferredLighting(GBufferSurface s, float shadowFactor)
{
    float3 vToCamera = normalize(gvCameraPosition - s.positionW);
    float3 c = 0.0f;
    bool bShadowApplied = false;

    [loop]
    for (int i = 0; i < gnLights; i++)
    {
        if (!gLights[i].m_bEnable)
            continue;

        if (gLights[i].m_nType == DIRECTIONAL_LIGHT)
        {
            
            float sh = bShadowApplied ? 1.0f : shadowFactor;
            bShadowApplied = true;
            float3 term = DeferredLightTerm(i, s, vToCamera, normalize(-gLights[i].m_vDirection), 1.0f);
            
            c += gLights[i].m_cAmbient.rgb * s.albedo + (term - gLights[i].m_cAmbient.rgb * s.albedo) * sh;
        }
        else
        {
            float3 vToLight = gLights[i].m_vPosition - s.positionW;
            float d = length(vToLight);
            if (d > gLights[i].m_fRange)
                continue;
            vToLight /= d;
            float fAtten = 1.0f / dot(gLights[i].m_vAttenuation, float3(1.0f, d, d * d));

            if (gLights[i].m_nType == SPOT_LIGHT)
            {
                float fAlpha = max(dot(-vToLight, gLights[i].m_vDirection), 0.0f);
                fAtten *= pow(max((fAlpha - gLights[i].m_fPhi) / (gLights[i].m_fTheta - gLights[i].m_fPhi), 0.0f),
                              gLights[i].m_fFalloff);
            }
            c += DeferredLightTerm(i, s, vToCamera, vToLight, fAtten);
        }
    }
    return c + gcGlobalAmbientLight.rgb * s.albedo;
}




#endif // LIGHT_HLSLI
/*
* Copyright (c) 2012-2018, NVIDIA CORPORATION. All rights reserved.
*
* NVIDIA CORPORATION and its licensors retain all intellectual property
* and proprietary rights in and to this software, related documentation
* and any modifications thereto. Any use, reproduction, disclosure or
* distribution of this software and related documentation without an express
* license agreement from NVIDIA CORPORATION is strictly prohibited.
*/

char const g_GBufferLoader[] = R"(

// A structure that you can use to keep any information in - it's passed from VxgiLoadGBufferSample to all other functions
struct VxgiGBufferSample
{
    float sampleDepth;
    float3 samplePosition;
    float3 sampleSmoothNormal;
    float3 sampleTangant;
};

struct GBufferParameters
{
    float4x4 viewProjMatrixInv;
    float2 viewportOrigin;
    float2 viewportSizeInv;
};

cbuffer cBuiltinGBufferParameters : register(b0)
{
    GBufferParameters g_GBuffer;
    GBufferParameters g_PreviousGBuffer;
}

Texture2D g_DepthBuffer : register(t0);
Texture2D g_TargetFlatNormal : register(t2);

// Loads a sample from the current or previous G-buffer at given window coordinates.
// If onlyPosition is true, the function should skip loading and processing anything else, for performance.
bool VxgiLoadGBufferSample(float2 sampleScreenPosition, uint viewIndex, bool previous, bool onlyPosition, out VxgiGBufferSample result)
{
    [branch] 
    if (0U == viewIndex)
    {
        float sampleDepth = g_DepthBuffer[int2(sampleScreenPosition)];
        float3 sampleSmoothNormal = normalize(g_TargetFlatNormal[int2(sampleScreenPosition)]);

        float3 samplePosition;
        [branch] 
        if (previous)
        {
            float2 uv = (sampleScreenPosition - g_PreviousGBuffer.viewportOrigin) * g_PreviousGBuffer.viewportSizeInv;
            float4 clipCoord = float4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, sampleDepth, 1.0);
            float4 samplePositionV4 = mul(clipCoord, g_PreviousGBuffer.viewProjMatrixInv);
            samplePosition = samplePositionV4.xyz /= samplePositionV4.w;
        }
        else
        {
            float2 uv = (sampleScreenPosition - g_GBuffer.viewportOrigin) * g_GBuffer.viewportSizeInv;
            float4 clipCoord = float4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, sampleDepth, 1.0);
            float4 samplePositionV4 = mul(clipCoord, g_GBuffer.viewProjMatrixInv);
            samplePosition = samplePositionV4.xyz /= samplePositionV4.w;
        }

        float3 sampleTangant;
        {
            float3 normal = sampleSmoothNormal;

            float3 absNormal = abs(normal);
            float maxComp = max(absNormal.x, max(absNormal.y, absNormal.z));

            float3 tangent;
            [branch] 
            if (maxComp == absNormal.x)
            {
                tangent = float3((-normal.y - normal.z) * sign(normal.x), absNormal.x, absNormal.x);
            }
            else if (maxComp == absNormal.y)
            {
                tangent = float3(absNormal.y, (-normal.x - normal.z) * sign(normal.y), absNormal.y);
            }
            else
            {
                tangent = float3(absNormal.z, absNormal.z, (-normal.x - normal.y) * sign(normal.z));
            }

            sampleTangant = normalize(tangent);
        }

        result.sampleDepth = sampleDepth;
        result.samplePosition = samplePosition;
        result.sampleSmoothNormal = sampleSmoothNormal;
        result.sampleTangant = sampleTangant;

        return true;
    }
    else
    {
        return false;
    }
}

// Returns the view depth or distance to camera for a given sample
float VxgiGetGBufferViewDepth(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.sampleDepth;
}

// Returns the world position of a given sample
float3 VxgiGetGBufferWorldPos(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.samplePosition;
}

// Returns the world space normal for a given sample
float3 VxgiGetGBufferNormal(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.sampleSmoothNormal;
}

// Returns the world space tangent for a given sample.
// Tangents are used by VXGI to calculate directions for diffuse cones. Using tangents that originate from meshes
// can help avoid seams on diffuse illumination where computed tangents have a discontinuity.
float3 VxgiGetGBufferTangent(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.sampleTangant;
}

// Returns the diffuse/ambient tracing settings for the current sample.
VxgiDiffuseShaderParameters VxgiGetGBufferDiffuseShaderParameters(VxgiGBufferSample gbufferSample)
{
    // An instance of this structure with all-default fields can be obtained by calling VxgiGetDefaultDiffuseShaderParameters().
    return VxgiGetDefaultDiffuseShaderParameters();
}

// Returns the specular tracing settings for the current sample.
VxgiSpecularShaderParameters VxgiGetGBufferSpecularShaderParameters(VxgiGBufferSample gbufferSample)
{
    return VxgiGetDefaultSpecularShaderParameters();
}

// Returns the area light settings for the current sample.
VxgiAreaLightShaderParameters VxgiGetGBufferAreaLightShaderParameters(VxgiGBufferSample gbufferSample)
{
    return VxgiGetDefaultAreaLightShaderParameters();
}

// Return true if SSAO  should be computed for the sample;
// VXGI assumes that the sample is valid (position, normal etc.) if this function returns true.
bool VxgiGetGBufferEnableSSAO(VxgiGBufferSample gbufferSample)
{
    return false;
}

// Returns the clip-space position for a given sample.
// When normalized == true, VXGI expects that the .w component of position will be 1.0
// This function is only used for SSAO.
float4 VxgiGetGBufferClipPos(VxgiGBufferSample gbufferSample, bool normalized)
{
    return float4(0.0, 0.0, 0.0, 0.0);
}

// Maps a given clip-space position to window coordinates which can be used to sample the G-buffer.
// This function is only used for SSAO.
float2 VxgiGBufferMapClipToWindow(uint viewIndex, float2 clipPos)
{
    return float2(0.0, 0.0);
}

// TODO:
float2 VxgiGBufferMapWindowToClip(uint viewIndex, float2 windowPos)
{
    return float2(0.0, 0.0);
}

// Maps a given sample to a different view in the same or previous frame and returns the window coordinates.
// Returns true if a matching surface exists in the other view, false otherwise.
bool VxgiGetGBufferPositionInOtherView(VxgiGBufferSample gbufferSample, uint viewIndex, bool previous, out float2 prevWindowPos)
{
    [branch] 
    if (0U == viewIndex)
    {
        prevWindowPos = float2(0.0, 0.0);
        return true;
    }
    else
    {
        return false;
    }
}

// Returns irradiance from an environment map for a surface at 'surfacePos' coming from a cone
// looking in 'coneDirection' with the cone factor 'coneFactor'.
float3 VxgiGetEnvironmentIrradiance(float3 surfacePos, float3 coneDirection, float coneFactor, bool isSpecular)
{
#if 0
    float correctedAmbient = pow(saturate(cone.ambient * g_AmbientScale + g_AmbientBias), g_AmbientPower);
    return (correctedAmbient * g_AmbientColor.rgb);
#else
    return float3(1.0, 1.0, 1.0);
#endif
}

// TODO:
void VxgiGetGBufferRightAndUp(VxgiGBufferSample gbufferSample, out float3 right, out float3 up)
{
    right = float3(0.0, 0.0, 0.0);
    up = float3(0.0, 0.0, 0.0);
}
)";
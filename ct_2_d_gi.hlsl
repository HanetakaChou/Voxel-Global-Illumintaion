#define REGISTER(type, slot) register(type##slot)
#define VXGI_VOXELTEX_SAMPLER_SLOT 2
#define VXGI_CONE_TRACING_CB_SLOT 3
#define VXGI_CONE_TRACING_TRANSLATION_CB_SLOT 4
#define VXGI_OPACITY_SRV_SLOT 14
#define VXGI_EMITTANCE_EVEN_SRV_SLOT 15
#define VXGI_EMITTANCE_ODD_SRV_SLOT 16
#define VXGI_VIEW_TRACING_CB_SLOT 1
#define VXGI_VIEW_TRACING_SAMPLER_SLOT 0
#define VXGI_VIEW_TRACING_SAMPLER_2_SLOT 1
#define VXGI_VIEW_TRACING_TEXTURE_1_SLOT 4
#define VXGI_VIEW_TRACING_TEXTURE_2_SLOT 5
#define VXGI_VIEW_TRACING_TEXTURE_3_SLOT 6
#define VXGI_VIEW_TRACING_TEXTURE_4_SLOT 7
#define VXGI_VIEW_TRACING_TEXTURE_5_SLOT 8
#define VXGI_VIEW_TRACING_TEXTURE_6_SLOT 9
#define VXGI_VIEW_TRACING_TEXTURE_7_SLOT 10
#define VXGI_VIEW_TRACING_TEXTURE_8_SLOT 11
#define VXGI_VIEW_TRACING_TEXTURE_9_SLOT 12
#define VXGI_VIEW_TRACING_TEXTURE_10_SLOT 13
#define VXGI_AREA_LIGHT_CB_SLOT 2

#pragma pack_matrix(row_major)

struct VxgiDiffuseShaderParameters
{
    float tracingStep;
    float ambientRange;
    float initialOffsetBias;
    float initialOffsetDistanceFactor;
};

VxgiDiffuseShaderParameters VxgiGetDefaultDiffuseShaderParameters()
{
    VxgiDiffuseShaderParameters result;
    result.tracingStep = 0.5;
    result.ambientRange = 128;
    result.initialOffsetBias = 2;
    result.initialOffsetDistanceFactor = 1;
    return result;
}

struct VxgiSpecularShaderParameters
{
    float3 viewDirection;
    float roughness;
    float tracingStep;
    float initialOffsetBias;
    float initialOffsetDistanceFactor;
    float coplanarOffsetFactor;
};

VxgiSpecularShaderParameters VxgiGetDefaultSpecularShaderParameters()
{
    VxgiSpecularShaderParameters result;
    result.viewDirection = float3(0, 0, 0);
    result.roughness = 0;
    result.tracingStep = 1;
    result.initialOffsetBias = 2;
    result.initialOffsetDistanceFactor = 1;
    result.coplanarOffsetFactor = 5;
    return result;
}

struct VxgiAreaLightShaderParameters
{
    bool enableDiffuse;
    bool enableSpecular;
    float3 viewDirection;
    float roughness;
    float tracingStep;
    float initialOffsetBias;
    float initialOffsetDistanceFactor;
    float coplanarOffsetFactor;
};

VxgiAreaLightShaderParameters VxgiGetDefaultAreaLightShaderParameters()
{
    VxgiAreaLightShaderParameters result;
    result.enableDiffuse = true;
    result.enableSpecular = false;
    result.viewDirection = float3(0, 0, 0);
    result.roughness = 0;
    result.tracingStep = 1;
    result.initialOffsetBias = 2;
    result.initialOffsetDistanceFactor = 1;
    result.coplanarOffsetFactor = 5;
    return result;
}

static const float VxgiPI = 3.14159265;

float2 float2scalar(float x) { return float2(x, x); }
float3 float3scalar(float x) { return float3(x, x, x); }
float4 float4scalar(float x) { return float4(x, x, x, x); }
int2 int2scalar(int x) { return int2(x, x); }
int3 int3scalar(int x) { return int3(x, x, x); }
int4 int4scalar(int x) { return int4(x, x, x, x); }
uint2 uint2scalar(uint x) { return uint2(x, x); }
uint3 uint3scalar(uint x) { return uint3(x, x, x); }
uint4 uint4scalar(uint x) { return uint4(x, x, x, x); }

struct VxgiFullScreenQuadOutput
{
    float2 uv : TEXCOORD;
    float4 posProj : RAY;
    float instanceID : INSTANCEID;
};

float3 VxgiProjToRay(float4 posProj, float3 cameraPos, float4x4 viewProjMatrixInv)
{
    float4 farPoint = mul(posProj, viewProjMatrixInv);
    farPoint.xyz /= farPoint.w;

    return normalize(farPoint.xyz - cameraPos.xyz);
}

struct VxgiBox4i
{
    int4 lower;
    int4 upper;
};

struct VxgiBox4f
{
    float4 lower;
    float4 upper;
};

bool VxgiPartOfRegion(int3 coords, VxgiBox4i region)
{
    return coords.x <= region.upper.x && coords.y <= region.upper.y && coords.z <= region.upper.z &&
           coords.x >= region.lower.x && coords.y >= region.lower.y && coords.z >= region.lower.z;
}

bool VxgiPartOfRegionWithBorder(int3 coords, VxgiBox4i region, int border)
{
    return coords.x <= region.upper.x + border && coords.y <= region.upper.y + border && coords.z <= region.upper.z + border &&
           coords.x >= region.lower.x - border && coords.y >= region.lower.y - border && coords.z >= region.lower.z - border;
}

bool VxgiPartOfRegionf(float3 coords, float3 lower, float3 upper)
{
    return coords.x <= upper.x && coords.y <= upper.y && coords.z <= upper.z &&
           coords.x >= lower.x && coords.y >= lower.y && coords.z >= lower.z;
}

float4 VxgiPackEmittance(float4 v)
{
    return float4(v);
}

float4 VxgiUnpackEmittance(float4 n)
{
    return float4(n.rgba);
}

uint2 VxgiPackEmittanceForAtomic(float4 v)
{
    uint4 parts = f32tof16(v);
    return uint2(parts.x | (parts.y << 16), parts.z | (parts.w << 16));
}

uint VxgiPackOpacity(float opacity)
{
    return uint(1023 * opacity);
}

float VxgiUnpackOpacity(uint opacityBits)
{
    return float((opacityBits) & 0x3ff) / 1023.0;
}

float VxgiAverage4(float a, float b, float c, float d)
{
    return (a + b + c + d) / 4;
}

bool VxgiIsOdd(int x)
{
    return (x & 1) != 0;
}

float VxgiMax3(float3 v)
{
    return max(v.x, max(v.y, v.z));
}

float VxgiNormalizedDistance(float2 p, float a, float b)
{
    return sqrt(p.x / a * p.x / a + p.y / b + p.y / b);
}

float3 VxgiRayPlaneIntersection(float3 rayStart, float3 rayDir, float3 planeNormal, float3 planePoint)
{

    float t = dot(planePoint - rayStart, planeNormal) / dot(rayDir, planeNormal);
    return rayStart + t * rayDir;
}

float VxgiMin3(float3 v)
{
    return min(v.x, min(v.y, v.z));
}

int3 VxgiGetToroidalAddress(int3 localPos, int3 offset, uint3 textureSize)
{
    return (localPos + offset) & (int3(textureSize) - int3scalar(1));
}

SamplerState s_VoxelTextureSampler : REGISTER(s, VXGI_VOXELTEX_SAMPLER_SLOT);

Texture3D<float4> t_Opacity : REGISTER(t, VXGI_OPACITY_SRV_SLOT);

Texture3D<float4> t_EmittanceEven : REGISTER(t, VXGI_EMITTANCE_EVEN_SRV_SLOT);
Texture3D<float4> t_EmittanceOdd : REGISTER(t, VXGI_EMITTANCE_ODD_SRV_SLOT);

struct VxgiAbstractTracingConstants
{
    float4 rOpacityTextureSize;
    float4 rEmittanceTextureSize;
    float4 ClipmapAnchor;
    float4 NearestLevelBoundary;
    float4 SceneBoundaryLower;
    float4 SceneBoundaryUpper;
    float4 ClipmapCenter;
    float4 rClipmapSizeWorld;
    float4 TracingToroidalOffset;
    float4 StackTextureSize;
    float4 rNearestLevel0Boundary;
    float EmittancePackingStride;
    float EmittanceChannelStride;
    float FinestVoxelSize;
    float FinestVoxelSizeInv;
    float MaxMipmapLevel;
    float rEmittanceStorageScale;
};

cbuffer AbstractTracingCB : REGISTER(b, VXGI_CONE_TRACING_CB_SLOT)
{
    VxgiAbstractTracingConstants g_VxgiAbstractTracingCB;
};

cbuffer TranslationCB : REGISTER(b, VXGI_CONE_TRACING_TRANSLATION_CB_SLOT)
{
    float4 g_VxgiTranslationParameters1[13];
    float4 g_VxgiTranslationParameters2[13];
    float4 g_VxgiTranslationParameters3[13];
    float4 g_VxgiTranslationParameters4[13];
};

static const int g_VxgiPoissonDiskSize = 16;

static const float2 g_VxgiPoissonDisk[] = {
    float2(-0.7593753f, 0.518795f),
    float2(0.5322764f, 0.2350069f),
    float2(0.8114883f, -0.458026f),
    float2(-0.3093514f, -0.749256f),
    float2(0.2293134f, 0.7607011f),
    float2(0.08265103f, -0.8939569f),
    float2(0.09813362f, 0.192451f),
    float2(-0.3114384f, -0.3017288f),
    float2(0.6505286f, 0.6297367f),
    float2(-0.3022015f, 0.297664f),
    float2(-0.7386893f, -0.5215692f),
    float2(-0.3935238f, 0.7530643f),
    float2(-0.6928226f, 0.07119545f),
    float2(0.8581018f, -0.01624052f),
    float2(0.3988827f, -0.617012f),
    float2(0.2837671f, -0.179743f)};

float VxgiSqr(float x) { return x * x; }

float3 VxgiGetDistanceFromAnchor(float3 position)
{
    return abs(position - g_VxgiAbstractTracingCB.ClipmapAnchor.xyz);
}

float VxgiGetMinSampleSizeInternal(float3 distanceFromAnchor)
{
    float3 relativeDistance = distanceFromAnchor.xyz * g_VxgiAbstractTracingCB.rNearestLevel0Boundary.xyz;
    float maxRelativeDistance = max(relativeDistance.x, max(relativeDistance.y, relativeDistance.z));
    return max(2 * maxRelativeDistance, 1);
}

float VxgiGetMinSampleSizeInVoxels(float3 position)
{
    return VxgiGetMinSampleSizeInternal(VxgiGetDistanceFromAnchor(position));
}

float VxgiGetFinestVoxelSize()
{
    return g_VxgiAbstractTracingCB.FinestVoxelSize;
}

float VxgiProjectDirectionalOpacities(float3 opacity, float3 normal)
{
    return saturate(saturate(opacity.x * normal.x) + saturate(opacity.y * normal.y) + saturate(opacity.z * normal.z));
}

void VxgiGetLevelCoordinates(float3 position, float level, bool smoothSampling, out float3 opacityCoords, out float3 emittanceCoords)

{
    float4 translationParams1 = g_VxgiTranslationParameters1[int(level)];
    float4 translationParams2 = g_VxgiTranslationParameters2[int(level)];
    float4 translationParams3 = g_VxgiTranslationParameters3[int(level)];
    float4 translationParams4 = g_VxgiTranslationParameters4[int(level)];

    float3 positionInClipmap = (position - g_VxgiAbstractTracingCB.ClipmapCenter.xyz) * translationParams4.xyz + 0.5;
    float3 fVoxelCoord = frac(positionInClipmap + translationParams2.xyz);
    float3 iVoxelCoord = fVoxelCoord * translationParams3.xyz;

    if (smoothSampling)
    {

        float3 uv = iVoxelCoord + 0.5;
        float3 iuv = floor(uv);
        float3 fuv = frac(uv);
        uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);

        iVoxelCoord = uv - 0.5;
    }

    opacityCoords = (iVoxelCoord + float3(0, 0, translationParams1.x)) * g_VxgiAbstractTracingCB.rOpacityTextureSize.xyz;
    emittanceCoords = (iVoxelCoord + float3(2, 0, translationParams1.y)) * g_VxgiAbstractTracingCB.rEmittanceTextureSize.xyz;
}

float VxgiSampleOpacityTextures(float3 coords, out bool sampleEmittance)
{
    float opacity;
    float4 pos = t_Opacity.SampleLevel(s_VoxelTextureSampler, coords, 0);

    opacity = pos.x;

    sampleEmittance = pos.w != 0 ? true : false;

    return opacity;
}

float3 VxgiSampleEmittanceTextures(float3 coords, float3 direction, bool isOdd)
{
    float3 emittanceX, emittanceY, emittanceZ;

    float offsetX = direction.x > 0 ? 3 : 0;
    float offsetY = direction.y > 0 ? 4 : 1;
    float offsetZ = direction.z > 0 ? 5 : 2;

    float3 coordsX = coords + float3(offsetX * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);
    float3 coordsY = coords + float3(offsetY * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);
    float3 coordsZ = coords + float3(offsetZ * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);

    if (isOdd)
    {
        emittanceX = t_EmittanceOdd.SampleLevel(s_VoxelTextureSampler, coordsX, 0).rgb;
        emittanceY = t_EmittanceOdd.SampleLevel(s_VoxelTextureSampler, coordsY, 0).rgb;
        emittanceZ = t_EmittanceOdd.SampleLevel(s_VoxelTextureSampler, coordsZ, 0).rgb;
    }
    else
    {
        emittanceX = t_EmittanceEven.SampleLevel(s_VoxelTextureSampler, coordsX, 0).rgb;
        emittanceY = t_EmittanceEven.SampleLevel(s_VoxelTextureSampler, coordsY, 0).rgb;
        emittanceZ = t_EmittanceEven.SampleLevel(s_VoxelTextureSampler, coordsZ, 0).rgb;
    }

    return abs(direction.x) * emittanceX + abs(direction.y) * emittanceY + abs(direction.z) * emittanceZ;
}

void VxgiCalculateSampleParameters(float t, float coneFactor, float tracingStep, float minSampleSize, out float tStep, out float fLevel, out float sampleSize)
{
    float cone_ratio = coneFactor;

    float cone_current_height = t;

    float minimum_cone_diameter = minSampleSize;

    // -------

    float cone_current_diameter = max(minimum_cone_diameter, cone_ratio * cone_current_height);

    float cone_next_height = max(cone_current_height + minimum_cone_diameter, (2.0 * cone_current_height + cone_current_diameter) / max(1E-5, 2.0 - cone_ratio));

    tStep = cone_next_height - cone_current_height;

    // -------

    sampleSize = cone_current_diameter;

    tStep *= tracingStep;

    fLevel = log2(sampleSize);
}

void VxgiSampleVoxelData(float3 curPosition, float fLevel, float3 direction, float weight, bool smoothSampling, out float opacity, out float3 emittance, out bool anyEmittance)
{
    float iLevel = floor(fLevel);
    float fracLevel = fLevel - iLevel;
    float weightLow = (1.0 - fracLevel) * weight;
    float weightHigh = (fLevel > g_VxgiAbstractTracingCB.MaxMipmapLevel) ? 0 : fracLevel * weight;

    float3 opacityCoords1;
    float3 emittanceCoords1;
    float3 opacityCoords2;
    float3 emittanceCoords2;
    VxgiGetLevelCoordinates(curPosition, iLevel, smoothSampling, opacityCoords1, emittanceCoords1);
    VxgiGetLevelCoordinates(curPosition, iLevel + 1, smoothSampling, opacityCoords2, emittanceCoords2);

    bool sampleEmittance1;
    bool sampleEmittance2;
    opacity = VxgiSampleOpacityTextures(opacityCoords1.xyz, sampleEmittance1) * weightLow + VxgiSampleOpacityTextures(opacityCoords2.xyz, sampleEmittance2) * weightHigh;

    emittance = float3(0, 0, 0);
    anyEmittance = false;

    float factorLow = pow(4, iLevel) * VxgiSqr(g_VxgiAbstractTracingCB.FinestVoxelSize);
    float factorHigh = factorLow * 4;

    factorLow *= weightLow;
    factorHigh *= weightHigh;

    if ((int(iLevel) & 1) != 0)
    {
        {
            float temp = factorHigh;
            factorHigh = factorLow;
            factorLow = temp;
        };
        {
            float3 temp = emittanceCoords1;
            emittanceCoords1 = emittanceCoords2;
            emittanceCoords2 = temp;
        };
        {
            bool temp = sampleEmittance1;
            sampleEmittance1 = sampleEmittance2;
            sampleEmittance2 = temp;
        };
    }

    if (sampleEmittance1)
    {
        emittance = VxgiSampleEmittanceTextures(emittanceCoords1.xyz, direction, false) * factorLow;
        anyEmittance = true;
    }

    if (sampleEmittance2 && factorHigh > 0)
    {
        emittance += VxgiSampleEmittanceTextures(emittanceCoords2.xyz, direction, true) * factorHigh;
        anyEmittance = true;
    }
}

struct VxgiConeTracingArguments
{
    float3 firstSamplePosition;
    float3 direction;
    float coneFactor;
    float tracingStep;
    float firstSampleT;
    float maxTracingDistance;
    float ambientAttenuationFactor;
    bool enableSceneBoundsCheck;
};

VxgiConeTracingArguments VxgiDefaultConeTracingArguments()
{
    VxgiConeTracingArguments args;
    args.firstSamplePosition = float3(0, 0, 0);
    args.direction = float3(1, 0, 0);
    args.coneFactor = 1.0;
    args.tracingStep = 1.0;
    args.firstSampleT = 1.0;
    args.maxTracingDistance = 0.0;
    args.ambientAttenuationFactor = 0.0;
    args.enableSceneBoundsCheck = true;
    return args;
}

struct VxgiConeTracingResults
{
    float3 radiance;
    float ambient;
    float finalOpacity;
};

#define VCT_CLIPMAP_LEVEL_COUNT 5
// #define VCT_CLIPMAP_SIZE 128
// #define VCT_CLIPMAP_FINEST_VOXEL_SIZE 8

#define VCT_CONE_TRACING_SAMPLE_COUNT 128

float K(float a, float t)
{
    // normalized kernel k = a * exp (- a * t)
    // antiderivative K = - exp (-a * t)
    //
    // we have multiple intersection (weighted by "transparency") within the same direction
    // use the normalized kernal to combine them together

    return -exp(-a * t);
}

VxgiConeTracingResults VxgiTraceCone(VxgiConeTracingArguments args, bool enable_radiance, bool enable_ambient)
{
    const float VCT_CLIPMAP_FINEST_VOXEL_SIZE = g_VxgiAbstractTracingCB.FinestVoxelSize;
    const float VCT_CLIPMAP_SIZE = g_VxgiAbstractTracingCB.StackTextureSize;

    const float clipmap_boundary = float(VCT_CLIPMAP_FINEST_VOXEL_SIZE) * float(1 << (int(VCT_CLIPMAP_LEVEL_COUNT) - 1)) * (float(VCT_CLIPMAP_SIZE) * 0.5 - 0.5);

    float transparency = 1.0;

    float3 cone_radiance = float3(0, 0, 0);

    // \int a * \exp (-a t) T(t)  dt
    // occlusion contribution varies by distance
    float cone_ambient = 0.0;

    // K(0) = -1
    float prev_ambient_factor = -1.0;

    float3 curPosition = args.firstSamplePosition;
    float t = args.firstSampleT;

    float3 direction = args.direction;

    float maxT = args.maxTracingDistance / g_VxgiAbstractTracingCB.FinestVoxelSize;

    [loop] for (int sampleIndex = 0; sampleIndex < int(VCT_CONE_TRACING_SAMPLE_COUNT); ++sampleIndex)
    {
        float3 distanceFromAnchor = VxgiGetDistanceFromAnchor(curPosition);
        float max_distance_from_anchor = max(distanceFromAnchor.x, max(distanceFromAnchor.y, distanceFromAnchor.z));
        float minDistanceToBoundary = clipmap_boundary - max_distance_from_anchor;
        float max_relative_distance_from_anchor = max_distance_from_anchor * (1.0 / clipmap_boundary);
        float minSampleSize = max(2 * max_relative_distance_from_anchor, 1);

        float tStep;
        float fLevel;
        float sampleSize;
        VxgiCalculateSampleParameters(t, args.coneFactor, args.tracingStep, minSampleSize, tStep, fLevel, sampleSize);

        if (fLevel >= g_VxgiAbstractTracingCB.MaxMipmapLevel + 1 || (args.maxTracingDistance != 0 && t > maxT))
        {
            break;
        }

        float sampleSizeWorld = sampleSize * g_VxgiAbstractTracingCB.FinestVoxelSize;
        float rSampleSizeWorld = rcp(sampleSizeWorld);
        minDistanceToBoundary -= sampleSizeWorld;

        if (minDistanceToBoundary < 0)
        {
            break;
        }

        if (args.enableSceneBoundsCheck)
        {
            if (any((curPosition.xyz + sampleSizeWorld < g_VxgiAbstractTracingCB.SceneBoundaryLower.xyz)) || any((curPosition.xyz - sampleSizeWorld > g_VxgiAbstractTracingCB.SceneBoundaryUpper.xyz)))
                break;
        }

        if (enable_ambient)
        {
            // Newton–Leibniz theorem
            // we assume the "transparency" is the same within each segment
            float ambient_factor = K(args.ambientAttenuationFactor, t);
            cone_ambient += (ambient_factor - prev_ambient_factor) * transparency;
            prev_ambient_factor = ambient_factor;
        }

        float3 emittance;
        float alpha;
        {
            float weight = saturate(minDistanceToBoundary * rSampleSizeWorld);
            if (maxT > 0)
                weight *= saturate((maxT - t) / tStep);

            float3 adjustedPosition = curPosition;

            float opacity;
            bool anyEmittance;
            VxgiSampleVoxelData(adjustedPosition, fLevel, direction, weight, true, opacity, emittance, anyEmittance);

            // photon mapping: (1.0/(PI*r*r)) * brdf * DeltaPhi
            //
            // "brdf * DeltaPhi / area" stored in the voxel
            //
            // area is calculated by the following
            // factorLow = pow(4, iLevel) * VxgiSqr(g_VxgiAbstractTracingCB.FinestVoxelSize)
            // factorHigh = factorLow * 4
            //
            // uniform kernel
            // square shape
            // VxgiSqr(rSampleSizeWorld)
            if (anyEmittance && enable_radiance)
            {
                emittance *= VxgiSqr(rSampleSizeWorld);
            }

            // tStep: axial distance
            // sampleSize: diameter
            //
            // Beer's Law
            // transmittance
            // 1.0 - opacity = e^(-omega_t*sampleSize)
            // 1.0 - correctedOpacity = e^(-omega_t*tStep)
            //
            // correctedOpacity = 1.0 - pow(1.0 - opacity, (tStep / sampleSize))
            float correctedOpacity = saturate(1.0 - pow(saturate(1.0 - opacity), (tStep / sampleSize)));

            alpha = correctedOpacity;
        }

        if (enable_radiance)
        {
            // transparency: V_{k-1}
            //
            // emittance: premultipled alpha A_k*C_k
            //
            cone_radiance += transparency * emittance;
        }

        // [Dunn 2014] [Alex Dunn. "Transparency (or Translucency) Rendering." NVIDIA GameWorks Blog 2014.](https://developer.nvidia.com/content/transparency-or-translucency-rendering)
        // under operation
        transparency *= (1.0 - alpha);

        if (transparency < 0.0001)
        {
            break;
        }

        t += tStep;
        curPosition += tStep * g_VxgiAbstractTracingCB.FinestVoxelSize * direction;
    }

    if (enable_ambient)
    {
        // k(inf) = 0
        cone_ambient += (0.0 - K(args.ambientAttenuationFactor, t)) * transparency;
    }

    VxgiConeTracingResults result;
    result.radiance = cone_radiance;
    result.ambient = saturate(cone_ambient);
    result.finalOpacity = saturate(1.0f - transparency);
    return result;
}

//////////////////APP CODE BOUNDARY/////////////

struct GBufferParameters
{
    float4x4 viewMatrixInv;
    float4x4 projMatrixInv;
    float2 viewportOrigin;
    float2 viewportSizeInv;
};

cbuffer cBuiltinGBufferParameters : register(b0)
{
    GBufferParameters g_GBuffer;
    GBufferParameters g_PreviousGBuffer;
}

Texture2D g_Depth : register(t0);
Texture2D g_DepthPrev : register(t1);
Texture2D g_GBufferA : register(t2);
Texture2D g_GBufferAPrev : register(t3);

// A structure that you can use to keep any information in - it's passed from VxgiLoadGBufferSample to all other functions
struct VxgiGBufferSample
{
    float viewDepth;
    float3 worldPos;
    float3 normal;
    float3 cameraPos;
    float3 viewRight;
    float3 viewUp;
    float roughness;
};

// Loads a sample from the current or previous G-buffer at given window coordinates.
// If onlyPosition is true, the function should skip loading and processing anything else, for performance.
bool VxgiLoadGBufferSample(float2 windowPos, uint viewIndex, bool previous, bool onlyPosition, out VxgiGBufferSample result)
{
    float4x4 viewMatrixInv;
    float4x4 projMatrixInv;
    float2 viewportOrigin;
    float2 viewportSizeInv;
    float4 GBufferA;
    float Depth;
    [branch] if (previous)
    {
        viewMatrixInv = g_PreviousGBuffer.viewMatrixInv;
        projMatrixInv = g_PreviousGBuffer.projMatrixInv;
        viewportOrigin = g_PreviousGBuffer.viewportOrigin;
        viewportSizeInv = g_PreviousGBuffer.viewportSizeInv;
        GBufferA = g_GBufferAPrev[int2(windowPos)];
        Depth = g_DepthPrev[int2(windowPos)].r;
    }
    else
    {
        viewMatrixInv = g_GBuffer.viewMatrixInv;
        projMatrixInv = g_GBuffer.projMatrixInv;
        viewportOrigin = g_GBuffer.viewportOrigin;
        viewportSizeInv = g_GBuffer.viewportSizeInv;
        GBufferA = g_GBufferA[int2(windowPos)];
        Depth = g_Depth[int2(windowPos)].r;
    }

    float2 UV = (windowPos - viewportOrigin) * viewportSizeInv;
    float4 clipPos = float4(UV.x * 2.0 - 1.0, 1.0 - UV.y * 2.0, Depth, 1.0);
    [branch] if (any(abs(clipPos.xyz) > abs(clipPos.w)))
    {
        return false;
    }

    float4 viewPosV4 = mul(clipPos, projMatrixInv);
    float3 viewPos = viewPosV4.xyz /= viewPosV4.w;
    result.viewDepth = viewPos.z;

    result.worldPos = mul(float4(viewPos, 1.0), viewMatrixInv).xyz;

    result.normal = GBufferA.xyz;

    result.cameraPos = mul(float4(0.0, 0.0, 0.0, 1.0), viewMatrixInv).xyz;
    result.viewRight = mul(float4(1.0, 0.0, 0.0, 0.0), viewMatrixInv).xyz;
    result.viewUp = mul(float4(0.0, 1.0, 0.0, 0.0), viewMatrixInv).xyz;

    result.roughness = GBufferA.w;

    return true;
}

// Returns the view depth or distance to camera for a given sample
float VxgiGetGBufferViewDepth(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.viewDepth;
}

// Returns the world position of a given sample
float3 VxgiGetGBufferWorldPos(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.worldPos;
}

// Returns the world space normal for a given sample
float3 VxgiGetGBufferNormal(VxgiGBufferSample gbufferSample)
{
    return gbufferSample.normal;
}

// Returns the world space tangent for a given sample.
// Tangents are used by VXGI to calculate directions for diffuse cones. Using tangents that originate from meshes
// can help avoid seams on diffuse illumination where computed tangents have a discontinuity.
float3 VxgiGetGBufferTangent(VxgiGBufferSample gbufferSample)
{
    float3 normal = gbufferSample.normal;

    float3 absNormal = abs(normal);
    float maxComp = max(absNormal.x, max(absNormal.y, absNormal.z));

    float3 tangent;
    [branch] if (maxComp == absNormal.x)
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

    return (normalize(tangent));
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
    VxgiSpecularShaderParameters result = VxgiGetDefaultSpecularShaderParameters();
    result.roughness = min(gbufferSample.roughness, 0.75);
    result.viewDirection = normalize(gbufferSample.worldPos - gbufferSample.cameraPos);
    return result;
}

// Returns the area light settings for the current sample.
VxgiAreaLightShaderParameters VxgiGetGBufferAreaLightShaderParameters(VxgiGBufferSample gbufferSample)
{
    VxgiAreaLightShaderParameters result = VxgiGetDefaultAreaLightShaderParameters();
    result.roughness = gbufferSample.roughness;
    result.viewDirection = normalize(gbufferSample.worldPos - gbufferSample.cameraPos);
    return result;
}

// Return true if SSAO should be computed for the sample;
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

float2 VxgiGBufferMapWindowToClip(uint viewIndex, float2 windowPos)
{
    float2 UV = (windowPos - g_GBuffer.viewportOrigin.xy) * g_GBuffer.viewportSizeInv.xy;

    float2 clipPos;
    clipPos.x = UV.x * 2 - 1;
    clipPos.y = 1 - UV.y * 2;
    return clipPos;
}

// Maps a given sample to a different view in the same or previous frame and returns the window coordinates.
// Returns true if a matching surface exists in the other view, false otherwise.
bool VxgiGetGBufferPositionInOtherView(VxgiGBufferSample gbufferSample, uint viewIndex, bool previous, out float2 prevWindowPos)
{
    prevWindowPos = float2(0.0, 0.0);
    return false;
}

// Returns irradiance from an environment map for a surface at 'surfacePos' coming from a cone
// looking in 'coneDirection' with the cone factor 'coneFactor'.
float3 VxgiGetEnvironmentIrradiance(float3 surfacePos, float3 coneDirection, float coneFactor, bool isSpecular)
{
    return float3(0.0, 0.0, 0.0);
}

void VxgiGetGBufferRightAndUp(VxgiGBufferSample gbufferSample, out float3 right, out float3 up)
{
    right = gbufferSample.viewRight;
    up = gbufferSample.viewUp;
}

//////////////////APP CODE BOUNDARY/////////////

struct VxgiBuiltinTracingConstants
{
    float4x4 ViewProjMatrix;
    float4x4 ViewProjMatrixInv;
    float4 PreViewTranslation;
    float4 DownsampleScale;
    float4 RefinementGridResolution;
    float4 InternalParameters;
    uint4 NormalizationModes;
    float4 NeighborhoodClampingWidths;
    float4 TemporalReprojectionWeights;
    float4 ReprojectionCombinedWeightScales;
    int2 PixelToSave;
    int2 RandomOffset;
    float2 GridOrigin;
    float2 GbufferSizeInv;
    uint ViewIndex;
    float ConeFactor;
    int MaxSamples;
    int NumCones;
    float rNumCones;
    float EmittanceScale;
    float ReprojectionDepthWeightScale;
    float ReprojectionNormalWeightExponent;
    float InterpolationWeightThreshold;
    uint EnableRefinement;
    float AmbientDistanceDarkening;
    float AmbientNormalizationFactor;
    int ViewReprojectionSource;
    float ViewReprojectionWeightThreshold;
    float PerPixelOffsetScale;
    uint OpacityLookback;
    float DiffuseSoftness;
    float DepthDeltaSign;
    uint EnableConeJitter;
};

cbuffer cBuiltinTracingParameters : REGISTER(b, VXGI_VIEW_TRACING_CB_SLOT)
{
    VxgiBuiltinTracingConstants g_VxgiBuiltinTracingCB;
};

struct VxgiSsaoConstants
{
    float4x4 ViewMatrix;
    uint2 ViewOrigin;
    uint2 ViewSize;
    float2 GbufferSizeInv;
    float2 ClipToView;
    float2 RadiusToClip;
    uint ViewIndex;
    float SurfaceBias;
    float RadiusWorld;
    float rBackgroundViewDepth;
    float CoarseAO;
    float PowerExponent;
};

cbuffer cSSAOParameters : REGISTER(b, VXGI_VIEW_TRACING_CB_SLOT)
{
    VxgiSsaoConstants g_VxgiSsaoCB;
};

bool IsInfOrNaN(float x)
{
    uint exponent = asuint(x) & 0x7f800000;
    return exponent == 0x7f800000;
}

bool IsInfOrNaN(float4 v)
{
    return IsInfOrNaN(v.x) || IsInfOrNaN(v.y) || IsInfOrNaN(v.z) || IsInfOrNaN(v.w);
}

struct ViewSampleParameters
{
    float2 referencePos;
    float4 sampleWeights;
    float totalWeight;
};

ViewSampleParameters PrepareViewSample(
    VxgiGBufferSample gbufferSample,
    uint sourceViewIndex,
    bool sourcePreviousFrame)
{
    ViewSampleParameters result;
    result.totalWeight = 0;
    result.referencePos = float2scalar(0);
    result.sampleWeights = float4scalar(0);

    float2 prevWindowPos;
    if (!VxgiGetGBufferPositionInOtherView(gbufferSample, sourceViewIndex, sourcePreviousFrame, prevWindowPos))
        return result;

    result.referencePos = floor(prevWindowPos - float2scalar(0.5));

    float3 newNormal = VxgiGetGBufferNormal(gbufferSample);
    float3 newPos = VxgiGetGBufferWorldPos(gbufferSample);

    int index = 0;
    [unroll] for (float y = 0.5; y < 2; y++)
        [unroll] for (float x = 0.5; x < 2; x++)
    {
        float2 samplePos = result.referencePos + float2(x, y);

        float gbufferWeight = 0;
        VxgiGBufferSample oldSample;
        if (VxgiLoadGBufferSample(samplePos, sourceViewIndex, sourcePreviousFrame, false, oldSample))
            gbufferWeight = 1;

        float3 oldNormal = VxgiGetGBufferNormal(oldSample);
        float3 oldPos = VxgiGetGBufferWorldPos(oldSample);

        float depthWeight = saturate(1.0 - abs(dot(oldPos - newPos, newNormal)) * g_VxgiBuiltinTracingCB.ReprojectionDepthWeightScale);
        float normalWeight = saturate(pow(saturate(dot(newNormal, oldNormal)), g_VxgiBuiltinTracingCB.ReprojectionNormalWeightExponent));
        float bilerpWeight = saturate((1.0 - abs(prevWindowPos.x - samplePos.x)) * (1.0 - abs(prevWindowPos.y - samplePos.y)));
        float weight = depthWeight * normalWeight * bilerpWeight * gbufferWeight;

        if (!IsInfOrNaN(weight))
        {
            result.totalWeight += weight;
            result.sampleWeights[index] = weight;
        }

        index += 1;
    }

    return result;
}

float4 SampleViewTexture(
    ViewSampleParameters params,
    Texture2D tex)
{
    float4 result = 0;

    int index = 0;
    [unroll] for (float y = 0.5; y < 2; y++)
        [unroll] for (float x = 0.5; x < 2; x++)
    {
        int2 samplePos = int2(params.referencePos + float2(x, y));
        float4 color = tex[samplePos].rgba;

        if (!IsInfOrNaN(color))
        {
            result += color *= params.sampleWeights[index];
        }

        index += 1;
    }

    return result;
}

float4 SampleViewTextureWithClamping(
    ViewSampleParameters params,
    Texture2D tex,
    float4 colorMin,
    float4 colorMax)
{
    float4 result = 0;

    int index = 0;
    [unroll] for (float y = 0.5; y < 2; y++)
        [unroll] for (float x = 0.5; x < 2; x++)
    {
        int2 samplePos = int2(params.referencePos + float2(x, y));
        float4 color = tex[samplePos].rgba;

        if (!IsInfOrNaN(color))
        {
            color = max(colorMin, min(colorMax, color));
            result += color *= params.sampleWeights[index];
        }

        index += 1;
    }

    return result;
}

float4 SampleViewImage(
    ViewSampleParameters params,
    RWTexture2D<float4> img)
{
    float4 result = 0;

    int index = 0;
    [unroll] for (float y = 0.5; y < 2; y++)
        [unroll] for (float x = 0.5; x < 2; x++)
    {
        int2 samplePos = int2(params.referencePos + float2(x, y));
        float4 color = img[samplePos].rgba;

        if (!IsInfOrNaN(color))
        {
            result += color *= params.sampleWeights[index];
        }

        index += 1;
    }

    return result;
}

float2 GetRotatedGridOffset(float2 pixelCoord)
{

    float2 remainders = floor(frac(pixelCoord * g_VxgiBuiltinTracingCB.DownsampleScale.zw) * g_VxgiBuiltinTracingCB.DownsampleScale.xy);
    return float2(remainders.y, g_VxgiBuiltinTracingCB.DownsampleScale.x - remainders.x - 1);
}

float2 CoarsePosToGBufferPos(float2 coarsePixelPos)
{
    return coarsePixelPos * g_VxgiBuiltinTracingCB.DownsampleScale.xy +
           GetRotatedGridOffset(coarsePixelPos + g_VxgiBuiltinTracingCB.RandomOffset.xy) +
           float2scalar(0.5);
}

void AdjustConePosition(
    float3 surfacePosition,
    float4 initialOffsetParams,
    float4 sampleNormalParams,
    inout VxgiConeTracingArguments args)
{
    float t = args.tracingStep * 5.0f;

    float tStep, fLevel, sampleSize, initialOffset;

    float minSampleSize = VxgiGetMinSampleSizeInVoxels(surfacePosition);
    VxgiCalculateSampleParameters(t, args.coneFactor, args.tracingStep, minSampleSize, tStep, fLevel, sampleSize);

    initialOffset = minSampleSize * initialOffsetParams.y + initialOffsetParams.x;

    initialOffset += initialOffsetParams.x * sampleNormalParams.w;

    initialOffset += initialOffsetParams.w;

    args.firstSampleT = initialOffset;
    args.firstSamplePosition = surfacePosition + normalize(lerp(args.direction, sampleNormalParams.xyz, initialOffsetParams.z)) * (VxgiGetFinestVoxelSize() * initialOffset);
}

float InfNaNOutputGuard(float x)
{
    return IsInfOrNaN(x) ? 0.f : x;
}

float4 InfNaNOutputGuard(float4 v)
{
    return float4(
        InfNaNOutputGuard(v.x),
        InfNaNOutputGuard(v.y),
        InfNaNOutputGuard(v.z),
        InfNaNOutputGuard(v.w));
}

float VxgiGetConfidence(float3 worldPos)
{
    float3 distanceFromAnchor = VxgiGetDistanceFromAnchor(worldPos.xyz);
    float3 distanceToBoundary = g_VxgiAbstractTracingCB.NearestLevelBoundary.xyz - distanceFromAnchor.xyz;
    float3 relativeDistance = distanceToBoundary.xyz * g_VxgiAbstractTracingCB.rClipmapSizeWorld.xyz;
    float minRelativeDistance = min(relativeDistance.x, min(relativeDistance.y, relativeDistance.z));
    float confidence = saturate(minRelativeDistance * 4);
    return confidence;
}

float4 NormalizeInput(float4 input, uint mode)
{
    if (mode == 1)
    {
        if (input.y > 0 && input.y != 1)
        {
            input.x /= input.y;
            input.y = 1;
        }

        if (input.w > 0 && input.w != 1)
        {
            input.z /= input.w;
            input.w = 1;
        }
    }
    else if (mode == 2)
    {
        if (input.w > 0 && input.w != 1)
        {
            input.xyz /= input.w;
            input.w = 1;
        }
    }

    return input;
}

struct SampleData
{
    float3 worldSamplePos;
    float mipLevel;
    float3 sampledEmittance;
    float accumulatedOcclusion;
    float3 direction;
    int coneIndex;
    int sampleIndex;
    float sampleT;
};

struct ConeData
{
    float3 startPos;
    float3 direction;
    int coneIndex;
    float weight;
    float maxTracingDistance;
};

Texture2DArray t_ConeDirectionMap : REGISTER(t, VXGI_VIEW_TRACING_TEXTURE_1_SLOT);

float2 hammersley_2d(uint sample_index, uint sample_count)
{
    // PBR Book V3: ["7.4.1 Hammersley and Halton Sequences"](https://www.pbr-book.org/3ed-2018/Sampling_and_Reconstruction/The_Halton_Sampler#HammersleyandHaltonSequences)
    // PBR Book V4: ["8.6.1 Hammersley and Halton Points"](https://pbr-book.org/4ed/Sampling_and_Reconstruction/Halton_Sampler#HammersleyandHaltonPoints)
    // UE: [Hammersley](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L34)
    // U3D: [Hammersley2d](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/Sampling/Hammersley.hlsl#L415)

    const float UINT32_MAX = 4294967296.0;

    const float xi_1 = float(sample_index) / float(sample_count);
    const float xi_2 = reversebits(sample_index) * (1.0 / UINT32_MAX);

    return float2(xi_1, xi_2);
}

float3 normalized_clamped_cosine_sample_omega_i(float2 xi)
{
    // PBR Book V3: [13.6.3 Cosine-Weighted Hemisphere Sampling](https://www.pbr-book.org/3ed-2018/Monte_Carlo_Integration/2D_Sampling_with_Multidimensional_Transformations#Cosine-WeightedHemisphereSampling)
    // PBRT-V3: [CosineSampleHemisphere](https://github.com/mmp/pbrt-v3/blob/book/src/core/sampling.h#L155)
    // PBR Book V4: [A.5.3 Cosine-Weighted Hemisphere Sampling](https://www.pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions#Cosine-WeightedHemisphereSampling)
    // PBRT-V4: [SampleCosineHemisphere](https://github.com/mmp/pbrt-v4/blob/master/src/pbrt/util/sampling.h#L409)
    // UE: [CosineSampleHemisphere](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L241)
    // U3D: [SampleHemisphereCosine](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/Sampling/Sampling.hlsl#L157)

    const float M_PI = 3.141592653589793238462643;

    float2 d;
    {
        // Map uniform random numbers to $[-1, 1]^2$
        float2 u_offset = 2.0 * xi - float2(1.0, 1.0);

        [branch] if (0.0 == u_offset.x && 0.0 == u_offset.y)
        {
            // Handle degeneracy at the origin
            d = float2(0.0, 0.0);
        }
        else
        {
            // Apply concentric mapping to point
            float r;
            float theta;

            [branch] if (abs(u_offset.x) > abs(u_offset.y))
            {
                r = u_offset.x;
                theta = (M_PI / 4.0) * (u_offset.y / u_offset.x);
            }
            else
            {
                r = u_offset.y;
                theta = (M_PI / 2.0) - (M_PI / 4.0) * (u_offset.x / u_offset.y);
            }

            d = r * float2(cos(theta), sin(theta));
        }
    }

    float z = sqrt(max(0.0, 1.0 - dot(d, d)));

    float3 omega_i = float3(d.x, d.y, z);
    return omega_i;
}

float normalized_clamped_cosine_pdf_omega_i(float NdotL)
{
    // PBR Book V3: [13.6.3 Cosine-Weighted Hemisphere Sampling](https://www.pbr-book.org/3ed-2018/Monte_Carlo_Integration/2D_Sampling_with_Multidimensional_Transformations#Cosine-WeightedHemisphereSampling)
    // PBRT-V3: [CosineHemispherePdf](https://github.com/mmp/pbrt-v3/blob/book/src/core/sampling.h#L161)
    // PBR Book V4: [A.5.3 Cosine-Weighted Hemisphere Sampling](https://www.pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions#Cosine-WeightedHemisphereSampling)
    // PBRT-V4: [CosineHemispherePDF](https://github.com/mmp/pbrt-v4/blob/master/src/pbrt/util/sampling.h#L415)
    // UE: [CosineSampleHemisphere](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L241)
    // U3D: [SampleHemisphereCosine](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/Sampling/Sampling.hlsl#L157)

    const float M_PI = 3.141592653589793238462643;

    float cos_theta_i = NdotL;

    float pdf = cos_theta_i * (1.0 / M_PI);

    return pdf;
}

void main(VxgiFullScreenQuadOutput quadIn,
          in float4 gl_FragCoord : SV_Position,
          out float4 o_color : SV_Target0,
          out float4 o_confidence : SV_Target1)

{
    const int VCT_DIFFUSE_CONE_TRACING_CONE_COUNT = g_VxgiBuiltinTracingCB.NumCones;

    o_color = float4scalar(0);

    o_confidence = float4scalar(0);

    float2 gbufferSamplePosition;
    if (all((g_VxgiBuiltinTracingCB.DownsampleScale.xy > float2(1.0, 1.0))))
        gbufferSamplePosition = CoarsePosToGBufferPos(floor(gl_FragCoord.xy));
    else
        gbufferSamplePosition = gl_FragCoord.xy;

    VxgiGBufferSample gbufferSample;
    if (!VxgiLoadGBufferSample(gbufferSamplePosition, g_VxgiBuiltinTracingCB.ViewIndex, false, false, gbufferSample))
        return;

    VxgiDiffuseShaderParameters params = VxgiGetGBufferDiffuseShaderParameters(gbufferSample);

    float3 samplePosition = VxgiGetGBufferWorldPos(gbufferSample);
    float confidence = VxgiGetConfidence(samplePosition);

    if (confidence == 0)
        return;

    float3 N = VxgiGetGBufferNormal(gbufferSample);

    float3 T;
    float3 B;
    {
        // Since the clamped cosine is isotropic, the outgoing direction V is **usually** assumed to be in the XOZ plane.
        // Actually the clamped cosine is **also** radially symmetric and the tangent direction is arbitrary.
        // UE: [GetTangentBasis](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L12)
        // U3D: [GetLocalFrame](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl#L408)

        // NOTE: "local_z" should be normalized.
        float3 local_z = N;

        float x = local_z.x;
        float y = local_z.y;
        float z = local_z.z;

        float sz = z >= 0.0 ? 1.0 : -1.0;
        float a = 1.0 / (sz + z);
        float ya = y * a;
        float b = x * ya;
        float c = x * sz;

        float3 local_x = float3(c * x * a - 1, sz * b, c);
        float3 local_y = float3(b, y * ya - sz, y);

        T = local_x;
        B = local_y;
    }

    int cone_index = quadIn.instanceID;

    float3 omega_i = normalized_clamped_cosine_sample_omega_i(hammersley_2d(cone_index, VCT_DIFFUSE_CONE_TRACING_CONE_COUNT));

    float3 L = normalize(T * omega_i.x + B * omega_i.y + N * omega_i.z);

    float pdf = normalized_clamped_cosine_pdf_omega_i(saturate(omega_i.z));

    // "20.4 Mipmap Filtered Samples" of GPU Gems 3
    // UE: [SolidAngleSample](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/ReflectionEnvironmentShaders.usf#L414)
    // U3D: [omegaS](https://github.com/Unity-Technologies/Graphics/blob/v10.8.0/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl#L500)
    float omega_s = (1.0 / float(VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)) / pdf;

    // Omega = 2 PI (1 - cos theta) // theta: cone half-angle
    float cone_cos_theta = 1.0 - min(omega_s / (2.0 * VxgiPI), 1.0);
    float cone_tan_theta = sqrt(max(0.0, 1.0 - cone_cos_theta * cone_cos_theta)) / max(cone_cos_theta, 1E-5);
    float cone_factor = cone_tan_theta * 2.0;

    float minSampleSize = VxgiGetMinSampleSizeInVoxels(samplePosition.xyz);
    float tracingStep = max(0.05, params.tracingStep);

    VxgiConeTracingArguments args = VxgiDefaultConeTracingArguments();
    args.direction = L;
    args.coneFactor = cone_factor;
    args.tracingStep = tracingStep;
    args.enableSceneBoundsCheck = true;

    args.ambientAttenuationFactor = 2.3 * g_VxgiAbstractTracingCB.FinestVoxelSize / max(g_VxgiAbstractTracingCB.FinestVoxelSize, params.ambientRange) * pow(minSampleSize, g_VxgiBuiltinTracingCB.AmbientDistanceDarkening);

    float perPixelOffset = 0.5 * g_VxgiBuiltinTracingCB.PerPixelOffsetScale * minSampleSize * tracingStep;
    float4 offsetParams = float4(params.initialOffsetBias, params.initialOffsetDistanceFactor, 1.0 - g_VxgiBuiltinTracingCB.DiffuseSoftness, perPixelOffset);

    AdjustConePosition(samplePosition.xyz, offsetParams, float4(N, 0), args);

    VxgiConeTracingResults cone = VxgiTraceCone(args, true, true);
    // radiosity += (1.0 - cone.finalOpacity) * VxgiGetEnvironmentIrradiance(samplePosition, rayDir, g_VxgiBuiltinTracingCB.ConeFactor, false) * g_VxgiBuiltinTracingCB.rNumCones;
    float3 L_i = cone.radiance;
    float3 V_i = cone.ambient;

    // monte carlo estimate: 1/N * 1/PI * albedo * L_i * cos_theta_i / (1/PI * cos_theta_i) = 1/N * albedo * L_i
    float3 radiance = (1.0 / float(VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)) * L_i;

    // monte carlo estimate: 1/N * 1/PI * V_i * cos_theta_i / (1/PI * cos_theta_i) = 1/N * V_i
    float ambient = (1.0 / float(VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)) * V_i;

    o_color.rgba = float4(radiance, ambient);
    o_color = InfNaNOutputGuard(o_color);

    o_confidence.x = confidence * g_VxgiBuiltinTracingCB.rNumCones;
    o_confidence.x = InfNaNOutputGuard(o_confidence.x);
}
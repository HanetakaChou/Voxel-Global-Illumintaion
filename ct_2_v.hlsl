#define REGISTER(type, slot) register(type##slot)
#define NV_SHADER_EXTN_SLOT u0
#define VXGI_VOXELIZE_CB_SLOT 1
#define VXGI_ALLOCATION_MAP_UAV_SLOT 1
#define VXGI_OPACITY_UAV_SLOT 2
#define VXGI_EMITTANCE_EVEN_UAV_SLOT 3
#define VXGI_EMITTANCE_ODD_UAV_SLOT 4
#define VXGI_IRRADIANCE_MAP_SRV_SLOT 2
#define VXGI_IRRADIANCE_MAP_SAMPLER_SLOT 2
#define VXGI_INVALIDATE_BITMAP_SRV_SLOT 3

#pragma pack_matrix(row_major)

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

uint3 VxgiPackEmittanceForAtomic(float3 v)
{
    float fixedPointScale = 1 << 20;
    return uint3(v.rgb * fixedPointScale);
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

struct VxgiVoxelizationConstants
{
    float4 GridCenterPrevious;
    float4 rGridWorldSizePrevious;
    int4 ToroidalOffset;
    VxgiBox4f ScissorRegionsClipSpaceOpacity[5];
    VxgiBox4f ScissorRegionsClipSpaceEmittance[5];
    int4 TextureToAmapTranslation[5];
    float4 ResolutionFactors[5];
    uint4 AllocationMapSize;
    float4 IrradianceMapSize;
    uint4 ClipLevelSize;
    float4 CullingScale;
    uint DirectionStride;
    uint ChannelStride;
    uint LevelStride;
    uint ClipLevelMask;
    uint MaxClipLevel;
    float EmittanceStorageScale;
    uint UseIrradianceMap;
    uint PersistentVoxelData;
    uint UseInvalidateBitmap;
    uint CanWriteEmittance;
};

cbuffer VoxelizationCB : REGISTER(b, VXGI_VOXELIZE_CB_SLOT)
{
    VxgiVoxelizationConstants g_VxgiVoxelizationCB;
};

struct VxgiVoxelizationGSOutputData
{
    nointerpolation uint gl_ViewportIndex : SV_ViewportArrayIndex;
};

struct VxgiVoxelizationPSInputData
{
    VxgiVoxelizationGSOutputData GSData;
    float4 gl_FragCoord : SV_Position;
    uint gl_SampleMaskIn : SV_Coverage;
};

static const float2 g_VxgiSamplePositions[] = {
    float2(0.0625, -0.1875), float2(-0.0625, 0.1875), float2(0.3125, 0.0625), float2(-0.1875, -0.3125),
    float2(-0.3125, 0.3125), float2(-0.4375, 0.0625), float2(0.1875, 0.4375), float2(0.4375, -0.4375),
    float2(0, 0)};

bool VxgiCanWriteEmittance()
{

    return g_VxgiVoxelizationCB.CanWriteEmittance != 0;
}

RWTexture3D<uint> u_AllocationMap : REGISTER(u, VXGI_ALLOCATION_MAP_UAV_SLOT);

RWTexture3D<uint> u_EmittanceEven : REGISTER(u, VXGI_EMITTANCE_EVEN_UAV_SLOT);
RWTexture3D<uint> u_EmittanceOdd : REGISTER(u, VXGI_EMITTANCE_ODD_UAV_SLOT);

RWTexture3D<uint> u_Opacity : REGISTER(u, VXGI_OPACITY_UAV_SLOT);

SamplerState s_IrradianceMapSampler : REGISTER(s, VXGI_IRRADIANCE_MAP_SAMPLER_SLOT);
Texture3D<float4> t_IrradianceMap : REGISTER(t, VXGI_IRRADIANCE_MAP_SRV_SLOT);

void VxgiGetLayeredCoverage(float inputZ, uint coverage, float depthSign, float inputOpacity, out float4 layersForOpacity, out float4 layersForEmittance)
{
    layersForOpacity = float4scalar(0);
    layersForEmittance = float4scalar(0);

    if (inputOpacity <= 1)
    {
        float2 dZ = float2(ddx(inputZ), ddy(inputZ));
        float fracZ = frac(inputZ);

        [unroll] for (int nSample = 0; nSample < 8; nSample++)
        {
            if ((coverage & (1 << nSample)) != 0)
            {
                float relativeZ = fracZ + dot(dZ, g_VxgiSamplePositions[nSample]);
                const float delta = 1.0f / 8;

                layersForEmittance.x += delta * saturate(1 - abs(relativeZ + 0.5));
                layersForEmittance.y += delta * saturate(1 - abs(relativeZ - 0.5));
                layersForEmittance.z += delta * saturate(1 - abs(relativeZ - 1.5));
            }
        }

        layersForOpacity = layersForEmittance;
    }
    else
    {
        float extraDepth = 0.5 * saturate(inputOpacity - 1);
        float e1 = extraDepth + 1;
        float e2 = extraDepth * depthSign;

        float2 dZ = float2(ddx(inputZ), ddy(inputZ));
        float fracZ = frac(inputZ);
        if (depthSign < 0)
            fracZ += 1;

        [unroll] for (int nSample = 0; nSample < 8; nSample++)
        {
            if ((coverage & (1 << nSample)) != 0)
            {
                float relativeZ = fracZ + dot(dZ, g_VxgiSamplePositions[nSample]);
                const float delta = 1.0f / 8;

                layersForEmittance.x += delta * saturate(1 - abs(relativeZ + 0.5));
                layersForEmittance.y += delta * saturate(1 - abs(relativeZ - 0.5));
                layersForEmittance.z += delta * saturate(1 - abs(relativeZ - 1.5));
                layersForEmittance.w += delta * saturate(1 - abs(relativeZ - 2.5));

                layersForOpacity.x += delta * saturate(e1 - abs(relativeZ + 0.5 + e2));
                layersForOpacity.y += delta * saturate(e1 - abs(relativeZ - 0.5 + e2));
                layersForOpacity.z += delta * saturate(e1 - abs(relativeZ - 1.5 + e2));
                layersForOpacity.w += delta * saturate(e1 - abs(relativeZ - 2.5 + e2));
            }
        }
    }
}

float VxgiGetNormalProjection(float3 normal, uint direction)
{
    switch (direction)
    {
    case 0:
        return normal.x;
    case 3:
        return -normal.x;
    case 1:
        return normal.y;
    case 4:
        return -normal.y;
    case 2:
        return normal.z;
    case 5:
        return -normal.z;
    }
}

void VxgiWriteVoxel(int3 coordinates, int clipLevel, bool writeOpacity, bool writeEmittance, float perVoxelScaleOpacity, float perVoxelScaleEmittance, float opacity, float3 emittanceFront, float3 emittanceBack, float3 normal, inout int prevPageCoordinatesHash, inout uint page)
{
    emittanceFront = max(emittanceFront * perVoxelScaleEmittance, 0);
    emittanceBack = max(emittanceBack * perVoxelScaleEmittance, 0);
    opacity = saturate(opacity * perVoxelScaleOpacity);

    if (opacity == 0)
        writeOpacity = false;

    bool emittanceFrontPresent = any(emittanceFront != 0);
    bool emittanceBackPresent = any(emittanceBack != 0);

    if (!emittanceFrontPresent && !emittanceBackPresent)
        writeEmittance = false;

    if (!writeOpacity && !writeEmittance)
    {
        return;
    }

    int3 tmp = coordinates.xyz & ~(int3(g_VxgiVoxelizationCB.ClipLevelSize.xyz) - int3scalar(1));
    if ((tmp.x | tmp.y | tmp.z) != 0)
    {
        return;
    }

    {
        int4 translation = g_VxgiVoxelizationCB.TextureToAmapTranslation[clipLevel];
        int3 pageCoordinates = int3(((coordinates >> translation.w) + translation.xyz) & (g_VxgiVoxelizationCB.AllocationMapSize.xyz - 1));
        int pageCoordinatesHash = pageCoordinates.x + pageCoordinates.y + pageCoordinates.z;

        if (pageCoordinatesHash != prevPageCoordinatesHash)
            page = u_AllocationMap[pageCoordinates].x;

        prevPageCoordinatesHash = pageCoordinatesHash;

        if ((page & 0x04) == 0)
            writeOpacity = false;

        if ((page & 0x08) == 0)
            writeEmittance = false;

        if (!writeOpacity && !writeEmittance)
        {
            return;
        }

        uint newPage = page;
        if (writeOpacity || writeEmittance)
            newPage |= 0x01;
        if (writeEmittance)
            newPage |= 0x02;

        if (page != newPage)
        {
            InterlockedOr(u_AllocationMap[pageCoordinates], newPage);
        }

        page = newPage;
    }

    int3 voxelCoords = int3(VxgiGetToroidalAddress(coordinates, g_VxgiVoxelizationCB.ToroidalOffset.xyz >> clipLevel, g_VxgiVoxelizationCB.ClipLevelSize.xyz));
    int3 opacityAddress = voxelCoords + int3(0, 0, int(g_VxgiVoxelizationCB.LevelStride) * clipLevel + 1);

    if (writeOpacity)
    {
        InterlockedAdd(u_Opacity[opacityAddress], uint(opacity * 1023));
    }

    if (writeEmittance)
    {
        int3 address = voxelCoords + int3(2, 0, int(g_VxgiVoxelizationCB.LevelStride) * (clipLevel >> 1) + 1);

        emittanceFront.rgb *= g_VxgiVoxelizationCB.EmittanceStorageScale;
        emittanceBack.rgb *= g_VxgiVoxelizationCB.EmittanceStorageScale;

        [unroll] for (uint direction = 0; direction < 6; ++direction)
        {
            float multiplier = VxgiGetNormalProjection(normal, direction);
            bool emittancePresent = (multiplier > 0) ? emittanceFrontPresent : emittanceBackPresent;

            if (multiplier != 0 && emittancePresent)
            {
                int3 channelAddress = address;
                float3 emittanceFrontOrBack = (multiplier > 0) ? emittanceFront : emittanceBack;
                uint3 packedEmittance = VxgiPackEmittanceForAtomic(emittanceFrontOrBack * abs(multiplier));

                if (VxgiIsOdd(clipLevel))
                {
                    InterlockedAdd(u_EmittanceOdd[channelAddress], packedEmittance.r);
                    channelAddress.y += int(g_VxgiVoxelizationCB.ChannelStride);
                    InterlockedAdd(u_EmittanceOdd[channelAddress], packedEmittance.g);
                    channelAddress.y += int(g_VxgiVoxelizationCB.ChannelStride);
                    InterlockedAdd(u_EmittanceOdd[channelAddress], packedEmittance.b);
                }
                else
                {
                    InterlockedAdd(u_EmittanceEven[channelAddress], packedEmittance.r);
                    channelAddress.y += int(g_VxgiVoxelizationCB.ChannelStride);
                    InterlockedAdd(u_EmittanceEven[channelAddress], packedEmittance.g);
                    channelAddress.y += int(g_VxgiVoxelizationCB.ChannelStride);
                    InterlockedAdd(u_EmittanceEven[channelAddress], packedEmittance.b);
                }
            }

            address.x += int(g_VxgiVoxelizationCB.DirectionStride);
        }
    }
}

void VxgiStoreVoxelizationData(VxgiVoxelizationPSInputData IN, float3 worldNormal, float opacity, float3 emissiveColorFront, float3 emissiveColorBack)
{
    bool writeEmittance = VxgiCanWriteEmittance() && (any(emissiveColorFront.rgb != float3scalar(0)) || any(emissiveColorBack.rgb != float3scalar(0)));
    bool writeOpacity = (opacity > 0);

    if (!writeEmittance && !writeOpacity)
        return;

    float fVP = float(IN.GSData.gl_ViewportIndex) * 0.334;
    int projectionIndex = int(floor(frac(fVP) * 3));
    int clipLevel = int(floor(fVP));

    float inputZ = IN.gl_FragCoord.z;

    float zResolution = (projectionIndex == 0)   ? g_VxgiVoxelizationCB.ClipLevelSize.z
                        : (projectionIndex == 1) ? g_VxgiVoxelizationCB.ClipLevelSize.y
                                                 : g_VxgiVoxelizationCB.ClipLevelSize.x;

    float unscaledZ = inputZ;

    inputZ *= (1 << (g_VxgiVoxelizationCB.MaxClipLevel - clipLevel));
    inputZ = inputZ * 0.5 + 0.5;
    inputZ *= zResolution;

    float resolutionFactor = g_VxgiVoxelizationCB.ResolutionFactors[clipLevel].x;
    float rResolutionFactor = g_VxgiVoxelizationCB.ResolutionFactors[clipLevel].y;

    float3 texelSpace = float3(IN.gl_FragCoord.xy, inputZ);
    texelSpace.xy *= rResolutionFactor;

    int3 offsetDir;
    float2 levelSize;
    VxgiBox4f scissorRegionOpacity = g_VxgiVoxelizationCB.ScissorRegionsClipSpaceOpacity[clipLevel];
    VxgiBox4f scissorRegionEmittance = g_VxgiVoxelizationCB.ScissorRegionsClipSpaceEmittance[clipLevel];

    if (projectionIndex == 0)
    {
        writeOpacity = writeOpacity && unscaledZ >= scissorRegionOpacity.lower.z && unscaledZ <= scissorRegionOpacity.upper.z;
        writeEmittance = writeEmittance && unscaledZ >= scissorRegionEmittance.lower.z && unscaledZ <= scissorRegionEmittance.upper.z;
        offsetDir = int3(0, 0, 1);
        levelSize = float2(g_VxgiVoxelizationCB.ClipLevelSize.xy);
        texelSpace.y = levelSize.y - texelSpace.y;
    }
    else if (projectionIndex == 1)
    {
        writeOpacity = writeOpacity && unscaledZ >= scissorRegionOpacity.lower.y && unscaledZ <= scissorRegionOpacity.upper.y;
        writeEmittance = writeEmittance && unscaledZ >= scissorRegionEmittance.lower.y && unscaledZ <= scissorRegionEmittance.upper.y;
        offsetDir = int3(0, 1, 0);
        levelSize = float2(g_VxgiVoxelizationCB.ClipLevelSize.zx);
        texelSpace.y = levelSize.y - texelSpace.y;
        texelSpace.zxy = texelSpace.xyz;
    }
    else
    {
        writeOpacity = writeOpacity && unscaledZ >= scissorRegionOpacity.lower.x && unscaledZ <= scissorRegionOpacity.upper.x;
        writeEmittance = writeEmittance && unscaledZ >= scissorRegionEmittance.lower.x && unscaledZ <= scissorRegionEmittance.upper.x;
        offsetDir = int3(1, 0, 0);
        levelSize = float2(g_VxgiVoxelizationCB.ClipLevelSize.yz);
        texelSpace.y = levelSize.y - texelSpace.y;
        texelSpace.yzx = texelSpace.xyz;
    }

    if (!writeOpacity && !writeEmittance)
    {
        discard;
        return;
    }

    int3 voxelCoordinates = int3(floor(texelSpace));
    voxelCoordinates -= offsetDir;

    float4 layersForOpacity;
    float4 layersForEmittance;

    uint coverage = uint(IN.gl_SampleMaskIn);
    float depthSign = -sign(dot(worldNormal, offsetDir));

    if (depthSign < 0 && opacity > 1)
        voxelCoordinates -= offsetDir;

    VxgiGetLayeredCoverage(inputZ, coverage, depthSign, opacity, layersForOpacity, layersForEmittance);

    float3 geometryNormal = normalize(cross(ddx(texelSpace), ddy(texelSpace)));

    float areaScale = rcp(max(abs(geometryNormal.x), max(abs(geometryNormal.y), abs(geometryNormal.z))));

    areaScale *= rResolutionFactor * rResolutionFactor;

    int pageCoordinatesHash = -1;
    uint page = 0;

    [loop] for (uint voxel = 0; voxel < 4; voxel++)
    {
        VxgiWriteVoxel(
            voxelCoordinates,
            clipLevel,
            writeOpacity,
            writeEmittance,
            layersForOpacity.x * areaScale,
            layersForEmittance.x * areaScale,
            opacity,
            emissiveColorFront,
            emissiveColorBack,
            worldNormal,
            pageCoordinatesHash,
            page);

        voxelCoordinates += offsetDir;
        layersForOpacity.xyz = layersForOpacity.yzw;
        layersForEmittance.xyz = layersForEmittance.yzw;
    }

    discard;
}

float4 VxgiNormalizeIrradiance(float4 irradiance)
{
    if (irradiance.a <= 0)
        return float4scalar(0);

    return float4(irradiance.rgb / irradiance.a, 1);
}

float3 VxgiGetIndirectIrradiance(float3 worldPos, float3 normal)
{
    if (bool(g_VxgiVoxelizationCB.UseIrradianceMap))
    {
        float3 relativePos = (worldPos - g_VxgiVoxelizationCB.GridCenterPrevious.xyz) * g_VxgiVoxelizationCB.rGridWorldSizePrevious.xyz;

        float3 validities = saturate(g_VxgiVoxelizationCB.IrradianceMapSize.xyz * (float3scalar(1.0) - 2 * abs(relativePos.xyz)));
        float validity = validities.x * validities.y * validities.z;

        if (validity == 0)
            return float3scalar(0.0);

        relativePos += 0.5;

        const float zstep = rcp(6.0);
        relativePos.z *= zstep;

        float4 irradianceX = t_IrradianceMap.SampleLevel(s_IrradianceMapSampler, relativePos + float3(0, 0, zstep * (normal.x > 0 ? 0 : 3)), 0);
        float4 irradianceY = t_IrradianceMap.SampleLevel(s_IrradianceMapSampler, relativePos + float3(0, 0, zstep * (normal.y > 0 ? 1 : 4)), 0);
        float4 irradianceZ = t_IrradianceMap.SampleLevel(s_IrradianceMapSampler, relativePos + float3(0, 0, zstep * (normal.z > 0 ? 2 : 5)), 0);

        return (VxgiNormalizeIrradiance(irradianceX).rgb * abs(normal.x) + VxgiNormalizeIrradiance(irradianceY).rgb * abs(normal.y) + VxgiNormalizeIrradiance(irradianceZ).rgb * abs(normal.z)) * validity;
    }

    return float3scalar(0);
}

//////////////////APP CODE BOUNDARY/////////////
struct PSInput
{
    float4 position : SV_Position;
    float2 texCoord : TEXCOORD;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
    float3 binormal : BINORMAL;
    float3 positionWS : WSPOSITION;
    VxgiVoxelizationPSInputData vxgiData;
};

cbuffer GlobalConstants : register(b0)
{
    float4x4 g_WorldMatrix;
    float4x4 g_ViewProjMatrix;
    float4x4 g_ViewProjMatrixInv;
    float4x4 g_LightViewProjMatrix;
    float4 g_CameraPos;
    float4 g_LightDirection;
    float4 g_DiffuseColor;
    float4 g_LightColor;
    float4 g_AmbientColor;
    float g_rShadowMapSize;
    uint g_EnableIndirectDiffuse;
    uint g_EnableIndirectSpecular;
    float g_TransparentRoughness;
    float g_TransparentReflectance;
};

Texture2D<float4> t_DiffuseColor : register(t0);
Texture2D t_ShadowMap : register(t1);
SamplerState g_SamplerLinearWrap : register(s0);
SamplerComparisonState g_SamplerComparison : register(s1);

static const float PI = 3.14159265;

float GetShadowFast(float3 fragmentPos)
{
    float4 clipPos = mul(float4(fragmentPos, 1.0f), g_LightViewProjMatrix);

    // Early out
    if (abs(clipPos.x) > clipPos.w || abs(clipPos.y) > clipPos.w || clipPos.z <= 0)
    {
        return 0;
    }

    clipPos.xyz /= clipPos.w;
    clipPos.x = clipPos.x * 0.5f + 0.5f;
    clipPos.y = 0.5f - clipPos.y * 0.5f;

    return t_ShadowMap.SampleCmpLevelZero(g_SamplerComparison, clipPos.xy, clipPos.z);
}

void main(PSInput IN)
{
    float3 worldPos = IN.positionWS.xyz;
    float3 normal = normalize(IN.normal.xyz);

    float3 albedo = g_DiffuseColor.rgb;

    if (g_DiffuseColor.a > 0)
        albedo = t_DiffuseColor.Sample(g_SamplerLinearWrap, IN.texCoord.xy).rgb;

    float NdotL = saturate(-dot(normal, g_LightDirection.xyz));

    // photon mapping
    //
    // \Delta\Phi = E_n * Area / N_p = E_l * cos_theta * Area / N_p
    //
    // L = f * \Delta\Phi = f * E_l * cos_theta * Area / N_p
    //
    // we calculate "f * E_l * cos_theta" here
    //
    // the outgoing direction of BRDF should be the cone direction
    // we do not have such information here and we only calculate diffuse without specular
    //
    float3 brdf_mul_DeltaPhi_div_area;
    if (NdotL > 0.0)
    {
        float3 E_l = g_LightColor.rgb * GetShadowFast(worldPos);

        float3 E_n = E_l * NdotL;

        float3 DeltaPhi_div_area = E_n;

        float3 brdf = (1.0 / PI) * albedo.rgb;

        brdf_mul_DeltaPhi_div_area = brdf * DeltaPhi_div_area;
    }
    else
    {
        brdf_mul_DeltaPhi_div_area = 0.0;
    }

    VxgiStoreVoxelizationData(IN.vxgiData, normal, 1, brdf_mul_DeltaPhi_div_area, 0);
}
//////////////////APP CODE BOUNDARY/////////////

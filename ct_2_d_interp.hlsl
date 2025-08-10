#define REGISTER(type, slot) register(type##slot)
#define VXGI_VIEW_TRACING_CB_SLOT 1

#pragma pack_matrix(row_major)

float2 float2scalar(float x) { return float2(x, x); }

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

RWTexture2D<float4> u_InterpolatedTarget : REGISTER(u, 0);
RWTexture2D<unorm float> u_InterpolatedConfidence : REGISTER(u, 1);
RWTexture2D<unorm float> u_RefinementControl : REGISTER(u, 2);
RWTexture2D<unorm float> u_RefinementGrid : REGISTER(u, 3);

groupshared float4 s_CoarseNormalAndX[((16 + 4 - 1) / 4 + 1 + 1 + 1)][((16 + 4 - 1) / 4 + 1 + 1 + 1)];
groupshared float4 s_CoarseWorldPosAndY[((16 + 4 - 1) / 4 + 1 + 1 + 1)][((16 + 4 - 1) / 4 + 1 + 1 + 1)];

groupshared float4 s_CoarseDiffuse[((16 + 4 - 1) / 4 + 1 + 1 + 1)][((16 + 4 - 1) / 4 + 1 + 1 + 1)];

[numthreads(16, 16, 1)] void main(in uint3 gfsdk_GroupIdx : SV_GroupID, in uint3 gfsdk_GroupThreadIdx : SV_GroupThreadID, in uint3 gfsdk_GlobalIdx : SV_DispatchThreadID)
{
    float2 gbufferSamplePos = gfsdk_GlobalIdx.xy + g_VxgiBuiltinTracingCB.GridOrigin.xy + float2scalar(0.5);
    u_InterpolatedTarget[int2(gbufferSamplePos)] = float4(0.0, 0.0, 0.0, 0.0);
    u_InterpolatedConfidence[int2(gbufferSamplePos)] = 0.0;
    u_RefinementControl[int2(gbufferSamplePos)] = 1;
    u_RefinementGrid[int2(gbufferSamplePos / 32)] = 1;
}

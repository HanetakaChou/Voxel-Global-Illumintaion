#define REGISTER(type, slot) register(type##slot)
#define VXGI_VIEW_TRACING_CB_SLOT 1

#pragma pack_matrix(row_major)

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

RWTexture2D<float4> u_CoarseOutput0 : REGISTER(u, 0);

[numthreads(8, 8, 1)] void main(in uint3 gfsdk_GroupIdx : SV_GroupID, in uint3 gfsdk_GroupThreadIdx : SV_GroupThreadID, in uint3 gfsdk_GlobalIdx : SV_DispatchThreadID)
{
    int2 groupBase = int2(gfsdk_GlobalIdx.xy - gfsdk_GroupThreadIdx.xy) + int2(floor(g_VxgiBuiltinTracingCB.GridOrigin.xy * g_VxgiBuiltinTracingCB.DownsampleScale.zw));

    int2 coarsePixelPos = groupBase + int2(gfsdk_GroupThreadIdx.xy);

    u_CoarseOutput0[coarsePixelPos] = float4(0.0, 0.0, 0.0, 0.0);
}

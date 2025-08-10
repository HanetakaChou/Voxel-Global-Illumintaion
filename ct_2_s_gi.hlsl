#define brx_float float

#define brx_float2 float2

#define brx_float3 float3

#define brx_float4 float4

#define brx_is_inf(x) (isinf(x))

#define brx_int_as_float(x) (asfloat(x))

#define brx_uint_as_float(x) (asfloat(x))

#define brx_int int

#define brx_int2 int2

#define brx_int3 int3

#define brx_float_as_int(x) (asint(x))

#define brx_uint uint

#define brx_uint2 uint2

#define brx_uint3 uint3

#define brx_uint4 uint4

#define brx_float_as_uint(x) (asuint(x))

#define brx_column_major column_major

#define brx_float3x3 float3x3

#define brx_float3x4 float3x4

#define brx_float4x4 float4x4

#define brx_float3x3_from_columns(column0, column1, column2) float3x3(float3((column0).x, (column1).x, (column2).x), float3((column0).y, (column1).y, (column2).y), float3((column0).z, (column1).z, (column2).z))

#define brx_float3x3_from_rows(row0, row1, row2) float3x3((row0), (row1), (row2))

#if defined(BRX_ENABLE_RAY_TRACING) && BRX_ENABLE_RAY_TRACING

#define brx_ray_query RayQuery<RAY_FLAG_NONE>

#endif

#define brx_cbuffer(name, set, binding) cbuffer name : register(b##binding, space##set)

#define brx_read_only_byte_address_buffer(name, set, binding) ByteAddressBuffer name : register(t##binding, space##set)

#define brx_read_write_byte_address_buffer(name, set, binding) RWByteAddressBuffer name : register(u##binding, space##set)

#define brx_write_only_byte_address_buffer(name, set, binding) RWByteAddressBuffer name : register(u##binding, space##set)

#define brx_texture_2d(name, set, binding) Texture2D name : register(t##binding, space##set)

#define brx_texture_2d_uint(name, set, binding) Texture2D<uint4> name : register(t##binding, space##set)

#define brx_sampler_state(name, set, binding) SamplerState name : register(s##binding, space##set)

#define brx_write_only_texture_2d(name, set, binding) RWTexture2D<float4> name : register(u##binding, space##set)

#define brx_write_only_texture_2d_uint(name, set, binding) RWTexture2D<uint4> name : register(u##binding, space##set)

#define brx_top_level_acceleration_structure(name, set, binding) RaytracingAccelerationStructure name : register(t##binding, space##set)

#define brx_read_only_byte_address_buffer_array(name, set, binding, count) ByteAddressBuffer name[count] : register(t##binding, space##set)

#define brx_read_write_byte_address_buffer_array(name, set, binding, count) RWByteAddressBuffer name[count] : register(u##binding, space##set)

#define brx_write_only_byte_address_buffer_array(name, set, binding, count) RWByteAddressBuffer name[count] : register(u##binding, space##set)

#define brx_texture_2d_array(name, set, binding, count) Texture2D name[count] : register(t##binding, space##set)

#define brx_texture_2d_uint_array(name, set, binding, count) Texture2D<uint4> name[count] : register(t##binding, space##set)

#define brx_sampler_state_array(name, set, binding, count) SamplerState name[count] : register(s##binding, space##set)

#define brx_write_only_texture_2d_array(name, set, binding, count) RWTexture2D<float4> name[count] : register(u##binding, space##set)

#define brx_write_only_texture_2d_uint_array(name, set, binding, count) RWTexture2D<uint4> name[count] : register(u##binding, space##set)

#define brx_top_level_acceleration_structure_array(name, set, binding, count) RaytracingAccelerationStructure name[count] : register(t##binding, space##set)

#if defined(BRX_ENABLE_RAY_TRACING) && BRX_ENABLE_RAY_TRACING

#define brx_read_only_byte_address_buffer_unbounded(name, set, binding) ByteAddressBuffer name[] : register(t##binding, space##set)

#define brx_texture_2d_unbounded(name, set, binding) Texture2D name[] : register(t##binding, space##set)

#define brx_texture_2d_uint_unbounded(name, set, binding) Texture2D<uint4> name[] : register(t##binding, space##set)

#endif

// https://gcc.gnu.org/onlinedocs/cpp/Stringizing.html
#if 1
#define brx_root_signature_stringizing(string) #string
#define brx_root_signature_x_stringizing(string) brx_root_signature_stringizing(string)
#else
// comma is not supported by HLSL
#define brx_root_signature_stringizing(...) #__VA_ARGS__
#define brx_root_signature_x_stringizing(...) brx_root_signature_stringizing(__VA_ARGS__)
#endif

#define brx_root_signature_root_parameter_begin(name) brx_root_signature_x_stringizing(RootFlags(ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT)) ","

#define brx_root_signature_root_parameter_split ","

#define brx_root_signature_root_parameter_end

#define brx_root_signature_root_cbv(set, binding) brx_root_signature_x_stringizing(CBV(b##binding, space = set, visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature_root_descriptor_table_srv(set, binding, count) brx_root_signature_x_stringizing(DescriptorTable(SRV(t##binding, space = set, numdescriptors = count), visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature_root_descriptor_table_srv_unbounded(set, binding) brx_root_signature_x_stringizing(DescriptorTable(SRV(t##binding, space = set, numdescriptors = unbounded), visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature_root_descriptor_table_sampler(set, binding, count) brx_root_signature_x_stringizing(DescriptorTable(Sampler(s##binding, space = set, numdescriptors = count), visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature_root_descriptor_table_uav(set, binding, count) brx_root_signature_x_stringizing(DescriptorTable(UAV(u##binding, space = set, numdescriptors = count), visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature_root_descriptor_table_top_level_acceleration_structure(set, binding, count) brx_root_signature_x_stringizing(DescriptorTable(SRV(t##binding, space = set, numdescriptors = count), visibility = SHADER_VISIBILITY_ALL))

#define brx_root_signature(macro, name) [RootSignature(macro)]

#define brx_branch [branch]

#define brx_unroll [unroll]

#define brx_unroll_x(x) [unroll(x)]

#define brx_vertex_shader_parameter_begin(name) void name (

#define brx_vertex_shader_parameter_split ,

#define brx_vertex_shader_parameter_end(name) )

#define brx_vertex_shader_parameter_in_vertex_index in uint _internal_base_vertex_location : SV_StartVertexLocation, in uint _internal_vertex_id : SV_VERTEXID

#define brx_vertex_index (_internal_base_vertex_location + _internal_vertex_id)

#define brx_vertex_shader_parameter_in(type, name, location) in type name : LOCATION##location

#define brx_vertex_shader_parameter_out_position out float4 brx_position : SV_POSITION

#define brx_vertex_shader_parameter_out(type, name, location) out type name : LOCATION##location

#define brx_early_depth_stencil [earlydepthstencil]

#define brx_pixel_shader_parameter_begin(name) void name (

#define brx_pixel_shader_parameter_split ,

#define brx_pixel_shader_parameter_end(name) )

#define brx_pixel_shader_parameter_in_frag_coord in float4 brx_frag_coord : SV_POSITION

#define brx_pixel_shader_parameter_in(type, name, location) in type name : LOCATION##location

#define brx_pixel_shader_parameter_out_depth out float brx_depth : SV_DEPTH

#define brx_pixel_shader_parameter_out(type, name, location) out type name : SV_TARGET##location

#define brx_num_threads(x, y, z) [numthreads(x, y, z)]

#define brx_group_shared groupshared

#define brx_group_memory_barrier_with_group_sync GroupMemoryBarrierWithGroupSync

#define brx_compute_shader_parameter_begin(name) void name (

#define brx_compute_shader_parameter_split ,

#define brx_compute_shader_parameter_end(name) )

#define brx_compute_shader_parameter_in_group_id in uint3 brx_group_id : SV_GroupID

#define brx_compute_shader_parameter_in_group_thread_id in uint3 brx_group_thread_id : SV_GroupThreadID

#define brx_compute_shader_parameter_in_group_index in uint brx_group_index : SV_GroupIndex

#define brx_array_constructor_begin(type, count) {

#define brx_array_constructor_split ,

#define brx_array_constructor_end }

#define brx_mul(x, y) (mul((x), (y)))

#define brx_dot(x, y) (dot((x), (y)))

#define brx_min(x, y) (min((x), (y)))

#define brx_max(x, y) (max((x), (y)))

#define brx_cross(x, y) (cross((x), (y)))

#define brx_pow(x, y) (pow((x), (y)))

#define brx_ddx(x) (ddx((x)))

#define brx_ddy(x) (ddy((x)))

#define brx_abs(x) (abs((x)))

#define brx_length(x) (length((x)))

#define brx_normalize(x) (normalize(x))

#define brx_cos(x) (cos((x)))

#define brx_sin(x) (sin((x)))

#define brx_acos(x) (acos((x)))

#define brx_atan2(y, x) (atan2((y), (x)))

#define brx_sqrt(x) (sqrt((x)))

#define brx_rsqrt(x) (rsqrt((x)))

#define brx_firstbithigh(value) (firstbithigh(value))

#define brx_reversebits(value) (reversebits(value))

#define brx_sign(x) (sign((x)))

#define brx_clamp(x, min, max) (clamp((x), (min), (max)))

#define brx_lerp(x, y, s) (lerp((x), (y), (s)))

#define brx_reflect(x, y) (reflect((x), (y)))

inline uint _internal_brx_byte_address_buffer_get_dimension(ByteAddressBuffer object)
{
    uint out_dim;
    object.GetDimensions(out_dim);
    return out_dim;
}

#define brx_byte_address_buffer_get_dimension(object) (_internal_brx_byte_address_buffer_get_dimension((object)))

#define brx_byte_address_buffer_load(object, location) ((object).Load((location)))

#define brx_byte_address_buffer_load2(object, location) ((object).Load2((location)))

#define brx_byte_address_buffer_load3(object, location) ((object).Load3((location)))

#define brx_byte_address_buffer_load4(object, location) ((object).Load4((location)))

#define brx_byte_address_buffer_store(object, location, data) ((object).Store((location), (data)))

#define brx_byte_address_buffer_store2(object, location, data) ((object).Store2((location), (data)))

#define brx_byte_address_buffer_store3(object, location, data) ((object).Store3((location), (data)))

#define brx_byte_address_buffer_store4(object, location, data) ((object).Store4((location), (data)))

inline uint _internal_brx_byte_address_buffer_interlocked_compare_exchange(RWByteAddressBuffer object, int location, uint expected_old_value, uint new_value)
{
    uint out_actual_old_value_packed;
    object.InterlockedCompareExchange(location, expected_old_value, new_value, out_actual_old_value_packed);
    return out_actual_old_value_packed;
}

#define brx_byte_address_buffer_interlocked_compare_exchange(object, location, old_value, new_value) (_internal_brx_byte_address_buffer_interlocked_compare_exchange((object), (location), (old_value), (new_value)))

inline uint2 _internal_brx_texture_2d_get_dimension(Texture2D object, uint mip_level)
{
    uint out_width;
    uint out_height;
    uint out_number_of_levels;
    object.GetDimensions(mip_level, out_width, out_height, out_number_of_levels);

    return uint2(out_width, out_height);
}

#define brx_texture_2d_get_dimension(object, lod) (_internal_brx_texture_2d_get_dimension((object), (lod)))

inline uint2 _internal_brx_write_only_texture_2d_get_dimension(RWTexture2D<float4> object)
{
    uint out_width;
    uint out_height;
    object.GetDimensions(out_width, out_height);

    return uint2(out_width, out_height);
}

#define brx_write_only_texture_2d_get_dimension(object) (_internal_brx_write_only_texture_2d_get_dimension((object)))

#define brx_sample_2d(object, s, location) ((object).Sample((s), (location)))

#define brx_sample_grad_2d(object, s, location, ddx, ddy) ((object).SampleGrad((s), (location), (ddx), (ddy)))

#define brx_sample_level_2d(object, s, location, lod) ((object).SampleLevel((s), (location), (lod)))

#define brx_load_2d(object, location) ((object).Load(location))

#define brx_store_2d(object, location, data) (((object)[location]) = (data))

#if defined(BRX_ENABLE_WAVE_INTRINSICS) && BRX_ENABLE_WAVE_INTRINSICS

#define brx_wave_lane_count (WaveGetLaneCount())

#define brx_wave_active_sum(expr) (WaveActiveSum(expr))

#endif

#if defined(BRX_ENABLE_RAY_TRACING) && BRX_ENABLE_RAY_TRACING

#define BRX_RAY_FLAG_NONE RAY_FLAG_NONE

#define BRX_RAY_FLAG_CULL_BACK_FACING_TRIANGLES RAY_FLAG_CULL_BACK_FACING_TRIANGLES

inline RayDesc _internal_brx_make_ray_desc(float3 origin, float t_min, float3 direction, float t_max)
{
    RayDesc ray_desc;
    ray_desc.Origin = origin;
    ray_desc.TMin = t_min;
    ray_desc.Direction = direction;
    ray_desc.TMax = t_max;
    return ray_desc;
}

#define brx_ray_query_trace_ray_inline(ray_query_object, acceleration_structure, ray_flags, instance_inclusion_mask, origin, t_min, direction, t_max) ((ray_query_object).TraceRayInline((acceleration_structure), (ray_flags), (instance_inclusion_mask), _internal_brx_make_ray_desc((origin), (t_min), (direction), (t_max))))

#define brx_ray_query_proceed(ray_query_object) ((ray_query_object).Proceed())

#define BRX_CANDIDATE_NON_OPAQUE_TRIANGLE CANDIDATE_NON_OPAQUE_TRIANGLE

#define brx_ray_query_candidate_type(ray_query_object) ((ray_query_object).CandidateType())

#define brx_ray_query_committed_non_opaque_triangle_hit(ray_query_object) ((ray_query_object).CommitNonOpaqueTriangleHit())

#define BRX_COMMITTED_TRIANGLE_HIT COMMITTED_TRIANGLE_HIT

#define brx_ray_query_committed_status(ray_query_object) ((ray_query_object).CommittedStatus())

#define brx_ray_query_committed_instance_id(ray_query_object) ((ray_query_object).CommittedInstanceID())

#define brx_ray_query_committed_object_to_world(ray_query_object) ((ray_query_object).CommittedObjectToWorld3x4())

#define brx_ray_query_committed_geometry_index(ray_query_object) ((ray_query_object).CommittedGeometryIndex())

#define brx_ray_query_committed_primitive_index(ray_query_object) ((ray_query_object).CommittedPrimitiveIndex())

#define brx_ray_query_committed_triangle_barycentrics(ray_query_object) ((ray_query_object).CommittedTriangleBarycentrics())

#define brx_ray_query_committed_triangle_front_face(ray_query_object) ((ray_query_object).CommittedTriangleFrontFace())

#define brx_non_uniform_resource_index(i) (NonUniformResourceIndex((i)))

#endif

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

Texture2D t_Randoms : REGISTER(t, VXGI_VIEW_TRACING_TEXTURE_1_SLOT);
Texture2D t_PrevSpecular : REGISTER(t, VXGI_VIEW_TRACING_TEXTURE_2_SLOT);

RWTexture2D<float4> u_RadianceAndAmbientOutput : REGISTER(u, 0);

float rand(float2 co)
{
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

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

float3 trowbridge_reitz_sample_omega_h(float2 xi, float alpha, float3 omega_o)
{
    const float M_PI = 3.141592653589793238462643;

    // PBR Book V3: [Equation 8.12](https://pbr-book.org/3ed-2018/Reflection_Models/Microfacet_Models#MaskingandShadowing)
    // PBRT-V3: [TrowbridgeReitzDistribution::Sample_wh](https://github.com/mmp/pbrt-v3/blob/book/src/core/microfacet.cpp#L308)
    // PBR Book V4: [Equation 9.23](https://pbr-book.org/4ed/Reflection_Models/Roughness_Using_Microfacet_Theory#SamplingtheDistributionofVisibleNormals)
    // PBRT-V4: [TrowbridgeReitzDistribution::Sample_wm](https://github.com/mmp/pbrt-v4/blob/master/src/pbrt/util/scattering.h#L163)
    // UE: [ImportanceSampleVisibleGGX](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L380)
    // U3D: [SampleGGXVisibleNormal](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl#L222)

    float3 omega_o_hemisphere = normalize(float3(omega_o.xy * alpha, max(1E-5, omega_o.z)));

    float3 T1;
    {
        float3 T_1_raw = float3(-omega_o_hemisphere.y, omega_o_hemisphere.x, 0.0);
        float T_1_length_square = dot(T_1_raw, T_1_raw);
        T1 = (T_1_length_square > 1E-5) ? T_1_raw / sqrt(T_1_length_square) : float3(1.0, 0.0, 0.0);
    }

    float3 T2 = cross(omega_o_hemisphere, T1);

    float3 p;
    {
        float r = sqrt(max(0.0, xi.x));
        float theta = 2.0 * M_PI * xi.y;
        float disk_x = r * cos(theta);
        float disk_y = r * sin(theta);

        float p_x = disk_x;
        float p_y = lerp(sqrt(max(0.0, 1.0 - disk_x * disk_x)), disk_y, (1.0 + omega_o_hemisphere.z) * 0.5);

        float p_z = sqrt(max(0.0, 1.0 - dot(float2(p_x, p_y), float2(p_x, p_y))));

        p = float3(p_x, p_y, p_z);
    }

    float3 n_h = T1 * p.x + T2 * p.y + omega_o_hemisphere * p.z;

    float3 omega_h = normalize(float3(n_h.xy * alpha, max(1E-5, n_h.z)));
    return omega_h;
}

float trowbridge_reitz_pdf_omega_i(float alpha, float NdotV, float NdotH)
{
    const float M_PI = 3.141592653589793238462643;

    // VNDF = D * VdotH * G1 / NdotV
    //
    // PBR Book V3: [Equation 8.12](https://pbr-book.org/3ed-2018/Reflection_Models/Microfacet_Models#MaskingandShadowing)
    // PBRT-V3: [MicrofacetDistribution::Pdf](https://github.com/mmp/pbrt-v3/blob/book/src/core/microfacet.cpp#L339)
    // PBR Book V4: [Equation 9.23](https://pbr-book.org/4ed/Reflection_Models/Roughness_Using_Microfacet_Theory#SamplingtheDistributionofVisibleNormals)
    // PBRT-V4: [TrowbridgeReitzDistribution::PDF](https://github.com/mmp/pbrt-v4/blob/master/src/pbrt/util/scattering.h#L160)
    // UE: [ImportanceSampleVisibleGGX](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/MonteCarlo.ush#L380)
    // U3D: [SampleGGXVisibleNormal](https://github.com/Unity-Technologies/Graphics/blob/v10.8.1/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl#L222)

    // PDF = VNDF / (4.0 * VdotH) = D * (G1 / NdotV) / 4.0
    //
    // PBR Book V3: [Figure 14.4](https://pbr-book.org/3ed-2018/Light_Transport_I_Surface_Reflection/Sampling_Reflection_Functions#MicrofacetBxDFs)
    // PBRT-V3: [MicrofacetReflection::Sample_f](https://github.com/mmp/pbrt-v3/blob/book/src/core/reflection.cpp#L413)
    // PBR Book V4: [Figure 9.30](https://pbr-book.org/4ed/Reflection_Models/Roughness_Using_Microfacet_Theory#x5-TheHalf-DirectionTransform)
    // PBRT-V4: [ConductorBxDF ::Sample_f](https://github.com/mmp/pbrt-v4/blob/master/src/pbrt/bxdfs.h#L317)

    float D;
    float G1_div_NdotV;
    {
        float alpha2 = alpha * alpha;

        {
            float denominator = (NdotH * alpha2 - NdotH) * NdotH + 1.0;
            D = alpha2 / (M_PI * denominator * denominator);
        }

        {
            G1_div_NdotV = 2.0 / (NdotV + sqrt(NdotV * (NdotV - NdotV * alpha2) + alpha2));
        }
    }

    float pdf = D * G1_div_NdotV / 4.0;

    return pdf;
}

#define MAX_SAMPLE_COUNT 256

// https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-variable-syntax
// "in D3D11 the maximum size is 32kb"
#define GROUP_SHARED_MEMORY_COUNT (MAX_SAMPLE_COUNT / 2)
brx_group_shared brx_float4 reduction_group_shared_memory[GROUP_SHARED_MEMORY_COUNT];

#define VCT_DIFFUSE_CONE_TRACING_CONE_COUNT 64

#define VCT_SPECULAR_CONE_TRACING_CONE_COUNT 32

[numthreads(MAX_SAMPLE_COUNT, 1, 1)] void main(in uint3 gfsdk_GroupIdx : SV_GroupID, in uint gfsdk_GroupIndex : SV_GroupIndex)
{
    // TODO: remove these two loops and scale the dispath parameters
    for (int width = 0; width < 8; ++width)
    {
        for (int height = 0; height < 8; ++height)
        {
            float2 gbufferSamplePos = float2(8, 8) * gfsdk_GroupIdx.xy + float2(width, height) + float2scalar(0.5);

            brx_int reduction_index = brx_int(gfsdk_GroupIndex);

            brx_float3 reduction_thread_local_diffuse_radiance = brx_float3(0.0, 0.0, 0.0);
            brx_float reduction_thread_local_ambient = 0.0;
            brx_float3 reduction_thread_local_specular_radiance = brx_float3(0.0, 0.0, 0.0);
            {
                VxgiGBufferSample gbufferSample;

                [branch] if (VxgiLoadGBufferSample(gbufferSamplePos.xy, g_VxgiBuiltinTracingCB.ViewIndex, false, false, gbufferSample))
                {
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

                    float3 samplePosition = VxgiGetGBufferWorldPos(gbufferSample);

                    brx_branch if (reduction_index < VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)
                    {
                        VxgiDiffuseShaderParameters params = VxgiGetGBufferDiffuseShaderParameters(gbufferSample);

                        int cone_index = reduction_index;

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

                        const float AmbientDistanceDarkening = -0.25;

                        args.ambientAttenuationFactor = 2.3 * g_VxgiAbstractTracingCB.FinestVoxelSize / max(g_VxgiAbstractTracingCB.FinestVoxelSize, params.ambientRange) * pow(minSampleSize, AmbientDistanceDarkening);

                        const float DiffuseSoftness = 0.5;
                        const float PerPixelOffsetScale = 1.0;

                        float perPixelOffset = 0.5 * PerPixelOffsetScale * minSampleSize * tracingStep;
                        float4 offsetParams = float4(params.initialOffsetBias, params.initialOffsetDistanceFactor, 1.0 - DiffuseSoftness, perPixelOffset);

                        AdjustConePosition(samplePosition.xyz, offsetParams, float4(N, 0), args);

                        VxgiConeTracingResults cone = VxgiTraceCone(args, true, true);
                        // radiosity += (1.0 - cone.finalOpacity) * VxgiGetEnvironmentIrradiance(samplePosition, rayDir, g_VxgiBuiltinTracingCB.ConeFactor, false) * g_VxgiBuiltinTracingCB.rNumCones;
                        float3 L_i = cone.radiance;
                        float3 V_i = cone.ambient;

                        // TODO: from GBuffer
                        brx_float3 rho = brx_float3(1.0, 1.0, 1.0);

                        // monte carlo estimator
                        // 1/N * 1/PI * rho * L_i * NdotL / (1/PI * NdotL) = 1/N * rho * L_i
                        reduction_thread_local_diffuse_radiance = (1.0 / float(VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)) * rho * L_i;

                        // monte carlo estimator
                        // 1/N * 1/PI * V_i * NdotL / (1/PI * NdotL) = 1/N * V_i
                        reduction_thread_local_ambient = (1.0 / float(VCT_DIFFUSE_CONE_TRACING_CONE_COUNT)) * V_i;
                    }

                    brx_branch if (reduction_index < VCT_SPECULAR_CONE_TRACING_CONE_COUNT)
                    {
                        VxgiSpecularShaderParameters params = VxgiGetGBufferSpecularShaderParameters(gbufferSample);

                        float3 V = normalize(-params.viewDirection);

                        [branch] if (dot(N, V) > 1E-5)
                        {
                            // Prevent the roughness to be zero
                            // https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/CapsuleLightIntegrate.ush#L94
                            const float cvar_global_min_roughness_override = 0.02;
                            float roughness = max(cvar_global_min_roughness_override, params.roughness);

                            // Real-Time Rendering Fourth Edition / 9.8.1 Normal Distribution Functions: "In the Disney principled shading model, Burley[214] exposes the roughness control to users as g = r2, where r is the user-interface roughness parameter value between 0 and 1."
                            float alpha = roughness * roughness;

                            int cone_index = reduction_index;

                            float3 omega_o = normalize(float3(dot(V, T), dot(V, B), dot(V, N)));

                            float3 omega_h = trowbridge_reitz_sample_omega_h(hammersley_2d(cone_index, VCT_SPECULAR_CONE_TRACING_CONE_COUNT), alpha, omega_o);

                            float3 H = normalize(T * omega_h.x + B * omega_h.y + N * omega_h.z);

                            float3 L = reflect(-V, H);

                            // Prevent the NdotV to be zero
                            // https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/BRDF.ush#L34
                            float NdotV = max(1e-5, omega_o.z);

                            float NdotH = max(1e-5, omega_h.z);

                            float NdotL = max(1e-5, dot(N, L));

                            float pdf = trowbridge_reitz_pdf_omega_i(alpha, NdotV, NdotH);

                            // "20.4 Mipmap Filtered Samples" of GPU Gems 3
                            // UE: [SolidAngleSample](https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/ReflectionEnvironmentShaders.usf#L414)
                            // U3D: [omegaS](https://github.com/Unity-Technologies/Graphics/blob/v10.8.0/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl#L500)
                            float omega_s = (1.0 / float(VCT_SPECULAR_CONE_TRACING_CONE_COUNT)) / pdf;

                            // Omega = 2 PI (1 - cos theta) // theta: cone half-angle
                            float cone_cos_theta = 1.0 - min(omega_s / (2.0 * VxgiPI), 1.0);
                            float cone_tan_theta = sqrt(max(0.0, 1.0 - cone_cos_theta * cone_cos_theta)) / max(cone_cos_theta, 1E-5);
                            float cone_factor = cone_tan_theta * 2.0;

                            // The following is the original code
                            // float coneFactor = min ( 1 , max ( 0.001 , params . roughness * params . roughness * sqrt ( VxgiPI ) ) ) ;

                            // TODO:
                            // cone_factor = min(max(0.001, cone_factor), 1.0);

                            float minSampleSize = VxgiGetMinSampleSizeInVoxels(samplePosition.xyz);
                            float tracingStep = max(0.05, params.tracingStep);

                            float Inv_NDotV_Factor = pow(saturate(1.0 - NdotV), 4.0) * params.coplanarOffsetFactor;

                            float perPixelOffset = 0.5 * g_VxgiBuiltinTracingCB.PerPixelOffsetScale * minSampleSize * tracingStep;
                            float4 offsetParams = float4(params.initialOffsetBias, params.initialOffsetDistanceFactor, 0, perPixelOffset);

                            VxgiConeTracingArguments args = VxgiDefaultConeTracingArguments();
                            args.direction = L;
                            args.coneFactor = cone_factor;
                            args.tracingStep = tracingStep;
                            args.enableSceneBoundsCheck = true;

                            // args.ambientAttenuationFactor = 2.3 * g_VxgiAbstractTracingCB.FinestVoxelSize / max(g_VxgiAbstractTracingCB.FinestVoxelSize, params.ambientRange) * pow(minSampleSize, g_VxgiBuiltinTracingCB.AmbientDistanceDarkening);

                            AdjustConePosition(samplePosition.xyz, offsetParams, float4(N, Inv_NDotV_Factor), args);

                            VxgiConeTracingResults cone = VxgiTraceCone(args, true, false);
                            // float finalOpacity = cone.finalOpacity;
                            // radiance += (1.0 - finalOpacity) * VxgiGetEnvironmentIrradiance(samplePosition, coneDirection, cone_factor, true);
                            brx_float3 L_i = cone.radiance;

                            brx_float G2_div_G1;
                            {
                                brx_float alpha2 = alpha * alpha;
                                G2_div_G1 = 2.0 * NdotL / (NdotL + sqrt(NdotL * (NdotL - NdotL * alpha2) + alpha2));
                            }

                            // TODO: from GBuffer
                            brx_float3 F = brx_float3(1.0, 1.0, 1.0);
#if 0
                            brx_float3 F;
                            {
                                brx_float x = brx_clamp(1.0 - VdotH, 0.0, 1.0);
                                brx_float x2 = x * x;
                                brx_float x5 = x * x2 * x2;
                                F = f0 + (f90 - f0) * x5;
                            }
#endif

                            // monte carlo estimator
                            // (1/N) * D * G2 * F / (4.0 * NdotV * NdotL) * L_i * NdotL / (D * (G1 / NdotV) / 4.0) = (1/N) * (G2 / G1) * F * L_i
                            reduction_thread_local_specular_radiance = (1.0 / float(VCT_SPECULAR_CONE_TRACING_CONE_COUNT)) * G2_div_G1 * F * L_i;
                        }
                    }
                }
            }

            brx_float4 reduction_thread_local = brx_float4(reduction_thread_local_diffuse_radiance + reduction_thread_local_specular_radiance, reduction_thread_local_ambient);

            // Parallel Reduction
            brx_float4 reduction_group_total;
            {

                // Half of the group shared memory can be saved by the following method:
                // Half threads store the local values into the group shared memory, and the other threads read back these values from the group shared memory and reduce them with their local values.

                brx_branch if (reduction_index >= GROUP_SHARED_MEMORY_COUNT && reduction_index < (GROUP_SHARED_MEMORY_COUNT * 2))
                {
                    brx_int group_shared_memory_index = reduction_index - GROUP_SHARED_MEMORY_COUNT;
                    reduction_group_shared_memory[group_shared_memory_index] = reduction_thread_local;
                }

                brx_group_memory_barrier_with_group_sync();

                brx_branch if (reduction_index < GROUP_SHARED_MEMORY_COUNT)
                {
                    brx_int group_shared_memory_index = reduction_index;
                    reduction_group_shared_memory[group_shared_memory_index] = reduction_thread_local + reduction_group_shared_memory[group_shared_memory_index];
                }

#if 1
                brx_unroll for (brx_int k = (GROUP_SHARED_MEMORY_COUNT / 2); k >= 1; k /= 2)
                {
                    brx_group_memory_barrier_with_group_sync();

                    brx_branch if (reduction_index < k)
                    {
                        brx_int group_shared_memory_index = reduction_index;
                        reduction_group_shared_memory[group_shared_memory_index] = reduction_group_shared_memory[group_shared_memory_index] + reduction_group_shared_memory[group_shared_memory_index + k];
                    }
                }
#else
                brx_unroll for (brx_int k = brx_firstbithigh(GROUP_SHARED_MEMORY_COUNT / 2); k >= 0; --k)
                {
                    brx_group_memory_barrier_with_group_sync();

                    brx_branch if (reduction_index < (1u << k))
                    {
                        brx_int group_shared_memory_index = reduction_index;
                        reduction_group_shared_memory[group_shared_memory_index] = reduction_group_shared_memory[group_shared_memory_index] + reduction_group_shared_memory[group_shared_memory_index + (1u << k)];
                    }
                }
#endif

                brx_group_memory_barrier_with_group_sync();

                brx_branch if (0 == reduction_index)
                {
                    reduction_group_total = reduction_group_shared_memory[0];
                }
            }

            brx_branch if (0 == reduction_index)
            {
                float4 reduction_group_total_radiance_and_ambient = reduction_group_total;

#if 0
                if (g_VxgiBuiltinTracingCB.TemporalReprojectionWeights.x > 0)
                {
                    ViewSampleParameters reprojectionParams = PrepareViewSample(gbufferSample, g_VxgiBuiltinTracingCB.ViewIndex, true);
                    float4 reprojectedColor = SampleViewTexture(reprojectionParams, t_PrevSpecular);

                    float4 result = float4(radiance, finalOpacity) * (1 - reprojectionParams.totalWeight * g_VxgiBuiltinTracingCB.TemporalReprojectionWeights.x) + reprojectedColor.rgba * g_VxgiBuiltinTracingCB.TemporalReprojectionWeights.x;

                    radiance = result.rgb;
                    finalOpacity = result.a;
                }
#endif

                float4 radiance_and_ambient = reduction_group_total_radiance_and_ambient;
                radiance_and_ambient = InfNaNOutputGuard(radiance_and_ambient);
                (u_RadianceAndAmbientOutput[int2(gbufferSamplePos)] = radiance_and_ambient);
            }
        }
    }
}
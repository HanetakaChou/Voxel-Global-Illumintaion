#define GFSDK_UBO_SLOT_BASE 56
#define GFSDK_TEXTURE_SLOT_BASE 32
#define GFSDK_IMAGE_SLOT_BASE 0
#define GFSDK_SSBO_SLOT_BASE 0
#define EMITTANCE_FORMAT UNORM8
#define USE_SAVE_SAMPLES 0
#define MSAA_G_BUFFER 0
#define GFSDK_VXGI_SM5
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
#define VXGI_VOXELTEX_SAMPLER_SLOT 0
#define VXGI_OPACITY_POS_SRV_SLOT 6
#define VXGI_OPACITY_NEG_SRV_SLOT 7
#define VXGI_EMITTANCE_EVEN_R_SRV_SLOT 12
#define VXGI_EMITTANCE_EVEN_G_SRV_SLOT 13
#define VXGI_EMITTANCE_EVEN_B_SRV_SLOT 14
#define VXGI_EMITTANCE_ODD_R_SRV_SLOT 15
#define VXGI_EMITTANCE_ODD_G_SRV_SLOT 16
#define VXGI_EMITTANCE_ODD_B_SRV_SLOT 17
#define VXGI_CONE_TRACING_CB_SLOT 0
#define VXGI_CONE_TRACING_TRANSLATION_CB_SLOT 1
#if USE_SAVE_SAMPLES
#define VXGI_MONITOR_CONE_TRACING
#endif
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
#ifdef TEST_COMPILE
#define VXGI_VOXELTEX_SAMPLER_SLOT 0
#define VXGI_OPACITY_POS_SRV_SLOT 0
#define VXGI_OPACITY_NEG_SRV_SLOT 1
#define VXGI_EMITTANCE_EVEN_R_SRV_SLOT 3
#define VXGI_EMITTANCE_EVEN_G_SRV_SLOT 4
#define VXGI_EMITTANCE_EVEN_B_SRV_SLOT 5
#define VXGI_EMITTANCE_ODD_R_SRV_SLOT 6
#define VXGI_EMITTANCE_ODD_G_SRV_SLOT 7
#define VXGI_EMITTANCE_ODD_B_SRV_SLOT 8
#define VXGI_CONE_TRACING_CB_SLOT 0
#define VXGI_CONE_TRACING_TRANSLATION_CB_SLOT 1
#endif
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
#define MAX_INVALIDATE_REGIONS 128
#define MAX_STACK_LEVELS 5
#define MAX_PAGED_LEVELS 7
#define MAX_TOTAL_LEVELS 13
#define MAX_CONES 128
#define FASTGS_COMPATIBLE 1
#define NV_SHADER_EXTENSION_UAV_SLOT 7
#define EMITTANCE_POSITIVE_X 0
#define EMITTANCE_POSITIVE_Y 1
#define EMITTANCE_POSITIVE_Z 2
#define EMITTANCE_NEGATIVE_X 3
#define EMITTANCE_NEGATIVE_Y 4
#define EMITTANCE_NEGATIVE_Z 5
#define MULTILIST_COUNTER_OFFSET 0
#define MULTILIST_DISPATCHARGS_OFFSET 1
#define MULTILIST_DATA_OFFSET 4
#define TRACING_REFINEMENT_GRID_SIZE 32
#ifdef ANDROID
#define ALIGN_ATTRIBUTE(B) __attribute__((aligned(B)));
#define CONSTANT_BUFFER(C) struct C ALIGN_ATTRIBUTE(16);
#else
#ifdef _WIN32
#define ALIGN_ATTRIBUTE(B) __declspec(align(B))
#define CONSTANT_BUFFER(C) struct ALIGN_ATTRIBUTE(16) C;
#endif
#endif
/*
 * Copyright (c) 2012-2016, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */
#define NONE 0
#define UNORM8 1
#define FLOAT16 2
#define FLOAT16_NVAPI 3
#define FLOAT32 4
#if EMITTANCE_FORMAT == FLOAT16
#define STORE_EMITTANCE(e) e
#if defined(GFSDK_VXGI_SM5)
#define EMITTANCE_STORAGE_TYPE float4
#define LOAD_EMITTANCE_FROM_UAV(uav, address) uav[address]
#else
#extension GL_NV_gpu_shader5 : enable
#extension GL_NV_shader_atomic_fp16_vector : enable
#define EMITTANCE_STORAGE_TYPE f16vec4
#define LOAD_EMITTANCE_FROM_UAV(uav, address) gfsdk_ImageLoad(uav, address)
#endif
#define STORE_EMITTANCE_TO_UAV(uav, address, value) gfsdk_ImageStore(uav, address, value)
#define SAMPLE_EMITTANCE(srv, sampler, address) SampleTexLod(sampler, srv, address, 0)
#elif EMITTANCE_FORMAT == FLOAT16_NVAPI
#define STORE_EMITTANCE(e) e
#if defined(GFSDK_VXGI_SM5)
#ifndef DYNAMIC_NV_SHADER_EXTN_SLOT
#define NV_SHADER_EXTN_SLOT u[NV_SHADER_EXTENSION_UAV_SLOT]
#endif
#define EMITTANCE_STORAGE_TYPE float4
#define LOAD_EMITTANCE_FROM_UAV(uav, address) NvLoadUavTyped(uav, address)
#else
#extension GL_NV_gpu_shader5 : enable
#extension GL_NV_shader_atomic_fp16_vector : enable
#define EMITTANCE_STORAGE_TYPE f16vec4
#define LOAD_EMITTANCE_FROM_UAV(uav, address) gfsdk_ImageLoad(uav, address)
#endif
#define STORE_EMITTANCE_TO_UAV(uav, address, value) gfsdk_ImageStore(uav, address, value)
#define SAMPLE_EMITTANCE(srv, sampler, address) SampleTexLod(sampler, srv, address, 0)
#elif EMITTANCE_FORMAT == FLOAT32
#if defined(GFSDK_VXGI_SM5)
#define STORE_EMITTANCE(e) e
#else
#define STORE_EMITTANCE(e) e.xxxx
#endif
#define EMITTANCE_STORAGE_TYPE uint3
#define LOAD_EMITTANCE_FROM_UAV(uav, address) uint3(gfsdk_ImageLoad(uav##R, address).r, gfsdk_ImageLoad(uav##G, address).r, gfsdk_ImageLoad(uav##B, address).r)
#define STORE_EMITTANCE_TO_UAV(uav, address, value) \
    gfsdk_ImageStore(uav##R, address, value.rrrr);  \
    gfsdk_ImageStore(uav##G, address, value.gggg);  \
    gfsdk_ImageStore(uav##B, address, value.bbbb)
#define SAMPLE_EMITTANCE(srv, sampler, address) float4(SampleTexLod(sampler, srv##R, address, 0).r, SampleTexLod(sampler, srv##G, address, 0).r, SampleTexLod(sampler, srv##B, address, 0).r, 0)
#else
#if defined(GFSDK_VXGI_SM5)
#define STORE_EMITTANCE(e) e
#else
#define STORE_EMITTANCE(e) e.xxxx
#endif
#define EMITTANCE_STORAGE_TYPE uint
#define LOAD_EMITTANCE_FROM_UAV(uav, address) gfsdk_ImageLoad(uav, address).x
#define STORE_EMITTANCE_TO_UAV(uav, address, value) gfsdk_ImageStore(uav, address, STORE_EMITTANCE(value))
#define SAMPLE_EMITTANCE(srv, sampler, address) SampleTexLod(sampler, srv, address, 0)
#endif
#if defined(GFSDK_VXGI_SM5)
#ifndef PREPROCESSING
#define REGISTER(type, slot) register(type##slot)
#endif
#pragma pack_matrix(row_major)
#define SampleTex(sampler, name, coordinates) name.Sample(sampler, coordinates)
#define SampleTexLod(sampler, name, coordinates, lod) name.SampleLevel(sampler, coordinates, lod)
#define GatherTex(sampler, name, coordinates, offset) name.Gather(sampler, coordinates, offset)
#define CBUFFER(name, slot) cbuffer name : REGISTER(b, slot)
#define SEMANTIC(x) : x
#define RWTEXTURE3DUINT(name, slot) RWTexture3D<uint> name : REGISTER(u, slot)
#define RWTEXTURE3DHALF(name, slot) RWTexture3D<float4> name : REGISTER(u, slot)
#define RWTEXTURE3DFLOAT(name, slot) RWTexture3D<float4> name : REGISTER(u, slot)
#define RWTEXTURE2DUNORM8(name, slot) RWTexture2D<float> name : REGISTER(u, slot)
#define RWTEXTURE2DFLOAT(name, slot) RWTexture2D<float4> name : REGISTER(u, slot)
#define RWTEXTURE2DFLOAT1(name, slot) RWTexture2D<float> name : REGISTER(u, slot)
#define RWTEXTURE2DARRAYFLOAT1(name, slot) RWTexture2DArray<float> name : REGISTER(u, slot)
#define TEXTURE3DUINT(name, slot) Texture3D<uint> name : REGISTER(t, slot)
#define TEXTURE3DFLOAT(name, slot) Texture3D<float4> name : REGISTER(t, slot)
#define TEXTURE2D(name, slot) Texture2D name : REGISTER(t, slot)
#define TEXTURE2DMS(name, slot) Texture2DMS<float4> name : REGISTER(t, slot)
#define TEXTURE2DARRAY(name, slot) Texture2DArray name : REGISTER(t, slot)
#define TEXTURE2DSTENCIL(name, slot) Texture2D<uint2> name : REGISTER(t, slot)
#define TEXTURE2DSTENCILMS(name, slot) Texture2DMS<uint2> name : REGISTER(t, slot)
#define TEXTURECUBE(name, slot) TextureCube name : REGISTER(t, slot)
#define RWBUFFER(type, name, slot) RWBuffer<type> name : REGISTER(u, slot)
#define BUFFERUINT(name, slot) Buffer<uint> name : REGISTER(t, slot)
#define STRUCTUREDBUFFER(type, name, slot) StructuredBuffer<type> name : REGISTER(t, slot)
#define RWSTRUCTUREDBUFFER(type, name, slot) RWStructuredBuffer<type> name : REGISTER(u, slot)
#define SAMPLER(name, slot) SamplerState name : REGISTER(s, slot);
#define NUMTHREADS(x, y, z) [numthreads(x, y, z)]
#define CS_COMMON_INPUT in uint3 gfsdk_GroupIdx SEMANTIC(SV_GroupID), in uint3 gfsdk_GroupThreadIdx SEMANTIC(SV_GroupThreadID), in uint3 gfsdk_GlobalIdx SEMANTIC(SV_DispatchThreadID)
#define STORE_SCALAR(e) e
#define gfsdk_Equal(a, b) (a == b)
#define gfsdk_NotEqual(a, b) (a != b)
#define gfsdk_LessThanEqual(a, b) (a <= b)
#define gfsdk_LessThan(a, b) (a < b)
#define gfsdk_GreaterThanEqual(a, b) (a >= b)
#define gfsdk_GreaterThan(a, b) (a > b)
#define gfsdk_Unroll [unroll]
#define gfsdk_Loop [loop]
#define gfsdk_BufferLoad(buffer, addr) buffer[addr]
#define gfsdk_TextureLoad(texture, addr) texture[addr]
#define gfsdk_TextureLoadMS(texture, addr, sample) texture.Load(addr, sample)
#define gfsdk_ImageLoad(image, addr) image[addr]
#define gfsdk_ImageStore(image, addr, value) (image[addr] = value)
#define gfsdk_EmitVertex(stream, vertex) stream.Append(vertex)
#define gfsdk_EndPrimitive(stream) stream.RestartStrip()
#define gfsdk_ddx(x) ddx(x)
#define gfsdk_ddy(x) ddy(x)
#define gfsdk_AtomicAdd(dst, value, prevValue) InterlockedAdd(dst, value, prevValue)
#define gfsdk_ImageReductionAdd(image, addr, value) InterlockedAdd(image[addr], value)
#define gfsdk_ImageReductionOr(image, addr, value) InterlockedOr(image[addr], value)
#define gfsdk_SharedReductionOr(variable, value) InterlockedOr(variable, value)
#define gfsdk_ScalarStoreUint(x) x
#define gfsdk_CubemapSamplePos(x) x
#define isaturate(x) saturate(x)
#define floatBitsToInt(f) asint(f)
#define floatBitsToUint(f) asuint(f)
#define intBitsToFloat(i) asfloat(i)
#define uintBitsToFloat(u) asfloat(u)
#define f16vec4 uint2
#define gfsdk_Position position
#define BUILTIN_GLVAR_IN_STRUCT(struct, var) struct.var
#elif defined(GFSDK_VXGI_GL)
#define SampleTex(sampler, name, coordinates) texture(name, coordinates)
#define SampleTexLod(sampler, name, coordinates, lod) textureLod(name, coordinates, lod)
#define GatherTex(sampler, name, coordinates, offset) textureGatherOffset(name, coordinates, offset)
#define CBUFFER(name, slot) layout(binding = GFSDK_UBO_SLOT_BASE + slot) uniform name
#define SEMANTIC(x)
#define uint2 uvec2
#define uint3 uvec3
#define uint4 uvec4
#define int2 ivec2
#define int3 ivec3
#define int4 ivec4
#define float2 vec2
#define float3 vec3
#define float4 vec4
#define float3x3 mat3x3
#define float4x3 mat3x4
#define float4x4 mat4x4
vec3 mul(mat3x3 m, vec3 v) { return m * v; }
vec4 mul(vec4 v, mat4x4 m) { return m * v; }
#define lerp mix
#define saturate(x) clamp(x, 0.0, 1.0)
#define isaturate(x) clamp(x, 0, 1)
#define frac(x) fract(x)
#define rsqrt(x) inversesqrt(x)
#define gfsdk_VertexID gl_VertexID
#define RWTEXTURE3DUINT(name, slot) layout(r32ui, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform uimage3D name
#define RWTEXTURE3DHALF(name, slot) layout(rgba16f, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image3D name
#define RWTEXTURE3DFLOAT(name, slot) layout(rgba32f, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image3D name
#define RWTEXTURE2DUNORM8(name, slot) layout(r8, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image2D name
#define RWTEXTURE2DFLOAT(name, slot) layout(rgba32f, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image2D name
#define RWTEXTURE2DFLOAT1(name, slot) layout(r32f, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image2D name
#define RWTEXTURE2DARRAYFLOAT1(name, slot) layout(r32f, binding = GFSDK_IMAGE_SLOT_BASE + slot) uniform image2DArray name
#define TEXTURE3DUINT(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform usampler3D name
#define TEXTURE3DFLOAT(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform sampler3D name
#define TEXTURE2D(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform sampler2D name
#define TEXTURE2DMS(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform sampler2DMS name
#define TEXTURE2DARRAY(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform sampler2DArray name
#define TEXTURE2DSTENCIL(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform usampler2D name
#define TEXTURE2DSTENCILMS(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform usampler2DMS name
#define TEXTURECUBE(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform samplerCubeArray name
#define RWBUFFER(type, name, slot) \
    layout(binding = GFSDK_SSBO_SLOT_BASE + slot) buffer name##slot { type name[]; }
#define BUFFERUINT(name, slot) layout(binding = GFSDK_TEXTURE_SLOT_BASE + slot) uniform usamplerBuffer name
#define STRUCTUREDBUFFER(type, name, slot) \
    layout(binding = GFSDK_SSBO_SLOT_BASE + slot) buffer name##slot { type name[]; }
#define RWSTRUCTUREDBUFFER(type, name, slot) \
    layout(binding = GFSDK_SSBO_SLOT_BASE + slot) buffer name##slot { type name[]; }
#define SAMPLER(name, slot)
#define CS_COMMON_INPUT
#define NUMTHREADS(x, y, z) layout(local_size_x = x, local_size_y = y, local_size_z = z) in;
#define STORE_SCALAR(e) e.xxxx
#define nointerpolation
#define static
#define groupshared shared
#define gfsdk_Unroll
#define gfsdk_Loop
#define gfsdk_Equal(a, b) equal(a, b)
#define gfsdk_NotEqual(a, b) notEqual(a, b)
#define gfsdk_LessThanEqual(a, b) lessThanEqual(a, b)
#define gfsdk_LessThan(a, b) lessThan(a, b)
#define gfsdk_GreaterThanEqual(a, b) greaterThanEqual(a, b)
#define gfsdk_GreaterThan(a, b) greaterThan(a, b)
#define gfsdk_BufferLoad(buffer, addr) texelFetch(buffer, addr)
#define gfsdk_TextureLoad(texture, addr) texelFetch(texture, addr, 0)
#define gfsdk_TextureLoadMS(texture, addr, sample) texelFetch(texture, addr, sample)
#define gfsdk_ImageLoad(image, addr) imageLoad(image, addr)
#define gfsdk_ImageStore(image, addr, value) imageStore(image, addr, value)
#define gfsdk_ScalarStoreUint(x) uint4scalar(x)
#define gfsdk_CubemapSamplePos(x) float4(x, 0)
#define gfsdk_GroupIdx gl_WorkGroupID
#define gfsdk_GroupThreadIdx gl_LocalInvocationID
#define gfsdk_GlobalIdx gl_GlobalInvocationID
// efine gfsdk_ColorOutput gl_FragColor
#define gfsdk_DepthOutput gl_FragDepth
#define gfsdk_InvocationID gl_InvocationID
#define gfsdk_EmitVertex(stream, vertex) EmitVertex()
#define gfsdk_EndPrimitive(stream) EndPrimitive()
#define gfsdk_ddx(x) dFdx(x)
#define gfsdk_ddy(x) dFdy(x)
#define GroupMemoryBarrierWithGroupSync barrier
#define gfsdk_AtomicAdd(dst, value, prevValue) prevValue = atomicAdd(dst, value)
#define gfsdk_ImageReductionAdd(image, addr, value) imageAtomicAdd(image, addr, value)
#define gfsdk_ImageReductionOr(image, addr, value) imageAtomicOr(image, addr, value)
#define gfsdk_SharedReductionOr(variable, value) atomicOr(variable, value)
#define NvInterlockedAddFp16x4 imageAtomicAdd
#define countbits bitCount
#define rcp(x) (1.0 / float(x))
#define gfsdk_Position gl_Position
#define BUILTIN_GLVAR_IN_STRUCT(struct, var) var
#else
#error Shader model not defined (expected GFSDK_VXGI_SM5 or GFSDK_VXGI_GL)
#endif
#define AMAP_PRESENT_BIT 0x01
#define AMAP_EMISSIVE_BIT 0x02
#define AMAP_GEOMETRY_DIRTY_BIT 0x04
#define AMAP_LIGHTING_DIRTY_BIT 0x08
#define AMAP_DILATED_EMITTANCE_BIT 0x10
#define PAGE_DATA_VALID_BIT 0x80000000u
#define TOROIDAL_ADDRESS(localPos, offset, textureSize) ((localPos) + (offset)) & ((textureSize) - 1)
#define EMITTANCE_DIRECTIONS 6
#define EMITTANCE_FIXED_POINT_BITS 20
#define MARK_EMITTANCE_IN_OPACITY 1
#define MARK_OPACITY_MASK 0xC0000000u
#define INJECTION_FIXED_POINT_SCALE 65536
#if MARK_EMITTANCE_IN_OPACITY
#define MARK_OPACITY(_address_) gfsdk_ImageStore(u_Opacity_Pos, _address_, gfsdk_ImageLoad(u_Opacity_Pos, _address_) | MARK_OPACITY_MASK)
#define CLEAR_OPACITY(_address_) gfsdk_ImageStore(u_Opacity_Pos, _address_, gfsdk_ImageLoad(u_Opacity_Pos, _address_) & ~MARK_OPACITY_MASK)
#else
#define MARK_OPACITY(_address_)
#define CLEAR_OPACITY(_address_)
#endif
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
    float2 uv SEMANTIC(TEXCOORD);
    float4 posProj SEMANTIC(RAY);
    float instanceID SEMANTIC(INSTANCEID);
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
float VxgiToSRGB(float x)
{
    x = saturate(x);
    return x <= 0.0031308f ? x * 12.92f : saturate(1.055f * pow(x, 0.4166667f) - 0.055f);
}
float VxgiFromSRGB(float x)
{
    return x <= 0.04045f ? saturate(x * 0.0773994f) : pow(saturate(x * 0.9478672f + 0.0521327f), 2.4f);
}
EMITTANCE_STORAGE_TYPE VxgiPackEmittance(float4 v)
{
#if EMITTANCE_FORMAT == FLOAT16 || EMITTANCE_FORMAT == FLOAT16_NVAPI
    return EMITTANCE_STORAGE_TYPE(v);
#elif EMITTANCE_FORMAT == FLOAT32
    return floatBitsToUint(v.rgb);
#else
    v.rgb = float3(VxgiToSRGB(v.r), VxgiToSRGB(v.g), VxgiToSRGB(v.b));
    uint result = uint(255.0f * v.x) | (uint(255.0f * v.y) << 8) | (uint(255.0f * v.z) << 16);
    return result;
#endif
}
float4 VxgiUnpackEmittance(EMITTANCE_STORAGE_TYPE n)
{
#if EMITTANCE_FORMAT == FLOAT16 || EMITTANCE_FORMAT == FLOAT16_NVAPI
    return float4(n.rgba);
#elif EMITTANCE_FORMAT == FLOAT32
    return float4(uintBitsToFloat(n.rgb), 0);
#else
    float3 result;
    result.x = ((n >> 0) & 0xFF) / 255.0f;
    result.y = ((n >> 8) & 0xFF) / 255.0f;
    result.z = ((n >> 16) & 0xFF) / 255.0f;
    result = float3(VxgiFromSRGB(result.r), VxgiFromSRGB(result.g), VxgiFromSRGB(result.b));
    return float4(result, 0);
#endif
}
#if EMITTANCE_FORMAT == FLOAT16 || EMITTANCE_FORMAT == FLOAT16_NVAPI
f16vec4 VxgiPackEmittanceForAtomic(float4 v)
{
#if defined(GFSDK_VXGI_GL)
    return f16vec4(v);
#else
    uint4 parts = f32tof16(v);
    return uint2(parts.x | (parts.y << 16), parts.z | (parts.w << 16));
#endif
}
#else
uint3 VxgiPackEmittanceForAtomic(float3 v)
{
    float fixedPointScale = 1 << EMITTANCE_FIXED_POINT_BITS;
    return uint3(v.rgb * fixedPointScale);
}
#endif
uint VxgiPackOpacity(float3 opacity)
{
    return uint(1023 * opacity.x) | (uint(1023 * opacity.y) << 10) | (uint(1023 * opacity.z) << 20);
}
float4 VxgiUnpackOpacity(uint opacity)
{
    float4 fOpacity;
    fOpacity.x = float((opacity) & 0x3ff) / 1023.0;
    fOpacity.y = float((opacity >> 10) & 0x3ff) / 1023.0;
    fOpacity.z = float((opacity >> 20) & 0x3ff) / 1023.0;
    fOpacity.w = 0;
    return fOpacity;
}
float VxgiGetNormalProjection(float3 normal, uint direction)
{
    float normalProjection = 0;
    switch (direction)
    {
    case EMITTANCE_POSITIVE_X:
        normalProjection = saturate(normal.x);
        break;
    case EMITTANCE_NEGATIVE_X:
        normalProjection = saturate(-normal.x);
        break;
    case EMITTANCE_POSITIVE_Y:
        normalProjection = saturate(normal.y);
        break;
    case EMITTANCE_NEGATIVE_Y:
        normalProjection = saturate(-normal.y);
        break;
    case EMITTANCE_POSITIVE_Z:
        normalProjection = saturate(normal.z);
        break;
    case EMITTANCE_NEGATIVE_Z:
        normalProjection = saturate(-normal.z);
        break;
    }
    return normalProjection;
}
float VxgiAverage4(float a, float b, float c, float d)
{
    return (a + b + c + d) / 4;
}
float VxgiMultiplyComplements(float a, float b)
{
    return 1 - (1 - a) * (1 - b);
}
bool VxgiIsOdd(int x)
{
    return (x & 1) != 0;
}
SAMPLER(s_VoxelTextureSampler, VXGI_VOXELTEX_SAMPLER_SLOT)
TEXTURE3DFLOAT(t_OpacityMap_Pos, VXGI_OPACITY_POS_SRV_SLOT);
TEXTURE3DFLOAT(t_OpacityMap_Neg, VXGI_OPACITY_NEG_SRV_SLOT);
#if EMITTANCE_FORMAT == FLOAT32
TEXTURE3DFLOAT(t_EmittanceEvenR, VXGI_EMITTANCE_EVEN_R_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceEvenG, VXGI_EMITTANCE_EVEN_G_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceEvenB, VXGI_EMITTANCE_EVEN_B_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceOddR, VXGI_EMITTANCE_ODD_R_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceOddG, VXGI_EMITTANCE_ODD_G_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceOddB, VXGI_EMITTANCE_ODD_B_SRV_SLOT);
#elif EMITTANCE_FORMAT == UNORM8
TEXTURE3DFLOAT(t_EmittanceEven, VXGI_EMITTANCE_EVEN_R_SRV_SLOT);
TEXTURE3DFLOAT(t_EmittanceOdd, VXGI_EMITTANCE_ODD_R_SRV_SLOT);
#endif
struct VxgiAbstractTracingConstants
{
    float4 rOpacityTextureSize;
    float4 rEmittanceTextureSize;
    float4 ClipmapAnchor;
    float4 SceneBoundaryLower;
    float4 SceneBoundaryUpper;
    float4 ClipmapCenter;
    float4 TracingToroidalOffset;
    float EmittancePackingStride;
    float FinestVoxelSize;
    float StackTextureSize;
    float rNearestLevel0Boundary;
    float MaxMipmapLevel;
    float rEmittanceStorageScale;
    float rClipmapSizeWorld;
    uint Use6DOpacity;
};
CBUFFER(AbstractTracingCB, VXGI_CONE_TRACING_CB_SLOT)
{
    VxgiAbstractTracingConstants g_VxgiAbstractTracingCB;
};
CBUFFER(TranslationCB, VXGI_CONE_TRACING_TRANSLATION_CB_SLOT)
{
    float4 g_VxgiTranslationParameters[MAX_TOTAL_LEVELS];
    float4 g_VxgiTranslationParameters2[MAX_TOTAL_LEVELS];
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
float VxgiGetDistanceFromAnchor(float3 position)
{
    float3 centerOffset = abs(position - g_VxgiAbstractTracingCB.ClipmapAnchor.xyz);
    return max(centerOffset.x, max(centerOffset.y, centerOffset.z));
}
float VxgiGetMinSampleSizeInternal(float distanceFromAnchor)
{
    return max(2 * distanceFromAnchor * g_VxgiAbstractTracingCB.rNearestLevel0Boundary, 1);
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
void VxgiGetLevelCoordinates(float3 position, float level, out float3 opacityCoords, out float3 emittanceCoords)
{
    float4 translationParams = g_VxgiTranslationParameters[int(level)];
    float4 translationParams2 = g_VxgiTranslationParameters2[int(level)];
    float3 positionInClipmap = (position - g_VxgiAbstractTracingCB.ClipmapCenter.xyz) * translationParams.x + 0.5;
    float3 fVoxelCoord = frac(positionInClipmap + translationParams2.xyz);
    float3 iVoxelCoord = fVoxelCoord * translationParams.y;
    opacityCoords = (iVoxelCoord + float3(0, 0, translationParams.z)) * g_VxgiAbstractTracingCB.rOpacityTextureSize.xyz;
    emittanceCoords = (iVoxelCoord + float3(1, 0, translationParams.w)) * g_VxgiAbstractTracingCB.rEmittanceTextureSize.xyz;
}
float VxgiSampleOpacityTextures(float3 coords, float3 direction, bool flipOpacityDirections, out bool sampleEmittance)
{
    float opacity;
    float4 pos = SampleTexLod(s_VoxelTextureSampler, t_OpacityMap_Pos, coords, 0);
    if (bool(g_VxgiAbstractTracingCB.Use6DOpacity))
    {
        float4 neg = SampleTexLod(s_VoxelTextureSampler, t_OpacityMap_Neg, coords, 0);
        if (flipOpacityDirections)
        {
            direction = -direction;
        }
        opacity = VxgiProjectDirectionalOpacities(pos.xyz, -direction) + VxgiProjectDirectionalOpacities(neg.xyz, direction);
    }
    else
    {
        opacity = VxgiProjectDirectionalOpacities(pos.xyz, abs(direction));
    }
#if EMITTANCE_FORMAT == NONE
    sampleEmittance = false;
#elif MARK_EMITTANCE_IN_OPACITY
    sampleEmittance = pos.w != 0 ? true : false;
#else
    sampleEmittance = true;
#endif
    return opacity;
}
#if EMITTANCE_FORMAT != NONE
float3 VxgiSampleEmittanceTextures(float3 coords, float3 direction, bool VxgiIsOdd)
{
    float3 emittanceX, emittanceY, emittanceZ;
    float offsetX = direction.x > 0 ? EMITTANCE_NEGATIVE_X : EMITTANCE_POSITIVE_X;
    float offsetY = direction.y > 0 ? EMITTANCE_NEGATIVE_Y : EMITTANCE_POSITIVE_Y;
    float offsetZ = direction.z > 0 ? EMITTANCE_NEGATIVE_Z : EMITTANCE_POSITIVE_Z;
    float3 coordsX = coords + float3(offsetX * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);
    float3 coordsY = coords + float3(offsetY * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);
    float3 coordsZ = coords + float3(offsetZ * g_VxgiAbstractTracingCB.EmittancePackingStride, 0, 0);
    if (VxgiIsOdd)
    {
        emittanceX = SAMPLE_EMITTANCE(t_EmittanceOdd, s_VoxelTextureSampler, coordsX).rgb;
        emittanceY = SAMPLE_EMITTANCE(t_EmittanceOdd, s_VoxelTextureSampler, coordsY).rgb;
        emittanceZ = SAMPLE_EMITTANCE(t_EmittanceOdd, s_VoxelTextureSampler, coordsZ).rgb;
    }
    else
    {
        emittanceX = SAMPLE_EMITTANCE(t_EmittanceEven, s_VoxelTextureSampler, coordsX).rgb;
        emittanceY = SAMPLE_EMITTANCE(t_EmittanceEven, s_VoxelTextureSampler, coordsY).rgb;
        emittanceZ = SAMPLE_EMITTANCE(t_EmittanceEven, s_VoxelTextureSampler, coordsZ).rgb;
    }
    return abs(direction.x) * emittanceX + abs(direction.y) * emittanceY + abs(direction.z) * emittanceZ;
}
#endif

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

#define EXCHANGE(TYPE, A, B) \
    {                        \
        TYPE temp = A;       \
        A = B;               \
        B = temp;            \
    }

void VxgiSampleVoxelData(float3 curPosition, float fLevel, float3 direction, float weight, bool flipOpacityDirections, out float opacity, out float3 emittance, out bool anyEmittance)
{
    bool sampleEmittance1, sampleEmittance2;
    float iLevel = floor(fLevel);
    float fracLevel = fLevel - iLevel;
    float weightLow = (1.0 - fracLevel) * weight;
    float weightHigh = (fLevel > g_VxgiAbstractTracingCB.MaxMipmapLevel) ? 0 : fracLevel * weight;
    float3 opacityCoords1, opacityCoords2;
    float3 emittanceCoords1, emittanceCoords2;
    VxgiGetLevelCoordinates(curPosition, iLevel, opacityCoords1, emittanceCoords1);
    VxgiGetLevelCoordinates(curPosition, iLevel + 1, opacityCoords2, emittanceCoords2);
    opacity =
        VxgiSampleOpacityTextures(opacityCoords1.xyz, direction, flipOpacityDirections, sampleEmittance1) * weightLow +
        VxgiSampleOpacityTextures(opacityCoords2.xyz, direction, flipOpacityDirections, sampleEmittance2) * weightHigh;
    emittance = float3(0, 0, 0);
    anyEmittance = false;
#if EMITTANCE_FORMAT != NONE
    float factorLow = pow(4, iLevel) * VxgiSqr(g_VxgiAbstractTracingCB.FinestVoxelSize);
    float factorHigh = factorLow * 4;
    factorLow *= weightLow;
    factorHigh *= weightHigh;
    if ((int(iLevel) & 1) != 0)
    {
        EXCHANGE(float, factorHigh, factorLow);
        EXCHANGE(float3, emittanceCoords1, emittanceCoords2);
        EXCHANGE(bool, sampleEmittance1, sampleEmittance2);
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
#endif
}
void VxgiGetTangentAndCotangent(float3 normal, out float3 tangent, out float3 cotangent)
{
    float3 absNormal = abs(normal);
    float maxComp = max(absNormal.x, max(absNormal.y, absNormal.z));
    if (maxComp == absNormal.x)
        tangent = float3((-normal.y - normal.z) * sign(normal.x), absNormal.x, absNormal.x);
    else if (maxComp == absNormal.y)
        tangent = float3(absNormal.y, (-normal.x - normal.z) * sign(normal.y), absNormal.y);
    else
        tangent = float3(absNormal.z, absNormal.z, (-normal.x - normal.y) * sign(normal.z));
    tangent = normalize(tangent);
    cotangent = cross(tangent, normal);
}
struct VxgiConeTracingArguments
{
    float3 firstSamplePosition;
    float3 direction;
    float coneFactor;
    float tracingStep;
    float firstSampleT;
    float maxTracingDistance;
    float opacityCorrectionFactor;
    float randomSeed;
    float tangentJitterScale;
    bool enableSceneBoundsCheck;
    bool flipOpacityDirections;
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
    args.opacityCorrectionFactor = 1.0;
    args.enableSceneBoundsCheck = true;
    args.flipOpacityDirections = false;
    args.randomSeed = 0;
    args.tangentJitterScale = 0;
    return args;
}
struct VxgiConeTracingResults
{
    float3 radiance;
    float finalOpacity;
};

#ifndef VXGI_MONITOR_CONE_TRACING
#endif

#define VCT_CLIPMAP_LEVEL_COUNT 5
// #define VCT_CLIPMAP_SIZE 128
// #define VCT_CLIPMAP_FINEST_VOXEL_SIZE 8

#define VCT_CONE_TRACING_SAMPLE_COUNT 128

VxgiConeTracingResults VxgiTraceCone(VxgiConeTracingArguments args)
{
    const float VCT_CLIPMAP_FINEST_VOXEL_SIZE = g_VxgiAbstractTracingCB.FinestVoxelSize;
    const float VCT_CLIPMAP_SIZE = g_VxgiAbstractTracingCB.StackTextureSize;

    const float clipmap_boundary = float(VCT_CLIPMAP_FINEST_VOXEL_SIZE) * float(1 << (int(VCT_CLIPMAP_LEVEL_COUNT) - 1)) * (float(VCT_CLIPMAP_SIZE) * 0.5 - 0.5);

    float initialTransparency = 1.0;
    float transparency = initialTransparency;
    float pTransparency = initialTransparency;
    float ppTransparency = initialTransparency;

    float3 cone_radiance = float3(0.0, 0.0, 0.0);

    float3 curPosition = args.firstSamplePosition;
    float t = args.firstSampleT;
    float3 direction = args.direction;

    float3 tangent;
    float3 cotangent;
    VxgiGetTangentAndCotangent(direction, tangent, cotangent);

    int poissonOffset = int(frac(args.randomSeed) * g_VxgiPoissonDiskSize);

    float maxT = args.maxTracingDistance / g_VxgiAbstractTracingCB.FinestVoxelSize;

    gfsdk_Loop for (int sampleIndex = 0; sampleIndex < int(VCT_CONE_TRACING_SAMPLE_COUNT); ++sampleIndex)
    {
        float distanceFromAnchor = VxgiGetDistanceFromAnchor(curPosition);
        float distanceToBoundary = clipmap_boundary - distanceFromAnchor;
        float relative_distance_from_anchor = distanceFromAnchor * (1.0 / clipmap_boundary);
        float minSampleSize = max(2 * relative_distance_from_anchor, 1);

        float tStep;
        float fLevel;
        float sampleSize;
        VxgiCalculateSampleParameters(t, args.coneFactor, args.tracingStep, minSampleSize, tStep, fLevel, sampleSize);

        if (fLevel >= g_VxgiAbstractTracingCB.MaxMipmapLevel + 1 || (args.maxTracingDistance != 0 && t > maxT))
        {
            break;
        }

        float sampleSizeWorld = sampleSize * g_VxgiAbstractTracingCB.FinestVoxelSize;
        distanceToBoundary -= sampleSizeWorld;
        if (distanceToBoundary < 0)
        {
            break;
        }

        if (args.enableSceneBoundsCheck)
        {
            if (any(gfsdk_LessThan(curPosition.xyz + sampleSizeWorld, g_VxgiAbstractTracingCB.SceneBoundaryLower.xyz)) || any(gfsdk_GreaterThan(curPosition.xyz - sampleSizeWorld, g_VxgiAbstractTracingCB.SceneBoundaryUpper.xyz)))
                break;
        }

        float3 emittance;
        float alpha;
        {
            float weight = saturate(distanceToBoundary / sampleSizeWorld);

            float3 adjustedPosition = curPosition;
            if (args.tangentJitterScale > 0)
            {
                float2 poisson = g_VxgiPoissonDisk[(int(sampleIndex) + poissonOffset) & (g_VxgiPoissonDiskSize - 1)];
                poisson *= sampleSize * g_VxgiAbstractTracingCB.FinestVoxelSize * args.tangentJitterScale;
                adjustedPosition = curPosition + tangent * poisson.x + cotangent * poisson.y;
            }

            float opacity;
            bool anyEmittance;
            VxgiSampleVoxelData(adjustedPosition, fLevel, direction, weight, args.flipOpacityDirections, opacity, emittance, anyEmittance);

            if (anyEmittance)
            {
                emittance *= VxgiSqr(1.0 / (sampleSize * g_VxgiAbstractTracingCB.FinestVoxelSize));
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

        cone_radiance += ppTransparency * emittance;

        ppTransparency = pTransparency;
        pTransparency = transparency;

        // [Dunn 2014] [Alex Dunn. "Transparency (or Translucency) Rendering." NVIDIA GameWorks Blog 2014.](https://developer.nvidia.com/content/transparency-or-translucency-rendering)
        // under operation
        transparency *= (1.0 - alpha);

        if (ppTransparency < 0.0001)
        {
            break;
        }

        t += tStep;
        curPosition += tStep * g_VxgiAbstractTracingCB.FinestVoxelSize * direction;
    }

    VxgiConeTracingResults result;
    result.radiance = cone_radiance;
    result.finalOpacity = saturate(1.0f - transparency);
    return result;
}

#ifdef TEST_COMPILE
#ifdef GFSDK_VXGI_GL
#define gl_FragColor gfsdk_ColorOutput
layout(location = 0) out float4 gfsdk_ColorOutput;
// t float4 gl_FragColor;
void main()
#else
void main(out float4 gl_FragColor : SV_Target)
#endif
{
    VxgiConeTracingArguments args = VxgiDefaultConeTracingArguments();
    VxgiConeTracingResults cone = VxgiTraceCone(args);
    gl_FragColor = float4(cone.radiance.rgb, cone.ambient);
}
#endif

struct GBufferParameters
{
    float4x4 viewProjMatrix;
    float4x4 viewProjMatrixInv;
    float4x4 viewMatrix;
    float4 cameraPosition;
    float4 uvToView;
    float2 gbufferSize;
    float2 gbufferSizeInv;
    float2 viewportOrigin;
    float2 viewportSize;
    float2 viewportSizeInv;
    float2 firstSamplePosition;
    float projectionA;
    float projectionB;
    float depthScale;
    float depthBias;
    float normalScale;
    float normalBias;
    float radiusToScreen;
};
#if MSAA_G_BUFFER
#define Load2D(tex, iCoords, i) gfsdk_TextureLoadMS(tex, iCoords, i)
TEXTURE2DMS(g_DepthBuffer, 0);
TEXTURE2DMS(g_TargetNormal, 2);
TEXTURE2DMS(g_TargetFlatNormal, 3);
TEXTURE2DSTENCILMS(g_TargetStencil, 4);
#else
#define Load2D(tex, iCoords, i) gfsdk_TextureLoad(tex, iCoords)
TEXTURE2D(g_DepthBuffer, 0);
TEXTURE2D(g_TargetNormal, 2);
TEXTURE2D(g_TargetFlatNormal, 3);
TEXTURE2DSTENCIL(g_TargetStencil, 4);
#endif
float RescaleDepth(float depthFromGBuffer, GBufferParameters gbufferParams)
{
    return depthFromGBuffer * gbufferParams.depthScale + gbufferParams.depthBias;
}
float3 RescaleNormal(float3 normalFromBGuffer, GBufferParameters gbufferParams)
{
    float3 scaled = normalFromBGuffer.xyz * gbufferParams.normalScale + gbufferParams.normalBias;
    float len = length(scaled);
    if (len > 0)
        return scaled / len;
    return float3(0, 0, 0);
}
float2 PixelToUV(float2 sampleScreenPosition, GBufferParameters gbufferParams)
{
    float2 uv = (sampleScreenPosition - gbufferParams.viewportOrigin) * gbufferParams.viewportSizeInv;
#if defined(GFSDK_VXGI_GL)
    uv.y = 1.0 - uv.y;
#endif
    return uv;
}
float3 DepthToWorldPos(float2 sampleScreenPosition, float depth, GBufferParameters gbufferParams)
{
    float2 uv = PixelToUV(sampleScreenPosition, gbufferParams);
#if defined(GFSDK_VXGI_GL)
    depth = depth * 2.0 - 1.0;
#endif
    float4 clipCoord = float4(uv.x * 2.0f - 1.0f, 1.0f - uv.y * 2.0f, depth, 1.0f);
    float4 samplePosition = mul(clipCoord, gbufferParams.viewProjMatrixInv);
    samplePosition.xyz /= samplePosition.w;
    return samplePosition.xyz;
}
float DepthToViewSpaceDepth(float depth, GBufferParameters gbufferParams)
{
#if defined(GFSDK_VXGI_GL)
    return gbufferParams.projectionB / (depth * 2.0 - 1.0 - gbufferParams.projectionA);
#else
    return gbufferParams.projectionB / (depth - gbufferParams.projectionA);
#endif
}
void GetGeometrySampleFromGBuffer(int2 sampleScreenPosition, int sampleIndex, GBufferParameters gbufferParams, out float depth, out float4 normal, out float3 smoothNormal)
{
    depth = Load2D(g_DepthBuffer, sampleScreenPosition, sampleIndex).x;
    normal = Load2D(g_TargetNormal, sampleScreenPosition, sampleIndex);
    smoothNormal = Load2D(g_TargetFlatNormal, sampleScreenPosition, sampleIndex).xyz;
    depth = RescaleDepth(depth, gbufferParams);
    normal.xyz = RescaleNormal(normal.xyz, gbufferParams);
    smoothNormal.xyz = RescaleNormal(smoothNormal.xyz, gbufferParams);
}
bool IsInfOrNaN(float x)
{
    uint exponent = floatBitsToUint(x) & 0x7f800000;
    return exponent == 0x7f800000;
}
bool IsInfOrNaN(float4 v)
{
    return IsInfOrNaN(v.x) || IsInfOrNaN(v.y) || IsInfOrNaN(v.z) || IsInfOrNaN(v.w);
}
bool IsInvalidNormal(float3 normal)
{
    uint3 normalExp = floatBitsToUint(normal) & 0x7f800000;
    return all(gfsdk_Equal(normalExp, uint3(0, 0, 0))) || any(gfsdk_Equal(normalExp, uint3(0x7f800000, 0x7f800000, 0x7f800000)));
}
float GetDepthDiscontinuity(float refW, float w, float rMinSampleSize)
{
    return saturate(abs(refW - w) * rMinSampleSize * 0.05);
}
float GetNormalDiscontinuity(float3 refNormal, float3 normal)
{
    return saturate(1.0 - pow(saturate(dot(refNormal, normal)), 20));
}
#define USE_ROTATED_GRID 1
CBUFFER(cBuiltinTracingParameters, 2)
{
    GBufferParameters g_GBuffer;
    GBufferParameters g_PreviousGBuffer;
    float4x4 g_ReprojectionMatrix;
    float4 g_AmbientColor;
    float4 g_DownsampleScale;
    float4 g_DebugParams;
    float4 g_EnvironmentMapTint;
    float4 g_RefinementGridResolution;
    float4 g_BackgroundColor;
    int2 g_PixelToSave;
    int2 g_RandomOffset;
    float2 g_GridOrigin;
    float g_ConeFactor;
    float g_TracingStep;
    float g_OpacityCorrectionFactor;
    int g_MaxSamples;
    int g_NumCones;
    float g_rNumCones;
    float g_EmittanceScale;
    float g_EnvironmentMapResolution;
    float g_MaxEnvironmentMapMipLevel;
    float g_NormalOffsetFactor;
    float g_AmbientAttenuationFactor;
    uint g_FlipOpacityDirections;
    float g_InitialOffsetBias;
    float g_InitialOffsetDistanceFactor;
    uint g_EnableSpecularRandomOffsets;
    uint g_NumDiscontinuityLevels;
    float g_TemporalReprojectionWeight;
    float g_TangentJitterScale;
    float g_DepthDeltaSign;
    float g_ReprojectionDepthWeightScale;
    float g_ReprojectionNormalWeightExponent;
    float g_InterpolationWeightThreshold;
    uint g_EnableRefinement;
    float g_AmbientScale;
    float g_AmbientBias;
    float g_AmbientPower;
    float g_AmbientDistanceDarkening;
    int g_AltSettingsStencilMask;
    int g_AltSettingsStencilRefValue;
    float g_AltInitialOffsetBias;
    float g_AltInitialOffsetDistanceFactor;
    float g_AltNormalOffsetFactor;
    float g_AltTracingStep;
    float g_SSAO_SurfaceBias;
    float g_SSAO_RadiusWorld;
    float g_SSAO_rBackgroundViewDepth;
    float g_SSAO_CoarseAO;
    float g_SSAO_PowerExponent;
};
float4 GetColorFromPreviousFrame(
    float2 uv,
    float newDepth,
    float3 newNormal,
#if defined(GFSDK_VXGI_SM5)
#if MSAA_G_BUFFER
    Texture2DMS<float4> prevDepthBuffer,
    Texture2DMS<float4> prevNormalBuffer,
#else
    Texture2D<float4> prevDepthBuffer,
    Texture2D<float4> prevNormalBuffer,
#endif
    Texture2D<float4> prevColorBuffer,
#else
#if MSAA_G_BUFFER
    sampler2DMS prevDepthBuffer,
    sampler2DMS prevNormalBuffer,
#else
    sampler2D prevDepthBuffer,
    sampler2D prevNormalBuffer,
#endif
    sampler2D prevColorBuffer,
#endif
    out float totalWeight)
{
#if defined(GFSDK_VXGI_GL)
    newDepth = newDepth * 2.0 - 1.0;
#endif
    totalWeight = 0;
    float4 clipCoord = float4(uv.x * 2.0f - 1.0f, 1.0f - uv.y * 2.0f, newDepth, 1.0f);
    float4 previousClipCoord = mul(clipCoord, g_ReprojectionMatrix);
    if (any(gfsdk_GreaterThanEqual(abs(previousClipCoord.xyz), previousClipCoord.www)) || previousClipCoord.w <= 0)
        return float4(0, 0, 0, 0);
    previousClipCoord.xyz /= previousClipCoord.w;
#if defined(GFSDK_VXGI_GL)
    previousClipCoord.y = -previousClipCoord.y;
    previousClipCoord.z = previousClipCoord.z * 0.5 + 0.5;
#endif
    float2 oldPos;
    oldPos.x = g_PreviousGBuffer.viewportOrigin.x + (previousClipCoord.x * 0.5 + 0.5) * g_PreviousGBuffer.viewportSize.x;
    oldPos.y = g_PreviousGBuffer.viewportOrigin.y + (0.5 - previousClipCoord.y * 0.5) * g_PreviousGBuffer.viewportSize.y;
    float expectedW = DepthToViewSpaceDepth(previousClipCoord.z, g_PreviousGBuffer);
    float4 colorSum = float4(0, 0, 0, 0);
    gfsdk_Unroll for (float x = -0.5; x < 1; x++)
        gfsdk_Unroll for (float y = -0.5; y < 1; y++)
    {
        float2 samplePos = floor(oldPos + float2(x, y));
        int2 isamplePos = int2(samplePos);
        float oldW = DepthToViewSpaceDepth(RescaleDepth(Load2D(prevDepthBuffer, isamplePos, 0).x, g_PreviousGBuffer), g_PreviousGBuffer);
        float3 oldNormal = RescaleNormal(Load2D(prevNormalBuffer, isamplePos, 0).xyz, g_PreviousGBuffer);
        float4 oldColor = gfsdk_TextureLoad(prevColorBuffer, isamplePos).rgba;
        float depthWeight = saturate(1.0 - abs(expectedW - oldW) * g_ReprojectionDepthWeightScale);
        float normalWeight = saturate(pow(saturate(dot(newNormal, oldNormal)), g_ReprojectionNormalWeightExponent));
        float bilerpWeight = saturate((1.0 - abs(oldPos.x - samplePos.x - 0.5)) * (1.0 - abs(oldPos.y - samplePos.y - 0.5)));
        float weight = depthWeight * normalWeight * bilerpWeight;
        if (!(IsInfOrNaN(weight) || IsInfOrNaN(oldColor)))
        {
            colorSum += oldColor.rgba * weight;
            totalWeight += weight;
        }
    }
    return colorSum;
}
float2 GetRotatedGridOffset(float2 pixelCoord)
{
#if USE_ROTATED_GRID
    float2 remainders = floor(frac(pixelCoord * g_DownsampleScale.zw) * g_DownsampleScale.xy);
    return float2(remainders.y, g_DownsampleScale.x - remainders.x - 1);
#else
    return float2(0, 0);
#endif
}
float2 CoarsePosToGBufferPos(float2 coarsePixelPos)
{
    return coarsePixelPos * g_DownsampleScale.xy +
           GetRotatedGridOffset(coarsePixelPos + g_RandomOffset.xy) +
           g_GBuffer.firstSamplePosition;
}
float FindDepthIntersection(float3 startPt, float3 endPt, float numSteps, float depthThreshold, out float3 samplePt)
{
    float4 startClip = mul(float4(startPt, 1), g_GBuffer.viewProjMatrix);
    float4 endClip = mul(float4(endPt, 1), g_GBuffer.viewProjMatrix);
    startClip.xyz /= startClip.w;
    endClip.xyz /= endClip.w;
    float4 windowTransform = float4(0.5, -0.5, 0.5, 0.5);
#if defined(GFSDK_VXGI_GL)
    windowTransform = float4(0.5, 0.5, 0.5, 0.5);
    startClip.z = startClip.z * 0.5 + 0.5;
    endClip.z = endClip.z * 0.5 + 0.5;
#endif
    startClip.xy = startClip.xy * windowTransform.xy + windowTransform.zw;
    endClip.xy = endClip.xy * windowTransform.xy + windowTransform.zw;
    float3 stepSize = (endClip.xyz - startClip.xyz) / numSteps;
    float threshold = abs(stepSize.z) * 0.1;
    float depth = 1.0;
    bool hit = false;
    for (float i = 0; i < numSteps; ++i)
    {
        samplePt = startClip.xyz + stepSize * i;
        depth = RescaleDepth(Load2D(g_DepthBuffer, int2(samplePt.xy * g_GBuffer.viewportSize + g_GBuffer.viewportOrigin), 0).x, g_GBuffer);
        float depthDiff = (samplePt.z - depth) * g_DepthDeltaSign;
        hit = depthDiff > threshold;
        if (hit)
            i = numSteps;
    }
    float occlusion = 0;
    if (hit)
    {
        float4 clipTransform = float4(2.0, -2.0, -1.0, 1.0);
#if defined(GFSDK_VXGI_GL)
        clipTransform = float4(2.0, 2.0, -1.0, -1.0);
        samplePt.z = samplePt.z * 2.0 - 1.0;
        depth = depth * 2.0 - 1.0;
#endif
        samplePt.xy = samplePt.xy * clipTransform.xy + clipTransform.zw;
        float4 posWS_0 = mul(float4(samplePt, 1), g_GBuffer.viewProjMatrixInv);
        posWS_0.xyz /= posWS_0.w;
        float4 posWS_1 = mul(float4(samplePt.xy, depth, 1), g_GBuffer.viewProjMatrixInv);
        posWS_1.xyz /= posWS_1.w;
        samplePt = posWS_0.xyz;
        float delta = length(posWS_0.xyz - posWS_1.xyz);
        if (delta < depthThreshold)
        {
            occlusion = 1.0 - pow(saturate(delta / depthThreshold), 0.8);
            occlusion *= 1.0 - length(startPt - posWS_0.xyz) / length(startPt - endPt);
            occlusion = saturate(occlusion);
        }
    }
    return occlusion;
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
    initialOffset += initialOffsetParams.x * sampleNormalParams.w * 5.0;
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
    float coneFactor;
    int coneIndex;
};

#if USE_SAVE_SAMPLES
RWSTRUCTUREDBUFFER(SampleData, u_SamplePositions, 3);
RWSTRUCTUREDBUFFER(ConeData, u_ConeDirections, 4);
RWBUFFER(uint, u_AppendCounters, 5);
void VxgiOnBeginCone(float3 worldPos, float3 direction, float4 userData)
{
    if (userData.x > 0)
    {
        ConeData CD;
        CD.startPos = worldPos;
        CD.direction = direction;
        CD.coneIndex = int(userData.y);
        CD.coneFactor = userData.z;
        uint slot;
        gfsdk_AtomicAdd(u_AppendCounters[1], 1, slot);
        u_ConeDirections[slot] = CD;
    }
}
void VxgiOnConeSample(float t, float3 worldPos, float3 direction, float fLevel, float sampleIndex, float transparency, float3 emittance, float4 userData)
{
    if (userData.x > 0)
    {
        SampleData SD;
        SD.worldSamplePos = worldPos;
        SD.mipLevel = fLevel;
        SD.accumulatedOcclusion = 1 - transparency;
        SD.sampledEmittance = emittance;
        SD.coneIndex = int(userData.y);
        SD.sampleIndex = int(sampleIndex + 1);
        SD.direction = direction;
        SD.sampleT = t;
        uint slot;
        gfsdk_AtomicAdd(u_AppendCounters[0], 1, slot);
        u_SamplePositions[slot] = SD;
    }
}
#endif

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

#define VCT_SPECULAR_CONE_TRACING_CONE_COUNT 1

#define USE_SPECULAR_SS_CORRECTION 0
TEXTURE2D(t_Randoms, 9);
TEXTURECUBE(t_EnvironmentMap, 11);
SAMPLER(s_EnvironmentMapSampler, 11)
#if MSAA_G_BUFFER
TEXTURE2DMS(g_PrevDepthBuffer, 18);
TEXTURE2DMS(g_PrevTargetNormal, 19);
#else
TEXTURE2D(g_PrevDepthBuffer, 18);
TEXTURE2D(g_PrevTargetNormal, 19);
#endif
TEXTURE2D(g_PrevSpecular, 20);
float rand(float2 co)
{
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}
#if defined(GFSDK_VXGI_GL)
in VxgiFullScreenQuadOutput quadIn;
#define gl_FragColor gfsdk_ColorOutput
layout(location = 0) out float4 gfsdk_ColorOutput;
// t float4 gl_FragColor;
void main()
#else
void main(
    VxgiFullScreenQuadOutput quadIn,
    in float4 gl_FragCoord : SV_Position,
    out float4 gl_FragColor : SV_Target)
#endif
{
    float3 color = float3(0.0, 0.0, 0.0);
    uint s = 0;
    float sampleDepth;
    float4 sampleNormalRoughness;
    float3 sampleSmoothNormal;
    GetGeometrySampleFromGBuffer(int2(gl_FragCoord.xy), 0, g_GBuffer, sampleDepth, sampleNormalRoughness, sampleSmoothNormal);
    float3 samplePosition = DepthToWorldPos(gl_FragCoord.xy, sampleDepth, g_GBuffer);
    float params_roughness = sampleNormalRoughness.w;
    if (params_roughness <= 0)
    {
        gl_FragColor = float4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    float3 V = normalize(g_GBuffer.cameraPosition.xyz - samplePosition);
    float3 N = sampleNormalRoughness.xyz;

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

    [branch] if (dot(N, V) < 1E-5)
    {
        return;
    }

    // Prevent the roughness to be zero
    // https://github.com/EpicGames/UnrealEngine/blob/4.27/Engine/Shaders/Private/CapsuleLightIntegrate.ush#L94
    const float cvar_global_min_roughness_override = 0.02;
    float roughness = max(cvar_global_min_roughness_override, params_roughness);

    // Real-Time Rendering Fourth Edition / 9.8.1 Normal Distribution Functions: "In the Disney principled shading model, Burley[214] exposes the roughness control to users as g = r2, where r is the user-interface roughness parameter value between 0 and 1."
    float alpha = roughness * roughness;

    float3 omega_o = normalize(float3(dot(V, T), dot(V, B), dot(V, N)));

    float3 omega_h = float3(0.0, 0.0, 1.0);

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

    // TODO:
    // cone_factor = min(max(0.001, cone_factor), 1.0);

    float minSampleSize = VxgiGetMinSampleSizeInVoxels(samplePosition.xyz);
    float Inv_NDotV_Factor = pow(saturate(1.0 - NdotV), 4.0);
    float perPixelOffset = (g_EnableSpecularRandomOffsets != 0)
                               ? gfsdk_TextureLoad(t_Randoms, int2(gl_FragCoord.xy + g_RandomOffset.xy) & 3).x
                               : 0.5f;
    float4 offsetParams = float4(g_InitialOffsetBias, g_InitialOffsetDistanceFactor, 0, minSampleSize * perPixelOffset * g_TracingStep);

    // roughness = min(roughness, 0.75);
    // float alpha = VxgiSqr(roughness);
    // float coneFactor = alpha * sqrt(VxgiPI);

#if USE_SPECULAR_SS_CORRECTION
    if (g_UseScreenSpaceCorrection != 0)
    {
        const float voxelSize = VxgiGetFinestVoxelSize();
        const float numSteps = (0.5 + 0.5 * Inv_NDotV_Factor) * 60.0;
        const float tracingDistance = voxelSize * (Inv_NDotV_Factor + 0.1) * 20;
        const float tracingOffset = voxelSize * 0.1;
        float3 startPt = samplePosition.xyz + (sampleNormal.xyz + rayDir.xyz) * tracingOffset;
        float3 endPt = samplePosition.xyz + rayDir.xyz * tracingDistance;
        float3 samplePt;
        opacity = FindDepthIntersection(startPt, endPt, numSteps, voxelSize, samplePt);
        if (opacity > 0)
        {
            samplePosition.xyz = lerp(samplePosition.xyz, samplePt, opacity);
            offsetParams *= (1.0 - opacity).xxxx;
        }
    }
#endif

    VxgiConeTracingArguments args = VxgiDefaultConeTracingArguments();
    args.direction = L;
    args.coneFactor = cone_factor;
    args.tracingStep = g_TracingStep;
    args.opacityCorrectionFactor = g_OpacityCorrectionFactor;
    args.enableSceneBoundsCheck = true;
    args.flipOpacityDirections = (g_FlipOpacityDirections != 0);
    args.randomSeed = rand(gl_FragCoord.xy + g_RandomOffset.xy);
    args.tangentJitterScale = g_TangentJitterScale;
    AdjustConePosition(samplePosition.xyz, offsetParams, float4(N, Inv_NDotV_Factor), args);
    VxgiConeTracingResults cone = VxgiTraceCone(args);

    float finalOpacity = cone.finalOpacity;

    // float3 envMapScale = g_EnvironmentMapTint.rgb * (1 - cone.finalOpacity);
    // if (any(gfsdk_GreaterThan(envMapScale, float3scalar(0))))
    // {
    //     float envMip = min(g_MaxEnvironmentMapMipLevel, max(0, log2(coneFactor * g_EnvironmentMapResolution) - 1));
    //     radiosity.rgb += envMapScale * SampleTexLod(s_EnvironmentMapSampler, t_EnvironmentMap, gfsdk_CubemapSamplePos(rayDir), envMip).rgb * VxgiSqr(coneFactor);
    // }

    float3 L_i = cone.radiance;

    float G2_div_G1;
    {
        float alpha2 = alpha * alpha;
        G2_div_G1 = 2.0 * NdotL / (NdotL + sqrt(NdotL * (NdotL - NdotL * alpha2) + alpha2));
    }

    // TODO: from GBuffer
    float3 F = float3(1.0, 1.0, 1.0);
#if 0
    float3 F;
    {
        float x = brx_clamp(1.0 - VdotH, 0.0, 1.0);
        float x2 = x * x;
        float x5 = x * x2 * x2;
        F = f0 + (f90 - f0) * x5;
    }
#endif

    // (1/N) * D * G2 * F / (4.0 * NdotV * NdotL) * L_i * NdotL / (D * (G1 / NdotV) / 4.0) = (1/N) * (G2 / G1) * F * L_i
    float3 radiance = (1.0 / float(VCT_SPECULAR_CONE_TRACING_CONE_COUNT)) * G2_div_G1 * F * L_i;

    if (g_TemporalReprojectionWeight > 0)
    {
        float reprojectedWeight = 0;
        float4 reprojectedColor = GetColorFromPreviousFrame(quadIn.uv, sampleDepth, N,
                                                            g_PrevDepthBuffer, g_PrevTargetNormal, g_PrevSpecular, reprojectedWeight);
        float4 result = float4(radiance, finalOpacity) * (1 - reprojectedWeight * g_TemporalReprojectionWeight) + reprojectedColor.rgba * g_TemporalReprojectionWeight;
        radiance = result.rgb;
        finalOpacity = result.a;
    }
    gl_FragColor.rgb = radiance;
    gl_FragColor.a = finalOpacity;
    gl_FragColor = InfNaNOutputGuard(gl_FragColor);
}

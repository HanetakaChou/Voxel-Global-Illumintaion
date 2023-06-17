/* 
* Copyright (c) 2012-2018, NVIDIA CORPORATION. All rights reserved. 
* 
* NVIDIA CORPORATION and its licensors retain all intellectual property 
* and proprietary rights in and to this software, related documentation 
* and any modifications thereto. Any use, reproduction, disclosure or 
* distribution of this software and related documentation without an express 
* license agreement from NVIDIA CORPORATION is strictly prohibited. 
*/ 

char const g_VoxelizationPS[] = R"(struct PSInput 
{
    float4 position : SV_Position;
    float2 texCoord : TEXCOORD;
    float3 normal   : NORMAL;
    float3 tangent  : TANGENT;
    float3 binormal : BINORMAL;
    float3 positionWS : WSPOSITION;
    VxgiVoxelizationPSInputData vxgiData;
};

void main(PSInput IN)
{
    float3 normal = normalize(IN.normal.xyz);

    float3 radiosity = float3(1.0, 1.0, 1.0);

    VxgiStoreVoxelizationData(IN.vxgiData, normal, 1.0, radiosity, float3(0.0, 0.0, 0.0));
})";

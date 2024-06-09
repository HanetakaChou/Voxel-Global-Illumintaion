/*
 * Copyright (c) 2012-2018, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#pragma once

#include "Windows.h"
#include "GFSDK_NVRHI.h"
#include "GFSDK_VXGI_MathTypes.h"
#include <vector>

struct VertexBufferEntry
{
    VXGI::float3 position;
    VXGI::float3 normal;
};

class Scene
{
protected:
    NVRHI::IRendererInterface *m_Renderer;

    UINT m_numMeshes;

    std::vector<VXGI::Box3f> m_MeshBounds;
    VXGI::Box3f m_SceneBounds;

    std::vector<UINT> m_IndexCounts;
    std::vector<UINT> m_IndexOffsets;
    std::vector<UINT> m_VertexOffsets;

    std::vector<UINT> m_Indices;
    std::vector<VertexBufferEntry> m_Vertices;

    NVRHI::BufferRef m_IndexBuffer;
    NVRHI::BufferRef m_VertexBuffer;

    std::vector<VXGI::float3> m_BaseColors;
    std::vector<float> m_MetallicValues;
    std::vector<float> m_RoughnessValues;

    std::vector<NVRHI::ConstantBufferRef> m_MaterialBuffers;

public:
    Scene() : m_numMeshes(0U), m_Renderer(NULL)
    {
    }

    virtual ~Scene()
    {
        Release();
        ReleaseResources();
    }

    VXGI::float4x4 m_WorldMatrix;

    HRESULT Load(const char *fileName);
    HRESULT InitResources(NVRHI::IRendererInterface *pRenderer);

    void Release();
    void ReleaseResources();

    UINT GetMeshesNum() const { return m_numMeshes; }

    NVRHI::BufferHandle GetIndexBuffer() const { return m_IndexBuffer; }
    NVRHI::BufferHandle GetVertexBuffer() const { return m_VertexBuffer; }

    NVRHI::DrawArguments GetMeshDrawArguments(UINT meshID) const;

    int GetMaterialIndex(UINT meshID) const { return meshID; }
    NVRHI::ConstantBufferRef GetMaterialBuffer(UINT meshID) const;

    VXGI::Box3f GetSceneBounds() const;
    VXGI::Box3f GetMeshBounds(UINT meshID) const;
};
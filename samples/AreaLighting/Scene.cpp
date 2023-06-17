/*
 * Copyright (c) 2012-2018, NVIDIA CORPORATION. All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto. Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#include "Scene.h"
#include "assimp/cimport.h"
#include "assimp/postprocess.h"
#include "FreeImage.h"
#include "SDKmisc.h"
#include <assert.h>

UINT getMipLevelsNum(UINT width, UINT height)
{
    UINT size = __max(width, height);
    UINT levelsNum = (UINT)(logf((float)size) / logf(2.0f)) + 1;

    return levelsNum;
}

HRESULT Scene::Load(const char *fileName, UINT flags)
{
    flags |= aiProcess_Triangulate;
    flags |= aiProcess_CalcTangentSpace;

    m_pScene = (aiScene *)aiImportFile(fileName, flags);

    if (!m_pScene)
    {
        char buf[1024];
        sprintf_s(buf, "unable to load scene file `%s`: %s\n", fileName, aiGetErrorString());
        OutputDebugStringA(buf);
        return E_FAIL;
    }

    m_ScenePath = fileName;

    UINT facesNum = 0;
    UINT verticesNum = 0;

    for (UINT i = 0; i < m_pScene->mNumMeshes; ++i)
    {
        facesNum += m_pScene->mMeshes[i]->mNumFaces;
        verticesNum += m_pScene->mMeshes[i]->mNumVertices;
    }

    UpdateBounds();

    return S_OK;
}

void Scene::Release()
{
    printf("Releasing the scene...\n");

    aiReleaseImport(m_pScene);
    m_pScene = NULL;
}

void Scene::UpdateBounds()
{
    assert(m_pScene != NULL);

    const float maxFloat = 3.402823466e+38F;
    VXGI::float3 _minBoundary(maxFloat, maxFloat, maxFloat);
    VXGI::float3 _maxBoundary(-maxFloat, -maxFloat, -maxFloat);

    if (m_pScene->mNumMeshes)
    {
        m_MeshBounds.resize(m_pScene->mNumMeshes);

        m_SceneBounds.lower = _minBoundary;
        m_SceneBounds.upper = _maxBoundary;

        for (UINT i = 0; i < m_pScene->mNumMeshes; ++i)
        {
            VXGI::float3 minBoundary = _minBoundary;
            VXGI::float3 maxBoundary = _maxBoundary;

            for (UINT v = 0; v < m_pScene->mMeshes[i]->mNumVertices; ++v)
            {
                VXGI::float3 vertex = VXGI::float3(&m_pScene->mMeshes[i]->mVertices[v].x);
                vertex = m_WorldMatrix.pntTransform(vertex);

                minBoundary.x = __min(minBoundary.x, vertex.x);
                minBoundary.y = __min(minBoundary.y, vertex.y);
                minBoundary.z = __min(minBoundary.z, vertex.z);

                maxBoundary.x = __max(maxBoundary.x, vertex.x);
                maxBoundary.y = __max(maxBoundary.y, vertex.y);
                maxBoundary.z = __max(maxBoundary.z, vertex.z);
            }

            m_MeshBounds[i].lower = minBoundary;
            m_MeshBounds[i].upper = maxBoundary;

            m_SceneBounds.lower.x = __min(m_SceneBounds.lower.x, minBoundary.x);
            m_SceneBounds.lower.y = __min(m_SceneBounds.lower.y, minBoundary.y);
            m_SceneBounds.lower.z = __min(m_SceneBounds.lower.z, minBoundary.z);

            m_SceneBounds.upper.x = __max(m_SceneBounds.upper.x, maxBoundary.x);
            m_SceneBounds.upper.y = __max(m_SceneBounds.upper.y, maxBoundary.y);
            m_SceneBounds.upper.z = __max(m_SceneBounds.upper.z, maxBoundary.z);
        }
    }
}

VXGI::Box3f Scene::GetSceneBounds() const
{
    assert(m_MeshBounds.empty() == false);

    return m_SceneBounds;
}

NVRHI::TextureHandle Scene::LoadTextureFromFile(const char *name)
{
    std::string str_path = GetScenePath();
    size_t pos = str_path.find_last_of("\\/");
    str_path = pos ? str_path.substr(0, pos) : "";
    str_path += '\\';
    str_path += name;

    return LoadTextureFromFileInternal(str_path.c_str());
}

NVRHI::TextureHandle Scene::LoadTextureFromFileInternal(const char *name)
{
    NVRHI::TextureHandle texture = m_LoadedTextures[name];
    if (texture)
    {
        return texture;
    }

    FREE_IMAGE_FORMAT imageFormat = FreeImage_GetFileType(name);

    FIBITMAP *pBitmap = FreeImage_Load(imageFormat, name, TARGA_DEFAULT);
    if (pBitmap)
    {
        UINT width = FreeImage_GetWidth(pBitmap);
        UINT height = FreeImage_GetHeight(pBitmap);
        UINT bpp = FreeImage_GetBPP(pBitmap);

        NVRHI::Format::Enum format;
        FIBITMAP *newBitmap = NULL;

        switch (bpp)
        {
        case 8:
            format = NVRHI::Format::R8_UNORM;
            break;

        case 24:
            newBitmap = FreeImage_ConvertTo32Bits(pBitmap);
            FreeImage_Unload(pBitmap);
            pBitmap = newBitmap;
            format = NVRHI::Format::BGRA8_UNORM;
            break;

        case 32:
            format = NVRHI::Format::BGRA8_UNORM;
            break;

        default:
            return NULL;
        }

        NVRHI::TextureDesc textureDesc;
        textureDesc.width = width;
        textureDesc.height = height;
        textureDesc.mipLevels = getMipLevelsNum(width, height);
        textureDesc.format = format;
        textureDesc.debugName = name;
        texture = m_Renderer->createTexture(textureDesc, NULL);

        if (texture)
        {
            for (UINT mipLevel = 0; mipLevel < textureDesc.mipLevels; mipLevel++)
            {
                UINT freeImagePitch = FreeImage_GetPitch(pBitmap);
                BYTE *bitmapData = FreeImage_GetBits(pBitmap);

                m_Renderer->writeTexture(texture, mipLevel, bitmapData, freeImagePitch, 0);

                if (mipLevel < textureDesc.mipLevels - 1u)
                {
                    width = __max(1, width >> 1);
                    height = __max(1, height >> 1);
                    newBitmap = FreeImage_Rescale(pBitmap, width, height, FILTER_BILINEAR);
                    FreeImage_Unload(pBitmap);
                    pBitmap = newBitmap;
                }
            }
        }

        FreeImage_Unload(pBitmap);
    }
    else
    {
        char error[MAX_PATH + 50];
        sprintf_s(error, "Couldn't load texture file `%s`\n", name);
        OutputDebugStringA(error);
    }

    m_LoadedTextures[name] = texture;
    return texture;
}

HRESULT Scene::InitResources()
{
    if (!m_pScene)
        return E_FAIL;

    if (m_pScene->mNumMeshes)
    {
        std::vector<std::pair<UINT, UINT>> meshMaterials(m_pScene->mNumMeshes);
        for (UINT sceneMesh = 0; sceneMesh < m_pScene->mNumMeshes; ++sceneMesh)
        {
            meshMaterials[sceneMesh] = std::pair<UINT, UINT>(sceneMesh, m_pScene->mMeshes[sceneMesh]->mMaterialIndex);
        }

        std::sort(meshMaterials.begin(), meshMaterials.end(), [](std::pair<UINT, UINT> a, std::pair<UINT, UINT> b)
                  { return a.second < b.second; });

        m_IndexOffsets.resize(m_pScene->mNumMeshes);
        m_VertexOffsets.resize(m_pScene->mNumMeshes);

        UINT totalIndices = 0;
        UINT totalVertices = 0;

        // Count all the indices and vertices first
        for (UINT meshID = 0; meshID < m_pScene->mNumMeshes; ++meshID)
        {
            m_IndexOffsets[meshID] = totalIndices;
            m_VertexOffsets[meshID] = totalVertices;
            UINT sceneMesh = meshMaterials[meshID].first;

            totalIndices += m_pScene->mMeshes[sceneMesh]->mNumFaces * 3;
            totalVertices += m_pScene->mMeshes[sceneMesh]->mNumVertices;
        }

        // printf("%d meshes, %d indices, %d vertices\n", m_pScene->mNumMeshes, totalIndices, totalVertices);

        std::vector<UINT> indices(totalIndices);
        std::vector<VertexBufferEntry> vertices(totalVertices);

        m_MeshToSceneMapping.resize(m_pScene->mNumMeshes);

        // Copy data into buffer images
        for (UINT meshID = 0; meshID < m_pScene->mNumMeshes; ++meshID)
        {
            m_MeshToSceneMapping[meshID] = meshMaterials[meshID].first;

            UINT sceneMesh = meshMaterials[meshID].first;
            UINT indexOffset = m_IndexOffsets[meshID];
            UINT vertexOffset = m_VertexOffsets[meshID];

            const aiMesh *pMesh = m_pScene->mMeshes[sceneMesh];
            UINT numVertices = pMesh->mNumVertices;

            // Indices
            for (UINT f = 0; f < pMesh->mNumFaces; ++f)
            {
                memcpy(&indices[indexOffset + f * 3], pMesh->mFaces[f].mIndices, sizeof(int) * 3);
            }

            for (UINT v = 0; v < numVertices; v++)
            {
                VertexBufferEntry &vertex = vertices[v + vertexOffset];

                vertex.position = pMesh->mVertices[v];

                if (pMesh->HasNormals())
                {
                    vertex.normal = pMesh->mNormals[v];
                }

                if (pMesh->HasTangentsAndBitangents())
                {
                    vertex.tangent = pMesh->mTangents[v];
                    vertex.binormal = pMesh->mBitangents[v];
                }

                if (pMesh->HasTextureCoords(0))
                {
                    vertex.texCoord = aiVector2D(pMesh->mTextureCoords[0][v].x, pMesh->mTextureCoords[0][v].y);
                }
            }
        }

        // Create buffers
        NVRHI::BufferDesc indexBufferDesc;
        indexBufferDesc.isIndexBuffer = true;
        indexBufferDesc.byteSize = totalIndices * sizeof(int);
        m_Renderer->createBuffer(indexBufferDesc, &indices[0], &m_IndexBuffer);

        NVRHI::BufferDesc vertexBufferDesc;
        vertexBufferDesc.isVertexBuffer = true;
        vertexBufferDesc.byteSize = totalVertices * sizeof(VertexBufferEntry);
        m_Renderer->createBuffer(vertexBufferDesc, &vertices[0], &m_VertexBuffer);
    }

    if (m_pScene->HasMaterials())
    {
        m_DiffuseTextures.resize(m_pScene->mNumMaterials);
        m_SpecularTextures.resize(m_pScene->mNumMaterials);
        m_NormalsTextures.resize(m_pScene->mNumMaterials);
        m_OpacityTextures.resize(m_pScene->mNumMaterials);
        m_EmissiveTextures.resize(m_pScene->mNumMaterials);
        m_DiffuseColors.resize(m_pScene->mNumMaterials);
        m_SpecularColors.resize(m_pScene->mNumMaterials);
        m_EmissiveColors.resize(m_pScene->mNumMaterials);
        m_MaterialNames.resize(m_pScene->mNumMaterials);

        for (UINT materialIndex = 0; materialIndex < m_pScene->mNumMaterials; ++materialIndex)
        {
            aiString texturePath;
            aiMaterial *material = m_pScene->mMaterials[materialIndex];

            if (material->GetTexture(aiTextureType_DIFFUSE, 0, &texturePath) == AI_SUCCESS)
            {
                m_DiffuseTextures[materialIndex] = LoadTextureFromFile(texturePath.C_Str());
            }

            if (material->GetTexture(aiTextureType_SPECULAR, 0, &texturePath) == AI_SUCCESS)
            {
                m_SpecularTextures[materialIndex] = LoadTextureFromFile(texturePath.C_Str());
            }

            if (material->GetTexture(aiTextureType_NORMALS, 0, &texturePath) == AI_SUCCESS)
            {
                m_NormalsTextures[materialIndex] = LoadTextureFromFile(texturePath.C_Str());
            }
            else if (material->GetTexture(aiTextureType_HEIGHT, 0, &texturePath) == AI_SUCCESS)
            {
                m_NormalsTextures[materialIndex] = LoadTextureFromFile(texturePath.C_Str());
            }

            if (material->GetTexture(aiTextureType_OPACITY, 0, &texturePath) == AI_SUCCESS)
            {
                m_OpacityTextures[materialIndex] = LoadTextureFromFile(texturePath.C_Str());
            }

            aiColor3D color;
            if (material->Get(AI_MATKEY_COLOR_DIFFUSE, color) == AI_SUCCESS)
            {
                m_DiffuseColors[materialIndex] = VXGI::float3(color.r, color.g, color.b);
            }

            aiString materialName;
            if (material->Get(AI_MATKEY_NAME, materialName) == AI_SUCCESS)
            {
                m_MaterialNames[materialIndex] = materialName.C_Str();
            }
        }
    }

    return S_OK;
}

void Scene::ReleaseResources()
{
    m_DiffuseTextures.clear();
    m_SpecularTextures.clear();
    m_NormalsTextures.clear();
    m_OpacityTextures.clear();
    m_EmissiveTextures.clear();

    m_LoadedTextures.clear();
}

NVRHI::DrawArguments Scene::GetMeshDrawArguments(UINT meshID) const
{
    NVRHI::DrawArguments args;

    args.vertexCount = m_pScene->mMeshes[m_MeshToSceneMapping[meshID]]->mNumFaces * 3;
    args.startIndexLocation = m_IndexOffsets[meshID];
    args.startVertexLocation = m_VertexOffsets[meshID];

    return args;
}

NVRHI::TextureHandle Scene::GetTextureSRV(aiTextureType type, UINT meshID) const
{
    int materialIndex = GetMaterialIndex(meshID);

    if (materialIndex >= 0)
    {
        switch (type)
        {
        case aiTextureType_DIFFUSE:
            return materialIndex < (int)m_DiffuseTextures.size() ? m_DiffuseTextures[materialIndex] : NULL;
        case aiTextureType_SPECULAR:
            return materialIndex < (int)m_SpecularTextures.size() ? m_SpecularTextures[materialIndex] : NULL;
        case aiTextureType_NORMALS:
            return materialIndex < (int)m_NormalsTextures.size() ? m_NormalsTextures[materialIndex] : NULL;
        case aiTextureType_OPACITY:
            return materialIndex < (int)m_OpacityTextures.size() ? m_OpacityTextures[materialIndex] : NULL;
        case aiTextureType_EMISSIVE:
            return materialIndex < (int)m_EmissiveTextures.size() ? m_EmissiveTextures[materialIndex] : NULL;
        }
    }

    return NULL;
}

VXGI::float3 Scene::GetColor(aiTextureType type, UINT meshID) const
{
    int materialIndex = GetMaterialIndex(meshID);

    if (materialIndex >= 0)
    {
        switch (type)
        {
        case aiTextureType_DIFFUSE:
            return materialIndex < (int)m_DiffuseColors.size() ? m_DiffuseColors[materialIndex] : VXGI::float3();
        case aiTextureType_SPECULAR:
            return materialIndex < (int)m_SpecularColors.size() ? m_SpecularColors[materialIndex] : VXGI::float3();
        case aiTextureType_EMISSIVE:
            return materialIndex < (int)m_EmissiveColors.size() ? m_EmissiveColors[materialIndex] : VXGI::float3();
        }
    }

    return VXGI::float3();
}

int Scene::GetMaterialIndex(UINT meshID) const
{
    if (m_pScene->HasMaterials() && meshID < m_MeshToSceneMapping.size())
    {
        return (int)m_pScene->mMeshes[m_MeshToSceneMapping[meshID]]->mMaterialIndex;
    }

    return -1;
}

VXGI::Box3f Scene::GetMeshBounds(UINT meshID) const
{
    assert(meshID < m_MeshBounds.size());

    if (meshID < m_MeshBounds.size())
        return m_MeshBounds[m_MeshToSceneMapping[meshID]];
    else
        return VXGI::Box3f();
}

const std::string &Scene::GetMaterialName(UINT materialIndex) const
{
    return m_MaterialNames[materialIndex];
}

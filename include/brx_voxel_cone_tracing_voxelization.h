//
// Copyright (C) YuqiaoZhang(HanetakaChou)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#ifndef _BRX_VOXEL_CONE_TRACING_VOXELIZATION_H_
#define _BRX_VOXEL_CONE_TRACING_VOXELIZATION_H_ 1

#include "brx_voxel_cone_tracing.h"

static inline DirectX::XMFLOAT3 brx_voxel_cone_tracing_voxelization_compute_clipmap_center(DirectX::XMFLOAT3 const &in_clipmap_anchor)
{
    float const coarsest_stack_level_voxel_size = static_cast<float>(BRX_VCT_CLIPMAP_FINEST_VOXEL_SIZE) * static_cast<float>(1U << (static_cast<uint32_t>(BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT) - 1U));

    DirectX::XMFLOAT3 clipmap_center;
    DirectX::XMStoreFloat3(&clipmap_center, DirectX::XMVectorScale(DirectX::XMVectorRound(DirectX::XMVectorScale(DirectX::XMLoadFloat3(&in_clipmap_anchor), 1.0F / coarsest_stack_level_voxel_size)), coarsest_stack_level_voxel_size));
    return clipmap_center;
}

static inline DirectX::XMFLOAT4X4 brx_voxel_cone_tracing_voxelization_compute_viewport_depth_direction_view_matrix(DirectX::XMFLOAT3 const &in_clipmap_center, uint32_t viewport_depth_direction_index)
{
    assert(viewport_depth_direction_index < BRX_VCT_VIEWPORT_DEPTH_DIRECTION_COUNT);

    constexpr DirectX::XMFLOAT3 const viewport_depth_direction_eye_directions[BRX_VCT_VIEWPORT_DEPTH_DIRECTION_COUNT] = {
        DirectX::XMFLOAT3(0.0F, 0.0F, 1.0F), // AXIS_INDEX_Z xyz -> xyz
        DirectX::XMFLOAT3(0.0F, 1.0F, 0.0F), // AXIS_INDEX_Y xyz -> zxy
        DirectX::XMFLOAT3(1.0F, 0.0F, 0.0F)  // AXIS_INDEX_X xyz -> yzx
    };

    constexpr DirectX::XMFLOAT3 const viewport_depth_direction_up_directions[BRX_VCT_VIEWPORT_DEPTH_DIRECTION_COUNT] = {
        DirectX::XMFLOAT3(0.0F, 1.0F, 0.0F), // AXIS_INDEX_Z xyz -> xyz
        DirectX::XMFLOAT3(1.0F, 0.0F, 0.0F), // AXIS_INDEX_Y xyz -> zxy
        DirectX::XMFLOAT3(0.0F, 0.0F, 1.0F)  // AXIS_INDEX_X xyz -> yzx
    };

    DirectX::XMFLOAT4X4 viewport_depth_direction_view_matrix;
    DirectX::XMStoreFloat4x4(&viewport_depth_direction_view_matrix, DirectX::XMMatrixLookToLH(DirectX::XMLoadFloat3(&in_clipmap_center), DirectX::XMLoadFloat3(&viewport_depth_direction_eye_directions[viewport_depth_direction_index]), DirectX::XMLoadFloat3(&viewport_depth_direction_up_directions[viewport_depth_direction_index])));
    return viewport_depth_direction_view_matrix;
}

static inline DirectX::XMFLOAT4X4 brx_voxel_cone_tracing_voxelization_compute_clipmap_stack_level_projection_matrix(uint32_t clipmap_stack_level_index)
{
    // float const clipmap_level_voxel_size = static_cast<float>(BRX_VCT_CLIPMAP_FINEST_VOXEL_SIZE) * static_cast<float>(1U << std::min(static_cast<int32_t>(clipmap_level_index), static_cast<int32_t>(BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT) - 1));
    // float const clipmap_level_map_size = static_cast<float>(BRX_VCT_CLIPMAP_MAP_SIZE) / static_cast<float>(1U << std::max(0, static_cast<int32_t>(clipmap_level_index) - (static_cast<int32_t>(BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT) - 1)));
    // float const clipmap_level_boundary = clipmap_level_voxel_size * clipmap_level_map_size;

    assert(clipmap_stack_level_index < BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT);
    float const clipmap_stack_level_voxel_size = static_cast<float>(BRX_VCT_CLIPMAP_FINEST_VOXEL_SIZE) * static_cast<float>(1U << clipmap_stack_level_index);
    float const clipmap_stack_level_map_size = static_cast<float>(BRX_VCT_CLIPMAP_MAP_SIZE);
    float const clipmap_stack_level_boundary = clipmap_stack_level_voxel_size * clipmap_stack_level_map_size;

    DirectX::XMFLOAT4X4 clipmap_level_projection_matrix;
    DirectX::XMStoreFloat4x4(&clipmap_level_projection_matrix, DirectX::XMMatrixOrthographicLH(clipmap_stack_level_boundary, clipmap_stack_level_boundary, -clipmap_stack_level_boundary * 0.5F, clipmap_stack_level_boundary * 0.5F));
    return clipmap_level_projection_matrix;
}

static inline DirectX::XMUINT3 brx_voxel_cone_tracing_voxelization_compute_opacity_texture_extent()
{
    // return DirectX::XMUINT3(BRX_VCT_CLIPMAP_MAP_SIZE, BRX_VCT_CLIPMAP_MAP_SIZE, BRX_VCT_CLIPMAP_MAP_LEVEL_STRIDE * BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT);
}

static inline DirectX::XMUINT3 brx_voxel_cone_tracing_voxelization_compute_illumination_texture_extent()
{
    // return DirectX::XMUINT3(BRX_VCT_CLIPMAP_MAP_DIRECTION_STRIDE * INTERNAL_BRX_VCT_CLIPMAP_VOXEL_DIRECTION_COUNT, BRX_VCT_CLIPMAP_MAP_SIZE, BRX_VCT_CLIPMAP_MAP_LEVEL_STRIDE * BRX_VCT_CLIPMAP_STACK_LEVEL_COUNT);
}

#endif

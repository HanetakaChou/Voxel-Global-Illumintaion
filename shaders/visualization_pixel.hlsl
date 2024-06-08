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

#include "vct_configuration.sli"
#include "vct_constant.sli"
#include "visualization_shader_resource_table.sli"

void main(in float4 in_position : SV_Position, in float2 in_uv : TEXCOORD0, out float4 out_color : SV_TARGET0)
{
    // [unroll]
    for (int clipmap_level_index = 0; clipmap_level_index < int(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
    {
        // DXR: [GenerateCameraRay](https://github.com/microsoft/DirectX-Graphics-Samples/blob/v10.0.17763.0/Samples/Desktop/D3D12Raytracing/src/D3D12RaytracingMiniEngineSample/ModelViewerRayTracing.h#L51)
        float3 ray_origin_texel_space;
        float3 ray_direction_texel_space;
        {
            // 0.5 is compatible with Reversed-Z
            float4 position_normalized_device_space = float4(in_uv.x * 2.0 - 1.0, 1.0 - in_uv.y * 2.0, 0.5, 1.0);

            float4 temp_view_space = mul(position_normalized_device_space, g_main_camera_inverse_projection_matrix);

            float3 position_view_space = temp_view_space.xyz / temp_view_space.w;

            float3 position_world_space = mul(float4(position_view_space, 1.0), g_main_camera_inverse_view_matrix).xyz;

            float3 ray_origin_world_space = g_main_camera_position;

            float3 ray_direction_world_space = normalize(position_world_space - g_main_camera_position);

            // texel space: 0 - 127
            float clipmap_level_voxel_size = float(VCT_FINEST_VOXEL_SIZE) * float(1 << clipmap_level_index);

            ray_origin_texel_space = (ray_origin_world_space - g_clipmap_center) * (1.0 / clipmap_level_voxel_size) + float(VCT_CLIPMAP_SIZE) * 0.5;

            // ray_direction_texel_space = normalize(ray_direction_world_space * (1.0 / clipmap_level_voxel_size));
            ray_direction_texel_space = ray_direction_world_space;
        }

        // "22.7 Ray/Box Intersection" of [Real-Time Rendering Fourth Edition](https://www.realtimerendering.com/)
        // [BoundingBox::Intersects](https://github.com/microsoft/DirectXMath/blob/jul2018b/Inc/DirectXCollision.inl#L1728)
        float t_min;
        float t_max;
        {
            const float margin = pow(2.0, -8.0);
            float3 box_min_texel_space = float3(margin, margin, margin);
            float3 box_max_texel_space = float3(float(VCT_CLIPMAP_SIZE) - margin, float(VCT_CLIPMAP_SIZE) - margin, float(VCT_CLIPMAP_SIZE) - margin);

            // TODO: Ray/Slab Parallel?
            float3 inverse_ray_direction_texel_space = float3(1.0, 1.0, 1.0) / ray_direction_texel_space;

            float3 t1 = (box_min_texel_space - ray_origin_texel_space) * inverse_ray_direction_texel_space;
            float3 t2 = (box_max_texel_space - ray_origin_texel_space) * inverse_ray_direction_texel_space;

            float3 temp_t_min = min(t1, t2);
            float3 temp_t_max = max(t1, t2);

            t_min = max(max(temp_t_min.x, temp_t_min.y), temp_t_min.z);
            t_max = min(min(temp_t_max.x, temp_t_max.y), temp_t_max.z);
        }

        // Avoid opposite direction
        t_min = max(0.5, t_min);

        [branch]
        if (t_min >= t_max && t_max <= 0.0)
        {
            continue;
        }

        // \[McGuire 2014\] [Morgan McGuire, Michael Mara. "Efficient GPU Screen-Space Ray Tracing." JCGT 2014.](https://jcgt.org/published/0003/04/04/)
        // Try to minimize the divergent execution

        // step along the nearest axis direction
        float t_begin;
        float t_delta;
        {
            float3 temp_begin_position_texel_space = ray_origin_texel_space + ray_direction_texel_space * t_min;

            float3 abs_ray_direction_texel_space = abs(ray_direction_texel_space);
            [branch] if (abs_ray_direction_texel_space.x > abs_ray_direction_texel_space.y && abs_ray_direction_texel_space.x > abs_ray_direction_texel_space.z)
            {
                t_begin = (sign(temp_begin_position_texel_space.x) * (round(abs(temp_begin_position_texel_space.x) + 0.5) - 0.5) - ray_origin_texel_space.x) / ray_direction_texel_space.x;
                t_delta = 1.0 / abs_ray_direction_texel_space.x;
            }
            else if (abs_ray_direction_texel_space.y > abs_ray_direction_texel_space.z)
            {
                t_begin = (sign(temp_begin_position_texel_space.y) * (round(abs(temp_begin_position_texel_space.y) + 0.5) - 0.5) - ray_origin_texel_space.y) / ray_direction_texel_space.y;
                t_delta = 1.0 / abs_ray_direction_texel_space.y;
            }
            else
            {
                t_begin = (sign(temp_begin_position_texel_space.z) * (round(abs(temp_begin_position_texel_space.z) + 0.5) - 0.5) - ray_origin_texel_space.z) / ray_direction_texel_space.z;
                t_delta = 1.0 / abs_ray_direction_texel_space.z;
            }
        }

        float t_current = t_begin;
        //[loop]
        for (int unused_index = 0; unused_index < 128; ++unused_index, t_current += t_delta)
        {
            [branch]
            if (t_current <= t_min)
            {
                continue;
            }

            [branch]
            if (t_current >= t_max)
            {
                break;
            }

            float3 current_position_texel_space = ray_origin_texel_space + ray_direction_texel_space * t_current;

            int3 voxel_clipmap_texel_space = int3(current_position_texel_space);

            [branch]
            if (any(voxel_clipmap_texel_space < int3(0, 0, 0)) || any(voxel_clipmap_texel_space >= int3(VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE)))
            {
                continue;
            }

            float voxel_opacity;
#if 5 == VCT_CLIPMAP_LEVEL_COUNT
            [branch]
            if (0 == clipmap_level_index)
            {
                voxel_opacity = asfloat(g_clipmap_opacity[0].Load(int4(voxel_clipmap_texel_space, 0)));
            }
            else if (1 == clipmap_level_index)
            {
                voxel_opacity = asfloat(g_clipmap_opacity[1].Load(int4(voxel_clipmap_texel_space, 0)));
            }
            else if (2 == clipmap_level_index)
            {
                voxel_opacity = asfloat(g_clipmap_opacity[2].Load(int4(voxel_clipmap_texel_space, 0)));
            }
            else if (3 == clipmap_level_index)
            {
                voxel_opacity = asfloat(g_clipmap_opacity[3].Load(int4(voxel_clipmap_texel_space, 0)));
            }
            else if (4 == clipmap_level_index)
            {
                voxel_opacity = asfloat(g_clipmap_opacity[4].Load(int4(voxel_clipmap_texel_space, 0)));
            }
            else
            {
                // Error
                // 5 == VCT_CLIPMAP_LEVEL_COUNT
                voxel_opacity = 0.0;
                out_color = float4(0.0, 0.0, 0.0, 0.0);
                discard;
                return;
            }
#else
#error TODO
#endif

            [branch]
            if (voxel_opacity > 0.0)
            {
                float3 opacity_color = lerp(float3(0.0, 0.0, 1.0), float3(1.0, 0.0, 0.0), voxel_opacity);

                out_color = float4(opacity_color, 1.0);
                return;
            }
        }
    }

    out_color = float4(0.0, 0.0, 0.0, 0.0);
    discard;
    return;
}
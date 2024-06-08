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

#include "vct_light_injection_shader_resource_table.sli"

void main(
#include "mesh_vertex.sli"
	,
	in uint in_vertex_id : SV_VertexID, in uint in_instance_id : SV_InstanceID, out float4 out_position : SV_Position, out float out_cull_distance[2] : SV_CullDistance, out nointerpolation int out_viewport_depth_direction_index : TEXCOORD0, out nointerpolation int out_clipmap_level_index : TEXCOORD1)
{
	// Decode Input

	// For debug
	// 0 - 2
	int viewport_depth_direction_index = in_instance_id / int(VCT_CLIPMAP_LEVEL_COUNT);
	// assert(clipmap_level_index < VCT_VIEWPORT_DEPTH_DIRECTION_COUNT);

	// 0 - 4
	int clipmap_level_index = in_instance_id % int(VCT_CLIPMAP_LEVEL_COUNT);
	// assert(clipmap_level_index < VCT_CLIPMAP_LEVEL_COUNT);

	// Model Space
	float3 positions_model_space = in_position_xyzw.xyz;

	// World Space
	float3 positions_world_space = mul(float4(positions_model_space, 1.0), g_model_matrix).xyz;

	// View Space
	float3 position_view_space = mul(float4(positions_world_space, 1.0), g_viewport_depth_direction_view_matrices[viewport_depth_direction_index]).xyz;

	// Clip Space
	float4 position_clip_space = mul(float4(position_view_space, 1.0), g_clipmap_level_projection_matrices[clipmap_level_index]);

	// "DepthClipEnable" is similiar to "SV_ClipDistance"
	// The whole primitive will be clipped as long as one of the three vertices are clipped.
	float cull_distance[2];
	// Depth Direction
	// assert(1.0 == position_clip_space.w)
	cull_distance[0] = position_clip_space.z - (-1.0 / (float(VCT_CLIPMAP_SIZE) * 0.5));
	cull_distance[1] = (1.0 + 1.0 / (float(VCT_CLIPMAP_SIZE) * 0.5)) - position_clip_space.z;

	// Encode Output
	out_position = position_clip_space;
	out_cull_distance[0] = cull_distance[0];
	out_cull_distance[1] = cull_distance[1];
	out_viewport_depth_direction_index = viewport_depth_direction_index;
	out_clipmap_level_index = clipmap_level_index;
}
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
#include "mesh_vertex.sli"

void main(
	in uint in_vertex_id : SV_VertexID, 
	in uint in_instance_id : SV_InstanceID, 
	out float4 out_position : SV_Position, 
	out float out_cull_distance[2] : SV_CullDistance, 
	out nointerpolation int out_viewport_depth_direction_index : TEXCOORD0, 
	out nointerpolation int out_clipmap_level_index : TEXCOORD1)
{
	// Decode Input
	float3 triangle_vertex_positions_model_space[3];
    {
        uint triangle_index = in_vertex_id / 3u;
        
        uint3 triangle_vertex_indices = g_index_buffer.Load3(g_index_uint32_buffer_stride * 3u * triangle_index);

        uint3 triangle_vertex_buffer_offset = g_vertex_position_buffer_stride * triangle_vertex_indices;
        triangle_vertex_positions_model_space[0] = asfloat(g_vertex_position_buffer.Load3(triangle_vertex_buffer_offset.x));
        triangle_vertex_positions_model_space[1] = asfloat(g_vertex_position_buffer.Load3(triangle_vertex_buffer_offset.y));
        triangle_vertex_positions_model_space[2] = asfloat(g_vertex_position_buffer.Load3(triangle_vertex_buffer_offset.z));
    }

	float3 vertex_position_model_space;
	{
        uint index_index = in_vertex_id;

        uint vertex_index = g_index_buffer.Load(g_index_uint32_buffer_stride * index_index);

        vertex_position_model_space = asfloat(g_vertex_position_buffer.Load3(g_vertex_position_buffer_stride * vertex_index));
    }

	// Depth Direction

	float3 triangle_vertex_positions_world_space[3];
	{
		triangle_vertex_positions_world_space[0] = mul(float4(triangle_vertex_positions_model_space[0], 1.0), g_model_matrix).xyz;
		triangle_vertex_positions_world_space[1] = mul(float4(triangle_vertex_positions_model_space[1], 1.0), g_model_matrix).xyz;
		triangle_vertex_positions_world_space[2] = mul(float4(triangle_vertex_positions_model_space[2], 1.0), g_model_matrix).xyz;
	}

	// normalize NOT required here
	float3 triangle_abs_normal_world_space = abs(cross(triangle_vertex_positions_world_space[1] - triangle_vertex_positions_world_space[0], triangle_vertex_positions_world_space[2] - triangle_vertex_positions_world_space[0]));

	// 0 - 2
	int viewport_depth_direction_index;
	{
		// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
		// If (the absolute value of) either of these gradients "ddx(depth) or ddy(depth)" exceeds 1.0, then the voxelized plane will have "cracks" in a direction perpendicular to the depth direction.
	
		[branch]
		if((triangle_abs_normal_world_space.z >= triangle_abs_normal_world_space.x) && (triangle_abs_normal_world_space.z >= triangle_abs_normal_world_space.y))
		{
			viewport_depth_direction_index = VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_Z;
		}
		else if(triangle_abs_normal_world_space.y >= triangle_abs_normal_world_space.x)
		{
			viewport_depth_direction_index = VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_Y;
		}
		else
		{
			viewport_depth_direction_index = VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_X;
		}
	}
	// assert(clipmap_level_index < VCT_VIEWPORT_DEPTH_DIRECTION_COUNT);

	// Clipmap Level
	
	// 0 - 4
	int clipmap_level_index = in_instance_id % int(VCT_CLIPMAP_LEVEL_COUNT);
	// assert(clipmap_level_index < VCT_CLIPMAP_LEVEL_COUNT);

	// Vertex MVP Transform

	float3 vertex_position_world_space = mul(float4(vertex_position_model_space, 1.0), g_model_matrix).xyz;

	float3 vertex_position_view_space = mul(float4(vertex_position_world_space, 1.0), g_viewport_depth_direction_view_matrices[viewport_depth_direction_index]).xyz;

	float4 vertex_position_clip_space = mul(float4(vertex_position_view_space, 1.0), g_clipmap_level_projection_matrices[clipmap_level_index]);

	// "DepthClipEnable" is similiar to "SV_ClipDistance"
	// The whole primitive will be clipped as long as one of the three vertices are clipped.
	float cull_distance[2];
	// Depth Direction
	// assert(1.0 == vertex_position_clip_space.w)
	cull_distance[0] = vertex_position_clip_space.z - (-1.0 / (float(VCT_CLIPMAP_SIZE) * 0.5));
	cull_distance[1] = (1.0 + 1.0 / (float(VCT_CLIPMAP_SIZE) * 0.5)) - vertex_position_clip_space.z;

	// Encode Output
	out_position = vertex_position_clip_space;
	out_cull_distance[0] = cull_distance[0];
	out_cull_distance[1] = cull_distance[1];
	out_viewport_depth_direction_index = viewport_depth_direction_index;
	out_clipmap_level_index = clipmap_level_index;
}
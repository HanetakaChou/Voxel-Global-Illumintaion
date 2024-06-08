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
#include "vct_light_injection_shader_resource_table.sli"
#include "toroidal_address.hlsli"
#include "packed_opacity.hlsli"

void main(in uint in_sample_mask : SV_Coverage, in float4 in_position : SV_Position, in float in_cull_distance[2] : SV_CullDistance, in nointerpolation int in_viewport_depth_direction_index : TEXCOORD0, in nointerpolation int in_clipmap_level_index : TEXCOORD1)
{
	// texel space: 0 - 127
	float pixel_clipmap_texel_space_viewport_x_direction_component = in_position.x;
	// TODO: why flip y ???
	float pixel_clipmap_texel_space_viewport_y_direction_component = float(VCT_CLIPMAP_SIZE) - in_position.y;
	float pixel_clipmap_texel_space_viewport_depth_direction_component = in_position.z * float(VCT_CLIPMAP_SIZE);

	// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
	// If (the absolute value of) either of these gradients "ddx(depth) or ddy(depth)" exceeds 1.0, then the voxelized plane will have "cracks" in a direction perpendicular to the depth direction.
	float2 delta_pixel_clipmap_texel_space_viewport_depth_direction = float2(ddx(pixel_clipmap_texel_space_viewport_depth_direction_component), ddy(pixel_clipmap_texel_space_viewport_depth_direction_component));
	[branch]
	if (any(abs(delta_pixel_clipmap_texel_space_viewport_depth_direction) > float2(1.0, 1.0)))
	{
		// out_debug_color = float4(0.5, 0.0, 0.0, 1.0);
		discard;
		return;
	}

#if 8 == VCT_VOXELIZATION_SAMPLE_COUNT
	// "Standard Sample Patterns" https://learn.microsoft.com/en-us/windows/win32/api/d3d11/ne-d3d11-d3d11_standard_multisample_quality_levels
	const float2 voxelization_sample_positions[VCT_VOXELIZATION_SAMPLE_COUNT] = {
		float2(1.0 / 16.0, -3.0 / 16.0),
		float2(-1.0 / 16.0, 3.0 / 16.0),
		float2(5.0 / 16.0, 1.0 / 16.0),
		float2(-3.0 / 16.0, -5.0 / 16.0),
		float2(-5.0 / 16.0, 5.0 / 16.0),
		float2(-7.0 / 16.0, -1.0 / 16.0),
		float2(3.0 / 16.0, 7.0 / 16.0),
		float2(7.0 / 16.0, -7.0 / 16.0) };

	// TODO: Vulkan
	// "Standard Sample Locations" https://registry.khronos.org/vulkan/specs/1.0/html/chap25.html#primsrast-multisampling
#else
#error TODO
#endif

	// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
	// \[Hasselgren 2005\] [Jon Hasselgren, Tomas Akenine-Moller, Lennart Ohlsson. "Chapter 42. Conservative Rasterization." GPU Gems 2.](https://developer.nvidia.com/gpugems/gpugems2/part-v-image-oriented-computing/chapter-42-conservative-rasterization)
	// MSAA                                        | SV_Coverage      | gl_SampleMaskIn
	// (Overestimated) Conservative Rasterization  | SV_Coverage      | gl_SampleMaskIn
	// (Underestimated) Conservative Rasterization | SV_InnerCoverage | gl_FragFullyCoveredNV
	//
	// \[Panteleev 2014\] [Alexey Panteleev. "Practical Real-Time Voxel-Based Global Illumination for Current GPUs." GTC 2014.](https://on-demand.gputechconf.com/gtc/2014/presentations/S4552-rt-voxel-based-global-illumination-gpus.pdf)
	// "Voxelization For Opacity"
	//
	// one pixel shader may correspond to multplie voxels (three at most)
	// both x and y directions of the viewport must be at the center of the voxel
	// the depth direction may be distributed in different voxels
	const int voxel_count = 3;
	float opacity_sample_scale[voxel_count];
	{
		int voxelization_sample_mask = in_sample_mask;

		float fractional_pixel_clipmap_texel_space_viewport_depth_direction_component = frac(pixel_clipmap_texel_space_viewport_depth_direction_component);

		opacity_sample_scale[0] = 0.0;
		opacity_sample_scale[1] = 0.0;
		opacity_sample_scale[2] = 0.0;

		[unroll]
		for (int voxelization_sample_index = 0; voxelization_sample_index < int(VCT_VOXELIZATION_SAMPLE_COUNT); ++voxelization_sample_index)
		{
			[branch]
			if (0 != (voxelization_sample_mask & (1 << voxelization_sample_index)))
			{
				float fractional_voxelization_sample_clipmap_texel_space_viewport_depth_direction_component = fractional_pixel_clipmap_texel_space_viewport_depth_direction_component + dot(delta_pixel_clipmap_texel_space_viewport_depth_direction, voxelization_sample_positions[voxelization_sample_index]);

				opacity_sample_scale[0] += (1.0 / float(VCT_VOXELIZATION_SAMPLE_COUNT)) * saturate(1.0 - abs(fractional_voxelization_sample_clipmap_texel_space_viewport_depth_direction_component - (-0.5)));
				opacity_sample_scale[1] += (1.0 / float(VCT_VOXELIZATION_SAMPLE_COUNT)) * saturate(1.0 - abs(fractional_voxelization_sample_clipmap_texel_space_viewport_depth_direction_component - 0.5));
				opacity_sample_scale[2] += (1.0 / float(VCT_VOXELIZATION_SAMPLE_COUNT)) * saturate(1.0 - abs(fractional_voxelization_sample_clipmap_texel_space_viewport_depth_direction_component - 1.5));
			}
		}
	}

	float3 pixel_clipmap_texel_space;
	int3 clipmap_texel_space_viewport_depth_direction;
	[branch] 
	if (int(VIEWPORT_DEPTH_DIRECTION_AXIS_Z) == in_viewport_depth_direction_index)
	{
		pixel_clipmap_texel_space = float3(pixel_clipmap_texel_space_viewport_x_direction_component, pixel_clipmap_texel_space_viewport_y_direction_component, pixel_clipmap_texel_space_viewport_depth_direction_component);
		clipmap_texel_space_viewport_depth_direction = int3(0, 0, 1);
	}
	else if (int(VIEWPORT_DEPTH_DIRECTION_AXIS_Y) == in_viewport_depth_direction_index)
	{
		pixel_clipmap_texel_space = float3(pixel_clipmap_texel_space_viewport_y_direction_component, pixel_clipmap_texel_space_viewport_depth_direction_component, pixel_clipmap_texel_space_viewport_x_direction_component);
		clipmap_texel_space_viewport_depth_direction = int3(0, 1, 0);
	}
	else if (int(VIEWPORT_DEPTH_DIRECTION_AXIS_X) == in_viewport_depth_direction_index)
	{
		pixel_clipmap_texel_space = float3(pixel_clipmap_texel_space_viewport_depth_direction_component, pixel_clipmap_texel_space_viewport_x_direction_component, pixel_clipmap_texel_space_viewport_y_direction_component);
		clipmap_texel_space_viewport_depth_direction = int3(1, 0, 0);
	}
	else
	{
		// Error
		pixel_clipmap_texel_space = float3(-1.0, -1.0, -1.0);
		clipmap_texel_space_viewport_depth_direction = int3(-1, -1, -1);
		// out_debug_color = float4(0.25, 0.0, 0.0, 1.0);
		discard;
		return;
	}

	float opacity_area_scale;
	{
		float3 normal = normalize(cross(ddx(pixel_clipmap_texel_space), ddy(pixel_clipmap_texel_space)));

		opacity_area_scale = 1.0 / max(max(abs(normal.x), abs(normal.y)), abs(normal.z));
	}

	// TODO: Allocation Map ???

	// one pixel shader may correspond to multplie voxels (three at most)
	[unroll]
	for (int voxel_index = 0; voxel_index < voxel_count; ++voxel_index)
	{
		float opacity = saturate(opacity_sample_scale[voxel_index] * opacity_area_scale);

		[branch]
		if (0.0 == opacity)
		{
			continue;
		}

		int3 voxel_clipmap_texel_space = int3(pixel_clipmap_texel_space) + clipmap_texel_space_viewport_depth_direction * (voxel_index - 1);

		[branch]
		if (any(voxel_clipmap_texel_space < int3(0, 0, 0)) || any(voxel_clipmap_texel_space >= int3(VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE)))
		{
			continue;
		}
	
		int3 voxel_clipmap_toroidal_address = calculate_clipmap_toroidal_address(voxel_clipmap_texel_space, in_clipmap_level_index);

		uint packed_opacity = pack_opacity(opacity);
#if 5 == VCT_CLIPMAP_LEVEL_COUNT
		[branch]
		if (0 == in_clipmap_level_index)
		{
			InterlockedAdd(g_clipmap_opacity[0][voxel_clipmap_toroidal_address], packed_opacity);
		}
		else if (1 == in_clipmap_level_index)
		{
			InterlockedAdd(g_clipmap_opacity[1][voxel_clipmap_toroidal_address], packed_opacity);
		}
		else if (2 == in_clipmap_level_index)
		{
			InterlockedAdd(g_clipmap_opacity[2][voxel_clipmap_toroidal_address], packed_opacity);
		}
		else if (3 == in_clipmap_level_index)
		{
			InterlockedAdd(g_clipmap_opacity[3][voxel_clipmap_toroidal_address], packed_opacity);
		}
		else if (4 == in_clipmap_level_index)
		{
			InterlockedAdd(g_clipmap_opacity[4][voxel_clipmap_toroidal_address], packed_opacity);
		}
		else
		{
			// Error
			// 5 == VCT_CLIPMAP_LEVEL_COUNT
			// out_debug_color = float4(0.25, 0.0, 0.0, 1.0);
			discard;
			return;
		}
#else
#error TODO
#endif
	}

	// out_debug_color = float4(1.0, 0.0, 0.0, 1.0);
	discard;
	return;
}

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

// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
// the same pixel may intersecting multiple voxels in the viewport depth direction
#define MAX_VOXEL_COUNT 3

void main(
	in uint in_sample_mask : SV_Coverage,
	in float4 in_position : SV_Position,
	in float in_cull_distance[2] : SV_CullDistance,
	in nointerpolation int in_viewport_depth_direction_index : TEXCOORD0,
	in nointerpolation int in_clipmap_level_index : TEXCOORD1)
{
	// texel space: 0 - 127
	float pixel_clipmap_texel_space_viewport_x_direction_component = in_position.x;
	// TODO: why flip y ???
	float pixel_clipmap_texel_space_viewport_y_direction_component = float(VCT_CLIPMAP_SIZE) - in_position.y;
	float pixel_clipmap_texel_space_viewport_depth_direction_component = in_position.z * float(VCT_CLIPMAP_SIZE);

	float voxel_clipmap_texel_space_viewport_depth_direction_component_relatives[MAX_VOXEL_COUNT] = {-0.5, 0.5, 1.5};
	int voxel_clipmap_texel_space_viewport_depth_direction_component_offsets[MAX_VOXEL_COUNT] = {-1, 0, 1};

	float voxel_opacity_sample_scales[MAX_VOXEL_COUNT];
	{
		[unroll]
		for (int voxel_index = 0; voxel_index < MAX_VOXEL_COUNT; ++voxel_index)
		{
			voxel_opacity_sample_scales[voxel_index] = 0.0;
		}

		// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
		// If (the absolute value of) either of these gradients "ddx(depth) or ddy(depth)" exceeds 1.0, then the voxelized plane will have "cracks" in a direction perpendicular to the depth direction.
		float2 delta_pixel_clipmap_texel_space_viewport_depth_direction = float2(ddx(pixel_clipmap_texel_space_viewport_depth_direction_component), ddy(pixel_clipmap_texel_space_viewport_depth_direction_component));
#if 0
		[branch]
		if (any(abs(delta_pixel_clipmap_texel_space_viewport_depth_direction) > float2(1.0, 1.0)))
		{
			// out_debug_color = float4(0.5, 0.0, 0.0, 1.0);
			discard;
			return;
		}
#endif

		// \[Hasselgren 2005\] [Jon Hasselgren, Tomas Akenine-Moller, Lennart Ohlsson. "Chapter 42. Conservative Rasterization." GPU Gems 2.](https://developer.nvidia.com/gpugems/gpugems2/part-v-image-oriented-computing/chapter-42-conservative-rasterization)
		// MSAA                                        | SV_Coverage      | gl_SampleMaskIn
		// (Overestimated) Conservative Rasterization  | SV_Coverage      | gl_SampleMaskIn
		// (Underestimated) Conservative Rasterization | SV_InnerCoverage | gl_FragFullyCoveredNV

		// \[Panteleev 2014\] [Alexey Panteleev. "Practical Real-Time Voxel-Based Global Illumination for Current GPUs." GTC 2014.](https://on-demand.gputechconf.com/gtc/2014/presentations/S4552-rt-voxel-based-global-illumination-gpus.pdf)
		// "Voxelization For Opacity"
		{
#if 8 == VCT_VOXELIZATION_SAMPLE_COUNT
			// "Standard Sample Patterns" https://learn.microsoft.com/en-us/windows/win32/api/d3d11/ne-d3d11-d3d11_standard_multisample_quality_levels
			const float2 sample_positions[VCT_VOXELIZATION_SAMPLE_COUNT] = {
				float2(1.0 / 16.0, -3.0 / 16.0),
				float2(-1.0 / 16.0, 3.0 / 16.0),
				float2(5.0 / 16.0, 1.0 / 16.0),
				float2(-3.0 / 16.0, -5.0 / 16.0),
				float2(-5.0 / 16.0, 5.0 / 16.0),
				float2(-7.0 / 16.0, -1.0 / 16.0),
				float2(3.0 / 16.0, 7.0 / 16.0),
				float2(7.0 / 16.0, -7.0 / 16.0)};

			// TODO: Vulkan
			// "Standard Sample Locations" https://registry.khronos.org/vulkan/specs/1.0/html/chap25.html#primsrast-multisampling
#else
#error TODO
#endif
			int sample_mask = in_sample_mask;

			float pixel_clipmap_texel_space_viewport_depth_direction_component_fraction = frac(pixel_clipmap_texel_space_viewport_depth_direction_component);

			[unroll]
			for (int sample_index = 0; sample_index < int(VCT_VOXELIZATION_SAMPLE_COUNT); ++sample_index)
			{
				[branch]
				if (0 != (sample_mask & (1 << sample_index)))
				{
					float sample_clipmap_texel_space_viewport_depth_direction_component_relative = pixel_clipmap_texel_space_viewport_depth_direction_component_fraction + dot(delta_pixel_clipmap_texel_space_viewport_depth_direction, sample_positions[sample_index]);

					[unroll]
					for (int voxel_index = 0; voxel_index < MAX_VOXEL_COUNT; ++voxel_index)
					{
						voxel_opacity_sample_scales[voxel_index] += (1.0 / float(VCT_VOXELIZATION_SAMPLE_COUNT)) * saturate(1.0 - abs(sample_clipmap_texel_space_viewport_depth_direction_component_relative - voxel_clipmap_texel_space_viewport_depth_direction_component_relatives[voxel_index]));
					}
				}
			}
		}
	}

	float3 pixel_clipmap_texel_space;
	int3 clipmap_texel_space_viewport_depth_direction;
	[branch]
	if (int(VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_Z) == in_viewport_depth_direction_index)
	{
		pixel_clipmap_texel_space = float3(pixel_clipmap_texel_space_viewport_x_direction_component, pixel_clipmap_texel_space_viewport_y_direction_component, pixel_clipmap_texel_space_viewport_depth_direction_component);
		clipmap_texel_space_viewport_depth_direction = int3(0, 0, 1);
	}
	else if (int(VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_Y) == in_viewport_depth_direction_index)
	{
		pixel_clipmap_texel_space = float3(pixel_clipmap_texel_space_viewport_y_direction_component, pixel_clipmap_texel_space_viewport_depth_direction_component, pixel_clipmap_texel_space_viewport_x_direction_component);
		clipmap_texel_space_viewport_depth_direction = int3(0, 1, 0);
	}
	else if (int(VCT_VIEWPORT_DEPTH_DIRECTION_AXIS_X) == in_viewport_depth_direction_index)
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

	float voxel_opacity_area_scale;
	{
		float3 normal = normalize(cross(ddx(pixel_clipmap_texel_space), ddy(pixel_clipmap_texel_space)));
		voxel_opacity_area_scale = 1.0 / max(max(abs(normal.x), abs(normal.y)), abs(normal.z));
	}

	[unroll]
	for (int voxel_index = 0; voxel_index < MAX_VOXEL_COUNT; ++voxel_index)
	{
		float voxel_opacity = saturate(voxel_opacity_sample_scales[voxel_index] * voxel_opacity_area_scale);
		
		int3 voxel_clipmap_texel_space = int3(pixel_clipmap_texel_space) + clipmap_texel_space_viewport_depth_direction * voxel_clipmap_texel_space_viewport_depth_direction_component_offsets[voxel_index];

		[branch]
		if (voxel_opacity > 0.0 && all(voxel_clipmap_texel_space >= int3(0, 0, 0)) && all(voxel_clipmap_texel_space < int3(VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE, VCT_CLIPMAP_SIZE)))
		{
#if 5 == VCT_CLIPMAP_LEVEL_COUNT
			[branch]
			if (0 == in_clipmap_level_index)
			{
				uint old_value_packed;
				uint new_value_packed;
				uint return_value_packed;
				[loop]
				do
				{
					old_value_packed = g_clipmap_opacity[0][voxel_clipmap_texel_space];
					
					float old_value_unpacked = asfloat(old_value_packed);
					
					float new_value_unpacked = old_value_unpacked + voxel_opacity;
					
					new_value_packed = asuint(new_value_unpacked);
					
					InterlockedCompareExchange(g_clipmap_opacity[0][voxel_clipmap_texel_space], old_value_packed, new_value_packed, return_value_packed);
				
				} while (return_value_packed != old_value_packed);
			}
			else if (1 == in_clipmap_level_index)
			{
				uint old_value_packed;
				uint new_value_packed;
				uint return_value_packed;
				[loop]
				do
				{
					old_value_packed = g_clipmap_opacity[1][voxel_clipmap_texel_space];
					
					float old_value_unpacked = asfloat(old_value_packed);
					
					float new_value_unpacked = old_value_unpacked + voxel_opacity;
					
					new_value_packed = asuint(new_value_unpacked);
					
					InterlockedCompareExchange(g_clipmap_opacity[1][voxel_clipmap_texel_space], old_value_packed, new_value_packed, return_value_packed);
				
				} while (return_value_packed != old_value_packed);
			}
			else if (2 == in_clipmap_level_index)
			{
				uint old_value_packed;
				uint new_value_packed;
				uint return_value_packed;
				[loop]
				do
				{
					old_value_packed = g_clipmap_opacity[2][voxel_clipmap_texel_space];
					
					float old_value_unpacked = asfloat(old_value_packed);
					
					float new_value_unpacked = old_value_unpacked + voxel_opacity;
					
					new_value_packed = asuint(new_value_unpacked);
					
					InterlockedCompareExchange(g_clipmap_opacity[2][voxel_clipmap_texel_space], old_value_packed, new_value_packed, return_value_packed);
				
				} while (return_value_packed != old_value_packed);
			}
			else if (3 == in_clipmap_level_index)
			{
				uint old_value_packed;
				uint new_value_packed;
				uint return_value_packed;
				[loop]
				do
				{
					old_value_packed = g_clipmap_opacity[3][voxel_clipmap_texel_space];
					
					float old_value_unpacked = asfloat(old_value_packed);
					
					float new_value_unpacked = old_value_unpacked + voxel_opacity;
					
					new_value_packed = asuint(new_value_unpacked);
					
					InterlockedCompareExchange(g_clipmap_opacity[3][voxel_clipmap_texel_space], old_value_packed, new_value_packed, return_value_packed);
				
				} while (return_value_packed != old_value_packed);
			}
			else if (4 == in_clipmap_level_index)
			{
				uint old_value_packed;
				uint new_value_packed;
				uint return_value_packed;
				[loop]
				do
				{
					old_value_packed = g_clipmap_opacity[4][voxel_clipmap_texel_space];
					
					float old_value_unpacked = asfloat(old_value_packed);
					
					float new_value_unpacked = old_value_unpacked + voxel_opacity;
					
					new_value_packed = asuint(new_value_unpacked);
					
					InterlockedCompareExchange(g_clipmap_opacity[4][voxel_clipmap_texel_space], old_value_packed, new_value_packed, return_value_packed);
				
				} while (return_value_packed != old_value_packed);
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
	}

	// out_debug_color = float4(1.0, 0.0, 0.0, 1.0);
	discard;
	return;
}

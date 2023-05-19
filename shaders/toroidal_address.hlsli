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

#ifndef _SHADERS_TOROIDAL_ADDRESS_HLSLI_
#define _SHADERS_TOROIDAL_ADDRESS_HLSLI_ 1

#include "config.sli"

int3 calculate_clipmap_toroidal_address(int3 clipmap_texel_space, int clipmap_level_index)
{
	// "Toroidal Addressing" of \[Panteleev 2014\] [Alexey Panteleev. "Practical Real-Time Voxel-Based Global Illumination for Current GPUs." GTC 2014.](https://on-demand.gputechconf.com/gtc/2014/presentations/S4552-rt-voxel-based-global-illumination-gpus.pdf)	
	// "A fixed point in space always maps to the same address in the clipmap"

#if PERSISTENT_VOXEL_DATA
	// assert(all(g_clipmap_level_toroidal_offsets[in_clipmap_level_index].xyz >= 0))
	// int3 clipmap_toroidal_address = ((clipmap_texel_space + g_clipmap_level_toroidal_offsets[clipmap_level_index].xyz) % int3(CLIPMAP_SIZE, CLIPMAP_SIZE, CLIPMAP_SIZE) + int3(CLIPMAP_SIZE, CLIPMAP_SIZE, CLIPMAP_SIZE)) % int3(CLIPMAP_SIZE, CLIPMAP_SIZE, CLIPMAP_SIZE);
	int3 clipmap_toroidal_address = (clipmap_texel_space + g_clipmap_level_toroidal_offsets[clipmap_level_index].xyz) % int3(CLIPMAP_SIZE, CLIPMAP_SIZE, CLIPMAP_SIZE);
#else
	// fake
	int3 clipmap_toroidal_address = clipmap_texel_space;
#endif

	return clipmap_toroidal_address;
}

#endif
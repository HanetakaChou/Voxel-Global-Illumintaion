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

#ifndef _SHADERS_PACKED_OPACITY_HLSLI_
#define _SHADERS_PACKED_OPACITY_HLSLI_ 1

uint pack_opacity(float unpacked_opacity)
{
    uint packed_opacity = uint(unpacked_opacity * 1023.0);
    return packed_opacity;
}

float unpack_opacity(uint packed_opacity)
{
    float unpacked_opacity = float(packed_opacity) / 1023.0;
    return unpacked_opacity;
}


#endif
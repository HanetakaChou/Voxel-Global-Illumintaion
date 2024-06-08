#version 310 es

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

#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_control_flow_attributes : enable
#extension GL_ARB_fragment_shader_interlock : enable

layout(set = 1, binding = 0, r32i) highp uniform iimage3D u_Opacity;

void main()
{
    // VK_EXT_fragment_shader_interlock

    beginInvocationInterlockARB();

    highp int test = imageLoad(u_Opacity, ivec3(0, 0, 0)).x;

    test = test + 1;

    imageStore(u_Opacity, ivec3(0, 0, 0), ivec4(test, 0, 0, 0));

    endInvocationInterlockARB();

    // VK_EXT_rasterization_order_attachment_access
}
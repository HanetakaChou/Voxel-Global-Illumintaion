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

#ifndef _LIGHT_INJECTION_SHARED_H_
#define _LIGHT_INJECTION_SHARED_H_ 1

#if defined(__fsl)

STRUCT(light_injection_type_render_pass_set_per_frame_rootcbv)
{
	DATA(float4x4, g_view_transform, None);
	DATA(float4x4, g_projection_transform, None);
};
RES(CBUFFER(light_injection_type_render_pass_set_per_frame_rootcbv), light_injection_render_pass_set_per_frame_rootcbv, UPDATE_FREQ_NONE, b0, binding = 0);

STRUCT(light_injection_type_render_pass_set_per_draw_rootcbv)
{
	DATA(float4x4, g_model_transform, None);
};
RES(CBUFFER(light_injection_type_render_pass_set_per_draw_rootcbv), light_injection_render_pass_set_per_draw_rootcbv, UPDATE_FREQ_NONE, b1, binding = 1);

STRUCT(light_injection_type_mesh_material_set_constant_buffer)
{
	DATA(float3, g_base_color, None);
	DATA(float, g_metallic, None);
	DATA(float, g_roughness, None);
};
RES(CBUFFER(light_injection_type_mesh_material_set_constant_buffer), light_injection_mesh_material_set_constant_buffer, UPDATE_FREQ_PER_DRAW, b0, binding = 0);

#else

struct light_injection_render_pass_set_per_frame_rootcbv_data
{
	DirectX::XMFLOAT4X4 view_transform;
	DirectX::XMFLOAT4X4 projection_transform;
};

struct light_injection_render_pass_set_per_draw_rootcbv_data
{
	DirectX::XMFLOAT4X4 model_transform;
};

struct light_injection_mesh_material_set_constant_buffer_data
{
	DirectX::XMFLOAT3 base_color;
	float metallic;
	float roughness;
};

#endif

#endif
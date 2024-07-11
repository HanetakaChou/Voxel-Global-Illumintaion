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

#include "light_injection_shared.h"

STRUCT(VSInput)
{
	DATA(float3, Position, POSITION);
	DATA(float4, Normal, NORMAL);
};

STRUCT(VS_TO_PS)
{
	DATA(float4, Position, SV_Position);
	DATA(float3, Normal, NORMAL);
};

STRUCT(PS_OUT)
{
	DATA(float4, Color, SV_TARGET0);
};

#if STAGE_VERT

VS_TO_PS VS_MAIN(VSInput vertex_input)
{
	INIT_MAIN;

	VS_TO_PS vertex_output;
	vertex_output.Position = mul(Get(g_projection_transform), mul(Get(g_view_transform), mul(Get(g_model_transform), float4(vertex_input.Position, 1.0))));
	vertex_output.Normal = vertex_input.Normal.xyz * 2.0 - 1.0;
	RETURN(vertex_output);
}

#elif STAGE_FRAG

PS_OUT PS_MAIN(VS_TO_PS pixel_input)
{
	INIT_MAIN;

	float3 N = normalize(pixel_input.Normal);

	PS_OUT pixel_output;
	pixel_output.Color = float4(Get(g_base_color), 1.0);

	RETURN(pixel_output);
}

#else
#error Unknown Stage
#endif
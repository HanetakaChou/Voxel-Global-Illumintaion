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

void main(in uint in_vertex_id : SV_VertexID, out float4 out_position : SV_Position, out float2 out_uv : TEXCOORD0)
{
    const float2 full_screen_triangle_positions[3] = { float2(-1.0, 3.0), float2(3.0, -1.0),  float2(-1.0, -1.0) };
    const float2 full_screen_triangle_uvs[3] = { float2(0.0, -1.0), float2(2.0, 1.0), float2(0.0, 1.0) };

    out_position = float4(full_screen_triangle_positions[in_vertex_id], 0.0, 1.0);
	out_uv = full_screen_triangle_uvs[in_vertex_id];
}
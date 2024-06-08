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

#ifndef _DEMO_H_
#define _DEMO_H_ 1

#include <sdkddkver.h>
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#ifndef NOMINMAX
#define NOMINMAX 1
#endif
#include <windows.h>

#include <dxgi.h>
#include <d3d11.h>

#include "../shaders/vct_configuration.sli"

class Demo
{
	// Frame Buffer
	// Swap Chain
	ID3D11RenderTargetView *m_swap_chain_frame_buffer_render_target_view;
	// Light Injection
	ID3D11Texture2D *m_vct_light_injection_frame_buffer_render_target;
	ID3D11RenderTargetView *m_vct_light_injection_frame_buffer_render_target_view;

	// Clipmap
	ID3D11Texture3D *m_clipmap_opacity[VCT_CLIPMAP_LEVEL_COUNT];
	ID3D11UnorderedAccessView *m_clipmap_opacity_unordered_access_view[VCT_CLIPMAP_LEVEL_COUNT];
	ID3D11ShaderResourceView *m_clipmap_opacity_shader_resource_view[VCT_CLIPMAP_LEVEL_COUNT];

	// Mesh Asset
	// Sponza
	ID3D11Buffer *m_sponza_vertex_buffer_position;
	ID3D11ShaderResourceView *m_sponza_vertex_buffer_position_view;
	ID3D11Buffer *m_sponza_index_buffer;
	ID3D11ShaderResourceView *m_sponza_index_buffer_view;
	uint32_t m_sponza_index_count;

	// Pipeline State Object
	// Light Injection
	ID3D11VertexShader *m_vct_light_injection_mesh_vertex_shader;
	ID3D11RasterizerState *m_vct_light_injection_rasterizer_state;
	ID3D11PixelShader *m_vct_light_injection_pixel_shader;
	ID3D11DepthStencilState *m_vct_light_injection_depth_stencil_state;
	ID3D11Buffer *m_vct_light_injection_per_batch_constant_buffer;
	ID3D11Buffer *m_vct_light_injection_per_draw_constant_buffer;
	// Visualization
	ID3D11VertexShader *m_full_screen_triangle_vertex_shader;
	ID3D11RasterizerState *m_visualization_rasterizer_state;
	ID3D11PixelShader *m_visualization_pixel_shader;
	ID3D11DepthStencilState *m_visualization_depth_stencil_state;
	ID3D11Buffer *m_visualization_constant_buffer_frame;

public:
	void Init(ID3D11Device *d3d11_device, ID3D11DeviceContext *d3d11_device_context, IDXGISwapChain *dxgi_swap_chain);
	void Tick(ID3D11DeviceContext *d3d11_device_context, IDXGISwapChain *dxgi_swap_chain);
};

#endif
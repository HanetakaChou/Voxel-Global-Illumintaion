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

#include <sdkddkver.h>
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#ifndef NOMINMAX
#define NOMINMAX 1
#endif
#include <windows.h>

#include <stddef.h>
#include <stdint.h>
#include <assert.h>
#include <vector>

#include <DirectXMath.h>
#include <DirectXPackedVector.h>

#include <dxgi.h>
#include <d3d11.h>

#include "support/resolution.h"
#include "support/camera_controller.h"

#include "demo.h"

#include "../assets/sponza.h"

#include "../shaders/vct_configuration.sli"
#include "../shaders/vct_constant.sli"
#include "../shaders/mesh_vertex.sli"
#include "../shaders/vct_light_injection_shader_resource_table.sli"
#include "../shaders/visualization_shader_resource_table.sli"

#include "../dxbc/vct_light_injection_mesh_vertex.inl"
#include "../dxbc/vct_light_injection_pixel.inl"
#include "../dxbc/full_screen_triangle_vertex.inl"
#include "../dxbc/visualization_pixel.inl"

void Demo::Init(ID3D11Device *d3d_device, ID3D11DeviceContext *d3d_device_context, IDXGISwapChain *dxgi_swap_chain)
{
	// Frame Buffer
	// Swap Chain
	this->m_swap_chain_frame_buffer_render_target_view = NULL;
	{
		ID3D11Texture2D *swap_chain_back_buffer = NULL;
		HRESULT res_dxgi_swap_chain_get_buffer = dxgi_swap_chain->GetBuffer(0U, IID_PPV_ARGS(&swap_chain_back_buffer));
		assert(SUCCEEDED(res_dxgi_swap_chain_get_buffer));

		D3D11_RENDER_TARGET_VIEW_DESC d3d_render_target_view_desc;
		d3d_render_target_view_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
		d3d_render_target_view_desc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
		d3d_render_target_view_desc.Texture2D.MipSlice = 0U;

		HRESULT res_d3d_device_create_render_target_view = d3d_device->CreateRenderTargetView(swap_chain_back_buffer, &d3d_render_target_view_desc, &this->m_swap_chain_frame_buffer_render_target_view);
		assert(SUCCEEDED(res_d3d_device_create_render_target_view));
	}
	// Light Injection
	this->m_vct_light_injection_frame_buffer_render_target = NULL;
	{
		D3D11_TEXTURE2D_DESC d3d_texture2d_desc;
		d3d_texture2d_desc.Width = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);
		d3d_texture2d_desc.Height = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);
		d3d_texture2d_desc.MipLevels = 1U;
		d3d_texture2d_desc.ArraySize = 1U;
		d3d_texture2d_desc.Format = DXGI_FORMAT_R8_UNORM;
		d3d_texture2d_desc.SampleDesc.Count = static_cast<uint32_t>(VCT_VOXELIZATION_SAMPLE_COUNT);
		d3d_texture2d_desc.SampleDesc.Quality = D3D11_STANDARD_MULTISAMPLE_PATTERN;
		d3d_texture2d_desc.Usage = D3D11_USAGE_DEFAULT;
		d3d_texture2d_desc.BindFlags = D3D11_BIND_RENDER_TARGET;
		d3d_texture2d_desc.CPUAccessFlags = 0U;
		d3d_texture2d_desc.MiscFlags = 0U;

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateTexture2D(&d3d_texture2d_desc, NULL, &this->m_vct_light_injection_frame_buffer_render_target);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}
	this->m_vct_light_injection_frame_buffer_render_target_view = NULL;
	{
		D3D11_RENDER_TARGET_VIEW_DESC d3d_render_target_view_desc;
		d3d_render_target_view_desc.Format = DXGI_FORMAT_R8_UNORM;
		d3d_render_target_view_desc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2DMS;
		// d3d_render_target_view_desc.Texture2DMS.UnusedField_NothingToDefine = 0U;

		HRESULT res_d3d_device_create_shader_resource_view = d3d_device->CreateRenderTargetView(this->m_vct_light_injection_frame_buffer_render_target, &d3d_render_target_view_desc, &this->m_vct_light_injection_frame_buffer_render_target_view);
		assert(SUCCEEDED(res_d3d_device_create_shader_resource_view));
	}

	// Clipmap
	// this->m_clipmap_opacity = NULL;
	{
		for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
		{
			D3D11_TEXTURE3D_DESC d3d_texture3d_desc;
			d3d_texture3d_desc.Width = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);
			d3d_texture3d_desc.Height = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);
			d3d_texture3d_desc.Depth = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);
			d3d_texture3d_desc.MipLevels = 1U;
			d3d_texture3d_desc.Format = DXGI_FORMAT_R32_UINT;
			d3d_texture3d_desc.Usage = D3D11_USAGE_DEFAULT;
			d3d_texture3d_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS;
			d3d_texture3d_desc.CPUAccessFlags = 0U;
			d3d_texture3d_desc.MiscFlags = 0U;

			HRESULT res_d3d_device_create_buffer = d3d_device->CreateTexture3D(&d3d_texture3d_desc, NULL, &this->m_clipmap_opacity[clipmap_level_index]);
			assert(SUCCEEDED(res_d3d_device_create_buffer));
		}
	}
	// this->m_clipmap_opacity_unordered_access_view = NULL;
	{

		for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
		{
			D3D11_UNORDERED_ACCESS_VIEW_DESC d3d_unordered_access_view_desc;
			d3d_unordered_access_view_desc.Format = DXGI_FORMAT_R32_UINT;
			d3d_unordered_access_view_desc.ViewDimension = D3D11_UAV_DIMENSION_TEXTURE3D;
			d3d_unordered_access_view_desc.Texture3D.MipSlice = 0U;
			d3d_unordered_access_view_desc.Texture3D.FirstWSlice = 0U;
			d3d_unordered_access_view_desc.Texture3D.WSize = static_cast<uint32_t>(VCT_CLIPMAP_SIZE);

			HRESULT res_d3d_device_create_unordered_access_view = d3d_device->CreateUnorderedAccessView(this->m_clipmap_opacity[clipmap_level_index], &d3d_unordered_access_view_desc, &this->m_clipmap_opacity_unordered_access_view[clipmap_level_index]);
			assert(SUCCEEDED(res_d3d_device_create_unordered_access_view));
		}
	}
	// this->m_clipmap_opacity_shader_resource_view = NULL;
	{
		for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
		{
			D3D11_SHADER_RESOURCE_VIEW_DESC d3d_shader_resource_view_desc;
			d3d_shader_resource_view_desc.Format = DXGI_FORMAT_R32_UINT;
			d3d_shader_resource_view_desc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE3D;
			d3d_shader_resource_view_desc.Texture3D.MostDetailedMip = 0U;
			d3d_shader_resource_view_desc.Texture3D.MipLevels = 1U;

			HRESULT res_d3d_device_create_shader_resource_view = d3d_device->CreateShaderResourceView(this->m_clipmap_opacity[clipmap_level_index], &d3d_shader_resource_view_desc, &this->m_clipmap_opacity_shader_resource_view[clipmap_level_index]);
			assert(SUCCEEDED(res_d3d_device_create_shader_resource_view));
		}
	}

	// Mesh Asset
	// Sponza
	uint32_t const sponza_vertex_count = sizeof(sponza_vertex_positions) / sizeof(sponza_vertex_positions[0]);
	this->m_sponza_vertex_buffer_position = NULL;
	{

		std::vector<mesh_vertex_position> mesh_vertex_positions;
		mesh_vertex_positions.resize(sponza_vertex_count);
		for (uint32_t vertex_index = 0U; vertex_index < sponza_vertex_count; ++vertex_index)
		{
			mesh_vertex_positions[vertex_index].position_x = sponza_vertex_positions[vertex_index].x;
			mesh_vertex_positions[vertex_index].position_y = sponza_vertex_positions[vertex_index].y;
			mesh_vertex_positions[vertex_index].position_z = sponza_vertex_positions[vertex_index].z;
		}

		D3D11_BUFFER_DESC d3d_buffer_desc;
		d3d_buffer_desc.ByteWidth = sizeof(mesh_vertex_position) * sponza_vertex_count;
		d3d_buffer_desc.Usage = D3D11_USAGE_IMMUTABLE;
		d3d_buffer_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
		d3d_buffer_desc.CPUAccessFlags = 0U;
		d3d_buffer_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
		d3d_buffer_desc.StructureByteStride = 0U;

		D3D11_SUBRESOURCE_DATA d3d_subresource_data;
		d3d_subresource_data.pSysMem = &mesh_vertex_positions[0];
		d3d_subresource_data.SysMemPitch = sizeof(mesh_vertex_position);
		d3d_subresource_data.SysMemSlicePitch = sizeof(mesh_vertex_position);

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateBuffer(&d3d_buffer_desc, &d3d_subresource_data, &this->m_sponza_vertex_buffer_position);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}
	this->m_sponza_vertex_buffer_position_view = NULL;
	{
		D3D11_SHADER_RESOURCE_VIEW_DESC d3d_view_desc;
		d3d_view_desc.Format = DXGI_FORMAT_R32_TYPELESS;
		d3d_view_desc.ViewDimension = D3D_SRV_DIMENSION_BUFFEREX;
		d3d_view_desc.BufferEx.FirstElement = 0U;
		assert(0U == ((sizeof(mesh_vertex_position) * sponza_vertex_count) % sizeof(uint32_t)));
		d3d_view_desc.BufferEx.NumElements = sizeof(mesh_vertex_position) * sponza_vertex_count / sizeof(uint32_t);
		d3d_view_desc.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
		HRESULT res_d3d_device_create_view = d3d_device->CreateShaderResourceView(this->m_sponza_vertex_buffer_position, &d3d_view_desc, &this->m_sponza_vertex_buffer_position_view);
		assert(SUCCEEDED(res_d3d_device_create_view));
	}
	uint32_t const sponza_index_count = sizeof(sponza_indices) / sizeof(sponza_indices[0]);
	this->m_sponza_index_buffer = NULL;
	{
		D3D11_BUFFER_DESC d3d_buffer_desc;
		d3d_buffer_desc.ByteWidth = sizeof(uint32_t) * sponza_index_count;
		d3d_buffer_desc.Usage = D3D11_USAGE_IMMUTABLE;
		d3d_buffer_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
		d3d_buffer_desc.CPUAccessFlags = 0U;
		d3d_buffer_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
		d3d_buffer_desc.StructureByteStride = 0U;

		D3D11_SUBRESOURCE_DATA d3d_subresource_data;
		d3d_subresource_data.pSysMem = &sponza_indices[0];
		d3d_subresource_data.SysMemPitch = sizeof(uint32_t);
		d3d_subresource_data.SysMemSlicePitch = sizeof(uint32_t);

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateBuffer(&d3d_buffer_desc, &d3d_subresource_data, &this->m_sponza_index_buffer);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}
	this->m_sponza_index_buffer_view = NULL;
	{
		D3D11_SHADER_RESOURCE_VIEW_DESC d3d_view_desc;
		d3d_view_desc.Format = DXGI_FORMAT_R32_TYPELESS;
		d3d_view_desc.ViewDimension = D3D_SRV_DIMENSION_BUFFEREX;
		d3d_view_desc.BufferEx.FirstElement = 0U;
		assert(0U == ((sizeof(uint32_t) * sponza_index_count) % sizeof(uint32_t)));
		d3d_view_desc.BufferEx.NumElements = sizeof(uint32_t) * sponza_index_count / sizeof(uint32_t);
		d3d_view_desc.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
		HRESULT res_d3d_device_create_view = d3d_device->CreateShaderResourceView(this->m_sponza_index_buffer, &d3d_view_desc, &this->m_sponza_index_buffer_view);
		assert(SUCCEEDED(res_d3d_device_create_view));
	}
	this->m_sponza_index_count = sponza_index_count;

	// Pipeline State Object
	// Light Injection
	this->m_vct_light_injection_mesh_vertex_shader = NULL;
	{
		HRESULT res_d3d_device_create_vertex_shader = d3d_device->CreateVertexShader(g_dxbc_vct_light_injection_mesh_vertex, sizeof(g_dxbc_vct_light_injection_mesh_vertex), NULL, &this->m_vct_light_injection_mesh_vertex_shader);
		assert(SUCCEEDED(res_d3d_device_create_vertex_shader));
	}
	this->m_vct_light_injection_rasterizer_state = NULL;
	{
		D3D11_RASTERIZER_DESC d3d_rasterizer_desc;
		d3d_rasterizer_desc.FillMode = D3D11_FILL_SOLID;
		d3d_rasterizer_desc.CullMode = D3D11_CULL_NONE;
		d3d_rasterizer_desc.FrontCounterClockwise = FALSE;
		d3d_rasterizer_desc.DepthBias = 0;
		d3d_rasterizer_desc.DepthBiasClamp = 0.0F;
		d3d_rasterizer_desc.SlopeScaledDepthBias = 0.0F;
		d3d_rasterizer_desc.DepthClipEnable = FALSE; // The whole primitive will be clipped even if only one of the three Vertices is clipped
		d3d_rasterizer_desc.ScissorEnable = FALSE;
		d3d_rasterizer_desc.MultisampleEnable = TRUE;
		d3d_rasterizer_desc.AntialiasedLineEnable = FALSE;
		HRESULT res_d3d_device_create_rasterizer_state = d3d_device->CreateRasterizerState(&d3d_rasterizer_desc, &this->m_vct_light_injection_rasterizer_state);
		assert(SUCCEEDED(res_d3d_device_create_rasterizer_state));
	}
	this->m_vct_light_injection_pixel_shader = NULL;
	{
		HRESULT res_d3d_device_create_pixel_shader = d3d_device->CreatePixelShader(g_dxbc_vct_light_injection_pixel, sizeof(g_dxbc_vct_light_injection_pixel), NULL, &this->m_vct_light_injection_pixel_shader);
		assert(SUCCEEDED(res_d3d_device_create_pixel_shader));
	}
	this->m_vct_light_injection_depth_stencil_state = NULL;
	{
		D3D11_DEPTH_STENCIL_DESC d3d_depth_stencil_desc;
		d3d_depth_stencil_desc.DepthEnable = FALSE;
		d3d_depth_stencil_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
		d3d_depth_stencil_desc.DepthFunc = D3D11_COMPARISON_LESS;
		d3d_depth_stencil_desc.StencilEnable = FALSE;
		d3d_depth_stencil_desc.StencilReadMask = D3D11_DEFAULT_STENCIL_READ_MASK;
		d3d_depth_stencil_desc.StencilWriteMask = D3D11_DEFAULT_STENCIL_WRITE_MASK;
		d3d_depth_stencil_desc.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		d3d_depth_stencil_desc.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		d3d_depth_stencil_desc.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		HRESULT res_d3d_device_create_depth_stencil_state = d3d_device->CreateDepthStencilState(&d3d_depth_stencil_desc, &this->m_vct_light_injection_depth_stencil_state);
		assert(SUCCEEDED(res_d3d_device_create_depth_stencil_state));
	}
	this->m_vct_light_injection_per_batch_constant_buffer = NULL;
	{
		D3D11_BUFFER_DESC d3d_buffer_desc;
		d3d_buffer_desc.ByteWidth = sizeof(light_injection_per_batch_constant_buffer);
		d3d_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
		d3d_buffer_desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		d3d_buffer_desc.CPUAccessFlags = 0U;
		d3d_buffer_desc.MiscFlags = 0U;
		d3d_buffer_desc.StructureByteStride = 0U;

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateBuffer(&d3d_buffer_desc, NULL, &this->m_vct_light_injection_per_batch_constant_buffer);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}
	this->m_vct_light_injection_per_draw_constant_buffer = NULL;
	{
		D3D11_BUFFER_DESC d3d_buffer_desc;
		d3d_buffer_desc.ByteWidth = sizeof(light_injection_per_batch_constant_buffer);
		d3d_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
		d3d_buffer_desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		d3d_buffer_desc.CPUAccessFlags = 0U;
		d3d_buffer_desc.MiscFlags = 0U;
		d3d_buffer_desc.StructureByteStride = 0U;

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateBuffer(&d3d_buffer_desc, NULL, &this->m_vct_light_injection_per_draw_constant_buffer);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}
	// Visualization
	this->m_full_screen_triangle_vertex_shader = NULL;
	{
		HRESULT res_d3d_device_create_vertex_shader = d3d_device->CreateVertexShader(g_dxbc_full_screen_triangle_vertex, sizeof(g_dxbc_full_screen_triangle_vertex), NULL, &this->m_full_screen_triangle_vertex_shader);
		assert(SUCCEEDED(res_d3d_device_create_vertex_shader));
	}
	this->m_visualization_rasterizer_state = NULL;
	{
		D3D11_RASTERIZER_DESC d3d_rasterizer_desc;
		d3d_rasterizer_desc.FillMode = D3D11_FILL_SOLID;
		d3d_rasterizer_desc.CullMode = D3D11_CULL_BACK;
		d3d_rasterizer_desc.FrontCounterClockwise = FALSE;
		d3d_rasterizer_desc.DepthBias = 0;
		d3d_rasterizer_desc.DepthBiasClamp = 0.0F;
		d3d_rasterizer_desc.SlopeScaledDepthBias = 0.0F;
		d3d_rasterizer_desc.DepthClipEnable = TRUE;
		d3d_rasterizer_desc.ScissorEnable = FALSE;
		d3d_rasterizer_desc.MultisampleEnable = FALSE;
		d3d_rasterizer_desc.AntialiasedLineEnable = FALSE;
		HRESULT res_d3d_device_create_rasterizer_state = d3d_device->CreateRasterizerState(&d3d_rasterizer_desc, &this->m_visualization_rasterizer_state);
		assert(SUCCEEDED(res_d3d_device_create_rasterizer_state));
	}
	this->m_visualization_pixel_shader = NULL;
	{
		HRESULT res_d3d_device_create_pixel_shader = d3d_device->CreatePixelShader(g_dxbc_visualization_pixel, sizeof(g_dxbc_visualization_pixel), NULL, &this->m_visualization_pixel_shader);
		assert(SUCCEEDED(res_d3d_device_create_pixel_shader));
	}
	this->m_visualization_depth_stencil_state = NULL;
	{
		D3D11_DEPTH_STENCIL_DESC d3d_depth_stencil_desc;
		d3d_depth_stencil_desc.DepthEnable = FALSE;
		d3d_depth_stencil_desc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
		d3d_depth_stencil_desc.DepthFunc = D3D11_COMPARISON_LESS;
		d3d_depth_stencil_desc.StencilEnable = FALSE;
		d3d_depth_stencil_desc.StencilReadMask = D3D11_DEFAULT_STENCIL_READ_MASK;
		d3d_depth_stencil_desc.StencilWriteMask = D3D11_DEFAULT_STENCIL_WRITE_MASK;
		d3d_depth_stencil_desc.FrontFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		d3d_depth_stencil_desc.BackFace.StencilFunc = D3D11_COMPARISON_ALWAYS;
		d3d_depth_stencil_desc.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilPassOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.FrontFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		d3d_depth_stencil_desc.BackFace.StencilFailOp = D3D11_STENCIL_OP_KEEP;
		HRESULT res_d3d_device_create_depth_stencil_state = d3d_device->CreateDepthStencilState(&d3d_depth_stencil_desc, &this->m_visualization_depth_stencil_state);
		assert(SUCCEEDED(res_d3d_device_create_depth_stencil_state));
	}
	this->m_visualization_constant_buffer_frame = NULL;
	{
		D3D11_BUFFER_DESC d3d_buffer_desc;
		d3d_buffer_desc.ByteWidth = sizeof(visualization_constant_buffer_frame);
		d3d_buffer_desc.Usage = D3D11_USAGE_DEFAULT;
		d3d_buffer_desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		d3d_buffer_desc.CPUAccessFlags = 0U;
		d3d_buffer_desc.MiscFlags = 0U;
		d3d_buffer_desc.StructureByteStride = 0U;

		HRESULT res_d3d_device_create_buffer = d3d_device->CreateBuffer(&d3d_buffer_desc, NULL, &this->m_visualization_constant_buffer_frame);
		assert(SUCCEEDED(res_d3d_device_create_buffer));
	}

	// Camera
	g_camera_controller.m_eye_position = DirectX::XMFLOAT3(0.0f, 100.0f, 50.0f);
	g_camera_controller.m_eye_direction = DirectX::XMFLOAT3(-100.0f, 0.0f, 0.0f);
	g_camera_controller.m_up_direction = DirectX::XMFLOAT3(0.0, 1.0, 0.0);
}

void Demo::Tick(ID3D11DeviceContext *d3d_device_context, IDXGISwapChain *dxgi_swap_chain)
{
	// Update Frame Constant
	struct light_injection_per_batch_constant_buffer voxelization_b0;
	struct visualization_constant_buffer_frame visualization_b0;
	{
		DirectX::XMVECTOR main_camera_position = DirectX::XMLoadFloat3(&g_camera_controller.m_eye_position);
		DirectX::XMVECTOR main_camera_direction = DirectX::XMLoadFloat3(&g_camera_controller.m_eye_direction);
		DirectX::XMVECTOR main_camera_up_direction = DirectX::XMLoadFloat3(&g_camera_controller.m_up_direction);

		// Camera
		{
			DirectX::XMStoreFloat3(&visualization_b0.g_main_camera_position, main_camera_position);

			DirectX::XMMATRIX main_camera_view_matrix = DirectX::XMMatrixLookToLH(main_camera_position, main_camera_direction, main_camera_up_direction);

			DirectX::XMVECTOR main_camera_view_matrix_determinant;
			DirectX::XMMATRIX main_camera_inverse_view_matrix = DirectX::XMMatrixInverse(&main_camera_view_matrix_determinant, main_camera_view_matrix);

			DirectX::XMStoreFloat4x4(&visualization_b0.g_main_camera_inverse_view_matrix, main_camera_inverse_view_matrix);

			DirectX::XMMATRIX main_camera_projection_matrix = DirectX::XMMatrixPerspectiveFovLH(DirectX::XM_PIDIV4, static_cast<float>(g_resolution_width) / static_cast<float>(g_resolution_height), 1.0F, 10000.0F);

			DirectX::XMVECTOR main_camera_projection_matrix_determinant;
			DirectX::XMMATRIX main_camera_inverse_projection_matrix = DirectX::XMMatrixInverse(&main_camera_projection_matrix_determinant, main_camera_projection_matrix);

			DirectX::XMStoreFloat4x4(&visualization_b0.g_main_camera_inverse_projection_matrix, main_camera_inverse_projection_matrix);
		}

		// Anchor is the point around which the clipmap center is located
		DirectX::XMVECTOR clipmap_anchor = DirectX::XMVectorAdd(main_camera_position, DirectX::XMVectorScale(DirectX::XMVector3Normalize(main_camera_direction), static_cast<float>(VCT_FINEST_VOXEL_SIZE) * static_cast<float>(VCT_CLIPMAP_SIZE) * 0.5F));

		// The anchor is snapped to a grid.
		DirectX::XMVECTOR clipmap_center;
		{
			float const coarsest_voxel_size = static_cast<float>(VCT_FINEST_VOXEL_SIZE) * static_cast<float>(1U << (static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT) - 1U));

			clipmap_center = DirectX::XMVectorScale(DirectX::XMVectorRound(DirectX::XMVectorScale(clipmap_anchor, 1.0F / coarsest_voxel_size)), coarsest_voxel_size);

			DirectX::XMStoreFloat3(&visualization_b0.g_clipmap_center, clipmap_center);
		}

		// Axis
		{
			// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)

			DirectX::XMFLOAT3 viewport_depth_direction_eye_directions[VCT_VIEWPORT_DEPTH_DIRECTION_COUNT] = {
				DirectX::XMFLOAT3(0.0F, 0.0F, 1.0F), // AXIS_INDEX_Z xyz -> xyz
				DirectX::XMFLOAT3(0.0F, 1.0F, 0.0F), // AXIS_INDEX_Y xyz -> zxy
				DirectX::XMFLOAT3(1.0F, 0.0F, 0.0F)	 // AXIS_INDEX_X xyz -> yzx
			};

			DirectX::XMFLOAT3 viewport_depth_direction_up_directions[VCT_VIEWPORT_DEPTH_DIRECTION_COUNT] = {
				DirectX::XMFLOAT3(0.0F, 1.0F, 0.0F), // AXIS_INDEX_Z xyz -> xyz
				DirectX::XMFLOAT3(1.0F, 0.0F, 0.0F), // AXIS_INDEX_Y xyz -> zxy
				DirectX::XMFLOAT3(0.0F, 0.0F, 1.0F)	 // AXIS_INDEX_X xyz -> yzx
			};

			for (uint32_t viewport_depth_direction_index = 0U; viewport_depth_direction_index < VCT_VIEWPORT_DEPTH_DIRECTION_COUNT; ++viewport_depth_direction_index)
			{
				DirectX::XMMATRIX viewport_depth_direction_view_matrix = DirectX::XMMatrixLookToLH(clipmap_center, DirectX::XMLoadFloat3(&viewport_depth_direction_eye_directions[viewport_depth_direction_index]), DirectX::XMLoadFloat3(&viewport_depth_direction_up_directions[viewport_depth_direction_index]));

				DirectX::XMStoreFloat4x4(&voxelization_b0.g_viewport_depth_direction_view_matrices[viewport_depth_direction_index], viewport_depth_direction_view_matrix);
			}
		}

		// Clip Map Level
		for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
		{
			float clipmap_level_voxel_size = static_cast<float>(VCT_FINEST_VOXEL_SIZE) * static_cast<float>(1U << clipmap_level_index);

			DirectX::XMMATRIX clipmap_level_projection_matrix = DirectX::XMMatrixOrthographicLH(clipmap_level_voxel_size * static_cast<float>(VCT_CLIPMAP_SIZE), clipmap_level_voxel_size * static_cast<float>(VCT_CLIPMAP_SIZE), -clipmap_level_voxel_size * static_cast<float>(VCT_CLIPMAP_SIZE) * 0.5F, clipmap_level_voxel_size * static_cast<float>(VCT_CLIPMAP_SIZE) * 0.5F);

			DirectX::XMStoreFloat4x4(&voxelization_b0.g_clipmap_level_projection_matrices[clipmap_level_index], clipmap_level_projection_matrix);

			// To make sure the result is NOT negative
			assert(DirectX::XMVector3Equal(DirectX::XMVectorMod(clipmap_center, DirectX::XMVectorReplicate(clipmap_level_voxel_size)), DirectX::XMVectorZero()));
			DirectX::XMVECTOR clipmap_level_toroidal_offset = DirectX::XMVectorMod(DirectX::XMVectorAdd(DirectX::XMVectorMod(DirectX::XMVectorScale(clipmap_center, 1.0F / clipmap_level_voxel_size), DirectX::XMVectorReplicate(static_cast<float>(VCT_CLIPMAP_SIZE))), DirectX::XMVectorReplicate(static_cast<float>(VCT_CLIPMAP_SIZE))), DirectX::XMVectorReplicate(static_cast<float>(VCT_CLIPMAP_SIZE)));

			DirectX::XMStoreFloat3(&voxelization_b0.g_clipmap_level_toroidal_offsets[clipmap_level_index], clipmap_level_toroidal_offset);
			DirectX::XMStoreFloat3(&visualization_b0.g_clipmap_level_toroidal_offsets[clipmap_level_index], clipmap_level_toroidal_offset);
		}
	}

	// Light Injection Pass
	{
		// Update Frame Constant
		d3d_device_context->UpdateSubresource(this->m_vct_light_injection_per_batch_constant_buffer, 0U, NULL, &voxelization_b0, sizeof(struct light_injection_per_batch_constant_buffer), sizeof(struct light_injection_per_batch_constant_buffer));

		// Frame Buffer
		{
			D3D11_VIEWPORT viewports[1] = {{0.0F, 0.0F, static_cast<float>(VCT_CLIPMAP_SIZE), static_cast<float>(VCT_CLIPMAP_SIZE), 0.0F, 1.0F}};
			d3d_device_context->RSSetViewports(1U, viewports);

			// \[Takeshige 2015\] [Masaya Takeshige. "The Basics of GPU Voxelization." NVIDIA GameWorks Blog 2015.](https://developer.nvidia.com/content/basics-gpu-voxelization)
			// We use dummy render target to force "MSAA" and simulate "conservative rasterization"
			ID3D11RenderTargetView *const render_target_views[1U] = {this->m_vct_light_injection_frame_buffer_render_target_view};

			ID3D11UnorderedAccessView *unordered_access_views[VCT_CLIPMAP_LEVEL_COUNT];
			for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
			{
				unordered_access_views[clipmap_level_index] = this->m_clipmap_opacity_unordered_access_view[clipmap_level_index];
			}
			d3d_device_context->OMSetRenderTargetsAndUnorderedAccessViews(1U, render_target_views, NULL, 1U, VCT_CLIPMAP_LEVEL_COUNT, unordered_access_views, NULL);

			for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
			{
				float const zero_float = 0.0F;
				uint32_t const zero_uint = (*reinterpret_cast<uint32_t const *>(&zero_float));
				UINT values[4] = {zero_uint, zero_uint, zero_uint, zero_uint};
				d3d_device_context->ClearUnorderedAccessViewUint(unordered_access_views[clipmap_level_index], values);
			}
		}

		// Pipeline State Object
		{
			d3d_device_context->IASetInputLayout(NULL);
			d3d_device_context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
			d3d_device_context->VSSetShader(this->m_vct_light_injection_mesh_vertex_shader, NULL, 0U);
			d3d_device_context->RSSetState(this->m_vct_light_injection_rasterizer_state);
			d3d_device_context->PSSetShader(this->m_vct_light_injection_pixel_shader, NULL, 0U);
			d3d_device_context->OMSetDepthStencilState(this->m_vct_light_injection_depth_stencil_state, 0U);

			d3d_device_context->VSSetConstantBuffers(0U, 1U, &this->m_vct_light_injection_per_batch_constant_buffer);
			d3d_device_context->VSSetConstantBuffers(1U, 1U, &this->m_vct_light_injection_per_draw_constant_buffer);
			d3d_device_context->PSSetConstantBuffers(0U, 1U, &this->m_vct_light_injection_per_batch_constant_buffer);
		}

		// Update Object Constant
		{
			struct light_injection_per_draw_constant_buffer voxelization_b1;

			DirectX::XMFLOAT4X4 model_matrix;
			DirectX::XMStoreFloat4x4(&model_matrix, DirectX::XMMatrixIdentity());
			voxelization_b1.g_model_matrix = model_matrix;

			d3d_device_context->UpdateSubresource(this->m_vct_light_injection_per_draw_constant_buffer, 0U, NULL, &voxelization_b1, sizeof(struct light_injection_per_draw_constant_buffer), sizeof(struct light_injection_per_draw_constant_buffer));
		}

		// Draw Sponza
		{
			d3d_device_context->VSSetShaderResources(0U, 1U, &this->m_sponza_vertex_buffer_position_view);
			d3d_device_context->VSSetShaderResources(1U, 1U, &this->m_sponza_index_buffer_view);
			d3d_device_context->DrawInstanced(this->m_sponza_index_count, static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT), 0U, 0U);
		}
	}

	// Visualization Pass
	{
		// Update Frame Constant
		d3d_device_context->UpdateSubresource(this->m_visualization_constant_buffer_frame, 0U, NULL, &visualization_b0, sizeof(struct visualization_constant_buffer_frame), sizeof(struct visualization_constant_buffer_frame));

		// Frame Buffer
		{
			D3D11_VIEWPORT viewports[1] = {{0.0F, 0.0F, static_cast<float>(g_resolution_width), static_cast<float>(g_resolution_height), 0.0F, 1.0F}};
			d3d_device_context->RSSetViewports(1U, viewports);

			ID3D11RenderTargetView *const render_target_views[1U] = {this->m_swap_chain_frame_buffer_render_target_view};
			d3d_device_context->OMSetRenderTargets(1U, render_target_views, NULL);
		}

		// Pipeline State Object
		{
			d3d_device_context->IASetInputLayout(NULL);
			d3d_device_context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
			d3d_device_context->VSSetShader(this->m_full_screen_triangle_vertex_shader, NULL, 0U);
			d3d_device_context->RSSetState(this->m_visualization_rasterizer_state);
			d3d_device_context->PSSetShader(this->m_visualization_pixel_shader, NULL, 0U);
			d3d_device_context->OMSetDepthStencilState(this->m_visualization_depth_stencil_state, 0U);
			d3d_device_context->PSSetConstantBuffers(0U, 1U, &this->m_visualization_constant_buffer_frame);

			ID3D11ShaderResourceView *shader_resource_views[VCT_CLIPMAP_LEVEL_COUNT];
			for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
			{
				shader_resource_views[clipmap_level_index] = this->m_clipmap_opacity_shader_resource_view[clipmap_level_index];
			}
			d3d_device_context->PSSetShaderResources(0U, static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT), shader_resource_views);
		}

		// Draw Fullscreen Triangle
		{
			d3d_device_context->DrawInstanced(3U, 1U, 0U, 0U);
		}

		// Unbind
		{
			ID3D11ShaderResourceView *shader_resource_views[VCT_CLIPMAP_LEVEL_COUNT];
			for (uint32_t clipmap_level_index = 0U; clipmap_level_index < static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT); ++clipmap_level_index)
			{
				shader_resource_views[clipmap_level_index] = NULL;
			}
			d3d_device_context->PSSetShaderResources(0U, static_cast<uint32_t>(VCT_CLIPMAP_LEVEL_COUNT), shader_resource_views);
		}
	}

	// Present
	{
		HRESULT res_dxgi_swap_chain_present = dxgi_swap_chain->Present(1U, 0U);
		assert(SUCCEEDED(res_dxgi_swap_chain_present));
	}
}

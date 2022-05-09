#define WIN32_LEAN_AND_MEAN
#define NOMINMAX 1
#include <sdkddkver.h>
#include <windows.h>
#include "resolution.h"
#include "window_main.h"
#include "render_main.h"

unsigned __stdcall render_main(void* pVoid)
{
	HWND hWnd = static_cast<HWND>(pVoid);

	return 0U;
}

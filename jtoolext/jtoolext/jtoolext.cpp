#include "pch.h"
#include "Winuser.h"
#define fn_export extern "C" __declspec (dllexport)

fn_export double window_handle_set_alpha(double hwnd_double, double alpha)
{
    HWND hwnd = (HWND)(int)hwnd_double;
    SetWindowLong(hwnd, GWL_EXSTYLE, GetWindowLong(hwnd, GWL_EXSTYLE) | WS_EX_LAYERED);
    SetLayeredWindowAttributes(hwnd, RGB(255, 0, 0), alpha, LWA_ALPHA);
    return 1;
}

#include "MDIClientWnd.h"


//******************************************************************************
//
//  CMDIClientWnd::OnCommand
//
//      WM_COMMAND消息处理函数
//
//
void CMDIClientWnd::OnCommand(WPARAM wParam, LPARAM lParam)
{
}

void CMDIClientWnd::SizeParent(HWND hWndParent, RECT *pRect)
{
	Move(pRect->left, pRect->top, pRect->right - pRect->left, pRect->bottom - pRect->top, TRUE);
}

LRESULT CALLBACK CMDIClientWnd::WindowProc(
										HWND hWnd,
										UINT uMsg,
										WPARAM wParam,
										LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_DESTROY:
		break;
	case WM_SIZE:
		break;
	case WM_COMMAND:
//		OnCommand(wParam, lParam);
		break;
	}
	return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
}
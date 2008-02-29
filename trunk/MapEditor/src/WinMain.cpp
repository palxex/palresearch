////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		WinMain.cpp
//
//	说明：
//
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include "resource.h"

#include "Map.h"
#include "FrameWnd.h"
#include "StatusBar.h"
#include "Palette.h"


#include "WinMain.h"

////////////////////////////////////////////////////////////////////////////////
//
//                              全局变量
//
////////////////////////////////////////////////////////////////////////////////

// 地图数据
WORD		g_MapData[ 128 ][ 128 ][ 2 ];

// 模板数据
WORD		g_TemplateData[ 128 ][ 128 ][ 2 ];

// 图块图像
DWORD		g_dwImageCount	= 0;
HDC		g_hDCTileImage[ 512 ];// 图组
HDC		g_hDCMiniTileImage[ 512 ]; // 用于迷你地图

// 调色板
RGBQUAD		g_Palette[ 256 ];		// window的调色板结构

DWORD		g_dwTemplateCount;
DRAWTILESTRUCT	g_Template[ MAX_TEMPLATE ];

// 状态栏
CStatusBar	g_StatusBar;

////////////////////////////////////////////////////////////////////////////////
//
//
//                              函数声明
//
//
////////////////////////////////////////////////////////////////////////////////
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
BOOL	InitApplication(HINSTANCE hInstance);	// 初始化程序
BOOL	InitInstance(HINSTANCE hInstance);	// 初始化实例
void	ExitApplication(void);			// 退出程序
int	Run(void);				// 进入消息循环


////////////////////////////////////////////////////////////////////////////////
//
//
//                              函数定义
//
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
//
// 描述  :
//	Win32应用程序入口
//
// 返回值:
//	
// 参数  :
//	hInstance -
//	hPrevInstance -
//	lpCmdLine -
//	nCmdShow -
//
////////////////////////////////////////////////////////////////////////////////
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	if (!InitApplication(hInstance) || !InitInstance(hInstance))
		return 0;

	Run();
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL InitApplication(HINSTANCE hInstance)
//
// 描述  :
//	初始化应用程序，注册窗口类
//	
// 返回值:
//	
// 参数  :
//	HINSTANCE hInstance -
//
////////////////////////////////////////////////////////////////////////////////
BOOL InitApplication(HINSTANCE hInstance)
{
	// 注册公共控件类
	INITCOMMONCONTROLSEX icex;
	icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
	icex.dwICC  = ICC_BAR_CLASSES;
	InitCommonControlsEx(&icex);

	return TRUE;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL InitInstance(HINSTANCE hInstance)
//
// 描述  :
//	初始化实例，创建主窗口
//
// 返回值:
//	
// 参数  :
//	HINSTANCE hInstance -
//
////////////////////////////////////////////////////////////////////////////////
BOOL InitInstance(HINSTANCE hInstance)
{
//	m_hAccelerators = ::LoadAccelerators(m_hInstance, MAKEINTRESOURCE(IDR_ACCELERATOR));
	// 读调色板
	if (!Palette_Init(g_Palette))
	{
		return FALSE;
	}


	if (!FrameWnd_Create(hInstance))
	{
		return FALSE;
	}

	return TRUE;
}

// 退出程序
void ExitApplication(void)
{

}

//      运行程序，进入消息循环
int Run(void)
{
	MSG msg;
	while (::GetMessage(&msg, (HWND)NULL, 0, 0))
	{
/*		if (!TranslateAccelerator(
			m_pMainWnd->GetWindow(),           // handle to receiving window
			m_hAccelerators,    // handle to active accelerator table
			&msg))              // address of message data
*/		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return msg.wParam;
}
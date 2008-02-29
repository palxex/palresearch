/*******************************************************************************
                           C L I E N T W N D

	Name:       MDIClientWnd.h

    Description:
		客户区窗口类

*******************************************************************************/
#ifndef _MDICLIENTWND_
#define _MDICLIENTWND_

LRESULT CALLBACK MDIClientWndProc(
							   HWND hWnd,
							   UINT uMsg,
							   WPARAM wParam,
							   LPARAM lParam);

class CMDIClientWnd : public CWnd
{
public:
	CMDIClientWnd();
	~CMDIClientWnd();

public:
	BOOL Create(HWND hWndParent, UINT uID);
	void SizeParent(HWND hWndParent, RECT *pRect);
	LRESULT CALLBACK WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
	void OnCommand(WPARAM wParam, LPARAM lParam);

private:

public:
	static CMDIClientWnd *m_pThis;


private:
	WNDPROC m_OldWindowProc;
};

#endif
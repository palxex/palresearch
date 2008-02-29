#ifndef _WINAPP_H_
#define _WINAPP_H_

BOOL	InitApplication(HINSTANCE hInstance);	// 初始化程序
BOOL	InitInstance(void);			// 初始化实例
BOOL	ExitApplication(void);			// 退出程序
int	Run(void);				// 进入消息循环

#endif //_WINAPP_H_
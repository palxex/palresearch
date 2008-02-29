#ifndef _MENU_H_
#define _MENU_H_

BOOL Menu_Create(HWND hWndParent);

VOID Menu_Enable(UINT uID, BOOL bEnable);
VOID Menu_Check(UINT uID, BOOL bChecked);

#endif //_MENU_H_
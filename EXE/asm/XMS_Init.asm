seg030:009A ; =============== S U B R O U T I N E =======================================
seg030:009A
seg030:009A ; Attributes: bp-based frame
seg030:009A
seg030:009A ; int __stdcall __far XMS_Init(char flag, int)
seg030:009A proc            XMS_Init far            ; CODE XREF: real_entry+5A4↑P
seg030:009A
seg030:009A flag            = byte ptr  6
seg030:009A
seg030:009A                 push    bp
seg030:009B                 mov     bp, sp
seg030:009D                 push    ds
seg030:009E                 push    es
seg030:009F                 push    si
seg030:00A0                 push    di
seg030:00A1                 xor     ax, ax
seg030:00A3                 les     di, [dword ptr bp+flag]
seg030:00A6                 stosw
seg030:00A7                 mov     ax, 4300h
seg030:00AA                 int     2Fh             ; - Multiplex - XMS - INSTALLATION CHECK
seg030:00AA                                         ; Return: AL = 80h XMS driver installed
seg030:00AA                                         ; AL <> 80h no driver
seg030:00AC                 cmp     al, 80h
seg030:00AE                 jnz     short no_xms_present
seg030:00B0                 mov     ax, 0FFFFh
seg030:00B3
seg030:00B3 loc_2EAC3:
seg030:00B3                 les     di, [dword ptr bp+flag]
seg030:00B6                 stosw
seg030:00B7                 mov     ax, 4310h
seg030:00BA                 int     2Fh             ; - Multiplex - XMS - GET DRIVER ADDRESS
seg030:00BA                                         ; Return: ES:BX -> driver entry point
seg030:00BC
seg030:00BC loc_2EACC:
seg030:00BC                 mov     [word ptr cs:XMS_Driver], bx
seg030:00C1                 mov     [word ptr cs:XMS_Driver+2], es
seg030:00C6
seg030:00C6 no_xms_present:                         ; CODE XREF: XMS_Init+14↑j
seg030:00C6                 pop     di
seg030:00C7
seg030:00C7 loc_2EAD7:
seg030:00C7                 pop     si
seg030:00C8                 pop     es
seg030:00C9                 pop     ds
seg030:00CA                 pop     bp
seg030:00CB                 retf    4
seg030:00CB endp            XMS_Init

.text:1000120D ; =============== S U B R O U T I N E =======================================
.text:1000120D
.text:1000120D ; Attributes: bp-based frame
.text:1000120D
.text:1000120D sub_1000120D    proc near               ; CODE XREF: ResetMode+6↓p
.text:1000120D                                         ; PlayAvi+C↓p
.text:1000120D                 push    ebp
.text:1000120E                 mov     ebp, esp
.text:10001210                 push    ebx
.text:10001211                 push    esi
.text:10001212                 push    edi
.text:10001213                 cmp     dword_1000C040, 0
.text:1000121A                 jz      loc_1000123A
.text:10001220                 mov     eax, dword_1000C040
.text:10001225                 push    eax
.text:10001226                 mov     eax, dword_1000C040
.text:1000122B                 mov     eax, [eax]
.text:1000122D                 call    dword ptr [eax+8]
.text:10001230                 mov     dword_1000C040, 0
.text:1000123A
.text:1000123A loc_1000123A:                           ; CODE XREF: sub_1000120D+D↑j
.text:1000123A                 cmp     dword_1000C03C, 0
.text:10001241                 jz      loc_1000126D
.text:10001247                 mov     eax, h
.text:1000124C                 push    eax             ; ho
.text:1000124D                 call    ds:DeleteObject
.text:10001253                 mov     eax, dword_1000C03C
.text:10001258                 push    eax
.text:10001259                 mov     eax, dword_1000C03C
.text:1000125E                 mov     eax, [eax]
.text:10001260                 call    dword ptr [eax+8]
.text:10001263                 mov     dword_1000C03C, 0
.text:1000126D
.text:1000126D loc_1000126D:                           ; CODE XREF: sub_1000120D+34↑j
.text:1000126D                 cmp     dword_1000C038, 0
.text:10001274                 jz      loc_100012E3
.text:1000127A                 push    0
.text:1000127C                 push    1
.text:1000127E                 push    offset dword_10010A90
.text:10001283                 push    0
.text:10001285                 mov     eax, dword_1000C038
.text:1000128A                 push    eax
.text:1000128B                 mov     eax, dword_1000C038
.text:10001290                 mov     eax, [eax]
.text:10001292                 call    dword ptr [eax+64h]
.text:10001295                 push    0FA00h          ; Size
.text:1000129A                 push    0               ; Val
.text:1000129C                 mov     eax, dword_10010AB4
.text:100012A1                 push    eax             ; void *
.text:100012A2                 call    _memset
.text:100012A7                 add     esp, 0Ch
.text:100012AA                 push    0
.text:100012AC                 mov     eax, dword_1000C038
.text:100012B1                 push    eax
.text:100012B2                 mov     eax, dword_1000C038
.text:100012B7                 mov     eax, [eax]
.text:100012B9                 call    dword ptr [eax+80h]
.text:100012BF                 push    0
.text:100012C1                 call    sub_10002944
.text:100012C6                 add     esp, 4
.text:100012C9                 mov     eax, dword_1000C038
.text:100012CE                 push    eax
.text:100012CF                 mov     eax, dword_1000C038
.text:100012D4                 mov     eax, [eax]
.text:100012D6                 call    dword ptr [eax+8]
.text:100012D9                 mov     dword_1000C038, 0
.text:100012E3
.text:100012E3 loc_100012E3:                           ; CODE XREF: sub_1000120D+67↑j
.text:100012E3                 cmp     dword_1000C034, 0
.text:100012EA                 jz      loc_1000130A
.text:100012F0                 mov     eax, dword_1000C034
.text:100012F5                 push    eax
.text:100012F6                 mov     eax, dword_1000C034
.text:100012FB                 mov     eax, [eax]
.text:100012FD                 call    dword ptr [eax+8]
.text:10001300                 mov     dword_1000C034, 0
.text:1000130A
.text:1000130A loc_1000130A:                           ; CODE XREF: sub_1000120D+DD↑j
.text:1000130A                 pop     edi
.text:1000130B                 pop     esi
.text:1000130C                 pop     ebx
.text:1000130D                 leave
.text:1000130E                 retn
.text:1000130E sub_1000120D    endp
.text:1000130E

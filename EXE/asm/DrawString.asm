.text:1000262E ; Exported entry   3. DrawString
.text:1000262E
.text:1000262E ; =============== S U B R O U T I N E =======================================
.text:1000262E
.text:1000262E ; Attributes: bp-based frame
.text:1000262E
.text:1000262E ; int __stdcall DrawString(LPCSTR lpString, __int16, __int16, __int16, char, int)
.text:1000262E                 public DrawString
.text:1000262E DrawString      proc near               ; DATA XREF: .rdata:off_1000B0F8↓o
.text:1000262E
.text:1000262E var_30          = dword ptr -30h
.text:1000262E var_2C          = dword ptr -2Ch
.text:1000262E var_28          = dword ptr -28h
.text:1000262E var_24          = dword ptr -24h
.text:1000262E hdc             = dword ptr -20h
.text:1000262E var_1C          = dword ptr -1Ch
.text:1000262E var_18          = dword ptr -18h
.text:1000262E var_14          = dword ptr -14h
.text:1000262E var_10          = dword ptr -10h
.text:1000262E var_C           = dword ptr -0Ch
.text:1000262E var_8           = dword ptr -8
.text:1000262E var_4           = byte ptr -4
.text:1000262E lpString        = dword ptr  8
.text:1000262E arg_4           = word ptr  0Ch
.text:1000262E arg_8           = word ptr  10h
.text:1000262E arg_C           = word ptr  14h
.text:1000262E arg_10          = byte ptr  18h
.text:1000262E arg_14          = dword ptr  1Ch
.text:1000262E
.text:1000262E                 push    ebp
.text:1000262F                 mov     ebp, esp
.text:10002631                 sub     esp, 30h
.text:10002634                 push    ebx
.text:10002635                 push    esi
.text:10002636                 push    edi
.text:10002637                 push    0
.text:10002639                 push    1
.text:1000263B                 push    offset dword_10010A90
.text:10002640                 push    0
.text:10002642                 mov     eax, dword_1000C03C
.text:10002647                 push    eax
.text:10002648                 mov     eax, dword_1000C03C
.text:1000264D                 mov     eax, [eax]
.text:1000264F                 call    dword ptr [eax+64h]
.text:10002652                 mov     eax, dword_10010AB4
.text:10002657                 mov     [ebp+var_18], eax
.text:1000265A                 push    1900h           ; Size
.text:1000265F                 push    0FFh            ; Val
.text:10002664                 mov     eax, [ebp+var_18]
.text:10002667                 push    eax             ; void *
.text:10002668                 call    _memset
.text:1000266D                 add     esp, 0Ch
.text:10002670                 push    0
.text:10002672                 mov     eax, dword_1000C03C
.text:10002677                 push    eax
.text:10002678                 mov     eax, dword_1000C03C
.text:1000267D                 mov     eax, [eax]
.text:1000267F                 call    dword ptr [eax+80h]
.text:10002685                 lea     eax, [ebp+hdc]
.text:10002688                 push    eax
.text:10002689                 mov     eax, dword_1000C03C
.text:1000268E                 push    eax
.text:1000268F                 mov     eax, dword_1000C03C
.text:10002694                 mov     eax, [eax]
.text:10002696                 call    dword ptr [eax+44h]
.text:10002699                 mov     eax, h
.text:1000269E                 push    eax             ; h
.text:1000269F                 mov     eax, [ebp+hdc]
.text:100026A2                 push    eax             ; hdc
.text:100026A3                 call    ds:SelectObject
.text:100026A9                 push    1               ; mode
.text:100026AB                 mov     eax, [ebp+hdc]
.text:100026AE                 push    eax             ; hdc
.text:100026AF                 call    ds:SetBkMode
.text:100026B5                 movsx   eax, [ebp+arg_C]
.text:100026B9                 test    eax, eax
.text:100026BB                 jnz     loc_100026EC
.text:100026C1                 push    0               ; color
.text:100026C3                 mov     eax, [ebp+hdc]
.text:100026C6                 push    eax             ; hdc
.text:100026C7                 call    ds:SetTextColor
.text:100026CD                 mov     eax, [ebp+lpString]
.text:100026D0                 push    eax             ; Str
.text:100026D1                 call    _strlen
.text:100026D6                 add     esp, 4
.text:100026D9                 push    eax             ; c
.text:100026DA                 mov     eax, [ebp+lpString]
.text:100026DD                 push    eax             ; lpString
.text:100026DE                 push    1               ; y
.text:100026E0                 push    1               ; x
.text:100026E2                 mov     eax, [ebp+hdc]
.text:100026E5                 push    eax             ; hdc
.text:100026E6                 call    ds:TextOutA
.text:100026EC
.text:100026EC loc_100026EC:                           ; CODE XREF: DrawString+8D↑j
.text:100026EC                 cmp     dword_10011504, 0
.text:100026F3                 jz      loc_10002722
.text:100026F9                 mov     dword_10010694, 0FFFFFFh
.text:10002703                 mov     eax, offset dword_10010690
.text:10002708                 add     eax, 4
.text:1000270B                 push    eax
.text:1000270C                 push    1
.text:1000270E                 push    1
.text:10002710                 push    0
.text:10002712                 mov     eax, dword_1000C040
.text:10002717                 push    eax
.text:10002718                 mov     eax, dword_1000C040
.text:1000271D                 mov     eax, [eax]
.text:1000271F                 call    dword ptr [eax+18h]
.text:10002722
.text:10002722 loc_10002722:                           ; CODE XREF: DrawString+C5↑j
.text:10002722                 push    0FFFFFFh        ; color
.text:10002727                 mov     eax, [ebp+hdc]
.text:1000272A                 push    eax             ; hdc
.text:1000272B                 call    ds:SetTextColor
.text:10002731                 mov     eax, [ebp+lpString]
.text:10002734                 push    eax             ; Str
.text:10002735                 call    _strlen
.text:1000273A                 add     esp, 4
.text:1000273D                 push    eax             ; c
.text:1000273E                 mov     eax, [ebp+lpString]
.text:10002741                 push    eax             ; lpString
.text:10002742                 push    0               ; y
.text:10002744                 push    0               ; x
.text:10002746                 mov     eax, [ebp+hdc]
.text:10002749                 push    eax             ; hdc
.text:1000274A                 call    ds:TextOutA
.text:10002750                 cmp     dword_10011504, 0
.text:10002757                 jz      loc_10002786
.text:1000275D                 mov     dword_10010694, 0
.text:10002767                 mov     eax, offset dword_10010690
.text:1000276C                 add     eax, 4
.text:1000276F                 push    eax
.text:10002770                 push    1
.text:10002772                 push    1
.text:10002774                 push    0
.text:10002776                 mov     eax, dword_1000C040
.text:1000277B                 push    eax
.text:1000277C                 mov     eax, dword_1000C040
.text:10002781                 mov     eax, [eax]
.text:10002783                 call    dword ptr [eax+18h]
.text:10002786
.text:10002786 loc_10002786:                           ; CODE XREF: DrawString+129↑j
.text:10002786                 mov     eax, [ebp+hdc]
.text:10002789                 push    eax
.text:1000278A                 mov     eax, dword_1000C03C
.text:1000278F                 push    eax
.text:10002790                 mov     eax, dword_1000C03C
.text:10002795                 mov     eax, [eax]
.text:10002797                 call    dword ptr [eax+68h]
.text:1000279A                 push    0
.text:1000279C                 push    1
.text:1000279E                 push    offset dword_10010A90
.text:100027A3                 push    0
.text:100027A5                 mov     eax, dword_1000C03C
.text:100027AA                 push    eax
.text:100027AB                 mov     eax, dword_1000C03C
.text:100027B0                 mov     eax, [eax]
.text:100027B2                 call    dword ptr [eax+64h]
.text:100027B5                 mov     eax, dword_10010AB4
.text:100027BA                 mov     [ebp+var_18], eax
.text:100027BD                 mov     [ebp+var_1C], 0
.text:100027C4                 jmp     loc_100027CC
.text:100027C9 ; ---------------------------------------------------------------------------
.text:100027C9
.text:100027C9 loc_100027C9:                           ; CODE XREF: DrawString:loc_1000280E↓j
.text:100027C9                 inc     [ebp+var_1C]
.text:100027CC
.text:100027CC loc_100027CC:                           ; CODE XREF: DrawString+196↑j
.text:100027CC                 cmp     [ebp+var_1C], 1900h
.text:100027D3                 jge     loc_10002813
.text:100027D9                 mov     eax, [ebp+var_1C]
.text:100027DC                 mov     ecx, [ebp+var_18]
.text:100027DF                 mov     al, [eax+ecx]
.text:100027E2                 mov     [ebp+var_4], al
.text:100027E5                 xor     eax, eax
.text:100027E7                 mov     al, [ebp+var_4]
.text:100027EA                 test    eax, eax
.text:100027EC                 jz      loc_1000280E
.text:100027F2                 xor     eax, eax
.text:100027F4                 mov     al, [ebp+var_4]
.text:100027F7                 cmp     eax, 0FFh
.text:100027FC                 jz      loc_1000280E
.text:10002802                 mov     al, [ebp+arg_10]
.text:10002805                 mov     ecx, [ebp+var_1C]
.text:10002808                 mov     edx, [ebp+var_18]
.text:1000280B                 mov     [ecx+edx], al
.text:1000280E
.text:1000280E loc_1000280E:                           ; CODE XREF: DrawString+1BE↑j
.text:1000280E                                         ; DrawString+1CE↑j
.text:1000280E                 jmp     loc_100027C9
.text:10002813 ; ---------------------------------------------------------------------------
.text:10002813
.text:10002813 loc_10002813:                           ; CODE XREF: DrawString+1A5↑j
.text:10002813                 cmp     [ebp+arg_14], 0
.text:10002817                 jz      loc_10002837
.text:1000281D                 movsx   eax, [ebp+arg_8]
.text:10002821                 push    eax
.text:10002822                 movsx   eax, [ebp+arg_4]
.text:10002826                 push    eax
.text:10002827                 mov     eax, [ebp+arg_14]
.text:1000282A                 push    eax
.text:1000282B                 mov     eax, [ebp+var_18]
.text:1000282E                 push    eax
.text:1000282F                 call    sub_10004130
.text:10002834                 add     esp, 10h
.text:10002837
.text:10002837 loc_10002837:                           ; CODE XREF: DrawString+1E9↑j
.text:10002837                 push    0
.text:10002839                 mov     eax, dword_1000C03C
.text:1000283E                 push    eax
.text:1000283F                 mov     eax, dword_1000C03C
.text:10002844                 mov     eax, [eax]
.text:10002846                 call    dword ptr [eax+80h]
.text:1000284C                 cmp     [ebp+arg_14], 0
.text:10002850                 jnz     loc_100028ED
.text:10002856                 mov     [ebp+var_14], 0
.text:1000285D                 mov     [ebp+var_10], 0
.text:10002864                 mov     eax, 140h
.text:10002869                 movsx   ecx, [ebp+arg_4]
.text:1000286D                 sub     eax, ecx
.text:1000286F                 mov     [ebp+var_C], eax
.text:10002872                 movsx   eax, [ebp+arg_8]
.text:10002876                 cmp     eax, 0B4h
.text:1000287B                 jle     loc_10002894
.text:10002881                 mov     eax, 0C8h
.text:10002886                 movsx   ecx, [ebp+arg_8]
.text:1000288A                 sub     eax, ecx
.text:1000288C                 mov     [ebp+var_8], eax
.text:1000288F                 jmp     loc_1000289B
.text:10002894 ; ---------------------------------------------------------------------------
.text:10002894
.text:10002894 loc_10002894:                           ; CODE XREF: DrawString+24D↑j
.text:10002894                 mov     [ebp+var_8], 14h
.text:1000289B
.text:1000289B loc_1000289B:                           ; CODE XREF: DrawString+261↑j
.text:1000289B                 push    11h
.text:1000289D                 lea     eax, [ebp+var_14]
.text:100028A0                 push    eax
.text:100028A1                 mov     eax, dword_1000C03C
.text:100028A6                 push    eax
.text:100028A7                 movsx   eax, [ebp+arg_8]
.text:100028AB                 push    eax
.text:100028AC                 movsx   eax, [ebp+arg_4]
.text:100028B0                 push    eax
.text:100028B1                 mov     eax, dword_1000C038
.text:100028B6                 push    eax
.text:100028B7                 mov     eax, dword_1000C038
.text:100028BC                 mov     eax, [eax]
.text:100028BE                 call    dword ptr [eax+1Ch]
.text:100028C1                 movsx   eax, [ebp+arg_4]
.text:100028C5                 mov     [ebp+var_30], eax
.text:100028C8                 movsx   eax, [ebp+arg_8]
.text:100028CC                 mov     [ebp+var_2C], eax
.text:100028CF                 mov     eax, [ebp+var_C]
.text:100028D2                 add     eax, [ebp+var_30]
.text:100028D5                 mov     [ebp+var_28], eax
.text:100028D8                 mov     eax, [ebp+var_2C]
.text:100028DB                 add     eax, [ebp+var_8]
.text:100028DE                 mov     [ebp+var_24], eax
.text:100028E1                 lea     eax, [ebp+var_30]
.text:100028E4                 push    eax
.text:100028E5                 call    sub_10002944
.text:100028EA                 add     esp, 4
.text:100028ED
.text:100028ED loc_100028ED:                           ; CODE XREF: DrawString+222↑j
.text:100028ED                 pop     edi
.text:100028EE                 pop     esi
.text:100028EF                 pop     ebx
.text:100028F0                 leave
.text:100028F1                 retn    18h
.text:100028F1 DrawString      endp
.text:100028F1
.text:100028F4

seg000:EFF1 ; =============== S U B R O U T I N E =======================================
seg000:EFF1
seg000:EFF1 ; Attributes: bp-based frame
seg000:EFF1
seg000:EFF1 ; int __stdcall __far show_fbp(int, int argu_gap)
seg000:EFF1 proc            show_fbp far            ; CODE XREF: real_entry+BA3↑P
seg000:EFF1                                         ; process_scripts+3C64↓P
seg000:EFF1
seg000:EFF1 src_offset      = dword ptr -26h
seg000:EFF1 length          = dword ptr -22h
seg000:EFF1 var_1E          = word ptr -1Eh
seg000:EFF1 times           = dword ptr -1Ch
seg000:EFF1 var_18          = dword ptr -18h
seg000:EFF1 src             = byte ptr -14h
seg000:EFF1 argu_gap        = word ptr  6
seg000:EFF1 argu_fbp        = word ptr  8
seg000:EFF1
seg000:EFF1                 mov     cx, 14h
seg000:EFF4                 mov     bx, 0
seg000:EFF7                 call    far ptr B$ENRA  ; setup stack & other state info.
seg000:EFFC                 mov     si, offset DDIM_screen_buf
seg000:EFFF                 xor     bx, bx
seg000:F001                 add     bx, [si+0Ah]
seg000:F004                 mov     es, [word ptr si+2]
seg000:F007                 mov     ax, es
seg000:F009                 mov     [word ptr bp+src], ax
seg000:F00C                 mov     [word ptr bp+var_18], 0FA00h
seg000:F011                 mov     [word ptr bp+var_18+2], 0
seg000:F016                 lea     bx, [bp+src]
seg000:F019                 push    ds
seg000:F01A                 pop     es
seg000:F01B                 push    es              ; int
seg000:F01C                 push    bx              ; src
seg000:F01D                 lea     bx, [bp+var_18]
seg000:F020                 push    ds
seg000:F021                 pop     es
seg000:F022                 push    es
seg000:F023                 push    bx              ; length
seg000:F024                 mov     bx, offset XMS_handle_bak
seg000:F027                 push    ds
seg000:F028                 pop     es
seg000:F029                 push    es
seg000:F02A                 push    bx              ; dst_handle
seg000:F02B                 call    XMS_CopyBlockToXMS
seg000:F030                 mov     si, [bp+argu_fbp]
seg000:F033                 cmp     [word ptr si], 0
seg000:F036                 jge     short not_0
seg000:F038                 jmp     is_0
seg000:F03B ; ---------------------------------------------------------------------------
seg000:F03B
seg000:F03B not_0:                                  ; CODE XREF: show_fbp+45↑j
seg000:F03B                 push    [bp+argu_fbp]
seg000:F03E                 call    deyj1_fbp_subfile_to_screen_buf
seg000:F043                 jmp     next
seg000:F046 ; ---------------------------------------------------------------------------
seg000:F046
seg000:F046 is_0:                                   ; CODE XREF: show_fbp+47↑j
seg000:F046                 mov     [word ptr bp+times+2], 7D00h
seg000:F04B                 mov     si, offset DDIM_screen_buf
seg000:F04E                 xor     bx, bx
seg000:F050                 add     bx, [si+0Ah]
seg000:F053                 mov     es, [word ptr si+2]
seg000:F056                 push    es              ; int
seg000:F057                 push    bx              ; ptr
seg000:F058                 lea     bx, [bp+times+2]
seg000:F05B                 push    ds
seg000:F05C                 pop     es
seg000:F05D                 push    es
seg000:F05E                 push    bx              ; bytes
seg000:F05F                 call    clear_DDIM
seg000:F064
seg000:F064 next:                                   ; CODE XREF: show_fbp+52↑j
seg000:F064                 mov     si, [bp+argu_gap]
seg000:F067                 mov     ax, [si]
seg000:F069                 and     ax, ax
seg000:F06B                 jnz     short eliminate
seg000:F06D                 jmp     draw
seg000:F070 ; ---------------------------------------------------------------------------
seg000:F070
seg000:F070 eliminate:                              ; CODE XREF: show_fbp+7A↑j
seg000:F070                 mov     [word ptr bp+times], 5Fh
seg000:F075                 mov     [bp+var_1E], 29B0h
seg000:F07A                 push    [bp+argu_gap]
seg000:F07D                 lea     ax, [bp+times]
seg000:F080                 push    ax              ; times
seg000:F081                 lea     ax, [bp+var_1E]
seg000:F084                 push    ax              ; int
seg000:F085                 call    crossFadeOut
seg000:F08A                 jmp     restore
seg000:F08D ; ---------------------------------------------------------------------------
seg000:F08D
seg000:F08D draw:                                   ; CODE XREF: show_fbp+7C↑j
seg000:F08D                 mov     si, offset DDIM_screen_buf
seg000:F090                 xor     bx, bx
seg000:F092                 add     bx, [si+0Ah]
seg000:F095                 mov     es, [word ptr si+2]
seg000:F098                 push    es
seg000:F099                 push    bx
seg000:F09A                 call    write_to_screen
seg000:F09F
seg000:F09F restore:                                ; CODE XREF: show_fbp+99↑j
seg000:F09F                 mov     [word ptr bp+length], 0FA00h
seg000:F0A4                 mov     [word ptr bp+length+2], 0
seg000:F0A9                 mov     [word ptr bp+src_offset], 0
seg000:F0AE                 mov     [word ptr bp+src_offset+2], 0
seg000:F0B3                 mov     si, offset DDIM_screen_buf
seg000:F0B6                 xor     bx, bx
seg000:F0B8                 add     bx, [si+0Ah]
seg000:F0BB                 mov     es, [word ptr si+2]
seg000:F0BE                 push    es              ; int
seg000:F0BF                 push    bx              ; dst_offset
seg000:F0C0                 lea     bx, [bp+length]
seg000:F0C3                 push    ds
seg000:F0C4                 pop     es
seg000:F0C5                 push    es
seg000:F0C6                 push    bx              ; length
seg000:F0C7                 mov     bx, offset XMS_handle_bak
seg000:F0CA                 push    ds
seg000:F0CB                 pop     es
seg000:F0CC                 push    es
seg000:F0CD                 push    bx              ; src_handle
seg000:F0CE                 lea     bx, [bp+src_offset]
seg000:F0D1                 push    ds
seg000:F0D2                 pop     es
seg000:F0D3                 push    es
seg000:F0D4                 push    bx              ; src_offset
seg000:F0D5                 call    XMS_CopyBlockFromXMS_toAddr
seg000:F0DA                 call    B$EXSA          ; clear frame state info
seg000:F0DF                 retf    4
seg000:F0DF endp            show_fbp

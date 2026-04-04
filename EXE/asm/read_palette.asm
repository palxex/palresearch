seg001:B0BC ; =============== S U B R O U T I N E =======================================
seg001:B0BC
seg001:B0BC ; Attributes: bp-based frame
seg001:B0BC
seg001:B0BC proc            read_palette far        ; CODE XREF: real_entry+AE2↑P
seg001:B0BC                                         ; real_entry+B75↑P
seg001:B0BC                                         ; process_scripts+4780↑P
seg001:B0BC                                         ; begin_scene+14↓P
seg001:B0BC
seg001:B0BC var_18          = word ptr -18h
seg001:B0BC psdDest         = word ptr -16h
seg001:B0BC argu_palette_id = word ptr  6
seg001:B0BC
seg001:B0BC                 mov     cx, 6
seg001:B0BF                 mov     bx, 1
seg001:B0C2                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:B0C7                 push    offset BSTR_PAT_mkf ; psdSource
seg001:B0CA                 lea     ax, [bp+psdDest]
seg001:B0CD                 push    ax              ; psdDest
seg001:B0CE                 call    B$SAS1          ; String assignment
seg001:B0D3                 lea     ax, [bp+psdDest]
seg001:B0D6                 push    ax
seg001:B0D7                 push    [bp+argu_palette_id]
seg001:B0DA                 call    Read_subfile_to_glb_1
seg001:B0DF                 mov     [bp+var_18], 300h
seg001:B0E4                 mov     si, offset DDIM_palette
seg001:B0E7                 xor     bx, bx
seg001:B0E9                 add     bx, [si+0Ah]
seg001:B0EC                 mov     es, [word ptr si+2]
seg001:B0EF                 push    es
seg001:B0F0                 push    bx
seg001:B0F1                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:B0F4                 xor     bx, bx
seg001:B0F6                 add     bx, [si+0Ah]
seg001:B0F9                 mov     es, [word ptr si+2]
seg001:B0FC                 push    es
seg001:B0FD                 push    bx
seg001:B0FE                 lea     bx, [bp+var_18]
seg001:B101                 push    ds
seg001:B102                 pop     es
seg001:B103                 push    es
seg001:B104                 push    bx
seg001:B105                 call    transfer_MEM
seg001:B10A                 call    B$EXSA          ; clear frame state info
seg001:B10F                 retf    2
seg001:B10F endp            read_palette

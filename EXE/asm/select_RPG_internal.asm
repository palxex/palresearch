seg001:1BF6 ; =============== S U B R O U T I N E =======================================
seg001:1BF6
seg001:1BF6 ; Attributes: bp-based frame
seg001:1BF6
seg001:1BF6 proc            select_RPG_internal far ; CODE XREF: real_entry:next6↑P
seg001:1BF6                                         ; system_SaveRPG↑P
seg001:1BF6                                         ; system_LoadRPG↑P
seg001:1BF6
seg001:1BF6 var_50          = word ptr -50h
seg001:1BF6 var_4E          = word ptr -4Eh
seg001:1BF6 var_4C          = word ptr -4Ch
seg001:1BF6 var_4A          = word ptr -4Ah
seg001:1BF6 var_48          = word ptr -48h
seg001:1BF6 var_46          = word ptr -46h
seg001:1BF6 var_44          = word ptr -44h
seg001:1BF6 var_42          = word ptr -42h
seg001:1BF6 var_40          = word ptr -40h
seg001:1BF6 var_3E          = word ptr -3Eh
seg001:1BF6 psdDest         = word ptr -3Ch
seg001:1BF6 var_38          = word ptr -38h
seg001:1BF6 var_36          = word ptr -36h
seg001:1BF6 var_34          = word ptr -34h
seg001:1BF6 var_32          = word ptr -32h
seg001:1BF6 var_30          = word ptr -30h
seg001:1BF6 var_2E          = word ptr -2Eh
seg001:1BF6 width           = word ptr -2Ch
seg001:1BF6 dialog_x        = word ptr -2Ah
seg001:1BF6 dialog_y        = word ptr -28h
seg001:1BF6 var_26          = word ptr -26h
seg001:1BF6 var_24          = word ptr -24h
seg001:1BF6 shadow          = word ptr -22h
seg001:1BF6 rpg_counter     = word ptr -20h
seg001:1BF6 bytes           = dword ptr -1Eh
seg001:1BF6 open_method     = word ptr -1Ah
seg001:1BF6 var_16          = word ptr -16h
seg001:1BF6 var_14          = word ptr -14h
seg001:1BF6
seg001:1BF6                 mov     cx, 3Eh ; '>'
seg001:1BF9                 mov     bx, 2
seg001:1BFC                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:1C01                 mov     ax, 1
seg001:1C04                 jmp     begin_loop
seg001:1C07 ; ---------------------------------------------------------------------------
seg001:1C07                 nop
seg001:1C08
seg001:1C08 loop_open_rpgs:                         ; CODE XREF: select_RPG_internal+D5↓j
seg001:1C08                 add     ax, 30h ; '0'
seg001:1C0B                 push    ax              ; val
seg001:1C0C                 call    B$FCHR          ; CHR$ function
seg001:1C11                 push    ax              ; psd1_dst
seg001:1C12                 push    offset BSTR__RPG ; psd2
seg001:1C15                 call    B$SCT1          ; Concatenate strings
seg001:1C1A                 push    ax              ; psdSource
seg001:1C1B                 lea     ax, [bp+open_method]
seg001:1C1E                 push    ax              ; psdDest
seg001:1C1F                 call    B$SAS1          ; String assignment
seg001:1C24                 mov     [bp+var_14], 0
seg001:1C29                 lea     ax, [bp+open_method]
seg001:1C2C                 push    ax              ; open_method
seg001:1C2D                 lea     ax, [bp+var_14]
seg001:1C30                 push    ax              ; int
seg001:1C31                 call    Open_File
seg001:1C36                 mov     [bp+var_16], ax
seg001:1C39                 mov     ax, [bp+var_16]
seg001:1C3C                 mov     [ds:file_handle], ax
seg001:1C3F                 or      ax, ax
seg001:1C41                 jg      short next_
seg001:1C43                 jmp     open_failed
seg001:1C46 ; ---------------------------------------------------------------------------
seg001:1C46
seg001:1C46 next_:                                  ; CODE XREF: select_RPG_internal+4B↑j
seg001:1C46                 mov     [word ptr bp+bytes], 2
seg001:1C4B                 mov     [word ptr bp+bytes+2], 0
seg001:1C50                 mov     bx, offset file_handle
seg001:1C53                 push    ds
seg001:1C54                 pop     es
seg001:1C55                 push    es              ; int
seg001:1C56                 push    bx              ; file_handle
seg001:1C57                 mov     bx, [bp+rpg_counter]
seg001:1C5A                 dec     bx
seg001:1C5B                 shl     bx, 1
seg001:1C5D                 mov     si, offset DDIM_buf_common_short
seg001:1C60                 add     bx, [si+0Ah]
seg001:1C63                 mov     es, [word ptr si+2]
seg001:1C66                 push    es
seg001:1C67                 push    bx              ; buffer
seg001:1C68                 lea     bx, [bp+bytes]
seg001:1C6B                 push    ds
seg001:1C6C                 pop     es
seg001:1C6D                 push    es
seg001:1C6E                 push    bx              ; bytes
seg001:1C6F                 call    DOS_ReadFile_toBuf
seg001:1C74                 mov     bx, [bp+rpg_counter]
seg001:1C77                 dec     bx
seg001:1C78                 shl     bx, 1
seg001:1C7A                 mov     si, offset DDIM_buf_common_short
seg001:1C7D                 mov     dx, bx
seg001:1C7F                 add     bx, [si+0Ah]
seg001:1C82                 mov     es, [word ptr si+2]
seg001:1C85                 mov     ax, [es:bx]
seg001:1C88                 cmp     ax, [ds:max_save_number]
seg001:1C8C                 jle     short not_max
seg001:1C8E                 mov     bx, dx
seg001:1C90                 add     bx, [si+0Ah]
seg001:1C93                 mov     es, [word ptr si+2]
seg001:1C96                 mov     ax, [es:bx]
seg001:1C99                 mov     [ds:max_save_number], ax
seg001:1C9C
seg001:1C9C not_max:                                ; CODE XREF: select_RPG_internal+96↑j
seg001:1C9C                 jmp     close_
seg001:1C9F ; ---------------------------------------------------------------------------
seg001:1C9F
seg001:1C9F open_failed:                            ; CODE XREF: select_RPG_internal+4D↑j
seg001:1C9F                 mov     bx, [bp+rpg_counter]
seg001:1CA2                 dec     bx
seg001:1CA3                 shl     bx, 1
seg001:1CA5                 mov     si, offset DDIM_buf_common_short
seg001:1CA8                 add     bx, [si+0Ah]
seg001:1CAB                 mov     es, [word ptr si+2]
seg001:1CAE                 mov     [word ptr es:bx], 0
seg001:1CB3
seg001:1CB3 close_:                                 ; CODE XREF: select_RPG_internal:not_max↑j
seg001:1CB3                 mov     bx, offset file_handle
seg001:1CB6                 push    ds
seg001:1CB7                 pop     es
seg001:1CB8                 push    es              ; int
seg001:1CB9                 push    bx              ; file_handle
seg001:1CBA                 call    DOS_CloseFile
seg001:1CBF                 mov     ax, [bp+rpg_counter]
seg001:1CC2                 inc     ax
seg001:1CC3
seg001:1CC3 begin_loop:                             ; CODE XREF: select_RPG_internal+E↑j
seg001:1CC3                 mov     [bp+rpg_counter], ax
seg001:1CC6                 cmp     ax, 5
seg001:1CC9                 jg      short loop_end
seg001:1CCB                 jmp     loop_open_rpgs
seg001:1CCE ; ---------------------------------------------------------------------------
seg001:1CCE
seg001:1CCE loop_end:                               ; CODE XREF: select_RPG_internal+D3↑j
seg001:1CCE                 mov     [bp+shadow], 0FFFFh
seg001:1CD3                 mov     [bp+var_24], 0FFFEh
seg001:1CD8                 mov     [bp+var_26], 0
seg001:1CDD                 nop
seg001:1CDE
seg001:1CDE loc_1173E:                              ; CODE XREF: select_RPG_internal:loc_118DC↓j
seg001:1CDE                 cmp     [bp+var_24], 0FFFEh
seg001:1CE2                 jz      short next
seg001:1CE4                 jmp     return
seg001:1CE7 ; ---------------------------------------------------------------------------
seg001:1CE7
seg001:1CE7 next:                                   ; CODE XREF: select_RPG_internal+EC↑j
seg001:1CE7                 cmp     [bp+var_26], 0
seg001:1CEB                 jge     short next2
seg001:1CED                 mov     [bp+var_26], 0
seg001:1CF2
seg001:1CF2 next2:                                  ; CODE XREF: select_RPG_internal+F5↑j
seg001:1CF2                 cmp     [bp+var_26], 4
seg001:1CF6                 jle     short next3
seg001:1CF8                 mov     [bp+var_26], 4
seg001:1CFD
seg001:1CFD next3:                                  ; CODE XREF: select_RPG_internal+100↑j
seg001:1CFD                 mov     [bp+dialog_y], 4
seg001:1D02                 xor     ax, ax
seg001:1D04                 jmp     begin_loop_?
seg001:1D07 ; ---------------------------------------------------------------------------
seg001:1D07                 nop
seg001:1D08
seg001:1D08 loop_?:                                 ; CODE XREF: select_RPG_internal+248↓j
seg001:1D08                 mov     [bp+dialog_x], 0B4h
seg001:1D0D                 mov     [bp+width], 6
seg001:1D12                 lea     ax, [bp+dialog_x]
seg001:1D15                 push    ax              ; a_y
seg001:1D16                 lea     ax, [bp+dialog_y]
seg001:1D19                 push    ax              ; a_width
seg001:1D1A                 lea     ax, [bp+width]
seg001:1D1D                 push    ax              ; a_shadow
seg001:1D1E                 lea     ax, [bp+shadow]
seg001:1D21                 push    ax              ; int
seg001:1D22                 call    make_dialog_frame
seg001:1D27                 mov     ax, [bp+var_26]
seg001:1D2A                 cmp     ax, [bp+rpg_counter]
seg001:1D2D                 jz      short loc_11792
seg001:1D2F                 jmp     loc_117C6
seg001:1D32 ; ---------------------------------------------------------------------------
seg001:1D32
seg001:1D32 loc_11792:                              ; CODE XREF: select_RPG_internal+137↑j
seg001:1D32                 mov     [bp+var_2E], 0C5h
seg001:1D37                 mov     ax, [bp+dialog_y]
seg001:1D3A                 add     ax, 9
seg001:1D3D                 mov     [bp+var_30], ax
seg001:1D40                 mov     ax, [bp+rpg_counter]
seg001:1D43                 add     ax, 2Bh ; '+'
seg001:1D46                 mov     [bp+var_32], ax
seg001:1D49                 mov     [bp+var_34], 0FAh
seg001:1D4E                 lea     ax, [bp+var_2E]
seg001:1D51                 push    ax
seg001:1D52                 lea     ax, [bp+var_30]
seg001:1D55                 push    ax
seg001:1D56                 lea     ax, [bp+var_32]
seg001:1D59                 push    ax
seg001:1D5A                 lea     ax, [bp+var_34]
seg001:1D5D                 push    ax
seg001:1D5E                 call    show_text_shadow
seg001:1D63                 jmp     loc_11844
seg001:1D66 ; ---------------------------------------------------------------------------
seg001:1D66
seg001:1D66 loc_117C6:                              ; CODE XREF: select_RPG_internal+139↑j
seg001:1D66                 mov     [bp+var_36], 0C6h
seg001:1D6B                 mov     ax, [bp+dialog_y]
seg001:1D6E                 add     ax, 0Ah
seg001:1D71                 mov     [bp+var_38], ax
seg001:1D74                 mov     ax, 0Ah
seg001:1D77                 imul    [bp+rpg_counter]
seg001:1D7A                 add     ax, 1AEh
seg001:1D7D                 mov     bx, ax
seg001:1D7F                 mov     si, offset DDIM_word_dat
seg001:1D82                 add     bx, [si+0Ah]
seg001:1D85                 mov     es, [word ptr si+2]
seg001:1D88                 push    es
seg001:1D89                 push    bx
seg001:1D8A                 mov     bx, ax
seg001:1D8C                 mov     ax, 0Ah
seg001:1D8F                 push    ax
seg001:1D90                 mov     [bp+var_42], bx
seg001:1D93                 call    B$LDFS          ; load fixed length string
seg001:1D98                 push    ax              ; psdSource
seg001:1D99                 lea     ax, [bp+psdDest]
seg001:1D9C                 push    ax              ; psdDest
seg001:1D9D                 call    B$SAS1          ; String assignment
seg001:1DA2                 mov     [bp+var_3E], 3
seg001:1DA7                 mov     [bp+var_40], 0
seg001:1DAC                 lea     ax, [bp+var_36]
seg001:1DAF                 push    ax
seg001:1DB0                 lea     ax, [bp+var_38]
seg001:1DB3                 push    ax
seg001:1DB4                 lea     ax, [bp+psdDest]
seg001:1DB7                 push    ax
seg001:1DB8                 lea     ax, [bp+var_3E]
seg001:1DBB                 push    ax
seg001:1DBC                 lea     ax, [bp+var_40]
seg001:1DBF                 push    ax
seg001:1DC0                 call    dialog_string
seg001:1DC5                 lea     ax, [bp+psdDest]
seg001:1DC8                 push    ds              ; src_seg
seg001:1DC9                 push    ax              ; src_off
seg001:1DCA                 xor     ax, ax
seg001:1DCC                 push    ax              ; src_len
seg001:1DCD                 mov     si, offset DDIM_word_dat
seg001:1DD0                 mov     bx, [bp+var_42]
seg001:1DD3                 add     bx, [si+0Ah]
seg001:1DD6                 mov     es, [word ptr si+2]
seg001:1DD9                 push    es              ; dst_seg
seg001:1DDA                 push    bx              ; dst_off
seg001:1DDB                 mov     ax, 0Ah
seg001:1DDE                 push    ax              ; dst_len
seg001:1DDF                 call    STRINGASSIGN
seg001:1DE4
seg001:1DE4 loc_11844:                              ; CODE XREF: select_RPG_internal+16D↑j
seg001:1DE4                 mov     [bp+var_44], 10Eh
seg001:1DE9                 mov     ax, [bp+dialog_y]
seg001:1DEC                 add     ax, 0Fh
seg001:1DEF                 mov     [bp+var_46], ax
seg001:1DF2                 mov     bx, [bp+rpg_counter]
seg001:1DF5                 shl     bx, 1
seg001:1DF7                 mov     si, offset DDIM_buf_common_short
seg001:1DFA                 mov     dx, bx
seg001:1DFC                 add     bx, [si+0Ah]
seg001:1DFF                 mov     es, [word ptr si+2]
seg001:1E02                 mov     ax, [es:bx]
seg001:1E05                 mov     [bp+var_48], ax
seg001:1E08                 lea     ax, [bp+var_44]
seg001:1E0B                 push    ax
seg001:1E0C                 lea     ax, [bp+var_46]
seg001:1E0F                 push    ax
seg001:1E10                 lea     ax, [bp+var_48]
seg001:1E13                 push    ax
seg001:1E14                 mov     [bp+var_4A], dx
seg001:1E17                 call    show_white_number
seg001:1E1C                 mov     si, offset DDIM_buf_common_short
seg001:1E1F                 mov     bx, [bp+var_4A]
seg001:1E22                 add     bx, [si+0Ah]
seg001:1E25                 mov     es, [word ptr si+2]
seg001:1E28                 mov     ax, [bp+var_48]
seg001:1E2B                 mov     [es:bx], ax
seg001:1E2E                 add     [bp+dialog_y], 26h ; '&'
seg001:1E32                 mov     ax, [bp+rpg_counter]
seg001:1E35                 inc     ax
seg001:1E36
seg001:1E36 begin_loop_?:                           ; CODE XREF: select_RPG_internal+10E↑j
seg001:1E36                 mov     [bp+rpg_counter], ax
seg001:1E39                 cmp     ax, 4
seg001:1E3C                 jg      short end_loop
seg001:1E3E                 jmp     loop_?
seg001:1E41 ; ---------------------------------------------------------------------------
seg001:1E41
seg001:1E41 end_loop:                               ; CODE XREF: select_RPG_internal+246↑j
seg001:1E41                 mov     [bp+shadow], 0
seg001:1E46                 call    WaitForKey_internal
seg001:1E4B                 mov     [bp+var_4C], ax
seg001:1E4E                 mov     ax, [bp+var_4C]
seg001:1E51                 mov     [bp+var_4E], ax
seg001:1E54                 cmp     ax, 1
seg001:1E57                 jnz     short loc_118BE
seg001:1E59                 mov     [bp+var_24], 0FFFFh
seg001:1E5E
seg001:1E5E loc_118BE:                              ; CODE XREF: select_RPG_internal+261↑j
seg001:1E5E                 cmp     [bp+var_4E], 3
seg001:1E62                 jnz     short loc_118C7
seg001:1E64                 dec     [bp+var_26]
seg001:1E67
seg001:1E67 loc_118C7:                              ; CODE XREF: select_RPG_internal+26C↑j
seg001:1E67                 cmp     [bp+var_4E], 4
seg001:1E6B                 jnz     short loc_118D0
seg001:1E6D                 inc     [bp+var_26]
seg001:1E70
seg001:1E70 loc_118D0:                              ; CODE XREF: select_RPG_internal+275↑j
seg001:1E70                 cmp     [bp+var_4E], 2
seg001:1E74                 jnz     short loc_118DC
seg001:1E76                 mov     ax, [bp+var_26]
seg001:1E79                 mov     [bp+var_24], ax
seg001:1E7C
seg001:1E7C loc_118DC:                              ; CODE XREF: select_RPG_internal+27E↑j
seg001:1E7C                 jmp     loc_1173E
seg001:1E7F ; ---------------------------------------------------------------------------
seg001:1E7F                 nop
seg001:1E80
seg001:1E80 return:                                 ; CODE XREF: select_RPG_internal+EE↑j
seg001:1E80                 mov     ax, [bp+var_24]
seg001:1E83                 mov     [bp+var_50], ax
seg001:1E86                 mov     ax, [bp+var_50]
seg001:1E89                 call    B$EXSA          ; clear frame state info
seg001:1E8E                 retf    0
seg001:1E8E endp            select_RPG_internal

seg001:C05F ; =============== S U B R O U T I N E =======================================
seg001:C05F
seg001:C05F ; Attributes: bp-based frame
seg001:C05F
seg001:C05F proc            play_all_kinds_music far
seg001:C05F                                         ; CODE XREF: process_scripts+575E↑P
seg001:C05F                                         ; begin_scene+128↓P
seg001:C05F                                         ; begin_scene+62E↓P
seg001:C05F
seg001:C05F func_id         = dword ptr -1Eh
seg001:C05F argu_pointer    = dword ptr -1Ah
seg001:C05F var_16          = word ptr -16h
seg001:C05F var_14          = word ptr -14h
seg001:C05F arg_2           = word ptr  6
seg001:C05F arg_4           = word ptr  8
seg001:C05F arg_6           = word ptr  0Ah
seg001:C05F
seg001:C05F                 mov     cx, 0Ch
seg001:C062                 mov     bx, 0
seg001:C065                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:C06A                 mov     ax, [ds:mask_use_CD]
seg001:C06D                 and     ax, ax
seg001:C06F                 jnz     short use_CD
seg001:C071                 jmp     dont_use_CD
seg001:C074 ; ---------------------------------------------------------------------------
seg001:C074
seg001:C074 use_CD:                                 ; CODE XREF: play_all_kinds_music+10↑j
seg001:C074                 mov     [bp+var_14], 2
seg001:C079                 mov     [bp+var_16], 0
seg001:C07E                 lea     bx, [bp+var_14]
seg001:C081                 push    ds
seg001:C082                 pop     es
seg001:C083                 push    es
seg001:C084                 push    bx
seg001:C085                 lea     bx, [bp+var_16]
seg001:C088                 push    ds
seg001:C089                 pop     es
seg001:C08A                 push    es
seg001:C08B                 push    bx
seg001:C08C                 mov     bx, offset theurgy_effect
seg001:C08F                 push    ds
seg001:C090                 pop     es
seg001:C091                 push    es
seg001:C092                 push    bx
seg001:C093                 call    setup_RIX?
seg001:C098                 mov     [word ptr bp+argu_pointer+2], 2
seg001:C09D                 mov     [word ptr bp+argu_pointer], 0
seg001:C0A2                 lea     bx, [bp+argu_pointer+2]
seg001:C0A5                 push    ds
seg001:C0A6                 pop     es
seg001:C0A7                 push    es
seg001:C0A8                 push    bx              ; argu_offset
seg001:C0A9                 lea     bx, [bp+argu_pointer]
seg001:C0AC                 push    ds
seg001:C0AD                 pop     es
seg001:C0AE                 push    es
seg001:C0AF                 push    bx              ; argu_pointer
seg001:C0B0                 mov     bx, offset theurgy_effect
seg001:C0B3                 push    ds
seg001:C0B4                 pop     es
seg001:C0B5                 push    es
seg001:C0B6                 push    bx              ; __int32
seg001:C0B7                 call    setup_MIDI?
seg001:C0BC                 mov     ax, [ds:use_cd]
seg001:C0BF                 and     ax, ax
seg001:C0C1                 jnz     short loc_1BB26
seg001:C0C3                 jmp     jmp_return
seg001:C0C6 ; ---------------------------------------------------------------------------
seg001:C0C6
seg001:C0C6 loc_1BB26:                              ; CODE XREF: play_all_kinds_music+62↑j
seg001:C0C6                 mov     si, [bp+arg_6]
seg001:C0C9                 cmp     [word ptr si], 0
seg001:C0CC                 jge     short loc_1BB31
seg001:C0CE                 jmp     jmp_return
seg001:C0D1 ; ---------------------------------------------------------------------------
seg001:C0D1
seg001:C0D1 loc_1BB31:                              ; CODE XREF: play_all_kinds_music+6D↑j
seg001:C0D1                 mov     ax, [si]
seg001:C0D3                 mov     [ds:CDtrack_play], ax
seg001:C0D6                 or      ax, ax
seg001:C0D8                 jz      short loc_1BB3D
seg001:C0DA                 jmp     loc_1BB55
seg001:C0DD ; ---------------------------------------------------------------------------
seg001:C0DD
seg001:C0DD loc_1BB3D:                              ; CODE XREF: play_all_kinds_music+79↑j
seg001:C0DD                 mov     [word ptr bp+func_id+2], 2
seg001:C0E2                 lea     bx, [bp+func_id+2]
seg001:C0E5                 push    ds
seg001:C0E6                 pop     es
seg001:C0E7                 push    es
seg001:C0E8                 push    bx              ; func_id
seg001:C0E9                 mov     bx, offset theurgy_effect
seg001:C0EC                 push    ds
seg001:C0ED                 pop     es
seg001:C0EE                 push    es
seg001:C0EF                 push    bx              ; __int32
seg001:C0F0                 call    CDROM_functions
seg001:C0F5
seg001:C0F5 loc_1BB55:                              ; CODE XREF: play_all_kinds_music+7B↑j
seg001:C0F5                 mov     si, [bp+arg_6]
seg001:C0F8                 cmp     [word ptr si], 0
seg001:C0FB                 jg      short loc_1BB60
seg001:C0FD                 jmp     jmp_return
seg001:C100 ; ---------------------------------------------------------------------------
seg001:C100
seg001:C100 loc_1BB60:                              ; CODE XREF: play_all_kinds_music+9C↑j
seg001:C100                 mov     ax, [si]
seg001:C102                 mov     [ds:theurgy_effect], ax
seg001:C105                 mov     [word ptr bp+func_id], 1
seg001:C10A                 lea     bx, [bp+func_id]
seg001:C10D                 push    ds
seg001:C10E                 pop     es
seg001:C10F                 push    es
seg001:C110                 push    bx              ; func_id
seg001:C111                 mov     bx, offset theurgy_effect
seg001:C114                 push    ds
seg001:C115                 pop     es
seg001:C116                 push    es
seg001:C117                 push    bx              ; __int32
seg001:C118                 call    CDROM_functions
seg001:C11D
seg001:C11D jmp_return:                             ; CODE XREF: play_all_kinds_music+64↑j
seg001:C11D                                         ; play_all_kinds_music+6F↑j
seg001:C11D                                         ; play_all_kinds_music+9E↑j
seg001:C11D                 jmp     return
seg001:C120 ; ---------------------------------------------------------------------------
seg001:C120
seg001:C120 dont_use_CD:                            ; CODE XREF: play_all_kinds_music+12↑j
seg001:C120                 push    [bp+arg_4]
seg001:C123                 push    [bp+arg_2]
seg001:C126                 call    play_rix_music
seg001:C12B
seg001:C12B return:                                 ; CODE XREF: play_all_kinds_music:jmp_return↑j
seg001:C12B                 call    B$EXSA          ; clear frame state info
seg001:C130                 retf    6
seg001:C130 endp            play_all_kinds_music

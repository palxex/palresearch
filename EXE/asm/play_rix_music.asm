seg001:C136 ; =============== S U B R O U T I N E =======================================
seg001:C136
seg001:C136 ; Attributes: bp-based frame
seg001:C136
seg001:C136 proc            play_rix_music far      ; CODE XREF: real_entry+B8C↑P
seg001:C136                                         ; process_Battle+356↑P
seg001:C136                                         ; process_Battle+3AA0↑P
seg001:C136                                         ; Load_Data+142↑P
seg001:C136                                         ; process_scripts+1FF0↑P
seg001:C136                                         ; play_all_kinds_music+C7↑P
seg001:C136
seg001:C136 argu_offset     = dword ptr -22h
seg001:C136 argu_pointer    = dword ptr -1Eh
seg001:C136 var_1A          = word ptr -1Ah
seg001:C136 var_18          = word ptr -18h
seg001:C136 func_id         = dword ptr -16h
seg001:C136 arg_flag_       = dword ptr  6
seg001:C136
seg001:C136                 mov     cx, 10h
seg001:C139                 mov     bx, 0
seg001:C13C                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:C141                 mov     ax, [ds:CDtrack_play]
seg001:C144                 and     ax, ax
seg001:C146                 jnz     short loc_1BBAB
seg001:C148                 jmp     loc_1BBC9
seg001:C14B ; ---------------------------------------------------------------------------
seg001:C14B
seg001:C14B loc_1BBAB:                              ; CODE XREF: play_rix_music+10↑j
seg001:C14B                 mov     [word ptr bp+func_id+2], 2
seg001:C150                 lea     bx, [bp+func_id+2]
seg001:C153                 push    ds
seg001:C154                 pop     es
seg001:C155                 push    es
seg001:C156                 push    bx              ; func_id
seg001:C157                 lea     bx, [bp+func_id]
seg001:C15A                 push    ds
seg001:C15B                 pop     es
seg001:C15C                 push    es
seg001:C15D                 push    bx              ; __int32
seg001:C15E                 call    CDROM_functions
seg001:C163                 mov     [ds:CDtrack_play], 0
seg001:C169
seg001:C169 loc_1BBC9:                              ; CODE XREF: play_rix_music+12↑j
seg001:C169                 mov     [bp+var_18], 2
seg001:C16E                 mov     [bp+var_1A], 0
seg001:C173                 lea     bx, [bp+var_18]
seg001:C176                 push    ds
seg001:C177                 pop     es
seg001:C178                 push    es
seg001:C179                 push    bx
seg001:C17A                 lea     bx, [bp+var_1A]
seg001:C17D                 push    ds
seg001:C17E                 pop     es
seg001:C17F                 push    es
seg001:C180                 push    bx
seg001:C181                 lea     bx, [bp+func_id]
seg001:C184                 push    ds
seg001:C185                 pop     es
seg001:C186                 push    es
seg001:C187                 push    bx
seg001:C188                 call    setup_RIX?
seg001:C18D                 mov     [word ptr bp+argu_pointer+2], 2
seg001:C192                 mov     [word ptr bp+argu_pointer], 0
seg001:C197                 lea     bx, [bp+argu_pointer+2]
seg001:C19A                 push    ds
seg001:C19B                 pop     es
seg001:C19C                 push    es
seg001:C19D                 push    bx              ; argu_offset
seg001:C19E                 lea     bx, [bp+argu_pointer]
seg001:C1A1                 push    ds
seg001:C1A2                 pop     es
seg001:C1A3                 push    es
seg001:C1A4                 push    bx              ; argu_pointer
seg001:C1A5                 lea     bx, [bp+func_id]
seg001:C1A8                 push    ds
seg001:C1A9                 pop     es
seg001:C1AA                 push    es
seg001:C1AB                 push    bx              ; __int32
seg001:C1AC                 call    setup_MIDI?
seg001:C1B1                 cmp     [ds:music_mode], 0
seg001:C1B6                 jg      short loc_1BC1B
seg001:C1B8                 jmp     loc_1BC95
seg001:C1BB ; ---------------------------------------------------------------------------
seg001:C1BB
seg001:C1BB loc_1BC1B:                              ; CODE XREF: play_rix_music+80↑j
seg001:C1BB                 mov     si, [word ptr bp+arg_flag_+2]
seg001:C1BE                 cmp     [word ptr si], 0
seg001:C1C1                 jg      short loc_1BC26
seg001:C1C3                 jmp     loc_1BC95
seg001:C1C6 ; ---------------------------------------------------------------------------
seg001:C1C6
seg001:C1C6 loc_1BC26:                              ; CODE XREF: play_rix_music+8B↑j
seg001:C1C6                 push    [word ptr bp+arg_flag_+2]
seg001:C1C9                 call    rix_load?
seg001:C1CE                 push    [word ptr ds:length+2] ; op1_h
seg001:C1D2                 push    [word ptr ds:length] ; op1_l
seg001:C1D6                 push    0               ; op2_h
seg001:C1D8                 push    0               ; op2_l
seg001:C1DA                 call    B$CPI4          ; long integer compare
seg001:C1DF                 jg      short loc_1BC44
seg001:C1E1                 jmp     loc_1BC95
seg001:C1E4 ; ---------------------------------------------------------------------------
seg001:C1E4
seg001:C1E4 loc_1BC44:                              ; CODE XREF: play_rix_music+A9↑j
seg001:C1E4                 cmp     [ds:music_mode], 1
seg001:C1E9                 jz      short loc_1BC4E
seg001:C1EB                 jmp     loc_1BC76
seg001:C1EE ; ---------------------------------------------------------------------------
seg001:C1EE
seg001:C1EE loc_1BC4E:                              ; CODE XREF: play_rix_music+B3↑j
seg001:C1EE                 mov     [word ptr bp+argu_offset+2], 1
seg001:C1F3                 lea     bx, [bp+argu_offset+2]
seg001:C1F6                 push    ds
seg001:C1F7                 pop     es
seg001:C1F8                 push    es
seg001:C1F9                 push    bx
seg001:C1FA                 mov     bx, [word ptr bp+arg_flag_]
seg001:C1FD                 push    ds
seg001:C1FE                 pop     es
seg001:C1FF                 push    es
seg001:C200                 push    bx
seg001:C201                 mov     si, offset DDIM_buf_MPU401
seg001:C204                 xor     bx, bx
seg001:C206                 add     bx, [si+0Ah]
seg001:C209                 mov     es, [word ptr si+2]
seg001:C20C                 push    es
seg001:C20D                 push    bx
seg001:C20E                 call    setup_RIX?
seg001:C213                 jmp     loc_1BC95
seg001:C216 ; ---------------------------------------------------------------------------
seg001:C216
seg001:C216 loc_1BC76:                              ; CODE XREF: play_rix_music+B5↑j
seg001:C216                 mov     [word ptr bp+argu_offset], 1
seg001:C21B                 lea     bx, [bp+argu_offset]
seg001:C21E                 push    ds
seg001:C21F                 pop     es
seg001:C220                 push    es
seg001:C221                 push    bx              ; argu_offset
seg001:C222                 mov     bx, [word ptr bp+arg_flag_]
seg001:C225                 push    ds
seg001:C226                 pop     es
seg001:C227                 push    es
seg001:C228                 push    bx              ; argu_pointer
seg001:C229                 mov     bx, offset xms_handle_22k_midi
seg001:C22C                 push    ds
seg001:C22D                 pop     es
seg001:C22E                 push    es
seg001:C22F                 push    bx              ; __int32
seg001:C230                 call    setup_MIDI?
seg001:C235
seg001:C235 loc_1BC95:                              ; CODE XREF: play_rix_music+82↑j
seg001:C235                                         ; play_rix_music+8D↑j
seg001:C235                                         ; play_rix_music+AB↑j
seg001:C235                                         ; play_rix_music+DD↑j
seg001:C235                 call    B$EXSA          ; clear frame state info
seg001:C23A                 retf    4
seg001:C23A endp            play_rix_music

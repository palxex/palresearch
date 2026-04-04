seg001:807A ; =============== S U B R O U T I N E =======================================
seg001:807A
seg001:807A ; Attributes: bp-based frame
seg001:807A
seg001:807A proc            fade_in far             ; CODE XREF: real_entry+BB1↑P
seg001:807A                                         ; process_Battle+423↑P
seg001:807A                                         ; scanline_draw_normal_scene+12A↑P
seg001:807A                                         ; process_scripts+29CF↑P
seg001:807A                                         ; playRNG_impl+1C4↓P
seg001:807A
seg001:807A multiplier      = dword ptr -16h
seg001:807A delay_time      = word ptr  6
seg001:807A
seg001:807A                 mov     cx, 4
seg001:807D                 mov     bx, 0
seg001:8080                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:8085                 mov     ax, [ds:mutex_can_change_palette]
seg001:8088                 and     ax, ax
seg001:808A                 jnz     short could_
seg001:808C                 jmp     could_not
seg001:808F ; ---------------------------------------------------------------------------
seg001:808F
seg001:808F could_:                                 ; CODE XREF: fade_in+10↑j
seg001:808F                 mov     [ds:mutex_can_change_palette], 0
seg001:8095                 mov     si, [bp+delay_time]
seg001:8098                 cmp     [word ptr si], 0
seg001:809B                 jg      short begin
seg001:809D                 jmp     set
seg001:80A0 ; ---------------------------------------------------------------------------
seg001:80A0
seg001:80A0 begin:                                  ; CODE XREF: fade_in+21↑j
seg001:80A0                 mov     ax, 4
seg001:80A3                 jmp     continue?
seg001:80A6 ; ---------------------------------------------------------------------------
seg001:80A6
seg001:80A6 fade_loop:                              ; CODE XREF: fade_in+89↓j
seg001:80A6                 mov     [word ptr bp+multiplier+2], 300h
seg001:80AB                 mov     si, offset DDIM_palette
seg001:80AE                 mov     bx, 600h
seg001:80B1                 add     bx, [si+0Ah]
seg001:80B4                 mov     es, [word ptr si+2]
seg001:80B7                 push    es              ; int
seg001:80B8                 push    bx              ; dst
seg001:80B9                 mov     bx, [ds:DDIM_instrum_icon_y_offs.Dimension1.DM_iLbound]
seg001:80BD                 shl     bx, 1
seg001:80BF                 add     bx, [si+0Ah]
seg001:80C2                 mov     es, [word ptr si+2]
seg001:80C5                 push    es
seg001:80C6                 push    bx              ; src
seg001:80C7                 lea     bx, [bp+multiplier+2]
seg001:80CA                 push    ds
seg001:80CB                 pop     es
seg001:80CC                 push    es
seg001:80CD                 push    bx              ; bytes
seg001:80CE                 lea     bx, [bp+multiplier]
seg001:80D1                 push    ds
seg001:80D2                 pop     es
seg001:80D3                 push    es
seg001:80D4                 push    bx              ; multiplier
seg001:80D5                 call    block_tweak
seg001:80DA                 mov     si, offset DDIM_palette
seg001:80DD                 mov     bx, 600h
seg001:80E0                 add     bx, [si+0Ah]
seg001:80E3                 mov     es, [word ptr si+2]
seg001:80E6                 push    es
seg001:80E7                 push    bx              ; palette_ptr
seg001:80E8                 call    set_palette
seg001:80ED                 mov     bx, [bp+delay_time]
seg001:80F0                 push    ds
seg001:80F1                 pop     es
seg001:80F2                 push    es              ; int
seg001:80F3                 push    bx              ; delay_time
seg001:80F4                 call    delay_centisecond
seg001:80F9                 mov     ax, [word ptr bp+multiplier]
seg001:80FC                 inc     ax
seg001:80FD
seg001:80FD continue?:                              ; CODE XREF: fade_in+29↑j
seg001:80FD                 mov     [word ptr bp+multiplier], ax
seg001:8100                 cmp     ax, 3Fh ; '?'
seg001:8103                 jle     short fade_loop
seg001:8105
seg001:8105 set:                                    ; CODE XREF: fade_in+23↑j
seg001:8105                 mov     bx, [ds:RPG_color_begin_ptr]
seg001:8109                 shl     bx, 1
seg001:810B                 mov     si, offset DDIM_palette
seg001:810E                 add     bx, [si+0Ah]
seg001:8111                 mov     es, [word ptr si+2]
seg001:8114                 push    es
seg001:8115                 push    bx              ; palette_ptr
seg001:8116                 call    set_palette
seg001:811B
seg001:811B could_not:                              ; CODE XREF: fade_in+12↑j
seg001:811B                 call    B$EXSA          ; clear frame state info
seg001:8120                 retf    2
seg001:8120 endp            fade_in
seg001:8120

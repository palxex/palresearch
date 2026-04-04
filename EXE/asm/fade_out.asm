seg001:7F97 ; =============== S U B R O U T I N E =======================================
seg001:7F97
seg001:7F97 ; Attributes: bp-based frame
seg001:7F97
seg001:7F97 proc            fade_out far            ; CODE XREF: real_entry+B42↑P
seg001:7F97                                         ; real_entry+D51↑P
seg001:7F97                                         ; process_scripts+29B4↑P
seg001:7F97                                         ; LoadRPG_internal+3EC↓P
seg001:7F97                                         ; begin_scene+60E↓P
seg001:7F97
seg001:7F97 bytes           = dword ptr -1Ah
seg001:7F97 multiplier      = dword ptr -16h
seg001:7F97 argu_timegap    = word ptr  6
seg001:7F97
seg001:7F97                 mov     cx, 8
seg001:7F9A                 mov     bx, 0
seg001:7F9D                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:7FA2                 cmp     [ds:mutex_can_change_palette], 0
seg001:7FA7                 jz      short next
seg001:7FA9                 jmp     return
seg001:7FAC ; ---------------------------------------------------------------------------
seg001:7FAC
seg001:7FAC next:                                   ; CODE XREF: fade_out+10↑j
seg001:7FAC                 mov     [ds:mutex_can_change_palette], 1
seg001:7FB2                 mov     si, [bp+argu_timegap]
seg001:7FB5                 cmp     [word ptr si], 0
seg001:7FB8                 jg      short multi_times
seg001:7FBA                 jmp     once
seg001:7FBD ; ---------------------------------------------------------------------------
seg001:7FBD
seg001:7FBD multi_times:                            ; CODE XREF: fade_out+21↑j
seg001:7FBD                 mov     ax, 3Fh ; '?'
seg001:7FC0                 jmp     startloop
seg001:7FC3 ; ---------------------------------------------------------------------------
seg001:7FC3                 nop
seg001:7FC4
seg001:7FC4 fade_loop:                              ; CODE XREF: fade_out+8A↓j
seg001:7FC4                 mov     [word ptr bp+multiplier+2], 300h
seg001:7FC9                 mov     si, offset DDIM_palette
seg001:7FCC                 mov     bx, 600h
seg001:7FCF                 add     bx, [si+0Ah]
seg001:7FD2                 mov     es, [word ptr si+2]
seg001:7FD5                 push    es              ; int
seg001:7FD6                 push    bx              ; dst
seg001:7FD7                 mov     bx, [ds:RPG_color_begin_ptr]
seg001:7FDB                 shl     bx, 1
seg001:7FDD                 add     bx, [si+0Ah]
seg001:7FE0                 mov     es, [word ptr si+2]
seg001:7FE3                 push    es
seg001:7FE4                 push    bx              ; src
seg001:7FE5                 lea     bx, [bp+multiplier+2]
seg001:7FE8                 push    ds
seg001:7FE9                 pop     es
seg001:7FEA                 push    es
seg001:7FEB                 push    bx              ; bytes
seg001:7FEC                 lea     bx, [bp+multiplier]
seg001:7FEF                 push    ds
seg001:7FF0                 pop     es
seg001:7FF1                 push    es
seg001:7FF2                 push    bx              ; multiplier
seg001:7FF3                 call    block_tweak
seg001:7FF8                 mov     si, offset DDIM_palette
seg001:7FFB                 mov     bx, 600h
seg001:7FFE                 add     bx, [si+0Ah]
seg001:8001                 mov     es, [word ptr si+2]
seg001:8004                 push    es
seg001:8005                 push    bx              ; palette_ptr
seg001:8006                 call    set_palette
seg001:800B                 mov     bx, [bp+argu_timegap]
seg001:800E                 push    ds
seg001:800F                 pop     es
seg001:8010                 push    es              ; int
seg001:8011                 push    bx              ; delay_time
seg001:8012                 call    delay_centisecond
seg001:8017                 mov     ax, [word ptr bp+multiplier]
seg001:801A                 dec     ax
seg001:801B
seg001:801B startloop:                              ; CODE XREF: fade_out+29↑j
seg001:801B                 mov     [word ptr bp+multiplier], ax
seg001:801E                 cmp     ax, 3
seg001:8021                 jge     short fade_loop
seg001:8023
seg001:8023 once:                                   ; CODE XREF: fade_out+23↑j
seg001:8023                 mov     [word ptr bp+bytes+2], 300h
seg001:8028                 mov     [word ptr bp+bytes], 0
seg001:802D                 mov     si, offset DDIM_palette
seg001:8030                 mov     bx, 600h
seg001:8033                 add     bx, [si+0Ah]
seg001:8036                 mov     es, [word ptr si+2]
seg001:8039                 push    es              ; int
seg001:803A                 push    bx              ; dst
seg001:803B                 mov     bx, [ds:RPG_color_begin_ptr]
seg001:803F                 shl     bx, 1
seg001:8041                 add     bx, [si+0Ah]
seg001:8044                 mov     es, [word ptr si+2]
seg001:8047                 push    es
seg001:8048                 push    bx              ; src
seg001:8049                 lea     bx, [bp+bytes+2]
seg001:804C                 push    ds
seg001:804D                 pop     es
seg001:804E                 push    es
seg001:804F                 push    bx              ; bytes
seg001:8050                 lea     bx, [bp+bytes]
seg001:8053                 push    ds
seg001:8054                 pop     es
seg001:8055                 push    es
seg001:8056                 push    bx              ; multiplier
seg001:8057                 call    block_tweak
seg001:805C                 mov     si, offset DDIM_palette
seg001:805F                 mov     bx, 600h
seg001:8062                 add     bx, [si+0Ah]
seg001:8065                 mov     es, [word ptr si+2]
seg001:8068                 push    es
seg001:8069                 push    bx              ; palette_ptr
seg001:806A                 call    set_palette
seg001:806F
seg001:806F return:                                 ; CODE XREF: fade_out+12↑j
seg001:806F                 call    B$EXSA          ; clear frame state info
seg001:8074                 retf    2
seg001:8074 endp            fade_out

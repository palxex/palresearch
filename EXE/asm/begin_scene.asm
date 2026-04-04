seg001:E984 ; =============== S U B R O U T I N E =======================================
seg001:E984
seg001:E984 ; Attributes: bp-based frame
seg001:E984
seg001:E984 proc            begin_scene far         ; CODE XREF: real_entry+B47↑P
seg001:E984
seg001:E984 var_6C          = word ptr -6Ch
seg001:E984 var_6A          = word ptr -6Ah
seg001:E984 var_68          = word ptr -68h
seg001:E984 var_66          = word ptr -66h
seg001:E984 argu_pointer    = dword ptr -64h
seg001:E984 var_60          = word ptr -60h
seg001:E984 var_5E          = word ptr -5Eh
seg001:E984 var_5C          = word ptr -5Ch
seg001:E984 var_5A          = word ptr -5Ah
seg001:E984 var_58          = word ptr -58h
seg001:E984 var_56          = byte ptr -56h
seg001:E984 argu_addr       = dword ptr -54h
seg001:E984 argu_y          = dword ptr -50h
seg001:E984 multiplier      = dword ptr -4Ch
seg001:E984 delay_time      = byte ptr -48h
seg001:E984 begin_scanline  = dword ptr -46h
seg001:E984 argu_scrn_y     = dword ptr -42h
seg001:E984 argu_splice_len = dword ptr -3Eh
seg001:E984 viewport_X      = dword ptr -3Ah
seg001:E984 var_title_height= word ptr -34h
seg001:E984 curr_crazyboys_height= word ptr -32h
seg001:E984 deci_0          = word ptr -30h
seg001:E984 pixels_scrolled = word ptr -2Eh
seg001:E984 deci_16         = word ptr -2Ch
seg001:E984 deci_40         = word ptr -2Ah
seg001:E984 multi_          = word ptr -28h
seg001:E984 bytes           = word ptr -26h
seg001:E984 var_24          = word ptr -24h
seg001:E984 var_22          = word ptr -22h
seg001:E984 var_20          = word ptr -20h
seg001:E984 var_1E          = word ptr -1Eh
seg001:E984 counter         = word ptr -1Ch
seg001:E984 var_1A          = word ptr -1Ah
seg001:E984 var_18          = word ptr -18h
seg001:E984 var_16          = word ptr -16h
seg001:E984 var_14          = word ptr -14h
seg001:E984
seg001:E984                 mov     cx, 5Ah ; 'Z'
seg001:E987                 mov     bx, 0
seg001:E98A                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:E98F                 mov     [bp+var_14], 1
seg001:E994                 lea     ax, [bp+var_14]
seg001:E997                 push    ax
seg001:E998                 call    read_palette
seg001:E99D                 mov     [bp+var_16], 26h ; '&' ; 云谷鹤峰
seg001:E9A2                 lea     ax, [bp+var_16]
seg001:E9A5                 push    ax
seg001:E9A6                 call    get_fbp_two_scene_cat_to_glb_scrn
seg001:E9AB                 mov     [bp+var_18], 49h ; 'I' ; 雁
seg001:E9B0                 lea     ax, [bp+var_18]
seg001:E9B3                 push    ax
seg001:E9B4                 call    read_mgo_subfile_to_glb_1
seg001:E9B9                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:E9BC                 xor     bx, bx
seg001:E9BE                 add     bx, [si+DDIM.offset]
seg001:E9C1                 mov     es, [si+DDIM.header.segment]
seg001:E9C4                 push    es              ; int
seg001:E9C5                 push    bx              ; src_ptr
seg001:E9C6                 mov     si, offset DDIM_NPC_mgo_decoded_pack
seg001:E9C9                 xor     bx, bx
seg001:E9CB                 add     bx, [si+DDIM.offset]
seg001:E9CE                 mov     es, [si+DDIM.header.segment]
seg001:E9D1                 push    es
seg001:E9D2                 push    bx              ; dest_ptr
seg001:E9D3                 call    DeYJ_1
seg001:E9D8                 mov     [bp+var_1A], 47h ; 'G' ; 仙剑狂徒
seg001:E9DD                 lea     ax, [bp+var_1A]
seg001:E9E0                 push    ax
seg001:E9E1                 call    read_mgo_subfile_to_glb_1
seg001:E9E6                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:E9E9                 xor     bx, bx
seg001:E9EB                 add     bx, [si+DDIM.offset]
seg001:E9EE                 mov     es, [si+DDIM.header.segment]
seg001:E9F1                 push    es              ; int
seg001:E9F2                 push    bx              ; src_ptr
seg001:E9F3                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:E9F6                 xor     bx, bx
seg001:E9F8                 add     bx, [si+DDIM.offset]
seg001:E9FB                 mov     es, [si+DDIM.header.segment]
seg001:E9FE                 push    es
seg001:E9FF                 push    bx              ; dest_ptr
seg001:EA00                 call    DeYJ_1
seg001:EA05                 xor     ax, ax
seg001:EA07                 jmp     next
seg001:EA0A ; ---------------------------------------------------------------------------
seg001:EA0A
seg001:EA0A gen_random_loop:                        ; CODE XREF: begin_scene+10A↓j
seg001:EA0A                 call    B$RND0          ; RND function
seg001:EA0F                 mov     si, ax
seg001:EA11                 fld     [dword ptr si]  ; (emulator call)
seg001:EA14                 fmul    [ds:fp32_260]   ; (emulator call)
seg001:EA19                 fadd    [ds:fp32_420]   ; (emulator call)
seg001:EA1E                 mov     bx, [bp+counter]
seg001:EA21                 shl     bx, 1
seg001:EA23                 mov     si, offset DDIM_posXs ; 开场仙鹤X:rnd(260)+420
seg001:EA26                 mov     dx, bx
seg001:EA28                 add     bx, [si+DDIM.offset]
seg001:EA2B                 mov     es, [si+DDIM.header.segment]
seg001:EA2E                 fistp   [word ptr es:bx] ; (emulator call)
seg001:EA32                 wait                    ; (emulator call)
seg001:EA34                 mov     [bp+var_1E], dx
seg001:EA37                 call    B$RND0          ; RND function
seg001:EA3C                 mov     si, ax
seg001:EA3E                 fld     [dword ptr si]  ; (emulator call)
seg001:EA41                 fmul    [ds:fp32_80]    ; (emulator call)
seg001:EA46                 mov     si, offset DDIM_posYs ; 开场仙鹤Y:rnd(80)
seg001:EA49                 mov     bx, [bp+var_1E]
seg001:EA4C                 mov     dx, bx
seg001:EA4E                 add     bx, [si+DDIM.offset]
seg001:EA51                 mov     es, [si+DDIM.header.segment]
seg001:EA54                 fistp   [word ptr es:bx] ; (emulator call)
seg001:EA58                 wait                    ; (emulator call)
seg001:EA5A                 call    B$RND0          ; RND function
seg001:EA5F                 mov     si, ax
seg001:EA61                 fld     [dword ptr si]  ; (emulator call)
seg001:EA64                 fmul    [ds:fp32_8]     ; (emulator call)
seg001:EA69                 wait                    ; (emulator call)
seg001:EA6B                 call    B$INT4          ; Round to even
seg001:EA70                 mov     si, offset DDIM_buf_common_short
seg001:EA73                 mov     bx, [bp+var_1E]
seg001:EA76                 add     bx, [si+DDIM.offset]
seg001:EA79                 mov     es, [si+DDIM.header.segment]
seg001:EA7C                 fistp   [word ptr es:bx] ; (emulator call)
seg001:EA80                 wait                    ; (emulator call)
seg001:EA82                 mov     ax, [bp+counter]
seg001:EA85                 inc     ax
seg001:EA86
seg001:EA86 next:                                   ; CODE XREF: begin_scene+83↑j
seg001:EA86                 mov     [bp+counter], ax
seg001:EA89                 cmp     ax, 8
seg001:EA8C                 jg      short gen_ok
seg001:EA8E                 jmp     gen_random_loop
seg001:EA91 ; ---------------------------------------------------------------------------
seg001:EA91
seg001:EA91 gen_ok:                                 ; CODE XREF: begin_scene+108↑j
seg001:EA91                 mov     [bp+var_20], 7
seg001:EA96                 mov     [bp+var_22], 5
seg001:EA9B                 mov     [bp+var_24], 0
seg001:EAA0                 lea     ax, [bp+var_20]
seg001:EAA3                 push    ax
seg001:EAA4                 lea     ax, [bp+var_22]
seg001:EAA7                 push    ax
seg001:EAA8                 lea     ax, [bp+var_24]
seg001:EAAB                 push    ax
seg001:EAAC                 call    play_all_kinds_music
seg001:EAB1                 mov     [bp+bytes], 2D0h
seg001:EAB6                 mov     [bp+multi_], 0
seg001:EABB                 mov     si, offset DDIM_palette
seg001:EABE                 mov     bx, 600h
seg001:EAC1                 add     bx, [si+DDIM.offset]
seg001:EAC4                 mov     es, [si+DDIM.header.segment]
seg001:EAC7                 push    es              ; int
seg001:EAC8                 push    bx              ; dst
seg001:EAC9                 xor     bx, bx
seg001:EACB                 add     bx, [si+DDIM.offset]
seg001:EACE                 mov     es, [si+DDIM.header.segment]
seg001:EAD1                 push    es
seg001:EAD2                 push    bx              ; src
seg001:EAD3                 lea     bx, [bp+bytes]
seg001:EAD6                 push    ds
seg001:EAD7                 pop     es
seg001:EAD8                 push    es
seg001:EAD9                 push    bx              ; bytes
seg001:EADA                 lea     bx, [bp+multi_]
seg001:EADD                 push    ds
seg001:EADE                 pop     es
seg001:EADF                 push    es
seg001:EAE0                 push    bx              ; multiplier
seg001:EAE1                 call    block_tweak     ; 调色板先黑到底
seg001:EAE6                 mov     si, offset DDIM_palette
seg001:EAE9                 mov     bx, 600h
seg001:EAEC                 add     bx, [si+DDIM.offset]
seg001:EAEF                 mov     es, [si+DDIM.header.segment]
seg001:EAF2                 push    es
seg001:EAF3                 push    bx              ; palette_ptr
seg001:EAF4                 call    set_palette
seg001:EAF9                 mov     [bp+deci_40], 40
seg001:EAFE                 mov     [bp+deci_16], 16
seg001:EB03                 mov     ax, [ds:constant_200d]
seg001:EB06                 mov     [bp+pixels_scrolled], ax
seg001:EB09                 mov     [bp+deci_0], 0
seg001:EB0E                 mov     [bp+curr_crazyboys_height], 8
seg001:EB13                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:EB16                 xor     bx, bx
seg001:EB18                 add     bx, [si+DDIM.offset]
seg001:EB1B                 mov     es, [si+DDIM.header.segment]
seg001:EB1E                 mov     ax, [es:bx]
seg001:EB21                 shl     ax, 1
seg001:EB23                 add     ax, 2
seg001:EB26                 mov     bx, ax
seg001:EB28                 add     bx, [si+DDIM.offset]
seg001:EB2B                 mov     es, [si+DDIM.header.segment]
seg001:EB2E                 mov     ax, [es:bx]
seg001:EB31                 mov     [bp+var_title_height], ax
seg001:EB34
seg001:EB34 end_case:                               ; CODE XREF: begin_scene+491↓j
seg001:EB34                 cmp     [bp+pixels_scrolled], -300
seg001:EB39                 jg      short draw
seg001:EB3B                 jmp     last_line?
seg001:EB3E ; ---------------------------------------------------------------------------
seg001:EB3E
seg001:EB3E draw:                                   ; CODE XREF: begin_scene+1B5↑j
seg001:EB3E                 mov     bx, offset key_pressed
seg001:EB41                 push    ds
seg001:EB42                 pop     es
seg001:EB43                 push    es
seg001:EB44                 push    bx
seg001:EB45                 mov     si, offset DDIM_keybuf
seg001:EB48                 xor     bx, bx
seg001:EB4A                 add     bx, [si+DDIM.offset]
seg001:EB4D                 mov     es, [si+DDIM.header.segment]
seg001:EB50                 push    es
seg001:EB51                 push    bx
seg001:EB52                 call    Parse_key
seg001:EB57                 cmp     [ds:key_pressed], 2
seg001:EB5C                 jnz     short not_confirm
seg001:EB5E                 mov     [bp+pixels_scrolled], -999
seg001:EB63                 mov     [word ptr bp-36h], 0FFFFh
seg001:EB68
seg001:EB68 not_confirm:                            ; CODE XREF: begin_scene+1D8↑j
seg001:EB68                 cmp     [bp+pixels_scrolled], 0
seg001:EB6C                 jle     short confirm?
seg001:EB6E                 mov     si, offset DDIM_screen_buf
seg001:EB71                 xor     bx, bx
seg001:EB73                 add     bx, [si+DDIM.offset]
seg001:EB76                 mov     es, [si+DDIM.header.segment]
seg001:EB79                 mov     ax, es
seg001:EB7B                 mov     bx, ax
seg001:EB7D                 mov     ax, 20
seg001:EB80                 imul    [bp+pixels_scrolled]
seg001:EB83                 add     bx, ax
seg001:EB85                 mov     [word ptr bp+viewport_X+2], bx
seg001:EB88
seg001:EB88 confirm?:                               ; CODE XREF: begin_scene+1E8↑j
seg001:EB88                 mov     [word ptr bp+viewport_X], 0
seg001:EB8D                 mov     [word ptr bp+argu_splice_len+2], 0
seg001:EB92                 mov     bx, offset scanline_bottom_boundary_2
seg001:EB95                 push    ds
seg001:EB96                 pop     es
seg001:EB97                 push    es
seg001:EB98                 push    bx              ; boundary
seg001:EB99                 lea     bx, [bp+viewport_X]
seg001:EB9C                 push    ds
seg001:EB9D                 pop     es
seg001:EB9E                 push    es
seg001:EB9F                 push    bx              ; viewport_X
seg001:EBA0                 lea     bx, [bp+argu_splice_len+2]
seg001:EBA3                 push    ds
seg001:EBA4                 pop     es
seg001:EBA5                 push    es
seg001:EBA6                 push    bx              ; viewport_Y
seg001:EBA7                 mov     bx, offset constant_200d
seg001:EBAA                 push    ds
seg001:EBAB                 pop     es
seg001:EBAC                 push    es
seg001:EBAD                 push    bx              ; c200d
seg001:EBAE                 mov     bx, offset decimal_320
seg001:EBB1                 push    ds
seg001:EBB2                 pop     es
seg001:EBB3                 push    es
seg001:EBB4                 push    bx              ; width
seg001:EBB5                 mov     bx, offset constant_200d
seg001:EBB8                 push    ds
seg001:EBB9                 pop     es
seg001:EBBA                 push    es
seg001:EBBB                 push    bx              ; height
seg001:EBBC                 lea     bx, [bp+viewport_X+2]
seg001:EBBF                 push    ds
seg001:EBC0                 pop     es
seg001:EBC1                 push    es
seg001:EBC2                 push    bx              ; DDIM_scrn
seg001:EBC3                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:EBC6                 xor     bx, bx
seg001:EBC8                 add     bx, [si+DDIM.offset]
seg001:EBCB                 mov     es, [si+DDIM.header.segment]
seg001:EBCE                 push    es
seg001:EBCF                 push    bx              ; DDIM_redraw
seg001:EBD0                 call    split_scrn_to_scanlines_in_redraw
seg001:EBD5                 xor     ax, ax
seg001:EBD7                 jmp     draw_goose_loop
seg001:EBDA ; ---------------------------------------------------------------------------
seg001:EBDA
seg001:EBDA calc_goose_loop:                        ; CODE XREF: begin_scene+359↓j
seg001:EBDA                 shl     ax, 1
seg001:EBDC                 mov     bx, ax
seg001:EBDE                 mov     si, offset DDIM_posXs
seg001:EBE1                 add     bx, [si+DDIM.offset]
seg001:EBE4                 mov     es, [si+DDIM.header.segment]
seg001:EBE7                 mov     cx, [es:bx]
seg001:EBEA                 sub     cx, 2
seg001:EBED                 mov     bx, ax
seg001:EBEF                 add     bx, [si+DDIM.offset]
seg001:EBF2                 mov     es, [si+DDIM.header.segment]
seg001:EBF5                 mov     [es:bx], cx
seg001:EBF8                 cmp     [bp+pixels_scrolled], 0
seg001:EBFC                 jle     short next__
seg001:EBFE                 mov     bx, ax
seg001:EC00                 mov     si, offset DDIM_posYs
seg001:EC03                 add     bx, [si+DDIM.offset]
seg001:EC06                 mov     es, [si+DDIM.header.segment]
seg001:EC09                 mov     cx, [es:bx]
seg001:EC0C                 mov     dx, [bp+pixels_scrolled]
seg001:EC0F                 and     dx, 1
seg001:EC12                 add     cx, dx
seg001:EC14                 mov     bx, ax
seg001:EC16                 add     bx, [si+DDIM.offset]
seg001:EC19                 mov     es, [si+DDIM.header.segment]
seg001:EC1C                 mov     [es:bx], cx
seg001:EC1F
seg001:EC1F next__:                                 ; CODE XREF: begin_scene+278↑j
seg001:EC1F                 mov     bx, [bp+counter]
seg001:EC22                 shl     bx, 1
seg001:EC24                 mov     si, offset DDIM_buf_common_short
seg001:EC27                 mov     dx, bx
seg001:EC29                 add     bx, [si+DDIM.offset]
seg001:EC2C                 mov     es, [si+DDIM.header.segment]
seg001:EC2F                 mov     ax, [es:bx]
seg001:EC32                 mov     cx, [bp+deci_0]
seg001:EC35                 and     cx, 1
seg001:EC38                 add     cx, ax
seg001:EC3A                 and     cx, 7
seg001:EC3D                 mov     bx, dx
seg001:EC3F                 add     bx, [si+DDIM.offset]
seg001:EC42                 mov     es, [si+DDIM.header.segment]
seg001:EC45                 mov     [es:bx], cx
seg001:EC48                 mov     bx, dx
seg001:EC4A                 mov     si, offset DDIM_posXs
seg001:EC4D                 add     bx, [si+DDIM.offset]
seg001:EC50                 mov     es, [si+DDIM.header.segment]
seg001:EC53                 cmp     [word ptr es:bx], 0FFD8h
seg001:EC57                 jg      short big_enough?
seg001:EC59                 jmp     continue
seg001:EC5C ; ---------------------------------------------------------------------------
seg001:EC5C
seg001:EC5C big_enough?:                            ; CODE XREF: begin_scene+2D3↑j
seg001:EC5C                 mov     [word ptr bp+argu_splice_len], 0
seg001:EC61                 mov     bx, [bp+counter]
seg001:EC64                 shl     bx, 1
seg001:EC66                 mov     si, offset DDIM_posXs
seg001:EC69                 mov     dx, bx
seg001:EC6B                 add     bx, [si+DDIM.offset]
seg001:EC6E                 mov     es, [si+DDIM.header.segment]
seg001:EC71                 push    es
seg001:EC72                 push    bx              ; argu_scrn_x
seg001:EC73                 mov     bx, dx
seg001:EC75                 mov     si, offset DDIM_posYs
seg001:EC78                 add     bx, [si+DDIM.offset]
seg001:EC7B                 mov     es, [si+DDIM.header.segment]
seg001:EC7E                 push    es
seg001:EC7F                 push    bx              ; argu_scrn_y
seg001:EC80                 lea     bx, [bp+argu_splice_len]
seg001:EC83                 push    ds
seg001:EC84                 pop     es
seg001:EC85                 push    es
seg001:EC86                 push    bx              ; argu_splice_len
seg001:EC87                 mov     bx, offset constant_200d
seg001:EC8A                 push    ds
seg001:EC8B                 pop     es
seg001:EC8C                 push    es
seg001:EC8D                 push    bx              ; argu_eff_y
seg001:EC8E                 mov     bx, offset scanline_bottom_boundary_2
seg001:EC91                 push    ds
seg001:EC92                 pop     es
seg001:EC93                 push    es
seg001:EC94                 push    bx              ; argu_return
seg001:EC95                 mov     bx, dx
seg001:EC97                 mov     si, offset DDIM_buf_common_short
seg001:EC9A                 add     bx, [si+DDIM.offset]
seg001:EC9D                 mov     es, [si+DDIM.header.segment]
seg001:ECA0                 mov     ax, [es:bx]
seg001:ECA3                 shl     ax, 1
seg001:ECA5                 mov     bx, ax
seg001:ECA7                 mov     si, offset DDIM_NPC_mgo_decoded_pack
seg001:ECAA                 add     bx, [si+DDIM.offset]
seg001:ECAD                 mov     es, [si+DDIM.header.segment]
seg001:ECB0                 mov     ax, [es:bx]
seg001:ECB3                 shl     ax, 1
seg001:ECB5                 mov     bx, ax
seg001:ECB7                 add     bx, [si+DDIM.offset]
seg001:ECBA                 mov     es, [si+DDIM.header.segment]
seg001:ECBD                 push    es
seg001:ECBE                 push    bx              ; argu_RLEsrc
seg001:ECBF                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:ECC2                 xor     bx, bx
seg001:ECC4                 add     bx, [si+DDIM.offset]
seg001:ECC7                 mov     es, [si+DDIM.header.segment]
seg001:ECCA                 push    es
seg001:ECCB                 push    bx              ; argu_DDIM
seg001:ECCC                 call    DeRLE_scanline
seg001:ECD1
seg001:ECD1 continue:                               ; CODE XREF: begin_scene+2D5↑j
seg001:ECD1                 mov     ax, [bp+counter]
seg001:ECD4                 inc     ax
seg001:ECD5
seg001:ECD5 draw_goose_loop:                        ; CODE XREF: begin_scene+253↑j
seg001:ECD5                 mov     [bp+counter], ax
seg001:ECD8                 cmp     ax, 8
seg001:ECDB                 jg      short loc_1E740
seg001:ECDD                 jmp     calc_goose_loop
seg001:ECE0 ; ---------------------------------------------------------------------------
seg001:ECE0
seg001:ECE0 loc_1E740:                              ; CODE XREF: begin_scene+357↑j
seg001:ECE0                 inc     [bp+curr_crazyboys_height]
seg001:ECE3                 mov     ax, [bp+var_title_height]
seg001:ECE6                 cmp     ax, [bp+curr_crazyboys_height]
seg001:ECE9                 jge     short loc_1E74E
seg001:ECEB                 mov     [bp+curr_crazyboys_height], ax
seg001:ECEE
seg001:ECEE loc_1E74E:                              ; CODE XREF: begin_scene+365↑j
seg001:ECEE                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:ECF1                 xor     bx, bx
seg001:ECF3                 add     bx, [si+DDIM.offset]
seg001:ECF6                 mov     es, [si+DDIM.header.segment]
seg001:ECF9                 mov     ax, [es:bx]
seg001:ECFC                 shl     ax, 1
seg001:ECFE                 add     ax, 2
seg001:ED01                 mov     bx, ax
seg001:ED03                 add     bx, [si+DDIM.offset]
seg001:ED06                 mov     es, [si+DDIM.header.segment]
seg001:ED09                 mov     ax, [bp+curr_crazyboys_height]
seg001:ED0C                 mov     [es:bx], ax
seg001:ED0F                 mov     [word ptr bp+argu_scrn_y+2], 0FEh
seg001:ED14                 mov     [word ptr bp+argu_scrn_y], 0Ah
seg001:ED19                 mov     [word ptr bp+begin_scanline+2], 0
seg001:ED1E                 lea     bx, [bp+argu_scrn_y+2]
seg001:ED21                 push    ds
seg001:ED22                 pop     es
seg001:ED23                 push    es
seg001:ED24                 push    bx              ; argu_scrn_x
seg001:ED25                 lea     bx, [bp+argu_scrn_y]
seg001:ED28                 push    ds
seg001:ED29                 pop     es
seg001:ED2A                 push    es
seg001:ED2B                 push    bx              ; argu_scrn_y
seg001:ED2C                 lea     bx, [bp+begin_scanline+2]
seg001:ED2F                 push    ds
seg001:ED30                 pop     es
seg001:ED31                 push    es
seg001:ED32                 push    bx              ; argu_splice_len
seg001:ED33                 mov     bx, offset constant_200d
seg001:ED36                 push    ds
seg001:ED37                 pop     es
seg001:ED38                 push    es
seg001:ED39                 push    bx              ; argu_eff_y
seg001:ED3A                 mov     bx, offset scanline_bottom_boundary_2
seg001:ED3D                 push    ds
seg001:ED3E                 pop     es
seg001:ED3F                 push    es
seg001:ED40                 push    bx              ; argu_return
seg001:ED41                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:ED44                 xor     bx, bx
seg001:ED46                 add     bx, [si+DDIM.offset]
seg001:ED49                 mov     es, [si+DDIM.header.segment]
seg001:ED4C                 mov     ax, [es:bx]
seg001:ED4F                 shl     ax, 1
seg001:ED51                 mov     bx, ax
seg001:ED53                 add     bx, [si+DDIM.offset]
seg001:ED56                 mov     es, [si+DDIM.header.segment]
seg001:ED59                 push    es
seg001:ED5A                 push    bx              ; argu_RLEsrc
seg001:ED5B                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:ED5E                 xor     bx, bx
seg001:ED60                 add     bx, [si+DDIM.offset]
seg001:ED63                 mov     es, [si+DDIM.header.segment]
seg001:ED66                 push    es
seg001:ED67                 push    bx              ; argu_DDIM
seg001:ED68                 call    DeRLE_scanline
seg001:ED6D                 mov     [word ptr bp+begin_scanline], 0
seg001:ED72                 lea     bx, [bp+begin_scanline]
seg001:ED75                 push    ds
seg001:ED76                 pop     es
seg001:ED77                 push    es
seg001:ED78                 push    bx              ; begin_scanline
seg001:ED79                 mov     bx, offset constant_200d
seg001:ED7C                 push    ds
seg001:ED7D                 pop     es
seg001:ED7E                 push    es
seg001:ED7F                 push    bx              ; end_scanline
seg001:ED80                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:ED83                 xor     bx, bx
seg001:ED85                 add     bx, [si+DDIM.offset]
seg001:ED88                 mov     es, [si+DDIM.header.segment]
seg001:ED8B                 push    es
seg001:ED8C                 push    bx              ; REDRAW
seg001:ED8D                 call    draw_scanline_to_scrn
seg001:ED92                 mov     [word ptr bp+delay_time], 0Ah
seg001:ED97                 lea     bx, [bp+delay_time]
seg001:ED9A                 push    ds
seg001:ED9B                 pop     es
seg001:ED9C                 push    es              ; int
seg001:ED9D                 push    bx              ; delay_time
seg001:ED9E                 call    delay_centisecond
seg001:EDA3                 mov     cx, 10
seg001:EDA6                 mov     ax, [bp+deci_40]
seg001:EDA9                 cwd
seg001:EDAA                 idiv    cx
seg001:EDAC                 mov     [word ptr bp+multiplier+2], ax
seg001:EDAF                 mov     ax, [bp+deci_16]
seg001:EDB2                 add     [bp+deci_40], ax
seg001:EDB5                 dec     [bp+deci_16]
seg001:EDB8                 cmp     [bp+deci_16], 3
seg001:EDBC                 jge     short loc_1E823
seg001:EDBE                 mov     [bp+deci_16], 3
seg001:EDC3
seg001:EDC3 loc_1E823:                              ; CODE XREF: begin_scene+438↑j
seg001:EDC3                 inc     [bp+deci_0]
seg001:EDC6                 cmp     [word ptr bp+multiplier+2], 40h ; '@'
seg001:EDCA                 jle     short tweak_palette
seg001:EDCC                 jmp     gogo
seg001:EDCF ; ---------------------------------------------------------------------------
seg001:EDCF
seg001:EDCF tweak_palette:                          ; CODE XREF: begin_scene+446↑j
seg001:EDCF                 mov     [word ptr bp+multiplier], 2D0h
seg001:EDD4                 mov     si, offset DDIM_palette
seg001:EDD7                 mov     bx, 600h
seg001:EDDA                 add     bx, [si+DDIM.offset]
seg001:EDDD                 mov     es, [si+DDIM.header.segment]
seg001:EDE0                 push    es              ; int
seg001:EDE1                 push    bx              ; dst
seg001:EDE2                 xor     bx, bx
seg001:EDE4                 add     bx, [si+DDIM.offset]
seg001:EDE7                 mov     es, [si+DDIM.header.segment]
seg001:EDEA                 push    es
seg001:EDEB                 push    bx              ; src
seg001:EDEC                 lea     bx, [bp+multiplier]
seg001:EDEF                 push    ds
seg001:EDF0                 pop     es
seg001:EDF1                 push    es
seg001:EDF2                 push    bx              ; bytes
seg001:EDF3                 lea     bx, [bp+multiplier+2]
seg001:EDF6                 push    ds
seg001:EDF7                 pop     es
seg001:EDF8                 push    es
seg001:EDF9                 push    bx              ; multiplier
seg001:EDFA                 call    block_tweak
seg001:EDFF                 mov     si, offset DDIM_palette
seg001:EE02                 mov     bx, 600h
seg001:EE05                 add     bx, [si+DDIM.offset]
seg001:EE08                 mov     es, [si+DDIM.header.segment]
seg001:EE0B                 push    es
seg001:EE0C                 push    bx              ; palette_ptr
seg001:EE0D                 call    set_palette
seg001:EE12
seg001:EE12 gogo:                                   ; CODE XREF: begin_scene+448↑j
seg001:EE12                 dec     [bp+pixels_scrolled]
seg001:EE15                 jmp     end_case
seg001:EE18 ; ---------------------------------------------------------------------------
seg001:EE18
seg001:EE18 last_line?:                             ; CODE XREF: begin_scene+1B7↑j
seg001:EE18                 mov     ax, [bp-36h]
seg001:EE1B                 and     ax, ax
seg001:EE1D                 jnz     short end_draw
seg001:EE1F                 jmp     wait_and_exit
seg001:EE22 ; ---------------------------------------------------------------------------
seg001:EE22
seg001:EE22 end_draw:                               ; CODE XREF: begin_scene+499↑j
seg001:EE22                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:EE25                 xor     bx, bx
seg001:EE27                 add     bx, [si+DDIM.offset]
seg001:EE2A                 mov     es, [si+DDIM.header.segment]
seg001:EE2D                 mov     ax, [es:bx]
seg001:EE30                 shl     ax, 1
seg001:EE32                 add     ax, 2
seg001:EE35                 mov     bx, ax
seg001:EE37                 add     bx, [si+DDIM.offset]
seg001:EE3A                 mov     es, [si+DDIM.header.segment]
seg001:EE3D                 mov     ax, [bp+var_title_height]
seg001:EE40                 mov     [es:bx], ax
seg001:EE43                 mov     si, offset DDIM_screen_buf
seg001:EE46                 xor     bx, bx
seg001:EE48                 add     bx, [si+DDIM.offset]
seg001:EE4B                 mov     es, [si+DDIM.header.segment]
seg001:EE4E                 push    es
seg001:EE4F                 push    bx
seg001:EE50                 call    read_from_screen
seg001:EE55                 mov     [word ptr bp+argu_y+2], 0FEh
seg001:EE5A                 mov     [word ptr bp+argu_y], 0Ah
seg001:EE5F                 mov     si, offset DDIM_screen_buf
seg001:EE62                 xor     bx, bx
seg001:EE64                 add     bx, [si+DDIM.offset]
seg001:EE67                 mov     es, [si+DDIM.header.segment]
seg001:EE6A                 mov     ax, es
seg001:EE6C                 mov     [word ptr bp+argu_addr+2], ax
seg001:EE6F                 lea     bx, [bp+argu_y+2]
seg001:EE72                 push    ds
seg001:EE73                 pop     es
seg001:EE74                 push    es
seg001:EE75                 push    bx              ; argu_x
seg001:EE76                 lea     bx, [bp+argu_y]
seg001:EE79                 push    ds
seg001:EE7A                 pop     es
seg001:EE7B                 push    es
seg001:EE7C                 push    bx              ; argu_y
seg001:EE7D                 mov     si, offset DDIM_role_mgo_decoded_pack_or_battle_ico ; MKF,随需构建
seg001:EE80                 xor     bx, bx
seg001:EE82                 add     bx, [si+DDIM.offset]
seg001:EE85                 mov     es, [si+DDIM.header.segment]
seg001:EE88                 mov     ax, [es:bx]
seg001:EE8B                 shl     ax, 1
seg001:EE8D                 mov     bx, ax
seg001:EE8F                 add     bx, [si+DDIM.offset]
seg001:EE92                 mov     es, [si+DDIM.header.segment]
seg001:EE95                 push    es
seg001:EE96                 push    bx              ; argu_rle
seg001:EE97                 lea     bx, [bp+argu_addr+2]
seg001:EE9A                 push    ds
seg001:EE9B                 pop     es
seg001:EE9C                 push    es
seg001:EE9D                 push    bx              ; argu_addr
seg001:EE9E                 call    DeRLE
seg001:EEA3                 mov     si, offset DDIM_screen_buf
seg001:EEA6                 xor     bx, bx
seg001:EEA8                 add     bx, [si+DDIM.offset]
seg001:EEAB                 mov     es, [si+DDIM.header.segment]
seg001:EEAE                 push    es
seg001:EEAF                 push    bx
seg001:EEB0                 call    write_to_screen
seg001:EEB5                 mov     ax, [word ptr bp+multiplier+2]
seg001:EEB8                 jmp     loc_1E974
seg001:EEBB ; ---------------------------------------------------------------------------
seg001:EEBB                 nop
seg001:EEBC
seg001:EEBC loc_1E91C:                              ; CODE XREF: begin_scene+596↓j
seg001:EEBC                 mov     [word ptr bp+argu_addr], 2D0h
seg001:EEC1                 mov     si, offset DDIM_palette
seg001:EEC4                 mov     bx, 600h
seg001:EEC7                 add     bx, [si+DDIM.offset]
seg001:EECA                 mov     es, [si+DDIM.header.segment]
seg001:EECD                 push    es              ; int
seg001:EECE                 push    bx              ; dst
seg001:EECF                 xor     bx, bx
seg001:EED1                 add     bx, [si+DDIM.offset]
seg001:EED4                 mov     es, [si+DDIM.header.segment]
seg001:EED7                 push    es
seg001:EED8                 push    bx              ; src
seg001:EED9                 lea     bx, [bp+argu_addr]
seg001:EEDC                 push    ds
seg001:EEDD                 pop     es
seg001:EEDE                 push    es
seg001:EEDF                 push    bx              ; bytes
seg001:EEE0                 lea     bx, [bp+counter]
seg001:EEE3                 push    ds
seg001:EEE4                 pop     es
seg001:EEE5                 push    es
seg001:EEE6                 push    bx              ; multiplier
seg001:EEE7                 call    block_tweak
seg001:EEEC                 mov     si, offset DDIM_palette
seg001:EEEF                 mov     bx, 600h
seg001:EEF2                 add     bx, [si+DDIM.offset]
seg001:EEF5                 mov     es, [si+DDIM.header.segment]
seg001:EEF8                 push    es
seg001:EEF9                 push    bx              ; palette_ptr
seg001:EEFA                 call    set_palette
seg001:EEFF                 mov     [word ptr bp+var_56], 1
seg001:EF04                 lea     bx, [bp+var_56]
seg001:EF07                 push    ds
seg001:EF08                 pop     es
seg001:EF09                 push    es              ; int
seg001:EF0A                 push    bx              ; delay_time
seg001:EF0B                 call    delay_centisecond
seg001:EF10                 mov     ax, [bp+counter]
seg001:EF13                 inc     ax
seg001:EF14
seg001:EF14 loc_1E974:                              ; CODE XREF: begin_scene+534↑j
seg001:EF14                 mov     [bp+counter], ax
seg001:EF17                 cmp     ax, 40h ; '@'
seg001:EF1A                 jle     short loc_1E91C
seg001:EF1C                 mov     [bp+var_58], 90
seg001:EF21                 lea     ax, [bp+var_58]
seg001:EF24                 push    ax
seg001:EF25                 call    wait_key
seg001:EF2A                 jmp     loc_1E99B
seg001:EF2D ; ---------------------------------------------------------------------------
seg001:EF2D
seg001:EF2D wait_and_exit:                          ; CODE XREF: begin_scene+49B↑j
seg001:EF2D                 call    WaitForKey_internal
seg001:EF32                 mov     [bp+var_5A], ax
seg001:EF35                 mov     ax, [bp+var_5A]
seg001:EF38                 mov     [bp+var_5C], ax
seg001:EF3B
seg001:EF3B loc_1E99B:                              ; CODE XREF: begin_scene+5A6↑j
seg001:EF3B                 mov     [bp+var_5E], 2
seg001:EF40                 mov     [bp+var_60], 1
seg001:EF45                 lea     bx, [bp+var_5E]
seg001:EF48                 push    ds
seg001:EF49                 pop     es
seg001:EF4A                 push    es
seg001:EF4B                 push    bx
seg001:EF4C                 lea     bx, [bp+var_60]
seg001:EF4F                 push    ds
seg001:EF50                 pop     es
seg001:EF51                 push    es
seg001:EF52                 push    bx
seg001:EF53                 lea     bx, [bp+counter]
seg001:EF56                 push    ds
seg001:EF57                 pop     es
seg001:EF58                 push    es
seg001:EF59                 push    bx
seg001:EF5A                 call    setup_RIX?
seg001:EF5F                 mov     [word ptr bp+argu_pointer+2], 2
seg001:EF64                 mov     [word ptr bp+argu_pointer], 1
seg001:EF69                 lea     bx, [bp+argu_pointer+2]
seg001:EF6C                 push    ds
seg001:EF6D                 pop     es
seg001:EF6E                 push    es
seg001:EF6F                 push    bx              ; argu_offset
seg001:EF70                 lea     bx, [bp+argu_pointer]
seg001:EF73                 push    ds
seg001:EF74                 pop     es
seg001:EF75                 push    es
seg001:EF76                 push    bx              ; argu_pointer
seg001:EF77                 lea     bx, [bp+counter]
seg001:EF7A                 push    ds
seg001:EF7B                 pop     es
seg001:EF7C                 push    es
seg001:EF7D                 push    bx              ; __int32
seg001:EF7E                 call    setup_MIDI?
seg001:EF83                 mov     [ds:mutex_can_change_palette], 0
seg001:EF89                 mov     [bp+var_66], 2
seg001:EF8E                 lea     ax, [bp+var_66]
seg001:EF91                 push    ax
seg001:EF92                 call    fade_out
seg001:EF97                 mov     [bp+var_68], 0
seg001:EF9C                 mov     [bp+var_6A], 0
seg001:EFA1                 mov     [bp+var_6C], 0
seg001:EFA6                 lea     ax, [bp+var_68]
seg001:EFA9                 push    ax
seg001:EFAA                 lea     ax, [bp+var_6A]
seg001:EFAD                 push    ax
seg001:EFAE                 lea     ax, [bp+var_6C]
seg001:EFB1                 push    ax
seg001:EFB2                 call    play_all_kinds_music
seg001:EFB7                 call    B$EXSA          ; clear frame state info
seg001:EFBC                 retf    0
seg001:EFBC endp            begin_scene

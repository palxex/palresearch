seg029:001E ; =============== S U B R O U T I N E =======================================
seg029:001E
seg029:001E ; Attributes: bp-based frame
seg029:001E
seg029:001E proc            setup_RIX? far          ; CODE XREF: real_entry+656↑P
seg029:001E                                         ; system_MusicOption+4F↑P
seg029:001E                                         ; process_scripts+3CC9↑P
seg029:001E                                         ; process_scripts+3CF2↑P
seg029:001E                                         ; release_resources_exit+CD↑P
seg029:001E                                         ; play_all_kinds_music+34↑P
seg029:001E                                         ; play_rix_music+52↑P
seg029:001E                                         ; play_rix_music+D8↑P
seg029:001E                                         ; begin_scene+5D6↑P
seg029:001E
seg029:001E arg_0           = dword ptr  6
seg029:001E arg_4           = dword ptr  0Ah
seg029:001E arg_8           = dword ptr  0Eh
seg029:001E
seg029:001E                 push    bp
seg029:001F
seg029:001F loc_2D44F:
seg029:001F                 mov     bp, sp
seg029:0021
seg029:0021 loc_2D451:
seg029:0021                 push    ds
seg029:0022
seg029:0022 loc_2D452:
seg029:0022                 push    es
seg029:0023                 push    si
seg029:0024
seg029:0024 loc_2D454:
seg029:0024                 push    di
seg029:0025
seg029:0025 loc_2D455:
seg029:0025                 cld
seg029:0026
seg029:0026 loc_2D456:
seg029:0026                 lds     si, [bp+arg_0]
seg029:0029                 push    ds
seg029:002A                 push    si
seg029:002B
seg029:002B loc_2D45B:
seg029:002B                 lds     si, [bp+arg_4]
seg029:002E                 push    [word ptr si]
seg029:0030
seg029:0030 loc_2D460:
seg029:0030                 lds     si, [bp+arg_8]
seg029:0033                 push    [word ptr si]
seg029:0035                 push    cs
seg029:0036
seg029:0036 loc_2D466:
seg029:0036                 call    near ptr ad_func_?
seg029:0039
seg029:0039 loc_2D469:
seg029:0039                 cmp     [word ptr si], 0FFh
seg029:003D                 jnz     short loc_2D473
seg029:003F                 les     di, [bp+arg_0]
seg029:0042                 stosw
seg029:0043
seg029:0043 loc_2D473:                              ; CODE XREF: setup_RIX?+1F↑j
seg029:0043                 add     sp, 8
seg029:0046
seg029:0046 loc_2D476:
seg029:0046                 pop     di
seg029:0047                 pop     si
seg029:0048                 pop     es
seg029:0049                 pop     ds
seg029:004A
seg029:004A loc_2D47A:
seg029:004A                 pop     bp
seg029:004B                 retf    0Ch
seg029:004B endp            setup_RIX?

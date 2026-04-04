seg003:0CE8 ; =============== S U B R O U T I N E =======================================
seg003:0CE8
seg003:0CE8 ; Attributes: bp-based frame
seg003:0CE8
seg003:0CE8 ; int __stdcall __far setup_MIDI_(__int32, __int32 argu_pointer, __int32 argu_offset)
seg003:0CE8 proc            setup_MIDI? far         ; CODE XREF: real_entry+714↑P
seg003:0CE8                                         ; real_entry+73A↑P
seg003:0CE8                                         ; real_entry+760↑P
seg003:0CE8                                         ; system_MusicOption+79↑P
seg003:0CE8                                         ; system_MusicOption+A3↑P
seg003:0CE8                                         ; process_scripts+3D29↑P
seg003:0CE8                                         ; process_scripts+3D52↑P
seg003:0CE8                                         ; release_resources_exit+85↑P
seg003:0CE8                                         ; release_resources_exit+A9↑P
seg003:0CE8                                         ; play_all_kinds_music+58↑P
seg003:0CE8                                         ; play_rix_music+76↑P
seg003:0CE8                                         ; play_rix_music+FA↑P
seg003:0CE8                                         ; begin_scene+5FA↑P
seg003:0CE8
seg003:0CE8 arg_0           = dword ptr  6
seg003:0CE8 argu_pointer    = dword ptr  0Ah
seg003:0CE8 argu_offset     = dword ptr  0Eh
seg003:0CE8
seg003:0CE8                 push    bp
seg003:0CE9                 mov     bp, sp
seg003:0CEB                 push    es
seg003:0CEC                 push    si
seg003:0CED                 push    di
seg003:0CEE                 les     si, [bp+argu_offset]
seg003:0CF1                 assume es:nothing
seg003:0CF1                 mov     ax, [es:si]
seg003:0CF4                 cmp     ax, 0FFh
seg003:0CF7                 jnz     short is_100?
seg003:0CF9                 call    sub_24F01
seg003:0CFC                 cmp     ax, 0FFFFh
seg003:0CFF                 jnz     short loc_24843
seg003:0D01                 xor     ax, ax
seg003:0D03
seg003:0D03 loc_24843:                              ; CODE XREF: setup_MIDI?+17↑j
seg003:0D03                 les     di, [bp+arg_0]
seg003:0D06                 stosw
seg003:0D07                 jmp     ret
seg003:0D0A ; ---------------------------------------------------------------------------
seg003:0D0A
seg003:0D0A is_100?:                                ; CODE XREF: setup_MIDI?+F↑j
seg003:0D0A                 cmp     ax, 100h
seg003:0D0D                 jnz     short other
seg003:0D0F                 les     ax, [bp+argu_pointer]
seg003:0D12                 mov     [word ptr ptr_MPU401_func+2], es
seg003:0D16                 mov     bx, es
seg003:0D18                 mov     ax, 0
seg003:0D1B                 call    midi_timer_dispatch
seg003:0D20                 les     bx, [bp+arg_0]
seg003:0D23                 mov     dx, [es:bx]
seg003:0D26                 mov     ax, 0
seg003:0D29                 call    [ptr_MPU401_func]
seg003:0D2D                 mov     ax, 9
seg003:0D30                 call    midi_timer_dispatch
seg003:0D35                 jmp     ret
seg003:0D38 ; ---------------------------------------------------------------------------
seg003:0D38
seg003:0D38 other:                                  ; CODE XREF: setup_MIDI?+25↑j
seg003:0D38                 mov     dx, [word ptr ptr_MPU401_func+2]
seg003:0D3C                 or      dx, dx
seg003:0D3E                 jnz     short loc_24883
seg003:0D40                 jmp     ret
seg003:0D43 ; ---------------------------------------------------------------------------
seg003:0D43
seg003:0D43 loc_24883:                              ; CODE XREF: setup_MIDI?+56↑j
seg003:0D43                 mov     bx, ax
seg003:0D45                 add     bx, bx
seg003:0D47                 jmp     [midi_dispatch+bx]
seg003:0D4B
seg003:0D4B loc_2488B:                              ; DATA XREF: seg034:midi_dispatch↓o
seg003:0D4B                 mov     ax, 0Ah
seg003:0D4E                 call    midi_timer_dispatch
seg003:0D53                 jmp     ret
seg003:0D56 ; ---------------------------------------------------------------------------
seg003:0D56
seg003:0D56 loc_24896:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0D56                                         ; DATA XREF: seg034:18AE↓o
seg003:0D56                 mov     ax, 1
seg003:0D59                 mov     bx, 0
seg003:0D5C                 les     si, [bp+argu_pointer]
seg003:0D5F                 mov     cl, [es:si]
seg003:0D62                 les     si, [bp+arg_0]
seg003:0D65                 mov     si, [es:si]
seg003:0D68                 mov     ch, 1
seg003:0D6A
seg003:0D6A loc_248AA:
seg003:0D6A                 call    [ptr_MPU401_func]
seg003:0D6E                 jmp     short ret
seg003:0D70 ; ---------------------------------------------------------------------------
seg003:0D70
seg003:0D70 loc_248B0:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0D70                                         ; DATA XREF: seg034:18B0↓o
seg003:0D70                 mov     ax, 2
seg003:0D73                 mov     bx, 0
seg003:0D76                 les     si, [bp+argu_pointer]
seg003:0D79                 mov     cx, [es:si]
seg003:0D7C                 call    [ptr_MPU401_func]
seg003:0D80                 jmp     short ret
seg003:0D82 ; ---------------------------------------------------------------------------
seg003:0D82
seg003:0D82 loc_248C2:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0D82                                         ; DATA XREF: seg034:18B2↓o
seg003:0D82                 mov     ax, 3
seg003:0D85                 mov     bx, 0
seg003:0D88                 les     si, [bp+argu_pointer]
seg003:0D8B                 mov     dx, [es:si]
seg003:0D8E                 call    [ptr_MPU401_func]
seg003:0D92                 jmp     short ret
seg003:0D94 ; ---------------------------------------------------------------------------
seg003:0D94
seg003:0D94 loc_248D4:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0D94                                         ; DATA XREF: seg034:18B4↓o
seg003:0D94                 mov     ax, 4
seg003:0D97                 mov     bx, 0
seg003:0D9A                 les     si, [bp+argu_pointer]
seg003:0D9D                 mov     dx, [es:si]
seg003:0DA0                 call    [ptr_MPU401_func]
seg003:0DA4                 jmp     short ret
seg003:0DA6 ; ---------------------------------------------------------------------------
seg003:0DA6
seg003:0DA6 loc_248E6:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0DA6                                         ; DATA XREF: seg034:18B6↓o
seg003:0DA6                 mov     ax, 5
seg003:0DA9                 mov     bx, 0
seg003:0DAC                 les     si, [bp+argu_pointer]
seg003:0DAF                 mov     cx, [es:si]
seg003:0DB2                 call    [ptr_MPU401_func]
seg003:0DB6                 jmp     short ret
seg003:0DB8 ; ---------------------------------------------------------------------------
seg003:0DB8
seg003:0DB8 loc_248F8:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0DB8                                         ; DATA XREF: seg034:18B8↓o
seg003:0DB8                 mov     ax, 6
seg003:0DBB                 mov     bx, 0
seg003:0DBE                 les     si, [bp+argu_pointer]
seg003:0DC1                 mov     dx, [es:si]
seg003:0DC4                 call    [ptr_MPU401_func]
seg003:0DC8                 jmp     short ret
seg003:0DCA ; ---------------------------------------------------------------------------
seg003:0DCA
seg003:0DCA loc_2490A:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0DCA                                         ; DATA XREF: seg034:18BA↓o
seg003:0DCA                 jmp     short ret
seg003:0DCC ; ---------------------------------------------------------------------------
seg003:0DCC
seg003:0DCC loc_2490C:                              ; CODE XREF: setup_MIDI?+5F↑j
seg003:0DCC                                         ; DATA XREF: seg034:18BC↓o
seg003:0DCC                 mov     ax, 8
seg003:0DCF                 mov     bx, 0
seg003:0DD2                 call    [ptr_MPU401_func]
seg003:0DD6                 les     di, [bp+arg_0]
seg003:0DD9                 stosw
seg003:0DDA                 jmp     short $+2
seg003:0DDC
seg003:0DDC ret:                                    ; CODE XREF: setup_MIDI?+1F↑j
seg003:0DDC                                         ; setup_MIDI?+4D↑j
seg003:0DDC                                         ; setup_MIDI?+58↑j
seg003:0DDC                                         ; setup_MIDI?+6B↑j
seg003:0DDC                                         ; setup_MIDI?+86↑j
seg003:0DDC                                         ; setup_MIDI?+98↑j
seg003:0DDC                                         ; setup_MIDI?+AA↑j
seg003:0DDC                                         ; setup_MIDI?+BC↑j
seg003:0DDC                                         ; setup_MIDI?+CE↑j
seg003:0DDC                                         ; setup_MIDI?+E0↑j
seg003:0DDC                                         ; setup_MIDI?:loc_2490A↑j
seg003:0DDC                 pop     di
seg003:0DDD                 pop     si
seg003:0DDE                 pop     es
seg003:0DDF                 pop     bp
seg003:0DE0
seg003:0DE0 return:
seg003:0DE0                 retf    0Ch
seg003:0DE0 endp            setup_MIDI?

seg003:0DE4 ; =============== S U B R O U T I N E =======================================
seg003:0DE4
seg003:0DE4 ; Attributes: bp-based frame
seg003:0DE4
seg003:0DE4 ; int __stdcall __far CDROM_functions(__int32, __int32 func_id)
seg003:0DE4 proc            CDROM_functions far     ; CODE XREF: real_entry+47D↑P
seg003:0DE4                                         ; real_entry+4AA↑P
seg003:0DE4                                         ; process_scripts+3CA1↑P
seg003:0DE4                                         ; play_all_kinds_music+91↑P
seg003:0DE4                                         ; play_all_kinds_music+B9↑P
seg003:0DE4                                         ; play_rix_music+28↑P
seg003:0DE4
seg003:0DE4 arg_0           = dword ptr  6
seg003:0DE4 func_id         = dword ptr  0Ah
seg003:0DE4
seg003:0DE4                 push    bp
seg003:0DE5                 mov     bp, sp
seg003:0DE7                 push    ds
seg003:0DE8                 push    es
seg003:0DE9                 push    si
seg003:0DEA                 push    di
seg003:0DEB                 sub     ax, ax
seg003:0DED                 les     si, [bp+func_id]
seg003:0DF0                 mov     bx, [es:si]
seg003:0DF3                 cmp     bx, 8
seg003:0DF6                 jge     short func_end
seg003:0DF8                 or      bx, bx
seg003:0DFA                 jz      short func0_obtain_info
seg003:0DFC                 mov     al, [CDriver_letter]
seg003:0DFF                 cmp     al, 0
seg003:0E01                 jl      short func_end
seg003:0E03                 shl     bx, 1
seg003:0E05                 jmp     [chk_CD_dispatch+bx]
seg003:0E09
seg003:0E09 func0_obtain_info:                      ; CODE XREF: CDROM_functions+16↑j
seg003:0E09                                         ; DATA XREF: seg034:chk_CD_dispatch↓o
seg003:0E09                 call    CDROM_info_check
seg003:0E0C                 jmp     short func_end
seg003:0E0E ; ---------------------------------------------------------------------------
seg003:0E0E
seg003:0E0E func_play:                              ; CODE XREF: CDROM_functions+21↑j
seg003:0E0E                                         ; DATA XREF: seg034:1AA1↓o
seg003:0E0E                 les     si, [bp+arg_0]
seg003:0E11                 mov     al, [es:si]
seg003:0E14                 sub     edx, edx
seg003:0E17                 mov     ecx, 0FFFFFFFEh
seg003:0E1D
seg003:0E1D loc_2495D:
seg003:0E1D                 call    CD_play
seg003:0E20                 jmp     short func_end
seg003:0E22 ; ---------------------------------------------------------------------------
seg003:0E22
seg003:0E22 func2_stop:                             ; CODE XREF: CDROM_functions+21↑j
seg003:0E22                                         ; DATA XREF: seg034:1AA3↓o
seg003:0E22                 call    CD_stopplay
seg003:0E25                 jmp     short func_end
seg003:0E27 ; ---------------------------------------------------------------------------
seg003:0E27
seg003:0E27 func3_stoppause:                        ; CODE XREF: CDROM_functions+21↑j
seg003:0E27                                         ; DATA XREF: seg034:1AA5↓o
seg003:0E27                 call    CD_stoppause
seg003:0E2A                 jmp     short func_end
seg003:0E2C ; ---------------------------------------------------------------------------
seg003:0E2C
seg003:0E2C func4_resume:                           ; CODE XREF: CDROM_functions+21↑j
seg003:0E2C                                         ; DATA XREF: seg034:1AA7↓o
seg003:0E2C                 call    CD_resume
seg003:0E2F                 jmp     short func_end
seg003:0E31 ; ---------------------------------------------------------------------------
seg003:0E31
seg003:0E31 func5_GetTracks:                        ; CODE XREF: CDROM_functions+21↑j
seg003:0E31                                         ; DATA XREF: seg034:1AA9↓o
seg003:0E31                 mov     al, [end_track]
seg003:0E34                 jmp     short func_end
seg003:0E36 ; ---------------------------------------------------------------------------
seg003:0E36
seg003:0E36 func6_null:                             ; CODE XREF: CDROM_functions+21↑j
seg003:0E36                                         ; DATA XREF: seg034:1AAB↓o
seg003:0E36                 jmp     short func_end
seg003:0E38 ; ---------------------------------------------------------------------------
seg003:0E38
seg003:0E38 func7_load_unload:                      ; CODE XREF: CDROM_functions+21↑j
seg003:0E38                                         ; DATA XREF: seg034:1AAD↓o
seg003:0E38                 call    LoadUnloadMedia
seg003:0E3B                 jmp     short $+2
seg003:0E3D
seg003:0E3D func_end:                               ; CODE XREF: CDROM_functions+12↑j
seg003:0E3D                                         ; CDROM_functions+1D↑j
seg003:0E3D                                         ; CDROM_functions+28↑j
seg003:0E3D                                         ; CDROM_functions+3C↑j
seg003:0E3D                                         ; CDROM_functions+41↑j
seg003:0E3D                                         ; CDROM_functions+46↑j
seg003:0E3D                                         ; CDROM_functions+4B↑j
seg003:0E3D                                         ; CDROM_functions+50↑j
seg003:0E3D                                         ; CDROM_functions:func6_null↑j
seg003:0E3D                 les     di, [bp+arg_0]
seg003:0E40                 cbw
seg003:0E41                 stosw
seg003:0E42                 pop     di
seg003:0E43                 pop     si
seg003:0E44                 pop     es
seg003:0E45                 pop     ds
seg003:0E46                 assume ds:nothing
seg003:0E46                 pop     bp
seg003:0E47
seg003:0E47 locret_24987:
seg003:0E47                 retf    8
seg003:0E47 endp            CDROM_functions

seg003:0E4A ; =============== S U B R O U T I N E =======================================
seg003:0E4A
seg003:0E4A
seg003:0E4A proc            CDROM_SendDriverRequest near ; CODE XREF: playCD+2C↓p
seg003:0E4A                                         ; CD_is_pause?+46↓p
seg003:0E4A                                         ; GetSubChannelData+56↓p
seg003:0E4A                                         ; stop_CD+18↓p
seg003:0E4A                                         ; CD_resume+18↓p
seg003:0E4A                                         ; Get_track_attr+50↓p
seg003:0E4A                                         ; Check_CD_info+3F↓p
seg003:0E4A                                         ; LoadUnloadMedia-1A↓p
seg003:0E4A                 mov     ax, 1510h
seg003:0E4D                 movzx   cx, [ds:CDriver_letter]
seg003:0E52                 push    ds
seg003:0E53                 pop     es
seg003:0E54                 int     2Fh             ;  Multiplex - CDROM - 2.10 - SEND DEVICE DRIVER REQUEST
seg003:0E54                                         ; CX = CD-ROM drive letter (0 = A, 1 = B, etc)
seg003:0E54                                         ; ES:BX -> CD-ROM device driver request header
seg003:0E56
seg003:0E56 locret_24996:
seg003:0E56                 retn
seg003:0E56 endp            CDROM_SendDriverRequest
seg003:0E56
seg003:0E57
seg003:0E57 ; =============== S U B R O U T I N E =======================================
seg003:0E57
seg003:0E57
seg003:0E57 proc            playCD near             ; CODE XREF: CD_play:loc_24D01↓p
seg003:0E57                 sub     ebx, 96h
seg003:0E5E                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], ebx
seg003:0E63
seg003:0E63 loc_249A3:
seg003:0E63                 mov     [dword ptr ds:CDROM_request_header.status+0Fh], ecx
seg003:0E68                 mov     al, 0Dh
seg003:0E6A                 mov     [ds:CDROM_request_header.len_drh], al
seg003:0E6D                 mov     al, [ds:CDriver_letter]
seg003:0E70
seg003:0E70 loc_249B0:
seg003:0E70                 mov     [ds:CDROM_request_header.subUnit], al
seg003:0E73                 mov     al, 84h
seg003:0E75                 mov     [ds:CDROM_request_header.funcNr], al
seg003:0E78                 xor     ax, ax
seg003:0E7A                 mov     [ds:CDROM_request_header.status], ax
seg003:0E7D                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:0E80                 mov     bx, offset CDROM_request_header
seg003:0E83                 call    CDROM_SendDriverRequest
seg003:0E86                 mov     ax, [ds:CDROM_request_header.status]
seg003:0E89                 mov     bl, ah
seg003:0E8B                 and     bl, 81h
seg003:0E8E                 xor     bl, 80h
seg003:0E91                 jz      short locret_249E1
seg003:0E93                 mov     cl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0E93                                         ;            错误           正播  正常
seg003:0E97                 or      cl, 2
seg003:0E9A                 and     cl, 0FBh
seg003:0E9D                 mov     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0E9D                                         ;            错误           正播  正常
seg003:0EA1
seg003:0EA1 locret_249E1:                           ; CODE XREF: playCD+3A↑j
seg003:0EA1                 retn
seg003:0EA1 endp            playCD
seg003:0EA1
seg003:0EA2
seg003:0EA2 ; =============== S U B R O U T I N E =======================================
seg003:0EA2
seg003:0EA2
seg003:0EA2 proc            CD_stopplay near        ; CODE XREF: CDROM_functions:func2_stop↑p
seg003:0EA2                                         ; LoadUnloadMedia↓p
seg003:0EA2                 call    is_pause?
seg003:0EA5                 and     al, 4
seg003:0EA7                 jnz     short loc_249EC
seg003:0EA9                 call    stop_CD
seg003:0EAC
seg003:0EAC loc_249EC:                              ; CODE XREF: CD_stopplay+5↑j
seg003:0EAC                 call    stop_CD
seg003:0EAF                 mov     cl, ah
seg003:0EB1                 and     cl, 81h
seg003:0EB4                 xor     cl, 80h
seg003:0EB7                 jnz     short ret
seg003:0EB9                 mov     cl, 0F9h
seg003:0EBB                 and     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0EBB                                         ;            错误           正播  正常
seg003:0EBF
seg003:0EBF ret:                                    ; CODE XREF: CD_stopplay+15↑j
seg003:0EBF                 retn
seg003:0EBF endp            CD_stopplay
seg003:0EBF
seg003:0EC0
seg003:0EC0 ; =============== S U B R O U T I N E =======================================
seg003:0EC0
seg003:0EC0
seg003:0EC0 proc            is_pause? near          ; CODE XREF: CD_stopplay↑p
seg003:0EC0                                         ; CD_stoppause↓p
seg003:0EC0                                         ; CD_resume+24↓p CD_play+5↓p
seg003:0EC0                 call    CD_is_pause?
seg003:0EC3                 mov     al, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0EC3                                         ;            错误           正播  正常
seg003:0EC6                 retn
seg003:0EC6 endp            is_pause?
seg003:0EC6
seg003:0EC7
seg003:0EC7 ; =============== S U B R O U T I N E =======================================
seg003:0EC7
seg003:0EC7
seg003:0EC7 proc            CD_is_pause? near       ; CODE XREF: is_pause?↑p
seg003:0EC7                 call    GetSubChannelData
seg003:0ECA                 mov     al, 0Dh
seg003:0ECC                 mov     [ds:CDROM_request_header.len_drh], al
seg003:0ECF                 mov     al, [ds:CDriver_letter]
seg003:0ED2                 mov     [ds:CDROM_request_header.subUnit], al
seg003:0ED5                 mov     al, 3
seg003:0ED7                 mov     [ds:CDROM_request_header.funcNr], al
seg003:0EDA                 xor     eax, eax
seg003:0EDD                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:0EE0                 mov     [ds:CDROM_request_header.status], ax
seg003:0EE3                 mov     [ds:not_used], ax
seg003:0EE6                 mov     [ds:not_used_too], eax
seg003:0EEA                 mov     [word ptr ds:AudioStatus.pause], ax
seg003:0EED                 mov     [dword ptr ds:AudioStatus.resStart.second], eax
seg003:0EF1                 mov     [dword ptr ds:AudioStatus.resEnd.second], eax
seg003:0EF5                 push    ds
seg003:0EF6                 push    offset ioctl_fct_GetAudioStatus
seg003:0EF9                 pop     eax
seg003:0EFB                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], eax
seg003:0EFF                 mov     ax, 0Bh
seg003:0F02                 mov     [ds:CDROM_request_header.status+0Fh], ax
seg003:0F05                 mov     al, 0Fh
seg003:0F07                 mov     [ds:ioctl_fct_GetAudioStatus], al
seg003:0F0A                 mov     bx, offset CDROM_request_header
seg003:0F0D                 call    CDROM_SendDriverRequest
seg003:0F10                 xor     al, al
seg003:0F12                 mov     bl, 2
seg003:0F14                 test    [byte ptr ds:CDROM_request_header.status+1], bl
seg003:0F18                 jz      short loc_24A5C
seg003:0F1A                 mov     al, 2
seg003:0F1C
seg003:0F1C loc_24A5C:                              ; CODE XREF: CD_is_pause?+51↑j
seg003:0F1C                 shr     bl, 1
seg003:0F1E                 test    [ds:AudioStatus.pause], bl
seg003:0F22                 jz      short loc_24A66
seg003:0F24                 or      al, 4
seg003:0F26
seg003:0F26 loc_24A66:                              ; CODE XREF: CD_is_pause?+5B↑j
seg003:0F26                 mov     dl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0F26                                         ;            错误           正播  正常
seg003:0F2A                 and     dl, 1
seg003:0F2D                 jz      short loc_24A97
seg003:0F2F                 or      al, al
seg003:0F31                 jnz     short loc_24A97
seg003:0F33                 push    ax
seg003:0F34                 mov     dh, 5
seg003:0F36                 mov     ax, [word ptr ds:SubChannelData.rel.second]
seg003:0F39                 xchg    ah, al
seg003:0F3B                 mov     si, ax
seg003:0F3D
seg003:0F3D loc_24A7D:                              ; CODE XREF: CD_is_pause?+87↓j
seg003:0F3D                 call    GetSubChannelData
seg003:0F40                 mov     ax, [word ptr ds:SubChannelData.rel.second]
seg003:0F43                 xchg    ah, al
seg003:0F45                 sub     ax, si
seg003:0F47                 cmp     ax, 100h
seg003:0F4A                 jnb     short loc_24A90
seg003:0F4C                 dec     dh
seg003:0F4E                 jnz     short loc_24A7D
seg003:0F50
seg003:0F50 loc_24A90:                              ; CODE XREF: CD_is_pause?+83↑j
seg003:0F50                 pop     ax
seg003:0F51                 or      dh, dh
seg003:0F53                 jz      short loc_24A97
seg003:0F55                 or      al, 2
seg003:0F57
seg003:0F57 loc_24A97:                              ; CODE XREF: CD_is_pause?+66↑j
seg003:0F57                                         ; CD_is_pause?+6A↑j
seg003:0F57                                         ; CD_is_pause?+8C↑j
seg003:0F57                 or      al, dl
seg003:0F59                 mov     [ds:CDROM_access_result], al ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0F59                                         ;            错误           正播  正常
seg003:0F5C                 mov     ax, [word ptr ds:AudioStatus.pause]
seg003:0F5F                 retn
seg003:0F5F endp            CD_is_pause?
seg003:0F5F
seg003:0F60
seg003:0F60 ; =============== S U B R O U T I N E =======================================
seg003:0F60
seg003:0F60
seg003:0F60 proc            GetSubChannelData near  ; CODE XREF: CD_is_pause?↑p
seg003:0F60                                         ; CD_is_pause?:loc_24A7D↑p
seg003:0F60                                         ; LoadUnloadMedia:loc_24DAF↓p
seg003:0F60                 mov     al, 0Dh
seg003:0F62                 mov     [ds:CDROM_request_header.len_drh], al
seg003:0F65                 mov     al, [ds:CDriver_letter]
seg003:0F68                 mov     [ds:CDROM_request_header.subUnit], al
seg003:0F6B                 mov     al, 3
seg003:0F6D                 mov     [ds:CDROM_request_header.funcNr], al
seg003:0F70                 xor     eax, eax
seg003:0F73                 mov     [ds:SubChannelData.attribute], al
seg003:0F76                 mov     [ds:SubChannelData.subtrack], al
seg003:0F79                 mov     [ds:SubChannelData.index], al
seg003:0F7C                 mov     [ds:SubChannelData.rel.minute], al
seg003:0F7F                 mov     [ds:SubChannelData.rel.second], al
seg003:0F82                 mov     [ds:SubChannelData.rel.hour], al
seg003:0F85                 mov     [ds:SubChannelData.reserved_sc], al
seg003:0F88                 mov     [ds:SubChannelData.abs.minute], al
seg003:0F8B                 mov     [ds:SubChannelData.abs.second], al
seg003:0F8E                 mov     [ds:SubChannelData.abs.hour], al
seg003:0F91                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:0F94                 mov     [ds:CDROM_request_header.status], ax
seg003:0F97                 mov     [ds:not_used], ax
seg003:0F9A                 mov     [ds:not_used_too], eax
seg003:0F9E                 push    ds
seg003:0F9F                 push    offset ioctl_fct_GetAudioSubChannelData
seg003:0FA2                 pop     eax
seg003:0FA4                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], eax
seg003:0FA8                 mov     ax, 0Bh
seg003:0FAB                 mov     [ds:CDROM_request_header.status+0Fh], ax
seg003:0FAE                 mov     al, 0Ch
seg003:0FB0                 mov     [ds:ioctl_fct_GetAudioSubChannelData], al
seg003:0FB3                 mov     bx, offset CDROM_request_header
seg003:0FB6                 call    CDROM_SendDriverRequest
seg003:0FB9                 mov     ax, [ds:CDROM_request_header.status]
seg003:0FBC                 mov     bl, ah
seg003:0FBE                 and     bl, 81h
seg003:0FC1                 xor     bl, 1
seg003:0FC4                 mov     cl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0FC4                                         ;            错误           正播  正常
seg003:0FC8                 jz      short loc_24B0F
seg003:0FCA                 and     cl, 11111110b
seg003:0FCD                 jmp     short loc_24B12
seg003:0FCF ; ---------------------------------------------------------------------------
seg003:0FCF
seg003:0FCF loc_24B0F:                              ; CODE XREF: GetSubChannelData+68↑j
seg003:0FCF                 or      cl, 1
seg003:0FD2
seg003:0FD2 loc_24B12:                              ; CODE XREF: GetSubChannelData+6D↑j
seg003:0FD2                 test    ah, 2           ; playing
seg003:0FD5                 jz      short loc_24B1F
seg003:0FD7                 and     cl, 11111011b
seg003:0FDA                 or      cl, 10b         ; 增加第2位，去掉第3位
seg003:0FDD                 jmp     short loc_24B29
seg003:0FDF ; ---------------------------------------------------------------------------
seg003:0FDF
seg003:0FDF loc_24B1F:                              ; CODE XREF: GetSubChannelData+75↑j
seg003:0FDF                 and     cl, 11111101b   ; 去掉第2位
seg003:0FE2                 test    al, 1
seg003:0FE4                 jz      short loc_24B29
seg003:0FE6                 or      cl, 100b        ; 增加第3位
seg003:0FE9
seg003:0FE9 loc_24B29:                              ; CODE XREF: GetSubChannelData+7D↑j
seg003:0FE9                                         ; GetSubChannelData+84↑j
seg003:0FE9                 mov     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:0FE9                                         ;            错误           正播  正常
seg003:0FED                 retn
seg003:0FED endp            GetSubChannelData
seg003:0FED
seg003:0FEE
seg003:0FEE ; =============== S U B R O U T I N E =======================================
seg003:0FEE
seg003:0FEE
seg003:0FEE proc            CD_stoppause near       ; CODE XREF: CDROM_functions:func3_stoppause↑p
seg003:0FEE                 call    is_pause?
seg003:0FF1                 and     al, 2
seg003:0FF3                 jnz     short loc_24B38
seg003:0FF5                 xor     ax, ax
seg003:0FF7                 retn
seg003:0FF8 ; ---------------------------------------------------------------------------
seg003:0FF8
seg003:0FF8 loc_24B38:                              ; CODE XREF: CD_stoppause+5↑j
seg003:0FF8                 call    stop_CD
seg003:0FFB                 mov     bl, ah
seg003:0FFD                 and     bl, 80h
seg003:1000
seg003:1000 loc_24B40:
seg003:1000                 jnz     short locret_24B50
seg003:1002                 mov     cl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:1002                                         ;            错误           正播  正常
seg003:1006                 or      cl, 4
seg003:1009                 and     cl, 0FDh
seg003:100C                 mov     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:100C                                         ;            错误           正播  正常
seg003:1010
seg003:1010 locret_24B50:                           ; CODE XREF: CD_stoppause:loc_24B40↑j
seg003:1010                 retn
seg003:1010 endp            CD_stoppause
seg003:1010
seg003:1011
seg003:1011 ; =============== S U B R O U T I N E =======================================
seg003:1011
seg003:1011
seg003:1011 proc            stop_CD near            ; CODE XREF: CD_stopplay+7↑p
seg003:1011                                         ; CD_stopplay:loc_249EC↑p
seg003:1011                                         ; CD_stoppause:loc_24B38↑p
seg003:1011                                         ; CD_play+28↓p
seg003:1011                 mov     al, 0Dh
seg003:1013                 mov     [ds:CDROM_request_header.len_drh], al
seg003:1016                 mov     al, [ds:CDriver_letter]
seg003:1019                 mov     [ds:CDROM_request_header.subUnit], al
seg003:101C                 mov     al, 85h
seg003:101E                 mov     [ds:CDROM_request_header.funcNr], al
seg003:1021                 xor     ax, ax
seg003:1023                 mov     [ds:CDROM_request_header.status], ax
seg003:1026                 mov     bx, offset CDROM_request_header
seg003:1029                 call    CDROM_SendDriverRequest
seg003:102C                 mov     ax, [ds:CDROM_request_header.status]
seg003:102F                 retn
seg003:102F endp            stop_CD
seg003:102F
seg003:1030
seg003:1030 ; =============== S U B R O U T I N E =======================================
seg003:1030
seg003:1030
seg003:1030 proc            CD_resume near          ; CODE XREF: CDROM_functions:func4_resume↑p
seg003:1030                 mov     al, 0Dh
seg003:1032                 mov     [ds:CDROM_request_header.len_drh], al
seg003:1035                 mov     al, [ds:CDriver_letter]
seg003:1038                 mov     [ds:CDROM_request_header.subUnit], al
seg003:103B                 mov     al, 88h
seg003:103D                 mov     [ds:CDROM_request_header.funcNr], al
seg003:1040                 xor     ax, ax
seg003:1042                 mov     [ds:CDROM_request_header.status], ax
seg003:1045                 mov     bx, 1A6Eh
seg003:1048                 call    CDROM_SendDriverRequest
seg003:104B                 mov     ax, [ds:CDROM_request_header.status]
seg003:104E                 test    ah, 80h
seg003:1051                 jnz     short locret_24B9D
seg003:1053                 push    ax
seg003:1054                 call    is_pause?
seg003:1057                 and     al, 0FBh
seg003:1059                 mov     [ds:CDROM_access_result], al ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:1059                                         ;            错误           正播  正常
seg003:105C                 pop     ax
seg003:105D
seg003:105D locret_24B9D:                           ; CODE XREF: CD_resume+21↑j
seg003:105D                 retn
seg003:105D endp            CD_resume
seg003:105D
seg003:105E
seg003:105E ; =============== S U B R O U T I N E =======================================
seg003:105E
seg003:105E
seg003:105E proc            GetThisTrackMSF near    ; CODE XREF: CD_play+2C↓p
seg003:105E                                         ; CD_play+3F↓p
seg003:105E                 xor     bh, bh
seg003:1060                 xor     eax, eax
seg003:1063                 mov     si, 7
seg003:1066                 imul    si, bx
seg003:1069                 add     si, offset track_info_array
seg003:106D                 mov     di, si
seg003:106F                 add     di, 7
seg003:1072                 xor     ebx, ebx
seg003:1075                 mov     bl, [si+track_info_s.start.min]
seg003:1078                 imul    bx, 3Ch ; '<'
seg003:107B                 mov     al, [si+track_info_s.start.sec]
seg003:107E                 add     ebx, eax
seg003:1081                 imul    ebx, 4Bh ; 'K'
seg003:1085                 mov     al, [si+track_info_s.start.fr]
seg003:1088                 add     ebx, eax
seg003:108B                 xor     ecx, ecx
seg003:108E                 mov     cl, [di+track_info_s.start.min]
seg003:1091                 imul    cx, 3Ch ; '<'
seg003:1094                 mov     al, [di+track_info_s.start.sec]
seg003:1097                 add     ecx, eax
seg003:109A                 imul    ecx, 4Bh ; 'K'
seg003:109E                 mov     al, [di+track_info_s.start.fr]
seg003:10A1                 add     ecx, eax
seg003:10A4                 sub     ecx, ebx
seg003:10A7                 retn
seg003:10A7 endp            GetThisTrackMSF
seg003:10A7
seg003:10A8
seg003:10A8 ; =============== S U B R O U T I N E =======================================
seg003:10A8
seg003:10A8
seg003:10A8 proc            Get_track_attr near     ; CODE XREF: CDROM_info_check+34↓p
seg003:10A8                 xor     dh, dh
seg003:10AA                 mov     al, 0Dh
seg003:10AC                 mov     [ds:CDROM_request_header.len_drh], al
seg003:10AF                 mov     al, [ds:CDriver_letter]
seg003:10B2                 mov     [ds:CDROM_request_header.subUnit], al
seg003:10B5                 mov     al, 3
seg003:10B7                 mov     [ds:CDROM_request_header.funcNr], al
seg003:10BA                 xor     eax, eax
seg003:10BD                 mov     [ds:CDROM_request_header.status], ax
seg003:10C0                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:10C3                 mov     [ds:not_used], ax
seg003:10C6                 mov     [ds:not_used_too], eax
seg003:10CA                 mov     di, 7
seg003:10CD                 mov     [ds:CDROM_request_header.status+0Fh], di
seg003:10D1                 imul    di, dx
seg003:10D4                 add     di, offset track_info_array
seg003:10D8                 push    ds
seg003:10D9                 push    di
seg003:10DA                 pop     eax
seg003:10DC                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], eax
seg003:10E0                 mov     al, 0Bh         ; Audio Track Info
seg003:10E2                 mov     [di], al
seg003:10E4                 mov     [di+track_info_s.track], dl ; track
seg003:10E7                 xor     al, al
seg003:10E9                 mov     [di+track_info_s.start.min], al ; 时间、attr清零
seg003:10EC                 mov     [di+track_info_s.start.sec], al
seg003:10EF                 mov     [di+track_info_s.start.fr], al
seg003:10F2                 mov     [di+track_info_s.attr], al
seg003:10F5                 mov     bx, offset CDROM_request_header
seg003:10F8                 call    CDROM_SendDriverRequest
seg003:10FB                 mov     ax, [ds:CDROM_request_header.status]
seg003:10FE                 retn
seg003:10FE endp            Get_track_attr
seg003:10FE
seg003:10FF
seg003:10FF ; =============== S U B R O U T I N E =======================================
seg003:10FF
seg003:10FF
seg003:10FF proc            Check_CD_info near      ; CODE XREF: CDROM_info_check+16↓p
seg003:10FF                 mov     al, 0Dh
seg003:1101                 mov     [ds:CDROM_request_header.len_drh], al
seg003:1104                 mov     al, [ds:CDriver_letter]
seg003:1107                 mov     [ds:CDROM_request_header.subUnit], al
seg003:110A                 mov     al, 3
seg003:110C                 mov     [ds:CDROM_request_header.funcNr], al ; IOCTL read
seg003:110F                 xor     eax, eax
seg003:1112                 mov     [ds:CDROM_request_header.status], ax
seg003:1115                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:1118                 mov     [ds:not_used], ax
seg003:111B                 mov     [ds:not_used_too], eax
seg003:111F                 mov     [ds:start_track], al
seg003:1122                 mov     [ds:end_track], al
seg003:1125                 mov     [ds:CDROM_TMSF], eax
seg003:1129                 push    ds
seg003:112A                 push    offset ioctl_fct_AudioTrackInfo
seg003:112D                 pop     eax
seg003:112F                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], eax
seg003:1133                 mov     ax, 7
seg003:1136                 mov     al, 0Ah
seg003:1138                 mov     [ds:ioctl_fct_AudioTrackInfo], al ; Get Audio Disk info
seg003:113B                 mov     bx, offset CDROM_request_header
seg003:113E                 call    CDROM_SendDriverRequest
seg003:1141                 mov     ax, [ds:CDROM_request_header.status] ; 100h,Done
seg003:1144                 mov     bl, ah
seg003:1146                 and     bl, 81h
seg003:1149                 xor     bl, 1
seg003:114C                 mov     cl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:114C                                         ;            错误           正播  正常
seg003:1150                 jz      short Done
seg003:1152                 and     cl, 0FEh
seg003:1155                 jmp     short loc_24C9A
seg003:1157 ; ---------------------------------------------------------------------------
seg003:1157
seg003:1157 Done:                                   ; CODE XREF: Check_CD_info+51↑j
seg003:1157                 or      cl, 1
seg003:115A
seg003:115A loc_24C9A:                              ; CODE XREF: Check_CD_info+56↑j
seg003:115A                 mov     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:115A                                         ;            错误           正播  正常
seg003:115E                 retn
seg003:115E endp            Check_CD_info
seg003:115E
seg003:115F
seg003:115F ; =============== S U B R O U T I N E =======================================
seg003:115F
seg003:115F
seg003:115F proc            CD_play near            ; CODE XREF: CDROM_functions:loc_2495D↑p
seg003:115F                 push    edx
seg003:1161                 push    ecx
seg003:1163                 push    ax
seg003:1164                 call    is_pause?
seg003:1167                 test    al, 1
seg003:1169                 jnz     short loc_24CB1
seg003:116B                 add     sp, 0Ah
seg003:116E                 mov     al, 0FFh
seg003:1170                 retn
seg003:1171 ; ---------------------------------------------------------------------------
seg003:1171
seg003:1171 loc_24CB1:                              ; CODE XREF: CD_play+A↑j
seg003:1171                 pop     ax
seg003:1172                 sub     al, [ds:start_track]
seg003:1176                 jl      short loc_24CBE
seg003:1178                 cmp     al, [ds:end_track]
seg003:117C                 jl      short loc_24CC4
seg003:117E
seg003:117E loc_24CBE:                              ; CODE XREF: CD_play+17↑j
seg003:117E                 add     sp, 8
seg003:1181                 mov     al, 0FFh
seg003:1183                 retn
seg003:1184 ; ---------------------------------------------------------------------------
seg003:1184
seg003:1184 loc_24CC4:                              ; CODE XREF: CD_play+1D↑j
seg003:1184                 sub     sp, 2
seg003:1187                 call    stop_CD
seg003:118A                 pop     bx
seg003:118B                 call    GetThisTrackMSF
seg003:118E                 pop     eax
seg003:1190                 cmp     eax, 0FFFFFFFFh
seg003:1194                 jnz     short loc_24CEB
seg003:1196                 push    ebx
seg003:1198                 mov     bl, [ds:end_track]
seg003:119C                 inc     bl
seg003:119E                 call    GetThisTrackMSF
seg003:11A1                 mov     ecx, ebx
seg003:11A4                 pop     ebx
seg003:11A6                 sub     ecx, ebx
seg003:11A9                 jmp     short loc_24CF4
seg003:11AB ; ---------------------------------------------------------------------------
seg003:11AB
seg003:11AB loc_24CEB:                              ; CODE XREF: CD_play+35↑j
seg003:11AB                 cmp     eax, 0FFFFFFFEh
seg003:11AF                 jz      short loc_24CF4
seg003:11B1                 mov     ecx, eax
seg003:11B4
seg003:11B4 loc_24CF4:                              ; CODE XREF: CD_play+4A↑j
seg003:11B4                                         ; CD_play+50↑j
seg003:11B4                 pop     edx
seg003:11B6                 add     ebx, edx
seg003:11B9                 sub     ecx, edx
seg003:11BC                 jg      short loc_24D01
seg003:11BE                 mov     al, 0FFh
seg003:11C0                 retn
seg003:11C1 ; ---------------------------------------------------------------------------
seg003:11C1
seg003:11C1 loc_24D01:                              ; CODE XREF: CD_play+5D↑j
seg003:11C1                 call    playCD
seg003:11C4                 xor     al, al
seg003:11C6                 retn
seg003:11C6 endp            CD_play
seg003:11C6
seg003:11C7
seg003:11C7 ; =============== S U B R O U T I N E =======================================
seg003:11C7
seg003:11C7
seg003:11C7 proc            CDROM_info_check near   ; CODE XREF: CDROM_functions:func0_obtain_info↑p
seg003:11C7                 mov     ax, 1500h
seg003:11CA                 xor     bx, bx
seg003:11CC                 int     2Fh             ;  Multiplex - CDROM - INSTALLATION CHECK
seg003:11CC                                         ; BX = 0000h
seg003:11CC                                         ; Return: BX = number of CDROM drive letters used
seg003:11CC                                         ; CX = starting drive letter (0=A:)
seg003:11CE                 or      bx, bx
seg003:11D0                 jnz     short CDROM_installed
seg003:11D2                 mov     al, 0FFh
seg003:11D4                 retn
seg003:11D5 ; ---------------------------------------------------------------------------
seg003:11D5
seg003:11D5 CDROM_installed:                        ; CODE XREF: CDROM_info_check+9↑j
seg003:11D5                 mov     [ds:CDriver_letter], cl
seg003:11D9                 mov     cx, 2
seg003:11DC
seg003:11DC ensure_loop:                            ; CODE XREF: CDROM_info_check+26↓j
seg003:11DC                 push    cx
seg003:11DD                 call    Check_CD_info
seg003:11E0                 pop     cx
seg003:11E1                 test    ah, 80h
seg003:11E4                 jz      short no_problem
seg003:11E6                 push    cx
seg003:11E7                 mov     cx, 0FFFFh
seg003:11EA
seg003:11EA null_loop:                              ; CODE XREF: CDROM_info_check:null_loop↓j
seg003:11EA                 loop    null_loop
seg003:11EC                 pop     cx
seg003:11ED                 loop    ensure_loop
seg003:11EF
seg003:11EF no_problem:                             ; CODE XREF: CDROM_info_check+1D↑j
seg003:11EF                 movzx   cx, [ds:end_track]
seg003:11F4                 mov     dl, [ds:start_track]
seg003:11F8                 inc     cx              ; 轨数+1
seg003:11F9
seg003:11F9 Track_loop:                             ; CODE XREF: CDROM_info_check+3B↓j
seg003:11F9                 push    cx
seg003:11FA                 push    dx
seg003:11FB                 call    Get_track_attr
seg003:11FE                 pop     dx
seg003:11FF                 inc     dl
seg003:1201                 pop     cx
seg003:1202                 loop    Track_loop
seg003:1204                 mov     eax, [ds:CDROM_TMSF]
seg003:1208                 mov     [di+track_info_s.start.fr], al ; 确保最后一轨?
seg003:120B                 shr     eax, 8
seg003:120F                 mov     [di+track_info_s.start.sec], al
seg003:1212                 shr     eax, 8
seg003:1216                 mov     [di+track_info_s.start.min], al
seg003:1219                 mov     al, [ds:CDriver_letter]
seg003:121C                 retn
seg003:121C endp            CDROM_info_check
seg003:121C
seg003:121D ; ---------------------------------------------------------------------------
seg003:121D                 push    2
seg003:121F ; START OF FUNCTION CHUNK FOR LoadUnloadMedia
seg003:121F
seg003:121F loc_24D5F:                              ; CODE XREF: LoadUnloadMedia+D↓j
seg003:121F                 mov     al, 0Dh
seg003:1221                 mov     [ds:CDROM_request_header.len_drh], al
seg003:1224                 mov     al, [ds:CDriver_letter]
seg003:1227                 mov     [ds:CDROM_request_header.subUnit], al
seg003:122A                 mov     al, 0Ch
seg003:122C                 mov     [ds:CDROM_request_header.funcNr], al
seg003:122F                 xor     eax, eax
seg003:1232                 mov     [ds:CDROM_request_header.status], ax
seg003:1235                 mov     [byte ptr ds:CDROM_request_header.bytes_to_access+1], al
seg003:1238                 mov     [ds:not_used], ax
seg003:123B                 mov     [ds:not_used_too], eax
seg003:123F                 mov     ax, 1
seg003:1242                 mov     [ds:CDROM_request_header.status+0Fh], ax
seg003:1245                 mov     ax, sp
seg003:1247                 push    ss
seg003:1248                 push    ax
seg003:1249                 pop     eax
seg003:124B                 mov     [dword ptr ds:CDROM_request_header.len_drh+0Eh], eax
seg003:124F                 mov     bx, offset CDROM_request_header
seg003:1252                 call    CDROM_SendDriverRequest
seg003:1255                 mov     ax, [ds:CDROM_request_header.status]
seg003:1258                 test    ah, 80h
seg003:125B                 jnz     short loc_24DA8
seg003:125D                 mov     cl, [ds:CDROM_access_result] ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:125D                                         ;            错误           正播  正常
seg003:1261                 and     cl, 0F8h
seg003:1264                 mov     [ds:CDROM_access_result], cl ; F    E D C B A 9     8    7 6 5 4 3 2 1 0
seg003:1264                                         ;            错误           正播  正常
seg003:1268
seg003:1268 loc_24DA8:                              ; CODE XREF: LoadUnloadMedia-11↑j
seg003:1268                 add     sp, 2
seg003:126B                 retn
seg003:126B ; END OF FUNCTION CHUNK FOR LoadUnloadMedia
seg003:126C
seg003:126C ; =============== S U B R O U T I N E =======================================
seg003:126C
seg003:126C
seg003:126C proc            LoadUnloadMedia near    ; CODE XREF: CDROM_functions:func7_load_unload↑p
seg003:126C
seg003:126C ; FUNCTION CHUNK AT seg003:121F SIZE 0000004D BYTES
seg003:126C
seg003:126C                 call    CD_stopplay
seg003:126F
seg003:126F loc_24DAF:                              ; CODE XREF: LoadUnloadMedia+9↓j
seg003:126F                 call    GetSubChannelData
seg003:1272                 test    ah, 2
seg003:1275                 jnz     short loc_24DAF
seg003:1277                 push    0
seg003:1279                 jmp     short loc_24D5F
seg003:1279 endp            LoadUnloadMedia

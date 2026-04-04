seg001:AF9E ; =============== S U B R O U T I N E =======================================
seg001:AF9E
seg001:AF9E ; Attributes: bp-based frame
seg001:AF9E
seg001:AF9E proc            rix_load? far           ; CODE XREF: play_rix_music+93↓P
seg001:AF9E
seg001:AF9E var_2C          = word ptr -2Ch
seg001:AF9E var_2A          = word ptr -2Ah
seg001:AF9E var_28          = word ptr -28h
seg001:AF9E var_26          = word ptr -26h
seg001:AF9E psdDest         = word ptr -24h
seg001:AF9E argu_xmshandle  = word ptr -20h
seg001:AF9E var_1E          = word ptr -1Eh
seg001:AF9E var_1C          = word ptr -1Ch
seg001:AF9E var_1A          = word ptr -1Ah
seg001:AF9E var_18          = word ptr -18h
seg001:AF9E open_method     = word ptr -16h
seg001:AF9E arg_2           = word ptr  6
seg001:AF9E
seg001:AF9E                 mov     cx, 1Ah
seg001:AFA1                 mov     bx, 2
seg001:AFA4                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:AFA9                 mov     [word ptr ds:length], 0
seg001:AFAF                 mov     [word ptr ds:length+2], 0
seg001:AFB5                 mov     ax, [ds:midi_port]
seg001:AFB8                 and     ax, ax
seg001:AFBA                 jnz     short loc_1AA1F
seg001:AFBC                 jmp     loc_1AA8D
seg001:AFBF ; ---------------------------------------------------------------------------
seg001:AFBF
seg001:AFBF loc_1AA1F:                              ; CODE XREF: rix_load?+1C↑j
seg001:AFBF                 push    offset BSTR_CDriver_If_min_inst ; psd1_dst
seg001:AFC2                 push    offset BSTR_Midi_mkf ; psd2
seg001:AFC5                 call    B$SCT1          ; Concatenate strings
seg001:AFCA                 push    ax              ; psdSource
seg001:AFCB                 lea     ax, [bp+open_method]
seg001:AFCE                 push    ax              ; psdDest
seg001:AFCF                 call    B$SAS1          ; String assignment
seg001:AFD4                 mov     [bp+var_18], 0
seg001:AFD9                 lea     ax, [bp+open_method]
seg001:AFDC                 push    ax              ; open_method
seg001:AFDD                 lea     ax, [bp+var_18]
seg001:AFE0                 push    ax              ; int
seg001:AFE1                 call    Open_File
seg001:AFE6                 mov     [bp+var_1A], ax
seg001:AFE9                 mov     ax, [bp+var_1A]
seg001:AFEC                 mov     [ds:file_handle], ax
seg001:AFEF                 push    offset file_handle
seg001:AFF2                 push    [bp+arg_2]
seg001:AFF5                 call    get_subfile_len
seg001:AFFA                 mov     [bp+var_1E], ax
seg001:AFFD                 mov     [bp+var_1C], dx
seg001:B000                 mov     ax, [bp+var_1E]
seg001:B003                 mov     dx, [bp+var_1C]
seg001:B006                 mov     [word ptr ds:length], ax
seg001:B009                 mov     [word ptr ds:length+2], dx
seg001:B00D                 mov     [bp+argu_xmshandle], 0
seg001:B012                 lea     ax, [bp+argu_xmshandle]
seg001:B015                 push    ax              ; argu_xmshandle
seg001:B016                 push    offset xms_handle_22k_midi ; int
seg001:B019                 call    read_subfile
seg001:B01E                 mov     bx, offset file_handle
seg001:B021                 push    ds
seg001:B022                 pop     es
seg001:B023                 push    es              ; int
seg001:B024                 push    bx              ; file_handle
seg001:B025                 call    DOS_CloseFile
seg001:B02A                 jmp     loc_1AB11
seg001:B02D ; ---------------------------------------------------------------------------
seg001:B02D
seg001:B02D loc_1AA8D:                              ; CODE XREF: rix_load?+1E↑j
seg001:B02D                 cmp     [ds:music_mode], 1
seg001:B032                 jz      short loc_1AA97
seg001:B034                 jmp     loc_1AB11
seg001:B037 ; ---------------------------------------------------------------------------
seg001:B037
seg001:B037 loc_1AA97:                              ; CODE XREF: rix_load?+94↑j
seg001:B037                 push    offset BSTR_CDriver_If_min_inst ; psd1_dst
seg001:B03A                 push    offset BSTR_MUS_MKF ; psd2
seg001:B03D                 call    B$SCT1          ; Concatenate strings
seg001:B042                 push    ax              ; psdSource
seg001:B043                 lea     ax, [bp+psdDest]
seg001:B046                 push    ax              ; psdDest
seg001:B047                 call    B$SAS1          ; String assignment
seg001:B04C                 mov     [bp+var_26], 0
seg001:B051                 lea     ax, [bp+psdDest]
seg001:B054                 push    ax              ; open_method
seg001:B055                 lea     ax, [bp+var_26]
seg001:B058                 push    ax              ; int
seg001:B059                 call    Open_File
seg001:B05E                 mov     [bp+var_28], ax
seg001:B061                 mov     ax, [bp+var_28]
seg001:B064                 mov     [ds:file_handle], ax
seg001:B067                 push    offset file_handle
seg001:B06A                 push    [bp+arg_2]
seg001:B06D                 call    get_subfile_len
seg001:B072                 mov     [bp+var_2C], ax
seg001:B075                 mov     [bp+var_2A], dx
seg001:B078                 mov     ax, [bp+var_2C]
seg001:B07B                 mov     dx, [bp+var_2A]
seg001:B07E                 mov     [word ptr ds:length], ax
seg001:B081                 mov     [word ptr ds:length+2], dx
seg001:B085                 mov     bx, offset file_handle
seg001:B088                 push    ds
seg001:B089                 pop     es
seg001:B08A                 push    es              ; int
seg001:B08B                 push    bx              ; file_handle
seg001:B08C                 mov     si, offset DDIM_buf_MPU401
seg001:B08F                 xor     bx, bx
seg001:B091                 add     bx, [si+0Ah]
seg001:B094                 mov     es, [word ptr si+2]
seg001:B097                 push    es
seg001:B098                 push    bx              ; buffer
seg001:B099                 mov     bx, offset length
seg001:B09C                 push    ds
seg001:B09D                 pop     es
seg001:B09E                 push    es
seg001:B09F                 push    bx              ; bytes
seg001:B0A0                 call    DOS_ReadFile_toBuf
seg001:B0A5                 mov     bx, offset file_handle
seg001:B0A8                 push    ds
seg001:B0A9                 pop     es
seg001:B0AA                 push    es              ; int
seg001:B0AB                 push    bx              ; file_handle
seg001:B0AC                 call    DOS_CloseFile
seg001:B0B1
seg001:B0B1 loc_1AB11:                              ; CODE XREF: rix_load?+8C↑j
seg001:B0B1                                         ; rix_load?+96↑j
seg001:B0B1                 call    B$EXSA          ; clear frame state info
seg001:B0B6                 retf    2
seg001:B0B6 endp            rix_load?

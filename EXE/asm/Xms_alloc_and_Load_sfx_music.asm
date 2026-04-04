seg001:EFC2 ; =============== S U B R O U T I N E =======================================
seg001:EFC2
seg001:EFC2 ; Attributes: bp-based frame
seg001:EFC2
seg001:EFC2 proc            Xms_alloc_and_Load_sfx_music far
seg001:EFC2                                         ; CODE XREF: real_entry:next2↑P
seg001:EFC2
seg001:EFC2 var_56          = word ptr -56h
seg001:EFC2 var_54          = word ptr -54h
seg001:EFC2 var_52          = dword ptr -52h
seg001:EFC2 var_4E          = word ptr -4Eh
seg001:EFC2 offset          = dword ptr -4Ch
seg001:EFC2 var_48          = word ptr -48h
seg001:EFC2 var_46          = word ptr -46h
seg001:EFC2 bytes           = dword ptr -44h
seg001:EFC2 var_40          = word ptr -40h
seg001:EFC2 var_3E          = word ptr -3Eh
seg001:EFC2 open_method     = word ptr -3Ch
seg001:EFC2 xms_handle      = word ptr -38h
seg001:EFC2 var_34          = byte ptr -34h
seg001:EFC2 var_32          = byte ptr -32h
seg001:EFC2 var_30          = byte ptr -30h
seg001:EFC2 v_xms_amount    = word ptr -2Eh
seg001:EFC2 var_2C          = byte ptr -2Ch
seg001:EFC2 var_2A          = byte ptr -2Ah
seg001:EFC2 var_28          = byte ptr -28h
seg001:EFC2 var_26          = byte ptr -26h
seg001:EFC2 var_24          = byte ptr -24h
seg001:EFC2 var_22          = byte ptr -22h
seg001:EFC2 var_20          = byte ptr -20h
seg001:EFC2 var_1E          = byte ptr -1Eh
seg001:EFC2 var_1C          = byte ptr -1Ch
seg001:EFC2 var_1A          = byte ptr -1Ah
seg001:EFC2 var_18          = byte ptr -18h
seg001:EFC2 var_16          = byte ptr -16h
seg001:EFC2 length_KB       = byte ptr -14h
seg001:EFC2
seg001:EFC2                 mov     cx, 44h ; 'D'
seg001:EFC5                 mov     bx, 2
seg001:EFC8                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:EFCD                 mov     [word ptr bp+length_KB], 1
seg001:EFD2                 lea     bx, [bp+length_KB]
seg001:EFD5                 push    ds
seg001:EFD6                 pop     es
seg001:EFD7                 push    es              ; int
seg001:EFD8                 push    bx              ; length_KB
seg001:EFD9                 mov     bx, offset xms_handle_data@5_battlefield_effect
seg001:EFDC                 push    ds
seg001:EFDD                 pop     es
seg001:EFDE                 push    es
seg001:EFDF                 push    bx              ; handle
seg001:EFE0                 call    XMS_Alloc_Block
seg001:EFE5                 mov     [word ptr bp+var_16], 1
seg001:EFEA                 lea     bx, [bp+var_16]
seg001:EFED                 push    ds
seg001:EFEE                 pop     es
seg001:EFEF                 push    es              ; int
seg001:EFF0                 push    bx              ; length_KB
seg001:EFF1                 mov     bx, offset xms_handle_data@E_uplevel_exp
seg001:EFF4                 push    ds
seg001:EFF5                 pop     es
seg001:EFF6                 push    es
seg001:EFF7                 push    bx              ; handle
seg001:EFF8                 call    XMS_Alloc_Block
seg001:EFFD                 mov     [word ptr bp+var_18], 4
seg001:F002                 lea     bx, [bp+var_18]
seg001:F005                 push    ds
seg001:F006                 pop     es
seg001:F007                 push    es              ; int
seg001:F008                 push    bx              ; length_KB
seg001:F009                 mov     bx, offset xms_handle_data@4_theurgy_data
seg001:F00C                 push    ds
seg001:F00D                 pop     es
seg001:F00E                 push    es
seg001:F00F                 push    bx              ; handle
seg001:F010                 call    XMS_Alloc_Block
seg001:F015                 mov     [word ptr bp+var_1A], 4
seg001:F01A                 lea     bx, [bp+var_1A]
seg001:F01D                 push    ds
seg001:F01E                 pop     es
seg001:F01F                 push    es              ; int
seg001:F020                 push    bx              ; length_KB
seg001:F021                 mov     bx, offset xms_handle_data@2_enemy_team
seg001:F024                 push    ds
seg001:F025                 pop     es
seg001:F026                 push    es
seg001:F027                 push    bx              ; handle
seg001:F028                 call    XMS_Alloc_Block
seg001:F02D                 mov     [word ptr bp+var_1C], 0Ch
seg001:F032                 lea     bx, [bp+var_1C]
seg001:F035                 push    ds
seg001:F036                 pop     es
seg001:F037                 push    es              ; int
seg001:F038                 push    bx              ; length_KB
seg001:F039                 mov     bx, offset xms_handle_data@1_enemy_data
seg001:F03C                 push    ds
seg001:F03D                 pop     es
seg001:F03E                 push    es
seg001:F03F                 push    bx              ; handle
seg001:F040                 call    XMS_Alloc_Block
seg001:F045                 mov     [word ptr bp+var_1E], 1Ah
seg001:F04A                 lea     bx, [bp+var_1E]
seg001:F04D                 push    ds
seg001:F04E                 pop     es
seg001:F04F                 push    es              ; int
seg001:F050                 push    bx              ; length_KB
seg001:F051                 mov     bx, offset xms_handle_data@9_menu_in_game
seg001:F054                 push    ds
seg001:F055                 pop     es
seg001:F056                 push    es
seg001:F057                 push    bx              ; handle
seg001:F058                 call    XMS_Alloc_Block
seg001:F05D                 mov     [word ptr bp+var_20], 12h
seg001:F062                 lea     bx, [bp+var_20]
seg001:F065                 push    ds
seg001:F066                 pop     es
seg001:F067                 push    es              ; int
seg001:F068                 push    bx              ; length_KB
seg001:F069                 mov     bx, offset xms_handle_data@A_use_magic_effect
seg001:F06C                 push    ds
seg001:F06D                 pop     es
seg001:F06E                 push    es
seg001:F06F                 push    bx              ; handle
seg001:F070                 call    XMS_Alloc_Block
seg001:F075                 mov     [word ptr bp+var_22], 40h ; '@'
seg001:F07A                 lea     bx, [bp+var_22]
seg001:F07D                 push    ds
seg001:F07E                 pop     es
seg001:F07F                 push    es              ; int
seg001:F080                 push    bx              ; length_KB
seg001:F081                 mov     bx, offset xms_handle_40K_backup
seg001:F084                 push    ds
seg001:F085                 pop     es
seg001:F086                 push    es
seg001:F087                 push    bx              ; handle
seg001:F088                 call    XMS_Alloc_Block
seg001:F08D                 mov     [word ptr bp+var_24], 40h ; '@'
seg001:F092                 lea     bx, [bp+var_24]
seg001:F095                 push    ds
seg001:F096                 pop     es
seg001:F097                 push    es              ; int
seg001:F098                 push    bx              ; length_KB
seg001:F099                 mov     bx, offset XMS_handle_bak
seg001:F09C                 push    ds
seg001:F09D                 pop     es
seg001:F09E                 push    es
seg001:F09F                 push    bx              ; handle
seg001:F0A0                 call    XMS_Alloc_Block
seg001:F0A5                 mov     [word ptr bp+var_26], 34h ; '4'
seg001:F0AA                 lea     bx, [bp+var_26]
seg001:F0AD                 push    ds
seg001:F0AE                 pop     es
seg001:F0AF                 push    es              ; int
seg001:F0B0                 push    bx              ; length_KB
seg001:F0B1                 mov     bx, offset xms_handle_sss@3_m_index
seg001:F0B4                 push    ds
seg001:F0B5                 pop     es
seg001:F0B6                 push    es
seg001:F0B7                 push    bx              ; handle
seg001:F0B8                 call    XMS_Alloc_Block
seg001:F0BD                 mov     [word ptr bp+var_28], 4Eh ; 'N'
seg001:F0C2                 lea     bx, [bp+var_28]
seg001:F0C5                 push    ds
seg001:F0C6                 pop     es
seg001:F0C7                 push    es              ; int
seg001:F0C8                 push    bx              ; length_KB
seg001:F0C9                 mov     bx, offset xms_handle_wor16_fon
seg001:F0CC                 push    ds
seg001:F0CD                 pop     es
seg001:F0CE                 push    es
seg001:F0CF                 push    bx              ; handle
seg001:F0D0                 call    XMS_Alloc_Block
seg001:F0D5                 mov     [word ptr bp+var_2A], 14Ch
seg001:F0DA                 lea     bx, [bp+var_2A]
seg001:F0DD                 push    ds
seg001:F0DE                 pop     es
seg001:F0DF                 push    es              ; int
seg001:F0E0                 push    bx              ; length_KB
seg001:F0E1                 mov     bx, offset xms_handle_sss@4_script
seg001:F0E4                 push    ds
seg001:F0E5                 pop     es
seg001:F0E6                 push    es
seg001:F0E7                 push    bx              ; handle
seg001:F0E8                 call    XMS_Alloc_Block
seg001:F0ED                 mov     [word ptr bp+var_2C], 0A8h
seg001:F0F2                 lea     bx, [bp+var_2C]
seg001:F0F5                 push    ds
seg001:F0F6                 pop     es
seg001:F0F7                 push    es              ; int
seg001:F0F8                 push    bx              ; length_KB
seg001:F0F9                 mov     bx, offset xms_handle_sss@0_evt_obj
seg001:F0FC                 push    ds
seg001:F0FD                 pop     es
seg001:F0FE                 push    es
seg001:F0FF                 push    bx              ; handle
seg001:F100                 call    XMS_Alloc_Block
seg001:F105                 lea     bx, [bp+v_xms_amount]
seg001:F108                 push    ds
seg001:F109                 pop     es
seg001:F10A                 push    es              ; int
seg001:F10B                 push    bx              ; flag
seg001:F10C                 call    XMS_Query_Amount
seg001:F111                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:F114                 mov     bx, 0Ah
seg001:F117                 add     bx, [si+0Ah]
seg001:F11A                 mov     es, [word ptr si+2]
seg001:F11D                 cmp     [word ptr es:bx], 0
seg001:F121                 jnz     short has_sfx
seg001:F123                 jmp     sb_end
seg001:F126 ; ---------------------------------------------------------------------------
seg001:F126
seg001:F126 has_sfx:                                ; CODE XREF: Xms_alloc_and_Load_sfx_music+15F↑j
seg001:F126                 mov     bx, 8
seg001:F129                 add     bx, [si+0Ah]
seg001:F12C                 mov     es, [word ptr si+2]
seg001:F12F                 mov     ax, [es:bx]
seg001:F132                 and     ax, 1
seg001:F135                 cmp     ax, 1
seg001:F138                 jz      short use_soundblaster
seg001:F13A                 jmp     sb_end
seg001:F13D ; ---------------------------------------------------------------------------
seg001:F13D
seg001:F13D use_soundblaster:                       ; CODE XREF: Xms_alloc_and_Load_sfx_music+176↑j
seg001:F13D                 cmp     [bp+v_xms_amount], 34h ; '4'
seg001:F141                 jg      short xms_enough
seg001:F143                 jmp     xms_too_few
seg001:F146 ; ---------------------------------------------------------------------------
seg001:F146
seg001:F146 xms_enough:                             ; CODE XREF: Xms_alloc_and_Load_sfx_music+17F↑j
seg001:F146                 sub     [bp+v_xms_amount], 34h ; '4'
seg001:F14A                 mov     [word ptr bp+var_30], 34h ; '4'
seg001:F14F                 lea     bx, [bp+var_30]
seg001:F152                 push    ds
seg001:F153                 pop     es
seg001:F154                 push    es              ; int
seg001:F155                 push    bx              ; length_KB
seg001:F156                 mov     bx, offset xms_handle_34k_RIX?
seg001:F159                 push    ds
seg001:F15A                 pop     es
seg001:F15B                 push    es
seg001:F15C                 push    bx              ; handle
seg001:F15D                 call    XMS_Alloc_Block
seg001:F162                 jmp     sb_end
seg001:F165 ; ---------------------------------------------------------------------------
seg001:F165
seg001:F165 xms_too_few:                            ; CODE XREF: Xms_alloc_and_Load_sfx_music+181↑j
seg001:F165                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:F168                 mov     bx, 0Ah
seg001:F16B                 add     bx, [si+0Ah]
seg001:F16E                 mov     es, [word ptr si+2]
seg001:F171                 mov     [word ptr es:bx], 0
seg001:F176
seg001:F176 sb_end:                                 ; CODE XREF: Xms_alloc_and_Load_sfx_music+161↑j
seg001:F176                                         ; Xms_alloc_and_Load_sfx_music+178↑j
seg001:F176                                         ; Xms_alloc_and_Load_sfx_music+1A0↑j
seg001:F176                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:F179                 mov     bx, 8
seg001:F17C                 add     bx, [si+0Ah]
seg001:F17F                 mov     es, [word ptr si+2]
seg001:F182                 mov     ax, [es:bx]
seg001:F185                 and     ax, 2
seg001:F188                 and     ax, ax
seg001:F18A                 jnz     short use_midi
seg001:F18C                 jmp     no_midi
seg001:F18F ; ---------------------------------------------------------------------------
seg001:F18F
seg001:F18F use_midi:                               ; CODE XREF: Xms_alloc_and_Load_sfx_music+1C8↑j
seg001:F18F                 cmp     [bp+v_xms_amount], 22h ; '"'
seg001:F193                 jg      short xms_enough_2
seg001:F195                 jmp     xms_too_few_2
seg001:F198 ; ---------------------------------------------------------------------------
seg001:F198
seg001:F198 xms_enough_2:                           ; CODE XREF: Xms_alloc_and_Load_sfx_music+1D1↑j
seg001:F198                 sub     [bp+v_xms_amount], 22h ; '"'
seg001:F19C                 mov     [word ptr bp+var_32], 22h ; '"'
seg001:F1A1                 lea     bx, [bp+var_32]
seg001:F1A4                 push    ds
seg001:F1A5                 pop     es
seg001:F1A6                 push    es              ; int
seg001:F1A7                 push    bx              ; length_KB
seg001:F1A8                 mov     bx, offset xms_handle_22k_midi
seg001:F1AB                 push    ds
seg001:F1AC                 pop     es
seg001:F1AD                 push    es
seg001:F1AE                 push    bx              ; handle
seg001:F1AF                 call    XMS_Alloc_Block
seg001:F1B4                 jmp     no_midi
seg001:F1B7 ; ---------------------------------------------------------------------------
seg001:F1B7
seg001:F1B7 xms_too_few_2:                          ; CODE XREF: Xms_alloc_and_Load_sfx_music+1D3↑j
seg001:F1B7                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:F1BA                 mov     bx, 8
seg001:F1BD                 add     bx, [si+0Ah]
seg001:F1C0                 mov     es, [word ptr si+2]
seg001:F1C3                 mov     ax, [es:bx]
seg001:F1C6                 xor     ax, 2
seg001:F1C9                 mov     bx, 8
seg001:F1CC                 add     bx, [si+0Ah]
seg001:F1CF                 mov     es, [word ptr si+2]
seg001:F1D2                 mov     [es:bx], ax
seg001:F1D5
seg001:F1D5 no_midi:                                ; CODE XREF: Xms_alloc_and_Load_sfx_music+1CA↑j
seg001:F1D5                                         ; Xms_alloc_and_Load_sfx_music+1F2↑j
seg001:F1D5                 cmp     [bp+v_xms_amount], 86h
seg001:F1DA                 jg      short can_read_ball_mkf
seg001:F1DC                 jmp     xms_too_few_3_skip_ball
seg001:F1DF ; ---------------------------------------------------------------------------
seg001:F1DF
seg001:F1DF can_read_ball_mkf:                      ; CODE XREF: Xms_alloc_and_Load_sfx_music+218↑j
seg001:F1DF                 sub     [bp+v_xms_amount], 86h
seg001:F1E4                 mov     [word ptr bp+var_34], 86h
seg001:F1E9                 lea     bx, [bp+var_34]
seg001:F1EC                 push    ds
seg001:F1ED                 pop     es
seg001:F1EE                 push    es              ; int
seg001:F1EF                 push    bx              ; length_KB
seg001:F1F0                 mov     bx, offset xms_handle_86k_ball
seg001:F1F3                 push    ds
seg001:F1F4                 pop     es
seg001:F1F5                 push    es
seg001:F1F6                 push    bx              ; handle
seg001:F1F7                 call    XMS_Alloc_Block
seg001:F1FC                 push    offset BSTR_CDriver_If_min_inst ; psd1_dst
seg001:F1FF                 push    offset BSTR_BALL_MKF ; psd2
seg001:F202                 call    B$SCT1          ; Concatenate strings
seg001:F207                 push    ax              ; psdSource
seg001:F208                 lea     ax, [bp+xms_handle]
seg001:F20B                 push    ax              ; psdDest
seg001:F20C                 call    B$SAS1          ; String assignment
seg001:F211                 lea     ax, [bp+xms_handle]
seg001:F214                 push    ax              ; xms_handle
seg001:F215                 push    offset xms_handle_86k_ball ; int
seg001:F218                 call    read_mkf_to_xms
seg001:F21D
seg001:F21D xms_too_few_3_skip_ball:                ; CODE XREF: Xms_alloc_and_Load_sfx_music+21A↑j
seg001:F21D                 lea     bx, [bp+v_xms_amount]
seg001:F220                 push    ds
seg001:F221                 pop     es
seg001:F222                 push    es              ; int
seg001:F223                 push    bx              ; flag
seg001:F224                 call    XMS_Query_Amount
seg001:F229                 cmp     [bp+v_xms_amount], 1
seg001:F22D                 jg      short leaving_xms_big_than_1k
seg001:F22F                 jmp     xms_too_few_4
seg001:F232 ; ---------------------------------------------------------------------------
seg001:F232
seg001:F232 leaving_xms_big_than_1k:                ; CODE XREF: Xms_alloc_and_Load_sfx_music+26B↑j
seg001:F232                 lea     bx, [bp+v_xms_amount]
seg001:F235                 push    ds
seg001:F236                 pop     es
seg001:F237                 push    es              ; int
seg001:F238                 push    bx              ; length_KB
seg001:F239                 mov     bx, offset xms_handle_leaving
seg001:F23C                 push    ds
seg001:F23D                 pop     es
seg001:F23E                 push    es
seg001:F23F                 push    bx              ; handle
seg001:F240                 call    XMS_Alloc_Block
seg001:F245                 jmp     next
seg001:F248 ; ---------------------------------------------------------------------------
seg001:F248
seg001:F248 xms_too_few_4:                          ; CODE XREF: Xms_alloc_and_Load_sfx_music+26D↑j
seg001:F248                 mov     [bp+v_xms_amount], 0
seg001:F24D
seg001:F24D next:                                   ; CODE XREF: Xms_alloc_and_Load_sfx_music+283↑j
seg001:F24D                 push    0
seg001:F24F                 push    1024
seg001:F252                 mov     ax, [bp+v_xms_amount]
seg001:F255                 cwd
seg001:F256                 push    dx
seg001:F257                 push    ax
seg001:F258                 call    B$MUI4          ; Long integer multiply
seg001:F25D                 mov     [word ptr ds:bytes_leavingxms], ax
seg001:F260                 mov     [word ptr ds:bytes_leavingxms+2], dx
seg001:F264                 push    dx              ; op1_h
seg001:F265                 push    ax              ; op1_l
seg001:F266                 push    0               ; op2_h
seg001:F268                 push    0               ; op2_l
seg001:F26A                 call    B$CPI4          ; long integer compare
seg001:F26F                 jg      short still_has_xms
seg001:F271                 jmp     xms_too_few_5_skip_soundeffect
seg001:F274 ; ---------------------------------------------------------------------------
seg001:F274
seg001:F274 still_has_xms:                          ; CODE XREF: Xms_alloc_and_Load_sfx_music+2AD↑j
seg001:F274                 push    offset BSTR_CDriver_If_min_inst ; psd1_dst
seg001:F277                 push    offset BSTR_Voc_MKF ; psd2
seg001:F27A                 call    B$SCT1          ; Concatenate strings
seg001:F27F                 push    ax              ; psdSource
seg001:F280                 lea     ax, [bp+open_method]
seg001:F283                 push    ax              ; psdDest
seg001:F284                 call    B$SAS1          ; String assignment
seg001:F289                 mov     [bp+var_3E], 0
seg001:F28E                 lea     ax, [bp+open_method]
seg001:F291                 push    ax              ; open_method
seg001:F292                 lea     ax, [bp+var_3E]
seg001:F295                 push    ax              ; int
seg001:F296                 call    Open_File
seg001:F29B                 mov     [bp+var_40], ax
seg001:F29E                 mov     ax, [bp+var_40]
seg001:F2A1                 mov     [ds:file_handle], ax
seg001:F2A4                 mov     [word ptr bp+bytes], 4
seg001:F2A9                 mov     [word ptr bp+bytes+2], 0
seg001:F2AE                 mov     bx, offset file_handle
seg001:F2B1                 push    ds
seg001:F2B2                 pop     es
seg001:F2B3                 push    es              ; int
seg001:F2B4                 push    bx              ; file_handle
seg001:F2B5                 mov     si, offset DDIM_buf_index
seg001:F2B8                 xor     bx, bx
seg001:F2BA                 add     bx, [si+0Ah]
seg001:F2BD                 mov     es, [word ptr si+2]
seg001:F2C0                 push    es
seg001:F2C1                 push    bx              ; buffer
seg001:F2C2                 lea     bx, [bp+bytes]
seg001:F2C5                 push    ds
seg001:F2C6                 pop     es
seg001:F2C7                 push    es
seg001:F2C8                 push    bx              ; bytes
seg001:F2C9                 call    DOS_ReadFile_toBuf
seg001:F2CE                 mov     si, offset DDIM_buf_index
seg001:F2D1                 xor     bx, bx
seg001:F2D3                 add     bx, [si+0Ah]
seg001:F2D6                 mov     es, [word ptr si+2]
seg001:F2D9                 fild    [dword ptr es:bx] ; (emulator call)
seg001:F2DD                 fdiv    [ds:fp64_4]     ; (emulator call)
seg001:F2E2                 fsub    [ds:fp64_2]     ; (emulator call)
seg001:F2E7                 fistp   [bp+var_48]     ; (emulator call)
seg001:F2EB                 wait                    ; (emulator call)
seg001:F2ED                 mov     ax, [bp+var_48]
seg001:F2F0                 mov     [bp+var_46], ax
seg001:F2F3                 xor     ax, ax
seg001:F2F5                 jmp     start_read_voc
seg001:F2F8 ; ---------------------------------------------------------------------------
seg001:F2F8
seg001:F2F8 read_subfile_loop:                      ; CODE XREF: Xms_alloc_and_Load_sfx_music+3F3↓j
seg001:F2F8                 mov     ax, [bp+var_4E]
seg001:F2FB                 shl     ax, 1
seg001:F2FD                 shl     ax, 1
seg001:F2FF                 cwd
seg001:F300                 mov     [word ptr bp+offset], ax
seg001:F303                 mov     [word ptr bp+offset+2], dx
seg001:F306                 mov     bx, offset file_handle
seg001:F309                 push    ds
seg001:F30A                 pop     es
seg001:F30B                 push    es              ; int
seg001:F30C                 push    bx              ; file_handle
seg001:F30D                 lea     bx, [bp+offset]
seg001:F310                 push    ds
seg001:F311                 pop     es
seg001:F312                 push    es
seg001:F313                 push    bx              ; offset
seg001:F314                 call    DOS_SeekFile_Absolute
seg001:F319                 mov     [word ptr bp+var_52], 80h
seg001:F31E                 mov     [word ptr bp+var_52+2], 0
seg001:F323                 mov     bx, offset file_handle
seg001:F326                 push    ds
seg001:F327                 pop     es
seg001:F328                 push    es              ; int
seg001:F329                 push    bx              ; file_handle
seg001:F32A                 mov     si, offset DDIM_buf_index
seg001:F32D                 xor     bx, bx
seg001:F32F                 add     bx, [si+0Ah]
seg001:F332                 mov     es, [word ptr si+2]
seg001:F335                 push    es
seg001:F336                 push    bx              ; buffer
seg001:F337                 lea     bx, [bp+var_52]
seg001:F33A                 push    ds
seg001:F33B                 pop     es
seg001:F33C                 push    es
seg001:F33D                 push    bx              ; bytes
seg001:F33E                 call    DOS_ReadFile_toBuf
seg001:F343                 xor     ax, ax
seg001:F345                 jmp     reach_end?
seg001:F348 ; ---------------------------------------------------------------------------
seg001:F348
seg001:F348 not_reach:                              ; CODE XREF: Xms_alloc_and_Load_sfx_music+3E3↓j
seg001:F348                 add     ax, [bp+var_4E]
seg001:F34B                 mov     [bp+var_54], ax
seg001:F34E                 cmp     ax, [bp+var_48]
seg001:F351                 jle     short continue_read_next_point
seg001:F353                 jmp     reach_last_subfile
seg001:F356 ; ---------------------------------------------------------------------------
seg001:F356
seg001:F356 continue_read_next_point:               ; CODE XREF: Xms_alloc_and_Load_sfx_music+38F↑j
seg001:F356                 mov     cx, [bp+var_56]
seg001:F359                 shl     cx, 1
seg001:F35B                 shl     cx, 1
seg001:F35D                 add     cx, 4
seg001:F360                 mov     bx, cx
seg001:F362                 mov     si, offset DDIM_buf_index
seg001:F365                 add     bx, [si+DDIM.offset]
seg001:F368                 mov     es, [si+DDIM.header.segment]
seg001:F36B                 push    [es:bx+DDIM.header.segment] ; op1_h
seg001:F36F                 push    [es:bx+DDIM.header.FHD_oData] ; op1_l
seg001:F372                 push    [word ptr ds:bytes_leavingxms+2] ; op2_h
seg001:F376                 push    [word ptr ds:bytes_leavingxms] ; op2_l
seg001:F37A                 call    B$CPI4          ; long integer compare
seg001:F37F                 jg      short reach_last_subfile
seg001:F381                 inc     ax
seg001:F382                 mov     [ds:vocs?], ax
seg001:F385                 mov     bx, cx
seg001:F387                 add     bx, [si+0Ah]
seg001:F38A                 mov     es, [word ptr si+2]
seg001:F38D                 mov     ax, [es:bx]
seg001:F390                 mov     dx, [es:bx+2]
seg001:F394                 mov     [word ptr ds:curr_subfile_offset], ax
seg001:F397                 mov     [word ptr ds:curr_subfile_offset+2], dx
seg001:F39B
seg001:F39B reach_last_subfile:                     ; CODE XREF: Xms_alloc_and_Load_sfx_music+391↑j
seg001:F39B                                         ; Xms_alloc_and_Load_sfx_music+3BD↑j
seg001:F39B                 mov     ax, [bp+var_56]
seg001:F39E                 inc     ax
seg001:F39F
seg001:F39F reach_end?:                             ; CODE XREF: Xms_alloc_and_Load_sfx_music+383↑j
seg001:F39F                 mov     [bp+var_56], ax
seg001:F3A2                 cmp     ax, 1Dh
seg001:F3A5                 jle     short not_reach
seg001:F3A7                 mov     ax, [bp+var_4E]
seg001:F3AA                 add     ax, 1Eh
seg001:F3AD
seg001:F3AD start_read_voc:                         ; CODE XREF: Xms_alloc_and_Load_sfx_music+333↑j
seg001:F3AD                 mov     [bp+var_4E], ax
seg001:F3B0                 cmp     ax, [bp+var_46]
seg001:F3B3                 jg      short endLoop
seg001:F3B5                 jmp     read_subfile_loop
seg001:F3B8 ; ---------------------------------------------------------------------------
seg001:F3B8
seg001:F3B8 endLoop:                                ; CODE XREF: Xms_alloc_and_Load_sfx_music+3F1↑j
seg001:F3B8                 mov     bx, offset file_handle
seg001:F3BB                 push    ds
seg001:F3BC                 pop     es
seg001:F3BD                 push    es              ; int
seg001:F3BE                 push    bx              ; file_handle
seg001:F3BF                 call    DOS_CloseFile
seg001:F3C4
seg001:F3C4 xms_too_few_5_skip_soundeffect:         ; CODE XREF: Xms_alloc_and_Load_sfx_music+2AF↑j
seg001:F3C4                 mov     bx, offset xms_handle_leaving
seg001:F3C7                 push    ds
seg001:F3C8                 pop     es
seg001:F3C9                 push    es
seg001:F3CA                 push    bx
seg001:F3CB                 mov     bx, offset leaving_addr
seg001:F3CE                 push    ds
seg001:F3CF                 pop     es
seg001:F3D0                 push    es
seg001:F3D1                 push    bx
seg001:F3D2                 call    XMS_Lock_Block
seg001:F3D7                 mov     bx, offset xms_handle_34k_RIX?
seg001:F3DA                 push    ds
seg001:F3DB                 pop     es
seg001:F3DC                 push    es
seg001:F3DD                 push    bx
seg001:F3DE                 mov     bx, offset rix_addr
seg001:F3E1                 push    ds
seg001:F3E2                 pop     es
seg001:F3E3                 push    es
seg001:F3E4                 push    bx
seg001:F3E5                 call    XMS_Lock_Block
seg001:F3EA                 mov     ax, [ds:xms_handle_leaving]
seg001:F3ED                 mov     [ds:save_xms_handle_leaving], ax
seg001:F3F0                 call    B$EXSA          ; clear frame state info
seg001:F3F5                 retf    0
seg001:F3F5 endp            Xms_alloc_and_Load_sfx_music

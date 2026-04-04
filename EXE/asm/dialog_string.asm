seg000:DE14 ; =============== S U B R O U T I N E =======================================
seg000:DE14
seg000:DE14 ; Attributes: bp-based frame
seg000:DE14
seg000:DE14 proc            dialog_string far       ; CODE XREF: process_Script+1EE↑P
seg000:DE14                                         ; process_Script+258↑P
seg000:DE14                                         ; show_current_money+85↑P
seg000:DE14                                         ; show_text_shadow+50↓P
seg000:DE14                                         ; calc_display_EXP+7D↓P
seg000:DE14                                         ; sub_10941+7D↓P
seg000:DE14                                         ; sub_10941+10D↓P
seg000:DE14                                         ; select_RPG_internal+1CA↓P
seg000:DE14                                         ; yes_no_dialog+FF↓P
seg000:DE14                                         ; process_scripts+33AF↓P
seg000:DE14                                         ; process_scripts+345F↓P
seg000:DE14                                         ; process_scripts+357D↓P
seg000:DE14                                         ; process_scripts+3601↓P
seg000:DE14                                         ; learnmagic_internal+14A↓P
seg000:DE14                                         ; learnmagic_internal+1C9↓P ...
seg000:DE14
seg000:DE14 src_offset      = dword ptr -2Ch
seg000:DE14 length          = dword ptr -28h
seg000:DE14 var_pos         = word ptr -24h
seg000:DE14 var_ASCII       = word ptr -22h
seg000:DE14 psdDest         = word ptr -20h
seg000:DE14 iStart          = word ptr -1Ch
seg000:DE14 var_length_bytes= word ptr -1Ah
seg000:DE14 var_x           = word ptr -18h
seg000:DE14 psdSource       = word ptr -16h
seg000:DE14 arg_color       = word ptr  6
seg000:DE14 arg_method      = word ptr  8
seg000:DE14 arg_STR         = word ptr  0Ah
seg000:DE14 arg_y           = word ptr  0Ch
seg000:DE14 arg_x           = word ptr  0Eh
seg000:DE14
seg000:DE14                 mov     cx, 1Ah
seg000:DE17                 mov     bx, 2
seg000:DE1A                 call    far ptr B$ENRA  ; setup stack & other state info.
seg000:DE1F                 push    [bp+arg_STR]
seg000:DE22                 call    B$RTRM          ; Trim both side of blanks from a string
seg000:DE27                 push    ax              ; psdSource
seg000:DE28                 lea     ax, [bp+psdSource]
seg000:DE2B                 push    ax              ; psdDest
seg000:DE2C                 call    B$SAS1          ; String assignment
seg000:DE31                 mov     si, [bp+arg_x]
seg000:DE34                 mov     ax, [si]
seg000:DE36                 mov     [bp+var_x], ax
seg000:DE39                 lea     ax, [bp+psdSource]
seg000:DE3C                 push    ax
seg000:DE3D                 call    STRINGLENGTH
seg000:DE42                 mov     [bp+var_length_bytes], ax
seg000:DE45                 mov     [bp+iStart], 1
seg000:DE4A
seg000:DE4A output_loop:                            ; CODE XREF: dialog_string+141↓j
seg000:DE4A                 mov     ax, [bp+var_length_bytes]
seg000:DE4D                 cmp     ax, [bp+iStart]
seg000:DE50                 jge     short next
seg000:DE52                 jmp     too_low
seg000:DE55 ; ---------------------------------------------------------------------------
seg000:DE55
seg000:DE55 next:                                   ; CODE XREF: dialog_string+3C↑j
seg000:DE55                 lea     ax, [bp+psdSource]
seg000:DE58                 push    ax              ; psdSource
seg000:DE59                 push    [bp+iStart]     ; iStart
seg000:DE5C                 push    2               ; cbLen
seg000:DE5E                 call    B$FMID          ; Compute MID$ function
seg000:DE63                 push    ax              ; psdSource
seg000:DE64                 lea     ax, [bp+psdDest]
seg000:DE67                 push    ax              ; psdDest
seg000:DE68                 call    B$SAS1          ; String assignment
seg000:DE6D                 lea     ax, [bp+psdDest]
seg000:DE70                 push    ax
seg000:DE71                 call    B$FASC          ; Compute ASC function
seg000:DE76                 mov     [bp+var_ASCII], ax
seg000:DE79                 mov     ax, [bp+var_length_bytes]
seg000:DE7C                 cmp     ax, [bp+iStart]
seg000:DE7F                 jg      short next2
seg000:DE81                 jmp     skip_one_byte
seg000:DE84 ; ---------------------------------------------------------------------------
seg000:DE84
seg000:DE84 next2:                                  ; CODE XREF: dialog_string+6B↑j
seg000:DE84                 cmp     [bp+var_ASCII], 0A0h ; big5判定
seg000:DE89                 jge     short next3
seg000:DE8B                 jmp     skip_one_byte
seg000:DE8E ; ---------------------------------------------------------------------------
seg000:DE8E
seg000:DE8E next3:                                  ; CODE XREF: dialog_string+75↑j
seg000:DE8E                 lea     ax, [bp+psdDest]
seg000:DE91                 push    ax
seg000:DE92                 call    far ptr B$FCVI  ; Convert string to integer
seg000:DE97                 mov     [bp+var_ASCII], ax
seg000:DE9A                 mov     ax, [ds:total_ch_chars]
seg000:DE9D                 mov     [bp+var_pos], ax
seg000:DEA0                 lea     bx, [bp+var_ASCII]
seg000:DEA3                 push    ds
seg000:DEA4                 pop     es
seg000:DEA5                 push    es
seg000:DEA6                 push    bx
seg000:DEA7                 lea     bx, [bp+var_pos]
seg000:DEAA                 push    ds
seg000:DEAB                 pop     es
seg000:DEAC                 push    es
seg000:DEAD                 push    bx
seg000:DEAE                 mov     si, offset DDIM_wor16_asc
seg000:DEB1                 xor     bx, bx
seg000:DEB3                 add     bx, [si+0Ah]
seg000:DEB6                 mov     es, [word ptr si+2]
seg000:DEB9                 push    es
seg000:DEBA                 push    bx
seg000:DEBB                 call    seek_char_pos
seg000:DEC0                 mov     [word ptr bp+length], 1Eh
seg000:DEC5                 mov     [word ptr bp+length+2], 0
seg000:DECA                 push    0
seg000:DECC                 push    1Eh
seg000:DECE                 mov     ax, [bp+var_pos]
seg000:DED1                 cwd
seg000:DED2                 push    dx
seg000:DED3                 push    ax
seg000:DED4                 call    B$MUI4          ; Long integer multiply
seg000:DED9                 mov     [word ptr bp+src_offset], ax
seg000:DEDC                 mov     [word ptr bp+src_offset+2], dx
seg000:DEDF                 mov     si, offset DDIM_buf_wor16_fon_buf
seg000:DEE2                 mov     bx, 682h
seg000:DEE5                 add     bx, [si+0Ah]
seg000:DEE8                 mov     es, [word ptr si+2]
seg000:DEEB                 push    es              ; int
seg000:DEEC                 push    bx              ; dst_offset
seg000:DEED                 lea     bx, [bp+length]
seg000:DEF0                 push    ds
seg000:DEF1                 pop     es
seg000:DEF2                 push    es
seg000:DEF3                 push    bx              ; length
seg000:DEF4                 mov     bx, offset xms_handle_wor16_fon
seg000:DEF7                 push    ds
seg000:DEF8                 pop     es
seg000:DEF9                 push    es
seg000:DEFA                 push    bx              ; src_handle
seg000:DEFB                 lea     bx, [bp+src_offset]
seg000:DEFE                 push    ds
seg000:DEFF                 pop     es
seg000:DF00                 push    es
seg000:DF01                 push    bx              ; src_offset
seg000:DF02                 call    XMS_CopyBlockFromXMS_toAddr
seg000:DF07                 lea     bx, [bp+var_x]
seg000:DF0A                 push    ds
seg000:DF0B                 pop     es
seg000:DF0C                 push    es
seg000:DF0D                 push    bx
seg000:DF0E                 mov     bx, [bp+arg_y]
seg000:DF11                 push    ds
seg000:DF12                 pop     es
seg000:DF13                 push    es
seg000:DF14                 push    bx
seg000:DF15                 mov     si, offset DDIM_buf_wor16_fon_buf
seg000:DF18                 mov     bx, 682h
seg000:DF1B                 add     bx, [si+0Ah]
seg000:DF1E                 mov     es, [word ptr si+2]
seg000:DF21                 push    es
seg000:DF22                 push    bx
seg000:DF23                 mov     bx, [bp+arg_method]
seg000:DF26                 push    ds
seg000:DF27                 pop     es
seg000:DF28                 push    es
seg000:DF29                 push    bx
seg000:DF2A                 mov     bx, [bp+arg_color]
seg000:DF2D                 push    ds
seg000:DF2E                 pop     es
seg000:DF2F                 push    es
seg000:DF30                 push    bx
seg000:DF31                 mov     bx, offset background_color
seg000:DF34                 push    ds
seg000:DF35                 pop     es
seg000:DF36                 push    es
seg000:DF37                 push    bx
seg000:DF38                 mov     bx, offset Addr_videoscreen
seg000:DF3B                 push    ds
seg000:DF3C                 pop     es
seg000:DF3D                 push    es
seg000:DF3E                 push    bx
seg000:DF3F                 call    DrawFont
seg000:DF44                 add     [bp+var_x], 10h
seg000:DF48                 inc     [bp+iStart]
seg000:DF4B                 jmp     continue
seg000:DF4E ; ---------------------------------------------------------------------------
seg000:DF4E
seg000:DF4E skip_one_byte:                          ; CODE XREF: dialog_string+6D↑j
seg000:DF4E                                         ; dialog_string+77↑j
seg000:DF4E                 add     [bp+var_x], 8
seg000:DF52
seg000:DF52 continue:                               ; CODE XREF: dialog_string+137↑j
seg000:DF52                 inc     [bp+iStart]
seg000:DF55                 jmp     output_loop
seg000:DF58 ; ---------------------------------------------------------------------------
seg000:DF58
seg000:DF58 too_low:                                ; CODE XREF: dialog_string+3E↑j
seg000:DF58                 call    B$EXSA          ; clear frame state info
seg000:DF5D                 retf    0Ah
seg000:DF5D endp            dialog_string
seg000:DF5D

seg000:
0030 ; =============== S U B R O U T I N E =======================================
0030
0030 ; Attributes: bp-based frame
0030
0030 proc real_entry near
0030
0030 var_14 = word ptr -14h
0030
0030 push 0
0032
0032 loc_32:
0032 push 1800h
0035
0035 loc_35:
0035 push 1
0037
0037 loc_37:
0037 call B$SSTK
003C
003C loc_3C:
003C push 0
003E
003E loc_3E: ; varargs_ub_lb
003E push 5FFh
0041 push 2 ; cbelem
0043
0043 loc_43: ; ndtyp
0043 push 101h
0046
0046 loc_46: ; pAd
0046 push offset DDIM_palette
0049 call B$DDIM ; DIM a dynamic array
004E push 0
0050
0050 loc_50: ; varargs_ub_lb
0050 push 7
0052 push 4 ; cbelem
0054
0054 loc_54: ; ndtyp
0054 push 101h
0057
0057 loc_57: ; pAd
0057 push offset DDIM_SB_buf?
005A call B$DDIM ; DIM a dynamic array
005F push 0
0061 push 7FFEh ; varargs_ub_lb
0064
0064 loc_64: ; cbelem
0064 push 2
0066 push 101h ; ndtyp
0069 push offset DDIM_NPC_mgo_decoded_pack ; pAd
006C
006C loc_6C: ; DIM a dynamic array
006C call B$DDIM
0071 push 0
0073 push 7FFEh ; varargs_ub_lb
0076 push 2 ; cbelem
0078
0078 loc_78: ; ndtyp
0078 push 101h
007B
007B loc_7B: ; pAd
007B push offset DDIM_buf_glb_gop_or_FADEmap
007E
007E loc_7E: ; DIM a dynamic array
007E call B$DDIM
0083 push 0
0085 push 7FFEh ; varargs_ub_lb
0088 push 2 ; cbelem
008A
008A loc_8A: ; ndtyp
008A push 101h
008D push offset DDIM_buf_glb_map ; pAd
0090
0090 loc_90: ; DIM a dynamic array
0090 call B$DDIM
0095 push 0
0097 push 7FFEh ; varargs_ub_lb
009A push 2 ; cbelem
009C push 101h ; ndtyp
009F push offset DDIM_screen_buf ; pAd
00A2
00A2 loc_A2: ; DIM a dynamic array
00A2 call B$DDIM
00A7 push 0
00A9 push 55EFh ; varargs_ub_lb
00AC
00AC loc_AC: ; cbelem
00AC push 2
00AE push 101h ; ndtyp
00B1 push offset DDIM_buf_glb_1_redraw ; pAd
00B4
00B4 loc_B4: ; DIM a dynamic array
00B4 call B$DDIM
00B9 push 0
00BB
00BB loc_BB: ; varargs_ub_lb
00BB push 3907h
00BE push 2 ; cbelem
00C0 push 101h ; ndtyp
00C3 push offset DDIM_role_mgo_decoded_pack_or_battle_ico ; pAd
00C6 call B$DDIM ; DIM a dynamic array
00CB
00CB loc_CB:
00CB push 0
00CD push 0A27h ; varargs_ub_lb
00D0 push 2 ; cbelem
00D2 push 101h ; ndtyp
00D5 push offset DDIM_wor16_asc ; pAd
00D8
00D8 loc_D8: ; DIM a dynamic array
00D8 call B$DDIM
00DD push 0
00DF push 350h ; varargs_ub_lb
00E2
00E2 loc_E2: ; cbelem
00E2 push 2
00E4 push 101h ; ndtyp
00E7 push offset DDIM_buf_wor16_fon_buf ; pAd
00EA call B$DDIM ; DIM a dynamic array
00EF push 0
00F1
00F1 loc_F1: ; varargs_ub_lb
00F1 push 257h
00F4 push 0Ah ; cbelem
00F6 push 101h ; ndtyp
00F9 push offset DDIM_word_dat ; pAd
00FC
00FC loc_FC: ; DIM a dynamic array
00FC call B$DDIM
0101 push 0
0103 push 95h ; varargs_ub_lb
0106 push 2 ; cbelem
0108 push 101h ; ndtyp
010B push offset DDIM_data@C_dialog_wait_icon ; pAd
010E
010E loc_10E: ; DIM a dynamic array
010E call B$DDIM
0113 push 0
0115 push 0Bh ; varargs_ub_lb
0117 push 0Ah ; cbelem
0119 push 101h ; ndtyp
011C push offset DDIM_sth_about_battle_row_10 ; pAd
011F call B$DDIM ; DIM a dynamic array
0124 push 1
0126 push 12Ch ; varargs_ub_lb
0129 push 8 ; cbelem
012B push 101h ; ndtyp
012E
012E loc_12E: ; pAd
012E push offset DDIM_sss@1_scene_def
0131
0131 loc_131: ; DIM a dynamic array
0131 call B$DDIM
0136 push 0
0138
0138 loc_138: ; varargs_ub_lb
0138 push 9
013A push 2 ; cbelem
013C push 101h ; ndtyp
013F
013F loc_13F: ; pAd
013F push offset DDIM_buf_SETUP_DAT
0142
0142 loc_142: ; DIM a dynamic array
0142 call B$DDIM
0147
0147 loc_147:
0147 push 0
0149 push 6Ch ; varargs_ub_lb
014B push 2 ; cbelem
014D push 101h ; ndtyp
0150 push offset DDIM_keybuf ; pAd
0153 call B$DDIM ; DIM a dynamic array
0158 push 0
015A push 4
015C push 0
015E push 13h ; varargs_ub_lb
0160 push 4 ; cbelem
0162 push 102h ; ndtyp
0165 push offset DDIM_data@6_uplevel_theurgy ; pAd
0168 call B$DDIM ; DIM a dynamic array
016D push 0
016F
016F loc_16F:
016F push 8
0171 push 0
0173 push 14h ; varargs_ub_lb
0175 push 2 ; cbelem
0177 push 102h ; ndtyp
017A push offset DDIM_data@0_shop ; pAd
017D
017D loc_17D: ; DIM a dynamic array
017D call B$DDIM
0182 push 0
0184 push 4 ; varargs_ub_lb
0186 push 2 ; cbelem
0188 push 101h ; ndtyp
018B push offset DDIM_x_off_fff0_fff0_10_10 ; pAd
018E call B$DDIM ; DIM a dynamic array
0193 push 0
0195 push 4 ; varargs_ub_lb
0197 push 2 ; cbelem
0199 push 101h ; ndtyp
019C push offset DDIM_y_off_8_fff8_fff8_8 ; pAd
019F call B$DDIM ; DIM a dynamic array
01A4 push 0
01A6 push 4 ; varargs_ub_lb
01A8 push 2 ; cbelem
01AA push 101h ; ndtyp
01AD push offset DDIM_x_block_off_ffff_ffff_1_1 ; pAd
01B0 call B$DDIM ; DIM a dynamic array
01B5 push 0
01B7 push 4 ; varargs_ub_lb
01B9 push 2 ; cbelem
01BB push 101h ; ndtyp
01BE push offset DDIM_y_block_off_1_ffff_ffff_1 ; pAd
01C1 call B$DDIM ; DIM a dynamic array
01C6 push 0
01C8 push 4 ; varargs_ub_lb
01CA push 4 ; cbelem
01CC push 101h ; ndtyp
01CF push offset DDIM_battletime_role_HP_MP ; pAd
01D2 call B$DDIM ; DIM a dynamic array
01D7 push 0
01D9 push 4 ; varargs_ub_lb
01DB push 2 ; cbelem
01DD push 101h ; ndtyp
01E0 push offset DDIM_battletime_enemy_HP ; pAd
01E3 call B$DDIM ; DIM a dynamic array
01E8 push 0
01EA push 4 ; varargs_ub_lb
01EC push 0Ah ; cbelem
01EE push 101h ; ndtyp
01F1 push offset DDIM_RPG_team_positions ; pAd
01F4 call B$DDIM ; DIM a dynamic array
01F9 push 0
01FB push 4 ; varargs_ub_lb
01FD push 6 ; cbelem
01FF push 101h ; ndtyp
0202 push offset DDIM_RPG_team_trace ; pAd
0205 call B$DDIM ; DIM a dynamic array
020A push 0
020C push 0FFh ; varargs_ub_lb
020F push 2 ; cbelem
0211 push 101h ; ndtyp
0214 push offset DDIM_buf_common_short ; pAd
0217 call B$DDIM ; DIM a dynamic array
021C push 0
021E push 5 ; varargs_ub_lb
0220 push 2 ; cbelem
0222 push 101h ; ndtyp
0225 push offset DDIM_fadegap_031524 ; pAd
0228 call B$DDIM ; DIM a dynamic array
022D push 0
022F push 63h ; varargs_ub_lb
0231 push 2 ; cbelem
0233 push 101h ; ndtyp
0236 push offset DDIM_buf_common ; pAd
0239 call B$DDIM ; DIM a dynamic array
023E push 0
0240 push 9 ; varargs_ub_lb
0242 push 2 ; cbelem
0244 push 101h ; ndtyp
0247 push offset DDIM_vs_id_table ; pAd
024A call B$DDIM ; DIM a dynamic array
024F push 0
0251 push 0Fh ; varargs_ub_lb
0253
0253 loc_253: ; cbelem
0253 push 2
0255 push 101h ; ndtyp
0258 push offset DDIM_posXs ; pAd
025B call B$DDIM ; DIM a dynamic array
0260 push 0
0262 push 0Fh ; varargs_ub_lb
0264
0264 loc_264: ; cbelem
0264 push 2
0266 push 101h ; ndtyp
0269 push offset DDIM_posYs ; pAd
026C call B$DDIM ; DIM a dynamic array
0271 push 0
0273 push 7 ; varargs_ub_lb
0275 push 0Ah ; cbelem
0277 push 101h ; ndtyp
027A push offset DDIM_role_attack_table ; pAd
027D call B$DDIM ; DIM a dynamic array
0282 push 0
0284 push 4 ; varargs_ub_lb
0286 push 1Eh ; cbelem
0288 push 101h ; ndtyp
028B push offset DDIM_battle_enemy_data_etc ; pAd
028E
028E loc_28E: ; DIM a dynamic array
028E call B$DDIM
0293 push 0
0295 push 9 ; varargs_ub_lb
0297 push 18h ; cbelem
0299 push 101h ; ndtyp
029C push offset DDIM_thisbattle_role_data_etc ; pAd
029F
029F loc_29F: ; DIM a dynamic array
029F call B$DDIM
02A4 push 1
02A6 push 5 ; varargs_ub_lb
02A8 push 2 ; cbelem
02AA push 101h ; ndtyp
02AD push offset DDIM_theurgy_pos_X? ; pAd
02B0 call B$DDIM ; DIM a dynamic array
02B5 push 1
02B7 push 5 ; varargs_ub_lb
02B9 push 2 ; cbelem
02BB push 101h ; ndtyp
02BE
02BE loc_2BE: ; pAd
02BE push offset DDIM_theurgy_pos_Y?
02C1 call B$DDIM ; DIM a dynamic array
02C6 push 1
02C8 push 5 ; varargs_ub_lb
02CA push 2 ; cbelem
02CC push 101h ; ndtyp
02CF
02CF loc_2CF: ; pAd
02CF push offset DDIM_summon_effect?
02D2 call B$DDIM ; DIM a dynamic array
02D7 push 0
02D9 push 4 ; varargs_ub_lb
02DB push 2 ; cbelem
02DD push 101h ; ndtyp
02E0 push offset DDIM_2FAA0 ; pAd
02E3 call B$DDIM ; DIM a dynamic array
02E8 push 0
02EA push 4 ; varargs_ub_lb
02EC push 2 ; cbelem
02EE push 101h ; ndtyp
02F1 push offset DDIM_2FACE ; pAd
02F4 call B$DDIM ; DIM a dynamic array
02F9 push 0
02FB push 4 ; varargs_ub_lb
02FD push 2 ; cbelem
02FF push 101h ; ndtyp
0302 push offset DDIM_instrum_icon_x_offs ; pAd
0305 call B$DDIM ; DIM a dynamic array
030A push 0
030C push 4 ; varargs_ub_lb
030E push 2 ; cbelem
0310
0310 loc_310: ; ndtyp
0310 push 101h
0313 push offset DDIM_instrum_icon_y_offs ; pAd
0316 call B$DDIM ; DIM a dynamic array
031B push 0
031D push 4 ; varargs_ub_lb
031F
031F loc_31F: ; cbelem
031F push 46h
0321 push 101h ; ndtyp
0324 push offset DDIM_thisbattle_enemy_data ; pAd
0327 call B$DDIM ; DIM a dynamic array
032C push 0
032E
032E loc_32E:
032E push 4
0330 push 0
0332 push 4 ; varargs_ub_lb
0334 push 4 ; cbelem
0336 push 102h ; ndtyp
0339 push offset DDIM_data@D_enemy_position ; pAd
033C
033C loc_33C: ; DIM a dynamic array
033C call B$DDIM
0341 push 0
0343 push 4
0345 push 0
0347 push 0Fh ; varargs_ub_lb
0349 push 2 ; cbelem
034B push 102h ; ndtyp
034E push offset DDIM_role_status ; pAd
0351 call B$DDIM ; DIM a dynamic array
0356 push 0
0358 push 4
035A push 0
035C push 0Fh ; varargs_ub_lb
035E push 2 ; cbelem
0360 push 102h ; ndtyp
0363 push offset DDIM_enemy_status ; pAd
0366 call B$DDIM ; DIM a dynamic array
036B push 0
036D push 4
036F push 0
0371 push 0Fh ; varargs_ub_lb
0373 push 4 ; cbelem
0375 push 102h ; ndtyp
0378 push offset DDIM_role_poison_stack ; pAd
037B call B$DDIM ; DIM a dynamic array
0380 push 0
0382 push 4
0384 push 0
0386 push 0Fh ; varargs_ub_lb
0388 push 4 ; cbelem
038A push 102h ; ndtyp
038D push offset DDIM_enemy_poison_stack ; pAd
0390 call B$DDIM ; DIM a dynamic array
0395 push 0
0397 push 257h ; varargs_ub_lb
039A push 0Ch ; cbelem
039C push 101h ; ndtyp
039F push offset DDIM_sss@2_object_defination ; pAd
03A2 call B$DDIM ; DIM a dynamic array
03A7 push 0
03A9 push 0FFh ; varargs_ub_lb
03AC push 6 ; cbelem
03AE push 101h ; ndtyp
03B1 push offset DDIM_items ; pAd
03B4 call B$DDIM ; DIM a dynamic array
03B9 push 0
03BB push 5
03BD push 0Bh
03BF push 11h
03C1 push 11h
03C3 push 1Eh ; varargs_ub_lb
03C5 push 2 ; cbelem
03C7 push 103h ; ndtyp
03CA push offset DDIM_role_parts_attr ; pAd
03CD call B$DDIM ; DIM a dynamic array
03D2 push 0
03D4 push 5
03D6 push 0
03D8 push 4Ah ; varargs_ub_lb
03DA
03DA loc_3DA: ; cbelem
03DA push 2
03DC push 102h ; ndtyp
03DF push offset DDIM_data@3_our_data ; pAd
03E2 call B$DDIM ; DIM a dynamic array
03E7 push 0
03E9 push 5
03EB push 0
03ED push 7 ; varargs_ub_lb
03EF push 8 ; cbelem
03F1 push 102h ; ndtyp
03F4 push offset DDIM_RPG_kinds_of_exps ; pAd
03F7 call B$DDIM ; DIM a dynamic array
03FC push 0
03FE push 0A0h ; varargs_ub_lb
0401 push 20h ; cbelem
0403 push 101h ; ndtyp
0406 push offset DDIM_evt_obj_curr_scene ; pAd
0409 call B$DDIM ; DIM a dynamic array
040E push 0
0410 push 9 ; varargs_ub_lb
0412 push 4 ; cbelem
0414 push 101h ; ndtyp
0417 push offset DDIM_data@B_unknown ; pAd
041A call B$DDIM ; DIM a dynamic array
041F push 0
0421 push 1Fh ; varargs_ub_lb
0423 push 4 ; cbelem
0425 push 101h ; ndtyp
0428 push offset DDIM_buf_index ; pAd
042B call B$DDIM ; DIM a dynamic array
0430 push 0
0432 push 0 ; varargs_ub_lb
0434 push 20h ; cbelem
0436 push 101h ; ndtyp
0439 push offset DDIM_theurgy_data ; pAd
043C call B$DDIM ; DIM a dynamic array
0441 push 0
0443 push 4 ; varargs_ub_lb
0445 push 2 ; cbelem
0447 push 101h ; ndtyp
044A push offset DDIM_21043_enemy_sequence ; pAd
044D call B$DDIM ; DIM a dynamic array
0452
0452 ALL_DDIMed: ; returns number of seconds past midnight of current day.
0452 call B$TIMR
0457 mov si, ax
0459 fld [dword ptr si] ; (emulator call)
045C sub sp, 8
045F mov bx, sp
0461 fstp [qword ptr bx] ; (emulator call)
0461 ; 将时间入栈
0464 wait ; (emulator call)
0466 call B$RNZP ; RANDOMIZE statement
046B push offset BSTR_SETUP_DAT ; psdSource
046E push offset filename_to_open ; psdDest
0471 call B$SAS1 ; String assignment
0476 mov si, offset DDIM_buf_SETUP_DAT
0479 xor bx, bx
047B add bx, [si+0Ah]
047E mov es, [word ptr si+2]
0481 mov ax, es
0483 mov [ds:buf_setup_dat], ax
0486 push offset filename_to_open ; argu_buffer
0489 push offset buf_setup_dat ; int
048C call ReadFile_toseg ; setup.dat
0491 push offset BSTR_CHECK_CD_ROM
0494 call B$PSSD ; Print a$; |
0499 mov [ds:CDROM_func0_checking], 0
049F mov bx, offset CDROM_func0_checking
04A2 push ds
04A3 pop es
04A4 push es
04A5 push bx ; func_id
04A6 mov bx, offset CDriver
04A9 push ds
04AA pop es
04AB push es
04AC push bx ; __int32
04AD call CDROM_functions
04B2 cmp [ds:this_step_frame+1], 0 ; Modified_eliminate CDROM detection
04B7 jge short CDROM_Found
04B9
04B9 loc_4B9:
04B9 push offset BSTR_NotFound
04BC call B$PESD ; Print a$ |
04C1 call far ptr B$CEND ; Termination routine for the runtime core.
04C6 ; ---------------------------------------------------------------------------
04C6
04C6 CDROM_Found: ; CODE XREF: real_entry+487↑j
04C6 mov [ds:CDROM_func5_GetTracks], 5
04CC mov bx, offset CDROM_func5_GetTracks
04CF push ds
04D0 pop es
04D1 push es
04D2 push bx ; func_id
04D3 mov bx, offset CD_tracks
04D6 push ds
04D7 pop es
04D8 push es
04D9 push bx ; __int32
04DA call CDROM_functions
04DF cmp [ds:CD_tracks], 9
04E4 jmp short CDROM_Ready
04E6 ; ---------------------------------------------------------------------------
04E6
04E6 ModifyEXE_eliminated_CheckTracks:
04E6 push offset BSTR_NotReady
04E9 call B$PESD ; Print a$ |
04EE call far ptr B$CEND ; Termination routine for the runtime core.
04F3 ; ---------------------------------------------------------------------------
04F3
04F3 CDROM_Ready: ; CODE XREF: real_entry+4B4↑j
04F3 mov ax, [ds:CDriver]
04F6 add ax, 'A'
04F9 push ax ; val
04FA call B$FCHR ; CHR$ function
04FF push ax ; psd1_dst
0500 push offset BSTR__ ; psd2
0503 call B$SCT1 ; Concatenate strings
0508 push ax ; psdSource
0509 push offset BSTR_CDriver ; psdDest
050C call B$SAS1 ; String assignment
0511 push offset BSTR_in
0514 call B$PSSD ; Print a$; |
0519 push offset BSTR_CDriver ; flag
051C call B$PESD ; Print a$ |
0521 push offset BSTR_CDriver ; psd2
0524 push offset BSTR_CDriver ; psd1
0527 push offset BSTR_fan ; psDst
052A call B$SACT ; Concatenate strings
052F mov si, offset DDIM_buf_SETUP_DAT
0532 mov bx, 8
0535 add bx, [si+DDIM.offset]
0538 mov es, [si+DDIM.header.segment]
053B mov ax, [es:bx]
053E and ax, 4
0541 or ax, ax
0543 mov cx, 0
0546 jz short no_CD_music
0548 dec cx
0549
0549 no_CD_music: ; CODE XREF: real_entry+516↑j
0549 mov [ds:mask_use_CD], cx
054D mov bx, 12h
0550 add bx, [si+DDIM.offset]
0553 mov es, [si+DDIM.header.segment]
0556 mov ax, [es:bx]
0559 and ax, ax
055B jz short no_useCD_forcing
055D push offset BSTR_CDriver ; psdSource
0560 push offset BSTR_CDriver_If_min_inst ; psdDest
0563 call B$SAS1 ; String assignment
0568 mov [ds:mask_use_CD], 0
056E jmp next_
0571 ; ---------------------------------------------------------------------------
0571
0571 no_useCD_forcing: ; CODE XREF: real_entry+52B↑j
0571 push offset BSTR_nullstr ; psdSource
0574 push offset BSTR_CDriver_If_min_inst ; psdDest
0577 call B$SAS1 ; String assignment
057C
057C next_: ; CODE XREF: real_entry+53E↑j
057C push 0FFFFh ; int
057E call far ptr B$FRI2 ; FREE function with numeric parameter
0583 mov [word ptr ds:free_bytes], ax
0586 mov [word ptr ds:free_bytes+2], dx
058A push offset BSTR_Free
058D call B$PSSD ; Print a$; |
0592 push [word ptr ds:free_bytes+2]
0596 push [word ptr ds:free_bytes]
059A call B$PSI4 ; Print I4; |
059F push offset BSTR_bytes
05A2 call B$PESD ; Print a$ |
05A7 push [word ptr ds:free_bytes+2] ; op1_h
05AB push [word ptr ds:free_bytes] ; op1_l
05AF push 0 ; op2_h
05B1 push 1000h ; op2_l
05B4 call B$CPI4 ; long integer compare
05B9 jge short mem_enough
05BB call B$BEEP ; BEEP stmt
05C0 push offset BSTR_ErrorFreeMemoryIsNotEnough570K
05C3 call B$PESD ; Print a$ |
05C8
05C8 loc_5C8: ; Termination routine for the runtime core.
05C8 call far ptr B$CEND
05CD ; ---------------------------------------------------------------------------
05CD
05CD mem_enough: ; CODE XREF: real_entry+589↑j
05CD mov bx, offset XMS_Driver_Present
05D0 push ds
05D1 pop es
05D2 push es ; int
05D3 push bx ; flag
05D4 call XMS_Init
05D9
05D9 loc_5D9:
05D9 mov ax, [ds:XMS_Driver_Present]
05DC and ax, ax
05DE jnz short next
05E0 jmp no_xms_availble
05E3 ; ---------------------------------------------------------------------------
05E3
05E3 next: ; CODE XREF: real_entry+5AE↑j
05E3 mov bx, offset XMS_Memory_Amount
05E6 push ds
05E7 pop es
05E8 push es ; int
05E9 push bx ; flag
05EA call XMS_Query_Amount
05EF push offset BSTR_XMS_eq
05F2 call B$PSSD ; Print a$; |
05F7 push [ds:XMS_Memory_Amount]
05FB call B$PSI2 ; Print I2; |
0600 push offset BSTR_k
0603 call B$PESD ; Print a$ |
0608 cmp [ds:XMS_Memory_Amount], 33Eh
060E jge short next2
0610 push offset BSTR_ErrorXmsIsNotEnough
0613 call B$PESD ; Print a$ |
0618 call far ptr B$CEND ; Termination routine for the runtime core.
061D ; ---------------------------------------------------------------------------
061D
061D next2: ; CODE XREF: real_entry+5DE↑j
061D call Xms_alloc_and_Load_sfx_music ; BALL,VOC
0622 jmp next3
0625 ; ---------------------------------------------------------------------------
0625
0625 no_xms_availble: ; CODE XREF: real_entry+5B0↑j
0625 push offset BSTR_XMSNotFound
0628 call B$PESD ; Print a$ |
062D call far ptr B$CEND ; Termination routine for the runtime core.
0632 ; ---------------------------------------------------------------------------
0632
0632 next3: ; CODE XREF: real_entry+5F2↑j
0632 call replace_timer_interrupt
0637 call replace_keyboard_interrupt
063C
063C loc_63C:
063C mov si, offset DDIM_buf_SETUP_DAT
063F mov bx, 8
0642 add bx, [si+DDIM.offset]
0645 mov es, [si+DDIM.header.segment]
0648 mov ax, [es:bx]
064B
064B loc_64B:
064B and ax, 3
064E mov [ds:music_mode], ax
0651 mov [ds:alloc_bytes], 5DBh
0657 mov [ds:midi_port], 0
065D cmp ax, 1
0660 jz short use_sb_not_sfx
0662 jmp next4
0665 ; ---------------------------------------------------------------------------
0665
0665 use_sb_not_sfx: ; CODE XREF: real_entry+630↑j
0665 mov [ds:save_ff?], 0FFh
066B mov [ds:save_0???], 0
0671 mov bx, offset save_ff?
0674 push ds
0675 pop es
0676 push es
0677 push bx
0678 mov bx, offset save_0???
067B push ds
067C pop es
067D push es
067E push bx
067F mov bx, offset CD_tracks
0682 push ds
0683 pop es
0684 push es
0685 push bx
0686 call setup_RIX?
068B push [word ptr ds:free_bytes+2] ; op1_h
068F
068F loc_68F: ; op1_l
068F push [word ptr ds:free_bytes]
0693 push 0 ; op2_h
0695 push 2800h ; op2_l
0698 call B$CPI4 ; long integer compare
069D jle short no_rix_music
069F
069F loc_69F:
069F mov [ds:alloc_bytes], 13EBh
06A5 push offset BSTR_FM_OK
06A8 call B$PESD ; Print a$ |
06AD jmp next4
06B0 ; ---------------------------------------------------------------------------
06B0
06B0 no_rix_music: ; CODE XREF: real_entry+66D↑j
06B0 mov [ds:music_mode], 0
06B6
06B6 next4: ; CODE XREF: real_entry+632↑j
06B6 ; real_entry+67D↑j
06B6 push 0
06B8 push [ds:alloc_bytes] ; varargs_ub_lb
06BC push 2 ; cbelem
06BE push 101h ; ndtyp
06C1 push offset DDIM_buf_MPU401 ; flag
06C4 call B$DDIM ; DIM a dynamic array
06C9 push 0FFFFh ; int
06CB call far ptr B$FRI2 ; FREE function with numeric parameter
06D0 mov [word ptr ds:free_bytes], ax
06D3 mov [word ptr ds:free_bytes+2], dx
06D7 mov ax, [ds:music_mode]
06DA and ax, 2
06DD and ax, ax
06DF jz short no_midi_music
06E1 mov si, offset DDIM_buf_SETUP_DAT
06E4 mov bx, 10h
06E7 add bx, [si+DDIM.offset]
06EA mov es, [si+DDIM.header.segment]
06ED mov ax, [es:bx]
06F0 mov [ds:midi_port], ax
06F3
06F3 no_midi_music: ; CODE XREF: real_entry+6AF↑j
06F3 mov ax, [ds:midi_port]
06F6 and ax, ax
06F8 jnz short has_midi
06FA jmp next_2
06FD ; ---------------------------------------------------------------------------
06FD
06FD has_midi: ; CODE XREF: real_entry+6C8↑j
06FD push offset BSTR_MPU401_DRV ; psdSource
0700 push offset BSTR_MPU401 ; psdDest
0703 call B$SAS1 ; String assignment
0708 mov si, offset DDIM_buf_MPU401
070B xor bx, bx
070D add bx, [si+DDIM.offset]
0710 mov es, [si+DDIM.header.segment]
0713 mov ax, es
0715 mov [ds:mpu401drv_seg], ax
0718 push offset BSTR_MPU401 ; argu_buffer
071B push offset mpu401drv_seg ; int
071E
071E loc_71E: ; MPU401.drv
071E call ReadFile_toseg
0723 mov [ds:mpu401_offset], 100h ; MPU401.drv代码开始的地方
0729 mov bx, offset mpu401_offset
072C push ds
072D pop es
072E push es
072F push bx ; argu_offset
0730
0730 loc_730:
0730 mov si, offset DDIM_buf_MPU401
0733 xor bx, bx
0735 add bx, [si+DDIM.offset]
0738 mov es, [si+DDIM.header.segment]
073B push es
073C push bx ; argu_pointer
073D mov bx, offset midi_port
0740 push ds
0741 pop es
0742 push es
0743 push bx ; __int32
0744 call setup_MIDI?
0749 mov [ds:ptr_6], 6
074F mov [ds:ptr_1], 1
0755 mov bx, offset ptr_6
0758 push ds
0759 pop es
075A push es
075B push bx ; argu_offset
075C mov bx, offset ptr_1
075F push ds
0760 pop es
0761 push es
0762 push bx ; argu_pointer
0763 mov bx, offset CD_tracks
0766 push ds
0767 pop es
0768 push es
0769 push bx ; __int32
076A call setup_MIDI?
076F mov [ds:MIDI_parm2], 3
0775 mov [ds:MIDI_parm1], 80
077B mov bx, offset MIDI_parm2
077E push ds
077F pop es
0780 push es
0781 push bx ; argu_offset
0782 mov bx, offset MIDI_parm1
0785 push ds
0786 pop es
0787 push es
0788 push bx ; argu_pointer
0789 mov bx, offset CD_tracks
078C push ds
078D pop es
078E push es
078F push bx ; __int32
0790 call setup_MIDI?
0795 push offset BSTR_Midi_OK
0798 call B$PESD ; Print a$ |
079D
079D next_2: ; CODE XREF: real_entry+6CA↑j
079D cmp [ds:music_mode], 0
07A2 mov ax, 0
07A5 jz short make_midi_mask
07A7 dec ax
07A8
07A8 make_midi_mask: ; CODE XREF: real_entry+775↑j
07A8 or ax, [ds:mask_use_CD]
07AC mov [ds:use_cd], ax
07AF mov [ds:sfx_result], 0
07B5 mov si, offset DDIM_buf_SETUP_DAT
07B8 mov bx, 0Ah
07BB add bx, [si+DDIM.offset]
07BE mov es, [si+DDIM.header.segment]
07C1 cmp [word ptr es:bx], 0
07C5 mov ax, 0
07C8 jz short no_sound_effect
07CA dec ax
07CB
07CB no_sound_effect: ; CODE XREF: real_entry+798↑j
07CB mov bx, 8
07CE add bx, [si+DDIM.offset]
07D1 mov es, [si+DDIM.header.segment]
07D4 and ax, [es:bx]
07D7 and ax, 1
07DA and ax, ax
07DC jnz short has_sb_sfx
07DE jmp next_3
07E1 ; ---------------------------------------------------------------------------
07E1
07E1 has_sb_sfx: ; CODE XREF: real_entry+7AC↑j
07E1 mov [ds:sfx_func_id_4], 4
07E7 mov bx, offset sfx_func_id_4
07EA push ds
07EB pop es
07EC push es
07ED push bx
07EE mov si, offset DDIM_buf_SETUP_DAT
07F1 mov bx, 0Ch ; IRQ
07F4 add bx, [si+DDIM.offset]
07F7 mov es, [si+DDIM.header.segment]
07FA push es
07FB push bx
07FC call sfx_func?
0801 mov [ds:sfx_func_id_5], 5
0807 mov bx, offset sfx_func_id_5
080A push ds
080B pop es
080C push es
080D push bx
080E mov si, offset DDIM_buf_SETUP_DAT
0811 mov bx, 0Eh ; I/0 port
0814 add bx, [si+DDIM.offset]
0817 mov es, [si+DDIM.header.segment]
081A push es
081B push bx
081C call sfx_func?
0821 mov [ds:sfx_func_id_0], 0
0827 mov bx, offset sfx_func_id_0
082A push ds
082B pop es
082C push es
082D push bx
082E mov bx, offset sfx_result
0831 push ds
0832 pop es
0833 push es
0834 push bx
0835 call sfx_func?
083A mov ax, [ds:sfx_result]
083D and ax, ax
083F jz short next_3
0841 mov [ds:flag_has_sfx], 0FFFFh
0847 push offset BSTR_Voice_OK
084A call B$PESD ; Print a$ |
084F
084F next_3: ; CODE XREF: real_entry+7AE↑j
084F ; real_entry+80F↑j
084F mov si, offset DDIM_buf_SETUP_DAT
0852 mov bx, 8
0855 add bx, [si+0Ah]
0858 mov es, [word ptr si+2]
085B mov ax, [ds:music_mode]
085E mov [es:bx], ax
0861 push offset BSTR_M_MSG ; sdName
0864 push 1 ; channel
0866 push 0FFFFh ; cbRecord
0868 push 20h ; ModeAccessLock
086A call B$OPEN ; open a disk file using new syntax
086F push offset BSTR_CDriver_If_min_inst ; psd1_dst
0872 push offset BSTR_RNG_MKF ; psd2
0875 call B$SCT1 ; Concatenate strings
087A push ax ; psdSource
087B push offset RNG_MKF ; psdDest
087E call B$SAS1 ; String assignment
0883 mov [ds:RNG_MKF.file_handle], 0
0889 push offset RNG_MKF ; open_method
088C push offset RNG_MKF.file_handle ; int
088F call Open_File
0894 mov [ds:RNG_MKF.pointee+6], ax
0897 mov ax, [ds:RNG_MKF.pointee+6]
089A mov [ds:rng_mkf_fp], ax
089D push offset BSTR_CDriver_If_min_inst ; psd1_dst
08A0 push offset BSTR_MGO_MKF ; psd2
08A3 call B$SCT1 ; Concatenate strings
08A8 push ax ; psdSource
08A9 push offset MGO_MKF ; psdDest
08AC call B$SAS1 ; String assignment
08B1 mov [ds:MGO_MKF.file_handle], 0
08B7 push offset MGO_MKF ; open_method
08BA push offset MGO_MKF.file_handle ; int
08BD call Open_File
08C2 mov [ds:MGO_MKF.pointee+6], ax
08C5 mov ax, [ds:MGO_MKF.pointee+6]
08C8 mov [ds:mgo_mkf_fp], ax
08CB push offset BSTR_CDriver_If_min_inst ; psd1_dst
08CE push offset BSTR_F_MKF ; psd2
08D1 call B$SCT1 ; Concatenate strings
08D6 push ax ; psdSource
08D7 push offset F_MKF ; psdDest
08DA call B$SAS1 ; String assignment
08DF mov [ds:F_MKF.file_handle], offset byte_2F380
08E5 push offset F_MKF ; open_method
08E8 push offset F_MKF.file_handle ; int
08EB call Open_File ; F
08F0 mov [ds:F_MKF.pointee+6], ax
08F3 mov ax, [ds:F_MKF.pointee+6]
08F6 mov [ds:f_mkf_fp], ax
08F9 push offset BSTR_CDriver_If_min_inst ; psd1_dst
08FC push offset BSTR_ABC_MKF ; psd2
08FF call B$SCT1 ; Concatenate strings
0904 push ax ; psdSource
0905 push offset ABC_MKF ; psdDest
0908 call B$SAS1 ; String assignment
090D mov [ds:ABC_MKF.file_handle], 0
0913 push offset ABC_MKF ; open_method
0916 push offset ABC_MKF.file_handle ; int
0919 call Open_File ; ABC
091E mov [ds:ABC_MKF.pointee+6], ax
0921 mov ax, [ds:ABC_MKF.pointee+6]
0924 mov [ds:abc_mkf_fp], ax
0927 call Load_system_files ; WOR16s,sss.mkf,data.mkf
092C mov si, offset DDIM_21043_enemy_sequence
092F xor bx, bx
0931 add bx, [si+DDIM.offset]
0934 mov es, [si+DDIM.header.segment]
0937 mov [word ptr es:bx], 2
093C mov bx, 2
093F add bx, [si+DDIM.offset]
0942 mov es, [si+DDIM.header.segment]
0945 mov [word ptr es:bx], 1
094A mov bx, 4
094D add bx, [si+DDIM.offset]
0950 mov es, [si+DDIM.header.segment]
0953 mov [word ptr es:bx], 0
0958 mov bx, 6
095B add bx, [si+DDIM.offset]
095E mov es, [si+DDIM.header.segment]
0961 mov [word ptr es:bx], 4
0966 mov bx, 8
0969 add bx, [si+DDIM.offset]
096C mov es, [si+DDIM.header.segment]
096F mov [word ptr es:bx], 3
0974 mov si, offset DDIM_instrum_icon_x_offs
0977 xor bx, bx
0979 add bx, [si+DDIM.offset]
097C mov es, [si+DDIM.header.segment]
097F mov [word ptr es:bx], 1Ch
0984 mov si, offset DDIM_instrum_icon_y_offs
0987 xor bx, bx
0989 add bx, [si+DDIM.offset]
098C mov es, [si+DDIM.header.segment]
098F mov [word ptr es:bx], 8Ch
0994 mov si, offset DDIM_instrum_icon_x_offs
0997 mov bx, 2
099A add bx, [si+DDIM.offset]
099D mov es, [si+DDIM.header.segment]
09A0 mov [word ptr es:bx], 0
09A5 mov si, offset DDIM_instrum_icon_y_offs
09A8 mov bx, 2
09AB add bx, [si+DDIM.offset]
09AE mov es, [si+DDIM.header.segment]
09B1 mov [word ptr es:bx], 9Bh
09B6 mov si, offset DDIM_instrum_icon_x_offs
09B9 mov bx, 4
09BC add bx, [si+DDIM.offset]
09BF mov es, [si+DDIM.header.segment]
09C2 mov [word ptr es:bx], 37h
09C7 mov si, offset DDIM_instrum_icon_y_offs
09CA mov bx, 4
09CD add bx, [si+DDIM.offset]
09D0 mov es, [si+DDIM.header.segment]
09D3 mov [word ptr es:bx], 9Bh
09D8 mov si, offset DDIM_instrum_icon_x_offs
09DB mov bx, 6
09DE add bx, [si+DDIM.offset]
09E1 mov es, [si+DDIM.header.segment]
09E4 mov [word ptr es:bx], 1Bh
09E9 mov si, offset DDIM_instrum_icon_y_offs
09EC mov bx, 6
09EF add bx, [si+DDIM.offset]
09F2 mov es, [si+DDIM.header.segment]
09F5 mov [word ptr es:bx], 0AAh
09FA mov si, offset DDIM_fadegap_031524
09FD xor bx, bx
09FF add bx, [si+DDIM.offset]
0A02 mov es, [si+DDIM.header.segment]
0A05 mov [word ptr es:bx], 0
0A0A mov bx, 2
0A0D add bx, [si+DDIM.offset]
0A10 mov es, [si+DDIM.header.segment]
0A13 mov [word ptr es:bx], 3
0A18 mov bx, 4
0A1B add bx, [si+DDIM.offset]
0A1E mov es, [si+DDIM.header.segment]
0A21 mov [word ptr es:bx], 1
0A26 mov bx, 6
0A29 add bx, [si+DDIM.offset]
0A2C mov es, [si+DDIM.header.segment]
0A2F mov [word ptr es:bx], 5
0A34 mov bx, 8
0A37 add bx, [si+DDIM.offset]
0A3A mov es, [si+DDIM.header.segment]
0A3D mov [word ptr es:bx], 2
0A42 mov bx, 0Ah
0A45 add bx, [si+DDIM.offset]
0A48 mov es, [si+DDIM.header.segment]
0A4B mov [word ptr es:bx], 4
0A50 xor ax, ax
0A52 jmp begin
0A55 ; ---------------------------------------------------------------------------
0A55 nop
0A56
0A56 direction_loop: ; CODE XREF: real_entry+AAF↓j
0A56 shl ax, 1
0A58 mov bx, ax
0A5A mov si, offset DDIM_x_off_fff0_fff0_10_10
0A5D add bx, [si+DDIM.offset]
0A60 mov es, [si+DDIM.header.segment]
0A63 push es
0A64 push bx
0A65 mov [bp+var_14], ax
0A68 call libfunc_?
0A6D mov si, offset DDIM_y_off_8_fff8_fff8_8
0A70 mov bx, [bp+var_14]
0A73 mov dx, bx
0A75 add bx, [si+DDIM.offset]
0A78 mov es, [si+DDIM.header.segment]
0A7B push es
0A7C push bx
0A7D call libfunc_?
0A82 mov si, offset DDIM_x_off_fff0_fff0_10_10
0A85 mov bx, [bp+var_14]
0A88 mov dx, bx
0A8A add bx, [si+DDIM.offset]
0A8D mov es, [si+DDIM.header.segment]
0A90 mov ax, [es:bx]
0A93 and ax, ax
0A95 jz short make_x_off
0A97 mov ax, 1
0A9A jge short make_x_off
0A9C neg ax
0A9E
0A9E make_x_off: ; CODE XREF: real_entry+A65↑j
0A9E ; real_entry+A6A↑j
0A9E mov bx, dx
0AA0 mov si, offset DDIM_x_block_off_ffff_ffff_1_1
0AA3 add bx, [si+DDIM.offset]
0AA6 mov es, [si+DDIM.header.segment]
0AA9 mov [es:bx], ax
0AAC mov bx, dx
0AAE mov si, offset DDIM_y_off_8_fff8_fff8_8
0AB1 add bx, [si+DDIM.offset]
0AB4 mov es, [si+DDIM.header.segment]
0AB7 mov ax, [es:bx]
0ABA and ax, ax
0ABC jz short make_y_off
0ABE mov ax, 1
0AC1 jge short make_y_off
0AC3 neg ax
0AC5
0AC5 make_y_off: ; CODE XREF: real_entry+A8C↑j
0AC5 ; real_entry+A91↑j
0AC5 mov bx, dx
0AC7 mov si, offset DDIM_y_block_off_1_ffff_ffff_1
0ACA add bx, [si+DDIM.offset]
0ACD mov es, [si+DDIM.header.segment]
0AD0 mov [es:bx], ax
0AD3 mov ax, [ds:loop_counter]
0AD6 inc ax
0AD7
0AD7 begin: ; CODE XREF: real_entry+A22↑j
0AD7 mov [ds:loop_counter], ax
0ADA cmp ax, 3
0ADD jg short loopend
0ADF jmp direction_loop
0AE2 ; ---------------------------------------------------------------------------
0AE2
0AE2 loopend: ; CODE XREF: real_entry+AAD↑j
0AE2 nop
0AE3 mov [ds:Addr_videoscreen], 0A000h
0AE9 mov [ds:decimal_200], 200
0AEF mov [ds:decimal_320], 320
0AF5 mov [ds:constant_200d], 200
0AFB mov [ds:rng_movie_id], 6
0B01 push offset rng_movie_id
0B04 call setMovie_impl
0B09 mov [ds:rng6_palette], 3
0B0F push offset rng6_palette
0B12 call read_palette
0B17 mov [ds:vga_mode], 13h ; 13h = G 40x25 8x8 320x200 256/256K . A000 VGA,MCGA,ATI VIP
0B1D mov bx, offset vga_mode
0B20 push ds
0B21 pop es
0B22 push es
0B23 push bx
0B24 call Video_Func ; set VGA Mode 13
0B29 mov si, offset DDIM_palette
0B2C xor bx, bx
0B2E add bx, [si+DDIM.offset]
0B31 mov es, [si+DDIM.header.segment]
0B34 push es
0B35 push bx ; palette_ptr
0B36 call set_palette
0B3B mov [ds:rng_startframe], 0
0B41 mov [ds:rng_stopframe], 999
0B47 mov [ds:rng_speed], 25
0B4D push offset rng_startframe
0B50 push offset rng_stopframe
0B53 push offset rng_speed
0B56 call playRNG_impl
0B5B mov [ds:wait_time], 180
0B61 push offset wait_time
0B64 call wait_key
0B69 mov [ds:fade_time_gap], 1
0B6F push offset fade_time_gap
0B72 call fade_out ; 淡出
0B77 call begin_scene ; 云谷鹤峰
0B7C mov ax, [word ptr ds:bytes_leavingxms]
0B7F mov dx, [word ptr ds:bytes_leavingxms+2]
0B83 mov [word ptr ds:curr_subfile_offset], ax
0B86 mov [word ptr ds:curr_subfile_offset+2], dx
0B8A
0B8A loc_B8A:
0B8A mov [ds:RPG_ememy_chase_rate], 1
0B90 mov [ds:RPG_change_chaserate_times], 0
0B96 mov [ds:delay_in_centisecond], 3
0B9C
0B9C loc_B9C:
0B9C mov [ds:palette_id], 0
0BA2 push offset palette_id
0BA5 call read_palette
0BAA mov [ds:music_id], 4
0BB0 mov [ds:music_?], 1
0BB6 push offset music_id
0BB9 push offset music_?
0BBC call play_rix_music
0BC1
0BC1 select_loop: ; CODE XREF: real_entry+C4B↓j
0BC1 mov [ds:fbp_idx], 3Ch ; 一书一剑一葫芦
0BC7 mov [ds:not_align?], 0
0BCD push offset fbp_idx ; argu_gap
0BD0 push offset not_align? ; int
0BD3 call show_fbp
0BD8 mov [ds:fade_time_gap_], 1
0BDE push offset fade_time_gap_
0BE1 call fade_in
0BE6 mov si, offset DDIM_buf_common_short
0BE9 xor bx, bx
0BEB add bx, [si+DDIM.offset]
0BEE mov es, [si+DDIM.header.segment]
0BF1 mov [word ptr es:bx], 7
0BF6 mov bx, 2
0BF9 add bx, [si+DDIM.offset]
0BFC mov es, [si+DDIM.header.segment]
0BFF mov [word ptr es:bx], 8
0C04 mov bx, 200
0C07 add bx, [si+DDIM.offset]
0C0A mov es, [si+DDIM.header.segment]
0C0D mov [word ptr es:bx], 0FFFFh
0C12 mov bx, 202
0C15 add bx, [si+DDIM.offset]
0C18 mov es, [si+DDIM.header.segment]
0C1B mov [word ptr es:bx], 0FFFFh
0C20 mov [ds:par_0], 0
0C26 mov [ds:par_x], 70h
0C2C mov [ds:par_y], 54h
0C32 mov [ds:par_no_frame], 0FFFFh
0C38 mov [ds:par_menus], 2
0C3E push offset par_0
0C41 push offset par_x
0C44 push offset par_y
0C47 push offset par_no_frame
0C4A push offset par_menus
0C4D call menu_select
0C52 mov [ds:flag_menu_loaded?], ax
0C55 mov ax, [ds:flag_menu_loaded?]
0C58 mov [ds:select_result], ax
0C5B mov [ds:flag_to_load], 10000b ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0C61 cmp ax, 1
0C64 jz short next6
0C66 jmp create_new
0C69 ; ---------------------------------------------------------------------------
0C69
0C69 next6: ; CODE XREF: real_entry+C34↑j
0C69 call select_RPG_internal
0C6E mov [ds:tmp], ax
0C71 mov ax, [ds:tmp]
0C74 mov [ds:global_var_menu_selected], ax
0C77 or ax, ax
0C79 jge short next5
0C7B jmp select_loop
0C7E ; ---------------------------------------------------------------------------
0C7E
0C7E next5: ; CODE XREF: real_entry+C49↑j
0C7E mov ax, [ds:global_var_menu_selected]
0C81 inc ax
0C82 mov [ds:rpg_to_load], ax
0C85 push offset rpg_to_load
0C88 call LoadRPG_internal
0C8D cmp [ds:RPG_save_number], 0
0C92 jnz short go_load_map
0C94 jmp create_new
0C97 ; ---------------------------------------------------------------------------
0C97
0C97 go_load_map: ; CODE XREF: real_entry+C62↑j
0C97 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0C9A or ax, 10b
0C9D mov [ds:flag_to_load], ax ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0CA0 jmp gogo_load_map
0CA3 ; ---------------------------------------------------------------------------
0CA3
0CA3 create_new: ; CODE XREF: real_entry+C36↑j
0CA3 ; real_entry+C64↑j
0CA3 mov [ds:scene_to_load], 1
0CA9 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0CAC or ax, 1101b
0CAF mov [ds:flag_to_load], ax ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0CB2 xor ax, ax
0CB4 jmp begin_role
0CB7 ; ---------------------------------------------------------------------------
0CB7 nop
0CB8
0CB8 role_loop: ; CODE XREF: real_entry+D45↓j
0CB8 xor ax, ax
0CBA jmp begin_exp_kind
0CBD ; ---------------------------------------------------------------------------
0CBD nop
0CBE
0CBE exp_loop: ; CODE XREF: real_entry+D36↓j
0CBE or ax, ax
0CC0 jle short primary_exp
0CC2 call B$RND0 ; RND function
0CC7 mov si, ax
0CC9 fld [dword ptr si] ; (emulator call)
0CCC fmul [ds:fp32_2] ; (emulator call)
0CD1 fadd [ds:fp32_2] ; (emulator call)
0CD6 fistp [ds:YJ_1_extracted_len] ; (emulator call)
0CDB wait ; (emulator call)
0CDD call B$RND0 ; RND function
0CE2 mov si, ax
0CE4 fld [dword ptr si] ; (emulator call)
0CE7 fmul [ds:fp32_20] ; (emulator call)
0CEC fistp [ds:random_m20] ; (emulator call)
0CF1 wait ; (emulator call)
0CF3 jmp loop_next
0CF6 ; ---------------------------------------------------------------------------
0CF6
0CF6 primary_exp: ; CODE XREF: real_entry+C90↑j
0CF6 mov [ds:YJ_1_extracted_len], 0
0CFC mov [ds:random_m20], 0
0D02
0D02 loop_next: ; CODE XREF: real_entry+CC3↑j
0D02 mov ax, 6
0D05 imul [ds:DDIM_data@3_our_data.Dimension2.Elements]
0D09 add ax, [ds:loop_counter]
0D0D shl ax, 1
0D0F mov bx, ax
0D11 mov si, offset DDIM_data@3_our_data
0D14 add bx, [si+0Ah]
0D17 mov es, [word ptr si+2]
0D1A mov ax, [es:bx]
0D1D add ax, [ds:YJ_1_extracted_len]
0D21 mov bx, ax
0D23 mov ax, [ds:DDIM_RPG_kinds_of_exps.Dimension2.Elements]
0D26 imul [ds:inner_counter]
0D2A add ax, [ds:loop_counter]
0D2E shl ax, 1
0D30 shl ax, 1
0D32 shl ax, 1
0D34 mov dx, bx
0D36 mov bx, ax
0D38 mov si, offset DDIM_RPG_kinds_of_exps
0D3B add bx, [si+0Ah]
0D3E mov es, [word ptr si+2]
0D41 add bx, 4
0D44 mov [es:bx], dx ; 等级:rnd(2)+2,主等级0。
0D47 mov bx, ax
0D49 mov ax, [ds:random_m20]
0D4C cwd
0D4D add bx, [si+0Ah]
0D50 mov es, [word ptr si+2] ; 经验值：rnd(20)，主经验值0。
0D53 mov [es:bx], ax
0D56 mov [es:bx+2], dx
0D5A
0D5A loc_D5A:
0D5A mov ax, [ds:inner_counter]
0D5D inc ax
0D5E
0D5E begin_exp_kind: ; CODE XREF: real_entry+C8A↑j
0D5E mov [ds:inner_counter], ax
0D61 cmp ax, 7
0D64 jg short go_outer
0D66 jmp exp_loop
0D69 ; ---------------------------------------------------------------------------
0D69
0D69 go_outer: ; CODE XREF: real_entry+D34↑j
0D69 mov ax, [ds:loop_counter]
0D6C
0D6C loc_D6C:
0D6C inc ax
0D6D
0D6D begin_role: ; CODE XREF: real_entry+C84↑j
0D6D mov [ds:loop_counter], ax
0D70 cmp ax, 4
0D73 jg short ok
0D75 jmp role_loop
0D78 ; ---------------------------------------------------------------------------
0D78
0D78 ok: ; CODE XREF: real_entry+D43↑j
0D78 mov [ds:time_gap], 1
0D7E push offset time_gap
0D81 call fade_out
0D86
0D86 gogo_load_map: ; CODE XREF: real_entry+C70↑j
0D86 mov [ds:step_off_x], 10h
0D8C mov [ds:step_off_y], 8
0D92 mov [ds:scanline_top], 0
0D98 mov [ds:coordinate_x_max], 1696
0D9E mov [ds:coordinate_y_max], 1840
0DA4
0DA4 call_change_map: ; CODE XREF: real_entry+DA9↓j
0DA4 ; real_entry:changemap↓j
0DA4 call Load_Data
0DA9
0DA9 mainloop: ; CODE XREF: real_entry+E1E↓j
0DA9 mov [ds:flag_which_key_pressed_], 0
0DAF push offset x_off ; a_updown
0DB2 push offset y_off ; int
0DB5 call process_Key
0DBA mov ax, [ds:key_pressed]
0DBD mov [ds:flag_which_key_pressed_], ax
0DC0 mov [ds:flag_to_load], 0 ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0DC6 mov [ds:flag_trigger?], 0FFFFh
0DCC push offset flag_trigger?
0DCF call GameLoop_OneCycle
0DD4 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0DD7 and ax, ax
0DD9 jnz short call_change_map
0DDB mov [ds:bytes_to_clear], 2000h
0DE1 mov si, offset DDIM_buf_glb_1_redraw
0DE4 xor bx, bx
0DE6 add bx, [si+0Ah]
0DE9 mov es, [word ptr si+2]
0DEC push es ; int
0DED push bx ; ptr
0DEE mov bx, offset bytes_to_clear
0DF1 push ds
0DF2 pop es
0DF3 push es
0DF4 push bx ; bytes
0DF5 call clear_DDIM
0DFA call clear_spirite_array
0DFF
0DFF loc_DFF:
0DFF call calc_team_walking
0E02 call our_team_setdraw
0E07 call visible_NPC_movment_setdraw
0E0C
0E0C loc_E0C:
0E0C call Redraw_Tiles_or_Fade_to_pic
0E11 call move_usable_screen
0E16 mov [ds:show_fade_gap], 1
0E1C
0E1C loc_E1C:
0E1C push offset show_fade_gap
0E1F call scanline_draw_normal_scene
0E24 cmp [ds:flag_which_key_pressed_], 1
0E29
0E29 loc_E29:
0E29 jz short open_menu
0E2B
0E2B loc_E2B:
0E2B jmp next7
0E2E ; ---------------------------------------------------------------------------
0E2E
0E2E open_menu: ; CODE XREF: real_entry:loc_E29↑j
0E2E call process_Menu
0E31
0E31 next7: ; CODE XREF: real_entry:loc_E2B↑j
0E31 cmp [ds:flag_which_key_pressed_], 2
0E36 jz short serviey
0E38
0E38 loc_E38:
0E38 jmp next8
0E3B ; ---------------------------------------------------------------------------
0E3B
0E3B serviey: ; CODE XREF: real_entry+E06↑j
0E3B call process_Explore
0E3E
0E3E next8: ; CODE XREF: real_entry:loc_E38↑j
0E3E mov ax, [ds:flag_parallel_mutex]
0E41 xor ax, 1
0E44
0E44 loc_E44:
0E44 mov [ds:flag_parallel_mutex], ax
0E47
0E47 loc_E47: ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
0E47 cmp [ds:flag_to_load], 0
0E4C jnz short changemap
0E4E jmp mainloop
0E51 ; ---------------------------------------------------------------------------
0E51
0E51 changemap: ; CODE XREF: real_entry+E1C↑j
0E51 jmp call_change_map
0E51 endp real_entry
0E51
0E54
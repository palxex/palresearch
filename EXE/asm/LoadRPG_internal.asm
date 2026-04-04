seg001:
AAD8 ; =============== S U B R O U T I N E =======================================
AAD8
AAD8 ; Attributes: bp-based frame
AAD8
AAD8 proc LoadRPG_internal far ; CODE XREF: real_entry+C58↑P
AAD8 ; system_LoadRPG+1F↑P
AAD8 ; Load_Data+3F↑P
AAD8
AAD8 var_4A = word ptr -4Ah
AAD8 length = dword ptr -48h
AAD8 dst_offset = dword ptr -44h
AAD8 var_40 = dword ptr -40h
AAD8 var_3C = dword ptr -3Ch
AAD8 var_38 = dword ptr -38h
AAD8 var_34 = dword ptr -34h
AAD8 var_30 = dword ptr -30h
AAD8 var_2C = dword ptr -2Ch
AAD8 var_28 = dword ptr -28h
AAD8 var_24 = dword ptr -24h
AAD8 var_20 = dword ptr -20h
AAD8 bytes = dword ptr -1Ch
AAD8 var_18 = word ptr -18h
AAD8 var_16 = word ptr -16h
AAD8 var_14 = word ptr -14h
AAD8 arg_2 = word ptr 6
AAD8
AAD8 mov cx, 38h ; '8'
AADB mov bx, 0
AADE call far ptr B$ENRA ; setup stack & other state info.
AAE3 mov si, [bp+arg_2]
AAE6 mov ax, [si]
AAE8 mov bx, ax
AAEA add ax, 30h ; '0'
AAED push ax ; val
AAEE mov [bp+var_18], bx
AAF1 call B$FCHR ; CHR$ function
AAF6 push ax ; psd1_dst
AAF7 push offset BSTR__RPG ; psd2
AAFA call B$SCT1 ; Concatenate strings
AAFF push ax ; psdSource
AB00 push offset BSTR_x_rpg ; psdDest
AB03 call B$SAS1 ; String assignment
AB08 mov ax, [bp+var_18]
AB0B mov [ds:rpg_to_load_], ax
AB0E mov [bp+var_14], 0
AB13 push offset BSTR_x_rpg ; open_method
AB16 lea ax, [bp+var_14]
AB19 push ax ; int
AB1A call Open_File
AB1F mov [bp+var_16], ax
AB22 mov ax, [bp+var_16]
AB25 mov [ds:file_handle], ax
AB28 mov [word ptr ds:length], 0
AB2E mov [word ptr ds:length+2], 0
AB34 or ax, ax
AB36 jge short opened
AB38 jmp not_opened_return
AB3B ; ---------------------------------------------------------------------------
AB3B
AB3B opened: ; CODE XREF: LoadRPG_internal+5E↑j
AB3B mov si, offset DDIM_buf_common ; 战时用于存储双方速度
AB3E xor bx, bx
AB40 add bx, [si+0Ah]
AB43 mov es, [word ptr si+2]
AB46 mov [word ptr es:bx], 0
AB4B mov [word ptr bp+bytes], 28h ; '('
AB50 mov [word ptr bp+bytes+2], 0
AB55 mov bx, offset file_handle
AB58 push ds
AB59 pop es
AB5A push es ; int
AB5B push bx ; file_handle
AB5C mov si, offset DDIM_buf_common ; 战时用于存储双方速度
AB5F xor bx, bx
AB61 add bx, [si+0Ah]
AB64 mov es, [word ptr si+2]
AB67 push es
AB68 push bx ; buffer
AB69 lea bx, [bp+bytes]
AB6C push ds
AB6D pop es
AB6E push es
AB6F push bx ; bytes
AB70 call DOS_ReadFile_toBuf
AB75 mov si, offset DDIM_buf_common ; 战时用于存储双方速度
AB78 xor bx, bx
AB7A add bx, [si+0Ah]
AB7D mov es, [word ptr si+2]
AB80 mov ax, [es:bx]
AB83 mov [ds:RPG_save_number], ax
AB86 or ax, ax
AB88 jg short next
AB8A jmp rpg_save_num_0
AB8D ; ---------------------------------------------------------------------------
AB8D
AB8D next: ; CODE XREF: LoadRPG_internal+B0↑j
AB8D mov bx, 2
AB90 add bx, [si+0Ah]
AB93 mov es, [word ptr si+2]
AB96 mov ax, [es:bx]
AB99 mov [ds:RPG_viewport_x], ax
AB9C mov bx, 4
AB9F add bx, [si+0Ah]
ABA2 mov es, [word ptr si+2]
ABA5 mov ax, [es:bx]
ABA8 mov [ds:RPG_viewport_y], ax
ABAB mov bx, 6
ABAE add bx, [si+0Ah]
ABB1 mov es, [word ptr si+2]
ABB4 mov ax, [es:bx]
ABB7 mov [ds:RPG_team_number], ax
ABBA mov bx, 8
ABBD add bx, [si+0Ah]
ABC0 mov es, [word ptr si+2]
ABC3 mov ax, [es:bx]
ABC6 mov [ds:scene_to_load], ax
ABC9 mov [ds:RPG_curr_scene], ax
ABCC mov bx, 0Ah
ABCF add bx, [si+0Ah]
ABD2 mov es, [word ptr si+2]
ABD5 mov ax, [es:bx]
ABD8 mov [ds:RPG_color_begin_ptr], ax
ABDB mov bx, 0Ch
ABDE
ABDE loc_1A63E:
ABDE add bx, [si+0Ah]
ABE1 mov es, [word ptr si+2]
ABE4 mov ax, [es:bx]
ABE7 mov [ds:RPG_team_direction], ax
ABEA mov bx, 0Eh
ABED add bx, [si+0Ah]
ABF0 mov es, [word ptr si+2]
ABF3 mov ax, [es:bx]
ABF6 mov [ds:RPG_music_number], ax
ABF9 mov bx, 10h
ABFC add bx, [si+0Ah]
ABFF mov es, [word ptr si+2]
AC02 mov ax, [es:bx]
AC05 mov [ds:RPG_battle_music_number], ax
AC08 mov bx, 12h
AC0B add bx, [si+0Ah]
AC0E mov es, [word ptr si+2]
AC11 mov ax, [es:bx]
AC14 mov [ds:RPG_battle_scene_number], ax
AC17 mov bx, 14h
AC1A add bx, [si+0Ah]
AC1D mov es, [word ptr si+2]
AC20 mov ax, [es:bx]
AC23 mov [ds:RPG_screen_wave_grade], ax
AC26 mov bx, 18h
AC29 add bx, [si+0Ah]
AC2C mov es, [word ptr si+2]
AC2F mov ax, [es:bx]
AC32 mov [ds:RPG_current_calabash_number], ax
AC35 mov bx, 1Ah
AC38 add bx, [si+0Ah]
AC3B mov es, [word ptr si+2]
AC3E mov ax, [es:bx]
AC41 mov [ds:RPG_role_locate_layer], ax
AC44 mov bx, 1Ch
AC47 add bx, [si+0Ah]
AC4A mov es, [word ptr si+2]
AC4D mov ax, [es:bx]
AC50 mov [ds:RPG_ememy_chase_rate], ax
AC53 mov bx, 1Eh
AC56 add bx, [si+0Ah]
AC59 mov es, [word ptr si+2]
AC5C mov ax, [es:bx]
AC5F mov [ds:RPG_change_chaserate_times], ax
AC62 mov bx, 20h ; ' '
AC65 add bx, [si+0Ah]
AC68 mov es, [word ptr si+2]
AC6B mov ax, [es:bx]
AC6E mov [ds:RPG_other_peoples], ax
AC71 mov [word ptr bp+var_20], 4
AC76 mov [word ptr bp+var_20+2], 0
AC7B mov bx, offset file_handle
AC7E push ds
AC7F pop es
AC80 push es ; int
AC81 push bx ; file_handle
AC82 mov bx, offset RPG_money
AC85 push ds
AC86 pop es
AC87 push es
AC88 push bx ; buffer
AC89 lea bx, [bp+var_20]
AC8C push ds
AC8D pop es
AC8E push es
AC8F push bx ; bytes
AC90 call DOS_ReadFile_toBuf
AC95 mov [word ptr bp+var_24], 32h ; '2'
AC9A mov [word ptr bp+var_24+2], 0
AC9F mov bx, offset file_handle
ACA2 push ds
ACA3 pop es
ACA4 push es ; int
ACA5 push bx ; file_handle
ACA6 mov si, offset DDIM_RPG_team_positions ; 每人10字节,0:号,2:posX,4:posY,6:方向桢,8:MGO_MemMKF_offset
ACA9 xor bx, bx
ACAB add bx, [si+0Ah]
ACAE mov es, [word ptr si+2]
ACB1 push es
ACB2 push bx ; buffer
ACB3 lea bx, [bp+var_24]
ACB6 push ds
ACB7 pop es
ACB8 push es
ACB9 push bx ; bytes
ACBA call DOS_ReadFile_toBuf
ACBF mov [word ptr bp+var_28], 1Eh
ACC4 mov [word ptr bp+var_28+2], 0
ACC9 mov bx, offset file_handle
ACCC push ds
ACCD pop es
ACCE push es ; int
ACCF push bx ; file_handle
ACD0 mov si, offset DDIM_RPG_team_trace ; 每人6字节,0:X,2:Y,4:方向
ACD3 xor bx, bx
ACD5 add bx, [si+0Ah]
ACD8 mov es, [word ptr si+2]
ACDB push es
ACDC push bx ; buffer
ACDD lea bx, [bp+var_28]
ACE0 push ds
ACE1 pop es
ACE2 push es
ACE3 push bx ; bytes
ACE4 call DOS_ReadFile_toBuf
ACE9 mov [word ptr bp+var_2C], 180h
ACEE mov [word ptr bp+var_2C+2], 0
ACF3 mov bx, offset file_handle
ACF6 push ds
ACF7 pop es
ACF8 push es ; int
ACF9 push bx ; file_handle
ACFA mov si, offset DDIM_RPG_kinds_of_exps
ACFD xor bx, bx
ACFF add bx, [si+0Ah]
AD02 mov es, [word ptr si+2]
AD05 push es
AD06 push bx ; buffer
AD07 lea bx, [bp+var_2C]
AD0A push ds
AD0B pop es
AD0C push es
AD0D push bx ; bytes
AD0E call DOS_ReadFile_toBuf
AD13 mov [word ptr bp+var_30], 384h
AD18 mov [word ptr bp+var_30+2], 0
AD1D mov bx, offset file_handle
AD20 push ds
AD21 pop es
AD22 push es ; int
AD23 push bx ; file_handle
AD24 mov si, offset DDIM_data@3_our_data
AD27 xor bx, bx
AD29 add bx, [si+0Ah]
AD2C mov es, [word ptr si+2]
AD2F push es
AD30 push bx ; buffer
AD31 lea bx, [bp+var_30]
AD34 push ds
AD35 pop es
AD36 push es
AD37 push bx ; bytes
AD38 call DOS_ReadFile_toBuf
AD3D mov [word ptr bp+var_34], 140h
AD42 mov [word ptr bp+var_34+2], 0
AD47 mov bx, offset file_handle
AD4A push ds
AD4B pop es
AD4C push es ; int
AD4D push bx ; file_handle
AD4E mov si, offset DDIM_role_poison_stack
AD51 xor bx, bx
AD53 add bx, [si+0Ah]
AD56 mov es, [word ptr si+2]
AD59 push es
AD5A push bx ; buffer
AD5B lea bx, [bp+var_34]
AD5E push ds
AD5F pop es
AD60 push es
AD61 push bx ; bytes
AD62 call DOS_ReadFile_toBuf
AD67 mov [word ptr bp+var_38], 600h
AD6C mov [word ptr bp+var_38+2], 0
AD71 mov bx, offset file_handle
AD74 push ds
AD75 pop es
AD76 push es ; int
AD77 push bx ; file_handle
AD78 mov si, offset DDIM_items ; 0:代码
AD78 ; 2:数量
AD78 ; 4:当前回合已使用数量
AD7B xor bx, bx
AD7D add bx, [si+0Ah]
AD80 mov es, [word ptr si+2]
AD83 push es
AD84 push bx ; buffer
AD85 lea bx, [bp+var_38]
AD88 push ds
AD89 pop es
AD8A push es
AD8B push bx ; bytes
AD8C call DOS_ReadFile_toBuf
AD91 mov [word ptr bp+var_3C], 960h
AD96 mov [word ptr bp+var_3C+2], 0
AD9B mov bx, offset file_handle
AD9E push ds
AD9F pop es
ADA0 push es ; int
ADA1 push bx ; file_handle
ADA2 mov si, offset DDIM_sss@1_scene_def
ADA5 mov bx, 8
ADA8 add bx, [si+0Ah]
ADAB mov es, [word ptr si+2]
ADAE push es
ADAF push bx ; buffer
ADB0 lea bx, [bp+var_3C]
ADB3 push ds
ADB4 pop es
ADB5 push es
ADB6 push bx ; bytes
ADB7 call DOS_ReadFile_toBuf
ADBC mov [word ptr bp+var_40], 1C20h
ADC1 mov [word ptr bp+var_40+2], 0
ADC6 mov bx, offset file_handle
ADC9 push ds
ADCA pop es
ADCB push es ; int
ADCC push bx ; file_handle
ADCD mov si, offset DDIM_sss@2_object_defination
ADD0 xor bx, bx
ADD2 add bx, [si+0Ah]
ADD5 mov es, [word ptr si+2]
ADD8 push es
ADD9 push bx ; buffer
ADDA lea bx, [bp+var_40]
ADDD push ds
ADDE pop es
ADDF push es
ADE0 push bx ; bytes
ADE1 call DOS_ReadFile_toBuf
ADE6 push 0
ADE8 push 20h ; ' '
ADEA mov ax, [ds:evt_objs]
ADED cwd
ADEE push dx
ADEF push ax
ADF0 call B$MUI4 ; Long integer multiply
ADF5 mov [word ptr ds:length], ax
ADF8 mov [word ptr ds:length+2], dx
ADFC mov [word ptr bp+dst_offset], 0
AE01 mov [word ptr bp+dst_offset+2], 0
AE06
AE06 load_sss@0_loop: ; CODE XREF: LoadRPG_internal+3D6↓j
AE06 push [word ptr ds:length+2] ; op1_h
AE0A push [word ptr ds:length] ; op1_l
AE0E push 0 ; op2_h
AE10 push 0 ; op2_l
AE12 call B$CPI4 ; long integer compare
AE17 jg short copy_block
AE19 jmp copy_end
AE1C ; ---------------------------------------------------------------------------
AE1C
AE1C copy_block: ; CODE XREF: LoadRPG_internal+33F↑j
AE1C mov ax, [word ptr ds:length]
AE1F mov dx, [word ptr ds:length+2]
AE23 mov [word ptr bp+length], ax
AE26 mov [word ptr bp+length+2], dx
AE29 push dx ; op1_h
AE2A push ax ; op1_l
AE2B push 0 ; op2_h
AE2D push 8000h ; op2_l
AE30 call B$CPI4 ; long integer compare
AE35 jle short last_block
AE37 mov [word ptr bp+length], 8000h
AE3C mov [word ptr bp+length+2], 0
AE41
AE41 last_block: ; CODE XREF: LoadRPG_internal+35D↑j
AE41 mov ax, [word ptr ds:length]
AE44 mov dx, [word ptr ds:length+2]
AE48 sub ax, [word ptr bp+length]
AE4B sbb dx, [word ptr bp+length+2]
AE4E mov [word ptr ds:length], ax
AE51 mov [word ptr ds:length+2], dx
AE55 mov bx, offset file_handle
AE58 push ds
AE59 pop es
AE5A push es ; int
AE5B push bx ; file_handle
AE5C mov si, offset DDIM_buf_glb_1_redraw
AE5F xor bx, bx
AE61 add bx, [si+0Ah]
AE64 mov es, [word ptr si+2]
AE67 push es
AE68 push bx ; buffer
AE69 lea bx, [bp+length]
AE6C push ds
AE6D pop es
AE6E push es
AE6F push bx ; bytes
AE70 call DOS_ReadFile_toBuf
AE75 mov si, offset DDIM_buf_glb_1_redraw
AE78 xor bx, bx
AE7A add bx, [si+0Ah]
AE7D mov es, [word ptr si+2]
AE80 push es ; int
AE81 push bx ; src_offset
AE82 lea bx, [bp+length]
AE85 push ds
AE86 pop es
AE87 push es
AE88 push bx ; length
AE89 mov bx, offset xms_handle_sss@0_evt_obj
AE8C push ds
AE8D pop es
AE8E push es
AE8F push bx ; dst_handle
AE90 lea bx, [bp+dst_offset]
AE93 push ds
AE94 pop es
AE95 push es
AE96 push bx ; dst_offset
AE97 call XMS_CopyBlockToXMS_byOffset
AE9C mov ax, [word ptr bp+length]
AE9F mov dx, [word ptr bp+length+2]
AEA2 add ax, [word ptr bp+dst_offset]
AEA5 adc dx, [word ptr bp+dst_offset+2]
AEA8 mov [word ptr bp+dst_offset], ax
AEAB mov [word ptr bp+dst_offset+2], dx
AEAE jmp load_sss@0_loop
AEB1 ; ---------------------------------------------------------------------------
AEB1 nop
AEB2
AEB2 copy_end: ; CODE XREF: LoadRPG_internal+341↑j
AEB2 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
AEB5 or ax, 7
AEB8 mov [ds:flag_to_load], ax ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
AEBB mov [bp+var_4A], 1
AEC0 lea ax, [bp+var_4A]
AEC3 push ax
AEC4 call fade_out
AEC9
AEC9 rpg_save_num_0: ; CODE XREF: LoadRPG_internal+B2↑j
AEC9 mov bx, offset file_handle
AECC push ds
AECD pop es
AECE push es ; int
AECF push bx ; file_handle
AED0 call DOS_CloseFile
AED5
AED5 not_opened_return: ; CODE XREF: LoadRPG_internal+60↑j
AED5 call B$EXSA ; clear frame state info
AEDA retf 2
AEDA endp LoadRPG_internal
AEDA
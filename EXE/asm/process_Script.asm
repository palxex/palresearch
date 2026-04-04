seg000:
C921 ; =============== S U B R O U T I N E =======================================
C921
C921 ; Attributes: bp-based frame
C921
C921 ; int __stdcall __far process_Script(int, int argu_script)
C921 proc process_Script far ; CODE XREF: menu_Magic+151↑P
C921 ; inventory_Equip+559↑P
C921 ; inventory_Use+C2↑P
C921 ; process_Explore+EE↑P
C921 ; enemy_magical_attack+4E2↑P
C921 ; enemy_phisical_attack_role+AE6↑P
C921 ; process_Battle+500↑P
C921 ; process_Battle+189B↑P
C921 ; process_Battle+1AB5↑P
C921 ; process_Battle+1F05↑P
C921 ; process_Battle+29BC↑P
C921 ; process_Battle+2C22↑P
C921 ; process_Battle+2CF4↑P
C921 ; process_Battle+30A7↑P
C921 ; process_Battle+3AEB↑P ...
C921
C921 var_56 = word ptr -56h
C921 var_54 = word ptr -54h
C921 var_52 = word ptr -52h
C921 var_50 = word ptr -50h
C921 var_4E = word ptr -4Eh
C921 var_4C = word ptr -4Ch
C921 var_4A = word ptr -4Ah
C921 var_48 = word ptr -48h
C921 var_46 = word ptr -46h
C921 var_y_off = word ptr -44h
C921 var_42 = word ptr -42h
C921 var_40 = word ptr -40h
C921 var_3E = word ptr -3Eh
C921 var_3C = word ptr -3Ch
C921 var_3A = word ptr -3Ah
C921 var_38 = word ptr -38h
C921 var_36 = word ptr -36h
C921 var_34 = word ptr -34h
C921 literals = word ptr -32h
C921 text_y = word ptr -30h
C921 text_x = word ptr -2Eh
C921 script_arg3 = word ptr -2Ch
C921 script_arg2 = word ptr -2Ah
C921 script_arg1 = word ptr -28h
C921 script_func = word ptr -26h
C921 func = word ptr -24h
C921 src_offset = dword ptr -22h
C921 length = dword ptr -1Eh
C921 script_id = word ptr -1Ah
C921 script_id_h = word ptr -18h
C921 callee_script_id= word ptr -16h
C921 var_over_ = word ptr -14h
C921 argu_script = word ptr 6
C921 argu_object = word ptr 8
C921
C921 mov cx, 44h
C924 mov bx, 0
C927 call far ptr B$ENRA ; setup stack & other state info.
C92C mov [ds:prelimit_OK], 0FFFFh
C932 mov [bp+var_over_], 0
C937 mov si, [bp+argu_script]
C93A mov ax, [si]
C93C mov [bp+callee_script_id], ax
C93F mov [ds:current_dialog_lines], 0
C945 mov [ds:glbvar_fontcolor], 4Fh ; 'O'
C94B mov [ds:font_color_yellow], 2Dh ; '-'
C951 mov [ds:font_color_red], 1Ah
C957 mov [ds:font_color_cyan], 8Dh
C95D mov [ds:frame_pos_flag], 1 ; 0:中,1:上,2:下,A:框
C963 mov [ds:dialog_x], 0Ch
C969 mov [ds:dialog_y], 8
C96F mov [ds:frame_text_x], 2Ch ; ','
C975 mov [ds:frame_text_y], 1Ah
C97B
C97B begin_parse_script: ; CODE XREF: process_Script+362↓j
C97B ; process_Script+3AF↓j
C97B ; process_Script+4CF↓j
C97B ; process_Script:no_defeat_script↓j
C97B ; process_Script+60D↓j
C97B ; process_Script+65A↓j
C97B mov si, [bp+argu_script]
C97E push [word ptr si]
C980 call B$FMKI ; Convert Integer to string
C985 push ax ; psd1_dst
C986 push 0 ; val
C988 call B$FCHR ; CHR$ function
C98D push ax ; psd2
C98E call B$SCT1 ; Concatenate strings
C993 push ax ; psd1_dst
C994 push 0 ; val
C996 call B$FCHR ; CHR$ function
C99B push ax ; psd2
C99C call B$SCT1 ; Concatenate strings
C9A1 push ax
C9A2 call B$FCVI_0 ; Convert string to long integer
C9A7 mov [bp+script_id], ax
C9AA mov [bp+script_id_h], dx
C9AD push dx ; op1_h
C9AE push ax ; op1_l
C9AF push [word ptr ds:script_number+2] ; op2_h
C9B3 push [word ptr ds:script_number] ; op2_l
C9B7 call B$CPI4 ; long integer compare
C9BC jle short go
C9BE jmp over
C9C1 ; ---------------------------------------------------------------------------
C9C1
C9C1 go: ; CODE XREF: process_Script+9B↑j
C9C1 cmp [word ptr si], 0
C9C4 jnz short gogo
C9C6 jmp over
C9C9 ; ---------------------------------------------------------------------------
C9C9
C9C9 gogo: ; CODE XREF: process_Script+A3↑j
C9C9 mov [word ptr bp+length], 8
C9CE mov [word ptr bp+length+2], 0
C9D3 push 0
C9D5 push 8
C9D7 push [bp+script_id_h]
C9DA push [bp+script_id]
C9DD call B$MUI4 ; Long integer multiply
C9E2 mov [word ptr bp+src_offset], ax
C9E5 mov [word ptr bp+src_offset+2], dx
C9E8 mov si, offset DDIM_buf_common ; 战时用于存储双方速度
C9EB xor bx, bx
C9ED add bx, [si+0Ah]
C9F0 mov es, [word ptr si+2]
C9F3 push es ; int
C9F4 push bx ; dst_offset
C9F5 lea bx, [bp+length]
C9F8 push ds
C9F9 pop es
C9FA push es
C9FB push bx ; length
C9FC mov bx, offset xms_handle_sss@4_script
C9FF push ds
CA00 pop es
CA01 push es
CA02 push bx ; src_handle
CA03 lea bx, [bp+src_offset]
CA06 push ds
CA07 pop es
CA08 push es
CA09 push bx ; src_offset
CA0A call XMS_CopyBlockFromXMS_toAddr
CA0F mov si, offset DDIM_buf_common ; 战时用于存储双方速度
CA12 xor bx, bx
CA14 add bx, [si+0Ah]
CA17 mov es, [word ptr si+2]
CA1A mov ax, [es:bx]
CA1D mov [bp+script_func], ax
CA20 mov bx, 2
CA23 add bx, [si+0Ah]
CA26 mov es, [word ptr si+2]
CA29 mov cx, [es:bx]
CA2C mov [bp+script_arg1], cx
CA2F mov bx, 4
CA32 add bx, [si+0Ah]
CA35 mov es, [word ptr si+2]
CA38 mov cx, [es:bx]
CA3B mov [bp+script_arg2], cx
CA3E mov bx, 6
CA41 add bx, [si+0Ah]
CA44 mov es, [word ptr si+2]
CA47 mov cx, [es:bx]
CA4A mov [bp+script_arg3], cx
CA4D mov [bp+func], ax
CA50 cmp [bp+func], 0FFFFh
CA54 jz short script_ffff
CA56 jmp case_0
CA59 ; ---------------------------------------------------------------------------
CA59
CA59 script_ffff: ; CODE XREF: process_Script+133↑j
CA59 cmp [ds:current_dialog_lines], 3
CA5E jg short lines_full
CA60 jmp not_full
CA63 ; ---------------------------------------------------------------------------
CA63
CA63 lines_full: ; CODE XREF: process_Script+13D↑j
CA63 call wait_show_icon
CA68 mov [ds:current_dialog_lines], 0
CA6E call restore_screen
CA73
CA73 not_full: ; CODE XREF: process_Script+13F↑j
CA73 cmp [ds:current_dialog_lines], 0
CA78 jz short begin_write
CA7A jmp continue_write
CA7D ; ---------------------------------------------------------------------------
CA7D
CA7D begin_write: ; CODE XREF: process_Script+157↑j
CA7D mov ax, [ds:frame_text_x]
CA80 mov [bp+text_x], ax
CA83 mov ax, [ds:frame_text_y]
CA86 mov [bp+text_y], ax
CA89 cmp [ds:flag_pic_level], 0 ; 0:地图,1:战斗,-1:动画
CA8E jz short call_backup
CA90 jmp continue_write
CA93 ; ---------------------------------------------------------------------------
CA93
CA93 call_backup: ; CODE XREF: process_Script+16D↑j
CA93 call backup_screen
CA98
CA98 continue_write: ; CODE XREF: process_Script+159↑j
CA98 ; process_Script+16F↑j
CA98 cmp [ds:frame_pos_flag], 0Ah ; 0:中,1:上,2:下,A:框
CA9D jge short has_frame
CA9F jmp gogogo
CAA2 ; ---------------------------------------------------------------------------
CAA2
CAA2 has_frame: ; CODE XREF: process_Script+17C↑j
CAA2 lea ax, [bp+script_arg1]
CAA5 push ax
CAA6 call get_m_msg
CAAB push offset BSTR_str_in_m_msg
CAAE call STRINGLENGTH
CAB3 mov cx, 2
CAB6 cwd
CAB7 idiv cx
CAB9 mov [bp+literals], ax
CABC shl ax, 1
CABE shl ax, 1
CAC0 shl ax, 1
CAC2 sub ax, [ds:frame_text_x]
CAC6 neg ax
CAC8 mov [bp+text_x], ax
CACB lea ax, [bp+text_x]
CACE push ax ; a_y
CACF lea ax, [bp+text_y]
CAD2 push ax ; a_width
CAD3 lea ax, [bp+literals]
CAD6 push ax ; a_shadow
CAD7 lea ax, [bp+var_34]
CADA push ax ; int
CADB call make_dialog_frame
CAE0 mov ax, [bp+text_x]
CAE3 add ax, 9
CAE6 mov [bp+var_36], ax
CAE9 mov ax, [bp+text_y]
CAEC add ax, 0Ah
CAEF mov [bp+var_38], ax
CAF2 mov [bp+var_3A], 3
CAF7 mov [bp+var_3C], 0
CAFC lea ax, [bp+var_36]
CAFF push ax
CB00 lea ax, [bp+var_38]
CB03 push ax
CB04 push offset BSTR_str_in_m_msg
CB07 lea ax, [bp+var_3A]
CB0A push ax
CB0B lea ax, [bp+var_3C]
CB0E push ax
CB0F call dialog_string
CB14 add [bp+text_y], 20h
CB18 mov [bp+var_3E], 140
CB1D lea ax, [bp+var_3E]
CB20 push ax
CB21 call wait_key
CB26 jmp ffff_continue
CB29 ; ---------------------------------------------------------------------------
CB29
CB29 gogogo: ; CODE XREF: process_Script+17E↑j
CB29 lea ax, [bp+script_arg1]
CB2C push ax
CB2D call get_m_msg
CB32 cmp [ds:frame_pos_flag], 0 ; 0:中,1:上,2:下,A:框
CB37 jg short has_image
CB39 jmp check_symbol
CB3C ; ---------------------------------------------------------------------------
CB3C
CB3C has_image: ; CODE XREF: process_Script+216↑j
CB3C cmp [ds:current_dialog_lines], 0
CB41 jz short first_line
CB43 jmp check_symbol
CB46 ; ---------------------------------------------------------------------------
CB46
CB46 first_line: ; CODE XREF: process_Script+220↑j
CB46 push offset BSTR_str_in_m_msg
CB49 push 2
CB4B call B$RGHT ; Compute RIGHT$ function
CB50 push ax ; psdL
CB51 push offset BSTR_colon ; psdR
CB54 call B$SCMP ; String comparison
CB59 jz short dialog_name
CB5B jmp check_symbol
CB5E ; ---------------------------------------------------------------------------
CB5E
CB5E dialog_name: ; CODE XREF: process_Script+238↑j
CB5E mov [bp+var_40], 0
CB63 mov [bp+var_42], 8Ch
CB68 push offset dialog_x
CB6B push offset dialog_y
CB6E push offset BSTR_str_in_m_msg
CB71 lea ax, [bp+var_40]
CB74 push ax
CB75 lea ax, [bp+var_42]
CB78 push ax
CB79 call dialog_string
CB7E jmp ffff_continue
CB81 ; ---------------------------------------------------------------------------
CB81
CB81 check_symbol: ; CODE XREF: process_Script+218↑j
CB81 ; process_Script+222↑j
CB81 ; process_Script+23A↑j
CB81 inc [ds:current_dialog_lines]
CB85 lea ax, [bp+text_x]
CB88 push ax ; argu_y
CB89 lea ax, [bp+text_y]
CB8C push ax ; argu_m_text
CB8D push offset BSTR_str_in_m_msg ; int
CB90 call draw_oneline_m_text
CB95 mov [bp+var_y_off], 10h
CB9A cmp [ds:frame_pos_flag], 0 ; 0:中,1:上,2:下,A:框
CB9F jnz short get_y_off
CBA1 mov [bp+var_y_off], 12h
CBA6
CBA6 get_y_off: ; CODE XREF: process_Script+27E↑j
CBA6 mov ax, [bp+var_y_off]
CBA9 add [bp+text_y], ax
CBAC
CBAC ffff_continue: ; CODE XREF: process_Script+205↑j
CBAC ; process_Script+25D↑j
CBAC jmp scripts_continue
CBAF ; ---------------------------------------------------------------------------
CBAF
CBAF case_0: ; CODE XREF: process_Script+135↑j
CBAF cmp [bp+func], 0
CBB3 jnz short case_1
CBB5 mov ax, [bp+callee_script_id]
CBB8 mov si, [bp+argu_script]
CBBB mov [si], ax
CBBD mov [bp+var_over_], 0FFFFh
CBC2 jmp scripts_continue
CBC5 ; ---------------------------------------------------------------------------
CBC5
CBC5 case_1: ; CODE XREF: process_Script+292↑j
CBC5 cmp [bp+func], 1
CBC9 jnz short case_2
CBCB mov si, [bp+argu_script]
CBCE inc [word ptr si]
CBD0 mov [bp+var_over_], 0FFFFh
CBD5 jmp scripts_continue
CBD8 ; ---------------------------------------------------------------------------
CBD8
CBD8 case_2: ; CODE XREF: process_Script+2A8↑j
CBD8 cmp [bp+func], 2
CBDC jz short yes_is_2
CBDE jmp case_3
CBE1 ; ---------------------------------------------------------------------------
CBE1
CBE1 yes_is_2: ; CODE XREF: process_Script+2BB↑j
CBE1 cmp [bp+script_arg2], 0
CBE5 jnz short times_2
CBE7 mov ax, [bp+script_arg1]
CBEA mov si, [bp+argu_script]
CBED mov [si], ax
CBEF mov [bp+var_over_], 0FFFFh
CBF4 jmp end_case_2
CBF7 ; ---------------------------------------------------------------------------
CBF7
CBF7 times_2: ; CODE XREF: process_Script+2C4↑j
CBF7 mov si, [bp+argu_object]
CBFA mov bx, [si]
CBFC shl bx, 1
CBFE shl bx, 1
CC00 shl bx, 1
CC02 shl bx, 1
CC04 shl bx, 1
CC06 mov si, offset DDIM_evt_obj_curr_scene
CC09 mov dx, bx
CC0B add bx, [si+0Ah]
CC0E mov es, [word ptr si+2]
CC11 add bx, 18h ; dddd
CC14 mov ax, [es:bx]
CC17 inc ax
CC18 mov bx, dx
CC1A add bx, [si+0Ah]
CC1D mov es, [word ptr si+2]
CC20 add bx, 18h
CC23 mov [es:bx], ax
CC26 mov bx, dx
CC28 add bx, [si+0Ah]
CC2B mov es, [word ptr si+2]
CC2E add bx, 18h
CC31 mov ax, [es:bx]
CC34 cmp ax, [bp+script_arg2]
CC37 jge short over_times_2
CC39 mov ax, [bp+script_arg1]
CC3C mov si, [bp+argu_script]
CC3F mov [si], ax
CC41 mov [bp+var_over_], 0FFFFh
CC46 jmp end_case_2
CC49 ; ---------------------------------------------------------------------------
CC49
CC49 over_times_2: ; CODE XREF: process_Script+316↑j
CC49 mov si, [bp+argu_object]
CC4C mov bx, [si]
CC4E shl bx, 1
CC50 shl bx, 1
CC52 shl bx, 1
CC54 shl bx, 1
CC56 shl bx, 1
CC58 mov si, offset DDIM_evt_obj_curr_scene
CC5B add bx, [si+0Ah]
CC5E mov es, [word ptr si+2]
CC61 add bx, 18h
CC64 mov [word ptr es:bx], 0
CC69
CC69 end_case_2: ; CODE XREF: process_Script+2D3↑j
CC69 ; process_Script+325↑j
CC69 jmp scripts_continue
CC6C ; ---------------------------------------------------------------------------
CC6C
CC6C case_3: ; CODE XREF: process_Script+2BD↑j
CC6C cmp [bp+func], 3
CC70 jz short yes_is_3
CC72 jmp case_4
CC75 ; ---------------------------------------------------------------------------
CC75
CC75 yes_is_3: ; CODE XREF: process_Script+34F↑j
CC75 cmp [bp+script_arg2], 0
CC79 jnz short times_3
CC7B mov ax, [bp+script_arg1]
CC7E mov si, [bp+argu_script]
CC81 mov [si], ax
CC83 jmp begin_parse_script
CC86 ; ---------------------------------------------------------------------------
CC86
CC86 times_3: ; CODE XREF: process_Script+358↑j
CC86 mov si, [bp+argu_object]
CC89 mov bx, [si]
CC8B shl bx, 1
CC8D shl bx, 1
CC8F shl bx, 1
CC91 shl bx, 1
CC93 shl bx, 1
CC95 mov si, offset DDIM_evt_obj_curr_scene
CC98 mov dx, bx
CC9A add bx, [si+DDIM.offset]
CC9D mov es, [si+DDIM.header.segment]
CCA0 add bx, 18h
CCA3 mov ax, [es:bx]
CCA6 inc ax
CCA7 mov bx, dx
CCA9 add bx, [si+DDIM.offset]
CCAC mov es, [si+DDIM.header.segment]
CCAF add bx, 18h
CCB2 mov [es:bx], ax
CCB5 mov bx, dx
CCB7 add bx, [si+DDIM.offset]
CCBA mov es, [si+DDIM.header.segment]
CCBD add bx, 18h
CCC0 mov ax, [es:bx]
CCC3 cmp ax, [bp+script_arg2]
CCC6 jge short over_times_3
CCC8 mov ax, [bp+script_arg1]
CCCB mov si, [bp+argu_script]
CCCE mov [si], ax
CCD0 jmp begin_parse_script
CCD3 ; ---------------------------------------------------------------------------
CCD3
CCD3 over_times_3: ; CODE XREF: process_Script+3A5↑j
CCD3 mov si, [bp+argu_object]
CCD6 mov bx, [si]
CCD8 shl bx, 1
CCDA shl bx, 1
CCDC shl bx, 1
CCDE shl bx, 1
CCE0 shl bx, 1
CCE2 mov si, offset DDIM_evt_obj_curr_scene
CCE5 add bx, [si+DDIM.offset]
CCE8 mov es, [si+DDIM.header.segment]
CCEB add bx, 18h
CCEE mov [word ptr es:bx], 0
CCF3 jmp scripts_continue
CCF6 ; ---------------------------------------------------------------------------
CCF6
CCF6 case_4: ; CODE XREF: process_Script+351↑j
CCF6 cmp [bp+func], 4
CCFA jz short yes_is_4
CCFC jmp case_5
CCFF ; ---------------------------------------------------------------------------
CCFF
CCFF yes_is_4: ; CODE XREF: process_Script+3D9↑j
CCFF cmp [bp+script_arg2], 0
CD03 jg short get_caller
CD05 jmp direct_call
CD08 ; ---------------------------------------------------------------------------
CD08
CD08 get_caller: ; CODE XREF: process_Script+3E2↑j
CD08 mov bx, [ds:RPG_curr_scene]
CD0C shl bx, 1
CD0E shl bx, 1
CD10 shl bx, 1
CD12 mov si, offset DDIM_sss@1_scene_def
CD15 add bx, [si+0Ah]
CD18 mov es, [word ptr si+2]
CD1B add bx, 6
CD1E mov ax, [es:bx]
CD21 sub ax, [bp+script_arg2]
CD24 neg ax
CD26 mov [bp+var_46], ax
CD29 or ax, ax
CD2B jg short next2
CD2D jmp no_script
CD30 ; ---------------------------------------------------------------------------
CD30
CD30 next2: ; CODE XREF: process_Script+40A↑j
CD30 cmp ax, [ds:evt_objs_curr_scene]
CD34 jle short valid
CD36 jmp no_script
CD39 ; ---------------------------------------------------------------------------
CD39
CD39 valid: ; CODE XREF: process_Script+413↑j
CD39 lea ax, [bp+var_46]
CD3C push ax ; argu_script
CD3D lea ax, [bp+script_arg1]
CD40 push ax ; int
CD41 call process_Script ; 调用脚本
CD46
CD46 no_script: ; CODE XREF: process_Script+40C↑j
CD46 ; process_Script+415↑j
CD46 jmp jmp_continue?
CD49 ; ---------------------------------------------------------------------------
CD49
CD49 direct_call: ; CODE XREF: process_Script+3E4↑j
CD49 push [bp+argu_object] ; argu_script
CD4C lea ax, [bp+script_arg1]
CD4F push ax ; int
CD50 call process_Script ; 调用脚本
CD55
CD55 jmp_continue?: ; CODE XREF: process_Script:no_script↑j
CD55 jmp scripts_continue
CD58 ; ---------------------------------------------------------------------------
CD58
CD58 case_5: ; CODE XREF: process_Script+3DB↑j
CD58 cmp [bp+func], 5
CD5C jz short yes_is_5
CD5E jmp case_6
CD61 ; ---------------------------------------------------------------------------
CD61
CD61 yes_is_5: ; CODE XREF: process_Script+43B↑j
CD61 cmp [ds:current_dialog_lines], 0
CD66 jg short finish_dialog
CD68 jmp go_on
CD6B ; ---------------------------------------------------------------------------
CD6B
CD6B finish_dialog: ; CODE XREF: process_Script+445↑j
CD6B call wait_show_icon
CD70 mov [ds:current_dialog_lines], 0
CD76
CD76 go_on: ; CODE XREF: process_Script+447↑j
CD76 cmp [ds:flag_pic_level], 0 ; 0:地图,1:战斗,-1:动画
CD7B jz short on_map
CD7D jmp clear
CD80 ; ---------------------------------------------------------------------------
CD80
CD80 on_map: ; CODE XREF: process_Script+45A↑j
CD80 mov ax, [bp+script_arg1]
CD83 mov [ds:redraw_progression], ax
CD86 cmp [bp+script_arg2], 0
CD8A jnz short valid_script5_arg2
CD8C mov [bp+script_arg2], 1
CD91
CD91 valid_script5_arg2: ; CODE XREF: process_Script+469↑j
CD91 mov ax, [bp+script_arg3]
CD94 and ax, ax
CD96 jnz short update_frames
CD98 jmp go_on_
CD9B ; ---------------------------------------------------------------------------
CD9B
CD9B update_frames: ; CODE XREF: process_Script+475↑j
CD9B call stop_and_update_frame
CDA0
CDA0 go_on_: ; CODE XREF: process_Script+477↑j
CDA0 lea ax, [bp+script_arg2]
CDA3 push ax
CDA4 call redraw_everything
CDA9 mov [ds:redraw_progression], 0
CDAF jmp go_continue
CDB2 ; ---------------------------------------------------------------------------
CDB2
CDB2 clear: ; CODE XREF: process_Script+45C↑j
CDB2 call restore_screen
CDB7
CDB7 go_continue: ; CODE XREF: process_Script+48E↑j
CDB7 jmp scripts_continue
CDBA ; ---------------------------------------------------------------------------
CDBA
CDBA case_6: ; CODE XREF: process_Script+43D↑j
CDBA cmp [bp+func], 6
CDBE jz short yes_is_6
CDC0 jmp case_7
CDC3 ; ---------------------------------------------------------------------------
CDC3
CDC3 yes_is_6: ; CODE XREF: process_Script+49D↑j
CDC3 call B$RND0 ; RND function
CDC8 mov si, ax
CDCA fld [dword ptr si] ; (emulator call)
CDCD fmul [ds:fp32_100_] ; (emulator call)
CDD2 fild [bp+script_arg1] ; (emulator call)
CDD6 wait ; (emulator call)
CDD8 call fcmp_st_st1
CDDD jb short jump_to
CDDF jmp jmp_continue?_
CDE2 ; ---------------------------------------------------------------------------
CDE2
CDE2 jump_to: ; CODE XREF: process_Script+4BC↑j
CDE2 cmp [bp+script_arg2], 0
CDE6 jz short prepare_exit
CDE8 mov ax, [bp+script_arg2]
CDEB mov si, [bp+argu_script]
CDEE mov [si], ax
CDF0 jmp begin_parse_script
CDF3 ; ---------------------------------------------------------------------------
CDF3
CDF3 prepare_exit: ; CODE XREF: process_Script+4C5↑j
CDF3 mov [bp+var_over_], 0FFFFh
CDF8
CDF8 jmp_continue?_: ; CODE XREF: process_Script+4BE↑j
CDF8 jmp scripts_continue
CDFB ; ---------------------------------------------------------------------------
CDFB
CDFB case_7: ; CODE XREF: process_Script+49F↑j
CDFB cmp [bp+func], 7
CDFF jz short yes_is_7
CE01 jmp case_8
CE04 ; ---------------------------------------------------------------------------
CE04
CE04 yes_is_7: ; CODE XREF: process_Script+4DE↑j
CE04 cmp [ds:current_dialog_lines], 0
CE09 jg short finish_dialog_
CE0B jmp battle
CE0E ; ---------------------------------------------------------------------------
CE0E
CE0E finish_dialog_: ; CODE XREF: process_Script+4E8↑j
CE0E call wait_show_icon
CE13 mov [ds:current_dialog_lines], 0
CE19
CE19 battle: ; CODE XREF: process_Script+4EA↑j
CE19 cmp [ds:flag_battle?], 0
CE1E jnz short no_battle?
CE20 lea ax, [bp+script_arg1]
CE23 push ax
CE24 lea ax, [bp+script_arg3]
CE27 push ax
CE28 call process_Battle
CE2D mov [bp+var_48], ax
CE30 mov ax, [bp+var_48]
CE33 mov [bp+var_4A], ax
CE36
CE36 no_battle?: ; CODE XREF: process_Script+4FD↑j
CE36 mov si, [bp+argu_script]
CE39 inc [word ptr si]
CE3B cmp [bp+script_arg2], 0
CE3F jz short no_vectory_script
CE41 cmp [bp+var_4A], 1
CE45 jnz short no_vectory_script
CE47 mov ax, [bp+script_arg2]
CE4A mov [si], ax
CE4C
CE4C no_vectory_script: ; CODE XREF: process_Script+51E↑j
CE4C ; process_Script+524↑j
CE4C cmp [bp+script_arg3], 0
CE50 jz short no_defeat_script
CE52 cmp [bp+var_4A], 2
CE56 jnz short no_defeat_script
CE58 mov ax, [bp+script_arg3]
CE5B mov si, [bp+argu_script]
CE5E mov [si], ax
CE60
CE60 no_defeat_script: ; CODE XREF: process_Script+52F↑j
CE60 ; process_Script+535↑j
CE60 jmp begin_parse_script
CE63 ; ---------------------------------------------------------------------------
CE63
CE63 case_8: ; CODE XREF: process_Script+4E0↑j
CE63 cmp [bp+func], 8
CE67 jnz short case_9
CE69 mov si, [bp+argu_script]
CE6C mov ax, [si]
CE6E inc ax
CE6F mov [bp+callee_script_id], ax
CE72 jmp scripts_continue
CE75 ; ---------------------------------------------------------------------------
CE75
CE75 case_9: ; CODE XREF: process_Script+546↑j
CE75 cmp [bp+func], 9
CE79 jz short yes_is_9
CE7B jmp case_A
CE7E ; ---------------------------------------------------------------------------
CE7E
CE7E yes_is_9: ; CODE XREF: process_Script+558↑j
CE7E cmp [ds:current_dialog_lines], 0
CE83 jg short first_wait
CE85 jmp go_
CE88 ; ---------------------------------------------------------------------------
CE88
CE88 first_wait: ; CODE XREF: process_Script+562↑j
CE88 call wait_show_icon
CE8D mov [ds:current_dialog_lines], 0
CE93
CE93 go_: ; CODE XREF: process_Script+564↑j
CE93 cmp [bp+script_arg1], 0
CE97 jnz short keep_big_0
CE99 mov [bp+script_arg1], 1
CE9E
CE9E keep_big_0: ; CODE XREF: process_Script+576↑j
CE9E mov ax, [bp+script_arg1]
CEA1 mov [bp+var_4C], ax
CEA4 mov ax, 1
CEA7 jmp begin_de
CEAA ; ---------------------------------------------------------------------------
CEAA
CEAA de_loop?: ; CODE XREF: process_Script+5BE↓j
CEAA mov ax, [bp+script_arg3]
CEAD and ax, ax
CEAF jnz short refresh_?
CEB1 jmp go_direct
CEB4 ; ---------------------------------------------------------------------------
CEB4
CEB4 refresh_?: ; CODE XREF: process_Script+58E↑j
CEB4 call calc_trace_frames
CEB9 call store_team_frame_data
CEBE
CEBE go_direct: ; CODE XREF: process_Script+590↑j
CEBE lea ax, [bp+script_arg2]
CEC1 push ax
CEC2 call GameLoop_OneCycle
CEC7 mov [bp+var_4E], 1
CECC lea ax, [bp+var_4E]
CECF push ax
CED0 call redraw_everything
CED5 mov ax, [bp+var_50]
CED8 inc ax
CED9
CED9 begin_de: ; CODE XREF: process_Script+586↑j
CED9 mov [bp+var_50], ax
CEDC cmp ax, [bp+var_4C]
CEDF jle short de_loop?
CEE1 jmp scripts_continue
CEE4 ; ---------------------------------------------------------------------------
CEE4
CEE4 case_A: ; CODE XREF: process_Script+55A↑j
CEE4 cmp [bp+func], 0Ah
CEE8 jz short yes_is_A
CEEA jmp default
CEED ; ---------------------------------------------------------------------------
CEED
CEED yes_is_A: ; CODE XREF: process_Script+5C7↑j
CEED mov [ds:current_dialog_lines], 0
CEF3 mov [bp+var_50], 0FFFFh
CEF8
CEF8 loc_CEF8: ; CODE XREF: process_Script+5FD↓j
CEF8 cmp [bp+var_50], 0
CEFC jge short got
CEFE mov [bp+var_52], 0
CF03 mov [bp+var_54], 13h
CF08 lea ax, [bp+var_52]
CF0B push ax
CF0C lea ax, [bp+var_54]
CF0F push ax
CF10 call yes_no_dialog
CF15 mov [bp+var_56], ax
CF18 mov ax, [bp+var_56]
CF1B mov [bp+var_50], ax
CF1E jmp short loc_CEF8
CF20 ; ---------------------------------------------------------------------------
CF20
CF20 got: ; CODE XREF: process_Script+5DB↑j
CF20 cmp [bp+var_50], 0
CF24 jnz short is_no
CF26 mov ax, [bp+script_arg1]
CF29 mov si, [bp+argu_script]
CF2C mov [si], ax
CF2E jmp begin_parse_script
CF31 ; ---------------------------------------------------------------------------
CF31
CF31 is_no: ; CODE XREF: process_Script+603↑j
CF31 jmp scripts_continue
CF34 ; ---------------------------------------------------------------------------
CF34
CF34 default: ; CODE XREF: process_Script+5C9↑j
CF34 cmp [bp+func], 0Ah
CF38 jg short script_other
CF3A jmp scripts_continue
CF3D ; ---------------------------------------------------------------------------
CF3D
CF3D script_other: ; CODE XREF: process_Script+617↑j
CF3D cmp [ds:current_dialog_lines], 0
CF42 jg short finish_it
CF44 jmp direct_go_
CF47 ; ---------------------------------------------------------------------------
CF47
CF47 finish_it: ; CODE XREF: process_Script+621↑j
CF47 call wait_show_icon
CF4C
CF4C direct_go_: ; CODE XREF: process_Script+623↑j
CF4C jmp $+3
CF4F
CF4F scripts_continue: ; CODE XREF: process_Script:ffff_continue↑j
CF4F ; process_Script+2A1↑j
CF4F ; process_Script+2B4↑j
CF4F ; process_Script:end_case_2↑j
CF4F ; process_Script+3D2↑j
CF4F ; process_Script:jmp_continue?↑j
CF4F ; process_Script:go_continue↑j
CF4F ; process_Script:jmp_continue?_↑j
CF4F ; process_Script+551↑j
CF4F ; process_Script+5C0↑j
CF4F ; process_Script:is_no↑j
CF4F ; process_Script+619↑j
CF4F mov ax, [bp+var_over_]
CF52 not ax
CF54 and ax, ax
CF56 jnz short scripts_dispatch
CF58 jmp over
CF5B ; ---------------------------------------------------------------------------
CF5B
CF5B scripts_dispatch: ; CODE XREF: process_Script+635↑j
CF5B push [bp+argu_object] ; script_id
CF5E push [bp+argu_script] ; script_func
CF61 lea ax, [bp+script_func]
CF64 push ax ; script_arg1
CF65 lea ax, [bp+script_arg1]
CF68 push ax ; script_arg2
CF69 lea ax, [bp+script_arg2]
CF6C push ax ; script_arg3
CF6D lea ax, [bp+script_arg3]
CF70 push ax ; int
CF71 call process_scripts
CF76 mov si, [bp+argu_script]
CF79 inc [word ptr si]
CF7B jmp begin_parse_script
CF7E ; ---------------------------------------------------------------------------
CF7E
CF7E over: ; CODE XREF: process_Script+9D↑j
CF7E ; process_Script+A5↑j
CF7E ; process_Script+637↑j
CF7E cmp [ds:current_dialog_lines], 0
CF83 jg short wait
CF85 jmp return
CF88 ; ---------------------------------------------------------------------------
CF88
CF88 wait: ; CODE XREF: process_Script+662↑j
CF88 call wait_show_icon
CF8D
CF8D return: ; CODE XREF: process_Script+664↑j
CF8D call B$EXSA ; clear frame state info
CF92 retf 4
CF92 endp process_Script
CF92
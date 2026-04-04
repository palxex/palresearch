seg000:
C412 ; =============== S U B R O U T I N E =======================================
C412
C412 ; Attributes: bp-based frame
C412
C412 proc Load_system_files far ; CODE XREF: real_entry+8F7↑P
C412
C412 dst_offset = dword ptr -7Ch
C412 var_78 = dword ptr -78h
C412 var_74 = word ptr -74h
C412 var_72 = word ptr -72h
C412 var_70 = word ptr -70h
C412 var_6C = word ptr -6Ch
C412 var_6A = word ptr -6Ah
C412 psdDest = word ptr -68h
C412 var_64 = word ptr -64h
C412 argu_buffer = word ptr -62h
C412 var_5E = word ptr -5Eh
C412 var_5C = word ptr -5Ch
C412 var_5A = word ptr -5Ah
C412 var_58 = word ptr -58h
C412 var_56 = word ptr -56h
C412 var_54 = word ptr -54h
C412 var_52 = word ptr -52h
C412 var_50 = word ptr -50h
C412 var_4E = word ptr -4Eh
C412 var_4C = word ptr -4Ch
C412 var_4A = word ptr -4Ah
C412 var_48 = word ptr -48h
C412 var_46 = word ptr -46h
C412 var_44 = word ptr -44h
C412 var_42 = word ptr -42h
C412 var_40 = word ptr -40h
C412 var_3E = word ptr -3Eh
C412 var_3C = word ptr -3Ch
C412 var_3A = word ptr -3Ah
C412 var_38 = dword ptr -38h
C412 var_34 = word ptr -34h
C412 var_32 = word ptr -32h
C412 open_method = word ptr -30h
C412 var_2C = word ptr -2Ch
C412 var_2A = word ptr -2Ah
C412 var_28 = word ptr -28h
C412 var_26 = word ptr -26h
C412 var_24 = word ptr -24h
C412 var_22 = word ptr -22h
C412 argu_xmshandle = word ptr -20h
C412 bytes = dword ptr -1Eh
C412 var_1A = word ptr -1Ah
C412 var_18 = word ptr -18h
C412 v_sss_mkf = word ptr -16h
C412
C412 mov cx, 6Ah ; 'j'
C415 mov bx, 5
C418 call far ptr B$ENRA ; setup stack & other state info.
C41D push offset BSTR_sss_mkf ; psdSource
C420 lea ax, [bp+v_sss_mkf]
C423 push ax ; psdDest
C424 call B$SAS1 ; String assignment
C429 mov [bp+var_18], 0
C42E lea ax, [bp+v_sss_mkf]
C431 push ax ; open_method
C432 lea ax, [bp+var_18]
C435 push ax ; int
C436 call Open_File
C43B mov [bp+var_1A], ax
C43E mov ax, [bp+var_1A]
C441 mov [ds:file_handle], ax
C444 mov [word ptr bp+bytes], 18h
C449 mov [word ptr bp+bytes+2], 0
C44E mov bx, offset file_handle
C451 push ds
C452 pop es
C453 push es ; int
C454 push bx ; file_handle
C455 mov si, offset DDIM_buf_index
C458 xor bx, bx
C45A add bx, [si+0Ah]
C45D mov es, [word ptr si+2]
C460 push es
C461 push bx ; buffer
C462 lea bx, [bp+bytes]
C465 push ds
C466 pop es
C467 push es
C468 push bx ; bytes
C469 call DOS_ReadFile_toBuf
C46E mov [bp+argu_xmshandle], 0
C473 lea ax, [bp+argu_xmshandle]
C476 push ax ; argu_xmshandle
C477 push offset xms_handle_sss@0_evt_obj ; int
C47A call read_subfile
C47F fild [ds:length] ; (emulator call)
C484 fdiv [ds:fp64_32] ; (emulator call)
C489 fistp [ds:evt_objs] ; (emulator call)
C48E wait ; (emulator call)
C490 mov [bp+var_22], 1
C495 mov [bp+var_24], 0
C49A lea ax, [bp+var_22]
C49D push ax ; argu_xmshandle
C49E lea ax, [bp+var_24]
C4A1 push ax ; int
C4A2 call read_subfile
C4A7 mov si, offset DDIM_sss@1_scene_def
C4AA mov bx, 8
C4AD add bx, [si+0Ah]
C4B0 mov es, [word ptr si+2]
C4B3 push es
C4B4 push bx
C4B5 mov si, offset DDIM_screen_buf
C4B8 xor bx, bx
C4BA add bx, [si+0Ah]
C4BD mov es, [word ptr si+2]
C4C0 push es
C4C1 push bx
C4C2 mov bx, offset file_len_in_word
C4C5 push ds
C4C6 pop es
C4C7 push es
C4C8 push bx
C4C9 call transfer_MEM
C4CE mov [bp+var_26], 2
C4D3 mov [bp+var_28], 0
C4D8 lea ax, [bp+var_26]
C4DB push ax ; argu_xmshandle
C4DC lea ax, [bp+var_28]
C4DF push ax ; int
C4E0 call read_subfile
C4E5 mov si, offset DDIM_sss@2_object_defination
C4E8 xor bx, bx
C4EA add bx, [si+0Ah]
C4ED mov es, [word ptr si+2]
C4F0 push es
C4F1 push bx
C4F2 mov si, offset DDIM_screen_buf
C4F5 xor bx, bx
C4F7 add bx, [si+0Ah]
C4FA mov es, [word ptr si+2]
C4FD push es
C4FE push bx
C4FF mov bx, offset file_len_in_word
C502 push ds
C503 pop es
C504 push es
C505 push bx
C506 call transfer_MEM
C50B mov [bp+var_2A], 3
C510 lea ax, [bp+var_2A]
C513 push ax ; argu_xmshandle
C514 push offset xms_handle_sss@3_m_index ; int
C517 call read_subfile
C51C mov [bp+var_2C], 4
C521 lea ax, [bp+var_2C]
C524 push ax ; argu_xmshandle
C525 push offset xms_handle_sss@4_script ; int
C528 call read_subfile
C52D fild [ds:length] ; (emulator call)
C532 fdiv [ds:fp64_8] ; (emulator call)
C537 fsub [ds:fp64_1] ; (emulator call)
C53C fistp [ds:script_number] ; (emulator call)
C541 wait ; (emulator call)
C543 mov bx, offset file_handle
C546 push ds
C547 pop es
C548 push es ; int
C549 push bx ; file_handle
C54A call DOS_CloseFile
C54F push offset BSTR_Data_mkf ; psdSource
C552 lea ax, [bp+open_method]
C555 push ax ; psdDest
C556 call B$SAS1 ; String assignment
C55B mov [bp+var_32], 0
C560 lea ax, [bp+open_method]
C563 push ax ; open_method
C564 lea ax, [bp+var_32]
C567 push ax ; int
C568 call Open_File
C56D mov [bp+var_34], ax
C570 mov ax, [bp+var_34]
C573 mov [ds:file_handle], ax
C576 mov [word ptr bp+var_38], 40h ; '@'
C57B mov [word ptr bp+var_38+2], 0
C580 mov bx, offset file_handle
C583 push ds
C584 pop es
C585 push es ; int
C586 push bx ; file_handle
C587 mov si, offset DDIM_buf_index
C58A xor bx, bx
C58C add bx, [si+0Ah]
C58F mov es, [word ptr si+2]
C592 push es
C593 push bx ; buffer
C594 lea bx, [bp+var_38]
C597 push ds
C598 pop es
C599 push es
C59A push bx ; bytes
C59B call DOS_ReadFile_toBuf
C5A0 mov [bp+var_3A], 0
C5A5 mov [bp+var_3C], 0
C5AA lea ax, [bp+var_3A]
C5AD push ax ; argu_xmshandle
C5AE lea ax, [bp+var_3C]
C5B1 push ax ; int
C5B2 call read_subfile
C5B7 mov si, offset DDIM_data@0_shop
C5BA xor bx, bx
C5BC add bx, [si+0Ah]
C5BF mov es, [word ptr si+2]
C5C2 push es
C5C3 push bx
C5C4 mov si, offset DDIM_screen_buf
C5C7 xor bx, bx
C5C9 add bx, [si+0Ah]
C5CC mov es, [word ptr si+2]
C5CF push es
C5D0 push bx
C5D1 mov bx, offset file_len_in_word
C5D4 push ds
C5D5 pop es
C5D6 push es
C5D7 push bx
C5D8 call transfer_MEM
C5DD mov [bp+var_3E], 1
C5E2 lea ax, [bp+var_3E]
C5E5 push ax ; argu_xmshandle
C5E6 push offset xms_handle_data@1_enemy_data ; int
C5E9 call read_subfile
C5EE mov [bp+var_40], 2
C5F3 lea ax, [bp+var_40]
C5F6 push ax ; argu_xmshandle
C5F7 push offset xms_handle_data@2_enemy_team ; int
C5FA call read_subfile
C5FF mov [bp+var_42], 3
C604 mov [bp+var_44], 0
C609 lea ax, [bp+var_42]
C60C push ax ; argu_xmshandle
C60D lea ax, [bp+var_44]
C610 push ax ; int
C611 call read_subfile
C616 mov si, offset DDIM_data@3_our_data
C619 xor bx, bx
C61B add bx, [si+0Ah]
C61E mov es, [word ptr si+2]
C621 push es
C622 push bx
C623 mov si, offset DDIM_screen_buf
C626 xor bx, bx
C628 add bx, [si+0Ah]
C62B mov es, [word ptr si+2]
C62E push es
C62F push bx
C630 mov bx, offset file_len_in_word
C633 push ds
C634 pop es
C635 push es
C636 push bx
C637 call transfer_MEM
C63C mov [bp+var_46], 4
C641 lea ax, [bp+var_46]
C644 push ax ; argu_xmshandle
C645 push offset xms_handle_data@4_theurgy_data ; int
C648 call read_subfile
C64D mov [bp+var_48], 5
C652 lea ax, [bp+var_48]
C655 push ax ; argu_xmshandle
C656 push offset xms_handle_data@5_battlefield_effect ; int
C659 call read_subfile
C65E mov [bp+var_4A], 6
C663 mov [bp+var_4C], 0
C668 lea ax, [bp+var_4A]
C66B push ax ; argu_xmshandle
C66C lea ax, [bp+var_4C]
C66F push ax ; int
C670 call read_subfile
C675 mov si, offset DDIM_data@6_uplevel_theurgy
C678 xor bx, bx
C67A add bx, [si+0Ah]
C67D mov es, [word ptr si+2]
C680 push es
C681 push bx
C682 mov si, offset DDIM_screen_buf
C685 xor bx, bx
C687 add bx, [si+0Ah]
C68A mov es, [word ptr si+2]
C68D push es
C68E push bx
C68F mov bx, offset file_len_in_word
C692 push ds
C693 pop es
C694 push es
C695 push bx
C696 call transfer_MEM
C69B mov [bp+var_4E], 9
C6A0 lea ax, [bp+var_4E]
C6A3 push ax ; argu_xmshandle
C6A4 push offset xms_handle_data@9_menu_in_game ; int
C6A7 call read_subfile
C6AC mov ax, [word ptr ds:length]
C6AF mov dx, [word ptr ds:length+2]
C6B3 mov [word ptr ds:data@9_length], ax
C6B6 mov [word ptr ds:data@9_length+2], dx
C6BA mov [bp+var_50], 0Ah
C6BF lea ax, [bp+var_50]
C6C2 push ax ; argu_xmshandle
C6C3 push offset xms_handle_data@A_use_magic_effect ; int
C6C6 call read_subfile
C6CB mov ax, [word ptr ds:length]
C6CE mov dx, [word ptr ds:length+2]
C6D2 mov [word ptr ds:data@A_length], ax
C6D5 mov [word ptr ds:data@A_length+2], dx
C6D9 mov [bp+var_52], 0Bh
C6DE mov [bp+var_54], 0
C6E3 lea ax, [bp+var_52]
C6E6 push ax ; argu_xmshandle
C6E7 lea ax, [bp+var_54]
C6EA push ax ; int
C6EB call read_subfile
C6F0 mov si, offset DDIM_data@B_unknown
C6F3 xor bx, bx
C6F5 add bx, [si+0Ah]
C6F8 mov es, [word ptr si+2]
C6FB push es
C6FC push bx
C6FD mov si, offset DDIM_screen_buf
C700 xor bx, bx
C702 add bx, [si+0Ah]
C705 mov es, [word ptr si+2]
C708 push es
C709 push bx
C70A mov bx, offset file_len_in_word
C70D push ds
C70E pop es
C70F push es
C710 push bx
C711 call transfer_MEM
C716 mov [bp+var_56], 0Ch
C71B mov [bp+var_58], 0
C720 lea ax, [bp+var_56]
C723 push ax ; argu_xmshandle
C724 lea ax, [bp+var_58]
C727 push ax ; int
C728 call read_subfile
C72D mov si, offset DDIM_data@C_dialog_wait_icon
C730 xor bx, bx
C732 add bx, [si+0Ah]
C735 mov es, [word ptr si+2]
C738 push es
C739 push bx
C73A mov si, offset DDIM_screen_buf
C73D xor bx, bx
C73F add bx, [si+0Ah]
C742 mov es, [word ptr si+2]
C745 push es
C746 push bx
C747 mov bx, offset file_len_in_word
C74A push ds
C74B pop es
C74C push es
C74D push bx
C74E call transfer_MEM
C753 mov [bp+var_5A], 0Dh
C758 mov [bp+var_5C], 0
C75D lea ax, [bp+var_5A]
C760 push ax ; argu_xmshandle
C761 lea ax, [bp+var_5C]
C764 push ax ; int
C765 call read_subfile
C76A mov si, offset DDIM_data@D_enemy_position
C76D xor bx, bx
C76F add bx, [si+0Ah]
C772 mov es, [word ptr si+2]
C775 push es
C776 push bx
C777 mov si, offset DDIM_screen_buf
C77A xor bx, bx
C77C add bx, [si+0Ah]
C77F mov es, [word ptr si+2]
C782 push es
C783 push bx
C784 mov bx, offset file_len_in_word
C787 push ds
C788 pop es
C789 push es
C78A push bx
C78B call transfer_MEM
C790 mov [bp+var_5E], 0Eh
C795 lea ax, [bp+var_5E]
C798 push ax ; argu_xmshandle
C799 push offset xms_handle_data@E_uplevel_exp ; int
C79C call read_subfile
C7A1 mov bx, offset file_handle
C7A4 push ds
C7A5 pop es
C7A6 push es ; int
C7A7 push bx ; file_handle
C7A8 call DOS_CloseFile
C7AD push offset BSTR_Word_dat ; psdSource
C7B0 lea ax, [bp+argu_buffer]
C7B3 push ax ; psdDest
C7B4 call B$SAS1 ; String assignment
C7B9 mov si, offset DDIM_word_dat
C7BC xor bx, bx
C7BE add bx, [si+0Ah]
C7C1 mov es, [word ptr si+2]
C7C4 mov ax, es
C7C6 mov [bp+var_64], ax
C7C9 lea ax, [bp+argu_buffer]
C7CC push ax ; argu_buffer
C7CD lea ax, [bp+var_64]
C7D0 push ax ; int
C7D1 call ReadFile_toseg
C7D6 push offset BSTR_Wor16_asc ; psdSource
C7D9 lea ax, [bp+psdDest]
C7DC push ax ; psdDest
C7DD call B$SAS1 ; String assignment
C7E2 mov si, offset DDIM_wor16_asc
C7E5 xor bx, bx
C7E7 add bx, [si+0Ah]
C7EA mov es, [word ptr si+2]
C7ED mov ax, es
C7EF mov [bp+var_6A], ax
C7F2 lea ax, [bp+psdDest]
C7F5 push ax ; argu_buffer
C7F6 lea ax, [bp+var_6A]
C7F9 push ax ; int
C7FA call ReadFile_toseg
C7FF mov [ds:background_color], 0E9h
C805 xor ax, ax
C807 jmp loc_C828
C80A ; ---------------------------------------------------------------------------
C80A
C80A loc_C80A: ; CODE XREF: Load_system_files+41C↓j
C80A shl ax, 1
C80C mov bx, ax
C80E mov si, offset DDIM_wor16_asc
C811 add bx, [si+0Ah]
C814 mov es, [word ptr si+2]
C817 cmp [word ptr es:bx], 0
C81B jz short loc_C824
C81D mov ax, [bp+var_6C]
C820 inc ax
C821 mov [ds:total_ch_chars], ax
C824
C824 loc_C824: ; CODE XREF: Load_system_files+409↑j
C824 mov ax, [bp+var_6C]
C827 inc ax
C828
C828 loc_C828: ; CODE XREF: Load_system_files+3F5↑j
C828 mov [bp+var_6C], ax
C82B cmp ax, 0A8Bh
C82E jle short loc_C80A
C830 push offset BSTR_Wor16_fon ; psdSource
C833 lea ax, [bp+var_70]
C836 push ax ; psdDest
C837 call B$SAS1 ; String assignment
C83C mov [bp+var_72], 0
C841 lea ax, [bp+var_70]
C844 push ax ; open_method
C845 lea ax, [bp+var_72]
C848 push ax ; int
C849 call Open_File
C84E mov [bp+var_74], ax
C851 mov ax, [bp+var_74]
C854 mov [ds:file_handle], ax
C857 mov [word ptr bp+var_78], 682h
C85C mov [word ptr bp+var_78+2], 0
C861 mov bx, offset file_handle
C864 push ds
C865 pop es
C866 push es ; int
C867 push bx ; file_handle
C868 mov si, offset DDIM_buf_wor16_fon_buf
C86B xor bx, bx
C86D add bx, [si+0Ah]
C870 mov es, [word ptr si+2]
C873 push es
C874 push bx ; buffer
C875 lea bx, [bp+var_78]
C878 push ds
C879 pop es
C87A push es
C87B push bx ; bytes
C87C call DOS_ReadFile_toBuf
C881 mov [word ptr bp+dst_offset], 0
C886 mov [word ptr bp+dst_offset+2], 0
C88B mov [word ptr ds:length], 8000h
C891 mov [word ptr ds:length+2], 0
C897 nop
C898
C898 loc_C898: ; CODE XREF: Load_system_files+4F6↓j
C898 push [word ptr ds:length+2] ; op1_h
C89C push [word ptr ds:length] ; op1_l
C8A0 push 0 ; op2_h
C8A2 push 8000h ; op2_l
C8A5 call B$CPI4 ; long integer compare
C8AA jz short loc_C8AF
C8AC jmp loc_C90A
C8AF ; ---------------------------------------------------------------------------
C8AF
C8AF loc_C8AF: ; CODE XREF: Load_system_files+498↑j
C8AF mov bx, offset file_handle
C8B2 push ds
C8B3 pop es
C8B4 push es ; int
C8B5 push bx ; file_handle
C8B6 mov si, offset DDIM_buf_glb_1_redraw
C8B9 xor bx, bx
C8BB add bx, [si+0Ah]
C8BE mov es, [word ptr si+2]
C8C1 push es
C8C2 push bx ; buffer
C8C3 mov bx, offset length
C8C6 push ds
C8C7 pop es
C8C8 push es
C8C9 push bx ; bytes
C8CA call DOS_ReadFile_toBuf
C8CF mov si, offset DDIM_buf_glb_1_redraw
C8D2 xor bx, bx
C8D4 add bx, [si+0Ah]
C8D7 mov es, [word ptr si+2]
C8DA push es ; int
C8DB push bx ; src_offset
C8DC mov bx, offset length
C8DF push ds
C8E0 pop es
C8E1 push es
C8E2 push bx ; length
C8E3 mov bx, offset xms_handle_wor16_fon
C8E6 push ds
C8E7 pop es
C8E8 push es
C8E9 push bx ; dst_handle
C8EA lea bx, [bp+dst_offset]
C8ED push ds
C8EE pop es
C8EF push es
C8F0 push bx ; dst_offset
C8F1 call XMS_CopyBlockToXMS_byOffset
C8F6 mov ax, [word ptr bp+dst_offset]
C8F9 mov dx, [word ptr bp+dst_offset+2]
C8FC add ax, 8000h
C8FF adc dx, 0
C902 mov [word ptr bp+dst_offset], ax
C905 mov [word ptr bp+dst_offset+2], dx
C908 jmp short loc_C898
C90A ; ---------------------------------------------------------------------------
C90A
C90A loc_C90A: ; CODE XREF: Load_system_files+49A↑j
C90A mov bx, offset file_handle
C90D push ds
C90E pop es
C90F push es ; int
C910 push bx ; file_handle
C911 call DOS_CloseFile
C916 call B$EXSA ; clear frame state info
C91B retf 0
C91B endp Load_system_files
C91B
C91E ; ---------------------------------------------------------------------------
C91E
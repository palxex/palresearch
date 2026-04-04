seg000:
EAFD ; =============== S U B R O U T I N E =======================================
EAFD
EAFD ; Attributes: bp-based frame
EAFD
EAFD proc Load_Data far ; CODE XREF: real_entry:call_change_map↑P
EAFD ; process_scripts+3D6B↓P
EAFD
EAFD var_1A = word ptr -1Ah
EAFD index = word ptr -18h
EAFD script = word ptr -16h
EAFD obj = word ptr -14h
EAFD
EAFD mov cx, 8
EB00 mov bx, 0
EB03 call far ptr B$ENRA ; setup stack & other state info.
EB08
EB08 not_inited: ; CODE XREF: Load_Data+126↓j
EB08 mov [ds:flag_battling?], 0
EB0E mov [ds:x_off], 0
EB14 mov [ds:y_off], 0
EB1A mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EB1D and ax, 10h
EB20 and ax, ax
EB22 jnz short read_voc
EB24 jmp next
EB27 ; ---------------------------------------------------------------------------
EB27
EB27 read_voc: ; CODE XREF: Load_Data+25↑j
EB27 call read_voc_to_xms_leaving
EB2C
EB2C next: ; CODE XREF: Load_Data+27↑j
EB2C mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EB2F and ax, 20h
EB32 and ax, ax
EB34 jnz short load__rpg
EB36 jmp next2
EB39 ; ---------------------------------------------------------------------------
EB39
EB39 load__rpg: ; CODE XREF: Load_Data+37↑j
EB39 push offset rpg_to_load_
EB3C call LoadRPG_internal
EB41 jmp next3
EB44 ; ---------------------------------------------------------------------------
EB44
EB44 next2: ; CODE XREF: Load_Data+39↑j
EB44 mov ax, [ds:scene_to_load]
EB47 cmp ax, [ds:RPG_curr_scene]
EB4B jnz short scene_changed
EB4D jmp next3
EB50 ; ---------------------------------------------------------------------------
EB50
EB50 scene_changed: ; CODE XREF: Load_Data+4E↑j
EB50 mov [ds:RPG_screen_wave_grade], 0
EB56 mov [ds:wave_progression], 0
EB5C cmp [ds:RPG_curr_scene], 0
EB61 jg short scene_not_loaded_once
EB63 jmp next3
EB66 ; ---------------------------------------------------------------------------
EB66
EB66 scene_not_loaded_once: ; CODE XREF: Load_Data+64↑j
EB66 call save_evt_obj_curr_scene
EB6B
EB6B next3: ; CODE XREF: Load_Data+44↑j
EB6B ; Load_Data+50↑j
EB6B ; Load_Data+66↑j
EB6B mov [ds:redraw_flag], 0 ; 0:生成,1:停工,2:淡入gop暂存屏
EB71 mov [ds:x_scrn_offset], 0A0h
EB77 mov [ds:y_scrn_offset], 70h
EB7D mov ax, [ds:scene_to_load]
EB80 mov [ds:RPG_curr_scene], ax
EB83 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EB86 and ax, 4
EB89 and ax, ax
EB8B jnz short next4
EB8D jmp draw
EB90 ; ---------------------------------------------------------------------------
EB90
EB90 next4: ; CODE XREF: Load_Data+8E↑j
EB90 push offset RPG_curr_scene
EB93 call Get_EventObject_for_currScene
EB98
EB98 draw: ; CODE XREF: Load_Data+90↑j
EB98 push offset RPG_curr_scene
EB9B call get_scene_map_source
EBA0 call get_sprites_curr_scene
EBA5 call produce_one_screen_map
EBAA mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EBAD and ax, 1
EBB0 and ax, ax
EBB2 jnz short load_team_data
EBB4 jmp next5
EBB7 ; ---------------------------------------------------------------------------
EBB7
EBB7 load_team_data: ; CODE XREF: Load_Data+B5↑j
EBB7 call load_team_mgo
EBBC
EBBC next5: ; CODE XREF: Load_Data+B7↑j
EBBC mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EBBF and ax, 8
EBC2 and ax, ax
EBC4 jnz short changescene
EBC6 jmp next6
EBC9 ; ---------------------------------------------------------------------------
EBC9
EBC9 changescene: ; CODE XREF: Load_Data+C7↑j
EBC9 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EBCC and ax, 2
EBCF mov [ds:flag_to_load], ax ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EBD2 mov [bp+obj], 0
EBD7 mov bx, [ds:RPG_curr_scene]
EBDB shl bx, 1
EBDD shl bx, 1
EBDF shl bx, 1
EBE1 mov si, offset DDIM_sss@1_scene_def
EBE4 mov dx, bx
EBE6 add bx, [si+0Ah]
EBE9 mov es, [word ptr si+2]
EBEC add bx, 2
EBEF mov ax, [es:bx]
EBF2 mov [bp+script], ax
EBF5 lea ax, [bp+obj]
EBF8 push ax ; argu_script
EBF9 lea ax, [bp+script]
EBFC push ax ; int
EBFD mov [bp+index], dx
EC00 call process_Script ; 场景进入脚本
EC05 mov si, offset DDIM_sss@1_scene_def
EC08 mov bx, [bp+index]
EC0B add bx, [si+0Ah]
EC0E mov es, [word ptr si+2]
EC11 add bx, 2
EC14 mov ax, [bp+script]
EC17 mov [es:bx], ax
EC1A mov ax, [ds:scene_to_load]
EC1D cmp ax, [ds:RPG_curr_scene]
EC21 jz short next6
EC23 jmp not_inited
EC26 ; ---------------------------------------------------------------------------
EC26
EC26 next6: ; CODE XREF: Load_Data+C9↑j
EC26 ; Load_Data+124↑j
EC26 mov ax, [ds:flag_to_load] ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EC29 and ax, 2
EC2C and ax, ax
EC2E jnz short play_music
EC30 jmp next7
EC33 ; ---------------------------------------------------------------------------
EC33
EC33 play_music: ; CODE XREF: Load_Data+131↑j
EC33 mov [bp+var_1A], 1
EC38 push offset RPG_music_number
EC3B lea ax, [bp+var_1A]
EC3E push ax
EC3F call play_rix_music
EC44
EC44 next7: ; CODE XREF: Load_Data+133↑j
EC44 mov [ds:flag_to_load], 0 ; 20h:last_save,10h:sfx,8:scene,4:evt,2:music,1:team_mgo
EC4A call setup_our_team_data_things
EC4F call B$EXSA ; clear frame state info
EC54 retf 0
EC54 endp Load_Data
EC54
EC57 ; ---------------------------------------------------------------------------
EC57
seg000:
0E54 ; =============== S U B R O U T I N E =======================================
0E54
0E54
0E54 proc calc_team_walking near ; CODE XREF: real_entry:loc_DFF↑p
0E54 cmp [ds:x_off], 0
0E59 jnz short leftright_0
0E5B mov ax, [ds:y_off]
0E5E neg ax
0E60
0E60 loc_E60:
0E60 mov [ds:x_off], ax
0E63
0E63 leftright_0: ; CODE XREF: calc_team_walking+5↑j
0E63 cmp [ds:y_off], 0
0E68 jnz short loc_E70
0E6A mov ax, [ds:x_off]
0E6D mov [ds:y_off], ax
0E70
0E70 loc_E70: ; CODE XREF: calc_team_walking+14↑j
0E70 mov [ds:x_direction_offset], 0
0E76 mov [ds:y_direction_offset], 0
0E7C cmp [ds:x_off], 0
0E81 jnz short loc_E86
0E83 jmp not_walking
0E86 ; ---------------------------------------------------------------------------
0E86
0E86 loc_E86: ; CODE XREF: calc_team_walking+2D↑j
0E86 mov ax, [ds:RPG_viewport_x]
0E89 add ax, [ds:x_scrn_offset]
0E8D mov cx, [ds:x_off]
0E91 shl cx, 1
0E93 shl cx, 1
0E95 shl cx, 1
0E97 shl cx, 1
0E99 add ax, cx
0E9B mov [ds:abstract_x_target], ax
0E9E mov ax, [ds:RPG_viewport_y]
0EA1 add ax, [ds:y_scrn_offset]
0EA5 mov cx, [ds:y_off]
0EA9 shl cx, 1
0EAB shl cx, 1
0EAD shl cx, 1
0EAF add ax, cx
0EB1 mov [ds:abstract_y_target], ax
0EB4 mov [ds:nobody], 0
0EBA push offset abstract_x_target ; a_y
0EBD push offset abstract_y_target ; a_self
0EC0 push offset nobody ; int
0EC3 call barrier_check ; 0阻碍
0EC8 mov [ds:flag_can_go_through], ax
0ECB mov ax, [ds:could_go_through]
0ECE or ax, [ds:flag_can_go_through]
0ED2 and ax, ax
0ED4 jz short not_walking
0ED6 mov ax, [ds:step_off_x]
0ED9 imul [ds:x_off]
0EDD mov [ds:x_direction_offset], ax
0EE0 mov ax, [ds:step_off_y]
0EE3 imul [ds:y_off]
0EE7 mov [ds:y_direction_offset], ax
0EEA mov [ds:flag_through], 1
0EF0
0EF0 not_walking: ; CODE XREF: calc_team_walking+2F↑j
0EF0 ; calc_team_walking+80↑j
0EF0 mov bx, offset RPG_team_direction
0EF3 push ds
0EF4 pop es
0EF5 push es
0EF6 push bx ; argu_face_to
0EF7 mov bx, offset x_off
0EFA push ds
0EFB pop es
0EFC push es
0EFD push bx ; argu_x_diff
0EFE mov bx, offset y_off
0F01 push ds
0F02 pop es
0F03 push es
0F04 push bx ; argu_y_diff
0F05 call calc_facing_to
0F0A mov ax, [ds:x_scrn_offset]
0F0D add ax, [ds:RPG_viewport_x]
0F11 mov [ds:abstract_x_bak], ax
0F14 mov ax, [ds:y_scrn_offset]
0F17 add ax, [ds:RPG_viewport_y]
0F1B mov [ds:abstract_y_bak], ax
0F1E mov ax, [ds:RPG_viewport_x]
0F21 mov [ds:viewport_x_bak], ax
0F24 mov cx, [ds:RPG_viewport_y]
0F28 mov [ds:viewport_y_bak], cx
0F2C cmp [ds:flag_through], 0
0F31 jg short through
0F33 jmp not_through
0F36 ; ---------------------------------------------------------------------------
0F36
0F36 through: ; CODE XREF: calc_team_walking+DD↑j
0F36 dec [ds:flag_through]
0F3A mov dx, [ds:x_direction_offset]
0F3E add [ds:RPG_viewport_x], dx
0F42 mov dx, [ds:y_direction_offset]
0F46 add [ds:RPG_viewport_y], dx
0F4A mov bx, offset RPG_viewport_x
0F4D push ds
0F4E pop es
0F4F push es
0F50 push bx
0F51 mov bx, offset RPG_viewport_y
0F54 push ds
0F55 pop es
0F56 push es
0F57 push bx
0F58 mov bx, offset coordinate_x_max
0F5B push ds
0F5C pop es
0F5D push es
0F5E push bx
0F5F mov bx, offset coordinate_y_max
0F62 push ds
0F63 pop es
0F64 push es
0F65 push bx
0F66 call ensure_role_in_map_boundary
0F6B mov ax, [ds:viewport_x_bak]
0F6E cmp ax, [ds:RPG_viewport_x]
0F72 jnz short donot_need_sync_y
0F74 mov ax, [ds:viewport_y_bak]
0F77 mov [ds:RPG_viewport_y], ax
0F7A
0F7A donot_need_sync_y: ; CODE XREF: calc_team_walking+11E↑j
0F7A mov ax, [ds:viewport_y_bak]
0F7D cmp ax, [ds:RPG_viewport_y]
0F81 jnz short donot_need_sync_x
0F83 mov ax, [ds:viewport_x_bak]
0F86 mov [ds:RPG_viewport_x], ax
0F89
0F89 donot_need_sync_x: ; CODE XREF: calc_team_walking+12D↑j
0F89 call team_walk_one_step
0F8E jmp next
0F91 ; ---------------------------------------------------------------------------
0F91
0F91 not_through: ; CODE XREF: calc_team_walking+DF↑j
0F91 call stop_and_update_frame
0F96
0F96 next: ; CODE XREF: calc_team_walking+13A↑j
0F96 mov ax, [ds:RPG_viewport_x]
0F99 add ax, [ds:x_scrn_offset]
0F9D mov [ds:team_abstract_x], ax
0FA0 mov ax, [ds:RPG_viewport_y]
0FA3 add ax, [ds:y_scrn_offset]
0FA7 mov [ds:team_abstract_y], ax
0FAA retn
0FAA endp calc_team_walking
0FAA
0FAB
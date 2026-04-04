seg000:1B65 ; =============== S U B R O U T I N E =======================================
seg000:1B65
seg000:1B65 ; Attributes: bp-based frame
seg000:1B65
seg000:1B65 proc            process_Explore near    ; CODE XREF: real_entry:serviey↑p
seg000:1B65
seg000:1B65 var_14          = word ptr -14h
seg000:1B65
seg000:1B65                 push    offset team_abstract_x ; argu_y
seg000:1B68                 push    offset team_abstract_y ; argu_direction
seg000:1B6B                 push    offset RPG_team_direction ; int
seg000:1B6E                 call    get_the_trigger_event
seg000:1B73                 mov     [ds:trig_script?], ax
seg000:1B76                 mov     ax, [ds:trig_script?]
seg000:1B79                 mov     [ds:trig_object], ax
seg000:1B7C                 or      ax, ax
seg000:1B7E                 jge     short loc_1B83
seg000:1B80                 jmp     locret_1C6D
seg000:1B83 ; ---------------------------------------------------------------------------
seg000:1B83
seg000:1B83 loc_1B83:                               ; CODE XREF: process_Explore+19↑j
seg000:1B83                 shl     ax, 1
seg000:1B85                 shl     ax, 1
seg000:1B87                 shl     ax, 1
seg000:1B89                 shl     ax, 1
seg000:1B8B                 shl     ax, 1
seg000:1B8D                 mov     bx, ax
seg000:1B8F                 mov     si, offset DDIM_evt_obj_curr_scene
seg000:1B92                 add     bx, [si+0Ah]
seg000:1B95                 mov     es, [word ptr si+2]
seg000:1B98                 add     bx, 16h
seg000:1B9B                 mov     cx, [es:bx]
seg000:1B9E                 mov     bx, ax
seg000:1BA0                 add     bx, [si+0Ah]
seg000:1BA3                 mov     es, [word ptr si+2]
seg000:1BA6                 add     bx, 12h
seg000:1BA9                 mov     dx, [es:bx]
seg000:1BAC                 shl     dx, 1
seg000:1BAE                 shl     dx, 1
seg000:1BB0                 cmp     cx, dx
seg000:1BB2                 jl      short loc_1BB7
seg000:1BB4                 jmp     loc_1C28
seg000:1BB7 ; ---------------------------------------------------------------------------
seg000:1BB7
seg000:1BB7 loc_1BB7:                               ; CODE XREF: process_Explore+4D↑j
seg000:1BB7                 mov     bx, ax
seg000:1BB9                 add     bx, [si+0Ah]
seg000:1BBC                 mov     es, [word ptr si+2]
seg000:1BBF                 add     bx, 16h
seg000:1BC2                 mov     [word ptr es:bx], 0
seg000:1BC7                 mov     cx, [ds:RPG_team_direction]
seg000:1BCB                 add     cx, 2
seg000:1BCE                 and     cx, 3
seg000:1BD1                 mov     bx, ax
seg000:1BD3                 add     bx, [si+0Ah]
seg000:1BD6                 mov     es, [word ptr si+2]
seg000:1BD9                 add     bx, 14h
seg000:1BDC                 mov     [es:bx], cx
seg000:1BDF                 mov     ax, [ds:RPG_team_number]
seg000:1BE2                 mov     [ds:word_2F5B6], ax
seg000:1BE5                 xor     ax, ax
seg000:1BE7                 jmp     loc_1C11
seg000:1BEA ; ---------------------------------------------------------------------------
seg000:1BEA
seg000:1BEA loc_1BEA:                               ; CODE XREF: process_Explore+B3↓j
seg000:1BEA                 mov     ax, 3
seg000:1BED                 imul    [ds:RPG_team_direction]
seg000:1BF1                 mov     bx, ax
seg000:1BF3                 mov     ax, 0Ah
seg000:1BF6                 imul    [ds:loop_counter]
seg000:1BFA                 mov     dx, bx
seg000:1BFC                 mov     bx, ax
seg000:1BFE                 mov     si, offset DDIM_RPG_team_positions ; 每人10字节,0:号,2:posX,4:posY,6:方向桢,8:MGO_MemMKF_offset
seg000:1C01                 add     bx, [si+0Ah]
seg000:1C04                 mov     es, [word ptr si+2]
seg000:1C07                 add     bx, 6
seg000:1C0A                 mov     [es:bx], dx
seg000:1C0D                 mov     ax, [ds:loop_counter]
seg000:1C10                 inc     ax
seg000:1C11
seg000:1C11 loc_1C11:                               ; CODE XREF: process_Explore+82↑j
seg000:1C11                 mov     [ds:loop_counter], ax
seg000:1C14                 cmp     ax, [ds:word_2F5B6]
seg000:1C18                 jle     short loc_1BEA
seg000:1C1A                 mov     [ds:word_2F5B8], 0
seg000:1C20                 push    offset word_2F5B8
seg000:1C23                 call    redraw_everything
seg000:1C28
seg000:1C28 loc_1C28:                               ; CODE XREF: process_Explore+4F↑j
seg000:1C28                 mov     bx, [ds:trig_object]
seg000:1C2C                 shl     bx, 1
seg000:1C2E                 shl     bx, 1
seg000:1C30                 shl     bx, 1
seg000:1C32                 shl     bx, 1
seg000:1C34                 shl     bx, 1
seg000:1C36                 mov     si, offset DDIM_evt_obj_curr_scene
seg000:1C39                 mov     dx, bx
seg000:1C3B                 add     bx, [si+0Ah]
seg000:1C3E                 mov     es, [word ptr si+2]
seg000:1C41                 add     bx, 8
seg000:1C44                 mov     ax, [es:bx]
seg000:1C47                 mov     [ds:trig_script], ax
seg000:1C4A                 push    offset trig_object ; argu_script
seg000:1C4D                 push    offset trig_script ; int
seg000:1C50                 mov     [bp+var_14], dx
seg000:1C53                 call    process_Script  ; 按键触发脚本
seg000:1C58                 mov     si, offset DDIM_evt_obj_curr_scene
seg000:1C5B                 mov     bx, [bp+var_14]
seg000:1C5E                 add     bx, [si+0Ah]
seg000:1C61                 mov     es, [word ptr si+2]
seg000:1C64                 add     bx, 8
seg000:1C67                 mov     ax, [ds:trig_script]
seg000:1C6A                 mov     [es:bx], ax
seg000:1C6D
seg000:1C6D locret_1C6D:                            ; CODE XREF: process_Explore+1B↑j
seg000:1C6D                 retn
seg000:1C6D endp            process_Explore

seg001:B602 ; =============== S U B R O U T I N E =======================================
seg001:B602
seg001:B602 ; Attributes: bp-based frame
seg001:B602
seg001:B602 proc            GameLoop_OneCycle far   ; CODE XREF: real_entry+D9F↑P
seg001:B602                                         ; process_Script+5A1↑P
seg001:B602                                         ; process_scripts+2155↑P
seg001:B602                                         ; process_scripts+39D1↑P
seg001:B602                                         ; process_scripts+421E↑P
seg001:B602                                         ; process_scripts+42DD↑P
seg001:B602                                         ; FadeInOrOut_internal+9C↑P
seg001:B602
seg001:B602 barrior_        = word ptr -38h
seg001:B602 self            = word ptr -36h
seg001:B602 direction       = word ptr -34h
seg001:B602 var_32          = word ptr -32h
seg001:B602 index2          = word ptr -30h
seg001:B602 autoscript      = word ptr -2Eh
seg001:B602 evtobjs2        = word ptr -2Ch
seg001:B602 y_offset        = word ptr -2Ah
seg001:B602 x_offset        = word ptr -28h
seg001:B602 index           = word ptr -26h
seg001:B602 trigger_script  = word ptr -24h
seg001:B602 var_22          = word ptr -22h
seg001:B602 evtobj_counter  = word ptr -20h
seg001:B602 distance_absolute= word ptr -1Eh
seg001:B602 evtobj_index    = word ptr -1Ch
seg001:B602 y_off           = word ptr -1Ah
seg001:B602 x_off           = word ptr -18h
seg001:B602 max_trigger_distance= word ptr -16h
seg001:B602 evtobjs         = word ptr -14h
seg001:B602 flag_trigger    = word ptr  6
seg001:B602
seg001:B602                 mov     cx, 26h ; '&'
seg001:B605                 mov     bx, 0
seg001:B608                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:B60D                 cmp     [ds:mutex_can_change_palette], 0
seg001:B612                 jz      short next
seg001:B614                 jmp     return
seg001:B617 ; ---------------------------------------------------------------------------
seg001:B617
seg001:B617 next:                                   ; CODE XREF: GameLoop_OneCycle+10↑j
seg001:B617                 mov     ax, [ds:evt_objs_curr_scene]
seg001:B61A                 mov     [bp+evtobjs], ax
seg001:B61D                 mov     ax, 1
seg001:B620                 jmp     begin
seg001:B623 ; ---------------------------------------------------------------------------
seg001:B623                 nop
seg001:B624
seg001:B624 evt_loop:                               ; CODE XREF: GameLoop_OneCycle+2AD↓j
seg001:B624                 shl     ax, 1
seg001:B626                 shl     ax, 1
seg001:B628                 shl     ax, 1
seg001:B62A                 shl     ax, 1
seg001:B62C                 shl     ax, 1
seg001:B62E                 mov     bx, ax
seg001:B630                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B633                 add     bx, [si+DDIM.offset]
seg001:B636                 mov     es, [si+DDIM.header.segment]
seg001:B639                 add     bx, event_object.obj_status ; 触发状态
seg001:B63C                 cmp     [word ptr es:bx], 0
seg001:B640                 jnz     short status_not_0
seg001:B642                 jmp     go_continue?
seg001:B645 ; ---------------------------------------------------------------------------
seg001:B645
seg001:B645 status_not_0:                           ; CODE XREF: GameLoop_OneCycle+3E↑j
seg001:B645                 mov     bx, ax
seg001:B647                 add     bx, [si+DDIM.offset]
seg001:B64A                 mov     es, [si+DDIM.header.segment]
seg001:B64D                 mov     cx, [es:bx]
seg001:B650                 mov     bx, ax
seg001:B652                 add     bx, [si+DDIM.offset]
seg001:B655                 mov     es, [si+DDIM.header.segment]
seg001:B658                 mov     dx, [es:bx]
seg001:B65B                 and     dx, dx
seg001:B65D                 jz      short chk_next
seg001:B65F                 mov     dx, 1           ; 不等于0就是1
seg001:B662                 jge     short chk_next
seg001:B664                 neg     dx              ; 要是负数就是-1
seg001:B666
seg001:B666 chk_next:                               ; CODE XREF: GameLoop_OneCycle+5B↑j
seg001:B666                                         ; GameLoop_OneCycle+60↑j
seg001:B666                 sub     cx, dx
seg001:B668                 mov     bx, ax
seg001:B66A                 add     bx, [si+DDIM.offset]
seg001:B66D                 mov     es, [si+DDIM.header.segment]
seg001:B670                 mov     [es:bx], cx
seg001:B673                 mov     bx, ax
seg001:B675                 add     bx, [si+DDIM.offset]
seg001:B678                 mov     es, [si+DDIM.header.segment]
seg001:B67B                 add     bx, event_object.obj_status
seg001:B67E                 cmp     [word ptr es:bx], 0
seg001:B682                 jg      short status_more_than_0
seg001:B684                 jmp     status_less_than_0
seg001:B687 ; ---------------------------------------------------------------------------
seg001:B687
seg001:B687 status_more_than_0:                     ; CODE XREF: GameLoop_OneCycle+80↑j
seg001:B687                 mov     bx, ax
seg001:B689                 add     bx, [si+DDIM.offset]
seg001:B68C                 mov     es, [si+DDIM.header.segment]
seg001:B68F                 cmp     [word ptr es:bx], 0
seg001:B693                 mov     cx, 0
seg001:B696                 jnz     short _1111_not_0
seg001:B698                 dec     cx
seg001:B699
seg001:B699 _1111_not_0:                            ; CODE XREF: GameLoop_OneCycle+94↑j
seg001:B699                 mov     bx, ax
seg001:B69B                 add     bx, [si+DDIM.offset]
seg001:B69E                 mov     es, [si+DDIM.header.segment]
seg001:B6A1                 add     bx, event_object.trigger_method
seg001:B6A4                 cmp     [word ptr es:bx], 4
seg001:B6A8                 mov     dx, 0
seg001:B6AB                 jl      short trig_method_need_key
seg001:B6AD                 dec     dx
seg001:B6AE
seg001:B6AE trig_method_need_key:                   ; CODE XREF: GameLoop_OneCycle+A9↑j
seg001:B6AE                 and     cx, dx
seg001:B6B0                 mov     di, [bp+flag_trigger]
seg001:B6B3                 and     cx, [di]
seg001:B6B5                 and     cx, cx
seg001:B6B7                 jnz     short chk_next_ ; 1111=0 and 8888>=4 and arg_mask
seg001:B6B9                 jmp     jmp_not_active
seg001:B6BC ; ---------------------------------------------------------------------------
seg001:B6BC
seg001:B6BC chk_next_:                              ; CODE XREF: GameLoop_OneCycle+B5↑j
seg001:B6BC                 mov     bx, ax
seg001:B6BE                 add     bx, [si+DDIM.offset]
seg001:B6C1                 mov     es, [si+DDIM.header.segment]
seg001:B6C4                 add     bx, event_object.trigger_method
seg001:B6C7                 mov     cx, [es:bx]
seg001:B6CA                 sub     cx, 4
seg001:B6CD                 shl     cx, 1
seg001:B6CF                 shl     cx, 1
seg001:B6D1                 shl     cx, 1
seg001:B6D3                 shl     cx, 1
seg001:B6D5                 shl     cx, 1
seg001:B6D7                 add     cx, 10h
seg001:B6DA                 mov     [bp+max_trigger_distance], cx
seg001:B6DD                 mov     bx, ax
seg001:B6DF                 add     bx, [si+DDIM.offset]
seg001:B6E2                 mov     es, [si+DDIM.header.segment]
seg001:B6E5                 add     bx, event_object.pos_x
seg001:B6E8                 mov     dx, [es:bx]
seg001:B6EB                 sub     dx, [ds:team_abstract_x]
seg001:B6EF                 neg     dx
seg001:B6F1                 mov     [bp+x_off], dx
seg001:B6F4                 mov     bx, ax
seg001:B6F6                 add     bx, [si+0Ah]
seg001:B6F9                 mov     es, [word ptr si+2]
seg001:B6FC                 add     bx, 4
seg001:B6FF                 mov     bx, [es:bx]
seg001:B702                 sub     bx, [ds:team_abstract_y]
seg001:B706                 neg     bx
seg001:B708                 mov     [bp+y_off], bx
seg001:B70B                 mov     [bp+evtobj_index], ax
seg001:B70E                 mov     ax, dx
seg001:B710                 cwd
seg001:B711                 xor     ax, dx
seg001:B713                 sub     ax, dx
seg001:B715                 mov     dx, ax
seg001:B717                 mov     ax, bx
seg001:B719                 mov     [bp+distance_absolute], dx
seg001:B71C                 cwd
seg001:B71D                 xor     ax, dx
seg001:B71F                 sub     ax, dx
seg001:B721                 shl     ax, 1
seg001:B723                 add     ax, [bp+distance_absolute]
seg001:B726                 cmp     cx, ax
seg001:B728                 jg      short triggle_event
seg001:B72A                 jmp     jmp_not_active
seg001:B72D ; ---------------------------------------------------------------------------
seg001:B72D
seg001:B72D triggle_event:                          ; CODE XREF: GameLoop_OneCycle+126↑j
seg001:B72D                 mov     bx, [bp+evtobj_index]
seg001:B730                 add     bx, [si+0Ah]
seg001:B733                 mov     es, [word ptr si+2]
seg001:B736                 add     bx, event_object.frames
seg001:B739                 cmp     [word ptr es:bx], 0
seg001:B73D                 jg      short frames_not_0
seg001:B73F                 jmp     frames_0
seg001:B742 ; ---------------------------------------------------------------------------
seg001:B742
seg001:B742 frames_not_0:                           ; CODE XREF: GameLoop_OneCycle+13B↑j
seg001:B742                 call    stop_and_update_frame
seg001:B747                 mov     bx, [bp+evtobj_counter]
seg001:B74A                 shl     bx, 1
seg001:B74C                 shl     bx, 1
seg001:B74E                 shl     bx, 1
seg001:B750                 shl     bx, 1
seg001:B752                 shl     bx, 1
seg001:B754                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B757                 add     bx, [si+0Ah]
seg001:B75A                 mov     es, [word ptr si+2]
seg001:B75D                 add     bx, 16h         ; 特殊图像参数?
seg001:B760                 mov     [word ptr es:bx], 0
seg001:B765                 mov     bx, [bp+evtobj_counter]
seg001:B768                 shl     bx, 1
seg001:B76A                 shl     bx, 1
seg001:B76C                 shl     bx, 1
seg001:B76E                 shl     bx, 1
seg001:B770                 shl     bx, 1
seg001:B772                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B775                 add     bx, [si+0Ah]
seg001:B778                 mov     es, [word ptr si+2]
seg001:B77B                 add     bx, event_object.direction
seg001:B77E                 push    es
seg001:B77F                 push    bx              ; argu_face_to
seg001:B780                 lea     bx, [bp+x_off]
seg001:B783                 push    ds
seg001:B784                 pop     es
seg001:B785                 push    es
seg001:B786                 push    bx              ; argu_x_diff
seg001:B787                 lea     bx, [bp+y_off]
seg001:B78A                 push    ds
seg001:B78B                 pop     es
seg001:B78C                 push    es
seg001:B78D                 push    bx              ; argu_y_diff
seg001:B78E                 call    calc_facing_to
seg001:B793                 mov     [bp+var_22], 1
seg001:B798                 lea     ax, [bp+var_22]
seg001:B79B                 push    ax
seg001:B79C                 call    redraw_everything
seg001:B7A1
seg001:B7A1 frames_0:                               ; CODE XREF: GameLoop_OneCycle+13D↑j
seg001:B7A1                 mov     [ds:x_off], 0
seg001:B7A7                 mov     [ds:y_off], 0
seg001:B7AD                 mov     bx, [bp+evtobj_counter]
seg001:B7B0                 shl     bx, 1
seg001:B7B2                 shl     bx, 1
seg001:B7B4                 shl     bx, 1
seg001:B7B6                 shl     bx, 1
seg001:B7B8                 shl     bx, 1
seg001:B7BA                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B7BD                 mov     dx, bx
seg001:B7BF                 add     bx, [si+0Ah]
seg001:B7C2                 mov     es, [word ptr si+2]
seg001:B7C5                 add     bx, 8
seg001:B7C8                 mov     ax, [es:bx]
seg001:B7CB                 mov     [bp+trigger_script], ax
seg001:B7CE                 lea     ax, [bp+evtobj_counter]
seg001:B7D1                 push    ax              ; argu_script
seg001:B7D2                 lea     ax, [bp+trigger_script]
seg001:B7D5                 push    ax              ; int
seg001:B7D6                 mov     [bp+index], dx
seg001:B7D9                 call    process_Script  ; 自动触发脚本
seg001:B7DE                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B7E1                 mov     bx, [bp+index]
seg001:B7E4                 add     bx, [si+0Ah]
seg001:B7E7                 mov     es, [word ptr si+2]
seg001:B7EA                 add     bx, 8
seg001:B7ED                 mov     ax, [bp+trigger_script]
seg001:B7F0                 mov     [es:bx], ax
seg001:B7F3
seg001:B7F3 jmp_not_active:                         ; CODE XREF: GameLoop_OneCycle+B7↑j
seg001:B7F3                                         ; GameLoop_OneCycle+128↑j
seg001:B7F3                 jmp     go_continue?
seg001:B7F6 ; ---------------------------------------------------------------------------
seg001:B7F6
seg001:B7F6 status_less_than_0:                     ; CODE XREF: GameLoop_OneCycle+82↑j
seg001:B7F6                 mov     bx, [bp+evtobj_counter]
seg001:B7F9                 shl     bx, 1
seg001:B7FB                 shl     bx, 1
seg001:B7FD                 shl     bx, 1
seg001:B7FF                 shl     bx, 1
seg001:B801                 shl     bx, 1
seg001:B803                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B806                 mov     dx, bx
seg001:B808                 add     bx, [si+DDIM.offset]
seg001:B80B                 mov     es, [si+DDIM.header.segment]
seg001:B80E                 cmp     [word ptr es:bx], 0
seg001:B812                 jz      short vanishtime_0
seg001:B814                 jmp     go_continue?
seg001:B817 ; ---------------------------------------------------------------------------
seg001:B817
seg001:B817 vanishtime_0:                           ; CODE XREF: GameLoop_OneCycle+210↑j
seg001:B817                 mov     bx, dx
seg001:B819                 add     bx, [si+DDIM.offset]
seg001:B81C                 mov     es, [si+DDIM.header.segment]
seg001:B81F                 add     bx, event_object.pos_x
seg001:B822                 mov     ax, [es:bx]
seg001:B825                 sub     ax, [ds:RPG_viewport_x]
seg001:B829                 mov     [bp+x_offset], ax
seg001:B82C                 mov     bx, dx
seg001:B82E                 add     bx, [si+DDIM.offset]
seg001:B831                 mov     es, [si+DDIM.header.segment]
seg001:B834                 add     bx, event_object.pos_y
seg001:B837                 mov     cx, [es:bx]
seg001:B83A                 sub     cx, [ds:RPG_viewport_y]
seg001:B83E                 mov     [bp+y_offset], cx
seg001:B841                 or      ax, ax
seg001:B843                 jl      short not_in_boundary
seg001:B845                 cmp     ax, 320
seg001:B848                 jg      short not_in_boundary
seg001:B84A                 or      cx, cx
seg001:B84C                 jl      short not_in_boundary
seg001:B84E                 cmp     cx, 220
seg001:B852                 jle     short go_continue?
seg001:B854
seg001:B854 not_in_boundary:                        ; CODE XREF: GameLoop_OneCycle+241↑j
seg001:B854                                         ; GameLoop_OneCycle+246↑j
seg001:B854                                         ; GameLoop_OneCycle+24A↑j
seg001:B854                 mov     bx, [bp+evtobj_counter]
seg001:B857                 shl     bx, 1
seg001:B859                 shl     bx, 1
seg001:B85B                 shl     bx, 1
seg001:B85D                 shl     bx, 1
seg001:B85F                 shl     bx, 1
seg001:B861                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B864                 mov     dx, bx
seg001:B866                 add     bx, [si+DDIM.offset]
seg001:B869                 mov     es, [si+DDIM.header.segment]
seg001:B86C                 add     bx, event_object.obj_status
seg001:B86F                 mov     ax, [es:bx]
seg001:B872                 mov     cx, dx
seg001:B874                 cwd
seg001:B875                 xor     ax, dx
seg001:B877                 sub     ax, dx
seg001:B879                 mov     bx, cx
seg001:B87B                 add     bx, [si+DDIM.offset]
seg001:B87E                 mov     es, [si+DDIM.header.segment]
seg001:B881                 add     bx, event_object.obj_status
seg001:B884                 mov     [es:bx], ax
seg001:B887                 mov     bx, cx
seg001:B889                 add     bx, [si+DDIM.offset]
seg001:B88C                 mov     es, [si+DDIM.header.segment]
seg001:B88F                 add     bx, event_object.curr_frame
seg001:B892                 mov     [word ptr es:bx], 0
seg001:B897
seg001:B897 go_continue?:                           ; CODE XREF: GameLoop_OneCycle+40↑j
seg001:B897                                         ; GameLoop_OneCycle:jmp_not_active↑j
seg001:B897                                         ; GameLoop_OneCycle+212↑j
seg001:B897                                         ; GameLoop_OneCycle+250↑j
seg001:B897                 mov     ax, [ds:RPG_curr_scene]
seg001:B89A                 cmp     ax, [ds:scene_to_load]
seg001:B89E                 jz      short continue
seg001:B8A0                 jmp     return
seg001:B8A3 ; ---------------------------------------------------------------------------
seg001:B8A3
seg001:B8A3 continue:                               ; CODE XREF: GameLoop_OneCycle+29C↑j
seg001:B8A3                 mov     ax, [bp+evtobj_counter]
seg001:B8A6                 inc     ax
seg001:B8A7
seg001:B8A7 begin:                                  ; CODE XREF: GameLoop_OneCycle+1E↑j
seg001:B8A7                 mov     [bp+evtobj_counter], ax
seg001:B8AA                 cmp     ax, [bp+evtobjs]
seg001:B8AD                 jg      short loop_end
seg001:B8AF                 jmp     evt_loop
seg001:B8B2 ; ---------------------------------------------------------------------------
seg001:B8B2
seg001:B8B2 loop_end:                               ; CODE XREF: GameLoop_OneCycle+2AB↑j
seg001:B8B2                 mov     ax, [ds:evt_objs_curr_scene]
seg001:B8B5                 mov     [bp+evtobjs2], ax
seg001:B8B8                 mov     ax, 1
seg001:B8BB                 jmp     begin_2
seg001:B8BE ; ---------------------------------------------------------------------------
seg001:B8BE
seg001:B8BE evt_loop_2:                             ; CODE XREF: GameLoop_OneCycle+4A2↓j
seg001:B8BE                 shl     ax, 1
seg001:B8C0                 shl     ax, 1
seg001:B8C2                 shl     ax, 1
seg001:B8C4                 shl     ax, 1
seg001:B8C6                 shl     ax, 1
seg001:B8C8                 mov     bx, ax
seg001:B8CA                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B8CD                 add     bx, [si+0Ah]
seg001:B8D0                 mov     es, [word ptr si+2]
seg001:B8D3                 add     bx, 0Ch
seg001:B8D6                 cmp     [word ptr es:bx], 0
seg001:B8DA                 jg      short active2
seg001:B8DC                 jmp     continue2
seg001:B8DF ; ---------------------------------------------------------------------------
seg001:B8DF
seg001:B8DF active2:                                ; CODE XREF: GameLoop_OneCycle+2D8↑j
seg001:B8DF                 mov     bx, ax
seg001:B8E1                 add     bx, [si+0Ah]
seg001:B8E4                 mov     es, [word ptr si+2]
seg001:B8E7                 cmp     [word ptr es:bx], 0
seg001:B8EB                 jz      short active_2
seg001:B8ED                 jmp     not_active2
seg001:B8F0 ; ---------------------------------------------------------------------------
seg001:B8F0
seg001:B8F0 active_2:                               ; CODE XREF: GameLoop_OneCycle+2E9↑j
seg001:B8F0                 mov     bx, [bp+evtobj_counter]
seg001:B8F3                 shl     bx, 1
seg001:B8F5                 shl     bx, 1
seg001:B8F7                 shl     bx, 1
seg001:B8F9                 shl     bx, 1
seg001:B8FB                 shl     bx, 1
seg001:B8FD                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B900                 mov     dx, bx
seg001:B902                 add     bx, [si+0Ah]
seg001:B905                 mov     es, [word ptr si+2]
seg001:B908                 add     bx, 0Ah
seg001:B90B                 mov     ax, [es:bx]
seg001:B90E                 mov     [bp+autoscript], ax
seg001:B911                 lea     ax, [bp+evtobj_counter]
seg001:B914                 push    ax              ; argu_script
seg001:B915                 lea     ax, [bp+autoscript]
seg001:B918                 push    ax              ; int
seg001:B919                 mov     [bp+index2], dx
seg001:B91C                 call    process_AutoScript
seg001:B921                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B924                 mov     bx, [bp+index2]
seg001:B927                 add     bx, [si+0Ah]
seg001:B92A                 mov     es, [word ptr si+2]
seg001:B92D                 add     bx, 0Ah
seg001:B930                 mov     ax, [bp+autoscript]
seg001:B933                 mov     [es:bx], ax
seg001:B936
seg001:B936 not_active2:                            ; CODE XREF: GameLoop_OneCycle+2EB↑j
seg001:B936                 mov     bx, [bp+evtobj_counter]
seg001:B939                 shl     bx, 1
seg001:B93B                 shl     bx, 1
seg001:B93D                 shl     bx, 1
seg001:B93F                 shl     bx, 1
seg001:B941                 shl     bx, 1
seg001:B943                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:B946                 mov     dx, bx
seg001:B948                 add     bx, [si+0Ah]
seg001:B94B                 mov     es, [word ptr si+2]
seg001:B94E                 add     bx, 0Ch
seg001:B951                 cmp     [word ptr es:bx], 2
seg001:B955                 mov     ax, 0
seg001:B958                 jnz     short next1
seg001:B95A                 dec     ax
seg001:B95B
seg001:B95B next1:                                  ; CODE XREF: GameLoop_OneCycle+356↑j
seg001:B95B                 mov     bx, dx
seg001:B95D                 add     bx, [si+0Ah]
seg001:B960                 mov     es, [word ptr si+2]
seg001:B963                 add     bx, 10h
seg001:B966                 cmp     [word ptr es:bx], 0
seg001:B96A                 mov     cx, 0
seg001:B96D                 jle     short next2
seg001:B96F                 dec     cx
seg001:B970
seg001:B970 next2:                                  ; CODE XREF: GameLoop_OneCycle+36B↑j
seg001:B970                 and     ax, cx
seg001:B972                 mov     di, [bp+flag_trigger]
seg001:B975                 and     ax, [di]
seg001:B977                 and     ax, ax
seg001:B979                 jnz     short gogogo
seg001:B97B                 jmp     continue2
seg001:B97E ; ---------------------------------------------------------------------------
seg001:B97E
seg001:B97E gogogo:                                 ; CODE XREF: GameLoop_OneCycle+377↑j
seg001:B97E                 mov     bx, dx
seg001:B980                 add     bx, [si+0Ah]
seg001:B983                 mov     es, [word ptr si+2]
seg001:B986                 add     bx, 2
seg001:B989                 mov     ax, [es:bx]
seg001:B98C                 sub     ax, [ds:team_abstract_x]
seg001:B990                 neg     ax
seg001:B992                 mov     [bp+x_off], ax
seg001:B995                 mov     bx, dx
seg001:B997                 add     bx, [si+0Ah]
seg001:B99A                 mov     es, [word ptr si+2]
seg001:B99D                 add     bx, 4
seg001:B9A0                 mov     cx, [es:bx]
seg001:B9A3                 sub     cx, [ds:team_abstract_y]
seg001:B9A7                 neg     cx
seg001:B9A9                 mov     [bp+y_off], cx
seg001:B9AC                 mov     bx, dx
seg001:B9AE                 cwd
seg001:B9AF                 xor     ax, dx
seg001:B9B1                 sub     ax, dx
seg001:B9B3                 mov     dx, ax
seg001:B9B5                 mov     ax, cx
seg001:B9B7                 mov     [bp+var_32], dx
seg001:B9BA                 cwd
seg001:B9BB                 xor     ax, dx
seg001:B9BD                 sub     ax, dx
seg001:B9BF                 shl     ax, 1
seg001:B9C1                 add     ax, [bp+var_32]
seg001:B9C4                 cmp     ax, 0Dh
seg001:B9C7                 jl      short in_boundary
seg001:B9C9                 jmp     continue2
seg001:B9CC ; ---------------------------------------------------------------------------
seg001:B9CC
seg001:B9CC in_boundary:                            ; CODE XREF: GameLoop_OneCycle+3C5↑j
seg001:B9CC                 add     bx, [si+0Ah]
seg001:B9CF                 mov     es, [word ptr si+2]
seg001:B9D2                 add     bx, event_object.direction
seg001:B9D5                 mov     ax, [es:bx]
seg001:B9D8                 mov     [bp+direction], ax
seg001:B9DB
seg001:B9DB snake_loop?:                            ; CODE XREF: GameLoop_OneCycle+493↓j
seg001:B9DB                 mov     ax, [bp+direction]
seg001:B9DE                 inc     ax
seg001:B9DF                 and     ax, 3
seg001:B9E2                 mov     [bp+direction], ax
seg001:B9E5                 shl     ax, 1
seg001:B9E7                 mov     bx, ax
seg001:B9E9                 mov     si, offset DDIM_x_off_fff0_fff0_10_10
seg001:B9EC                 add     bx, [si+0Ah]
seg001:B9EF                 mov     es, [word ptr si+2]
seg001:B9F2                 mov     cx, [es:bx]
seg001:B9F5                 add     cx, [ds:team_abstract_x]
seg001:B9F9                 mov     [bp+x_offset], cx
seg001:B9FC                 mov     bx, ax
seg001:B9FE                 mov     si, offset DDIM_y_off_8_fff8_fff8_8
seg001:BA01                 add     bx, [si+0Ah]
seg001:BA04                 mov     es, [word ptr si+2]
seg001:BA07                 mov     ax, [es:bx]
seg001:BA0A                 add     ax, [ds:team_abstract_y]
seg001:BA0E                 mov     [bp+y_offset], ax
seg001:BA11                 mov     [bp+self], 0
seg001:BA16                 lea     ax, [bp+x_offset]
seg001:BA19                 push    ax              ; a_y
seg001:BA1A                 lea     ax, [bp+y_offset]
seg001:BA1D                 push    ax              ; a_self
seg001:BA1E                 lea     ax, [bp+self]
seg001:BA21                 push    ax              ; int
seg001:BA22                 call    barrier_check   ; 0阻碍
seg001:BA27                 mov     [bp+barrior_], ax
seg001:BA2A                 mov     ax, [bp+barrior_]
seg001:BA2D                 and     ax, ax
seg001:BA2F                 jnz     short ok_stop
seg001:BA31                 jmp     loc_1B4D4
seg001:BA34 ; ---------------------------------------------------------------------------
seg001:BA34
seg001:BA34 ok_stop:                                ; CODE XREF: GameLoop_OneCycle+42D↑j
seg001:BA34                 mov     ax, [ds:team_abstract_x]
seg001:BA37                 mov     [ds:abstract_x_bak], ax
seg001:BA3A                 mov     ax, [ds:team_abstract_y]
seg001:BA3D                 mov     [ds:abstract_y_bak], ax
seg001:BA40                 mov     ax, [bp+x_offset]
seg001:BA43                 mov     [ds:team_abstract_x], ax
seg001:BA46                 mov     cx, [bp+y_offset]
seg001:BA49                 mov     [ds:team_abstract_y], cx
seg001:BA4D                 mov     dx, [ds:RPG_viewport_x]
seg001:BA51                 mov     [ds:viewport_x_bak], dx
seg001:BA55                 mov     dx, [ds:RPG_viewport_y]
seg001:BA59                 mov     [ds:viewport_y_bak], dx
seg001:BA5D                 sub     ax, [ds:x_scrn_offset]
seg001:BA61                 mov     [ds:RPG_viewport_x], ax
seg001:BA64                 sub     cx, [ds:y_scrn_offset]
seg001:BA68                 mov     [ds:RPG_viewport_y], cx
seg001:BA6C                 call    move_usable_screen
seg001:BA71                 jmp     continue2
seg001:BA74 ; ---------------------------------------------------------------------------
seg001:BA74
seg001:BA74 loc_1B4D4:                              ; CODE XREF: GameLoop_OneCycle+42F↑j
seg001:BA74                 mov     bx, [bp+evtobj_counter]
seg001:BA77                 shl     bx, 1
seg001:BA79                 shl     bx, 1
seg001:BA7B                 shl     bx, 1
seg001:BA7D                 shl     bx, 1
seg001:BA7F                 shl     bx, 1
seg001:BA81                 mov     si, offset DDIM_evt_obj_curr_scene
seg001:BA84                 add     bx, [si+0Ah]
seg001:BA87                 mov     es, [word ptr si+2]
seg001:BA8A                 add     bx, 14h
seg001:BA8D                 mov     ax, [es:bx]
seg001:BA90                 cmp     ax, [bp+direction]
seg001:BA93                 jz      short continue2
seg001:BA95                 jmp     snake_loop?
seg001:BA98 ; ---------------------------------------------------------------------------
seg001:BA98
seg001:BA98 continue2:                              ; CODE XREF: GameLoop_OneCycle+2DA↑j
seg001:BA98                                         ; GameLoop_OneCycle+379↑j
seg001:BA98                                         ; GameLoop_OneCycle+3C7↑j
seg001:BA98                                         ; GameLoop_OneCycle+46F↑j
seg001:BA98                                         ; GameLoop_OneCycle+491↑j
seg001:BA98                 mov     ax, [bp+evtobj_counter]
seg001:BA9B                 inc     ax
seg001:BA9C
seg001:BA9C begin_2:                                ; CODE XREF: GameLoop_OneCycle+2B9↑j
seg001:BA9C                 mov     [bp+evtobj_counter], ax
seg001:BA9F                 cmp     ax, [bp+evtobjs2]
seg001:BAA2                 jg      short exit_loop
seg001:BAA4                 jmp     evt_loop_2
seg001:BAA7 ; ---------------------------------------------------------------------------
seg001:BAA7
seg001:BAA7 exit_loop:                              ; CODE XREF: GameLoop_OneCycle+4A0↑j
seg001:BAA7                 dec     [ds:RPG_change_chaserate_times]
seg001:BAAB                 cmp     [ds:RPG_change_chaserate_times], 0
seg001:BAB0                 jg      short return
seg001:BAB2                 mov     [ds:RPG_ememy_chase_rate], 1
seg001:BAB8                 mov     [ds:RPG_change_chaserate_times], 0
seg001:BABE
seg001:BABE return:                                 ; CODE XREF: GameLoop_OneCycle+12↑j
seg001:BABE                                         ; GameLoop_OneCycle+29E↑j
seg001:BABE                                         ; GameLoop_OneCycle+4AE↑j
seg001:BABE                 call    B$EXSA          ; clear frame state info
seg001:BAC3                 retf    2
seg001:BAC3 endp            GameLoop_OneCycle

seg000:463E ; =============== S U B R O U T I N E =======================================
seg000:463E
seg000:463E ; Attributes: bp-based frame
seg000:463E
seg000:463E proc            menu_select far         ; CODE XREF: real_entry+C1D↑P
seg000:463E                                         ; menu_loop+5E↑P
seg000:463E                                         ; menu_Magic_selecting+DE↓P
seg000:463E
seg000:463E var_38          = word ptr -38h
seg000:463E var_index_      = word ptr -36h
seg000:463E var_pressed_color= word ptr -34h
seg000:463E var_text_index_ = word ptr -32h
seg000:463E var_y_          = word ptr -30h
seg000:463E var_x_          = word ptr -2Eh
seg000:463E var_key         = word ptr -2Ch
seg000:463E var_index       = word ptr -2Ah
seg000:463E var_text_index  = word ptr -28h
seg000:463E var_color___var_key= word ptr -26h
seg000:463E var_menu_counter= word ptr -24h
seg000:463E var_x           = word ptr -22h
seg000:463E var_y           = word ptr -20h
seg000:463E var_menuid_max  = word ptr -1Eh
seg000:463E var_selecting   = word ptr -1Ch
seg000:463E var_shadow      = word ptr -1Ah
seg000:463E var_frame_begin = word ptr -18h
seg000:463E var_menus_dec   = word ptr -16h
seg000:463E var_14          = word ptr -14h
seg000:463E arg_menus       = word ptr  6
seg000:463E arg_literals    = word ptr  8
seg000:463E arg_y           = word ptr  0Ah
seg000:463E arg_x           = word ptr  0Ch
seg000:463E arg_selecting   = word ptr  0Eh
seg000:463E
seg000:463E                 mov     cx, 26h ; '&'
seg000:4641                 mov     bx, 0
seg000:4644                 call    far ptr B$ENRA  ; setup stack & other state info.
seg000:4649                 mov     si, [bp+arg_literals]
seg000:464C                 mov     ax, [si]
seg000:464E                 dec     ax
seg000:464F                 mov     [bp+var_14], ax
seg000:4652                 mov     si, [bp+arg_menus]
seg000:4655                 mov     ax, [si]
seg000:4657                 dec     ax
seg000:4658                 mov     [bp+var_menus_dec], ax
seg000:465B                 mov     [bp+var_frame_begin], 0
seg000:4660                 mov     [bp+var_shadow], 0FFFFh
seg000:4665                 push    [bp+arg_x]
seg000:4668                 push    [bp+arg_y]
seg000:466B                 lea     ax, [bp+var_frame_begin]
seg000:466E                 push    ax
seg000:466F                 push    [bp+arg_literals]
seg000:4672                 push    [bp+arg_menus]
seg000:4675                 lea     ax, [bp+var_shadow]
seg000:4678                 push    ax
seg000:4679                 call    frame_menu
seg000:467E                 mov     [bp+var_selecting], 0FFFEh
seg000:4683                 nop
seg000:4684
seg000:4684 select_loop:                            ; CODE XREF: menu_select:not_down↓j
seg000:4684                 cmp     [bp+var_selecting], 0FFFEh
seg000:4688                 jz      short still_selecting
seg000:468A                 jmp     return
seg000:468D ; ---------------------------------------------------------------------------
seg000:468D
seg000:468D still_selecting:                        ; CODE XREF: menu_select+4A↑j
seg000:468D                 mov     si, [bp+arg_selecting]
seg000:4690                 cmp     [word ptr si], 0
seg000:4693                 jge     short arg_valid_min
seg000:4695                 mov     ax, [bp+var_menus_dec]
seg000:4698                 mov     [si], ax
seg000:469A
seg000:469A arg_valid_min:                          ; CODE XREF: menu_select+55↑j
seg000:469A                 mov     si, [bp+arg_selecting]
seg000:469D                 mov     ax, [si]
seg000:469F                 cmp     ax, [bp+var_menus_dec]
seg000:46A2                 jle     short arg_valid_max
seg000:46A4                 mov     [word ptr si], 0
seg000:46A8
seg000:46A8 arg_valid_max:                          ; CODE XREF: menu_select+64↑j
seg000:46A8                 mov     si, [bp+arg_y]
seg000:46AB                 mov     ax, [si]
seg000:46AD                 add     ax, 0Ch
seg000:46B0                 mov     [bp+var_y], ax
seg000:46B3                 mov     si, [bp+arg_x]
seg000:46B6                 mov     ax, [si]
seg000:46B8                 add     ax, 0Dh
seg000:46BB                 mov     [bp+var_x], ax
seg000:46BE                 mov     ax, [bp+var_menus_dec]
seg000:46C1                 mov     [bp+var_menuid_max], ax
seg000:46C4                 xor     ax, ax
seg000:46C6                 jmp     begin_menu_show
seg000:46C9 ; ---------------------------------------------------------------------------
seg000:46C9                 nop
seg000:46CA
seg000:46CA menu_show_loop:                         ; CODE XREF: menu_select+133↓j
seg000:46CA                 shl     ax, 1
seg000:46CC                 add     ax, 200
seg000:46CF                 mov     bx, ax
seg000:46D1                 mov     si, offset DDIM_buf_common_short
seg000:46D4                 add     bx, [si+0Ah]
seg000:46D7                 mov     es, [word ptr si+2]
seg000:46DA                 mov     ax, [es:bx]
seg000:46DD                 and     ax, ax
seg000:46DF                 jnz     short selectable
seg000:46E1                 jmp     not_selectable
seg000:46E4 ; ---------------------------------------------------------------------------
seg000:46E4
seg000:46E4 selectable:                             ; CODE XREF: menu_select+A1↑j
seg000:46E4                 mov     si, [bp+arg_selecting]
seg000:46E7                 mov     ax, [si]
seg000:46E9                 cmp     ax, [bp+var_menu_counter]
seg000:46EC                 jnz     short selectable_not_on
seg000:46EE                 cmp     [bp+var_selecting], 0FFFEh
seg000:46F2                 jnz     short selectable_not_on
seg000:46F4                 mov     [bp+var_color___var_key], 0FAh
seg000:46F9                 jmp     selectable_on
seg000:46FC ; ---------------------------------------------------------------------------
seg000:46FC
seg000:46FC selectable_not_on:                      ; CODE XREF: menu_select+AE↑j
seg000:46FC                                         ; menu_select+B4↑j
seg000:46FC                 mov     [bp+var_color___var_key], 4Eh ; 'N'
seg000:4701
seg000:4701 selectable_on:                          ; CODE XREF: menu_select+BB↑j
seg000:4701                 jmp     color_ok
seg000:4704 ; ---------------------------------------------------------------------------
seg000:4704
seg000:4704 not_selectable:                         ; CODE XREF: menu_select+A3↑j
seg000:4704                 mov     si, [bp+arg_selecting]
seg000:4707                 mov     ax, [si]
seg000:4709                 cmp     ax, [bp+var_menu_counter]
seg000:470C                 jnz     short notselectable_noton
seg000:470E                 cmp     [bp+var_selecting], 0FFFEh
seg000:4712                 jnz     short notselectable_noton
seg000:4714                 mov     [bp+var_color___var_key], 1Ch
seg000:4719                 jmp     color_ok
seg000:471C ; ---------------------------------------------------------------------------
seg000:471C
seg000:471C notselectable_noton:                    ; CODE XREF: menu_select+CE↑j
seg000:471C                                         ; menu_select+D4↑j
seg000:471C                 mov     [bp+var_color___var_key], 18h
seg000:4721
seg000:4721 color_ok:                               ; CODE XREF: menu_select:selectable_on↑j
seg000:4721                                         ; menu_select+DB↑j
seg000:4721                 mov     bx, [bp+var_menu_counter]
seg000:4724                 shl     bx, 1
seg000:4726                 mov     si, offset DDIM_buf_common_short
seg000:4729                 mov     dx, bx
seg000:472B                 add     bx, [si+0Ah]
seg000:472E                 mov     es, [word ptr si+2]
seg000:4731                 mov     ax, [es:bx]
seg000:4734                 mov     [bp+var_text_index], ax
seg000:4737                 lea     ax, [bp+var_x]
seg000:473A                 push    ax
seg000:473B                 lea     ax, [bp+var_y]
seg000:473E                 push    ax
seg000:473F                 lea     ax, [bp+var_text_index]
seg000:4742                 push    ax
seg000:4743                 lea     ax, [bp+var_color___var_key]
seg000:4746                 push    ax
seg000:4747                 mov     [bp+var_index], dx
seg000:474A                 call    show_text_shadow
seg000:474F                 mov     si, offset DDIM_buf_common_short
seg000:4752                 mov     bx, [bp+var_index]
seg000:4755                 add     bx, [si+0Ah]
seg000:4758                 mov     es, [word ptr si+2]
seg000:475B                 mov     ax, [bp+var_text_index]
seg000:475E                 mov     [es:bx], ax
seg000:4761                 add     [bp+var_y], 12h
seg000:4765                 mov     ax, [bp+var_menu_counter]
seg000:4768                 inc     ax
seg000:4769
seg000:4769 begin_menu_show:                        ; CODE XREF: menu_select+88↑j
seg000:4769                 mov     [bp+var_menu_counter], ax
seg000:476C                 cmp     ax, [bp+var_menuid_max]
seg000:476F                 jg      short go_key
seg000:4771                 jmp     menu_show_loop
seg000:4774 ; ---------------------------------------------------------------------------
seg000:4774
seg000:4774 go_key:                                 ; CODE XREF: menu_select+131↑j
seg000:4774                 call    WaitForKey_internal
seg000:4779                 mov     [bp+var_key], ax
seg000:477C                 mov     ax, [bp+var_key]
seg000:477F                 mov     [bp+var_color___var_key], ax
seg000:4782                 cmp     ax, 1
seg000:4785                 jnz     short not_escape
seg000:4787                 mov     [bp+var_selecting], 0FFFFh
seg000:478C
seg000:478C not_escape:                             ; CODE XREF: menu_select+147↑j
seg000:478C                 cmp     [bp+var_color___var_key], 2
seg000:4790                 mov     ax, 0
seg000:4793                 jnz     short not_enter
seg000:4795                 dec     ax
seg000:4796
seg000:4796 not_enter:                              ; CODE XREF: menu_select+155↑j
seg000:4796                 mov     si, [bp+arg_selecting]
seg000:4799                 mov     cx, [si]
seg000:479B                 mov     bx, cx
seg000:479D                 shl     cx, 1
seg000:479F                 add     cx, 200
seg000:47A3                 mov     dx, bx
seg000:47A5                 mov     bx, cx
seg000:47A7                 mov     si, offset DDIM_buf_common_short
seg000:47AA                 add     bx, [si+0Ah]
seg000:47AD                 mov     es, [word ptr si+2]
seg000:47B0                 and     ax, [es:bx]
seg000:47B3                 and     ax, ax
seg000:47B5                 jnz     short can_select
seg000:47B7                 jmp     cannot_select
seg000:47BA ; ---------------------------------------------------------------------------
seg000:47BA
seg000:47BA can_select:                             ; CODE XREF: menu_select+177↑j
seg000:47BA                 mov     [bp+var_selecting], dx
seg000:47BD                 mov     si, [bp+arg_x]
seg000:47C0                 mov     ax, [si]
seg000:47C2                 add     ax, 0Dh
seg000:47C5                 mov     [bp+var_x_], ax
seg000:47C8                 mov     ax, 12h
seg000:47CB                 imul    [bp+var_selecting]
seg000:47CE                 mov     si, [bp+arg_y]
seg000:47D1                 add     ax, [si]
seg000:47D3                 add     ax, 0Ch
seg000:47D6                 mov     [bp+var_y_], ax
seg000:47D9                 mov     bx, [bp+var_selecting]
seg000:47DC                 shl     bx, 1
seg000:47DE                 mov     si, offset DDIM_buf_common_short
seg000:47E1                 mov     dx, bx
seg000:47E3                 add     bx, [si+0Ah]
seg000:47E6                 mov     es, [word ptr si+2]
seg000:47E9                 mov     ax, [es:bx]
seg000:47EC                 mov     [bp+var_text_index_], ax
seg000:47EF                 mov     [bp+var_pressed_color], 2Bh ; '+'
seg000:47F4                 lea     ax, [bp+var_x_]
seg000:47F7                 push    ax
seg000:47F8                 lea     ax, [bp+var_y_]
seg000:47FB                 push    ax
seg000:47FC                 lea     ax, [bp+var_text_index_]
seg000:47FF                 push    ax
seg000:4800                 lea     ax, [bp+var_pressed_color]
seg000:4803                 push    ax
seg000:4804                 mov     [bp+var_index_], dx
seg000:4807                 call    show_text_shadow
seg000:480C                 mov     si, offset DDIM_buf_common_short
seg000:480F                 mov     bx, [bp+var_index_]
seg000:4812                 add     bx, [si+0Ah]
seg000:4815                 mov     es, [word ptr si+2]
seg000:4818                 mov     ax, [bp+var_text_index_]
seg000:481B                 mov     [es:bx], ax
seg000:481E
seg000:481E cannot_select:                          ; CODE XREF: menu_select+179↑j
seg000:481E                 cmp     [bp+var_color___var_key], 3
seg000:4822                 jnz     short not_up
seg000:4824                 mov     si, [bp+arg_selecting]
seg000:4827                 dec     [word ptr si]
seg000:4829
seg000:4829 not_up:                                 ; CODE XREF: menu_select+1E4↑j
seg000:4829                 cmp     [bp+var_color___var_key], 4
seg000:482D                 jnz     short not_down
seg000:482F                 mov     si, [bp+arg_selecting]
seg000:4832                 inc     [word ptr si]
seg000:4834
seg000:4834 not_down:                               ; CODE XREF: menu_select+1EF↑j
seg000:4834                 jmp     select_loop
seg000:4837 ; ---------------------------------------------------------------------------
seg000:4837                 nop
seg000:4838
seg000:4838 return:                                 ; CODE XREF: menu_select+4C↑j
seg000:4838                 mov     ax, [bp+var_selecting]
seg000:483B                 mov     [bp+var_38], ax
seg000:483E                 mov     ax, [bp+var_38]
seg000:4841                 call    B$EXSA          ; clear frame state info
seg000:4846                 retf    0Ah
seg000:4846 endp            menu_select
seg000:4846

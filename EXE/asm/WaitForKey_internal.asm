seg001:9E32 ; =============== S U B R O U T I N E =======================================
seg001:9E32
seg001:9E32 ; Attributes: bp-based frame
seg001:9E32
seg001:9E32 proc            WaitForKey_internal far ; CODE XREF: inventory_Equip+496↑P
seg001:9E32                                         ; select_thurgy:loc_4430↑P
seg001:9E32                                         ; menu_select:go_key↑P
seg001:9E32                                         ; sub_494C+FA↑P
seg001:9E32                                         ; select_item_with_filter:loc_5088↑P
seg001:9E32                                         ; shop_internal+496↑P
seg001:9E32                                         ; select_RPG_internal+250↑P
seg001:9E32                                         ; sub_118F4:loc_11CF0↑P
seg001:9E32                                         ; sub_11E02:loc_11F17↑P
seg001:9E32                                         ; yes_no_dialog+13B↑P
seg001:9E32                                         ; process_scripts:script4D_WaitForKeyPressed↑P
seg001:9E32                                         ; sub_17FA6+B↑P
seg001:9E32                                         ; show_role_status:loc_1DF85↓P
seg001:9E32                                         ; begin_scene:wait_and_exit↓P
seg001:9E32                                         ; wait_show_icon:loc_1F19C↓P
seg001:9E32
seg001:9E32 var_14          = word ptr -14h
seg001:9E32
seg001:9E32                 mov     cx, 2
seg001:9E35                 mov     bx, 0
seg001:9E38                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:9E3D                 mov     [ds:key_pressed], 0
seg001:9E43                 nop
seg001:9E44
seg001:9E44 parse_key_loop:                         ; CODE XREF: WaitForKey_internal+35↓j
seg001:9E44                 cmp     [ds:key_pressed], 0
seg001:9E49                 jz      short no_key
seg001:9E4B                 jmp     got
seg001:9E4E ; ---------------------------------------------------------------------------
seg001:9E4E
seg001:9E4E no_key:                                 ; CODE XREF: WaitForKey_internal+17↑j
seg001:9E4E                 mov     bx, offset key_pressed
seg001:9E51                 push    ds
seg001:9E52                 pop     es
seg001:9E53                 push    es
seg001:9E54                 push    bx
seg001:9E55                 mov     si, offset DDIM_keybuf
seg001:9E58                 xor     bx, bx
seg001:9E5A                 add     bx, [si+0Ah]
seg001:9E5D                 mov     es, [word ptr si+2]
seg001:9E60                 push    es
seg001:9E61                 push    bx
seg001:9E62                 call    Parse_key
seg001:9E67                 jmp     short parse_key_loop
seg001:9E69 ; ---------------------------------------------------------------------------
seg001:9E69                 nop
seg001:9E6A
seg001:9E6A got:                                    ; CODE XREF: WaitForKey_internal+19↑j
seg001:9E6A                 mov     ax, [ds:key_pressed]
seg001:9E6D                 mov     [bp+var_14], ax
seg001:9E70                 mov     ax, [bp+var_14]
seg001:9E73                 call    B$EXSA          ; clear frame state info
seg001:9E78                 retf    0
seg001:9E78 endp            WaitForKey_internal
seg001:9E78

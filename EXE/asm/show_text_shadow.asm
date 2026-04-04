seg000:DF63 ; =============== S U B R O U T I N E =======================================
seg000:DF63
seg000:DF63 ; Attributes: bp-based frame
seg000:DF63
seg000:DF63 proc            show_text_shadow far    ; CODE XREF: inventory_Equip+1E7↑P
seg000:DF63                                         ; inventory_Equip+351↑P
seg000:DF63                                         ; inventory_Equip+3D6↑P
seg000:DF63                                         ; select_thurgy+576↑P
seg000:DF63                                         ; menu_select+10C↑P
seg000:DF63                                         ; menu_select+1C9↑P
seg000:DF63                                         ; select_item_with_filter+452↑P
seg000:DF63                                         ; process_Battle+2E32↑P
seg000:DF63                                         ; process_Battle+2FB6↑P
seg000:DF63                                         ; escape_internal+19E↑P
seg000:DF63                                         ; summon_imgs?+53↑P
seg000:DF63                                         ; show_status_bar+2E6↑P
seg000:DF63                                         ; show_status_bar+330↑P
seg000:DF63                                         ; show_status_bar+378↑P
seg000:DF63                                         ; show_status_bar+3BC↑P ...
seg000:DF63
seg000:DF63 var_1A          = word ptr -1Ah
seg000:DF63 var_method_shadow= word ptr -18h
seg000:DF63 psdDest         = word ptr -16h
seg000:DF63 arg_color       = word ptr  6
seg000:DF63 arg_index       = word ptr  8
seg000:DF63 arg_y           = word ptr  0Ah
seg000:DF63 arg_x           = word ptr  0Ch
seg000:DF63
seg000:DF63                 mov     cx, 8
seg000:DF66                 mov     bx, 1
seg000:DF69                 call    far ptr B$ENRA  ; setup stack & other state info.
seg000:DF6E                 mov     si, [bp+arg_index]
seg000:DF71                 mov     ax, [si]
seg000:DF73                 mov     bx, 0Ah
seg000:DF76                 imul    bx
seg000:DF78                 mov     bx, ax
seg000:DF7A                 mov     si, offset DDIM_word_dat
seg000:DF7D                 add     bx, [si+0Ah]
seg000:DF80                 mov     es, [word ptr si+2]
seg000:DF83                 push    es
seg000:DF84                 push    bx
seg000:DF85                 mov     bx, ax
seg000:DF87                 mov     ax, 0Ah
seg000:DF8A                 push    ax
seg000:DF8B                 mov     [bp+var_1A], bx
seg000:DF8E                 call    B$LDFS          ; load fixed length string
seg000:DF93                 push    ax              ; psdSource
seg000:DF94                 lea     ax, [bp+psdDest]
seg000:DF97                 push    ax              ; psdDest
seg000:DF98                 call    B$SAS1          ; String assignment
seg000:DF9D                 mov     [bp+var_method_shadow], 0
seg000:DFA2                 push    [bp+arg_x]
seg000:DFA5                 push    [bp+arg_y]
seg000:DFA8                 lea     ax, [bp+psdDest]
seg000:DFAB                 push    ax
seg000:DFAC                 lea     ax, [bp+var_method_shadow]
seg000:DFAF                 push    ax
seg000:DFB0                 push    [bp+arg_color]
seg000:DFB3                 call    dialog_string
seg000:DFB8                 lea     ax, [bp+psdDest]
seg000:DFBB                 push    ds              ; src_seg
seg000:DFBC                 push    ax              ; src_off
seg000:DFBD                 xor     ax, ax
seg000:DFBF                 push    ax              ; src_len
seg000:DFC0                 mov     si, offset DDIM_word_dat
seg000:DFC3                 mov     bx, [bp+var_1A]
seg000:DFC6                 add     bx, [si+0Ah]
seg000:DFC9                 mov     es, [word ptr si+2]
seg000:DFCC                 push    es              ; dst_seg
seg000:DFCD                 push    bx              ; dst_off
seg000:DFCE                 mov     ax, 0Ah
seg000:DFD1                 push    ax              ; dst_len
seg000:DFD2                 call    STRINGASSIGN
seg000:DFD7                 call    B$EXSA          ; clear frame state info
seg000:DFDC                 retf    8
seg000:DFDC endp            show_text_shadow
seg000:DFDC

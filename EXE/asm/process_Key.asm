seg001:1116 ; =============== S U B R O U T I N E =======================================
seg001:1116
seg001:1116 ; Attributes: bp-based frame
seg001:1116
seg001:1116 ; int __stdcall __far process_Key(int, int a_updown)
seg001:1116 proc            process_Key far         ; CODE XREF: real_entry+D85↑P
seg001:1116
seg001:1116 status_counter  = word ptr -1Eh
seg001:1116 press_status    = word ptr -1Ch         ; 1:�ͷ�,2:ѹ��
seg001:1116 right_status    = word ptr -1Ah
seg001:1116 left_status     = word ptr -18h
seg001:1116 down_status     = word ptr -16h
seg001:1116 up_status       = word ptr -14h
seg001:1116 a_updown        = word ptr  6
seg001:1116 a_leftright     = word ptr  8
seg001:1116
seg001:1116                 mov     cx, 0Ch
seg001:1119                 mov     bx, 0
seg001:111C                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:1121                 mov     bx, offset key_pressed
seg001:1124                 push    ds
seg001:1125                 pop     es
seg001:1126                 push    es
seg001:1127                 push    bx
seg001:1128                 mov     si, offset DDIM_keybuf
seg001:112B                 xor     bx, bx
seg001:112D                 add     bx, [si+0Ah]
seg001:1130                 mov     es, [word ptr si+2]
seg001:1133                 push    es
seg001:1134                 push    bx
seg001:1135                 call    Parse_key
seg001:113A                 mov     [bp+up_status], 0
seg001:113F                 mov     [bp+down_status], 0
seg001:1144                 mov     [bp+left_status], 0
seg001:1149                 mov     [bp+right_status], 0
seg001:114E                 mov     ax, 2
seg001:1151                 jmp     begin
seg001:1154 ; ---------------------------------------------------------------------------
seg001:1154
seg001:1154 set_loop:                               ; CODE XREF: process_Key+F6↓j
seg001:1154                 sub     ax, 4
seg001:1157                 neg     ax
seg001:1159                 mov     [bp+press_status], ax ; 1:�ͷ�,2:ѹ��
seg001:115C                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:115F                 xor     bx, bx
seg001:1161                 add     bx, [si+DDIM.offset]
seg001:1164                 mov     es, [si+DDIM.header.segment]
seg001:1167                 mov     cx, [es:bx]
seg001:116A                 shl     cx, 1
seg001:116C                 mov     bx, cx
seg001:116E                 mov     si, offset DDIM_keybuf
seg001:1171                 add     bx, [si+DDIM.offset]
seg001:1174                 mov     es, [si+DDIM.header.segment]
seg001:1177                 mov     cx, [es:bx]
seg001:117A                 cmp     cx, [bp+status_counter]
seg001:117D                 jnz     short next_key_up
seg001:117F                 mov     [bp+left_status], ax
seg001:1182
seg001:1182 next_key_up:                            ; CODE XREF: process_Key+67↑j
seg001:1182                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:1185                 mov     bx, 2
seg001:1188                 add     bx, [si+0Ah]
seg001:118B                 mov     es, [word ptr si+2]
seg001:118E                 mov     ax, [es:bx]
seg001:1191                 shl     ax, 1
seg001:1193                 mov     bx, ax
seg001:1195                 mov     si, offset DDIM_keybuf
seg001:1198                 add     bx, [si+0Ah]
seg001:119B                 mov     es, [word ptr si+2]
seg001:119E                 mov     ax, [es:bx]
seg001:11A1                 cmp     ax, [bp+status_counter]
seg001:11A4                 jnz     short next_key_right
seg001:11A6                 mov     ax, [bp+press_status] ; 1:�ͷ�,2:ѹ��
seg001:11A9                 mov     [bp+up_status], ax
seg001:11AC
seg001:11AC next_key_right:                         ; CODE XREF: process_Key+8E↑j
seg001:11AC                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:11AF                 mov     bx, 4
seg001:11B2                 add     bx, [si+0Ah]
seg001:11B5                 mov     es, [word ptr si+2]
seg001:11B8                 mov     ax, [es:bx]
seg001:11BB                 shl     ax, 1
seg001:11BD                 mov     bx, ax
seg001:11BF                 mov     si, offset DDIM_keybuf
seg001:11C2                 add     bx, [si+0Ah]
seg001:11C5                 mov     es, [word ptr si+2]
seg001:11C8                 mov     ax, [es:bx]
seg001:11CB                 cmp     ax, [bp+status_counter]
seg001:11CE                 jnz     short next_key_down
seg001:11D0                 mov     ax, [bp+press_status] ; 1:�ͷ�,2:ѹ��
seg001:11D3                 mov     [bp+right_status], ax
seg001:11D6
seg001:11D6 next_key_down:                          ; CODE XREF: process_Key+B8↑j
seg001:11D6                 mov     si, offset DDIM_buf_SETUP_DAT
seg001:11D9                 mov     bx, 6
seg001:11DC                 add     bx, [si+0Ah]
seg001:11DF                 mov     es, [word ptr si+2]
seg001:11E2                 mov     ax, [es:bx]
seg001:11E5                 shl     ax, 1
seg001:11E7                 mov     bx, ax
seg001:11E9                 mov     si, offset DDIM_keybuf
seg001:11EC                 add     bx, [si+0Ah]
seg001:11EF                 mov     es, [word ptr si+2]
seg001:11F2                 mov     ax, [es:bx]
seg001:11F5                 cmp     ax, [bp+status_counter]
seg001:11F8                 jnz     short next_huh
seg001:11FA                 mov     ax, [bp+press_status] ; 1:�ͷ�,2:ѹ��
seg001:11FD                 mov     [bp+down_status], ax
seg001:1200
seg001:1200 next_huh:                               ; CODE XREF: process_Key+E2↑j
seg001:1200                 mov     ax, [bp+status_counter]
seg001:1203                 inc     ax
seg001:1204
seg001:1204 begin:                                  ; CODE XREF: process_Key+3B↑j
seg001:1204                 mov     [bp+status_counter], ax
seg001:1207                 cmp     ax, 3
seg001:120A                 jg      short next
seg001:120C                 jmp     set_loop
seg001:120F ; ---------------------------------------------------------------------------
seg001:120F
seg001:120F next:                                   ; CODE XREF: process_Key+F4↑j
seg001:120F                 mov     ax, [bp+down_status]
seg001:1212                 add     ax, [bp+up_status]
seg001:1215                 or      ax, ax
seg001:1217                 jz      short key_updown_not_pressed_or_released
seg001:1219                 jmp     leftright_switch
seg001:121C ; ---------------------------------------------------------------------------
seg001:121C
seg001:121C key_updown_not_pressed_or_released:     ; CODE XREF: process_Key+101↑j
seg001:121C                 mov     [ds:flag_key_updown], 0
seg001:1222                 mov     ax, [bp+right_status]
seg001:1225                 cmp     ax, [bp+left_status]
seg001:1228                 jge     short right_big_than_left
seg001:122A                 mov     [ds:flag_key_leftright], 0FFFFh
seg001:1230
seg001:1230 right_big_than_left:                    ; CODE XREF: process_Key+112↑j
seg001:1230                 mov     ax, [bp+right_status]
seg001:1233                 cmp     ax, [bp+left_status]
seg001:1236                 jle     short leftright_switch
seg001:1238                 mov     [ds:flag_key_leftright], 1
seg001:123E
seg001:123E leftright_switch:                       ; CODE XREF: process_Key+103↑j
seg001:123E                                         ; process_Key+120↑j
seg001:123E                 mov     ax, [bp+right_status]
seg001:1241                 add     ax, [bp+left_status]
seg001:1244                 or      ax, ax
seg001:1246                 jz      short key_leftright_not_pressed_or_released
seg001:1248                 jmp     set_end
seg001:124B ; ---------------------------------------------------------------------------
seg001:124B
seg001:124B key_leftright_not_pressed_or_released:  ; CODE XREF: process_Key+130↑j
seg001:124B                 mov     [ds:flag_key_leftright], 0
seg001:1251                 mov     ax, [bp+down_status]
seg001:1254                 cmp     ax, [bp+up_status]
seg001:1257                 jge     short up_less_than_down
seg001:1259                 mov     [ds:flag_key_updown], 0FFFFh
seg001:125F
seg001:125F up_less_than_down:                      ; CODE XREF: process_Key+141↑j
seg001:125F                 mov     ax, [bp+down_status]
seg001:1262                 cmp     ax, [bp+up_status]
seg001:1265                 jle     short set_end
seg001:1267                 mov     [ds:flag_key_updown], 1
seg001:126D
seg001:126D set_end:                                ; CODE XREF: process_Key+132↑j
seg001:126D                                         ; process_Key+14F↑j
seg001:126D                 cmp     [bp+up_status], 2
seg001:1271                 jnz     short not_up
seg001:1273                 mov     [ds:flag_key_updown], 0FFFFh
seg001:1279                 mov     [ds:flag_key_leftright], 0
seg001:127F
seg001:127F not_up:                                 ; CODE XREF: process_Key+15B↑j
seg001:127F                 cmp     [bp+down_status], 2
seg001:1283                 jnz     short not_down
seg001:1285                 mov     [ds:flag_key_updown], 1
seg001:128B                 mov     [ds:flag_key_leftright], 0
seg001:1291
seg001:1291 not_down:                               ; CODE XREF: process_Key+16D↑j
seg001:1291                 cmp     [bp+left_status], 2
seg001:1295                 jnz     short not_left
seg001:1297                 mov     [ds:flag_key_leftright], 0FFFFh
seg001:129D                 mov     [ds:flag_key_updown], 0
seg001:12A3
seg001:12A3 not_left:                               ; CODE XREF: process_Key+17F↑j
seg001:12A3                 cmp     [bp+right_status], 2
seg001:12A7                 jnz     short not_down_
seg001:12A9                 mov     [ds:flag_key_leftright], 1
seg001:12AF                 mov     [ds:flag_key_updown], 0
seg001:12B5
seg001:12B5 not_down_:                              ; CODE XREF: process_Key+191↑j
seg001:12B5                 cmp     [bp+right_status], 0
seg001:12B9                 jnz     short loc_10D28
seg001:12BB                 cmp     [ds:flag_key_leftright], 1
seg001:12C0                 jnz     short loc_10D28
seg001:12C2                 mov     [ds:flag_key_leftright], 0
seg001:12C8
seg001:12C8 loc_10D28:                              ; CODE XREF: process_Key+1A3↑j
seg001:12C8                                         ; process_Key+1AA↑j
seg001:12C8                 cmp     [bp+left_status], 0
seg001:12CC                 jnz     short loc_10D3B
seg001:12CE                 cmp     [ds:flag_key_leftright], 0FFFFh
seg001:12D3                 jnz     short loc_10D3B
seg001:12D5                 mov     [ds:flag_key_leftright], 0
seg001:12DB
seg001:12DB loc_10D3B:                              ; CODE XREF: process_Key+1B6↑j
seg001:12DB                                         ; process_Key+1BD↑j
seg001:12DB                 cmp     [bp+down_status], 0
seg001:12DF                 jnz     short loc_10D4E
seg001:12E1                 cmp     [ds:flag_key_updown], 1
seg001:12E6                 jnz     short loc_10D4E
seg001:12E8                 mov     [ds:flag_key_updown], 0
seg001:12EE
seg001:12EE loc_10D4E:                              ; CODE XREF: process_Key+1C9↑j
seg001:12EE                                         ; process_Key+1D0↑j
seg001:12EE                 cmp     [bp+up_status], 0
seg001:12F2                 jnz     short loc_10D61
seg001:12F4                 cmp     [ds:flag_key_updown], 0FFFFh
seg001:12F9                 jnz     short loc_10D61
seg001:12FB                 mov     [ds:flag_key_updown], 0
seg001:1301
seg001:1301 loc_10D61:                              ; CODE XREF: process_Key+1DC↑j
seg001:1301                                         ; process_Key+1E3↑j
seg001:1301                 mov     ax, [ds:flag_key_leftright]
seg001:1304                 mov     si, [bp+a_leftright]
seg001:1307                 mov     [si], ax
seg001:1309                 mov     ax, [ds:flag_key_updown]
seg001:130C                 mov     si, [bp+a_updown]
seg001:130F                 mov     [si], ax
seg001:1311                 call    B$EXSA          ; clear frame state info
seg001:1316                 retf    4
seg001:1316 endp            process_Key

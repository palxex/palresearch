seg001:F684 ; =============== S U B R O U T I N E =======================================
seg001:F684
seg001:F684 ; Attributes: bp-based frame
seg001:F684
seg001:F684 proc            wait_key far            ; CODE XREF: real_entry+B34↑P
seg001:F684                                         ; process_Script+200↑P
seg001:F684                                         ; calc_display_EXP+C4↑P
seg001:F684                                         ; sub_118F4+3F4↑P
seg001:F684                                         ; process_scripts+1AAE↑P
seg001:F684                                         ; process_scripts+34E7↑P
seg001:F684                                         ; learnmagic_internal+271↑P
seg001:F684                                         ; output_levelup?+24F↑P
seg001:F684                                         ; begin_scene+5A1↑P
seg001:F684                                         ; type_uplevel+279↑P
seg001:F684
seg001:F684 var_1A          = word ptr -1Ah
seg001:F684 delay_time      = byte ptr -18h
seg001:F684 var_16          = word ptr -16h
seg001:F684 var_14          = word ptr -14h
seg001:F684 arg_2           = word ptr  6
seg001:F684
seg001:F684                 mov     cx, 8
seg001:F687                 mov     bx, 0
seg001:F68A                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:F68F                 mov     si, [bp+arg_2]
seg001:F692                 mov     ax, [si]
seg001:F694                 mov     [bp+var_14], ax
seg001:F697                 mov     ax, 1
seg001:F69A                 jmp     next
seg001:F69D ; ---------------------------------------------------------------------------
seg001:F69D                 nop
seg001:F69E
seg001:F69E wait_key_loop:                          ; CODE XREF: wait_key+58↓j
seg001:F69E                 lea     bx, [bp+var_16]
seg001:F6A1                 push    ds
seg001:F6A2                 pop     es
seg001:F6A3                 push    es
seg001:F6A4                 push    bx
seg001:F6A5                 mov     si, offset DDIM_keybuf
seg001:F6A8                 xor     bx, bx
seg001:F6AA                 add     bx, [si+0Ah]
seg001:F6AD                 mov     es, [word ptr si+2]
seg001:F6B0                 push    es
seg001:F6B1                 push    bx
seg001:F6B2                 call    Parse_key
seg001:F6B7                 mov     ax, [bp+var_16]
seg001:F6BA                 and     ax, ax
seg001:F6BC                 jz      short no_key
seg001:F6BE                 jmp     next__
seg001:F6C1 ; ---------------------------------------------------------------------------
seg001:F6C1
seg001:F6C1 no_key:                                 ; CODE XREF: wait_key+38↑j
seg001:F6C1                 mov     [word ptr bp+delay_time], 1
seg001:F6C6                 lea     bx, [bp+delay_time]
seg001:F6C9                 push    ds
seg001:F6CA                 pop     es
seg001:F6CB                 push    es              ; int
seg001:F6CC                 push    bx              ; delay_time
seg001:F6CD                 call    delay_centisecond
seg001:F6D2                 mov     ax, [bp+var_1A]
seg001:F6D5                 inc     ax
seg001:F6D6
seg001:F6D6 next:                                   ; CODE XREF: wait_key+16↑j
seg001:F6D6                 mov     [bp+var_1A], ax
seg001:F6D9                 cmp     ax, [bp+var_14]
seg001:F6DC                 jle     short wait_key_loop
seg001:F6DE
seg001:F6DE next__:                                 ; CODE XREF: wait_key+3A↑j
seg001:F6DE                 call    B$EXSA          ; clear frame state info
seg001:F6E3                 retf    2
seg001:F6E3 endp            wait_key

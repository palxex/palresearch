seg029:142A ; =============== S U B R O U T I N E =======================================
seg029:142A
seg029:142A ; Attributes: bp-based frame
seg029:142A
seg029:142A ; int __stdcall __far delay_centisecond(char delay_time, int)
seg029:142A proc            delay_centisecond far   ; CODE XREF: enemy_magical_attack+175↑P
seg029:142A                                         ; process_Battle+409↑P
seg029:142A                                         ; process_Battle+2EFE↑P
seg029:142A                                         ; summon_lasting?+1AF↑P
seg029:142A                                         ; calc_display_theurgy+9B2↑P
seg029:142A                                         ; summon_imgs?+A4↑P
seg029:142A                                         ; summon_imgs?+1BC↑P
seg029:142A                                         ; draw_battle_scene+2C3↑P
seg029:142A                                         ; morph?+1D↑P
seg029:142A                                         ; scanline_draw_normal_scene+122↑P
seg029:142A                                         ; process_scripts+42FC↑P
seg029:142A                                         ; process_scripts+4892↑P
seg029:142A                                         ; palette_filter_fading+A3↑P
seg029:142A                                         ; fade_out+7B↑P fade_in+7A↑P ...
seg029:142A
seg029:142A delay_time      = byte ptr  6
seg029:142A
seg029:142A                 push    bp
seg029:142B                 mov     bp, sp
seg029:142D                 push    ds
seg029:142E                 push    si
seg029:142F                 lds     si, [dword ptr bp+delay_time]
seg029:1432                 mov     cx, [si]
seg029:1434                 or      cx, cx
seg029:1436                 jle     short return
seg029:1438
seg029:1438 delay_loop:                             ; CODE XREF: delay_centisecond+13↓j
seg029:1438                 cmp     cx, [cs:time_interrupt_occers]
seg029:143D                 ja      short delay_loop
seg029:143F                 xor     ax, ax
seg029:1441                 mov     [cs:time_interrupt_occers], ax
seg029:1445
seg029:1445 return:                                 ; CODE XREF: delay_centisecond+C↑j
seg029:1445                 pop     si
seg029:1446                 pop     ds
seg029:1447                 pop     bp
seg029:1448                 retf    4
seg029:1448 endp            delay_centisecond
seg029:1448
seg029:144B
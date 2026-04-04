seg027:000A ; =============== S U B R O U T I N E =======================================
seg027:000A
seg027:000A
seg027:000A proc            replace_keyboard_interrupt far
seg027:000A                                         ; CODE XREF: real_entry+607↑P
seg027:000A                 push    ds
seg027:000B
seg027:000B loc_2D0AB:
seg027:000B                 push    es
seg027:000C
seg027:000C loc_2D0AC:
seg027:000C                 push    si
seg027:000D
seg027:000D loc_2D0AD:
seg027:000D                 push    di
seg027:000E
seg027:000E loc_2D0AE:
seg027:000E                 mov     cx, 80h
seg027:0011
seg027:0011 loc_2D0B1:
seg027:0011                 xor     ax, ax
seg027:0013
seg027:0013 loc_2D0B3:
seg027:0013                 push    cs
seg027:0014
seg027:0014 loc_2D0B4:
seg027:0014                 pop     es
seg027:0015                 assume es:seg027
seg027:0015
seg027:0015 loc_2D0B5:
seg027:0015                 mov     di, offset keyboard_buf
seg027:0018
seg027:0018 loc_2D0B8:
seg027:0018                 cld
seg027:0019
seg027:0019 loc_2D0B9:
seg027:0019                 rep stosw
seg027:001B
seg027:001B loc_2D0BB:
seg027:001B                 xor     ax, ax
seg027:001D
seg027:001D loc_2D0BD:
seg027:001D                 mov     es, ax
seg027:001F                 assume es:nothing
seg027:001F
seg027:001F loc_2D0BF:
seg027:001F                 mov     ds, ax
seg027:0021                 assume ds:nothing
seg027:0021
seg027:0021 loc_2D0C1:                              ; Bitfields for keyboard status flags 1:
seg027:0021                 mov     si, 417h        ; Bit(s)  Description     (Table M0010)
seg027:0021                                         ;  7      INSert active
seg027:0021                                         ;  6      Caps Lock active
seg027:0021                                         ;  5      Num Lock active
seg027:0021                                         ;  4      Scroll Lock active
seg027:0021                                         ;  3      either Alt pressed
seg027:0021                                         ;  2      either Ctrl pressed
seg027:0021                                         ;  1      Left Shift pressed
seg027:0021                                         ;  0      Right Shift pressed
seg027:0024
seg027:0024 loc_2D0C4:
seg027:0024                 lodsb
seg027:0025
seg027:0025 loc_2D0C5:
seg027:0025                 mov     [cs:save_kbd_flag_1], al
seg027:0029
seg027:0029 loc_2D0C9:
seg027:0029                 mov     si, 24h ; '$'
seg027:002C
seg027:002C loc_2D0CC:
seg027:002C                 mov     di, si
seg027:002E                 lodsw
seg027:002F
seg027:002F loc_2D0CF:
seg027:002F                 mov     [word ptr cs:save_int_handle_9_kbdint], ax
seg027:0033                 lodsw
seg027:0034
seg027:0034 loc_2D0D4:
seg027:0034                 mov     [word ptr cs:save_int_handle_9_kbdint+2], ax
seg027:0038
seg027:0038 loc_2D0D8:
seg027:0038                 mov     dx, cs
seg027:003A
seg027:003A loc_2D0DA:
seg027:003A                 mov     ax, offset keyboard_interrupt
seg027:003D                 cld
seg027:003E
seg027:003E loc_2D0DE:
seg027:003E                 cli
seg027:003F                 stosw
seg027:0040
seg027:0040 loc_2D0E0:
seg027:0040                 mov     ax, dx
seg027:0042
seg027:0042 loc_2D0E2:
seg027:0042                 stosw
seg027:0043                 sti
seg027:0044                 pop     di
seg027:0045                 pop     si
seg027:0046
seg027:0046 loc_2D0E6:
seg027:0046                 pop     es
seg027:0047                 assume es:nothing
seg027:0047                 pop     ds
seg027:0048                 assume ds:nothing
seg027:0048
seg027:0048 locret_2D0E8:
seg027:0048                 retf
seg027:0048 endp            replace_keyboard_interrupt
seg027:0048
seg027:0049

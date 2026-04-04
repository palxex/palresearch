seg029:144B ; =============== S U B R O U T I N E =======================================
seg029:144B
seg029:144B
seg029:144B proc            replace_timer_interrupt far
seg029:144B                                         ; CODE XREF: real_entry:next3↑P
seg029:144B                 push    ds
seg029:144C                 push    es
seg029:144D                 mov     al, 8
seg029:144F                 mov     ah, 35h
seg029:1451                 int     21h             ; DOS - 2+ - GET INTERRUPT VECTOR
seg029:1451                                         ; AL = interrupt number
seg029:1451                                         ; Return: ES:BX = value of interrupt vector
seg029:1453
seg029:1453 loc_2E883:
seg029:1453                 mov     [word ptr cs:save_timer_interrupt], bx
seg029:1458                 mov     ax, es
seg029:145A                 mov     [word ptr cs:save_timer_interrupt+2], ax
seg029:145E                 mov     ax, cs
seg029:1460                 mov     ds, ax
seg029:1462                 assume ds:seg029
seg029:1462                 mov     dx, offset timer_interrupt
seg029:1465                 mov     al, 8
seg029:1467                 mov     ah, 25h
seg029:1469                 int     21h             ; DOS - SET INTERRUPT VECTOR
seg029:1469                                         ; AL = interrupt number
seg029:1469                                         ; DS:DX = new vector to be used for specified interrupt
seg029:146B                 mov     dx, 40h ; '@'
seg029:146E                 cli
seg029:146F                 mov     bx, 11932       ; 设置时中断为百分秒
seg029:1472                 mov     al, 36h ; '6'
seg029:1474                 out     43h, al         ; Timer 8253-5 (AT: 8254.2).
seg029:1476                 mov     al, bl
seg029:1478                 out     dx, al          ; Timer 8253-5 (AT: 8254.2).
seg029:1479                 mov     al, bh
seg029:147B                 out     dx, al          ; Timer 8253-5 (AT: 8254.2).
seg029:147C                 sti
seg029:147D                 pop     es
seg029:147E                 pop     ds
seg029:147F                 assume ds:nothing
seg029:147F                 retf
seg029:147F endp            replace_timer_interrupt

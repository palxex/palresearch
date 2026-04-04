seg029:15A5 ; =============== S U B R O U T I N E =======================================
seg029:15A5
seg029:15A5 ; Attributes: bp-based frame
seg029:15A5
seg029:15A5 ; int __stdcall __far set_palette(__int32 palette_ptr)
seg029:15A5 proc            set_palette far         ; CODE XREF: real_entry+B06↑P
seg029:15A5                                         ; process_scripts+2914↑P
seg029:15A5                                         ; process_scripts+2999↑P
seg029:15A5                                         ; process_scripts+42C2↑P
seg029:15A5                                         ; process_scripts+4324↑P
seg029:15A5                                         ; process_scripts+47A0↑P
seg029:15A5                                         ; process_scripts+4886↑P
seg029:15A5                                         ; palette_filter_fading+92↑P
seg029:15A5                                         ; fade_out+6F↑P
seg029:15A5                                         ; fade_out+D3↑P fade_in+6E↑P
seg029:15A5                                         ; fade_in+9C↑P
seg029:15A5                                         ; FadeInOrOut_internal+8E↑P
seg029:15A5                                         ; RollPicture_Imp+1BF↑P
seg029:15A5                                         ; FadeInPic_imp+1F6↑P ...
seg029:15A5
seg029:15A5 palette_ptr     = dword ptr  6
seg029:15A5
seg029:15A5                 push    bp
seg029:15A6
seg029:15A6 loc_2E9D6:
seg029:15A6                 mov     bp, sp
seg029:15A8
seg029:15A8 loc_2E9D8:
seg029:15A8                 push    ds
seg029:15A9                 push    si
seg029:15AA
seg029:15AA loc_2E9DA:
seg029:15AA                 cld
seg029:15AB                 lds     si, [bp+palette_ptr]
seg029:15AE
seg029:15AE loc_2E9DE:
seg029:15AE                 mov     [word ptr cs:ptr_palette], si
seg029:15B3
seg029:15B3 loc_2E9E3:
seg029:15B3                 mov     [word ptr cs:ptr_palette+2], ds
seg029:15B8
seg029:15B8 loc_2E9E8:
seg029:15B8                 mov     cx, 300h
seg029:15BB
seg029:15BB loc_2E9EB:
seg029:15BB                 mov     [cs:mutux_setpalette], 1
seg029:15C1
seg029:15C1 loc_2E9F1:
seg029:15C1                 mov     dx, 3DAh
seg029:15C4
seg029:15C4 loc_2E9F4:                              ; CODE XREF: set_palette:loc_2E9F7↓j
seg029:15C4                 in      al, dx          ; Video status bits:
seg029:15C4                                         ; 0: retrace.  1=display is in vert or horiz retrace.
seg029:15C4                                         ; 1: 1=light pen is triggered; 0=armed
seg029:15C4                                         ; 2: 1=light pen switch is open; 0=closed
seg029:15C4                                         ; 3: 1=vertical sync pulse is occurring.
seg029:15C5
seg029:15C5 loc_2E9F5:
seg029:15C5                 and     al, 8
seg029:15C7
seg029:15C7 loc_2E9F7:
seg029:15C7                 jnz     short loc_2E9F4
seg029:15C9
seg029:15C9 too:                                    ; CODE XREF: set_palette:loc_2E9FC↓j
seg029:15C9                 in      al, dx          ; Video status bits:
seg029:15C9                                         ; 0: retrace.  1=display is in vert or horiz retrace.
seg029:15C9                                         ; 1: 1=light pen is triggered; 0=armed
seg029:15C9                                         ; 2: 1=light pen switch is open; 0=closed
seg029:15C9                                         ; 3: 1=vertical sync pulse is occurring.
seg029:15CA
seg029:15CA loc_2E9FA:
seg029:15CA                 and     al, 8
seg029:15CC
seg029:15CC loc_2E9FC:
seg029:15CC                 jz      short too
seg029:15CE                 xor     ax, ax
seg029:15D0                 mov     dx, 3C8h        ; 03C8  RW  (VGA,MCGA) PEL address register (write mode)
seg029:15D0                                         ;                  Sets DAC in write mode and assign start of color register
seg029:15D0                                         ;                  index (0..255) for following write accesses to 3C9h.
seg029:15D0                                         ;                  Don't read from 3C9h while in write mode. Next access to
seg029:15D0                                         ;                  03C8h will stop pending mode immediatly.
seg029:15D3                 out     dx, al
seg029:15D4                 inc     dx              ; 03C9  RW  (VGA,MCGA) PEL data register
seg029:15D4                                         ;                  Three consequtive reads (in read mode) or writes (in write
seg029:15D4                                         ;                  mode) in the order: red, green, blue. The internal DAC index
seg029:15D4                                         ;                  is incremented each 3rd access.
seg029:15D4                                         ;                   bit7-6: HiColor VGA DACs only: color-value bit7-6
seg029:15D4                                         ;                   bit5-0:                        color-value bit5-0
seg029:15D5
seg029:15D5 fill_palette_loop:                      ; CODE XREF: set_palette+32↓j
seg029:15D5                 lodsb
seg029:15D6                 out     dx, al
seg029:15D7                 loop    fill_palette_loop
seg029:15D9                 mov     [cs:mutux_setpalette], 0
seg029:15DF                 pop     si
seg029:15E0
seg029:15E0 loc_2EA10:
seg029:15E0                 pop     ds
seg029:15E1                 pop     bp
seg029:15E2
seg029:15E2 locret_2EA12:
seg029:15E2                 retf    4
seg029:15E2 endp            set_palette
seg029:15E2
seg029:15E2 ends            seg029

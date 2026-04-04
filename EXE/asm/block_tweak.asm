seg008:0002 ; =============== S U B R O U T I N E =======================================
seg008:0002
seg008:0002 ; Attributes: bp-based frame
seg008:0002
seg008:0002 ; int __stdcall __far block_tweak(__int32 multiplier, __int32 bytes, __int32 src, char dst, int)
seg008:0002 proc            block_tweak far         ; CODE XREF: fade_out+5C↑P
seg008:0002                                         ; fade_out+C0↑P fade_in+5B↑P
seg008:0002                                         ; FadeInOrOut_internal+7B↑P
seg008:0002                                         ; RollPicture_Imp+1AC↑P
seg008:0002                                         ; FadeInPic_imp+1E3↑P
seg008:0002                                         ; Final_Stage_imp+297↑P
seg008:0002                                         ; begin_scene+15D↑P
seg008:0002                                         ; begin_scene+476↑P
seg008:0002                                         ; begin_scene+563↑P
seg008:0002
seg008:0002 multiplier      = dword ptr  6
seg008:0002 bytes           = dword ptr  0Ah
seg008:0002 src             = dword ptr  0Eh
seg008:0002 dst             = byte ptr  12h
seg008:0002
seg008:0002                 push    bp
seg008:0003
seg008:0003 loc_281D3:
seg008:0003                 mov     bp, sp
seg008:0005                 push    ds
seg008:0006
seg008:0006 loc_281D6:
seg008:0006                 push    es
seg008:0007
seg008:0007 loc_281D7:
seg008:0007                 push    si
seg008:0008
seg008:0008 loc_281D8:
seg008:0008                 push    di
seg008:0009                 cld
seg008:000A
seg008:000A loc_281DA:
seg008:000A                 lds     si, [bp+multiplier]
seg008:000D
seg008:000D loc_281DD:
seg008:000D                 mov     bx, [si]
seg008:000F
seg008:000F loc_281DF:
seg008:000F                 lds     si, [bp+bytes]
seg008:0012
seg008:0012 loc_281E2:
seg008:0012                 mov     cx, [si]
seg008:0014
seg008:0014 loc_281E4:
seg008:0014                 lds     si, [bp+src]
seg008:0017
seg008:0017 loc_281E7:
seg008:0017                 les     di, [dword ptr bp+dst]
seg008:001A
seg008:001A loop:                                   ; CODE XREF: block_tweak+21↓j
seg008:001A                 xor     ah, ah
seg008:001C
seg008:001C loc_281EC:
seg008:001C                 lodsb
seg008:001D
seg008:001D loc_281ED:
seg008:001D                 mul     bx
seg008:001F
seg008:001F loc_281EF:
seg008:001F                 shr     ax, 6
seg008:0022
seg008:0022 loc_281F2:                              ; dst=src*multiplier>>6
seg008:0022                 stosb
seg008:0023                 loop    loop
seg008:0025
seg008:0025 loc_281F5:
seg008:0025                 pop     di
seg008:0026                 pop     si
seg008:0027
seg008:0027 loc_281F7:
seg008:0027                 pop     es
seg008:0028
seg008:0028 loc_281F8:
seg008:0028                 pop     ds
seg008:0029                 mov     sp, bp
seg008:002B                 pop     bp
seg008:002C
seg008:002C locret_281FC:
seg008:002C                 retf    10h
seg008:002C endp            block_tweak
seg008:002C

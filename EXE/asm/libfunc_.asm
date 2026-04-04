seg002:
0687 ; =============== S U B R O U T I N E =======================================
0687
0687 ; Attributes: bp-based frame
0687
0687 proc libfunc_? far ; CODE XREF: real_entry+A38↑P
0687 ; real_entry+A4D↑P
0687
0687 dst_len = word ptr 6
0687 dst_seg = word ptr 0Ah
0687
0687 mov bl, 2
0689
0689 loc_1F9B9:
0689 cmp ax, 14B3h
068C cmp ax, 3B3h
068F push bp
0690 mov bp, sp
0692 push si
0693 push di
0694 mov [ds:save_bp_], bp
0698 mov [byte ptr ds:Save_ax_by_B$PRINT], bl
069C push bx
069D push ds
069E pop es
069F
069F loc_1F9CF: ; B$ReadVal
069F call [ds:ptr_B$ReadVal]
06A3 pop cx
06A4 shr cl, 1
06A6
06A6 loc_1F9D6:
06A6 jb short loc_1F9E6
06A8
06A8 loc_1F9D8:
06A8 les di, [dword ptr bp+dst_len]
06AB
06AB loc_1F9DB:
06AB and cx, 7
06AE
06AE loc_1F9DE:
06AE rep movsw
06B0
06B0 loc_1F9E0:
06B0 pop di
06B1 pop si
06B2 pop bp
06B3 retf 4
06B6 ; ---------------------------------------------------------------------------
06B6
06B6 loc_1F9E6: ; CODE XREF: libfunc_?:loc_1F9D6↑j
06B6 xor ax, ax
06B8
06B8 loc_1F9E8: ; src_seg
06B8 push ds
06B9 push [word ptr si] ; src_off
06BB push ax ; src_len
06BC
06BC loc_1F9EC: ; dst_seg
06BC push [bp+dst_seg]
06BF push [word ptr bp+8] ; dst_off
06C2 push [bp+dst_len] ; dst_len
06C5
06C5 loc_1F9F5:
06C5 call STRINGASSIGN
06CA pop di
06CB pop si
06CC pop bp
06CD retf 6
06CD endp libfunc_?
06CD
06D0 ; [00000037 BYTES: COLLAPSED FUNCTION B$ReadVal]
0707 ; [00000020 BYTES: COLLAPSED FUNCTION sub_1FA37]
0727 ; [0000000A BYTES: COLLAPSED FUNCTION sub_1FA57]
0731 db 0, 57h, 7, 8Eh, 35h, 5Bh, 35h, 5Bh, 35h, 8Eh, 35h, 0AFh
073D db 35h, 0AFh, 35h, 5Bh, 35h, 5Bh, 35h, 5Bh, 35h, 8Eh, 35h
0748 ; [000000B0 BYTES: COLLAPSED FUNCTION sub_1FA78]
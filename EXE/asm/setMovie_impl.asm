seg001:B115 ; =============== S U B R O U T I N E =======================================
seg001:B115
seg001:B115 ; Attributes: bp-based frame
seg001:B115
seg001:B115 proc            setMovie_impl far       ; CODE XREF: real_entry+AD4↑P
seg001:B115                                         ; process_scripts+1AF7↑P
seg001:B115
seg001:B115 var_18          = word ptr -18h
seg001:B115 var_16          = word ptr -16h
seg001:B115 var_14          = word ptr -14h
seg001:B115 arg_2           = word ptr  6
seg001:B115
seg001:B115                 mov     cx, 6
seg001:B118                 mov     bx, 0
seg001:B11B                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:B120                 mov     [bp+var_14], 2
seg001:B125                 lea     bx, [bp+var_14]
seg001:B128                 push    ds
seg001:B129                 pop     es
seg001:B12A                 push    es
seg001:B12B                 push    bx
seg001:B12C                 mov     bx, offset theurgy_effect
seg001:B12F                 push    ds
seg001:B130                 pop     es
seg001:B131                 push    es
seg001:B132                 push    bx
seg001:B133                 call    sfx_func?
seg001:B138                 mov     [ds:flag_??], 0FFFFh
seg001:B13E                 push    offset rng_mkf_fp
seg001:B141                 push    [bp+arg_2]
seg001:B144                 call    get_subfile_len
seg001:B149                 mov     [bp+var_18], ax
seg001:B14C                 mov     [bp+var_16], dx
seg001:B14F                 mov     ax, [bp+var_18]
seg001:B152                 mov     dx, [bp+var_16]
seg001:B155                 mov     [word ptr ds:length], ax
seg001:B158                 mov     [word ptr ds:length+2], dx
seg001:B15C                 push    offset rng_mkf_fp ; dst_handle
seg001:B15F                 push    offset save_xms_handle_leaving ; int
seg001:B162                 push    [bp+arg_2]      ; int
seg001:B165                 push    offset bytes_leavingxms ; int
seg001:B168                 call    get_movie_to_xms
seg001:B16D                 mov     si, offset DDIM_buf_index
seg001:B170                 xor     bx, bx
seg001:B172                 add     bx, [si+0Ah]
seg001:B175                 mov     es, [word ptr si+2]
seg001:B178                 mov     ax, [es:bx]
seg001:B17B                 mov     dx, [es:bx+2]
seg001:B17F                 mov     [word ptr ds:first_index], ax
seg001:B182                 mov     [word ptr ds:first_index+2], dx
seg001:B186                 push    [word ptr ds:length+2] ; op1_h
seg001:B18A                 push    [word ptr ds:length] ; op1_l
seg001:B18E                 push    [word ptr ds:curr_subfile_offset+2] ; op2_h
seg001:B192                 push    [word ptr ds:curr_subfile_offset] ; op2_l
seg001:B196                 call    B$CPI4          ; long integer compare
seg001:B19B                 jle     short enough
seg001:B19D                 mov     ax, [word ptr ds:length]
seg001:B1A0                 mov     dx, [word ptr ds:length+2]
seg001:B1A4                 mov     [word ptr ds:curr_subfile_offset], ax
seg001:B1A7                 mov     [word ptr ds:curr_subfile_offset+2], dx
seg001:B1AB
seg001:B1AB enough:                                 ; CODE XREF: setMovie_impl+86↑j
seg001:B1AB                 push    [word ptr ds:curr_subfile_offset+2] ; op1_h
seg001:B1AF                 push    [word ptr ds:curr_subfile_offset] ; op1_l
seg001:B1B3                 push    [word ptr ds:bytes_leavingxms+2] ; op2_h
seg001:B1B7                 push    [word ptr ds:bytes_leavingxms] ; op2_l
seg001:B1BB                 call    B$CPI4          ; long integer compare
seg001:B1C0                 jle     short enough_too
seg001:B1C2                 mov     ax, [word ptr ds:bytes_leavingxms]
seg001:B1C5                 mov     dx, [word ptr ds:bytes_leavingxms+2]
seg001:B1C9                 mov     [word ptr ds:curr_subfile_offset], ax
seg001:B1CC                 mov     [word ptr ds:curr_subfile_offset+2], dx
seg001:B1D0
seg001:B1D0 enough_too:                             ; CODE XREF: setMovie_impl+AB↑j
seg001:B1D0                 call    B$EXSA          ; clear frame state info
seg001:B1D5                 retf    2
seg001:B1D5 endp            setMovie_impl

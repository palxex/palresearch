seg001:E601 ; =============== S U B R O U T I N E =======================================
seg001:E601
seg001:E601 ; Attributes: bp-based frame
seg001:E601
seg001:E601 proc            playRNG_impl far        ; CODE XREF: real_entry+B26↑P
seg001:E601                                         ; process_scripts+1B27↑P
seg001:E601
seg001:E601 var_34          = dword ptr -34h
seg001:E601 var_30          = dword ptr -30h
seg001:E601 var_2C          = word ptr -2Ch
seg001:E601 offset          = dword ptr -2Ah
seg001:E601 var_26          = word ptr -26h
seg001:E601 src_offset      = dword ptr -24h
seg001:E601 length          = dword ptr -20h
seg001:E601 var_1C          = word ptr -1Ch
seg001:E601 var_1A          = dword ptr -1Ah
seg001:E601 src             = byte ptr -16h
seg001:E601 delay_time      = byte ptr -14h
seg001:E601 arg_2           = word ptr  6
seg001:E601 arg_4           = word ptr  8
seg001:E601 arg_6           = word ptr  0Ah
seg001:E601
seg001:E601                 mov     cx, 22h ; '"'
seg001:E604                 mov     bx, 0
seg001:E607                 call    far ptr B$ENRA  ; setup stack & other state info.
seg001:E60C                 fld     [ds:fp32_100]   ; (emulator call)
seg001:E611                 mov     si, [bp+arg_2]
seg001:E614                 fidiv   [word ptr si]   ; (emulator call)
seg001:E617                 fistp   [word ptr bp+delay_time] ; (emulator call)
seg001:E61B                 wait                    ; (emulator call)
seg001:E61D                 mov     si, offset DDIM_screen_buf ; ...空的？
seg001:E620                 xor     bx, bx
seg001:E622                 add     bx, [si+0Ah]
seg001:E625                 mov     es, [word ptr si+2]
seg001:E628                 mov     ax, es
seg001:E62A                 mov     [word ptr bp+src], ax
seg001:E62D                 mov     [word ptr bp+var_1A], 64000
seg001:E632                 mov     [word ptr bp+var_1A+2], 0
seg001:E637                 lea     bx, [bp+src]
seg001:E63A                 push    ds
seg001:E63B                 pop     es
seg001:E63C                 push    es              ; int
seg001:E63D                 push    bx              ; src
seg001:E63E                 lea     bx, [bp+var_1A]
seg001:E641                 push    ds
seg001:E642                 pop     es
seg001:E643                 push    es
seg001:E644                 push    bx              ; length
seg001:E645                 mov     bx, offset XMS_handle_bak
seg001:E648                 push    ds
seg001:E649                 pop     es
seg001:E64A                 push    es
seg001:E64B                 push    bx              ; dst_handle
seg001:E64C                 call    XMS_CopyBlockToXMS
seg001:E651                 mov     si, [bp+arg_4]
seg001:E654                 mov     ax, [si]
seg001:E656                 mov     [bp+var_1C], ax
seg001:E659                 mov     si, [bp+arg_6]
seg001:E65C                 mov     ax, [si]
seg001:E65E                 jmp     until
seg001:E661 ; ---------------------------------------------------------------------------
seg001:E661                 nop
seg001:E662
seg001:E662 play_rng_loop:                          ; CODE XREF: playRNG_impl+1E0↓j
seg001:E662                 mov     [word ptr bp+length], 8
seg001:E667                 mov     [word ptr bp+length+2], 0
seg001:E66C                 mov     ax, [bp+var_26]
seg001:E66F                 shl     ax, 1
seg001:E671                 shl     ax, 1
seg001:E673                 cwd
seg001:E674                 mov     [word ptr bp+src_offset], ax
seg001:E677                 mov     [word ptr bp+src_offset+2], dx
seg001:E67A                 mov     si, offset DDIM_buf_index
seg001:E67D                 xor     bx, bx
seg001:E67F                 add     bx, [si+0Ah]
seg001:E682                 mov     es, [word ptr si+2]
seg001:E685                 push    es              ; int
seg001:E686                 push    bx              ; position for data
seg001:E687                 lea     bx, [bp+length]
seg001:E68A                 push    ds
seg001:E68B                 pop     es
seg001:E68C                 push    es
seg001:E68D                 push    bx              ; data length
seg001:E68E                 mov     bx, offset save_xms_handle_leaving
seg001:E691                 push    ds
seg001:E692                 pop     es
seg001:E693                 push    es
seg001:E694                 push    bx              ; XMS handle
seg001:E695                 lea     bx, [bp+src_offset]
seg001:E698                 push    ds
seg001:E699                 pop     es
seg001:E69A                 push    es
seg001:E69B                 push    bx              ; XMS offset
seg001:E69C                 call    XMS_CopyBlockFromXMS_toAddr
seg001:E6A1                 mov     si, offset DDIM_buf_index
seg001:E6A4                 mov     bx, 4
seg001:E6A7                 add     bx, [si+0Ah]
seg001:E6AA                 mov     es, [word ptr si+2]
seg001:E6AD                 mov     ax, [es:bx]
seg001:E6B0                 mov     dx, [es:bx+2]
seg001:E6B4                 xor     bx, bx
seg001:E6B6                 add     bx, [si+0Ah]
seg001:E6B9                 mov     es, [word ptr si+2]
seg001:E6BC                 sub     ax, [es:bx]
seg001:E6BF                 sbb     dx, [es:bx+2]   ; get the offset of the curr frame
seg001:E6C3                 mov     [word ptr ds:length], ax
seg001:E6C6                 mov     [word ptr ds:length+2], dx
seg001:E6CA                 push    dx              ; op1_h
seg001:E6CB                 push    ax              ; op1_l
seg001:E6CC                 push    0               ; op2_h
seg001:E6CE                 push    0               ; op2_l
seg001:E6D0                 call    B$CPI4          ; long integer compare
seg001:E6D5                 jg      short length_not_0
seg001:E6D7                 jmp     stopplay?
seg001:E6DA ; ---------------------------------------------------------------------------
seg001:E6DA
seg001:E6DA length_not_0:                           ; CODE XREF: playRNG_impl+D4↑j
seg001:E6DA                 mov     bx, 4
seg001:E6DD                 add     bx, [si+0Ah]
seg001:E6E0                 mov     es, [word ptr si+2]
seg001:E6E3                 push    [word ptr es:bx+2] ; op1_h
seg001:E6E7                 push    [word ptr es:bx] ; op1_l
seg001:E6EA                 push    [word ptr ds:bytes_leavingxms+2] ; op2_h
seg001:E6EE                 push    [word ptr ds:bytes_leavingxms] ; op2_l
seg001:E6F2                 call    B$CPI4          ; long integer compare
seg001:E6F7                 jle     short xms_enough
seg001:E6F9                 jmp     xms_not_enough
seg001:E6FC ; ---------------------------------------------------------------------------
seg001:E6FC
seg001:E6FC xms_enough:                             ; CODE XREF: playRNG_impl+F6↑j
seg001:E6FC                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:E6FF                 xor     bx, bx
seg001:E701                 add     bx, [si+0Ah]
seg001:E704                 mov     es, [word ptr si+2]
seg001:E707                 push    es              ; int
seg001:E708                 push    bx              ; dst_offset
seg001:E709                 mov     bx, offset length
seg001:E70C                 push    ds
seg001:E70D                 pop     es
seg001:E70E                 push    es
seg001:E70F                 push    bx              ; length
seg001:E710                 mov     bx, offset save_xms_handle_leaving
seg001:E713                 push    ds
seg001:E714                 pop     es
seg001:E715                 push    es
seg001:E716                 push    bx              ; src_handle
seg001:E717                 mov     si, offset DDIM_buf_index
seg001:E71A                 xor     bx, bx
seg001:E71C                 add     bx, [si+0Ah]
seg001:E71F                 mov     es, [word ptr si+2]
seg001:E722                 push    es
seg001:E723                 push    bx              ; src_offset
seg001:E724                 call    XMS_CopyBlockFromXMS_toAddr
seg001:E729                 jmp     play_next
seg001:E72C ; ---------------------------------------------------------------------------
seg001:E72C
seg001:E72C xms_not_enough:                         ; CODE XREF: playRNG_impl+F8↑j
seg001:E72C                 mov     si, offset DDIM_buf_index ; 只好直接从磁盘读取
seg001:E72F                 xor     bx, bx
seg001:E731                 add     bx, [si+0Ah]
seg001:E734                 mov     es, [word ptr si+2]
seg001:E737                 mov     ax, [es:bx]
seg001:E73A                 mov     dx, [es:bx+2]
seg001:E73E                 add     ax, [word ptr ds:first_index]
seg001:E742                 adc     dx, [word ptr ds:first_index+2]
seg001:E746                 mov     [word ptr bp+offset], ax
seg001:E749                 mov     [word ptr bp+offset+2], dx
seg001:E74C                 mov     bx, offset rng_mkf_fp
seg001:E74F                 push    ds
seg001:E750                 pop     es
seg001:E751                 push    es              ; int
seg001:E752                 push    bx              ; file_handle
seg001:E753                 lea     bx, [bp+offset]
seg001:E756                 push    ds
seg001:E757                 pop     es
seg001:E758                 push    es
seg001:E759                 push    bx              ; offset
seg001:E75A                 call    DOS_SeekFile_Absolute
seg001:E75F                 mov     bx, offset rng_mkf_fp
seg001:E762                 push    ds
seg001:E763                 pop     es
seg001:E764                 push    es              ; int
seg001:E765                 push    bx              ; file_handle
seg001:E766                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:E769                 xor     bx, bx
seg001:E76B                 add     bx, [si+0Ah]
seg001:E76E                 mov     es, [word ptr si+2]
seg001:E771                 push    es
seg001:E772                 push    bx              ; buffer
seg001:E773                 mov     bx, offset length
seg001:E776                 push    ds
seg001:E777                 pop     es
seg001:E778                 push    es
seg001:E779                 push    bx              ; bytes
seg001:E77A                 call    DOS_ReadFile_toBuf
seg001:E77F
seg001:E77F play_next:                              ; CODE XREF: playRNG_impl+128↑j
seg001:E77F                 mov     si, offset DDIM_buf_glb_1_redraw
seg001:E782                 xor     bx, bx
seg001:E784                 add     bx, [si+0Ah]
seg001:E787                 mov     es, [word ptr si+2]
seg001:E78A                 push    es              ; int
seg001:E78B                 push    bx              ; src_ptr
seg001:E78C                 mov     si, offset DDIM_screen_buf
seg001:E78F                 xor     bx, bx
seg001:E791                 add     bx, [si+0Ah]
seg001:E794                 mov     es, [word ptr si+2]
seg001:E797                 push    es
seg001:E798                 push    bx              ; dest_ptr
seg001:E799                 call    DeYJ_1
seg001:E79E                 mov     si, offset DDIM_screen_buf
seg001:E7A1                 xor     bx, bx
seg001:E7A3                 add     bx, [si+0Ah]
seg001:E7A6                 mov     es, [word ptr si+2]
seg001:E7A9                 push    es
seg001:E7AA                 push    bx
seg001:E7AB                 call    parse_RNG_data_draw
seg001:E7B0                 lea     bx, [bp+delay_time]
seg001:E7B3                 push    ds
seg001:E7B4                 pop     es
seg001:E7B5                 push    es              ; int
seg001:E7B6                 push    bx              ; delay_time
seg001:E7B7                 call    delay_centisecond
seg001:E7BC                 mov     [bp+var_2C], 1
seg001:E7C1                 lea     ax, [bp+var_2C]
seg001:E7C4                 push    ax
seg001:E7C5                 call    fade_in
seg001:E7CA                 call    ShakeScreen
seg001:E7CF                 jmp     continue
seg001:E7D2 ; ---------------------------------------------------------------------------
seg001:E7D2
seg001:E7D2 stopplay?:                              ; CODE XREF: playRNG_impl+D6↑j
seg001:E7D2                 jmp     finish
seg001:E7D5 ; ---------------------------------------------------------------------------
seg001:E7D5
seg001:E7D5 continue:                               ; CODE XREF: playRNG_impl+1CE↑j
seg001:E7D5                 mov     ax, [bp+var_26]
seg001:E7D8                 inc     ax
seg001:E7D9
seg001:E7D9 until:                                  ; CODE XREF: playRNG_impl+5D↑j
seg001:E7D9                 mov     [bp+var_26], ax
seg001:E7DC                 cmp     ax, [bp+var_1C]
seg001:E7DF                 jg      short finish
seg001:E7E1                 jmp     play_rng_loop
seg001:E7E4 ; ---------------------------------------------------------------------------
seg001:E7E4
seg001:E7E4 finish:                                 ; CODE XREF: playRNG_impl:stopplay?↑j
seg001:E7E4                                         ; playRNG_impl+1DE↑j
seg001:E7E4                 mov     [word ptr bp+var_30], 0FA00h
seg001:E7E9                 mov     [word ptr bp+var_30+2], 0
seg001:E7EE                 mov     [word ptr bp+var_34], 0
seg001:E7F3                 mov     [word ptr bp+var_34+2], 0
seg001:E7F8                 mov     si, offset DDIM_screen_buf
seg001:E7FB                 xor     bx, bx
seg001:E7FD                 add     bx, [si+0Ah]
seg001:E800                 mov     es, [word ptr si+2]
seg001:E803                 push    es              ; int
seg001:E804                 push    bx              ; dst_offset
seg001:E805                 lea     bx, [bp+var_30]
seg001:E808                 push    ds
seg001:E809                 pop     es
seg001:E80A                 push    es
seg001:E80B                 push    bx              ; length
seg001:E80C                 mov     bx, offset XMS_handle_bak
seg001:E80F                 push    ds
seg001:E810                 pop     es
seg001:E811                 push    es
seg001:E812                 push    bx              ; src_handle
seg001:E813                 lea     bx, [bp+var_34]
seg001:E816                 push    ds
seg001:E817                 pop     es
seg001:E818                 push    es
seg001:E819                 push    bx              ; src_offset
seg001:E81A                 call    XMS_CopyBlockFromXMS_toAddr
seg001:E81F                 call    B$EXSA          ; clear frame state info
seg001:E824                 retf    6
seg001:E824 endp            playRNG_impl

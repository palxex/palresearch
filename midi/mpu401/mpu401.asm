; ===================================================================
; mpu401.drv — SoftStar MMS-Midi Driver
; PAL (Chinese Paladin) DOS version MPU-401 MIDI driver (original author Pei-Cheng Tong)
;
; Notes:
;   * SONG_BUFFER is the song-data buffer base; all references go through this equate.
;     To move the buffer or grow the code, change it first and adjust the layout.
;   * MPU_PORT is the MPU-401 status port (data port = MPU_PORT-1).
; ===================================================================
BITS 16
CPU 386

SONG_BUFFER  equ 0x0A80   ; Song-data buffer base (code region 0x180..0x0A80 is free to use)
MPU_PORT     equ 0x0331      ; MPU-401 status port

; Replacement routines (packed tightly right after the main code; located via handlers-table labels)
; PB re-send MSB / SysEx strip SMF length / CC#121 / CC64 normalize routines
; none takes a fixed address; NASM lays them out via handlers-table labels

; ---------------- 0x000-0x031: signature ----------------
sig:        db "SoftStar MMS-Midi Driver Writen By Pei-Cheng Tong", 0x1A

; ---------------- 0x032-0x03D: API entry ----------------
            jmp near L180        ; AX=service number -> main dispatch
            jmp near L18C        ; player 0 tick
            jmp near L191        ; player 1 tick
            jmp near L196        ; player 2 tick

; ---------------- 0x03E-0x04D: message dispatch table ----------------
; index = (status>>4)-8: 8..F -> NoteOff,NoteOn,PolyAT,CC,Prog,ChanAT,Pitch,Sys
handlers:   dw L42D, L43C, L44B, cc_fix, L466, L46E, pb_fix, sx_fix

; ---------------- 0x04E-0x155: player structures x3 ----------------
; each 0x58 bytes; fields in struct_layout.csv
; (0x4E) player0 | (0xA6) player1 | (0xFE) player2
struct_004E:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x004E  <-- struct base
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x005E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x006E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x007E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x008E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x009E

struct_00A6:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00A6  <-- struct base
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00B6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00C6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x00D6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00E6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00F6

struct_00FE:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00FE  <-- struct base
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x010E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x011E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x012E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x013E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x014E

; ---------------- 0x156-0x16F: service / player dispatch table ----------------
; [0x156]=player0 base [0x158]=player1 [0x15A]=player2; [0x15C]+ = service handlers
svc_table:  dw 0x004E, 0x00A6, 0x00FE
            dw L5F8, L63D, L762, L7C1, L7ED, L821, L869, L8A7, L8C7, L8D5

; ---------------- 0x170-0x17F: port / Mapper / strings ----------------
mpu_port:   dw MPU_PORT               ; 0x170 MPU-401 status port
mapper_ptr: dd 0                      ; 0x172 MIDI Mapper entry (filled at runtime)
            db "EMMXXXX0", 0, 0        ; 0x176

; ---------------- 0x180-0x0A80: code ----------------
; labels = L + offset; all SONG_BUFFER references use the equate

L180:    xchg ax,bx
         shl bx,1
         mov bx,cs:[bx+0x15c]
         xchg ax,bx
         call ax
         retf
L18C:    mov bx,0x4e
         jmp short L19B
L191:    mov bx,0xa6
         jmp short L19B
L196:    mov bx,0xfe
         jmp short L19B
L19B:    cmp word cs:[bx+0x8],0x0
         jg L1A3
         retf
L1A3:    pushad
         mov di,cs:[bx+0x1e]
         mov ax,cs:[bx+0x20]
         mov cx,cs:[bx+0x22]
         mov dx,cs:[bx+0x24]
         add di,0x64
         cmp di,0x3e8
         jc L1D3
         sub di,0x3e8
         inc ax
         cmp ax,0x3e8
         jnz L1D3
         xor ax,ax
         inc cx
         cmp cx,0x3c
         jnz L1D3
         xor cx,cx
         inc dx
L1D3:    mov cs:[bx+0x1e],di
         mov cs:[bx+0x20],ax
         mov cs:[bx+0x22],cx
         mov cs:[bx+0x24],dx
         cmp byte cs:[bx+0x36],0x0
         jz L22B
         mov dx,cs:[bx+0x3b]
         cmp dx,cs:[bx+0x39]
         jnz L227
         mov al,cs:[bx+0x36]
         add cs:[bx+0x3d],al
         mov al,cs:[bx+0x3d]
         or al,al
         jnz L214
         mov byte cs:[bx+0x36],0x0
         mov word cs:[bx+0x8],0x0
         call L5BC
         jmp short L21F
L214:    cmp al,cs:[bx+0x3e]
         jnz L21F
         mov byte cs:[bx+0x36],0x0
L21F:    mov word cs:[bx+0x3b],0x0
         jmp short L22B
L227:    inc word cs:[bx+0x3b]
L22B: xor eax,eax
         mov ax,0x2710
         add ax,cs:[bx+0x18]
         sub cs:[bx+0x1a],eax
         jg L23F
         call L2BE
L23F:    popad
         retf
L242:    push bx
         push cx
         push dx
         push si
         push di
         push ds
         push es
         lds si,word cs:[bx]
         mov al,cs:[bx+0x41]
         cmp al,0x0
         jna L25C
         call L94B
         push cs
         pop es
         call L985
L25C:    mov word cs:[bx+0xc],ds
         mov word cs:[bx+0x10],ds
         add si,0xc
         cld
         lodsw
         xchg ah,al
         mov cs:[bx+0x14],ax
         push ax
         add si,0x9
         mov cs:[bx+0xe],si
         mov cs:[bx+0x12],si
         pop cx
         mov dx,0x7
         mov ax,0xa120
         or cx,cx
         jnz L28C
         xor ax,ax
         xor dx,dx
         jmp short L28E
L28C:    div cx
L28E:    mov cs:[bx+0x16],ax
         mov word cs:[bx+0x1a],0x0
         mov word cs:[bx+0x1c],0x0
         mov word cs:[bx+0x1e],0x0
         mov word cs:[bx+0x20],0x0
         mov word cs:[bx+0x22],0x0
         mov word cs:[bx+0x24],0x0
         pop es
         pop ds
         pop di
         pop si
         pop dx
         pop cx
         pop bx
         ret
L2BE:    push ds
         push si
         cld
         mov ds,word cs:[bx+0xc]
         mov si,cs:[bx+0xe]
         mov al,cs:[bx+0x41]
         cmp al,0x0
         jna L2D4
         call L985
L2D4:    cld
         xor ax,ax
         lodsb
         cmp al,0xf0
         jnc L2EB
         cmp al,0x80
         jnc L2E7
         dec si
         mov ax,cs:[bx+0x3f]
         jmp short L2EB
L2E7:    mov cs:[bx+0x3f],ax
L2EB:    cmp al,0xff
         jnz L38E
         lodsb
         cmp al,0x2f
         jnz L365
         lodsb
         mov ax,cs:[bx+0xa]
         or ax,ax
         jnz L30A
         mov word cs:[bx+0x8],0x0
         call L5BC
         jmp short L34D
L30A:    cmp ax,0x1
         jnz L321
         push word cs:[bx+0x10]
         push word cs:[bx+0x12]
         pop word cs:[bx+0xe]
         pop word cs:[bx+0xc]
         jmp short L34D
L321:    push ax
         push word cs:[bx+0x4]
         push word cs:[bx+0x6]
         pop word cs:[bx+0x2]
         pop word cs:[bx]
         call L242
         pop ax
         cmp ax,0x2
         jnz L342
         mov word cs:[bx+0xa],0x0
         jmp short L34D
L342:    cmp ax,0x3
         jnz L34D
         mov word cs:[bx+0xa],0x1
L34D:    mov al,cs:[bx+0x41]
         cmp al,0x0
         jna L35C
         sub si,SONG_BUFFER
         call L977
L35C:    mov si,cs:[bx+0xe]
         jmp near L3F3
         jmp short L3A7
L365:    cmp al,0x51
         jnz L387
         lodsb
         mov cx,cs:[bx+0x14]
         lodsb
         mov dx,ax
         lodsb
         xchg ah,al
         lodsb
         or cx,cx
         jnz L37F
         xor ax,ax
         xor dx,dx
         jmp short L381
L37F:    div cx
L381:    mov cs:[bx+0x16],ax
         jmp short L3A7
L387:    lodsb
         xor ah,ah
         add si,ax
         jmp short L3A7
L38E: mov di,ax
         and di,0xf
         mov byte cs:[bx+di+0x26],0x1
         mov di,ax
         shr di,byte 0x4
         sub di,0x8
         shl di,1
         call word near cs:[di+0x3e]
L3A7: xor ax,ax
         xor dx,dx
L3AB:    lodsb
         test al,0x80
         jnz L3B4
         jmp short L3BC
         jmp short L3BA
L3B4: mov dh,dl
         mov dl,ah
         mov ah,al
L3BA:    jmp short L3AB
L3BC: or ax,ax
         jnz L3C4
         or dx,dx
         jz L3F0
L3C4:    shl dl,1
         shr dx,1
         shl al,1
         shl ax,1
         shr dx,1
         rcr ax,1
         shr dx,1
         rcr ax,1
         and dh,0xf
         push bx
         push dx
         push ax
         mov ax,cs:[bx+0x16]
         xor dx,dx
         push dx
         push ax
         call L58A
         pop bx
         add cs:[bx+0x1a],ax
         adc cs:[bx+0x1c],dx
         jmp short L3F3
L3F0:    jmp near L2D4
L3F3:    mov cs:[bx+0xe],si
         pop si
         pop ds
         ret
L3FA:    cmp word cs:[bx+0x8],0x2
         jnz L405
         xor al,al
         jmp short L42C
L405:    push cx
         push dx
         push ax
         xor cx,cx
         xor ah,ah
         mul byte cs:[bx+0x3d]
         mov cl,cs:[bx+0x3e]
         mul cx
         or cx,cx
         jnz L420
         xor ax,ax
         xor dx,dx
         jmp short L422
L420:    div cx
L422:    cwd
         mov cl,0x7f
         div cx
         pop dx
         mov ah,dh
         pop dx
         pop cx
L42C:    ret
L42D:    call L4FD
         lodsb
         call L4FD
         lodsb
         call L3FA
         call L4FD
         ret
L43C:    call L4FD
         lodsb
         call L4FD
         lodsb
         call L3FA
         call L4FD
         ret
L44B:    call L4FD
         lodsb
         call L4FD
         lodsb
         call L3FA
         call L4FD
         ret
L45A:    call L4FD
         lodsb
         call L4FD
         lodsb
         call L4FD
         ret
L466:    call L4FD
         lodsb
         call L4FD
         ret
L46E:    call L4FD
         lodsb
         call L4FD
         ret
L476:    call L4FD
         lodsb
         call L4FD
         lodsb
         ret
L47F:    cmp al,0xf0
         jnz L490
         dec si
         push ds
         push si
         call L4D6
         add sp,0x4
         add si,ax
         jmp short L4B9
L490:    cmp al,0xf1
         jnz L49D
         call L4FD
         lodsb
         call L4FD
         jmp short L4B9
L49D:    cmp al,0xf2
         jnz L4AE
         call L4FD
         lodsb
         call L4FD
         lodsb
         call L4FD
         jmp short L4B9
L4AE:    cmp al,0xf3
         jnz L4B9
         call L4FD
         lodsb
         call L4FD
L4B9:    ret
L4BA:    push cx
         mov cx,0x100
L4BE:    call L553
         cmp ax,0xffffffffffffffff
         jnz L4C8
         jmp short L4CA
L4C8:    loop L4BE
L4CA: xor ax,ax
         mov al,0x3f
         call L52F
         call L574
         pop cx
         ret
L4D6:    push bp
         mov bp,sp
         push bx
         push si
         push ds
         lds si,word [bp+0x4]
         push si
         lodsb
         cmp al,0xf0
         jnz L4F3
         call L4FD
L4E8:    lodsb
         mov bl,al
         call L4FD
         cmp bl,0xf7
         jnz L4E8
L4F3:    pop bx
         mov ax,si
         sub ax,bx
         pop ds
         pop si
         pop bx
         pop bp
         ret
L4FD:    push cx
         push dx
         mov cx,0x800
         mov dx,cs:[0x170]
         mov ah,al
L509:    in al,dx
         test al,0x40
         jnz L51D
         dec dx
         mov al,ah
         out dx,al
         inc dx
         mov cx,0xa
L516:    in al,dx
         loop L516
         xor ax,ax
         jmp short L526
L51D:    test al,0x80
         jnz L524
         dec dx
         in al,dx
         inc dx
L524:    loop L509
L526: or cx,cx
         jnz L52C
         mov al,0xff
L52C:    pop dx
         pop cx
         ret
L52F:    push cx
         push dx
         mov cx,0x800
         mov dx,cs:[0x170]
         mov ah,al
L53B:    in al,dx
         test al,0x40
         jnz L547
         mov al,ah
         out dx,al
         xor ax,ax
         jmp short L549
L547:    loop L53B
L549: or cx,cx
         jnz L550
         mov ax,0xffff
L550:    pop dx
         pop cx
         ret
L553:    push cx
         push dx
         mov cx,0x800
         mov dx,cs:[0x170]
L55D:    in al,dx
         test al,0x80
         jnz L568
         dec dx
         in al,dx
         xor ah,ah
         jmp short L56A
L568:    loop L55D
L56A: or cx,cx
         jnz L571
         mov ax,0xffff
L571:    pop dx
         pop cx
         ret
L574:    push ax
         push cx
         push dx
         mov cx,0x200
         mov dx,cs:[0x170]
         in al,dx
         dec dx
L581:    in al,dx
         loop L581
         inc dx
         in al,dx
         pop dx
         pop cx
         pop ax
         ret
L58A:    push bp
         mov bp,sp
         mov ax,[bp+0x6]
         mov cx,[bp+0xa]
         or cx,ax
         mov cx,[bp+0x8]
         jnz L5A3
         mov ax,[bp+0x4]
         mul cx
         pop bp
         ret word 0x8
L5A3:    push bx
         mul cx
         mov bx,ax
         mov ax,[bp+0x4]
         mul word [bp+0xa]
         add bx,ax
         mov ax,[bp+0x4]
         mul cx
         add dx,bx
         pop bx
         pop bp
         ret word 0x8
L5BC:    push ax
         push si
         db 0x90, 0x90, 0x90, 0x90, 0x90  ; 0x05BE  nop x5 (was mov al,0x5 + call L52F: sent 0x05 to 331, ignored in UART mode; dead code cleared)
         mov si,0x0
L5C6: mov ax,si
         or al,0xb0
         call L4FD
         mov al,0x7b
         call L4FD
         mov ax,0x0
         call L4FD
         call cc_reset  ; was mov al,0xd0 + call L52F; now CC#121 all controllers off
         db 0x90, 0x90  ; 0x05DB  nop x2
         mov ax,si
         or al,0xb0
         call L4FD  ; fix3: data port
         mov al,0x40
         call L4FD  ; fix3: data port
         mov ax,0x0
         call L4FD  ; fix3: data port
         inc si
         cmp si,0x10
         jnz L5C6
         pop si
         pop ax
         ret
L5F8:    push bx
         push si
         push di
         push es
         inc dx
         mov cs:[0x170],dx
         call cc64_setup  ; was call L4BA; init routine does the UART init internally
         xor cx,cx
L607: mov bx,cx
         shl bx,1
         mov bx,cs:[bx+0x156]
         mov word cs:[bx+0x8],0x0
         inc cx
         cmp cx,0x3
         jnz L607
         xor cx,cx
L61E:    mov al,0xb0
         or al,cl
         call L4FD
         mov al,0x7b
         call L4FD
         mov al,0x0
         call L4FD
         inc cx
         cmp cx,0x10
         jnz L61E
         call L91D
         pop es
         pop di
         pop si
         pop bx
         ret
L63D:    push bx
         push cx
         push dx
         push si
         push di
         shl bx,1
         mov bx,cs:[bx+0x156]
         cmp word cs:[bx+0x8],0x0
         jnz L759
         push si
         mov si,0x0
L656:    mov byte cs:[bx+si+0x26],0x0
         inc si
         cmp si,0x10
         jnz L656
         pop si
         mov cs:[bx+0x41],ch
         mov cs:[bx+0x4],di
         mov word cs:[bx+0x6],es
         mov cs:[bx],si
         mov cs:[bx+0x2],dx
         call L242
         mov al,cs:[bx+0x3e]
         mov cs:[bx+0x3d],al
         or cl,cl
         jnz L698
         mov word cs:[bx+0xa],0x0
         mov byte cs:[bx+0x36],0x0
         mov word cs:[bx+0x8],0x1
         jmp near L754
L698:    cmp cl,0x1
         jnz L6B1
         mov word cs:[bx+0xa],0x1
         mov byte cs:[bx+0x36],0x0
         mov word cs:[bx+0x8],0x1
         jmp near L754
L6B1:    cmp cl,0x2
         jnz L6CF
         mov word cs:[bx+0xa],0x0
         mov byte cs:[bx+0x36],0x1
         mov byte cs:[bx+0x3d],0x0
         mov word cs:[bx+0x8],0x1
         jmp near L754
L6CF:    cmp cl,0x3
         jnz L6EC
         mov word cs:[bx+0xa],0x1
         mov byte cs:[bx+0x36],0x1
         mov byte cs:[bx+0x3d],0x0
         mov word cs:[bx+0x8],0x1
         jmp short L754
L6EC:    cmp cl,0x4
         jnz L704
         mov word cs:[bx+0xa],0x2
         mov byte cs:[bx+0x36],0x0
         mov word cs:[bx+0x8],0x1
         jmp short L754
L704:    cmp cl,0x5
         jnz L71C
         mov word cs:[bx+0xa],0x3
         mov byte cs:[bx+0x36],0x0
         mov word cs:[bx+0x8],0x1
         jmp short L754
L71C:    cmp cl,0x6
         jnz L739
         mov word cs:[bx+0xa],0x2
         mov byte cs:[bx+0x36],0x1
         mov byte cs:[bx+0x3d],0x0
         mov word cs:[bx+0x8],0x1
         jmp short L754
L739:    cmp cl,0x7
         jnz L754
         mov word cs:[bx+0xa],0x3
         mov byte cs:[bx+0x36],0x1
         mov byte cs:[bx+0x3d],0x0
         mov word cs:[bx+0x8],0x1
L754:    mov ax,0x0
         jmp short L75C
L759:    mov ax,0xffff
L75C:    pop di
         pop si
         pop dx
         pop cx
         pop bx
         ret
L762:    push ax
         push bx
         shl bx,1
         mov bx,cs:[bx+0x156]
         or cx,cx
         jnz L77A
         mov word cs:[bx+0x8],0x0
         call L5BC
         jmp short L7BE
L77A:    cmp cx,0x1
         jnz L78E
         mov al,cs:[bx+0x3e]
         mov cs:[bx+0x3d],al
         mov byte cs:[bx+0x36],0xff
         jmp short L7BE
L78E:    cmp cx,0x2
         jnz L7A5
         mov word cs:[bx+0xa],0x0
L799:    cmp word cs:[bx+0x8],0x0
         jnz L799
         call L5BC
         jmp short L7BE
L7A5:    cmp cx,0x3
         jnz L7BE
         mov al,cs:[bx+0x3e]
         mov cs:[bx+0x3d],al
         mov byte cs:[bx+0x36],0xff
L7B7:    cmp word cs:[bx+0x8],0x0
         jnz L7B7
L7BE:    pop bx
         pop ax
         ret
L7C1:    push bx
         mov ax,bx
         shl bx,1
         mov bx,cs:[bx+0x156]
         cmp byte cs:[bx+0x36],0x0
         jnz L7E8
         mov cs:[bx+0x3e],dl
         mov cs:[bx+0x3d],dl
         mov dx,cs:[bx+0x37]
         mov bx,ax
         call L869
         mov ax,0x0
         jmp short L7EB
L7E8:    mov ax,0xffff
L7EB:    pop bx
         ret
L7ED:    push bx
         shl bx,1
         mov bx,cs:[bx+0x156]
         cmp word cs:[bx+0x8],0x0
         jz L81C
         mov ax,0x2710
         cmp dx,ax
         jg L817
         neg ax
         cmp dx,ax
         jl L812
         mov cs:[bx+0x18],dx
         mov ax,0x0
         jmp short L81F
L812:    mov ax,0xffff
         jmp short L81F
L817:    mov ax,0xffff
         jmp short L81F
L81C:    mov ax,0xffff
L81F:    pop bx
         ret
L821:    shl bx,1
         mov bx,cs:[bx+0x156]
         cmp word cs:[bx+0x8],0x0
         jna L865
         or cx,cx
         jnz L844
         xor word cs:[bx+0x8],0x3
         cmp word cs:[bx+0x8],0x2
         jnz L85F
         call L5BC
         jmp short L85F
L844:    cmp cx,0x1
         jnz L851
         mov word cs:[bx+0x8],0x1
         jmp short L85F
L851:    cmp cx,0x2
         jnz L85F
         mov word cs:[bx+0x8],0x2
         call L5BC
L85F:    mov ax,cs:[bx+0x8]
         jmp short L868
L865:    mov ax,0xffff
L868:    ret
L869:    push bx
         push cx
         push dx
         shl bx,1
         mov bx,cs:[bx+0x156]
         cmp byte cs:[bx+0x36],0x0
         jnz L8A0
         mov cs:[bx+0x37],dx
         mov ax,dx
         mov cx,0x64
         mul cx
         xor ch,ch
         mov cl,cs:[bx+0x3e]
         or cx,cx
         jnz L895
         xor ax,ax
         xor dx,dx
         jmp short L897
L895:    div cx
L897:    mov cs:[bx+0x39],ax
         mov ax,0x0
         jmp short L8A3
L8A0:    mov ax,0xffff
L8A3:    pop dx
         pop cx
         pop bx
         ret
L8A7:    shl bx,1
         mov bx,cs:[bx+0x156]
         cmp word cs:[bx+0x8],0x0
         jz L8C3
         mov ax,cs:[bx+0x20]
         mov cx,cs:[bx+0x24]
         mov bx,cs:[bx+0x22]
         jmp short L8C6
L8C3:    mov ax,0xffff
L8C6:    ret
L8C7:    push bx
         shl bx,1
         mov bx,cs:[bx+0x156]
         mov ax,cs:[bx+0x8]
         pop bx
         ret
L8D5:    push bx
         shl bx,1
         mov bx,cs:[bx+0x156]
         cmp word cs:[bx+0x8],0x0
         jz L918
         or cx,cx
         jnz L8F8
         neg word cs:[bx+0x8]
         cmp word cs:[bx+0x8],0xffffffffffffffff
         jnz L913
         call L5BC
         jmp short L913
L8F8:    cmp cx,0x1
         jnz L908
         mov word cs:[bx+0x8],0xffff
         call L5BC
         jmp short L913
L908:    cmp cx,0x2
         jnz L913
         mov word cs:[bx+0x8],0x1
L913:    mov ax,0x0
         jmp short L91B
L918:    mov ax,0xffff
L91B:    pop bx
         ret
L91D:    push ax
         push bx
         push es
         mov ax,0x4300
         int 0x2f
         cmp al,0x80
         jnz L938
         mov ax,0x4310
         int 0x2f
         mov cs:[0x172],bx
         mov word cs:[0x174],es
L938:    pop es
         pop bx
         pop ax
         ret
         push ax
         push bx
         push cx
         push di
         push si
         push es
         push ds
         pop ds
         pop es
         pop si
         pop di
         pop cx
         pop bx
         pop ax
         ret
L94B:    cmp al,0x1
         jnz L967
         mov cs:[bx+0x4c],si
         mov dword cs:[bx+0x4e],0x0
         mov si,SONG_BUFFER
         mov cs:[bx+0x54],si
         mov word cs:[bx+0x56],cs
L967:    push cs
         pop ds
         mov si,SONG_BUFFER
         ret
         push ax
         push dx
         pop dx
         pop ax
         ret
         push ax
         push dx
         pop dx
         pop ax
         ret
L977:    cmp al,0x1
         jnz L984
         mov dword cs:[bx+0x4e],0x0
L984:    ret
L985:    push eax
         push bx
         push ds
         sub si,SONG_BUFFER
         cmp al,0x1
         jnz L9A5
         xor eax,eax
         mov ax,si
         add cs:[bx+0x4e],eax
         lea si,[bx+0x48]
         mov ah,0xb
         call word far cs:[0x172]
L9A5:    mov si,SONG_BUFFER
         pop ds
         pop bx
         pop eax
         ret

; ============ fix1: Pitch Bend re-send MSB ============
; original handler read the MSB but never sent it; this routine sends it
pb_fix:
         call L4FD          ; send status
         lodsb
         call L4FD          ; send LSB
         lodsb
         call L4FD          ; send MSB (was dropped)
         ret

; ============ fix2: SysEx strip SMF length ============
; original sent everything from F0 to F7 verbatim, including the SMF length byte;
; this one sends F0, skips the VLQ length, then sends payload up to F7
sx_fix:
         cmp al, 0xf0
         jnz near L490       ; F1/F2/F3 keep the original path
         dec si
         mov di, si          ; remember start
         lodsb
         call L4FD           ; send F0
.skip_vlq:
         lodsb
         test al, 0x80
         jnz .skip_vlq       ; skip multi-byte VLQ length
.send_payload:
         lodsb
         mov bl, al
         call L4FD
         cmp bl, 0xf7
         jnz .send_payload   ; loop until F7
         mov ax, si
         sub ax, di          ; return bytes consumed
         ret

; ============ fix4: All Controllers Off ============
; added to the L5BC/L5C6 all-silence routine: Reset All Controllers on 16 channels (B0+ch / 0x79 / 0x00)
cc_reset:
         mov ax,si
         or al,0xb0
         call L4FD           ; B0+ch
         mov al,0x79
         call L4FD           ; 0x79 = CC#121 All Controllers Off
         mov ax,0x0
         call L4FD           ; 0x00
         ret

; ============ CC64 normalize / pass-through ============
; SUSPAN_FLAG = 1 -> CC64 passed through unchanged (keep original value)
; SUSPAN_FLAG = 0 -> CC64 <64 -> 0, >=64 -> 127 (GM/GS/XG spec switch; default)
cc_fix:
         call L4FD           ; send status
         lodsb               ; controller
         mov cl, al          ; save (CL survives L4FD)
         call L4FD           ; send controller
         lodsb               ; value
         cmp cl, 0x40        ; CC64 Damper Pedal?
         jne .send
         cmp byte cs:[SUSPAN_FLAG], 0
         jne .send           ; forced pass-through
         cmp al, 64
         jb .zero
         mov al, 127
         jmp .send
.zero:
         xor al, al
.send:
         call L4FD           ; send value
         ret

; ============ CC64 mode init ============
; Called at the very start of init (replaces the original call L4BA); first does the UART init internally.
; If a file named SUSSPAN exists -> SUSPAN_FLAG=1 (CC64 pass-through);
; otherwise SUSPAN_FLAG=0 (default: normalize 0/127 per GM/GS/XG).
; Note: the file check uses DOS INT 21h FindFirst, which has re-entrancy risk
; inside an ISR -- the override is only for users who explicitly want to disable normalization.
cc64_setup:
         call L4BA           ; UART init (drain + 0x3F + flush)
         push ax
         push bx
         push cx
         push dx
         push si
         push di
         ; --- forced pass-through: SUSSPAN file present -> keep CC64 raw value ---
         push ds             ; save/restore DS temporarily
         push cs
         pop ds
         mov ah,0x4e         ; DOS FindFirst
         xor cx,cx           ; normal file attributes
         mov dx,SUSSPAN_NAME
         int 0x21
         pop ds
         jc .normalize       ; no file -> default normalization
         mov al,1
         jmp .set_flag
.normalize:
         xor al,al
.set_flag:
         mov cs:[SUSPAN_FLAG],al
         pop di
         pop si
         pop dx
         pop cx
         pop bx
         pop ax
         ret

; ============ Mode flag data ============
; Runs in the ISR context; no file I/O besides the SUSSPAN check (no logging).
SUSPAN_FLAG: db 0             ; 0 = normalize CC64 to 0/127 (default), 1 = pass-through
SUSSPAN_NAME: db "susspan", 0 ; presence forces CC64 pass-through

; ============ Pad to SONG_BUFFER ============
times (SONG_BUFFER - ($-$$)) db 0

; ---------------- 0x0A80-0x0C7F: song data buffer ----------------
song_buffer: times 512 db 0


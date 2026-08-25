; ===================================================================
; mpu401.drv — SoftStar MMS-Midi Driver
; 仙剑 DOS 版 MPU-401 MIDI 驱动（原作者 Pei-Cheng Tong）
;
; 修改要点：
;   * SONG_BUFFER 是歌曲数据缓冲基址，代码里所有引用都走这个宏；
;     想挪缓冲/加代码，先改它再调布局。
;   * MPU_PORT 是 MPU-401 状态端口（数据口 = MPU_PORT-1）。
; ===================================================================
BITS 16
CPU 386

SONG_BUFFER  equ 0x2000   ; 歌曲数据缓冲基址（代码区 0x180..0x1FFF 可自由使用）
MPU_PORT     equ 0x0331      ; MPU-401 状态端口

; 三个修复用新例程（放在原 0x9AD 之后腾出的空间里）
PB_HANDLER   equ 0x9B0       ; Pitch Bend 补发 MSB
SX_HANDLER   equ 0x9C0       ; SysEx 剥 SMF 长度

; CC64 归一化与强制透传（也在腾出的空间里）
CC_FIX       equ 0x1000      ; CC 处理器：CC64 归一化 0/127，或按标志透传
CC64_SETUP   equ 0x1030      ; 初始化：UART 初始化 + SUSSPAN 文件检查
CC64_DATA    equ 0x1180      ; SUSPAN_FLAG 标志 / 文件名

; ---------------- 0x000-0x031: 签名 ----------------
sig:        db "SoftStar MMS-Midi Driver Writen By Pei-Cheng Tong", 0x1A

; ---------------- 0x032-0x03D: API 入口 ----------------
            jmp near L180        ; AX=服务号 -> 主分发
            jmp near L18C        ; 播放器 0 tick
            jmp near L191        ; 播放器 1 tick
            jmp near L196        ; 播放器 2 tick

; ---------------- 0x03E-0x04D: 消息分发表 ----------------
; 索引 = (status>>4)-8: 8..F -> NoteOff,NoteOn,PolyAT,CC,Prog,ChanAT,Pitch,Sys
handlers:   dw L42D, L43C, L44B, cc_fix, L466, L46E, PB_HANDLER, SX_HANDLER

; ---------------- 0x04E-0x155: 播放器结构体 x3 ----------------
; 每份 0x58 字节；字段见 struct_layout.csv
; (0x4E) 玩家0 | (0xA6) 玩家1 | (0xFE) 玩家2
struct_004E:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x004E  <-- 结构体基址
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x005E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x006E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x007E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x008E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x009E

struct_00A6:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00A6  <-- 结构体基址
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00B6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00C6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x00D6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00E6
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00F6

struct_00FE:
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x00FE  <-- 结构体基址
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x010E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x011E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00  ; 0x012E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x013E
            db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; 0x014E

; ---------------- 0x156-0x16F: 服务/玩家分发表 ----------------
; [0x156]=玩家0基址 [0x158]=玩家1 [0x15A]=玩家2；[0x15C]起为服务处理
svc_table:  dw 0x004E, 0x00A6, 0x00FE
            dw L5F8, L63D, L762, L7C1, L7ED, L821, L869, L8A7, L8C7, L8D5

; ---------------- 0x170-0x17F: 端口 / Mapper / 字符串 ----------------
mpu_port:   dw MPU_PORT               ; 0x170 MPU-401 状态端口
mapper_ptr: dd 0                      ; 0x172 MIDI Mapper 入口（运行时填充）
            db "EMMXXXX0", 0, 0        ; 0x176

; ---------------- 0x180-0x9AC: 代码 ----------------
; 标签 = L + 偏移；SONG_BUFFER 引用全部宏化

L180:    xchg ax,bx  ; 0x0180  93
         shl bx,1  ; 0x0181  d1 e3
         mov bx,cs:[bx+0x15c]  ; 0x0183  2e 8b 9f 5c 01
         xchg ax,bx  ; 0x0188  93
         call ax  ; 0x0189  ff d0
         retf  ; 0x018B  cb
L18C:    mov bx,0x4e  ; 0x018C  bb 4e 00
         jmp short L19B  ; 0x018F  eb 0a
L191:    mov bx,0xa6  ; 0x0191  bb a6 00
         jmp short L19B  ; 0x0194  eb 05
L196:    mov bx,0xfe  ; 0x0196  bb fe 00
         jmp short L19B  ; 0x0199  eb 00
L19B:    cmp word cs:[bx+0x8],0x0  ; 0x019B  2e 83 7f 08 00
         jg L1A3  ; 0x01A0  7f 01
         retf  ; 0x01A2  cb
L1A3:    pushad  ; 0x01A3  66 60
         mov di,cs:[bx+0x1e]  ; 0x01A5  2e 8b 7f 1e
         mov ax,cs:[bx+0x20]  ; 0x01A9  2e 8b 47 20
         mov cx,cs:[bx+0x22]  ; 0x01AD  2e 8b 4f 22
         mov dx,cs:[bx+0x24]  ; 0x01B1  2e 8b 57 24
         add di,0x64  ; 0x01B5  83 c7 64
         cmp di,0x3e8  ; 0x01B8  81 ff e8 03
         jc L1D3  ; 0x01BC  72 15
         sub di,0x3e8  ; 0x01BE  81 ef e8 03
         inc ax  ; 0x01C2  40
         cmp ax,0x3e8  ; 0x01C3  3d e8 03
         jnz L1D3  ; 0x01C6  75 0b
         db 0x33, 0xC0  ; xor ax,ax  (0x01C8 raw)
         inc cx  ; 0x01CA  41
         cmp cx,0x3c  ; 0x01CB  83 f9 3c
         jnz L1D3  ; 0x01CE  75 03
         db 0x33, 0xC9  ; xor cx,cx  (0x01D0 raw)
         inc dx  ; 0x01D2  42
L1D3:    mov cs:[bx+0x1e],di  ; 0x01D3  2e 89 7f 1e
         mov cs:[bx+0x20],ax  ; 0x01D7  2e 89 47 20
         mov cs:[bx+0x22],cx  ; 0x01DB  2e 89 4f 22
         mov cs:[bx+0x24],dx  ; 0x01DF  2e 89 57 24
         cmp byte cs:[bx+0x36],0x0  ; 0x01E3  2e 80 7f 36 00
         jz L22B  ; 0x01E8  74 41
         mov dx,cs:[bx+0x3b]  ; 0x01EA  2e 8b 57 3b
         cmp dx,cs:[bx+0x39]  ; 0x01EE  2e 3b 57 39
         jnz L227  ; 0x01F2  75 33
         mov al,cs:[bx+0x36]  ; 0x01F4  2e 8a 47 36
         add cs:[bx+0x3d],al  ; 0x01F8  2e 00 47 3d
         mov al,cs:[bx+0x3d]  ; 0x01FC  2e 8a 47 3d
         db 0x0A, 0xC0  ; or al,al  (0x0200 raw)
         jnz L214  ; 0x0202  75 10
         mov byte cs:[bx+0x36],0x0  ; 0x0204  2e c6 47 36 00
         mov word cs:[bx+0x8],0x0  ; 0x0209  2e c7 47 08 00 00
         db 0xE8, 0xAA, 0x03  ; call L5BC  (0x020F raw)
         jmp short L21F  ; 0x0212  eb 0b
L214:    cmp al,cs:[bx+0x3e]  ; 0x0214  2e 3a 47 3e
         jnz L21F  ; 0x0218  75 05
         mov byte cs:[bx+0x36],0x0  ; 0x021A  2e c6 47 36 00
L21F:    mov word cs:[bx+0x3b],0x0  ; 0x021F  2e c7 47 3b 00 00
         jmp short L22B  ; 0x0225  eb 04
L227:    inc word cs:[bx+0x3b]  ; 0x0227  2e ff 47 3b
L22B:    db 0x66, 0x33, 0xC0  ; xor eax,eax  (0x022B raw)
         mov ax,0x2710  ; 0x022E  b8 10 27
         add ax,cs:[bx+0x18]  ; 0x0231  2e 03 47 18
         db 0x66, 0x2E, 0x29, 0x47, 0x1A  ; sub cs:[bx+0x1a],eax  (0x0235 raw)
         jg L23F  ; 0x023A  7f 03
         call L2BE  ; 0x023C  e8 7f 00
L23F:    popad  ; 0x023F  66 61
         retf  ; 0x0241  cb
L242:    push bx  ; 0x0242  53
         push cx  ; 0x0243  51
         push dx  ; 0x0244  52
         push si  ; 0x0245  56
         push di  ; 0x0246  57
         push ds  ; 0x0247  1e
         push es  ; 0x0248  06
         lds si,word cs:[bx]  ; 0x0249  2e c5 37
         mov al,cs:[bx+0x41]  ; 0x024C  2e 8a 47 41
         cmp al,0x0  ; 0x0250  3c 00
         jna L25C  ; 0x0252  76 08
         db 0xE8, 0xF4, 0x06  ; call L94B  (0x0254 raw)
         push cs  ; 0x0257  0e
         pop es  ; 0x0258  07
         db 0xE8, 0x29, 0x07  ; call L985  (0x0259 raw)
L25C:    mov word cs:[bx+0xc],ds  ; 0x025C  2e 8c 5f 0c
         mov word cs:[bx+0x10],ds  ; 0x0260  2e 8c 5f 10
         add si,0xc  ; 0x0264  83 c6 0c
         cld  ; 0x0267  fc
         lodsw  ; 0x0268  ad
         xchg ah,al  ; 0x0269  86 e0
         mov cs:[bx+0x14],ax  ; 0x026B  2e 89 47 14
         push ax  ; 0x026F  50
         add si,0x9  ; 0x0270  83 c6 09
         mov cs:[bx+0xe],si  ; 0x0273  2e 89 77 0e
         mov cs:[bx+0x12],si  ; 0x0277  2e 89 77 12
         pop cx  ; 0x027B  59
         mov dx,0x7  ; 0x027C  ba 07 00
         mov ax,0xa120  ; 0x027F  b8 20 a1
         db 0x0B, 0xC9  ; or cx,cx  (0x0282 raw)
         jnz L28C  ; 0x0284  75 06
         db 0x33, 0xC0  ; xor ax,ax  (0x0286 raw)
         db 0x33, 0xD2  ; xor dx,dx  (0x0288 raw)
         jmp short L28E  ; 0x028A  eb 02
L28C:    div cx  ; 0x028C  f7 f1
L28E:    mov cs:[bx+0x16],ax  ; 0x028E  2e 89 47 16
         mov word cs:[bx+0x1a],0x0  ; 0x0292  2e c7 47 1a 00 00
         mov word cs:[bx+0x1c],0x0  ; 0x0298  2e c7 47 1c 00 00
         mov word cs:[bx+0x1e],0x0  ; 0x029E  2e c7 47 1e 00 00
         mov word cs:[bx+0x20],0x0  ; 0x02A4  2e c7 47 20 00 00
         mov word cs:[bx+0x22],0x0  ; 0x02AA  2e c7 47 22 00 00
         mov word cs:[bx+0x24],0x0  ; 0x02B0  2e c7 47 24 00 00
         pop es  ; 0x02B6  07
         pop ds  ; 0x02B7  1f
         pop di  ; 0x02B8  5f
         pop si  ; 0x02B9  5e
         pop dx  ; 0x02BA  5a
         pop cx  ; 0x02BB  59
         pop bx  ; 0x02BC  5b
         ret  ; 0x02BD  c3
L2BE:    push ds  ; 0x02BE  1e
         push si  ; 0x02BF  56
         cld  ; 0x02C0  fc
         mov ds,word cs:[bx+0xc]  ; 0x02C1  2e 8e 5f 0c
         mov si,cs:[bx+0xe]  ; 0x02C5  2e 8b 77 0e
         mov al,cs:[bx+0x41]  ; 0x02C9  2e 8a 47 41
         cmp al,0x0  ; 0x02CD  3c 00
         jna L2D4  ; 0x02CF  76 03
         db 0xE8, 0xB1, 0x06  ; call L985  (0x02D1 raw)
L2D4:    cld  ; 0x02D4  fc
         db 0x33, 0xC0  ; xor ax,ax  (0x02D5 raw)
         lodsb  ; 0x02D7  ac
         cmp al,0xf0  ; 0x02D8  3c f0
         jnc L2EB  ; 0x02DA  73 0f
         cmp al,0x80  ; 0x02DC  3c 80
         jnc L2E7  ; 0x02DE  73 07
         dec si  ; 0x02E0  4e
         mov ax,cs:[bx+0x3f]  ; 0x02E1  2e 8b 47 3f
         jmp short L2EB  ; 0x02E5  eb 04
L2E7:    mov cs:[bx+0x3f],ax  ; 0x02E7  2e 89 47 3f
L2EB:    cmp al,0xff  ; 0x02EB  3c ff
         jnz L38E  ; 0x02ED  0f 85 9d 00
         lodsb  ; 0x02F1  ac
         cmp al,0x2f  ; 0x02F2  3c 2f
         jnz L365  ; 0x02F4  75 6f
         lodsb  ; 0x02F6  ac
         mov ax,cs:[bx+0xa]  ; 0x02F7  2e 8b 47 0a
         db 0x0B, 0xC0  ; or ax,ax  (0x02FB raw)
         jnz L30A  ; 0x02FD  75 0b
         mov word cs:[bx+0x8],0x0  ; 0x02FF  2e c7 47 08 00 00
         db 0xE8, 0xB4, 0x02  ; call L5BC  (0x0305 raw)
         jmp short L34D  ; 0x0308  eb 43
L30A:    cmp ax,0x1  ; 0x030A  83 f8 01
         jnz L321  ; 0x030D  75 12
         push word cs:[bx+0x10]  ; 0x030F  2e ff 77 10
         push word cs:[bx+0x12]  ; 0x0313  2e ff 77 12
         pop word cs:[bx+0xe]  ; 0x0317  2e 8f 47 0e
         pop word cs:[bx+0xc]  ; 0x031B  2e 8f 47 0c
         jmp short L34D  ; 0x031F  eb 2c
L321:    push ax  ; 0x0321  50
         push word cs:[bx+0x4]  ; 0x0322  2e ff 77 04
         push word cs:[bx+0x6]  ; 0x0326  2e ff 77 06
         pop word cs:[bx+0x2]  ; 0x032A  2e 8f 47 02
         pop word cs:[bx]  ; 0x032E  2e 8f 07
         call L242  ; 0x0331  e8 0e ff
         pop ax  ; 0x0334  58
         cmp ax,0x2  ; 0x0335  83 f8 02
         jnz L342  ; 0x0338  75 08
         mov word cs:[bx+0xa],0x0  ; 0x033A  2e c7 47 0a 00 00
         jmp short L34D  ; 0x0340  eb 0b
L342:    cmp ax,0x3  ; 0x0342  83 f8 03
         jnz L34D  ; 0x0345  75 06
         mov word cs:[bx+0xa],0x1  ; 0x0347  2e c7 47 0a 01 00
L34D:    mov al,cs:[bx+0x41]  ; 0x034D  2e 8a 47 41
         cmp al,0x0  ; 0x0351  3c 00
         jna L35C  ; 0x0353  76 07
         sub si,SONG_BUFFER  ; 0x0355  81 ee ad 09
         db 0xE8, 0x1B, 0x06  ; call L977  (0x0359 raw)
L35C:    mov si,cs:[bx+0xe]  ; 0x035C  2e 8b 77 0e
         db 0xE9, 0x90, 0x00  ; jmp near L3F3  (0x0360 raw)
         db 0xEB, 0x42  ; jmp short L3A7  (0x0363 raw)
L365:    cmp al,0x51  ; 0x0365  3c 51
         jnz L387  ; 0x0367  75 1e
         lodsb  ; 0x0369  ac
         mov cx,cs:[bx+0x14]  ; 0x036A  2e 8b 4f 14
         lodsb  ; 0x036E  ac
         db 0x8B, 0xD0  ; mov dx,ax  (0x036F raw)
         lodsb  ; 0x0371  ac
         xchg ah,al  ; 0x0372  86 e0
         lodsb  ; 0x0374  ac
         db 0x0B, 0xC9  ; or cx,cx  (0x0375 raw)
         jnz L37F  ; 0x0377  75 06
         db 0x33, 0xC0  ; xor ax,ax  (0x0379 raw)
         db 0x33, 0xD2  ; xor dx,dx  (0x037B raw)
         jmp short L381  ; 0x037D  eb 02
L37F:    div cx  ; 0x037F  f7 f1
L381:    mov cs:[bx+0x16],ax  ; 0x0381  2e 89 47 16
         db 0xEB, 0x20  ; jmp short L3A7  (0x0385 raw)
L387:    lodsb  ; 0x0387  ac
         db 0x32, 0xE4  ; xor ah,ah  (0x0388 raw)
         db 0x03, 0xF0  ; add si,ax  (0x038A raw)
         db 0xEB, 0x19  ; jmp short L3A7  (0x038C raw)
L38E:    db 0x8B, 0xF8  ; mov di,ax  (0x038E raw)
         and di,0xf  ; 0x0390  83 e7 0f
         mov byte cs:[bx+di+0x26],0x1  ; 0x0393  2e c6 41 26 01
         db 0x8B, 0xF8  ; mov di,ax  (0x0398 raw)
         shr di,byte 0x4  ; 0x039A  c1 ef 04
         sub di,0x8  ; 0x039D  83 ef 08
         shl di,1  ; 0x03A0  d1 e7
         db 0x2E, 0xFF, 0x95, 0x3E, 0x00  ; call word near cs:[di+0x3e]  (0x03A2 raw)
L3A7:    db 0x33, 0xC0  ; xor ax,ax  (0x03A7 raw)
         db 0x33, 0xD2  ; xor dx,dx  (0x03A9 raw)
L3AB:    lodsb  ; 0x03AB  ac
         test al,0x80  ; 0x03AC  a8 80
         jnz L3B4  ; 0x03AE  75 04
         jmp short L3BC  ; 0x03B0  eb 0a
         jmp short L3BA  ; 0x03B2  eb 06
L3B4:    db 0x8A, 0xF2  ; mov dh,dl  (0x03B4 raw)
         db 0x8A, 0xD4  ; mov dl,ah  (0x03B6 raw)
         db 0x8A, 0xE0  ; mov ah,al  (0x03B8 raw)
L3BA:    jmp short L3AB  ; 0x03BA  eb ef
L3BC:    db 0x0B, 0xC0  ; or ax,ax  (0x03BC raw)
         jnz L3C4  ; 0x03BE  75 04
         db 0x0B, 0xD2  ; or dx,dx  (0x03C0 raw)
         jz L3F0  ; 0x03C2  74 2c
L3C4:    shl dl,1  ; 0x03C4  d0 e2
         shr dx,1  ; 0x03C6  d1 ea
         shl al,1  ; 0x03C8  d0 e0
         shl ax,1  ; 0x03CA  d1 e0
         shr dx,1  ; 0x03CC  d1 ea
         rcr ax,1  ; 0x03CE  d1 d8
         shr dx,1  ; 0x03D0  d1 ea
         rcr ax,1  ; 0x03D2  d1 d8
         and dh,0xf  ; 0x03D4  80 e6 0f
         push bx  ; 0x03D7  53
         push dx  ; 0x03D8  52
         push ax  ; 0x03D9  50
         mov ax,cs:[bx+0x16]  ; 0x03DA  2e 8b 47 16
         db 0x33, 0xD2  ; xor dx,dx  (0x03DE raw)
         push dx  ; 0x03E0  52
         push ax  ; 0x03E1  50
         call L58A  ; 0x03E2  e8 a5 01
         pop bx  ; 0x03E5  5b
         add cs:[bx+0x1a],ax  ; 0x03E6  2e 01 47 1a
         adc cs:[bx+0x1c],dx  ; 0x03EA  2e 11 57 1c
         jmp short L3F3  ; 0x03EE  eb 03
L3F0:    jmp near L2D4  ; 0x03F0  e9 e1 fe
L3F3:    mov cs:[bx+0xe],si  ; 0x03F3  2e 89 77 0e
         pop si  ; 0x03F7  5e
         pop ds  ; 0x03F8  1f
         ret  ; 0x03F9  c3
L3FA:    cmp word cs:[bx+0x8],0x2  ; 0x03FA  2e 83 7f 08 02
         jnz L405  ; 0x03FF  75 04
         db 0x32, 0xC0  ; xor al,al  (0x0401 raw)
         jmp short L42C  ; 0x0403  eb 27
L405:    push cx  ; 0x0405  51
         push dx  ; 0x0406  52
         push ax  ; 0x0407  50
         db 0x33, 0xC9  ; xor cx,cx  (0x0408 raw)
         db 0x32, 0xE4  ; xor ah,ah  (0x040A raw)
         mul byte cs:[bx+0x3d]  ; 0x040C  2e f6 67 3d
         mov cl,cs:[bx+0x3e]  ; 0x0410  2e 8a 4f 3e
         mul cx  ; 0x0414  f7 e1
         db 0x0B, 0xC9  ; or cx,cx  (0x0416 raw)
         jnz L420  ; 0x0418  75 06
         db 0x33, 0xC0  ; xor ax,ax  (0x041A raw)
         db 0x33, 0xD2  ; xor dx,dx  (0x041C raw)
         jmp short L422  ; 0x041E  eb 02
L420:    div cx  ; 0x0420  f7 f1
L422:    cwd  ; 0x0422  99
         mov cl,0x7f  ; 0x0423  b1 7f
         div cx  ; 0x0425  f7 f1
         pop dx  ; 0x0427  5a
         db 0x8A, 0xE6  ; mov ah,dh  (0x0428 raw)
         pop dx  ; 0x042A  5a
         pop cx  ; 0x042B  59
L42C:    ret  ; 0x042C  c3
L42D:    call L4FD  ; 0x042D  e8 cd 00
         lodsb  ; 0x0430  ac
         call L4FD  ; 0x0431  e8 c9 00
         lodsb  ; 0x0434  ac
         call L3FA  ; 0x0435  e8 c2 ff
         call L4FD  ; 0x0438  e8 c2 00
         ret  ; 0x043B  c3
L43C:    call L4FD  ; 0x043C  e8 be 00
         lodsb  ; 0x043F  ac
         call L4FD  ; 0x0440  e8 ba 00
         lodsb  ; 0x0443  ac
         call L3FA  ; 0x0444  e8 b3 ff
         call L4FD  ; 0x0447  e8 b3 00
         ret  ; 0x044A  c3
L44B:    call L4FD  ; 0x044B  e8 af 00
         lodsb  ; 0x044E  ac
         call L4FD  ; 0x044F  e8 ab 00
         lodsb  ; 0x0452  ac
         call L3FA  ; 0x0453  e8 a4 ff
         call L4FD  ; 0x0456  e8 a4 00
         ret  ; 0x0459  c3
L45A:    call L4FD  ; 0x045A  e8 a0 00
         lodsb  ; 0x045D  ac
         call L4FD  ; 0x045E  e8 9c 00
         lodsb  ; 0x0461  ac
         call L4FD  ; 0x0462  e8 98 00
         ret  ; 0x0465  c3
L466:    call L4FD  ; 0x0466  e8 94 00
         lodsb  ; 0x0469  ac
         call L4FD  ; 0x046A  e8 90 00
         ret  ; 0x046D  c3
L46E:    call L4FD  ; 0x046E  e8 8c 00
         lodsb  ; 0x0471  ac
         call L4FD  ; 0x0472  e8 88 00
         ret  ; 0x0475  c3
L476:    call L4FD  ; 0x0476  e8 84 00
         lodsb  ; 0x0479  ac
         call L4FD  ; 0x047A  e8 80 00
         lodsb  ; 0x047D  ac
         ret  ; 0x047E  c3
L47F:    cmp al,0xf0  ; 0x047F  3c f0
         jnz L490  ; 0x0481  75 0d
         dec si  ; 0x0483  4e
         push ds  ; 0x0484  1e
         push si  ; 0x0485  56
         call L4D6  ; 0x0486  e8 4d 00
         add sp,0x4  ; 0x0489  83 c4 04
         db 0x03, 0xF0  ; add si,ax  (0x048C raw)
         jmp short L4B9  ; 0x048E  eb 29
L490:    cmp al,0xf1  ; 0x0490  3c f1
         jnz L49D  ; 0x0492  75 09
         call L4FD  ; 0x0494  e8 66 00
         lodsb  ; 0x0497  ac
         call L4FD  ; 0x0498  e8 62 00
         jmp short L4B9  ; 0x049B  eb 1c
L49D:    cmp al,0xf2  ; 0x049D  3c f2
         jnz L4AE  ; 0x049F  75 0d
         call L4FD  ; 0x04A1  e8 59 00
         lodsb  ; 0x04A4  ac
         call L4FD  ; 0x04A5  e8 55 00
         lodsb  ; 0x04A8  ac
         call L4FD  ; 0x04A9  e8 51 00
         jmp short L4B9  ; 0x04AC  eb 0b
L4AE:    cmp al,0xf3  ; 0x04AE  3c f3
         jnz L4B9  ; 0x04B0  75 07
         call L4FD  ; 0x04B2  e8 48 00
         lodsb  ; 0x04B5  ac
         call L4FD  ; 0x04B6  e8 44 00
L4B9:    ret  ; 0x04B9  c3
L4BA:    push cx  ; 0x04BA  51
         mov cx,0x100  ; 0x04BB  b9 00 01
L4BE:    call L553  ; 0x04BE  e8 92 00
         cmp ax,0xffffffffffffffff  ; 0x04C1  83 f8 ff
         jnz L4C8  ; 0x04C4  75 02
         jmp short L4CA  ; 0x04C6  eb 02
L4C8:    loop L4BE  ; 0x04C8  e2 f4
L4CA:    db 0x33, 0xC0  ; xor ax,ax  (0x04CA raw)
         mov al,0x3f  ; 0x04CC  b0 3f
         call L52F  ; 0x04CE  e8 5e 00
         call L574  ; 0x04D1  e8 a0 00
         pop cx  ; 0x04D4  59
         ret  ; 0x04D5  c3
L4D6:    push bp  ; 0x04D6  55
         db 0x8B, 0xEC  ; mov bp,sp  (0x04D7 raw)
         push bx  ; 0x04D9  53
         push si  ; 0x04DA  56
         push ds  ; 0x04DB  1e
         lds si,word [bp+0x4]  ; 0x04DC  c5 76 04
         push si  ; 0x04DF  56
         lodsb  ; 0x04E0  ac
         cmp al,0xf0  ; 0x04E1  3c f0
         jnz L4F3  ; 0x04E3  75 0e
         call L4FD  ; 0x04E5  e8 15 00
L4E8:    lodsb  ; 0x04E8  ac
         db 0x8A, 0xD8  ; mov bl,al  (0x04E9 raw)
         call L4FD  ; 0x04EB  e8 0f 00
         cmp bl,0xf7  ; 0x04EE  80 fb f7
         jnz L4E8  ; 0x04F1  75 f5
L4F3:    pop bx  ; 0x04F3  5b
         db 0x8B, 0xC6  ; mov ax,si  (0x04F4 raw)
         db 0x2B, 0xC3  ; sub ax,bx  (0x04F6 raw)
         pop ds  ; 0x04F8  1f
         pop si  ; 0x04F9  5e
         pop bx  ; 0x04FA  5b
         pop bp  ; 0x04FB  5d
         ret  ; 0x04FC  c3
L4FD:    push cx  ; 0x04FD  51
         push dx  ; 0x04FE  52
         mov cx,0x800  ; 0x04FF  b9 00 08
         mov dx,cs:[0x170]  ; 0x0502  2e 8b 16 70 01
         db 0x8A, 0xE0  ; mov ah,al  (0x0507 raw)
L509:    in al,dx  ; 0x0509  ec
         test al,0x40  ; 0x050A  a8 40
         jnz L51D  ; 0x050C  75 0f
         dec dx  ; 0x050E  4a
         db 0x8A, 0xC4  ; mov al,ah  (0x050F raw)
         out dx,al  ; 0x0511  ee
         inc dx  ; 0x0512  42
         mov cx,0xa  ; 0x0513  b9 0a 00
L516:    in al,dx  ; 0x0516  ec
         loop L516  ; 0x0517  e2 fd
         db 0x33, 0xC0  ; xor ax,ax  (0x0519 raw)
         jmp short L526  ; 0x051B  eb 09
L51D:    test al,0x80  ; 0x051D  a8 80
         jnz L524  ; 0x051F  75 03
         dec dx  ; 0x0521  4a
         in al,dx  ; 0x0522  ec
         inc dx  ; 0x0523  42
L524:    loop L509  ; 0x0524  e2 e3
L526:    db 0x0B, 0xC9  ; or cx,cx  (0x0526 raw)
         jnz L52C  ; 0x0528  75 02
         mov al,0xff  ; 0x052A  b0 ff
L52C:    pop dx  ; 0x052C  5a
         pop cx  ; 0x052D  59
         ret  ; 0x052E  c3
L52F:    push cx  ; 0x052F  51
         push dx  ; 0x0530  52
         mov cx,0x800  ; 0x0531  b9 00 08
         mov dx,cs:[0x170]  ; 0x0534  2e 8b 16 70 01
         db 0x8A, 0xE0  ; mov ah,al  (0x0539 raw)
L53B:    in al,dx  ; 0x053B  ec
         test al,0x40  ; 0x053C  a8 40
         jnz L547  ; 0x053E  75 07
         db 0x8A, 0xC4  ; mov al,ah  (0x0540 raw)
         out dx,al  ; 0x0542  ee
         db 0x33, 0xC0  ; xor ax,ax  (0x0543 raw)
         jmp short L549  ; 0x0545  eb 02
L547:    loop L53B  ; 0x0547  e2 f2
L549:    db 0x0B, 0xC9  ; or cx,cx  (0x0549 raw)
         jnz L550  ; 0x054B  75 03
         mov ax,0xffff  ; 0x054D  b8 ff ff
L550:    pop dx  ; 0x0550  5a
         pop cx  ; 0x0551  59
         ret  ; 0x0552  c3
L553:    push cx  ; 0x0553  51
         push dx  ; 0x0554  52
         mov cx,0x800  ; 0x0555  b9 00 08
         mov dx,cs:[0x170]  ; 0x0558  2e 8b 16 70 01
L55D:    in al,dx  ; 0x055D  ec
         test al,0x80  ; 0x055E  a8 80
         jnz L568  ; 0x0560  75 06
         dec dx  ; 0x0562  4a
         in al,dx  ; 0x0563  ec
         db 0x32, 0xE4  ; xor ah,ah  (0x0564 raw)
         jmp short L56A  ; 0x0566  eb 02
L568:    loop L55D  ; 0x0568  e2 f3
L56A:    db 0x0B, 0xC9  ; or cx,cx  (0x056A raw)
         jnz L571  ; 0x056C  75 03
         mov ax,0xffff  ; 0x056E  b8 ff ff
L571:    pop dx  ; 0x0571  5a
         pop cx  ; 0x0572  59
         ret  ; 0x0573  c3
L574:    push ax  ; 0x0574  50
         push cx  ; 0x0575  51
         push dx  ; 0x0576  52
         mov cx,0x200  ; 0x0577  b9 00 02
         mov dx,cs:[0x170]  ; 0x057A  2e 8b 16 70 01
         in al,dx  ; 0x057F  ec
         dec dx  ; 0x0580  4a
L581:    in al,dx  ; 0x0581  ec
         loop L581  ; 0x0582  e2 fd
         inc dx  ; 0x0584  42
         in al,dx  ; 0x0585  ec
         pop dx  ; 0x0586  5a
         pop cx  ; 0x0587  59
         pop ax  ; 0x0588  58
         ret  ; 0x0589  c3
L58A:    push bp  ; 0x058A  55
         db 0x8B, 0xEC  ; mov bp,sp  (0x058B raw)
         mov ax,[bp+0x6]  ; 0x058D  8b 46 06
         mov cx,[bp+0xa]  ; 0x0590  8b 4e 0a
         db 0x0B, 0xC8  ; or cx,ax  (0x0593 raw)
         mov cx,[bp+0x8]  ; 0x0595  8b 4e 08
         jnz L5A3  ; 0x0598  75 09
         mov ax,[bp+0x4]  ; 0x059A  8b 46 04
         mul cx  ; 0x059D  f7 e1
         pop bp  ; 0x059F  5d
         ret word 0x8  ; 0x05A0  c2 08 00
L5A3:    push bx  ; 0x05A3  53
         mul cx  ; 0x05A4  f7 e1
         db 0x8B, 0xD8  ; mov bx,ax  (0x05A6 raw)
         mov ax,[bp+0x4]  ; 0x05A8  8b 46 04
         mul word [bp+0xa]  ; 0x05AB  f7 66 0a
         db 0x03, 0xD8  ; add bx,ax  (0x05AE raw)
         mov ax,[bp+0x4]  ; 0x05B0  8b 46 04
         mul cx  ; 0x05B3  f7 e1
         db 0x03, 0xD3  ; add dx,bx  (0x05B5 raw)
         pop bx  ; 0x05B7  5b
         pop bp  ; 0x05B8  5d
         ret word 0x8  ; 0x05B9  c2 08 00
L5BC:    push ax  ; 0x05BC  50
         push si  ; 0x05BD  56
         mov al,0x5  ; 0x05BE  b0 05
         db 0x90, 0x90, 0x90  ; 0x05C0  nop x3（原 call L52F：向 331 发 0x05，UART 下被忽略，无用）
         mov si,0x0  ; 0x05C3  be 00 00
L5C6:    db 0x8B, 0xC6  ; mov ax,si  (0x05C6 raw)
         or al,0xb0  ; 0x05C8  0c b0
         call L4FD  ; 0x05CA  e8 30 ff
         mov al,0x7b  ; 0x05CD  b0 7b
         call L4FD  ; 0x05CF  e8 2b ff
         mov ax,0x0  ; 0x05D2  b8 00 00
         call L4FD  ; 0x05D5  e8 25 ff
         mov al,0xd0  ; 0x05D8  b0 d0
         db 0x90, 0x90, 0x90  ; 0x05DA  nop x3（原 call L52F：向 331 发 0xD0，UART 下被忽略，无用）
         db 0x8B, 0xC6  ; mov ax,si  (0x05DD raw)
         or al,0xb0  ; 0x05DF  0c b0
         call L4FD  ; 0x05E1  e8 19 ff  (修复3: 数据口)
         mov al,0x40  ; 0x05E4  b0 40
         call L4FD  ; 0x05E6  e8 14 ff  (修复3: 数据口)
         mov ax,0x0  ; 0x05E9  b8 00 00
         call L4FD  ; 0x05EC  e8 0e ff  (修复3: 数据口)
         inc si  ; 0x05EF  46
         cmp si,0x10  ; 0x05F0  83 fe 10
         jnz L5C6  ; 0x05F3  75 d1
         pop si  ; 0x05F5  5e
         pop ax  ; 0x05F6  58
         ret  ; 0x05F7  c3
L5F8:    push bx  ; 0x05F8  53
         push si  ; 0x05F9  56
         push di  ; 0x05FA  57
         push es  ; 0x05FB  06
         inc dx  ; 0x05FC  42
         mov cs:[0x170],dx  ; 0x05FD  2e 89 16 70 01
         call cc64_setup  ; 0x0602  e8 xx xx (原 call L4BA，初始化例程内部先做 UART 初始化)
         db 0x33, 0xC9  ; xor cx,cx  (0x0605 raw)
L607:    db 0x8B, 0xD9  ; mov bx,cx  (0x0607 raw)
         shl bx,1  ; 0x0609  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x060B  2e 8b 9f 56 01
         mov word cs:[bx+0x8],0x0  ; 0x0610  2e c7 47 08 00 00
         inc cx  ; 0x0616  41
         cmp cx,0x3  ; 0x0617  83 f9 03
         jnz L607  ; 0x061A  75 eb
         db 0x33, 0xC9  ; xor cx,cx  (0x061C raw)
L61E:    mov al,0xb0  ; 0x061E  b0 b0
         db 0x0A, 0xC1  ; or al,cl  (0x0620 raw)
         call L4FD  ; 0x0622  e8 d8 fe
         mov al,0x7b  ; 0x0625  b0 7b
         call L4FD  ; 0x0627  e8 d3 fe
         mov al,0x0  ; 0x062A  b0 00
         call L4FD  ; 0x062C  e8 ce fe
         inc cx  ; 0x062F  41
         cmp cx,0x10  ; 0x0630  83 f9 10
         jnz L61E  ; 0x0633  75 e9
         call L91D  ; 0x0635  e8 e5 02
         pop es  ; 0x0638  07
         pop di  ; 0x0639  5f
         pop si  ; 0x063A  5e
         pop bx  ; 0x063B  5b
         ret  ; 0x063C  c3
L63D:    push bx  ; 0x063D  53
         push cx  ; 0x063E  51
         push dx  ; 0x063F  52
         push si  ; 0x0640  56
         push di  ; 0x0641  57
         shl bx,1  ; 0x0642  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x0644  2e 8b 9f 56 01
         cmp word cs:[bx+0x8],0x0  ; 0x0649  2e 83 7f 08 00
         jnz L759  ; 0x064E  0f 85 07 01
         push si  ; 0x0652  56
         mov si,0x0  ; 0x0653  be 00 00
L656:    mov byte cs:[bx+si+0x26],0x0  ; 0x0656  2e c6 40 26 00
         inc si  ; 0x065B  46
         cmp si,0x10  ; 0x065C  83 fe 10
         jnz L656  ; 0x065F  75 f5
         pop si  ; 0x0661  5e
         mov cs:[bx+0x41],ch  ; 0x0662  2e 88 6f 41
         mov cs:[bx+0x4],di  ; 0x0666  2e 89 7f 04
         mov word cs:[bx+0x6],es  ; 0x066A  2e 8c 47 06
         mov cs:[bx],si  ; 0x066E  2e 89 37
         mov cs:[bx+0x2],dx  ; 0x0671  2e 89 57 02
         call L242  ; 0x0675  e8 ca fb
         mov al,cs:[bx+0x3e]  ; 0x0678  2e 8a 47 3e
         mov cs:[bx+0x3d],al  ; 0x067C  2e 88 47 3d
         db 0x0A, 0xC9  ; or cl,cl  (0x0680 raw)
         jnz L698  ; 0x0682  75 14
         mov word cs:[bx+0xa],0x0  ; 0x0684  2e c7 47 0a 00 00
         mov byte cs:[bx+0x36],0x0  ; 0x068A  2e c6 47 36 00
         mov word cs:[bx+0x8],0x1  ; 0x068F  2e c7 47 08 01 00
         jmp near L754  ; 0x0695  e9 bc 00
L698:    cmp cl,0x1  ; 0x0698  80 f9 01
         jnz L6B1  ; 0x069B  75 14
         mov word cs:[bx+0xa],0x1  ; 0x069D  2e c7 47 0a 01 00
         mov byte cs:[bx+0x36],0x0  ; 0x06A3  2e c6 47 36 00
         mov word cs:[bx+0x8],0x1  ; 0x06A8  2e c7 47 08 01 00
         jmp near L754  ; 0x06AE  e9 a3 00
L6B1:    cmp cl,0x2  ; 0x06B1  80 f9 02
         jnz L6CF  ; 0x06B4  75 19
         mov word cs:[bx+0xa],0x0  ; 0x06B6  2e c7 47 0a 00 00
         mov byte cs:[bx+0x36],0x1  ; 0x06BC  2e c6 47 36 01
         mov byte cs:[bx+0x3d],0x0  ; 0x06C1  2e c6 47 3d 00
         mov word cs:[bx+0x8],0x1  ; 0x06C6  2e c7 47 08 01 00
         jmp near L754  ; 0x06CC  e9 85 00
L6CF:    cmp cl,0x3  ; 0x06CF  80 f9 03
         jnz L6EC  ; 0x06D2  75 18
         mov word cs:[bx+0xa],0x1  ; 0x06D4  2e c7 47 0a 01 00
         mov byte cs:[bx+0x36],0x1  ; 0x06DA  2e c6 47 36 01
         mov byte cs:[bx+0x3d],0x0  ; 0x06DF  2e c6 47 3d 00
         mov word cs:[bx+0x8],0x1  ; 0x06E4  2e c7 47 08 01 00
         jmp short L754  ; 0x06EA  eb 68
L6EC:    cmp cl,0x4  ; 0x06EC  80 f9 04
         jnz L704  ; 0x06EF  75 13
         mov word cs:[bx+0xa],0x2  ; 0x06F1  2e c7 47 0a 02 00
         mov byte cs:[bx+0x36],0x0  ; 0x06F7  2e c6 47 36 00
         mov word cs:[bx+0x8],0x1  ; 0x06FC  2e c7 47 08 01 00
         jmp short L754  ; 0x0702  eb 50
L704:    cmp cl,0x5  ; 0x0704  80 f9 05
         jnz L71C  ; 0x0707  75 13
         mov word cs:[bx+0xa],0x3  ; 0x0709  2e c7 47 0a 03 00
         mov byte cs:[bx+0x36],0x0  ; 0x070F  2e c6 47 36 00
         mov word cs:[bx+0x8],0x1  ; 0x0714  2e c7 47 08 01 00
         jmp short L754  ; 0x071A  eb 38
L71C:    cmp cl,0x6  ; 0x071C  80 f9 06
         jnz L739  ; 0x071F  75 18
         mov word cs:[bx+0xa],0x2  ; 0x0721  2e c7 47 0a 02 00
         mov byte cs:[bx+0x36],0x1  ; 0x0727  2e c6 47 36 01
         mov byte cs:[bx+0x3d],0x0  ; 0x072C  2e c6 47 3d 00
         mov word cs:[bx+0x8],0x1  ; 0x0731  2e c7 47 08 01 00
         jmp short L754  ; 0x0737  eb 1b
L739:    cmp cl,0x7  ; 0x0739  80 f9 07
         jnz L754  ; 0x073C  75 16
         mov word cs:[bx+0xa],0x3  ; 0x073E  2e c7 47 0a 03 00
         mov byte cs:[bx+0x36],0x1  ; 0x0744  2e c6 47 36 01
         mov byte cs:[bx+0x3d],0x0  ; 0x0749  2e c6 47 3d 00
         mov word cs:[bx+0x8],0x1  ; 0x074E  2e c7 47 08 01 00
L754:    mov ax,0x0  ; 0x0754  b8 00 00
         jmp short L75C  ; 0x0757  eb 03
L759:    mov ax,0xffff  ; 0x0759  b8 ff ff
L75C:    pop di  ; 0x075C  5f
         pop si  ; 0x075D  5e
         pop dx  ; 0x075E  5a
         pop cx  ; 0x075F  59
         pop bx  ; 0x0760  5b
         ret  ; 0x0761  c3
L762:    push ax  ; 0x0762  50
         push bx  ; 0x0763  53
         shl bx,1  ; 0x0764  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x0766  2e 8b 9f 56 01
         db 0x0B, 0xC9  ; or cx,cx  (0x076B raw)
         jnz L77A  ; 0x076D  75 0b
         mov word cs:[bx+0x8],0x0  ; 0x076F  2e c7 47 08 00 00
         call L5BC  ; 0x0775  e8 44 fe
         jmp short L7BE  ; 0x0778  eb 44
L77A:    cmp cx,0x1  ; 0x077A  83 f9 01
         jnz L78E  ; 0x077D  75 0f
         mov al,cs:[bx+0x3e]  ; 0x077F  2e 8a 47 3e
         mov cs:[bx+0x3d],al  ; 0x0783  2e 88 47 3d
         mov byte cs:[bx+0x36],0xff  ; 0x0787  2e c6 47 36 ff
         jmp short L7BE  ; 0x078C  eb 30
L78E:    cmp cx,0x2  ; 0x078E  83 f9 02
         jnz L7A5  ; 0x0791  75 12
         mov word cs:[bx+0xa],0x0  ; 0x0793  2e c7 47 0a 00 00
L799:    cmp word cs:[bx+0x8],0x0  ; 0x0799  2e 83 7f 08 00
         jnz L799  ; 0x079E  75 f9
         call L5BC  ; 0x07A0  e8 19 fe
         jmp short L7BE  ; 0x07A3  eb 19
L7A5:    cmp cx,0x3  ; 0x07A5  83 f9 03
         jnz L7BE  ; 0x07A8  75 14
         mov al,cs:[bx+0x3e]  ; 0x07AA  2e 8a 47 3e
         mov cs:[bx+0x3d],al  ; 0x07AE  2e 88 47 3d
         mov byte cs:[bx+0x36],0xff  ; 0x07B2  2e c6 47 36 ff
L7B7:    cmp word cs:[bx+0x8],0x0  ; 0x07B7  2e 83 7f 08 00
         jnz L7B7  ; 0x07BC  75 f9
L7BE:    pop bx  ; 0x07BE  5b
         pop ax  ; 0x07BF  58
         ret  ; 0x07C0  c3
L7C1:    push bx  ; 0x07C1  53
         db 0x8B, 0xC3  ; mov ax,bx  (0x07C2 raw)
         shl bx,1  ; 0x07C4  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x07C6  2e 8b 9f 56 01
         cmp byte cs:[bx+0x36],0x0  ; 0x07CB  2e 80 7f 36 00
         jnz L7E8  ; 0x07D0  75 16
         mov cs:[bx+0x3e],dl  ; 0x07D2  2e 88 57 3e
         mov cs:[bx+0x3d],dl  ; 0x07D6  2e 88 57 3d
         mov dx,cs:[bx+0x37]  ; 0x07DA  2e 8b 57 37
         db 0x8B, 0xD8  ; mov bx,ax  (0x07DE raw)
         call L869  ; 0x07E0  e8 86 00
         mov ax,0x0  ; 0x07E3  b8 00 00
         jmp short L7EB  ; 0x07E6  eb 03
L7E8:    mov ax,0xffff  ; 0x07E8  b8 ff ff
L7EB:    pop bx  ; 0x07EB  5b
         ret  ; 0x07EC  c3
L7ED:    push bx  ; 0x07ED  53
         shl bx,1  ; 0x07EE  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x07F0  2e 8b 9f 56 01
         cmp word cs:[bx+0x8],0x0  ; 0x07F5  2e 83 7f 08 00
         jz L81C  ; 0x07FA  74 20
         mov ax,0x2710  ; 0x07FC  b8 10 27
         db 0x3B, 0xD0  ; cmp dx,ax  (0x07FF raw)
         jg L817  ; 0x0801  7f 14
         neg ax  ; 0x0803  f7 d8
         db 0x3B, 0xD0  ; cmp dx,ax  (0x0805 raw)
         jl L812  ; 0x0807  7c 09
         mov cs:[bx+0x18],dx  ; 0x0809  2e 89 57 18
         mov ax,0x0  ; 0x080D  b8 00 00
         jmp short L81F  ; 0x0810  eb 0d
L812:    mov ax,0xffff  ; 0x0812  b8 ff ff
         jmp short L81F  ; 0x0815  eb 08
L817:    mov ax,0xffff  ; 0x0817  b8 ff ff
         jmp short L81F  ; 0x081A  eb 03
L81C:    mov ax,0xffff  ; 0x081C  b8 ff ff
L81F:    pop bx  ; 0x081F  5b
         ret  ; 0x0820  c3
L821:    shl bx,1  ; 0x0821  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x0823  2e 8b 9f 56 01
         cmp word cs:[bx+0x8],0x0  ; 0x0828  2e 83 7f 08 00
         jna L865  ; 0x082D  76 36
         db 0x0B, 0xC9  ; or cx,cx  (0x082F raw)
         jnz L844  ; 0x0831  75 11
         xor word cs:[bx+0x8],0x3  ; 0x0833  2e 83 77 08 03
         cmp word cs:[bx+0x8],0x2  ; 0x0838  2e 83 7f 08 02
         jnz L85F  ; 0x083D  75 20
         call L5BC  ; 0x083F  e8 7a fd
         jmp short L85F  ; 0x0842  eb 1b
L844:    cmp cx,0x1  ; 0x0844  83 f9 01
         jnz L851  ; 0x0847  75 08
         mov word cs:[bx+0x8],0x1  ; 0x0849  2e c7 47 08 01 00
         jmp short L85F  ; 0x084F  eb 0e
L851:    cmp cx,0x2  ; 0x0851  83 f9 02
         jnz L85F  ; 0x0854  75 09
         mov word cs:[bx+0x8],0x2  ; 0x0856  2e c7 47 08 02 00
         call L5BC  ; 0x085C  e8 5d fd
L85F:    mov ax,cs:[bx+0x8]  ; 0x085F  2e 8b 47 08
         jmp short L868  ; 0x0863  eb 03
L865:    mov ax,0xffff  ; 0x0865  b8 ff ff
L868:    ret  ; 0x0868  c3
L869:    push bx  ; 0x0869  53
         push cx  ; 0x086A  51
         push dx  ; 0x086B  52
         shl bx,1  ; 0x086C  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x086E  2e 8b 9f 56 01
         cmp byte cs:[bx+0x36],0x0  ; 0x0873  2e 80 7f 36 00
         jnz L8A0  ; 0x0878  75 26
         mov cs:[bx+0x37],dx  ; 0x087A  2e 89 57 37
         db 0x8B, 0xC2  ; mov ax,dx  (0x087E raw)
         mov cx,0x64  ; 0x0880  b9 64 00
         mul cx  ; 0x0883  f7 e1
         db 0x32, 0xED  ; xor ch,ch  (0x0885 raw)
         mov cl,cs:[bx+0x3e]  ; 0x0887  2e 8a 4f 3e
         db 0x0B, 0xC9  ; or cx,cx  (0x088B raw)
         jnz L895  ; 0x088D  75 06
         db 0x33, 0xC0  ; xor ax,ax  (0x088F raw)
         db 0x33, 0xD2  ; xor dx,dx  (0x0891 raw)
         jmp short L897  ; 0x0893  eb 02
L895:    div cx  ; 0x0895  f7 f1
L897:    mov cs:[bx+0x39],ax  ; 0x0897  2e 89 47 39
         mov ax,0x0  ; 0x089B  b8 00 00
         jmp short L8A3  ; 0x089E  eb 03
L8A0:    mov ax,0xffff  ; 0x08A0  b8 ff ff
L8A3:    pop dx  ; 0x08A3  5a
         pop cx  ; 0x08A4  59
         pop bx  ; 0x08A5  5b
         ret  ; 0x08A6  c3
L8A7:    shl bx,1  ; 0x08A7  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x08A9  2e 8b 9f 56 01
         cmp word cs:[bx+0x8],0x0  ; 0x08AE  2e 83 7f 08 00
         jz L8C3  ; 0x08B3  74 0e
         mov ax,cs:[bx+0x20]  ; 0x08B5  2e 8b 47 20
         mov cx,cs:[bx+0x24]  ; 0x08B9  2e 8b 4f 24
         mov bx,cs:[bx+0x22]  ; 0x08BD  2e 8b 5f 22
         jmp short L8C6  ; 0x08C1  eb 03
L8C3:    mov ax,0xffff  ; 0x08C3  b8 ff ff
L8C6:    ret  ; 0x08C6  c3
L8C7:    push bx  ; 0x08C7  53
         shl bx,1  ; 0x08C8  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x08CA  2e 8b 9f 56 01
         mov ax,cs:[bx+0x8]  ; 0x08CF  2e 8b 47 08
         pop bx  ; 0x08D3  5b
         ret  ; 0x08D4  c3
L8D5:    push bx  ; 0x08D5  53
         shl bx,1  ; 0x08D6  d1 e3
         mov bx,cs:[bx+0x156]  ; 0x08D8  2e 8b 9f 56 01
         cmp word cs:[bx+0x8],0x0  ; 0x08DD  2e 83 7f 08 00
         jz L918  ; 0x08E2  74 34
         db 0x0B, 0xC9  ; or cx,cx  (0x08E4 raw)
         jnz L8F8  ; 0x08E6  75 10
         neg word cs:[bx+0x8]  ; 0x08E8  2e f7 5f 08
         cmp word cs:[bx+0x8],0xffffffffffffffff  ; 0x08EC  2e 83 7f 08 ff
         jnz L913  ; 0x08F1  75 20
         call L5BC  ; 0x08F3  e8 c6 fc
         jmp short L913  ; 0x08F6  eb 1b
L8F8:    cmp cx,0x1  ; 0x08F8  83 f9 01
         jnz L908  ; 0x08FB  75 0b
         mov word cs:[bx+0x8],0xffff  ; 0x08FD  2e c7 47 08 ff ff
         call L5BC  ; 0x0903  e8 b6 fc
         jmp short L913  ; 0x0906  eb 0b
L908:    cmp cx,0x2  ; 0x0908  83 f9 02
         jnz L913  ; 0x090B  75 06
         mov word cs:[bx+0x8],0x1  ; 0x090D  2e c7 47 08 01 00
L913:    mov ax,0x0  ; 0x0913  b8 00 00
         jmp short L91B  ; 0x0916  eb 03
L918:    mov ax,0xffff  ; 0x0918  b8 ff ff
L91B:    pop bx  ; 0x091B  5b
         ret  ; 0x091C  c3
L91D:    push ax  ; 0x091D  50
         push bx  ; 0x091E  53
         push es  ; 0x091F  06
         mov ax,0x4300  ; 0x0920  b8 00 43
         int 0x2f  ; 0x0923  cd 2f
         cmp al,0x80  ; 0x0925  3c 80
         jnz L938  ; 0x0927  75 0f
         mov ax,0x4310  ; 0x0929  b8 10 43
         int 0x2f  ; 0x092C  cd 2f
         mov cs:[0x172],bx  ; 0x092E  2e 89 1e 72 01
         mov word cs:[0x174],es  ; 0x0933  2e 8c 06 74 01
L938:    pop es  ; 0x0938  07
         pop bx  ; 0x0939  5b
         pop ax  ; 0x093A  58
         ret  ; 0x093B  c3
         push ax  ; 0x093C  50
         push bx  ; 0x093D  53
         push cx  ; 0x093E  51
         push di  ; 0x093F  57
         push si  ; 0x0940  56
         push es  ; 0x0941  06
         push ds  ; 0x0942  1e
         pop ds  ; 0x0943  1f
         pop es  ; 0x0944  07
         pop si  ; 0x0945  5e
         pop di  ; 0x0946  5f
         pop cx  ; 0x0947  59
         pop bx  ; 0x0948  5b
         pop ax  ; 0x0949  58
         ret  ; 0x094A  c3
L94B:    cmp al,0x1  ; 0x094B  3c 01
         jnz L967  ; 0x094D  75 18
         mov cs:[bx+0x4c],si  ; 0x094F  2e 89 77 4c
         db 0x66, 0x2E, 0xC7, 0x47, 0x4E, 0x00, 0x00, 0x00, 0x00  ; mov dword cs:[bx+0x4e],0x0  (0x0953 raw)
         mov si,SONG_BUFFER  ; 0x095C  be ad 09
         mov cs:[bx+0x54],si  ; 0x095F  2e 89 77 54
         mov word cs:[bx+0x56],cs  ; 0x0963  2e 8c 4f 56
L967:    push cs  ; 0x0967  0e
         pop ds  ; 0x0968  1f
         mov si,SONG_BUFFER  ; 0x0969  be ad 09
         ret  ; 0x096C  c3
         push ax  ; 0x096D  50
         push dx  ; 0x096E  52
         pop dx  ; 0x096F  5a
         pop ax  ; 0x0970  58
         ret  ; 0x0971  c3
         push ax  ; 0x0972  50
         push dx  ; 0x0973  52
         pop dx  ; 0x0974  5a
         pop ax  ; 0x0975  58
         ret  ; 0x0976  c3
L977:    cmp al,0x1  ; 0x0977  3c 01
         jnz L984  ; 0x0979  75 09
         db 0x66, 0x2E, 0xC7, 0x47, 0x4E, 0x00, 0x00, 0x00, 0x00  ; mov dword cs:[bx+0x4e],0x0  (0x097B raw)
L984:    ret  ; 0x0984  c3
L985:    push eax  ; 0x0985  66 50
         push bx  ; 0x0987  53
         push ds  ; 0x0988  1e
         sub si,SONG_BUFFER  ; 0x0989  81 ee ad 09
         cmp al,0x1  ; 0x098D  3c 01
         jnz L9A5  ; 0x098F  75 14
         db 0x66, 0x33, 0xC0  ; xor eax,eax  (0x0991 raw)
         db 0x8B, 0xC6  ; mov ax,si  (0x0994 raw)
         db 0x66, 0x2E, 0x01, 0x47, 0x4E  ; add cs:[bx+0x4e],eax  (0x0996 raw)
         lea si,[bx+0x48]  ; 0x099B  8d 77 48
         mov ah,0xb  ; 0x099E  b4 0b
         call word far cs:[0x172]  ; 0x09A0  2e ff 1e 72 01
L9A5:    mov si,SONG_BUFFER  ; 0x09A5  be ad 09
         pop ds  ; 0x09A8  1f
         pop bx  ; 0x09A9  5b
         pop eax  ; 0x09AA  66 58
         ret  ; 0x09AC  c3

; ============ 修复1: Pitch Bend 补发 MSB (0x9B0) ============
; 原处理器读 MSB 后不发送，此例程补发
times (PB_HANDLER - ($-$$)) db 0
pb_fix:
         call L4FD          ; 发 status
         lodsb
         call L4FD          ; 发 LSB
         lodsb
         call L4FD          ; 发 MSB（原来丢掉）
         ret

; ============ 修复2: SysEx 剥 SMF 长度 (0x9C0) ============
; 原例程从 F0 起逐字节发到 F7，把 SMF 长度也发了；
; 此例程发 F0 → 跳过完整 VLQ 长度 → 发负载直到 F7
times (SX_HANDLER - ($-$$)) db 0
sx_fix:
         cmp al, 0xf0
         jnz near L490       ; F1/F2/F3 走原路径
         dec si
         mov di, si          ; 记起点
         lodsb
         call L4FD           ; 发 F0
.skip_vlq:
         lodsb
         test al, 0x80
         jnz .skip_vlq       ; 跳过 VLQ 多字节长度
.send_payload:
         lodsb
         mov bl, al
         call L4FD
         cmp bl, 0xf7
         jnz .send_payload   ; 循环到 F7
         mov ax, si
         sub ax, di          ; 返回消耗字节数
         ret

; ============ CC64 归一化 / 透传 (0x1000) ============
; SUSPAN_FLAG = 1 → CC64 原样透传（保留原始值）
; SUSPAN_FLAG = 0 → CC64 <64 归 0、>=64 归 127（GM/GS/XG 规范开关，默认）
times (CC_FIX - ($-$$)) db 0
cc_fix:
         call L4FD           ; 发 status
         lodsb               ; controller
         mov cl, al          ; 保存（CL 在 L4FD 中存活）
         call L4FD           ; 发 controller
         lodsb               ; value
         cmp cl, 0x40        ; CC64 Damper Pedal?
         jne .send
         cmp byte cs:[SUSPAN_FLAG], 0
         jne .send           ; 强制透传
         cmp al, 64
         jb .zero
         mov al, 127
         jmp .send
.zero:
         xor al, al
.send:
         call L4FD           ; 发 value
         ret

; ============ CC64 模式初始化 (0x1030) ============
; 在初始化最前面调用（替换原 call L4BA）；内部先做 UART 初始化。
; 若当前目录存在 SUSSPAN 文件 → SUSPAN_FLAG=1（CC64 透传）；
; 否则 SUSPAN_FLAG=0（默认归一化 0/127，GM/GS/XG 规范开关）。
; 注意：文件检查用 DOS INT 21h FindFirst，若此路径运行在 ISR 上下文
; 存在重入风险——强制开关本来就是给"不想默认归一化"的场景用的。
times (CC64_SETUP - ($-$$)) db 0
cc64_setup:
         call L4BA           ; 原 UART 初始化（排空 + 0x3F + flush）
         push ax
         push bx
         push cx
         push dx
         push si
         push di
         ; --- 强制透传开关：存在 SUSSPAN 文件 → 保留 CC64 原始值 ---
         push ds             ; 临时保存/恢复 DS，不占主栈槽位
         push cs
         pop ds
         mov ah,0x4e         ; DOS FindFirst
         xor cx,cx           ; 普通文件
         mov dx,SUSSPAN_NAME
         int 0x21
         pop ds
         jc .normalize       ; 无文件 → 默认归一化
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

; ============ 模式标志数据 (0x1180) ============
; 初始化运行在 ISR 上下文，除 SUSSPAN 文件检查外不做文件 I/O（无日志）
times (CC64_DATA - ($-$$)) db 0
SUSPAN_FLAG: db 0             ; 0 = CC64 归一化 0/127（默认）, 1 = 透传
SUSSPAN_NAME: db "susspan", 0 ; 存在则强制 CC64 透传

; ============ 填充剩余空间到 SONG_BUFFER ============
times (SONG_BUFFER - ($-$$)) db 0

; ---------------- 0x2000-0x21FF: 歌曲数据缓冲 ----------------
song_buffer: times 512 db 0


; ==============================================================================
;  ROLRIX.EXE  -  complete 16-bit x86 disassembly
;  rebuildable with NASM into a BYTE-IDENTICAL copy of the original EXE
;
;  Original binary : MS-DOS MZ executable, Borland C++ (large model)
;  File size       : 22656 bytes  (MZ header + 257 relocations + load image)
;  Load image      : 21600 bytes, image offsets 0x0000 .. 0x545F
;  Entry point     : CS:IP = 0000:02CF   (image offset 0x02CF)
;  Initial stack   : SS:SP = 153B:4000
;
;  Build :  nasm -f bin ROLRIX.ASM -o ROLRIX_REBUILT.EXE
;  Check :  cmp ROLRIX_REBUILT.EXE ROLRIX.EXE
;
;  File layout
;    file   0x0000 - 0x041F   MZ header + relocation table (1056 bytes)
;    file   0x0420 -           load image, mapped by DOS at the load segment
;      image 0x0000 - 0x15AF   the application itself
;                              0x0000 header/entry code
;                              0x0135 literal strings used by the program
;                              0x02CF C startup, main(), helpers
;      image 0x15B0 - 0x545F   Borland C runtime, its tables and literals
;
;  Conventions in this listing
;    func_XXXX  a real entry point (call target / startup / far-call target)
;    loc_XXXX   a branch target inside a function
;    each instruction line ends with the ORIGINAL machine bytes in []
;    `db` lines are byte-for-byte original data, or (rarely) an instruction
;    whose original encoding NASM cannot reproduce; the intended mnemonic is
;    given in the trailing comment.
; ==============================================================================

BITS 16
ORG 0

SECTION mz_header start=0
mz_header:
    dw 'MZ'    ; sig       = 23117  MZ signature  4D 5A ("MZ")
    dw 0x0080  ; lastpage  = 128    bytes used in last 512-byte page
    dw 0x002D  ; pagecnt   = 45     file size in 512-byte pages, including header
    dw 0x0101  ; nrel      = 257    number of relocation entries
    dw 0x0042  ; cparhdr   = 66     header size, in 16-byte paragraphs
    dw 0x13F5  ; minalloc  = 5109   minimum extra paragraphs the program needs
    dw 0xB3F5  ; maxalloc  = 46069  maximum extra paragraphs the program wants
    dw 0x153B  ; ss        = 5435   initial SS, relative to the load segment
    dw 0x4000  ; sp        = 16384  initial SP
    dw 0x0000  ; csum      = 0      checksum (0 = not used)
    dw 0x02CF  ; ip        = 719    initial IP
    dw 0x0000  ; cs        = 0      initial CS, relative to the load segment
    dw 0x001C  ; reloff    = 28     file offset of the relocation table
    dw 0x0000  ; ovl       = 0      overlay number (0 = main image)

    ; ---- relocation table: 257 entries of (offset, segment) ----
    ; At load time DOS adds the load segment to the 16-bit word at
    ; (segment field * 16 + offset field) inside the image.
    dw 0x0009,0x0000, 0x0015,0x0000, 0x004B,0x0000, 0x0063,0x0000; #000..003
    dw 0x0083,0x0000, 0x00CF,0x0000, 0x00EA,0x0000, 0x0120,0x0000; #004..007
    dw 0x02D2,0x0000, 0x02D7,0x0000, 0x02E2,0x0000, 0x02F3,0x0000; #008..011
    dw 0x02F8,0x0000, 0x030A,0x0000, 0x030F,0x0000, 0x0314,0x0000; #012..015
    dw 0x0326,0x0000, 0x032B,0x0000, 0x0330,0x0000, 0x033F,0x0000; #016..019
    dw 0x0359,0x0000, 0x035E,0x0000, 0x0363,0x0000, 0x0376,0x0000; #020..023
    dw 0x037B,0x0000, 0x0380,0x0000, 0x0391,0x0000, 0x039F,0x0000; #024..027
    dw 0x03AE,0x0000, 0x03C8,0x0000, 0x03CD,0x0000, 0x03D2,0x0000; #028..031
    dw 0x03E5,0x0000, 0x03EA,0x0000, 0x03EF,0x0000, 0x0400,0x0000; #032..035
    dw 0x040E,0x0000, 0x0420,0x0000, 0x0430,0x0000, 0x043A,0x0000; #036..039
    dw 0x0442,0x0000, 0x0447,0x0000, 0x044C,0x0000, 0x045E,0x0000; #040..043
    dw 0x046B,0x0000, 0x0470,0x0000, 0x0475,0x0000, 0x047F,0x0000; #044..047
    dw 0x0484,0x0000, 0x0496,0x0000, 0x049B,0x0000, 0x04A0,0x0000; #048..051
    dw 0x04B2,0x0000, 0x04B7,0x0000, 0x04BC,0x0000, 0x04D1,0x0000; #052..055
    dw 0x04DB,0x0000, 0x04E0,0x0000, 0x04EE,0x0000, 0x04F3,0x0000; #056..059
    dw 0x0504,0x0000, 0x0509,0x0000, 0x0520,0x0000, 0x0525,0x0000; #060..063
    dw 0x0549,0x0000, 0x054E,0x0000, 0x055F,0x0000, 0x0564,0x0000; #064..067
    dw 0x0580,0x0000, 0x0585,0x0000, 0x05AD,0x0000, 0x05B2,0x0000; #068..071
    dw 0x05C9,0x0000, 0x05CE,0x0000, 0x05EA,0x0000, 0x05EF,0x0000; #072..075
    dw 0x0620,0x0000, 0x0625,0x0000, 0x063C,0x0000, 0x0641,0x0000; #076..079
    dw 0x0656,0x0000, 0x066C,0x0000, 0x069B,0x0000, 0x06C6,0x0000; #080..083
    dw 0x06E6,0x0000, 0x06EC,0x0000, 0x06FE,0x0000, 0x070C,0x0000; #084..087
    dw 0x0711,0x0000, 0x0716,0x0000, 0x073E,0x0000, 0x0743,0x0000; #088..091
    dw 0x0750,0x0000, 0x0755,0x0000, 0x076C,0x0000, 0x0771,0x0000; #092..095
    dw 0x079B,0x0000, 0x07A0,0x0000, 0x07B7,0x0000, 0x07BC,0x0000; #096..099
    dw 0x083B,0x0000, 0x086C,0x0000, 0x0872,0x0000, 0x0881,0x0000; #100..103
    dw 0x0886,0x0000, 0x0893,0x0000, 0x0898,0x0000, 0x08B4,0x0000; #104..107
    dw 0x08B9,0x0000, 0x08EA,0x0000, 0x08EF,0x0000, 0x0906,0x0000; #108..111
    dw 0x090B,0x0000, 0x098F,0x0000, 0x09C0,0x0000, 0x09C6,0x0000; #112..115
    dw 0x09D5,0x0000, 0x09DA,0x0000, 0x09E7,0x0000, 0x09EC,0x0000; #116..119
    dw 0x0A08,0x0000, 0x0A0D,0x0000, 0x0A3E,0x0000, 0x0A43,0x0000; #120..123
    dw 0x0A5A,0x0000, 0x0A5F,0x0000, 0x0A6F,0x0000, 0x0AEB,0x0000; #124..127
    dw 0x0B1C,0x0000, 0x0B22,0x0000, 0x0B31,0x0000, 0x0B36,0x0000; #128..131
    dw 0x0B43,0x0000, 0x0B48,0x0000, 0x0B64,0x0000, 0x0B69,0x0000; #132..135
    dw 0x0B97,0x0000, 0x0B9C,0x0000, 0x0BB3,0x0000, 0x0BB8,0x0000; #136..139
    dw 0x0BC8,0x0000, 0x0C23,0x0000, 0x0C54,0x0000, 0x0C5A,0x0000; #140..143
    dw 0x0C6F,0x0000, 0x0C74,0x0000, 0x0C8F,0x0000, 0x0C99,0x0000; #144..147
    dw 0x0C9E,0x0000, 0x0CAC,0x0000, 0x0CB1,0x0000, 0x0CCE,0x0000; #148..151
    dw 0x0CD3,0x0000, 0x0CEA,0x0000, 0x0CEF,0x0000, 0x0D06,0x0000; #152..155
    dw 0x0D0B,0x0000, 0x0D22,0x0000, 0x0D27,0x0000, 0x0D56,0x0000; #156..159
    dw 0x0D5B,0x0000, 0x0D72,0x0000, 0x0D77,0x0000, 0x0DAE,0x0000; #160..163
    dw 0x0DBF,0x0000, 0x0DD4,0x0000, 0x0DDE,0x0000, 0x0DE8,0x0000; #164..167
    dw 0x0DED,0x0000, 0x0DFB,0x0000, 0x0E00,0x0000, 0x0E11,0x0000; #168..171
    dw 0x0E23,0x0000, 0x0E33,0x0000, 0x0E3D,0x0000, 0x0E45,0x0000; #172..175
    dw 0x0E4A,0x0000, 0x0E5C,0x0000, 0x0E61,0x0000, 0x0E74,0x0000; #176..179
    dw 0x0E79,0x0000, 0x0E8E,0x0000, 0x0E98,0x0000, 0x0EA2,0x0000; #180..183
    dw 0x0EA7,0x0000, 0x0EB5,0x0000, 0x0EC9,0x0000, 0x0ECE,0x0000; #184..187
    dw 0x0EE6,0x0000, 0x0EEB,0x0000, 0x0EF5,0x0000, 0x0EFA,0x0000; #188..191
    dw 0x0F11,0x0000, 0x0F16,0x0000, 0x0F2B,0x0000, 0x0F30,0x0000; #192..195
    dw 0x0F3A,0x0000, 0x0F3F,0x0000, 0x0F4C,0x0000, 0x0F51,0x0000; #196..199
    dw 0x0F63,0x0000, 0x0F68,0x0000, 0x0F6D,0x0000, 0x0F7F,0x0000; #200..203
    dw 0x0F84,0x0000, 0x0F89,0x0000, 0x0F9B,0x0000, 0x0FAA,0x0000; #204..207
    dw 0x0FAF,0x0000, 0x0FB4,0x0000, 0x104A,0x0000, 0x1057,0x0000; #208..211
    dw 0x1066,0x0000, 0x106B,0x0000, 0x1070,0x0000, 0x10DE,0x0000; #212..215
    dw 0x10F8,0x0000, 0x10FD,0x0000, 0x1159,0x0000, 0x115E,0x0000; #216..219
    dw 0x11C3,0x0000, 0x11DD,0x0000, 0x11E2,0x0000, 0x123E,0x0000; #220..223
    dw 0x1243,0x0000, 0x12A8,0x0000, 0x12C2,0x0000, 0x12C7,0x0000; #224..227
    dw 0x1323,0x0000, 0x1328,0x0000, 0x138D,0x0000, 0x13A7,0x0000; #228..231
    dw 0x13AC,0x0000, 0x1408,0x0000, 0x140D,0x0000, 0x14B6,0x0000; #232..235
    dw 0x14BB,0x0000, 0x1507,0x0000, 0x1521,0x0000, 0x1526,0x0000; #236..239
    dw 0x1550,0x0000, 0x1555,0x0000, 0x155F,0x0000, 0x1564,0x0000; #240..243
    dw 0x156E,0x0000, 0x1573,0x0000, 0x157D,0x0000, 0x1582,0x0000; #244..247
    dw 0x1594,0x0000, 0x1599,0x0000, 0x159E,0x0000, 0x15A8,0x0000; #248..251
    dw 0x0001,0x015B, 0x00EE,0x015B, 0x07ED,0x015B, 0x37E2,0x015B; #252..255
    dw 0x381F,0x015B                                         ; #256..256

SECTION image start=1056 vstart=0

; ------------------------------------------------------------------------------
;  LOAD IMAGE BEGINS  (image offset 0 = load-segment origin)
; ------------------------------------------------------------------------------

; ---- named global variables (equ constants) ----
max_tick             equ 0x004C
event_count          equ 0x004E
psp_seg              equ 0x0086
stack_margin         equ 0x0088
dos_errno            equ 0x008A
event_table_ptr      equ 0x0092
tick                 equ 0x0242
iodata               equ 0x0244
channel              equ 0x0248
n_events             equ 0x024A
n_ticks              equ 0x024C
hdr_byte65           equ 0x0250
basic_tempo          equ 0x0252
cur_pitch            equ 0x0256
cur_duration         equ 0x0258
ev_value             equ 0x025C
ev_step              equ 0x025E
ev_pitch             equ 0x0260
ev_volume            equ 0x0262
slot_table           equ 0x02C8


; ------------------------------------------------------------------------------
;  FUNCTION  alloc_slot_table   image offset 0x0000  <- called from 0x02E8
; ------------------------------------------------------------------------------
alloc_slot_table:
    push bp                                             ; [55]
    mov bp, sp                                          ; [89 e5]
    mov ax, 0x2                                         ; [b8 02 00]
    call 0x15B:0x4DF                                    ; [9a df 04 5b 01]
    sub sp, byte 0x2                                    ; [83 ec 02]
    mov ax, 0x500                                       ; [b8 00 05]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov word [slot_table], ax                           ; [a3 c8 02]
    mov word [0x02CA], dx                               ; [89 16 ca 02]
    xor ax, ax                                          ; [31 c0]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    jmp short 0x28                                      ; [eb 03]
alloc_slot_table_l0025:
    inc word [bp-0x2]                                   ; [ff 46 fe]
alloc_slot_table_l0028:
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x2]                                   ; [f7 66 fe]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    mov byte [es:di], 0x0                               ; [26 c6 05 00]
    cmp word [bp-0x2], 0x7F                             ; [83 7e fe 7f]
    jne short 0x25                                      ; [75 e7]
    mov sp, bp                                          ; [89 ec]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  name_table_lookup   image offset 0x0042  <- called from 0x0930
; ------------------------------------------------------------------------------
name_table_lookup:
    push bp                                             ; [55]
    mov bp, sp                                          ; [89 e5]
    mov ax, 0x104                                       ; [b8 04 01]
    call 0x15B:0x4DF                                    ; [9a df 04 5b 01]
    sub sp, word 0x104                                  ; [81 ec 04 01]
    les di,  [bp+0x4]                               ; [c4 7e 04]
    push es                                             ; [06]
    push di                                             ; [57]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0xFF                                        ; [b8 ff 00]
    push ax                                             ; [50]
    call 0x15B:0x3527                                   ; [9a 27 35 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [bp-0x104], ax                             ; [89 86 fc fe]
name_table_lookup_l006B:
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x104]                                 ; [f7 a6 fc fe]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    push es                                             ; [06]
    push di                                             ; [57]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    call 0x15B:0x3612                                   ; [9a 12 36 5b 01]
    je short 0xA0                                       ; [74 19]
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x104]                                 ; [f7 a6 fc fe]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    cmp byte [es:di], 0x0                               ; [26 80 3d 00]
    je short 0xA0                                       ; [74 06]
    inc word [bp-0x104]                                 ; [ff 86 fc fe]
    jmp short 0x6B                                      ; [eb cb]
name_table_lookup_l00A0:
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x104]                                 ; [f7 a6 fc fe]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    cmp byte [es:di], 0x0                               ; [26 80 3d 00]
    jne short 0xD1                                      ; [75 1e]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x104]                                 ; [f7 a6 fc fe]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, 0x9                                         ; [b8 09 00]
    push ax                                             ; [50]
    call 0x15B:0x3527                                   ; [9a 27 35 5b 01]
name_table_lookup_l00D1:
    mov ax, word [bp-0x104]                             ; [8b 86 fc fe]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    mov ax, word [bp-0x2]                               ; [8b 46 fe]
    mov sp, bp                                          ; [89 ec]
    pop bp                                              ; [5d]
    ret 0x4                                             ; [c2 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  name_table_count   image offset 0x00E1  <- called from 0x0C76
; ------------------------------------------------------------------------------
name_table_count:
    push bp                                             ; [55]
    mov bp, sp                                          ; [89 e5]
    mov ax, 0x4                                         ; [b8 04 00]
    call 0x15B:0x4DF                                    ; [9a df 04 5b 01]
    sub sp, byte 0x4                                    ; [83 ec 04]
    xor ax, ax                                          ; [31 c0]
    mov word [bp-0x4], ax                               ; [89 46 fc]
name_table_count_l00F4:
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [bp-0x4]                                   ; [f7 66 fc]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    cmp byte [es:di], 0x0                               ; [26 80 3d 00]
    je short 0x10B                                      ; [74 05]
    inc word [bp-0x4]                                   ; [ff 46 fc]
    jmp short 0xF4                                      ; [eb e9]
name_table_count_l010B:
    mov ax, word [bp-0x4]                               ; [8b 46 fc]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    mov ax, word [bp-0x2]                               ; [8b 46 fe]
    mov sp, bp                                          ; [89 ec]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  max_tick_update   image offset 0x0118  <- called from 0x068A, 0x080E, 0x0961, 0x0ABD, 0x0BF5
; ------------------------------------------------------------------------------
max_tick_update:
    push bp                                             ; [55]
    mov bp, sp                                          ; [89 e5]
    xor ax, ax                                          ; [31 c0]
    call 0x15B:0x4DF                                    ; [9a df 04 5b 01]
    mov ax, word [bp+0x4]                               ; [8b 46 04]
    cmp ax, word [max_tick]                             ; [3b 06 4c 00]
    jbe short 0x131                                     ; [76 06]
    mov ax, word [bp+0x4]                               ; [8b 46 04]
    mov word [max_tick], ax                             ; [a3 4c 00]
max_tick_update_l0131:
    pop bp                                              ; [5d]
    ret 0x2                                             ; [c2 02 00]

; ------------------------------------------------------------------------------
; DATA  image:0x0135 .. 0x02CE   410 bytes
; ------------------------------------------------------------------------------
data_0135:
    db 47, 'ROL_RIX.EXE     Convert .ROL File to .RIX File.'; 0x0135: text[47]
    db 47, '-----------------------------------------------'; 0x0165: text[47]
    db 20, 'Input .ROL Filename:'                  ; 0x0195: text[20]
    db 16, 'Input .INS Path:'                      ; 0x01AA: text[16]
    db 13, 'Source File :'                         ; 0x01BB: text[13]
    db 4, '.ROL'                                  ; 0x01C9: text[4]
    db 21, 'Instrument File Path='                 ; 0x01CE: text[21]
    db 24, 'Reading Source File.....'              ; 0x01E4: text[24]
    db 28, 'Please Wait a Minute .......'          ; 0x01FD: text[28]
    times 2 db 0x00                            ; 0x021A: 2 zero bytes
    db 0x20,0x41,0x11,0x54,0x4F,0x54,0x41,0x4C       ; 0x021C
    db '_DATA_EVENT='                                ; 0x0224: text
    times 3 db 0x00                            ; 0x0230: 3 zero bytes
    db 0x43,0x04,0x2E,0x52,0x49,0x58,0x04,0x2E       ; 0x0233
    db 0x49,0x4E,0x53,0x0C,0x43,0x61,0x6E,0x6E       ; 0x023B
    db 'ot Find ;Please Input a Instead Instrument or Press Ctrl-Break Exit.'; 0x0243: text
    db 18, 'Proceed Music Data'                    ; 0x0287: text[18]
    db 22, ' Tick Range From 0 to '                ; 0x029A: text[22]
    times 4 db 0x00                            ; 0x02B1: 4 zero bytes
    db 13, 'Proceed Tick '                         ; 0x02B5: text[13]
    db 0x00,0x7C,0x12,0x49,0x00,0xFE,0xFF,0x46       ; 0x02C3
    db 3, 'Ok!'                                   ; 0x02CB: text[3]

; ------------------------------------------------------------------------------
;  FUNCTION  main   image offset 0x02CF  <== PROGRAM ENTRY (MZ header CS:IP)
; ------------------------------------------------------------------------------
main:
    call 0x15B:0x0                                      ; [9a 00 00 5b 01]
    call 0x15B:0x9F6                                    ; [9a f6 09 5b 01]
    push bp                                             ; [55]
    mov bp, sp                                          ; [89 e5]
    mov ax, 0x200                                       ; [b8 00 02]
    call 0x15B:0x4DF                                    ; [9a df 04 5b 01]
    sub sp, word 0x200                                  ; [81 ec 00 02]
    call near 0x0                                       ; [e8 15 fd]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x135                                       ; [bf 35 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x165                                       ; [bf 65 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3D7D                                   ; [9a 7d 3d 5b 01]
    pop di                                              ; [5f]
    pop es                                              ; [07]
    cmp byte [es:di], 0x0                               ; [26 80 3d 00]
    jne short 0x384                                     ; [75 3b]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x195                                       ; [bf 95 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x86C                                    ; [9a 6c 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFD84                                      ; [bf 84 fd]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x200                                       ; [bf 00 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    call 0x15B:0x8DF                                    ; [9a df 08 5b 01]
    call 0x15B:0x81A                                    ; [9a 1a 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    jmp short 0x3A1                                     ; [eb 1d]
main_l0384:
    lea di, word [bp-0x200]                             ; [8d be 00 fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3D7D                                   ; [9a 7d 3d 5b 01]
    mov di, 0x200                                       ; [bf 00 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    call 0x15B:0x3527                                   ; [9a 27 35 5b 01]
main_l03A1:
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    call 0x15B:0x3D7D                                   ; [9a 7d 3d 5b 01]
    pop di                                              ; [5f]
    pop es                                              ; [07]
    cmp byte [es:di], 0x0                               ; [26 80 3d 00]
    jne short 0x3F3                                     ; [75 3b]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1AA                                       ; [bf aa 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x86C                                    ; [9a 6c 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFD84                                      ; [bf 84 fd]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xA                                         ; [bf 0a 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    call 0x15B:0x8DF                                    ; [9a df 08 5b 01]
    call 0x15B:0x81A                                    ; [9a 1a 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    jmp short 0x410                                     ; [eb 1d]
main_l03F3:
    lea di, word [bp-0x200]                             ; [8d be 00 fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    call 0x15B:0x3D7D                                   ; [9a 7d 3d 5b 01]
    mov di, 0xA                                         ; [bf 0a 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    call 0x15B:0x3527                                   ; [9a 27 35 5b 01]
main_l0410:
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1BB                                       ; [bf bb 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0x200                                       ; [bf 00 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0x1C9                                       ; [bf c9 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1CE                                       ; [bf ce 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    mov di, 0xA                                         ; [bf 0a 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1E4                                       ; [bf e4 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1FD                                       ; [bf fd 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0x200                                       ; [bf 00 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0x1C9                                       ; [bf c9 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    call 0x15B:0x3B09                                   ; [9a 09 3b 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3B37                                   ; [9a 37 3b 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2C                                        ; [b8 2c 00]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24C                                       ; [bf 4c 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    cmp word [n_ticks], 0x1E                            ; [83 3e 4c 02 1e]
    jle short 0x534                                     ; [7e 06]
    mov word [n_ticks], 0x1E                            ; [c7 06 4c 02 1e 00]
main_l0534:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24E                                       ; [bf 4e 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x35                                        ; [b8 35 00]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [hdr_byte65], ax                           ; [a3 50 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x250                                       ; [bf 50 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, 0x1                                         ; [b8 01 00]
    sub ax, word [hdr_byte65]                           ; [2b 06 50 02]
    mov word [hdr_byte65], ax                           ; [a3 50 02]
    mov ax, word [hdr_byte65]                           ; [a1 50 02]
    add ax, strict word 0x8                             ; [05 08 00]
    add ax, word [hdr_byte65]                           ; [03 06 50 02]
    mov word [event_table_ptr], ax                      ; [a3 92 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0xC5                                        ; [b8 c5 00]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x252                                       ; [bf 52 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [event_count], ax                          ; [a3 4e 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24A                                       ; [bf 4a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [n_events]                             ; [a1 4a 02]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    mov ax, 0x1                                         ; [b8 01 00]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    jbe short 0x602                                     ; [76 03]
    jmp near 0x686                                      ; [e9 84 00]
main_l0602:
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0x60B                                     ; [eb 04]
main_l0607:
    inc word [tick]                                     ; [ff 06 42 02]
main_l060B:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x256                                       ; [bf 56 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x258                                       ; [bf 58 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x35                                            ; [cd 35]
    push es                                             ; [06]
    pop ax                                              ; [58]
    db 0x02,0xCD                                   ; add cl, ch
    cmp al, 0x98                                        ; [3c 98]
    push cs                                             ; [0e]
    sbb al, byte [bp+si]                                ; [1a 02]
    int 0x34                                            ; [cd 34]
    push cs                                             ; [0e]
    push dx                                             ; [52]
    add bl, byte [bp+si+0x399D]                         ; [02 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x4E3E], cx                         ; [01 8b 3e 4e]
    add cl, dl                                          ; [00 d1]
    out 0xD1, ax                                        ; [e7 d1]
    out 0x89, ax                                        ; [e7 89]
    test sp, cx                                         ; [85 cc]
    db 0x02,0xCD                                   ; add cl, ch
    cmp ax, word [cur_pitch]                            ; [3b 06 56 02]
    call 0x15B:0x399D                                   ; [9a 9d 39 5b 01]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    jne short 0x607                                     ; [75 81]
main_l0686:
    push word [cur_pitch]                               ; [ff 36 56 02]
    call near 0x118                                     ; [e8 8b fa]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    sbb al, byte [bp+si]                                ; [1a 02]
    int 0x34                                            ; [cd 34]
    push cs                                             ; [0e]
    push dx                                             ; [52]
    add bl, byte [bp+si+0x399D]                         ; [02 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x4E3E], cx                         ; [01 8b 3e 4e]
    add cl, dl                                          ; [00 d1]
    out 0xD1, ax                                        ; [e7 d1]
    out 0x89, ax                                        ; [e7 89]
    test sp, cx                                         ; [85 cc]
    add cl, byte [bp+di+0x4E3E]                         ; [02 8b 3e 4e]
    add cl, dl                                          ; [00 d1]
    out 0xD1, ax                                        ; [e7 d1]
    out 0xC7, ax                                        ; [e7 c7]
    test si, cx                                         ; [85 ce]
    db 0x02,0xFF                                   ; add bh, bh
    jg short 0x6B7                                      ; [7f ff]
    push es                                             ; [06]
    dec si                                              ; [4e]
    db 0x00,0xA1,0x4E,0x00                         ; add byte [bx+di+0x4E], ah
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov word [0xFCD0], ax                               ; [a3 d0 fc]
    mov word [-0x32E], dx                               ; [89 16 d2 fc]
    mov di, 0x2CC                                       ; [bf cc 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    les di,  [-0x330]                               ; [c4 3e d0 fc]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    mov cx, 0xFA04                                      ; [b9 04 fa]
    xor bx, bx                                          ; [31 db]
    call 0x15B:0x345D                                   ; [9a 5d 34 5b 01]
    push ax                                             ; [50]
    call 0x15B:0x3D46                                   ; [9a 46 3d 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x21E                                       ; [bf 1e 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    push dx                                             ; [52]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x9AD                                    ; [9a ad 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [event_table_ptr]                      ; [a1 92 00]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    xor ax, ax                                          ; [31 c0]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    jbe short 0x728                                     ; [76 03]
    jmp near 0xC67                                      ; [e9 3f 05]
main_l0728:
    mov word [channel], ax                              ; [a3 48 02]
    jmp short 0x731                                     ; [eb 04]
main_l072D:
    inc word [channel]                                  ; [ff 06 48 02]
main_l0731:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3CBA                                   ; [9a ba 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    add ax, strict word 0xF                             ; [05 0f 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24A                                       ; [bf 4a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [event_count], ax                          ; [a3 4e 00]
    xor ax, ax                                          ; [31 c0]
    mov word [tick], ax                                 ; [a3 42 02]
main_l077D:
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [n_events]                             ; [3b 06 4a 02]
    jae short 0x7E9                                     ; [73 63]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x25C                                       ; [bf 5c 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x25E                                       ; [bf 5e 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [ev_value]                             ; [a1 5c 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov ax, word [tick]                                 ; [a1 42 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    mov ax, word [ev_step]                              ; [a1 5e 02]
    add word [tick], ax                                 ; [01 06 42 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    jmp short 0x77D                                     ; [eb 94]
main_l07E9:
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov ax, word [tick]                                 ; [a1 42 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    push word [tick]                                    ; [ff 36 42 02]
    call near 0x118                                     ; [e8 07 f9]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], 0x7FFF                         ; [c7 85 ce 02 ff 7f]
    mov ax, word [event_count]                          ; [a1 4e 00]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    add ax, strict word 0x4                             ; [05 04 00]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di-0x2A8], ax                             ; [89 85 58 fd]
    mov word [di-0x2A6], dx                             ; [89 95 5a fd]
    mov di, 0x2CC                                       ; [bf cc 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x2A8]                             ; [c4 bd 58 fd]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    mov cx, 0xFA04                                      ; [b9 04 fa]
    xor bx, bx                                          ; [31 db]
    call 0x15B:0x345D                                   ; [9a 5d 34 5b 01]
    push ax                                             ; [50]
    call 0x15B:0x3D46                                   ; [9a 46 3d 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3CBA                                   ; [9a ba 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    add ax, strict word 0xF                             ; [05 0f 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [event_count], ax                          ; [a3 4e 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24A                                       ; [bf 4a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [n_events]                             ; [a1 4a 02]
    mov word [bp-0x4], ax                               ; [89 46 fc]
    mov ax, 0x1                                         ; [b8 01 00]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    jbe short 0x8CC                                     ; [76 03]
    jmp near 0x95D                                      ; [e9 91 00]
main_l08CC:
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0x8D5                                     ; [eb 04]
main_l08D1:
    inc word [tick]                                     ; [ff 06 42 02]
main_l08D5:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x260                                       ; [bf 60 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xED                                        ; [bf ed 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0xC                                         ; [b8 0c 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov word [iodata], 0x1                              ; [c7 06 44 02 01 00]
main_l0913:
    mov di, word [iodata]                               ; [8b 3e 44 02]
    cmp byte [di+0xEC], 0x0                             ; [80 bd ec 00 00]
    je short 0x924                                      ; [74 06]
    inc word [iodata]                                   ; [ff 06 44 02]
    jmp short 0x913                                     ; [eb ef]
main_l0924:
    mov ax, word [iodata]                               ; [a1 44 02]
    dec ax                                              ; [48]
    mov byte [0x00EC], al                               ; [a2 ec 00]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call near 0x42                                      ; [e8 0f f7]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov ax, word [ev_pitch]                             ; [a1 60 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    je short 0x95D                                      ; [74 03]
    jmp near 0x8D1                                      ; [e9 74 ff]
main_l095D:
    push word [ev_pitch]                                ; [ff 36 60 02]
    call near 0x118                                     ; [e8 b4 f7]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], 0x7FFF                         ; [c7 85 ce 02 ff 7f]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [event_count]                          ; [a1 4e 00]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di-0x32C], ax                             ; [89 85 d4 fc]
    mov word [di-0x32A], dx                             ; [89 95 d6 fc]
    mov di, 0x2CC                                       ; [bf cc 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x32C]                             ; [c4 bd d4 fc]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    mov cx, 0xFA04                                      ; [b9 04 fa]
    xor bx, bx                                          ; [31 db]
    call 0x15B:0x345D                                   ; [9a 5d 34 5b 01]
    push ax                                             ; [50]
    call 0x15B:0x3D46                                   ; [9a 46 3d 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3CBA                                   ; [9a ba 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    add ax, strict word 0xF                             ; [05 0f 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [event_count], ax                          ; [a3 4e 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24A                                       ; [bf 4a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [n_events]                             ; [a1 4a 02]
    mov word [bp-0x4], ax                               ; [89 46 fc]
    mov ax, 0x1                                         ; [b8 01 00]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    jbe short 0xA20                                     ; [76 03]
    jmp near 0xAB9                                      ; [e9 99 00]
main_l0A20:
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0xA29                                     ; [eb 04]
main_l0A25:
    inc word [tick]                                     ; [ff 06 42 02]
main_l0A29:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x262                                       ; [bf 62 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x264                                       ; [bf 64 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x35                                            ; [cd 35]
    push es                                             ; [06]
    db 0x64,0x02,0xCD                              ; add cl, ch
    cmp al, 0x98                                        ; [3c 98]
    push cs                                             ; [0e]
    xor byte [bp+si], al                                ; [30 02]
    call 0x15B:0x399D                                   ; [9a 9d 39 5b 01]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    cmp word [di+0x2CC], 0xFF                           ; [81 bd cc 02 ff 00]
    jle short 0xA9B                                     ; [7e 0e]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], 0xFF                           ; [c7 85 cc 02 ff 00]
main_l0A9B:
    mov ax, word [ev_volume]                            ; [a1 62 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    je short 0xAB9                                      ; [74 03]
    jmp near 0xA25                                      ; [e9 6c ff]
main_l0AB9:
    push word [ev_volume]                               ; [ff 36 62 02]
    call near 0x118                                     ; [e8 58 f6]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], 0x7FFF                         ; [c7 85 ce 02 ff 7f]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [event_count]                          ; [a1 4e 00]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di-0x2D4], ax                             ; [89 85 2c fd]
    mov word [di-0x2D2], dx                             ; [89 95 2e fd]
    mov di, 0x2CC                                       ; [bf cc 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x2D4]                             ; [c4 bd 2c fd]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    mov cx, 0xFA04                                      ; [b9 04 fa]
    xor bx, bx                                          ; [31 db]
    call 0x15B:0x345D                                   ; [9a 5d 34 5b 01]
    push ax                                             ; [50]
    call 0x15B:0x3D46                                   ; [9a 46 3d 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3CBA                                   ; [9a ba 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    add ax, strict word 0xF                             ; [05 0f 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [event_count], ax                          ; [a3 4e 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24A                                       ; [bf 4a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [n_events]                             ; [a1 4a 02]
    mov word [bp-0x4], ax                               ; [89 46 fc]
    mov ax, 0x1                                         ; [b8 01 00]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    ja short 0xBF1                                      ; [77 78]
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0xB82                                     ; [eb 04]
main_l0B7E:
    inc word [tick]                                     ; [ff 06 42 02]
main_l0B82:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x268                                       ; [bf 68 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x26A                                       ; [bf 6a 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x35                                            ; [cd 35]
    push es                                             ; [06]
    push 0x2                                            ; [6a 02]
    int 0x3C                                            ; [cd 3c]
    db 0x98                                        ; cbw
    push cs                                             ; [0e]
    xor byte [bp+si], al                                ; [30 02]
    call 0x15B:0x399D                                   ; [9a 9d 39 5b 01]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], ax                             ; [89 85 cc 02]
    mov ax, word [0x0268]                               ; [a1 68 02]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], ax                             ; [89 85 ce 02]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x4]                               ; [3b 46 fc]
    jne short 0xB7E                                     ; [75 8d]
main_l0BF1:
    push word [0x0268]                                  ; [ff 36 68 02]
    call near 0x118                                     ; [e8 20 f5]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CC], 0x20                           ; [c7 85 cc 02 20 00]
    mov di, word [event_count]                          ; [8b 3e 4e 00]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di+0x2CE], 0x7FFF                         ; [c7 85 ce 02 ff 7f]
    inc word [event_count]                              ; [ff 06 4e 00]
    mov ax, word [event_count]                          ; [a1 4e 00]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    push ax                                             ; [50]
    call 0x15B:0x23F                                    ; [9a 3f 02 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    mov word [di-0x300], ax                             ; [89 85 00 fd]
    mov word [di-0x2FE], dx                             ; [89 95 02 fd]
    mov di, 0x2CC                                       ; [bf cc 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x300]                             ; [c4 bd 00 fd]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [event_count]                          ; [a1 4e 00]
    db 0x99                                        ; cwd
    mov cx, 0xFA04                                      ; [b9 04 fa]
    xor bx, bx                                          ; [31 db]
    call 0x15B:0x345D                                   ; [9a 5d 34 5b 01]
    push ax                                             ; [50]
    call 0x15B:0x3D46                                   ; [9a 46 3d 5b 01]
    mov ax, word [channel]                              ; [a1 48 02]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    je short 0xC67                                      ; [74 03]
    jmp near 0x72D                                      ; [e9 c6 fa]
main_l0C67:
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3BB8                                   ; [9a b8 3b 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    call near 0xE1                                      ; [e8 68 f4]
    mov word [0x00FE], ax                               ; [a3 fe 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0x200                                       ; [bf 00 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0x234                                       ; [bf 34 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    call 0x15B:0x3B09                                   ; [9a 09 3b 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3B40                                   ; [9a 40 3b 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov word [tick], 0x55AA                             ; [c7 06 42 02 aa 55]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x242                                       ; [bf 42 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x250                                       ; [bf 50 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x2                                         ; [bf 02 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x6                                         ; [bf 06 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [0x00FE]                               ; [a1 fe 00]
    mov cl, 0x6                                         ; [b1 06]
    shl ax, cl                                          ; [d3 e0]
    xor dx, dx                                          ; [31 d2]
    add ax, word [0x0006]                               ; [03 06 06 00]
    adc dx, word [0x0008]                               ; [13 16 08 00]
    mov word [0x00FA], ax                               ; [a3 fa 00]
    mov word [0x00FC], dx                               ; [89 16 fc 00]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xFA                                        ; [bf fa 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x2                                         ; [bf 02 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x4                                         ; [b8 04 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [0x00FE]                               ; [a1 fe 00]
    dec ax                                              ; [48]
    mov word [bp-0x2], ax                               ; [89 46 fe]
    xor ax, ax                                          ; [31 c0]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    jbe short 0xD8A                                     ; [76 03]
    jmp near 0xF23                                      ; [e9 99 01]
main_l0D8A:
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0xD93                                     ; [eb 04]
main_l0D8F:
    inc word [tick]                                     ; [ff 06 42 02]
main_l0D93:
    mov ax, 0xA                                         ; [b8 0a 00]
    mul word [tick]                                     ; [f7 26 42 02]
    les di,  [slot_table]                           ; [c4 3e c8 02]
    db 0x03,0xF8                                   ; add di, ax
    push es                                             ; [06]
    push di                                             ; [57]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0xC                                         ; [b8 0c 00]
    push ax                                             ; [50]
    call 0x15B:0x3527                                   ; [9a 27 35 5b 01]
    mov di, 0xAC                                        ; [bf ac 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    mov al, 0x0                                         ; [b0 00]
    push ax                                             ; [50]
    call 0x15B:0x3D69                                   ; [9a 69 3d 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0xA                                         ; [bf 0a 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    mov di, 0x239                                       ; [bf 39 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    call 0x15B:0x3B09                                   ; [9a 09 3b 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3B37                                   ; [9a 37 3b 5b 01]
main_l0DFD:
    call 0x15B:0x4A2                                    ; [9a a2 04 5b 01]
    or ax, ax                                           ; [09 c0]
    jne short 0xE09                                     ; [75 03]
    jmp near 0xEBA                                      ; [e9 b1 00]
main_l0E09:
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x23E                                       ; [bf 3e 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0x239                                       ; [bf 39 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x24B                                       ; [bf 4b 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    mov di, 0xFD84                                      ; [bf 84 fd]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0xC                                         ; [b8 0c 00]
    push ax                                             ; [50]
    call 0x15B:0x8DF                                    ; [9a df 08 5b 01]
    call 0x15B:0x81A                                    ; [9a 1a 08 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    lea di, word [bp-0x102]                             ; [8d be fe fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    mov di, 0xA                                         ; [bf 0a 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x350D                                   ; [9a 0d 35 5b 01]
    mov di, 0xEC                                        ; [bf ec 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    mov di, 0x239                                       ; [bf 39 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    call 0x15B:0x359A                                   ; [9a 9a 35 5b 01]
    call 0x15B:0x3B09                                   ; [9a 09 3b 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    call 0x15B:0x3B37                                   ; [9a 37 3b 5b 01]
    jmp near 0xDFD                                      ; [e9 43 ff]
main_l0EBA:
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    call 0x15B:0x3C8A                                   ; [9a 8a 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xAC                                        ; [bf ac 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3C22                                   ; [9a 22 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x180                                       ; [bf 80 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3BB8                                   ; [9a b8 3b 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0xAC                                        ; [bf ac 00]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x40                                        ; [b8 40 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    je short 0xF23                                      ; [74 03]
    jmp near 0xD8F                                      ; [e9 6c fe]
main_l0F23:
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3CBA                                   ; [9a ba 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov word [tick], ax                                 ; [a3 42 02]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x287                                       ; [bf 87 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x1FD                                       ; [bf fd 01]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x29A                                       ; [bf 9a 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    mov ax, word [max_tick]                             ; [a1 4c 00]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x9AD                                    ; [9a ad 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    xor ax, ax                                          ; [31 c0]
    mov word [0x026E], ax                               ; [a3 6e 02]
    xor ax, ax                                          ; [31 c0]
    mov word [channel], ax                              ; [a3 48 02]
    jmp short 0xFC6                                     ; [eb 04]
main_l0FC2:
    inc word [channel]                                  ; [ff 06 48 02]
main_l0FC6:
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x286], ax                             ; [89 85 86 02]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x2B2], ax                             ; [89 85 b2 02]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x29C], ax                             ; [89 85 9c 02]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    xor ax, ax                                          ; [31 c0]
    mov word [di+0x270], ax                             ; [89 85 70 02]
    cmp word [channel], 0xA                             ; [83 3e 48 02 0a]
    jne short 0xFC2                                     ; [75 c5]
    xor ax, ax                                          ; [31 c0]
    mov word [0x0246], ax                               ; [a3 46 02]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x4CA1                                      ; [3d a1 4c]
    add byte [bx+si-0x77], cl                           ; [00 48 89]
    inc si                                              ; [46]

; ------------------------------------------------------------------------------
; DATA  image:0x1015 .. 0x1015   1 bytes
; ------------------------------------------------------------------------------
data_1015:
    db 0xFE                                          ; 0x1015
    xor ax, ax                                          ; [31 c0]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    jbe short 0x1020                                    ; [76 03]
    jmp near 0x14E8                                     ; [e9 c8 04]
main_l1020:
    mov word [tick], ax                                 ; [a3 42 02]
    jmp short 0x1029                                    ; [eb 04]
main_l1025:
    inc word [tick]                                     ; [ff 06 42 02]
main_l1029:
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [max_tick]                             ; [3b 06 4c 00]
    je short 0x103C                                     ; [74 0a]
    mov ax, word [tick]                                 ; [a1 42 02]
    and ax, 0xFF                                        ; [25 ff 00]
    or ax, ax                                           ; [09 c0]
    jne short 0x1072                                    ; [75 36]
main_l103C:
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov al, 0xD                                         ; [b0 0d]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x8B5                                    ; [9a b5 08 5b 01]
    mov di, 0x2B5                                       ; [bf b5 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x9AD                                    ; [9a ad 09 5b 01]
    call 0x15B:0x86C                                    ; [9a 6c 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
main_l1072:
    mov ax, word [event_table_ptr]                      ; [a1 92 00]
    or ax, ax                                           ; [09 c0]
    jae short 0x107C                                    ; [73 03]
    jmp near 0x1423                                     ; [e9 a7 03]
main_l107C:
    mov word [channel], ax                              ; [a3 48 02]
    jmp short 0x1085                                    ; [eb 04]
main_l1081:
    dec word [channel]                                  ; [ff 0e 48 02]
main_l1085:
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    mov ax, word [di+0x286]                             ; [8b 85 86 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x32C]                             ; [c4 bd d4 fc]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    db 0x99                                        ; cwd
main_l10A6:
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    db 0x3B,0xD3                                   ; cmp dx, bx
    jg short 0x10BF                                     ; [7f 0c]
    jge short 0x10B8                                    ; [7d 03]
    jmp near 0x116A                                     ; [e9 b2 00]
main_l10B8:
    db 0x3B,0xC1                                   ; cmp ax, cx
    jae short 0x10BF                                    ; [73 03]
    jmp near 0x116A                                     ; [e9 ab 00]
main_l10BF:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov cl, 0x2                                         ; [b1 02]
main_l10CA:
    int 0x39                                            ; [cd 39]
    jle short 0x10CA                                    ; [7e fc]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x3]                               ; [8a 66 fd]
    sahf                                                ; [9e]
    je short 0x110C                                     ; [74 36]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add byte [bp+si+0x399D], bl                         ; [00 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x244], sp                          ; [01 a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x3E8B                                      ; [3d 8b 3e]
    dec ax                                              ; [48]
    db 0x02,0xD1                                   ; add dl, cl
    out 0x8B, ax                                        ; [e7 8b]
    test word [bp-0x2EFE], ax                           ; [85 86 02 d1]
    loopne 0x10EA                                       ; [e0 d1]
    loopne 0x10A6                                       ; [e0 8b]
    db 0x3E,0x48                                   ; dec ax
    db 0x02,0xD1                                   ; add dl, cl
    out 0xD1, ax                                        ; [e7 d1]
    out 0xC4, ax                                        ; [e7 c4]
    mov bp, 0xFCD4                                      ; [bd d4 fc]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di]                                ; [26 8b 05]
    db 0x99                                        ; cwd
    push dx                                             ; [52]
    push ax                                             ; [50]
    mov ax, word [channel]                              ; [a1 48 02]
    mov cx, 0x8                                         ; [b9 08 00]
    shl ax, cl                                          ; [d3 e0]
    or ax, 0x9000                                       ; [0d 00 90]
    xor dx, dx                                          ; [31 d2]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    db 0x0B,0xC1                                   ; or ax, cx
    db 0x0B,0xD3                                   ; or dx, bx
    mov word [iodata], ax                               ; [a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    inc word [di+0x286]                                 ; [ff 85 86 02]
main_l116A:
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    mov ax, word [di+0x2B2]                             ; [8b 85 b2 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x300]                             ; [c4 bd 00 fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    db 0x99                                        ; cwd
main_l118B:
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    db 0x3B,0xD3                                   ; cmp dx, bx
    jg short 0x11A4                                     ; [7f 0c]
    jge short 0x119D                                    ; [7d 03]
    jmp near 0x124F                                     ; [e9 b2 00]
main_l119D:
    db 0x3B,0xC1                                   ; cmp ax, cx
    jae short 0x11A4                                    ; [73 03]
    jmp near 0x124F                                     ; [e9 ab 00]
main_l11A4:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov cl, 0x2                                         ; [b1 02]
main_l11AF:
    int 0x39                                            ; [cd 39]
    jle short 0x11AF                                    ; [7e fc]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x3]                               ; [8a 66 fd]
    sahf                                                ; [9e]
    je short 0x11F1                                     ; [74 36]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add byte [bp+si+0x399D], bl                         ; [00 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x244], sp                          ; [01 a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x3E8B                                      ; [3d 8b 3e]
    dec ax                                              ; [48]
    db 0x02,0xD1                                   ; add dl, cl
    out 0x8B, ax                                        ; [e7 8b]
    test word [bp+si-0x2EFE], si                        ; [85 b2 02 d1]
    loopne 0x11CF                                       ; [e0 d1]
    loopne 0x118B                                       ; [e0 8b]
    db 0x3E,0x48                                   ; dec ax
    db 0x02,0xD1                                   ; add dl, cl
    out 0xD1, ax                                        ; [e7 d1]
    out 0xC4, ax                                        ; [e7 c4]
    mov bp, 0xFD00                                      ; [bd 00 fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di]                                ; [26 8b 05]
    db 0x99                                        ; cwd
    push dx                                             ; [52]
    push ax                                             ; [50]
    mov ax, word [channel]                              ; [a1 48 02]
    mov cx, 0x8                                         ; [b9 08 00]
    shl ax, cl                                          ; [d3 e0]
    or ax, 0xA000                                       ; [0d 00 a0]
    xor dx, dx                                          ; [31 d2]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    db 0x0B,0xC1                                   ; or ax, cx
    db 0x0B,0xD3                                   ; or dx, bx
    mov word [iodata], ax                               ; [a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    inc word [di+0x2B2]                                 ; [ff 85 b2 02]
main_l124F:
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    mov ax, word [di+0x29C]                             ; [8b 85 9c 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x2D4]                             ; [c4 bd 2c fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    db 0x99                                        ; cwd
main_l1270:
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    db 0x3B,0xD3                                   ; cmp dx, bx
    jg short 0x1289                                     ; [7f 0c]
    jge short 0x1282                                    ; [7d 03]
    jmp near 0x1334                                     ; [e9 b2 00]
main_l1282:
    db 0x3B,0xC1                                   ; cmp ax, cx
    jae short 0x1289                                    ; [73 03]
    jmp near 0x1334                                     ; [e9 ab 00]
main_l1289:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov cl, 0x2                                         ; [b1 02]
main_l1294:
    int 0x39                                            ; [cd 39]
    jle short 0x1294                                    ; [7e fc]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x3]                               ; [8a 66 fd]
    sahf                                                ; [9e]
    je short 0x12D6                                     ; [74 36]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add byte [bp+si+0x399D], bl                         ; [00 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x244], sp                          ; [01 a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x3E8B                                      ; [3d 8b 3e]
    dec ax                                              ; [48]
    db 0x02,0xD1                                   ; add dl, cl
    out 0x8B, ax                                        ; [e7 8b]
    test word [si-0x2EFE], bx                           ; [85 9c 02 d1]
    loopne 0x12B4                                       ; [e0 d1]
    loopne 0x1270                                       ; [e0 8b]
    db 0x3E,0x48                                   ; dec ax
    db 0x02,0xD1                                   ; add dl, cl
    out 0xD1, ax                                        ; [e7 d1]
    out 0xC4, ax                                        ; [e7 c4]
    mov bp, 0xFD2C                                      ; [bd 2c fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di]                                ; [26 8b 05]
    db 0x99                                        ; cwd
    push dx                                             ; [52]
    push ax                                             ; [50]
    mov ax, word [channel]                              ; [a1 48 02]
    mov cx, 0x8                                         ; [b9 08 00]
    shl ax, cl                                          ; [d3 e0]
    or ax, 0xB000                                       ; [0d 00 b0]
    xor dx, dx                                          ; [31 d2]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    db 0x0B,0xC1                                   ; or ax, cx
    db 0x0B,0xD3                                   ; or dx, bx
    mov word [iodata], ax                               ; [a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    inc word [di+0x29C]                                 ; [ff 85 9c 02]
main_l1334:
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    mov ax, word [di+0x270]                             ; [8b 85 70 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x2A8]                             ; [c4 bd 58 fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    db 0x99                                        ; cwd
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    db 0x3B,0xD3                                   ; cmp dx, bx
    jg short 0x136E                                     ; [7f 0c]
    jge short 0x1367                                    ; [7d 03]
    jmp near 0x1419                                     ; [e9 b2 00]
main_l1367:
    db 0x3B,0xC1                                   ; cmp ax, cx
    jae short 0x136E                                    ; [73 03]
    jmp near 0x1419                                     ; [e9 ab 00]
main_l136E:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov cl, 0x2                                         ; [b1 02]
main_l1379:
    int 0x39                                            ; [cd 39]
    jle short 0x1379                                    ; [7e fc]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x3]                               ; [8a 66 fd]
    sahf                                                ; [9e]
    je short 0x13BB                                     ; [74 36]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add byte [bp+si+0x399D], bl                         ; [00 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x244], sp                          ; [01 a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x3E8B                                      ; [3d 8b 3e]
    dec ax                                              ; [48]
    db 0x02,0xD1                                   ; add dl, cl
    out 0x8B, ax                                        ; [e7 8b]
    test word [bx+si+0x2], si                           ; [85 70 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    shl di, 0x1                                         ; [d1 e7]
    les di,  [di-0x2A8]                             ; [c4 bd 58 fd]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di]                                ; [26 8b 05]
    db 0x99                                        ; cwd
    push dx                                             ; [52]
    push ax                                             ; [50]
    mov ax, word [channel]                              ; [a1 48 02]
    mov cx, 0x8                                         ; [b9 08 00]
    shl ax, cl                                          ; [d3 e0]
    or ax, 0xC000                                       ; [0d 00 c0]
    xor dx, dx                                          ; [31 d2]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    db 0x0B,0xC1                                   ; or ax, cx
    db 0x0B,0xD3                                   ; or dx, bx
    mov word [iodata], ax                               ; [a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, word [channel]                              ; [8b 3e 48 02]
    shl di, 0x1                                         ; [d1 e7]
    inc word [di+0x270]                                 ; [ff 85 70 02]
main_l1419:
    cmp word [channel], 0x0                             ; [83 3e 48 02 00]
    je short 0x1423                                     ; [74 03]
    jmp near 0x1081                                     ; [e9 5e fc]
main_l1423:
    mov ax, word [0x026E]                               ; [a1 6e 02]
    inc ax                                              ; [40]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    les di,  [-0x330]                               ; [c4 3e d0 fc]
    db 0x03,0xF8                                   ; add di, ax
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    db 0x99                                        ; cwd
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx
    mov ax, word [tick]                                 ; [a1 42 02]
    xor dx, dx                                          ; [31 d2]
    db 0x3B,0xD3                                   ; cmp dx, bx
    jg short 0x1449                                     ; [7f 06]
    jl short 0x144D                                     ; [7c 08]
    db 0x3B,0xC1                                   ; cmp ax, cx
    jb short 0x144D                                     ; [72 04]
main_l1449:
    inc word [0x026E]                                   ; [ff 06 6e 02]
main_l144D:
    int 0x3B                                            ; [cd 3b]
    push es                                             ; [06]
    dec sp                                              ; [4c]
    db 0x02,0xCD                                   ; add cl, ch
    cmp al, 0x98                                        ; [3c 98]
    db 0x3E,0xC3                                   ; ret
    add ah, byte [bx+di+0x26E]                          ; [02 a1 6e 02]
    shl ax, 0x1                                         ; [d1 e0]
    shl ax, 0x1                                         ; [d1 e0]
    les di,  [-0x330]                               ; [c4 3e d0 fc]
    db 0x03,0xF8                                   ; add di, ax
    int 0x3C                                            ; [cd 3c]
    fild word [di]                                      ; [df 05]
    int 0x3A                                            ; [cd 3a]
    stc                                                 ; [f9]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    pushf                                               ; [9c]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x39CD                                      ; [3d cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp byte [0x009C], al                               ; [38 06 9c 00]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    movsb                                               ; [a4]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x39CD                                      ; [3d cd 39]
    push es                                             ; [06]
    movsb                                               ; [a4]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov word [bp+si], 0x39CD                            ; [c7 02 cd 39]
    jle short 0x148F                                    ; [7e fc]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x3]                               ; [8a 66 fd]
    sahf                                                ; [9e]
    jbe short 0x14D1                                    ; [76 36]
    mov word [iodata], 0x7FFF                           ; [c7 06 44 02 ff 7f]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    movsb                                               ; [a4]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    mov word [es:bp+si], 0x39CD                         ; [26 c7 02 cd 39]
    push ds                                             ; [1e]
    movsb                                               ; [a4]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0xB3EB                                      ; [3d eb b3]
main_l14D1:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    movsb                                               ; [a4]
    add ch, cl                                          ; [00 cd]
    cmp word [0x0094], bx                               ; [39 1e 94 00]
    int 0x3D                                            ; [cd 3d]
    mov ax, word [tick]                                 ; [a1 42 02]
    cmp ax, word [bp-0x2]                               ; [3b 46 fe]
    je short 0x14E8                                     ; [74 03]
    jmp near 0x1025                                     ; [e9 3d fb]
main_l14E8:
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp al, 0x98                                        ; [3c 98]
    push ds                                             ; [1e]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
main_l14F5:
    jle short 0x14F5                                    ; [7e fe]
    int 0x3D                                            ; [cd 3d]
    mov ah, byte [bp-0x1]                               ; [8a 66 ff]
    sahf                                                ; [9e]
    je short 0x1535                                     ; [74 36]
    int 0x39                                            ; [cd 39]
    push es                                             ; [06]
    xchg sp, ax                                         ; [94]
    add byte [bp+si+0x399D], bl                         ; [00 9a 9d 39]
    pop bx                                              ; [5b]
    add word [bp+di+0x244], sp                          ; [01 a3 44 02]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    push es                                             ; [06]
    mov cl, 0x2                                         ; [b1 02]
    int 0x39                                            ; [cd 39]
    push ds                                             ; [1e]
    xchg sp, ax                                         ; [94]
    add ch, cl                                          ; [00 cd]
    cmp ax, 0x6C7                                       ; [3d c7 06]
    inc sp                                              ; [44]
    add al, byte [bx+si]                                ; [02 00]
    cmp byte [bx+0x100], 0x1E                           ; [80 bf 00 01 1e]
    push di                                             ; [57]
    mov di, 0x244                                       ; [bf 44 02]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov ax, 0x2                                         ; [b8 02 00]
    push ax                                             ; [50]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    push ax                                             ; [50]
    call 0x15B:0x3C29                                   ; [9a 29 3c 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0x100                                       ; [bf 00 01]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x3BB8                                   ; [9a b8 3b 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov di, 0xFE84                                      ; [bf 84 fe]
    push ds                                             ; [1e]
    push di                                             ; [57]
    mov di, 0x2CB                                       ; [bf cb 02]
    push cs                                             ; [0e]
    push di                                             ; [57]
    xor ax, ax                                          ; [31 c0]
    push ax                                             ; [50]
    call 0x15B:0x917                                    ; [9a 17 09 5b 01]
    call 0x15B:0x848                                    ; [9a 48 08 5b 01]
    call 0x15B:0x4A9                                    ; [9a a9 04 5b 01]
    mov sp, bp                                          ; [89 ec]
    pop bp                                              ; [5d]
    xor ax, ax                                          ; [31 c0]
    call 0x15B:0xE9                                     ; [9a e9 00 5b 01]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_startup   image offset 0x15B0  <- called from 0x02CF
; ------------------------------------------------------------------------------
rtl_startup:
    mov dx, 0x53C                                       ; [ba 3c 05]
    mov ds, dx                                          ; [8e da]
    mov word [psp_seg], es                              ; [8c 06 86 00]
    db 0x33,0xED                                   ; xor bp, bp
    db 0x8B,0xC4                                   ; mov ax, sp
    add ax, strict word 0x13                            ; [05 13 00]
    mov cl, 0x4                                         ; [b1 04]
    shr ax, cl                                          ; [d3 e8]
    mov dx, ss                                          ; [8c d2]
    db 0x03,0xC2                                   ; add ax, dx
    mov word [0x0058], ax                               ; [a3 58 00]
    mov word [0x005A], ax                               ; [a3 5a 00]
    add ax, word [0x0052]                               ; [03 06 52 00]
    mov word [0x005C], ax                               ; [a3 5c 00]
    mov word [0x0066], ax                               ; [a3 66 00]
    mov word [0x006A], ax                               ; [a3 6a 00]
    mov word [0x0072], ax                               ; [a3 72 00]
    mov dx, word [es:0x2]                               ; [26 8b 16 02 00]
    mov word [0x006E], dx                               ; [89 16 6e 00]
    mov word [0x0078], 0xA9                             ; [c7 06 78 00 a9 00]
    mov word [0x007A], cs                               ; [8c 0e 7a 00]
    mov di, 0xFF84                                      ; [bf 84 ff]
    mov si, 0x1EE                                       ; [be ee 01]
    mov cx, 0x13                                        ; [b9 13 00]
    nop                                                 ; [90]
rtl_startup_l15FB:
    cld                                                 ; [fc]
    cs lodsb                                            ; [2e ac]
    mov ah, 0x35                                        ; [b4 35]
    int 0x21                                            ; [cd 21]
    mov word [di], bx                                   ; [89 1d]
    mov word [di+0x2], es                               ; [8c 45 02]
    add di, byte 0x4                                    ; [83 c7 04]
    loop 0x15FB                                         ; [e2 ef]
    push ds                                             ; [1e]
    push cs                                             ; [0e]
    pop ds                                              ; [1f]
    mov dx, 0xDF                                        ; [ba df 00]
    mov ax, 0x2500                                      ; [b8 00 25]
    int 0x21                                            ; [cd 21]
    mov dx, 0xE6                                        ; [ba e6 00]
    mov ax, 0x2523                                      ; [b8 23 25]
    int 0x21                                            ; [cd 21]
    mov dx, 0xAE                                        ; [ba ae 00]
    mov ax, 0x2524                                      ; [b8 24 25]
    int 0x21                                            ; [cd 21]
    mov dx, 0xD7                                        ; [ba d7 00]
    mov ax, 0x253F                                      ; [b8 3f 25]
    int 0x21                                            ; [cd 21]
    pop ds                                              ; [1f]
    mov ax, 0xFD84                                      ; [b8 84 fd]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    mov ax, 0x218                                       ; [b8 18 02]
    push cs                                             ; [0e]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x1AA5                                    ; [e8 65 04]
    push cs                                             ; [0e]
    call near 0x1B15                                    ; [e8 d1 04]
    mov ax, 0xFE84                                      ; [b8 84 fe]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    mov ax, 0x218                                       ; [b8 18 02]
    push cs                                             ; [0e]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x1AA5                                    ; [e8 51 04]
    push cs                                             ; [0e]
    call near 0x1B1A                                    ; [e8 c2 04]
    retf                                                ; [cb]
    db 0x33,0xC0                                   ; xor ax, ax
    retf 0x2                                            ; [ca 02 00]
    sti                                                 ; [fb]
    add sp, byte 0x6                                    ; [83 c4 06]
    pop ax                                              ; [58]
    and di, byte 0x1F                                   ; [83 e7 1f]
    add di, word 0x96                                   ; [81 c7 96 00]
    cmp ah, byte 0x39                                   ; [80 fc 39]
    jae short 0x1672                                    ; [73 03]
    mov di, 0xFFFF                                      ; [bf ff ff]
rtl_startup_l1672:
    push di                                             ; [57]
    mov ah, 0x54                                        ; [b4 54]
    int 0x21                                            ; [cd 21]
    db 0x8B,0xEC                                   ; mov bp, sp
    or byte [bp+0x16], 0x1                              ; [80 4e 16 01]
    pop ax                                              ; [58]
    pop bx                                              ; [5b]
    pop cx                                              ; [59]
    pop dx                                              ; [5a]
    pop si                                              ; [5e]
    pop di                                              ; [5f]
    pop bp                                              ; [5d]
    pop ds                                              ; [1f]
    pop es                                              ; [07]
    iret                                                ; [cf]
    mov ax, 0xD0                                        ; [b8 d0 00]
    add sp, byte 0x6                                    ; [83 c4 06]
    jmp short 0x1692                                    ; [eb 03]
    mov ax, 0xC8                                        ; [b8 c8 00]
rtl_startup_l1692:
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    jmp short 0x169D                                    ; [eb 07]

; ------------------------------------------------------------------------------
; DATA  image:0x1696 .. 0x1698   3 bytes
; ------------------------------------------------------------------------------
data_1696:
    db 0xB8,0xFF,0x00                                ; 0x1696

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_init   image offset 0x1699  <- called from 0x15A5
; ------------------------------------------------------------------------------
rtl_init:
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x33,0xDB                                   ; xor bx, bx
rtl_init_l169D:
    mov dx, 0x53C                                       ; [ba 3c 05]
    mov ds, dx                                          ; [8e da]
    sti                                                 ; [fb]
    mov word [0x0080], ax                               ; [a3 80 00]
    db 0x8B,0xC1                                   ; mov ax, cx
    db 0x0B,0xC3                                   ; or ax, bx
    je short 0x16CB                                     ; [74 1f]
    mov ax, word [0x005E]                               ; [a1 5e 00]
rtl_init_l16AF:
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x16C4                                     ; [74 11]
    mov es, ax                                          ; [8e c0]
    cmp bx, word [es:0x10]                              ; [26 3b 1e 10 00]
    je short 0x16C2                                     ; [74 06]
    mov ax, word [es:0x14]                              ; [26 a1 14 00]
    jmp short 0x16AF                                    ; [eb ed]
rtl_init_l16C2:
    mov bx, es                                          ; [8c c3]
rtl_init_l16C4:
    sub bx, word [psp_seg]                              ; [2b 1e 86 00]
    sub bx, byte 0x10                                   ; [83 eb 10]
rtl_init_l16CB:
    mov word [0x0082], cx                               ; [89 0e 82 00]
    mov word [0x0084], bx                               ; [89 1e 84 00]
    les bx,  [0x007C]                               ; [c4 1e 7c 00]
    mov ax, es                                          ; [8c c0]
    db 0x0B,0xC3                                   ; or ax, bx
    je short 0x16F0                                     ; [74 13]
    db 0x33,0xC0                                   ; xor ax, ax
    mov word [0x007C], ax                               ; [a3 7c 00]
    mov word [0x007E], ax                               ; [a3 7e 00]
    mov word [dos_errno], ax                            ; [a3 8a 00]
    mov ax, 0x123                                       ; [b8 23 01]
    push cs                                             ; [0e]
    push ax                                             ; [50]
    push es                                             ; [06]
    push bx                                             ; [53]
    retf                                                ; [cb]
rtl_init_l16F0:
    mov ax, 0xFD84                                      ; [b8 84 fd]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x1B6F                                    ; [e8 76 04]
    mov ax, 0xFE84                                      ; [b8 84 fe]
    push ds                                             ; [1e]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x1B6F                                    ; [e8 6d 04]
    mov di, 0xFF84                                      ; [bf 84 ff]
    mov si, 0x1EE                                       ; [be ee 01]
    mov cx, 0x13                                        ; [b9 13 00]
    nop                                                 ; [90]
rtl_init_l170C:
    cld                                                 ; [fc]
    cs lodsb                                            ; [2e ac]
    mov ah, 0x25                                        ; [b4 25]
    push ds                                             ; [1e]
    lds dx,  [di]                                   ; [c5 15]
    int 0x21                                            ; [cd 21]
    pop ds                                              ; [1f]
    add di, byte 0x4                                    ; [83 c7 04]
    loop 0x170C                                         ; [e2 f0]
    mov ax, word [0x0082]                               ; [a1 82 00]
    or ax, word [0x0084]                                ; [0b 06 84 00]
    je short 0x174E                                     ; [74 29]
    mov bx, 0x201                                       ; [bb 01 02]
    call near 0x1755                                    ; [e8 2a 00]
    mov ax, word [0x0080]                               ; [a1 80 00]
    call near 0x1763                                    ; [e8 32 00]
    mov bx, 0x210                                       ; [bb 10 02]
    call near 0x1755                                    ; [e8 1e 00]
    mov ax, word [0x0084]                               ; [a1 84 00]
    call near 0x177D                                    ; [e8 40 00]
    mov al, 0x3A                                        ; [b0 3a]
    call near 0x1797                                    ; [e8 55 00]
    mov ax, word [0x0082]                               ; [a1 82 00]
    call near 0x177D                                    ; [e8 35 00]
    mov bx, 0x215                                       ; [bb 15 02]
    call near 0x1755                                    ; [e8 07 00]
rtl_init_l174E:
    mov ax, word [0x0080]                               ; [a1 80 00]
    mov ah, 0x4C                                        ; [b4 4c]
    int 0x21                                            ; [cd 21]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_print_str   image offset 0x1755  <- called from 0x1728, 0x1734, 0x174B
; ------------------------------------------------------------------------------
rtl_print_str:
    mov al, byte [cs:bx]                                ; [2e 8a 07]
    db 0x0A,0xC0                                   ; or al, al
    je short 0x1762                                     ; [74 06]
    call near 0x1797                                    ; [e8 38 00]
    inc bx                                              ; [43]
    jmp short 0x1755                                    ; [eb f3]
rtl_print_str_l1762:
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_print_uint   image offset 0x1763  <- called from 0x172E
; ------------------------------------------------------------------------------
rtl_print_uint:
    mov cl, 0x64                                        ; [b1 64]
    call near 0x176F                                    ; [e8 07 00]
    mov cl, 0xA                                         ; [b1 0a]
    call near 0x176F                                    ; [e8 02 00]
    jmp short 0x1773                                    ; [eb 04]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_print_digit   image offset 0x176F  <- called from 0x1765, 0x176A
; ------------------------------------------------------------------------------
rtl_print_digit:
    db 0x32,0xE4                                   ; xor ah, ah
    div cl                                              ; [f6 f1]
rtl_print_digit_l1773:
    add al, 0x30                                        ; [04 30]
    push ax                                             ; [50]
    call near 0x1797                                    ; [e8 1e 00]
    pop ax                                              ; [58]
    db 0x8A,0xC4                                   ; mov al, ah
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_print_hex8   image offset 0x177D  <- called from 0x173A, 0x1745
; ------------------------------------------------------------------------------
rtl_print_hex8:
    push ax                                             ; [50]
    db 0x8A,0xC4                                   ; mov al, ah
    call near 0x1784                                    ; [e8 01 00]
    pop ax                                              ; [58]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_print_hex_nibble   image offset 0x1784  <- called from 0x1780
; ------------------------------------------------------------------------------
rtl_print_hex_nibble:
    push ax                                             ; [50]
    mov cl, 0x4                                         ; [b1 04]
    shr al, cl                                          ; [d2 e8]
    call near 0x178F                                    ; [e8 03 00]
    pop ax                                              ; [58]
    and al, 0xF                                         ; [24 0f]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_nibble_to_ascii   image offset 0x178F  <- called from 0x1789
; ------------------------------------------------------------------------------
rtl_nibble_to_ascii:
    add al, 0x30                                        ; [04 30]
    cmp al, 0x3A                                        ; [3c 3a]
    jb short 0x1797                                     ; [72 02]
    add al, 0x7                                         ; [04 07]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_putchar   image offset 0x1797  <- called from 0x173F, 0x175C, 0x1776
; ------------------------------------------------------------------------------
rtl_putchar:
    db 0x8A,0xD0                                   ; mov dl, al
    mov ah, 0x6                                         ; [b4 06]
    int 0x21                                            ; [cd 21]
    ret                                                 ; [c3]
    add byte [bp+si], al                                ; [00 02]
    sbb sp, word [bx+di]                                ; [1b 21]
    and sp, word [si]                                   ; [23 24]
    xor al, 0x35                                        ; [34 35]
    db 0x36,0x37                                   ; aaa
    cmp byte [bx+di], bh                                ; [38 39]
    cmp bh, byte [bp+di]                                ; [3a 3b]
    cmp al, 0x3D                                        ; [3c 3d]
    db 0x3E,0x3F                                   ; aas
    jne short 0x1804                                    ; [75 52]
    jne short 0x1822                                    ; [75 6e]
    je short 0x181F                                     ; [74 69]
    insw                                                ; [6d]
    db 0x65,0x20,0x65,0x72                         ; and byte [gs:di+0x72], ah
    jb short 0x182C                                     ; [72 6f]
    jb short 0x17DF                                     ; [72 20]
    add byte [bx+si], ah                                ; [00 20]
    popaw                                               ; [61]
    je short 0x17E4                                     ; [74 20]
    add byte [0x0A0D], ch                               ; [00 2e 0d 0a]
    add byte [bx+si+0x6F], dl                           ; [00 50 6f]
    jb short 0x1841                                     ; [72 74]
    imul bp, word [bx+0x6E], 0x2073                     ; [69 6f 6e 73 20]
    inc bx                                              ; [43]
    outsw                                               ; [6f]
    jo short 0x184F                                     ; [70 79]
    jb short 0x1841                                     ; [72 69]
    db 0x67,0x68,0x74,0x20                         ; push 0x2074
    sub byte [bp+di+0x29], ah                           ; [28 63 29]
rtl_putchar_l17DF:
    and byte [bx+di], dh                                ; [20 31]
    cmp word [bx+si], di                                ; [39 38]
    xor bp, word [si]                                   ; [33 2c]
    cmp word [bx+si], si                                ; [39 30]
    and byte [bp+si+0x6F], al                           ; [20 42 6f]
    jb short 0x1858                                     ; [72 6c]
    popaw                                               ; [61]
    outsb                                               ; [6e]

; ------------------------------------------------------------------------------
; DATA  image:0x17EE .. 0x17EE   1 bytes
; ------------------------------------------------------------------------------
data_17EE:
    db 0x64                                          ; 0x17EE

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_alloc_far   image offset 0x17EF  <- called from 0x0012, 0x06C3, 0x0838, 0x098C, 0x0AE8, 0x0C20
; ------------------------------------------------------------------------------
rtl_alloc_far:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    call near 0x18B8                                    ; [e8 c0 00]
    pop bp                                              ; [5d]
    jb short 0x17FE                                     ; [72 03]
    retf 0x2                                            ; [ca 02 00]
rtl_alloc_far_l17FE:
    mov ax, 0xCB                                        ; [b8 cb 00]
    jmp near 0x1692                                     ; [e9 8e fe]
rtl_alloc_far_l1804:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    les cx,  [bp+0x8]                               ; [c4 4e 08]
    mov bx, es                                          ; [8c c3]
    call near 0x1983                                    ; [e8 71 01]
    pop bp                                              ; [5d]
    jb short 0x1818                                     ; [72 03]
    retf 0x6                                            ; [ca 06 00]
rtl_alloc_far_l1818:
    mov ax, 0xCC                                        ; [b8 cc 00]
    jmp near 0x1692                                     ; [e9 74 fe]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    cld                                                 ; [fc]
    mov ax, word [0x0068]                               ; [a1 68 00]
    stosw                                               ; [ab]
    mov ax, word [0x006A]                               ; [a1 6a 00]
rtl_alloc_far_l182C:
    stosw                                               ; [ab]
    retf 0x4                                            ; [ca 04 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    les di,  [es:di]                                ; [26 c4 3d]
    mov word [0x0068], di                               ; [89 3e 68 00]
    mov word [0x006A], es                               ; [8c 06 6a 00]
rtl_alloc_far_l1841:
    mov word [0x0070], di                               ; [89 3e 70 00]
    mov word [0x0072], es                               ; [8c 06 72 00]
    retf 0x4                                            ; [ca 04 00]
    mov bx, 0x2B1                                       ; [bb b1 02]
rtl_alloc_far_l184F:
    jmp short 0x1888                                    ; [eb 37]
rtl_alloc_far_l1851:
    add dx, word 0x1000                                 ; [81 c2 00 10]
    jmp short 0x185C                                    ; [eb 05]
rtl_alloc_far_l1857:
    add ax, word [si+0x4]                               ; [03 44 04]
    jb short 0x1851                                     ; [72 f5]
rtl_alloc_far_l185C:
    add dx, word [si+0x6]                               ; [03 54 06]
    lds si,  [si]                                   ; [c5 34]
    mov bx, ds                                          ; [8c db]
    db 0x3B,0xDF                                   ; cmp bx, di
    jne short 0x1857                                    ; [75 f0]
    ret                                                 ; [c3]
    mov bx, 0x2D1                                       ; [bb d1 02]
    jmp short 0x1888                                    ; [eb 1b]
rtl_alloc_far_l186D:
    cmp dx, word [si+0x6]                               ; [3b 54 06]
    ja short 0x187F                                     ; [77 0d]
    jb short 0x1879                                     ; [72 05]
    cmp ax, word [si+0x4]                               ; [3b 44 04]
    jae short 0x187F                                    ; [73 06]
rtl_alloc_far_l1879:
    mov ax, word [si+0x4]                               ; [8b 44 04]
    mov dx, word [si+0x6]                               ; [8b 54 06]
rtl_alloc_far_l187F:
    lds si,  [si]                                   ; [c5 34]
    mov bx, ds                                          ; [8c db]
    db 0x3B,0xDF                                   ; cmp bx, di
    jne short 0x186D                                    ; [75 e6]
    ret                                                 ; [c3]
rtl_alloc_far_l1888:
    mov ax, word [0x006C]                               ; [a1 6c 00]
    mov dx, word [0x006E]                               ; [8b 16 6e 00]
    sub ax, word [0x0068]                               ; [2b 06 68 00]
    sbb dx, word [0x006A]                               ; [1b 16 6a 00]
    and ax, strict word 0xF                             ; [25 0f 00]
    push ds                                             ; [1e]
    mov di, word [0x006A]                               ; [8b 3e 6a 00]
    lds si,  [0x0070]                               ; [c5 36 70 00]
    call bx                                             ; [ff d3]
    pop ds                                              ; [1f]
    mov cl, 0x4                                         ; [b1 04]
    rol dx, cl                                          ; [d3 c2]
    db 0x8B,0xCA                                   ; mov cx, dx
    and cl, byte 0xF0                                   ; [80 e1 f0]
    and dx, byte 0xF                                    ; [83 e2 0f]
    db 0x03,0xC1                                   ; add ax, cx
    adc dx, byte 0x0                                    ; [83 d2 00]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_alloc_far_impl   image offset 0x18B8  <- called from 0x17F5
; ------------------------------------------------------------------------------
rtl_alloc_far_impl:
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x1932                                     ; [74 76]
    mov word [0xFFD0], ax                               ; [a3 d0 ff]
rtl_alloc_far_impl_l18BF:
    call near 0x1A41                                    ; [e8 7f 01]
    mov di, 0x70                                        ; [bf 70 00]
    mov cx, ds                                          ; [8c d9]
    mov es, cx                                          ; [8e c1]
rtl_alloc_far_impl_l18C9:
    db 0x8B,0xCF                                   ; mov cx, di
    mov bx, es                                          ; [8c c3]
    les di,  [es:di]                                ; [26 c4 3d]
    mov si, es                                          ; [8c c6]
    cmp si, word [0x006A]                               ; [3b 36 6a 00]
    je short 0x1933                                     ; [74 5b]
    cmp dx, word [es:di+0x6]                            ; [26 3b 55 06]
    ja short 0x18C9                                     ; [77 eb]
    jb short 0x18E6                                     ; [72 06]
    cmp ax, word [es:di+0x4]                            ; [26 3b 45 04]
    ja short 0x18C9                                     ; [77 e3]
rtl_alloc_far_impl_l18E6:
    push es                                             ; [06]
    push di                                             ; [57]
    push bx                                             ; [53]
    push cx                                             ; [51]
    mov cx, word [es:di]                                ; [26 8b 0d]
    mov bx, word [es:di+0x2]                            ; [26 8b 5d 02]
    je short 0x1926                                     ; [74 33]
    push bx                                             ; [53]
    push cx                                             ; [51]
    mov cx, word [es:di+0x4]                            ; [26 8b 4d 04]
    mov bx, word [es:di+0x6]                            ; [26 8b 5d 06]
    db 0x2B,0xC8                                   ; sub cx, ax
    db 0x1B,0xDA                                   ; sbb bx, dx
    and cx, byte 0xF                                    ; [83 e1 0f]
    db 0x03,0xC7                                   ; add ax, di
    db 0x03,0xD6                                   ; add dx, si
    add al, 0xF0                                        ; [04 f0]
    adc dx, byte 0x0                                    ; [83 d2 00]
    and al, 0xF                                         ; [24 0f]
    db 0x8B,0xF8                                   ; mov di, ax
    mov es, dx                                          ; [8e c2]
    pop word [es:di]                                    ; [26 8f 05]
    pop word [es:di+0x2]                                ; [26 8f 45 02]
    mov word [es:di+0x4], cx                            ; [26 89 4d 04]
    mov word [es:di+0x6], bx                            ; [26 89 5d 06]
    db 0x8B,0xCF                                   ; mov cx, di
    mov bx, es                                          ; [8c c3]
rtl_alloc_far_impl_l1926:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di], cx                                ; [26 89 0d]
    mov word [es:di+0x2], bx                            ; [26 89 5d 02]
    pop ax                                              ; [58]
    pop dx                                              ; [5a]
    clc                                                 ; [f8]
rtl_alloc_far_impl_l1932:
    ret                                                 ; [c3]
rtl_alloc_far_impl_l1933:
    db 0x03,0xC7                                   ; add ax, di
    db 0x03,0xD6                                   ; add dx, si
    add al, 0xF0                                        ; [04 f0]
    adc dx, byte 0x0                                    ; [83 d2 00]
    and al, 0xF                                         ; [24 0f]
    cmp dx, word [0x006E]                               ; [3b 16 6e 00]
    jb short 0x194C                                     ; [72 08]
    ja short 0x196B                                     ; [77 25]
    cmp ax, word [0x006C]                               ; [3b 06 6c 00]
    ja short 0x196B                                     ; [77 1f]
rtl_alloc_far_impl_l194C:
    push es                                             ; [06]
    push di                                             ; [57]
    db 0x8B,0xF9                                   ; mov di, cx
    mov es, bx                                          ; [8e c3]
    mov word [0x0068], ax                               ; [a3 68 00]
    mov word [0x006A], dx                               ; [89 16 6a 00]
    mov word [es:di], ax                                ; [26 89 05]
    mov word [es:di+0x2], dx                            ; [26 89 55 02]
    db 0x33,0xC0                                   ; xor ax, ax
    push ax                                             ; [50]
    db 0xFF,0x1E,0x78,0x00                         ; call dword [0x0078]
    pop ax                                              ; [58]
    pop dx                                              ; [5a]
    clc                                                 ; [f8]
    ret                                                 ; [c3]
rtl_alloc_far_impl_l196B:
    push word [-0x30]                                   ; [ff 36 d0 ff]
    db 0xFF,0x1E,0x78,0x00                         ; call dword [0x0078]
    cmp al, 0x1                                         ; [3c 01]
    jb short 0x1932                                     ; [72 bb]
    je short 0x197F                                     ; [74 06]
    mov ax, word [0xFFD0]                               ; [a1 d0 ff]
    jmp near 0x18BF                                     ; [e9 40 ff]
rtl_alloc_far_impl_l197F:
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x99                                        ; cwd
    ret                                                 ; [c3]
rtl_alloc_far_impl_l1983:
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x19E1                                     ; [74 5a]
    test cx, 0xFFF7                                     ; [f7 c1 f7 ff]
    jne short 0x19E0                                    ; [75 53]
    cmp bx, word [0x0066]                               ; [3b 1e 66 00]
    ja short 0x199B                                     ; [77 08]
    jb short 0x19E0                                     ; [72 4b]
    cmp cx, word [0x0064]                               ; [3b 0e 64 00]
    jb short 0x19E0                                     ; [72 45]
rtl_alloc_far_impl_l199B:
    cmp bx, word [0x006A]                               ; [3b 1e 6a 00]
    jb short 0x19A9                                     ; [72 08]
    ja short 0x19E0                                     ; [77 3d]
    cmp cx, word [0x0068]                               ; [3b 0e 68 00]
    jae short 0x19E0                                    ; [73 37]
rtl_alloc_far_impl_l19A9:
    call near 0x1A41                                    ; [e8 95 00]
    db 0x8B,0xF9                                   ; mov di, cx
    mov es, bx                                          ; [8e c3]
    mov word [es:di+0x4], ax                            ; [26 89 45 04]
    mov word [es:di+0x6], dx                            ; [26 89 55 06]
    mov di, 0x70                                        ; [bf 70 00]
    mov ax, ds                                          ; [8c d8]
    mov es, ax                                          ; [8e c0]
rtl_alloc_far_impl_l19BF:
    db 0x8B,0xC7                                   ; mov ax, di
    mov dx, es                                          ; [8c c2]
    les di,  [es:di]                                ; [26 c4 3d]
    mov si, es                                          ; [8c c6]
    db 0x3B,0xDE                                   ; cmp bx, si
    ja short 0x19BF                                     ; [77 f3]
    jb short 0x19D4                                     ; [72 06]
    db 0x3B,0xCF                                   ; cmp cx, di
    ja short 0x19BF                                     ; [77 ed]
    je short 0x19E0                                     ; [74 0c]
rtl_alloc_far_impl_l19D4:
    push dx                                             ; [52]
    push ax                                             ; [50]
    call near 0x19E2                                    ; [e8 09 00]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    call near 0x19E2                                    ; [e8 04 00]
    clc                                                 ; [f8]
    ret                                                 ; [c3]
rtl_alloc_far_impl_l19E0:
    stc                                                 ; [f9]
rtl_alloc_far_impl_l19E1:
    ret                                                 ; [c3]
rtl_alloc_far_impl_l19E2:
    db 0x8B,0xC7                                   ; mov ax, di
    mov dx, es                                          ; [8c c2]
    db 0x8B,0xF9                                   ; mov di, cx
    mov es, bx                                          ; [8e c3]
    add cx, word [es:di+0x4]                            ; [26 03 4d 04]
    add bx, word [es:di+0x6]                            ; [26 03 5d 06]
    add cl, byte 0xF0                                   ; [80 c1 f0]
    adc bx, byte 0x0                                    ; [83 d3 00]
    and cl, byte 0xF                                    ; [80 e1 0f]
    db 0x3B,0xDA                                   ; cmp bx, dx
    jne short 0x1A39                                    ; [75 3a]
    db 0x3B,0xC8                                   ; cmp cx, ax
    jne short 0x1A39                                    ; [75 36]
    cmp dx, word [0x006A]                               ; [3b 16 6a 00]
    jne short 0x1A18                                    ; [75 0f]
    cmp ax, word [0x0068]                               ; [3b 06 68 00]
    jne short 0x1A18                                    ; [75 09]
    mov word [0x0068], di                               ; [89 3e 68 00]
    mov word [0x006A], es                               ; [8c 06 6a 00]
    ret                                                 ; [c3]
rtl_alloc_far_impl_l1A18:
    push ds                                             ; [1e]
    push di                                             ; [57]
    db 0x8B,0xF0                                   ; mov si, ax
    mov ds, dx                                          ; [8e da]
    cld                                                 ; [fc]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    lodsw                                               ; [ad]
    xchg dx, ax                                         ; [92]
    lodsw                                               ; [ad]
    xchg dx, ax                                         ; [92]
    add ax, word [es:di]                                ; [26 03 05]
    add dx, word [es:di+0x2]                            ; [26 03 55 02]
    add al, 0xF0                                        ; [04 f0]
    adc dx, byte 0x0                                    ; [83 d2 00]
    and al, 0xF                                         ; [24 0f]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    pop di                                              ; [5f]
    pop ds                                              ; [1f]
    ret                                                 ; [c3]
rtl_alloc_far_impl_l1A39:
    mov word [es:di], ax                                ; [26 89 05]
    mov word [es:di+0x2], dx                            ; [26 89 55 02]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_bytes_to_paras   image offset 0x1A41  <- called from 0x18BF
; ------------------------------------------------------------------------------
rtl_bytes_to_paras:
    add ax, strict word 0x7                             ; [05 07 00]
    db 0x8B,0xD0                                   ; mov dx, ax
    rcr dx, 0x1                                         ; [d1 da]
    shr dx, 0x1                                         ; [d1 ea]
    shr dx, 0x1                                         ; [d1 ea]
    shr dx, 0x1                                         ; [d1 ea]
    and ax, strict word 0x8                             ; [25 08 00]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_geterrno_clear   image offset 0x1A52  <- called from 0x0DFD
; ------------------------------------------------------------------------------
rtl_geterrno_clear:
    db 0x33,0xC0                                   ; xor ax, ax
    xchg word [dos_errno], ax                           ; [87 06 8a 00]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_errno_check   image offset 0x1A59  <- called from 0x02F5, 0x0311, 0x032D, 0x0360, 0x037D, 0x03CF, 0x03EC, 0x0449
; ------------------------------------------------------------------------------
rtl_errno_check:
    cmp word [dos_errno], 0x0                           ; [83 3e 8a 00 00]
    jne short 0x1A61                                    ; [75 01]
    retf                                                ; [cb]
rtl_errno_check_l1A61:
    mov ax, word [dos_errno]                            ; [a1 8a 00]
    jmp near 0x1692                                     ; [e9 2b fc]
    db 0x8B,0xF4                                   ; mov si, sp
    mov es, word [ss:si+0x2]                            ; [36 8e 44 02]
    cmp dx, word [es:di+0x2]                            ; [26 3b 55 02]
    jg short 0x1A7A                                     ; [7f 07]
    jl short 0x1A89                                     ; [7c 14]
    cmp ax, word [es:di]                                ; [26 3b 05]
    jb short 0x1A89                                     ; [72 0f]
rtl_errno_check_l1A7A:
    cmp dx, word [es:di+0x6]                            ; [26 3b 55 06]
    jl short 0x1A88                                     ; [7c 08]
    jg short 0x1A89                                     ; [7f 07]
    cmp ax, word [es:di+0x4]                            ; [26 3b 45 04]
    ja short 0x1A89                                     ; [77 01]
rtl_errno_check_l1A88:
    retf                                                ; [cb]
rtl_errno_check_l1A89:
    mov ax, 0xC9                                        ; [b8 c9 00]
    jmp near 0x1692                                     ; [e9 03 fc]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_stack_check   image offset 0x1A8F  <- called from 0x0006, 0x0048, 0x00E7, 0x011D, 0x02DF
; ------------------------------------------------------------------------------
rtl_stack_check:
    add ax, 0x200                                       ; [05 00 02]
    db 0x2B,0xC4                                   ; sub ax, sp
    jae short 0x1A9F                                    ; [73 09]
    neg ax                                              ; [f7 d8]
    cmp ax, word [stack_margin]                         ; [3b 06 88 00]
    jb short 0x1A9F                                     ; [72 01]
    retf                                                ; [cb]
rtl_stack_check_l1A9F:
    mov ax, 0xCA                                        ; [b8 ca 00]
    jmp near 0x1692                                     ; [e9 ed fb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_memcpy_far   image offset 0x1AA5  <- called from 0x163D, 0x1651
; ------------------------------------------------------------------------------
rtl_memcpy_far:
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    les di,  [ss:bx+0x8]                            ; [36 c4 7f 08]
    lds si,  [ss:bx+0x4]                            ; [36 c5 77 04]
    cld                                                 ; [fc]
    db 0x33,0xC0                                   ; xor ax, ax
    stosw                                               ; [ab]
    mov ax, 0xD7B0                                      ; [b8 b0 d7]
    stosw                                               ; [ab]
    mov ax, 0x80                                        ; [b8 80 00]
    stosw                                               ; [ab]
    db 0x33,0xC0                                   ; xor ax, ax
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    lea ax, word [di+0x74]                              ; [8d 45 74]
    stosw                                               ; [ab]
    mov ax, es                                          ; [8c c0]
    stosw                                               ; [ab]
    mov ax, 0x60C                                       ; [b8 0c 06]
    stosw                                               ; [ab]
    mov ax, cs                                          ; [8c c8]
    stosw                                               ; [ab]
    db 0x33,0xC0                                   ; xor ax, ax
    mov cx, 0xE                                         ; [b9 0e 00]
    db 0xF3,0xAB                                   ; rep stosw word [es:di], ax
    lodsb                                               ; [ac]
    cmp al, 0x4F                                        ; [3c 4f]
    jbe short 0x1ADD                                    ; [76 02]
    mov al, 0x4F                                        ; [b0 4f]
rtl_memcpy_far_l1ADD:
    db 0x8A,0xC8                                   ; mov cl, al
    db 0x32,0xED                                   ; xor ch, ch
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    db 0x32,0xC0                                   ; xor al, al
    stosb                                               ; [aa]
    pop ds                                              ; [1f]
    retf 0x8                                            ; [ca 08 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0xA]                            ; [36 c4 7f 0a]
    mov ax, word [ss:bx+0x4]                            ; [36 8b 47 04]
    mov word [es:di+0x4], ax                            ; [26 89 45 04]
    mov ax, word [ss:bx+0x6]                            ; [36 8b 47 06]
    mov word [es:di+0xC], ax                            ; [26 89 45 0c]
    mov ax, word [ss:bx+0x8]                            ; [36 8b 47 08]
    mov word [es:di+0xE], ax                            ; [26 89 45 0e]
    db 0x33,0xC0                                   ; xor ax, ax
    mov word [es:di+0x8], ax                            ; [26 89 45 08]
    mov word [es:di+0xA], ax                            ; [26 89 45 0a]
    retf 0xA                                            ; [ca 0a 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_alloc_huge   image offset 0x1B15  <- called from 0x1641
; ------------------------------------------------------------------------------
rtl_alloc_huge:
    mov dx, 0xD7B1                                      ; [ba b1 d7]
    jmp short 0x1B22                                    ; [eb 08]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_alloc_big   image offset 0x1B1A  <- called from 0x1655
; ------------------------------------------------------------------------------
rtl_alloc_big:
    mov dx, 0xD7B2                                      ; [ba b2 d7]
    jmp short 0x1B22                                    ; [eb 03]

; ------------------------------------------------------------------------------
; DATA  image:0x1B1F .. 0x1B21   3 bytes
; ------------------------------------------------------------------------------
data_1B1F:
    db 0xBA,0xB3,0xD7                                ; 0x1B1F
rtl_alloc_big_l1B22:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    cmp ax, 0xD7B1                                      ; [3d b1 d7]
    je short 0x1B43                                     ; [74 12]
    cmp ax, 0xD7B2                                      ; [3d b2 d7]
    je short 0x1B43                                     ; [74 0d]
    cmp ax, 0xD7B0                                      ; [3d b0 d7]
    je short 0x1B4B                                     ; [74 10]
    mov word [dos_errno], 0x66                          ; [c7 06 8a 00 66 00]
    jmp short 0x1B67                                    ; [eb 24]
rtl_alloc_big_l1B43:
    push dx                                             ; [52]
    push es                                             ; [06]
    push di                                             ; [57]
    push cs                                             ; [0e]
    call near 0x1B6F                                    ; [e8 25 00]
    pop dx                                              ; [5a]
rtl_alloc_big_l1B4B:
    db 0x33,0xC0                                   ; xor ax, ax
    mov word [es:di+0x2], dx                            ; [26 89 55 02]
    mov word [es:di+0x8], ax                            ; [26 89 45 08]
    mov word [es:di+0xA], ax                            ; [26 89 45 0a]
    mov bx, 0x10                                        ; [bb 10 00]
    call near 0x1BAB                                    ; [e8 4c 00]
    je short 0x1B67                                     ; [74 06]
    mov word [es:di+0x2], 0xD7B0                        ; [26 c7 45 02 b0 d7]
rtl_alloc_big_l1B67:
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
; DATA  image:0x1B6B .. 0x1B6E   4 bytes
; ------------------------------------------------------------------------------
data_1B6B:
    db 0xB0,0x00,0xEB,0x02                           ; 0x1B6B

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_free_far   image offset 0x1B6F  <- called from 0x16F6, 0x16FF, 0x1B47
; ------------------------------------------------------------------------------
rtl_free_far:
    mov al, 0x1                                         ; [b0 01]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    cmp word [es:di+0x2], 0xD7B1                        ; [26 81 7d 02 b1 d7]
    je short 0x1B97                                     ; [74 18]
    cmp word [es:di+0x2], 0xD7B2                        ; [26 81 7d 02 b2 d7]
    je short 0x1B8F                                     ; [74 08]
    mov word [dos_errno], 0x67                          ; [c7 06 8a 00 67 00]
    jmp short 0x1BA7                                    ; [eb 18]
rtl_free_far_l1B8F:
    push ax                                             ; [50]
    mov bx, 0x14                                        ; [bb 14 00]
    call near 0x1BAB                                    ; [e8 15 00]
    pop ax                                              ; [58]
rtl_free_far_l1B97:
    db 0x0A,0xC0                                   ; or al, al
    je short 0x1BA7                                     ; [74 0c]
    mov bx, 0x1C                                        ; [bb 1c 00]
    call near 0x1BAB                                    ; [e8 0a 00]
    mov word [es:di+0x2], 0xD7B0                        ; [26 c7 45 02 b0 d7]
rtl_free_far_l1BA7:
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_free_far_impl   image offset 0x1BAB  <- called from 0x1B5C, 0x1B93, 0x1B9E
; ------------------------------------------------------------------------------
rtl_free_far_impl:
    push es                                             ; [06]
    push di                                             ; [57]
    push es                                             ; [06]
    push di                                             ; [57]
    db 0x26,0xFF,0x19                              ; call dword [es:bx+di]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x1BB9                                     ; [74 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_free_far_impl_l1BB9:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    ret                                                 ; [c3]
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    lds di,  [ss:bx+0x4]                            ; [36 c5 7f 04]
    db 0x33,0xC9                                   ; xor cx, cx
    mov word [di], cx                                   ; [89 0d]
    mov ax, 0x3D00                                      ; [b8 00 3d]
    cmp word [di+0x2], 0xD7B1                           ; [81 7d 02 b1 d7]
    je short 0x1BDE                                     ; [74 0d]
    mov al, 0x2                                         ; [b0 02]
    inc word [di]                                       ; [ff 05]
    cmp word [di+0x2], 0xD7B3                           ; [81 7d 02 b3 d7]
    je short 0x1BDE                                     ; [74 02]
    mov ah, 0x3C                                        ; [b4 3c]
rtl_free_far_impl_l1BDE:
    cmp byte [di+0x30], 0x0                             ; [80 7d 30 00]
    je short 0x1BED                                     ; [74 09]
    lea dx, word [di+0x30]                              ; [8d 55 30]
    int 0x21                                            ; [cd 21]
    jb short 0x1C3A                                     ; [72 4f]
    mov word [di], ax                                   ; [89 05]
rtl_free_far_impl_l1BED:
    mov ax, 0x6E8                                       ; [b8 e8 06]
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x8B,0xD9                                   ; mov bx, cx
    cmp word [di+0x2], 0xD7B1                           ; [81 7d 02 b1 d7]
    je short 0x1C24                                     ; [74 29]
    mov bx, word [di]                                   ; [8b 1d]
    mov ax, 0x4400                                      ; [b8 00 44]
    int 0x21                                            ; [cd 21]
    mov ax, 0x73D                                       ; [b8 3d 07]
    db 0x8B,0xC8                                   ; mov cx, ax
    mov bx, cs                                          ; [8c cb]
    test dl, 0x80                                       ; [f6 c2 80]
    jne short 0x1C1F                                    ; [75 11]
    cmp word [di+0x2], 0xD7B3                           ; [81 7d 02 b3 d7]
    jne short 0x1C18                                    ; [75 03]
    call near 0x1C3E                                    ; [e8 26 00]
rtl_free_far_impl_l1C18:
    mov ax, 0x718                                       ; [b8 18 07]
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x8B,0xD9                                   ; mov bx, cx
rtl_free_far_impl_l1C1F:
    mov word [di+0x2], 0xD7B2                           ; [c7 45 02 b2 d7]
rtl_free_far_impl_l1C24:
    mov word [di+0x14], ax                              ; [89 45 14]
    mov word [di+0x16], cs                              ; [8c 4d 16]
    mov word [di+0x18], cx                              ; [89 4d 18]
    mov word [di+0x1A], bx                              ; [89 5d 1a]
    mov word [di+0x1C], 0x75D                           ; [c7 45 1c 5d 07]
    mov word [di+0x1E], cs                              ; [8c 4d 1e]
    db 0x33,0xC0                                   ; xor ax, ax
rtl_free_far_impl_l1C3A:
    pop ds                                              ; [1f]
    retf 0x4                                            ; [ca 04 00]
rtl_free_far_impl_l1C3E:
    db 0x33,0xD2                                   ; xor dx, dx
    db 0x33,0xC9                                   ; xor cx, cx
    mov bx, word [di]                                   ; [8b 1d]
    mov ax, 0x4202                                      ; [b8 02 42]
    int 0x21                                            ; [cd 21]
    sub ax, 0x80                                        ; [2d 80 00]
    sbb dx, byte 0x0                                    ; [83 da 00]
    jae short 0x1C55                                    ; [73 04]
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x33,0xD2                                   ; xor dx, dx
rtl_free_far_impl_l1C55:
    db 0x8B,0xCA                                   ; mov cx, dx
    db 0x8B,0xD0                                   ; mov dx, ax
    mov bx, word [di]                                   ; [8b 1d]
    mov ax, 0x4200                                      ; [b8 00 42]
    int 0x21                                            ; [cd 21]
    lea dx, word [di+0x80]                              ; [8d 95 80 00]
    mov cx, 0x80                                        ; [b9 80 00]
    mov bx, word [di]                                   ; [8b 1d]
    mov ah, 0x3F                                        ; [b4 3f]
    int 0x21                                            ; [cd 21]
    jae short 0x1C71                                    ; [73 02]
    db 0x33,0xC0                                   ; xor ax, ax
rtl_free_far_impl_l1C71:
    db 0x33,0xDB                                   ; xor bx, bx
rtl_free_far_impl_l1C73:
    db 0x3B,0xD8                                   ; cmp bx, ax
    je short 0x1C97                                     ; [74 20]
    cmp byte [bx+di+0x80], 0x1A                         ; [80 b9 80 00 1a]
    je short 0x1C81                                     ; [74 03]
    inc bx                                              ; [43]
    jmp short 0x1C73                                    ; [eb f2]
rtl_free_far_impl_l1C81:
    db 0x8B,0xD3                                   ; mov dx, bx
    db 0x2B,0xD0                                   ; sub dx, ax
    mov cx, 0xFFFF                                      ; [b9 ff ff]
    mov bx, word [di]                                   ; [8b 1d]
    mov ax, 0x4202                                      ; [b8 02 42]
    int 0x21                                            ; [cd 21]
    db 0x33,0xC9                                   ; xor cx, cx
    mov bx, word [di]                                   ; [8b 1d]
    mov ah, 0x40                                        ; [b4 40]
    int 0x21                                            ; [cd 21]
rtl_free_far_impl_l1C97:
    ret                                                 ; [c3]
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    lds dx,  [es:di+0xC]                            ; [26 c5 55 0c]
    mov cx, word [es:di+0x4]                            ; [26 8b 4d 04]
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ah, 0x3F                                        ; [b4 3f]
    int 0x21                                            ; [cd 21]
    jb short 0x1CC0                                     ; [72 10]
    mov word [es:di+0xA], ax                            ; [26 89 45 0a]
    db 0x33,0xC0                                   ; xor ax, ax
rtl_free_far_impl_l1CB6:
    mov word [es:di+0x8], 0x0                           ; [26 c7 45 08 00 00]
    pop ds                                              ; [1f]
    retf 0x4                                            ; [ca 04 00]
rtl_free_far_impl_l1CC0:
    mov word [es:di+0xA], 0x0                           ; [26 c7 45 0a 00 00]
    jmp short 0x1CB6                                    ; [eb ee]
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    lds dx,  [es:di+0xC]                            ; [26 c5 55 0c]
    db 0x33,0xC9                                   ; xor cx, cx
    xchg word [es:di+0x8], cx                           ; [26 87 4d 08]
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ah, 0x40                                        ; [b4 40]
    int 0x21                                            ; [cd 21]
    jb short 0x1CE9                                     ; [72 07]
    db 0x2B,0xC1                                   ; sub ax, cx
    je short 0x1CE9                                     ; [74 03]
    mov ax, 0x65                                        ; [b8 65 00]
rtl_free_far_impl_l1CE9:
    pop ds                                              ; [1f]
    retf 0x4                                            ; [ca 04 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    lds dx,  [es:di+0xC]                            ; [26 c5 55 0c]
    db 0x33,0xC9                                   ; xor cx, cx
    xchg word [es:di+0x8], cx                           ; [26 87 4d 08]
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ah, 0x40                                        ; [b4 40]
    int 0x21                                            ; [cd 21]
    jb short 0x1D09                                     ; [72 02]
    db 0x33,0xC0                                   ; xor ax, ax
rtl_free_far_impl_l1D09:
    pop ds                                              ; [1f]
    retf 0x4                                            ; [ca 04 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    mov bx, word [es:di]                                ; [26 8b 1d]
    cmp bx, byte 0x4                                    ; [83 fb 04]
    jbe short 0x1D21                                    ; [76 06]
    mov ah, 0x3E                                        ; [b4 3e]
    int 0x21                                            ; [cd 21]
    jb short 0x1D23                                     ; [72 02]
rtl_free_far_impl_l1D21:
    db 0x33,0xC0                                   ; xor ax, ax
rtl_free_far_impl_l1D23:
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_stream_write_chk   image offset 0x1D26  <- called from 0x1DD2, 0x1E98
; ------------------------------------------------------------------------------
rtl_stream_write_chk:
    cmp word [dos_errno], 0x0                           ; [83 3e 8a 00 00]
    jne short 0x1D35                                    ; [75 08]
    cmp word [es:di+0x2], 0xD7B1                        ; [26 81 7d 02 b1 d7]
    jne short 0x1D42                                    ; [75 0d]
rtl_stream_write_chk_l1D35:
    mov bx, word [es:di+0x8]                            ; [26 8b 5d 08]
    mov dx, word [es:di+0xA]                            ; [26 8b 55 0a]
    les di,  [es:di+0xC]                            ; [26 c4 7d 0c]
    ret                                                 ; [c3]
rtl_stream_write_chk_l1D42:
    mov word [dos_errno], 0x68                          ; [c7 06 8a 00 68 00]
    jmp short 0x1D35                                    ; [eb eb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_stream_read_chk   image offset 0x1D4A  <- called from 0x1DD7, 0x1DE3, 0x1EA3
; ------------------------------------------------------------------------------
rtl_stream_read_chk:
    db 0x3B,0xDA                                   ; cmp bx, dx
    je short 0x1D53                                     ; [74 05]
rtl_stream_read_chk_l1D4E:
    mov al, byte [es:bx+di]                             ; [26 8a 01]
    clc                                                 ; [f8]
    ret                                                 ; [c3]
rtl_stream_read_chk_l1D53:
    db 0x8B,0xFC                                   ; mov di, sp
    les di,  [ss:di+0x2]                            ; [36 c4 7d 02]
    call near 0x1D99                                    ; [e8 3d 00]
    db 0x8B,0xD0                                   ; mov dx, ax
    db 0x3B,0xDA                                   ; cmp bx, dx
    jne short 0x1D4E                                    ; [75 ec]
    mov al, 0x1A                                        ; [b0 1a]
    stc                                                 ; [f9]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fflush_check   image offset 0x1D66  <- called from 0x1E00, 0x1E6D, 0x1ED0, 0x1F76
; ------------------------------------------------------------------------------
rtl_fflush_check:
    cmp word [dos_errno], 0x0                           ; [83 3e 8a 00 00]
    jne short 0x1D75                                    ; [75 08]
    cmp word [es:di+0x2], 0xD7B2                        ; [26 81 7d 02 b2 d7]
    jne short 0x1D82                                    ; [75 0d]
rtl_fflush_check_l1D75:
    mov bx, word [es:di+0x8]                            ; [26 8b 5d 08]
    mov dx, word [es:di+0x4]                            ; [26 8b 55 04]
    les di,  [es:di+0xC]                            ; [26 c4 7d 0c]
    ret                                                 ; [c3]
rtl_fflush_check_l1D82:
    mov word [dos_errno], 0x69                          ; [c7 06 8a 00 69 00]
    jmp short 0x1D75                                    ; [eb eb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_stream_putc   image offset 0x1D8A  <- called from 0x1E07, 0x1E0C, 0x1E7A, 0x1E82, 0x1EE5, 0x1EF5, 0x1F88, 0x1F95
; ------------------------------------------------------------------------------
rtl_stream_putc:
    mov byte [es:bx+di], al                             ; [26 88 01]
    inc bx                                              ; [43]
    db 0x3B,0xDA                                   ; cmp bx, dx
    je short 0x1D93                                     ; [74 01]
    ret                                                 ; [c3]
rtl_stream_putc_l1D93:
    db 0x8B,0xFC                                   ; mov di, sp
    les di,  [ss:di+0x2]                            ; [36 c4 7d 02]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_stream_flush   image offset 0x1D99  <- called from 0x1D59
; ------------------------------------------------------------------------------
rtl_stream_flush:
    push cx                                             ; [51]
    push si                                             ; [56]
    push ds                                             ; [1e]
    mov dx, 0x53C                                       ; [ba 3c 05]
    mov ds, dx                                          ; [8e da]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    push es                                             ; [06]
    push di                                             ; [57]
    push es                                             ; [06]
    push di                                             ; [57]
    db 0x26,0xFF,0x5D,0x14                         ; call dword [es:di+0x14]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x1DB4                                     ; [74 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_stream_flush_l1DB4:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov ax, word [es:di+0xA]                            ; [26 8b 45 0a]
    mov bx, word [es:di+0x8]                            ; [26 8b 5d 08]
    mov dx, word [es:di+0x4]                            ; [26 8b 55 04]
    les di,  [es:di+0xC]                            ; [26 c4 7d 0c]
    pop ds                                              ; [1f]
    pop si                                              ; [5e]
    pop cx                                              ; [59]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fflush   image offset 0x1DCA  <- called from 0x0378, 0x03E7, 0x0E76
; ------------------------------------------------------------------------------
rtl_fflush:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D26                                    ; [e8 51 ff]
    jne short 0x1DEB                                    ; [75 14]
rtl_fflush_l1DD7:
    call near 0x1D4A                                    ; [e8 70 ff]
    cmp al, 0x1A                                        ; [3c 1a]
    je short 0x1DEB                                     ; [74 0d]
    inc bx                                              ; [43]
    cmp al, 0xD                                         ; [3c 0d]
    jne short 0x1DD7                                    ; [75 f4]
    call near 0x1D4A                                    ; [e8 64 ff]
    cmp al, 0xA                                         ; [3c 0a]
    jne short 0x1DEB                                    ; [75 01]
    inc bx                                              ; [43]
rtl_fflush_l1DEB:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    call near 0x1E29                                    ; [e8 35 00]
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fputs   image offset 0x1DF8  <- called from 0x02F0, 0x030C, 0x0328, 0x0444, 0x046D, 0x047C, 0x0498, 0x04B4
; ------------------------------------------------------------------------------
rtl_fputs:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D66                                    ; [e8 63 ff]
    jne short 0x1E0F                                    ; [75 0a]
    mov al, 0xD                                         ; [b0 0d]
    call near 0x1D8A                                    ; [e8 80 ff]
    mov al, 0xA                                         ; [b0 0a]
    call near 0x1D8A                                    ; [e8 7b ff]
rtl_fputs_l1E0F:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    call near 0x1E29                                    ; [e8 11 00]
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fclose_stream   image offset 0x1E1C  <- called from 0x035B, 0x03CA, 0x1068
; ------------------------------------------------------------------------------
rtl_fclose_stream:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    call near 0x1E29                                    ; [e8 04 00]
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fclose_impl   image offset 0x1E29  <- called from 0x1DF1, 0x1E15, 0x1E22
; ------------------------------------------------------------------------------
rtl_fclose_impl:
    cmp word [es:di+0x1A], 0x0                          ; [26 83 7d 1a 00]
    jne short 0x1E31                                    ; [75 01]
    ret                                                 ; [c3]
rtl_fclose_impl_l1E31:
    cmp word [dos_errno], 0x0                           ; [83 3e 8a 00 00]
    jne short 0x1E45                                    ; [75 0d]
    push es                                             ; [06]
    push di                                             ; [57]
    db 0x26,0xFF,0x5D,0x18                         ; call dword [es:di+0x18]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x1E45                                     ; [74 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_fclose_impl_l1E45:
    ret                                                 ; [c3]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x6]                               ; [c4 7e 06]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D26                                    ; [e8 d5 fe]
    jne short 0x1E61                                    ; [75 0e]
    call near 0x1D4A                                    ; [e8 f4 fe]
    jb short 0x1E59                                     ; [72 01]
    inc bx                                              ; [43]
rtl_fclose_impl_l1E59:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    pop bp                                              ; [5d]
    retf                                                ; [cb]
rtl_fclose_impl_l1E61:
    mov al, 0x1A                                        ; [b0 1a]
    jmp short 0x1E59                                    ; [eb f4]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fputc_w   image offset 0x1E65  <- called from 0x1047
; ------------------------------------------------------------------------------
rtl_fputc_w:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D66                                    ; [e8 f6 fe]
    jne short 0x1E85                                    ; [75 13]
    mov cx, word [bp+0x6]                               ; [8b 4e 06]
    dec cx                                              ; [49]
    jle short 0x1E7F                                    ; [7e 07]
rtl_fputc_w_l1E78:
    mov al, 0x20                                        ; [b0 20]
    call near 0x1D8A                                    ; [e8 0d ff]
    loop 0x1E78                                         ; [e2 f9]
rtl_fputc_w_l1E7F:
    mov al, byte [bp+0x8]                               ; [8a 46 08]
    call near 0x1D8A                                    ; [e8 05 ff]
rtl_fputc_w_l1E85:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fwrite_w   image offset 0x1E8F  <- called from 0x0373, 0x03E2, 0x0E71
; ------------------------------------------------------------------------------
rtl_fwrite_w:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push ds                                             ; [1e]
    les di,  [bp+0xC]                               ; [c4 7e 0c]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D26                                    ; [e8 8b fe]
    lds si,  [bp+0x8]                               ; [c5 76 08]
    mov cx, 0x0                                         ; [b9 00 00]
    jne short 0x1EB8                                    ; [75 15]
rtl_fwrite_w_l1EA3:
    call near 0x1D4A                                    ; [e8 a4 fe]
    cmp al, 0xD                                         ; [3c 0d]
    je short 0x1EB8                                     ; [74 0e]
    cmp al, 0x1A                                        ; [3c 1a]
    je short 0x1EB8                                     ; [74 0a]
    inc bx                                              ; [43]
    inc cx                                              ; [41]
    inc si                                              ; [46]
    mov byte [si], al                                   ; [88 04]
    cmp cx, word [bp+0x6]                               ; [3b 4e 06]
    jne short 0x1EA3                                    ; [75 eb]
rtl_fwrite_w_l1EB8:
    db 0x2B,0xF1                                   ; sub si, cx
    mov byte [si], cl                                   ; [88 0c]
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    pop ds                                              ; [1f]
    pop bp                                              ; [5d]
    retf 0x6                                            ; [ca 06 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fwrite_pad   image offset 0x1EC7  <- called from 0x0307, 0x0323, 0x0356, 0x03C5, 0x041D, 0x043F, 0x045B, 0x0468
; ------------------------------------------------------------------------------
rtl_fwrite_pad:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push ds                                             ; [1e]
    les di,  [bp+0xC]                               ; [c4 7e 0c]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D66                                    ; [e8 93 fe]
    jne short 0x1EFA                                    ; [75 25]
    lds si,  [bp+0x8]                               ; [c5 76 08]
    mov cx, word [bp+0x6]                               ; [8b 4e 06]
    cld                                                 ; [fc]
    lodsb                                               ; [ac]
    db 0x32,0xE4                                   ; xor ah, ah
    db 0x2B,0xC8                                   ; sub cx, ax
    jle short 0x1EEF                                    ; [7e 0c]
rtl_fwrite_pad_l1EE3:
    mov al, 0x20                                        ; [b0 20]
    call near 0x1D8A                                    ; [e8 a2 fe]
    loop 0x1EE3                                         ; [e2 f9]
    mov al, byte [si-0x1]                               ; [8a 44 ff]
    db 0x32,0xE4                                   ; xor ah, ah
rtl_fwrite_pad_l1EEF:
    db 0x8B,0xC8                                   ; mov cx, ax
    jcxz 0x1EFA                                         ; [e3 07]
rtl_fwrite_pad_l1EF3:
    cld                                                 ; [fc]
    lodsb                                               ; [ac]
    call near 0x1D8A                                    ; [e8 92 fe]
    loop 0x1EF3                                         ; [e2 f9]
rtl_fwrite_pad_l1EFA:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    pop ds                                              ; [1f]
    pop bp                                              ; [5d]
    retf 0x6                                            ; [ca 06 00]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    sub sp, byte 0x20                                   ; [83 ec 20]
    les di,  [bp+0x6]                               ; [c4 7e 06]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D26                                    ; [e8 13 fe]
    mov si, 0x0                                         ; [be 00 00]
    jne short 0x1F39                                    ; [75 21]
rtl_fwrite_pad_l1F18:
    call near 0x1D4A                                    ; [e8 2f fe]
    cmp al, 0x1A                                        ; [3c 1a]
    je short 0x1F39                                     ; [74 1a]
    cmp al, 0x20                                        ; [3c 20]
    ja short 0x1F26                                     ; [77 03]
    inc bx                                              ; [43]
    jmp short 0x1F18                                    ; [eb f2]
rtl_fwrite_pad_l1F26:
    call near 0x1D4A                                    ; [e8 21 fe]
    cmp al, 0x20                                        ; [3c 20]
    jbe short 0x1F39                                    ; [76 0c]
    inc bx                                              ; [43]
    cmp si, byte 0x20                                   ; [83 fe 20]
    je short 0x1F26                                     ; [74 f3]
    mov byte [bp+si-0x20], al                           ; [88 42 e0]
    inc si                                              ; [46]
    jmp short 0x1F26                                    ; [eb ed]
rtl_fwrite_pad_l1F39:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    db 0x8B,0xCE                                   ; mov cx, si
    jcxz 0x1F55                                         ; [e3 12]
    lea di, word [bp-0x20]                              ; [8d 7e e0]
    push ss                                             ; [16]
    pop es                                              ; [07]
    call near 0x5021                                    ; [e8 d6 30]
    jb short 0x1F4F                                     ; [72 02]
    jcxz 0x1F59                                         ; [e3 0a]
rtl_fwrite_pad_l1F4F:
    mov word [dos_errno], 0x6A                          ; [c7 06 8a 00 6a 00]
rtl_fwrite_pad_l1F55:
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x8B,0xD0                                   ; mov dx, ax
rtl_fwrite_pad_l1F59:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fread_w   image offset 0x1F5D  <- called from 0x0709, 0x0FA7, 0x1063
; ------------------------------------------------------------------------------
rtl_fread_w:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    sub sp, byte 0x20                                   ; [83 ec 20]
    mov ax, word [bp+0x8]                               ; [8b 46 08]
    mov dx, word [bp+0xA]                               ; [8b 56 0a]
    lea di, word [bp-0x20]                              ; [8d 7e e0]
    push ss                                             ; [16]
    pop es                                              ; [07]
    call near 0x4FA7                                    ; [e8 36 30]
    les di,  [bp+0xC]                               ; [c4 7e 0c]
    push es                                             ; [06]
    push di                                             ; [57]
    call near 0x1D66                                    ; [e8 ed fd]
    jne short 0x1F9A                                    ; [75 1f]
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    db 0x2B,0xC1                                   ; sub ax, cx
    jle short 0x1F8F                                    ; [7e 0d]
    db 0x8B,0xF1                                   ; mov si, cx
    db 0x8B,0xC8                                   ; mov cx, ax
rtl_fread_w_l1F86:
    mov al, 0x20                                        ; [b0 20]
    call near 0x1D8A                                    ; [e8 ff fd]
    loop 0x1F86                                         ; [e2 f9]
    db 0x8B,0xCE                                   ; mov cx, si
rtl_fread_w_l1F8F:
    lea si, word [bp-0x20]                              ; [8d 76 e0]
rtl_fread_w_l1F92:
    cld                                                 ; [fc]
    ss lodsb                                            ; [36 ac]
    call near 0x1D8A                                    ; [e8 f2 fd]
    loop 0x1F92                                         ; [e2 f8]
rtl_fread_w_l1F9A:
    pop di                                              ; [5f]
    pop es                                              ; [07]
    mov word [es:di+0x8], bx                            ; [26 89 5d 08]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    retf 0x6                                            ; [ca 06 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_init_streams   image offset 0x1FA6  <- called from 0x02D4
; ------------------------------------------------------------------------------
rtl_init_streams:
    call near 0x4CD0                                    ; [e8 27 2d]
    mov si, 0x332C                                      ; [be 2c 33]
    mov di, 0x33AC                                      ; [bf ac 33]
    db 0x0A,0xC0                                   ; or al, al
    jne short 0x1FBF                                    ; [75 0c]
    mov word [stack_margin], 0xE6                       ; [c7 06 88 00 e6 00]
    mov si, 0x2AF2                                      ; [be f2 2a]
    mov di, 0x27C2                                      ; [bf c2 27]
rtl_init_streams_l1FBF:
    jmp near 0x4D57                                     ; [e9 95 2d]
    db 0x87, 0xE2                                       ; xchg sp, dx
    add byte [si], cl                                   ; [00 0c]
    sbb byte [si], ah                                   ; [18 24]
    xor byte [si], bh                                   ; [30 3c]
    dec ax                                              ; [48]
    push sp                                             ; [54]
    pushaw                                              ; [60]
    insb                                                ; [6c]
    js short 0x1F54                                     ; [78 84]
    nop                                                 ; [90]
    pushf                                               ; [9c]
    test al, 0xB4                                       ; [a8 b4]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    db 0x00,0x80,0x01,0x00                         ; add byte [bx+si+0x1], al
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l1FE0:
    mov ax, 0xA24                                       ; [b8 24 0a]
    jmp short 0x2049                                    ; [eb 64]
    dec byte [bp+si-0x32E5]                             ; [fe 8a 1b cd]
    dec bx                                              ; [4b]
    js short 0x1F86                                     ; [78 9a]
    aam 0x2                                             ; [d4 02]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si+0xA35], bh                          ; [00 b8 35 0a]
    jmp short 0x2049                                    ; [eb 53]
    mov bx, 0x17F0                                      ; [bb f0 17]
    pop sp                                              ; [5c]
    sub word [bp+di], di                                ; [29 3b]
    stosb                                               ; [aa]
    mov ax, 0x1                                         ; [b8 01 00]
    add byte [bx+si], al                                ; [00 00]
    mov ax, 0xA46                                       ; [b8 46 0a]
    jmp short 0x2049                                    ; [eb 42]
    xor ax, 0x68C2                                      ; [35 c2 68]
    and word [bp+si+0xFDA], sp                          ; [21 a2 da 0f]
    leave                                               ; [c9]
    add al, byte [bx+si]                                ; [02 00]
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l2013:
    mov ax, 0xA57                                       ; [b8 57 0a]
    jmp short 0x2049                                    ; [eb 31]
    db 0x99                                        ; cwd
    db 0xF7,0xCF,0xFB,0x84                         ; test di, 0x84FB
    call 0xFFFF:0x9A20                                  ; [9a 20 9a ff ff]
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l2024:
    mov ax, 0xA68                                       ; [b8 68 0a]
    jmp short 0x2049                                    ; [eb 20]
    lodsb                                               ; [ac]
    jns short 0x1FFB                                    ; [79 cf]
    db 0xD1,0xF7                                   ; sal di, 0x1
    pop ss                                              ; [17]
    jb short 0x1FE2                                     ; [72 b1]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l2035:
    mov ax, 0xA79                                       ; [b8 79 0a]
    jmp short 0x2049                                    ; [eb 0f]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add ax, ax                                          ; [01 c0]
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l2046:
    mov ax, 0xA8A                                       ; [b8 8a 0a]
rtl_init_streams_l2049:
    push ds                                             ; [1e]
    mov cx, cs                                          ; [8c c9]
    mov ds, cx                                          ; [8e d9]
    xchg si, ax                                         ; [96]
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    sub di, byte 0xC                                    ; [83 ef 0c]
    xchg si, ax                                         ; [96]
    pop ds                                              ; [1f]
    ret                                                 ; [c3]
rtl_init_streams_l205B:
    push di                                             ; [57]
    push ax                                             ; [50]
    db 0x2B,0xC0                                   ; sub ax, ax
    cld                                                 ; [fc]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    pop ax                                              ; [58]
    stosw                                               ; [ab]
    db 0x8A,0xC1                                   ; mov al, cl
    mov ah, 0x0                                         ; [b4 00]
    stosw                                               ; [ab]
    pop di                                              ; [5f]
    ret                                                 ; [c3]
rtl_init_streams_l206D:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 4d 1d]
    push di                                             ; [57]
    db 0x2B,0xC0                                   ; sub ax, ax
    cld                                                 ; [fc]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    mov ah, 0xC0                                        ; [b4 c0]
    stosw                                               ; [ab]
    mov ax, 0x4001                                      ; [b8 01 40]
    stosw                                               ; [ab]
    mov ax, 0x1                                         ; [b8 01 00]
    stosw                                               ; [ab]
    pop di                                              ; [5f]
    ret                                                 ; [c3]
rtl_init_streams_l2086:
    push si                                             ; [56]
    push di                                             ; [57]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    push es                                             ; [06]
    push ds                                             ; [1e]
    pop es                                              ; [07]
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l20A0:
    push si                                             ; [56]
    push di                                             ; [57]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    push ds                                             ; [1e]
    push es                                             ; [06]
    push ds                                             ; [1e]
    pop es                                              ; [07]
    push cs                                             ; [0e]
    pop ds                                              ; [1f]
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    pop es                                              ; [07]
    pop ds                                              ; [1f]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l20BE:
    push si                                             ; [56]
    push di                                             ; [57]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l20D1:
    push si                                             ; [56]
    push di                                             ; [57]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    cld                                                 ; [fc]
    push es                                             ; [06]
    push ds                                             ; [1e]
    pop es                                              ; [07]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l20EB:
    push si                                             ; [56]
    push di                                             ; [57]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x8B,0xFE                                   ; mov di, si
    cld                                                 ; [fc]
    push es                                             ; [06]
    push ds                                             ; [1e]
    pop es                                              ; [07]
    mov cx, 0x6                                         ; [b9 06 00]
rtl_init_streams_l20FA:
    lodsw                                               ; [ad]
    xchg word [di+0xC], ax                              ; [87 45 0c]
    stosw                                               ; [ab]
    loop 0x20FA                                         ; [e2 f9]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l2105:
    mov ax, word [es:si]                                ; [26 8b 04]
    db 0x2B,0xC9                                   ; sub cx, cx
    mov dx, 0x0                                         ; [ba 00 00]
    db 0x0B,0xC0                                   ; or ax, ax
    jl short 0x2118                                     ; [7c 07]
    jg short 0x211C                                     ; [7f 09]
    mov bx, 0xC001                                      ; [bb 01 c0]
    jmp short 0x2128                                    ; [eb 10]
rtl_init_streams_l2118:
    neg ax                                              ; [f7 d8]
    mov dl, 0x1                                         ; [b2 01]
rtl_init_streams_l211C:
    db 0x2B,0xDB                                   ; sub bx, bx
    xchg cx, ax                                         ; [91]
rtl_init_streams_l211F:
    inc bx                                              ; [43]
    shr cx, 0x1                                         ; [d1 e9]
    rcr ax, 0x1                                         ; [d1 d8]
    jcxz 0x2128                                         ; [e3 02]
    jmp short 0x211F                                    ; [eb f7]
rtl_init_streams_l2128:
    mov word [di+0xA], dx                               ; [89 55 0a]
    mov word [di+0x8], bx                               ; [89 5d 08]
    mov word [di+0x6], ax                               ; [89 45 06]
    mov word [di+0x4], cx                               ; [89 4d 04]
    mov word [di+0x2], cx                               ; [89 4d 02]
    mov word [di], cx                                   ; [89 0d]
    ret                                                 ; [c3]
rtl_init_streams_l213A:
    mov cx, word [si+0x8]                               ; [8b 4c 08]
    cmp cx, byte 0x10                                   ; [83 f9 10]
    jg short 0x214C                                     ; [7f 0a]
    cmp cx, word 0xC001                                 ; [81 f9 01 c0]
    jg short 0x2156                                     ; [7f 0e]
    db 0x2B,0xC0                                   ; sub ax, ax
    jmp short 0x21C5                                    ; [eb 79]
rtl_init_streams_l214C:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 6e 1c]
    mov ax, 0x8000                                      ; [b8 00 80]
    jmp short 0x21C5                                    ; [eb 6f]
rtl_init_streams_l2156:
    mov bx, word [si+0x6]                               ; [8b 5c 06]
    db 0x2B,0xC0                                   ; sub ax, ax
    cmp cx, byte 0x0                                    ; [83 f9 00]
    jge short 0x2164                                    ; [7d 04]
    shr bx, 0x1                                         ; [d1 eb]
    rcr dx, 0x1                                         ; [d1 da]
rtl_init_streams_l2164:
    mov dx, word [si+0x4]                               ; [8b 54 04]
    cmp cx, byte 0x0                                    ; [83 f9 00]
    jle short 0x2174                                    ; [7e 08]
rtl_init_streams_l216C:
    shl dx, 0x1                                         ; [d1 e2]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl ax, 0x1                                         ; [d1 d0]
    loop 0x216C                                         ; [e2 f8]
rtl_init_streams_l2174:
    or dx, word [si]                                    ; [0b 14]
    or dx, word [si+0x2]                                ; [0b 54 02]
    db 0x0A,0xDE                                   ; or bl, dh
    db 0x0A,0xDA                                   ; or bl, dl
    mov cl, 0xC                                         ; [b1 0c]
    and cl, byte [0x00D7]                               ; [22 0e d7 00]
    cmp cl, byte 0xC                                    ; [80 f9 0c]
    je short 0x21BA                                     ; [74 32]
    cmp cl, byte 0x0                                    ; [80 f9 00]
    je short 0x21AE                                     ; [74 21]
    add cl, byte [si+0xA]                               ; [02 4c 0a]
    cmp cl, byte 0x4                                    ; [80 f9 04]
    je short 0x21BA                                     ; [74 25]
    cmp cl, byte 0x9                                    ; [80 f9 09]
    je short 0x21BA                                     ; [74 20]
    neg bx                                              ; [f7 db]
rtl_init_streams_l219C:
    adc ax, strict word 0x0                             ; [15 00 00]
    jns short 0x21BD                                    ; [79 1c]
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x214C                                    ; [75 a5]
    cmp ax, 0x8000                                      ; [3d 00 80]
    jne short 0x214C                                    ; [75 a0]
    jmp short 0x21BD                                    ; [eb 0f]
rtl_init_streams_l21AE:
    mov dl, 0x1                                         ; [b2 01]
    db 0x22,0xD0                                   ; and dl, al
    db 0x0A,0xDA                                   ; or bl, dl
    add bx, word 0x7FFF                                 ; [81 c3 ff 7f]
    jmp short 0x219C                                    ; [eb e2]
rtl_init_streams_l21BA:
    clc                                                 ; [f8]
    jmp short 0x219C                                    ; [eb df]
rtl_init_streams_l21BD:
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x21C5                                    ; [75 02]
    neg ax                                              ; [f7 d8]
rtl_init_streams_l21C5:
    mov word [es:di], ax                                ; [26 89 05]
    ret                                                 ; [c3]
rtl_init_streams_l21C9:
    push si                                             ; [56]
    push di                                             ; [57]
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x87, 0xF7                                       ; xchg si, di
    lea si, word [si+0x8]                               ; [8d 74 08]
    cmp word [si], 0xC001                               ; [81 3c 01 c0]
    jle short 0x21ED                                    ; [7e 0f]
    cmp word [si], 0x4001                               ; [81 3c 01 40]
    jge short 0x21EE                                    ; [7d 0a]
    dec word [si]                                       ; [ff 0c]
    call near 0x2105                                    ; [e8 1c ff]
    mov word [si], 0x1                                  ; [c7 04 01 00]
rtl_init_streams_l21ED:
    ret                                                 ; [c3]
rtl_init_streams_l21EE:
    mov word [si], 0xC001                               ; [c7 04 01 c0]
    mov word [di+0x8], 0xD                              ; [c7 45 08 0d 00]
    mov byte [di+0x7], 0x80                             ; [c6 45 07 80]
    jmp short 0x21ED                                    ; [eb f0]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    mov cx, word [si+0x8]                               ; [8b 4c 08]
    cmp cx, byte 0xF                                    ; [83 f9 0f]
    jg short 0x2212                                     ; [7f 08]
    db 0x0B,0xC9                                   ; or cx, cx
    jg short 0x221C                                     ; [7f 0e]
    db 0x2B,0xC0                                   ; sub ax, ax
    jmp short 0x222E                                    ; [eb 1c]
rtl_init_streams_l2212:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 a8 1b]
    mov ax, 0x7FFF                                      ; [b8 ff 7f]
    jmp short 0x2226                                    ; [eb 0a]
rtl_init_streams_l221C:
    mov ax, word [si+0x6]                               ; [8b 44 06]
    neg cl                                              ; [f6 d9]
    add cl, byte 0x10                                   ; [80 c1 10]
    shr ax, cl                                          ; [d3 e8]
rtl_init_streams_l2226:
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x222E                                    ; [75 02]
    neg ax                                              ; [f7 d8]
rtl_init_streams_l222E:
    mov cx, word [di+0x8]                               ; [8b 4d 08]
    cmp cx, word 0xC001                                 ; [81 f9 01 c0]
    jle short 0x224C                                    ; [7e 15]
    cmp cx, word 0x4001                                 ; [81 f9 01 40]
    jge short 0x224C                                    ; [7d 0f]
    db 0x03,0xC1                                   ; add ax, cx
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x225A                                    ; [7e 16]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2250                                    ; [7d 07]
    mov word [di+0x8], ax                               ; [89 45 08]
rtl_init_streams_l224C:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l2250:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 6a 1b]
    mov ax, 0x4001                                      ; [b8 01 40]
    jmp short 0x2262                                    ; [eb 08]
rtl_init_streams_l225A:
    mov ch, 0x10                                        ; [b5 10]
    call near 0x3DBF                                    ; [e8 60 1b]
    mov ax, 0xC001                                      ; [b8 01 c0]
rtl_init_streams_l2262:
    call near 0x205B                                    ; [e8 f6 fd]
    jmp short 0x224C                                    ; [eb e5]
    mov bx, word [es:si]                                ; [26 8b 1c]
    mov dx, word [es:si+0x2]                            ; [26 8b 54 02]
    db 0x2B,0xC0                                   ; sub ax, ax
    mov cx, 0x0                                         ; [b9 00 00]
    db 0x0B,0xD2                                   ; or dx, dx
    jns short 0x2280                                    ; [79 09]
    not dx                                              ; [f7 d2]
    neg bx                                              ; [f7 db]
    sbb dx, -0x1                                        ; [83 da ff]
    mov cl, 0x1                                         ; [b1 01]
rtl_init_streams_l2280:
    mov word [di+0xA], cx                               ; [89 4d 0a]
    mov cx, 0x10                                        ; [b9 10 00]
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x228E                                    ; [75 04]
    db 0x87, 0xDA                                       ; xchg bx, dx
    mov cl, 0x0                                         ; [b1 00]
rtl_init_streams_l228E:
    db 0x0B,0xD2                                   ; or dx, dx
    je short 0x229E                                     ; [74 0c]
    inc cx                                              ; [41]
    shr dx, 0x1                                         ; [d1 ea]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    jmp short 0x228E                                    ; [eb f3]
rtl_init_streams_l229B:
    mov cx, 0xC001                                      ; [b9 01 c0]
rtl_init_streams_l229E:
    jcxz 0x229B                                         ; [e3 fb]
    mov word [di+0x8], cx                               ; [89 4d 08]
    mov word [di+0x6], bx                               ; [89 5d 06]
    mov word [di+0x4], ax                               ; [89 45 04]
    mov word [di+0x2], dx                               ; [89 55 02]
    mov word [di], dx                                   ; [89 15]
    ret                                                 ; [c3]
    mov cx, word [si+0x8]                               ; [8b 4c 08]
    cmp cx, byte 0x20                                   ; [83 f9 20]
    jg short 0x22EA                                     ; [7f 33]
    db 0x0B,0xC9                                   ; or cx, cx
    jge short 0x22F7                                    ; [7d 3c]
    cmp cx, word 0xC001                                 ; [81 f9 01 c0]
    jle short 0x22D4                                    ; [7e 13]
    mov bl, 0xC                                         ; [b3 0c]
    and bl, byte [0x00D7]                               ; [22 1e d7 00]
    add bl, byte [si+0xA]                               ; [02 5c 0a]
    cmp bl, byte 0x5                                    ; [80 fb 05]
    je short 0x22DA                                     ; [74 0b]
    cmp bl, byte 0x8                                    ; [80 fb 08]
    je short 0x22DA                                     ; [74 06]
rtl_init_streams_l22D4:
    db 0x2B,0xD2                                   ; sub dx, dx
    db 0x8B,0xC2                                   ; mov ax, dx
    jmp short 0x22F4                                    ; [eb 1a]
rtl_init_streams_l22DA:
    db 0x2B,0xD2                                   ; sub dx, dx
    mov ax, 0x1                                         ; [b8 01 00]
    cmp bl, byte 0x5                                    ; [80 fb 05]
    jne short 0x22F4                                    ; [75 10]
    neg ax                                              ; [f7 d8]
    not dx                                              ; [f7 d2]
    jmp short 0x22F4                                    ; [eb 0a]
rtl_init_streams_l22EA:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 d0 1a]
    mov dx, 0x8000                                      ; [ba 00 80]
    db 0x2B,0xC0                                   ; sub ax, ax
rtl_init_streams_l22F4:
    jmp near 0x23A4                                     ; [e9 ad 00]
rtl_init_streams_l22F7:
    mov bx, word [si+0x2]                               ; [8b 5c 02]
    or bl, byte [si]                                    ; [0a 1c]
    or bl, byte [si+0x1]                                ; [0a 5c 01]
    mov ax, word [si+0x4]                               ; [8b 44 04]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    sub cl, byte 0x10                                   ; [80 e9 10]
    ja short 0x231A                                     ; [77 10]
rtl_init_streams_l230A:
    db 0x0A,0xC3                                   ; or al, bl
    db 0x0A,0xC7                                   ; or al, bh
    xchg bx, ax                                         ; [93]
    xchg dx, ax                                         ; [92]
    db 0x2B,0xD2                                   ; sub dx, dx
    add cl, byte 0x10                                   ; [80 c1 10]
    jle short 0x230A                                    ; [7e f3]
    and cl, byte 0xF                                    ; [80 e1 0f]
rtl_init_streams_l231A:
    jcxz 0x2339                                         ; [e3 1d]
    push si                                             ; [56]
    mov si, 0xFFFF                                      ; [be ff ff]
    rol dx, cl                                          ; [d3 c2]
    rol ax, cl                                          ; [d3 c0]
    shl si, cl                                          ; [d3 e6]
    db 0x8B,0xCE                                   ; mov cx, si
    db 0x23,0xC8                                   ; and cx, ax
    db 0x33,0xC1                                   ; xor ax, cx
    db 0x23,0xF2                                   ; and si, dx
    db 0x33,0xD6                                   ; xor dx, si
    db 0x0B,0xC6                                   ; or ax, si
    db 0x0A,0xDF                                   ; or bl, bh
    db 0x0A,0xD9                                   ; or bl, cl
    db 0x8A,0xFD                                   ; mov bh, ch
    pop si                                              ; [5e]
rtl_init_streams_l2339:
    mov cl, 0xC                                         ; [b1 0c]
    and cl, byte [0x00D7]                               ; [22 0e d7 00]
    cmp cl, byte 0xC                                    ; [80 f9 0c]
    je short 0x2394                                     ; [74 50]
    cmp cl, byte 0x0                                    ; [80 f9 00]
    je short 0x235C                                     ; [74 13]
    add cl, byte [si+0xA]                               ; [02 4c 0a]
    cmp cl, byte 0x4                                    ; [80 f9 04]
    je short 0x2394                                     ; [74 43]
    cmp cl, byte 0x9                                    ; [80 f9 09]
    je short 0x2394                                     ; [74 3e]
    neg bx                                              ; [f7 db]
    jb short 0x2366                                     ; [72 0c]
    jmp short 0x2366                                    ; [eb 0a]
rtl_init_streams_l235C:
    mov cl, 0x1                                         ; [b1 01]
    db 0x22,0xC8                                   ; and cl, al
    db 0x0A,0xD9                                   ; or bl, cl
    add bx, word 0x7FFF                                 ; [81 c3 ff 7f]
rtl_init_streams_l2366:
    adc ax, strict word 0x0                             ; [15 00 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    jns short 0x2397                                    ; [79 29]
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x2382                                    ; [75 0e]
    cmp dx, word 0x8000                                 ; [81 fa 00 80]
    jne short 0x2382                                    ; [75 08]
    cmp ax, strict word 0x0                             ; [3d 00 00]
    jne short 0x2382                                    ; [75 03]
    jmp short 0x2397                                    ; [eb 16]
    nop                                                 ; [90]
rtl_init_streams_l2382:
    jmp near 0x22EA                                     ; [e9 65 ff]
    db 0x8A,0xCE                                   ; mov cl, dh
    rol cl, 0x1                                         ; [d0 c1]
    xor cl, byte [si+0xA]                               ; [32 4c 0a]
    test cl, 0x1                                        ; [f6 c1 01]
    je short 0x2397                                     ; [74 06]
    jmp near 0x22EA                                     ; [e9 56 ff]
rtl_init_streams_l2394:
    clc                                                 ; [f8]
    jmp short 0x2366                                    ; [eb cf]
rtl_init_streams_l2397:
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x23A4                                    ; [75 07]
    not dx                                              ; [f7 d2]
    neg ax                                              ; [f7 d8]
    sbb dx, -0x1                                        ; [83 da ff]
rtl_init_streams_l23A4:
    mov word [es:di], ax                                ; [26 89 05]
    mov word [es:di+0x2], dx                            ; [26 89 55 02]
    ret                                                 ; [c3]
rtl_init_streams_l23AC:
    push bp                                             ; [55]
    push si                                             ; [56]
    mov ax, word [es:si]                                ; [26 8b 04]
    mov bx, word [es:si+0x2]                            ; [26 8b 5c 02]
    mov cx, word [es:si+0x4]                            ; [26 8b 4c 04]
    mov dx, word [es:si+0x6]                            ; [26 8b 54 06]
    mov bp, 0x0                                         ; [bd 00 00]
    db 0x0B,0xD2                                   ; or dx, dx
    jl short 0x23D7                                     ; [7c 13]
    jg short 0x23EC                                     ; [7f 26]
    db 0x0B,0xC9                                   ; or cx, cx
    jne short 0x23EC                                    ; [75 22]
    db 0x0B,0xDB                                   ; or bx, bx
    jne short 0x23EC                                    ; [75 1e]
    db 0x0B,0xC0                                   ; or ax, ax
    jne short 0x23EC                                    ; [75 1a]
    mov si, 0xC001                                      ; [be 01 c0]
    jmp short 0x240A                                    ; [eb 33]
rtl_init_streams_l23D7:
    not dx                                              ; [f7 d2]
    not cx                                              ; [f7 d1]
    not bx                                              ; [f7 d3]
    neg ax                                              ; [f7 d8]
    cmc                                                 ; [f5]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    mov bp, 0x1                                         ; [bd 01 00]
rtl_init_streams_l23EC:
    mov si, 0x40                                        ; [be 40 00]
rtl_init_streams_l23EF:
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x23FD                                    ; [75 0a]
    db 0x87, 0xD1                                       ; xchg dx, cx
    db 0x87, 0xCB                                       ; xchg cx, bx
    xchg bx, ax                                         ; [93]
    sub si, byte 0x10                                   ; [83 ee 10]
    jmp short 0x23EF                                    ; [eb f2]
rtl_init_streams_l23FD:
    js short 0x240A                                     ; [78 0b]
rtl_init_streams_l23FF:
    dec si                                              ; [4e]
    db 0x03,0xC0                                   ; add ax, ax
    db 0x13,0xDB                                   ; adc bx, bx
    db 0x13,0xC9                                   ; adc cx, cx
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x23FF                                    ; [79 f5]
rtl_init_streams_l240A:
    mov word [di+0xA], bp                               ; [89 6d 0a]
    mov word [di+0x8], si                               ; [89 75 08]
    mov word [di+0x6], dx                               ; [89 55 06]
    mov word [di+0x4], cx                               ; [89 4d 04]
    mov word [di+0x2], bx                               ; [89 5d 02]
    mov word [di], ax                                   ; [89 05]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l241E:
    push bp                                             ; [55]
    push di                                             ; [57]
    mov cx, word [si+0x8]                               ; [8b 4c 08]
    cmp cx, byte 0x3F                                   ; [83 f9 3f]
    jg short 0x2461                                     ; [7f 39]
    db 0x0B,0xC9                                   ; or cx, cx
    jge short 0x2472                                    ; [7d 46]
    cmp cx, word 0xC001                                 ; [81 f9 01 c0]
    jle short 0x2445                                    ; [7e 13]
    mov bl, 0xC                                         ; [b3 0c]
    and bl, byte [0x00D7]                               ; [22 1e d7 00]
    add bl, byte [si+0xA]                               ; [02 5c 0a]
    cmp bl, byte 0x5                                    ; [80 fb 05]
    je short 0x2449                                     ; [74 09]
    cmp bl, byte 0x8                                    ; [80 fb 08]
    je short 0x2449                                     ; [74 04]
rtl_init_streams_l2445:
    db 0x2B,0xED                                   ; sub bp, bp
    jmp short 0x2469                                    ; [eb 20]
rtl_init_streams_l2449:
    db 0x2B,0xED                                   ; sub bp, bp
    db 0x8B,0xD5                                   ; mov dx, bp
    mov ax, 0x1                                         ; [b8 01 00]
    cmp bl, byte 0x5                                    ; [80 fb 05]
    db 0x8B,0xDD                                   ; mov bx, bp
    jne short 0x246F                                    ; [75 18]
    neg ax                                              ; [f7 d8]
    not bx                                              ; [f7 d3]
    not dx                                              ; [f7 d2]
    not bp                                              ; [f7 d5]
    jmp short 0x246F                                    ; [eb 0e]
rtl_init_streams_l2461:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 59 19]
    mov bp, 0x8000                                      ; [bd 00 80]
rtl_init_streams_l2469:
    db 0x2B,0xD2                                   ; sub dx, dx
    db 0x8B,0xDA                                   ; mov bx, dx
    db 0x8B,0xC3                                   ; mov ax, bx
rtl_init_streams_l246F:
    jmp near 0x2503                                     ; [e9 91 00]
rtl_init_streams_l2472:
    mov bp, word [si+0x6]                               ; [8b 6c 06]
    mov dx, word [si+0x4]                               ; [8b 54 04]
    mov bx, word [si+0x2]                               ; [8b 5c 02]
    mov di, word [si]                                   ; [8b 3c]
    db 0x2B,0xC0                                   ; sub ax, ax
    sub cl, byte 0x30                                   ; [80 e9 30]
    ja short 0x249A                                     ; [77 16]
rtl_init_streams_l2484:
    db 0x0A,0xC4                                   ; or al, ah
    mov ah, 0x0                                         ; [b4 00]
    db 0x0B,0xC7                                   ; or ax, di
    db 0x8B,0xFB                                   ; mov di, bx
    db 0x8B,0xDA                                   ; mov bx, dx
    db 0x8B,0xD5                                   ; mov dx, bp
    db 0x2B,0xED                                   ; sub bp, bp
    add cl, byte 0x10                                   ; [80 c1 10]
    jle short 0x2484                                    ; [7e ed]
    and cl, byte 0xF                                    ; [80 e1 0f]
rtl_init_streams_l249A:
    neg cl                                              ; [f6 d9]
    je short 0x24AF                                     ; [74 11]
    add cl, byte 0x10                                   ; [80 c1 10]
rtl_init_streams_l24A1:
    db 0x0A,0xC4                                   ; or al, ah
    shr bp, 0x1                                         ; [d1 ed]
    rcr dx, 0x1                                         ; [d1 da]
    rcr bx, 0x1                                         ; [d1 db]
    rcr di, 0x1                                         ; [d1 df]
    rcr ah, 0x1                                         ; [d0 dc]
    loop 0x24A1                                         ; [e2 f2]
rtl_init_streams_l24AF:
    mov cl, 0xC                                         ; [b1 0c]
    and cl, byte [0x00D7]                               ; [22 0e d7 00]
    cmp cl, byte 0xC                                    ; [80 f9 0c]
    je short 0x24EA                                     ; [74 30]
    cmp cl, byte 0x0                                    ; [80 f9 00]
    je short 0x24D4                                     ; [74 15]
    add cl, byte [si+0xA]                               ; [02 4c 0a]
    cmp cl, byte 0x4                                    ; [80 f9 04]
    je short 0x24EA                                     ; [74 23]
    cmp cl, byte 0x9                                    ; [80 f9 09]
    je short 0x24EA                                     ; [74 1e]
    neg ax                                              ; [f7 d8]
    jb short 0x24DD                                     ; [72 0d]
    jmp short 0x24EA                                    ; [eb 18]
rtl_init_streams_l24D2:
    jmp short 0x2461                                    ; [eb 8d]
rtl_init_streams_l24D4:
    mov cl, 0x1                                         ; [b1 01]
    db 0x23,0xCF                                   ; and cx, di
    db 0x0A,0xC1                                   ; or al, cl
    add ax, 0x7FFF                                      ; [05 ff 7f]
rtl_init_streams_l24DD:
    mov cx, 0x0                                         ; [b9 00 00]
    db 0x13,0xF9                                   ; adc di, cx
    db 0x13,0xD9                                   ; adc bx, cx
    db 0x13,0xD1                                   ; adc dx, cx
    db 0x13,0xE9                                   ; adc bp, cx
    js short 0x24D2                                     ; [78 e8]
rtl_init_streams_l24EA:
    xchg di, ax                                         ; [97]
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x2503                                    ; [75 12]
    not bp                                              ; [f7 d5]
    not dx                                              ; [f7 d2]
    not bx                                              ; [f7 d3]
    neg ax                                              ; [f7 d8]
    cmc                                                 ; [f5]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    adc bp, byte 0x0                                    ; [83 d5 00]
rtl_init_streams_l2503:
    pop di                                              ; [5f]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg bp, ax                                         ; [95]
    stosw                                               ; [ab]
    sub di, byte 0x8                                    ; [83 ef 08]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l2510:
    push bp                                             ; [55]
    push si                                             ; [56]
    push di                                             ; [57]
    db 0x87, 0xEE                                       ; xchg bp, si
    mov cx, word [bp+0x8]                               ; [8b 4e 08]
    cmp cx, byte 0x40                                   ; [83 f9 40]
    jge short 0x2549                                    ; [7d 2c]
    db 0x0B,0xC9                                   ; or cx, cx
    jge short 0x2566                                    ; [7d 45]
    cmp cx, word 0xC001                                 ; [81 f9 01 c0]
    jle short 0x253A                                    ; [7e 13]
    mov cl, 0xC                                         ; [b1 0c]
    and cl, byte [0x00D7]                               ; [22 0e d7 00]
    add cl, byte [bp+0xA]                               ; [02 4e 0a]
    cmp cl, byte 0x5                                    ; [80 f9 05]
    je short 0x2541                                     ; [74 0c]
    cmp cl, byte 0x8                                    ; [80 f9 08]
    je short 0x2541                                     ; [74 07]
rtl_init_streams_l253A:
    db 0x2B,0xDB                                   ; sub bx, bx
    mov si, 0xC001                                      ; [be 01 c0]
    jmp short 0x2552                                    ; [eb 11]
rtl_init_streams_l2541:
    mov si, 0x1                                         ; [be 01 00]
    mov bx, 0x8000                                      ; [bb 00 80]
    jmp short 0x2552                                    ; [eb 09]
rtl_init_streams_l2549:
    je short 0x2563                                     ; [74 18]
    mov ch, 0x20                                        ; [b5 20]
    call near 0x3DBF                                    ; [e8 6f 18]
    jmp short 0x2563                                    ; [eb 11]
rtl_init_streams_l2552:
    db 0x2B,0xC0                                   ; sub ax, ax
    mov word [bp], ax                                   ; [89 46 00]
    mov word [bp+0x2], ax                               ; [89 46 02]
    mov word [bp+0x4], ax                               ; [89 46 04]
    mov word [bp+0x6], bx                               ; [89 5e 06]
    mov word [bp+0x8], si                               ; [89 76 08]
rtl_init_streams_l2563:
    jmp near 0x2616                                     ; [e9 b0 00]
rtl_init_streams_l2566:
    mov si, 0x38                                        ; [be 38 00]
    db 0x23,0xF1                                   ; and si, cx
    db 0x33,0xCE                                   ; xor cx, si
    shr si, 0x1                                         ; [d1 ee]
    shr si, 0x1                                         ; [d1 ee]
    shr si, 0x1                                         ; [d1 ee]
    neg si                                              ; [f7 de]
    add si, byte 0x7                                    ; [83 c6 07]
    cmp si, byte 0x7                                    ; [83 fe 07]
    jne short 0x2583                                    ; [75 06]
    mov ah, 0x0                                         ; [b4 00]
    mov al, byte [bp+si]                                ; [8a 02]
    jmp short 0x2585                                    ; [eb 02]
rtl_init_streams_l2583:
    mov ax, word [bp+si]                                ; [8b 02]
rtl_init_streams_l2585:
    db 0x2B,0xDB                                   ; sub bx, bx
    db 0x8B,0xFE                                   ; mov di, si
rtl_init_streams_l2589:
    dec di                                              ; [4f]
    jl short 0x2592                                     ; [7c 06]
    or bl, byte [bp+di]                                 ; [0a 1b]
    mov byte [bp+di], bh                                ; [88 3b]
    jmp short 0x2589                                    ; [eb f7]
rtl_init_streams_l2592:
    mov dx, 0xFF                                        ; [ba ff 00]
    and cl, byte 0x7                                    ; [80 e1 07]
    shr dx, cl                                          ; [d3 ea]
    db 0x8B,0xFA                                   ; mov di, dx
    inc di                                              ; [47]
    db 0x23,0xD0                                   ; and dx, ax
    jne short 0x25A5                                    ; [75 04]
    db 0x0A,0xDB                                   ; or bl, bl
    je short 0x2616                                     ; [74 71]
rtl_init_streams_l25A5:
    mov ch, 0x20                                        ; [b5 20]
    call near 0x3DBF                                    ; [e8 15 18]
    db 0x33,0xC2                                   ; xor ax, dx
    mov cl, 0xC                                         ; [b1 0c]
    and cl, byte [0x00D7]                               ; [22 0e d7 00]
    cmp cl, byte 0xC                                    ; [80 f9 0c]
    je short 0x25CF                                     ; [74 18]
    cmp cl, byte 0x0                                    ; [80 f9 00]
    je short 0x25DA                                     ; [74 1e]
    add cl, byte [bp+0xA]                               ; [02 4e 0a]
    cmp cl, byte 0x4                                    ; [80 f9 04]
    je short 0x25CF                                     ; [74 0b]
    cmp cl, byte 0x9                                    ; [80 f9 09]
    je short 0x25CF                                     ; [74 06]
    db 0x0A,0xDA                                   ; or bl, dl
    jne short 0x25F0                                    ; [75 23]
    jmp short 0x2616                                    ; [eb 47]
rtl_init_streams_l25CF:
    mov byte [bp+si], al                                ; [88 02]
    cmp byte [bp+0x7], 0x0                              ; [80 7e 07 00]
    jne short 0x2616                                    ; [75 3f]
    jmp near 0x253A                                     ; [e9 60 ff]
rtl_init_streams_l25DA:
    db 0x0A,0xDB                                   ; or bl, bl
    jne short 0x25EA                                    ; [75 0c]
    test di, ax                                         ; [85 c7]
    jne short 0x25EA                                    ; [75 08]
    db 0x03,0xD2                                   ; add dx, dx
    db 0x3B,0xD7                                   ; cmp dx, di
    jbe short 0x25CF                                    ; [76 e7]
    jmp short 0x25F0                                    ; [eb 06]
rtl_init_streams_l25EA:
    db 0x03,0xD2                                   ; add dx, dx
    db 0x3B,0xD7                                   ; cmp dx, di
    jb short 0x25CF                                     ; [72 df]
rtl_init_streams_l25F0:
    sub si, byte 0x7                                    ; [83 ee 07]
    jl short 0x25FE                                     ; [7c 09]
    db 0x03,0xC7                                   ; add ax, di
    mov byte [bp+si+0x7], al                            ; [88 42 07]
    neg ah                                              ; [f6 dc]
    jmp short 0x260D                                    ; [eb 0f]
rtl_init_streams_l25FE:
    db 0x03,0xC7                                   ; add ax, di
    mov word [bp+si+0x7], ax                            ; [89 42 07]
    inc si                                              ; [46]
rtl_init_streams_l2604:
    inc si                                              ; [46]
    jg short 0x260D                                     ; [7f 06]
    adc byte [bp+si+0x7], 0x0                           ; [80 52 07 00]
    jb short 0x2604                                     ; [72 f7]
rtl_init_streams_l260D:
    jae short 0x2616                                    ; [73 07]
    stc                                                 ; [f9]
    rcr word [bp+0x6], 0x1                              ; [d1 5e 06]
    inc word [bp+0x8]                                   ; [ff 46 08]
rtl_init_streams_l2616:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    mov ax, word [si+0x4]                               ; [8b 44 04]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    mov bx, word [si+0x8]                               ; [8b 5c 08]
    mov cl, byte [si+0xA]                               ; [8a 4c 0a]
    cmp word [si], 0x0                                  ; [83 3c 00]
    jne short 0x263A                                    ; [75 0f]
    cmp word [si+0x2], 0x0                              ; [83 7c 02 00]
    jne short 0x263A                                    ; [75 09]
    test al, 0x7F                                       ; [a8 7f]
    jne short 0x263A                                    ; [75 05]
    test ah, 0x1                                        ; [f6 c4 01]
    je short 0x2649                                     ; [74 0f]
rtl_init_streams_l263A:
    db 0x02,0xC0                                   ; add al, al
    adc ah, byte 0x0                                    ; [80 d4 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    jae short 0x2649                                    ; [73 05]
    rcr dx, 0x1                                         ; [d1 da]
    rcr ax, 0x1                                         ; [d1 d8]
    inc bx                                              ; [43]
rtl_init_streams_l2649:
    add bx, byte 0x7E                                   ; [83 c3 7e]
    jle short 0x2680                                    ; [7e 32]
    cmp bx, word 0xFF                                   ; [81 fb ff 00]
    jge short 0x266B                                    ; [7d 17]
rtl_init_streams_l2654:
    shl dx, 0x1                                         ; [d1 e2]
    shr cl, 0x1                                         ; [d0 e9]
    rcr bl, 0x1                                         ; [d0 db]
    rcr dx, 0x1                                         ; [d1 da]
    db 0x8A,0xC4                                   ; mov al, ah
    db 0x8A,0xE2                                   ; mov ah, dl
    db 0x8A,0xD6                                   ; mov dl, dh
    db 0x8A,0xF3                                   ; mov dh, bl
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    sub di, byte 0x4                                    ; [83 ef 04]
    ret                                                 ; [c3]
rtl_init_streams_l266B:
    cmp word [si+0x8], 0x4001                           ; [81 7c 08 01 40]
    jge short 0x267B                                    ; [7d 09]
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 48 17]
    db 0x2B,0xD2                                   ; sub dx, dx
    db 0x2B,0xC0                                   ; sub ax, ax
rtl_init_streams_l267B:
    mov bx, 0xFF                                        ; [bb ff 00]
    jmp short 0x2654                                    ; [eb d4]
rtl_init_streams_l2680:
    cmp word [si+0x8], 0xC001                           ; [81 7c 08 01 c0]
    jle short 0x268C                                    ; [7e 05]
    mov ch, 0x10                                        ; [b5 10]
    call near 0x3DBF                                    ; [e8 33 17]
rtl_init_streams_l268C:
    db 0x2B,0xDB                                   ; sub bx, bx
    db 0x8B,0xD3                                   ; mov dx, bx
    db 0x8B,0xC3                                   ; mov ax, bx
    jmp short 0x2654                                    ; [eb c0]
    push si                                             ; [56]
    push di                                             ; [57]
    push es                                             ; [06]
    cld                                                 ; [fc]
    mov ax, word [es:si]                                ; [26 8b 04]
    mov dx, word [es:si+0x2]                            ; [26 8b 54 02]
    db 0x2B,0xF6                                   ; sub si, si
    shl dx, 0x1                                         ; [d1 e2]
    rcl si, 0x1                                         ; [d1 d6]
    db 0x2B,0xDB                                   ; sub bx, bx
    db 0x02,0xDE                                   ; add bl, dh
    je short 0x26DB                                     ; [74 30]
    cmp dh, byte 0xFF                                   ; [80 fe ff]
    je short 0x26D0                                     ; [74 20]
    sub bx, byte 0x7E                                   ; [83 eb 7e]
rtl_init_streams_l26B3:
    stc                                                 ; [f9]
    rcr dl, 0x1                                         ; [d0 da]
rtl_init_streams_l26B6:
    db 0x8A,0xF2                                   ; mov dh, dl
    db 0x8A,0xD4                                   ; mov dl, ah
    db 0x8A,0xE8                                   ; mov ch, al
    mov cl, 0x0                                         ; [b1 00]
    push ds                                             ; [1e]
    pop es                                              ; [07]
    db 0x2B,0xC0                                   ; sub ax, ax
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg si, ax                                         ; [96]
    stosw                                               ; [ab]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l26D0:
    db 0x8B,0xD8                                   ; mov bx, ax
    db 0x0A,0xDA                                   ; or bl, dl
    neg bx                                              ; [f7 db]
    mov bx, 0x4001                                      ; [bb 01 40]
    jmp short 0x26B3                                    ; [eb d8]
rtl_init_streams_l26DB:
    db 0x8B,0xCA                                   ; mov cx, dx
    db 0x0B,0xC8                                   ; or cx, ax
    je short 0x26EF                                     ; [74 0e]
    sub bx, byte 0x7E                                   ; [83 eb 7e]
    shr dl, 0x1                                         ; [d0 ea]
rtl_init_streams_l26E6:
    db 0x03,0xC0                                   ; add ax, ax
    db 0x13,0xD2                                   ; adc dx, dx
    js short 0x26B6                                     ; [78 ca]
    dec bx                                              ; [4b]
    jmp short 0x26E6                                    ; [eb f7]
rtl_init_streams_l26EF:
    mov bx, 0xC001                                      ; [bb 01 c0]
    jmp short 0x26B6                                    ; [eb c2]
    push di                                             ; [57]
    mov ax, word [si+0x1]                               ; [8b 44 01]
    mov di, word [si+0x3]                               ; [8b 7c 03]
    mov cx, word [si+0x5]                               ; [8b 4c 05]
    mov dl, byte [si+0x7]                               ; [8a 54 07]
    mov bx, word [si+0x8]                               ; [8b 5c 08]
    mov dh, 0x3                                         ; [b6 03]
    db 0x22,0xF0                                   ; and dh, al
    or dh, byte [si]                                    ; [0a 34]
    jne short 0x2710                                    ; [75 04]
    test al, 0x8                                        ; [a8 08]
    je short 0x2721                                     ; [74 11]
rtl_init_streams_l2710:
    add ax, strict word 0x4                             ; [05 04 00]
    adc di, byte 0x0                                    ; [83 d7 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dl, byte 0x0                                    ; [80 d2 00]
    jae short 0x2721                                    ; [73 03]
    rcr dl, 0x1                                         ; [d0 da]
    inc bx                                              ; [43]
rtl_init_streams_l2721:
    add bx, word 0x3FE                                  ; [81 c3 fe 03]
    jle short 0x2769                                    ; [7e 42]
    cmp bx, word 0x7FF                                  ; [81 fb ff 07]
    jge short 0x2777                                    ; [7d 4a]
rtl_init_streams_l272D:
    and al, 0xF8                                        ; [24 f8]
    shl dl, 0x1                                         ; [d0 e2]
    shr bx, 0x1                                         ; [d1 eb]
    rcr dl, 0x1                                         ; [d0 da]
    db 0x0A,0xC7                                   ; or al, bh
    db 0x8A,0xF3                                   ; mov dh, bl
    db 0x8B,0xDF                                   ; mov bx, di
    shr di, 0x1                                         ; [d1 ef]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr dx, 0x1                                         ; [d1 da]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    shr di, 0x1                                         ; [d1 ef]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr dx, 0x1                                         ; [d1 da]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    or al, byte [si+0xA]                                ; [0a 44 0a]
    shr di, 0x1                                         ; [d1 ef]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr dx, 0x1                                         ; [d1 da]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
rtl_init_streams_l275C:
    pop di                                              ; [5f]
    cld                                                 ; [fc]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    sub di, byte 0x8                                    ; [83 ef 08]
    ret                                                 ; [c3]
rtl_init_streams_l2769:
    mov dx, 0x0                                         ; [ba 00 00]
    cmp word [si+0x8], 0xC001                           ; [81 7c 08 01 c0]
    jle short 0x2786                                    ; [7e 13]
    mov ch, 0x10                                        ; [b5 10]
    jmp short 0x2783                                    ; [eb 0c]
rtl_init_streams_l2777:
    cmp word [si+0x8], 0x4001                           ; [81 7c 08 01 40]
    jge short 0x2793                                    ; [7d 15]
    mov dx, 0xFFE0                                      ; [ba e0 ff]
    mov ch, 0x8                                         ; [b5 08]
rtl_init_streams_l2783:
    call near 0x3DBF                                    ; [e8 39 16]
rtl_init_streams_l2786:
    or dl, byte [si+0xA]                                ; [0a 54 0a]
    ror dx, 0x1                                         ; [d1 ca]
    db 0x2B,0xC9                                   ; sub cx, cx
    db 0x8B,0xD9                                   ; mov bx, cx
    db 0x8B,0xC1                                   ; mov ax, cx
    jmp short 0x275C                                    ; [eb c9]
rtl_init_streams_l2793:
    mov bx, 0x7FF                                       ; [bb ff 07]
    jmp short 0x272D                                    ; [eb 95]
    push di                                             ; [57]
    mov ax, ds                                          ; [8c d8]
    mov bx, es                                          ; [8c c3]
    mov ds, bx                                          ; [8e db]
    mov es, ax                                          ; [8e c0]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    db 0x2B,0xC0                                   ; sub ax, ax
    shl dx, 0x1                                         ; [d1 e2]
    rcl ax, 0x1                                         ; [d1 d0]
    std                                                 ; [fd]
    lea di, word [di+0xA]                               ; [8d 7d 0a]
    stosw                                               ; [ab]
    mov cl, 0x5                                         ; [b1 05]
    shr dx, cl                                          ; [d3 ea]
    je short 0x2815                                     ; [74 60]
    cmp dx, word 0x7FF                                  ; [81 fa ff 07]
    je short 0x27FF                                     ; [74 44]
    mov bl, 0x10                                        ; [b3 10]
    sub dx, word 0x3FE                                  ; [81 ea fe 03]
rtl_init_streams_l27C1:
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    mov dx, word [si+0x5]                               ; [8b 54 05]
    and dh, byte 0xF                                    ; [80 e6 0f]
    db 0x0A,0xF3                                   ; or dh, bl
    mov cx, word [si+0x3]                               ; [8b 4c 03]
    mov bx, word [si+0x1]                               ; [8b 5c 01]
    mov ah, byte [si]                                   ; [8a 24]
    mov al, 0x0                                         ; [b0 00]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl dx, 0x1                                         ; [d1 d2]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl dx, 0x1                                         ; [d1 d2]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl dx, 0x1                                         ; [d1 d2]
rtl_init_streams_l27ED:
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    mov ax, ds                                          ; [8c d8]
    mov bx, es                                          ; [8c c3]
    mov ds, bx                                          ; [8e db]
    mov es, ax                                          ; [8e c0]
    pop di                                              ; [5f]
    ret                                                 ; [c3]
rtl_init_streams_l27FF:
    mov bl, byte [si+0x6]                               ; [8a 5c 06]
    and bx, byte 0xF                                    ; [83 e3 0f]
    or bx, word [si+0x4]                                ; [0b 5c 04]
    or bx, word [si+0x2]                                ; [0b 5c 02]
    or bx, word [si]                                    ; [0b 1c]
    mov dx, 0x4001                                      ; [ba 01 40]
    or bl, byte 0x10                                    ; [80 cb 10]
    jmp short 0x27C1                                    ; [eb ac]
rtl_init_streams_l2815:
    mov bl, byte [si+0x6]                               ; [8a 5c 06]
    and bx, byte 0xF                                    ; [83 e3 0f]
    or bx, word [si+0x4]                                ; [0b 5c 04]
    or bx, word [si+0x2]                                ; [0b 5c 02]
    or bx, word [si]                                    ; [0b 1c]
    jne short 0x282A                                    ; [75 05]
    mov dx, 0xC001                                      ; [ba 01 c0]
    jmp short 0x27C1                                    ; [eb 97]
rtl_init_streams_l282A:
    mov dx, word [si+0x5]                               ; [8b 54 05]
    and dh, byte 0xF                                    ; [80 e6 0f]
    mov cx, word [si+0x3]                               ; [8b 4c 03]
    mov bx, word [si+0x1]                               ; [8b 5c 01]
    mov ah, byte [si]                                   ; [8a 24]
    mov al, 0x4                                         ; [b0 04]
rtl_init_streams_l283A:
    dec al                                              ; [fe c8]
    shl ah, 0x1                                         ; [d0 e4]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x283A                                    ; [79 f4]
    push ax                                             ; [50]
    mov ah, 0x0                                         ; [b4 00]
    sub ax, 0x3FE                                       ; [2d fe 03]
    stosw                                               ; [ab]
    pop ax                                              ; [58]
    mov al, 0x0                                         ; [b0 00]
    jmp short 0x27ED                                    ; [eb 9b]
rtl_init_streams_l2852:
    push si                                             ; [56]
    push di                                             ; [57]
    cld                                                 ; [fc]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    lodsw                                               ; [ad]
    mov cx, word [si]                                   ; [8b 0c]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2870                                    ; [7d 0f]
    add ax, 0x3FFE                                      ; [05 fe 3f]
    jl short 0x2875                                     ; [7c 0f]
rtl_init_streams_l2866:
    shl ax, 0x1                                         ; [d1 e0]
    shr cx, 0x1                                         ; [d1 e9]
    rcr ax, 0x1                                         ; [d1 d8]
    stosw                                               ; [ab]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l2870:
    mov ax, 0x7FFF                                      ; [b8 ff 7f]
    jmp short 0x2866                                    ; [eb f1]
rtl_init_streams_l2875:
    db 0x2B,0xC0                                   ; sub ax, ax
    jmp short 0x2866                                    ; [eb ed]
rtl_init_streams_l2879:
    push si                                             ; [56]
    push di                                             ; [57]
    push ds                                             ; [1e]
    push es                                             ; [06]
    mov ax, ds                                          ; [8c d8]
    mov bx, es                                          ; [8c c3]
    mov es, ax                                          ; [8e c0]
    mov ds, bx                                          ; [8e db]
    std                                                 ; [fd]
    lea si, word [si+0x8]                               ; [8d 74 08]
    lea di, word [di+0xA]                               ; [8d 7d 0a]
    lodsw                                               ; [ad]
    xchg bx, ax                                         ; [93]
    db 0x2B,0xC0                                   ; sub ax, ax
    shl bx, 0x1                                         ; [d1 e3]
    rcl ax, 0x1                                         ; [d1 d0]
    stosw                                               ; [ab]
    shr bx, 0x1                                         ; [d1 eb]
    je short 0x28A9                                     ; [74 10]
    sub bx, word 0x3FFE                                 ; [81 eb fe 3f]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
    movsw                                               ; [a5]
rtl_init_streams_l28A3:
    cld                                                 ; [fc]
    pop es                                              ; [07]
    pop ds                                              ; [1f]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
rtl_init_streams_l28A9:
    mov ax, 0xC001                                      ; [b8 01 c0]
    stosw                                               ; [ab]
    db 0x2B,0xC0                                   ; sub ax, ax
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    jmp short 0x28A3                                    ; [eb ee]
rtl_init_streams_l28B5:
    push dx                                             ; [52]
    push si                                             ; [56]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [si]                                    ; [0b 14]
    or dx, word [si+0x2]                                ; [0b 54 02]
    or dx, word [si+0x4]                                ; [0b 54 04]
    jne short 0x28E9                                    ; [75 21]
    cmp bx, -0x1                                        ; [83 fb ff]
    je short 0x28E5                                     ; [74 18]
    cmp word [bx+0x8], 0x4001                           ; [81 7f 08 01 40]
    jl short 0x28E5                                     ; [7c 11]
    mov dx, word [bx+0x6]                               ; [8b 57 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [bx]                                    ; [0b 17]
    or dx, word [bx+0x2]                                ; [0b 57 02]
    or dx, word [bx+0x4]                                ; [0b 57 04]
    jne short 0x292A                                    ; [75 45]
rtl_init_streams_l28E5:
    clc                                                 ; [f8]
rtl_init_streams_l28E6:
    pop si                                              ; [5e]
    pop dx                                              ; [5a]
    ret                                                 ; [c3]
rtl_init_streams_l28E9:
    cmp bx, -0x1                                        ; [83 fb ff]
    je short 0x292C                                     ; [74 3e]
    cmp word [bx+0x8], 0x4001                           ; [81 7f 08 01 40]
    jl short 0x292C                                     ; [7c 37]
    mov dx, word [bx+0x6]                               ; [8b 57 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [bx]                                    ; [0b 17]
    or dx, word [bx+0x2]                                ; [0b 57 02]
    or dx, word [bx+0x4]                                ; [0b 57 04]
    je short 0x292C                                     ; [74 26]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    cmp dx, word [bx+0x6]                               ; [3b 57 06]
    ja short 0x292C                                     ; [77 1e]
    jb short 0x292A                                     ; [72 1a]
    mov dx, word [si+0x4]                               ; [8b 54 04]
    cmp dx, word [bx+0x4]                               ; [3b 57 04]
    ja short 0x292C                                     ; [77 14]
    jb short 0x292A                                     ; [72 10]
    mov dx, word [si+0x2]                               ; [8b 54 02]
    cmp dx, word [bx+0x2]                               ; [3b 57 02]
    ja short 0x292C                                     ; [77 0a]
    jb short 0x292A                                     ; [72 06]
    mov dx, word [si]                                   ; [8b 14]
    cmp dx, word [bx]                                   ; [3b 17]
    ja short 0x292C                                     ; [77 02]
rtl_init_streams_l292A:
    db 0x8B,0xF3                                   ; mov si, bx
rtl_init_streams_l292C:
    push di                                             ; [57]
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 8d 14]
    mov cx, 0x6                                         ; [b9 06 00]
    cld                                                 ; [fc]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    stc                                                 ; [f9]
    pop di                                              ; [5f]
    jmp short 0x28E6                                    ; [eb aa]
rtl_init_streams_l293C:
    mov cl, 0x1                                         ; [b1 01]
    jmp short 0x2942                                    ; [eb 02]
rtl_init_streams_l2940:
    mov cl, 0x0                                         ; [b1 00]
rtl_init_streams_l2942:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x6]                               ; [8d 66 fa]
    push si                                             ; [56]
    push di                                             ; [57]
    mov si, word [bp+0x8]                               ; [8b 76 08]
    mov di, word [bp+0x6]                               ; [8b 7e 06]
    db 0x8A,0xC1                                   ; mov al, cl
    xor al, byte [di+0xA]                               ; [32 45 0a]
    xor al, byte [si+0xA]                               ; [32 44 0a]
    mov byte [bp-0x6], al                               ; [88 46 fa]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    mov bx, word [di+0x8]                               ; [8b 5d 08]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x299F                                    ; [7d 39]
    cmp bx, word 0x4001                                 ; [81 fb 01 40]
    jge short 0x29BC                                    ; [7d 50]
    db 0x3B,0xC3                                   ; cmp ax, bx
    jge short 0x2978                                    ; [7d 08]
    xor cl, byte [di+0xA]                               ; [32 4d 0a]
    xchg bx, ax                                         ; [93]
    db 0x87, 0xF7                                       ; xchg si, di
    jmp short 0x297B                                    ; [eb 03]
rtl_init_streams_l2978:
    mov cl, byte [si+0xA]                               ; [8a 4c 0a]
rtl_init_streams_l297B:
    mov byte [bp-0x5], cl                               ; [88 4e fb]
    mov cx, word [si+0x8]                               ; [8b 4c 08]
    mov word [bp-0x4], cx                               ; [89 4e fc]
    cmp bx, word 0xC001                                 ; [81 fb 01 c0]
    jle short 0x2991                                    ; [7e 07]
    db 0x2B,0xC3                                   ; sub ax, bx
    cmp ax, strict word 0x40                            ; [3d 40 00]
    jle short 0x29E6                                    ; [7e 55]
rtl_init_streams_l2991:
    mov ax, word [si]                                   ; [8b 04]
    mov bx, word [si+0x2]                               ; [8b 5c 02]
    mov cx, word [si+0x4]                               ; [8b 4c 04]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    jmp near 0x2AC9                                     ; [e9 2a 01]
rtl_init_streams_l299F:
    push bx                                             ; [53]
    push di                                             ; [57]
    db 0x8B,0xDF                                   ; mov bx, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 0c ff]
    pop di                                              ; [5f]
    pop bx                                              ; [5b]
    jb short 0x29E3                                     ; [72 36]
    cmp bx, word 0x4001                                 ; [81 fb 01 40]
    jl short 0x29D0                                     ; [7c 1d]
    mov al, byte [bp-0x6]                               ; [8a 46 fa]
    db 0x0A,0xC0                                   ; or al, al
    jne short 0x29DD                                    ; [75 23]
    jmp short 0x29D0                                    ; [eb 14]
rtl_init_streams_l29BC:
    mov bx, 0xFFFF                                      ; [bb ff ff]
    mov al, byte [di+0xA]                               ; [8a 45 0a]
    db 0x32,0xC1                                   ; xor al, cl
    db 0x8B,0xF7                                   ; mov si, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 e9 fe]
    jb short 0x29E3                                     ; [72 15]
    jmp short 0x29D3                                    ; [eb 03]
rtl_init_streams_l29D0:
    mov al, byte [si+0xA]                               ; [8a 44 0a]
rtl_init_streams_l29D3:
    mov byte [bp-0x5], al                               ; [88 46 fb]
    mov word [bp-0x4], 0x4001                           ; [c7 46 fc 01 40]
    jmp short 0x2991                                    ; [eb b4]
rtl_init_streams_l29DD:
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x206D                                    ; [e8 8a f6]
rtl_init_streams_l29E3:
    jmp near 0x2ADC                                     ; [e9 f6 00]
rtl_init_streams_l29E6:
    mov byte [bp-0x1], al                               ; [88 46 ff]
    mov ax, word [di]                                   ; [8b 05]
    mov bx, word [di+0x2]                               ; [8b 5d 02]
    mov cx, word [di+0x4]                               ; [8b 4d 04]
    mov dx, word [di+0x6]                               ; [8b 55 06]
    mov byte [bp-0x2], 0x0                              ; [c6 46 fe 00]
    sub byte [bp-0x1], 0x8                              ; [80 6e ff 08]
    jl short 0x2A17                                     ; [7c 19]
rtl_init_streams_l29FE:
    mov byte [bp-0x2], al                               ; [88 46 fe]
    db 0x8A,0xC4                                   ; mov al, ah
    db 0x8A,0xE3                                   ; mov ah, bl
    db 0x8A,0xDF                                   ; mov bl, bh
    db 0x8A,0xF9                                   ; mov bh, cl
    db 0x8A,0xCD                                   ; mov cl, ch
    db 0x8A,0xEA                                   ; mov ch, dl
    db 0x8A,0xD6                                   ; mov dl, dh
    mov dh, 0x0                                         ; [b6 00]
    sub byte [bp-0x1], 0x8                              ; [80 6e ff 08]
    jge short 0x29FE                                    ; [7d e7]
rtl_init_streams_l2A17:
    and byte [bp-0x1], 0x7                              ; [80 66 ff 07]
    je short 0x2A2D                                     ; [74 10]
rtl_init_streams_l2A1D:
    shr dx, 0x1                                         ; [d1 ea]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr byte [bp-0x2], 0x1                              ; [d0 5e fe]
    dec byte [bp-0x1]                                   ; [fe 4e ff]
    jne short 0x2A1D                                    ; [75 f0]
rtl_init_streams_l2A2D:
    db 0x2B,0xFF                                   ; sub di, di
    cmp byte [bp-0x6], 0x0                              ; [80 7e fa 00]
    jne short 0x2A52                                    ; [75 1d]
    add ax, word [si]                                   ; [03 04]
    adc bx, word [si+0x2]                               ; [13 5c 02]
    adc cx, word [si+0x4]                               ; [13 4c 04]
    adc dx, word [si+0x6]                               ; [13 54 06]
    jae short 0x2AA9                                    ; [73 67]
    rcr dx, 0x1                                         ; [d1 da]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr byte [bp-0x2], 0x1                              ; [d0 5e fe]
    inc word [bp-0x4]                                   ; [ff 46 fc]
    jmp short 0x2AA9                                    ; [eb 57]
rtl_init_streams_l2A52:
    xor byte [bp-0x5], 0x1                              ; [80 76 fb 01]
    sub ax, word [si]                                   ; [2b 04]
    sbb bx, word [si+0x2]                               ; [1b 5c 02]
    sbb cx, word [si+0x4]                               ; [1b 4c 04]
    sbb dx, word [si+0x6]                               ; [1b 54 06]
    jae short 0x2A7B                                    ; [73 18]
    xor byte [bp-0x5], 0x1                              ; [80 76 fb 01]
    not dx                                              ; [f7 d2]
    not cx                                              ; [f7 d1]
    not bx                                              ; [f7 d3]
    not ax                                              ; [f7 d0]
    neg byte [bp-0x2]                                   ; [f6 5e fe]
    cmc                                                 ; [f5]
    db 0x13,0xC7                                   ; adc ax, di
    db 0x13,0xDF                                   ; adc bx, di
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xD7                                   ; adc dx, di
rtl_init_streams_l2A7B:
    mov si, 0x40                                        ; [be 40 00]
    db 0x0A,0xF6                                   ; or dh, dh
    js short 0x2AA9                                     ; [78 27]
rtl_init_streams_l2A82:
    dec si                                              ; [4e]
    je short 0x2A9A                                     ; [74 15]
rtl_init_streams_l2A85:
    shl byte [bp-0x2], 0x1                              ; [d0 66 fe]
    rcl ax, 0x1                                         ; [d1 d0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x2A82                                    ; [79 f0]
    sub si, byte 0x40                                   ; [83 ee 40]
    add word [bp-0x4], si                               ; [01 76 fc]
    jmp short 0x2AA9                                    ; [eb 0f]
rtl_init_streams_l2A9A:
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x2A85                                    ; [75 e7]
    mov word [bp-0x4], 0xC001                           ; [c7 46 fc 01 c0]
    mov byte [bp-0x5], 0x0                              ; [c6 46 fb 00]
    jmp short 0x2AC9                                    ; [eb 20]
rtl_init_streams_l2AA9:
    shl byte [bp-0x2], 0x1                              ; [d0 66 fe]
    db 0x13,0xC7                                   ; adc ax, di
    db 0x13,0xDF                                   ; adc bx, di
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xD7                                   ; adc dx, di
    jae short 0x2ABB                                    ; [73 05]
    rcr dx, 0x1                                         ; [d1 da]
    inc word [bp-0x4]                                   ; [ff 46 fc]
rtl_init_streams_l2ABB:
    cmp word [bp-0x4], 0x4001                           ; [81 7e fc 01 40]
    jge short 0x2AE4                                    ; [7d 22]
    cmp word [bp-0x4], 0xC001                           ; [81 7e fc 01 c0]
    jle short 0x2AED                                    ; [7e 24]
rtl_init_streams_l2AC9:
    cld                                                 ; [fc]
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    mov ax, word [bp-0x4]                               ; [8b 46 fc]
    stosw                                               ; [ab]
    mov al, byte [bp-0x5]                               ; [8a 46 fb]
    stosb                                               ; [aa]
rtl_init_streams_l2ADC:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret 0x6                                             ; [c2 06 00]
rtl_init_streams_l2AE4:
    mov ch, 0x8                                         ; [b5 08]
    mov word [bp-0x4], 0x4001                           ; [c7 46 fc 01 40]
    jmp short 0x2AF4                                    ; [eb 07]
rtl_init_streams_l2AED:
    mov ch, 0x10                                        ; [b5 10]
    mov word [bp-0x4], 0xC001                           ; [c7 46 fc 01 c0]
rtl_init_streams_l2AF4:
    call near 0x3DBF                                    ; [e8 c8 12]
    mov byte [bp-0x5], 0x0                              ; [c6 46 fb 00]
    db 0x2B,0xC0                                   ; sub ax, ax
    db 0x8B,0xD8                                   ; mov bx, ax
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xD0                                   ; mov dx, ax
    jmp short 0x2AC9                                    ; [eb c4]
rtl_init_streams_l2B05:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x2]                               ; [8d 66 fe]
    push si                                             ; [56]
    push di                                             ; [57]
    cld                                                 ; [fc]
    mov si, word [bp+0x8]                               ; [8b 76 08]
    mov di, word [bp+0x6]                               ; [8b 7e 06]
    mov cl, byte [si+0xA]                               ; [8a 4c 0a]
    xor cl, byte [di+0xA]                               ; [32 4d 0a]
    mov byte [bp-0x2], cl                               ; [88 4e fe]
    mov bx, word [di+0x8]                               ; [8b 5d 08]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2B50                                    ; [7d 28]
    cmp bx, word 0x4001                                 ; [81 fb 01 40]
    jge short 0x2B65                                    ; [7d 37]
    db 0x3B,0xC3                                   ; cmp ax, bx
    jl short 0x2B33                                     ; [7c 01]
    xchg bx, ax                                         ; [93]
rtl_init_streams_l2B33:
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x2B4B                                    ; [7e 13]
    db 0x03,0xC3                                   ; add ax, bx
    dec ax                                              ; [48]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2B83                                    ; [7d 43]
    inc ax                                              ; [40]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jg short 0x2B96                                     ; [7f 50]
    mov ch, 0x10                                        ; [b5 10]
    call near 0x3DBF                                    ; [e8 74 12]
rtl_init_streams_l2B4B:
    mov ax, 0xC001                                      ; [b8 01 c0]
    jmp short 0x2B8B                                    ; [eb 3b]
rtl_init_streams_l2B50:
    push di                                             ; [57]
    db 0x8B,0xDF                                   ; mov bx, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 5c fd]
    pop di                                              ; [5f]
    jb short 0x2B94                                     ; [72 38]
    cmp word [di+0x8], 0xC001                           ; [81 7d 08 01 c0]
    jle short 0x2B7B                                    ; [7e 18]
    jmp short 0x2B88                                    ; [eb 23]
rtl_init_streams_l2B65:
    push si                                             ; [56]
    mov bx, 0xFFFF                                      ; [bb ff ff]
    db 0x8B,0xF7                                   ; mov si, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 44 fd]
    pop si                                              ; [5e]
    jb short 0x2B94                                     ; [72 20]
    cmp word [si+0x8], 0xC001                           ; [81 7c 08 01 c0]
    jg short 0x2B88                                     ; [7f 0d]
rtl_init_streams_l2B7B:
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x206D                                    ; [e8 ec f4]
    jmp short 0x2BE6                                    ; [eb 63]
rtl_init_streams_l2B83:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 37 12]
rtl_init_streams_l2B88:
    mov ax, 0x4001                                      ; [b8 01 40]
rtl_init_streams_l2B8B:
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    mov cl, byte [bp-0x2]                               ; [8a 4e fe]
    call near 0x205B                                    ; [e8 c7 f4]
rtl_init_streams_l2B94:
    jmp short 0x2BE6                                    ; [eb 50]
rtl_init_streams_l2B96:
    push ax                                             ; [50]
    call near 0x2086                                    ; [e8 ec f4]
    db 0x87, 0xF7                                       ; xchg si, di
    call near 0x2086                                    ; [e8 e7 f4]
    call near 0x2BEE                                    ; [e8 4c 00]
    add word [0x00D8], 0x18                             ; [83 06 d8 00 18]
    pop di                                              ; [5f]
    db 0x0B,0xD2                                   ; or dx, dx
    js short 0x2BB7                                     ; [78 0b]
    dec di                                              ; [4f]
    shl si, 0x1                                         ; [d1 e6]
    rcl ax, 0x1                                         ; [d1 d0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl dx, 0x1                                         ; [d1 d2]
rtl_init_streams_l2BB7:
    shl si, 0x1                                         ; [d1 e6]
    adc ax, strict word 0x0                             ; [15 00 00]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    jae short 0x2BCA                                    ; [73 03]
    rcr dx, 0x1                                         ; [d1 da]
    inc di                                              ; [47]
rtl_init_streams_l2BCA:
    cmp di, word 0x4001                                 ; [81 ff 01 40]
    jl short 0x2BD2                                     ; [7c 02]
    jmp short 0x2B83                                    ; [eb b1]
rtl_init_streams_l2BD2:
    db 0x8B,0xF7                                   ; mov si, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg si, ax                                         ; [96]
    stosw                                               ; [ab]
    mov al, byte [bp-0x2]                               ; [8a 46 fe]
    mov ah, 0x0                                         ; [b4 00]
    stosw                                               ; [ab]
rtl_init_streams_l2BE6:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret 0x6                                             ; [c2 06 00]
rtl_init_streams_l2BEE:
    push bp                                             ; [55]
    push di                                             ; [57]
    mov bp, word [0x00D8]                               ; [8b 2e d8 00]
    db 0x2B,0xFF                                   ; sub di, di
    db 0x8B,0xCF                                   ; mov cx, di
    db 0x8B,0xF7                                   ; mov si, di
    test byte [bp+0xF], 0x80                            ; [f6 46 0f 80]
    je short 0x2C06                                     ; [74 06]
    mov cx, word [bp]                                   ; [8b 4e 00]
    mov si, word [bp+0x2]                               ; [8b 76 02]
rtl_init_streams_l2C06:
    test byte [bp+0x3], 0x80                            ; [f6 46 03 80]
    je short 0x2C1B                                     ; [74 0f]
    add cx, word [bp+0xC]                               ; [03 4e 0c]
    adc si, word [bp+0xE]                               ; [13 76 0e]
    db 0x13,0xFF                                   ; adc di, di
    test byte [bp+0xF], 0x80                            ; [f6 46 0f 80]
    je short 0x2C1B                                     ; [74 01]
    dec di                                              ; [4f]
rtl_init_streams_l2C1B:
    db 0x2B,0xDB                                   ; sub bx, bx
    mov ax, word [bp+0xC]                               ; [8b 46 0c]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xC8                                   ; add cx, ax
    db 0x13,0xF2                                   ; adc si, dx
    adc di, byte 0x0                                    ; [83 d7 00]
    mov ax, word [bp+0x10]                              ; [8b 46 10]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x2C48                                     ; [74 17]
    mul word [bp]                                       ; [f7 66 00]
    db 0x03,0xC8                                   ; add cx, ax
    db 0x13,0xF2                                   ; adc si, dx
    adc di, byte 0x0                                    ; [83 d7 00]
    mov ax, word [bp+0x10]                              ; [8b 46 10]
    mul word [bp+0x2]                                   ; [f7 66 02]
    db 0x03,0xF0                                   ; add si, ax
    db 0x13,0xFA                                   ; adc di, dx
    adc bx, byte 0x0                                    ; [83 d3 00]
rtl_init_streams_l2C48:
    mov ax, word [bp+0xC]                               ; [8b 46 0c]
    mul word [bp+0x6]                                   ; [f7 66 06]
    db 0x03,0xF0                                   ; add si, ax
    db 0x13,0xFA                                   ; adc di, dx
    adc bx, byte 0x0                                    ; [83 d3 00]
    mov ax, word [bp+0xE]                               ; [8b 46 0e]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xF0                                   ; add si, ax
    db 0x13,0xFA                                   ; adc di, dx
    adc bx, byte 0x0                                    ; [83 d3 00]
    mov ax, word [bp+0x12]                              ; [8b 46 12]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x2C73                                     ; [74 0a]
    mul word [bp]                                       ; [f7 66 00]
    db 0x03,0xF0                                   ; add si, ax
    db 0x13,0xFA                                   ; adc di, dx
    adc bx, byte 0x0                                    ; [83 d3 00]
rtl_init_streams_l2C73:
    db 0x2B,0xC9                                   ; sub cx, cx
    push si                                             ; [56]
    db 0x8B,0xF1                                   ; mov si, cx
    mov ax, word [bp+0xE]                               ; [8b 46 0e]
    mul word [bp+0x6]                                   ; [f7 66 06]
    db 0x03,0xF8                                   ; add di, ax
    db 0x13,0xDA                                   ; adc bx, dx
    adc cx, byte 0x0                                    ; [83 d1 00]
    mov ax, word [bp+0x10]                              ; [8b 46 10]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x2CA3                                     ; [74 17]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xF8                                   ; add di, ax
    db 0x13,0xDA                                   ; adc bx, dx
    adc cx, byte 0x0                                    ; [83 d1 00]
    mov ax, word [bp+0x10]                              ; [8b 46 10]
    mul word [bp+0x6]                                   ; [f7 66 06]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    adc si, byte 0x0                                    ; [83 d6 00]
rtl_init_streams_l2CA3:
    mov ax, word [bp+0x12]                              ; [8b 46 12]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x2CCE                                     ; [74 24]
    mul word [bp+0x2]                                   ; [f7 66 02]
    db 0x03,0xF8                                   ; add di, ax
    db 0x13,0xDA                                   ; adc bx, dx
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc si, byte 0x0                                    ; [83 d6 00]
    mov ax, word [bp+0x12]                              ; [8b 46 12]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    adc si, byte 0x0                                    ; [83 d6 00]
    mov ax, word [bp+0x12]                              ; [8b 46 12]
    mul word [bp+0x6]                                   ; [f7 66 06]
    db 0x03,0xC8                                   ; add cx, ax
    db 0x13,0xF2                                   ; adc si, dx
rtl_init_streams_l2CCE:
    db 0x8B,0xD6                                   ; mov dx, si
    xchg di, ax                                         ; [97]
    pop si                                              ; [5e]
    pop di                                              ; [5f]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l2CD5:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x8]                               ; [8d 66 f8]
    mov bx, word [bp+0x8]                               ; [8b 5e 08]
    push word [bx+0x6]                                  ; [ff 77 06]
    push word [bx+0x4]                                  ; [ff 77 04]
    push word [bx+0x2]                                  ; [ff 77 02]
    push word [bx]                                      ; [ff 37]
    db 0x2B,0xC0                                   ; sub ax, ax
    push ax                                             ; [50]
    push si                                             ; [56]
    push di                                             ; [57]
    cld                                                 ; [fc]
    mov di, word [bp+0x6]                               ; [8b 7e 06]
    mov al, byte [bx+0xA]                               ; [8a 47 0a]
    xor al, byte [di+0xA]                               ; [32 45 0a]
    mov byte [bp-0x3], al                               ; [88 46 fd]
    mov si, word [di+0x8]                               ; [8b 75 08]
    mov ax, word [bx+0x8]                               ; [8b 47 08]
    cmp si, word 0x4001                                 ; [81 fe 01 40]
    jge short 0x2D45                                    ; [7d 3e]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2D5B                                    ; [7d 4f]
    cmp si, word 0xC001                                 ; [81 fe 01 c0]
    jle short 0x2D31                                    ; [7e 1f]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x2D28                                    ; [7e 11]
    db 0x2B,0xC6                                   ; sub ax, si
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2D2D                                    ; [7d 0f]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jg short 0x2D6A                                     ; [7f 47]
    mov ch, 0x10                                        ; [b5 10]
    call near 0x3DBF                                    ; [e8 97 10]
rtl_init_streams_l2D28:
    mov ax, 0xC001                                      ; [b8 01 c0]
    jmp short 0x2D39                                    ; [eb 0c]
rtl_init_streams_l2D2D:
    mov ch, 0x8                                         ; [b5 08]
    jmp short 0x2D33                                    ; [eb 02]
rtl_init_streams_l2D31:
    mov ch, 0x4                                         ; [b5 04]
rtl_init_streams_l2D33:
    call near 0x3DBF                                    ; [e8 89 10]
rtl_init_streams_l2D36:
    mov ax, 0x4001                                      ; [b8 01 40]
rtl_init_streams_l2D39:
    mov cl, byte [bp-0x3]                               ; [8a 4e fd]
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x205B                                    ; [e8 19 f3]
rtl_init_streams_l2D42:
    jmp near 0x2F1A                                     ; [e9 d5 01]
rtl_init_streams_l2D45:
    db 0x8B,0xF7                                   ; mov si, di
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 68 fb]
    jb short 0x2D42                                     ; [72 f3]
    cmp word [bx+0x8], 0x4001                           ; [81 7f 08 01 40]
    jl short 0x2D28                                     ; [7c d2]
    call near 0x206D                                    ; [e8 14 f3]
    jmp short 0x2D42                                    ; [eb e7]
rtl_init_streams_l2D5B:
    db 0x8B,0xF3                                   ; mov si, bx
    mov bx, 0xFFFF                                      ; [bb ff ff]
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    call near 0x28B5                                    ; [e8 4f fb]
    jb short 0x2D42                                     ; [72 da]
    jmp short 0x2D36                                    ; [eb cc]
rtl_init_streams_l2D6A:
    mov word [bp-0x2], ax                               ; [89 46 fe]
    db 0x2B,0xC9                                   ; sub cx, cx
    mov dx, word [bp-0xA]                               ; [8b 56 f6]
    mov si, word [di+0x6]                               ; [8b 75 06]
    db 0x3B,0xF2                                   ; cmp si, dx
    ja short 0x2D7C                                     ; [77 03]
    db 0x2B,0xD6                                   ; sub dx, si
    inc cx                                              ; [41]
rtl_init_streams_l2D7C:
    mov ax, word [bp-0xC]                               ; [8b 46 f4]
    div si                                              ; [f7 f6]
    adc ax, strict word 0x1                             ; [15 01 00]
    db 0x12,0xCD                                   ; adc cl, ch
    mov byte [bp-0x4], cl                               ; [88 4e fc]
    mov word [bp-0x6], ax                               ; [89 46 fa]
    push ax                                             ; [50]
    mov ax, word [di]                                   ; [8b 05]
    mov bx, word [di+0x2]                               ; [8b 5d 02]
    jcxz 0x2DA5                                         ; [e3 11]
    mov dx, word [di+0x4]                               ; [8b 55 04]
rtl_init_streams_l2D97:
    sub word [bp-0x10], ax                              ; [29 46 f0]
    sbb word [bp-0xE], bx                               ; [19 5e f2]
    sbb word [bp-0xC], dx                               ; [19 56 f4]
    sbb word [bp-0xA], si                               ; [19 76 f6]
    loop 0x2D97                                         ; [e2 f2]
rtl_init_streams_l2DA5:
    pop si                                              ; [5e]
    mul si                                              ; [f7 e6]
    mov word [bp-0x12], ax                              ; [89 46 ee]
    xchg dx, ax                                         ; [92]
    xchg bx, ax                                         ; [93]
    mul si                                              ; [f7 e6]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    mov ax, word [di+0x4]                               ; [8b 45 04]
    mul si                                              ; [f7 e6]
    db 0x03,0xC8                                   ; add cx, ax
    adc dx, byte 0x0                                    ; [83 d2 00]
    xchg dx, ax                                         ; [92]
    xchg si, ax                                         ; [96]
    mul word [di+0x6]                                   ; [f7 65 06]
    db 0x03,0xC6                                   ; add ax, si
    adc dx, byte 0x0                                    ; [83 d2 00]
    sub bx, word [bp-0x10]                              ; [2b 5e f0]
    sbb cx, word [bp-0xE]                               ; [1b 4e f2]
    sbb ax, word [bp-0xC]                               ; [1b 46 f4]
    sbb dx, word [bp-0xA]                               ; [1b 56 f6]
    mov word [bp-0x10], bx                              ; [89 5e f0]
    mov word [bp-0xE], cx                               ; [89 4e f2]
    mov word [bp-0xC], ax                               ; [89 46 f4]
    mov si, word [di+0x6]                               ; [8b 75 06]
    div si                                              ; [f7 f6]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    db 0x2B,0xD2                                   ; sub dx, dx
    stc                                                 ; [f9]
    db 0x13,0xC2                                   ; adc ax, dx
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x2B,0xD0                                   ; sub dx, ax
    mov word [bp-0x8], dx                               ; [89 56 f8]
    sbb word [bp-0x6], cx                               ; [19 4e fa]
    sbb byte [bp-0x4], 0x0                              ; [80 5e fc 00]
    push ax                                             ; [50]
    mov ax, word [di]                                   ; [8b 05]
    mov bx, word [di+0x2]                               ; [8b 5d 02]
    jcxz 0x2E10                                         ; [e3 11]
    mov dx, word [di+0x4]                               ; [8b 55 04]
rtl_init_streams_l2E02:
    sub word [bp-0x12], ax                              ; [29 46 ee]
    sbb word [bp-0x10], bx                              ; [19 5e f0]
    sbb word [bp-0xE], dx                               ; [19 56 f2]
    sbb word [bp-0xC], si                               ; [19 76 f4]
    loop 0x2E02                                         ; [e2 f2]
rtl_init_streams_l2E10:
    pop si                                              ; [5e]
    mul si                                              ; [f7 e6]
    xchg dx, ax                                         ; [92]
    xchg bx, ax                                         ; [93]
    mul si                                              ; [f7 e6]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    mov ax, word [di+0x4]                               ; [8b 45 04]
    mul si                                              ; [f7 e6]
    db 0x03,0xC8                                   ; add cx, ax
    adc dx, byte 0x0                                    ; [83 d2 00]
    xchg dx, ax                                         ; [92]
    xchg si, ax                                         ; [96]
    mul word [di+0x6]                                   ; [f7 65 06]
    db 0x03,0xC6                                   ; add ax, si
    adc dx, byte 0x0                                    ; [83 d2 00]
    sub bx, word [bp-0x12]                              ; [2b 5e ee]
    sbb cx, word [bp-0x10]                              ; [1b 4e f0]
    sbb ax, word [bp-0xE]                               ; [1b 46 f2]
    sbb dx, word [bp-0xC]                               ; [1b 56 f4]
    mov word [bp-0x12], bx                              ; [89 5e ee]
    mov word [bp-0x10], cx                              ; [89 4e f0]
    mov word [bp-0xE], ax                               ; [89 46 f2]
    mov si, word [di+0x6]                               ; [8b 75 06]
    div si                                              ; [f7 f6]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    db 0x2B,0xD2                                   ; sub dx, dx
    stc                                                 ; [f9]
    db 0x13,0xC2                                   ; adc ax, dx
    db 0x13,0xCA                                   ; adc cx, dx
    mov word [bp-0xA], ax                               ; [89 46 f6]
    add word [bp-0x8], cx                               ; [01 4e f8]
    adc word [bp-0x6], dx                               ; [11 56 fa]
    adc byte [bp-0x4], dl                               ; [10 56 fc]
    xchg si, ax                                         ; [96]
    mov dx, word [di+0x2]                               ; [8b 55 02]
    xchg dx, ax                                         ; [92]
    mov bx, word [di+0x4]                               ; [8b 5d 04]
    jcxz 0x2E74                                         ; [e3 0b]
rtl_init_streams_l2E69:
    sub word [bp-0x12], ax                              ; [29 46 ee]
    sbb word [bp-0x10], bx                              ; [19 5e f0]
    sbb word [bp-0xE], dx                               ; [19 56 f2]
    loop 0x2E69                                         ; [e2 f5]
rtl_init_streams_l2E74:
    mul si                                              ; [f7 e6]
    xchg dx, ax                                         ; [92]
    xchg bx, ax                                         ; [93]
    mul si                                              ; [f7 e6]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    mov ax, word [di+0x6]                               ; [8b 45 06]
    mul si                                              ; [f7 e6]
    db 0x03,0xC1                                   ; add ax, cx
    adc dx, byte 0x0                                    ; [83 d2 00]
    sub bx, word [bp-0x12]                              ; [2b 5e ee]
    sbb ax, word [bp-0x10]                              ; [1b 46 f0]
    sbb dx, word [bp-0xE]                               ; [1b 56 f2]
    mov word [bp-0x12], bx                              ; [89 5e ee]
    mov word [bp-0x10], ax                              ; [89 46 f0]
    mov si, word [di+0x4]                               ; [8b 75 04]
    db 0x03,0xF6                                   ; add si, si
    mov si, word [di+0x6]                               ; [8b 75 06]
    adc si, byte 0x0                                    ; [83 d6 00]
    jae short 0x2EA8                                    ; [73 04]
    db 0x87, 0xDA                                       ; xchg bx, dx
    jmp short 0x2EB9                                    ; [eb 11]
rtl_init_streams_l2EA8:
    shl bx, 0x1                                         ; [d1 e3]
    rcl ax, 0x1                                         ; [d1 d0]
    rcl dx, 0x1                                         ; [d1 d2]
    div si                                              ; [f7 f6]
    xchg bx, ax                                         ; [93]
    div si                                              ; [f7 f6]
    shr bx, 0x1                                         ; [d1 eb]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr dh, 0x1                                         ; [d0 de]
rtl_init_streams_l2EB9:
    mov cx, 0xFFFF                                      ; [b9 ff ff]
    db 0x8B,0xF1                                   ; mov si, cx
    db 0x8A,0xD1                                   ; mov dl, cl
    not bx                                              ; [f7 d3]
    not ax                                              ; [f7 d0]
    neg dh                                              ; [f6 de]
    cmc                                                 ; [f5]
    adc ax, strict word 0x0                             ; [15 00 00]
    adc bx, word [bp-0xA]                               ; [13 5e f6]
    adc cx, word [bp-0x8]                               ; [13 4e f8]
    adc si, word [bp-0x6]                               ; [13 76 fa]
    adc dl, byte [bp-0x4]                               ; [12 56 fc]
    shr dl, 0x1                                         ; [d0 ea]
    jae short 0x2EE7                                    ; [73 0d]
    rcr si, 0x1                                         ; [d1 de]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr dh, 0x1                                         ; [d0 de]
    inc word [bp-0x2]                                   ; [ff 46 fe]
rtl_init_streams_l2EE7:
    db 0x2B,0xFF                                   ; sub di, di
    db 0x02,0xF6                                   ; add dh, dh
    db 0x13,0xC7                                   ; adc ax, di
    db 0x13,0xDF                                   ; adc bx, di
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xF7                                   ; adc si, di
    adc dl, byte 0x0                                    ; [80 d2 00]
    mov dx, word [bp-0x2]                               ; [8b 56 fe]
    je short 0x2EFF                                     ; [74 04]
    mov si, 0x8000                                      ; [be 00 80]
    inc dx                                              ; [42]
rtl_init_streams_l2EFF:
    cmp dx, word 0x4001                                 ; [81 fa 01 40]
    jl short 0x2F08                                     ; [7c 03]
    jmp near 0x2D36                                     ; [e9 2e fe]
rtl_init_streams_l2F08:
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    cld                                                 ; [fc]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg si, ax                                         ; [96]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    mov al, byte [bp-0x3]                               ; [8a 46 fd]
    db 0x98                                        ; cbw
    stosw                                               ; [ab]
rtl_init_streams_l2F1A:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret 0x6                                             ; [c2 06 00]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x2F58                                    ; [7e 29]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x2F5C                                    ; [7d 28]
    cmp byte [si+0xA], 0x0                              ; [80 7c 0a 00]
    jne short 0x2F66                                    ; [75 2c]
    call near 0x2086                                    ; [e8 49 f1]
    call near 0x2F77                                    ; [e8 37 00]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2CD5                                    ; [e8 8b fd]
    push di                                             ; [57]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2940                                    ; [e8 f0 f9]
    dec word [si+0x8]                                   ; [ff 4c 08]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
rtl_init_streams_l2F58:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l2F5C:
    mov bx, 0xFFFF                                      ; [bb ff ff]
    db 0x8B,0xFE                                   ; mov di, si
    call near 0x28B5                                    ; [e8 51 f9]
    jmp short 0x2F58                                    ; [eb f2]
rtl_init_streams_l2F66:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 54 0e]
    db 0x8B,0xFE                                   ; mov di, si
    call near 0x2046                                    ; [e8 d6 f0]
    mov word [di+0x8], 0x4001                           ; [c7 45 08 01 40]
    jmp short 0x2F58                                    ; [eb e1]
rtl_init_streams_l2F77:
    push si                                             ; [56]
    push di                                             ; [57]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    mov bx, word [di+0x8]                               ; [8b 5d 08]
    mov dx, word [di+0x6]                               ; [8b 55 06]
    mov ax, word [di+0x4]                               ; [8b 45 04]
    mov cx, word [di+0x2]                               ; [8b 4d 02]
    sar bx, 0x1                                         ; [d1 fb]
    jae short 0x2F94                                    ; [73 07]
    inc bx                                              ; [43]
    shr dx, 0x1                                         ; [d1 ea]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr cx, 0x1                                         ; [d1 d9]
rtl_init_streams_l2F94:
    cmp dx, -0x2                                        ; [83 fa fe]
    jae short 0x2FB6                                    ; [73 1d]
    push bx                                             ; [53]
    push cx                                             ; [51]
    db 0x8B,0xCA                                   ; mov cx, dx
    db 0x8B,0xD8                                   ; mov bx, ax
    db 0x8B,0xF2                                   ; mov si, dx
    stc                                                 ; [f9]
    rcr si, 0x1                                         ; [d1 de]
rtl_init_streams_l2FA4:
    div si                                              ; [f7 f6]
    dec si                                              ; [4e]
    db 0x3B,0xF0                                   ; cmp si, ax
    jbe short 0x2FBD                                    ; [76 12]
    inc si                                              ; [46]
    db 0x03,0xF0                                   ; add si, ax
    rcr si, 0x1                                         ; [d1 de]
    db 0x8B,0xD1                                   ; mov dx, cx
    db 0x8B,0xC3                                   ; mov ax, bx
    jmp short 0x2FA4                                    ; [eb ee]
rtl_init_streams_l2FB6:
    stc                                                 ; [f9]
    rcr dx, 0x1                                         ; [d1 da]
    rcr ax, 0x1                                         ; [d1 d8]
    jmp short 0x2FD4                                    ; [eb 17]
rtl_init_streams_l2FBD:
    inc si                                              ; [46]
    db 0x3B,0xF0                                   ; cmp si, ax
    jae short 0x2FC3                                    ; [73 01]
    xchg si, ax                                         ; [96]
rtl_init_streams_l2FC3:
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    db 0x2B,0xD2                                   ; sub dx, dx
    db 0x03,0xF1                                   ; add si, cx
    rcr si, 0x1                                         ; [d1 de]
    rcr ax, 0x1                                         ; [d1 d8]
    db 0x13,0xC2                                   ; adc ax, dx
    db 0x13,0xD6                                   ; adc dx, si
rtl_init_streams_l2FD4:
    cld                                                 ; [fc]
    db 0x2B,0xC9                                   ; sub cx, cx
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    mov ax, 0x0                                         ; [b8 00 00]
    stosw                                               ; [ab]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
    add byte [bp+si], al                                ; [00 02]
    inc ax                                              ; [40]
    inc dx                                              ; [42]
    add word [bp+di], ax                                ; [01 03]
    inc cx                                              ; [41]
    inc bx                                              ; [43]
rtl_init_streams_l2FEF:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push word [di+0xA]                                  ; [ff 75 0a]
    lea sp, word [bp-0x6]                               ; [8d 66 fa]
    push si                                             ; [56]
    push di                                             ; [57]
    mov ax, word [di]                                   ; [8b 05]
    mov bx, word [di+0x2]                               ; [8b 5d 02]
    mov cx, word [di+0x4]                               ; [8b 4d 04]
    mov dx, word [di+0x6]                               ; [8b 55 06]
    mov word [bp-0x4], 0x0                              ; [c7 46 fc 00 00]
    mov di, word [di+0x8]                               ; [8b 7d 08]
    sub di, word [si+0x8]                               ; [2b 7c 08]
    jge short 0x302A                                    ; [7d 18]
    jmp short 0x3066                                    ; [eb 52]
    nop                                                 ; [90]
rtl_init_streams_l3015:
    inc di                                              ; [47]
    jmp short 0x3055                                    ; [eb 3d]
rtl_init_streams_l3018:
    dec di                                              ; [4f]
    jl short 0x3015                                     ; [7c fa]
    shl word [bp-0x4], 0x1                              ; [d1 66 fc]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    db 0x13,0xD2                                   ; adc dx, dx
    jb short 0x3043                                     ; [72 1b]
    jns short 0x3018                                    ; [79 ee]
rtl_init_streams_l302A:
    cmp dx, word [si+0x6]                               ; [3b 54 06]
    ja short 0x3043                                     ; [77 14]
    jb short 0x3018                                     ; [72 e7]
    cmp cx, word [si+0x4]                               ; [3b 4c 04]
    ja short 0x3043                                     ; [77 0d]
    jb short 0x3018                                     ; [72 e0]
    cmp bx, word [si+0x2]                               ; [3b 5c 02]
    ja short 0x3043                                     ; [77 06]
    jb short 0x3018                                     ; [72 d9]
    cmp ax, word [si]                                   ; [3b 04]
    jb short 0x3018                                     ; [72 d5]
rtl_init_streams_l3043:
    inc word [bp-0x4]                                   ; [ff 46 fc]
    sub ax, word [si]                                   ; [2b 04]
    sbb bx, word [si+0x2]                               ; [1b 5c 02]
    sbb cx, word [si+0x4]                               ; [1b 4c 04]
    sbb dx, word [si+0x6]                               ; [1b 54 06]
    db 0x0B,0xFF                                   ; or di, di
    jg short 0x3018                                     ; [7f c3]
rtl_init_streams_l3055:
    db 0x0B,0xD2                                   ; or dx, dx
    js short 0x3066                                     ; [78 0d]
    je short 0x309F                                     ; [74 44]
rtl_init_streams_l305B:
    dec di                                              ; [4f]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x305B                                    ; [79 f5]
rtl_init_streams_l3066:
    add di, word [si+0x8]                               ; [03 7c 08]
rtl_init_streams_l3069:
    push di                                             ; [57]
    mov di, word [bp-0xA]                               ; [8b 7e f6]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    pop ax                                              ; [58]
    stosw                                               ; [ab]
    mov al, byte [bp-0x2]                               ; [8a 46 fe]
    db 0x98                                        ; cbw
    stosw                                               ; [ab]
    and byte [0x00D5], 0xBC                             ; [80 26 d5 00 bc]
    mov di, 0x7                                         ; [bf 07 00]
    mov ax, word [bp-0x4]                               ; [8b 46 fc]
    cmp byte [bp-0x2], 0x1                              ; [80 7e fe 01]
    jne short 0x308E                                    ; [75 02]
    neg ax                                              ; [f7 d8]
rtl_init_streams_l308E:
    db 0x23,0xF8                                   ; and di, ax
    mov dl, byte [cs:di+0x1A37]                         ; [2e 8a 95 37 1a]
    or byte [0x00D5], dl                                ; [08 16 d5 00]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l309F:
    db 0x87, 0xD1                                       ; xchg dx, cx
    db 0x87, 0xCB                                       ; xchg cx, bx
    xchg bx, ax                                         ; [93]
    sub di, byte 0x10                                   ; [83 ef 10]
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x3055                                    ; [75 aa]
    db 0x87, 0xD1                                       ; xchg dx, cx
    db 0x87, 0xCB                                       ; xchg cx, bx
    sub di, byte 0x10                                   ; [83 ef 10]
    db 0x87, 0xD1                                       ; xchg dx, cx
    sub di, byte 0x10                                   ; [83 ef 10]
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x3055                                    ; [75 9a]
    mov di, 0xC001                                      ; [bf 01 c0]
    db 0x2B,0xD2                                   ; sub dx, dx
    db 0x2B,0xC9                                   ; sub cx, cx
    db 0x2B,0xDB                                   ; sub bx, bx
    db 0x2B,0xC0                                   ; sub ax, ax
    jmp short 0x3069                                    ; [eb a1]
rtl_init_streams_l30C8:
    mov dx, word [si+0x6]                               ; [8b 54 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [si]                                    ; [0b 14]
    or dx, word [si+0x2]                                ; [0b 54 02]
    or dx, word [si+0x4]                                ; [0b 54 04]
    je short 0x310D                                     ; [74 34]
rtl_init_streams_l30D9:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 e1 0c]
    mov ax, 0x4500                                      ; [b8 00 45]
    jmp near 0x3175                                     ; [e9 91 00]
rtl_init_streams_l30E4:
    mov dx, word [di+0x6]                               ; [8b 55 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [di]                                    ; [0b 15]
    or dx, word [di+0x2]                                ; [0b 55 02]
    or dx, word [di+0x4]                                ; [0b 55 04]
    jne short 0x30D9                                    ; [75 e4]
    jmp short 0x3113                                    ; [eb 1c]
rtl_init_streams_l30F7:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    mov si, word [bp+0x6]                               ; [8b 76 06]
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    mov bx, word [di+0x8]                               ; [8b 5d 08]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x30C8                                    ; [7d bb]
rtl_init_streams_l310D:
    cmp bx, word 0x4001                                 ; [81 fb 01 40]
    jge short 0x30E4                                    ; [7d d1]
rtl_init_streams_l3113:
    db 0x8B,0xD0                                   ; mov dx, ax
    db 0x3B,0xC3                                   ; cmp ax, bx
    jg short 0x311B                                     ; [7f 02]
    db 0x8B,0xD3                                   ; mov dx, bx
rtl_init_streams_l311B:
    cmp dx, word 0xC001                                 ; [81 fa 01 c0]
    jle short 0x315C                                    ; [7e 3b]
    mov cl, byte [si+0xA]                               ; [8a 4c 0a]
    cmp cl, byte [di+0xA]                               ; [3a 4d 0a]
    jl short 0x3172                                     ; [7c 49]
    jg short 0x3168                                     ; [7f 3d]
    db 0x3B,0xC3                                   ; cmp ax, bx
    jl short 0x3163                                     ; [7c 34]
    jg short 0x316D                                     ; [7f 3c]
    mov ax, word [si+0x6]                               ; [8b 44 06]
    cmp ax, word [di+0x6]                               ; [3b 45 06]
    jne short 0x3161                                    ; [75 28]
    mov ch, 0x3                                         ; [b5 03]
    and ch, byte [0x00D7]                               ; [22 2e d7 00]
    je short 0x317F                                     ; [74 3e]
    mov ax, word [si+0x4]                               ; [8b 44 04]
    cmp ax, word [di+0x4]                               ; [3b 45 04]
    jne short 0x3161                                    ; [75 18]
    mov ax, word [si+0x2]                               ; [8b 44 02]
    cmp ax, word [di+0x2]                               ; [3b 45 02]
    jne short 0x3161                                    ; [75 10]
    cmp ch, byte 0x2                                    ; [80 fd 02]
    je short 0x31A1                                     ; [74 4b]
    mov ax, word [si]                                   ; [8b 04]
    cmp ax, word [di]                                   ; [3b 05]
    jne short 0x3161                                    ; [75 05]
rtl_init_streams_l315C:
    mov ax, 0x4000                                      ; [b8 00 40]
    jmp short 0x3175                                    ; [eb 14]
rtl_init_streams_l3161:
    ja short 0x316D                                     ; [77 0a]
rtl_init_streams_l3163:
    cmp cl, byte 0x0                                    ; [80 f9 00]
    jne short 0x3172                                    ; [75 0a]
rtl_init_streams_l3168:
    mov ax, 0x100                                       ; [b8 00 01]
    jmp short 0x3175                                    ; [eb 08]
rtl_init_streams_l316D:
    cmp cl, byte 0x0                                    ; [80 f9 00]
    jne short 0x3168                                    ; [75 f6]
rtl_init_streams_l3172:
    mov ax, 0x0                                         ; [b8 00 00]
rtl_init_streams_l3175:
    mov byte [0x00D5], ah                               ; [88 26 d5 00]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret 0x4                                             ; [c2 04 00]
rtl_init_streams_l317F:
    mov bx, word [si]                                   ; [8b 1c]
    sub bx, word [di]                                   ; [2b 1d]
    mov bx, word [si+0x2]                               ; [8b 5c 02]
    sbb bx, word [di+0x2]                               ; [1b 5d 02]
    mov bx, word [si+0x4]                               ; [8b 5c 04]
    sbb bx, word [di+0x4]                               ; [1b 5d 04]
    ja short 0x319A                                     ; [77 09]
    neg bx                                              ; [f7 db]
    and bx, byte 0xFF80                                 ; [83 e3 80]
    je short 0x315C                                     ; [74 c4]
    jmp short 0x3163                                    ; [eb c9]
rtl_init_streams_l319A:
    and bx, byte 0xFF80                                 ; [83 e3 80]
    je short 0x315C                                     ; [74 bd]
    jmp short 0x316D                                    ; [eb cc]
rtl_init_streams_l31A1:
    mov bx, word [si]                                   ; [8b 1c]
    sub bx, word [di]                                   ; [2b 1d]
    ja short 0x31B0                                     ; [77 09]
    neg bx                                              ; [f7 db]
    and bh, byte 0xFC                                   ; [80 e7 fc]
    je short 0x315C                                     ; [74 ae]
    jmp short 0x3163                                    ; [eb b3]
rtl_init_streams_l31B0:
    and bh, byte 0xFC                                   ; [80 e7 fc]
    je short 0x315C                                     ; [74 a7]
    jmp short 0x316D                                    ; [eb b6]
rtl_init_streams_l31B7:
    mov ax, 0x4000                                      ; [b8 00 40]
    cmp word [si+0x8], 0xC001                           ; [81 7c 08 01 c0]
    jle short 0x31D4                                    ; [7e 13]
    cmp word [si+0x8], 0x4001                           ; [81 7c 08 01 40]
    jge short 0x31D9                                    ; [7d 11]
rtl_init_streams_l31C8:
    mov ax, 0x100                                       ; [b8 00 01]
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    je short 0x31D4                                     ; [74 03]
    mov ax, 0x0                                         ; [b8 00 00]
rtl_init_streams_l31D4:
    mov byte [0x00D5], ah                               ; [88 26 d5 00]
    ret                                                 ; [c3]
rtl_init_streams_l31D9:
    mov dx, word [si+0x6]                               ; [8b 54 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [si]                                    ; [0b 14]
    or dx, word [si+0x2]                                ; [0b 54 02]
    or dx, word [si+0x4]                                ; [0b 54 04]
    je short 0x31C8                                     ; [74 de]
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 d0 0b]
    mov ax, 0x4500                                      ; [b8 00 45]
    jmp short 0x31D4                                    ; [eb e0]
rtl_init_streams_l31F4:
    mov ax, 0x4000                                      ; [b8 00 40]
    cmp word [si+0x8], 0xC001                           ; [81 7c 08 01 c0]
    jle short 0x3211                                    ; [7e 13]
    cmp word [si+0x8], 0x4001                           ; [81 7c 08 01 40]
    jge short 0x3216                                    ; [7d 11]
    mov ax, 0x400                                       ; [b8 00 04]
rtl_init_streams_l3208:
    cmp byte [si+0xA], 0x1                              ; [80 7c 0a 01]
    jne short 0x3211                                    ; [75 03]
    or ax, 0x200                                        ; [0d 00 02]
rtl_init_streams_l3211:
    mov byte [0x00D5], ah                               ; [88 26 d5 00]
    ret                                                 ; [c3]
rtl_init_streams_l3216:
    mov ax, 0x500                                       ; [b8 00 05]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    and dx, word 0x7FFF                                 ; [81 e2 ff 7f]
    or dx, word [si]                                    ; [0b 14]
    or dx, word [si+0x2]                                ; [0b 54 02]
    or dx, word [si+0x4]                                ; [0b 54 04]
    je short 0x3208                                     ; [74 de]
    mov ax, 0x100                                       ; [b8 00 01]
    jmp short 0x3208                                    ; [eb d9]
rtl_init_streams_l322F:
    push bp                                             ; [55]
    push si                                             ; [56]
    push di                                             ; [57]
    mov bp, word [0x00D8]                               ; [8b 2e d8 00]
    mov ax, word [bp]                                   ; [8b 46 00]
    mov bx, word [bp+0x2]                               ; [8b 5e 02]
    mov cx, word [bp+0x4]                               ; [8b 4e 04]
    mov dx, word [bp+0x6]                               ; [8b 56 06]
    db 0x2B,0xFF                                   ; sub di, di
    mov si, word [bp+0x8]                               ; [8b 76 08]
    cmp si, word 0xC001                                 ; [81 fe 01 c0]
    je short 0x326E                                     ; [74 21]
    cmp si, -0x10                                       ; [83 fe f0]
    jg short 0x325F                                     ; [7f 0d]
    db 0x8B,0xF8                                   ; mov di, ax
    db 0x8B,0xC3                                   ; mov ax, bx
    db 0x8B,0xD9                                   ; mov bx, cx
    db 0x8B,0xCA                                   ; mov cx, dx
    db 0x2B,0xD2                                   ; sub dx, dx
    add si, byte 0x10                                   ; [83 c6 10]
rtl_init_streams_l325F:
    inc si                                              ; [46]
    jg short 0x326E                                     ; [7f 0c]
    shr dx, 0x1                                         ; [d1 ea]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    rcr di, 0x1                                         ; [d1 df]
    jmp short 0x325F                                    ; [eb f1]
rtl_init_streams_l326E:
    shl di, 0x1                                         ; [d1 e7]
    mov di, 0x0                                         ; [bf 00 00]
    db 0x13,0xC7                                   ; adc ax, di
    db 0x13,0xDF                                   ; adc bx, di
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xD7                                   ; adc dx, di
    mov word [bp], ax                                   ; [89 46 00]
    mov word [bp+0x2], bx                               ; [89 5e 02]
    mov word [bp+0x4], cx                               ; [89 4e 04]
    mov word [bp+0x6], dx                               ; [89 56 06]
    db 0x8B,0xDF                                   ; mov bx, di
    db 0x8B,0xCF                                   ; mov cx, di
    db 0x8B,0xF7                                   ; mov si, di
    test byte [bp+0x3], 0x80                            ; [f6 46 03 80]
    je short 0x329D                                     ; [74 0a]
    mov bx, word [bp]                                   ; [8b 5e 00]
    mov cx, word [bp+0x2]                               ; [8b 4e 02]
    shl bx, 0x1                                         ; [d1 e3]
    rcl cx, 0x1                                         ; [d1 d1]
rtl_init_streams_l329D:
    mov ax, word [bp]                                   ; [8b 46 00]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    db 0x8B,0xD9                                   ; mov bx, cx
    db 0x8B,0xCE                                   ; mov cx, si
    db 0x2B,0xF6                                   ; sub si, si
    mov ax, word [bp+0x2]                               ; [8b 46 02]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    mov ax, word [bp]                                   ; [8b 46 00]
    mul word [bp+0x6]                                   ; [f7 66 06]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    shl bx, 0x1                                         ; [d1 e3]
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xF7                                   ; adc si, di
    db 0x8B,0xD9                                   ; mov bx, cx
    db 0x8B,0xCE                                   ; mov cx, si
    db 0x2B,0xF6                                   ; sub si, si
    mov ax, word [bp+0x4]                               ; [8b 46 04]
    mul ax                                              ; [f7 e0]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    mul word [bp+0x2]                                   ; [f7 66 02]
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    db 0x03,0xD8                                   ; add bx, ax
    db 0x13,0xCA                                   ; adc cx, dx
    db 0x13,0xF7                                   ; adc si, di
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    mul word [bp+0x4]                                   ; [f7 66 04]
    db 0x03,0xC8                                   ; add cx, ax
    db 0x13,0xF2                                   ; adc si, dx
    db 0x13,0xFF                                   ; adc di, di
    db 0x03,0xC8                                   ; add cx, ax
    db 0x13,0xF2                                   ; adc si, dx
    adc di, byte 0x0                                    ; [83 d7 00]
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    mul ax                                              ; [f7 e0]
    db 0x03,0xF0                                   ; add si, ax
    db 0x13,0xFA                                   ; adc di, dx
    mov word [bp], bx                                   ; [89 5e 00]
    mov word [bp+0x2], cx                               ; [89 4e 02]
    mov word [bp+0x4], si                               ; [89 76 04]
    mov word [bp+0x6], di                               ; [89 7e 06]
    mov byte [bp+0xA], 0x0                              ; [c6 46 0a 00]
    mov word [bp+0x8], 0x0                              ; [c7 46 08 00 00]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l3337:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    push ds                                             ; [1e]
    push es                                             ; [06]
    mov al, 0xC                                         ; [b0 0c]
    mul byte [bp+0x6]                                   ; [f6 66 06]
    sub ax, strict word 0xC                             ; [2d 0c 00]
    xchg si, ax                                         ; [96]
    add si, word [bp+0x4]                               ; [03 76 04]
    call near 0x20A0                                    ; [e8 53 ed]
    db 0x8B,0xFE                                   ; mov di, si
rtl_init_streams_l334F:
    dec byte [bp+0x6]                                   ; [fe 4e 06]
    jle short 0x33D2                                    ; [7e 7e]
    push di                                             ; [57]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    mov al, byte [di+0x16]                              ; [8a 45 16]
    xor byte [di+0xA], al                               ; [30 45 0a]
    call near 0x2BEE                                    ; [e8 8c f8]
    mov word [di], ax                                   ; [89 05]
    mov word [di+0x2], bx                               ; [89 5d 02]
    mov word [di+0x4], cx                               ; [89 4d 04]
    mov word [di+0x6], dx                               ; [89 55 06]
    pop di                                              ; [5f]
    sub di, byte 0xC                                    ; [83 ef 0c]
    push bp                                             ; [55]
    mov bp, word [0x00D8]                               ; [8b 2e d8 00]
    mov bx, word [cs:di]                                ; [2e 8b 1d]
    mov cx, word [cs:di+0x2]                            ; [2e 8b 4d 02]
    mov dx, word [cs:di+0x4]                            ; [2e 8b 55 04]
    mov si, word [cs:di+0x6]                            ; [2e 8b 75 06]
    mov al, byte [cs:di+0xA]                            ; [2e 8a 45 0a]
    cmp al, byte [bp+0xA]                               ; [3a 46 0a]
    je short 0x33C2                                     ; [74 34]
    sub bx, word [bp]                                   ; [2b 5e 00]
    sbb cx, word [bp+0x2]                               ; [1b 4e 02]
    sbb dx, word [bp+0x4]                               ; [1b 56 04]
    sbb si, word [bp+0x6]                               ; [1b 76 06]
    jae short 0x33B0                                    ; [73 14]
    not si                                              ; [f7 d6]
    not dx                                              ; [f7 d2]
    not cx                                              ; [f7 d1]
    neg bx                                              ; [f7 db]
    cmc                                                 ; [f5]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    adc si, byte 0x0                                    ; [83 d6 00]
    xor al, 0x1                                         ; [34 01]
rtl_init_streams_l33B0:
    mov word [bp], bx                                   ; [89 5e 00]
    mov word [bp+0x2], cx                               ; [89 4e 02]
    mov word [bp+0x4], dx                               ; [89 56 04]
    mov word [bp+0x6], si                               ; [89 76 06]
    mov byte [bp+0xA], al                               ; [88 46 0a]
    pop bp                                              ; [5d]
    jmp short 0x334F                                    ; [eb 8d]
rtl_init_streams_l33C2:
    add word [bp], bx                                   ; [01 5e 00]
    adc word [bp+0x2], cx                               ; [11 4e 02]
    adc word [bp+0x4], dx                               ; [11 56 04]
    adc word [bp+0x6], si                               ; [11 76 06]
    pop bp                                              ; [5d]
    jmp near 0x334F                                     ; [e9 7d ff]
rtl_init_streams_l33D2:
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    cld                                                 ; [fc]
    lodsw                                               ; [ad]
    xchg bx, ax                                         ; [93]
    lodsw                                               ; [ad]
    xchg cx, ax                                         ; [91]
    lodsw                                               ; [ad]
    xchg dx, ax                                         ; [92]
    lodsw                                               ; [ad]
    xchg di, ax                                         ; [97]
    lodsw                                               ; [ad]
    lodsw                                               ; [ad]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    db 0x87, 0xF7                                       ; xchg si, di
    db 0x2B,0xFF                                   ; sub di, di
    cmp al, 0x1                                         ; [3c 01]
    jne short 0x33FE                                    ; [75 11]
    not si                                              ; [f7 d6]
    not dx                                              ; [f7 d2]
    not cx                                              ; [f7 d1]
    neg bx                                              ; [f7 db]
    cmc                                                 ; [f5]
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xD7                                   ; adc dx, di
    db 0x13,0xF7                                   ; adc si, di
    jmp short 0x3410                                    ; [eb 12]
rtl_init_streams_l33FE:
    stc                                                 ; [f9]
    rcr si, 0x1                                         ; [d1 de]
    rcr dx, 0x1                                         ; [d1 da]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    db 0x13,0xDF                                   ; adc bx, di
    db 0x13,0xCF                                   ; adc cx, di
    db 0x13,0xD7                                   ; adc dx, di
    db 0x13,0xF7                                   ; adc si, di
    inc di                                              ; [47]
rtl_init_streams_l3410:
    mov ax, word [0x00D8]                               ; [a1 d8 00]
    xchg di, ax                                         ; [97]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    xchg si, ax                                         ; [96]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    mov ax, 0x0                                         ; [b8 00 00]
    stosw                                               ; [ab]
    pop es                                              ; [07]
    pop ds                                              ; [1f]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret 0x4                                             ; [c2 04 00]
    or byte [bx+si], al                                 ; [08 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    mov dh, 0xAA                                        ; [b6 aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    sub al, byte [bx+si]                                ; [2a 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [bp+di], al                                ; [00 03]
    and al, 0x22                                        ; [24 22]
    and ah, byte [bp+si]                                ; [22 22]
    and ah, byte [bp+si]                                ; [22 22]
    add al, byte [bx+si]                                ; [02 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bp+di+0xE4], dh                           ; [00 b3 e4 00]
    or ax, 0xD0                                         ; [0d d0 00]
    or ax, strict word 0x0                              ; [0d 00 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [bp+0x8], ch                               ; [00 6e 08]
    dec bx                                              ; [4b]

; ------------------------------------------------------------------------------
; DATA  image:0x345F .. 0x345F   1 bytes
; ------------------------------------------------------------------------------
data_345F:
    db 0xC7                                          ; 0x345F
    cmp bp, word [0x0000]                               ; [3b 2e 00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    mov byte [bx+si+0x16], 0x99                         ; [c6 40 16 99]
    imul ax, word [bx+si], 0x0                          ; [6b 00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [si], cl                                   ; [00 0c]
    inc bp                                              ; [45]
    xchg dx, ax                                         ; [92]
    mov al, 0x0                                         ; [b0 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add ch, dl                                          ; [00 d5]
    inc bp                                              ; [45]
    salc                                                ; [d6]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [bx+si], cl                                ; [00 08]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    db 0x00,0x88,0xFF,0xFF                         ; add byte [bx+si-0x1], cl

; ------------------------------------------------------------------------------
; DATA  image:0x349D .. 0x34A0   4 bytes
; ------------------------------------------------------------------------------
data_349D:
    db 0xFF,0xFF,0xFF,0xFF                           ; 0x349D
    jg short 0x34A3                                     ; [7f 00]
rtl_init_streams_l34A3:
    add byte [bx+di], al                                ; [00 01]
    add byte [bp-0x5566], ah                            ; [00 a6 9a aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    or al, byte [bx+si]                                 ; [0a 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx-0x1A], bh                              ; [00 7f e6]
    add al, 0x5B                                        ; [04 5b]
    mov al, 0x5                                         ; [b0 05]
    pop bx                                              ; [5b]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+di], al                                ; [00 01]
    add bh, ch                                          ; [00 ef]
    db 0x26,0x9B                                   ; wait
    add word [bp+si], bx                                ; [01 1a]
    mov al, byte [0x0001]                               ; [a0 01 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    sbb ax, 0xDCCE                                      ; [1d ce dc]
    xchg bx, ax                                         ; [93]
    lahf                                                ; [9f]
    add al, 0x0                                         ; [04 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [bx], cl                                   ; [00 0f]
    mov cl, 0x4B                                        ; [b1 4b]
    db 0xF7,0x08,0x00,0x00                         ; test word [bx+si], 0x0
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bp+di], al                                ; [00 03]
    fdivr dword [bp+di+0xC]                             ; [d8 7b 0c]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add word [bx+si], ax                                ; [01 00]
rtl_init_streams_l34EE:
    call near 0x2086                                    ; [e8 95 eb]
    call near 0x322F                                    ; [e8 3b fd]
rtl_init_streams_l34F4:
    push word [cs:0x1E7A]                               ; [2e ff 36 7a 1e]
    mov ax, 0x1E7C                                      ; [b8 7c 1e]
    push ax                                             ; [50]
    call near 0x3337                                    ; [e8 37 fe]
    push word [0x00D8]                                  ; [ff 36 d8 00]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 fc f5]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    ret                                                 ; [c3]
rtl_init_streams_l350F:
    call near 0x322F                                    ; [e8 1d fd]
rtl_init_streams_l3512:
    push word [cs:0x1EDC]                               ; [2e ff 36 dc 1e]
    mov ax, 0x1EDE                                      ; [b8 de 1e]
    push ax                                             ; [50]
    call near 0x3337                                    ; [e8 19 fe]
    ret                                                 ; [c3]
rtl_init_streams_l351F:
    call near 0x2086                                    ; [e8 64 eb]
    call near 0x322F                                    ; [e8 0a fd]
    call near 0x20D1                                    ; [e8 a9 eb]
    call near 0x34F4                                    ; [e8 c9 ff]
    call near 0x3512                                    ; [e8 e4 ff]
    ret                                                 ; [c3]
    xor ax, 0x68C2                                      ; [35 c2 68]
    and word [bp+si+0xFDA], sp                          ; [21 a2 da 0f]
    leave                                               ; [c9]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+si], al                                ; [00 00]
    or byte [bx+si], al                                 ; [08 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    push di                                             ; [57]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+di], al                                ; [00 01]
    add byte [bp+0x3332], bh                            ; [00 be 32 33]
    xor si, word [bp+di]                                ; [33 33]
    xor ax, word [bp+di]                                ; [33 03]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [di+0x1E], bh                              ; [00 7d 1e]
    dec cx                                              ; [49]
    xchg dx, ax                                         ; [92]
    and al, 0x9                                         ; [24 09]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add word [bx+si], ax                                ; [01 00]
    mov sp, 0xC6FE                                      ; [bc fe c6]
    jno short 0x358E                                    ; [71 1c]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si-0x1], bl                               ; [00 5c ff]
    push ss                                             ; [16]
    pop bp                                              ; [5d]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add word [bx+si], ax                                ; [01 00]
    fdivr dword [bp+di+0x13A]                           ; [d8 bb 3a 01]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    or cl, byte [si]                                    ; [0a 0c]
    add al, 0x0                                         ; [04 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add bh, ah                                          ; [00 e7]
    std                                                 ; [fd]
    inc word [bx+si]                                    ; [ff 00]
    add byte [di-0x295C], bh                            ; [00 bd a4 d6]
    jnp short 0x359C                                    ; [7b ee]
    db 0x64,0x5C                                   ; pop sp
    mov bl, 0xFF                                        ; [b3 ff]
    inc word [bx+si]                                    ; [ff 00]
    add byte [di+0x4785], dh                            ; [00 b5 85 47]
    cld                                                 ; [fc]
    je short 0x35EB                                     ; [74 30]
    db 0x11,0xA1,0x00,0x00                         ; adc word [bx+di], sp
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    db 0x00,0x80,0x01,0x00                         ; add byte [bx+si+0x1], al
    add byte [bx+si], al                                ; [00 00]
    pushf                                               ; [9c]
    cli                                                 ; [fa]
    db 0x64,0xB0,0xB2                              ; fs mov al, 0xB2
    sbb ax, 0xE607                                      ; [1d 07 e6]

; ------------------------------------------------------------------------------
; DATA  image:0x35D5 .. 0x35D5   1 bytes
; ------------------------------------------------------------------------------
data_35D5:
    db 0xFE                                          ; 0x35D5
    inc word [bx+si]                                    ; [ff 00]
    add byte [si+0x64FA], bl                            ; [00 9c fa 64]
    mov al, 0xB2                                        ; [b0 b2]
    sbb ax, 0xE607                                      ; [1d 07 e6]

; ------------------------------------------------------------------------------
; DATA  image:0x35E1 .. 0x35E1   1 bytes
; ------------------------------------------------------------------------------
data_35E1:
    db 0xFF                                          ; 0x35E1
    inc word [bx+si]                                    ; [ff 00]
    add ch, dh                                          ; [00 f5]
    mov bx, 0x44B                                       ; [bb 4b 04]
    inc si                                              ; [46]
    push si                                             ; [56]
rtl_init_streams_l35EB:
    db 0x85,0xAC,0x00,0x00                         ; test word [si], bp
    add byte [bx+si], al                                ; [00 00]
    out 0x6E, al                                        ; [e6 6e]
    fstp dword [bx]                                     ; [d9 1f]
    mov bp, 0xFA09                                      ; [bd 09 fa]
    jmp near 0x35F9                                     ; [e9 fe ff]
    add byte [bx+si], al                                ; [00 00]
    lea di, word [bp+di+0x35]                           ; [8d 7b 35]
    mov bp, 0x845B                                      ; [bd 5b 84]

; ------------------------------------------------------------------------------
; DATA  image:0x3603 .. 0x3603   1 bytes
; ------------------------------------------------------------------------------
data_3603:
    db 0xDD                                          ; 0x3603
    idiv bh                                             ; [f6 ff]
    inc word [bx+si]                                    ; [ff 00]
    add byte [bx-0x2B], bh                              ; [00 7f d5]
    xor ax, 0xDB02                                      ; [35 02 db]
    xor byte [bp+di-0x34], 0x0                          ; [80 73 cc 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [di-0x75], dl                              ; [00 55 8b]
    in al, dx                                           ; [ec]
    lea sp, word [bp-0x2]                               ; [8d 66 fe]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2CD5                                    ; [e8 b2 f6]
    mov word [bp-0x2], 0x0                              ; [c7 46 fe 00 00]
    mov di, 0x1FED                                      ; [bf ed 1f]
rtl_init_streams_l362B:
    cmp word [bp-0x2], 0x3                              ; [83 7e fe 03]
    jae short 0x3652                                    ; [73 21]
    db 0x87, 0xF7                                       ; xchg si, di
    call near 0x20A0                                    ; [e8 6a ea]
    db 0x87, 0xFE                                       ; xchg di, si
    push si                                             ; [56]
    push word [0x00D8]                                  ; [ff 36 d8 00]
    call near 0x30F7                                    ; [e8 b7 fa]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    cmp ax, strict word 0x0                             ; [3d 00 00]
    jne short 0x3652                                    ; [75 08]
    inc word [bp-0x2]                                   ; [ff 46 fe]
    add di, byte 0xC                                    ; [83 c7 0c]
    jmp short 0x362B                                    ; [eb d9]
rtl_init_streams_l3652:
    cmp word [bp-0x2], 0x0                              ; [83 7e fe 00]
    jne short 0x365D                                    ; [75 05]
    call near 0x36C8                                    ; [e8 6d 00]
    jmp short 0x36C2                                    ; [eb 65]
rtl_init_streams_l365D:
    mov bx, word [bp-0x2]                               ; [8b 5e fe]
    dec bx                                              ; [4b]
    mov bl, byte [cs:bx+0xA14]                          ; [2e 8a 9f 14 0a]
    mov word [bp-0x2], bx                               ; [89 5e fe]
    add bx, word 0x2041                                 ; [81 c3 41 20]
    db 0x8B,0xFB                                   ; mov di, bx
    db 0x87, 0xF7                                       ; xchg si, di
    call near 0x20A0                                    ; [e8 2c ea]
    db 0x87, 0xFE                                       ; xchg di, si
    push si                                             ; [56]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    push di                                             ; [57]
    lea ax, word [di-0xC]                               ; [8d 45 f4]
    mov word [0x00D8], ax                               ; [a3 d8 00]
    push ax                                             ; [50]
    call near 0x293C                                    ; [e8 b6 f2]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 79 f4]
    call near 0x1FE0                                    ; [e8 51 e9]
    push di                                             ; [57]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2940                                    ; [e8 ab f2]
    push word [0x00D8]                                  ; [ff 36 d8 00]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2CD5                                    ; [e8 37 f6]
    add word [0x00D8], 0x18                             ; [83 06 d8 00 18]
    call near 0x36C8                                    ; [e8 22 00]
    mov di, word [bp-0x2]                               ; [8b 7e fe]
    add di, word 0x201D                                 ; [81 c7 1d 20]
    db 0x87, 0xF7                                       ; xchg si, di
    call near 0x20A0                                    ; [e8 ee e9]
    db 0x87, 0xFE                                       ; xchg di, si
    push word [0x00D8]                                  ; [ff 36 d8 00]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2940                                    ; [e8 83 f2]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
rtl_init_streams_l36C2:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l36C8:
    push si                                             ; [56]
    push di                                             ; [57]
    call near 0x2086                                    ; [e8 b9 e9]
    cmp word [si+0x8], -0x20                            ; [83 7c 08 e0]
    jg short 0x36DA                                     ; [7f 07]
    db 0x8B,0xFE                                   ; mov di, si
    call near 0x20BE                                    ; [e8 e6 e9]
    jmp short 0x36FC                                    ; [eb 22]
rtl_init_streams_l36DA:
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    add word [di+0x8], 0x3                              ; [83 45 08 03]
    call near 0x322F                                    ; [e8 4a fb]
    push word [cs:0x1F8B]                               ; [2e ff 36 8b 1f]
    mov ax, 0x1F8D                                      ; [b8 8d 1f]
    push ax                                             ; [50]
    call near 0x3337                                    ; [e8 46 fc]
    push di                                             ; [57]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 0e f4]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
rtl_init_streams_l36FC:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
    or ax, strict word 0x0                              ; [0d 00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bp+di], al                                ; [00 03]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    inc ax                                              ; [40]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    test ax, 0xAAAA                                     ; [a9 aa aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    stosb                                               ; [aa]
    or al, byte [bx+si]                                 ; [0a 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si+0x55], bh                           ; [00 78 55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [0x2223], ah                               ; [00 26 23 22]
    and ah, byte [bp+si]                                ; [22 22]
    and ah, byte [bp+si]                                ; [22 22]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si], bl                                   ; [00 1c]
    db 0x2B,0xD8                                   ; sub bx, ax
    db 0x82,0x2D,0xD8                              ; sub byte [di], 0xD8
    add al, byte [bx+si]                                ; [02 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    cld                                                 ; [fc]
    stc                                                 ; [f9]
    xor ax, word [bx+si+0x3]                            ; [33 40 03]
    xor al, 0x0                                         ; [34 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si], dl                                   ; [00 14]
    push dx                                             ; [52]
    add si, word [si]                                   ; [03 34]
    inc ax                                              ; [40]
    add ax, word [bx+si]                                ; [03 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [-0x3894], bl                              ; [00 1e 6c c7]
    cmp bp, word [0x0000]                               ; [3b 2e 00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si-0x50], cl                              ; [00 4c b0]
    leave                                               ; [c9]
    dec di                                              ; [4f]
    add al, byte [bx+si]                                ; [02 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    xchg cx, ax                                         ; [91]
    push cs                                             ; [0e]
    out 0x1A, al                                        ; [e6 1a]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    push cx                                             ; [51]
    jbe short 0x37A7                                    ; [76 1f]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add ch, al                                          ; [00 c5]
    sub al, 0xB                                         ; [2c 0b]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [di+0x56], dl                              ; [00 55 56]
    push di                                             ; [57]
    mov bp, word [0x00D8]                               ; [8b 2e d8 00]
    lea di, word [bp-0xC]                               ; [8d 7e f4]
rtl_init_streams_l37A7:
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call near 0x2035                                    ; [e8 87 e8]
    push di                                             ; [57]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 51 f3]
    mov word [0x00D8], bp                               ; [89 2e d8 00]
    mov di, word [si+0x8]                               ; [8b 7c 08]
    cmp di, -0x20                                       ; [83 ff e0]
    jle short 0x3817                                    ; [7e 57]
    mov ax, word [si]                                   ; [8b 04]
    mov bx, word [si+0x2]                               ; [8b 5c 02]
    mov cx, word [si+0x4]                               ; [8b 4c 04]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    inc di                                              ; [47]
    jge short 0x37E5                                    ; [7d 17]
rtl_init_streams_l37CE:
    shr dx, 0x1                                         ; [d1 ea]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ax, 0x1                                         ; [d1 d8]
    inc di                                              ; [47]
    jl short 0x37CE                                     ; [7c f5]
    adc ax, strict word 0x0                             ; [15 00 00]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
rtl_init_streams_l37E5:
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    cld                                                 ; [fc]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    stosw                                               ; [ab]
    xchg bx, ax                                         ; [93]
    stosw                                               ; [ab]
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    xchg dx, ax                                         ; [92]
    stosw                                               ; [ab]
    db 0x2B,0xC0                                   ; sub ax, ax
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    sub di, byte 0xC                                    ; [83 ef 0c]
    push word [cs:0x214F]                               ; [2e ff 36 4f 21]
    mov ax, 0x2151                                      ; [b8 51 21]
    push ax                                             ; [50]
    call near 0x3337                                    ; [e8 2e fb]
    mov ax, word [0x00D8]                               ; [a1 d8 00]
    push ax                                             ; [50]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 f3 f2]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
rtl_init_streams_l3817:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    mov bx, 0x17F0                                      ; [bb f0 17]
    pop sp                                              ; [5c]
    sub word [bp+di], di                                ; [29 3b]
    stosb                                               ; [aa]
    mov ax, 0x1                                         ; [b8 01 00]
    add byte [bx+si], al                                ; [00 00]
    or word [bx+si], ax                                 ; [09 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    push 0x5555                                         ; [68 55 55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    push bp                                             ; [55]
    add ax, strict word 0x0                             ; [05 00 00]
    add byte [bx+si], al                                ; [00 00]
    mov dx, 0x3334                                      ; [ba 34 33]
    xor si, word [bp+di]                                ; [33 33]
    xor si, word [bp+di]                                ; [33 33]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+0x48C3], ah                            ; [00 a7 c3 48]
    xchg dx, ax                                         ; [92]
    and al, 0x49                                        ; [24 49]
    add al, byte [bx+si]                                ; [02 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    dec bp                                              ; [4d]
    pop bp                                              ; [5d]
    db 0x22,0xC7                                   ; and al, bh
    jno short 0x387B                                    ; [71 1c]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    and al, 0x56                                        ; [24 56]
    jmp short 0x38C5                                    ; [eb 5c]
    je short 0x386C                                     ; [74 01]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    cmp word [di-0x4E14], bp                            ; [39 ad ec b1]
    adc ax, word [bx+si]                                ; [13 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
rtl_init_streams_l387B:
    add byte [bx+si], al                                ; [00 00]
    std                                                 ; [fd]
    salc                                                ; [d6]
    or byte [bx], 0x1                                   ; [80 0f 01]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [di-0x1B86], dh                            ; [00 b5 7a e4]
    adc byte [bx+si], al                                ; [10 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [di-0x75], dl                              ; [00 55 8b]
    in al, dx                                           ; [ec]
    push word [di+0x8]                                  ; [ff 75 08]
    push si                                             ; [56]
    push di                                             ; [57]
    mov ax, word [di]                                   ; [8b 05]
    mov bx, word [di+0x2]                               ; [8b 5d 02]
    mov cx, word [di+0x4]                               ; [8b 4d 04]
    mov dx, word [di+0x6]                               ; [8b 55 06]
    cmp dx, word 0xB505                                 ; [81 fa 05 b5]
    ja short 0x38BE                                     ; [77 10]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl dx, 0x1                                         ; [d1 d2]
    mov si, 0x0                                         ; [be 00 00]
    dec word [bp-0x2]                                   ; [ff 4e fe]
    jmp short 0x38D3                                    ; [eb 15]
rtl_init_streams_l38BE:
    not dx                                              ; [f7 d2]
    not cx                                              ; [f7 d1]
    not bx                                              ; [f7 d3]
    neg ax                                              ; [f7 d8]
    cmc                                                 ; [f5]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    mov si, 0x1                                         ; [be 01 00]
rtl_init_streams_l38D3:
    db 0x2B,0xFF                                   ; sub di, di
rtl_init_streams_l38D5:
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x38F2                                    ; [75 19]
    xchg bx, ax                                         ; [93]
    xchg cx, ax                                         ; [91]
    xchg dx, ax                                         ; [92]
    sub di, byte 0x10                                   ; [83 ef 10]
    cmp di, -0x40                                       ; [83 ff c0]
    jg short 0x38D5                                     ; [7f f1]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    call near 0x2046                                    ; [e8 56 e7]
    jmp short 0x391F                                    ; [eb 2d]
rtl_init_streams_l38F2:
    js short 0x38FF                                     ; [78 0b]
rtl_init_streams_l38F4:
    dec di                                              ; [4f]
    shl ax, 0x1                                         ; [d1 e0]
    rcl bx, 0x1                                         ; [d1 d3]
    rcl cx, 0x1                                         ; [d1 d1]
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x38F4                                    ; [79 f5]
rtl_init_streams_l38FF:
    push si                                             ; [56]
    push di                                             ; [57]
    push dx                                             ; [52]
    push cx                                             ; [51]
    push bx                                             ; [53]
    push ax                                             ; [50]
    db 0x8B,0xF4                                   ; mov si, sp
    call near 0x3985                                    ; [e8 7b 00]
    mov si, 0x226B                                      ; [be 6b 22]
    call near 0x20A0                                    ; [e8 90 e7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x8B,0xC4                                   ; mov ax, sp
    push si                                             ; [56]
    push ax                                             ; [50]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 e9 f1]
    add sp, byte 0xC                                    ; [83 c4 0c]
rtl_init_streams_l391F:
    lea si, word [bp-0x2]                               ; [8d 76 fe]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    call near 0x2105                                    ; [e8 d7 e7]
    lea si, word [di+0xC]                               ; [8d 75 0c]
    push si                                             ; [56]
    push di                                             ; [57]
    push di                                             ; [57]
    call near 0x2940                                    ; [e8 09 f0]
    push di                                             ; [57]
    push word [bp-0x4]                                  ; [ff 76 fc]
    push word [bp-0x4]                                  ; [ff 76 fc]
    call near 0x2B05                                    ; [e8 c4 f1]
    add word [0x00D8], 0x18                             ; [83 06 d8 00 18]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    db 0x8B,0xF7                                   ; mov si, di
    call near 0x2086                                    ; [e8 30 e7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x3985                                    ; [e8 28 00]
    mov si, 0x226B                                      ; [be 6b 22]
    call near 0x20A0                                    ; [e8 3d e7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    push si                                             ; [56]
    lea si, word [si+0xC]                               ; [8d 74 0c]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 95 f1]
    push si                                             ; [56]
    push word [bp-0x2]                                  ; [ff 76 fe]
    push word [bp-0x2]                                  ; [ff 76 fe]
    call near 0x2B05                                    ; [e8 8b f1]
    add word [0x00D8], 0x18                             ; [83 06 d8 00 18]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l3985:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    cmp word [si+0x8], -0x40                            ; [83 7c 08 c0]
    jle short 0x39D6                                    ; [7e 46]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    call near 0x1FE0                                    ; [e8 44 e6]
    inc word [di+0x8]                                   ; [ff 45 08]
    push si                                             ; [56]
    push di                                             ; [57]
    push di                                             ; [57]
    call near 0x2940                                    ; [e8 9b ef]
    push si                                             ; [56]
    push di                                             ; [57]
    push di                                             ; [57]
    call near 0x2CD5                                    ; [e8 2a f3]
    call near 0x20D1                                    ; [e8 23 e7]
    mov bx, word [0x00D8]                               ; [8b 1e d8 00]
    add word [bx+0x8], 0x2                              ; [83 47 08 02]
    call near 0x322F                                    ; [e8 76 f8]
    push word [cs:0x2277]                               ; [2e ff 36 77 22]
    mov ax, 0x2279                                      ; [b8 79 22]
    push ax                                             ; [50]
    call near 0x3337                                    ; [e8 72 f9]
    push word [0x00D8]                                  ; [ff 36 d8 00]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 37 f1]
    inc word [si+0x8]                                   ; [ff 44 08]
    add word [0x00D8], 0x18                             ; [83 06 d8 00 18]
rtl_init_streams_l39D6:
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    mov cl, 0x0                                         ; [b1 00]
    jmp short 0x39E6                                    ; [eb 06]
    mov cl, 0x2                                         ; [b1 02]
    jmp short 0x39E6                                    ; [eb 02]
    mov cl, 0x4                                         ; [b1 04]
rtl_init_streams_l39E6:
    mov es, di                                          ; [8e c7]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    mov ch, byte [di+0xA]                               ; [8a 6d 0a]
    push cx                                             ; [51]
    push ax                                             ; [50]
    cmp word [di+0x8], -0x20                            ; [83 7d 08 e0]
    jg short 0x3A04                                     ; [7f 0b]
    cmp cl, byte 0x2                                    ; [80 f9 02]
    jne short 0x3A01                                    ; [75 03]
    call near 0x1FE0                                    ; [e8 df e5]
rtl_init_streams_l3A01:
    jmp near 0x3ABE                                     ; [e9 ba 00]
rtl_init_streams_l3A04:
    cmp word [di+0x8], 0x40                             ; [83 7d 08 40]
    jle short 0x3A15                                    ; [7e 0b]
    call near 0x206D                                    ; [e8 60 e6]
    mov word [di+0x6], 0x21                             ; [c7 45 06 21 00]
    jmp near 0x3ABE                                     ; [e9 a9 00]
rtl_init_streams_l3A15:
    mov byte [di+0xA], 0x0                              ; [c6 45 0a 00]
    lea si, word [di-0xC]                               ; [8d 75 f4]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    db 0x87, 0xFE                                       ; xchg di, si
    call near 0x2013                                    ; [e8 ee e5]
    db 0x87, 0xFE                                       ; xchg di, si
    sub word [si+0x8], 0x2                              ; [83 6c 08 02]
    call near 0x2FEF                                    ; [e8 c1 f5]
    and al, 0x7                                         ; [24 07]
    mov byte [bp-0x4], al                               ; [88 46 fc]
    mov bl, byte [bp-0x2]                               ; [8a 5e fe]
    cmp bl, byte 0x4                                    ; [80 fb 04]
    je short 0x3A76                                     ; [74 3b]
    add bl, byte [bp-0x4]                               ; [02 5e fc]
    and bl, byte 0x7                                    ; [80 e3 07]
    mov byte [bp-0x4], bl                               ; [88 5e fc]
    shr bx, 0x1                                         ; [d1 eb]
    jae short 0x3A59                                    ; [73 11]
    db 0x87, 0xFE                                       ; xchg di, si
    call near 0x2013                                    ; [e8 c6 e5]
    db 0x87, 0xFE                                       ; xchg di, si
    sub word [si+0x8], 0x2                              ; [83 6c 08 02]
    push si                                             ; [56]
    push di                                             ; [57]
    push di                                             ; [57]
    call near 0x293C                                    ; [e8 e3 ee]
rtl_init_streams_l3A59:
    mov word [0x00D8], di                               ; [89 3e d8 00]
    db 0x8B,0xF7                                   ; mov si, di
    test byte [bp-0x4], 0x3                             ; [f6 46 fc 03]
    jp short 0x3A6A                                     ; [7a 05]
    call near 0x350F                                    ; [e8 a7 fa]
    jmp short 0x3A6D                                    ; [eb 03]
rtl_init_streams_l3A6A:
    call near 0x34EE                                    ; [e8 81 fa]
rtl_init_streams_l3A6D:
    mov bl, byte [bp-0x4]                               ; [8a 5e fc]
    shr bl, 0x1                                         ; [d0 eb]
    shr bl, 0x1                                         ; [d0 eb]
    jmp short 0x3AB2                                    ; [eb 3c]
rtl_init_streams_l3A76:
    test byte [bp-0x4], 0x1                             ; [f6 46 fc 01]
    je short 0x3A8D                                     ; [74 11]
    db 0x87, 0xF7                                       ; xchg si, di
    call near 0x2013                                    ; [e8 92 e5]
    db 0x87, 0xF7                                       ; xchg si, di
    sub word [si+0x8], 0x2                              ; [83 6c 08 02]
    push si                                             ; [56]
    push di                                             ; [57]
    push di                                             ; [57]
    call near 0x293C                                    ; [e8 af ee]
rtl_init_streams_l3A8D:
    mov word [0x00D8], di                               ; [89 3e d8 00]
    db 0x8B,0xF7                                   ; mov si, di
    call near 0x351F                                    ; [e8 89 fa]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    db 0x8B,0xC6                                   ; mov ax, si
    test byte [bp-0x4], 0x3                             ; [f6 46 fc 03]
    jp short 0x3AA3                                     ; [7a 02]
    db 0x87, 0xF7                                       ; xchg si, di
rtl_init_streams_l3AA3:
    xchg di, ax                                         ; [97]
    push si                                             ; [56]
    push ax                                             ; [50]
    push di                                             ; [57]
    call near 0x2CD5                                    ; [e8 2b f2]
    mov bl, byte [bp-0x4]                               ; [8a 5e fc]
    shr bl, 0x1                                         ; [d0 eb]
    and bl, byte 0x1                                    ; [80 e3 01]
rtl_init_streams_l3AB2:
    cmp byte [bp-0x2], 0x2                              ; [80 7e fe 02]
    je short 0x3ABB                                     ; [74 03]
    xor bl, byte [bp-0x1]                               ; [32 5e ff]
rtl_init_streams_l3ABB:
    mov byte [di+0xA], bl                               ; [88 5d 0a]
rtl_init_streams_l3ABE:
    mov word [0x00D8], di                               ; [89 3e d8 00]
    db 0x8B,0xE5                                   ; mov sp, bp
    ret                                                 ; [c3]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call near 0x1FE0                                    ; [e8 0b e5]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x3B15                                    ; [7d 38]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x3B10                                    ; [7e 2e]
    mov cl, 0x0                                         ; [b1 00]
    db 0x8B,0xDE                                   ; mov bx, si
    dec ax                                              ; [48]
    jl short 0x3AF0                                     ; [7c 07]
    call near 0x20EB                                    ; [e8 ff e5]
    db 0x8B,0xDF                                   ; mov bx, di
    mov cl, 0x1                                         ; [b1 01]
rtl_init_streams_l3AF0:
    mov ch, 0x0                                         ; [b5 00]
    xchg byte [bx+0xA], ch                              ; [86 6f 0a]
    push cx                                             ; [51]
    call near 0x3615                                    ; [e8 1c fb]
    pop cx                                              ; [59]
    cmp cl, byte 0x1                                    ; [80 f9 01]
    jne short 0x3B0D                                    ; [75 0e]
    push cx                                             ; [51]
    call near 0x2013                                    ; [e8 10 e5]
    dec word [di+0x8]                                   ; [ff 4d 08]
    push di                                             ; [57]
    push si                                             ; [56]
    push si                                             ; [56]
    call near 0x293C                                    ; [e8 30 ee]
    pop cx                                              ; [59]
rtl_init_streams_l3B0D:
    mov byte [si+0xA], ch                               ; [88 6c 0a]
rtl_init_streams_l3B10:
    mov word [0x00D8], si                               ; [89 36 d8 00]
    ret                                                 ; [c3]
rtl_init_streams_l3B15:
    db 0x8B,0xFE                                   ; mov di, si
    push word [si+0xA]                                  ; [ff 74 0a]
    call near 0x2013                                    ; [e8 f6 e4]
    pop word [si+0xA]                                   ; [8f 44 0a]
    dec word [si+0x8]                                   ; [ff 4c 08]
    jmp short 0x3B10                                    ; [eb eb]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call near 0x2035                                    ; [e8 00 e5]
    jmp short 0x3B59                                    ; [eb 22]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call near 0x1FE0                                    ; [e8 99 e4]
    jmp short 0x3B59                                    ; [eb 10]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call near 0x2024                                    ; [e8 cb e4]
rtl_init_streams_l3B59:
    call near 0x20EB                                    ; [e8 8f e5]
    cmp byte [di+0xA], 0x0                              ; [80 7d 0a 00]
    jne short 0x3B7B                                    ; [75 19]
    mov ax, word [di+0x8]                               ; [8b 45 08]
    cmp ax, 0xC001                                      ; [3d 01 c0]
    jle short 0x3B77                                    ; [7e 0d]
    cmp ax, 0x4001                                      ; [3d 01 40]
    jge short 0x3B7B                                    ; [7d 0c]
    call near 0x3895                                    ; [e8 23 fd]
rtl_init_streams_l3B72:
    mov word [0x00D8], si                               ; [89 36 d8 00]
    ret                                                 ; [c3]
rtl_init_streams_l3B77:
    mov ch, 0x4                                         ; [b5 04]
    jmp short 0x3B7D                                    ; [eb 02]
rtl_init_streams_l3B7B:
    mov ch, 0x1                                         ; [b5 01]
rtl_init_streams_l3B7D:
    call near 0x3DBF                                    ; [e8 3f 02]
    mov ax, 0x4001                                      ; [b8 01 40]
    db 0x8B,0xFE                                   ; mov di, si
    mov cl, 0x0                                         ; [b1 00]
    call near 0x205B                                    ; [e8 d1 e4]
    jmp short 0x3B72                                    ; [eb e6]
    mov ax, 0xA52                                       ; [b8 52 0a]
    jmp short 0x3B9F                                    ; [eb 0e]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    jmp short 0x3BB8                                    ; [eb 1c]
    mov ax, 0xA41                                       ; [b8 41 0a]
rtl_init_streams_l3B9F:
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    lea di, word [si-0xC]                               ; [8d 7c f4]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    call ax                                             ; [ff d0]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 51 ef]
    mov word [0x00D8], si                               ; [89 36 d8 00]
rtl_init_streams_l3BB8:
    db 0x8B,0xEC                                   ; mov bp, sp
    mov ax, 0x0                                         ; [b8 00 00]
    push ax                                             ; [50]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    cmp ax, strict word 0xC                             ; [3d 0c 00]
    jg short 0x3C14                                     ; [7f 4e]
    cmp ax, strict word 0xFFC0                          ; [3d c0 ff]
    jle short 0x3C25                                    ; [7e 5a]
    call near 0x20D1                                    ; [e8 03 e5]
    inc word [di+0x8]                                   ; [ff 45 08]
    push word [0x00D6]                                  ; [ff 36 d6 00]
    and byte [0x00D7], 0xF3                             ; [80 26 d7 00 f3]
    or byte [0x00D7], 0x4                               ; [80 0e d7 00 04]
    db 0x8B,0xF7                                   ; mov si, di
    call near 0x2510                                    ; [e8 2c e9]
    pop word [0x00D6]                                   ; [8f 06 d6 00]
    push ax                                             ; [50]
    db 0x8B,0xFC                                   ; mov di, sp
    call near 0x213A                                    ; [e8 4c e5]
    dec word [si+0x8]                                   ; [ff 4c 08]
    lea di, word [si+0xC]                               ; [8d 7c 0c]
    push di                                             ; [57]
    push si                                             ; [56]
    push di                                             ; [57]
    call near 0x293C                                    ; [e8 42 ed]
    pop ax                                              ; [58]
    sar ax, 0x1                                         ; [d1 f8]
    jae short 0x3C2C                                    ; [73 2d]
    mov word [si], 0x6485                               ; [c7 04 85 64]
    mov word [si+0x2], 0xF9DE                           ; [c7 44 02 de f9]
    mov word [si+0x4], 0xF333                           ; [c7 44 04 33 f3]
    mov word [si+0x6], 0xB504                           ; [c7 44 06 04 b5]
    jmp short 0x3C3F                                    ; [eb 2b]
rtl_init_streams_l3C14:
    db 0x8B,0xFE                                   ; mov di, si
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 a4 01]
    mov ax, 0x4001                                      ; [b8 01 40]
    mov cl, 0x0                                         ; [b1 00]
    call near 0x205B                                    ; [e8 38 e4]
    jmp short 0x3C65                                    ; [eb 40]
rtl_init_streams_l3C25:
    db 0x8B,0xFE                                   ; mov di, si
    call near 0x1FE0                                    ; [e8 b6 e3]
    jmp short 0x3C65                                    ; [eb 39]
rtl_init_streams_l3C2C:
    mov word [si], 0x0                                  ; [c7 04 00 00]
    mov word [si+0x2], 0x0                              ; [c7 44 02 00 00]
    mov word [si+0x4], 0x0                              ; [c7 44 04 00 00]
    mov word [si+0x6], 0x8000                           ; [c7 44 06 00 80]
rtl_init_streams_l3C3F:
    inc ax                                              ; [40]
    mov word [si+0x8], ax                               ; [89 44 08]
    mov byte [si+0xA], 0x0                              ; [c6 44 0a 00]
    db 0x8B,0xFE                                   ; mov di, si
    lea si, word [di+0xC]                               ; [8d 75 0c]
    call near 0x379D                                    ; [e8 4e fb]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2B05                                    ; [e8 b0 ee]
    push si                                             ; [56]
    push di                                             ; [57]
    push si                                             ; [56]
    call near 0x2940                                    ; [e8 e5 ec]
    cmp byte [bp-0x2], 0x1                              ; [80 7e fe 01]
    jne short 0x3C65                                    ; [75 04]
    xor byte [si+0xA], 0x1                              ; [80 74 0a 01]
rtl_init_streams_l3C65:
    mov word [0x00D8], si                               ; [89 36 d8 00]
    db 0x8B,0xE5                                   ; mov sp, bp
    ret                                                 ; [c3]
    mov es, di                                          ; [8e c7]
    lea di, word [bp+0x18]                              ; [8d 7e 18]
    mov ch, 0x0                                         ; [b5 00]
    db 0x8B,0xE9                                   ; mov bp, cx
    mov al, 0xA                                         ; [b0 0a]
    mul cl                                              ; [f6 e1]
    db 0x03,0xF8                                   ; add di, ax
    mov si, 0xC0                                        ; [be c0 00]
rtl_init_streams_l3C7E:
    sub si, byte 0xC                                    ; [83 ee 0c]
    sub di, byte 0xA                                    ; [83 ef 0a]
    call near 0x2852                                    ; [e8 cb eb]
    dec bp                                              ; [4d]
    jg short 0x3C7E                                     ; [7f f4]
    db 0x8B,0xCE                                   ; mov cx, si
    sub cx, word [0x00D8]                               ; [2b 0e d8 00]
    sub si, byte 0x2                                    ; [83 ee 02]
    mov di, 0xBE                                        ; [bf be 00]
    std                                                 ; [fd]
    shr cx, 0x1                                         ; [d1 e9]
    je short 0x3C9D                                     ; [74 02]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
rtl_init_streams_l3C9D:
    inc di                                              ; [47]
    inc di                                              ; [47]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    ret                                                 ; [c3]
    mov es, di                                          ; [8e c7]
    mov ch, 0x0                                         ; [b5 00]
    db 0x8B,0xE9                                   ; mov bp, cx
    db 0x8A,0xD9                                   ; mov bl, cl
    mov bh, 0x0                                         ; [b7 00]
    mov bl, byte [cs:bx+0xA14]                          ; [2e 8a 9f 14 0a]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x8B,0xFE                                   ; mov di, si
    db 0x2B,0xFB                                   ; sub di, bx
    mov word [0x00D8], di                               ; [89 3e d8 00]
    mov cx, 0xC0                                        ; [b9 c0 00]
    db 0x2B,0xCE                                   ; sub cx, si
    je short 0x3CCB                                     ; [74 05]
    cld                                                 ; [fc]
    shr cx, 0x1                                         ; [d1 e9]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
rtl_init_streams_l3CCB:
    lea si, word [bp+0x18]                              ; [8d 76 18]
rtl_init_streams_l3CCE:
    call near 0x2879                                    ; [e8 a8 eb]
    add di, byte 0xC                                    ; [83 c7 0c]
    add si, byte 0xA                                    ; [83 c6 0a]
    dec bp                                              ; [4d]
    jg short 0x3CCE                                     ; [7f f4]
    ret                                                 ; [c3]
    mov bx, word [0x00D8]                               ; [8b 1e d8 00]
    push bx                                             ; [53]
    lea si, word [bx+0xC]                               ; [8d 77 0c]
    push si                                             ; [56]
    add si, byte 0xC                                    ; [83 c6 0c]
    jmp short 0x3CFD                                    ; [eb 14]
    mov bx, word [0x00D8]                               ; [8b 1e d8 00]
    push bx                                             ; [53]
    lea si, word [bx+0xC]                               ; [8d 77 0c]
    push si                                             ; [56]
    jmp short 0x3CFD                                    ; [eb 09]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    push si                                             ; [56]
    lea bx, word [si+0xC]                               ; [8d 5c 0c]
    push bx                                             ; [53]
rtl_init_streams_l3CFD:
    mov es, di                                          ; [8e c7]
    call near 0x30F7                                    ; [e8 f5 f3]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    mov byte [bp+0x16], ah                              ; [88 66 16]
    ret                                                 ; [c3]
    and byte [0x00D7], 0xFC                             ; [80 26 d7 00 fc]
    jmp short 0x3D16                                    ; [eb 05]
    and byte [0x00D7], 0xFE                             ; [80 26 d7 00 fe]
rtl_init_streams_l3D16:
    mov es, di                                          ; [8e c7]
    mov bx, word [0x00D8]                               ; [8b 1e d8 00]
    push bx                                             ; [53]
    lea si, word [bx+0xC]                               ; [8d 77 0c]
    push si                                             ; [56]
    call near 0x30F7                                    ; [e8 d3 f3]
    or byte [0x00D7], 0x3                               ; [80 0e d7 00 03]
    add si, byte 0xC                                    ; [83 c6 0c]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    mov byte [bp+0x16], ah                              ; [88 66 16]
    ret                                                 ; [c3]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x31B7                                    ; [e8 7a f4]
    mov byte [bp+0x16], ah                              ; [88 66 16]
    ret                                                 ; [c3]
    mov es, di                                          ; [8e c7]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x31F4                                    ; [e8 aa f4]
    mov word [bp+0xE], ax                               ; [89 46 0e]
    ret                                                 ; [c3]
    mov sp, 0xF426                                      ; [bc 26 f4]
    db 0x26,0x5A                                   ; pop dx
    daa                                                 ; [27]
    popaw                                               ; [61]
    daa                                                 ; [27]
    sub sp, word [bx]                                   ; [2b 27]
    cmp word [bx], sp                                   ; [39 27]
    test byte [bx], ah                                  ; [84 27]
    xchg cx, ax                                         ; [91]
    daa                                                 ; [27]
    sub al, 0x24                                        ; [2c 24]
    xor byte [si], ah                                   ; [30 24]
    xor al, 0x24                                        ; [34 24]
    adc ax, 0x7525                                      ; [15 25 75]
    and ax, 0x2587                                      ; [25 87 25]
    db 0x99                                        ; cwd
    and ax, 0x25DC                                      ; [25 dc 25]
    loope 0x3D95                                        ; [e1 25]
    in al, dx                                           ; [ec]
    and ax, 0xFCFB                                      ; [25 fb fc]
    push dx                                             ; [52]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push bp                                             ; [55]
    push si                                             ; [56]
    push di                                             ; [57]
    push es                                             ; [06]
    push cx                                             ; [51]
    push ds                                             ; [1e]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov word [ss:0xDE], bp                              ; [36 89 2e de 00]
    lds si,  [bp+0x12]                              ; [c5 76 12]
    lodsw                                               ; [ad]
    mov word [bp+0x12], si                              ; [89 76 12]
    mov di, ss                                          ; [8c d7]
    mov ds, di                                          ; [8e df]
    db 0x8A,0xCC                                   ; mov cl, ah
    db 0x98                                        ; cbw
    xchg bx, ax                                         ; [93]
    cmp bl, byte 0xDC                                   ; [80 fb dc]
    jb short 0x3DB5                                     ; [72 1d]
    call [cs:bx+0x27C2]                                 ; [2e ff 97 c2 27]
    cmp word [ss:0xD8], 0xC0                            ; [36 81 3e d8 00 c0 00]
    ja short 0x3DBC                                     ; [77 16]
rtl_init_streams_l3DA6:
    mov sp, word [ss:0xDE]                              ; [36 8b 26 de 00]
    pop ds                                              ; [1f]
    pop cx                                              ; [59]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    pop bx                                              ; [5b]
    pop ax                                              ; [58]
    pop dx                                              ; [5a]
    iret                                                ; [cf]
rtl_init_streams_l3DB5:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 05 00]
    jmp short 0x3DA6                                    ; [eb ea]
rtl_init_streams_l3DBC:
    int3                                                ; [cc]
    jmp short 0x3DA6                                    ; [eb e7]
rtl_init_streams_l3DBF:
    push ax                                             ; [50]
    push cx                                             ; [51]
    push ds                                             ; [1e]
    push ss                                             ; [16]
    pop ds                                              ; [1f]
    mov al, byte [0x00D4]                               ; [a0 d4 00]
    mov cl, byte [0x00D6]                               ; [8a 0e d6 00]
    and cl, byte 0x3F                                   ; [80 e1 3f]
    xor cl, byte 0x3F                                   ; [80 f1 3f]
    db 0x0A,0xC5                                   ; or al, ch
    db 0x8A,0xE0                                   ; mov ah, al
    db 0x22,0xE1                                   ; and ah, cl
    db 0x32,0xE0                                   ; xor ah, al
    test ah, 0x8                                        ; [f6 c4 08]
    je short 0x3DE0                                     ; [74 02]
    or al, 0x20                                         ; [0c 20]
rtl_init_streams_l3DE0:
    test cl, al                                         ; [84 c1]
    je short 0x3DF3                                     ; [74 0f]
    or al, 0x80                                         ; [0c 80]
    mov byte [0x00D4], al                               ; [a2 d4 00]
    db 0x22,0xC1                                   ; and al, cl
    cmp al, 0x20                                        ; [3c 20]
    jne short 0x3DFC                                    ; [75 0d]
    pop ds                                              ; [1f]
    pop cx                                              ; [59]
    pop ax                                              ; [58]
    ret                                                 ; [c3]
rtl_init_streams_l3DF3:
    and al, 0x7F                                        ; [24 7f]
    mov byte [0x00D4], al                               ; [a2 d4 00]
    pop ds                                              ; [1f]
    pop cx                                              ; [59]
    pop ax                                              ; [58]
    ret                                                 ; [c3]
rtl_init_streams_l3DFC:
    mov ax, 0x3502                                      ; [b8 02 35]
    int 0x21                                            ; [cd 21]
    mov word [ss:0xD0], bx                              ; [36 89 1e d0 00]
    mov word [ss:0xD2], es                              ; [36 8c 06 d2 00]
    mov sp, word [ss:0xDE]                              ; [36 8b 26 de 00]
    pop ds                                              ; [1f]
    pop cx                                              ; [59]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    pop bx                                              ; [5b]
    pop ax                                              ; [58]
    pop dx                                              ; [5a]
    db 0x36,0xFF,0x2E,0xD0,0x00                    ; jmp dword [ss:0xD0]
rtl_init_streams_l3E1E:
    push bx                                             ; [53]
    push cx                                             ; [51]
    push dx                                             ; [52]
    mov cl, 0x4                                         ; [b1 04]
    mov ch, 0xA                                         ; [b5 0a]
    mov bx, word [es:si]                                ; [26 8b 1c]
    db 0x8A,0xC7                                   ; mov al, bh
    shr al, cl                                          ; [d2 e8]
    mul ch                                              ; [f6 e5]
    mov dl, 0xF                                         ; [b2 0f]
    db 0x22,0xD7                                   ; and dl, bh
    db 0x02,0xC2                                   ; add al, dl
    mul ch                                              ; [f6 e5]
    mov dx, 0xF0                                        ; [ba f0 00]
    db 0x22,0xD3                                   ; and dl, bl
    shr dx, cl                                          ; [d3 ea]
    db 0x03,0xC2                                   ; add ax, dx
    mov cx, 0xA                                         ; [b9 0a 00]
    mul cx                                              ; [f7 e1]
    and bx, byte 0xF                                    ; [83 e3 0f]
    db 0x03,0xC3                                   ; add ax, bx
    pop dx                                              ; [5a]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    ret                                                 ; [c3]
rtl_init_streams_l3E4D:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    mov al, byte [es:si+0x9]                            ; [26 8a 44 09]
    and ax, 0x80                                        ; [25 80 00]
    rol al, 0x1                                         ; [d0 c0]
    mov word [di+0xA], ax                               ; [89 45 0a]
    mov cl, 0x4                                         ; [b1 04]
    mov al, byte [es:si+0x8]                            ; [26 8a 44 08]
    shl ax, cl                                          ; [d3 e0]
    shr al, cl                                          ; [d2 e8]
    aad 0xA                                             ; [d5 0a]
    mov di, 0x2710                                      ; [bf 10 27]
    mul di                                              ; [f7 e7]
    xchg bx, ax                                         ; [93]
    lea si, word [si+0x6]                               ; [8d 74 06]
    call near 0x3E1E                                    ; [e8 a8 ff]
    db 0x03,0xC3                                   ; add ax, bx
    db 0x12,0xD6                                   ; adc dl, dh
    db 0x8B,0xDA                                   ; mov bx, dx
    mul di                                              ; [f7 e7]
    xchg bx, ax                                         ; [93]
    db 0x8B,0xCA                                   ; mov cx, dx
    mul di                                              ; [f7 e7]
    db 0x03,0xC8                                   ; add cx, ax
    db 0x12,0xD6                                   ; adc dl, dh
    sub si, byte 0x2                                    ; [83 ee 02]
    call near 0x3E1E                                    ; [e8 91 ff]
    db 0x03,0xC3                                   ; add ax, bx
    adc cx, byte 0x0                                    ; [83 d1 00]
    db 0x12,0xD6                                   ; adc dl, dh
    push si                                             ; [56]
    db 0x8B,0xDA                                   ; mov bx, dx
    mul di                                              ; [f7 e7]
    xchg cx, ax                                         ; [91]
    db 0x8B,0xF2                                   ; mov si, dx
    mul di                                              ; [f7 e7]
    xchg bx, ax                                         ; [93]
    db 0x87, 0xFA                                       ; xchg di, dx
    mul dx                                              ; [f7 e2]
    db 0x03,0xDE                                   ; add bx, si
    db 0x13,0xF8                                   ; adc di, ax
    pop si                                              ; [5e]
    sub si, byte 0x2                                    ; [83 ee 02]
    call near 0x3E1E                                    ; [e8 70 ff]
    db 0x03,0xC1                                   ; add ax, cx
    db 0x13,0xDA                                   ; adc bx, dx
    db 0x13,0xFA                                   ; adc di, dx
    mov si, 0x2710                                      ; [be 10 27]
    mul si                                              ; [f7 e6]
    xchg bx, ax                                         ; [93]
    db 0x8B,0xCA                                   ; mov cx, dx
    mul si                                              ; [f7 e6]
    xchg si, ax                                         ; [96]
    db 0x87, 0xFA                                       ; xchg di, dx
    mul dx                                              ; [f7 e2]
    db 0x03,0xCE                                   ; add cx, si
    db 0x13,0xF8                                   ; adc di, ax
    adc dx, byte 0x0                                    ; [83 d2 00]
    mov si, word [bp-0x2]                               ; [8b 76 fe]
    call near 0x3E1E                                    ; [e8 4e ff]
    db 0x03,0xD8                                   ; add bx, ax
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc di, byte 0x0                                    ; [83 d7 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    mov ax, 0x40                                        ; [b8 40 00]
rtl_init_streams_l3EDE:
    db 0x0B,0xD2                                   ; or dx, dx
    jne short 0x3EEF                                    ; [75 0d]
    sub ax, strict word 0x10                            ; [2d 10 00]
    je short 0x3F13                                     ; [74 2c]
    db 0x87, 0xD7                                       ; xchg dx, di
    db 0x87, 0xF9                                       ; xchg di, cx
    db 0x87, 0xCB                                       ; xchg cx, bx
    jmp short 0x3EDE                                    ; [eb ef]
rtl_init_streams_l3EEF:
    js short 0x3EFC                                     ; [78 0b]
rtl_init_streams_l3EF1:
    dec ax                                              ; [48]
    shl bx, 0x1                                         ; [d1 e3]
    rcl cx, 0x1                                         ; [d1 d1]
    rcl di, 0x1                                         ; [d1 d7]
    db 0x13,0xD2                                   ; adc dx, dx
    jns short 0x3EF1                                    ; [79 f5]
rtl_init_streams_l3EFC:
    mov si, word [bp-0x4]                               ; [8b 76 fc]
    mov word [si], bx                                   ; [89 1c]
    mov word [si+0x2], cx                               ; [89 4c 02]
    mov word [si+0x4], di                               ; [89 7c 04]
    mov word [si+0x6], dx                               ; [89 54 06]
    mov word [si+0x8], ax                               ; [89 44 08]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l3F13:
    mov ax, 0xC001                                      ; [b8 01 c0]
    jmp short 0x3EFC                                    ; [eb e4]
rtl_init_streams_l3F18:
    push ax                                             ; [50]
    push cx                                             ; [51]
    mov al, 0x64                                        ; [b0 64]
    mov cl, 0x4                                         ; [b1 04]
    xchg dx, ax                                         ; [92]
    div dl                                              ; [f6 f2]
    db 0x8A,0xD4                                   ; mov dl, ah
    aam 0xA                                             ; [d4 0a]
    shl ah, cl                                          ; [d2 e4]
    db 0x0A,0xE0                                   ; or ah, al
    xchg dx, ax                                         ; [92]
    aam 0xA                                             ; [d4 0a]
    shl ah, cl                                          ; [d2 e4]
    db 0x0A,0xC4                                   ; or al, ah
    db 0x8A,0xE6                                   ; mov ah, dh
    stosw                                               ; [ab]
    pop cx                                              ; [59]
    pop ax                                              ; [58]
    ret                                                 ; [c3]
rtl_init_streams_l3F36:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push si                                             ; [56]
    push di                                             ; [57]
    cld                                                 ; [fc]
    mov ax, word [si+0x8]                               ; [8b 44 08]
    mov bx, word [si]                                   ; [8b 1c]
    mov cx, word [si+0x2]                               ; [8b 4c 02]
    mov dx, word [si+0x6]                               ; [8b 54 06]
    mov si, word [si+0x4]                               ; [8b 74 04]
    cmp ax, strict word 0x0                             ; [3d 00 00]
    jl short 0x3F87                                     ; [7c 38]
    sub ax, strict word 0x3C                            ; [2d 3c 00]
    jl short 0x3F73                                     ; [7c 1f]
    jg short 0x3F89                                     ; [7f 33]
    cmp dx, word 0xDE0B                                 ; [81 fa 0b de]
    jb short 0x3F73                                     ; [72 17]
    ja short 0x3F89                                     ; [77 2b]
    cmp si, word 0x6B3A                                 ; [81 fe 3a 6b]
    jb short 0x3F73                                     ; [72 0f]
    ja short 0x3F89                                     ; [77 23]
    cmp cx, word 0x763F                                 ; [81 f9 3f 76]
    jb short 0x3F73                                     ; [72 07]
    ja short 0x3F89                                     ; [77 1b]
    cmp bx, -0x10                                       ; [83 fb f0]
    ja short 0x3F89                                     ; [77 16]
rtl_init_streams_l3F73:
    mov ah, 0x0                                         ; [b4 00]
    sub al, 0x4                                         ; [2c 04]
rtl_init_streams_l3F77:
    add al, 0x10                                        ; [04 10]
    jg short 0x3F8B                                     ; [7f 10]
    db 0x8A,0xE7                                   ; mov ah, bh
    db 0x8B,0xD9                                   ; mov bx, cx
    db 0x8B,0xCE                                   ; mov cx, si
    db 0x8B,0xF2                                   ; mov si, dx
    db 0x2B,0xD2                                   ; sub dx, dx
    jmp short 0x3F77                                    ; [eb f0]
rtl_init_streams_l3F87:
    jmp short 0x3FF0                                    ; [eb 67]
rtl_init_streams_l3F89:
    jmp short 0x3FF9                                    ; [eb 6e]
rtl_init_streams_l3F8B:
    sub al, 0x10                                        ; [2c 10]
    jge short 0x3F9D                                    ; [7d 0e]
rtl_init_streams_l3F8F:
    shr dx, 0x1                                         ; [d1 ea]
    rcr si, 0x1                                         ; [d1 de]
    rcr cx, 0x1                                         ; [d1 d9]
    rcr bx, 0x1                                         ; [d1 db]
    rcr ah, 0x1                                         ; [d0 dc]
    inc al                                              ; [fe c0]
    jl short 0x3F8F                                     ; [7c f2]
rtl_init_streams_l3F9D:
    db 0x02,0xE4                                   ; add ah, ah
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc cx, byte 0x0                                    ; [83 d1 00]
    adc si, byte 0x0                                    ; [83 d6 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    xchg si, ax                                         ; [96]
    mov si, 0x2710                                      ; [be 10 27]
    div si                                              ; [f7 f6]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    xchg bx, ax                                         ; [93]
    div si                                              ; [f7 f6]
    call near 0x3F18                                    ; [e8 5e ff]
    db 0x2B,0xD2                                   ; sub dx, dx
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    xchg bx, ax                                         ; [93]
    div si                                              ; [f7 f6]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    call near 0x3F18                                    ; [e8 50 ff]
    db 0x8B,0xD3                                   ; mov dx, bx
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    xchg cx, ax                                         ; [91]
    div si                                              ; [f7 f6]
    call near 0x3F18                                    ; [e8 45 ff]
    db 0x8B,0xD1                                   ; mov dx, cx
    div si                                              ; [f7 f6]
    call near 0x3F18                                    ; [e8 3e ff]
    aam 0xA                                             ; [d4 0a]
    mov cl, 0x4                                         ; [b1 04]
    shl ah, cl                                          ; [d2 e4]
    db 0x0A,0xC4                                   ; or al, ah
    stosb                                               ; [aa]
rtl_init_streams_l3FE3:
    mov si, word [bp-0x2]                               ; [8b 76 fe]
    mov al, byte [si+0xA]                               ; [8a 44 0a]
    ror al, 0x1                                         ; [d0 c8]
    stosb                                               ; [aa]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
rtl_init_streams_l3FF0:
    mov al, 0x0                                         ; [b0 00]
rtl_init_streams_l3FF2:
    mov cx, 0x9                                         ; [b9 09 00]
    db 0xF3,0xAA                                   ; rep stosb byte [es:di], al
    jmp short 0x3FE3                                    ; [eb ea]
rtl_init_streams_l3FF9:
    mov ch, 0x8                                         ; [b5 08]
    call near 0x3DBF                                    ; [e8 c1 fd]
    mov al, 0x99                                        ; [b0 99]
    jmp short 0x3FF2                                    ; [eb f0]
    dec cx                                              ; [49]
    sub dx, word [bp+di+0x2B]                           ; [2b 53 2b]
    pop bp                                              ; [5d]
    sub sp, word [bx+0x2B]                              ; [2b 67 2b]
    jno short 0x4037                                    ; [71 2b]
    js short 0x4039                                     ; [78 2b]
    xchg si, ax                                         ; [96]
    sub di, word [bx+0x2B]                              ; [2b 7f 2b]
    sbb al, 0x2F                                        ; [1c 2f]
    xchg cx, ax                                         ; [91]
    das                                                 ; [2f]
    imul word [bx]                                      ; [f7 2f]
    stc                                                 ; [f9]
    das                                                 ; [2f]
    in al, 0x10                                         ; [e4 10]
    mov bh, 0xC                                         ; [b7 0c]
    call near 0x9532                                    ; [e8 11 55]
    or sp, word [bx]                                    ; [0b 27]
    sub al, 0x2E                                        ; [2c 2e]
    sub al, 0x38                                        ; [2c 38]
    sub al, 0x35                                        ; [2c 35]
    sub al, 0x3F                                        ; [2c 3f]
    sub al, 0x3E                                        ; [2c 3e]
    sub al, 0x47                                        ; [2c 47]
    sub al, 0x46                                        ; [2c 46]
    sub al, 0xE4                                        ; [2c e4]
    adc byte [bx-0x17F4], dh                            ; [10 b7 0c e8]
rtl_init_streams_l4037:
    adc word [di+0xB], dx                               ; [11 55 0b]
    push 0x10                                           ; [6a 10]
    dec word [si]                                       ; [ff 0c]
    inc sp                                              ; [44]
    adc word [bp+si-0x40F5], cx                         ; [11 8a 0b bf]
    sub al, 0xB9                                        ; [2c b9]
    sub al, 0x56                                        ; [2c 56]
    sub ax, 0x2CE3                                      ; [2d e3 2c]
    db 0xC8,0x2C,0xF3,0x2C                         ; enter -0xCD4, 0x2C
    mov cx, 0xD32C                                      ; [b9 2c d3]
    sub al, 0x3                                         ; [2c 03]
    sub ax, 0x2CB9                                      ; [2d b9 2c]
    and al, 0x2D                                        ; [24 2d]
    mov dx, 0x8C2D                                      ; [ba 2d 8c]
    sub ax, 0x2DC7                                      ; [2d c7 2d]
    xchg cx, ax                                         ; [91]
    sub ax, 0x2DAD                                      ; [2d ad 2d]
rtl_init_streams_l4062:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 58 fd]
    jmp near 0x45D7                                     ; [e9 6d 05]
rtl_init_streams_l406A:
    ja short 0x4090                                     ; [77 24]
    test ah, 0x20                                       ; [f6 c4 20]
    jne short 0x4062                                    ; [75 f1]
    inc dx                                              ; [42]
    db 0x8A,0xC4                                   ; mov al, ah
    mov di, ds                                          ; [8c df]
    and al, 0xC0                                        ; [24 c0]
    je short 0x4088                                     ; [74 0e]
    cmp al, 0x80                                        ; [3c 80]
    mov di, ss                                          ; [8c d7]
    jb short 0x4088                                     ; [72 08]
    mov di, word [bp+0x4]                               ; [8b 7e 04]
    ja short 0x4088                                     ; [77 03]
    mov di, word [bp+0x14]                              ; [8b 7e 14]
rtl_init_streams_l4088:
    es lodsb                                            ; [26 ac]
    db 0x86, 0xE0                                       ; xchg ah, al
    and al, 0x7                                         ; [24 07]
    jmp short 0x40C2                                    ; [eb 32]
rtl_init_streams_l4090:
    cmp al, 0x9                                         ; [3c 09]
    jne short 0x409D                                    ; [75 09]
    mov word [es:si-0x3], 0xE489                        ; [26 c7 44 fd 89 e4]
    jmp near 0x45D7                                     ; [e9 3a 05]
rtl_init_streams_l409D:
    jmp near 0x3DFC                                     ; [e9 5c fd]
    loopne 0x40A2                                       ; [e0 00]
rtl_init_streams_l40A2:
    sti                                                 ; [fb]
    cld                                                 ; [fc]
    push dx                                             ; [52]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push bp                                             ; [55]
    push si                                             ; [56]
    push di                                             ; [57]
    push es                                             ; [06]
    push cx                                             ; [51]
    push ds                                             ; [1e]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov word [ss:0xDE], bp                              ; [36 89 2e de 00]
    les si,  [bp+0x12]                              ; [c4 76 12]
    dec si                                              ; [4e]
    mov dl, 0x0                                         ; [b2 00]
    es lodsw                                            ; [26 ad]
    sub al, 0x34                                        ; [2c 34]
    cmp al, 0x8                                         ; [3c 08]
    jae short 0x406A                                    ; [73 a8]
rtl_init_streams_l40C2:
    mov bx, 0xC007                                      ; [bb 07 c0]
    db 0x22,0xDC                                   ; and bl, ah
    db 0x22,0xFC                                   ; and bh, ah
    xchg cx, ax                                         ; [91]
    cmp bh, byte 0xC0                                   ; [80 ff c0]
    jae short 0x4136                                    ; [73 67]
    cmp bh, byte 0x40                                   ; [80 ff 40]
    ja short 0x40E6                                     ; [77 12]
    je short 0x40EA                                     ; [74 14]
    db 0x2B,0xC0                                   ; sub ax, ax
    cmp bl, byte 0x6                                    ; [80 fb 06]
    jne short 0x40ED                                    ; [75 10]
    es lodsw                                            ; [26 ad]
    mov word [bp+0x12], si                              ; [89 76 12]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 65]
rtl_init_streams_l40E6:
    es lodsw                                            ; [26 ad]
    jmp short 0x40ED                                    ; [eb 03]
rtl_init_streams_l40EA:
    es lodsb                                            ; [26 ac]
    db 0x98                                        ; cbw
rtl_init_streams_l40ED:
    mov word [bp+0x12], si                              ; [89 76 12]
    mov bh, 0x0                                         ; [b7 00]
    shl bx, 0x1                                         ; [d1 e3]
    jmp [cs:bx+0x2A52]                                  ; [2e ff a7 52 2a]
    add ax, word [bp+0xC]                               ; [03 46 0c]
    add ax, word [bp+0x8]                               ; [03 46 08]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 48]
    add ax, word [bp+0xC]                               ; [03 46 0c]
    add ax, word [bp+0x6]                               ; [03 46 06]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 3e]
    add ax, word [bp+0xA]                               ; [03 46 0a]
    add ax, word [bp+0x8]                               ; [03 46 08]
    mov si, ss                                          ; [8c d6]
    jmp short 0x414B                                    ; [eb 34]
    add ax, word [bp+0xA]                               ; [03 46 0a]
    add ax, word [bp+0x6]                               ; [03 46 06]
    mov si, ss                                          ; [8c d6]
    jmp short 0x414B                                    ; [eb 2a]
    add ax, word [bp+0x8]                               ; [03 46 08]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 23]
    add ax, word [bp+0x6]                               ; [03 46 06]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 1c]
    add ax, word [bp+0xC]                               ; [03 46 0c]
    mov si, ds                                          ; [8c de]
    jmp short 0x414B                                    ; [eb 15]
rtl_init_streams_l4136:
    mov word [bp+0x12], si                              ; [89 76 12]
    mov ax, ss                                          ; [8c d0]
    mov ds, ax                                          ; [8e d8]
    mov es, ax                                          ; [8e c0]
    test cl, 0x1                                        ; [f6 c1 01]
    je short 0x4177                                     ; [74 33]
    jmp short 0x415D                                    ; [eb 17]
    add ax, word [bp+0xA]                               ; [03 46 0a]
    mov si, ss                                          ; [8c d6]
rtl_init_streams_l414B:
    xchg si, ax                                         ; [96]
    cmp dl, byte 0x1                                    ; [80 fa 01]
    jne short 0x4152                                    ; [75 01]
    xchg di, ax                                         ; [97]
rtl_init_streams_l4152:
    mov es, ax                                          ; [8e c0]
    mov ax, ss                                          ; [8c d0]
    mov ds, ax                                          ; [8e d8]
    test cl, 0x1                                        ; [f6 c1 01]
    je short 0x4177                                     ; [74 1a]
rtl_init_streams_l415D:
    cmp ch, byte 0xC0                                   ; [80 fd c0]
    jae short 0x4165                                    ; [73 03]
    jmp near 0x41FE                                     ; [e9 99 00]
rtl_init_streams_l4165:
    test ch, 0x20                                       ; [f6 c5 20]
    jne short 0x416D                                    ; [75 03]
    jmp near 0x43A4                                     ; [e9 37 02]
rtl_init_streams_l416D:
    mov bx, 0x6                                         ; [bb 06 00]
    db 0x22,0xD9                                   ; and bl, cl
    jmp [cs:bx+0x2A62]                                  ; [2e ff a7 62 2a]
rtl_init_streams_l4177:
    mov ax, 0x38                                        ; [b8 38 00]
    db 0x22,0xC5                                   ; and al, ch
    shr ax, 0x1                                         ; [d1 e8]
    shr ax, 0x1                                         ; [d1 e8]
    xchg bp, ax                                         ; [95]
    cmp ch, byte 0xC0                                   ; [80 fd c0]
    jae short 0x41B0                                    ; [73 2a]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    mov bx, 0x6                                         ; [bb 06 00]
    db 0x22,0xD9                                   ; and bl, cl
    call [cs:bx+0x2A6A]                                 ; [2e ff 97 6a 2a]
    mov cx, ss                                          ; [8c d1]
    mov es, cx                                          ; [8e c1]
    mov si, 0xC                                         ; [be 0c 00]
    db 0x8B,0xDF                                   ; mov bx, di
    lea ax, word [bx+si]                                ; [8d 00]
    db 0x8B,0xD0                                   ; mov dx, ax
    mov cx, 0x3022                                      ; [b9 22 30]
    jmp [cs:bp+0x2A72]                                  ; [2e ff a6 72 2a]
rtl_init_streams_l41B0:
    mov bh, 0x0                                         ; [b7 00]
    mov bl, byte [cs:bx+0xA14]                          ; [2e 8a 9f 14 0a]
    mov ax, word [0x00D8]                               ; [a1 d8 00]
    db 0x03,0xD8                                   ; add bx, ax
    test cl, 0x4                                        ; [f6 c1 04]
    db 0x8B,0xD0                                   ; mov dx, ax
    je short 0x41C5                                     ; [74 02]
    db 0x8B,0xD3                                   ; mov dx, bx
rtl_init_streams_l41C5:
    db 0x2B,0xF6                                   ; sub si, si
    test cl, 0x2                                        ; [f6 c1 02]
    je short 0x41CF                                     ; [74 03]
    mov si, 0xC                                         ; [be 0c 00]
rtl_init_streams_l41CF:
    mov cx, 0x3022                                      ; [b9 22 30]
    jmp [cs:bp+0x2A72]                                  ; [2e ff a6 72 2a]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push dx                                             ; [52]
    push cx                                             ; [51]
    jmp near 0x2940                                     ; [e9 62 e7]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push dx                                             ; [52]
    push cx                                             ; [51]
    jmp near 0x2B05                                     ; [e9 20 e9]
    add si, byte 0xC                                    ; [83 c6 0c]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push cx                                             ; [51]
    jmp near 0x30F7                                     ; [e9 09 ef]
    xchg bx, ax                                         ; [93]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push dx                                             ; [52]
    push cx                                             ; [51]
    jmp near 0x293C                                     ; [e9 46 e7]
    xchg bx, ax                                         ; [93]
    push ax                                             ; [50]
    push bx                                             ; [53]
    push dx                                             ; [52]
    push cx                                             ; [51]
    jmp near 0x2CD5                                     ; [e9 d7 ea]
rtl_init_streams_l41FE:
    mov bp, 0x6                                         ; [bd 06 00]
    db 0x23,0xE9                                   ; and bp, cx
    test ch, 0x20                                       ; [f6 c5 20]
    jne short 0x424A                                    ; [75 42]
    test ch, 0x10                                       ; [f6 c5 10]
    jne short 0x4227                                    ; [75 1a]
    test ch, 0x8                                        ; [f6 c5 08]
    jne short 0x4266                                    ; [75 54]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    mov ax, 0xFFF4                                      ; [b8 f4 ff]
    db 0x03,0xF8                                   ; add di, ax
    mov word [0x00DA], ax                               ; [a3 da 00]
    mov ax, 0x301D                                      ; [b8 1d 30]
    push ax                                             ; [50]
    jmp [cs:bp+0x2A82]                                  ; [2e ff a6 82 2a]
rtl_init_streams_l4227:
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    db 0x87, 0xF7                                       ; xchg si, di
    test ch, 0x8                                        ; [f6 c5 08]
    jne short 0x423B                                    ; [75 09]
    mov ax, 0x3027                                      ; [b8 27 30]
    push ax                                             ; [50]
    jmp [cs:bp+0x2A8A]                                  ; [2e ff a6 8a 2a]
rtl_init_streams_l423B:
    mov word [0x00DA], 0xC                              ; [c7 06 da 00 0c 00]
    mov ax, 0x301D                                      ; [b8 1d 30]
    push ax                                             ; [50]
    jmp [cs:bp+0x2A8A]                                  ; [2e ff a6 8a 2a]
rtl_init_streams_l424A:
    mov ax, 0x8                                         ; [b8 08 00]
    db 0x22,0xC5                                   ; and al, ch
    db 0x0B,0xE8                                   ; or bp, ax
    mov ax, 0x3027                                      ; [b8 27 30]
    push ax                                             ; [50]
    test ch, 0x10                                       ; [f6 c5 10]
    jne short 0x425F                                    ; [75 05]
    jmp [cs:bp+0x2A92]                                  ; [2e ff a6 92 2a]
rtl_init_streams_l425F:
    db 0x87, 0xF7                                       ; xchg si, di
    jmp [cs:bp+0x2AA2]                                  ; [2e ff a6 a2 2a]
rtl_init_streams_l4266:
    jmp near 0x45D7                                     ; [e9 6e 03]
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 51 fb]
    ret                                                 ; [c3]
rtl_init_streams_l426F:
    mov cl, 0x4                                         ; [b1 04]
    mov ax, word [es:si+0x2]                            ; [26 8b 44 02]
    mov word [0x00D4], ax                               ; [a3 d4 00]
    mov ax, word [es:si]                                ; [26 8b 04]
    mov word [0x00D6], ax                               ; [a3 d6 00]
    mov ch, 0x0                                         ; [b5 00]
    jmp near 0x3DBF                                     ; [e9 3c fb]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    call near 0x23AC                                    ; [e8 1f e1]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    ret                                                 ; [c3]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    call near 0x3E4D                                    ; [e8 b0 fb]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    ret                                                 ; [c3]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    call near 0x2879                                    ; [e8 cc e5]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
    ret                                                 ; [c3]
rtl_init_streams_l42B3:
    call near 0x433C                                    ; [e8 86 00]
    call near 0x4341                                    ; [e8 88 00]
    mov ax, 0xC0                                        ; [b8 c0 00]
    sub ax, word [0x00D8]                               ; [2b 06 d8 00]
    mov dl, 0xC                                         ; [b2 0c]
    div dl                                              ; [f6 f2]
    mov cx, 0xFFFF                                      ; [b9 ff ff]
    xchg cx, ax                                         ; [91]
    db 0x03,0xC9                                   ; add cx, cx
    shr ax, cl                                          ; [d3 e8]
    stosw                                               ; [ab]
    db 0x2B,0xC0                                   ; sub ax, ax
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    stosw                                               ; [ab]
    ret                                                 ; [c3]
    call near 0x42B3                                    ; [e8 dc ff]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    mov bp, word [es:di-0xA]                            ; [26 8b 6d f6]
    or bp, word 0x5555                                  ; [81 cd 55 55]
    jmp short 0x42F4                                    ; [eb 0f]
rtl_init_streams_l42E5:
    call near 0x2852                                    ; [e8 6a e5]
    add si, byte 0xC                                    ; [83 c6 0c]
    add di, byte 0xA                                    ; [83 c7 0a]
    shl bp, 0x1                                         ; [d1 e5]
    shl bp, 0x1                                         ; [d1 e5]
    je short 0x4305                                     ; [74 11]
rtl_init_streams_l42F4:
    jns short 0x42E5                                    ; [79 ef]
    jmp short 0x4303                                    ; [eb 0b]
rtl_init_streams_l42F8:
    db 0x2B,0xC0                                   ; sub ax, ax
    mov cx, 0x5                                         ; [b9 05 00]
    db 0xF3,0xAB                                   ; rep stosw word [es:di], ax
    shl bp, 0x1                                         ; [d1 e5]
    shl bp, 0x1                                         ; [d1 e5]
rtl_init_streams_l4303:
    jne short 0x42F8                                    ; [75 f3]
rtl_init_streams_l4305:
    ret                                                 ; [c3]
    mov di, 0xC0                                        ; [bf c0 00]
    mov bp, word [es:si+0x4]                            ; [26 8b 6c 04]
    add si, byte 0x54                                   ; [83 c6 54]
    or bp, word 0x5555                                  ; [81 cd 55 55]
rtl_init_streams_l4314:
    shr bp, 0x1                                         ; [d1 ed]
    shr bp, 0x1                                         ; [d1 ed]
    jae short 0x4325                                    ; [73 0b]
    sub si, byte 0xA                                    ; [83 ee 0a]
    db 0x0B,0xED                                   ; or bp, bp
    jne short 0x4314                                    ; [75 f3]
    jmp short 0x4332                                    ; [eb 0f]
rtl_init_streams_l4323:
    shr bp, 0x1                                         ; [d1 ed]
rtl_init_streams_l4325:
    sub di, byte 0xC                                    ; [83 ef 0c]
    call near 0x2879                                    ; [e8 4e e5]
    sub si, byte 0xA                                    ; [83 ee 0a]
    shr bp, 0x1                                         ; [d1 ed]
    jb short 0x4323                                     ; [72 f1]
rtl_init_streams_l4332:
    mov word [0x00D8], di                               ; [89 3e d8 00]
    add si, -0x4                                        ; [83 c6 fc]
    jmp near 0x426F                                     ; [e9 33 ff]
rtl_init_streams_l433C:
    mov ax, word [0x00D6]                               ; [a1 d6 00]
    stosw                                               ; [ab]
    ret                                                 ; [c3]
rtl_init_streams_l4341:
    mov ax, word [0x00D8]                               ; [a1 d8 00]
    sub ax, 0xC0                                        ; [2d c0 00]
    mov cl, 0xC                                         ; [b1 0c]
    idiv cl                                             ; [f6 f9]
    and al, 0x7                                         ; [24 07]
    mov cl, 0x3                                         ; [b1 03]
    shl al, cl                                          ; [d2 e0]
    mov cx, word [0x00D4]                               ; [8b 0e d4 00]
    and ch, byte 0xC7                                   ; [80 e5 c7]
    db 0x0A,0xE8                                   ; or ch, al
    xchg cx, ax                                         ; [91]
    stosw                                               ; [ab]
    ret                                                 ; [c3]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x241E                                    ; [e8 ba e0]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    ret                                                 ; [c3]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x3F36                                    ; [e8 c5 fb]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    ret                                                 ; [c3]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    call near 0x2852                                    ; [e8 d4 e4]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    ret                                                 ; [c3]
    adc bp, word [0x2E66]                               ; [13 2e 66 2e]
    daa                                                 ; [27]
    and word [cs:0x2E6D], bp                            ; [2e 21 2e 6d 2e]
    db 0x66,0x2E,0x6D                              ; insd dword [es:di], dx
    cs insw                                             ; [2e 6d]
    db 0x2E,0x61                                   ; popaw
    db 0x2E,0x66,0x2E,0x7E,0x2E                    ; jle 0x43C8
    mov word [0x2E89], bp                               ; [89 2e 89 2e]
    db 0x66,0x2E,0x89,0x2E,0x89,0x2E               ; mov dword [cs:0x2E89], ebp
rtl_init_streams_l43A4:
    mov bh, 0x0                                         ; [b7 00]
    mov bl, byte [cs:bx+0xA14]                          ; [2e 8a 9f 14 0a]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x03,0xF3                                   ; add si, bx
    mov bl, 0x18                                        ; [b3 18]
    db 0x22,0xDD                                   ; and bl, ch
    and cl, byte 0x6                                    ; [80 e1 06]
    db 0x0A,0xD9                                   ; or bl, cl
    cld                                                 ; [fc]
    mov cx, 0x6                                         ; [b9 06 00]
    jmp [cs:bx+0x2DD4]                                  ; [2e ff a7 d4 2d]
    sub word [0x00D8], 0xC                              ; [83 2e d8 00 0c]
rtl_init_streams_l43C8:
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    jmp near 0x45D7                                     ; [e9 06 02]
    mov di, 0xC                                         ; [bf 0c 00]
    jmp short 0x43DA                                    ; [eb 04]
    nop                                                 ; [90]
    mov di, 0x0                                         ; [bf 00 00]
rtl_init_streams_l43DA:
    cmp si, word 0xB4                                   ; [81 fe b4 00]
    je short 0x43F0                                     ; [74 10]
    db 0x87, 0xFE                                       ; xchg di, si
    mov ax, 0x4001                                      ; [b8 01 40]
    mov cl, 0x0                                         ; [b1 00]
    call near 0x205B                                    ; [e8 71 dc]
    add word [0x00D8], si                               ; [01 36 d8 00]
    jmp short 0x4445                                    ; [eb 55]
rtl_init_streams_l43F0:
    add di, byte 0xC                                    ; [83 c7 0c]
    db 0x8B,0xD7                                   ; mov dx, di
    db 0x8B,0xCE                                   ; mov cx, si
    sub cx, word [0x00D8]                               ; [2b 0e d8 00]
    je short 0x440B                                     ; [74 0e]
    push ss                                             ; [16]
    pop es                                              ; [07]
    sub si, byte 0x2                                    ; [83 ee 02]
    mov di, 0xBE                                        ; [bf be 00]
    std                                                 ; [fd]
    shr cx, 0x1                                         ; [d1 e9]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    cld                                                 ; [fc]
rtl_init_streams_l440B:
    add word [0x00D8], dx                               ; [01 16 d8 00]
    jmp short 0x4445                                    ; [eb 34]
    test ch, 0x7                                        ; [f6 c5 07]
    je short 0x4445                                     ; [74 2f]
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 a4 f9]
    jmp short 0x4445                                    ; [eb 28]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
rtl_init_streams_l4421:
    mov ax, word [di]                                   ; [8b 05]
    xchg word [si], ax                                  ; [87 04]
    stosw                                               ; [ab]
    add si, byte 0x2                                    ; [83 c6 02]
    loop 0x4421                                         ; [e2 f6]
    jmp near 0x45D7                                     ; [e9 a9 01]
    db 0x8B,0xFE                                   ; mov di, si
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    jmp near 0x45D7                                     ; [e9 9e 01]
    db 0x8B,0xFE                                   ; mov di, si
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    mov word [0x00D8], si                               ; [89 36 d8 00]
rtl_init_streams_l4445:
    jmp near 0x45D7                                     ; [e9 8f 01]
    add al, 0x4                                         ; [04 04]
    add al, 0x4                                         ; [04 04]
    add al, 0x4                                         ; [04 04]
    add al, 0x4                                         ; [04 04]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si], al                                   ; [00 04]
    add al, 0x8                                         ; [04 08]
    push es                                             ; [06]
    or byte [0x0204], al                                ; [08 06 04 02]
    add byte [bp+si], cl                                ; [00 0a]
    or byte [si], al                                    ; [08 04]
    add al, 0x4                                         ; [04 04]
    or al, byte [si]                                    ; [0a 04]
    add al, 0xF8                                        ; [04 f8]
    db 0x2E,0xFD                                   ; std
    or ch, byte [cs:bx]                                 ; [2e 0a 2f]
    or ch, byte [bx]                                    ; [0a 2f]
    pop es                                              ; [07]
    sbb al, 0x44                                        ; [1c 44]
    sbb al, 0xA                                         ; [1c 0a]
    das                                                 ; [2f]
    or ch, byte [bx]                                    ; [0a 2f]
    xor byte [bp+si], cl                                ; [30 0a]
    inc cx                                              ; [41]
    or dl, byte [bp+si+0xA]                             ; [0a 52 0a]
    arpl word [bp+si], cx                               ; [63 0a]
    je short 0x448C                                     ; [74 0a]
    test word [bp+si], cx                               ; [85 0a]
    xchg si, ax                                         ; [96]
    or cl, byte [bp+si]                                 ; [0a 0a]
    das                                                 ; [2f]
    in ax, dx                                           ; [ed]
    and bp, sp                                          ; [21 e5]
    and ch, byte [bx+0x1F]                              ; [22 6f 1f]
    db 0x65,0x20,0x02                              ; and byte [gs:bp+si], al
    das                                                 ; [2f]
    or ch, byte [bx]                                    ; [0a 2f]
    or ch, byte [bx]                                    ; [0a 2f]
    or ch, byte [bx]                                    ; [0a 2f]
    aas                                                 ; [3f]
    sbb bl, byte [si+0x7223]                            ; [1a 9c 23 72]
    sbb word [bp+si], cx                                ; [19 0a]
    das                                                 ; [2f]
    pushaw                                              ; [60]
    cmovge cx, word [si]                                ; [0f 4d 0c]
    or ch, byte [bx]                                    ; [0a 2f]
    or ch, byte [bx]                                    ; [0a 2f]
    xor byte [si+0xA], 0x1                              ; [80 74 0a 01]
    ret                                                 ; [c3]
    mov byte [si+0xA], 0x0                              ; [c6 44 0a 00]
    ret                                                 ; [c3]
    push si                                             ; [56]
    push di                                             ; [57]
    call near 0x21C9                                    ; [e8 12 dd]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    ret                                                 ; [c3]
    mov ch, 0x1                                         ; [b5 01]
    jmp near 0x3DBF                                     ; [e9 00 f9]
    ret                                                 ; [c3]
    das                                                 ; [2f]
    das                                                 ; [2f]
    db 0x66,0x2F                                   ; das
    inc dx                                              ; [42]
    das                                                 ; [2f]
    push cx                                             ; [51]
    das                                                 ; [2f]
    outsb                                               ; [6e]
    das                                                 ; [2f]
    sub word [bx], 0x1FBB                               ; [81 2f bb 1f]
    add byte [bp+si], ah                                ; [00 22]

; ------------------------------------------------------------------------------
; DATA  image:0x44D0 .. 0x44D0   1 bytes
; ------------------------------------------------------------------------------
data_44D0:
    db 0xDD                                          ; 0x44D0
    mov al, byte [cs:bx+0x2E98]                         ; [2e 8a 87 98 2e]
    db 0x98                                        ; cbw
    xchg di, ax                                         ; [97]
    shl bx, 0x1                                         ; [d1 e3]
    jmp [cs:di+0x2F10]                                  ; [2e ff a5 10 2f]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    sub di, byte 0xC                                    ; [83 ef 0c]
    call [cs:bx+0x2EB8]                                 ; [2e ff 97 b8 2e]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    jmp near 0x45D7                                     ; [e9 e5 00]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x8B,0xFE                                   ; mov di, si
    mov ax, 0x3027                                      ; [b8 27 30]
    push ax                                             ; [50]
    jmp [cs:bx+0x2EB8]                                  ; [2e ff a7 b8 2e]
    mov si, word [0x00D8]                               ; [8b 36 d8 00]
    db 0x8B,0xFE                                   ; mov di, si
    sub di, byte 0xC                                    ; [83 ef 0c]
    call [cs:bx+0x2EB8]                                 ; [2e ff 97 b8 2e]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    jmp near 0x45D7                                     ; [e9 c1 00]
    add word [0x00D8], 0xC                              ; [83 06 d8 00 0c]
    jmp near 0x45D7                                     ; [e9 b9 00]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    lea si, word [di+0xC]                               ; [8d 75 0c]
    call [cs:bx+0x2EB8]                                 ; [2e ff 97 b8 2e]
    mov word [0x00D8], si                               ; [89 36 d8 00]
    jmp near 0x45D7                                     ; [e9 a6 00]
    mov di, word [0x00D8]                               ; [8b 3e d8 00]
    lea si, word [di+0xC]                               ; [8d 75 0c]
    mov ax, 0x3027                                      ; [b8 27 30]
    push ax                                             ; [50]
    jmp [cs:bx+0x2EB8]                                  ; [2e ff a7 b8 2e]
    and ch, byte 0x1F                                   ; [80 e5 1f]
    cmp ch, byte 0x3                                    ; [80 fd 03]
    jne short 0x4593                                    ; [75 4a]
    mov di, 0xC0                                        ; [bf c0 00]
    mov word [0x00D8], di                               ; [89 3e d8 00]
    mov ax, 0x4001                                      ; [b8 01 40]
    mov cl, 0x0                                         ; [b1 00]
    call near 0x205B                                    ; [e8 03 db]
    lea si, word [di+0xA]                               ; [8d 75 0a]
    sub di, byte 0x2                                    ; [83 ef 02]
    std                                                 ; [fd]
    sub sp, byte 0x60                                   ; [83 ec 60]
    mov cx, 0x30                                        ; [b9 30 00]
    db 0xF3,0xA5                                   ; rep movsw word [es:di], word [si]
    mov word [0x00D4], 0x4100                           ; [c7 06 d4 00 00 41]
    mov word [0x00D6], 0x33F                            ; [c7 06 d6 00 3f 03]
    mov word [0x00DA], 0x0                              ; [c7 06 da 00 00 00]
    mov word [0x00D8], 0xC0                             ; [c7 06 d8 00 c0 00]
    mov word [0x00E0], 0x6D65                           ; [c7 06 e0 00 65 6d]
    mov word [0x00E2], 0x8775                           ; [c7 06 e2 00 75 87]
    mov word [0x00E4], 0x1                              ; [c7 06 e4 00 01 00]
    jmp short 0x45A4                                    ; [eb 11]
rtl_init_streams_l4593:
    cmp ch, byte 0x2                                    ; [80 fd 02]
    jne short 0x459F                                    ; [75 07]
    mov byte [0x00D4], 0x0                              ; [c6 06 d4 00 00]
    jmp short 0x45A4                                    ; [eb 05]
rtl_init_streams_l459F:
    mov ch, 0x1                                         ; [b5 01]
    call near 0x3DBF                                    ; [e8 1b f8]
rtl_init_streams_l45A4:
    jmp short 0x45D7                                    ; [eb 31]
    nop                                                 ; [90]
    jmp short 0x459F                                    ; [eb f6]
    test ch, 0x1F                                       ; [f6 c5 1f]
    jne short 0x459F                                    ; [75 f1]
    mov ax, word [0x00D8]                               ; [a1 d8 00]
    sub ax, 0xC0                                        ; [2d c0 00]
    mov cl, 0xC                                         ; [b1 0c]
    idiv cl                                             ; [f6 f9]
    and al, 0x7                                         ; [24 07]
    mov cl, 0x3                                         ; [b1 03]
    shl al, cl                                          ; [d2 e0]
    mov cx, word [0x00D4]                               ; [8b 0e d4 00]
    and ch, byte 0xC7                                   ; [80 e5 c7]
    db 0x0A,0xE8                                   ; or ch, al
    mov word [bp+0xE], cx                               ; [89 4e 0e]
    jmp short 0x45D7                                    ; [eb 0b]
    nop                                                 ; [90]
    mov si, word [ss:0xDA]                              ; [36 8b 36 da 00]
    add word [ss:0xD8], si                              ; [36 01 36 d8 00]
rtl_init_streams_l45D7:
    cmp word [ss:0xD8], 0xC0                            ; [36 81 3e d8 00 c0 00]
    ja short 0x45EF                                     ; [77 0f]
rtl_init_streams_l45E0:
    mov sp, word [ss:0xDE]                              ; [36 8b 26 de 00]
    pop ds                                              ; [1f]
    pop cx                                              ; [59]
    pop es                                              ; [07]
    pop di                                              ; [5f]
    pop si                                              ; [5e]
    pop bp                                              ; [5d]
    pop bx                                              ; [5b]
    pop ax                                              ; [58]
    pop dx                                              ; [5a]
    iret                                                ; [cf]
rtl_init_streams_l45EF:
    int3                                                ; [cc]
    jmp short 0x45E0                                    ; [eb ee]
    xor ax, 0x68C2                                      ; [35 c2 68]
    and word [bp+si+0xFDA], sp                          ; [21 a2 da 0f]
    leave                                               ; [c9]

; ------------------------------------------------------------------------------
; DATA  image:0x45FA .. 0x45FA   1 bytes
; ------------------------------------------------------------------------------
data_45FA:
    db 0xFE                                          ; 0x45FA
    aas                                                 ; [3f]
    xor ax, 0x68C2                                      ; [35 c2 68]
    and word [bp+si+0xFDA], sp                          ; [21 a2 da 0f]
    leave                                               ; [c9]

; ------------------------------------------------------------------------------
; DATA  image:0x4604 .. 0x4604   1 bytes
; ------------------------------------------------------------------------------
data_4604:
    db 0xFF                                          ; 0x4604
    aas                                                 ; [3f]
    add byte [bp+si-0x40], al                           ; [00 42 c0]
    inc word [bx+si]                                    ; [ff 00]
    dec ax                                              ; [48]
    sar bh, 0x0                                         ; [c0 ff 00]
    dec dx                                              ; [4a]
    sar bh, 0x0                                         ; [c0 ff 00]
    add byte [bx+si], al                                ; [00 00]
    aas                                                 ; [3f]
    test word [si-0x22], sp                             ; [85 64 de]
    stc                                                 ; [f9]
    db 0x33,0xF3                                   ; xor si, bx
    add al, 0xB5                                        ; [04 b5]

; ------------------------------------------------------------------------------
; DATA  image:0x461E .. 0x461E   1 bytes
; ------------------------------------------------------------------------------
data_461E:
    db 0xFF                                          ; 0x461E
    aas                                                 ; [3f]
    add byte [bx+si], al                                ; [00 00]
    cmp byte [bx-0x4F], 0x0                             ; [80 7f b1 00]
    jmp short 0x462E                                    ; [eb 06]
    mov cl, 0x2                                         ; [b1 02]
    jmp short 0x462E                                    ; [eb 02]
    mov cl, 0x4                                         ; [b1 04]
rtl_init_streams_l462E:
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x2]                               ; [8d 66 fe]
    wait                                                ; [9b]
    fnstsw word [bp-0x2]                                ; [dd 7e fe]
    wait                                                ; [9b]
    mov ah, byte [bp-0x1]                               ; [8a 66 ff]
    sahf                                                ; [9e]
    jb short 0x4651                                     ; [72 0f]
    jne short 0x4672                                    ; [75 2e]
    cmp cl, byte 0x2                                    ; [80 f9 02]
    jne short 0x464F                                    ; [75 06]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
rtl_init_streams_l464F:
    jmp short 0x466F                                    ; [eb 1e]
rtl_init_streams_l4651:
    je short 0x4661                                     ; [74 0e]
    jnp short 0x4661                                    ; [7b 0c]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fld dword [cs:0x3056]                               ; [2e d9 06 56 30]
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
rtl_init_streams_l4661:
    jmp short 0x466F                                    ; [eb 0c]
rtl_init_streams_l4663:
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
    wait                                                ; [9b]
    fld dword [cs:0x3056]                               ; [2e d9 06 56 30]
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
rtl_init_streams_l466F:
    jmp near 0x4719                                     ; [e9 a7 00]
rtl_init_streams_l4672:
    wait                                                ; [9b]
    fabs                                                ; [d9 e1]
    wait                                                ; [9b]
    fld tword [cs:0x3042]                               ; [2e db 2e 42 30]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fprem                                               ; [d9 f8]
    mov ch, 0x2                                         ; [b5 02]
    db 0x22,0xEC                                   ; and ch, ah
    shr ch, 0x1                                         ; [d0 ed]
    wait                                                ; [9b]
    fnstsw word [bp-0x2]                                ; [dd 7e fe]
    wait                                                ; [9b]
    mov ah, byte [bp-0x1]                               ; [8a 66 ff]
    sahf                                                ; [9e]
    jp short 0x4663                                     ; [7a d1]
    mov al, 0x3                                         ; [b0 03]
    db 0x22,0xC4                                   ; and al, ah
    shl ah, 0x1                                         ; [d0 e4]
    shl ah, 0x1                                         ; [d0 e4]
    rcl al, 0x1                                         ; [d0 d0]
    add al, 0xFC                                        ; [04 fc]
    rcl al, 0x1                                         ; [d0 d0]
    cmp cl, byte 0x2                                    ; [80 f9 02]
    jne short 0x46A9                                    ; [75 04]
    db 0x02,0xC1                                   ; add al, cl
    mov ch, 0x0                                         ; [b5 00]
rtl_init_streams_l46A9:
    and al, 0x7                                         ; [24 07]
    test al, 0x1                                        ; [a8 01]
    je short 0x46B4                                     ; [74 05]
    wait                                                ; [9b]
    fsubp st1                                           ; [de e9]
    jmp short 0x46B7                                    ; [eb 03]
rtl_init_streams_l46B4:
    wait                                                ; [9b]
    fstp st1                                            ; [dd d9]
rtl_init_streams_l46B7:
    wait                                                ; [9b]
    fptan                                               ; [d9 f2]
    cmp cl, byte 0x4                                    ; [80 f9 04]
    je short 0x46E8                                     ; [74 29]
    test al, 0x3                                        ; [a8 03]
    jp short 0x46C6                                     ; [7a 03]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
rtl_init_streams_l46C6:
    wait                                                ; [9b]
    fld st1                                             ; [d9 c1]
    wait                                                ; [9b]
    fmul st0                                            ; [d8 c8]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fmul st0                                            ; [d8 c8]
    wait                                                ; [9b]
    faddp st1                                           ; [de c1]
    wait                                                ; [9b]
    fsqrt                                               ; [d9 fa]
    shr al, 0x1                                         ; [d0 e8]
    shr al, 0x1                                         ; [d0 e8]
    db 0x32,0xC5                                   ; xor al, ch
    je short 0x46E3                                     ; [74 03]
    wait                                                ; [9b]
    fchs                                                ; [d9 e0]
rtl_init_streams_l46E3:
    wait                                                ; [9b]
    fdivp st1                                           ; [de f9]
    jmp short 0x4719                                    ; [eb 31]
rtl_init_streams_l46E8:
    db 0x8A,0xE0                                   ; mov ah, al
    shr ah, 0x1                                         ; [d0 ec]
    and ah, byte 0x1                                    ; [80 e4 01]
    db 0x32,0xE5                                   ; xor ah, ch
    je short 0x46F6                                     ; [74 03]
    wait                                                ; [9b]
    fchs                                                ; [d9 e0]
rtl_init_streams_l46F6:
    test al, 0x3                                        ; [a8 03]
    jp short 0x4716                                     ; [7a 1c]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
    wait                                                ; [9b]
    fnstsw word [bp-0x2]                                ; [dd 7e fe]
    wait                                                ; [9b]
    test byte [bp-0x1], 0x40                            ; [f6 46 ff 40]
    je short 0x4716                                     ; [74 0b]
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
    wait                                                ; [9b]
    fld dword [cs:0x3070]                               ; [2e d9 06 70 30]
    jmp short 0x4719                                    ; [eb 03]
rtl_init_streams_l4716:
    wait                                                ; [9b]
    fdivp st1                                           ; [de f9]
rtl_init_streams_l4719:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x2]                               ; [8d 66 fe]
    wait                                                ; [9b]
    fnstsw word [bp-0x2]                                ; [dd 7e fe]
    wait                                                ; [9b]
    mov ah, byte [bp-0x1]                               ; [8a 66 ff]
    sahf                                                ; [9e]
    xchg cx, ax                                         ; [91]
    jb short 0x4736                                     ; [72 04]
    jne short 0x4750                                    ; [75 1c]
    jmp short 0x4782                                    ; [eb 4c]
rtl_init_streams_l4736:
    je short 0x4782                                     ; [74 4a]
    jnp short 0x4782                                    ; [7b 48]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fld tword [cs:0x304C]                               ; [2e db 2e 4c 30]
    jmp short 0x477A                                    ; [eb 35]
rtl_init_streams_l4745:
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
    wait                                                ; [9b]
    fld tword [cs:0x3042]                               ; [2e db 2e 42 30]
    jmp short 0x477A                                    ; [eb 2a]
rtl_init_streams_l4750:
    wait                                                ; [9b]
    fabs                                                ; [d9 e1]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    fcom st1                                            ; [d8 d1]
    wait                                                ; [9b]
    fnstsw word [bp-0x2]                                ; [dd 7e fe]
    wait                                                ; [9b]
    mov ah, byte [bp-0x1]                               ; [8a 66 ff]
    sahf                                                ; [9e]
    je short 0x4745                                     ; [74 e1]
    jae short 0x4769                                    ; [73 03]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
rtl_init_streams_l4769:
    wait                                                ; [9b]
    fpatan                                              ; [d9 f3]
    jae short 0x477A                                    ; [73 0c]
    wait                                                ; [9b]
    fld tword [cs:0x304C]                               ; [2e db 2e 4c 30]
    wait                                                ; [9b]
    fsubp st1                                           ; [de e9]
    xor ch, byte 0x2                                    ; [80 f5 02]
rtl_init_streams_l477A:
    test ch, 0x2                                        ; [f6 c5 02]
    je short 0x4782                                     ; [74 03]
    wait                                                ; [9b]
    fchs                                                ; [d9 e0]
rtl_init_streams_l4782:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    jmp short 0x4793                                    ; [eb 08]
    wait                                                ; [9b]
    fldlg2                                              ; [d9 ec]
    jmp short 0x4793                                    ; [eb 03]
    wait                                                ; [9b]
    fldln2                                              ; [d9 ed]
rtl_init_streams_l4793:
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    lea sp, word [bp-0xA]                               ; [8d 66 f6]
    wait                                                ; [9b]
    fnstsw word [bp-0xA]                                ; [dd 7e f6]
    wait                                                ; [9b]
    mov ah, byte [bp-0x9]                               ; [8a 66 f7]
    sahf                                                ; [9e]
    jb short 0x47B6                                     ; [72 0c]
    je short 0x47B1                                     ; [74 05]
    test ah, 0x2                                        ; [f6 c4 02]
    je short 0x47C8                                     ; [74 17]
rtl_init_streams_l47B1:
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    jmp short 0x47BA                                    ; [eb 04]
rtl_init_streams_l47B6:
    je short 0x47C3                                     ; [74 0b]
    jnp short 0x47C3                                    ; [7b 09]
rtl_init_streams_l47BA:
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fld dword [cs:0x305A]                               ; [2e d9 06 5a 30]
rtl_init_streams_l47C3:
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
    jmp short 0x47EC                                    ; [eb 24]
rtl_init_streams_l47C8:
    wait                                                ; [9b]
    fld st0                                             ; [d9 c0]
    wait                                                ; [9b]
    fstp tword [bp-0xA]                                 ; [db 7e f6]
    wait                                                ; [9b]
    cmp word [bp-0x2], 0x3FFF                           ; [81 7e fe ff 3f]
    jne short 0x47E9                                    ; [75 12]
    cmp word [bp-0x4], 0x8000                           ; [81 7e fc 00 80]
    jne short 0x47E9                                    ; [75 0b]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    fsubp st1                                           ; [de e9]
    wait                                                ; [9b]
    fyl2xp1                                             ; [d9 f9]
    jmp short 0x47EC                                    ; [eb 03]
rtl_init_streams_l47E9:
    wait                                                ; [9b]
    fyl2x                                               ; [d9 f1]
rtl_init_streams_l47EC:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    wait                                                ; [9b]
    fldl2e                                              ; [d9 ea]
    mov cl, 0x1                                         ; [b1 01]
    jmp short 0x4802                                    ; [eb 0b]
    db 0x2B,0xC9                                   ; sub cx, cx
    jmp short 0x4802                                    ; [eb 07]
    wait                                                ; [9b]
    fldl2t                                              ; [d9 e9]
    mov cl, 0x1                                         ; [b1 01]
    jmp short 0x4802                                    ; [eb 00]
rtl_init_streams_l4802:
    jcxz 0x4807                                         ; [e3 03]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
rtl_init_streams_l4807:
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    lea sp, word [bp-0x6]                               ; [8d 66 fa]
    wait                                                ; [9b]
    fnstsw word [bp-0x6]                                ; [dd 7e fa]
    jcxz 0x4819                                         ; [e3 03]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
rtl_init_streams_l4819:
    wait                                                ; [9b]
    mov ah, byte [bp-0x5]                               ; [8a 66 fb]
    sahf                                                ; [9e]
    xchg bx, ax                                         ; [93]
    jb short 0x4831                                     ; [72 10]
    jne short 0x4849                                    ; [75 26]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    jcxz 0x482B                                         ; [e3 03]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
rtl_init_streams_l482B:
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    jmp near 0x48D8                                     ; [e9 a7 00]
rtl_init_streams_l4831:
    jcxz 0x4836                                         ; [e3 03]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
rtl_init_streams_l4836:
    je short 0x4843                                     ; [74 0b]
    jnp short 0x4843                                    ; [7b 09]
rtl_init_streams_l483A:
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fld dword [cs:0x305E]                               ; [2e d9 06 5e 30]
rtl_init_streams_l4843:
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
    jmp near 0x48D8                                     ; [e9 8f 00]
rtl_init_streams_l4849:
    jcxz 0x484E                                         ; [e3 03]
    wait                                                ; [9b]
    fmulp st1                                           ; [de c9]
rtl_init_streams_l484E:
    wait                                                ; [9b]
    fabs                                                ; [d9 e1]
    wait                                                ; [9b]
    fcom dword [cs:0x3062]                              ; [2e d8 16 62 30]
    wait                                                ; [9b]
    fnstsw word [bp-0x6]                                ; [dd 7e fa]
    wait                                                ; [9b]
    test byte [bp-0x5], 0x41                            ; [f6 46 fb 41]
    je short 0x486D                                     ; [74 0b]
    wait                                                ; [9b]
    f2xm1                                               ; [d9 f0]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    faddp st1                                           ; [de c1]
    jmp short 0x48CD                                    ; [eb 60]
rtl_init_streams_l486D:
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    fld st1                                             ; [d9 c1]
    wait                                                ; [9b]
    fnstcw word [bp-0x6]                                ; [d9 7e fa]
    wait                                                ; [9b]
    fscale                                              ; [d9 fd]
    or byte [bp-0x5], 0xF                               ; [80 4e fb 0f]
    wait                                                ; [9b]
    fldcw word [bp-0x6]                                 ; [d9 6e fa]
    wait                                                ; [9b]
    frndint                                             ; [d9 fc]
    and byte [bp-0x5], 0xF3                             ; [80 66 fb f3]
    wait                                                ; [9b]
    fldcw word [bp-0x6]                                 ; [d9 6e fa]
    wait                                                ; [9b]
    fist dword [bp-0x4]                                 ; [db 56 fc]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fchs                                                ; [d9 e0]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fscale                                              ; [d9 fd]
    wait                                                ; [9b]
    fstp st1                                            ; [dd d9]
    wait                                                ; [9b]
    fsubp st1                                           ; [de e9]
    cmp word [bp-0x2], 0x0                              ; [83 7e fe 00]
    jg short 0x483A                                     ; [7f 91]
    wait                                                ; [9b]
    f2xm1                                               ; [d9 f0]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    faddp st1                                           ; [de c1]
    shr word [bp-0x4], 0x1                              ; [d1 6e fc]
    jae short 0x48C0                                    ; [73 09]
    wait                                                ; [9b]
    fld tword [cs:0x3066]                               ; [2e db 2e 66 30]
    wait                                                ; [9b]
    fmulp st1                                           ; [de c9]
rtl_init_streams_l48C0:
    wait                                                ; [9b]
    fild word [bp-0x4]                                  ; [df 46 fc]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fscale                                              ; [d9 fd]
    wait                                                ; [9b]
    fstp st1                                            ; [dd d9]
rtl_init_streams_l48CD:
    test bh, 0x2                                        ; [f6 c7 02]
    je short 0x48D8                                     ; [74 06]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    fdivrp st1                                          ; [de f1]
rtl_init_streams_l48D8:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    ret                                                 ; [c3]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    push ax                                             ; [50]
    push si                                             ; [56]
    push ds                                             ; [1e]
    test byte [bp+0x7], 0x2                             ; [f6 46 07 02]
    je short 0x48E9                                     ; [74 01]
    sti                                                 ; [fb]
rtl_init_streams_l48E9:
    lds si,  [bp+0x2]                               ; [c5 76 02]
    mov ax, word [si-0x1]                               ; [8b 44 ff]
    sub al, 0x34                                        ; [2c 34]
    cmp al, 0x8                                         ; [3c 08]
    jae short 0x4901                                    ; [73 0c]
    sub si, byte 0x2                                    ; [83 ee 02]
    add word [si], 0xA3CE                               ; [81 04 ce a3]
rtl_init_streams_l48FC:
    mov word [bp+0x2], si                               ; [89 76 02]
    jmp short 0x4924                                    ; [eb 23]
rtl_init_streams_l4901:
    ja short 0x4929                                     ; [77 26]
    test ah, 0x20                                       ; [f6 c4 20]
    jne short 0x4936                                    ; [75 2e]
    sub si, byte 0x2                                    ; [83 ee 02]
    mov word [bp+0x2], si                               ; [89 76 02]
    mov byte [si], 0x9B                                 ; [c6 04 9b]
    inc si                                              ; [46]
    db 0x8A,0xC4                                   ; mov al, ah
    and ax, 0x7C0                                       ; [25 c0 07]
    shr al, 0x1                                         ; [d0 e8]
    shr al, 0x1                                         ; [d0 e8]
    shr al, 0x1                                         ; [d0 e8]
    xor al, 0x18                                        ; [34 18]
    add ax, 0xD826                                      ; [05 26 d8]
    mov word [si], ax                                   ; [89 04]
rtl_init_streams_l4924:
    pop ds                                              ; [1f]
    pop si                                              ; [5e]
    pop ax                                              ; [58]
    pop bp                                              ; [5d]
    iret                                                ; [cf]
rtl_init_streams_l4929:
    cmp al, 0x9                                         ; [3c 09]
    ja short 0x4936                                     ; [77 09]
    sub si, byte 0x2                                    ; [83 ee 02]
    mov word [si], 0x9B90                               ; [c7 04 90 9b]
    jmp short 0x48FC                                    ; [eb c6]
rtl_init_streams_l4936:
    jmp short 0x4924                                    ; [eb ec]
    into                                                ; [ce]
    db 0x33,0xE2                                   ; xor sp, dx
    db 0x33,0xF3                                   ; xor si, bx
    db 0x33,0xF8                                   ; xor di, ax
    xor bp, word [bx]                                   ; [33 2f]
    xor al, 0x41                                        ; [34 41]
    xor al, 0x4B                                        ; [34 4b]
    xor al, 0x50                                        ; [34 50]
    xor al, 0x74                                        ; [34 74]
    xor byte [bx+si+0x30], bh                           ; [30 78 30]
    jl short 0x497E                                     ; [7c 30]
    insw                                                ; [6d]
    xor ax, sp                                          ; [31 e0]
    xor si, dx                                          ; [31 d6]
    xor bx, bx                                          ; [31 db]
    xor word [bx+si+0x32], ax                           ; [31 40 32]
    inc di                                              ; [47]
    xor cl, byte [bp+di+0x32]                           ; [32 4b 32]
    sti                                                 ; [fb]
    cld                                                 ; [fc]
    push ax                                             ; [50]
    push si                                             ; [56]
    push es                                             ; [06]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les si,  [bp+0x8]                               ; [c4 76 08]
    es lodsw                                            ; [26 ad]
    mov word [bp+0x8], si                               ; [89 76 08]
    cmp al, 0xDC                                        ; [3c dc]
    jb short 0x4979                                     ; [72 09]
    db 0x8B,0xF0                                   ; mov si, ax
    db 0x98                                        ; cbw
    xchg si, ax                                         ; [96]
    call [cs:si+0x33AC]                                 ; [2e ff 94 ac 33]
rtl_init_streams_l4979:
    pop bp                                              ; [5d]
    pop es                                              ; [07]
    pop si                                              ; [5e]
    pop ax                                              ; [58]
    iret                                                ; [cf]
rtl_init_streams_l497E:
    dec ah                                              ; [fe cc]
    jl short 0x4990                                     ; [7c 0e]
    mov al, 0xA                                         ; [b0 0a]
    mul ah                                              ; [f6 e4]
    xchg si, ax                                         ; [96]
rtl_init_streams_l4987:
    wait                                                ; [9b]
    fstp tword [bp+si+0xE]                              ; [db 7a 0e]
    sub si, byte 0xA                                    ; [83 ee 0a]
    jge short 0x4987                                    ; [7d f7]
rtl_init_streams_l4990:
    wait                                                ; [9b]
    ret                                                 ; [c3]
    db 0x2B,0xF6                                   ; sub si, si
rtl_init_streams_l4994:
    dec ah                                              ; [fe cc]
    jl short 0x49A1                                     ; [7c 09]
    wait                                                ; [9b]
    fld tword [bp+si+0xE]                               ; [db 6a 0e]
    add si, byte 0xA                                    ; [83 c6 0a]
    jmp short 0x4994                                    ; [eb f3]
rtl_init_streams_l49A1:
    wait                                                ; [9b]
    ret                                                 ; [c3]
    mov al, 0x0                                         ; [b0 00]
    jmp short 0x49AA                                    ; [eb 03]
    nop                                                 ; [90]
    mov al, 0x1                                         ; [b0 01]
rtl_init_streams_l49AA:
    push bp                                             ; [55]
    push ax                                             ; [50]
    db 0x8B,0xEC                                   ; mov bp, sp
    wait                                                ; [9b]
    fnstcw word [bp]                                    ; [d9 7e 00]
    wait                                                ; [9b]
    mov si, word [bp]                                   ; [8b 76 00]
    and byte [bp+0x1], 0xFC                             ; [80 66 01 fc]
    or byte [bp+0x1], al                                ; [08 46 01]
    wait                                                ; [9b]
    fldcw word [bp]                                     ; [d9 6e 00]
    wait                                                ; [9b]
    fldz                                                ; [d9 ee]
    wait                                                ; [9b]
    fsub st2, st0                                       ; [dc ea]
    wait                                                ; [9b]
    faddp st1                                           ; [de c1]
    mov word [bp], si                                   ; [89 76 00]
    wait                                                ; [9b]
    fldcw word [bp]                                     ; [d9 6e 00]
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
    wait                                                ; [9b]
    fnstsw word [bp]                                    ; [dd 7e 00]
    wait                                                ; [9b]
    pop ax                                              ; [58]
    pop bp                                              ; [5d]
    mov byte [bp+0xC], ah                               ; [88 66 0c]
    ret                                                 ; [c3]
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
rtl_init_streams_l49E2:
    mov ah, byte [bp+0xD]                               ; [8a 66 0d]
    wait                                                ; [9b]
    fnstsw word [bp+0xC]                                ; [dd 7e 0c]
    wait                                                ; [9b]
    mov al, byte [bp+0xD]                               ; [8a 46 0d]
    mov word [bp+0xC], ax                               ; [89 46 0c]
    ret                                                 ; [c3]
    wait                                                ; [9b]
    fcomp st1                                           ; [d8 d9]
    jmp short 0x49E2                                    ; [eb ec]
    wait                                                ; [9b]
    fcom st1                                            ; [d8 d1]
    jmp short 0x49E2                                    ; [eb e7]
    wait                                                ; [9b]
    ftst                                                ; [d9 e4]
    jmp short 0x49E2                                    ; [eb e2]
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    wait                                                ; [9b]
    fnstsw word [bp+0x6]                                ; [dd 7e 06]
    wait                                                ; [9b]
    ret                                                 ; [c3]
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0x8B,0xDA                                   ; mov bx, dx

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_lmul   image offset 0x4A0D  <- called from 0x06E3, 0x0869, 0x09BD, 0x0B19, 0x0C51
; ------------------------------------------------------------------------------
rtl_lmul:
    db 0x8B,0xF0                                   ; mov si, ax
    db 0x8B,0xFA                                   ; mov di, dx
    mul cx                                              ; [f7 e1]
    push ax                                             ; [50]
    push dx                                             ; [52]
    db 0x8B,0xC6                                   ; mov ax, si
    mul bx                                              ; [f7 e3]
    db 0x8B,0xD8                                   ; mov bx, ax
    db 0x8B,0xC7                                   ; mov ax, di
    mul cx                                              ; [f7 e1]
    db 0x8B,0xC8                                   ; mov cx, ax
    pop dx                                              ; [5a]
    pop ax                                              ; [58]
    db 0x03,0xD3                                   ; add dx, bx
    db 0x03,0xD1                                   ; add dx, cx
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_ldiv   image offset 0x4A28  <- called from 0x527B
; ------------------------------------------------------------------------------
rtl_ldiv:
    push bp                                             ; [55]
    db 0x8B,0xE9                                   ; mov bp, cx
    db 0x0B,0xEB                                   ; or bp, bx
    je short 0x4A8F                                     ; [74 60]
    db 0x0B,0xDB                                   ; or bx, bx
    pushf                                               ; [9c]
    jns short 0x4A3E                                    ; [79 0a]
    not cx                                              ; [f7 d1]
    not bx                                              ; [f7 d3]
    add cx, byte 0x1                                    ; [83 c1 01]
    adc bx, byte 0x0                                    ; [83 d3 00]
rtl_ldiv_l4A3E:
    db 0x0B,0xD2                                   ; or dx, dx
    pushf                                               ; [9c]
    jns short 0x4A4D                                    ; [79 0a]
    not ax                                              ; [f7 d0]
    not dx                                              ; [f7 d2]
    add ax, strict word 0x1                             ; [05 01 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
rtl_ldiv_l4A4D:
    db 0x8B,0xF1                                   ; mov si, cx
    db 0x8B,0xFB                                   ; mov di, bx
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x33,0xDB                                   ; xor bx, bx
    mov bp, 0x21                                        ; [bd 21 00]
rtl_ldiv_l4A58:
    rcl cx, 0x1                                         ; [d1 d1]
    rcl bx, 0x1                                         ; [d1 d3]
    db 0x2B,0xCE                                   ; sub cx, si
    db 0x1B,0xDF                                   ; sbb bx, di
    jae short 0x4A66                                    ; [73 04]
    db 0x03,0xCE                                   ; add cx, si
    db 0x13,0xDF                                   ; adc bx, di
rtl_ldiv_l4A66:
    cmc                                                 ; [f5]
    rcl ax, 0x1                                         ; [d1 d0]
    rcl dx, 0x1                                         ; [d1 d2]
    dec bp                                              ; [4d]
    jne short 0x4A58                                    ; [75 ea]
    popf                                                ; [9d]
    jns short 0x4A80                                    ; [79 0f]
    not cx                                              ; [f7 d1]
    not bx                                              ; [f7 d3]
    add cx, byte 0x1                                    ; [83 c1 01]
    adc bx, byte 0x0                                    ; [83 d3 00]
    popf                                                ; [9d]
    jns short 0x4A83                                    ; [79 05]
    jmp short 0x4A8D                                    ; [eb 0d]
rtl_ldiv_l4A80:
    popf                                                ; [9d]
    jns short 0x4A8D                                    ; [79 0a]
rtl_ldiv_l4A83:
    not ax                                              ; [f7 d0]
    not dx                                              ; [f7 d2]
    add ax, strict word 0x1                             ; [05 01 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
rtl_ldiv_l4A8D:
    pop bp                                              ; [5d]
    retf                                                ; [cb]
rtl_ldiv_l4A8F:
    pop bp                                              ; [5d]
    mov ax, 0xC8                                        ; [b8 c8 00]
    jmp near 0x1692                                     ; [e9 fc cb]
    and cx, byte 0x1F                                   ; [83 e1 1f]
    je short 0x4AA1                                     ; [74 06]
rtl_ldiv_l4A9B:
    shr dx, 0x1                                         ; [d1 ea]
    rcr ax, 0x1                                         ; [d1 d8]
    loop 0x4A9B                                         ; [e2 fa]
rtl_ldiv_l4AA1:
    retf                                                ; [cb]
    and cx, byte 0x1F                                   ; [83 e1 1f]
    je short 0x4AAD                                     ; [74 06]
rtl_ldiv_l4AA7:
    shl ax, 0x1                                         ; [d1 e0]
    rcl dx, 0x1                                         ; [d1 d2]
    loop 0x4AA7                                         ; [e2 fa]
rtl_ldiv_l4AAD:
    retf                                                ; [cb]
    db 0x0B,0xD2                                   ; or dx, dx
    jge short 0x4ABC                                    ; [7d 0a]
    not ax                                              ; [f7 d0]
    not dx                                              ; [f7 d2]
    add ax, strict word 0x1                             ; [05 01 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
rtl_ldiv_l4ABC:
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_memcpy_far2   image offset 0x4ABD  <- called from 0x042D, 0x04CE, 0x0C8C, 0x0DD1, 0x0E30, 0x0E8B
; ------------------------------------------------------------------------------
rtl_memcpy_far2:
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    les di,  [ss:bx+0x8]                            ; [36 c4 7f 08]
    lds si,  [ss:bx+0x4]                            ; [36 c5 77 04]
    lodsb                                               ; [ac]
    stosb                                               ; [aa]
    db 0x8A,0xC8                                   ; mov cl, al
    db 0x32,0xED                                   ; xor ch, ch
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_memset_far   image offset 0x4AD7  <- called from 0x0060, 0x00CC, 0x039C, 0x040B, 0x0DAB
; ------------------------------------------------------------------------------
rtl_memset_far:
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    lds si,  [ss:bx+0xA]                            ; [36 c5 77 0a]
    les di,  [ss:bx+0x6]                            ; [36 c4 7f 06]
    mov cx, word [ss:bx+0x4]                            ; [36 8b 4f 04]
    lodsb                                               ; [ac]
    db 0x3A,0xC1                                   ; cmp al, cl
    jbe short 0x4AEF                                    ; [76 02]
    db 0x8A,0xC1                                   ; mov al, cl
rtl_memset_far_l4AEF:
    stosb                                               ; [aa]
    db 0x8A,0xC8                                   ; mov cl, al
    db 0x32,0xED                                   ; xor ch, ch
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0xA                                            ; [ca 0a 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    mov al, byte [es:di]                                ; [26 8a 05]
    db 0x32,0xE4                                   ; xor ah, ah
    retf 0x4                                            ; [ca 04 00]
rtl_memset_far_l4B09:
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    les di,  [ss:bx+0xC]                            ; [36 c4 7f 0c]
    lds si,  [ss:bx+0x8]                            ; [36 c5 77 08]
    mov al, byte [si]                                   ; [8a 04]
    db 0x32,0xE4                                   ; xor ah, ah
    mov cx, word [ss:bx+0x6]                            ; [36 8b 4f 06]
    db 0x0B,0xC9                                   ; or cx, cx
    jg short 0x4B25                                     ; [7f 03]
    mov cx, 0x1                                         ; [b9 01 00]
rtl_memset_far_l4B25:
    db 0x03,0xF1                                   ; add si, cx
    db 0x2B,0xC1                                   ; sub ax, cx
    jb short 0x4B3E                                     ; [72 13]
    inc ax                                              ; [40]
    mov cx, word [ss:bx+0x4]                            ; [36 8b 4f 04]
    db 0x0B,0xC9                                   ; or cx, cx
    jge short 0x4B36                                    ; [7d 02]
    db 0x33,0xC9                                   ; xor cx, cx
rtl_memset_far_l4B36:
    db 0x3B,0xC1                                   ; cmp ax, cx
    jbe short 0x4B40                                    ; [76 06]
    db 0x8B,0xC1                                   ; mov ax, cx
    jmp short 0x4B40                                    ; [eb 02]
rtl_memset_far_l4B3E:
    db 0x33,0xC0                                   ; xor ax, ax
rtl_memset_far_l4B40:
    stosb                                               ; [aa]
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0x8                                            ; [ca 08 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_memcmp_far   image offset 0x4B4A  <- called from 0x0437, 0x04D8, 0x0C96, 0x0DDB, 0x0DE5, 0x0E3A, 0x0E95, 0x0E9F
; ------------------------------------------------------------------------------
rtl_memcmp_far:
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    les di,  [ss:bx+0x8]                            ; [36 c4 7f 08]
    lds si,  [ss:bx+0x4]                            ; [36 c5 77 04]
    mov cl, byte [es:di]                                ; [26 8a 0d]
    db 0x32,0xED                                   ; xor ch, ch
    lodsb                                               ; [ac]
    add byte [es:di], al                                ; [26 00 05]
    jae short 0x4B6A                                    ; [73 08]
    mov byte [es:di], 0xFF                              ; [26 c6 05 ff]
    db 0x8A,0xC1                                   ; mov al, cl
    not al                                              ; [f6 d0]
rtl_memcmp_far_l4B6A:
    db 0x03,0xF9                                   ; add di, cx
    inc di                                              ; [47]
    db 0x8A,0xC8                                   ; mov cl, al
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0x4                                            ; [ca 04 00]
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    lds si,  [ss:bx+0x8]                            ; [36 c5 77 08]
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    mov cl, byte [es:di]                                ; [26 8a 0d]
    db 0x32,0xED                                   ; xor ch, ch
    jcxz 0x4BB2                                         ; [e3 29]
    inc di                                              ; [47]
    lodsb                                               ; [ac]
    cmp al, 0x1                                         ; [3c 01]
    jb short 0x4BB8                                     ; [72 29]
    ja short 0x4B99                                     ; [77 08]
    lodsb                                               ; [ac]
    db 0xF2,0xAE                                   ; repne scasb al, byte [es:di]
    jne short 0x4BB2                                    ; [75 1c]
    dec di                                              ; [4f]
    jmp short 0x4BB8                                    ; [eb 1f]
rtl_memcmp_far_l4B99:
    db 0x32,0xE4                                   ; xor ah, ah
    db 0x8B,0xD1                                   ; mov dx, cx
    db 0x2B,0xD0                                   ; sub dx, ax
    jb short 0x4BB2                                     ; [72 11]
    inc dx                                              ; [42]
rtl_memcmp_far_l4BA2:
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0xF3,0xA6                                   ; repe cmpsb byte [si], byte [es:di]
    je short 0x4BB6                                     ; [74 0e]
    db 0x2B,0xC8                                   ; sub cx, ax
    db 0x03,0xF1                                   ; add si, cx
    db 0x03,0xF9                                   ; add di, cx
    inc di                                              ; [47]
    dec dx                                              ; [4a]
    jne short 0x4BA2                                    ; [75 f0]
rtl_memcmp_far_l4BB2:
    db 0x33,0xC0                                   ; xor ax, ax
    jmp short 0x4BBE                                    ; [eb 08]
rtl_memcmp_far_l4BB6:
    db 0x2B,0xF8                                   ; sub di, ax
rtl_memcmp_far_l4BB8:
    db 0x8B,0xC7                                   ; mov ax, di
    sub ax, word [ss:bx+0x4]                            ; [36 2b 47 04]
rtl_memcmp_far_l4BBE:
    pop ds                                              ; [1f]
    retf 0x8                                            ; [ca 08 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_strcmp_far   image offset 0x4BC2  <- called from 0x0080
; ------------------------------------------------------------------------------
rtl_strcmp_far:
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    lds si,  [ss:bx+0x8]                            ; [36 c5 77 08]
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    lodsb                                               ; [ac]
    mov ah, byte [es:di]                                ; [26 8a 25]
    inc di                                              ; [47]
    db 0x8A,0xC8                                   ; mov cl, al
    db 0x3A,0xCC                                   ; cmp cl, ah
    jbe short 0x4BDC                                    ; [76 02]
    db 0x8A,0xCC                                   ; mov cl, ah
rtl_strcmp_far_l4BDC:
    db 0x0A,0xC9                                   ; or cl, cl
    je short 0x4BE6                                     ; [74 06]
    db 0x32,0xED                                   ; xor ch, ch
    db 0xF3,0xA6                                   ; repe cmpsb byte [si], byte [es:di]
    jne short 0x4BE8                                    ; [75 02]
rtl_strcmp_far_l4BE6:
    db 0x3A,0xC4                                   ; cmp al, ah
rtl_strcmp_far_l4BE8:
    mov ds, dx                                          ; [8e da]
    retf 0x8                                            ; [ca 08 00]
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x6]                            ; [36 c4 7f 06]
    mov al, 0x1                                         ; [b0 01]
    stosb                                               ; [aa]
    mov al, byte [ss:bx+0x4]                            ; [36 8a 47 04]
    stosb                                               ; [aa]
    retf 0x2                                            ; [ca 02 00]
    cld                                                 ; [fc]
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    les di,  [ss:bx+0xA]                            ; [36 c4 7f 0a]
    lds si,  [ss:bx+0x6]                            ; [36 c5 77 06]
    mov ax, word [ss:bx+0x4]                            ; [36 8b 47 04]
    stosb                                               ; [aa]
    db 0x8B,0xC8                                   ; mov cx, ax
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0x6                                            ; [ca 06 00]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    sub sp, word 0x200                                  ; [81 ec 00 02]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    dec ax                                              ; [48]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x4B09                                    ; [e8 d0 fe]
    les di,  [bp+0xE]                               ; [c4 7e 0e]
    push es                                             ; [06]
    push di                                             ; [57]
    push cs                                             ; [0e]
    call near 0x4B4A                                    ; [e8 08 ff]
    lea di, word [bp-0x200]                             ; [8d be 00 fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    push word [bp+0x6]                                  ; [ff 76 06]
    mov ax, 0xFF                                        ; [b8 ff 00]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x4B09                                    ; [e8 b1 fe]
    push cs                                             ; [0e]
    call near 0x4B4A                                    ; [e8 ee fe]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    push word [bp+0x8]                                  ; [ff 76 08]
    push cs                                             ; [0e]
    call near 0x4AD7                                    ; [e8 6f fe]
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    retf 0xC                                            ; [ca 0c 00]
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    sub sp, word 0x200                                  ; [81 ec 00 02]
    cmp word [bp+0x6], 0x0                              ; [83 7e 06 00]
    jle short 0x4CBE                                    ; [7e 43]
    lea di, word [bp-0x100]                             ; [8d be 00 ff]
    push ss                                             ; [16]
    push di                                             ; [57]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, 0x1                                         ; [b8 01 00]
    push ax                                             ; [50]
    mov ax, word [bp+0x8]                               ; [8b 46 08]
    dec ax                                              ; [48]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x4B09                                    ; [e8 76 fe]
    lea di, word [bp-0x200]                             ; [8d be 00 fe]
    push ss                                             ; [16]
    push di                                             ; [57]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, word [bp+0x8]                               ; [8b 46 08]
    add ax, word [bp+0x6]                               ; [03 46 06]
    push ax                                             ; [50]
    mov ax, 0xFF                                        ; [b8 ff 00]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x4B09                                    ; [e8 5c fe]
    push cs                                             ; [0e]
    call near 0x4B4A                                    ; [e8 99 fe]
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    push es                                             ; [06]
    push di                                             ; [57]
    mov ax, 0xFF                                        ; [b8 ff 00]
    push ax                                             ; [50]
    push cs                                             ; [0e]
    call near 0x4AD7                                    ; [e8 19 fe]
rtl_strcmp_far_l4CBE:
    db 0x8B,0xE5                                   ; mov sp, bp
    pop bp                                              ; [5d]
    retf 0x8                                            ; [ca 08 00]
    aas                                                 ; [3f]
    pop ds                                              ; [1f]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si+0x7FFF], al                         ; [00 80 ff 7f]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_get_psp   image offset 0x4CD0  <- called from 0x1FA6
; ------------------------------------------------------------------------------
rtl_get_psp:
    mov bx, 0xFFD4                                      ; [bb d4 ff]
    db 0x33,0xFF                                   ; xor di, di
    mov es, word [psp_seg]                              ; [8e 06 86 00]
    mov es, word [es:0x2C]                              ; [26 8e 06 2c 00]
    mov cx, 0x7FFF                                      ; [b9 ff 7f]
    cld                                                 ; [fc]
rtl_get_psp_l4CE2:
    mov ax, word [es:di]                                ; [26 8b 05]
    db 0x0A,0xC0                                   ; or al, al
    je short 0x4D04                                     ; [74 1b]
    cmp ax, 0x3738                                      ; [3d 38 37]
    jne short 0x4CFE                                    ; [75 10]
    mov ax, word [es:di+0x2]                            ; [26 8b 45 02]
    cmp al, 0x3D                                        ; [3c 3d]
    jne short 0x4CFE                                    ; [75 08]
    and ah, byte 0xDF                                   ; [80 e4 df]
    cmp ah, byte 0x59                                   ; [80 fc 59]
    jmp short 0x4D1B                                    ; [eb 1d]
rtl_get_psp_l4CFE:
    db 0x33,0xC0                                   ; xor ax, ax
    db 0xF2,0xAE                                   ; repne scasb al, byte [es:di]
    je short 0x4CE2                                     ; [74 de]
rtl_get_psp_l4D04:
    db 0x33,0xC0                                   ; xor ax, ax
    out 0xF0, al                                        ; [e6 f0]
    fninit                                              ; [db e3]
    mov word [bx], ax                                   ; [89 07]
    fnstcw word [bx]                                    ; [d9 3f]
    mov cx, 0x14                                        ; [b9 14 00]
rtl_get_psp_l4D11:
    loop 0x4D11                                         ; [e2 fe]
    mov ax, word [bx]                                   ; [8b 07]
    and ax, 0xF3F                                       ; [25 3f 0f]
    cmp ax, 0x33F                                       ; [3d 3f 03]
rtl_get_psp_l4D1B:
    mov dx, 0x1330                                      ; [ba 30 13]
    mov al, 0x0                                         ; [b0 00]
    jne short 0x4D4F                                    ; [75 2d]
    push sp                                             ; [54]
    pop ax                                              ; [58]
    db 0x3B,0xC4                                   ; cmp ax, sp
    mov al, 0x1                                         ; [b0 01]
    jne short 0x4D4F                                    ; [75 25]
    wait                                                ; [9b]
    fninit                                              ; [db e3]
    wait                                                ; [9b]
    fld1                                                ; [d9 e8]
    wait                                                ; [9b]
    fldz                                                ; [d9 ee]
    wait                                                ; [9b]
    fdivp st1                                           ; [de f9]
    wait                                                ; [9b]
    fld st0                                             ; [d9 c0]
    wait                                                ; [9b]
    fchs                                                ; [d9 e0]
    wait                                                ; [9b]
    fcompp                                              ; [de d9]
    wait                                                ; [9b]
    fnstsw word [bx]                                    ; [dd 3f]
    wait                                                ; [9b]
    mov ax, word [bx]                                   ; [8b 07]
    sahf                                                ; [9e]
    mov al, 0x2                                         ; [b0 02]
    je short 0x4D4F                                     ; [74 05]

; ------------------------------------------------------------------------------
; DATA  image:0x4D4A .. 0x4D4A   1 bytes
; ------------------------------------------------------------------------------
data_4D4A:
    db 0xBA                                          ; 0x4D4A
rtl_get_psp_l4D4B:
    xor dl, byte [bp+di]                                ; [32 13]
    mov al, 0x3                                         ; [b0 03]
rtl_get_psp_l4D4F:
    mov byte [0x0091], al                               ; [a2 91 00]
    mov word [-0x2E], dx                                ; [89 16 d2 ff]
    ret                                                 ; [c3]
rtl_get_psp_l4D57:
    push ds                                             ; [1e]
    push cs                                             ; [0e]
    pop ds                                              ; [1f]
    mov ax, 0x2534                                      ; [b8 34 25]
    mov cx, 0xA                                         ; [b9 0a 00]
    db 0x8B,0xD6                                   ; mov dx, si
rtl_get_psp_l4D62:
    int 0x21                                            ; [cd 21]
    inc ax                                              ; [40]
    loop 0x4D62                                         ; [e2 fb]
    db 0x8B,0xD7                                   ; mov dx, di
    int 0x21                                            ; [cd 21]
    mov dx, 0x37DF                                      ; [ba df 37]
    mov al, 0x2                                         ; [b0 02]
    int 0x21                                            ; [cd 21]
    mov dx, 0x37D3                                      ; [ba d3 37]
    mov al, 0x75                                        ; [b0 75]
    int 0x21                                            ; [cd 21]
    pop ds                                              ; [1f]
    int 0x37                                            ; [cd 37]
    jcxz 0x4D4B                                         ; [e3 cd]
    xor ax, 0xD22E                                      ; [35 2e d2]
    db 0xFF,0xCB                                   ; dec bx
    push ax                                             ; [50]
    db 0x32,0xC0                                   ; xor al, al
    out 0xF0, al                                        ; [e6 f0]
    mov al, 0x20                                        ; [b0 20]
    out 0xA0, al                                        ; [e6 a0]
    out 0x20, al                                        ; [e6 20]
    pop ax                                              ; [58]
    push ax                                             ; [50]
    push ds                                             ; [1e]
    mov ax, 0x53C                                       ; [b8 3c 05]
    mov ds, ax                                          ; [8e d8]
    cmp byte [0x0091], 0x0                              ; [80 3e 91 00 00]
    jne short 0x4DA4                                    ; [75 07]
    int 0x35                                            ; [cd 35]
    ss fdivr st7                                        ; [36 d8 ff]
    jmp short 0x4DA9                                    ; [eb 05]
rtl_get_psp_l4DA4:
    fnstenv [-0x28]                                     ; [d9 36 d8 ff]
    wait                                                ; [9b]
rtl_get_psp_l4DA9:
    mov al, byte [0xFFD8]                               ; [a0 d8 ff]
    not al                                              ; [f6 d0]
    and al, byte [-0x26]                                ; [22 06 da ff]
    js short 0x4DBC                                     ; [78 08]
    pushf                                               ; [9c]
    db 0xFF,0x1E,0x88,0xFF                         ; call dword [-0x78]
    pop ds                                              ; [1f]
    pop ax                                              ; [58]
    iret                                                ; [cf]
rtl_get_psp_l4DBC:
    sti                                                 ; [fb]
    test al, 0x3D                                       ; [a8 3d]
    je short 0x4E08                                     ; [74 47]
    int 0x37                                            ; [cd 37]
    jcxz 0x4D92                                         ; [e3 cd]
    xor ax, 0xD22E                                      ; [35 2e d2]
    db 0xFF,0x59,0x59                              ; call dword [bx+di+0x59]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    cmp bx, word 0x15B                                  ; [81 fb 5b 01]
    jne short 0x4DD6                                    ; [75 03]
    pop cx                                              ; [59]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
rtl_get_psp_l4DD6:
    db 0x8B,0xD1                                   ; mov dx, cx
    db 0x0B,0xD3                                   ; or dx, bx
    jne short 0x4DDE                                    ; [75 02]
    dec cx                                              ; [49]
    dec bx                                              ; [4b]
rtl_get_psp_l4DDE:
    test al, 0x1                                        ; [a8 01]
    jne short 0x4DF7                                    ; [75 15]
    mov dx, 0xC8                                        ; [ba c8 00]
    test al, 0x4                                        ; [a8 04]
    jne short 0x4DFA                                    ; [75 11]
    mov dx, 0xCD                                        ; [ba cd 00]
    test al, 0x8                                        ; [a8 08]
    jne short 0x4DFA                                    ; [75 0a]
    mov dx, 0xCE                                        ; [ba ce 00]
    test al, 0x10                                       ; [a8 10]
    jne short 0x4DFA                                    ; [75 03]
rtl_get_psp_l4DF7:
    mov dx, 0xCF                                        ; [ba cf 00]
rtl_get_psp_l4DFA:
    xchg dx, ax                                         ; [92]
    jmp near 0x169D                                     ; [e9 9f c8]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fpu_init   image offset 0x4DFE  <- called from 0x4E54, 0x4E60
; ------------------------------------------------------------------------------
rtl_fpu_init:
    push ds                                             ; [1e]
    lds bx,  [-0x1E]                                ; [c5 1e e2 ff]
    wait                                                ; [9b]
    nop                                                 ; [90]
    nop                                                 ; [90]
    pop ds                                              ; [1f]
    ret                                                 ; [c3]
rtl_fpu_init_l4E08:
    push bx                                             ; [53]
    mov ax, word [0xFFE0]                               ; [a1 e0 ff]
    db 0x8A,0xD8                                   ; mov bl, al
    and bl, byte 0xC0                                   ; [80 e3 c0]
    cmp bl, byte 0xC0                                   ; [80 fb c0]
    je short 0x4E1A                                     ; [74 04]
    and al, 0x38                                        ; [24 38]
    or al, 0x7                                          ; [0c 07]
rtl_fpu_init_l4E1A:
    db 0x86, 0xC4                                       ; xchg al, ah
    and al, 0x7                                         ; [24 07]
    or al, 0xD8                                         ; [0c d8]
    mov word [cs:0x3854], ax                            ; [2e a3 54 38]
    cmp ax, 0x7D9                                       ; [3d d9 07]
    je short 0x4E79                                     ; [74 50]
    cmp ax, 0x7DD                                       ; [3d dd 07]
    je short 0x4E79                                     ; [74 4b]
    cmp ax, 0x2FDB                                      ; [3d db 2f]
    je short 0x4E79                                     ; [74 46]
    cmp ax, 0x17D8                                      ; [3d d8 17]
    je short 0x4E7C                                     ; [74 44]
    cmp ax, 0x17DC                                      ; [3d dc 17]
    je short 0x4E7C                                     ; [74 3f]
    cmp ax, 0x1FD8                                      ; [3d d8 1f]
    je short 0x4E7C                                     ; [74 3a]
    cmp ax, 0x1FDC                                      ; [3d dc 1f]
    je short 0x4E7C                                     ; [74 35]
    cmp ax, 0x37D8                                      ; [3d d8 37]
    je short 0x4E59                                     ; [74 0d]
    cmp ax, 0x37DC                                      ; [3d dc 37]
    je short 0x4E59                                     ; [74 08]
    wait                                                ; [9b]
    fnclex                                              ; [db e2]
    call near 0x4DFE                                    ; [e8 a7 ff]
    jmp short 0x4E6C                                    ; [eb 13]
rtl_fpu_init_l4E59:
    sub word [cs:0x3854], 0x2FFF                        ; [2e 81 2e 54 38 ff 2f]
    call near 0x4DFE                                    ; [e8 9b ff]
    call near 0x4E8D                                    ; [e8 27 00]
    wait                                                ; [9b]
    fnclex                                              ; [db e2]
    wait                                                ; [9b]
    fdivp st1                                           ; [de f9]
rtl_fpu_init_l4E6C:
    wait                                                ; [9b]
    fnstsw word [-0x2C]                                 ; [dd 3e d4 ff]
    wait                                                ; [9b]
    mov al, byte [0xFFD4]                               ; [a0 d4 ff]
    or byte [-0x26], al                                 ; [08 06 da ff]
rtl_fpu_init_l4E79:
    call near 0x4E8D                                    ; [e8 11 00]
rtl_fpu_init_l4E7C:
    wait                                                ; [9b]
    fnclex                                              ; [db e2]
    and byte [-0x26], 0xFD                              ; [80 26 da ff fd]
    wait                                                ; [9b]
    fldenv [-0x28]                                      ; [d9 26 d8 ff]
    pop bx                                              ; [5b]
    pop ds                                              ; [1f]
    pop ax                                              ; [58]
    iret                                                ; [cf]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fpu_status   image offset 0x4E8D  <- called from 0x4E63, 0x4E79
; ------------------------------------------------------------------------------
rtl_fpu_status:
    wait                                                ; [9b]
    fxam                                                ; [d9 e5]
    wait                                                ; [9b]
    fnstsw word [-0x2C]                                 ; [dd 3e d4 ff]
    wait                                                ; [9b]
    mov ax, word [0xFFD4]                               ; [a1 d4 ff]
    test ax, 0x4500                                     ; [a9 00 45]
    je short 0x4EAF                                     ; [74 11]
    test ax, 0x4000                                     ; [a9 00 40]
    je short 0x4EBE                                     ; [74 1b]
    test ax, 0x400                                      ; [a9 00 04]
    je short 0x4EBE                                     ; [74 16]
    wait                                                ; [9b]
    fstp st0                                            ; [dd d8]
    wait                                                ; [9b]
    fldz                                                ; [d9 ee]
    ret                                                 ; [c3]
rtl_fpu_status_l4EAF:
    wait                                                ; [9b]
    fld tword [cs:0x3716]                               ; [2e db 2e 16 37]
    wait                                                ; [9b]
    fxch st0, st1                                       ; [d9 c9]
    wait                                                ; [9b]
    fprem                                               ; [d9 f8]
    wait                                                ; [9b]
    fstp st1                                            ; [dd d9]
rtl_fpu_status_l4EBE:
    ret                                                 ; [c3]
    db 0x0A,0xC0                                   ; or al, al
    je short 0x4EE5                                     ; [74 22]
    db 0x32,0xC9                                   ; xor cl, cl
    db 0x8A,0xEC                                   ; mov ch, ah
    db 0x8A,0xE6                                   ; mov ah, dh
    and ah, byte 0x80                                   ; [80 e4 80]
    add ax, 0x3F7E                                      ; [05 7e 3f]
    or dh, byte 0x80                                    ; [80 ce 80]
    push ax                                             ; [50]
    push dx                                             ; [52]
    push bx                                             ; [53]
    push cx                                             ; [51]
    db 0x33,0xC9                                   ; xor cx, cx
    push cx                                             ; [51]
    db 0x8B,0xDC                                   ; mov bx, sp
    int 0x3C                                            ; [cd 3c]
    pop bx                                              ; [5b]
    das                                                 ; [2f]
    int 0x3D                                            ; [cd 3d]
    add sp, byte 0xA                                    ; [83 c4 0a]
    retf                                                ; [cb]
rtl_fpu_status_l4EE5:
    int 0x35                                            ; [cd 35]
    out dx, al                                          ; [ee]
    retf                                                ; [cb]
    sub sp, byte 0xA                                    ; [83 ec 0a]
    db 0x8B,0xDC                                   ; mov bx, sp
    int 0x3C                                            ; [cd 3c]
    pop bx                                              ; [5b]
    aas                                                 ; [3f]
    int 0x3D                                            ; [cd 3d]
    add sp, byte 0x2                                    ; [83 c4 02]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    pop dx                                              ; [5a]
    pop ax                                              ; [58]
    db 0x8B,0xF8                                   ; mov di, ax
    and ax, 0x7FFF                                      ; [25 ff 7f]
    sub ax, 0x3F7E                                      ; [2d 7e 3f]
    jbe short 0x4F1F                                    ; [76 1a]
    db 0x0A,0xE4                                   ; or ah, ah
    jne short 0x4F2A                                    ; [75 21]
    db 0x8A,0xE5                                   ; mov ah, ch
    shl cl, 0x1                                         ; [d0 e1]
    adc ah, byte 0x0                                    ; [80 d4 00]
    adc bx, byte 0x0                                    ; [83 d3 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
    jb short 0x4F26                                     ; [72 0e]
rtl_fpu_status_l4F18:
    shl dx, 0x1                                         ; [d1 e2]
    shl di, 0x1                                         ; [d1 e7]
    rcr dx, 0x1                                         ; [d1 da]
    retf                                                ; [cb]
rtl_fpu_status_l4F1F:
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x33,0xDB                                   ; xor bx, bx
    db 0x33,0xD2                                   ; xor dx, dx
    retf                                                ; [cb]
rtl_fpu_status_l4F26:
    inc al                                              ; [fe c0]
    jne short 0x4F18                                    ; [75 ee]
rtl_fpu_status_l4F2A:
    mov ax, 0xCD                                        ; [b8 cd 00]
    jmp near 0x1692                                     ; [e9 62 c7]
    int 0x35                                            ; [cd 35]
    ds fdivr st7                                        ; [3e d8 ff]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    cs adc al, 0x37                                     ; [2e 14 37]
    int 0x37                                            ; [cd 37]
    push ds                                             ; [1e]
    aam 0xFF                                            ; [d4 ff]
    int 0x35                                            ; [cd 35]
    cs fdivr st7                                        ; [2e d8 ff]
    mov ax, word [0xFFD4]                               ; [a1 d4 ff]
    mov dx, word [-0x2A]                                ; [8b 16 d6 ff]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fpu_int   image offset 0x4F4D  <- called from 0x0669, 0x0A6C, 0x0BC5
; ------------------------------------------------------------------------------
rtl_fpu_int:
    int 0x37                                            ; [cd 37]
    push ds                                             ; [1e]
    aam 0xFF                                            ; [d4 ff]
    int 0x3D                                            ; [cd 3d]
    mov ax, word [0xFFD4]                               ; [a1 d4 ff]
    mov dx, word [-0x2A]                                ; [8b 16 d6 ff]
    retf                                                ; [cb]
    int 0x35                                            ; [cd 35]
    ds fdivr st7                                        ; [3e d8 ff]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    cs adc al, 0x37                                     ; [2e 14 37]
    int 0x35                                            ; [cd 35]
    cld                                                 ; [fc]
    int 0x35                                            ; [cd 35]
    cs fdivr st7                                        ; [2e d8 ff]
    retf                                                ; [cb]
    int 0x35                                            ; [cd 35]
    ds fdivr st7                                        ; [3e d8 ff]
    int 0x3C                                            ; [cd 3c]
    db 0x99                                        ; cwd
    cs adc al, 0x37                                     ; [2e 14 37]
    int 0x35                                            ; [cd 35]
    ror ch, 0x35                                        ; [c0 cd 35]
    cld                                                 ; [fc]
    int 0x3A                                            ; [cd 3a]
    jmp near 0x8553                                     ; [e9 cd 35]
    cs fdivr st7                                        ; [2e d8 ff]
    retf                                                ; [cb]
    int 0x35                                            ; [cd 35]
    cli                                                 ; [fa]
    retf                                                ; [cb]
    int 0x3E                                            ; [cd 3e]
    in al, dx                                           ; [ec]
    nop                                                 ; [90]
    retf                                                ; [cb]
    int 0x3E                                            ; [cd 3e]
    out dx, al                                          ; [ee]
    nop                                                 ; [90]
    retf                                                ; [cb]
    int 0x3E                                            ; [cd 3e]
    repne nop                                           ; [f2 90]
    retf                                                ; [cb]
    int 0x3E                                            ; [cd 3e]
    hlt                                                 ; [f4]
    nop                                                 ; [90]
    retf                                                ; [cb]
    int 0x3E                                            ; [cd 3e]
    cli                                                 ; [fa]
    nop                                                 ; [90]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_shift_signed   image offset 0x4FA7  <- called from 0x1F6E
; ------------------------------------------------------------------------------
rtl_shift_signed:
    push di                                             ; [57]
    cld                                                 ; [fc]
    db 0x8B,0xD8                                   ; mov bx, ax
    db 0x0B,0xD2                                   ; or dx, dx
    jge short 0x4FBC                                    ; [7d 0d]
    not bx                                              ; [f7 d3]
    not dx                                              ; [f7 d2]
    add bx, byte 0x1                                    ; [83 c3 01]
    adc dx, byte 0x0                                    ; [83 d2 00]
    mov al, 0x2D                                        ; [b0 2d]
    stosb                                               ; [aa]
rtl_shift_signed_l4FBC:
    mov si, 0x3A49                                      ; [be 49 3a]
    mov cl, 0x9                                         ; [b1 09]
rtl_shift_signed_l4FC1:
    cmp dx, word [cs:si+0x2]                            ; [2e 3b 54 02]
    jb short 0x4FCE                                     ; [72 07]
    ja short 0x4FD5                                     ; [77 0c]
    cmp bx, word [cs:si]                                ; [2e 3b 1c]
    jae short 0x4FD5                                    ; [73 07]
rtl_shift_signed_l4FCE:
    add si, byte 0x4                                    ; [83 c6 04]
    dec cl                                              ; [fe c9]
    jne short 0x4FC1                                    ; [75 ec]
rtl_shift_signed_l4FD5:
    inc cl                                              ; [fe c1]
rtl_shift_signed_l4FD7:
    mov al, 0x2F                                        ; [b0 2f]
rtl_shift_signed_l4FD9:
    inc al                                              ; [fe c0]
    sub bx, word [cs:si]                                ; [2e 2b 1c]
    sbb dx, word [cs:si+0x2]                            ; [2e 1b 54 02]
    jae short 0x4FD9                                    ; [73 f5]
    add bx, word [cs:si]                                ; [2e 03 1c]
    adc dx, word [cs:si+0x2]                            ; [2e 13 54 02]
    add si, byte 0x4                                    ; [83 c6 04]
    stosb                                               ; [aa]
    dec cl                                              ; [fe c9]
    jne short 0x4FD7                                    ; [75 e4]
    db 0x8B,0xCF                                   ; mov cx, di
    pop di                                              ; [5f]
    db 0x2B,0xCF                                   ; sub cx, di
    ret                                                 ; [c3]
    add dl, cl                                          ; [00 ca]
    call 0xF5E1:0x3B                                    ; [9a 3b 00 e1 f5]
    add ax, 0x9680                                      ; [05 80 96]
    db 0x98                                        ; cbw
    add byte [bx+si+0x42], al                           ; [00 40 42]
    verr word [bx+si+0x186]                             ; [0f 00 a0 86 01]
    add byte [bx+si], dl                                ; [00 10]
    daa                                                 ; [27]
    add byte [bx+si], al                                ; [00 00]
    call near 0x5017                                    ; [e8 03 00]
    db 0x00,0x64,0x00                              ; add byte [si], ah
rtl_shift_signed_l5017:
    add byte [bx+si], al                                ; [00 00]
    or al, byte [bx+si]                                 ; [0a 00]
    add byte [bx+si], al                                ; [00 00]
    add word [bx+si], ax                                ; [01 00]
    add byte [bx+si], al                                ; [00 00]
rtl_shift_signed_l5021:
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x33,0xD2                                   ; xor dx, dx
    db 0x33,0xF6                                   ; xor si, si
    jcxz 0x5082                                         ; [e3 59]
    cmp byte [es:di], 0x2B                              ; [26 80 3d 2b]
    je short 0x5036                                     ; [74 07]
    cmp byte [es:di], 0x2D                              ; [26 80 3d 2d]
    jne short 0x503A                                    ; [75 05]
    inc si                                              ; [46]
rtl_shift_signed_l5036:
    inc di                                              ; [47]
    dec cx                                              ; [49]
    jcxz 0x5082                                         ; [e3 48]
rtl_shift_signed_l503A:
    cmp byte [es:di], 0x24                              ; [26 80 3d 24]
    je short 0x5084                                     ; [74 44]
rtl_shift_signed_l5040:
    mov bl, byte [es:di]                                ; [26 8a 1d]
    sub bl, byte 0x3A                                   ; [80 eb 3a]
    add bl, byte 0xA                                    ; [80 c3 0a]
    jae short 0x5073                                    ; [73 28]
    test dx, 0xF000                                     ; [f7 c2 00 f0]
    jne short 0x5082                                    ; [75 31]
    push bx                                             ; [53]
    shl ax, 0x1                                         ; [d1 e0]
    rcl dx, 0x1                                         ; [d1 d2]
    push dx                                             ; [52]
    push ax                                             ; [50]
    shl ax, 0x1                                         ; [d1 e0]
    rcl dx, 0x1                                         ; [d1 d2]
    shl ax, 0x1                                         ; [d1 e0]
    rcl dx, 0x1                                         ; [d1 d2]
    pop bx                                              ; [5b]
    db 0x03,0xC3                                   ; add ax, bx
    pop bx                                              ; [5b]
    db 0x13,0xD3                                   ; adc dx, bx
    pop bx                                              ; [5b]
    db 0x32,0xFF                                   ; xor bh, bh
    db 0x03,0xC3                                   ; add ax, bx
    adc dx, byte 0x0                                    ; [83 d2 00]
    js short 0x5082                                     ; [78 12]
    inc di                                              ; [47]
    loop 0x5040                                         ; [e2 cd]
rtl_shift_signed_l5073:
    dec si                                              ; [4e]
    jne short 0x5080                                    ; [75 0a]
    not ax                                              ; [f7 d0]
    not dx                                              ; [f7 d2]
    add ax, strict word 0x1                             ; [05 01 00]
    adc dx, byte 0x0                                    ; [83 d2 00]
rtl_shift_signed_l5080:
    clc                                                 ; [f8]
    ret                                                 ; [c3]
rtl_shift_signed_l5082:
    stc                                                 ; [f9]
    ret                                                 ; [c3]
rtl_shift_signed_l5084:
    inc di                                              ; [47]
    dec cx                                              ; [49]
    jcxz 0x5082                                         ; [e3 fa]
rtl_shift_signed_l5088:
    mov bl, byte [es:di]                                ; [26 8a 1d]
    cmp bl, byte 0x61                                   ; [80 fb 61]
    jb short 0x5093                                     ; [72 03]
    sub bl, byte 0x20                                   ; [80 eb 20]
rtl_shift_signed_l5093:
    sub bl, byte 0x3A                                   ; [80 eb 3a]
    add bl, byte 0xA                                    ; [80 c3 0a]
    jb short 0x50A6                                     ; [72 0b]
    sub bl, byte 0x17                                   ; [80 eb 17]
    add bl, byte 0x6                                    ; [80 c3 06]
    jae short 0x5073                                    ; [73 d0]
    add bl, byte 0xA                                    ; [80 c3 0a]
rtl_shift_signed_l50A6:
    mov bh, 0x4                                         ; [b7 04]
rtl_shift_signed_l50A8:
    shl ax, 0x1                                         ; [d1 e0]
    rcl dx, 0x1                                         ; [d1 d2]
    jb short 0x5082                                     ; [72 d4]
    dec bh                                              ; [fe cf]
    jne short 0x50A8                                    ; [75 f6]
    db 0x0A,0xC3                                   ; or al, bl
    inc di                                              ; [47]
    loop 0x5088                                         ; [e2 d1]
    jmp short 0x5073                                    ; [eb ba]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fread_buf   image offset 0x50B9  <- called from 0x04DD, 0x0C9B, 0x0DEA, 0x0EA4
; ------------------------------------------------------------------------------
rtl_fread_buf:
    db 0x8B,0xDC                                   ; mov bx, sp
    push ds                                             ; [1e]
    les di,  [ss:bx+0x8]                            ; [36 c4 7f 08]
    lds si,  [ss:bx+0x4]                            ; [36 c5 77 04]
    cld                                                 ; [fc]
    db 0x33,0xC0                                   ; xor ax, ax
    stosw                                               ; [ab]
    mov ax, 0xD7B0                                      ; [b8 b0 d7]
    stosw                                               ; [ab]
    db 0x33,0xC0                                   ; xor ax, ax
    mov cx, 0x16                                        ; [b9 16 00]
    db 0xF3,0xAB                                   ; rep stosw word [es:di], ax
    lodsb                                               ; [ac]
    cmp al, 0x4F                                        ; [3c 4f]
    jbe short 0x50DA                                    ; [76 02]
    mov al, 0x4F                                        ; [b0 4f]
rtl_fread_buf_l50DA:
    db 0x8A,0xC8                                   ; mov cl, al
    db 0x32,0xED                                   ; xor ch, ch
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    db 0x32,0xC0                                   ; xor al, al
    stosb                                               ; [aa]
    pop ds                                              ; [1f]
    retf 0x8                                            ; [ca 08 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_read_handle   image offset 0x50E7  <- called from 0x04EB, 0x0DF8, 0x0EB2
; ------------------------------------------------------------------------------
rtl_read_handle:
    mov al, byte [0x0090]                               ; [a0 90 00]
    mov ah, 0x3D                                        ; [b4 3d]
    db 0x33,0xD2                                   ; xor dx, dx
    jmp short 0x50F6                                    ; [eb 06]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_write_handle   image offset 0x50F0  <- called from 0x0CA9
; ------------------------------------------------------------------------------
rtl_write_handle:
    mov ax, 0x3C00                                      ; [b8 00 3c]
    mov dx, 0x1                                         ; [ba 01 00]
rtl_write_handle_l50F6:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x8]                               ; [c4 7e 08]
    cmp word [es:di+0x2], 0xD7B0                        ; [26 81 7d 02 b0 d7]
    je short 0x511E                                     ; [74 1a]
    cmp word [es:di+0x2], 0xD7B3                        ; [26 81 7d 02 b3 d7]
    je short 0x5114                                     ; [74 08]
    mov word [dos_errno], 0x66                          ; [c7 06 8a 00 66 00]
    jmp short 0x5148                                    ; [eb 34]
rtl_write_handle_l5114:
    push ax                                             ; [50]
    push dx                                             ; [52]
    push es                                             ; [06]
    push di                                             ; [57]
    push cs                                             ; [0e]
    call near 0x5168                                    ; [e8 4c 00]
    pop dx                                              ; [5a]
    pop ax                                              ; [58]
rtl_write_handle_l511E:
    cmp byte [es:di+0x30], 0x0                          ; [26 80 7d 30 00]
    je short 0x5137                                     ; [74 12]
    push ds                                             ; [1e]
    lea dx, word [di+0x30]                              ; [8d 55 30]
    push es                                             ; [06]
    pop ds                                              ; [1f]
    db 0x33,0xC9                                   ; xor cx, cx
    int 0x21                                            ; [cd 21]
    pop ds                                              ; [1f]
    jae short 0x5138                                    ; [73 06]
    mov word [dos_errno], ax                            ; [a3 8a 00]
    jmp short 0x5148                                    ; [eb 11]
rtl_write_handle_l5137:
    xchg dx, ax                                         ; [92]
rtl_write_handle_l5138:
    mov word [es:di+0x2], 0xD7B3                        ; [26 c7 45 02 b3 d7]
    mov word [es:di], ax                                ; [26 89 05]
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    mov word [es:di+0x4], ax                            ; [26 89 45 04]
rtl_write_handle_l5148:
    pop bp                                              ; [5d]
    retf 0x6                                            ; [ca 06 00]
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    call near 0x518D                                    ; [e8 38 00]
    jne short 0x5165                                    ; [75 0e]
    db 0x33,0xC9                                   ; xor cx, cx
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ah, 0x40                                        ; [b4 40]
    int 0x21                                            ; [cd 21]
    jae short 0x5165                                    ; [73 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_write_handle_l5165:
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fclose_fd   image offset 0x5168  <- called from 0x0C6C, 0x0EF2, 0x155C, 0x5119
; ------------------------------------------------------------------------------
rtl_fclose_fd:
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x4]                            ; [36 c4 7f 04]
    call near 0x518D                                    ; [e8 1c 00]
    jne short 0x518A                                    ; [75 17]
    mov bx, word [es:di]                                ; [26 8b 1d]
    cmp bx, byte 0x4                                    ; [83 fb 04]
    jbe short 0x5184                                    ; [76 09]
    mov ah, 0x3E                                        ; [b4 3e]
    int 0x21                                            ; [cd 21]
    jae short 0x5184                                    ; [73 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_fclose_fd_l5184:
    mov word [es:di+0x2], 0xD7B0                        ; [26 c7 45 02 b0 d7]
rtl_fclose_fd_l518A:
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_check_stream   image offset 0x518D  <- called from 0x516E, 0x51E4, 0x5240
; ------------------------------------------------------------------------------
rtl_check_stream:
    cmp word [es:di+0x2], 0xD7B3                        ; [26 81 7d 02 b3 d7]
    je short 0x519B                                     ; [74 06]
    mov word [dos_errno], 0x67                          ; [c7 06 8a 00 67 00]
rtl_check_stream_l519B:
    ret                                                 ; [c3]
    mov ah, 0x3F                                        ; [b4 3f]
    mov dx, 0x64                                        ; [ba 64 00]
    jmp short 0x51A8                                    ; [eb 05]
    mov ah, 0x40                                        ; [b4 40]
    mov dx, 0x65                                        ; [ba 65 00]
rtl_check_stream_l51A8:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    call near 0x518D                                    ; [e8 dc ff]
    jne short 0x51CE                                    ; [75 1b]
    push ds                                             ; [1e]
    push dx                                             ; [52]
    lds dx,  [bp+0x6]                               ; [c5 56 06]
    mov cx, word [es:di+0x4]                            ; [26 8b 4d 04]
    mov bx, word [es:di]                                ; [26 8b 1d]
    int 0x21                                            ; [cd 21]
    pop dx                                              ; [5a]
    pop ds                                              ; [1f]
    jb short 0x51CB                                     ; [72 06]
    db 0x3B,0xC1                                   ; cmp ax, cx
    je short 0x51CE                                     ; [74 05]
    db 0x8B,0xC2                                   ; mov ax, dx
rtl_check_stream_l51CB:
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_check_stream_l51CE:
    pop bp                                              ; [5d]
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fread   image offset 0x51D2  <- called from 0x051D, 0x0546, 0x057D, 0x05C6, 0x05E7, 0x061D, 0x0639, 0x0769
; ------------------------------------------------------------------------------
rtl_fread:
    mov bl, 0x3F                                        ; [b3 3f]
    mov cx, 0x64                                        ; [b9 64 00]
    jmp short 0x51DE                                    ; [eb 05]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fwrite   image offset 0x51D9  <- called from 0x0CCB, 0x0CE7, 0x0D03, 0x0D1F, 0x0D53, 0x0D6F, 0x0F0E, 0x10F5
; ------------------------------------------------------------------------------
rtl_fwrite:
    mov bl, 0x40                                        ; [b3 40]
    mov cx, 0x65                                        ; [b9 65 00]
rtl_fwrite_l51DE:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0x10]                              ; [c4 7e 10]
    call near 0x518D                                    ; [e8 a6 ff]
    jne short 0x5228                                    ; [75 3f]
    mov ax, word [bp+0xA]                               ; [8b 46 0a]
    db 0x0B,0xC0                                   ; or ax, ax
    je short 0x520C                                     ; [74 1c]
    push ds                                             ; [1e]
    push cx                                             ; [51]
    mul word [es:di+0x4]                                ; [26 f7 65 04]
    db 0x8B,0xC8                                   ; mov cx, ax
    lds dx,  [bp+0xC]                               ; [c5 56 0c]
    db 0x8A,0xE3                                   ; mov ah, bl
    mov bx, word [es:di]                                ; [26 8b 1d]
    int 0x21                                            ; [cd 21]
    pop cx                                              ; [59]
    pop ds                                              ; [1f]
    jb short 0x5225                                     ; [72 1f]
    db 0x33,0xD2                                   ; xor dx, dx
    div word [es:di+0x4]                                ; [26 f7 75 04]
rtl_fwrite_l520C:
    les di,  [bp+0x6]                               ; [c4 7e 06]
    mov dx, es                                          ; [8c c2]
    db 0x0B,0xD7                                   ; or dx, di
    je short 0x521A                                     ; [74 05]
    mov word [es:di], ax                                ; [26 89 05]
    jmp short 0x5236                                    ; [eb 1c]
rtl_fwrite_l521A:
    cmp ax, word [bp+0xA]                               ; [3b 46 0a]
    je short 0x5236                                     ; [74 17]
    mov word [dos_errno], cx                            ; [89 0e 8a 00]
    jmp short 0x5236                                    ; [eb 11]
rtl_fwrite_l5225:
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_fwrite_l5228:
    les di,  [bp+0x6]                               ; [c4 7e 06]
    mov dx, es                                          ; [8c c2]
    db 0x0B,0xD7                                   ; or dx, di
    je short 0x5236                                     ; [74 05]
    db 0x33,0xC0                                   ; xor ax, ax
    mov word [es:di], ax                                ; [26 89 05]
rtl_fwrite_l5236:
    pop bp                                              ; [5d]
    retf 0xE                                            ; [ca 0e 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_lseek   image offset 0x523A  <- called from 0x0501, 0x055C, 0x05AA, 0x074D, 0x0890, 0x09E4, 0x0B40, 0x0EC6
; ------------------------------------------------------------------------------
rtl_lseek:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    les di,  [bp+0xA]                               ; [c4 7e 0a]
    call near 0x518D                                    ; [e8 4a ff]
    jne short 0x5266                                    ; [75 21]
    mov ax, word [bp+0x8]                               ; [8b 46 08]
    mul word [es:di+0x4]                                ; [26 f7 65 04]
    db 0x8B,0xC8                                   ; mov cx, ax
    mov ax, word [bp+0x6]                               ; [8b 46 06]
    mul word [es:di+0x4]                                ; [26 f7 65 04]
    db 0x03,0xCA                                   ; add cx, dx
    db 0x8B,0xD0                                   ; mov dx, ax
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ax, 0x4200                                      ; [b8 00 42]
    int 0x21                                            ; [cd 21]
    jae short 0x5266                                    ; [73 03]
    mov word [dos_errno], ax                            ; [a3 8a 00]
rtl_lseek_l5266:
    pop bp                                              ; [5d]
    retf 0x8                                            ; [ca 08 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fopen   image offset 0x526A  <- called from 0x073B, 0x087E, 0x09D2, 0x0B2E, 0x0F37
; ------------------------------------------------------------------------------
rtl_fopen:
    call near 0x52B1                                    ; [e8 44 00]
    jb short 0x527E                                     ; [72 0f]
    mov cx, word [es:di+0x4]                            ; [26 8b 4d 04]
    cmp cx, byte 0x1                                    ; [83 f9 01]
    je short 0x527E                                     ; [74 06]
    db 0x33,0xDB                                   ; xor bx, bx
    push cs                                             ; [0e]
    call near 0x4A28                                    ; [e8 aa f7]
rtl_fopen_l527E:
    retf 0x4                                            ; [ca 04 00]
    call near 0x52B1                                    ; [e8 2d 00]
    jb short 0x5299                                     ; [72 13]
    db 0x8B,0xC1                                   ; mov ax, cx
    db 0x8B,0xD3                                   ; mov dx, bx
    mov cx, word [es:di+0x4]                            ; [26 8b 4d 04]
    cmp cx, byte 0x1                                    ; [83 f9 01]
    je short 0x5299                                     ; [74 06]
    db 0x33,0xDB                                   ; xor bx, bx
    push cs                                             ; [0e]
    call near 0x4A28                                    ; [e8 8f f7]
rtl_fopen_l5299:
    retf 0x4                                            ; [ca 04 00]
    call near 0x52B1                                    ; [e8 12 00]
    jb short 0x52AC                                     ; [72 0b]
    db 0x2B,0xC1                                   ; sub ax, cx
    db 0x1B,0xD3                                   ; sbb dx, bx
    jb short 0x52AC                                     ; [72 05]
    mov al, 0x1                                         ; [b0 01]
    retf 0x4                                            ; [ca 04 00]
rtl_fopen_l52AC:
    db 0x32,0xC0                                   ; xor al, al
    retf 0x4                                            ; [ca 04 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fopen_impl   image offset 0x52B1  <- called from 0x526A
; ------------------------------------------------------------------------------
rtl_fopen_impl:
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x6]                            ; [36 c4 7f 06]
    cmp word [es:di+0x2], 0xD7B3                        ; [26 81 7d 02 b3 d7]
    jne short 0x52EA                                    ; [75 2b]
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x33,0xD2                                   ; xor dx, dx
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ax, 0x4201                                      ; [b8 01 42]
    int 0x21                                            ; [cd 21]
    push dx                                             ; [52]
    push ax                                             ; [50]
    db 0x33,0xC9                                   ; xor cx, cx
    db 0x33,0xD2                                   ; xor dx, dx
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ax, 0x4202                                      ; [b8 02 42]
    int 0x21                                            ; [cd 21]
    pop bx                                              ; [5b]
    pop cx                                              ; [59]
    push dx                                             ; [52]
    push ax                                             ; [50]
    db 0x8B,0xD3                                   ; mov dx, bx
    mov bx, word [es:di]                                ; [26 8b 1d]
    mov ax, 0x4200                                      ; [b8 00 42]
    int 0x21                                            ; [cd 21]
    pop cx                                              ; [59]
    pop bx                                              ; [5b]
    ret                                                 ; [c3]
rtl_fopen_impl_l52EA:
    mov word [dos_errno], 0x67                          ; [c7 06 8a 00 67 00]
    db 0x33,0xC0                                   ; xor ax, ax
    db 0x33,0xD2                                   ; xor dx, dx
    stc                                                 ; [f9]
    ret                                                 ; [c3]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fwrite_raw   image offset 0x52F6  <- called from 0x06E9, 0x086F, 0x09C3, 0x0B1F, 0x0C57
; ------------------------------------------------------------------------------
rtl_fwrite_raw:
    db 0x8B,0xDC                                   ; mov bx, sp
    mov dx, ds                                          ; [8c da]
    lds si,  [ss:bx+0xA]                            ; [36 c5 77 0a]
    les di,  [ss:bx+0x6]                            ; [36 c4 7f 06]
    mov cx, word [ss:bx+0x4]                            ; [36 8b 4f 04]
    cld                                                 ; [fc]
    db 0x3B,0xF7                                   ; cmp si, di
    jae short 0x5312                                    ; [73 07]
    db 0x03,0xF1                                   ; add si, cx
    db 0x03,0xF9                                   ; add di, cx
    dec si                                              ; [4e]
    dec di                                              ; [4f]
    std                                                 ; [fd]
rtl_fwrite_raw_l5312:
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    mov ds, dx                                          ; [8e da]
    retf 0xA                                            ; [ca 0a 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_fread_raw   image offset 0x5319  <- called from 0x0DBC
; ------------------------------------------------------------------------------
rtl_fread_raw:
    db 0x8B,0xDC                                   ; mov bx, sp
    les di,  [ss:bx+0x8]                            ; [36 c4 7f 08]
    mov cx, word [ss:bx+0x6]                            ; [36 8b 4f 06]
    mov al, byte [ss:bx+0x4]                            ; [36 8a 47 04]
    cld                                                 ; [fc]
    db 0xF3,0xAA                                   ; rep stosb byte [es:di], al
    retf 0x8                                            ; [ca 08 00]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_get_dos_version   image offset 0x532D  <- called from 0x033C, 0x038E, 0x03AB, 0x03FD
; ------------------------------------------------------------------------------
rtl_get_dos_version:
    push bp                                             ; [55]
    db 0x8B,0xEC                                   ; mov bp, sp
    mov dx, word [bp+0x6]                               ; [8b 56 06]
    db 0x0B,0xD2                                   ; or dx, dx
    je short 0x533C                                     ; [74 05]
    call near 0x5383                                    ; [e8 49 00]
    jmp short 0x536C                                    ; [eb 30]
rtl_get_dos_version_l533C:
    mov ah, 0x30                                        ; [b4 30]
    int 0x21                                            ; [cd 21]
    cmp al, 0x3                                         ; [3c 03]
    mov ax, 0x0                                         ; [b8 00 00]
    jb short 0x536C                                     ; [72 25]
    mov es, word [psp_seg]                              ; [8e 06 86 00]
    mov es, word [es:0x2C]                              ; [26 8e 06 2c 00]
    db 0x33,0xFF                                   ; xor di, di
    cld                                                 ; [fc]
rtl_get_dos_version_l5353:
    cmp al, byte [es:di]                                ; [26 3a 05]
    je short 0x535F                                     ; [74 07]
    mov cx, 0xFFFF                                      ; [b9 ff ff]
    db 0xF2,0xAE                                   ; repne scasb al, byte [es:di]
    jmp short 0x5353                                    ; [eb f4]
rtl_get_dos_version_l535F:
    add di, byte 0x3                                    ; [83 c7 03]
    db 0x8B,0xF7                                   ; mov si, di
    mov cx, 0x100                                       ; [b9 00 01]
    db 0xF2,0xAE                                   ; repne scasb al, byte [es:di]
    xchg cx, ax                                         ; [91]
    not al                                              ; [f6 d0]
rtl_get_dos_version_l536C:
    push ds                                             ; [1e]
    push es                                             ; [06]
    pop ds                                              ; [1f]
    les di,  [bp+0x8]                               ; [c4 7e 08]
    cld                                                 ; [fc]
    stosb                                               ; [aa]
    xchg cx, ax                                         ; [91]
    db 0xF3,0xA4                                   ; rep movsb byte [es:di], byte [si]
    pop ds                                              ; [1f]
    pop bp                                              ; [5d]
    retf 0x2                                            ; [ca 02 00]
    db 0x33,0xD2                                   ; xor dx, dx
    call near 0x5383                                    ; [e8 02 00]
    xchg bx, ax                                         ; [93]
    retf                                                ; [cb]

; ------------------------------------------------------------------------------
;  FUNCTION  rtl_env_scan   image offset 0x5383  <- called from 0x5337
; ------------------------------------------------------------------------------
rtl_env_scan:
    mov es, word [psp_seg]                              ; [8e 06 86 00]
    mov di, 0x80                                        ; [bf 80 00]
    mov cl, byte [es:di]                                ; [26 8a 0d]
    db 0x32,0xED                                   ; xor ch, ch
    inc di                                              ; [47]
    db 0x33,0xDB                                   ; xor bx, bx
rtl_env_scan_l5392:
    jcxz 0x539D                                         ; [e3 09]
rtl_env_scan_l5394:
    cmp byte [es:di], 0x20                              ; [26 80 3d 20]
    ja short 0x539D                                     ; [77 03]
    inc di                                              ; [47]
    loop 0x5394                                         ; [e2 f7]
rtl_env_scan_l539D:
    db 0x8B,0xF7                                   ; mov si, di
    jcxz 0x53AA                                         ; [e3 09]
rtl_env_scan_l53A1:
    cmp byte [es:di], 0x20                              ; [26 80 3d 20]
    jbe short 0x53AA                                    ; [76 03]
    inc di                                              ; [47]
    loop 0x53A1                                         ; [e2 f7]
rtl_env_scan_l53AA:
    db 0x8B,0xC7                                   ; mov ax, di
    db 0x2B,0xC6                                   ; sub ax, si
    je short 0x53B4                                     ; [74 04]
    inc bx                                              ; [43]
    dec dx                                              ; [4a]
    jne short 0x5392                                    ; [75 de]
rtl_env_scan_l53B4:
    ret                                                 ; [c3]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [si], dl                                   ; [00 14]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bp+si], al                                ; [00 02]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]
    add byte [bx+si], al                                ; [00 00]

; ------------------------------------------------------------------------------
; DATA  image:0x545F .. 0x545F   1 bytes
; ------------------------------------------------------------------------------
data_545F:
    db 0x00                                          ; 0x545F

; ==============================================================================
;  end of load image
; ==============================================================================

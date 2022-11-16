;-------------------------------------------------------------------------------

/*
    TIA_BASE_ADDRESS

    The TIA_BASE_ADDRESS defines the base address of access to TIA registers.
    Normally 0, the base address should (externally, before including this file)
    be set to $40 when creating 3F-bankswitched (and other?) cartridges.
    The reason is that this bankswitching scheme treats any access to locations
    < $40 as a bankswitch.
*/
TIA_BASE_ADDRESS        = 0

TIA_BASE_READ_ADDRESS   = TIA_BASE_ADDRESS
TIA_BASE_WRITE_ADDRESS  = TIA_BASE_ADDRESS

;-------------------------------------------------------------------------------

.zpvar = TIA_BASE_WRITE_ADDRESS

.zpvar VSYNC                .byte   ; $00  0000 00x0   Vertical Sync Set-Clear
.zpvar VBLANK               .byte   ; $01  xx00 00x0   Vertical Blank Set-Clear
.zpvar WSYNC                .byte   ; $02  ---- ----   Wait for Horizontal Blank
.zpvar RSYNC                .byte   ; $03  ---- ----   Reset Horizontal Sync Counter
.zpvar NUSIZ0               .byte   ; $04  00xx 0xxx   Number-Size player/missle 0
.zpvar NUSIZ1               .byte   ; $05  00xx 0xxx   Number-Size player/missle 1
.zpvar COLUP0               .byte   ; $06  xxxx xxx0   Color-Luminance Player 0
.zpvar COLUP1               .byte   ; $07  xxxx xxx0   Color-Luminance Player 1
.zpvar COLUPF               .byte   ; $08  xxxx xxx0   Color-Luminance Playfield
.zpvar COLUBK               .byte   ; $09  xxxx xxx0   Color-Luminance Background
.zpvar CTRLPF               .byte   ; $0A  00xx 0xxx   Control Playfield, Ball, Collisions
.zpvar REFP0                .byte   ; $0B  0000 x000   Reflection Player 0
.zpvar REFP1                .byte   ; $0C  0000 x000   Reflection Player 1
.zpvar PF0                  .byte   ; $0D  xxxx 0000   Playfield Register Byte 0
.zpvar PF1                  .byte   ; $0E  xxxx xxxx   Playfield Register Byte 1
.zpvar PF2                  .byte   ; $0F  xxxx xxxx   Playfield Register Byte 2
.zpvar RESP0                .byte   ; $10  ---- ----   Reset Player 0
.zpvar RESP1                .byte   ; $11  ---- ----   Reset Player 1
.zpvar RESM0                .byte   ; $12  ---- ----   Reset Missle 0
.zpvar RESM1                .byte   ; $13  ---- ----   Reset Missle 1
.zpvar RESBL                .byte   ; $14  ---- ----   Reset Ball
.zpvar AUDC0                .byte   ; $15  0000 xxxx   Audio Control 0
.zpvar AUDC1                .byte   ; $16  0000 xxxx   Audio Control 1
.zpvar AUDF0                .byte   ; $17  000x xxxx   Audio Frequency 0
.zpvar AUDF1                .byte   ; $18  000x xxxx   Audio Frequency 1
.zpvar AUDV0                .byte   ; $19  0000 xxxx   Audio Volume 0
.zpvar AUDV1                .byte   ; $1A  0000 xxxx   Audio Volume 1
.zpvar GRP0                 .byte   ; $1B  xxxx xxxx   Graphics Register Player 0
.zpvar GRP1                 .byte   ; $1C  xxxx xxxx   Graphics Register Player 1
.zpvar ENAM0                .byte   ; $1D  0000 00x0   Graphics Enable Missle 0
.zpvar ENAM1                .byte   ; $1E  0000 00x0   Graphics Enable Missle 1
.zpvar ENABL                .byte   ; $1F  0000 00x0   Graphics Enable Ball
.zpvar HMP0                 .byte   ; $20  xxxx 0000   Horizontal Motion Player 0
.zpvar HMP1                 .byte   ; $21  xxxx 0000   Horizontal Motion Player 1
.zpvar HMM0                 .byte   ; $22  xxxx 0000   Horizontal Motion Missle 0
.zpvar HMM1                 .byte   ; $23  xxxx 0000   Horizontal Motion Missle 1
.zpvar HMBL                 .byte   ; $24  xxxx 0000   Horizontal Motion Ball
.zpvar VDELP0               .byte   ; $25  0000 000x   Vertical Delay Player 0
.zpvar VDELP1               .byte   ; $26  0000 000x   Vertical Delay Player 1
.zpvar VDELBL               .byte   ; $27  0000 000x   Vertical Delay Ball
.zpvar RESMP0               .byte   ; $28  0000 00x0   Reset Missle 0 to Player 0
.zpvar RESMP1               .byte   ; $29  0000 00x0   Reset Missle 1 to Player 1
.zpvar HMOVE                .byte   ; $2A  ---- ----   Apply Horizontal Motion
.zpvar HMCLR                .byte   ; $2B  ---- ----   Clear Horizontal Move Registers
.zpvar CXCLR                .byte   ; $2C  ---- ----   Clear Collision Latche 
 
;-------------------------------------------------------------------------------   

.zpvar = TIA_BASE_READ_ADDRESS
                                    ;                                  bit 7   bit 6
.nowarn .zpvar CXM0P        .byte   ; $00  xx00 0000   Read Collision  M0-P1   M0-P0
.nowarn .zpvar CXM1P        .byte   ; $01  xx00 0000                   M1-P0   M1-P1
.nowarn .zpvar CXP0FB       .byte   ; $02  xx00 0000                   P0-PF   P0-BL
.nowarn .zpvar CXP1FB       .byte   ; $03  xx00 0000                   P1-PF   P1-BL
.nowarn .zpvar CXM0FB       .byte   ; $04  xx00 0000                   M0-PF   M0-BL
.nowarn .zpvar CXM1FB       .byte   ; $05  xx00 0000                   M1-PF   M1-BL
.nowarn .zpvar CXBLPF       .byte   ; $06  x000 0000                   BL-PF   -----
.nowarn .zpvar CXPPMM       .byte   ; $07  xx00 0000                   P0-P1   M0-M1
.nowarn .zpvar INPT0        .byte   ; $08  x000 0000   Read Pot Port 0
.nowarn .zpvar INPT1        .byte   ; $09  x000 0000   Read Pot Port 1
.nowarn .zpvar INPT2        .byte   ; $0A  x000 0000   Read Pot Port 2
.nowarn .zpvar INPT3        .byte   ; $0B  x000 0000   Read Pot Port 3
.nowarn .zpvar INPT4        .byte   ; $0C  x000 0000   Read Input (Trigger) 0
.nowarn .zpvar INPT5        .byte   ; $0D  x000 0000   Read Input (Trigger) 1

;-------------------------------------------------------------------------------
; RIOT MEMORY MAP
;-------------------------------------------------------------------------------

SWCHA   = $280      ; Port A data register for joysticks:
                    ; Bits 4-7 for player 1.  Bits 0-3 for player 2.

SWACNT  = $281      ; Port A data direction register (DDR)
SWCHB   = $282      ; Port B data (console switches)
SWBCNT  = $283      ; Port B DDR
INTIM   = $284      ; Timer output

TIMINT  = $285

                    ; Unused/undefined registers ($285-$294)
                    ; $286
                    ; $287
                    ; $288
                    ; $289
                    ; $28A
                    ; $28B
                    ; $28C
                    ; $28D
                    ; $28E
                    ; $28F
                    ; $290
                    ; $291
                    ; $292
                    ; $293

TIM1T   = $294      ; set 1 clock interval
TIM8T   = $295      ; set 8 clock interval
TIM64T  = $296      ; set 64 clock interval
T1024T  = $297      ; set 1024 clock interval

;-------------------------------------------------------------------------------

/*
--------------------------------------------------------------------------------
    MEMOS
--------------------------------------------------------------------------------

    BANK_SEL
            --  F8  F6  F4
    0x1FF8  0   0   2   4   b0  1111 1000
    0x1FF9  -   1   3   5   b1  1111 1001
    0x1FF6  -   -   0   2   b2  1111 0110
    0x1FF7  -   -   1   3   b3  1111 0111
    0x1FF4  -   -   -   0   b4  1111 0100
    0x1FF5  -   -   -   1   b5  1111 0101
    0x1FFA  -   -   -   6   b6  1111 1010
    0x1FFB  -   -   -   7   b7  1111 1011

--------------------------------------------------------------------------------

    Type        NTSC  PAL/SECAM
    V-Sync      3     3    scanlines
    V-Blank     37    45   scanlines (upper border)
    Picture     192   228  scanlines
    Overscan    30    36   scanlines (lower border)
    Frame Rate  60    50   Hz
    Frame Time  262   312  scanlines

--------------------------------------------------------------------------------

    --- scanline numbers ---
    Type        NTSC     PAL/SECAM
    V-Sync      3        3    
    V-Blank     37       45   
    Picture     192      228  
    Overscan    30       36

--------------------------------------------------------------------------------

var ns0=0x04,ns1;               // 00xx 0xxx   Number-Size player/missle 0/1
                                //       ^^^    - Player-Missile number & Player size (See table below)
                                //       000          0  One copy              (X.........)
                                //       001          1  Two copies - close    (X.X.......)
                                //       010          2  Two copies - medium   (X...X.....)
                                //       011          3  Three copies - close  (X.X.X.....)
                                //       100          4  Two copies - wide     (X.......X.)
                                //       101          5  Double sized player   (XX........)
                                //       110          6  Three copies - medium (X...X...X.)
                                //       111          7  Quad sized player     (XXXX......)
                                //   ^^         - Missile Size  (0..3 = 1,2,4,8 pixels width)

var cp0=0x06,cp1,cpf,cbg;       // xxxx xxx-   Color-Luminance Player 0/1, Playfield, Background
var ctpf=0x0A;                  // --xx -xxx   Control Playfield, Ball, Collisions
                                //         ^    - Playfield Reflection     (0=Normal, 1=Mirror right half)
                                //        ^     - Playfield Color          (0=Normal, 1=Score Mode, only if Bit2=0)
                                //       ^      - Playfield/Ball Priority  (0=Normal, 1=Above Players/Missiles)
                                //   ^^         - Ball size                (0..3 = 1,2,4,8 pixels width)

var rep0=0x0B, rep1;            // ---- x---   Reflection Player 0/1
var pf0=0x0D, pf1, pf2;         // xxxx ----   Playfield Register Byte 0
                                // xxxx xxxx   Playfield Register Byte 1
                                // xxxx xxxx   Playfield Register Byte 2
var rp0=0x10,rp1,rm0,rm1,rb;    // ---- ----   Reset Player 0/1, Missile 0/1, Ball

var gp0=0x1B,gp1;               // xxxx xxxx   Graphics Register Player 0/1
var em0=0x1D,em1,eb;            // ---- --x-   Graphics Enable Missle 0/1, Ball
var hp0=0x20,hp1,hm0,hm1,hb;    // xxxx ----   Horizontal Motion Player 0/1, Missile 0/1, Ball
var vdp0=0x25,vdp1,vdb;         // ---- ---x   Vertical Delay Player 0/1, Ball
var rmp0=0x28,rmp1;             // ---- --x-   Reset Missle 0/1 to Player 0/1
var hmove=0x2A;                 // ---- ----   Apply Horizontal Motion
var hmclr=0x2B;                 // ---- ----   Clear Horizontal Move Registers

var gp0h=0x11B,gp1h;            // xxxx xxxx   Graphics Register Player 0/1
var rmp0h=0x128,rmp1h;          // ---- --x-   Reset Missle 0/1 to Player 0/1
var pf0h=0x10D, pf1h, pf2h;     // xxxx ----   Playfield Register Byte 0
var cp0h=0x106,cp1h,cpfh,cbgh;  // xxxx xxx-   Color-Luminance Player 0/1, Playfield, Background
var hp0h=0x120,hp1h,hm0h,hm1h,hbh;  // xxxx ----   Horizontal Motion Player 0/1, Missile 0/1, Ball

var ac0=0x15,ac1;               // ---- xxxx   Audio Control 0/1
var af0=0x17,af1;               // ---x xxxx   Audio Frequency 0/1
var av0=0x19,av1;               // ---- xxxx   Audio Volume 0/1

var inpt0=0x38;                 // x--- ----   read pot port
var inpt1=0x39;                 // x--- ----   read pot port
var inpt2=0x3A;                 // x--- ----   read pot port
var inpt3=0x3B;                 // x--- ----   read pot port
var inpt4=0x3C;                 // x--- ----   read input / P0 Fire (0 active)
var inpt5=0x3D;                 // x--- ----   read input / P1 Fire (0 active)
  
var swcha=0x280;                // xxxx xxxx   Port A
                                //         ^    - P1 Up     (0 active)
                                //        ^     - P1 Down   (0 active)
                                //       ^      - P1 Left   (0 active)
                                //      ^       - P1 Right  (0 active)
                                //    ^         - P0 Up     (0 active)
                                //   ^          - P0 Down   (0 active)
                                //  ^           - P0 Left   (0 active)
                                // ^            - P0 Right  (0 active)

var swchb=0x282;                // xx-- x-xx   Port B
                                //         ^    - Reset Button          (0=Pressed)
                                //        ^     - Select Button         (0=Pressed)
                                //      ^       - Color Switch          (0=B/W, 1=Color) (Always 0 for SECAM)
                                //  ^           - P0 Difficulty Switch  (0=Beginner (B), 1=Advanced (A))
                                // ^            - P1 Difficulty Switch  (0=Beginner (B), 1=Advanced (A))

--------------------------------------------------------------------------------
*/
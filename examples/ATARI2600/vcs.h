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

            org TIA_BASE_WRITE_ADDRESS

VSYNC       .ds 1    ; $00  0000 00x0   Vertical Sync Set-Clear
VBLANK      .ds 1    ; $01  xx00 00x0   Vertical Blank Set-Clear
WSYNC       .ds 1    ; $02  ---- ----   Wait for Horizontal Blank
RSYNC       .ds 1    ; $03  ---- ----   Reset Horizontal Sync Counter
NUSIZ0      .ds 1    ; $04  00xx 0xxx   Number-Size player/missle 0
NUSIZ1      .ds 1    ; $05  00xx 0xxx   Number-Size player/missle 1
COLUP0      .ds 1    ; $06  xxxx xxx0   Color-Luminance Player 0
COLUP1      .ds 1    ; $07  xxxx xxx0   Color-Luminance Player 1
COLUPF      .ds 1    ; $08  xxxx xxx0   Color-Luminance Playfield
COLUBK      .ds 1    ; $09  xxxx xxx0   Color-Luminance Background
CTRLPF      .ds 1    ; $0A  00xx 0xxx   Control Playfield, Ball, Collisions
REFP0       .ds 1    ; $0B  0000 x000   Reflection Player 0
REFP1       .ds 1    ; $0C  0000 x000   Reflection Player 1
PF0         .ds 1    ; $0D  xxxx 0000   Playfield Register Byte 0
PF1         .ds 1    ; $0E  xxxx xxxx   Playfield Register Byte 1
PF2         .ds 1    ; $0F  xxxx xxxx   Playfield Register Byte 2
RESP0       .ds 1    ; $10  ---- ----   Reset Player 0
RESP1       .ds 1    ; $11  ---- ----   Reset Player 1
RESM0       .ds 1    ; $12  ---- ----   Reset Missle 0
RESM1       .ds 1    ; $13  ---- ----   Reset Missle 1
RESBL       .ds 1    ; $14  ---- ----   Reset Ball
AUDC0       .ds 1    ; $15  0000 xxxx   Audio Control 0
AUDC1       .ds 1    ; $16  0000 xxxx   Audio Control 1
AUDF0       .ds 1    ; $17  000x xxxx   Audio Frequency 0
AUDF1       .ds 1    ; $18  000x xxxx   Audio Frequency 1
AUDV0       .ds 1    ; $19  0000 xxxx   Audio Volume 0
AUDV1       .ds 1    ; $1A  0000 xxxx   Audio Volume 1
GRP0        .ds 1    ; $1B  xxxx xxxx   Graphics Register Player 0
GRP1        .ds 1    ; $1C  xxxx xxxx   Graphics Register Player 1
ENAM0       .ds 1    ; $1D  0000 00x0   Graphics Enable Missle 0
ENAM1       .ds 1    ; $1E  0000 00x0   Graphics Enable Missle 1
ENABL       .ds 1    ; $1F  0000 00x0   Graphics Enable Ball
HMP0        .ds 1    ; $20  xxxx 0000   Horizontal Motion Player 0
HMP1        .ds 1    ; $21  xxxx 0000   Horizontal Motion Player 1
HMM0        .ds 1    ; $22  xxxx 0000   Horizontal Motion Missle 0
HMM1        .ds 1    ; $23  xxxx 0000   Horizontal Motion Missle 1
HMBL        .ds 1    ; $24  xxxx 0000   Horizontal Motion Ball
VDELP0      .ds 1    ; $25  0000 000x   Vertical Delay Player 0
VDELP1      .ds 1    ; $26  0000 000x   Vertical Delay Player 1
VDELBL      .ds 1    ; $27  0000 000x   Vertical Delay Ball
RESMP0      .ds 1    ; $28  0000 00x0   Reset Missle 0 to Player 0
RESMP1      .ds 1    ; $29  0000 00x0   Reset Missle 1 to Player 1
HMOVE       .ds 1    ; $2A  ---- ----   Apply Horizontal Motion
HMCLR       .ds 1    ; $2B  ---- ----   Clear Horizontal Move Registers
CXCLR       .ds 1    ; $2C  ---- ----   Clear Collision Latche 

;-------------------------------------------------------------------------------   

            org TIA_BASE_READ_ADDRESS

                     ;                                  bit 7   bit 6
CXM0P       .ds 1    ; $00  xx00 0000   Read Collision  M0-P1   M0-P0
CXM1P       .ds 1    ; $01  xx00 0000                   M1-P0   M1-P1
CXP0FB      .ds 1    ; $02  xx00 0000                   P0-PF   P0-BL
CXP1FB      .ds 1    ; $03  xx00 0000                   P1-PF   P1-BL
CXM0FB      .ds 1    ; $04  xx00 0000                   M0-PF   M0-BL
CXM1FB      .ds 1    ; $05  xx00 0000                   M1-PF   M1-BL
CXBLPF      .ds 1    ; $06  x000 0000                   BL-PF   -----
CXPPMM      .ds 1    ; $07  xx00 0000                   P0-P1   M0-M1
INPT0       .ds 1    ; $08  x000 0000   Read Pot Port 0
INPT1       .ds 1    ; $09  x000 0000   Read Pot Port 1
INPT2       .ds 1    ; $0A  x000 0000   Read Pot Port 2
INPT3       .ds 1    ; $0B  x000 0000   Read Pot Port 3
INPT4       .ds 1    ; $0C  x000 0000   Read Input (Trigger) 0
INPT5       .ds 1    ; $0D  x000 0000   Read Input (Trigger) 1

;-------------------------------------------------------------------------------
; RIOT MEMORY MAP
;-------------------------------------------------------------------------------

            org $280

SWCHA       .ds 1    ; $280      Port A data register for joysticks:
                     ;           Bits 4-7 for player 1.  Bits 0-3 for player 2.

SWACNT      .ds 1    ; $281      Port A data direction register (DDR)
SWCHB       .ds 1    ; $282      Port B data (console switches)
SWBCNT      .ds 1    ; $283      Port B DDR
INTIM       .ds 1    ; $284      Timer output

TIMINT      .ds 1    ; $285

            ; Unused/undefined registers ($285-$294)

            .ds 1    ; $286
            .ds 1    ; $287
            .ds 1    ; $288
            .ds 1    ; $289
            .ds 1    ; $28A
            .ds 1    ; $28B
            .ds 1    ; $28C
            .ds 1    ; $28D
            .ds 1    ; $28E
            .ds 1    ; $28F
            .ds 1    ; $290
            .ds 1    ; $291
            .ds 1    ; $292
            .ds 1    ; $293

TIM1T       .ds 1    ; $294      set 1 clock interval
TIM8T       .ds 1    ; $295      set 8 clock interval
TIM64T      .ds 1    ; $296      set 64 clock interval
T1024T      .ds 1    ; $297      set 1024 clock interval

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
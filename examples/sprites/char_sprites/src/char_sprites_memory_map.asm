; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************
NO_SPR          equ  12
CHARSET_EOR		equ $10	;difference between two charset buffers

;.def RASTERCOLORIZE

;.def VBICOLORIZE

;.def TESTSPRITEDRAW

;.def PLAYMUSIC

TESTSPRITEY     equ $3C
TESTSPRITEX     equ $10
TESTSPRITENO    equ 0

RMT_MODULE_LOAD equ $6000

DLISTSTART      equ $9000

PMMEMBASE       equ $9100

EKR1            equ $9800
EKR2            equ $9C00

charbaseos      equ $E000
charbase		equ $A000
charbase2       equ $B000

shl             equ $C000
shr             equ $C400
mask_shl        equ $C800
mask_shr        equ $CC00


i               equ $05
j               equ $06
k               equ $07
buffer_switched equ $08
buffer_rendered equ $09
frame_counter   equ $0A
max_frame       equ $0B

ek              equ $0C

brx             equ $0E
bry             equ $0F

scrhi           equ $10

char_buffer     equ $11
screen_buffer   equ $12

REGY            EQU $13
REGX            EQU $14
ACC             EQU $15
dli_index       EQU $16
yand7           EQU $17

current_dlist   EQU $18

scroll_value    EQU $19 ; $1A

b00             equ $A0
b01             equ $A2
b02             equ $A4
b03             equ $A6
b10             equ $A8
b11             equ $AA
b12             equ $AC
b13             equ $AE
b20             equ $B0
b21             equ $B2
b22             equ $B4
b23             equ $B6
b30             equ $B8
b31             equ $BA
b32             equ $BC
b33             equ $BE

mskad0          equ $C0
mskad1          equ $C2
mskad2          equ $C4
mskad3          equ $C6

sprad0          equ $C8
sprad1          equ $CA
sprad2          equ $CC
sprad3          equ $CE

c00             equ $D0
c01             equ $D2
c02             equ $D4
c03             equ $D6
c10             equ $D8
c11             equ $DA
c12             equ $DC
c13             equ $DE
c20             equ $E0
c21             equ $E2
c22             equ $E4
c23             equ $E6
c30             equ $E8
c31             equ $EA
c32             equ $EC
c33             equ $EE

POM             EQU $F0
POM1            EQU $F1
POM2            EQU $F2
POM3            EQU $F3
POM4            EQU $F4
POM5            EQU $F5
AD1             EQU $F6
AD2             EQU $F8

sprx            equ $fa
spry            equ $fb
sprno           equ $fc
sprajt_index    equ $fd
ad              equ $fe

COLPF0          equ $D016
COLPF1          equ $D017
COLPF2          equ $D018
COLPF3          equ $D019
COLBK           equ $D01A

CHBASE          equ $D409

PORTB           equ $D301

NMIEN           equ $D40E
NMIST           equ $D40F
NMIRES          equ $D40F
VCOUNT          equ $D40B
WSYNC           equ $D40A
DLISTL          equ $D402
DLISTH          equ $D403
HSCROL          equ $D404
RANDOM          equ $D20A

PMBASE          equ $D407   ;STARTING ADRESS PLAYER MISSILE GRAPHICS

HPOSP0          EQU $D000   ;HORIZONTAL POSITION P0
HPOSP1          EQU $D001   ;HORIZONTAL POSITION P1
HPOSP2          EQU $D002   ;HORIZONTAL POSITION P2
HPOSP3          EQU $D003   ;HORIZONTAL POSITION P3
HPOSM0          EQU $D004   ;HORIZONTAL POSITION M0
HPOSM1          EQU $D005   ;HORIZONTAL POSITION M1
HPOSM2          EQU $D006   ;HORIZONTAL POSITION M2
HPOSM3          EQU $D007   ;HORIZONTAL POSITION M3

SIZEP0          EQU $D008   ;SIZE P0
SIZEP1          EQU $D009   ;SIZE P0
SIZEP2          EQU $D00A   ;SIZE P0
SIZEP3          EQU $D00B   ;SIZE P0
SIZEM           EQU $D00C   ;SIZE M

GRAFP0          EQU $D00D
GRAFP1          EQU $D00E
GRAFP2          EQU $D00F
GRAFP3          EQU $D010   ; ??????
GRAFM           EQU $D011   ; ??????

COLPM0          EQU $D012   ;COLOR P0/M0
COLPM1          EQU $D013   ;COLOR P1/M1
COLPM2          EQU $D014   ;COLOR P2/M2
COLPM3          EQU $D015   ;COLOR P3/M3

IRQEN           equ $D20E
IRQST           equ $D20E

TRIG0           equ $D010   ;FIRE BUTTON JOY 1
TRIG1           equ $D011   ;FIRE BUTTON JOY 2
STICK0          equ $D300
PBCTL           equ $D303

KBCODE          equ $D209
SKSTAT          equ $D20F
SKCTL           equ $D20F

NMI             equ $FFFA
RESET           equ $FFFC
IRQ             equ $FFFE

DMACTL          equ $D400
CHACTL          equ $D401
GRACTL          equ $D01D
GPRIOR          equ $D01B


color_Rust          equ 7+16
color_White         equ 0+14
color_Black         equ 0
color_Red_orange    equ 7+32
color_Dark_orange   equ 7+48
color_Yellow        equ 218
color_Red           equ 7+64
color_Dark_lavender equ 7+80
color_Cobalt_blue   equ 7+96
color_Darker_blue   equ 134
color_Ultramarine   equ 7+112
color_Cyan          equ 154
color_Dark_blue     equ 7+144
color_Medium_blue   equ 7+128
color_Blue_grey     equ 7+160
color_Olive_green   equ 7+176
color_Medium_green  equ 7+192
color_Dark_green    equ 7+208
color_Orange_green  equ 7+224
color_Orange        equ 7+240
color_Black_pale    equ 2
color_Pale_brown    equ 228
color_Blue2         equ 128+8
color_Brown_light   equ 16+12


LMS                 equ 64
HS                  equ 16
MODE2               equ 2
MODE4               equ 4
MODED               equ $0D
MODEE               equ $0E
BLANK1              equ $00
BLANK7              equ $60
BLANK8              equ $70
DLI                 equ 128
DLIJUMP             equ 65

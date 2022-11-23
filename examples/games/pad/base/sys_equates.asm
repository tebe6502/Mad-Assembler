;================================================================================
; System equates, Atari XL + mads [NRV 2009]
;================================================================================

;----------------------------------------
; GTIA:
;----------------------------------------

M0PF	= $D000  ; read only
M1PF	= $D001  ; read only
M2PF	= $D002  ; read only
M3PF	= $D003  ; read only

P0PF	= $D004  ; read only
P1PF	= $D005  ; read only
P2PF	= $D006  ; read only
P3PF	= $D007  ; read only

M0PL	= $D008  ; read only
M1PL	= $D009  ; read only
M2PL	= $D00A  ; read only
M3PL	= $D00B  ; read only

P0PL	= $D00C  ; read only
P1PL	= $D00D  ; read only
P2PL	= $D00E  ; read only
P3PL	= $D00F  ; read only

TRIG0	= $D010  ; read only
TRIG1	= $D011  ; read only
TRIG2	= $D012  ; read only
TRIG3	= $D013  ; read only

PAL		= $D014  ; read only

; positions for normal screen: 48 left (+160)--> 208 right (or 32-->224 for wide playfield)
; 32 top (+192)--> 224 bottom (or 16-->112 for double line resolution)
HPOSP0	= $D000  ; write only
HPOSP1	= $D001  ; write only
HPOSP2	= $D002  ; write only
HPOSP3	= $D003  ; write only

HPOSM0	= $D004  ; write only
HPOSM1	= $D005  ; write only
HPOSM2	= $D006  ; write only
HPOSM3	= $D007  ; write only

; 0 (or 2) normal width, 1 double width, 4 quadruple width
SIZEP0	= $D008  ; write only
SIZEP1	= $D009  ; write only
SIZEP2	= $D00A  ; write only
SIZEP3	= $D00B  ; write only

SIZEM	= $D00C  ; write only		// the same 2 bits as the players, but in one byte, in this order: m3m2m1m0

GRAFP0	= $D00D  ; write only
GRAFP1	= $D00E  ; write only
GRAFP2	= $D00F  ; write only
GRAFP3	= $D010  ; write only

GRAFM	= $D011  ; write only		// 4 missiles in this order: m3m2m1m0

COLPM0	= $D012  ; write only
COLPM1	= $D013  ; write only
COLPM2	= $D014  ; write only
COLPM3	= $D015  ; write only

COLPF0	= $D016  ; write only
COLPF1	= $D017  ; write only
COLPF2	= $D018  ; write only
COLPF3	= $D019  ; write only

COLBK	= $D01A  ; write only

PRIOR	= $D01B  ; write only
VDELAY	= $D01C  ; write only
GRACTL	= $D01D  ; write only
HITCLR	= $D01E  ; write only

CONSOL	= $D01F  ; read and write

;----------------------------------------
; POKEY:
;----------------------------------------

POT0	= $D200  ; read only
POT1	= $D201  ; read only
POT2	= $D202  ; read only
POT3	= $D203  ; read only
POT4	= $D204  ; read only
POT5	= $D205  ; read only
POT6	= $D206  ; read only
POT7	= $D207  ; read only

ALLPOT	= $D208  ; read only

KBCODE	= $D209  ; read only
RANDOM	= $D20A  ; read only

SERIN	= $D20D  ; read only
IRQST	= $D20E  ; read only
SKSTAT	= $D20F  ; read only


AUDF1	= $D200  ; write only
AUDC1	= $D201  ; write only
AUDF2	= $D202  ; write only
AUDC2	= $D203  ; write only
AUDF3	= $D204  ; write only
AUDC3	= $D205  ; write only
AUDF4	= $D206  ; write only
AUDC4	= $D207  ; write only

AUDCTL	= $D208  ; write only

STIMER	= $D209  ; write only
SKREST	= $D20A  ; write only
POTGO	= $D20B  ; write only

SEROUT	= $D20D  ; write only
IRQEN	= $D20E  ; write only
SKCTL	= $D20F  ; write only

;----------------------------------------
; PIA:
;----------------------------------------

PORTA	= $D300  ; read and write
PORTB	= $D301  ; read and write
PACTL	= $D302  ; read and write
PBCTL	= $D303  ; read and write

;----------------------------------------
; ANTIC:
;----------------------------------------

VCOUNT	= $D40B  ; read only

PENH	= $D40C  ; read only
PENV	= $D40D  ; read only

NMIST	= $D40F  ; read only


DMACTL	= $D400  ; write only
CHACTL	= $D401  ; write only
DLISTL	= $D402  ; write only
DLISTH	= $D403  ; write only
HSCROL	= $D404  ; write only
VSCROL	= $D405  ; write only
PMBASE	= $D407  ; write only
CHBASE	= $D409  ; write only
WSYNC	= $D40A  ; write only
NMIEN	= $D40E  ; write only
NMIRES	= $D40F  ; write only

;----------------------------------------
; Shadow registers:
;----------------------------------------

SDMCTL	= 559	; shadow of DMACTL
GPRIOR	= 623	; shadow of PRIOR

PCOLR0	= 704	; shadow of COLPM0
COLOR0	= 708	; shadow of COLPF0

RTCLOCK	= 20
ATRACT	= 77

CHBAS	= 756	; shadow of CHBASE
CH		= 764
CHACT	= 755

SDLSTL	= 560	; display list address
VDSLST	= 512	; DLI address

PADDL0	= 624	; 0-228 , shadow of POT0
PTRIG0	= 636	; 0 = PRESSED , shadow of PTRG0
STICK0	= 632	; 0000 = RLDU , shadow of PORTA
STRIG0	= 644	; 0 = PRESSED , shadow of TRIG0

COLDST	= 580	; non zero --> do a cold start when pressing the reset key

;----------------------------------------
; VBI:
;----------------------------------------

XITVB_I			= 58463
XITVB_D			= 58466
VBI_I			= 6
VBI_D			= 7
NORMAL_VBI_I	= 49378
NORMAL_VBI_D	= 49802
SETVBV			= 58460
VVBLKI			= 546
VVBLKD			= 548
XITVB			= XITVB_D

;----------------------------------------
; Handler vectors:
;----------------------------------------

NMIH_VECTOR		= 65530
RESH_VECTOR		= 65532
IRQH_VECTOR		= 65534

;----------------------------------------
; I/O:
;----------------------------------------

CIOV			= $E456	; (58454)
SIOV			= $E459	; (58457)

;----------------------------------------
; Bit values:
;----------------------------------------

; DMA values
DV_DMA_ON			= %00100000
DV_PM_ONE_LINE		= %00010000
DV_PLAYERS_ON		= %00001000
DV_MISSILES_ON		= %00000100
DV_WIDE_PF			= %00000011
DV_NORMAL_PF		= %00000010
DV_NARROW_PF		= %00000001

; Display list values
DL_DLI_MASK		= %10000000
DL_LMS_MASK		= %01000000
DL_VSCROLL_MASK	= %00100000
DL_HSCROLL_MASK	= %00010000

DL_JMP		= 1
DL_JVB		= 65

DL_BLANK_1	= 0
DL_BLANK_2	= 16
DL_BLANK_3	= 32
DL_BLANK_4	= 48
DL_BLANK_5	= 64
DL_BLANK_6	= 80
DL_BLANK_7	= 96
DL_BLANK_8	= 112

; Antic graphic modes
GM_CHAR_A2	= 2			; 2 colors, 40x24, 960b, 40xline, 8 scanlines
GM_CHAR_A6	= 6			; 4 colors, 20x24, 480b, 40xline, 8 scanlines
GM_CHAR_A7	= 7			; 4 colors, 20x12, 240b, 20xline, 16 scanlines
GM_CHAR_A4	= 4			; 5 colors, 40x24, 960b, 40xline, 8 scanlines
GM_CHAR_A5	= 5			; 5 colors, 40x12, 480b, 40xline, 16 scanlines
GM_CHAR_A3	= 3			; 2 colors, 40x24, 760b, 40xline, 10 scanlines

; Basic graphic modes
GM_CHAR_G0	= 2			; 2 colors, 40x24, 960b, 40xline, 8 scanlines
GM_CHAR_G1	= 6			; 4 colors, 20x24, 480b, 40xline, 8 scanlines
GM_CHAR_G2	= 7			; 4 colors, 20x12, 240b, 20xline, 16 scanlines
GM_CHAR_G12	= 4			; 5 colors, 40x24, 960b, 40xline, 8 scanlines
GM_CHAR_G13	= 5			; 5 colors, 40x12, 480b, 40xline, 16 scanlines

GM_PIXEL_G3	= 8			; 4 colors, 40x24, 240b, 10xline, 8 scanline
GM_PIXEL_G4	= 9			; 2 colors, 80x48, 480b, 10xline, 4 scanline
GM_PIXEL_G5	= 10		; 4 colors, 80x48, 960b, 20xline, 4 scanline
GM_PIXEL_G6	= 11		; 2 colors, 160x96, 1920b, 20xline, 2 scanline
GM_PIXEL_G7	= 13		; 4 colors, 160x96, 3840b, 40xline, 2 scanline
GM_PIXEL_G8	= 15		; 2 colors, 320x192, 7680b, 40xline, 1 scanline
GM_PIXEL_G14	= 12	; 2 colors, 160x192, 3840b, 20xline, 1 scanline
GM_PIXEL_G15	= 14	; 4 colors, 160x192, 7680b, 40xline, 1 scanline

GM_PIXEL_G9	= 15		; 1 color, 80x192, 7680b, 40xline, 1 scanline
GM_PIXEL_G10	= 15	; 9 colors, 80x192, 7680b, 40xline, 1 scanline
GM_PIXEL_G11	= 15	; 16 colors, 80x192, 7680b, 40xline, 1 scanline

; Prior values
PRV_PM_PRIORITY_1	= %00000001		; p0 p1 p2 p3 / pf0 pf1 pf2 pf3 (p5) / bk
PRV_PM_PRIORITY_2	= %00000010		; p0 p1 / pf0 pf1 pf2 pf3 (p5) / p2 p3 / bk
PRV_PM_PRIORITY_3	= %00000100		; pf0 pf1 pf2 pf3 (p5) /  p0 p1 p2 p3 / bk
PRV_PM_PRIORITY_4	= %00001000		; pf1 pf2 /  p0 p1 p2 p3 / pf0 pf3 (p5) / bk
PRV_FIFTH_PLAYER	= %00010000
PRV_PM_OVERLAP		= %00100000
PRV_GTIA_9			= %01000000
PRV_GTIA_10			= %10000000
PRV_GTIA_11			= %11000000

; Gractl values
GCTL_MISSILES		= %001
GCTL_PLAYERS		= %010
GCTL_LATCH_TRIGGERS	= %100

; Consol values:
CNV_START_MASK		= %001
CNV_OPTION_MASK		= %010
CNV_SELECT_MASK		= %100

; Stick values:
STV_RIGHT_MASK		= %1000
STV_LEFT_MASK		= %0100
STV_DOWN_MASK		= %0010
STV_UP_MASK			= %0001

STICK_MASK_RIGHT	= %1000
STICK_MASK_LEFT		= %0100
STICK_MASK_DOWN		= %0010
STICK_MASK_UP		= %0001

STICK_VALUE_RIGHT	= %0111
STICK_VALUE_LEFT	= %1011
STICK_VALUE_DOWN	= %1101
STICK_VALUE_UP		= %1110


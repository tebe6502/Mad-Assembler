;GTIA ==============================
GTIA	= $D000
HPOSP=$D000 ; 53248 ; horizontal position player
HPOSP0	= $D000
HPOSP1	= $D001
HPOSP2	= $D002
HPOSP3	= $D003

HPOSM=53252         ; horizontal position missiles
HPOSM0	= $D004
HPOSM1	= $D005
HPOSM2	= $D006
HPOSM3	= $D007

SIZEP = $D008       ; horizontal size player
SIZEP0	= $D008
SIZEP1	= $D009
SIZEP2	= $D00A
SIZEP3	= $D00B

SIZEM	= $D00C       ; horizontal size missile

GRAFP0	= $D00D     ; direct player write access without Antic
GRAFP1	= $D00E
GRAFP2	= $D00F
GRAFP3	= $D010

GRAFM	= $D011       ; direct missile write access without Antic

COLPM=$D012         ; color register player/missile
COLPM0	= $D012     ; shadow is 704
COLPM1	= $D013
COLPM2	= $D014
COLPM3	= $D015

COLPF=$D016         ; color register playfield
COLPF0	= $D016     ; shadow is 708
COLPF1	= $D017
COLPF2	= $D018
COLPF3	= $D019

COLBAK	= $D01A     ; color register background (shadow is 712)

COLBK	= $D01A 	;alias of COLBAK

; .enum	@prior
; 	prior0	= %0
; 	prior1	= %1
; 	prior2	= %10
; 	prior4	= %100
; 	prior8	= %1000
; 	ply5	= %10000	; Fifth Player Enable
; 	mlc	= %100000	; Multiple Color Player Enable
; 	mode9	= %01000000
; 	mode10	= %10000000
; 	mode11	= %11000000
; .ende

PRIOR	= $D01B       ; direction access for playfield to player/missiles

VDELAY	= $D01C     ; hardware scrolling in low res player/missiles 1 bit only

; .enum	@gractl
; 	missiles= %1
; 	players	= %10
; 	trigs	= %100
; .ende

GRACTL	= $D01D     ; player/missiles on/off
HITCLR	= $D01E     ; clear all collision registers
CONSOL	= $D01F     ; status of START, OPTION, SELECT

; collisions
M0PF	= $D000
M1PF	= $D001
M2PF	= $D002
M3PF	= $D003

P0PF	= $D004
P1PF	= $D005
P2PF	= $D006
P3PF	= $D007

M0PL	= $D008
M1PL	= $D009
M2PL	= $D00A
M3PL	= $D00B

P0PL	= $D00C
P1PL	= $D00D
P2PL	= $D00E
P3PL	= $D00F

TRIG0	= $D010
TRIG1	= $D011
TRIG2	= $D012
TRIG3	= $D013

PAL	= $D014 ; 53268 ; 1=PAL, $E=NTSC

;Pokey ==============================
POKEY	= $D200

AUDF1	= $D200
AUDF2	= $D202
AUDF3	= $D204
AUDF4	= $D206

AUDC1	= $D201
AUDC2	= $D203
AUDC3	= $D205
AUDC4	= $D207

POT0	= $D200
POT1	= $D201
POT2	= $D202
POT3	= $D203
POT4	= $D204
POT5	= $D205
POT6	= $D206
POT7	= $D207

AUDCTL	= $D208
ALLPOT	= $D208
POTST	= $D208

STIMER	= $D209

KBCODE	= $D209

SKRES	= $D20A
RANDOM	= $D20A
POTGO	= $D20B
SEROUT	= $D20D
SERIN	= $D20D
IRQEN	= $D20E
IRQST	= $D20E
SKCTL	= $D20F
SKSTAT	= $D20F

;PIA ==============================
PIA	= $D300
PORTA	= $D300
PORTB	= $D301
PACTL	= $D302
PBCTL	= $D303

;ANTIC ==============================
ANTIC	= $D400

 .enum	@dmactl
 	blank	= %00
 	narrow	= %01
 	standard= %10
 	wide	= %11
 	missiles= %100
 	players	= %1000
 	lineX1	= %10000
 	lineX2	= %00000
 	dma	= %100000
 .ende
 
 scr48	= @dmactl(wide|dma|players|missiles|lineX1)		;screen 48b
 scr40	= @dmactl(standard|dma|players|missiles|lineX1)		;screen 40b
 scr32	= @dmactl(narrow|dma|players|missiles|lineX1)		;screen 32b
 

DMACTL	= $D400 ; DMA Register (Shadow of 559)
CHACTL	= $D401 ; page to character list

DLISTL	= $D402 ; Start address of Display List
DLISTH	= $D403

HSCROL	= $D404 ; horizontal scrolling in "color clocks"! Bitwise in high res (320pixel) not possible

VSCROL	= $D405 ; vertical scrolling

PMBASE	= $D407 ; Start off player/Missiles (1k (lowres) or 2k(highres))

CHBASE	= $D409 ; Start address of font

WSYNC	= $D40A ;54282  ; insert value, hold on the 6502-CPU until next line

VCOUNT	= $D40B ; 54283 ; vertical screen line / 2 at PAL 0-155, NTSC 0-131

PENH	= $D40C
PENV	= $D40D

NMIEN	= $D40E   ; mask for interrupts
NMIRES	= $D40F ; clear current interrupt register
NMIST	= $D40F   ; contains bit of current interrupt


;ANTIC display list commands
DL_E1	= $00     ; empty lines
DL_E2	= $10
DL_E3	= $20
DL_E4	= $30
DL_E5	= $40
DL_E6	= $50
DL_E7	= $60
DL_E8	= $70

DL_JUMP	= $01   ;jump to adress and create one empty line
DL_LOOP	= $41   ;jump to adress and wait for vsync
DL_ADDRES	= $40 ;load memory counter
DL_DLI	= $80   ;dli interrupt
DL_HS	= $10     ;horizontal scroll
DL_VS	= $20     ;vertical scroll

;BASIC XL GR-codes:
DL_GR0	= $02   ;text hi-res mode 40 bytes/line 8 pixel per line
DL_A3	  = $03   ;hi-res text mode 8x10 pixel char, 40 bytes/line 10 pixel per line
DL_GR12 = $04   ;text - 4+1 color, 1 line V
DL_GR13 = $05   ;text - 4+1 color, 2 line V
DL_GR1	= $06   ;4 color text mode 20 bytes/line, 1 line V
DL_GR2	= $07   ;4 color text mode 20 bytes/line, 2 line V

DL_GR3	= $08   ;4 color graphics mode 10 bytes/line, 8 line V
DL_GR4	= $09   ;1 color graphics mode 10 bytes/line, 4 line V
DL_GR5	= $0A   ;4 color graphics mode, 20 bytes/line, 4 line V
DL_GR6	= $0B   ;1 color graphics mode, 20 bytes/line, 2 line V
DL_GR14	= $0C   ;1 color graphics mode, 20 bytes/line, 1 line V
DL_GR7	= $0D   ;4 color graphics mode, 40 bytes/line, 2 line V
DL_GR15	= $0E   ;4 color graphics mode, 40 bytes/line, 1 line V
DL_GR8	= $0F   ;graphics hi-res mode 40 bytes/line

; GTIA Graphics modes
DL_GR9	= $0F   ;graphics hi-res mode 40 bytes/line PRIOR=$40
DL_GR10	= $0F   ;graphics hi-res mode 40 bytes/line PRIOR=$80
DL_GR11	= $0F   ;graphics hi-res mode 40 bytes/line PRIOR=$C0




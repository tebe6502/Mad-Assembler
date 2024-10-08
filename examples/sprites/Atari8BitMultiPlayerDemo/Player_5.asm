; Player Missile Demo
;
; Shows how one can draw multiple players on the screen
; by using just one player (PL0)
;
; This is accomplished by writing player data directly into
; the grafp0 register one scan line at a time
;
; This version uses a table driven dli kernel routine
; It is possible to move each player 0.n independly in all
; directions
;
; Drawback: Two players at same y pos. can not be displayed at
; the same time. If the do, they clear each other.....
; To solve this problem, avoid assigning 2 ore more player 0, n etc.. the 
; same y pos. To solve this, you must define another player, as shown
; in the dli kernel (Player 0 is displayed 7 times, player's 1+2 are
; displayed 1 time each (bounching ball....)
; 
;
;
; Rev: 27.1.2015
;

; ANTIC

DLPTR	EQU 560	
VDLIST	EQU $200	 
NMIEN	EQU $D40E
WSYNC	EQU $D40A
VCOUNT	EQU $D40B
RTCLK	EQU $14
SDMCTL	EQU 559

; COLORS

COLPF0	EQU 708  
COLPF1	EQU 709 
COLPF2	EQU 710
COLPF3	EQU 711
COLBAK	EQU 712

COLPF0S	EQU $D016 
COLPF1S	EQU $D017
COLPF2S	EQU $D018
COLPF3S	EQU $D019
COLBAKS	EQU $D01A

; DISK I/O

DSKINV	EQU $E453  
DSKCMD	EQU $302	  
DSKAUX1	EQU $30A      
DSKDEV	EQU $300   
DSKUNIT	EQU $301	  
DSKBY	EQU $308   
DSKBUFF	EQU $304   
DSKTMOT	EQU $306 

; PM GRAPHICS

PMADR	EQU $B800 
PMCNTL	EQU $D01D 

HPOSP0	EQU $D000 
HPOSP1	EQU $D001
HPOSP2	EQU $D002
HPOSP3	EQU $D003

SIZEP0	EQU $D008 
SIZEP1	EQU $D009
SIZEP2	EQU $D00A
SIZEP3	EQU $D00B

COLPM0	EQU 704   
COLPM1	EQU 705
COLPM2	EQU 706
COLPM3	EQU 707

PMBASE	EQU $D407

GRACTL	EQU $D01D 

; Zeropage

ZP		equ $e0
zp2		equ $e2
zp3		equ $e4
zp4		equ $e6
zp5		equ	$e8
zp6		equ $ea
zp7		equ $ec
zp8		equ $ee

;
; MAIN
;

	org $a800
	
	lda #<dlist		; Display list on
	sta dlptr	
	lda #>dlist
	sta dlptr+1
	

	
	lda #<dli   	; Display- List- Interrupt on
	sta vdlist
	lda #>dli
	sta vdlist+1
	lda #$C0
	sta NMIEN
	
	ldy #<vbi		; Immediate VBI on!
	ldx #>vbi
	lda #6
	jsr $e45c

	lda #32+2		; PM DMA off+ normal screen width
	sta sdmctl
	
	lda #14
	sta colbak

	;
	; Main loop
	;
	; Move 'all' Player's 0 :-) => DLI enables indepentend movement
	;

end
	jmp end
	
;
; VBI
;
; Do something on the screen, while electron beam
; returns to the left upper corner of TV => nobody will
; notice anything :-)
;

wt	.byte 2

; Delta y/x  table for player 2+3

yc	.byte 0
ytb	.byte 1,1,1,1,1,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1
xc	.byte 0
xtb	.byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

vbi
	;
	; Draw Players, the lazy way. Could be table driven.....
	;

	dec wt
	beq gon
	jmp xt
gon	
	lda #2
	sta wt
	
	;---------------; Player 0

	ldy y1			; Player 0.1
	ldx #9
pp1
	lda pl1,x
	sta pm1,y
	lda x1
	sta pm1x,y
	lda co1,x
	sta pm1c,y

	iny
	dex
	bne pp1
	
	ldy y2
	ldx #10
pp2
	lda pl2,x		; Player 0.2
	sta pm1,y
	lda x2
	sta pm1x,y
	lda co2,x
	sta pm2c,y
	iny
	dex
	bne pp2
	
	ldy y3
	ldx #10
pp3
	lda pl3,x		; Player 0.3
	sta pm1,y
	lda x3
	sta pm1x,y
	lda co3
	sta pm3c,y
	iny
	dex
	bne pp3
	
	ldy y4
	ldx #10
pp4
	lda pl3,x		; Player 0.4
	sta pm1,y
	lda x4
	sta pm1x,y
	lda co3
	sta pm3c,y
	iny
	dex
	bne pp4	
	
	ldy y5
	ldx #10
pp5
	lda pl1,x		; Player 0.5
	sta pm1,y
	lda x5
	sta pm1x,y
	lda co3
	sta pm3c,y
	iny
	dex
	bne pp5
	
	ldy y6
	ldx #10
pp6
	lda pl1,x		; Player 0.6
	sta pm1,y
	lda x6
	sta pm1x,y
	lda co3
	sta pm3c,y
	iny
	dex
	bne pp6
	
	ldy y7
	ldx #10
pp7
	lda pl3,x		; Player 0.7
	sta pm1,y
	lda x7
	sta pm1x,y
	lda co3
	sta pm3c,y
	iny
	dex
	bne pp7
	
	;---------------: Player 1

	ldy y8
	ldx #10
pp8
	lda pl4c1,x		; Player 1.0
	sta pm2,y
	lda x8
	sta pm2x,y
	lda #100
	sta pm2c,y
	iny
	dex
	bne pp8
	
	;---------------; Player 2

	ldy y9
	ldx #10
pp9
	lda pl4c2,x		; Player 2.0
	sta pm3,y
	lda x9
	sta pm3x,y
	lda #155
	sta pm3c,y
	iny
	dex
	bne pp9
	
	;
	; move players
	;
	
	inc x1
	dec x2
	inc x3
	inc x3
	inc x3
	
	inc x4
	inc x4

	dec x5
	
	inc x6
	dec x7
	dec x7
	
	; Move player 2+3

	lda yc
	cmp #25	; Table length
	bne goo		
	lda #0
	sta yc
goo
	tax
	lda ytb,x	; Delta y=0?
	beq xxx		; Yes! Move in x Dir
	bmi minus	; No, check if minus?
	
	lda y8		; y=y+1
	clc
	adc #1
	sta y8
	
	lda y9
	clc
	adc #1
	sta y9
	jmp xxx
minus
	lda y8		; y=y-1
	sec
	sbc #1
	sta y8
	
	lda y9
	sec
	sbc #1
	sta y9
	
	; Change x pos

xxx		
	inc yc
	lda xc
	cmp #30	; Table length
	bne goo2		
	lda #0
	sta xc
goo2
	tax
	lda xtb,x	; Delta x=0?
	beq nomv	; Yes! Do nothing
	bmi minus2	; No, check if minus?
	
	lda x8		; x=x+1
	clc
	adc #1
	sta x8
	
	lda x9
	clc
	adc #1
	sta x9
	jmp nomv
minus2
	lda x8		; x=x-1
	sec
	sbc #1
	sta x8
	
	lda x9
	sec
	sbc #1
	sta x9
nomv	
	inc xc		; Next delta y
	
xt
	jmp $e45f	; Leave VBI

;
; DLI
;

y1	.byte 60	; Player Pos.
x1	.byte 40

y2	.byte 70
x2 	.byte 60

y3	.byte 80
x3	.byte 60

y4	.byte 90
x4	.byte 10

y5	.byte 100
x5	.byte 45

y6	.byte 110
x6	.byte 49

x7	.byte 120
y7	.byte 120

x8	.byte 120
y8	.byte 120

x9	.byte 120
y9	.byte 120

; Player 1

pl1	.byte 0,119	,	34	,	127	,	249	,	249	,	127	,	34	,	119
co1	.byte 0,0,255,33,70,70,33,255,0; Color

; Player 2

pl2 .byte 0,0,231,36,126,219,126,60,102,195,0
co2	.byte 0,0,255,255,60,60,60,60,255,255,255

xw2	.byte 2

; Player 3

pl3	.byte 0,0,255,129,129,129,129,129,255,0,0 
co3	.byte 0,255,10,10,10,10,10,255

; Player 4

pl4c1	.byte 0,0,60	,	66	,	129	,	129	,	129	,	129	,	66	,	60,0,0
pl4c2	.byte 0,0,0	,	48	,	64	,	64	,	64	,	64	,	48	,	0,0,0


dli
	pha			;  Save registers
	txa
	pha
	tya
	pha

	ldy #0		; Line counter
	
	lda #45		; Set colors for
	sta $d013	; player 1+2
	lda #100
	sta $d014
	
	sta wsync
	
screenl
	
	;
	; From here on, changes will appaer 
	; on scan line basis, rather than affecting the whole screen
	
	; 8 times player 0 ! :-)

	lda pm1,y	; Get shape data and x pos. from
	ldx pm1x,y	; pre- initialized array
	;sta wsync	; Wait for scanline to finish
	sta 53261	; Write player 0 data
	stx hposp0	; Set x- pos
	sty $d012	; Change player 0 color	stx wsync
	

	; 1 time player 1
	
	lda pm2,y	; Get shape data of player 1
	ldx pm2x,y	; Get hpos for player 1

	;sta wsync  ; IF YOU ENABLE THIS WSYNC, EACH PLAYER IS
				; DISPLAYED IN DOUBLE LINE RESOLUTION
				; SCREEN WILL ALSO BE IN DOUBLE LINE RES.
				; (E.G. : IF YOU CHANGE THE BK COLOR, EACH COLOR
				; CHANGE TAKES 2 SCANLINES)
				; WHY SHOULD ONE DO THIS?

	sta 53262	; Write data for player 1
	stx hposp1	; Set hpos for player 1

	; 1 time player 2

	lda pm3,y	; Get shape data of player 2
	ldx pm3x,y	; Get hpos for player 2
	;sta wsync
	sta 53263	; Write data for player 2
	stx hposp2	; Set hpos for player 2

	; Playfield color....

	lda pfcol,y
	sta wsync
	sta colbaks
	sta colpf2s

	inx			; increase color
	iny			; Next scan line
	cpy #200
	bne screenl

dlout
	pla			; Get registers back
	tay
	pla
	tax
	pla

	rti
	
;
; ANTIC
;

dlist
	.byte 112+$80,112,112
	.byte $40+6,a(screen)
:10	.byte 2
	.byte $41,a(dlist)
	
; 
; Background color
;

pfcol
:50	.byte 14
:50	.byte 6
:50	.byte 8
:50	.byte 14

	
screen
		.byte "multi player demo   "
	  	.byte "How many can you count?                 "
		.byte "Belive me, the only thing you can see   "
		.byte "are Players 0 (horizontal moving) and   "
		.byte "Players 1+2 (bounching ball...)         "
		.byte "                                        "
		.byte "DEMO_5.ASM // 27.1.2015                 "
:4		.byte "                                        "

pm1
:300	.byte 0
pm1x	
.byte 0
pm1c
:300	.byte 0

pm2
:300	.byte 0
pm2x	
:300	.byte 0
pm2c
:300	.byte 0
pm3
:300	.byte 0
pm3x	
:300	.byte 0
pm3c
:300	.byte 0
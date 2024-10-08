; Player Missile Demo
;
; Shows how one can draw multiple players on the screen
; by using just one player (PL0)
;
; This is accomplished by writing player data directly into
; the grafp0 register one scan line at a time
;
; This version uses the 'vcount' register to set
; the players y-position => now it is possible to change x and y pos
;
; X and Y pos are changed during VBI. Every object has it's own speed
; assigned, so they move independly at their own peace....
;
; >>>>>>>ISSUE: If the upermost Player, say y=50, moves down and reaches y pos of the
; second player, second player will also start to move down....
;
; Each player now has it's own color table which defines the color
; of each scan line of the player.....
;
; Player 1 and 2 are now animated. All data can be found in the header of
; the DLI- service routine.
;
; Player 1 and 2 are  now prototype's for an generlized game engine
; See header of player 1 definition in sub 'DLI'
;
; Rev: 15.1.2015
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
zp1		equ $e2
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
	
	lda #46			; PM on
	sta sdmctl

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

vbi

;---------Move player 1

	dec xw1sav	; Wait ?
	bne on1		; Yes!
	
	; Move it!
	
	lda f1sav
	cmp f1cnt
	bne anim	; All frames?
	lda #0
	sta f1sav	; Yes, reset it
anim				
	asl			; Get adress of next frame and
	tax
	lda f1,x	; put it into zp 
	sta zp		; DLI writes player data from there
	inx
	lda f1,x
	sta zp+1
	inc f1sav	; Next frame
	inc x1		; Move player	
	lda xw1		; Reset wait
	sta xw1sav
	
;---------Move player 2

on1
	dec xw2sav 	; Wait ?
	bne on2
	
	; Move it!
	
	lda f2sav
	cmp f2cnt
	bne anim2	; All frames?
	lda #0
	sta f2sav	; Yes, reset it
anim2				
	asl			; Get adress of next frame and
	tax
	lda f2,x	; put it into zp 
	sta zp1		; DLI writes player data from there
	inx
	lda f2,x
	sta zp1+1
	inc f2sav	; Next frame
	inc x2		; Move player	
	lda xw2		; Reset wait
	sta xw2sav

;---------MMove Player 3

on2	
	inc x3		; No wait this time :-)
	jmp $e45f	; Leave VBI

;
; DLI
;

;------------Player 1.1

x1	.byte 100											; Position on screen
y1	.byte 50

f1	.word pl1,pl11,pl12,pl11							; Pointers, determines order of frames 

f1cnt	.byte 4											; # of frames, frame counter
f1sav	.byte 0											; Storage for present frame

pl1		.byte $00,$00,$7c,$42,$b7,$e7,$d2,$92,$0c,$00	; Frame Data
pl11	.byte $00,$00,$7c,$42,$b7,$e7,$d2,$12,$0c,$00
pl12	.byte $00,$00,$7c,$42,$b7,$e7,$12,$12,$0c,$00

co1	 	.byte 255,255,255,40,40,40,255,255,255			; Color of each scanline of player

xw1		.byte 3											; Number of cycles, until object moves => Determines speed
xw1sav	.byte 1											; Temp. storage
		
;------------Player 1.2

x2	.byte 60
y2	.byte 80

f2	.word pl2,pl22,pl23,pl22							

f2cnt	.byte 4											
f2sav	.byte 0											

pl2 	.byte 0,255,36,36,126,219,219,126,60,102,195
pl22	.byte 0,231,255,36,126,219,219,126,60,102,195
pl23	.byte 0,231,36,255,126,219,219,126,60,102,195

co2		.byte 0,0,255,255,60,60,60,60,255,255,255

xw2		.byte 4
xw2sav	.byte 1

;------------ Player 1.3

x3	.byte 100
y3	.byte 200

pl3	.byte 0,255,129,129,129,129,129,255 
co3	.byte 0,255,10,10,10,10,10,255

xw3	.byte 1


dli
	pha			;  Save registers
	txa
	pha
	tya
	pha
	
	;
	; First PL0 => Player 1.1
	;

ply1	
	lda vcount	; Wait, until
	asl			; vcount reaches y1 pos
	cmp y1
	bcc ply1	; vcount<y1 => wait until y1 reached...
pp1	
	lda x1		; First PL0, set x pos
	sta hposp0
	
	ldy #9
loop1			; Draw first PL0
	lda (zp),y
	sta wsync
	sta $d00d
	
	lda co1,y
	sta $d012	; Change color
	dey
	bne loop1
	lda #0
	sta wsync	; Wait one scan line!
	sta $d00d	; Clear rest of player
	
	;
	; Second PL0 => Player 1.2
	;

ply2	
	lda vcount	; Wait until vcount reaches
	asl			; y2 pos
	cmp y2
	bcc ply2
pp2
	lda x2		; Second PL0 at new x pos
	sta hposp0
	
	ldy #11		
loop2			; Draw second PL0
	lda (zp1),y
	sta wsync
	sta $d00d
	lda co2,y
	sta $d012	; Color, shadow reg. for player 0
	dey
	bne loop2
	lda #0
	sta wsync	; Wait one scan line!
	sta $d00d	; Clear rest of player
	
	;
	; Third PL0 => Player 1.3
	;

ply3	
	lda vcount	; Wait until vcount reaches
	asl			; y3 pos
	cmp y3
	bcc ply3
pp3
	lda x3		; Third PL0 at new x pos
	sta hposp0
	
	ldy #7		
loop3			; Draw third PL0
	lda pl3,y
	sta wsync
	sta $d00d
	lda co3,y
	stx $d012	; Color, shadow reg. for player 0
	dey
	bne loop3
	lda #0
	sta wsync	; Wait one scan line!
	sta $d00d	; Clear rest of player
	
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
	.byte 112,112,112+$80
	.byte $40+$02,a(screen)
:24	.byte $02
	.byte $41,a(dlist)
	
screen
:800	.byte 0
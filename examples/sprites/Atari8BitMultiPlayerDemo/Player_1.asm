; Player Missile Demo
;
; Shows how one can draw multiple players on the screen
; by using just one player (PL0)
;
; This is accomplished by writing player data directly into
; the grafp0 register one scan line at a time
;
; Rev: 5.1.2015
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
	
	lda #46			; PM on
	sta sdmctl
	lda #150
	sta hposp0

;
; Move Player 0
;

end
	dec x1 
	inc x2
	dec x3
	dec x3

	
	ldx #140
w1
	ldy #80
w2
	dey
	bne w2
	dex
	bne w1
	jmp end	


; DLI

x1	.byte 200
y1	.byte 20
x2	.byte 80
x3	.byte 100

pl1	.byte 0,255,129,129,129,129,129,255 
pl2 .byte 0,231,36,36,126,219,219,126,60,102,195
pl3	.byte 0,255,129,129,129,129,129,255 


dli
	pha			;  Save registers
	txa
	pha
	tya
	pha
	
	ldy y1	; First, wait 20 scan lines
y1l
	sty wsync	
	lda #0
	sta wsync
	sta $d00d
	dey
	bne y1l	
	
	;
	; First PL0
	;
	
	lda x1		; First PL0, set x pos
	sta hposp0	
	
	ldy #7
	ldx #200
loop1			; Draw first PL0, beginning at scan line 20
	lda pl1,y
	sta wsync
	sta $d00d
	inx
	stx $d012	; Change color
	dey
	bne loop1
	
	ldy #15		; Second, wait some scan lines
y2l
	lda #0		; Clear PL0
	sta wsync
	sta $d00d
	dey
	bne y2l
	
	lda x2		; Second PL0 at new x pos
	sta hposp0
	
	;
	; Second PL0
	;
	
	ldy #11
	ldx #20
loop2			; Draw second PL0, beginning at scan line 20+7+5
	lda pl2,y
	sta wsync
	sta $d00d
	inx
	stx $d012	; Color, shadow reg. for player 0
	dey
	bne loop2
	
	ldy #5		; Third, wait some scan lines
y3l
	lda #0		; Clear PL0
	sta wsync
	sta $d00d
	dey
	bne y3l
	
	lda x3		; Third PL0 at new x pos
	sta hposp0
	
	;
	; Third PL0
	;
	
	ldy #7
	ldx #150
loop3			; Draw third PL0, beginning at scan line 20+7+5....
	lda pl3,y
	sta wsync
	sta $d00d
	inx
	stx $d012	; Color, shadow reg. for player 0
	dey
	bne loop3

	ldy #50
y4l
	lda #0		; Clear PL0 for rest of Screen
	sta wsync
	sta $d00d
	dey
	bne y4l
	
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
:20	.byte $02
	.byte $41,a(dlist)
	
screen
:800	.byte 0
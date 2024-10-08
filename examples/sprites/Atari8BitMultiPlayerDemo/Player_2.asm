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
; Rev: 6.1.2015
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
; Main loop
;
; Move 'all' Player's 0 :-) => DLI enables indepentend movement
;

end
	dec x1 
	inc x2
	dec x3
	
	
	ldx #50
w1
	ldy #50
w2
	dey
	bne w2
	dex
	bne w1
	jmp end	
	

;
; DLI
;

x1	.byte 200
y1	.byte 50

x2	.byte 60
y2	.byte 80

x3	.byte 100
y3	.byte 200

pl1	.byte 0,255,129,129,129,129,129,255 
pl2 .byte 0,231,36,36,126,219,219,126,60,102,195
pl3	.byte 0,255,129,129,129,129,129,255 


dli
	pha			;  Save registers
	txa
	pha
	tya
	pha
	
	;
	; First PL0
	;

ply1	
	lda vcount	; Wait, until
	asl			; vcount reaches y1 pos
	cmp y1
	bcc ply1
pp1	
	lda x1		; First PL0, set x pos
	sta hposp0
	
	ldy #7
	ldx #200	; Color of players first scan line
loop1			; Draw first PL0
	lda pl1,y
	sta wsync
	sta $d00d
	inx
	stx $d012	; Change color
	dey
	bne loop1
	lda #0
	sta wsync	; Wait one scan line!
	sta $d00d	; Clear rest of player
	
	;
	; Second PL0
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
	ldx #20		; Color of players first scan line
loop2			; Draw second PL0
	lda pl2,y
	sta wsync
	sta $d00d
	inx
	stx $d012	; Color, shadow reg. for player 0
	dey
	bne loop2
	lda #0
	sta wsync	; Wait one scan line!
	sta $d00d	; Clear rest of player
	
	;
	; Third PL0
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
	ldx #150	; Color of players first scan line
loop3			; Draw third PL0
	lda pl3,y
	sta wsync
	sta $d00d
	inx
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
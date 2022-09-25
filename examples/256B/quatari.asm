; Quatari - Jakub 'Ilmenit' Debski 07.2020
; 4 different effects with SFX in 256b on 8bit Atari

RANDOM	equ $d20a
WSYNC	equ $D40a
LMARGN  equ $52
RMARGN  equ $53
TIMER2  equ $14
TIMER1  equ $13
;;;;;; SOUND 
AUDF1	equ $D200
AUDF2	equ $D202
AUDF3	equ $D204
AUDF4	equ $D206
AUDC1	equ $D201
AUDC2	equ $D203
AUDC3	equ $D205
AUDC4	equ $D207
AUDCTL	equ $D208
STIMER	equ $D209

NMIEN   equ $D40E

;;;;;; GFX
COLOR   equ $2fb	;Color for graphics operations
GPRIOR  equ $26F

COLPF0	equ $D016
COLPF1	equ $D017
COLPF2	equ $D018
COLPF3	equ $D019
COLBK	equ $D01A

PCOLR0	equ $02C0				;p/m 0 color
PCOLR1	equ $02C1				;p/m 1 color
PCOLR2	equ $02C2				;p/m 2 color
PCOLR3	equ $02C3				;p/m 3 color

COLOR0	equ $02c4
COLOR1	equ $02c5
COLOR2	equ $02c6
COLOR3	equ $02c7
COLOR4	equ $02c8

ROWCRS	equ $54		;Row of cursor, 1 byte
COLCRS	equ $55		;Column of cursor, 2 bytes

OLDROW  equ $5A
OLDCOL  equ $5B     ; 2 bytes

VVBLKD  equ $0224
XITVBV  equ $e462

; Aliases, because orig reg names are hard to remember ;)
cursor_y    equ ROWCRS
cursor_x    equ COLCRS
prev_y      equ OLDROW
prev_x      equ OLDCOL

; OS functions
openmode  equ $ef9c
drawpoint equ $f1d8
drawto    equ $f9c2
putline   equ $c642
print     equ $f1a4


	org $80
_x:
	org $81
		
color_height: ; predefined, shorter than some manual initialization
	.byte 170,150
	.byte 144,144
	.byte 122,122
	.byte 110,110
	.byte 94,94
	.byte 86,86
	.byte 82,80

;#### start ####	

; the smallest and the simplest effect
.local maze
        lda #0
        sta TIMER2
_y equ *-1
	jsr openmode	; 3 bytes, Changes $7B (SWPFLG) on zero page to zero so we can't load data there        
        sta COLOR2   ; 0
loop:
	lda RANDOM
	clc
	and #1
color_loops:	; we are using this byte as color loops counter in Lights part
	adc #6
        jsr print        
	dec _x
	bne loop
	dec _y
	bne loop    	
.endl
		

; also a very small effect
.local sierpinski
	lda #$07		; 2 bytes
	jsr openmode	; 3 bytes, Changes $7B (SWPFLG) on zero page to zero so we can't load data there
	; A=00 X=07 Y=01

	stx color

; zero position
	
first_line:	
	ldy #96
	sty cursor_y

next_line:
	ldx #127
	stx cursor_x

next_pixel:
	lda cursor_x	
	and cursor_y	
	bne zero
	jsr drawpoint
zero:	
	dec cursor_x
	bpl next_pixel
	dec cursor_y
	bpl next_line

	; process next colors
	dec color
	bpl sierpinski.first_line
.endl

.local lights
	lda #11
	jsr openmode	
	lda #128    ; set gr. mode 10
	sta GPRIOR 
	sta PCOLR0+8 ; better colors

	;lda #1 ; y=1 after opening the mode
	sty color
	sty cursor_y			
loop1:
	ldx #79
		
	stx cursor_x
draw_line:
	; set prev to screen center
	ldx #40
	stx prev_x
		
	ldy #191		
	sty prev_y
	
	dec color
	bne skip_color_0
	lda #9
	sta color 
skip_color_0:
	jsr drawto
	dec cursor_x
	bpl draw_line

	; lines drawn, animate

next_loop
	ldx #8	
pal_loop:
	lda PCOLR0,x
	sta PCOLR0+1,x
	dex
	bne pal_loop	
	ldy PCOLR0+9
	sty PCOLR1
	
check_again:	
	lda TIMER2
	and #3
	bne check_again
	inc TIMER2		
	;inc value+1		
	dec maze.color_loops ; we use this byte as counter
	bpl next_loop
	
end:	
.endl

	
.local landscape
	lda #$9		
	jsr openmode	
	; pos_y = 0;
	;sty MY_VBL.pattern+1 
	;sty MY_VBL.control+1

	lda #$B0
	sta COLOR4
	
start:	
	lda #79
	sta prev_x	
	sta cursor_x


next_column:
	ldx #13
	stx color

draw_column:
	sty prev_y ; y=1
		
color_loop:	
	ldx color
	lda color_height,x	
	sta cursor_y
	tay
			
	lda RANDOM
	bpl skip1
	iny 
skip1:
	lda RANDOM
	bpl skip2
	dey 	
skip2:		
	sty color_height,x

	jsr drawto

	dec color
	bpl color_loop
	
	dec cursor_x
	dec prev_x	
	
	bpl next_column		
		
.endl

.local end
	bmi *	; infinite loop, smaller than jmp *
.endl
	
.local MY_VBL	
	sbc TIMER2
	ora #%10000011
	sta AUDC3			

pattern:	
	and #%11100100
	sta AUDF1
control: 
	ora #%01100010 
	sta AUDC1 		
	jmp XITVBV 
.end;
	
	org VVBLKD
	dta a(MY_VBL)
	
	RUN maze
	
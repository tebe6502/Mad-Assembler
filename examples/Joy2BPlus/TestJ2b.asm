; Programa Test Joystick 2b+
; Por Abel Carrasco
;------------------------------
; 01/05/2019 - first version 
; 06/04/2019 - change graphics
; 11/04/2021 - changes shared by Eyvind Bernhardsen :
;			 * allow testing of non-Joy2B sticks
;			 * buttons 2 and 3 only appear if they are present
;			 * tweak and add decay to the sounds
;			 * make the direction rose point in eight directions instead of four
; 12/04/2021 - change of text to english and new version 

RTCLOK = $14
ATRACT = $4d
VDSLST = $200
SDLSTL = $230
PADDL0 = $270
PADDL1 = $271
PADDL2 = $272
PADDL3 = $273
STICK0 = $278
STICK1 = $279
COLOR1 = $2c5
COLOR2 = $2c6
STRIG0 = $d010
STRIG1 = $d011
COLPF0 = $d016
COLBK  = $d01a
AUDF1  = $d200
AUDC1  = $d201
AUDF2  = $d202
AUDC2  = $d203
AUDF3  = $d204
AUDC3  = $d205
AUDF4  = $d206
AUDC4  = $d207
AUDCTL = $d208
PORTA  = $d300
WSYNC  = $d40a
NMIEN  = $d40e

	org $2000

; Program start
start
	mva #0 AUDCTL
	mva #59 AUDF1
	mva #71 AUDF2
	mva #84 AUDF3
	mva #107 AUDF4
	mwa #dl SDLSTL
	mwa #dli VDSLST
	mva #$c0 NMIEN
	mva #$30 COLOR2
	mva #$f COLOR1

; Joystick control
joystick
	mva #0 ATRACT
	lda STICK0
	drawDirection #%0101, #%0000, #$47, joy1_1+10	; up + left
	drawDirection #%1101, #%1100, #$7c, joy1_1+11	; up
	drawDirection #%1001, #%0000, #$46, joy1_1+12	; up + right
	drawDirection #%0111, #%0011, #$52, joy1_2+10	; left
	drawDirection #%1011, #%0011, #$52, joy1_2+12	; right
	drawDirection #%0110, #%0000, #$46, joy1_3+10	; down + left
	drawDirection #%1110, #%1100, #$7c, joy1_3+11	; down
	drawDirection #%1010, #%0000, #$47, joy1_3+12	; down + right
	setVolume prev_s1, vol_s1

	lda STICK1
	drawDirection #%0101, #%0000, #$47, joy2_1+10	; up + left
	drawDirection #%1101, #%1100, #$7c, joy2_1+11	; up
	drawDirection #%1001, #%0000, #$46, joy2_1+12	; up + right
	drawDirection #%0111, #%0011, #$52, joy2_2+10	; left
	drawDirection #%1011, #%0011, #$52, joy2_2+12	; right
	drawDirection #%0110, #%0000, #$46, joy2_3+10	; down + left
	drawDirection #%1110, #%1100, #$7c, joy2_3+11	; down
	drawDirection #%1010, #%0000, #$47, joy2_3+12	; down + right
	setVolume prev_s2, vol_s2

	sound vol_s1, vol_s2, AUDC1


; Buttons
	lda STRIG0
	readButton #$01, #"1", joy1_2+18, vol_a1
	lda STRIG1
	readButton #$10, #"1", joy2_2+18, vol_a2
	sound vol_a1, vol_a2, AUDC2

	lda PADDL0
	cmp #$e4
	readButton #$02, #"2", joy1_2+23, vol_b1
	lda PADDL2
	cmp #$e4
	readButton #$20, #"2", joy2_2+23, vol_b2
	sound vol_b1, vol_b2, AUDC3

	lda PADDL1
	cmp #$e4
	readButton #$04, #"3", joy1_2+28, vol_c1
	lda PADDL3
	cmp #$e4
	readButton #$40, #"3", joy2_2+28, vol_c2
	sound vol_c1, vol_c2, AUDC4

	ldx #0
	ldy #3
delay
	dex
	bne delay
	dey
	bne delay
	jmp joystick


; The drawDirection macro pushes the accumulator to the stack on entry
; and pops it back off on exit to allow chaining.

.macro drawDirection mask, value, char, pos
	pha
	and :mask
	cmp :value
	bne clear
	lda :char
	bne draw
clear
	lda #0
draw
	sta :pos
	pla
.endm

.macro setVolume prev, vol
	cmp :prev
	beq unchanged
	sta :prev
	cmp #$f
	beq not_held
	lda #$8f
	bne setvol
not_held
	lda #0
	beq setvol
unchanged
	lda :vol
	beq skip
	sec
	sbc #1
setvol
	sta :vol
skip
.endm

.macro sound v1, v2, channel
	lda :v1
	cmp :v2
	scs:lda :v2
	lsr
	lsr
	lsr
	lsr
	seq:ora #$a0
	sta :channel
.endm

.macro readButton mask, char, pos, vol
	beq pressed
	lda :exists
	ora :mask
	sta :exists
	mva :char+128 :pos
	lda #0
	beq setvol
pressed
	lda :exists
	and :mask
	beq next
	mva :char :pos
	lda :vol
	bne decay
	lda #$8f
	bne setvol
decay
	cmp #$f
	bcc next
	sbc #1
setvol
	sta :vol
next
.endm

exists
	.byte 0
vol_s1
	.byte 0
vol_s2
	.byte 0
prev_s1
	.byte 0
prev_s2
	.byte 0
vol_a1
	.byte 0
vol_a2
	.byte 0
vol_b1
	.byte 0
vol_b2
	.byte 0
vol_c1
	.byte 0
vol_c2
	.byte 0

; Display list
dl
:3	.byte $70
	.byte $70+$80
	.byte $47
	.word title
	.byte $40,$46
	.word author
	.byte $70,$70
	.byte $42
	.word blankline
	.byte $42
	.word joy1_1
	.byte $42
	.word joy1_2
	.byte $42
	.word joy1_3
	.byte $42
	.word blankline
	.byte $70
	.byte $42
	.word blankline
	.byte $42
	.word joy2_1
	.byte $42
	.word joy2_2
	.byte $42
	.word joy2_3
	.byte $42
	.word blankline
	.byte $70,$70,$42
	.word messages
	.byte $02
	.byte $41
	.word dl

; Diseño de textos
title
	.byte "   TESTER JOY 2B+   "
author
	.byte "  POR ASCRNET 2021  "

blankline
:40	.byte " "

joy1_1
:10	.byte " "
	.byte 0,92,0
:4	.byte " "
	.byte 72," "*,74
:2	.byte " "
	.byte 72," "*,74
:2	.byte " "
	.byte 72," "*,74
:10	.byte " "

joy1_2
:10	.byte " "
	.byte 94,"O",95
:4	.byte " "
	.byte "   "*
:2	.byte " "
	.byte "   "*
:2	.byte " "
	.byte "   "*
:10	.byte " "

joy1_3
:10	.byte " "
	.byte 0,93,0
:4	.byte " "
	.byte 202," "*,200
:2	.byte " "
	.byte 202," "*,200
:2	.byte " "
	.byte 202," "*,200
:10	.byte " "

joy2_1
:10	.byte " "
	.byte 0,92,0
:4	.byte " "
	.byte 72," "*,74
:2	.byte " "
	.byte 72," "*,74
:2	.byte " "
	.byte 72," "*,74
:10	.byte " "

joy2_2
:10	.byte " "
	.byte 94,"O",95
:4	.byte " "
	.byte "   "*
:2	.byte " "
	.byte "   "*
:2	.byte " "
	.byte "   "*
:10	.byte " "

joy2_3
:10	.byte " "
	.byte 0,93,0
:4	.byte " "
	.byte 202," "*,200
:2	.byte " "
	.byte 202," "*,200
:2	.byte " "
	.byte 202," "*,200
:10	.byte " "

messages
	dta " Buttons "
	dta "2"*
	dta " and "
	dta "3"*
	dta " will be activated when "
	dta "  a joystick with support is connected  "

; Display list interrupts
dli
	phr
	ldx #$0
dli_color1
	lda dli_colores1,x
	sta COLPF0
	sta WSYNC
	inx
	cpx #16
	bne dli_color1
	ldx #0
dli_color2
	lda dli_colores2,x
	sta COLBK
	sta WSYNC
	inx
	cpx #18
	bne dli_color2
	plr
	rti

; DLI colors
dli_colores1
	.byte $b0,$b0,$b0,$bf,$bf,$bc,$bc,$ba,$ba,$b8,$b8,$b6,$b6,$b4,$b4,$f
dli_colores2
	.byte $0,$0,$0,$2a,$28,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$28,$2a,$0

	run start

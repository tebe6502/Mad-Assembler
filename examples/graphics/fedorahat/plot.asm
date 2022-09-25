
open	= 3
close	= 12

	icl 'atari.hea'

	.extrn tmp1, tmp2	.byte

	.public plot, gr8

	.reloc


.proc plot (.word xa .byte y) .reg
	sta tmp1
	stx tmp1+1

	clc
	adc <lastY
	sta @lyPtr+1
	sta @lyPtr2+1
	txa
	adc >lastY
	sta @lyPtr+2
	sta @lyPtr2+2

@lyPtr:
	cpy lastY

	bcs @end

@lyPtr2:
	sty lastY

	lda grLinL,y
	ldx grLinH,y

	dec tmp1+1
	bmi @ok
	bne @end

	clc
	adc #32
	bcc @ok
	inx
@ok:
	sta tmp2
	stx tmp2+1
	ldx tmp1
	ldy grPos0,x
	lda grMask,x

	ora (tmp2),y
	sta (tmp2),y

@end:
	rts

.endp


.proc gr8
	ldx #$60
	lda #CLOSE
	jsr xcio

	lda #8+16
	sta ioaux2,x
	lda #0
	sta ioaux1,x
	mwa #devstr ioadr,x
	lda #OPEN
	jsr xcio

	lda SAVMSC
	ldx SAVMSC+1
	ldy #0

loop:
	sta grLinL,y
	clc
	adc #40
	pha
	txa
	sta grLinH,y
	adc #0
	tax
	pla

	iny
	cpy #192
	bne loop

	ldy #0
	lda #128
	ldx #0

loop2:
	pha
	txa
	sta grPos0,y
	pla
	sta grMask,y
	iny
	lsr @
	bcc loop2
	lda #128
	inx
	cpy #0
	bne loop2

outLoop2:
	lda #192
	ldy #160
loop3:
	sta lastY-1,y
	sta lastY+160-1,y
	dey
	bne loop3
	rts

xcio	sta iocom,x
	jmp ciov

devstr:
	dta c'S:',$9b

.endp

grPos0:	.ds 256
grMask:	.ds 256
grLinL:	.ds 192
grLinH: .ds 192
lastY:	.ds 320

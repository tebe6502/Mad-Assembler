
	.extrn mtmp, tmp1, tmp2, mul2	.byte

	.public sqrt, sine, InitSine

	.reloc


.proc sqrt (.word xa) .reg
	cpx #32
	bcc @ok

	lda <8192
	ldx >8192
	rts

	; Now, 0 <= X < 1.0
@ok:
	; X = X << 3
	stx mul2+1
	asl @
	rol mul2+1
	asl @
	rol mul2+1
	asl @
	rol mul2+1
	sta mul2

	lda #0
	sta mul2+2 ; H
	sta mul2+3
	sta mtmp   ; R
	sta mtmp+1
	ldy #13    ; 7 + 13/2

@loop:
	; R = R << 1
	asl mtmp
	rol mtmp+1
	; Q = H - R - 1
	; NOTE: accum = mul2+2
	sta mul2+2
	clc
	sbc mtmp
	tax
	lda mul2+3
	sbc mtmp+1
	bmi @nosub

	; H = Q
	sta mul2+3
	stx mul2+2
	; R += 2
	lda mtmp
	clc
	adc #2
	sta mtmp
	bcc @nosub
	inc mtmp+1

@nosub: ; H:X <<= 2
	lda mul2+2
	asl mul2
	rol mul2+1
	rol @
	rol mul2+3

	asl mul2
	rol mul2+1
	rol @
	rol mul2+3

	; Loop
	dey
	bne @loop

	lda mtmp
	ldx mtmp+1

	rts

.endp

.proc sine (.word xa) .reg
	stx mul2+1
	asl @
	rol mul2+1
	asl @
	rol mul2+1
	ror mul2+2
	asl @
	rol mul2+1
	; mul2+1 has the fractional part, mul2+2 has the sign (1 bits), C is the reflection
	bcc @noreflect

	lda mul2+1
	eor #255
	tay
	lda sineLo+1,y
	ldx sineHi+1,y

	bcs @invert

@noreflect:
	ldy mul2+1
	lda sineLo,y
	ldx sineHi,y

@invert:
	ldy mul2+2
	bpl @ok

	clc
	eor #255
	adc #1
	pha
	txa
	eor #255
	adc #0
	tax
	pla

@ok:    rts

.endp


.proc initSine

	iniSum = 54

	lda #iniSum
	sta tmp1

	lda #0
	sta mtmp
	sta mtmp+1
	tay
	tax

nextbyte:
	; Read next byte
	pha
	lda genTable,x
	sta tmp2
	pla

	inx
	stx mtmp+1
	ldx mtmp

	jsr genFour
	jsr genFour

	stx mtmp
	ldx mtmp+1
	cpx #32
	bne nextbyte

	lda #0
	sta sineLo+256
	lda #$20
	sta sineHi+256

	rts

genTable: .byte $f0,$00,$02,$00,$01,$00,$10,$04,$04,$04,$08,$20,$82,$10,$42,$21
	  .byte $08,$88,$44,$44,$44,$88,$89,$12,$24,$48,$92,$24,$89,$22,$49,$12

	; Generates one value
genFour:
	jsr genTwo
genTwo:
	jsr genOne
genOne:
	; AX = AX + sum
	sta sineLo,y
	pha
	txa
	sta sineHi,y
	pla
	iny

	clc
	adc tmp1
	bcc @noinc
	inx
@noinc:
	; Read bit, test if sum must be decreased
	asl tmp2
	bcc @nodec
	dec tmp1
@nodec:
	rts
.endp

sineHi:	.ds 257
sineLo:	.ds 257

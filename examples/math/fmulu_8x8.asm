* Unsigned multiplication
* A*X -> A:Y (A-high byte, Y-low)
* b. Fox/Tqa

/*
	org $2000

	jsr fmulu.init

	fmulu #123 , #22

	jmp *

*/


.proc fmulu (.byte a,x) .reg

sq1l	equ $a000
sq1h	equ $a200
sq2l	equ $a400
sq2h	equ $a600

	sta l1+1
	sta h1+1
	eor #$ff
	sta l2+1
	sta h2+1
	sec
l1	lda sq1l,x
l2	sbc sq2l,x
	tay
h1	lda sq1h,x
h2	sbc sq2h,x
	rts

init	ldx #0
	stx sq1l
	stx sq1h
	stx sq2l+$ff
	stx sq2h+$ff
	ldy #$ff
msq1	txa
	lsr @
	adc sq1l,x
	sta sq1l+1,x
	sta sq2l-1,y
	sta sq2l+$100,x
	lda #0
	adc sq1h,x
	sta sq1h+1,x
	sta sq2h-1,y
	sta sq2h+$100,x
	inx
	dey
	bne msq1
msq2	tya
	sbc #0
	ror @
	adc sq1l+$ff,y
	sta sq1l+$100,y
	lda #0
	adc sq1h+$ff,y
	sta sq1h+$100,y
	iny
	bne msq2
	rts

.endp

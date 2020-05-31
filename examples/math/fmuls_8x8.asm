* Signed multiplication
* A*X -> A:Y (A-high byte, Y-low)
* b. Fox/Tqa

/*
	org $2000

	jsr fmuls.init

	fmuls #123 , #9

	jmp *

*/


.proc fmuls (.byte a,x) .reg

sq1l	equ $a000
sq1h	equ $a200
sq2l	equ $a400
sq2h	equ $a600

	eor #$80
	sta l1+1
	sta h1+1
	eor #$ff
	sta l2+1
	sta h2+1
	txa
	eor #$80
	tax
	sec
l1	lda sq1l,x
l2	sbc sq2l,x
	tay
h1	lda sq1h,x
h2	sbc sq2h,x
	rts

init	ldx #0
	stx sq1l+$100
	stx sq1h+$100
	stx sq2l+$ff
	stx sq2h+$ff
	ldy #$ff
msqr	txa
	lsr @
	adc sq1l+$100,x
	sta sq1l,y
	sta sq1l+$101,x
	sta sq2l-1,y
	sta sq2l+$100,x
	lda #0
	adc sq1h+$100,x
	sta sq1h,y
	sta sq1h+$101,x
	sta sq2h-1,y
	sta sq2h+$100,x
	inx
	dey
	bne msqr
	rts

.endp
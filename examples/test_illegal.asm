
	org $2000

	ldx #$00

	lda #$ff

	lax test

	nop

	sta $bc40
	stx $bc40+1

jj	ldy $d20a
	sty $d01a
	jmp jj

test	dta d'!'



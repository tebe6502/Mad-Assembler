	.6502
frmcnt	equ	$76
	.org	$8000
	lda	frmcnt
	lsr
	bcc	.10
	nop
	bcs	.20
.10:
	nop
.20:
	asl
	sta	frmcnt
	jmp	$d069

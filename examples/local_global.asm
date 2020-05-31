
	org $2000

lp	ldx #0		; deklaracja globalna etykiety 'LP' 

	test
	test

test	.MACRO

	lda :lp		; znak ':' przed etykieta odczyta wartosc etykiety globalnej

	sta lp+1	; odwolanie do etykiety lokalnej 'LP' w makrze
lp	lda #0		; deklaracja etykiety lokalnej 'LP'

	.ENDM


	lda main.a

	lda main._sub.a


main	.LOCAL
a	dta 1

_sub	.LOCAL

a	dta 2

	lda main.a
	lda a

	.ENDL

	.ENDL

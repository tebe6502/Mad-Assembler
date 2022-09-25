
// przyklad deklaracji obszaru lokalnego i odwolania do niego

	org $2000

tmp	ldx #0			; etykieta w obszarze globalnym

	lda temp.pole		; odwolanie do obszaru lokalnego

temp	.local			; deklaracja obszaru lokalnego

	lda tmp			; odwołanie w obszarze lokalnym

	lda :tmp		; odwolanie do obszaru globalnego

tmp	nop			; deklaracja w obszarze lokalnym

pole	lda #0			; deklaracja w obszarze lokalnym

	lda pole		; odwolanie w obszarze lokalnym

	.endl			; koniec deklaracji obszaru lokalnego

	nop

temp	.local			; obszary mozna dodawac (addytywnosc)
	nop

	.endl


	.print .len temp	; długość ostatniego obszaru TEMP

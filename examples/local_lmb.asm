
	org $2000

	lmb #1

temp	nop		; not visible for main program

	lmb #2

temp	nop		; last declaration visible for main program
			;
	lmb #0		;
			;
main_program		;
			;
	lda temp	;

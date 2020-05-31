
/*
  POS XY

  Procedura ustawia pozycje X/Y kursora okreslone przez zmienne odpowiednio COLCRS ($55-$56) i ROWCRS ($54).

  Dla trybu znakowego (Graphics 0) starszy bajt pozycji poziomej kursora COLCRS rowny jest zawsze zeru.
  Starszy bajt pozycji poziomej kursora bedzie wykorzystywany podczas rysowania linii w trybach graficznych.

*/

COLCRS	= $55	;(2)
ROWCRS	= $54	;(1)

	.public	posxy

	.reloc

posxy	.proc (.byte x .byte y) .reg

	stx COLCRS
	sty ROWCRS

	mva #$00 COLCRS+1
	rts

	.endp

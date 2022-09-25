
/*
  PUT CHAR

  Procedura wyprowadza znak na ekran na pozycji X/Y kursora okreslonej przez zmienne odpowiednio
  COLCRS ($55-$56) i ROWCRS ($54). Zaklada sie, ze obowiazuja przy tym domyslne ustawienia OS-u,
  to jest ekran jest w trybie Graphics 0, a kanal IOCB 0 jest otwarty dla edytora ekranowego. 

  Wyprowadzenie znaku polega na zaladowaniu jego kodu ATASCII do akumulatora i wykonaniu rozkazu
  JSR PUTCHR. 
*/

icputb = $0346

	.public	putchar

	.reloc

putchar	.proc (.byte a) .reg

putchr	ldx #$00
	tay
	lda icputb+1,x
	pha
	lda icputb,x
	pha
	tya
	rts

	.endp

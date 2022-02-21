
/*
  PUT LINE

  Procedura wyprowadza na ekran ciag znaków (string) na pozycji X/Y kursora okreslonej przez
  zmienne odpowiednio COLCRS ($55-$56) i ROWCRS ($54). Ciag znaków musi byc zakończony znakiem
  RETURN ($9B). Zaklada sie, ze obowiazuja przy tym domyslne ustawienia OS-u, to jest ekran jest
  w trybie Graphics 0, a kanal IOCB 0 jest otwarty dla edytora ekranowego. 

  Maksymalna dopuszczalna dlugosc ciagu to 255 znaków lacznie ze znakiem konca EOL = $9B.

  Wyprowadzenie tekstu uzyskuje sie przez zaladowanie jego adresu do rejestrów A/Y
  (mlodszy/starszy) i wykonaniu rozkazu JSR PUTLINE. 
*/

iccmd    = $0342
icbufa   = $0344
icbufl   = $0348
jciomain = $e456

maxlen	 = $ff

	.public	putline

	.reloc

putline	.proc (.word ya) .reg

	ldx #$00
	sta icbufa,x
	tya
	sta icbufa+1,x

	mwa	#maxlen	icbufl,x

	mva	#$09	iccmd,x

	jmp jciomain

	.endp

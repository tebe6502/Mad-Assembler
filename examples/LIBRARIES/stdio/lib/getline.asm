
/*
  GETLINE

  Program czeka, az uzytkownik wpisze ciag znaków z klawiatury i nacisnie klawisz RETURN.
  Znaki podczas wpisywania sa wyswietlane na ekranie, dzialaja tez normalne znaki kontrolne
  (odczyt jest robiony z edytora ekranowego). 

  Wywolanie funkcji polega na zaladowaniu adresu, pod jaki maja byc wpisane znaki,
  do rejestrów A/Y (mlodszy/starszy) i wykonaniu rozkazu JSR GETLINE. 
*/

iccmd		= $0342
icbufa		= $0344
icbufl		= $0348
jciomain	= $e456

maxlen		= $ff

	.public getline

	.reloc

getline	.proc (.word ya) .reg

	ldx	#$00
	sta	icbufa,x
	tya
	sta	icbufa+1,x

	mwa	#maxlen	icbufl,x	;maks. wielkosc tekstu

	mva	#$05	iccmd,x
	jmp	jciomain

	.endp

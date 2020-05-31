
/*

 procedura wykorzystuje rekurencje makr, generujaca rozkazy 'sta adres+0..20'

*/

	org $2000

	lda #"A"

; --- wywolujemy makro LOOP
; --- pierwszy parametr to adres poczatkowy
; --- drugi parametr to liczba wywolan makra, czyli liczba powtorzen rozkazu 'STA ADRES+...'

	?licz = 0	// zerujemy definicje etykiety tymczasowej-globalnej ?LICZ

	LOOP $bc40,20

	jmp * 


.macro	LOOP

  .if ?licz<:2

   sta :1+?licz
   ?licz ++
   LOOP :1,:2

  .endif

.endm

	run $2000
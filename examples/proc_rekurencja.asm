/*
  Przyklad deklaracji procedury uzywajacej stosu programowego MADS-a i jej rekurencyjnego wywolywania,
 "zaglebiajacego" sie do 20 razy.
  
  Efektem dzialania sa wartosci z przedzialu <19..0> umieszczone od adresu $bc40.
  
  ostatnie zmiany: 31.07.2006
*/


@stack_pointer = $FF    // wskaznik stosu programowego
@stack_address = $400   // adres stosu programowego
@proc_vars_adr = over   // adres obszaru w ktorym skladowane sa przekazywane do procedur parametry

;---
	org $2000
;--- 

	lda #0			// dla pewnosci zerujemy wskaznik stosu @STACK_POINTER = 0
	sta @stack_pointer

	test #0			// wywolujemy procedure TEST, parametrem jest wartosc #0, lub inna wartosc <20

	jmp *			// petla bez konca, aby mozna bylo zobaczyc efekt dzialania


test	.proc (.byte war)	// deklaracja procedury TEST i parametru WAR typu BYTE

; tutaj po .PROC, MADS wymusza wykonanie makra @PULL, ktore zdejmuje ze stosu parametry i zapisuje
; od adresu @PROC_VARS_ADR
; zdjecie ze stosu parametrow nie powoduje modyfikacji wskaznika stosu programowego @STACK_POINTER

	lda war			// zwiekszamy przekazany parametr o 1
	add #1

	cmp #20			// sprawdzamy czy jest >= 20
	bcs quit

	test @			// jesli nie jest >=20 to ponownie wywolujemy procedure TEST

quit				// procedura TEST konczy sie, wracamy

	lda war			// wartosc parametru umieszczamy na ekranie
ekr	sta $bc40
	inc ekr+1

	rts		// wyjscie z procedury TEST, po ktorym nastapi modyfikacja
			// wskaznika stosu programowego @STACK_POINTER

.endp 


over		// od adresu OVER skladowane sa parametry przekazywane do procedur
		// @PROC_VARS_ADR = OVER

 opt l-
 icl 'macros/@call.mac'
 icl 'macros/@pull.mac'
 icl 'macros/@exit.mac'

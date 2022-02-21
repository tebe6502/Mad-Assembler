/*
 przykladowy program wykorzystujacy deklaracje procedury .PROC i programowy stos MADS'a

 program realizuje zamiane wartosci typu WORD na postac hexadecymalna

 ostatnia modyfikacja: 24.06.2007
*/

	org $2000

@stack_address = $400	; adres poczatku stosu - wymagana przez MADS deklaracja etykiety dla .PROC z parametrami
@stack_pointer = $ff	; wskaznik stosu       - wymagana przez MADS deklaracja etykiety dla .PROC z parametrami
@proc_vars_adr = $80	; obszar gdzie skladowane sa parametry przekazywane do procedur

main
	mva #0	@stack_pointer		; zerujemy wskaznik stosu programowego

	hex #$12b5 #$bc40+18+10*40	; wywolujemy procedure HEX, pierwszym parametrem jest wartosc #$12b5
					; drugi parametr to adres pamieci obrazu gdzie zostanie wyswietlony tekst z wartoscia HEX

	jmp *				; petla bez konca, aby zobaczyc efekt dzialania

* ----------- *
*  PROCEDURE  *
* ----------- *
// procedurka LHEX reprezentujaca wartosc 1-bajtowa (BYTE) w postaci HEXadecymalnej
lHex	.proc ( .byte low )

// po deklaracji procedury .PROC z parametrami, automatycznie wymuszone zostaje wykonanie
// makra @PULL, ktore zdejmie za nas parametry ze stosu programowego i umiesci je w pamieci
// od adresu @PROC_VARS_ADR, etykiecie parametru LOW zostaje przypisany adres @PROC_VARS_ADR

	lda low
	:4 lsr @

	jsr HEX2INT

	tax		; wynik działania w regX

	lda low
	and #$0f

HEX2INT	SED
	CMP #$0A
	ADC #"0"
	CLD
			; wynik działania w regA
	rts

// konczymy procedure w sposob standardowy czyli przez RTS
// po powrocie zostanie zmodyfikowany wskaznik stosu programowego @STACK_POINTER 
// zawartosc rejestrow A,X,Y zostaje zachowana, wiec mozemy ta droga przekazac wynik dzialania procedury

	.endp


// procedurka reprezentujaca wartosc 2-bajtowa (WORD)
// w postaci HEXadecymalnej
hex	.proc ( .word par1, out )

	lda par1
	lHex @		; @ oznacza ze pierwszy parametr to zawartosc akumulatora
			; tylko na pierwszej pozycji jest on rozpoznawany przez makro @CALL
	ldy #3
	jsr put

	lda par1+1
	lHex @

	ldy #1
	jsr put

	rts		; koniec

put
	sta (out),y
	dey
	txa
	sta (out),y
	rts

	.endp


	opt l-
	icl 'macros/@call.mac'
	icl 'macros/@pull.mac'
	icl 'macros/@exit.mac'

; ---
	run main

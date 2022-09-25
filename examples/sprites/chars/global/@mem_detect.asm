
/*
  Detekcja pamieci dodatkowej

  Program na podstawie dopuszczalnych kodow bankow dBANK sprawdza obecnosc rozszerzenia pamieci
  i zapisuje od adresu @TAB_MEM_BANKS+1 znalezione banki. Sposob testowania wyklucza mozliwosc zdublowania
  ktoregokolwiek banku pamieci dodatkowej.

  Pierwszym wpisem w tablicy @TAB_MEM_BANKS jest wartosc $FF, jest to kod banku numer 0.

  Liczbe odnalezionych bankow zwraca w rejestrze akumulatora A

  ostatnie zmiany: 03.10.2005
*/


.proc   @MEM_DETECT

MAX_BANKS = 64		; maksymalna liczba bankow pamieci

PORTB	  = $D301


* zapamietamy bajty spod adresu $7FFF w tablicy dSAFE

	LDA $7FFF	; bajt z pamieci podstawowej
	STA TEMP


        LDX #MAX_BANKS-1

_s1     LDA dBANK,X
        STA PORTB

        LDA $7FFF
        STA dSAFE,X

        DEX
        BPL _s1

* w kazdym z bankow, pod adresem $7FFF zapisujemy kod banku

        LDX #MAX_BANKS-1

_s2     LDA dBANK,X
        STA PORTB

        STA $7FFF

        DEX
        BPL _s2

* wracamy do pamieci podstawowej, tutaj pod $7FFF zapisujemy wartosc $FF

	LDA #$FF
	STA PORTB

	STA $7FFF

	STA @TAB_MEM_BANKS		; pierwszy wpis w @TAB_MEM_BANKS = $FF

* sprawdzamy obecnosc bankow dodatkowej pamieci
* wykryte banki zapisujemy od adresu @TAB_MEM_BANKS+1
* rejestr Y zlicza znalezione banki pamieci

	LDY #0

        LDX #MAX_BANKS-1

LOP	LDA dBANK,X
        STA PORTB

        CMP $7FFF
        BNE SKP

	STA @TAB_MEM_BANKS+1,Y
        INY
SKP
        DEX
        BPL LOP

* przywracamy bajty z tablicy dSAFE pod adres $7FFF

        LDX #MAX_BANKS-1

_r3     LDA dBANK,X
        STA PORTB

        LDA dSAFE,X
        STA $7FFF

        DEX
        BPL _r3

* konczymy, przywracajac pamiec podstawowa

        LDA #$FF
        STA PORTB

	LDA #0		; przywracamy stara zawartosc komorki pamieci spod adresu $7FFF w pamieci podstawowej
TEMP	EQU *-1
	STA $7FFF

	TYA		; w regA liczba odnalezionych bankow dodatkowej pamieci

        RTS

* tablica dBANK zawiera dopuszczalne kody dla PORTB wlaczajace banki

dBANK   DTA B($E3),B($C3),B($A3),B($83),B($63),B($43),B($23),B($03)
        DTA B($E7),B($C7),B($A7),B($87),B($67),B($47),B($27),B($07)
        DTA B($EB),B($CB),B($AB),B($8B),B($6B),B($4B),B($2B),B($0B)
        DTA B($EF),B($CF),B($AF),B($8F),B($6F),B($4F),B($2F),B($0F)

        DTA B($ED),B($CD),B($AD),B($8D),B($6D),B($4D),B($2D),B($0D)
        DTA B($E9),B($C9),B($A9),B($89),B($69),B($49),B($29),B($09)
        DTA B($E5),B($C5),B($A5),B($85),B($65),B($45),B($25),B($05)
        DTA B($E1),B($C1),B($A1),B($81),B($61),B($41),B($21),B($01)

dSAFE	.ds MAX_BANKS

.endp

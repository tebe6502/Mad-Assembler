
	opt h-

.byte $43		; numer wersji
.byte c'XAUTORUN   '	; plik autorun
.byte >$0800		; starszy bajt adresu biblioteki
.byte >$0700		; starszy bajt adresu bufora
.word $02e2		; INITAD
.word $02e0		; RUNAD
.word $0000		; adres modu³u I/O – $0000 oznacza u¿ycie standardowego modu³u SIO
.word $0000		; relokator modulu I/O
.byte $ff		; ustawienie PORTB, nie bierze pod uwage BASICA
.byte $c0		; ustawienie NMIEN
.byte $00		; ustawienie IRQEN

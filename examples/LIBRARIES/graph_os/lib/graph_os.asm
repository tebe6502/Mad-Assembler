
;----------------------------;
; Biblioteka procedur        ;
; graficznych                ;
;----------------------------;
; Autorzy:                   ;
;  Slawomir 'SERO' Ritter,   ;
;  Jakub Cebula,             ;
;  Winfried Hofacker         ;
;----------------------------;
; Wersja:1.1 DATA:09.01.2008 ;
;----------------------------;

ciov	= $e456		; Wektor do cio

rowcrs	= $54		; Wiersz  kursora
colcrs	= $55		; (2) Kolumna kursora

atachr	= $2fb		; Numer coloru dla PLOT,DRAW,FILL ITD.

iocb	= $340		; IOCB
iocom	= iocb+2	; Komenda dla IOCB
ioadr	= iocb+4	; (2) Adres bufora   dla IOCB
ioaux1	= iocb+10	; Bajt pomocniczy 1 IOCB
ioaux2	= iocb+11	; Bajt pomocniczy 2 IOCB

open	= $03		; Otworz kanal
close	= $0c		; Zamknij kanal

IDplot	= $09		; Narysuj punkt
IDdraw	= $11		; Narysuj linie
IDfill	= $12		; Wypelnij obszar


	.reloc

	.public position graphics color plot drawto

;------------------------;
;Ustaw kursor            ;
;------------------------;
;We:.Y  -wspolrzedna y   ;
;   .X.A-wspolrzedna x   ;
;------------------------;
POSITION .proc (.word ax .byte y) .reg

	sty rowcrs
	stx colcrs
	and #1
	sta colcrs+1
	rts

	.endp


;------------------------;
;Wy:.Y-numer bledu (1-OK);
;   f(N)=1-wystapil blad ;
;------------------------;
COMMAND
	ldx	scrchn

	sta	iocom,x

	mva	colscr	atachr

	jmp	ciov


;------------------------;
; Ustaw tryb ekranu      ;
;------------------------;
;We:.X-numer kanalu      ;
;      (normalnie 0)     ;
;   .Y-numer trybu (O.S.);
;   .A-Ustawiony bit nr :;
;     5-Nie kasowanie    ;
;       pamieci ekranu   ;
;     4-Obecnosc okna    ;
;       tekstowego       ;
;     2-Odczyt z ekranu  ;
;------------------------;
;Wy:SCRCHN-numer kanalu  ;
;  .Y-numer bledu (1-OK) ;
;   f(N)=1 wystapil blad ;
;------------------------;
GRAPHICS .proc (.byte x,y,a) .reg

	.var	byte1 byte2	.byte

	sta	byte1
	sty	byte2

	stx	scrchn

	mva	#close	iocom,x
	jsr	ciov

	lda	byte1		; =opcje
	ora	#8		; +zapis na ekranie
	sta	ioaux1,x

	mva	byte2	ioaux2,x	;=nr.trybu

	mva	#open	iocom,x

	mwa	#scrnam	ioadr,x

	jmp	ciov

scrnam   dta c'S:',$9b

	.endp

;------------------------;
;Ustaw kolor dla operacji;
;graf. (PLOT,DRAW,itd.)  ;
;------------------------;
;We:.X  -numer koloru    ;
;------------------------;
COLOR	.proc (.byte x) .reg

	stx colscr
	rts

	.endp


PLOT	.proc (.word ax .byte y) .reg

	jsr	position

	lda	#IDplot

	jmp	COMMAND
	.endp


DRAWTO	.proc (.word ax .byte y) .reg

	jsr	position

	lda	#IDdraw

	jmp	COMMAND
	.endp


scrchn	brk		; numer otwartego kana³u dla obrazu w trybie graficznym
colscr	brk		; kolor pisaka
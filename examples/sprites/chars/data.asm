
* ---	TABLICE
;
; najlepiej zeby zaczynały się od początku strony, czy też mieściły się w jej granicach
;

*---
	.align

* ---	shpAdr, mskAdr

; adgx
; behx
; cfix
; xxxx  4x4 = 16 + 1

	?b = 16*8		; liczba znaków przypadająca na 1 klatkę animacji (duch12x24)
	?c = 16			; ?C=16 aby wyrównać do strony pamięci

mskAdr12	:?c	_ADRH #	$6000,$6800,$7000,$7800		; ?c*8 = 128 bajtów

shpAdr12	:?c	_ADR # 	$4000,$4800,$5000,$5800		; ?c*8 = 128 bajtów

	ert .lo(mskAdr12)<>0	; mskAdr12 koniecznie od początku strony pamięci


; adx
; bex
; cfx
; xxx  3x4 = 12 + 1

	?b = 12*8		; liczba znaków przypadająca na 1 klatkę animacji (duch8x24)
	?c = 32			; ?C=32 aby wyrównać do strony pamięci

shpAdr8		:?c	_ADR # 	$4000,$4800,$5000,$5800		; ?c*8 = 256 bajtów

mskAdr8		:?c	_ADRH #	$6000,$6800,$7000,$7800		; ?c*8 = 256 bajtów

	ert .lo(mskAdr8)<>0	; mskAdr8 koniecznie od początku strony pamięci


_ADR	.macro
	dta a(:2+:1*?b)
	dta a(:3+:1*?b)
	dta a(:4+:1*?b)
	dta a(:5+:1*?b)
	.endm

_ADRH	.macro
	dta h(:2+:1*?b , :2+:1*?b)
	dta h(:3+:1*?b , :3+:1*?b)
	dta h(:4+:1*?b , :4+:1*?b)
	dta h(:5+:1*?b , :5+:1*?b)
	.endm


* ---	STRUKTURY DANYCH
; rozmiar struktury @SPRITE limituje maksymalną liczbę duchów (256/@SPRITE)
; rozmiar struktury @SHAPE limituje maksymalną liczbę banków pamięci z kształtami duchów (256/@SHAPE)

sts_visible	= $80	; bit7
sts_newsprt	= $40	; bit6


@SPRITE	.struct
	prg	.word	; adres programu obsługi ducha
	frm	.word	; adres tablicy z kolejnymi numerami klatek animacji

	shp	.byte	; bezpośredni indeks do tablicy SHAPES, pozwala odczytać parametry dotyczące tego kształtu ducha
	psx	.byte	; pozycja pozioma X
	psy	.byte	; pozycja pionowa Y
	old_psx	.byte	; poprzednia pozycja pozioma X
	old_psy	.byte	; poprzednia pozycja pionowa Y
	cnt	.byte	; licznik klatek animacji
	sts	.byte	; status sprita
			; bit7 = sts_visible:
			;			0 - widoczny
			;			1 - nie widoczny
			; bit6 = sts_newsprt:
			;			0 - obsługuj w aktualnej kolejce zadań
			;			1 - obsługuj w następnej kolejce zadań
	.ends


@SHAPE	.struct
	bnk	.byte	; bank z klatkami animacji ducha (wartość dla rejestru PORTB)
	typ	.byte	; =0 duch 12x24, <>0 duch 8x24 (!!! tylko jeden typ ducha w banku pamięci !!!)
	hig	.byte	; wysokość dla tego kształtu, wartość pomocna przy detekcji kolizji
			; duchy zawsze mają wysokość 24 linii ale nie zawsze wszystkie linie są wykorzystane
			; minimalna wartość HIG = 5 (!!! nie wolno wstawić mniejszej wartości !!!)
	.ends


shapes	dta	@shape	[max_shapes-1]
sprites	dta	@sprite	[max_sprites-1]

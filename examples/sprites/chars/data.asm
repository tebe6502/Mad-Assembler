
* ---	TABLICE
;
; najlepiej zeby zaczyna³y siê od pocz¹tku strony, czy te¿ mieœci³y siê w jej granicach
;

*---
	.align

* ---	shpAdr, mskAdr

; adgx
; behx
; cfix
; xxxx  4x4 = 16 + 1

	?b = 16*8		; liczba znaków przypadaj¹ca na 1 klatkê animacji (duch12x24)
	?c = 16			; ?C=16 aby wyrównaæ do strony pamiêci

mskAdr12	:?c	_ADRH #	$6000,$6800,$7000,$7800		; ?c*8 = 128 bajtów

shpAdr12	:?c	_ADR # 	$4000,$4800,$5000,$5800		; ?c*8 = 128 bajtów

	ert .lo(mskAdr12)<>0	; mskAdr12 koniecznie od pocz¹tku strony pamiêci


; adx
; bex
; cfx
; xxx  3x4 = 12 + 1

	?b = 12*8		; liczba znaków przypadaj¹ca na 1 klatkê animacji (duch8x24)
	?c = 32			; ?C=32 aby wyrównaæ do strony pamiêci

shpAdr8		:?c	_ADR # 	$4000,$4800,$5000,$5800		; ?c*8 = 256 bajtów

mskAdr8		:?c	_ADRH #	$6000,$6800,$7000,$7800		; ?c*8 = 256 bajtów

	ert .lo(mskAdr8)<>0	; mskAdr8 koniecznie od pocz¹tku strony pamiêci


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
; rozmiar struktury @SPRITE limituje maksymaln¹ liczbê duchów (256/@SPRITE)
; rozmiar struktury @SHAPE limituje maksymaln¹ liczbê banków pamiêci z kszta³tami duchów (256/@SHAPE)

sts_visible	= $80	; bit7
sts_newsprt	= $40	; bit6


@SPRITE	.struct
	prg	.word	; adres programu obs³ugi ducha
	frm	.word	; adres tablicy z kolejnymi numerami klatek animacji

	shp	.byte	; bezpoœredni indeks do tablicy SHAPES, pozwala odczytaæ parametry dotycz¹ce tego kszta³tu ducha
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
			;			0 - obs³uguj w aktualnej kolejce zadañ
			;			1 - obs³uguj w nastêpnej kolejce zadañ
	.ends


@SHAPE	.struct
	bnk	.byte	; bank z klatkami animacji ducha (wartoœæ dla rejestru PORTB)
	typ	.byte	; =0 duch 12x24, <>0 duch 8x24 (!!! tylko jeden typ ducha w banku pamiêci !!!)
	hig	.byte	; wysokoœæ dla tego kszta³tu, wartoœæ pomocna przy detekcji kolizji
			; duchy zawsze maj¹ wysokoœæ 24 linii ale nie zawsze wszystkie linie s¹ wykorzystane
			; minimalna wartoœæ HIG = 5 (!!! nie wolno wstawiæ mniejszej wartoœci !!!)
	.ends


shapes	dta	@shape	[max_shapes-1]
sprites	dta	@sprite	[max_sprites-1]


/*
  Procedura obliczajaca sinus, cosinus z dowolnej liczby rzeczywistej wg n/w wzoru.
  Precyzja obliczen odpowiada prawie tej z ATARI BASIC-a, jest tez podobnie powolna,
  srednio jedno obliczenie sinusa trwa 5 ramek (50 ramek = 1sek, dla PAL), dla FASTCHIP-a sa to juz 2 ramki.

  sin(x) = x^13/13! - x^11/11! + x^9/9! - x^7/7! + x^5/5! - x^3/3! + x =
         = x^13 * f - x^11 * e + x^9 * d - x^7 * c + x^5 * b - x^3 * a + x =
         = x^3 * (x^2 * (x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c) + b) - a) + x

  a = 1 / 3!
  b = 1 / 5!
  c = 1 / 7!
  d = 1 / 9!
  e = 1 / 11!
  f = 1 / 13!

  cos(x) = sin (pi/2 - x)

  Parametrem procedury _FPSIN, _FPCOS jest adres wskazujacy na liczbe FP dla ktorej obliczony
  ma zostac SINUS, COSINUS.  Wynik obliczen znajdzie sie w rejestrze FR0 pakietu zmiennoprzecinkowego
  ATARI (FR0 = $d4..$d9)
*/

	icl 'global.asm'

	.reloc

;------------------------------------
       .globl _degtorad
;      degtorad(int) -> fr0
_degtorad	.proc (.word yx) .reg

	jsr	fld0r		; -> fr0

	ldx	<mpi		; fr1 = mpi
	ldy	>mpi
	jsr	fld1r

	jmp	fmul		; fr0 = fr0*fr1

	.endp

;------------------------------------
       .globl _fpcos
;
_fpcos	.proc	(.word yx) .reg

	jsr	fld1r

	ldx	<pi90
	ldy	>pi90
	jsr	fld0r

	jsr	fsub

	jmp	_fpsin.go

	.endp

;------------------------------------
       .globl _fpsin
;
_fpsin	.proc	(.word yx) .reg

	jsr	fld0r

go
	ldx	<s2
	ldy 	>s2
	jsr	fst0r		; kopia fr0 -> s2

* ---	normalizacja

	sign	=	ptr0

	lda	fr0
	tax
	and	#$80
	sta	sign

	txa
	and	#$7f
	sta	fr0		; x = abs(x)

* ---	x = <0..2pi> = <0..360> stopni

rep0
	ldx	<pi360		; x = x - 2pi
	ldy	>pi360
	jsr	fld1r

	jsr	fsub

	lda	fr0
	bpl	rep0		; jesli wartosc dodatnia to petlimy sie

	ldx	<pi360		; ok, poprawiamy i wynik normalizacji do zakresu <0,2pi> gotowy
	ldy	>pi360
	jsr	fld1r

	jsr	fadd
	
* ---	okreslamy w ktorej polówce PI jestesmy <0..3>
* ---	0 = <0..90), 1 = <90..180>, 2 = <180..270), 3 = <270..360)

	ldx	<s2
	ldy 	>s2
	jsr	fst0r		; kopia fr0 -> s2

	cnt	=	ptr0+1

	mva	#$ff	cnt	; cnt = -1
rep1
	ldx	<pi90		; x = x - pi/2
	ldy	>pi90
	jsr	fld1r

	jsr	fsub

	inc	cnt		; cnt++

	lda	fr0
	bpl	rep1		; jesli wartosc dodatnia to petlimy sie

* ---	czas zastosowac wzory redukcyjne

	ldx	<s2
	ldy	>s2
	jsr	fld0r		; s2 -> fr0	przywracamy wartosc fr0

	lda	cnt
	beq	sinus

	cmp	#1
	beq	_90_180
	cmp	#2
	beq	_180_270

_270_360
	ldx	<pi360
	ldy	>pi360
	jsr	fld1r

	jsr	fsub

	jmp	sinus

_90_180
	ldx	<pi
	ldy	>pi
	jsr	fld1r

	jsr	fsub

	lda	fr0
	and	#$7f
	sta	fr0

	jmp	sinus


_180_270
	ldx	<pi
	ldy	>pi
	jsr	fld1r

	jsr	fsub

	lda	fr0
	ora	#$80
	sta	fr0

* ---	liczenie sinusa

sinus	ldy	#5
_copy	lda	fr0,y
	sta	fr1,y
	sta	s1,y		; s1=angle
	dey
	bpl	_copy

	jsr     fmul

	ldx	<s2
	ldy 	>s2
	jsr	fst0r		; fr0 -> s2

	loadfr1	#_f
	jsr	fmul

	loadfr1	#_e
	jsr	_sub		; x^2 * (x^2 * f - e)

	loadfr1	#_d
	jsr	_add		; x^2 * (x^2 * (x^2 * f - e) + d)

	loadfr1	#_c
	jsr	_sub		; x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c)

	loadfr1	#_b
	jsr	_add		; x^2 * (x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c) + b)

	loadfr1	#_a
	jsr	_sub		; x^2 * (x^2 * (x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c) + b) - a)

	loadfr1	#s1
	jsr	fmul		; x * x^2 * (x^2 * (x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c) + b) - a)

	loadfr1	#s1
	jsr	fadd		; x^3 * (x^2 * (x^2 * (x^2 * (x^2 * (x^2 * f - e) + d) - c) + b) - a) + x

	mva	#$00	fr0+5

	lda	fr0
	eor	sign
	sta	fr0
	rts


_add	jsr	fadd
	loadfr1	#s2
	jmp	fmul

_sub	jsr	fsub
	loadfr1	#s2
	jmp	fmul


s1	:6 brk
s2	:6 brk

_a	.fl 0.1666666666666666		;.he 3f 16 66 66 66 66	; 1/3!
_b	.fl 0.0083333333333333		;.he 3e 83 33 33 33 33	; 1/5!
_c	.fl 0.000198412698412698412	;.he 3e 01 98 41 26 98	; 1/7!
_d	.he 3d 02 75 57 31 92	; 1/9!
_e	.he 3c 02 50 52 10 83	; 1/11!
_f	.he 3b 01 60 59 04 38	; 1/13!

	.endp

pi	.fl 3.1415926535897932384626433832795	; pi == 180*pi/180
pi90	.fl 1.5707963267948966192313216916398	; 90*pi/180
pi360	.fl 6.283185307179586476925286766559	; 360*pi/180

mpi	.fl 0.017453292519943295769236907684886	; pi/180


loadfr1	.macro " "
	ldx	<:2
	ldy	>:2
	jsr	fld1r
	.endm

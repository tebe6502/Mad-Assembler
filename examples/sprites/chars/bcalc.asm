 
; BCALC (08.09.2008)
; zadaniem procedury BCALC jest odczytanie 4*COLS znaków i obliczenie ich adresów
; dodatkowo po odczytaniu znaków zastępowane są one nowymi znakami: FREE, FREE+1 ... FREE+COLS
;
; zmienna BUFOR określa dla jakiego bufora odbędzie się asemblacja
; zmienna COLS określa maksymalną liczbę kolumn znaków przypadającą na ducha (liczba wierszy jest stała = 4)
;
; upublicznianym adresem uruchomienia jest BCALC, BINIT
;


	icl 'global\global.hea'


	ift bufor==2
Buf = B2scr
Fnt = B2fnt0
Clr = B2Clr
Idx = B2ClrIdx
	eli bufor==3
Buf = B3scr
Fnt = B3fnt0
Clr = B3Clr
Idx = B3ClrIdx
	els
	ert "not defined"
	eif


fnt0	= Fnt			; FNT0, FNT1, FNT2, FNT3 następują po sobie !!! koniecznie !!!
fnt1	= fnt0+$0400		; wykorzystamy ten fakt do optymalizacji kodu używając rozkazów ADC# i SBC#
fnt2	= fnt1+$0400
fnt3	= fnt2+$0400


	.public	BCALC BINIT

* ------------------------------------------------------
* ------------------------------------------------------

	org $4000

	.pages $40

hchar0	:256 dta h(fnt0+(#&127)*8)
hchar1	:256 dta h(fnt1+(#&127)*8)
hchar2	:256 dta h(fnt2+(#&127)*8)
hchar3	:256 dta h(fnt3+(#&127)*8)

lchar	:256 dta l(fnt0+(#&127)*8)


lhadr	.rept @sh-2, #
	dta a(r:1)
	.endr

	.align $80

lhlin	.rept @sh-2, #
	dta a(l:1)
	.endr


* ------------------------------------------------------
* ------------------------------------------------------
; obliczenie adresow SCR i DST dla jednego ducha
* ------------------------------------------------------
* ------------------------------------------------------

	?row = 0

	.rept @sh-2, #
r:1	ROW
	.endr

* ------------------------------------------------------
* ------------------------------------------------------
; obliczenie adresu skoku wg współrzędnych ducha
* ------------------------------------------------------
* ------------------------------------------------------

BCALC
	lda posx
	:2 lsr @
	tax

	lda posy
	:3 lsr @
	asl @
	sta _jmp+1

	clc			; !!! koniecznie tutaj CLC !!!

_jmp	jmp (lhadr)


* ------------------------------------------------------
* ------------------------------------------------------
; inicjalizacja bufora #2 (b2scr) LUB #3 (b3scr)
* ------------------------------------------------------
* ------------------------------------------------------

	.rept @sh-2, #
l:1	LINE :1
	.endr

* ------------------------------------------------------

BINIT	ldy Idx
	beq stop

	dey

loop	lda	Clr+$80,y
	asl
	ora	#$80
	sta	_ljmp+1

	ldx	Clr,y

_ljmp	jmp (lhlin)

_lret	dey
	bpl loop

	iny
	sty Idx

stop	rts


* ------------------------------------------------------

	.endpg

* ------------------------------------------------------


	.print '$4000..',*

	blk update public



* ---	MACROS

	opt l-


LINE	.macro
	:+4 mva B1scr+:1*@sw+@sw*0+#,x	Buf+:1*@sw+@sw*0+#,x
	:+4 mva B1scr+:1*@sw+@sw*1+#,x	Buf+:1*@sw+@sw*1+#,x
	:+4 mva B1scr+:1*@sw+@sw*2+#,x	Buf+:1*@sw+@sw*2+#,x
	:+4 mva B1scr+:1*@sw+@sw*3+#,x	Buf+:1*@sw+@sw*3+#,x

	jmp _lret
	.endm


ROW	.macro " "
	.def ?cnt = 0
	.def ?cnt2 = 0
	.def ?sign = 0		; na początku występuje rozkaz CLC dlatego ?SIGN=0

	.rept 4
	.def ?col = #

	ADR	<[?row+?cnt]&3	<?cnt
	ADR	<[?row+?cnt]&3	<?cnt
	ADR	<[?row+?cnt]&3	<?cnt
	ADR	<[?row+?cnt]&3	<?cnt

	ADR2	<[?row+?cnt2]&3	<?cnt2

	inc	free

	ift #==2
	lda isSiz3
	bne _skp
	eif
	.endr

_skp	rts

	.def ?row++
	.endm


ADR	.macro " "
	ldy Buf+@sw*[?row+?cnt&3]+?col,x
	lda lchar,y
	sta zp[15-:4].src
	lda hchar:2,y
	sta zp[15-:4].src+1

	tya
	and #$80
	ora free
	sta Buf+@sw*[?row+?cnt&3]+?col,x

	.def ?cnt++
	.endm


ADR2	.macro " "

	.def ?c = ?cnt2

	ldy free

	lda lchar,y
	sta zp[15-?c].dst
	sta zp[15-?c-1].dst
	sta zp[15-?c-2].dst
	sta zp[15-?c-3].dst

	.def ?oldb = $ff

	.def ?c = ?cnt2
	.def ?b = [?row+?c]&3
	HIGH <?b <?c
	.def ?c = ?cnt2+1
	.def ?b = [?row+?c]&3
	HIGH <?b <?c
	.def ?c = ?cnt2+2
	.def ?b = [?row+?c]&3
	HIGH <?b <?c
	.def ?c = ?cnt2+3
	.def ?b = [?row+?c]&3
	HIGH <?b <?c

	.def ?cnt2 += 4
	.endm


HIGH	.macro " "
	ift ?oldb==$ff
	lda hchar:2,y
	eli :2-?oldb==1
	adc #4-?sign
	.def ?sign = 0
	els
	sbc #12-1
	.def ?sign = 1
	eif

	sta zp[15-:4].dst+1

	.def ?oldb=:2
	.endm

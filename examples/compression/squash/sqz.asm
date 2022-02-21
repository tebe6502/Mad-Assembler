
* SQZ depacker v1.6 (24.11.2009)

* kody wstawia do drzewa binarnego
* dane -zrodlowe- mozna umiescic w obszarze -docelowym-

* w naglowku SQZ (0..15) bajty 12..13 okreslaja ofset
* o jaki maja byc przemieszczone dane -zrodlowe- wzgledem adresu -docelowego-

;zpSQZ	= $f0
;bfSQZ	= $0200

input	= zpSQZ		; source address
output	= input+2	; destination address
tmp	= output+2
nxt	= tmp+2
val	= nxt+1
csh	= val+1

	ert	<bfSQZ<>0

adh0	= bfSQZ
adh1	= adh0+$100
adl0	= adh1+$100
adl1	= adl0+$100
tre01	= adl1+$100
tre02	= tre01+$100


/*
	mwa #source	input
	mwa #destin	output
	jsr sqz
	rts
*/


* ---

sqz

* SORT sortujemy match_len z HUFL+??
* i zapamietujemy stara kolejnosc
* wystepowania danych w TRE01

* VFAST
* ----------------------------------

sort	ldx	#0
	ldy	#16		; od INPUT[16] zaczynają się nibble z długościami kodów
nibble	lda	(input),y
	pha			; starszy nibbl
	lsr @
	lsr @
	lsr @
	lsr @
	sta	tre02,x
	inx
	pla
	and	#$0f		; młodszy nibbl
	sta	tre02,x
	iny
	inx
	bne	nibble

	txa
	ldy	#15
	sta:rpl	adh0,y-		; pom

	sta	md+1
	sta	md_+1

	tay			; liczymy elementy
c2	ldx	tre02,y
	inc	adh0,x		; pom
	iny
	bne	c2

	ldx	#0		; pozycje elementow
l2_	ldy	#0		; nie posortowanych
l2	txa			; do tablicy TRE01
	cmp	tre02,y		; dla celow PCK
	bne	s2
md_	sty	tre01
	inc	md_+1
s2	iny
	bne	l2
	inx
	cpx	#16
	bne	l2_

	ldx	#0		; sortuje
l_	ldy	adh0,x		; pom
	beq	s1
md	stx	tre02
	inc	md+1
	dey
	bne	md
s1	inx
	cpx	#16
	bne	l_

* generowanie kodów Shannon-Fano
*----------------------------------

* TRE01 - stare pozycje
* TRE02 - długości kodów

fano	ldy	#0
	tya
cl	sta	adl0,y
	sta	adl1,y
	sta	adh0,y
	sta	adh1,y
	iny
	bne	cl

	sta	lcode+1		; code
	sta	hcode+1
	sta	lerr+1		; code increment
	sta	herr+1
	sta	lbl+1		; last bit length
	sta	nxt

;	ldy	#0		;tworzymy kod FANO
lp	ldx	tre02,y		;if TRE02<>0 then SKP
	beq	skp

lcode	lda	#0		;P=P+ERR
	clc
lerr	adc	#0
	sta	lcode+1
	sta	tmp

hcode	lda	#0
herr	adc	#0
	sta	hcode+1
	sta	tmp+1

lbl	cpx	#0
	beq	skip

	stx	lbl+1

	mva	lmsk-1,x	lerr+1
	mva	hmsk-1,x	herr+1

* wstaw do drzewa
*----------------------------------

skip	mva	tre01,y		val

	ldx	tre02,y
	sty	skp_+1

	lda	#0       	; next link=0
_l1	dex
	tay
	asl	tmp		; bit
	rol	tmp+1
	bcs	_1

_0	txa
	bne	_s1
	mva	val	adl0,y
	jmp	skp_

_s1	lda	adh0,y
	bne	_l1
	inc	nxt
	mva	nxt	adh0,y
	jmp	_l1

_1	txa
	bne	_s2
	mva	val	adl1,y
	jmp	skp_

_s2	lda	adh1,y
	bne	_l1
	inc	nxt
	mva	nxt	adh1,y
	jmp	_l1

skp_	ldy	#0
skp	iny
	bne	lp


* dekompresja, główna pętla 
*----------------------------------

main	adw	input #16+128 data+1	; DATA+1	adres spakowanych danych

	ldy	#4			; INPUT[4..5]	rozmiar danych do dekompresji
					; LLEN, HLEN	adres końca skompresowanych danych
	lda	output
	tax
	add	(input),y
	sta	llen+1

	iny
	lda	output+1
	sta	sbyte+2
	adc	(input),y
	sta	hlen+1

	mva	#0	csh
*---

loop	tay

gbit	asl	csh
	bne	decode

data	lda	$ffff
	inw	data+1

	sec
	rol	@
	sta	csh

decode	bcs	bit1

bit0	lda	adh0,y
	bne	loop
	lda	adl0,y
	jmp	sbyte

bit1	lda	adh1,y
	bne	loop
	lda	adl1,y

sbyte	sta	$ff00,x

	inx
	sne
	inc	sbyte+2

	ldy	#0

llen	cpx	#0
	bne	gbit
	lda	sbyte+2
hlen	cmp	#0
	bne	gbit
	rts				; koniec dekompresji

*----------------------------------

lmsk	dta l($8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,8,4,2,1)
hmsk	dta h($8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,8,4,2,1)

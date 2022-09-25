* LZSS depacker V4.1
* kody wstawia do drzewa binarnego
* najszybsza, rozpisany DEP 0,64,320

* dane -zrodlowe- mozna umiescic
* w obszarze -docelowym-

* w naglowku PCK (0..15) bajty 12..13
* okreslaja ofset o jaki maja byc
* przemieszczone dane -zrodlowe-
* wzgledem adresu -docelowego-


 org >[free+$100]*$100		; od poczatku strony

*-
* +$21 = RIP header lenght
*-

src	equ $2000		; packed rip file
buf	equ src+$21		; zrodlowy, source
out	equ $6000		; docelowy, destination

adl0	equ $b000		; bufory depackera, po 576 bajtow kazdy
adh0	equ adl0+576		; 576 1 wg tej
adl1	equ adh0+576		; 576 2 kolejnosci
adh1	equ adl1+576		; 576 3 w pamieci
tre01	equ adh1+576		; 256 lo =0
tre02	equ tre01+256		; 256 lo =0

pic	equ $80

err	equ $80		;2
mx	equ err+2	;1
l0	equ mx+1	;2
l1	equ l0+2	;2
h0	equ l1+2	;2
h1	equ h0+2	;2
*-
p	equ h1+2	;2
l	equ p+2		;1
nxt	equ l+1		;1
val	equ nxt+1	;1
tmp	equ val+1	;2
pom	equ tmp+2	;16
*-
ind	equ p		;2
lic	equ ind+2	;1
csh	equ lic+1	;1

tand	equ $f8


* Wstep, parametry pliku
* mozna je pominac
*-----------------------

lzss	lda buf+3		; stopien kompresji
	and #$7f
	sta ratio

	lda buf+4		; dlugosc oryginalna
	sta lng
	lda buf+5
	sta lng+1

	lda buf+6		; dlugosc spakowana
	sta lnght
	lda buf+7
	sta lnght+1

* wywolanie Fano dla 3 typow danych
* match_len 64
* ofset     256
* unpack    256
*----------------------------------

go	ldx <src
	ldy >src
	stx pic
	sty pic+1

	ldy #11			; lsb byte of header lenght
	lda (pic),y
	sec
	sbc #9			; index for color pallete
	tay

	ldx #0			; colors
co	lda (pic),y
	sta $2c0,x
	iny
	inx
	cpx #9
	bne co

	lda <adl0
	ldx >adl0
	jsr set_hv
	lda <buf+16		; match_len
	ldx >buf+16
	ldy #64
	jsr fano

	lda <adl0+64
	ldx >adl0+64
	jsr set_hv
	lda <buf+16+32		; ofset
	ldx >buf+16+32
	ldy #0
	jsr fano

	lda <adl0+320
	ldx >adl0+320
	jsr set_hv
	lda <buf+16+160		; unpack
	ldx >buf+16+160
	ldy #0
	jsr fano

* dekompresja
* glowna proc
*------------

* lda buf+8   ;liczba znacznikow 1bit
* sta ln
* lda buf+9
* sta ln+1

	ldx <buf+16+288		; spakowane dane
	ldy >buf+16+288
	stx stc+1
	sty stc+2

	lda <out		; IND docelowy
	sta ind
	clc			; BUF 4..5 rozmiar
	adc buf+4		; niespakowanych danych
	sta lln+1
	lda >out		; LLN HLN koniec danych
	sta ind+1
	adc buf+5
	sta hln+1

* init licznik LIC
	lda #$ff
	sta lic

*-----------
lop	sty $d01a

	jsr gbit		; 0 - unpack
	bcs dp_ofs		; 1 - match_len, ofset

dp_unp	equ *
dep320	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0+320,y
	bne *-9
	lda adl0+320,y
	jmp j1

	lda adh1+320,y
	bne *-20
	lda adl1+320,y


j1	ldy #0
	sta (ind),y

	inw ind

tst	lda ind+1
hln	cmp #0
	bne lop
	lda ind
lln	cmp #0
	bcc lop

exit	equ *			; koniec dekompresji

	rts


dp_ofs	equ *
dep64	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0+64,y
	bne *-9
	lda adl0+64,y
	jmp j2

	lda adh1+64,y
	bne *-20
	lda adl1+64,y


j2	clc			; OFS=OFS+2
	adc #1			; zamiast 'adc #2'
	sta ofs+1

	lda ind			; IND=IND-OFS
	sta _adr+1
;	sec
ofs	sbc #0			; CLC ustawione
	sta adr+1		; czyli doda 1
	lda ind+1
	sta _adr+2
	sbc #0
	sta adr+2


dep0	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0,y
	bne *-9
	lda adl0,y
	jmp j3

	lda adh1,y
	bne *-20
	lda adl1,y


j3	tay			; LEN=LEN+2
	iny			; dla BPL -1
	tya
	sec
	adc ind
	sta ind
	scc
	inc ind+1

adr	lda $ffff,y
_adr	sta $ffff,y		;sta (ind),y
	dey
	bpl adr

	jmp tst


*---------

gbit	inc lic
	bne g_
	lda #tand
	sta lic
stc	lda $ffff
	sta csh
	inw stc+1
g_	rol csh
	rts

*------------
set_hv	sta l0
	stx l0+1

	clc
	adc <576
	sta h0
	txa
	adc >576
	sta h0+1

	adw h0 #576 l1

	adw l1 #576 h1

 rts

* generowanie kodow
* Shannon-Fano
*------------------

* TRE01 - stare pozycje
* TRE02 - dlugosci kodow

fano	sty mx
	jsr sort

	ldy #0
	tya
cl	sta (l0),y
	sta (l1),y
	sta (h0),y
	sta (h1),y
	iny
	cpy mx
	bne cl

	sta p       		; code
	sta p+1
	sta err     		; code increment
	sta err+1
	sta l       		; last bit length
	sta nxt

	ldy #0			; tworzymy kod FANO
lp	lda tre02,y		; if TRE02<>0 then SKP
	beq skp

	adw p err		; P=P+ERR

	ldx tre02,y
	cpx l
	beq sp
	stx l

	mva lmsk-1,x err
	mva hmsk-1,x err+1

sp	mwa p tmp

* wstaw do drzewa
*----------------
	lda tre01,y
	sta val
	ldx tre02,y
	sty skp_+1

	lda #0			; next link=0
_l1	dex
	tay
bit	asl tmp
	rol tmp+1
	bcs _1

_0	cpx #0
	bne _s1
	lda val
	sta (l0),y
	jmp skp_
_s1	lda (h0),y
	bne _l1
	inc nxt
	lda nxt
	sta (h0),y
	jmp _l1

_1	cpx #0
	bne _s2
	lda val
	sta (l1),y
	jmp skp_
_s2	lda (h1),y
	bne _l1
	inc nxt
	lda nxt
	sta (h1),y
	jmp _l1

skp_	ldy #0
skp	iny
	cpy mx
	bne lp
	rts

* SORT sortujemy match_len z HUFL+??
* i zapamietujemy stara kolejnosc
* wystepowania danych w TRE01

* VFAST
*------
sort	jsr cnibl

	lda #0
	ldy #15
c1	sta:rpl pom,y-

	sta md+1
	sta md_+1

	tay		; liczymy elementy
c2	ldx tre02,y
	inc pom,x
	iny
	cpy mx
	bne c2

	ldx #0			; pozycje elementow
l2_	ldy #0			; nie posortowanych
l2	txa			; do tablicy TRE01
	cmp tre02,y		; dla celow PCK
	bne s2
md_	sty tre01
	inc md_+1
s2	iny
	cpy mx
	bne l2
	inx
	cpx #16
	bne l2_

	ldx #0			; sortuje
l_	ldy pom,x
	beq s1
md	stx tre02
	inc md+1
	dey
	bne md
s1	inx
	cpx #16
	bne l_
	rts

cnibl	sta ld_bf+1		; zamiana na nible
	stx ld_bf+2		; do TRE02

	ldy #0
	ldx #0
ld_bf	lda $ffff,x
	pha			; starszy nibel
	lsr @
	lsr @
	lsr @
	lsr @
	sta tre02,y
	iny
	pla
	and #$f			; mlodszy nibel
	sta tre02,y
	inx
	iny
	cpy mx
	bne ld_bf
	rts

*-----
lmsk	dta l($8000),l($4000),l($2000)
	dta l($1000),l($800),l($400)
	dta l($200),l($100),l($80)
	dta l($40),l($20),l($10)
	dta l(8),l(4),l(2),l(1)

hmsk	dta h($8000),h($4000),h($2000)
	dta h($1000),h($800),h($400)
	dta h($200),h($100),h($80)
	dta h($40),h($20),h($10)
	dta h(8),h(4),h(2),h(1)

ratio	brk
lng	dta a(0)
lnght	dta a(0)


	org src
	ins 'razor2.rip'

free

	ini lzss


/*******************************************************

                 R I P   S H O W

*******************************************************/

.local	rip_show

* Version 2.0
* 
* proc for Rip with height 200
* uncompress, this is important
* 
* height 200=200*40byte(widght)=8000
* 2x16kb banks for 1 picture
* all Rip = 16kb memory for 200 line

* Rip header
* d'RIP1.0  ',b(0),b(packed=1, unpack=0)
* a(header lenCht),a(widght),a(height+1),
* a(name lenght),d'T:',name,
* how many colors(default=9 in RIP1.0)
* d'CM:',d'123456789'

	org $b000

ad1	equ $2010 ;screen 1
ad2	equ $4010 ;screen 2

pic	equ $80
rip	equ pic+2
x	equ rip+2
y	equ x+2
line	equ y+2

*--

main	ldx <$6000	; rip adres
	ldy >$6000	; file load to this ...

;	ldx $600  ;parametr /adres/
	stx pic
;	ldy $601
	sty pic+1

	lda $2c8	; for dli
	sta col1+1
	sta col2+1

	mva #$22 $22f

	mwa #dl $230

	mva #$80 $26f

	jsr copy
	jsr _conv

	mwa #dli $200

	mva #$c0 $d40e

	jmp *		; loop or exit

dli	pha
	txa
	pha

	ldx #100
_d0	lda #$40
	sta $d40a
	sta $d01b
	lda #0
	sta $d01a
	lda #$80
	sta $d40a
	sta $d01b
col1	lda #$0
	sta $d01a
	dex
	bpl _d0

	mva >ad2	adr+1
	mva >ad2+$1000	adr2+1

	mwa #dli2 $200

	pla
	tax
	pla
	rti


dli2	pha
	txa
	pha

	ldx #100
_d1	lda #$80
	sta $d40a
	sta $d01b
col2	lda #$0
	sta $d01a
	lda #$40
	sta $d40a
	sta $d01b
	lda #0
	sta $d01a
	dex
	bpl _d1

	mva >ad1	adr+1
	mva >ad1+$1000	adr2+1

	mwa #dli $200

	pla
	tax
	pla
	rti

*- Copy
*  Rip data /2 picture/
*  to adres ad1, ad2
*-

copy	ldy #11		; header lenght
	lda (pic),y
	sta mem+1

	lda pic		; get absolute adres
	clc		; of rip data /skip header/
mem	adc #0
	sta rip
	lda pic+1
	adc #0
	sta rip+1

	lda rip
	sta c1+1
	clc
	adc <9520	; 238line x 40byte=9520
	sta c3+1
	lda rip+1
	sta c1+2
	adc >9520
	sta c3+2

	ldx <ad1
	ldy >ad1
	stx c2+1
	sty c2+2

	ldx <ad2
	ldy >ad2
	stx c4+1
	sty c4+2

	ldy #0
	ldx #32
c1	lda $ffff,y      ;picture 1
c2	sta ad1,y
c3	lda $8000,y      ;picture 2
c4	sta ad2,y
	iny
	bne c1

	inc c1+2
	inc c2+2
	inc c3+2
	inc c4+2

	dex
	bne c1
	rts

*--

_conv	mva #99		line
	mva <ad1	x
 	mva >ad1	x+1

	mwa #ad2	y

	ldy #39
exc	lda (x),y
	tax
	lda (y),y
	sta (x),y
	txa
	sta (y),y
	dey
	bpl exc

	ldy #39

	adw x #80

	adw y #80

	dec line
	bpl exc
	rts


dl	dta d'ppð',b($4f)
adr	dta a(ad1)
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'/////',b($4f)
adr2	dta b(0),h(ad1+$1000)
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'////////////////'
	dta d'/',b($41),a(dl)

	run main

.endl

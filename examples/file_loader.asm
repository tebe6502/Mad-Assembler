* File loader by MADMAN/MADTEAM
* 31.01.96

* wersja dla MAD-Assembler 14.02.2005

	org $600

ad	equ $80
dlg	equ 176			;przesuniecie
buf	equ buf_adr+dlg		;bufor na katalog
obr	equ $bc40		;adres obrazu

source	equ $2000		;zrodlo
destin	equ $0700		;cel

main
	pla
	pla

	ldx <go
	ldy >go
	stx $a
	sty $a+1

	ldy #0
	ldx #4
mv	lda source,y
mv_	sta destin,y
	dey
	bne mv
	inc mv+2
	inc mv_+2
	dex
	bne mv

	jmp destin	;odpalamy !


; asemblujemy pod adres DESTIN, umieszczamy
; w pamieci pod adresem SOURCE

  org destin,source

* Init
go	ldx <go		;ustaw wektor RESET'a
	ldy >go
	stx $c
	sty $c+1

	lda #'}'	;wyczysc ekran
	jsr $f2b0

	lda #$31	;nr stacji+$30
	sta $300
	lda #1		;nr stacji
	sta $301

	ldx <go		;ustaw ($2e0) na 'go'
	ldy >go
	stx $2e0
	sty $2e0+1
	lda #7
	sta $306	;timeout
	ldx <buf-dlg
	ldy >buf-dlg
	stx bf+1
	sty bf+2

	ldx #0
	stx file	;liczba plikow=0
	stx up+1	;wskaznik pliku=0
	stx eof+1	;znacznik konca=0
	stx fl+1	;flaga fl=0
	stx $2e2
	stx $2e2+1
	lda #32		;wyczysc
cl	jsr bf
	dex
	bne cl

* Density
	lda #$53	;odczyt statusu stacji
	sta $302
	jsr $e453
	ldx <256	;256 bajtow
	ldy >256	;w sektorze
	lda $2ea
	and #%00100000
	bne rd
	ldx <128	;128 bajtow
	ldy >128	;w sektorze

* Read directory
rd	lda #$52	;$52 odczyt sektora
	jsr set
	ldx <$169	;pierwszy nr sektora
	ldy >$169	;z katalogiem dysku
	stx $30a
	sty $30b
	ldx <buf
	ldy >buf
	stx ad
	sty ad+1
	stx bf+1
	sty bf+2
	lda #8
	sta lic
l_	jsr sio

	clc
	lda $304
	adc llng+1
	sta $304
	tax
	lda $305
	adc hlng+1
	sta $305
	tay

	inc $30a
	dec lic
	bne l_

* Create directory
	lda #8
	sta lic
a_	ldy #0
b_	lda (ad),y
	cmp #$42	;pliki odbezpieczone
	beq _a
	cmp #$62	;pliki zabezpieczone
	beq _a
;	cmp #$80	;pliki skasowane
;	beq _a

	tya
	clc
	adc #16
	tay
	bne sk

_a	ldx #0
c_	lda (ad),y
	jsr bf
	iny
	inx
	cpx #16
	bne c_
	inc file

	adw bf+1 #16

sk	cpy #$80
	bne b_

	lda ad
	clc
	adc llng+1
	sta ad
	lda ad+1
	adc hlng+1
	sta ad+1

	dec lic
	bne a_

	ldy #8
	ldx #0
	lda #32
cr	jsr bf
	dex
	bne cr
	inc bf+2
	dey
	bne cr
	dec file

* Change file
cre	jsr mul
	sta md+1

	lda <buf-dlg
	clc
md	adc #0
	sta bu+1
	lda >buf-dlg
sd	adc #0
	sta bu+2

	ldx <obr+9
	ldy >obr+9
	stx ek+1
	sty ek+2

	ldx #0
_b	ldy #5
bu	lda $ffff,y
	sec
	sbc #32
ek	sta obr+9,y
	iny
	cpy #16
	bne bu

	adw bu+1 #16

	adw ek+1 #40

	inx
	cpx #24
	bne _b

is	ldy #0
in	lda obr+454,y
	ora #128
	sta obr+454,y
	iny
	cpy #11
	bne in

key	lda #$ff
	sta 764
ee	lda 764
	cmp #255
	beq ee
	cmp #15
	beq up
	cmp #14
	beq do
	cmp #33
	beq new
	cmp #28
	beq esc
	cmp #12
	beq loa
	jmp key

esc	jmp $c8fc  ;Self Test
new	jmp go
up	lda #0
	cmp file
	beq u_q
	inc up+1
u_q	jmp cre

do	lda up+1
	beq d_q
	dec up+1
d_q	jmp cre

* Load file
loa	jsr mul
	sta low+1
	lda <buf
	clc
low	adc #0
	sta ad
	lda >buf
	adc sd+1
	sta ad+1

	lda llng+1
	sec
	sbc #3
	sta rx+1	;dlugosc sektora-3

	ldy #3		;pierwszy sektor
	lda (ad),y
	sta link
	iny
	lda (ad),y
	sta link+1

	jsr r_sec

p3	ldy i
	lda mem,y
	sta adr
	jsr inc_i
	lda mem,y
	sta adr+1
	jsr inc_i

	lda adr
	and adr+1
	cmp #$ff
	beq ok
fl	lda #0		;if fl=0 then go
	bne p4		;naglowek pliku<>ffff
	jmp go
ok	inc fl+1	;fl=fl+1
	jmp p3

p4	ldy i
	lda mem,y
	sta end
	jsr inc_i
	lda mem,y
	sta end+1

	sbw end adr len	;end-adr=len
			;len-dlugosc bloku

ki	ldx adr		;adres ladowania
	ldy adr+1	;bloku
	stx des+1
	sty des+2

* Tutaj mozna sprawdzic czy adres
* ladowania nie koliduje z Loaderem
* lub z innym obszarem pamieci.

p1	jsr inc_i	;laduje len+1 bajtow
	lda mem,y
des	sta $ffff

	inw des+1

om	sec
	lda len		;len=len-1
	sbc #1
	sta len
	lda len+1
	sbc #0
	sta len+1
	bcs p1		;if len>=0 then p1

	lda $2e2	;if ($2e2)<>0 then ini
	ora $2e2+1
	bne ini
no	and #0
	sta $2e2
	sta $2e2+1
	jsr inc_i
	jmp p3

ini	lda >no-1	;wloz na stos adres
	pha		;powrotu
	lda <no-1
	pha
	jmp ($2e2)	;wywolaj blok

r_sec	lda link	;czytanie sektora
	sta $30a	;< nr sektora
	lda link+1
	sta $30b	;> nr sektora
	ldx <mem
	ldy >mem
	jsr sio		;wczytaj
rx	ldx #0
	lda mem,x
	and #%00000011
	sta link+1	;link nastepny sektor
	lda mem+1,x
	sta link
	lda mem+2,x
	sta max+1	;max bajtow w sektorze

	lda link	;czy ostatni sektor
	ora link+1
	bne con
	inc eof+1	;ustaw eof
con	and #0
	sta i
	rts

inc_i	inc i		;i=i+1
	lda i
max	cmp #0		;if i>=max then r_sec
	bcc out
eof	lda #0
	bne run
	jsr r_sec
out	ldy i
	rts

run	pla		;zdejm adres powrotu
	pla
	lda >go-1	;wloz adres powrotu
	pha
	lda <go-1
	pha
	jmp ($2e0)	;uruchom glowny blok

mul	lda #0		;oblicz adres nazwy
	sta sd+1	;pliku
	ldy #4
	lda up+1
rr	asl @
	rol sd+1
	dey
	bne rr
rt_	rts

bf	sta $ffff,x
	rts

set	sta cod+1	;kod operacji
	stx llng+1	;< dlugosc sektora
	sty hlng+1	;> dlugosc sektora
	rts

sio	stx $304	;< adres bufora
	sty $305	;> adres bufora
cod	lda #$4e	;$4e konifguracja
	sta $302
	lda #$40	;$40 odczyt
	sta $303
llng	lda <12		;< dlugosc bufora
	sta $308
hlng	lda >12		;> dlugosc bufora
	sta $309
	jsr $e459	;wywolanie procedury
	rts

lic	.ds 1
file	.ds 1
i	.ds 1
link	.ds 2
adr	.ds 2
end	.ds 2
len	.ds 2

mem	.ds 256		;bufor na sektor

buf_adr			;bufor dla katalogu dyskietki

	run main

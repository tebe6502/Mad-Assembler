
; inicjalizacja danych, przepisanie pod odpowiednie adresy


	.extrn b1scr b2scr b3scr b2fnt0 b2fnt1 b2fnt2 b2fnt3 b3fnt0 b3fnt1 b3fnt2 b3fnt3 .word
	.extrn b2clr b3clr b2clridx b3clridx .word


;charsBAK	= 56	; liczba znaków przeznaczonych na tło pola gry <0..charsBAK-1>
			; <charsBAK..127> znaki przeznaczone na duchy

	.public	charsBAK


	.reloc

init	.proc

	lda:cmp:req 20

	sei
	mva #$00 $d40e
	sta $d400
	sta 559
	mva #$fe $d301


	ldy #ile
	ldx #0

	stx B2ClrIdx		; koniecznie zerujemy !!! B2ClrIdx !!!

	stx B3ClrIdx		; koniecznie zerujemy !!! B3ClrIdx !!!
lp
	mwa adr,x	move.src+1
	mwa adr+2,x	move.dst+1
	jsr move

	:4 inx
	dey
	bne lp


* teraz kopiujemy B1SCR -> B2SCR, B1SCR -> B3SCR

	#while .word src+1 < _len
src	lda B1scr
dst2	sta B2scr
dst3	sta B3scr

	inw src+1
	inw dst2+1
	inw dst3+1
	#end


	lda:rne $d40b

	mva #$ff $d301
	mva #$40 $d40e
	cli

	rts

* ------------------------------------------------

_len	dta a(B3scr)


adr	.word fnt,	B2fnt0
	.word fnt,	B2fnt2
	.word fnt+$400,	B2fnt1
	.word fnt+$400,	B2fnt3
	.word fnt,	B3fnt0
	.word fnt,	B3fnt2
	.word fnt+$400,	B3fnt1
	.word fnt+$400,	B3fnt3
	.word scr,	B1scr		; najważniejszy bufor skąd przepisywane są dane do pozostałych buforów

	ile	= [*-adr]/4		; ile operacji przeniesienia danych

fnt	ins 'ride.fnt'		; przykładowy zestaw znaków

; akceptujemy znaki z zakresu <0..charsBAK-1>, dodatkowo dodajemy invers co drugi bajt

	.get 'ride.scr',0,8*32	; przykladowe tło

	.rept 8*32

	 ift .get[#]<4 .or .get[#]>charsBAK-1
	  .put[#]=4
	 eif

	 .put[#/2] = .get[#/2]|$80
	.endr


scr	:4 .sav 8*32

	.endp


; procka do przenoszenia danych SRC -> DST
; rejestry X,Y musimy zachować

move	.proc

	stx rX+1
	sty rY+1

	ldx #4
	ldy #0
src	lda $ffff,y
dst	sta $ffff,y
	iny
	bne src
	inc src+2
	inc dst+2
	dex
	bne src

rX	ldx #0
rY	ldy #0

	rts

	.endp

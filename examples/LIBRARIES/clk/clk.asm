
	icl 'atari.hea'
	icl 'global.asm'

	org $2000

main	jsr test

	jsr printf			; wypisujemy wynik na ekran
	.he '@' 9b 0
	.wo clkmfp

	jmp *



test	tsx
	stx	data.stk

	ldx	#$01
v0	lda	vvblki,x
	sta	data.vbl,x
	dex
	bpl	v0

	sei

	jsr	_vbs

	ldx	#<stop2
	ldy	#>stop2

bogo2	lda	vcount
	cmp	#112
	bne	bogo2

	stx	vvblki
	sty	vvblki+1

	lda	#$00
	tax
	tay

	sta	wsync

loop2	iny
	bne	loop2
	inx
	bne	loop2
	clc
	adc	#$01
	bne	loop2

stop2
	pla
	sta	clkm
	pla
	sta	clkm+1
	pla
	sta	clkm+2
	sta	fr0

	ldx	data.stk
	txs

	jsr	_rstvb

	lda	#$00
	sta	fr0+1
	jsr	ifp
	jsr	fmov01
	ldx	#<data.m
	ldy	#>data.m
	jsr	fld0r
	jsr	fmul
	jsr	fmov01

	lda	clkm
	sta	fr0
	lda	clkm+1
	sta	fr0+1

	jsr	ifp
	jsr	fadd

	ldx	#<data.d
	ldy	#>data.d
	jsr	fld1r
	jsr	fdiv
	ldx	#<clkmfp
	ldy	#>clkmfp
	jsr	fst0r

	jsr	fpi
	ldx	fr0
	stx	clkmul

	cli
	rts

_rstvb	ldx	#$01
v2	lda	data.vbl,x
	sta	vvblki,x
	dex
	bpl	v2
	cli
	rts

_vbs	lda:cmp:req rtclok+2
	rts

fmov01	ldx #5
fmv	lda fr0,x
	sta fr1,x
	dex
	bpl fmv
	rts
;
.local	data
m	.fl	65536
d	.fl	487
vbl	.ds	2
stk	.ds	1
.endl

clkm	.ds	3
clkmul	.ds	1	;wynik
clkmfp	.ds	6


	.link '..\stdio\lib\printf.obx'

	run main

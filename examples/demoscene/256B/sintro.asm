
//------------------------------------------------------------------------
//	Sintro V2.0
//	Cosinus generator - 1024 byte
//------------------------------------------------------------------------


.nowarn	.zpvar ax, bx, cx, dx .word = $80

	org	$9f2f

//------------------------------------------------------------------------
//	Create
//------------------------------------------------------------------------

go	mwa	#$798f	bx
	mwa	#0	cx

	ldy	#8
lp	adw	cx	#$FFFF		; CX+DX - DX=$FFFF
	adw	bx	cx

	add	#128
	sta	tcos,y
	iny
	bne	lp

	jsr	sin
	jsr	sin


//------------------------------------------------------------------------
//	Animation
//------------------------------------------------------------------------

	mva	#%00100000	623

	lda	#3
	sta	$d008
	sta	$d009
	sta	$d00a
	sta	$d00b

	mva	#$30	704
	mva	#$40	705
	mva	#$e0	706
	mva	#$b0	707

loop	ldx	#30-7         ; y=0
rp	sta	$d40a
	dex
	bne	rp

ll	lda	tcos,y
	sta	$d40a
	sta	$d000
	lsr
	adc	#48
	sta	$d001
	lsr
	adc	#48+8
	sta	$d002
	lsr
	adc	#48+8
	sta	$d003
	iny
	bne	ll

	lda	ll+1
;	clc
	adc	#8
	sta	ll+1
	bne	up

	inc	ll+2
	lda	ll+2
	cmp	>tcos+$400
	bne	up

	lda	>tcos
	sta	ll+2

up	lda:cmp:req 20
	jmp	loop


//------------------------------------------------------------------------

sin	ldy	#0

	ldx	#255
	stx	$d00d
	stx	$d00e
	stx	$d00f
	stx	$d010

cn	mva	tcos+256,y	tcos+512,x

	lda	tcos,y
	sta	tcos+1024,y
	sta	tcos+768,x
	eor	#$ff
	sta	tcos+256,x

	dex
	iny
	bne	cn
	rts

tcos	:8	dta 249

	org	$bc40+9+400
	dta	d'Sintro 256B MADTEAM ''97'

//------------------------------------------------------------------------

	run	go

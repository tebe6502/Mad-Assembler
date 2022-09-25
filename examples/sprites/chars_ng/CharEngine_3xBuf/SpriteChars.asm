
//---------------------------------------------------------------------
//	SPRITE CHARS
//---------------------------------------------------------------------

.local	SpriteChars

	sty zp+@zp.hlp0
	iny
	sty zp+@zp.hlp0+1
	iny
	sty zp+@zp.hlp1
	iny
	sty zp+@zp.hlp1+1

	mva	Charsets-4,x	zp+@zp.hlp2
	mva	Charsets-4+1,x	zp+@zp.hlp3
	mva	Charsets-4+2,x	zp+@zp.hlp4
	mva	Charsets-4+3,x	zp+@zp.hlp5

//------------------ ROW #0 ----------------------------

r0	lda zp+@zp.hlp2
	bne row0

	@Empty	0 1 2 3

	jmp r1

row0	ldy #PlayfieldWidth*0

	@Chars	0	hlp2	hlp0
	iny
	@Chars	1	hlp2	hlp0+1
	iny
	@Chars	2	hlp2	hlp1
	iny
	@Chars	3	hlp2	hlp1+1

//------------------ ROW #1 ----------------------------

r1	lda zp+@zp.hlp3
	bne row1

	@Empty	4 5 6 7

	jmp r2

row1	ldy #PlayfieldWidth*1

	@Chars	4	hlp3	hlp0
	iny
	@Chars	5	hlp3	hlp0+1
	iny
	@Chars	6	hlp3	hlp1
	iny
	@Chars	7	hlp3	hlp1+1

//------------------ ROW #2 ----------------------------

r2	lda zp+@zp.hlp4
	bne row2

	@Empty	8 9 10 11

	jmp r3

row2	ldy #PlayfieldWidth*2

	@Chars	8	hlp4	hlp0
	iny
	@Chars	9	hlp4	hlp0+1
	iny
	@Chars	10	hlp4	hlp1
	iny
	@Chars	11	hlp4	hlp1+1

//------------------ ROW #3 ----------------------------

r3	lda zp+@zp.hlp5
	bne row3

	@Empty	12 13 14 15

	rts

row3	ldy #PlayfieldWidth*3

	@Chars	12	hlp5	hlp0
	iny
	@Chars	13	hlp5	hlp0+1
	iny
	@Chars	14	hlp5	hlp1
	iny
	@Chars	15	hlp5	hlp1+1

	rts
.endl


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@Empty

	lda <EmptyChar
	sta src:1+1
	sta src:2+1
	sta src:3+1
	sta src:4+1

	sta dst:1+1
	sta dst:2+1
	sta dst:3+1
	sta dst:4+1

	lda >EmptyChar
	sta src:1+2
	sta src:2+2
	sta src:3+2
	sta src:4+2

	sta dst:1+2
	sta dst:2+2
	sta dst:3+2
	sta dst:4+2
.endm


.macro	@Chars

	lda (zp+@zp.hlp6),y
	tax

	mva lAdrCharset,x src:1+1	; adres znaków z aktualnego bufora
	lda hAdrCharset,x
	add zp+@zp.:2
	sta src:1+2

	lda zp+@zp.:3			; znak reprezentuj¹cy ducha
	cpx #0
	spl
	ora #$80
	sta (zp+@zp.hlp6),y

	tax
	mva lAdrCharset,x dst:1+1	; adres docelowych znaków w aktualnym buforze
	lda hAdrCharset,x
	add zp+@zp.:2
	sta dst:1+2
.endm

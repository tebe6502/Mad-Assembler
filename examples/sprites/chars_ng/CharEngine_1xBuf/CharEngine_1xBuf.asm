
//---------------------------------------------------------------------
// SOFTWARE SPRITES ENGINE II (CHARS MODE) v2.0 (29.10.2008)
//---------------------------------------------------------------------

; ZA£O¯ENIA:
; - mo¿liwoœæ zdefiniowana liczby zestawów znakowych od 4..N zmienianych co wiersz (tablica CHARSETS) na przerwaniu DLI
; - kolory pola gry zmieniane co wiersz (przerwanie DLI) na podstawie tablic TCOLOR1, TCOLOR2, TCOLOR3
; - mo¿liwoœæ zdefiniowania szerokoœci (PLAYFIELDWIDTH) i wysokoœci pola gry (PLAYFIELDHEIGHT)
; - duch na pozycji X:Y = 0:0 jest poza polem gry, na pozycji 32:32 w lewym górnym naro¿niku pola gry
; - sta³a maksymalna liczba duchów = 6
; - sta³y maksymalny rozmiar duchów = 12x21 pixle
; - tylko jeden bufor dla pamiêci obrazu, mo¿liwe jest w nim u¿ycie znaków 0..75
; - tylko 1 bitmapa kszta³tu dla 1 klatki ducha (zajmuje 64 bajty), przesuwanie bitów realizowane poprzez tablicê
; - bitmapa maski obliczana na podstawie aktualnej bitmapy kszta³tu poprzez tablicê (nie ma potrzeby jej przesuwaæ)
; - sta³e wartoœci kodów znaków dla reprezentacji duchów rozpoczynaj¹ce siê od znaku 76

; ZALETY:
; - brak potrzeby rozpisania klatek kszta³tu i maski ducha, oszczêdnoœæ pamiêci
; - tylko 1 bufor obrazu, mo¿liwoœæ jego dowolnej modyfikacji poprzez procedurê PLAYFIELD_UPDATE

; WADY:
; - tylko 6 duchów wyrabia siê w 2 ramkach na w¹skim ekranie (silnik z gry BombJack obs³u¿y w tym czasie 11 duchów)

; 	# BUFOR #0
;	# duch0 = znak 76, 77, 78, 79
;	# duch1 = znak 80, 81, 82, 83
;	# duch2 = znak 84, 85, 86, 87
;	# duch3 = znak 88, 89, 90, 91
;	# duch4 = znak 92, 93, 94, 95
;	# duch5 = znak 96, 97, 98, 99

; 	# BUFOR #1
;	# duch0 = znak 100, 101, 102, 103
;	# duch1 = znak 104, 105, 106, 107
;	# duch2 = znak 108, 109, 110, 111
;	# duch3 = znak 112, 113, 114, 115
;	# duch4 = znak 116, 117, 118, 119
;	# duch5 = znak 120, 121, 122, 123

; znaki 124, 125, 126, 127 nie s¹ u¿ywane m.in. w celu ochrony obszaru $fff8..$ffff (dla zestawu $fc00..$ffff)
; ka¿de 4 znaki musz¹ mieœciæ siê w granicy strony pamiêæi

first_char	= 76

B0		= 0
B1		= 1

	icl 'Engine_1xBuf.hea'

	.reloc

	.extrn Charsets, Playfield_Update	.word

	.extrn zp	.byte

	.public Engine, Engine.reset
	.public Sprite0.x, Sprite1.x, Sprite2.x, Sprite3.x, Sprite4.x, Sprite5.x
	.public Sprite0.y, Sprite1.y, Sprite2.y, Sprite3.y, Sprite4.y, Sprite5.y
	.public Sprite0.new, Sprite1.new, Sprite2.new, Sprite3.new, Sprite4.new, Sprite5.new
	.public Sprite0.bitmaps, Sprite1.bitmaps, Sprite2.bitmaps, Sprite3.bitmaps
	.public Sprite4.bitmaps, Sprite5.bitmaps


//---------------------------------------------------------------------

.struct	@zp

	old0B0		.word
	old1B0		.word
	old2B0		.word
	old3B0		.word
	old4B0		.word
	old5B0		.word

	old0B1		.word
	old1B1		.word
	old2B1		.word
	old3B1		.word
	old4B1		.word
	old5B1		.word

	hlp0		.word
	hlp1		.word
	hlp2		.word
	hlp3		.word
	hlp4		.word
	hlp5		.word
.ends

	.print '@ZP Length: ',@zp

//---------------------------------------------------------------------

.struct	@Spr

	x	.byte
	y	.byte

	xOk	.byte
	yOk	.byte

	row	.byte

	bitmaps	.word		; tablica z adresami bitmap (adres = $0000 koñczy tak¹ talicê)

	index	.byte		; indeks do tablicy BITMAPS
	delay	.byte
	new	.byte
.ends

//---------------------------------------------------------------------

.macro	@shift
		:+256 dta :1([#<<8]>>:2)
.endm

ShiftRight2H	@shift h 2
ShiftRight2L	@shift l 2

ShiftRight4H	@shift h 4
ShiftRight4L	@shift l 4
	
ShiftRight6H	@shift h 6
ShiftRight6L	@shift l 6


lAdrCharset	:256 dta l([#&$7f]*8)
hAdrCharset	:256 dta h([#&$7f]*8)


tByte		.rept 256
		?p3 = #&$c0
		?p2 = #&$30
		?p1 = #&$0c
		?p0 = #&$03

		?v = #
		ift ?p3=$c0
		?v=?v&[$c0^$ff]
		eif

		ift ?p2=$30
		?v=?v&[$30^$ff]
		eif

		ift ?p1=$0c
		?v=?v&[$0c^$ff]
		eif

		ift ?p0=$03
		?v=?v&[$03^$ff]
		eif

		dta ?v
		.endr


tMask		.rept 256
		?p3 = #&$c0
		?p2 = #&$30
		?p1 = #&$0c
		?p0 = #&$03

		?v = 0
		ift ?p3<>$c0
		?v=?v|$c0
		eif

		ift ?p2<>$30
		?v=?v|$30
		eif

		ift ?p1<>$0c
		?v=?v|$0c
		eif

		ift ?p0<>$03
		?v=?v|$03
		eif

		dta ?v^$ff
		.endr


shpBuf		:256 dta $ff

CharsBackupB0	:128 brk
CharsBackupB1	:128 brk


	.pages
Sprite0		@Spr
Sprite1		@Spr
Sprite2		@Spr
Sprite3		@Spr
Sprite4		@Spr
Sprite5		@Spr

lAdrPlayfield	:PlayfieldHeight+8	dta l(PlayfieldBuf+#*PlayfieldWidth)
hAdrPlayfield	:PlayfieldHeight+8	dta h(PlayfieldBuf+#*PlayfieldWidth)

tLShift		dta h(ShiftRight2L, ShiftRight2L, ShiftRight4L, ShiftRight6L)
tHShift		dta h(ShiftRight2H, ShiftRight2H, ShiftRight4H, ShiftRight6H)

EmptyChar	:8 brk

tOraLeft	dta %00000000
		dta %11000000
		dta %11110000
		dta %11111100

tOraRight	dta %00000000
		dta %00111111
		dta %00001111
		dta %00000011

	.endpg


//---------------------------------------------------------------------
//	E N G I N E
//---------------------------------------------------------------------

.local	Engine

//*********************************************************************
//	G£ÓWNY BLOK AKTUALIZACJI BUFORA PLAYFIELD
//*********************************************************************

buf	lda #0
	eor #1
	sta buf+1

	jne rB0

rB1	@sprite_playfield_restore B1 5		; usuwamy wszystkie duchy z pola gry
	@sprite_playfield_restore B1 4
	@sprite_playfield_restore B1 3
	@sprite_playfield_restore B1 2 
	@sprite_playfield_restore B1 1
	@sprite_playfield_restore B1 0

	jmp next0

rB0	@sprite_playfield_restore B0 5
	@sprite_playfield_restore B0 4
	@sprite_playfield_restore B0 3
	@sprite_playfield_restore B0 2
	@sprite_playfield_restore B0 1
	@sprite_playfield_restore B0 0

next0	lda buf+1			; modyfikacja bufora PLAYFIELD poprzez wstawienie znaków reprezentuj¹cych duchy
	jne uB0

	?ch = first_char

uB1	@sprite_backup B1 0		; licz now¹ klatkê ducha na nowej pozycji X:Y
	@sprite_backup B1 1
	@sprite_backup B1 2
	@sprite_backup B1 3
	@sprite_backup B1 4
	@sprite_backup B1 5

	@sprite_restore B1 5		; skasuj klatkê ducha z nowej pozycji X:Y
	@sprite_restore B1 4
	@sprite_restore B1 3
	@sprite_restore B1 2
	@sprite_restore B1 1
	@sprite_restore B1 0

	jsr Playfield_Update		; procedura u¿ytkownika aktualizauj¹ca pole gry

	?ch = first_char+6*4

	@sprite_show B0 0		; poka¿ poprzedni¹ klatkê ducha na poprzedniej pozycji X:Y
	@sprite_show B0 1
	@sprite_show B0 2
	@sprite_show B0 3
	@sprite_show B0 4
	@sprite_show B0 5

	jmp next1

	?ch = first_char+6*4

uB0	@sprite_backup B0 0
	@sprite_backup B0 1
	@sprite_backup B0 2
	@sprite_backup B0 3
	@sprite_backup B0 4
	@sprite_backup B0 5

	@sprite_restore B0 5
	@sprite_restore B0 4
	@sprite_restore B0 3
	@sprite_restore B0 2
	@sprite_restore B0 1
	@sprite_restore B0 0

	jsr Playfield_Update		; procedura u¿ytkownika aktualizauj¹ca pole gry

	?ch = first_char

	@sprite_show B1 0
	@sprite_show B1 1
	@sprite_show B1 2
	@sprite_show B1 3
	@sprite_show B1 4
	@sprite_show B1 5

//*********************************************************************

next1	lda buf+1		; modyfikacja znaków reprezentuj¹cych duchy
	jne B0

	?ch = first_char

B1	@sprite_create B1 0
	@sprite_create B1 1
	@sprite_create B1 2
	@sprite_create B1 3
	@sprite_create B1 4
	@sprite_create B1 5

	rts

B0	@sprite_create B0 0
	@sprite_create B0 1
	@sprite_create B0 2
	@sprite_create B0 3
	@sprite_create B0 4
	@sprite_create B0 5

	rts

//---------------------------------------------------------------------

RESET	lda #0				; wszystkie duchy wy³¹czone

	.rept 6,#
	sta Sprite:1.x
	sta Sprite:1.y
	sta Sprite:1.index
	sta Sprite:1.delay
	sta Sprite:1.new
	.endr

	rts
.endl


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro @sprite_backup

	ldy Sprite:2.x
	beq skp

	cpy #(PlayfieldWidth-4)*4
	scc
	ldy #(PlayfieldWidth-4)*4

	lda Sprite:2.y
	cmp #(PlayfieldHeight+4)*8
	scc
	lda #(PlayfieldHeight+4)*8

	sta Sprite:2.yOk
	sty Sprite:2.xOk

	lsr @
	lsr @
	lsr @
	tax

	sta Sprite:2.row

	tya
	lsr @
	lsr @
	add lAdrPlayfield,x
	sta zp+@zp.old:2:1
	sta zp+@zp.hlp5

	lda hAdrPlayfield,x
	adc #0
	sta zp+@zp.old:2:1+1
	sta zp+@zp.hlp5+1

	ldy #?ch

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteCharsBackup
skp
	.def ?ch+=4
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------


.macro	@sprite_create

	lda Sprite:2.x
	beq skp

	ldy #?ch		// regY = znak
	ldx Sprite:2.row	// regX = numer wiersza

	ift :1=B0		// regA = bufor znaków
	lda #:2*16
	els
	lda #:2*16+128
	eif

	jsr SpriteChars

	ldx <Sprite:2

	jsr MoveShape2Buf
skp
	.def ?ch+=4
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@sprite_playfield_restore

	lda Sprite:2.x
	beq skp

	lda Sprite:2.new
	beq ok

	lda #0
	sta Sprite:2.new
	beq skp

ok	lda zp+@zp.old:2:1
	ldy zp+@zp.old:2:1+1

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteRestore
skp
.endm


.macro	@sprite_restore

	lda Sprite:2.x
	beq skp

	lda zp+@zp.old:2:1
	ldy zp+@zp.old:2:1+1

	ift :1=B0
	ldx #:2*16
	els
	ldx #:2*16+128
	eif

	jsr SpriteRestore
skp
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@sprite_show

	lda Sprite:2.x
	beq skp

	lda zp+@zp.old:2:1
	ldx zp+@zp.old:2:1+1

	ldy #?ch

	jsr SpriteShow
skp
	.def ?ch+=4
.endm

//---------------------------------------------------------------------
//---------------------------------------------------------------------

	icl 'MoveShape2Buf.asm'
	icl 'SpriteChars.asm'
	icl 'SpriteCharsBackup.asm'
	icl 'SpriteRestore.asm'
	icl 'SpriteShow.asm'

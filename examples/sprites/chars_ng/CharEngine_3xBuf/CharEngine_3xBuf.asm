
//---------------------------------------------------------------------
// SOFTWARE SPRITES ENGINE II (CHARS MODE) v1.0 (24.10.2008)
//---------------------------------------------------------------------


; ZA£O¯ENIA:
; - mo¿liwoœæ zdefiniowana liczby zestawów znakowych zmienianych co wiersz (tablica CHARSETS) na przerwaniu DLI
; - kolory pola gry zmieniane co wiersz (przerwanie DLI) na podstawie tablic TCOLOR1, TCOLOR2, TCOLOR3
; - pole gry maksymalnie wysokie na 30+8 wierszy, szerokie maksymalnie na 40+8 bajtów
; - duch na pozycji X:Y = 0:0 jest poza polem gry, na pozycji 32:32 w lewym górnym naro¿niku pola gry
; - sta³a liczba duchów = 7
; - sta³y rozmiar duchów = 12x21 pixle
; - dwa bufory dla pamiêci obrazu, w ka¿dym z nich mo¿liwe jest u¿ycie znaków 0..70
; - tylko 1 bitmapa kszta³tu dla 1 klatki ducha, przesuwanie bitów realizowane poprzez tablicê
; - bitmapa maski obliczana na podstawie aktualnej bitmapy kszta³tu poprzez tablicê (nie ma potrzeby jej przesuwaæ)
; - sta³e wartoœci kodów znaków dla reprezentacji duchów

; ZALETY:
; - brak potrzeby rozpisania klatek kszta³tu i maski ducha, oszczêdnoœæ pamiêci

; WADY:
; - 7 duchów wyrabia siê w 2 ramkach na w¹skim ekranie (silnik z gry BombJack obs³u¿y w tym czasie 11 duchów)

; 	# BUFOR #0
;	# duch0 = znak 71, 72, 73, 74
;	# duch1 = znak 75, 76, 77, 78
;	# duch2 = znak 79, 80, 81, 82
;	# duch3 = znak 83, 84, 85, 86
;	# duch4 = znak 87, 88, 89, 90
;	# duch5 = znak 91, 92, 93, 94
;	# duch6 = znak 95, 96, 97, 98

; 	# BUFOR #1
;	# duch0 = znak 99, 100, 101, 102
;	# duch1 = znak 103, 104, 105, 106
;	# duch2 = znak 107, 108, 109, 110
;	# duch3 = znak 111, 112, 113, 114
;	# duch4 = znak 115, 116, 117, 118
;	# duch5 = znak 119, 120, 121, 122
;	# duch6 = znak 123, 124, 125, 126

; znak $7f nie mo¿e zostaæ u¿yty bo zostanie zniszczony obszar $fff8..$ffff z wektorami przerwañ


	icl 'Engine_3xBuf.hea'

	.reloc

	.extrn dlist, dlist0, dlist1, Charsets	.word

	.extrn zp	.byte

	.public Engine, Engine.reset
	.public Sprite0.x, Sprite1.x, Sprite2.x, Sprite3.x, Sprite4.x, Sprite5.x, Sprite6.x
	.public Sprite0.y, Sprite1.y, Sprite2.y, Sprite3.y, Sprite4.y, Sprite5.y, Sprite6.y
	.public Sprite0.bitmaps, Sprite1.bitmaps, Sprite2.bitmaps, Sprite3.bitmaps
	.public Sprite4.bitmaps, Sprite5.bitmaps, Sprite6.bitmaps

//---------------------------------------------------------------------

.struct	@zp

	old0B0		.word
	old1B0		.word
	old2B0		.word
	old3B0		.word
	old4B0		.word
	old5B0		.word
	old6B0		.word

	old0B1		.word
	old1B1		.word
	old2B1		.word
	old3B1		.word
	old4B1		.word
	old5B1		.word
	old6B1		.word

	hlp0		.word
	hlp1		.word
	hlp2		.word
	hlp3		.word
	hlp4		.word
	hlp5		.word
	hlp6		.word
.ends

	.print '@ZP Length: ',@zp

//---------------------------------------------------------------------

.struct	@Spr

	x	.byte
	y	.byte

	xOk	.byte
	yOk	.byte

	bitmaps	.word		; tablica z adresami bitmap (adres = $0000 koñczy tak¹ talicê)

	index	.byte		; indeks do tablicy BITMAPS
	delay	.byte
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

	.pages
Sprite0		@Spr
Sprite1		@Spr
Sprite2		@Spr
Sprite3		@Spr
Sprite4		@Spr
Sprite5		@Spr
Sprite6		@Spr

lAdrPlayfield	:PlayfieldHeight+8	dta l(#*PlayfieldWidth)

hAdrPlayfieldB0	:PlayfieldHeight+8	dta h(PlayfieldB0+#*PlayfieldWidth)
hAdrPlayfieldB1	:PlayfieldHeight+8	dta h(PlayfieldB1+#*PlayfieldWidth)

tLShift	dta h(ShiftRight2L, ShiftRight2L, ShiftRight4L, ShiftRight6L)
tHShift	dta h(ShiftRight2H, ShiftRight2H, ShiftRight4H, ShiftRight6H)

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
//---------------------------------------------------------------------

.macro	@CallSprite

	ldy Sprite:2.x
	seq
	jsr Sprite:2:1
.endm

//---------------------------------------------------------------------

.local	Engine

buf	lda #0				; prze³¹czanie buforów
	tax
	eor #1
	sta buf+1	

	mva ldlist,x dlist
	sta $d402
	mva hdlist,x dlist+1
	sta $d403

	cpx #0
	sne
	jmp PlayfieldB1_Restore		; usuniêcie duchów w buforze #1, wyœwietlany jest bufor #0
	jmp PlayfieldB0_Restore		; usuniecie duchów w buforze #0, wyœwietlany jest bufor #1


return	cpx #0
	bne B0

B1	@CallSprite B1 0
	@CallSprite B1 1
	@CallSprite B1 2
	@CallSprite B1 3
	@CallSprite B1 4
	@CallSprite B1 5
	@CallSprite B1 6

	rts


B0	@CallSprite B0 0
	@CallSprite B0 1
	@CallSprite B0 2
	@CallSprite B0 3
	@CallSprite B0 4
	@CallSprite B0 5
	@CallSprite B0 6

	rts


RESET	lda #0				; wszystkie duchy wy³¹czone
	sta Sprite0.x
	sta Sprite1.x
	sta Sprite2.x
	sta Sprite3.x
	sta Sprite4.x
	sta Sprite5.x
	sta Sprite6.x

	sta Sprite0.y
	sta Sprite1.y
	sta Sprite2.y
	sta Sprite3.y
	sta Sprite4.y
	sta Sprite5.y
	sta Sprite6.y

	sta Sprite0.index
	sta Sprite1.index
	sta Sprite2.index
	sta Sprite3.index
	sta Sprite4.index
	sta Sprite5.index
	sta Sprite6.index

	sta Sprite0.delay
	sta Sprite1.delay
	sta Sprite2.delay
	sta Sprite3.delay
	sta Sprite4.delay
	sta Sprite5.delay
	sta Sprite6.delay

	lda <PlayfieldB0		; poprzedni adres ducha dla BUF#0 ustawiamy na lewy górny naro¿nik
	sta zp+@zp.old0B0
	sta zp+@zp.old1B0
	sta zp+@zp.old2B0
	sta zp+@zp.old3B0
	sta zp+@zp.old4B0
	sta zp+@zp.old5B0
	sta zp+@zp.old6B0

	lda >PlayfieldB0
	sta zp+@zp.old0B0+1
	sta zp+@zp.old1B0+1
	sta zp+@zp.old2B0+1
	sta zp+@zp.old3B0+1
	sta zp+@zp.old4B0+1
	sta zp+@zp.old5B0+1
	sta zp+@zp.old6B0+1

	lda <PlayfieldB1		; poprzedni adres ducha dla BUF#1 ustawiamy na lewy górny naro¿nik
	sta zp+@zp.old0B1
	sta zp+@zp.old1B1
	sta zp+@zp.old2B1
	sta zp+@zp.old3B1
	sta zp+@zp.old4B1
	sta zp+@zp.old5B1
	sta zp+@zp.old6B1

	lda >PlayfieldB1
	sta zp+@zp.old0B1+1
	sta zp+@zp.old1B1+1
	sta zp+@zp.old2B1+1
	sta zp+@zp.old3B1+1
	sta zp+@zp.old4B1+1
	sta zp+@zp.old5B1+1
	sta zp+@zp.old6B1+1

	rts

ldlist	dta l(dlist0, dlist1)
hdlist	dta h(dlist0, dlist1)

.endl


//---------------------------------------------------------------------
//	SPRITE #0..#7 B0
//---------------------------------------------------------------------

	?ch = 70

Sprite0B0	@sprite_init B0 0
Sprite1B0	@sprite_init B0 1
Sprite2B0	@sprite_init B0 2
Sprite3B0	@sprite_init B0 3
Sprite4B0	@sprite_init B0 4
Sprite5B0	@sprite_init B0 5
Sprite6B0	@sprite_init B0 6

//---------------------------------------------------------------------
//	SPRITE #0..#7 B1
//---------------------------------------------------------------------

Sprite0B1	@sprite_init B1 0
Sprite1B1	@sprite_init B1 1
Sprite2B1	@sprite_init B1 2
Sprite3B1	@sprite_init B1 3
Sprite4B1	@sprite_init B1 4
Sprite5B1	@sprite_init B1 5
Sprite6B1	@sprite_init B1 6


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@sprite_init

	.def ?cnt = 0
	.def ?row = 0

	cpy #(PlayfieldWidth-4)*4
	scc
	ldy #(PlayfieldWidth-4)*4

	lda Sprite:2.y
	cmp #(PlayfieldHeight+4)*8
	scc
	lda #(PlayfieldHeight+4)*8

	sty Sprite:2.xOk		; aktualnie obowi¹zuj¹ca pozycja pozioma ducha
	sta Sprite:2.yOk		; aktualnie obowi¹zuj¹ca pozycja pionowa ducha

	lsr @
	lsr @
	lsr @
	tax

	tya
	lsr @
	lsr @
	add lAdrPlayfield,x
	sta zp+@zp.old:2:1
	sta zp+@zp.hlp6

	lda hAdrPlayfield:1,x
	adc #0
	sta zp+@zp.old:2:1+1
	sta zp+@zp.hlp6+1

	ldy #?ch

	jsr SpriteChars			// regA = znak ; regX = pozycja Y

	ldx <Sprite:2

	jmp MoveShape2Buf

	.def ?ch+=4
.endm


//---------------------------------------------------------------------
//---------------------------------------------------------------------

	icl 'MoveShape2Buf.asm'
	icl 'PlayfieldRestore.asm'
	icl 'SpriteChars.asm'

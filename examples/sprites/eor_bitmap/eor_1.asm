
/*
 v1.1 - najszybsza, maksymalna szerokoœæ ducha ShapeWidth = 5 (czyli 32 pixle trybu F ANTIC-a, 16 pixle trybu E ANTIC-a)

 Silnik dla duchów programowych zapo¿yczony z gry MARIO BROS. (disasemblacja i modyfikacje Tebe/Madteam, 11.09.2007)

 Silnik ten dzia³a na zasadzie EOR-owania obrazu, wykorzystuje tylko 1 bufor obrazu, zajmuje bardzo ma³o pamiêci, nie
 ma potrzeby zapamiêtywania ani odœwie¿ania zawartoœci ekranu po wyœwietleniu ducha.

 Przesuniêcia bitów zosta³y stablicowane ShiftRight2H:ShiftRight2L, ShiftRight4H:ShiftRight4L, ShiftRight6H:ShiftRight6L

 *** !!! Dokonywane jest przesuniêcie dwóch bitmap ducha (z pozycji poprzedniej i aktualnej) !!! ***

 !!! Maksymalna wysokoœæ przetwarzanych duchów wynosi 128/ShapeWidth !!!

 !!! Minimalna szerokoœæ duchów ShapeWidth = 2..5 !!!

 Ca³y silnik sk³ada siê z dwóch procedur PutShape i MoveShapeToBuffer.

 PutShape		w³aœciwa procedura realizuj¹ca przesuwanie bitów bitmapy ducha i umieszczanie
 			ich w odpowiednim obszarze pamiêci (obszarze pamiêci obrazu)

 MoveShapeToBuffer	procedura kopiuj¹ca dane bitmapy ducha do jednego z dwóch buforów pomocniczych
 			ShapeBuffer0 i ShapeBuffer1

 SCHEMAT DZIA£ANIA:

 0. duch0_enabled=false		; duch o wspó³rzêdnych poprzednich (gdy startujemy nie mamy danych o takim duchu)
    duch1_enabled=true		; duch o wspó³rzêdnych aktualnych

 1. IF duch0_enabled THEN
	przepisz_bitmape_dla_ducha0_i_przesuñ_jej_pixle
    ELSE
	zapisz_zerow¹_bitmape_dla_ducha0_nie_przesuwaj_pixli
    ENDIF
 
 2. IF duch1_enabled THEN
	przepisz_bitmape_dla_ducha1_i_przesuñ_jej_pixle
    ELSE
	zapisz_zerow¹_bitmape_dla_ducha1_nie_przesuwaj_pixli
    ENDIF

 3. duch0 EOR dane_obrazu_o_wspó³rzêdnych_dla_ducha0
    duch1 EOR dane_obrazu_o_wspó³rzêdnych_dla_ducha1

 4. przepisz dane opisuj¹ce ducha1 do ducha0

 5. goto 1

*/


; $3a linii skaningowych (maksymalna prêdkoœæ silnika dla ducha o rozmiarze 32x16 pixli Hires)
; $2f linii skaningowych (maksymalna prêdkoœæ silnika dla ducha o rozmiarze 24x16 pixli Hires)
; $23 linii skaningowych (maksymalna prêdkoœæ silnika dla ducha o rozmiarze 16x16 pixli Hires)
; $17 linii skaningowych (maksymalna prêdkoœæ silnika dla ducha o rozmiarze 8x16 pixli Hires)


Screen		= $a010		; adres pamiêci obrazu

ScreenWidth	= 40		; szerokoœæ obrazu

ShapeWidth	= 4		; width+1, szerokoœæ przetwarzanych duchów w bajtach (+1 dodatkowy bajt)

	ert ShapeWidth<2||ShapeWidth>5

* -------------------------------------------------------------------

	org $80

height		.ds 1		; parametry ducha
positionX	.ds 1
positionY	.ds 1
type		.ds 1
enabled		.ds 1
collision	.ds 1

height_old	.ds 1		; kopia parametrów ducha
positionX_old	.ds 1
positionY_old	.ds 1
type_old	.ds 1
enabled_old	.ds 1
collision_old	.ds 1

ScreenAdr0	.ds 2
ScreenAdr1	.ds 2

	ert *>$ff

* -------------------------------------------------------------------

	org $2000

ShapeBuffer	.ds 256
ShapeBuffer0	= ShapeBuffer		; bufor pomocniczy dla ducha #0 (koniecznie w obszarze strony pamiêci)
ShapeBuffer1	= ShapeBuffer+128	; bufor pomocniczy dla ducha #1 (koniecznie w obszarze strony pamiêci)

lAdrLine	:256 dta l(Screen+#*ScreenWidth)	; m³odsze bajty adresu linii obrazu
hAdrLine	:256 dta h(Screen+#*ScreenWidth)	; starsze bajty adresu linii obrazu

ShiftRight2H	:256 dta h([#<<8]>>2)
ShiftRight2L	:256 dta l([#<<8]>>2)

ShiftRight4H	:256 dta h([#<<8]>>4)
ShiftRight4L	:256 dta l([#<<8]>>4)

ShiftRight6H	:256 dta h([#<<8]>>6)
ShiftRight6L	:256 dta l([#<<8]>>6)

mulTab		:128/ShapeWidth dta #*ShapeWidth	; pomocnicza tablica mno¿enia (oszczêdzamy dziêki niej pare cykli)


dlist	dta d'ppp'		; program dla ANTIC-a
	dta $4e,a(screen)
	:101 dta $e
	dta $4e,0,h(screen+$1000)
	:101 dta $e
	dta $41,a(dlist)
	

main	mwa #dlist 560

	lda #$ff		; zezwolenie na ducha #0
	sta enabled

	lda #0			; blokada ducha #1
	sta enabled_old

	lda #16
	sta height

	lda #100
	sta positionX

	lda #60
	sta positionY

	lda #0
	sta type


loop
;	lda:cmp:req 20
	lda:rne $d40b
	

	mva #$0f $d01a

	jsr putShape

	inc positionX

	inc positionY
	lda positionY
	cmp #204-32
	scc
	lda #0

	sta positionY

	mva #$00 $d01a

	lda $d40b
	cmp $100
	scc
	sta $100	

	jmp loop


* -------------------------------------------------------------------
* ---	WYŒWIETLENIE DUCHÓW PROGRAMOWYCH W POLU GRY
* ---	PRZETWARZANE S¥ DWA DUCHY, ShapeBuffer0 (#0) i ShapeBuffer1 (#1)
* ---	DUCH NA POZYCJI POPRZEDNIEJ ORAZ DUCH NA POZYCJI AKTUALNEJ
* ---	NIE MA POTRZEBY ODŒWIE¯ANIA POLA GRY STAR¥ ZAWARTOŒÆI¥
* -------------------------------------------------------------------
.proc	PutShape

	mva #0 collision		; !!! ZNACZNIK KOLIZJI !!!

	lda enabled_old			; czy zerowaæ bufor ducha #0
	bne E_9568

	lda #$00			; zerowanie obszaru ducha #0 (84 bajty), duch ma wysokoœæ max 21 linii
	ldx #$53
	sta:rpl ShapeBuffer0,x-
	bmi E_957f

E_9568	ldy type_old

	ldx	<ShapeBuffer0
	jsr	moveShapeToBuffer

E_957f	lda enabled			; czy zerowaæ bufor ducha #1
	bne E_958f

	lda #$00			; zerowanie obszaru ducha #1 (84 bajty), duch ma wysokoœæ max 21 linii
	ldx #$53
	sta:rpl ShapeBuffer1,x-
	bmi E_95a6

E_958f	ldy type

	ldx	<ShapeBuffer1
	jsr	moveShapeToBuffer

E_95a6	lda positionX_old		; pozycja pozioma ducha #0
	and #$03
	beq E_95d4

	tay
	ldx tabShiftH,y

	ift .def tShfH0
	stx tShfH0+2
	eif

	ift .def tShfH1
	stx tShfH1+2
	eif

	ift .def tShfH2
	stx tShfH2+2
	eif

	ift .def tShfH3
	stx tShfH3+2
	eif

	ift .def tShfH4
	stx tShfH4+2
	eif

	inx

	ift .def tShfL0
	stx tShfL0+2
	eif

	ift .def tShfL1
	stx tShfL1+2
	eif

	ift .def tShfL2
	stx tShfL2+2
	eif

	ift .def tShfL3
	stx tShfL3+2
	eif

E_95ae	ldy height_old			; wysokoœæ ducha
	dey
E_95b1	ldx mulTab,y

	sec

shift	ldy ShapeBuffer0,x
tShfH0	lda $ff00,y
	sta ShapeBuffer0,x
tShfL0	lda $ff00,y

	ldy ShapeBuffer0+1,x
tShfH1	ora $ff00,y
	sta ShapeBuffer0+1,x

	ift ShapeWidth>2
tShfL1	lda $ff00,y

	ldy ShapeBuffer0+2,x
tShfH2	ora $ff00,y
	sta ShapeBuffer0+2,x
	eif

	ift ShapeWidth>3
tShfL2	lda $ff00,y

	ldy ShapeBuffer0+3,x
tShfH3	ora $ff00,y
	sta ShapeBuffer0+3,x
	eif

	ift ShapeWidth>4
tShfL3	lda $ff00,y

	ldy ShapeBuffer0+4,x
tShfH4	ora $ff00,y
	sta ShapeBuffer0+4,x
	eif

	txa
	sbc #ShapeWidth
	tax

	bpl shift


E_95d4	lda positionX			; pozycja pozioma ducha #1
	and #$03
	beq E_9602

	tay
	ldx tabShiftH,y

	ift .def _tShfH0
	stx _tShfH0+2
	eif

	ift .def _tShfH1
	stx _tShfH1+2
	eif

	ift .def _tShfH2
	stx _tShfH2+2
	eif

	ift .def _tShfH3
	stx _tShfH3+2
	eif

	ift .def _tShfH4
	stx _tShfH4+2
	eif

	inx

	ift .def _tShfL0
	stx _tShfL0+2
	eif

	ift .def _tShfL1
	stx _tShfL1+2
	eif

	ift .def _tShfL2
	stx _tShfL2+2
	eif

	ift .def _tShfL3
	stx _tShfL3+2
	eif

E_95dc	ldy height			; wysokoœæ ducha
	dey
E_95df	ldx mulTab,y

	sec

_shift	ldy ShapeBuffer1,x
_tShfH0	lda $ff00,y
	sta ShapeBuffer1,x
_tShfL0	lda $ff00,y

	ldy ShapeBuffer1+1,x
_tShfH1	ora $ff00,y
	sta ShapeBuffer1+1,x

	ift ShapeWidth>2
_tShfL1	lda $ff00,y

	ldy ShapeBuffer1+2,x
_tShfH2	ora $ff00,y
	sta ShapeBuffer1+2,x
	eif

	ift ShapeWidth>3
_tShfL2	lda $ff00,y

	ldy ShapeBuffer1+3,x
_tShfH3	ora $ff00,y
	sta ShapeBuffer1+3,x
	eif

	ift ShapeWidth>4
_tShfL3	lda $ff00,y

	ldy ShapeBuffer1+4,x
_tShfH4	ora $ff00,y
	sta ShapeBuffer1+4,x
	eif

	txa
	sbc #ShapeWidth
	tax

	bpl _shift


E_9602	ldy height

	ldx mulTab,y
	dex				; wysokoœæ ducha*ShapeWidth-1 = d³ugoœæ danych ducha (!!! regX !!!)

	lda positionY_old		; pozycja pionowa ducha #0
	clc
	adc height			; wysokoœæ ducha
	tay

	lda positionX_old		; pozycja pozioma ducha #0
	:2 lsr @
	clc
	adc ladrLine,y
	sta ScreenAdr0
	lda #$00
	adc hadrLine,y
	sta ScreenAdr0+1		; adres pierwszego bajtu ekranu dla ducha #0


	lda positionY			; pozycja pionowa ducha #1
	clc
	adc height			; wysokoœæ ducha 
	tay

	lda positionX			; pozycja pozioma ducha #1
	:2 lsr @
	clc
	adc ladrLine,y
	sta ScreenAdr1
	lda #$00
	adc hadrLine,y
	sta ScreenAdr1+1		; adres pierwszego bajtu ekranu dla ducha #1


E_9656	ldy #ShapeWidth-1		; przenosimy duchy od do³u do góry (pewnie w celu zminimalizowania mrugania)

	.rept ShapeWidth
	lda ShapeBuffer0-#,x
	eor (ScreenAdr0),y
	sta (ScreenAdr0),y

	lda (ScreenAdr1),y		; jeœli bajt t³a to nie ma kolizji

	seq				; !!!!!!!!!!!!!!!! DETEKCJA KOLIZJI !!!!!!!!!!!!!!!!!
	sta collision			; !!!!!!!!!!! BANALNA W SWEJ PROSTOCIE !!!!!!!!!!!!!!

	eor ShapeBuffer1-#,x
	sta (ScreenAdr1),y
	
	ift #<>ShapeWidth-1
	dey
	eif
	.endr

	sec

	lda ScreenAdr0
	sbc #ScreenWidth
	sta ScreenAdr0
	bcs _skp0
	dec ScreenAdr0+1
	sec

_skp0	lda ScreenAdr1
	sbc #ScreenWidth
	sta ScreenAdr1
	bcs _skp1
	dec ScreenAdr1+1
	sec
_skp1
	txa
	sbc #ShapeWidth
	tax

	bpl E_9656

	mva	positionX	positionX_old
	mva	positionY	positionY_old
	mva	type		type_old
	mva	height		height_old
	mva	enabled		enabled_old
	mva	collision	collision_old

	rts

tabShiftH	dta h(0, ShiftRight2H, ShiftRight4H, ShiftRight6H)

.endp


* -------------------------------------------------------------------
* ---	KOPIOWANIE DUCHA DO BUFORA, DUCHY MAJ¥ SZEROKOŒÆ 3 BAJTÓW
* ---	JEDNAK BUFOR WYPE£NIANY JEST 4 BAJTAMI, 4 BAJT JEST ZEROWANY
* -------------------------------------------------------------------
.proc	MoveShapeToBuffer

	mva	lAdrShape,y	ScreenAdr1
	mva	hAdrShape,y	ScreenAdr1+1

	ldy height			; wysokoœæ ducha

	txa
	add mulTab,y
	sta max				; wysokoœæ ducha*ShapeWidth+<ShapeBuffer

	ldy #0

moveShp
	.rept ShapeWidth
	ift #<>ShapeWidth-1
	lda (ScreenAdr1),y		; przenosimy do bufora bitmape ducha
	sta ShapeBuffer+#,x
	iny
	els
	lda #0
	sta ShapeBuffer+#,x		; ostatni bajt jest zerowany
	eif
	.endr

;	clc
	txa
	adc #ShapeWidth
	tax

	cpx #0
max	equ *-1
	bne moveShp
	rts
.endp


* ---------------------------------

lAdrShape	dta l(krab)
hadrShape	dta h(krab)

	.get 'crab.mic'

krab	@@CutMIC 0 0 ShapeWidth-1 16

* ---------------------------------

	run main

	.print 'PROC PutShape length: ',.len PutShape
	.print 'PROC MoveShapeToBuffer length: ',.len MoveShapeToBuffer

	opt l-
	icl '@@cutmic.mac'

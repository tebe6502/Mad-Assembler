
/*
 v3.0 - naj najszybsza, kosztem pamięci (obsługa 1 ducha zajmuje prawie $300 bajtów pamięci),
 	do obsługi ducha potrzebna osobna procedura (np. 8 duchów = 8 procedur)

 Silnik ten działa na zasadzie EOR-owania obrazu, wykorzystuje tylko 1 bufor obrazu, potrzebuje $300 bajtów pamięci
 na obsługę 1 ducha, nie ma potrzeby zapamiętywania ani odświeżania zawartości ekranu po wyświetleniu ducha.

 Przesunięcia bitów zostały stablicowane ShiftRight2H:ShiftRight2L, ShiftRight4H:ShiftRight4L, ShiftRight6H:ShiftRight6L

 *** !!! Dokonywane jest przesunięcie JEDNEJ bitmapy ducha z aktualnej pozycji, bitmapa z poprzedniej pozycji jest w buforze !!! ***

 !!! Maksymalna wysokość przetwarzanych duchów wynosi 128/ShapeWidth !!!

 !!! Minimalna szerokość duchów ShapeWidth = 2..5 !!!

 Cały silnik składa się z jednej procedury PutShape

 PutShape	procedura realizująca kopiowanie bitmapy ducha do bufora, przesuwanie bitów bitmapy ducha,
 		umieszczanie nowo przeliczonej bitmapy w odpowiednim obszarze pamięci (obszarze pamięci obrazu)


 SCHEMAT DZIAŁANIA:

 0. X = $80
    wyzeruj obszar ShapeBuffer[0..127]
 
 1. przepisz_bitmape_dla_ducha_i_przesuń_jej_pixle w obszarze ShapeBuffer[X..X+127]

 2. if X<>0
	duch0 EOR dane_obrazu_o_współrzędnych_dla_ducha0
    	duch1 EOR dane_obrazu_o_współrzędnych_dla_ducha1
    else
	duch1 EOR dane_obrazu_o_współrzędnych_dla_ducha0
    	duch0 EOR dane_obrazu_o_współrzędnych_dla_ducha1
    endif

 4. X = X eor $80

 5. goto 1

*/


; $26 linii skaningowych (maksymalna prędkość silnika dla ducha o rozmiarze 32x16 pixli Hires)
; $1e linii skaningowych (maksymalna prędkość silnika dla ducha o rozmiarze 24x16 pixli Hires)
; $16 linii skaningowych (maksymalna prędkość silnika dla ducha o rozmiarze 16x16 pixli Hires)
; $0e linii skaningowych (maksymalna prędkość silnika dla ducha o rozmiarze 8x16 pixli Hires)


Screen		= $a010		; adres pamięci obrazu

ScreenWidth	= 40		; szerokość obrazu

ShapeWidth	= 4		; width+1, szerokość przetwarzanych duchów w bajtach (+1 dodatkowy bajt)

	ert ShapeWidth<2||ShapeWidth>5

* -------------------------------------------------------------------

	org $80

height		.ds 1		; parametry ducha
positionX	.ds 1
positionY	.ds 1
type		.ds 1
collision	.ds 1

positionX_old	.ds 1
positionY_old	.ds 1
collision_old	.ds 1

temp		.ds 1		; zmienne pomocnicze

ScreenAdr0	.ds 2
ScreenAdr1	.ds 2

	ert *>$ff

* -------------------------------------------------------------------

	org $2000

dlist	dta d'ppp'		; program dla ANTIC-a
	dta $4e,a(screen)
	:101 dta $e
	dta $4e,0,h(screen+$1000)
	:101 dta $e
	dta $41,a(dlist)


tabShiftH	dta h(0, ShiftRight2H, ShiftRight4H, ShiftRight6H)

;tabShiftL	dta h(0, ShiftRight2L, ShiftRight4L, ShiftRight6L)

* -------------------------------------------------------------------

	org $2100

ShapeBuffer	.ds 256
ShapeBuffer0	= ShapeBuffer		; bufor pomocniczy dla ducha #0 (koniecznie w obszarze strony pamięci)
ShapeBuffer1	= ShapeBuffer+128	; bufor pomocniczy dla ducha #1 (koniecznie w obszarze strony pamięci)

lAdrLine	:256 dta l(Screen+#*ScreenWidth)	; młodsze bajty adresu linii obrazu
hAdrLine	:256 dta h(Screen+#*ScreenWidth)	; starsze bajty adresu linii obrazu

ShiftRight2H	:256 dta h([#<<8]>>2)
ShiftRight2L	:256 dta l([#<<8]>>2)

ShiftRight4H	:256 dta h([#<<8]>>4)
ShiftRight4L	:256 dta l([#<<8]>>4)

ShiftRight6H	:256 dta h([#<<8]>>6)
ShiftRight6L	:256 dta l([#<<8]>>6)

mulTab0		:128/ShapeWidth dta #*ShapeWidth	; pomocnicza tablica mnożenia (oszczędzamy dzięki niej pare cykli)
mulTab1		:128/ShapeWidth dta #*ShapeWidth+$80	; pomocnicza tablica mnożenia (oszczędzamy dzięki niej pare cykli)


main	lda:cmp:req 20
	mwa #dlist 560

	lda #16
	sta height

	lda #100
	sta positionX

	lda #60
	sta positionY

	lda #0
	sta type


	lda <mulTab1			; init default value
	sta PutShape.E_95df+1

	lda <ShapeBuffer1
	sta PutShape.E_9591+1

.nowarn	lda #{bmi}
	sta PutShape.loopShf


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
	sta $100	; tutaj zapisujemy aktualną szybkość wyświetlenia ducha

	jmp loop


* -------------------------------------------------------------------
* ---	WYŚWIETLENIE DUCHÓW PROGRAMOWYCH W POLU GRY
* ---	PRZETWARZANE SĄ DWA DUCHY, ShapeBuffer0 (#0) i ShapeBuffer1 (#1)
* ---	DUCH NA POZYCJI POPRZEDNIEJ ORAZ DUCH NA POZYCJI AKTUALNEJ
* ---	NIE MA POTRZEBY ODŚWIEŻANIA POLA GRY STARĄ ZAWARTOŚĆIĄ
* -------------------------------------------------------------------
.proc	PutShape

	mva #0 collision		; !!! ZNACZNIK KOLIZJI !!!


E_958f	ldy type

E_9591	ldx	<ShapeBuffer1		; !!! koniecznie zaczynamy od <ShapeBuffer1 !!!

	mva	lAdrShape,y	ScreenAdr1
	mva	hAdrShape,y	ScreenAdr1+1

	ldy height			; wysokość ducha

	txa
	add mulTab0,y
	sta max				; wysokość ducha*ShapeWidth+<ShapeBuffer

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


E_95d4	lda positionX			; pozycja pozioma ducha #1
	and #$03
	beq E_9602

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

E_95dc	ldy height			; wysokość ducha
	dey

E_95df	ldx mulTab1,y			; !!! koniecznie zaczynamy od mulTab1 !!!

	sec

shift	ldy ShapeBuffer,x
tShfH0	lda $ff00,y
	sta ShapeBuffer,x
tShfL0	lda $ff00,y

	ldy ShapeBuffer+1,x
tShfH1	ora $ff00,y
	sta ShapeBuffer+1,x

	ift ShapeWidth>2
tShfL1	lda $ff00,y

	ldy ShapeBuffer+2,x
tShfH2	ora $ff00,y
	sta ShapeBuffer+2,x
	eif

	ift ShapeWidth>3
tShfL2	lda $ff00,y

	ldy ShapeBuffer+3,x
tShfH3	ora $ff00,y
	sta ShapeBuffer+3,x
	eif

	ift ShapeWidth>4
tShfL3	lda $ff00,y

	ldy ShapeBuffer+4,x
tShfH4	ora $ff00,y
	sta ShapeBuffer+4,x
	eif

	txa
	sbc #ShapeWidth
	tax

loopShf	bmi shift


E_9602	ldy height

	ldx mulTab0,y
	dex				; wysokość ducha*ShapeWidth-1 = długość danych ducha (!!! regX !!!)

	lda positionY_old		; pozycja pionowa ducha #0
	clc
	adc height			; wysokość ducha
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
	adc height			; wysokość ducha 
	tay

	lda positionX			; pozycja pozioma ducha #1
	:2 lsr @
	clc
	adc ladrLine,y
	sta ScreenAdr1
	lda #$00
	adc hadrLine,y
	sta ScreenAdr1+1		; adres pierwszego bajtu ekranu dla ducha #1

	lda E_9591+1
	bne b01

b10	.local

	ldy #ShapeWidth-1		; przenosimy duchy od dołu do góry (pewnie w celu zminimalizowania mrugania)

	.rept ShapeWidth
	lda ShapeBuffer1-#,x
	eor (ScreenAdr0),y
	sta (ScreenAdr0),y

	lda (ScreenAdr1),y		; jeśli bajt tła to nie ma kolizji

	seq				; !!!!!!!!!!!!!!!! DETEKCJA KOLIZJI !!!!!!!!!!!!!!!!!
	sta collision			; !!!!!!!!!!! BANALNA W SWEJ PROSTOCIE !!!!!!!!!!!!!!

	eor ShapeBuffer0-#,x
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

	bpl b10
	bmi quit

	.endl


b01	.local

	ldy #ShapeWidth-1		; przenosimy duchy od dołu do góry (pewnie w celu zminimalizowania mrugania)

	.rept ShapeWidth
	lda ShapeBuffer0-#,x
	eor (ScreenAdr0),y
	sta (ScreenAdr0),y

	lda (ScreenAdr1),y		; jeśli bajt tła to nie ma kolizji

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

	bpl b01

	.endl

quit
	mva	positionX	positionX_old
	mva	positionY	positionY_old
	mva	collision	collision_old

	lda E_95df+1			; przełączenie buforów
	eor #[<mulTab0]^[<mulTab1]
	sta E_95df+1

	lda E_9591+1
	eor #[<ShapeBuffer0]^[<ShapeBuffer1]
	sta E_9591+1

	lda loopShf
.nowarn	eor #{bpl}^{bmi}
	sta loopShf

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

	opt l-
	icl '@@cutmic.mac'

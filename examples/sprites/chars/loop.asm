
* ---	LOOP
; główna pętla sterująca wykonywana non-stop

LOOP

* ---	modyfikujemy BUFOR2, wyswietlamy BUFOR3

	WAIT	B3

	mva	#charsBAK	free	; pierwszy wolny znak do wykorzystania przez duchy

	INITBUF	B2

	mva cloc speed			; w komórce SPEED liczba ramek reprezentująca szybkość silnika


* ---	modyfikujemy BUFOR3, wyswietlamy BUFOR2

	WAIT	B2

	mva	#charsBAK	free	; pierwszy wolny znak do wykorzystania przez duchy

	INITBUF	B3

	mva cloc speed			; w komórce SPEED liczba ramek reprezentująca szybkość silnika

	jmp loop



* ---	B2SHAPE
; stawianie duchów w BUFOR #2
;
; B2CALC inicjuje adresy SRC, DST na podstawie znaków odczytanych z pamięci obrazu BUFOR #2
; dodatkowo ustawia nowe znaki w miejsce wcześniej odczytanych które będą reprezentować ducha

B2SHAPE	.proc

	SPRTEST			; krótki test, czy aktualny duch będzie przetwarzany w tej kolejce

	jsr	GETPARAM	; w GETPARAM m.in. rejestr X zostaje zapamiętany w OLDX
				; oraz parametry ducha zostają przepisane do zmiennych POSX, POSY, BANK, TYPE, HEIGHT
*---
	CALC	B2		; właściwy fragment kodu modyfikujący znaki z BUFOR #3	
*---				; na końcu skaczemy do programu obsługi ducha

	ift COLLISION_DETECTION
	jmp	DETECT_UPD	; kończymy skokiem do procedury aktualizacji tablic detekcji COLISx, COLISy
	els
	rts
	eif

	.endp


* ---	B3SHAPE
; stawianie duchów w BUFOR #3
;
; B3CALC inicjuje adresy SRC, DST na podstawie znaków odczytanych z pamięci obrazu BUFOR #3
; dodatkowo ustawia nowe znaki w miejsce wcześniej odczytanych które będą reprezentować ducha

B3SHAPE	.proc

	SPRTEST			; krótki test, czy aktualny duch będzie przetwarzany w tej kolejce

	jsr	GETPARAM	; w GETPARAM m.in. rejestr X zostaje zapamiętany w OLDX
				; oraz parametry ducha zostają przepisane do zmiennych POSX, POSY, BANK, TYPE, HEIGHT
*---
	CALC	B3		; właściwy fragment kodu modyfikujący znaki z BUFOR #3		
*---				; na końcu skaczemy do programu obsługi ducha

	ift COLLISION_DETECTION
	jmp	DETECT_UPD	; kończymy skokiem do procedury aktualizacji tablic detekcji COLISx, COLISy
	els
	rts
	eif

	.endp



* ---	GETPARAM
; wspólna dla B2SHAPE i B3SHAPE procedura odczytująca i uaktualniająca parametry ducha
; zwiększany jest licznik klatek animacji @SPRITE.CNT, maksymalna liczba klatek animacji
; podana jest w tablicy SHAPES -> SHAPES.MAX

GETPARAM
	stx	oldX

	ldy	sprites[0].shp,x	; odczytujemy numer kształtu ducha

	mwa	sprites[0].frm,x	zp[0].src	; adres tablicy z zapisaną kolejnością klatek animacji (numer*8)
							; korzystamy z zp[0].src bo później i tak zostanie tam zapisany adres
	mva	shapes[0].bnk,y		bank
	mva	shapes[0].typ,y		type
	mva	shapes[0].hig,y		height

	mva	sprites[0].psx,x	posx
	mva	sprites[0].psy,x	posy

	cmp	#@sh*8-16
	scc
	rts

	and	#7			; obliczamy ofset przesunięcia w pionie dla SHP i MSK
	eor	#7
	sta	zp[1].src		; (posy&7)^7+1
		 			; korzystamy z zp[1].src bo i tak zostanie tam zapisany adres

	ldy	#0

	lda	sprites[0].cnt,x
	add	#1			; zwiększamy licznik klatek animacji
	cmp	(zp[0].src),y		; porównujemy z dopuszczalną maksymalną wartością (SHAPES.FRM),0
	scc				; (rejestr Y zawiera indeks do tablicy SHAPES)
	tya				; zerujemy licznik klatek (Y=0)

	sta	sprites[0].cnt,x

	tay			; w rejestrze Y znajduje sie aktualny numer klatki do wyświetlenia

	iny			; Y++ ponieważ omijamy pierwszy bajt tablicy, pierwszy bajt tablicy
				; określa maksymalną wartość licznika klatek animacji, sprawdzaliśmy go 'CMP (ZP[0].SRC),Y'
	lda	posx
	and	#3
	asl	@		; a=(posx&3)*2

	clc
	adc	(zp[0].src),y	; a=a+y*8
	tay

*---
; inicjalizacja adresow SHP i MSK
;
; odbywa się przez zaincjowanie rejestrów A, X, Y odpowiednią wartością z tablic
; shpAdr12, mskAdr12	dla ducha 12x24
; shpAdr8, mskAdr8	dla ducha 8x24
;
; potem zwiększamy SHP i MSK co 8 bajtów
;
; MSK względem SHP przesunięte jest zawsze o $2000 bajtów, wykorzystujemy tą właściwość przy optymalizacji kodu

	lda	type		; rodzaj ducha, wartość =0 to duch 12x24, wartość <>0 to duch 8x24
	beq	_12x24

_8x24	.local
	sty	tmpY+1
	lda	shpAdr8,y	; duch 8x24
	ldx	shpAdr8+1,y
tmpY	ldy	mskAdr8		; mskAdr8 zaczyna się od początku strony pamięci więc możemy zrobić taki trick

	jmp	_skp
	.endl


_12x24	.local
	sty	tmpY+1
	lda	shpAdr12,y	; duch 12x24
	ldx	shpAdr12+1,y
tmpY	ldy	mskAdr12	; mskAdr12 zaczyna się od początku strony pamięci więc możemy zrobić taki trick
	.endl

_skp

	add	zp[1].src	; ofset dla SHP i MSK
	bcc	*+5
	inx:iny:clc

	.rept 16
	sta	zp[15-#].shp
	sta	zp[15-#].msk
	stx	zp[15-#].shp+1
	sty	zp[15-#].msk+1

	ift #<>15
	adc	#8
	bcc	*+5
	inx:iny:clc
	eif
	.endr


	lda posy
	:3 lsr @
	tay

	lda posx
	:2 lsr @


* ---	CLR UPDATE
// pozycja pozioma znaku w regA
// pozycja pionowa znaku w regY

.local	CLR_UPDATE

	jmp B2
BufNum	equ *-2

;-----------------------------------
// BUFOR #3
;-----------------------------------
B3
	ldx B3ClrIdx

	sta B3Clr,x		; pozycja pozioma
	tya
	sta B3Clr+$80,x		; pozycja pionowa

	inc B3ClrIdx

	rts

;-----------------------------------
// BUFOR #2
;-----------------------------------
B2
	ldx B2ClrIdx

	sta B2Clr,x		; pozycja pozioma
	tya
	sta B2Clr+$80,x		; pozycja pionowa

	inc B2ClrIdx

	rts

.endl



* ---	M A C R O S


* ---	WAIT
; kod odpowiedzialny za synchronizację obrazu i przełączanie obrazów

WAIT	.macro

B2no	= CLR_UPDATE.B3		; jeśli wyświetlamy B2 to modyfikujemy B3
B3no	= CLR_UPDATE.B2		; jeśli wyświetlamy B3 to modyfikujemy B2

_wait	lda:cmp:req cloc

;	lda	cloc
	cmp	#min_frames-1
	bcc	_wait

	lda	<:1ant
	ldx	>:1ant
	sta	560
	stx	560+1
	sta	$d402
	stx	$d402+1

	mwa	#:1no	CLR_UPDATE.bufNum

	mva	#0	cloc		; zerujemy licznik ramek

	mva	>:1fnt0	dli0+1
	mva	>:1fnt1	dli1+1
	mva	>:1fnt2	dli2+1
	mva	>:1fnt3	dli3+1

	.endm



* ---	CALC
; na podstawie pozycji poziomej oceniamy czy możemy optymalizować ducha 12x24 poprzez wywołanie ducha 8x24
;
; inicjalizujemy adresy wywołując B2CALC,B3CALC ze zmienną isSiz3<>0 dla ducha 8x24
; inicjalizujemy adresy wywołując B2CALC,B3CALC ze zmienną isSiz3=0 dla ducha 12x24
;
; kończymy modyfikacje wywołując procedurę na stronie zerowej SHAPEZP
;
; ostatnią czynnością jest skok do programu obsługi ducha _JMP
;

CALC	.macro

	lda	posy
	cmp	#@sh*8-16
	bcs	_cont

	lda	@TAB_MEM_BANKS+[=:1calc]
	sta	$d301

	lda	type
	bne	_8x24

	lda	posx		; optymalizacja dla ducha 12x24 i klatki SHR0 (przepisujemy tylko 12 znaków zamiast 16)
	and	#3
	bne	_12x24

_8x24
	mva	#$ff	isSiz3		; ten duch ma szerokość 1 znaku (isSiz3 <> 0)
					; ze zmiennej isSiz3 korzysta B2CALC i B3CALC

	jsr	:1calc			; wywołujemy B2CALC lub B3CALC

	mva	bank	$d301		; włączamy bank z bitmapą i maską ducha


; modyfikujemy kod programu na stronie zerowej aby modyfikował 12 znaków a nie 16

	mva	<zp[4]	shpJMP+1

	ldy	#7
	jsr	zp[4]

; przywracamy modyfikację 16 znaków

	mva	<zp[0]	shpJMP+1

	jmp	_cont

_12x24
	mva	#0	isSiz3		; ten duch nie ma szerokości 3 znaków (isSiz3 = 0)
					; ze zmiennej isSiz3 korzysta B2CALC i B3CALC

	jsr	:1calc			; wywołujemy B2CALC lub B3CALC

	mva	bank	$d301		; włączamy bank z bitmapą i maską ducha

	ldy	#7
	jsr	SHAPEZP

_cont

	ldx oldX
	mwa sprites[0].prg,x	_jsr+1

	mva sprites[0].psx,x	sprites[0].old_psx,x
	mva sprites[0].psy,x	sprites[0].old_psy,x

_jsr	jsr $ffff		; skok do programu obsługi ducha

	.endm


* ---	SPRTEST
; sprawdzamy bit STS_NEWSPRT spod adresu SPRITES[].STS
; wartość <>0 oznacza że duch został dopisany w tej kolejce i dlatego zostanie obsłużony dopiero w następnej

SPRTEST	.macro

	lda	sprites[0].sts,x	; czy w tej kolejce ten duch może zostać obsłużony
	cmp	#sts_newsprt|sts_visible
	bne	_ok

;	lda	sprites[0].sts,x	; ale w następnej i tak zostanie obsłużony
	and	#sts_newsprt^$ff
	sta	sprites[0].sts,x
	rts
_ok
	.endm



* ---	INITBUF
; zainicjowanie odpowiedniego bufora (B2BUF lub B3BUF) poprzez przepisanie tła z głównego bufora BUFOR #1
; następnie sprawdzamy MAX_SPRITES razy czy duch jest aktywny i czy mamy go obsłużyć
;
; dodatkowo oprócz przepisania tła kasowana jest zawartość buforów kolizji COLISx, COLISy poprzez
; wypełnienie ich wartością $FF
;

INITBUF	.macro

	ift COLLISION_DETECTION
	jsr	COLLISION_DETECTION_INIT
	eif

	lda	@TAB_MEM_BANKS+[=:1init]	; zaincjowanie bufora B2INIT lub B3INIT	
	sta	$d301
	jsr	:1init

	.rept	max_sprites			; maksymalna liczba duchów do wyświetlenia

	ldx	#.sizeof(@sprite)*#			; x=x+@SPRITES
	lda	sprites[0].sts,x

	ift	sts_visible=$80
	spl
	els
	and	#sts_visible
	seq
	eif

	jsr	:1SHAPE				; skok do procedury obsługi (tworzenia) ducha B2SHAPE lub B3SHAPE

	.endr

	.endm

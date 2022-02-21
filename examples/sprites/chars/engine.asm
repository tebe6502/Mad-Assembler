
;-------------------------------;
;- Software Sprite Engine v2.1 -;
;-------------------------------;
;- 27.06.2009	zmiana sts_visible na $80, sts_newsprt na $40 w celu wykorzystania krótszego skoku SPL
;- 28.06.2009	poprawki w LOOP.ASM (makro CALC), poprawiony plik generujący dane ..\SHAPE\SHAPE.ASM dla duchów 8x24

/*

 wersja zrównoważona względem szybkosci i pamięciożerności

 !!! w celu modyfikacji rozmiaru obrazu, włączenia/wyłączenia detekcji kolizji należy modyfikować plik ..GLOBAL\GLOBAL.HEA !!!

 !!! tylko jedna procedura tworząca ducha na stronie zerowej >> SHAPEZP <<, przepisanie 1 ducha trwa 2253 cykli !!!
 !!! programy obsługi duchów B2CALC, B3CALC w dwóch bankach pamięci !!!

 sprite: 12x24 pixli na znakach, programy obsługi B2CALC i B3CALC, zmienna isSiz3=0
         maksymalnie 11 duchów w 2 ramkach (ekran 32x26 bez detekcji kolizji)

 sprite: 8x24 pixli na znakach, programy obsługi B2CALC i B3CALC, zmienna isSiz3<>0
 	 maksymalnie 14 duchów w 2 ramkach (ekran 32x26 bez detekcji kolizji)

 strona zerowa zajęta jest od adresu ZPAGE przez procedurę SHAPEZP i zmienne do których przepisywane są parametry duchów
 aby dodać nowe zmienne na stronie zerowej można zmodyfikować plik ..GLOBAL\GLOBAL.HEA (dodać zmienne przez .DS)

 albo dodać nowe zmienne od adresu freeZP bez potrzeby modyfikacji pliku ..GLOBAL\GLOBAL.HEA

 tablice przechowujące parametry duchów i kształtów definiują struktury @SPRITE i @SHAPE (plik DATA.ASM), rozmiar
 tych struktur decyduje o maksymalnej możliwej liczbie duchów i maksymalnej możliwej liczbie kształtów

 MAX AVAILABLE SPRITES: maksymalna liczba duchów którą może przetworzyć silnik = 256/@SPRITE
  MAX AVAILABLE SHAPES: maksymalna liczba kształtów które może przetworzyć silnik = 256/@SHAPE

 dane klatek i masek animacji ducha umieszczone są w bankach dodatkowej pamięci co $0800 bajtów
 maksymalnie w 1 banku można przechować 15 klatek animacji ducha 12x24 (klatki kształtu i maski)

 $4000-$47FF SHP.SHR0		$6000-$67FF MSK.SHR0       klatki ducha z przesunięciem o 0 pixli
 $4800-$4FFF SHP.SHR2		$6800-$6FFF MSK.SHR2       klatki ducha z przesunięciem o 1 pixel
 $5000-$57FF SHP.SHR4		$7000-$77FF MSK.SHR4       klatki ducha z przesunięciem o 2 pixle
 $5800-$5FFF SHP.SHR6		$7800-$7FFF MSK.SHR6       klatki ducha z przesunięciem o 3 pixle
 
 !!! klatek z duchami 8x24 i 12x24 nie można umieszczać w tym samym banku pamięci, to muszą być oddzielne banki !!!

 SHP - bitmapa kształtu ducha, bitmapa kształtu potrzebna jest dla operacji ORA
 MSK - bitmapa maski ducha, maska wycina dziurę w obrazie, dzięki niej możemy także dodać np. czarną obwódkę
       na krawędzi ducha, bitmapa naski ducha potrzebna jest dla operacji AND

 SHR0, SHR2, SHR4, SHR6	- przesunięte bitmapy o zadaną liczbę bitów (0,2,4,6)

 znaki wykorzystywane przez duchy przydzielane są dynamicznie, pierwszym wolnym znakiem jest !!! charsBAK !!!
 charsBAK wyznacza liczbę znaków przeznaczonych na tło <0..charsBAK-1>
 pozostałe znaki <charsBAK..127> przeznaczone zostają na duchy

*/


	icl 'global\global.hea'

speed	= $200			; aktualna liczba ramek, czyli szybkość działania silnika pod adresem SPEED

regA	= $f0

@TAB_MEM_BANKS	= $0100		; tablica z kodami banków dla rejestru $d301 (PORTB)

pmg0		= $0000		; adres pamięci dla PMG #0
pmg1		= $0800		; adres pamięci dla PMG #1

prg		= $2000		; adres programu, im niższy tym więcej ciągłego obszaru pamieci do wykorzystania

max_shapes	= 256/.sizeof(@SHAPE)	; maksymalna dopuszczalna liczba kształtów duchów (@SHAPE to struktura danych)

min_frames	= 2		; minimalna liczba klatek synchronizacji dla silnika poniżej której nie może zejść
				; to na wypadek gdyby silnik przetwarzał mniejszą liczbę duchów, wówczas widoczne byłyby
				; przyspieszenia i zwolnienia albo gdyby silnik był uruchamiany na szybszej Atarce :)

max_sprites	= 12		; liczba duchów do wyświetlenia


	ert max_sprites > 256/.sizeof(@SPRITE)

	ert max_shapes > 256/.sizeof(@SHAPE)


* ---	INIT

	org $0600
	.ds 128
@PROC_ADD_BANK			; adres procedury przełączającej banki dla LMB, NMB

	org prg

	icl 'global\@mem_detect.asm'

	ini @mem_detect

*---
	org prg
	
init	.link 'init\init.obx'	; inicjalizacja buforow, przepisanie fontów itd.

	ini init


* ---	BANKI PAMIĘCI
	opt b+				; BANK SENSITIVE ON

; w MADS etykiety zdefiniowane w banku >0 sa zasięgu lokalnego
; nieograniczony dostęp do takich etykiet możliwy jest tylko z poziomu banku 0
;
	LMB #0				; startujemy od banku #0 z pamięci podstawowej RAM $4000..$7FFF

* ---	PROCEDURY OBSLUGI DUCHA 12x24 i 8x24, BUFOR #2

.local	@@@tmp
	.link 'b2calc.obx'
.endl
B2CALC	= @@@tmp.BCALC			; etykieta lokalna B2CALC dla tego banku
B2INIT	= @@@tmp.BINIT

	.print 'RAM-BANK #0: $4000..',*


* ---	PROCEDURY OBSLUGI DUCHA 12x24 i 8x24, BUFOR #3

	NMB
	.link 'b3calc.obx'
B3CALC	= BCALC				; etykieta lokalna B3CALC dla tego banku
B3INIT	= BINIT

	.print 'EXT-BANK #1: $4000..',*


* ---	dane dla SHAPE1 co $800 bajtow
	nmb
	.pages $40
	
shape1	ins 'shape\shape1.dat'

	.endpg


* ---	dane dla SHAPE2 co $0800 bajtow
	nmb
	.pages $40

shape2	ins 'shape\shape2.dat'

	.endpg


* ---	dane dla SHAPE3 co $800 bajtow
	nmb
	.pages $40
	
shape3	ins 'shape\shape3.dat'

	.endpg


	opt b-				; BANK SENSITIVE OFF

	rmb				; BANK = 0

; od teraz mamy dostęp do wszystkich etykiet zdefiniowanych w obszarze dodatkowych banków

* ---	MAIN PROGRAM

	org prg

* ---	ANTIC PROGRAMs

B2ant	:(30-@sh)/2-1 dta $70
	dta $f0
	dta $c4,a(B2scr)
	:@sh-2 dta $84
	dta 4
	dta b($41),a(B2ant)

B3ant	:(30-@sh)/2-1 dta $70
	dta $f0
	dta $c4,a(B3scr)
	:@sh-2 dta $84
	dta 4
	dta b($41),a(B3ant)


* ---	DATA

	icl 'data.asm'

*---
 	.align

* ---	DLI PROGRAM
; program przerwania DLI, koniecznie musi mieścić się w granicy strony pamięci
;
; dyrektywa .PAGES wygeneruje ostrzeżenie jeśli kod zawarty pomiędzy .PAGES i .ENDPG
; znajdzie się poza obszarem strony pamięci

	.pages

dli0	lda >B2fnt0
	sta $d40a
	sta chbase
	mva <dli1 vdli+1
	lda regA
	rti

dli1	lda >B2fnt1
	sta $d40a
	sta chbase
	mva <dli2 vdli+1
	lda regA
	rti

dli2	lda >B2fnt2
	sta $d40a
	sta chbase
	mva <dli3 vdli+1
	lda regA
	rti

dli3	lda >B2fnt3
	sta $d40a
	sta chbase
	mva <dli0 vdli+1
	lda regA
	rti

	.endpg


* ---	MAIN PROGRAM
; wyłączamy ROM, inicjalizujemy odpowiednie rejestry
; zaczynamy skokiem do pętli JMP LOOP
 
main
	lda:cmp:req 20

	cld
	sei
	mva #$00 $d40e
	mva #$fe $d301
 
	mva >pmg0 $d407		; missiles and players data address
	mva #3 $d01d		; enable players and missiles


; inicjalizacja duchów sprzętowych

	ldy #0			; wyczyszczenie pamięci dla duchów sprzętowych
	tya
clrPMG	:5 sta	pmg0+$300+#*$100,y
	:5 sta	pmg1+$300+#*$100,y
	iny
	bne	clrPMG

	mva #0 sizem		; pociski i duchy normalnej szerokości (pojedyńczej)

	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3

	lda #4			; piorytet =4, duchy i pociski zasłania grafika bitmapy
	sta gtictl

	?b = 64
	mva #?b		hposp0
	sta hposm0
	mva #?b+16	hposp1
	sta hposm1
	mva #?b+32	hposp2
	sta hposm2
	mva #?b+48	hposp3
	sta hposm3

	ldx #$1f
	lda #$ff
kk
	sta pmg0+$300+120,x
	sta pmg0+$400+60,x
	sta pmg0+$500+60,x
	sta pmg0+$600+60,x
	sta pmg0+$700+60,x

	sta pmg1+$300+120,x
	sta pmg1+$400+60,x
	sta pmg1+$500+60,x
	sta pmg1+$600+60,x
	sta pmg1+$700+60,x

	dex
	bpl kk

	mwa #nmi $fffa
	mwa #B2ant 560
 
 
;---	inicjalizacja silnika

	ldx #$7f		; skasowanie bit0 w kodach banków pamięci
_cl	lda @TAB_MEM_BANKS,x
	and #$fe
	sta @TAB_MEM_BANKS,x
	dex
	bpl _cl


	jsr shapeMOV			; przepisanie procedury SHAPEZP na stronę zerową


	lda #0				; zerowanie statusu duchów, wszystkie wyłączone STS=0
	:max_sprites sta sprites[#].sts

// --------------------------------------------
// ZAINCJOWANIE DOSTĘPNYCH TYPÓW DLA DUCHÓW
// --------------------------------------------

; 0
	lda @TAB_MEM_BANKS+[=shape1]	; dopisanie kształtu SHAPE #1 do tablicy SHAPES
	sta	shapes[0].bnk		; bank w którym znajdują się dane kształtu
	mva #0	shapes[0].typ		; =0 kształt o rozmiarze 12x24
	mva #21	shapes[0].hig		; wysokość dla tego kształtu

; 1
	lda @TAB_MEM_BANKS+[=shape2]	; dopisanie kształtu SHAPE #2 do tablicy SHAPES
	sta	shapes[1].bnk		; bank w którym znajdują się dane kształtu
	mva #0	shapes[1].typ		; =0 kształt o rozmiarze 12x24
	mva #21	shapes[1].hig		; wysokość dla tego kształtu


; 2
	lda @TAB_MEM_BANKS+[=shape3]	; dopisanie kształtu SHAPE #3 do tablicy SHAPES
	sta	shapes[2].bnk		; bank w ktorym znajdują się dane kształtu
	mva #1	shapes[2].typ		; <>0 kształt o rozmiarze 8x24
	mva #14	shapes[2].hig		; wysokość dla tego kształtu


; zaincjowanie tablicy SPRITES, na przemian duch kształtu SHAPE #0, #1, #2
; 'sts_visible'			włączenie ducha podczas pierwszego uruchomienia silnika
; 'sts_visible|sts_newsprt'	włączenie ducha podczas działania silnika

// --------------------------------------------
// ZAINCJOWANIE TABLICY SPRITES DUCHAMI
// --------------------------------------------

	?b = 0
	
	.rept 16

	ift ?b<max_sprites
	mwa #sprite0		sprites[?b].prg	; program obsługi ducha
	mva #0*.sizeof(@SHAPE)	sprites[?b].shp	; duch kształtu SHAPE #0
	mva #sts_visible	sprites[?b].sts	; bit7=1 duch widoczny
	mva #17+#*12		sprites[?b].psx	; początkowa pozycja pozioma X
	mva #8+#*8		sprites[?b].psy	; początkowa pozycja pionowa Y
	mva #0			sprites[?b].cnt	; zerujemy licznik klatek animacji
	mwa #shp1		sprites[?b].frm	; adres tablicy z kolejnymi numerami klatek animacji
	eif
	?b++

	ift ?b<max_sprites
	mwa #sprite0		sprites[?b].prg	; program obsługi ducha
	mva #1*.sizeof(@SHAPE)	sprites[?b].shp	; duch kształtu SHAPE #1
	mva #sts_visible	sprites[?b].sts	; bit7=1 duch widoczny
	mva #16+#*12		sprites[?b].psx	; początkowa pozycja pozioma X
	mva #32+#*8		sprites[?b].psy	; początkowa pozycja pionowa Y
	mva #0			sprites[?b].cnt	; zerujemy licznik klatek animacji
	mwa #shp2		sprites[?b].frm	; adres tablicy z kolejnymi numerami klatek animacji
	eif
	?b++

	ift ?b<max_sprites
	mwa #sprite0		sprites[?b].prg	; program obsługi ducha
	mva #2*.sizeof(@SHAPE)	sprites[?b].shp	; duch kształtu SHAPE #2
	mva #sts_visible	sprites[?b].sts	; bit7=1 duch widoczny
	mva #20+#*12		sprites[?b].psx	; początkowa pozycja pozioma X
	mva #56+#*8		sprites[?b].psy	; początkowa pozycja pionowa Y
	mva #0			sprites[?b].cnt	; zerujemy licznik klatek animacji
	mwa #shp3		sprites[?b].frm	; adres tablicy z kolejnymi numerami klatek animacji
	eif
	?b++

	.endr

;---	

	mva #$c0 $d40e
	
;---

	jmp	loop		; LET'S GO

;---

shp1	dta 10		; maksymalna wartość licznika klatek animacji dla kształtu SHAPE #1
	:10 dta #*8	; kolejne numery klatek animacji *8

shp2	dta 8		; maksymalna wartość licznika klatek animacji dla kształtu SHAPE #2
	:8 dta #*8	; kolejne numery klatek animacji *8

shp3	dta 13		; maksymalna wartość licznika klatek animacji dla kształtu SHAPE #3
	:13 dta #*8	; kolejne numery klatek animacji *8

;---

	icl 'loop.asm'

	ift COLLISION_DETECTION
	icl 'detect.asm'
	eif


* ---	SPRITE0
; uniwersalna procedura obsługi ducha
;
; do każdej procedury obsługi przekazywany jest w rejesrze X indeks do tablicy SPRITES
;
; na podstawie rejestru X możemy odczytać poszczególne parametry ducha
;
; po tablicy SPRITES poruszamy się za pomoca indeksów zdefiniowanych w strukturze @SPRITE

sprite0
	inc sprites[0].psy,x

	inc sprites[0].psx,x
	lda sprites[0].psx,x
	cmp #@sw*4-12
	scc
	lda #0

	sta sprites[0].psx,x

	ift COLLISION_DETECTION
	jsr DETECT
	bcc BRAK_KOLIZJI
	lda $d20a
	sta $d01a
BRAK_KOLIZJI
	eif

	rts


* ---	SHAPEZP
; uniwersalna procedura modyfikujaca zestaw znaków (procedurę definiuje struktura @ZPVAR)
;
; SRC -> adresy znaków które zostaną odczytane i poddane modyfikacji
; MSK -> maska kształtu ducha dla operacji AND
; SHP -> maska z kształtem ducha dla operacji OR (maska i kszałt nie muszą być względem siebie "symetryczne")
; DST -> adresy znaków docelowych, tutaj zostanie zapisany wynik operacji LDA:AND:ORA:STA DST
;
; shapeTMP zostanie przepisany na stronę zerową od adresu shapeZP

shapeMOV
	ldx	#0
mov	mva	shapeTMP,x	shapeZP,x+
	cpx	#shapeTMP_end-shapeTMP
	bne	mov
	rts

*---

shapeTMP	dta @ZPVAR [15] ( {lda*,y}, $ffff, {and*,y}, $ffff, {ora*,y}, $ffff, {sta*,y}, $ffff )

	dey
	smi
	jmp shapeZP
	rts

shapeTMP_end

*---

* ---	NMI
	
nmi	bit $d40f
	bpl vbl

	sta regA
vdli	jmp dli0

vbl	phr
	sta $d40f

	inc cloc

	mwa 560 $d402

	ift @sw=32
	 lda #%00111101
	eli @sw=40
	 lda #%00111110
	els
	 lda #%00111111
	eif

	sta $d400

pmg	lda >pmg0
	eor #[>pmg0]^[>pmg1]
	sta pmg+1

	sta $d407

	mva	#$14	color0
	mva	#8	color1
	mva	#$f	color2
	mva	#$fe	color3
	mva	#0	colbak

	mva	#$18	colpm0
	mva	#$28	colpm1
	mva	#$38	colpm2
	mva	#$48	colpm3

	mva <dli0 vdli+1

	plr
	rti


* ---	VARIABLE

cloc	brk


	ert *>$3fff

* ---	RUN

	.print 'FREE_MEM: ',*,'..$3FFF, $8000..$BFFF'
	.print 'FREE_MEM: ',free_mem,'..$FFF0'
	.print 'FREE_ZPAGE: ',freeZP,'..$00FF'
	.print 'MAX AVAILABLE SPRITES: ',256/.sizeof(@SHAPE)
	.print 'MAX AVAILABLE SHAPES: ',256/.sizeof(@SHAPE)

	run main


	opt l-
	icl 'global\@bank_add.mac'

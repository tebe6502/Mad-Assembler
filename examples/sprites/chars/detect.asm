
/*
  kod inicjujacy tablice COLISx, COLISy - wypelniajacy je wartoscia $FF
  zawarty jest pod adresami B2INIT, B3INIT

  inicjowanie tablic COLISx, COLISy odbywa sie w momencie zaincjowania
  bufora BUFOR #2 (przez B2INIT), bufora BUFOR #3 (przez B3INIT)
  
*/


* ---	DETECT
; detekcja pierwszej napotkanej kolizji przy pomocy tablic COLISx, COLISy, COLIS (3 strony pamieci)
;
; wynik operacji zwracany jest w rejestrze Y (znacznik C ustawiony 'SEC') i jest to INDEKS do ducha z ktorym nastapila
; kolizja (wpadlismy na niego), jesli wartoscia INDEKS-u jest $FF (znacznik C skasowany 'CLC) tzn ze nie nastapila kolizja
;
; dokladnosc detekcji uzalezniona jest od podania wlasciwej wysokosci ksztaltu ducha ( SHAPES[0].HIG = HEIGHT )
;
; !!! procedure detekcji powinnismy wywolywac z poziomu programu obslugi ducha !!!
; 
; !!! tym sposobem nie ma mozliwosci sprawdzenia kolizji po wygenerowaniu wszystkich duchow !!!
; !!! trzeba koniecznie kolizje sprawdzac na biezaco dla interesujacego nas ducha !!!
;

COLLISION_DETECTION_INIT
	lda #$ff
	:@sw*4+12	sta COLISx+#
	:@sh*8+24	sta COLISy+#
	rts

*---
	align
*---

DETECT	.proc

	jsr init

*---
; wstawiamy HEIGHT zer do tablicy COLIS, indeksem do tablicy COLIS jest wartosc odczytana z COLISy
; dzieki takiej organizacji przyspieszymy porownywanie wartosci

	ldx	height
	mva	ofsy,x	_jmp+1

	lda	#0
	ldy	posy

_jmp	jmp	f_end


	.pages

f23	ldx COLISy+25,y \ sta COLIS,x	; rozpisana w/w petla wypelniajaca, mlodszy bajt adresu wejscia do petli jest w OFSY
f22	ldx COLISy+24,y \ sta COLIS,x	; caly ten fragment musi miescic sie w granicy strony pamieci, czuwaja
f21	ldx COLISy+23,y \ sta COLIS,x	; na tym dyrektywy .PAGES i .ENDPG
f20	ldx COLISy+22,y \ sta COLIS,x	; makro ALIGN natychmiastowo wyrowna do poczatku strony (uzyjemy go jesli .PAGES wykaze blad)
f19	ldx COLISy+21,y \ sta COLIS,x
f18	ldx COLISy+20,y \ sta COLIS,x
f17	ldx COLISy+19,y \ sta COLIS,x
f16	ldx COLISy+18,y \ sta COLIS,x
f15	ldx COLISy+17,y \ sta COLIS,x
f14	ldx COLISy+16,y \ sta COLIS,x
f13	ldx COLISy+15,y \ sta COLIS,x
f12	ldx COLISy+14,y \ sta COLIS,x
f11	ldx COLISy+13,y \ sta COLIS,x
f10	ldx COLISy+12,y \ sta COLIS,x
f9	ldx COLISy+11,y \ sta COLIS,x
f8	ldx COLISy+10,y \ sta COLIS,x
f7	ldx COLISy+9,y \ sta COLIS,x
f6	ldx COLISy+8,y \ sta COLIS,x
f5	ldx COLISy+7,y \ sta COLIS,x
f4	ldx COLISy+6,y \ sta COLIS,x
f3	ldx COLISy+5,y \ sta COLIS,x
f2	ldx COLISy+4,y \ sta COLIS,x
f1	ldx COLISy+3,y \ sta COLIS,x
f0	ldx COLISy+2,y \ sta COLIS,x

f_end

	.endpg


	lda	#$ff	; w tym miejscu koniecznie przywracamy COLIS[$FF]=$FF, indeks $FF ma specjalne znaczenie
	sta	COLIS+$ff


	ldx	posx	; pozycja pozioma ducha


	lda type
	beq _12x	; TYPE=0 to duch 12x24


_8x	.local
	.rept	3	; test od pozycji X+1 dla zmniejszenia czulosci (6 pixli zamiast 8)

	ldy	COLISx+1+#*2,x
	lda	COLIS,y
	beq	hit

	ldy	COLISx+6-#*2,x
	lda	COLIS,y
	beq	hit

	.endr

	clc		; nie wykryto kolizji
	rts

hit	sec		; wykryto kolizje
	rts
	.endl


_12x	.local
	.rept	5	; test od pozycji X+1 dla zmniejszenia czulosci (10 pixli zamiast 12)

	ldy	COLISx+1+#*2,x
	lda	COLIS,y
	beq	hit

	ldy	COLISx+10-#*2,x
	lda	COLIS,y
	beq	hit

	.endr

	clc		; nie wykryto kolizji
	rts

hit	sec		; wykryto kolizje
	rts
	.endl


	.pages

ofsy	dta l(f_end, f_end, f_end, f_end, f_end)	; pierwsze wartosci wskazuja na pusty obszar
	:24 LADR #

	.endpg


init	lda #$ff	; inicjujemy tablice COLIS wartoscia $FF
	:max_sprites	sta COLIS+#*@SPRITE
	rts

	.endp



* ---	DETECT_UPD
; aktualizacja tablic COLISx, COLISy na podstawie pozycji X:Y ducha oraz jego wysokosci ksztaltu HEIGHT
;
; dla zmniejszenia czulosci detekcji zaczynamy test ducha od pozycji (X+1, Y+2) i odpowiednio mniejszej szerokosci i wysokosci
;

*---
	align
*---

DETECT_UPD	.proc

	ldx	height		; wysokosc danego ksztaltu ducha
	mva	ofsy,x	_jmp+1

	lda	oldX		; oldX to wartosc indeksu do tablicy SPRITES, ta wartoscia bedziemy wypelniali tablice COLISy
	ldy	posy		; pozycja pionowa ducha

_jmp	jmp	f_end


	.pages

f23	sta	COLISy+25,y	; rozpisana w/w petla wypelniajaca, mlodszy bajt adresu wejscia do petli jest w OFSY
f22	sta	COLISy+24,y	; caly ten fragment musi mieściś się w granicy strony pamięci, czuwają
f21	sta	COLISy+23,y	; nad tym dyrektywy .PAGES i .ENDPG
f20	sta	COLISy+22,y	; makro ALIGN natychmiastowo wyrówna do początku strony (użyjemy go jeśli .PAGES wykaże błąd)
f19	sta	COLISy+21,y
f18	sta	COLISy+20,y
f17	sta	COLISy+19,y
f16	sta	COLISy+18,y
f15	sta	COLISy+17,y
f14	sta	COLISy+16,y
f13	sta	COLISy+15,y
f12	sta	COLISy+14,y
f11	sta	COLISy+13,y
f10	sta	COLISy+12,y
f9	sta	COLISy+11,y
f8	sta	COLISy+10,y
f7	sta	COLISy+9,y
f6	sta	COLISy+8,y
f5	sta	COLISy+7,y
f4	sta	COLISy+6,y
f3	sta	COLISy+5,y
f2	sta	COLISy+4,y
f1	sta	COLISy+3,y
f0	sta	COLISy+2,y

f_end

	.endpg


	ldx	posx		; pozycja pozioma ducha


	lda	type		; typ ducha (=0 to duch 12x24, <>0 to duch 8x24)
	beq	_12x24

	lda	oldX
	:8-2	sta COLISx+#+1,x	; wypelniamy od pozycji X+1 dla zmniejszenia czulosci

	rts

_12x24
	lda	oldX
	:12-2	sta COLISx+#+1,x	; wypelniamy od pozycji X+1 dla zmniejszenia czulosci

	rts


	.pages						; tablica OFSY koniecznie w granicy strony pamieci

ofsy	dta l(f_end, f_end, f_end, f_end, f_end)	; pierwsze wartosci wskazuja na pusty obszar
	:24 LADR #

	.endpg


	.endp


*---

LADR	.macro			; mlodszy bajt adresu dla F0,F1,F2,F3 ... F23
	dta l(f:1)
	.endm

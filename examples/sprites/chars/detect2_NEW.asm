
* ---	DETECT 2
; kolizje między prostokątami na płaszczyźnie

; ten wariant detekcji jest najszybszy pod warunkiem że kolizja sprawdzana
; jest pomiędzy duchem #0 a duchami #1..#MAX_SPRITES

; rozmiar sprawdzanych duchów jest stały, np. 12x21


COLLISION_DETECTION_INIT

	mva	#0	DETECT_UPD.HIT+1
	rts


.proc	DETECT_UPD

	ldx	oldX
	bne	test

* ---	INICJALIZUJEMY TEST ZAPISUJĄC PARAMETRY BOHATERA
* ---
spr0	lda posx
;	add #1

	sta left+1

	adc #12	;-2	; szerokość bohatera
	sta right+1

	lda posy	; górna krawędź bohatera
;	add #1

	sta top+1

	add #21	;-2	; wysokość bohatera
	sta bottom+1

	rts

* ---	DETEKCJA KOLIZJI Z BOHATEREM
* ---
test
	lda posx
	add #6

left	cmp #0
	bcc NOTHIT
right	cmp #0
	bcs NOTHIT

	lda posy
	add #12

top	cmp #0
	bcc NOTHIT
bottom	cmp #0
	bcs NOTHIT

HIT	ldy	#0

	lda	oldX
	sta	status,y

	inc	HIT+1

NOTHIT	rts

status	:MAX_SPRITES	brk

	.endp

* ---	DETECT 2
; kolizje miêdzy prostok¹tami na p³aszczyŸnie

; ten wariant detekcji jest najszybszy pod warunkiem ¿e kolizja sprawdzana
; jest pomiêdzy duchem #0 a duchami #1..#MAX_SPRITES


COLLISION_DETECTION_INIT

	mva	#0	DETECT.COLIS
	rts


.proc	DETECT

	ldy	#0
COLIS	equ	*-1

	beq	no

yes	sec		; wykryto kolizje
	rts

no	clc		; nie wykryto kolizji
	rts
	.endp


.proc	DETECT_UPD

	ldx	oldX
	bne	test

* ---	INICJALIZUJEMY TEST ZAPISUJ¥C PARAMETRY BOHATERA
* ---
spr0	lda posx

	sta dx0
	sta dx1

	add #12		; szerokoœæ bohatera
	sta cx0
	sta cx1

	lda posy	; górna krawêdŸ bohatera

;	sta ay0
	sta ay1
	sta ay2

	add #21		; wysokoœæ bohatera
;	sta dy0
	sta dy1
	sta dy2

	rts

* ---	DETEKCJA KOLIZJI Z BOHATEREM
* ---
test
	lda posy
	add #2			; g.y

	cmp #0			; if g.y < d.y
dy2	equ *-1
	bcs skip

	cmp #0			; if g.y >= a.y
ay2	equ *-1
	bcs _OK_


skip	add #21-4

	cmp #0
dy1	equ *-1
	bcs _nxt

	cmp #0
ay1	equ *-1
	bcc _nxt


_OK_	lda posx
	add #12-2

	cmp #0
dx0	equ *-1
	bcc _nxt

	cmp #0
cx0	equ *-1
	bcc HIT

	lda posx
	add #1

	cmp #0
dx1	equ *-1
	bcc HIT

	cmp #0
cx1	equ *-1
	bcs _nxt

HIT	mva	oldX	DETECT.COLIS

_nxt	rts
	.endp
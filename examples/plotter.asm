; Sinus Plotter
; by Grzybson/SSG
; 17.08.2010

	org $6000

RND equ $d20a
scr equ $4000
scr2 equ $5000
counter equ 20

zp equ $80 ; adres tablicy zmiennych na stronie zerowej
adres equ zp ; pomocnicza zmienna dla plota
x equ zp+2 ; \_    zmienne dla procedury plot
y equ zp+3 ; /     (rejestry indeksowe x, y opdadaja, sa potrrzebne)
plot_counter equ zp+4 ;zmienna pomocnicza
f equ zp+5 ;zmienna czasu
tmp equ zp+6
tmp2 equ zp+7

cp_pointer equ zp+10 ;current pthase
np_pointer equ zp+12 ;next_phase

c0 equ 13
c1 equ 14

ile equ 127 ; iloœæ plotów -1
step equ 256/[ile+1] ; odsep miedzy plotami

;
; Init
;
Init
	mwa #plot1 np_pointer
	mwa np_pointer cp_pointer

; wait for VBlank
	lda 20
	cmp 20
	beq *-2

; disable IRQ
	sei

; disable NMI
	lda #0
	sta $d40e

; disable OS
	lda #$fe
	sta $d301

; set new NMI vector
	lda #<NMI
	sta $fffa
	lda #>NMI
	sta $fffb

; enable NMI
	lda #$c0
	sta $d40e

; set display list
	lda #<dlist
	sta $d402
	lda #>dlist
	sta $d403

; set colors
	mva #$28 $d016
	mva #$20 $d01a

	mva >fnt $d409
	jsr InitSin
	jsr InitPlot


;
; main loop
;



Clear1
	ldx #240
	lda #0
	sta scr-1,x
	sta scr+240*1-1,x
	sta scr+240*2-1,x
	sta scr+240*3-1,x
	sta scr+240*4-1,x
	sta scr+240*5-1,x
	sta scr+240*6-1,x
	sta scr+240*7-1,x
	sta scr2-1,x
	sta scr2+240*1-1,x
	sta scr2+240*2-1,x
	sta scr2+240*3-1,x
	sta scr2+240*4-1,x
	sta scr2+240*5-1,x
	sta scr2+240*6-1,x
	sta scr2+240*7-1,x
	dex
	bne Clear1+4

	mva #0 f
	mva #255 tmp

Main

;-- podwojne buforowanie START --
	jsr check_reset


_j	lda 20
	cmp 20
	beq *-2

	lda dd+1
	sta _scr+1 ; ustawiamy nowy adres ekranu dla procedury Plot
	eor #$10
	sta dd+1 ; zmieniamy adres ekranu


	lda _e1+2 	; korekta tablicy bajtów do wyczyszczenia - procki cls, plot,
	eor #6
	sta Cls+4
	sta _e1+2
	lda _e2+2
	eor #2
	sta _c0+2
	sta _e2+2
	jsr Cls

;-- podwojne buforowanie END --



	mva #ile plot_counter
	lda tmp
_b	clc
	adc #step	; i+=step(odstep pomiedzy kolejnymi plotami)
	sta tmp


	jmp (cp_pointer)

r	jsr plot
	;x,y - param. plot
	lda tmp

	dec plot_counter
	bpl _b

	inc f


	jmp Main


;
; Cls
;

Cls ldx #ile
	lda erase_l2,x
	sta _c1+1
_c0	lda erase_h2,x
	sta _c1+2
	lda #0
_c1 sta $FFFF

	dex
	bpl Cls+2
	rts

;
; Plot
;

InitPlot mwa #0 adres   ; adres pamiêci obrazu do zmiennej ADRES (WORD)

      ldy #0           ; inicjowanie licznika pêtli regY=0
in_0  lda adres        ; przepisanie m³odszego bajtu do tablicy 'l_line'
      sta l_line,y
      lda adres+1      ; przepisanie starszego bajtu do tablicy 'h_line'
      sta h_line,y

      lda adres        ; zwiekszenie zmiennej ADRES o szerokoœæ obrazu (32)
      clc              ; ADRES = ADRES + 32
      adc #20
      sta adres
      bcc *+4
      inc adres+1

      iny              ; zwiekszenie licznika petli
      cpy #96         ; wartosc maksymalna petli
      bne in_0         ; jesli nie osiagn¹³ wartoœci maksymalnej to skacz pod 'in_0'
	  rts

Plot  ldy y
	  lda l_line,y     ; odczytujemy z tablic adres linii
      sta adres
      lda h_line,y
      clc
_scr  adc #0
      sta adres+1
      lda x              ; DIV
      :3 lsr @         ; dzielimy przez 8 czyli przesuwamy o 3 bity w prawo
      tay


	  lda x			   ; MOD
      and #7           ; ANDujemy 3 najm³odsze bity (%00000111)
      tax

      lda (adres),y    ; pobieramy bajt z pamiêci obrazu
      ora ora_mask,x   ; stawiamy pixel
      sta (adres),y    ; z powrotem stawiamy bajt w pamiêci obrazu
	  tya
	  ldx plot_counter
	  clc
	  adc adres
_e1	  sta erase_l2,x
	  bcc *+4
	  inc adres+1
	  lda adres+1
_e2   sta erase_h2,x

      rts

ora_mask dta %10000000,%01000000,%00100000,%00010000
         dta %00001000,%00000100,%00000010,%00000001

;
;   InitSin - rozpoisanie reszty sinusa na podstawie stablicowanej pierwszej æwiartki
;

InitSin
		ldx #63
		ldy #64
		lda sintab,x
		sta sintab,y

		iny
		dex
		bpl InitSin+4

		ldx #127
_s		lda sintab,x
		eor #255
		sta sintab+128,x
		inc sintab+128,x
		dex
		bpl _s
		rts
;
; Display List
;

dlist
	dta $70,$70,$70 ; 24 puste linke
	dta $47,a(txt+16)
	dta $4b
dd	dta a(scr)
	:79 dta $0b
	dta $47,a(txt)
	dta $41,a(dlist)

;
; NMI
;
NMI
	bit $d40f ; DLI or VBL?
	bpl VBL
; DLI
	rti
; VBL
VBL
	sta $d40f ; reset NMI
	pha
	inc 20
	mwa c0 $d016
	mwa c1 $d01a

	lda 20
	bpl v0

	lda #0
	sta 20

	mwa np_pointer cp_pointer

v0	pla
	rti

sintab dta b(sin(0,32,256,0,63))

l_line equ *+192
h_line equ *+288
erase_l1 equ *+384
erase_h1 equ *+640
erase_l2 equ *+640+256
erase_h2 equ *+640+512

	org *+640+512+256


;
; Rysowanie plot
;

plot1
	mwy #$28 c0
	mwy #$20 c1

	mwy #plot2 np_pointer
	clc
	adc f		; ACC = i + f
	tax			; X = ACC
	lda sintab,x
	asl @
	clc
	adc #80
	sta x	;x = sin(i+f)

	lda tmp
	asl @
	asl @

	clc
	adc f
	tax		; X = ACC
	lda sintab,x ; ACC = sin (2*i)
	eor #255
	adc #40
	sta y
	jmp r

plot2
	mwy #$48 c0
	mwy #$40 c1

	mwy #plot3 np_pointer
	clc
	adc f		; ACC = i + f
	tax			; X = ACC
	mva sintab,x x	;x = sin(i+f)

	lda tmp
	asl @	;ACC = 2*i
	tax		; X = ACC
	lda sintab,x ; ACC = sin (2*i)
	clc
	adc x		;x = x + sin(2*i) = sin(i+f) + sin(2*i)

	adc #80
	;adc #64
	sta x

	lda tmp
	asl @
	asl @
	clc
	adc f
	tax
	lda sintab,x

	adc #40
	sta y
	jmp r

plot3
	mwy #$d8 c0
	mwy #$d0 c1

	mwy #plot4 np_pointer
	lsr @
	sbc #96
	clc
	adc f		; ACC = i + f
	tax			; X = ACC
	mva sintab,x x	;x = sin(i+f)

	lda tmp
	tax		; X = ACC
	lda sintab,x ; ACC = sin (2*i)
	clc
	adc x		;x = x + sin(2*i) = sin(i+f) + sin(2*i)
;
	adc #80
	;adc #64
	sta x


	lda tmp
	asl @

	clc
	adc f
	tax
	lda sintab,x

	adc #40
	sta y

	jmp r

plot4
	mwy #$fd c0
	mwy #$f2 c1
	mwy #plot5 np_pointer
	clc
	adc f		; ACC = i + f
	tax			; X = ACC
	mva sintab,x x	;x = sin(i+f)

	txa
	clc
	adc tmp
	tax		; X = ACC
	lda sintab,x ; ACC = sin (2*i)

	adc #40
	sta y


	txa
	clc
	adc tmp
	lda sintab,x ; ACC = sin (2*i)
	clc
	adc x
	adc #80
	sta x
	jmp r

plot5
	mwy #$b8 c0
	mwy #$b0 c1
	mwy #plot1 np_pointer
	lsr @
	sbc #96
	clc
	adc f		; ACC = i + f
	tax			; X = ACC
	mva sintab,x x	;x = sin(i+f)

	txa
	clc
	adc f
	tax		; X = ACC
	lda sintab,x ; ACC = sin (2*i)

	adc #40
	sta y


	txa
	clc
	adc f
	lda sintab,x ; ACC = sin (2*i)
	clc
	adc x
	adc #80
	sta x
	jmp r

check_reset
	lda $d20f
	and #4
	beq *+3

	rts
	lda #$ff
	sta $d40e
	sta $d301
	jmp $e477

txt :16 dta 4
	dta 0,1,2,3
	:16 dta 4

	org $5800

fnt	dta %00000111
	dta %00000100
	dta %00000100
	dta %00000111
	dta %00000100
	dta %00000100
	dta %00100100
	dta %00000000

	dta %10010000
	dta %01010000
	dta %01010000
	dta %10010000
	dta %00010000
	dta %00010000
	dta %00011110
	dta %00000000

	dta %01110011
	dta %10001000
	dta %10001000
	dta %10001000
	dta %10001000
	dta %10001000
	dta %01110000
	dta %00000000

	dta %11100000
	dta %10000000
	dta %10000000
	dta %10000000
	dta %10000000
	dta %10000000
	dta %10000000
	dta %00000000

	dta 0,0,0,0,0,0,0,0

	run Init
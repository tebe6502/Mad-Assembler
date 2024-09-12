	org $2000
start
; calc sin
sinep equ $2800
	ldx #0
	stx $CB ; hl
	stx $CC
	stx $CD ; de
	stx $CE
cslp
	lda $CC
	cmp #40
	bcs zobra1
	lda $CD
	clc
	adc #5
	sta $CD
	bcc zobra0
	inc $CE
zobra0
	jmp zobra2
zobra1
	lda $CD
	sec
	sbc #5
	sta $CD

	lda $CE
	sbc #$00
	sta $CE
zobra2
	lda $CB
	clc
	adc $CD
	sta $CB

	lda $CC
	adc $CE
	sta $CC
	sta sinep,x
	inx
	bne cslp
	stx $FF ; counter
	stx 710
;fill char
;	ldx #0
fchy
	ldy #0
	txa
fchx
	sta (88),y
	iny
	cpy #40
	bne fchx
	tya
	clc
	adc 88
	sta 88
	bcc noinc89
	inc 89
noinc89
	inx
	cpx #24
	bne fchy

;AUDCTL      equ $D208
;AUDC1       equ $D201
;AUDC2       equ $D203
;AUDC3       equ $D205
;AUDC4       equ $D207
;AUDF1       equ $D200
;AUDF2       equ $D202
;
;            lda #$01               ; A9 01
;            sta AUDCTL             ; 8D 08 D2
;            lda #$EC               ; 09 E0
;            sta AUDC1              ; 8D 01 D2
;            sta AUDC2              ; 8D 03 D2
;            sta AUDC3              ; 8D 05 D2
;            sta AUDC4              ; 8D 07 D2
;            ldy #$FF               ; A0 FF
;            sty AUDF1              ; 8C 00 D2
;            dey                    ; 88
;            sty AUDF2              ; 8C 02 D2

;draw bar
bars
;clear data
	lda #0
	tay
ch3 sta $4000,y
	iny
	bne ch3

	lda $CB
	clc
v1	adc #2
	sta $CB
	sta $CC

	lda $CD
	clc
v2	adc #3
	sta $CD
	sta $CE

	lda #12
	sta $CF ; counter
blp
	ldx $CC
	ldy $CE
	lda sinep,x
	clc
	adc sinep,y
	tay
	ldx #9
cbl lda barsd,x
ch1 sta $4000,y
	iny
	dex
	bpl cbl
	stx 709

;	stx AUDF1
;	dex
;	stx AUDF2

	lda $CC
	clc
v3	adc #8
	sta $CC

	lda $CE
	clc
v4	adc #$F4
	sta $CE

	dec $CF
	bne blp
;wait_frame
RTCLOK      equ $0012
      lda RTCLOK+2
waits
      cmp RTCLOK+2
       beq waits
ch2 lda #$40
	sta 756
	sta $d409
	eor #4
	sta ch2+1
	sta ch1+2
	sta ch3+2
	dec $FF
	bne cont
	lda 53770
	pha
	and #3
	clc
	adc #1
	sta v1+1
	pla
	and #1
	clc
	adc #1
	sta v2+1
cont
	jmp bars
barsd
	dta 0
	dta $55,$AA
	dta $FF
	dta $FF
	dta $FF
	dta $FF
	dta $AA,$55
	dta 0

	run start

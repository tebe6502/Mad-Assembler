
	org $2000

x0 = $CB
x1 = $CC
x2 = $CD
x3 = $CE
vl = $CF
dvl = $D0
vr = $D1
dvr = $D2
tt = $D3

; 0  1
; 2  3
;setup chars
	lda #$80
	sta 623 ; GPRIOR
	sta 756
	ldx #0
	stx $D5
	ldy #0
chlp
	txa
	sta $8000,y
	iny
	tya
	and #7
	bne chlp
	txa
	clc
	adc #$11
	tax
	bcc chlp

; copy colors
;	ldx #8
;copc
;	lda colors-1,x
;	sta 704,x
;	dex
;	bne copc
; init vars
ivar
	ldx #8
iv	txa
	eor $14
	adc 53770
	sta x0-1,x

	lda colors-1,x
	sta 704,x

	dex
	bne iv

	lda #$50
	sta $D208

	lda $230
	sta $ED
	lda $231
	sta $EE

lp1

	lda x0
	sta vl

	lda x1
	sta vr

	lda 88
	sta $EB
;	lda $BC25
	ldy #5
	lda ($ED),y
	eor #$0C
	sta $EC

	pha
	ldx #24

ylp	ldy #0
	lda x2
	sec
	sbc vl
	jsr sign
	clc
	adc vl
	sta vl
	sta tt
	lda x3
	sec
	sbc vr
;	jsr sign
	clc
	adc vr
	sta vr

xlp
	lda vr
	sec
	sbc vl
	jsr sign
	clc
	adc tt
	sta tt
	and #$0F
	cmp #$08
	bcs noin
	eor #$FF
noin
	and #$07
	sta ($EB),y
	iny
	cpy #40
	bne xlp
	tya
	clc
	adc $EB
	sta $EB
	bcc ny
	inc $EC
ny	dex
	bne ylp
;;	stx $D201
	inc x0
; fade sound ?
	lda $D5
	beq nofas
	sec
	sbc #8
;	bcs nofas
;	lda #0
nofas sta $D5
	sta $D201
	lda $14
	bne bra1
; change colors
	lda $13
	asl
	asl
	asl
	asl
	sta $d4
	ldx #8
co1 lda colors-1,x
	and #$0F
	ora $D4
	sta colors-1,x
	sta 704,x
	dex
	bne co1
	lda #$CF
	sta $D200
	lda #$2F+1
	sta $D201
	sta $D5
	dec x3
bra1

;wait_frame
RTCLOK=$0012
      lda RTCLOK+2
waits
      cmp RTCLOK+2
       beq waits
	pla
;	sta $BC25
	ldy #5
	sta ($ED),y
	jmp lp1
sign
	beq zero
	bpl plus
	lda #$FF
zero
	rts
plus
	lda #1
	rts
colors
;	.byte $1F,$1D,$1B,$19,$17,$15,$13,$11
	.byte $10,$12,$14,$16,$18,$1A,$1C,$1E

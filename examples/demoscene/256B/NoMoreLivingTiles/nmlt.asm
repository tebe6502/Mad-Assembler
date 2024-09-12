
	org $0600

;	lda #$18
;	sta 53272; 0400,2000
	lda #$20
	sta 756

;fill vram
	ldx #0
	lda 88
	sta $FB
	lda 89 ; lda #4
	sta $FC
ylp
	ldy #0
	txa
	and #7
	sta 2
xlp
	tya
	and #7
	asl
	asl
	asl
	ora 2
	sta ($FB),Y
	iny
	cpy #40
	bne xlp
	tya
	clc
	adc $FB
	sta $FB
	bcc noinfc
	inc $FC
noinfc
	inx
	cpx #25
	bne ylp

;X=300:Y=0
;X=X-Y/64
;Y=Y+X/64
initd
	lda #0 ;(2,3)=Y,(4,5)=X
	sta 2
	sta 3
	sta 4
	sta $F7;counter
v1	lda #$3f
;	and #$1F
	sta 5
;counter
	lda #2
	sta $F8
clp
	ldx #0
	jsr shr64;(FB,FC)-Y/64
;X=X-Y/64
;(2,3)=Y,(4,5)=X
	lda 4
	sec
	sbc $FB
	sta 4
	lda 5
	sbc $FC
	sta 5

	ldx #2
	jsr shr64;(FD,FE)-X/64
;Y=Y+X/64
;(2,3)=Y,(4,5)=X
	lda 2
	clc
	adc $FD
	sta 2
	lda 3
	adc $FE
	sta 3
;plot
	lda 5 ;X
	adc 6 ; $FF
	pha

	and #$38 ;(~7)&63
	ldx #$30
	ldy #3
s1l asl
	bcc noix
	inx
noix
	dey
	bne s1l
	sta $F9
	stx $FA

	lda 3 ;Y
	adc 6
;	adc $FF
	and #63
	tay
	pla 
;	lda 5;X
	and #7
	tax
	lda ($F9),y
	ora bw,x
	sta ($F9),y

;; Decrement a 16 bit value by one
;_DEC16  LDA MEM+0       ;Test if the LSB is zero
;        BNE _SKIP       ;If it isn't we can skip the next instruction
;        DEC MEM+1       ;Decrement the MSB when the LSB will underflow
;_SKIP   DEC MEM+0       ;Decrement the LSB
;dec counter
	lda $f7
	bne skp
	dec $F8
skp dec $F7
	lda $F7
	ora $F8
	beq vs
	jmp clp
;output
vs
;vs	ldy $D40B ; $d012 ;load the current raster line into the accumulator
;	bne vs
RTCLOK      = $0012
      lda RTCLOK+2
waits
      cmp RTCLOK+2
       beq waits

	ldy #0
copl
	lda $3000,y
	sta $2000,y
	lda $3100,y
	sta $2100,y
	lda $3200,y
	sta $2200,y

	lda #0
	sta $3000,y
	sta $3100,y
	sta $3200,y
	iny
	bne copl
	dec v1+1
	dec v1+1
	inc 6 ; $FF
	inc 6 ; $FF
	inc 6 ; $FF
	jmp initd

shr64
	lda 2,x
	sta $FB,x
	lda 3,x
	sta $FC,x
	ldy #6

shlp
; Arithmetic shift right A
	cmp #$80
	ror
	ror $FB,X
	dey
	bne shlp
	sta $FC,x
	rts

bw .byte $80,$40,$20,$10,8,4,2,1

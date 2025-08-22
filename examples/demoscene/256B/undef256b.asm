;compilation:
;set nam=undefl
;xasm.exe %nam%.asm /o:%nam%.xex

  org $4000

startd
tof	equ 10*41
; output
	lda 88
	clc
	adc #tof&255
	sta $cb
	lda 89
	adc #tof/256
	sta $cc
	lda #logo&255
	sta $cd
	lda #logo/256
	sta $ce
	
	lda #5
	sta $cf
ol
	ldy #0
ol2
	lda ($cd),y
;	eor #$80
	sta ($cb),y
	iny
	cpy #21
	bne ol2
	lda #40
	ldx #0
	jsr ebecplus40
	ldx #2
	tya
	jsr ebecplus40
	dec $cf
	bne ol

;---------------------
	lda #0
	ldy #2
	sta (88),y
	tay
;copy data
	ldx #30
;	ldy #0
copyras
	tya
	sta rasta,y
	sta rasta,x
	sta rasta+29+1,y
	sta rasta+15+14+1,x
	dex
	iny
	cpy #16
	bne copyras
;	jmp *
;	lda rasta
;raster
WSYNC	equ $D40A
wr
	ldx #$38
	ldy $CF
;	ldx #$0
wl
	cpx $D40B ;  VCOUNT
	bne wl
rlp
	lda rasta,y
	sta $D017
	inx
	iny
	sta WSYNC
	cpx #$0F+$0F+9+$38
	bne rlp
;	lda #0
;	sta $D017
;	sta WSYNC

	inc $CF
	lda $CF
	cmp #30
	bne nolpr
	lda #0
nolpr
	sta $CF
	jmp wr

ebecplus40
;	lda #40
	clc
	adc $CB,x
	sta $cb,x
	bcc exadd
	inc $cc,x
exadd
	rts
logo 
 dta $00,$00,$00,$4A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4A,$4A,$00,$00,$00,$00,$00,$00
 dta $00,$48,$D6,$D6,$4A,$00,$00,$48,$00,$00,$00,$48,$4A,$C7,$D6,$4A,$00,$00,$00,$00,$48
 dta $48,$80,$D6,$D6,$D6,$48,$CE,$C2,$48,$CE,$00,$80,$CD,$D6,$D6,$D6,$48,$CE,$48,$CE,$C2
 dta $CA,$80,$C8,$D6,$D6,$CA,$80,$C2,$CA,$80,$4A,$80,$00,$D6,$D6,$D6,$CA,$80,$C7,$80,$C2
 dta $00,$00,$00,$CA,$00,$00,$00,$00,$00,$00,$00,$CA,$00,$CA,$CA,$00,$00,$00,$00,$00,$00

rasta
;	dta $C0,$c1,$c2,$c3,$C4,$C5,$C6,$c7,$c8,$c9,$CA,$CB,$CC,$CD,$CE,$CF
;	dta $CE,$CD,$CC,$CB,$CA,$C9,$c8,$c7,$c6,$c5,$c4,$C3,$c2,$c1,$C0
;ras2
;	dta $c1,$c2,$c3,$C4,$C5,$C6,$c7,$c8,$c9,$CA,$CB,$CC,$CD,$CE,$CF
;	dta $CE,$CD,$CC,$CB,$CA,$C9,$c8,$c7,$c6,$c5,$c4,$C3,$c2,$c1,$C0

	run startd
; deform
;
; pr0be/laresistance 2004
;
tmp	equ $20
tmp2	equ $22
frame	equ $24

antic	equ $2800
antic2	equ $2c00
screen	equ $3000
texel0	equ $9000
texel1	equ $a000

;
	org $8000

; texture
texture	ins "texture.dat"

; *-- generate antic --*
start	ldy #$03
	sty tmp
	sty tmp2
	dey
	lda #$70
_blank	sta antic,y
	sta antic2,y
	dey
	bpl _blank

	ldy #$1f
_tabu	lda tabu,y
	sta tabu+$20,y
	dey
	bpl _tabu

	lda #>antic
	sta tmp+1
	lda #>antic2
	sta tmp2+1

	ldx #>[screen*2]
_genant	ldy #$00
	lda #$4f
	sta (tmp),y
	sta (tmp2),y
	iny
	lda #$00
	sta (tmp),y
	lda #$80
	sta (tmp2),y
	iny
	txa
	lsr @
	sta (tmp),y
	sta (tmp2),y
	iny
	lda #$00
	sta (tmp),y
	sta (tmp2),y
	lda tmp
	clc
	adc #$04
	sta tmp
	sta tmp2
	bcc *+6
	inc tmp+1
	inc tmp2+1
	inx
	cpx #>[screen*2+$6000]
	bne _genant

	lda #$40
	sta 623
	lda #$f0
	sta $2c8
	lda #%00100001
	sta 559

; *-- texture --*
	lda #>texel0
	sta tmp+1
	lda #>texel1
	sta tmp2+1

gentex0	ldx #$00
	stx tmp
	stx tmp2
	stx $230
gentex	ldy #$00
_gentex	lda texture,x
	pha
	and #$f0
_gtex1	sta (tmp),y
	lsr @
	lsr @
	lsr @
	lsr @
_gtex0	sta (tmp2),y
	iny
	pla
	and #$0f
_gtex2	sta (tmp2),y
	asl @
	asl @
	asl @
	asl @
_gtex3	sta (tmp),y
	inx
	txa
	and #$07
	tax
	iny
	cpy #$30
	bne _gentex
	inc tmp+1
	inc tmp2+1
	lda _gentex+1
	adc #$07
	sta _gentex+1
	bpl gentex0

; *-- render --*
render	ldx #$80
	ldy #>antic
	lda _scrbuf+1
	beq _flip
	ldx #$00
	ldy #>antic2
_flip	stx _scrbuf+1
	lda $d40b
	bne *-3
	sty $d403
	sty $231

	inc frame
	lda frame
	and #$1f
	sta frame
	and #$0f
	sta frame+1

	lda #>screen
	sta _scrbuf+2

	lda #$00
	sta tmp+1
	lda #>texel0
	clc
	adc frame+1
	sta _tex0+2
	lda #>texel1
	adc frame+1
	sta _tex1+2
	lda #$00
	sta tmp2

_deform	lda frame
	sta _tex0+1
	sta _tex1+1
	lda #$00
	sta tmp

	tay
	ldx frame
	clc
_tex0	lda texel0
	sta tmp2+1

	lda tmp
	adc tabu,x
	sta tmp
	bcc *+9
	inc _tex0+1
	inc _tex1+1
	clc

	lda tmp2+1
_tex1	ora texel1
_scrbuf	sta screen,y

	inx
	lda tmp
	adc tabu,x
	sta tmp
	bcc *+9
	inc _tex0+1
	inc _tex1+1
	clc

	inx
	iny
	cpy #$10
	bne _tex0

	lda tmp2
	clc
	adc frame
	tax
	lda tmp+1
	adc tabu,x
	sta tmp+1
	bcc *+8
	inc _tex0+2
	inc _tex1+2

	lda _tex0+2
	cmp #>texel1
	bne _scrl
	lda #>texel0
	sta _tex0+2
	lda #>texel1
	sta _tex1+2

_scrl	inc _scrbuf+2
	inc tmp2
	lda tmp2
	cmp #$20
	bne _deform

; copy buffer
	lda #>screen
	sta _cpybuf+2
	sta _cpybuf+5
	sta cpybuf1+2
	clc
	adc #$20
	sta cpybuf1+5
	lda _scrbuf+1
	sta _cpybuf+1
	sta cpybuf1+1
	sta cpybuf1+4
	adc #$10
	sta _cpybuf+4

	ldy #$20
cpybuf	ldx #$0f
_cpybuf	lda screen,x
	sta screen,x
	dex
	bpl _cpybuf
	inc _cpybuf+2
	inc _cpybuf+5
	dey
	bne cpybuf

	ldy #$10
cpybuf0	ldx #$1f
cpybuf1	lda screen,x
	sta screen,x
	dex
	bpl cpybuf1
	inc cpybuf1+2
	inc cpybuf1+5
	dey
	bne cpybuf0

	jmp render

; tables
tabu	ins "tabu.dat"

	org $2983
	dta $41,$00,>antic

	org $2d83
	dta $41,$00,>antic2

;
	run start

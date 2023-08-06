xtab	equ $3000
ztab	equ $3200
bitmask	equ $3400
sqrtab	equ $3500
ledge	equ $3700
redge	equ $3800
costab	equ sintab+$20

sinx	equ $7e
cosx	equ $7f
siny	equ $80
cosy	equ $81
sx1	equ $82
sx2	equ $83
sy1	equ $84
sy2	equ $85
screen	equ $86
tmp	equ $87
tmp2	equ $88
ext	equ $89
angx	equ $8a
angy	equ $8b
xn	equ $8c
yn	equ $8d
x1	equ $8f
x2	equ $90
x3	equ $91
y1	equ $92
y2	equ $93
y3	equ $94
dx	equ $95
dy	equ $96

chb	equ $97
tx	equ $af
ty	equ $b7

scr	equ $fe

	org $3b00

	dta c'code:pr0be'
; init
init	ldy #$00
	sty 560
_genxtb	tya
	lsr @
	lsr @
	sta xtab,y
	iny
	bne _genxtb

	tya
	sec
_genbm	ror @
	ror @
	bpl *+3
	ror @
	sta bitmask,y
	iny
	bne _genbm

	ldy #240
	ldx #$9f
_genan1	txa
	sta ant1+$02,y
	sta ant2+$02,y
	dey
	lda #$00
	sta ant1+$02,y
	lda #$40
	sta ant2+$02,y
	dey
	lda #$4d
	sta ant1+$02,y
	sta ant2+$02,y
	dex
	dey
	bne _genan1

; generate square table
gensqrt	tya
	tax
	beq _gsqr2

	sta tmp
	lda #$00
	sta ext
mult2	clc
	adc tmp
	bcc *+4
	inc ext
	dex
	bne mult2

	ldx #$07
_gsqrt	lsr ext
	ror @
	dex
	bne _gsqrt	; div 128
_gsqr2	sta sqrtab,y
	sta sqrtab+256,y
	pha
	tya
	eor #$ff
	clc
	adc #$01
	tax		; X=256-Y
	pla
	sta sqrtab,x
	sta sqrtab+256,x
	iny
	bpl gensqrt


; generate ztab
	ldx #191
_gnztab	stx tmp
	lda #$08
	sta ext

	ldy #$00
	tya
divv	sec
	sbc tmp
	bcs *+6
	dec ext
	bmi _div
	iny
	bne divv

_div	tya
	sta ztab-$40,x
	dex
	bne _gnztab

; generate sintab
	ldy #$1f
_gsin	lda sintab,x
	sta sintab+$20,y
	sta sintab+$80,x
	inx
	dey
	bpl _gsin

	ldx #$3f
_gsin2	lda sintab,x
	eor #$ff
	clc
	adc #$01
	sta sintab+$40,x
	dex
	bpl _gsin2

; generate chessboard
	ldx #23
	lda #$00
_genchb	sta chb,x
	dex
	sta chb,x
	eor #$55
	dex
	bpl _genchb

* main loop
loop	lda 20
	cmp 20
	beq *-2			; czekaj ramke (czy konieczne?)

	lda screen
	bne _flp
	ldx #>ant1
	bne _flp2
_flp	ldx #>ant2
_flp2	eor #$40
	sta screen
	stx 561
	stx $d403

* roll chessboard
	ldy #$01
roll	ldx #23
	lda chb
	asl @		; set carry flag
_roll	rol chb,x
	dex
	bpl _roll
	dey
	bpl roll

* draw chessboard
	lda #$60
	sta bp20+2
	lda screen
	clc
	adc #$08	; moze da rade zaoszczedzic te 3 bajty...
	sta bp20+1

	lda #$03
	sta tmp2
_drwcb4	lda #$01
	sta tmp
	lda #$00
	sta bp21+1
_drwcb3	ldy #$07
_drwcb	ldx #23
_drwcb2	lda chb,x
bp21	eor #$00
bp20	sta $ffff,x
	dex
	bpl _drwcb2
	inc bp20+2
	dey
	bpl _drwcb
	lda #$55
	sta bp21+1
	dec tmp
	bpl _drwcb3
	dec tmp2
	bpl _drwcb4

	ldx angx
	lda sintab,x
	sta sinx
	lda costab,x
	sta cosx
	ldx angy
	lda sintab,x
	sta siny
	lda costab,x
	sta cosy

	ldx #$07
; x axis rotation
rot	lda pz,x
	ldy sinx
	jsr fmul
	sta tmp
	lda py,x
	ldy cosx
	jsr fmul
	sec
	sbc tmp
	sta yn		; yn=py*cos(angx)-pz*sin(angx)

	lda pz,x
	ldy cosx
	jsr fmul
	sta tmp
	lda py,x
	ldy sinx
	jsr fmul
	clc
	adc tmp
	sta tmp		; tmp=py*sin(angx)+pz*cos(angx)

; y axis rotation
	lda tmp
	ldy siny
	jsr fmul
	sta tmp2
	lda px,x
	ldy cosy
	jsr fmul
	sec
	sbc tmp2
	sta xn		; xn=px*cos(angy)-tmp*sin(angy)

	lda px,x
	ldy siny
	jsr fmul
	sta tmp2
	lda tmp
	ldy cosy
	jsr fmul
	clc
	adc tmp2	; .a=px*sin(angy)+tmp*cos(angy)

; transformation
	clc
	adc #$40
	tay
	lda ztab,y
	tay
	lda xn
	jsr fmul
	clc
	adc #80
	sta tx,x	; tx=xn*ztab+80

	lda yn
	jsr fmul
	clc
	adc #48+$50
	sta ty,x	; ty=yn*ztab+48

	dex
	bpl rot

	inc angy

	lda angx
	clc
	adc #$02
	and #$7f
	sta angx
	lda angy
	and #$7f
	sta angy

	lda tx+2
	sta x2
	lda ty+2
	sta y2
	lda tx+1
	sta x3
	lda ty+1
	sta y3
	ldy tx+3
	lda ty+3
	jsr poly

	lda tx+2
	sta x2
	lda ty+2
	sta y2
	lda tx+0
	sta x3
	lda ty+0
	sta y3
	ldy tx+5
	lda ty+5
	jsr poly

	lda tx+4
	sta x2
	lda ty+4
	sta y2
	lda tx+3
	sta x3
	lda ty+3
	sta y3
	ldy tx+5
	lda ty+5
	jsr poly

	lda tx+0
	sta x2
	lda ty+0
	sta y2
	lda tx+1
	sta x3
	lda ty+1
	sta y3
	ldy tx+6
	lda ty+6
	jsr poly

	lda tx+5
	sta x2
	lda ty+5
	sta y2
	lda tx+7
	sta x3
	lda ty+7
	sta y3
	ldy tx+6
	lda ty+6
	jsr poly

	lda tx+1
	sta x2
	lda ty+1
	sta y2
	lda tx+7
	sta x3
	lda ty+7
	sta y3
	ldy tx+4
	lda ty+4
	jsr poly

	jmp loop

; poly (.y, .a, x2, y2, x3, y3)
poly	sty x1
	cmp y3
	bcc sorty
	tax
	lda x3
	sta x1
	sty x3
	ldy y3
	stx y3
	tya

sorty	sta y1
	cmp y2
	bcc sorty2
	tax
	lda y2
	sta y1
	stx y2
	ldx x1
	lda x2
	sta x1
	stx x2

sorty2	lda y2
	cmp y3
	bcc _dopoly
	tax
	lda y3
	sta y2
	stx y3
	ldx x2
	lda x3
	sta x2
	stx x3

_dopoly	ldx x1
	ldy y1
	lda x2
	sta sx2
	lda y2
	sta sy2
	jsr scanedg
	ldx x2
	ldy y2
	lda x3
	sta sx2
	lda y3
	sta sy2
	jsr scanedg
	ldx x1
	ldy y1
	lda #>redge
	sta bp2+2
	sta bp4+2
	jsr scanedg
	lda #>ledge
	sta bp2+2
	sta bp4+2

; draw poly
	ldy y1
_drwply	lda ledge,y
	cmp redge,y
	bcc _drw1
	ldx redge,y
	jsr hline
	jmp _drw2
_drw1	tax
	lda redge,y
	jsr hline
_drw2	iny
	cpy y3
	bcc _drwply

	rts

; scanedge
scanedg	cpy sy2
	bne *+3
	rts

	stx sx1
	cpx sx2
	bcc _scels1
	txa
	sec
	sbc sx2
	sta dx
	lda #$ca
	jmp _sce1

_scels1	lda sx2
	sec
	sbc sx1
	sta dx
	lda #$e8

_sce1	sta bp1
	sta bp3

	sty sy1
	lda sy2
	sec
	sbc sy1
	sta dy

	ldx sx1
	ldy sy1
	lda dx
	cmp dy
	bcc _sce2

	lda #$00
	sec
	sbc dx

	clc
bp1	inx
	adc dy
	bcc bp1
	sta tmp
	txa
bp2	sta ledge,y
	lda tmp
	iny
	sbc dx
	cpy sy2
	bcc bp1
	rts

_sce2	lda #$00
	sec
	sbc dy

	clc
_doedg	sta tmp
	txa
bp4	sta ledge,y
	lda tmp
	iny
	adc dx
	bcc _sce3
bp3	inx
	sbc dy
_sce3	cpy sy2
	bcc _doedg
	rts

; fast multiply A*Y->A
fmul	sta $fa
	eor #$ff
	clc
	adc #$01
	sta $fc
	lda ($fa),y
	sec
	sbc ($fc),y
	rts

sintab	dta $00,$01,$03,$04,$06,$07,$09,$0a,$0c,$0d,$0f,$10,$11,$13,$14,$15
	dta $16,$17,$18,$19,$1a,$1b,$1c,$1c,$1d,$1e,$1e,$1f,$1f,$1f,$1f,$1f

; antic
	org $4c00
ant1	dta $70,$70,$70			; self generating: + (3+4)*2 = 14bytes
	org $4cf3
	dta $41,$00,$4c
	org $4e00
ant2	dta $70,$70,$70			; self generating
	org $4ef3
	dta $41,$00,$4e			; 34 bytes for 2ant meyby better cpy std ant prg?

; color pallete
	org $2c4
	dta $84,$88,$8c

	org $bf
; hline (.x, .a, .y)
hline	sty tmp2
	sta $dc		; bp12

	lda screen
	sta $d2		; bp10+$01
	sta $d8		; bp11+$01
	sty $d3		; bp10+$02
	sty $d9		; bp11+$02

	clc
_drwhln	ldy xtab,x
bp10	lda $50ff,y
	adc bitmask,x
bp11	sta $50ff,y
	inx
bp12	cpx #$ff
	bcc _drwhln

	ldy tmp2
	rts

; object coord
px	dta $e0,$00,$f0,$10,$20,$00,$f0,$10
py	dta $00,$e0,$00,$00,$00,$20,$00,$00
pz	dta $00,$00,$10,$10,$00,$00,$f0,$f0
	dta $00,$35,$00,$35
;
	run init

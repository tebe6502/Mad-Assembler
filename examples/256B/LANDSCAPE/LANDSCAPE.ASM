; "Landscape", Atari XL/XE Intro 256B
; art direction by Piesiu / Agenda
; music by stRing / Agenda
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2021-03-14

y	equ $00c0
f	equ $00c1
x	equ $00c2
notes	equ $00c3

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
vvblkd	equ $0224
gprior	equ $026f
pcolr0	equ $02c0
pcolr1	equ $02c1
color0	equ $02c4
color1	equ $02c5
color2	equ $02c6
color4	equ $02c8
atachr	equ $02fb
hposp0	equ $d000
sizep0	equ $d008
grafp0	equ $d00d
audf1	equ $d200
audc1	equ $d201
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
xitvbv	equ $e462
osgraph	equ $ef9c
osprint	equ $f1a4
ospoint	equ $f1d8
osdraw	equ $f9c2


	org $2000

start
	; enter graphics mode
	lda #$0f
	jsr osgraph

	; set color palette
	iny			; Y is assumed to be 1 before "iny"
	lda #$52
loopa1	sta color0,y
	;clc			; not necessary
	adc #$02
	dey
	bpl loopa1

	; push PMG behind mountains
	ldy #$04
	sty gprior

	dey
	sty atachr

	; the idea behind particular mountain edge can be described
	; with the algorithm shown below
	;
	; uint8_t x = 0, y = 16, f = 0; 
	; do {
	;     --x;
	;     f = (f - 1) * x;
	;     if (f < x)
	;         ++y;
	;     else
        ;         --y;
	;     putPixel(x >> 1, y + 32, 1);
	;     if (!(x & 0xc0))
	;         putPixel((x >> 1) | 0x80, y + 32 + 16, 1);
	; } while (x != 0);

	; y = 16
loopb1	lda #16
	sta y

	; x = f = 0
	;lda #$00		; not necessary
	;sta f
	;sta x

loopb2	dec x			; --x

	; f = (f - 1) * x
	; lame multiplication, but short code, and fast enough
	; factor1: f
	; factor2: x
	; product: A and factor1 (low byte)
	ldy f
	dey			; (f - 1)
	lda #$00
loopb3	clc
	adc x
	dey
	bne loopb3
	sta f

	cmp x			; if (f < x)
	bcc skipb1
	dec y			; --y
	bpl skipb2		; jmp skipa2
skipb1	inc y			; ++y

skipb2	tya			; lda #$00
	sta opcodl1+1
	sta opcodl2+1
	jsr line
	lda #$80
	sta opcodl1+1
	lda #16
	sta opcodl2+1
	jsr line 

	lda x
	bne loopb2

	; prepare data for the next hill
	lda #64+32
	sta opcodl5+1
	lda #178
	sta opcodl6+1
	ldy #$4a
	sty opcodl3		; lsr
	ldx #$02
	cpx atachr
	bmi skipb3
	sty opcodl4		; lsr
	lda #64+64+32
	sta opcodl5+1
	lda #192
	sta opcodl6+1

skipb3	dec atachr
	bne loopb1

	; initialization of positions of stars
	ldy #$00
loopc1
opcodc1	lda #$fe		; PRNG seed
	asl
	bcc skipc1
	eor #$1d
skipc1	sta opcodc1+1
	sta starpos,y
	dey
	bmi loopc1

	; stars
loopc2	lda vcount
	bne loopc2
	;ldx #$00		; not necessary
loopc3	lda starpos,x	
	ldy #$02
	sta wsync
loopc4	sta hposp0,y
	asl
	dey
	bpl loopc4
	dex
	bne loopc3
	ldy random
	lda starpos,y
	eor #$ff
	sta starpos,y

	lda #%10100011
	sta audc1
	inc notes
	lda notes
	lsr
	lsr
	lsr
	lsr
	lsr
	tay
	lda music,y
	sta audf1

	bvc loopc2		; infinite loop


	; vertical line drawing routine
line	lda x
	lsr			; x >> 1
opcodl1	ora #$00		; (x >> 1) | 0x80 or (x >> 1)
	sta oldcol
	sta colcrs
	lda y
	clc
opcodl2	adc #$00		; y + 16 or y
opcodl3	nop
opcodl4	nop
	clc
opcodl5	adc #32			; y + 32 or y + 32 + 16
	sta rowcrs
opcodl6	lda #132
	sta oldrow
	jsr osdraw
	rts


music	.byte 121, 217, 204, 217, 121, 153, 162, 182


	; positions of stars
starpos	equ *+0


	org pcolr0

	.byte 44, 55, 66	;$82, $84, $86 ;44, 55, 66


	org grafp0

	.byte 1, 1, 1
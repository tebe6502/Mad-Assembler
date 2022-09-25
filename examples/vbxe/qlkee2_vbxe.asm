; x0F / TQA

QLKA_WIDTH	equ	24
QLKA_HEIGHT	equ	24
LIGHT	equ	16
LOG2FRAMES	equ	3
SPEED_MASK	equ	0
SPEED_NEGATIVE	equ	1
TIME_MASK	equ	3
NOT_FOUND	equ	1
METER	equ	0

pal_r	equ	$3000
pal_g	equ	pal_r+$100
pal_b	equ	pal_r+$200

qlka_vbxe	equ	$00000
xdl_vbxe	equ	$70800
bcb_vbxe	equ	$70880
scr_vbxe	equ	$01000

fx_ptr	equ	$80	; 2
src	equ	$82 ; 2
dest	equ	$84 ; 2
r	equ	$86
g	equ	$87
b	equ	$88
y	equ	$89
hue	equ	$8a
sx	equ	$90	; 8
sy	equ	sx+4
vx	equ	$98	; 8

	org	$3300
main
	jsr	fx_detect
	ift	NOT_FOUND
	beq	found_vbxe
	mwa	#no_vbxe_dl	$230
	bne	*
found_vbxe
	eif

next
	ldy	#$40	; VIDEO_CONTROL
	mva	#0	(fx_ptr),y	; xdl_disabled

	ldy	#$5d	; MEMB
	mva	#$80+[bcb_vbxe>>14]	(fx_ptr),y	; mbce
	mwa	#cls_bcb	src
	jsr	blit

	ldx	#0
	ldy	#63
expand_sin
	lda	sin,x
	sta	sin+256,x
	sta	sin+64,y
	eor	#$ff
	add	#1
	sta	sin+128,x
	sta	sin+192,y
	inx
	dey
	bpl	expand_sin

	ldx	#0
gen_palette
	stx	dest
	ldy	>pal_r
	lda	sin,x
	jsr	shades
	ldy	>pal_g
	lda	cos,x
	lsr	@
	adc	#64
	sub	sin,x
	ror	@
	jsr	shades
	ldy	>pal_b
	lda	cos,x
	eor	#$ff
	jsr	shades
	txa
	adc	#$f	; +
	tax
	bcc	gen_palette

	ldy	#$53	; BLITTER_BUSY
	lda:rne	(fx_ptr),y

;	lda	#0
convert_hue
	sta	hue
:2	lsr	@
	pha
	and	#$38
	sec:ror	@
	ldy	#$5d	; MEMB
	sta	(fx_ptr),y
	pla
	and	#4
	eor	>$4000+qlka_vbxe
	sta	dest+1
	mwa	#qlka	src
	mvy	#0	dest
convert_byte
	lda	(src),y
:4	lsr	@
	jsr	convert_store_pixel
	lda	(src),y
	and	#$f
	jsr	convert_store_pixel
	inw	src
	lda	src
	cmp	<qlka_end
	lda	src+1
	sbc	>qlka_end
	bcc	convert_byte
	lda	hue
	adc	#$f	; +
	bcc	convert_hue

;	ldy	#$5d	; MEMB
;	mva	#$80+[xdl_vbxe>>14]	(fx_ptr),y	; mbce
	ldy	#xdl_len-1
	mva:rpl	xdl,y	$4000+[xdl_vbxe&$3fff],y-
;	lda	20
;	cmp:req	20	
	ldy	#$40	; VIDEO_CONTROL
	mva	#1	(fx_ptr),y+	; xdl_enabled
	mva	#xdl_vbxe&$ff	(fx_ptr),y+	; XDL_ADR0
	mva	#[xdl_vbxe>>8]&$ff	(fx_ptr),y+	; XDL_ADR1
	mva	#xdl_vbxe>>16	(fx_ptr),y	; XDL_ADR2

	ldx	#15
init_shape	txa:ora	#6
	cmp	#15
	lda	$d20a
	bcc	init_shape_no_hi_speed
	ift	SPEED_NEGATIVE
	and	#[SPEED_MASK<<1]|1
	sbc	#SPEED_MASK-1
	els
	and	#SPEED_MASK
	eif
init_shape_no_hi_speed
	sta	sx,x-
	bpl	init_shape

loop
	ldx	#6
advance_loop
	lda	vx,x
	add:sta	sx,x
	lda	vx+1,x
	adc:sta	sx+1,x
	dex:dex
	bpl	advance_loop

	mva	#0	bcb_dest
	ldx	sy+1
	lda	sin,x
	ldx	sy+3
	add	sin,x
	ror	@
	lsr	@
	sta	y
	lsr	@
	ror	bcb_dest
	lsr	@
	ror	bcb_dest
	adc	y
	sta	bcb_dest+1
	ldx	sx+1
	lda	sin,x
	ldx	sx+3
	add	sin,x
	ror	@
	add:sta	bcb_dest
	scc:inc	bcb_dest+1
	lda	<scr_vbxe+[192-128-QLKA_HEIGHT]/2*320+[320-256-QLKA_WIDTH]/2
	add:sta	bcb_dest
	lda	>scr_vbxe+[192-128-QLKA_HEIGHT]/2*320+[320-256-QLKA_WIDTH]/2
	adc:sta	bcb_dest+1

	lda	20
	and	#[1<<LOG2FRAMES]-1
	sta	bcb_frame
	sta	$4000+[[xdl_vbxe+xdl_frame-xdl]&$3fff]

	lda	20
:LOG2FRAMES	lsr	@
	and	#$f
	sta	hue
	lsr	@
	sta	bcb+2
	lda	>qlka_vbxe
	scc:lda	>qlka_vbxe+$400
	sta	bcb+1

:METER	inc	$d01a
	lda	#96+QLKA_HEIGHT/4
	cmp:rne	$d40b
:METER	lsr	$d01a
	jsr	blit

	ldy	#$44
	mva	#0	(fx_ptr),y+	; CSEL
	mva	#1	(fx_ptr),y	; PSEL
	lda	hue
	eor	#$f
:4	asl	@
	sta	hue
	tax
set_palette_1
	ldy	#$46	; CR
	mva	pal_r,x	(fx_ptr),y+
	mva	pal_g,x	(fx_ptr),y+
	mva	pal_b,x	(fx_ptr),y
	inx
	cpx	hue
	bne	set_palette_1

	lda	20
	bne	jloop
	lda	19
	and	#TIME_MASK
	jeq	next
jloop
	jmp	loop

; Detect VBXE
fx_detect
	mwa	#$d600	fx_ptr
	jsr	fx_detect_1
	beq	fx_detect_exit
	inc	fx_ptr+1
fx_detect_1
	ldy	#$40	; CORE_VERSION
	lda	(fx_ptr),y
	cmp	#$10	; FX 1.xx
	bne	fx_detect_exit
	iny	; MINOR_VERSION
	lda	(fx_ptr),y
	and	#$70
	cmp	#$20	; 1.2x
fx_detect_exit
	rts

blit
	ldy	#bcb_len-1
	mva:rpl	(src),y	$4000+[bcb_vbxe&$3fff],y-
	ldy	#$50	; BL_ADR0
	mva	#bcb_vbxe&$ff	(fx_ptr),y+	; BL_ADR0
	mva	#[bcb_vbxe>>8]&$ff	(fx_ptr),y+	; BL_ADR1
	mva	#bcb_vbxe>>16	(fx_ptr),y+	; BL_ADR2
	mva	#1	(fx_ptr),y	; BLITTER_START
	rts

shades
	sty	dest+1
	ldy	#0
	eor	#$80
	bpl	shades_in_range
	clc
shades_dark
	pha
	mva	#0	(dest),y+
	pla
	adc	#LIGHT
	bcc	shades_dark
shades_in_range
	sta	(dest),y+
	cpy	#$10
	bcs	shades_done
	adc	#LIGHT
	bcc	shades_in_range
	lda	#$ff
shades_light
	sta	(dest),y+
	cpy	#$10
const16	equ	*-1
	bcc	shades_light
shades_done
	rts

convert_store_pixel
	seq:ora	hue
	sta	(dest),y
	inw	dest
	rts

qlka
	dta	$00,$00,$00,$00,$0f,$ff,$ff,$f0,$00,$00,$00,$00
	dta	$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$00
	dta	$00,$00,$0f,$ff,$ff,$ee,$ee,$ee,$dd,$d0,$00,$00
	dta	$00,$00,$ff,$ff,$ff,$ee,$ed,$dd,$dd,$dd,$00,$00
	dta	$00,$0e,$ff,$ff,$ff,$ed,$dd,$cc,$bb,$bb,$c0,$00
	dta	$00,$ce,$ff,$ff,$ff,$ed,$cb,$ba,$aa,$aa,$bc,$00
	dta	$08,$ce,$ff,$ff,$ff,$ed,$cb,$a9,$99,$99,$99,$70
	dta	$08,$ce,$ee,$ff,$fe,$ed,$ba,$98,$88,$78,$87,$70
	dta	$08,$be,$ee,$ff,$ee,$ec,$ba,$97,$76,$66,$77,$70
	dta	$78,$ad,$de,$ee,$ee,$dc,$b9,$77,$65,$55,$67,$78
	dta	$67,$8b,$cc,$cd,$dd,$cb,$98,$76,$55,$55,$67,$88
	dta	$67,$78,$99,$ab,$bb,$a9,$87,$65,$44,$45,$67,$98
	dta	$56,$67,$78,$89,$99,$88,$76,$54,$44,$45,$68,$99
	dta	$55,$56,$66,$77,$77,$66,$54,$43,$33,$45,$68,$a9
	dta	$44,$45,$55,$55,$55,$44,$33,$22,$23,$45,$79,$a9
	dta	$04,$43,$34,$43,$33,$21,$11,$12,$22,$45,$7a,$a0
	dta	$04,$33,$22,$22,$21,$11,$11,$11,$23,$46,$8a,$a0
	dta	$04,$33,$22,$11,$11,$11,$11,$11,$23,$57,$aa,$a0
	dta	$00,$32,$22,$11,$11,$11,$11,$12,$35,$79,$aa,$00
	dta	$00,$02,$21,$11,$11,$11,$11,$23,$57,$9a,$a0,$00
	dta	$00,$00,$21,$11,$11,$11,$23,$46,$79,$aa,$00,$00
	dta	$00,$00,$02,$11,$12,$34,$56,$78,$99,$90,$00,$00
	dta	$00,$00,$00,$11,$23,$45,$68,$89,$88,$00,$00,$00
	dta	$00,$00,$00,$00,$03,$45,$67,$70,$00,$00,$00,$00

	
qlka_end
bcb
	dta	a(qlka_vbxe),0
	dta	a(QLKA_WIDTH),1
bcb_dest
	dta	0,0
bcb_frame
	dta	0
	dta	a(320),1
	dta	a(QLKA_WIDTH-1),QLKA_HEIGHT-1
	dta	$ff,0,0
	dta	0,0,1
bcb_len	equ	*-bcb

cls_bcb
	dta	0,0,0
	dta	a(0),0
	dta	a(scr_vbxe),0
	dta	a(256*8),1
	dta	a(256-1),254-1
	dta	0,0,0
	dta	7,0,0

xdl
	dta	a($24),b(23)	; XDLC_OVOFF|XDLC_RTPL
	dta	a($8062),b(191) ; XDLC_GMON|XDLC_RTPL|XDLC_OVADR|XDLC_END
	dta	a(scr_vbxe)
xdl_frame
	dta	b(0),a(320)
xdl_len	equ	*-xdl

	ift	NOT_FOUND
no_vbxe_dl
:3	dta	$70
	dta	$47,a(no_vbxe_text)
	dta	$41,a(no_vbxe_dl)

no_vbxe_text
	dta	d'   VBXE REQUIRED!   '
	eif

sin
	dta	sin(128,127,256,0,63)
cos
	org	*+256

	run	main

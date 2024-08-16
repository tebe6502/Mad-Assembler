// Shanti engine example

SDLSTL	= $0230
SDLSTH	= $0231

color0	= $d016
color1	= $d017
color2	= $d018
color3	= $d019

dmactl	= $d400

.enum	@dmactl
	blank	= %00
	narrow	= %01
	normal	= %10
	wide	= %11
	missiles= %100
	players	= %1000
	oneline	= %10000
	dma	= %100000
.ende

scr48	= @dmactl(wide|dma|players|missiles|oneline)		;screen 48b
scr40	= @dmactl(normal|dma|players|missiles|oneline)		;screen 40b
scr32	= @dmactl(narrow|dma|players|missiles|oneline)		;screen 32b


	org $2000

jgp	;ins '..\assets\hans_kloss.fnt'

scr	;ins '..\assets\hans_kloss.scr'


	.align


dlist	;dta $70,$70
	dta $f0
	:24 dta $40|$04|$80|$10,a(scr+#*48)
	dta $41,a(dlist)


vbl
	;this area is for yours routines




	;the required exit method

	plr
	rti


main		lda <dlist		; DLIST address
		sta SDLSTL		; shadow DLPTR
		lda >dlist
		sta SDLSTH

		multi.init_engine #vbl		; !!! INIT_ENGINE !!! execute first

		mva #scr32 dmactl		; scr32, scr40, scr48

		mva #$84 color0
		mva #$e8 color1
		mva #$72 color2
		mva #$0e color3


		.put >jgp,>[jgp+$400],>[jgp+$800],>[jgp+$c00]

		.rept 26,#
		lda #.get[#&3]
		sta charsets+#
		.endr


		jsr f0	; addShape
		jsr f1
		jsr f2


// addSprite	num, color0, color1, shape_idx, sprite_x, sprite_y, anim_speed, anim

.macro addSprite (num, c0, c1, shape, x, y, speed, anim)
	mva #%%c0	sprite_c0+%%num
	mva #%%c1	sprite_c1+%%num
	mva #%%shape	sprite_shape+%%num	;ksztalt startowy
	mva #%%x	sprite_x+%%num
	mva #%%y	sprite_y+%%num
	mva #%%speed	sprite_anim_speed+%%num	;predkoœæ animacji
	mva #%%anim	sprite_anim+%%num	;maska dla liczby klatek animacji
.endm

		addSprite 0 $64 $18 12  40  32 7 255
		addSprite 1 $24 $e8 0   56  40 3 255
		addSprite 2 $04 $38 3   72  48 1 255
		addSprite 3 $04 $78 15  84  56 3 255
		addSprite 4 $a4 $a8 0   96  64 3 255
		addSprite 5 $34 $38 18 104  72 1 255
		addSprite 6 $04 $68 2  112  82 3 255
		addSprite 7 $04 $08 0  124  94 3 255
		addSprite 8 $4c $f8 11 134 108 3 255


	lda <$d01a		; ustawienie rejestru koloru
	sta creg+1


loop	lda:cmp:req 20

	jsr multi.show_sprites
	//jsr multi.animuj


px	lda #26
	sta npx+1
px2	lda #0
	sta npx2+1

	ldx #8

npx	lda track0
	add #48
	sta sprite_x,x

npx2	lda track1
	add #16
	sta sprite_y,x

	cpx #3
	bne sk_

	adb npx+1 #2
	sbb npx2+1 #5

sk_

	adb npx+1 #2
	sbb npx2+1 #5

	sta tcolor,x

	dex
	bpl npx

	lda $d20f
	and #4
	;bne skp

	inc px+1
	dec px2+1

skp

	jmp loop



.macro	addShape (idx, nam)
	mwa #%%nam._01 shape_tab01+%%idx*2
	mwa #%%nam._23 shape_tab23+%%idx*2
.endm


.local	f0
		addShape 0, shp0
		addShape 1, shp1
		addShape 2, shp2
		addShape 3, shp3
		addShape 4, shp4
		addShape 5, shp5
		addShape 6, shp6
		addShape 7, shp7

		rts

	icl '..\convert\font0.asm'

.endl


.local	f1
		addShape 8, shp0
		addShape 9, shp1
		addShape 10, shp2
		addShape 11, shp3
		addShape 12, shp4
		addShape 13, shp5
		addShape 14, shp6
		addShape 15, shp7

		rts

	icl '..\convert\font1.asm'

.endl


.local	f2
		addShape 16, shp0
		addShape 17, shp1
		addShape 18, shp2
		addShape 19, shp3
		addShape 20, shp4
		addShape 21, shp5
		addShape 22, shp6
		addShape 23, shp7

		rts

	icl '..\convert\font2.asm'

.endl


	.align

	icl 'track002_l.asm'		; track0, track1


; ------------------------------------------------------------------

	.align $0800

	.link '..\src\engine.obx'

	run main

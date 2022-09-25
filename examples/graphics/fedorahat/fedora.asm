
// Fedora Hat by DMSC
// http://atariage.com/forums/topic/218503-graphics-8-fedora-hat/page-1

	icl '..\..\atari.hea'

	; Constants
	cx	= 160	; sx / 2
	cy	= 90	; sy * 15/32
	stepZp	= 1	; sx/320
	startXs = 224	; sx/5 + cx
	startYs = 154	; sx/5 + cy
	numZi	= 128	; (-64+64)

	initAZt = $FF02	; FP (1/64)^2 - 2/64
	initZt2 = 8192	; FP 1
	stepZt2 = 4	; FP 2 * (1/64)^2
	initAXf = 102	; FP 256 * (20/(9*sx))^2 = 256 * (1/144)^2
	stepXf2 = 204	; FP 256 * 2*(20/(9*sx))^2 = 256 * 2*(1/144)^2

	org $80

zt2:	.ds	2
azt:	.ds	2
xs:	.ds	1
ys:	.ds	1
zi:	.ds	1

x1:	.ds	2
x2:	.ds	2
y1:	.ds	1
xf2:	.ds	3
axf:	.ds	2
di:	.ds	2
tmp1:	.ds	2
tmp2:	.ds	2

mul2:	.ds	4
mtmp:	.ds	2


	org $2000

_start:
	; Clear RT clock before start
	lda #0
	sta RTCLOK+2
	sta RTCLOK+1
	sta RTCLOK

	jsr gr8
	jsr initSine

	mwa #initZt2 zt2
	mwa #initAZt azt

	mva #startXs xs
	mva #startYs ys
	mva #numZi zi

	; Outer for loop:

loopZi:
	; x1 = x2 = xs
	lda xs
	ldx #0
	sta x1
	stx x1+1
	sta x2
	stx x2+1

	; xf2 = 0
	stx xf2
	stx xf2+1
	stx xf2+2
	; axf = initAXf
	mwa #initAXf axf

	; Inner loop:

loopX:
	; AX = xf^2 = xf2 >> 8
	; tmp1 = xf*xf + zt*zt
	adw xf2+1 zt2 tmp1

	; di = sqrt(tmp1)
	sqrt tmp1
	sta di
	stx di+1

	; tmp1 = di * 3; di = di * 2
	asl di
	rol di+1
	clc
	adc di
	sta tmp1
	txa
	adc di+1
	sta tmp1+1

	; tmp2 = sin(tmp1)
	sine tmp1
	sta tmp2
	stx tmp2+1

	; AX = tmp1 * 3
	lda tmp1
	ldx tmp1+1
	asl tmp1
	rol tmp1+1
	clc
	adc tmp1
	pha
	txa
	adc tmp1+1
	tax
	pla

	; AX = sin(AX) = sin(9*di)
	sine

	; AX = (1/2 - 1/8 + 1/32) * AX = 0.40625 * sin(9*di)
	stx tmp1+1
	cpx #128
	ror tmp1+1
	ror @
	ldx tmp1+1
	sta tmp1
	cpx #128
	ror tmp1+1
	ror @
	cpx #128
	ror tmp1+1
	ror @

	pha
	sec
	eor #255
	adc tmp1
	sta tmp1
	txa
	sbc tmp1+1
	tax
	pla

	cpx #128
	ror tmp1+1
	ror @
	cpx #128
	ror tmp1+1
	ror @

	clc
	adc tmp1
	pha
	txa
	adc tmp1+1
	tax
	pla

	; tmp2 += AX = sin(3*di) + 0.375 * sin(9*di)
	clc
	adc tmp2
	sta tmp2
	txa
	adc tmp2+1
	sta tmp2+1

	; tmp2 * 320 * 7 / 40 = tmp2 * 56 = tmp2 * 64 - tmp2 * 8
	;							= (t2<<6 - t2<<3)>>13
	;							= (t2<<1 - t2>>2)>>8
	tax
	lda tmp2  ; NOTE: AX holds tmp2
	; tmp2 = tmp2 >> 2
	cpx #128
	ror tmp2+1
	ror tmp2
	cpx #128
	ror tmp2+1
	ror tmp2
	; tmp1/A = AX << 1 ()
	stx tmp1+1
	asl @
	rol tmp1+1
	; A = (t2<<1 - t2>>2) >> 8
	sec
	sbc tmp2
	lda tmp1+1
	sbc tmp2+1
	; y1 = -A + ys
	eor #255
	clc
	adc ys
	sta y1

	; plot x1, y1
	plot x1,y1

	; plot x2, y1
	plot x2,y1

	; Condition: if(2*di>=2.0) break;
	lda di+1
	cmp #64
	bcs endLoopX

	; End of inner loop: x1++, x2--, xf2+=axf, axf+=stepXf2

	inw x1
;	inc x1
;	bne @ninc1
;	inc x1+1
@ninc1: dec x2

	adw xf2 axf
;	lda xf2
;	clc
;	adc axf
;	sta xf2
;	lda xf2+1
;	adc axf+1
;	sta xf2+1

	bcc @ninc2
	inc xf2+2
@ninc2:
	adw axf #stepXf2
;	lda axf
;	clc
;	adc #stepXf2
;	sta axf
;	bcc @noinc1
;	inc axf+1
@noinc1:
	jmp loopX

endLoopX:
	; End of outer loop: zt2+=azt, azt+=stepZt2, xs--, ys--
	dec xs
	dec ys

	adw zt2 azt
;	lda zt2
;	clc
;	adc azt
;	sta zt2
;	lda zt2+1
;	adc azt+1
;	sta zt2+1

	adw azt #stepZt2
;	lda azt
;	clc
;	adc #stepZt2
;	sta azt
;	bcc @noadd
;	inc azt+1
@noadd:
	; Condition: zi--; if( zi<0 ) break;
	dec zi
	bmi @skip
	jmp loopZi
@skip:


	; Read clock
@rdClk: lda RTCLOK+2
	ldx RTCLOK+1
	ldy RTCLOK
	cmp RTCLOK+2
	bne @rdClk

	; End of program
@end:
	jmp @end

	.link 'math.obx'
	.link 'plot.obx'

	run _start
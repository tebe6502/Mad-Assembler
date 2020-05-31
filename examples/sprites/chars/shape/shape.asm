
;x	= 0
;type	= 3
;frames	= 10

; type = 3 -> sprite 12x24
; type = 2 -> sprite 8x24

	ert type<>2&&type<>3,'type <> [2,3]'

	opt h-f+
	org $4000

	?nil = $00
	data x

	align $0800

	?nil = $ff
	data x+14

* --------------------------------------------
* --------------------------------------------

	opt l-

.macro	data
	.get 'shape_0.mic'

	:frames shape :1,#
	nil

* --------------------------------------------
	align $0800

	.get 'shape_1.mic'

	:frames shape :1,#
	nil

* --------------------------------------------
	align $0800

	.get 'shape_2.mic'

	:frames shape :1,#
	nil

* --------------------------------------------
	align $0800

	.get 'shape_3.mic'

	:frames	shape :1,#
	nil
.endm

* --------------------------------------------
* --------------------------------------------

	ift type=3

.macro	shape

	nil
	.rept 24\.sav[:1+0+(:2*24)*32+#*32]1\.endr
	nil
	.rept 24\.sav[:1+1+(:2*24)*32+#*32]1\.endr
	nil
	.rept 24\.sav[:1+2+(:2*24)*32+#*32]1\.endr
	nil
	.rept 24\.sav[:1+3+(:2*24)*32+#*32]1\.endr
;	nil
.endm

	els

.macro	shape

	nil
	.rept 16\.sav[:1+0+(:2*16)*32+#*32]1\.endr
	nil
	nil
	.rept 16\.sav[:1+1+(:2*16)*32+#*32]1\.endr
	nil
	nil
	.rept 16\.sav[:1+2+(:2*16)*32+#*32]1\.endr
	nil
.endm

	eif

.macro	nil
	dta ?nil,?nil,?nil,?nil,?nil,?nil,?nil,?nil
.endm

	icl 'align.mac'

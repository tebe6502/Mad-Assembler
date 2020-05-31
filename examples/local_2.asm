
	org $2000

.local	l0
	nop
	.local l1
	lda #0
		.local l2
		lda #0
		.endl
	.endl

	.local l3
	nop
	.endl
.end

	.print 'l0 length: ', .len l0
	.print 'l1 length: ', .len l0.l1
	.print 'l2 length: ', .len l0.l1.l2
	.print 'l3 length: ', .len l0.l3

	?tst = 1

.macro	@updateXY

	.local
	nop
	cmp #240
	bcs skp

	nop
	.endl
skp
	.def ?tst++
.endm


.local	wow

	?tst = 5

	@updateXY
	@updateXY

	.print '7=',?tst
.end

	.print '1=',?tst

;temp

.local	temp
.endl

;temp

.local	temp
.endl

;temp

.macro	test
	loop:
	.local
	loop:
	.endl
.endm

	test
	test

	
.proc	pr

.local	temp
a1	lda #0
.endl

.local	temp
a2	ldx #0
	nop
.endl

.end
	.print .len pr
	.print .len pr.temp

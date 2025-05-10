
dst	= $a010

	org $2000

dl	dta d'ppp'
	dta $4e,a(dst)
	:101 dta $e
	dta $4e,0,h(dst+$1000)
	:95 dta $e
	dta $41,a(dl)

main	mwa #dl $230

	lda:cmp:req 20

	lda #0
	sta $13
	sta $14

	mwa #data apl_srcptr
	mwa #dst apl_dstptr
	jsr aPL_depack

	mwa $13 $80
	mva $d40b $82

	jmp *

apl
	icl 'aplib_6502.asm'		; 11 69

	.print *-apl

data
	ins 'koronis.apl'


	run main
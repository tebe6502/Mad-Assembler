
/*
  test na obecnosc CPU65816
  dla CPU6502 kod programu jest calkowicie "przezroczysty"

  autor: Ullrich von Bassewitz
  
  changes: 14.03.2005  
*/

	opt c+
	org $2000

	lda #0

	inc @

	cmp #1
	bcc cpu6502

; ostateczny test na obecnosc 65816

	xba		; put $01 in B accu
	dec @		; A=$00 if 65C02
	xba		; get $01 back if 65816
	inc @		; make $01/$02

	cmp #2
	bne cpu6502

cpu65816
	printf
	.by '65816' $9b 0

	rts

cpu6502
	printf
	.by '6502' $9b 0

	rts

	.link 'libraries/stdio/lib/printf.obx'

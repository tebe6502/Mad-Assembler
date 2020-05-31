
* RLE Depacker by Konop, Magnus, Probe, Seban, Tebe (alphabetical order)

; Usage: RLE #SOURCE-1 , #DESTINATION


	.reloc

	.public rle


.proc	rle (.word inputPointer+1, outputPointer+1) .var

loop    jsr getByte
	beq stop
	lsr @

	tay
lp0	jsr getByte
outputPointer
lp1	sta $ffff

	inw outputPointer+1

	dey
_bpl    bmi loop

	bcs lp0
	bcc lp1

getByte
	inw inputPointer+1

inputPointer
	lda $ffff

stop    rts

.endp


* Depack routine for FlashPack 2.1
* By Fox of Taquart, 5th May 1997
* Average speed: 30 kB/sec

* 4 bytes on page 0

ff	equ $fc
bt	equ $fd
ad	equ $fe

* Do not start from here!!!
dep1	tax
	beq ret
	lda #$7f
dep2	bcc *+3
	inx
	inx
	sta ad
dep3	lda (ad),y
put	sta $8080,y
	iny
	bne dep4
	inc ad+1
	inc put+2
dep4	dex
	bne dep3
	asl bt
	bne dep7
	asl ff
	bne dep5
* Routine starts here!
start	equ *
	sec
	jsr get
	rol @
	sta ff
dep5	lda #1
	bcc dep6
	jsr get
	rol @
dep6	sta bt
dep7	jsr get
	ldx #1
	bcc put
	lsr @
	bne dep2
	jsr get
	bcs dep1
	tay
	jsr get
	sta ad+1
	sta put+2
	bcc dep7
* Set address of packed data here!
* (or make your own "get" routine)
get	lda $ffff
	inc get+1
	bne ret
	inc get+2
ret	rts

	end of code

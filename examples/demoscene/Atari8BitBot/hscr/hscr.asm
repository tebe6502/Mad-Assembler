	org $2000

; make & setup display list

	ldx #0		; load LSB byte of Display-List address
	stx 0		; set LO-byte o scroll window pointer
	stx $230	; set LO-byte of DL address
	ldy #$7f	; load MSB byte of Display-List address
	sty $231	; set HI-byte of DL address
	sty $2c4	; also $7f will be the char colour
	iny		; inc. Y, so we have $80 in Y now!
m0	lda #$56	; load ANTIC mode #6 with LMS + hscroll 
	jsr pdl		; push to DL
	lda #$64	; LO-byte of LMS
	jsr pdl		; push to DL
	tya		; HI-byte of LMS from Y reg.
	jsr pdl		; push to DL
	iny		; next line will start at next memory page ($80,$81...)
	cpx #90		; display-list construction complette? 
	bcc m0		; no! do the loop!

; select 2nd half on charset for ANTIC mode #6 (graphics 1)
	lda #$e2
	sta 756

; main loop

l0	lda $14		; wait for vertical blank
	cmp $14
	beq *-2

	dec s+1		; decrement H-Scroll value (self. mod code)
	bne s		; if not zero skip DL pointers update, do only H-Scroll mod.
	
	lda #8		; when H-Scroll value is 0 then reload it to initial value
	sta s+1

	ldx #87		; X reg. will be loop counter (30 lines * 3 bytes of DL program for each line)

	lda #0		; clear A reg.
l3	inc $7f01,x	; increment LO-byte of each LMS in DL
	bpl lx		; no overflow? (<$80) jump to lx
	sta $7f01,x	; when overflow (>$80) just clear tha LO-byte of LMS
lx	dex		; loop counter decrement -1
	dex		; ...                    -2
	dex             ; ...                    -3
	bpl l3		; loop until end of DL (X reg. > 0)

s	ldx #8		; H-Scroll value
	stx $d404	; put it into ANTIC HScroll register

; random maze generator routine is executed only whenn H-scroll register have full cycle

	dex		; decrement X (sets the Z bit in status register, and shorter then CPX)
	bne l0		; when X not zero skip maze-generator routine

	lda #$80	; 1st displayed line is located at $8000, 2nd at $8100, etc.
	sta 1		; init the HI-byte of maze generator write pointer
	
	ldx #30		; we will generate 30 maze elements (1 for each line)
l4	lda $d20a	; get random byte from POKEY POLY/LFSR reigster
	and #1		; leave only one bit (bit#0), so here we have only 0 or 1 values
	clc		; clear carry bit (before addition)
	adc #6		; add six, so we can get \ or / symbol in maze
	ldy #$00	; set slide window pointer at the begining of scroll window
	sta (0),y	; write value into scroll slide window
	ldy #$80	; set slide window pointer at the end of scroll window
	sta (0),y	; write the sam char value into scroll slide window
	inc 1		; inc. HI-byte of scrolling windows pointer (next page, means next line)
	dex		; decr. X reg. (loop counter)
	bne l4		; repeat loop until X is 0

	inc 0		; increment LO-byte of slide window write pointer
	bpl *+4		; check for overlow (when < $80) skip next instruction
	stx 0		; overflow occured! (value > $7f), so clear the LO-byte of write pointer
	bcc l0

; push to display list subroutine

pdl	sta $7f00,x	; write value from A reg. into actual Display list address ($7f00+ X reg.)
	inx		; move DL address / write pointer to the next location
	rts		; return

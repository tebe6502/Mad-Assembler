; zero page variables

cnt = $fb		; neigbours counter
src = $fc		; actual cell population pointer
dst = $fe		; new cell population pointer

; variables 

buf1 = $bc40		; screen buffer #1 address
buf2 = $ac40		; screen buffer #2 address

	org $2000		; location of code

; program starts here
;
; the code is called by the USR instrution from BASIC
; so the Y register is set to #1, and X register is set to #2

; generation of random cell population

main

	iny		; increment Y reg. (so we have #2 in Y reg.)	
s0	lda $d20a	; get random value
	and #$03	; mask out (0-3 values now possible)
	bne *+5		; non zero? skip next instr.
s1	inc buf1+39,x	; increment screen buffer (born of cell)
	inx		; next cell
	bne s0		; do the loop
	inc s1+2	; next page
	dey		; decr. page counter
	bpl s0		; negative? no, so do the loop
	stx buf1+2	; clear out the cursor

; generation loop...

; but at first we need to setup the bufferw pointers

ngen	lda #<buf1	; init LO-Bytes of buffer pointers
	sta src
	sta dst
xor	lda #>buf2	; load HI-byte...
	sta dst+1	; and put it in dst pointer
	eor #$10	; some kind of dirty hack, the fast way of change to 2nd buffer address
	sta src+1	; set HI-byte of src pointer
	sta $bc25	; set also screen address in display list (double buffering, page filp, etc.)
	sta xor+1	; set the buffer value for next generation of cells (swap the buffers actual with previous)
	clc		; clear carry
	adc #3		; add #3 for calculate end address of actual buffer
	sta xend+1	; save in code body below

; neighbors counting loop

loop	ldx #7		; load neighbors counter loop
	lda #0		; clear the cell counter
        sta cnt

c0	ldy idx,x	; get cell index/offset from LUT table
	lda (src),y	; check the presence of cell (value greater then 0 means live cell)
	beq c1		; no cell here, so skip to c1
	inc cnt		; cell present, increment cell counter
c1	dex		; dect. loop counter
	bpl c0		; X is negative (end of loop)
	ldx cnt		; load neighbors count to X reg.

	ldy #41		; set current cell position
	lda (src),y	; load current call value 
	bne cell	; cell is alive, go to next checks
	cpx #3		; cell is empty, check if new cell will be born?
	beq live	; yes! 3 neighbors, so born new cell!
	bne dead	; in other cases treat cell as dead.
cell	cpx #2		; live cell, check for 2 neigbors
	bcc dead	; ...if less then dead from loneliness
	cpx #4		; then check for 4 neigbors
	bcs dead	; ...if 4 or more then dead from overpopulation
live	lda #$54	; in other cases cell stay alive!
	.byte $2c	; BIT $xxxx mnemonic value (used to skip next 2 bytes, LDA #0 instruction in this case)
dead	lda #$00	; dead cell value

	sta (dst),y	; store in destination buffer

	inc dst+0	; incement src and dst pointers
	inc src+0
	bne *+6
	inc src+1
	inc dst+1
	
	lda src+0	; check for src buffer for end of processing value
	cmp #$b0	; LO-byte
	lda src+1
xend	sbc #$bf	; HI-byte
	bcc loop	; if scr pointer < end of buffer, do the loop

	bcs ngen	; end of frame processing, to next population loop

; neighbours index/offset table

idx	.byte 0,1,2,40,42,80,81,82

	run main
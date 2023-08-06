; simple "water effect" for Atari8bitBot
;
; done by Seban/Slight, 2021.01.12
;
; .O
; ..O  >>> Public Domain <<<
; OOO

; zero page variables (zeroed by default after running code in Atari8BitBot Enviroment)

buf1	= $f8
buf2	= $fa
drop	= $fc
cnt	= $fe

; starting address (located at 1st half of stack for saving some bytes in base63 decoder code)

	org	$100

st				; A reg is zero after ?USR(256)
	tax			; clear X reg. also

; prepare charset for GTIA 40x24 chunky mode

chlp	ldy	#15		; set rep. counter
rplp	sta	$8000,x		; save A as a charset value
	inx			; next byte
	dey			; dec. repetition counter
	bpl	rplp		; do the loop until Y reg. is positive
	adc	#$11		; add the value of "next shade of gray"
	bcc	chlp		; loop until carry overflow (>$ff)

; main loop

loop	lda	$d40b		; wait for scanline #128
	bpl	*-3
	sta	$2c8		; $80 in A reg. now, so set the background color
	sta	$2f4		; set HI-byte of charset
	lsr	@		; $80/2 = $40
	sta	$26f		; turn on the GTIA mode (16 shades of one colour)

xor	lda	#$a0		; load HI byte of 1st buffer ($A0xx)
	sta	buf1+1		; set HI byte of buffer #1 pointer
	sta	$bc25		; modify DL (HI byte of screen address is now pointing @ buffer#1
	eor	#$10		; xoring by $10 we set the HI byte to $B0xx
	sta	buf2+1		; set HI byte of buffer #2 pointer
	sta	xor+1		; self. mod. code (swap bufer #1 & buffer #2 addresses)
add	adc	#0		; add a RND value (0-3) to the HI byte of buffer #2)
	sta	drop+1		; save in HI-byte off "rain drop" address

	inc	cnt		; increment frame counter
	lda	cnt		; load frame counter
	and	#$07		; mask-out (leve only 3 lowest bits)
	bne	npr		; skip "rain drops" generation when not zero (rain drops generated every 8th frame)
	lda	$d20a		; get random byte
	sta	drop+0		; save in LO-byte of "rain drop" address
				; to save space we will use the same random byte to generate HI-byte off address
	and	#$03		; mask out all bits exept bits 0,1 (limit value to 0..3 range)
	sta	add+1		; store directly into code (self mod. code saves some bytes)

	lda	#$1f		; rain drops color value

; draw raindrop shape

	ldy	#41		; location of first pixel (x,y)
	sta	(drop),y	; put pixel at 1st location
	iny			; next pixel location (x+1,y)
	sta	(drop),y	; put pixel at 2nd location
	ldy	#81		; next pixel location (x,y+1)
	sta	(drop),y	; put pixel at 3rd location
	iny			; next pixel location (x+1,y+1)
	sta	(drop),y	; put pixel at 4th location

npr	ldx	#4		; # of pages to process

; water processing loop
;
; buffer #2 --> current water state
; buffer #1 --> previous water state
;
; for every byte/pixel in buffer #1 & #2 do...
;
; get those pixel values: A(X,Y-1), B(X-1,Y), C(X+1,Y), D(X,Y+1) from buffer #1
;
;    A
;   BVC
;    D
;
; get pixel value V from buffet #2
;
; then calculate: V= (A+B+C+D) /2 - V, when V<0 then V=-V
;
; ... and finally put the V value back into buffer #2

lp1	clc			; carry clear
	ldy	#1		; set pixel location
	lda	(buf1),y	; get 1st pixel value
	ldy	#81		; set pixel location
	adc	(buf1),y	; add 2nd pixel value
	ldy	#40		; set pixel location
	adc	(buf1),y	; add 3rd pixel value
	ldy	#42		; set pixel location
	adc	(buf1),y	; add 4th pixel value
	lsr	@		; divide by 2
	dey			; adjust pixel location
	sec			; set carry (for substraction)
	sbc	(buf2),y	; substract pixel value from buffer #2
	bcs	*+4		; skip when no overflow (>0)
	eor	#$ff		; inverse all bits (theoreticaly -V is equal V=(V xor $ff)+1...
				; but skipped +1 correction to save some bytes)

	sta	(buf2),y	; save calculated pixel value in buffer #2

	inc	buf1		; increment LO-byte address of 1st buffer
	inc	buf2		; increment LO-byte address of 2nd buffer
	bne	lp1		; loop until overflow

	inc	buf1+1		; increment HI-byte of buffer #1 pointer
	inc	buf2+1		; increment HI-byte of buffer #2 pointer
	dex			; decrement page counter
	bne	lp1		; repeat until done

	beq	loop		; jmp to main loop (shorter version of JMP)

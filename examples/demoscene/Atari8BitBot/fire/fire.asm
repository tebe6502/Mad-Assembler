; constant

cls		= 125		; clear-screen ATASCII code
scrn		= $9c40		; starting address of screen memory
scrfire		= $9f00		; last page of screen memory
memtop		= $a000		; MEMTOP address
charset		= $4000		; charset address
linelen		= 40		; line length (in bytes)

; direst OS-ROM calls (not very compatible with OS-es other than XL/XE OS-ROM)

graphics	= $ef9c
putchar		= $f1a4

; this part is needed when running the code outside Atari Assember Editor


	org $600

init	lda	#>memtop	; set MEMTOP
	sta	$6a		
	lda	#0		; select mode #0
	jsr	graphics	; set the graphics mode


; this loop fills the 1st page os screen memory with random garbage
; (for testing clear screen routine works)
; ... and ...
; and fills the 1st page after memtop with $ff values
; (testing that the fire routine don't touch anything after memtop area)

	ldx	#$00		; clear X reg. (loop counnter)

cl0	lda	$d20a		; get random byte
	sta	scrn,x		; put in on screen memory

	lda	#$ff		; load $ff into A reg. (max byte value)
	sta	memtop,x	; store it after memtop

	inx			; increment loop counter
	bne	cl0		; do the loop
	rts

	org	$2e0

	.word start
	.word init



	org	$2000

start	lda	#cls		; clear screen
	jsr	putchar		; OS-ROM put_char

	lda	#$40		; $40 will be...
	sta	$26f		; good for setting proper GTIA mode
	sta	$2f4		; and good address for new charater set ($4000)
	sta	$9c3c		; and also good for removing last line in 
	lsr	@		; also clears carry bit!
	sta	$2c8		; set background color!

	lda #0			; clear A reg.
	tax			; clear X reg. also

	sta	scrn+2		; clear the cursor

; prepare the charset

chlp	ldy	#15		; set rep. counter
rplp	sta	$4000,x		; save A as a charset value
	inx			; next byte
	dey			; dec. repetition counter
	bpl	rplp		; do the loop until Y reg. is positive
	adc	#$11		; add the value of "next shade of gray"
	bcc	chlp		; loop until carry overflow (>$ff)
 
; main loop

fireloop

	ldy	#>scrfire	; load the HI-byte of last page of screen memory

avglp	sty	s1+2		; put HI-byte od screen memory directrly into code (self. mod. code used)
	sty	s2+2
	dey			; because of "negative indexing" we need to change page boudary

	sty	s0+2		; and put decremented HI-byte directrly into code
	sty	s3+2
	sty	s4+2

; here we have the averaging loop
; we don't care about carry bit, because we need more "random" noise from other pixels

s0	lda	scrfire+0-1,x	; get X , Y pixel
s1	adc	scrfire+1-1,x	; add X+1,Y pixel
s2	adc	scrfire+2-1,x	; add X+2,Y pixel
s3	adc	scrfire+1-40,x	; add X+1,Y-1 pixel

	lsr	@		; ... divide by 2
	lsr	@		; ... and again

s4	sta	scrfire-40,x	; save new pixel value

	php			; store status reg. on stack (we need Carry to be left untouched)

; this should be done once per fire-loop, but due to optymization we do it here several times

	cpx	#linelen	; compare X reg. with line length
	bcs	rdn		; when X > screen line length skip

	lda	$d20a		; get random byte
	and	#$1f		; leave only 5 lower bits (values 0..31)
	sta	memtop-40,x	; store in last screen line

rdn	plp			; restore status reg.

	inx			; next byte on page
	bne	s0		; do the page loop

	cpy	#[>scrfire]-2	; check if all screen-memory pages are processed
	bcs	avglp		; no? then do the averaging loop again!
	
	bcc	fireloop	; carry is always cleared here, so BCC is like shorter JMP!

	run start
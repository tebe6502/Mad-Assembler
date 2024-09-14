		opt	h+

sine		equ	$600				; sine table location
line		equ	$00				; line buffer location

		org	$100				; start of code (placed at stack area)

init		inc	$d40e				; disable NMI

		ldy	#$00
;		tay					; when calling from TBXL we have #0 in A reg.

; move code to zero page

		ldx	#zp_code_end-zp_code_str	; size of moved code to X reg.
		stx	$d01b				; switch GTIA to 16-shades mode
zp_mv		lda	zp_code_ldr,x			; copy from source...
		sta	z:zp_code_str,x			; ...to destination
		dex					; decr. loop counter
		bpl	zp_mv				; all done?

; calculate sine table

s0		ldx	#-4				; use negative index for loop counter opt.
s1		lda	z:val+4,x			; first add delta to val, then add xad to delta
		adc	z:val+6,x
		sta	z:val+4,x
		inx					; inc. reg counter
		bne	s1				; done when X reg. is zero
		
		lda	z:val+1				; store calculated val (hi-byte) to sine LUT
		sta	sine,y
		eor	#$1f				; negate
		sta	sine+$80,y			; fill-up the 2nd half of fine table
		iny					; next step
		bpl	s0				; all bytes done?
		bmi	go				; jump to main code ;)

; code located od zero page starts here... 

zp_code_ldr
		org	r:$a0				; address of zero-page code location 
zp_code_str		

val		dta	a(0)				; used to caltulate sine LUT
dlt		dta	a(0)				; sine LUT delata
xad		dta	a(1)				; sine LUT increment

dl		dta	$4f,a(line+0),$01,a(dl)		; display list

loop		ldy	#240				; # of lines to process

adc0		lda	#0				; starting val. of 1st component
		sta	z:sm0+1				; store directly in code body
adc1		lda	#0				; starting val. of 2st component
		sta	z:sm1+1				; store directly in code body
		
kf_loop							; kefrens bars drawin loop
sm0		lda	sine				; get 1st sine value
sm1		adc	sine+$80			; add 2nd sine value
		lsr	@				; /2
		tax					; move to X reg. (line buffer index)

; the "shaded-plot" routine		
		
		clc					; clear carry
		lda	#$11				; value added to pixel/line buffer (add +1 to both nibbles)
		adc	z:line+3,x			; add current value in pixel/line buffer
		bcc	*+4				; check for overflow
		lda	#$ff				; when overflow then set max. luminance/saturation

		sta	z:line+3,x			; store in pixel/line buffer

		inc	sm0+1				; inc. index of 1st sine component
		inc	sm0+1
		inc	sm1+1				; inc. index of 2nd sine component

		sta	$d40a				; halt CPU till end of scanline!
		dey					; decr. loop counter (lines to process)
		bne	kf_loop				; all done?

		inc	adc1+1				; inc. 1st starting value
		dec	adc0+1				; dec. 2nd starting value
		dec	adc0+1				; repeat for 2nd component (-2)

go		ldx	$d40b				; wait for scanline #0
		bne	*-3
		stx	$d403				; set Hi-byte of DLIST pointer
xor		lda	#<dl				
		sta	$d402				; set Lo-byte od DLIST pointer
		eor	#$03				; emulate interlac mode (even/odd lines switch)
		sta	xor+1				; store modif. value
		
		txa					; clear A reg.
c0		sta	z:line,x			; clear pixel/line buffer
		inx					; next byte in pixel/line buffer
		bpl	c0				; repeat until X is <128 (of coz we can clear only 1st 40 bytes
							; ...this loop construcion shortens the code
		
		bmi	loop				; always jump to main loop 
zp_code_end

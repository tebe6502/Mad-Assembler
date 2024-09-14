		opt	h+

sine		equ	$600
line		equ	$00

		org	$100

init		inc	$d40e

		ldy	#$00
;		tay					; when calling from TBXL we have #0 in A reg.

		inc	$d01a				; set background color

		ldx	#zp_code_end-zp_code_str
		stx	$d01b				; switch GTIA to 16-shades mode
zp_mv		lda	zp_code_ldr,x
		sta	z:zp_code_str,x
		dex
		bpl	zp_mv

s0		ldx	#-4
		clc
s1		lda	z:val+4,x
		adc	z:val+6,x
		sta	z:val+4,x
		inx
		bne	s1
		
		lda	z:val+1
		sta	sine,y
		eor	#$1f
		sta	sine+$80,y
		iny
		bpl	s0
		bmi	go

zp_code_ldr
		org	r:$a8
zp_code_str		

dl		dta	$4f,a(line+8),$01,a(dl)

val		dta	a(0)
dlt		dta	a(0)
xad		dta	a(1)

loop		ldy	#240

		lda	z:sm0+1
		pha
		lda	z:sm1+1
		pha
		
kf_loop		
sm0		lda	sine
sm1		adc	sine
		tax
		
		lda	#$11
		adc	z:line,x
		bcc	*+4
		lda	#$ff
		
		sta	z:line,x

		inc	sm0+1
		inc	sm0+1
		inc	sm1+1

		sta	$d40a
		dey
		bne	kf_loop
	
		pla
		adc	#+1
		sta	sm1+1
		
		pla
		adc	#-2
		sta	sm0+1

go		lda	$d40b
		bne	*-3
		sta	$d403
		ldx	<dl
		stx	$d402
		
		tax
c0		sta	z:line,x
		inx
		bpl	c0
		
		bmi	loop
zp_code_end

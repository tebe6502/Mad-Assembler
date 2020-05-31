// http://xxl.atari.pl/mapram/


portb	= $d301

bsav	= $80
ext_b	= $5000		;cokolwiek z zakresu $5000-$57FF
Result	= $0600

false	= $24		; red
true	= $78		; blue

	org $2000
main

	sei
	inc $d40e

	mva #FALSE Result

	lda portb
	pha

	lda #$ff
	sta portb

	lda ext_b
	pha

_p0	jsr setb
	lda ext_b
	sta bsav

	lda #$00
	sta ext_b

	lda #$ff
	sta portb	;eliminacja pamiêci podstawowej
	sta ext_b

_p2	jsr setb

	inc ext_b
	beq _p3

	mva #TRUE Result

_p3	lda bsav
	sta ext_b

	lda #$ff
	sta portb

	pla
	sta ext_b

	pla
	sta portb

	mva result 712

	dec $d40e
	cli

	jmp *
	
	
setb	lda portb
	and #%01001110	; !!!
	ora #%00110000  ; MAPRAM ON
	sta portb	
	rts

	run main
	
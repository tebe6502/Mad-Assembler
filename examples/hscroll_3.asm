
	org $2000

hscrol	= $d404

scroll_buffer	= $400		; 0..95 bytes

end_of_text	= $9b


; ----------------------------------------------------------

dl	dta d'ppp'
	dta $42|$50
sadr	dta a(scroll_buffer)
	dta $41,a(dl)

; ----------------------------------------------------------

main
	mwa #dl 560

loop	lda:cmp:req 20

	jsr scroll

	jmp loop

; ----------------------------------------------------------

.local	scroll

	lda hsc
	bne toEnd

	lda #4
	sta hsc

	ldy sadr

	lda txtadr: text
	cmp #end_of_text
	bne skp

	mwa #text txtadr
	lda text

skp	sta scroll_buffer,y
	sta scroll_buffer+48,y

	iny
	cpy #48
	sne
	ldy #0
	sty sadr

	inw txtadr

toEnd	dec hsc

	lda hsc: #4
	sta hscrol

	rts

text	dta d 'to jest tekst przykladowy, scrolla z buforem ulegajacemu zapetleniu             '

	dta end_of_text		; end

.endl

; ----------------------------------------------------------

	run main

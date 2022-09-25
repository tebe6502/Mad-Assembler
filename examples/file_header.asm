
	org $2000

part1
	lda #$80
	sta 712
	rts 

	ini part1

/*
	jesli zmienimy naglowek na a($FFFA) wowczas DOS II+ po napotkaniu takiego bloku zakonczy odczyt
	natomiast SPARTA DOS (4.22) odczyta oba bloki, bo dla SPARTA DOS bloki a($FFFF) i a($FFFA) sa rownowazne
*/

;	org [a($FFFF)],$3000
	org [a($FFFA)],$3000

main
	lda #$26
	sta 712
	rts

	run main
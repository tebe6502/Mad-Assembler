
/*
  INPUT STRING

  wprowadza znaki 'A'..'Z' z klawiatury pod adres 'string' bez uzycia OS-u

  adres 'string' zwraca w zmiennej ZP0
*/

	org $2000

ekran	= $bc40+4*40+5

zp0	= $80

chars	= 10			; maksymalna liczba znakow do wprowadzenia


input_string

	lda #0
	sta indY+1
	sta _2+1

	mwa #ekran zp0		; ustawiamy kursor wg okna lewego lub prawego

_1	jsr get_key

	cmp #$9b	
	beq _end
	cmp #$7e
	beq _del

char_ok
	ldy _2+1
	cpy #chars		; maksymalna dopuszczalna liczba znakow
	beq _1
_2	ldy #0
	sta string,y
	iny
	sta (zp0),y
	lda #"?"
	iny
	sta (zp0),y
	inc _2+1
	jmp _1

_del	ldy _2+1
	beq _1
	lda #" "
	sta string,y
	iny
	sta (zp0),y
	dec _2+1
_4	lda #"?"
	dey
	sta (zp0),y
	jmp _1

_end	ldy _2+1
	sta string,y

indY	ldy #0
	mva #$9b string,y

	mwa #string zp0
	rts

* ----------------------------------

get_key
	lda:cmp:req 20

	lda $d20f
	and #4
	bne get_key

	ldy $d209
	lda tab,y
	cmp #$ff
	beq get_key

	cmp #0
old_key equ *-1
	bne skp

	ldx #6
delay	equ *-1
	dex
	stx delay
	bne get_key

	mvx #6 delay 

skp
	sta old_key

	mvx #6 delay
	rts

tab	.array [256] = $ff

	[63]:[127] = "A"
	[21]:[85]  = "B"
	[18]:[82]  = "C"
	[58]:[122] = "D"
	[42]:[106] = "E"
	[56]:[120] = "F"
	[61]:[125] = "G"
	[57]:[121] = "H"
	[13]:[77]  = "I"
	[1] :[65]  = "J"
	[5] :[69]  = "K"
	[0] :[64]  = "L"
	[37]:[101] = "M"
	[35]:[99]  = "N"
	[8] :[72]  = "O"
	[10]:[74]  = "P"
	[47]:[111] = "Q"
	[40]:[104] = "R"
	[62]:[126] = "S"
	[45]:[109] = "T"
	[11]:[75]  = "U"
	[16]:[80]  = "V"
	[46]:[110] = "W"
	[22]:[86]  = "X"
	[43]:[107] = "Y"
	[23]:[87]  = "Z"
	[33]:[97]  = " "
	[52]:[180] = $7e
	[12]:[76]  = $9b

	.enda


string	.ds chars+1

	run input_string

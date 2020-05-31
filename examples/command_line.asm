boot	= $09
dosvec	= $0a

	org $2000

main
	lda boot		; sprawdzamy, czy DOS w ogole jest w pamieci
	lsr
	bcc _no_command_line

	lda dosvec+1		; a jesli tak, czy DOSVEC nie wskazuje ROM-u
	cmp #$c0
	bcs _no_command_line

	ldy #$03
	lda (dosvec),y
	cmp #{jmp}
	bne _no_command_line

	; tu dalsze czynnosci zwiazane z wierszem polecen

	adw dosvec #3 zcr

loop	jsr $ffff
zcr	equ *-2
	beq _no_command_line

	ldy #33
_cp	lda (dosvec),y
	sta parbuf-33,y
	iny
	cmp #$9b
	bne _cp

	putline #parbuf

	jmp loop
	rts

_no_command_line
	; przeskok tutaj oznacza brak dostepnosci wiersza polecen

	mva #$26 712

	jmp *
	rts

	.link 'libraries\stdio\lib\putline.obx'

parbuf

	run main


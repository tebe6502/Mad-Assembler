
/*
  Przyk³ad wykorzystania biblioteki procedur graficznych GRAPH_OS.OBX
*/

	org $2000

main

	graphics #$60 #$f #%00010000	; kana³, tryb OS, typ_ekranu

; typ_ekranu:
;		bit 5 - bez kasowanie pamieci ekranu
;		bit 4 - z oknem tekstowym
;		bit 2 - odczyt z ekranu

	color #3			; kolor pisaka
	plot #0 #0			; punkt
	drawto #159 #191		; linia ³¹cz¹ca ostatnio narysowany punkt

	color #2
	plot #12 #32

	plot #32 #64
	drawto #100 #180

	color #1
	plot #100 #40
	drawto #120 #80
	drawto #80 #90
	drawto #80 #30
	drawto #100 #40


	printf				; wypisujemy tekst, koñczymy znakiem EOF ($88 = 136)
	.by 'Hello %' $9b
	.by 'World' $9b 0
	dta a(20)

	jmp *

;---
	.link 'lib\graph_os.obx'

	.link '..\stdio\lib\printf.obx'
;---
	run main

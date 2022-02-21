
hscrol	= $d404

	org $600

dlist	dta $70,$70,$70		; 24 puste linie ($70 = 8 pustych linii)
	dta $42|$10		; rozkaz ANTIC-a LMS ($42) dla trybu $02 + $10 dla HSCROL
adres	dta a(text)		; adres scrolla
	dta $41,a(dlist)	; zakończenie programu ANTIC-a

main	mwa #dlist 560		; ustawiamy nowy adres programu ANTIC-a

loop
	lda tmp			; płynny scroll, przepisanie wartości TMP do rejestru HSCROL
	sta hscrol		; koniecznie przed poniższą pętlą opóźniającą

	lda:cmp:req 20

	dec tmp			; zmniejszenie komórki TMP [3,2,1,0]
	bpl loop		; pętla

	mva #3 tmp		; odnowienie wartości komórki TMP

	inc adres		; scroll zgrubny

	ldx adres

	lda scroll
ascrol	equ *-2

	sta text+48,x
	sta text+48-256,x

	inw ascrol

	cpw ascrol #end_scroll
	scc
	mwa #scroll ascrol

	jmp loop

tmp	dta 3			; pomocnicza komórka pamięci TMP

scroll	dta d'to jest tekst przykladowy, scrolla z buforem ulegajacemu zapetleniu'
end_scroll

	org $a000
text	:48 dta d' '

	run main		; adres uruchomienia tego przykładu

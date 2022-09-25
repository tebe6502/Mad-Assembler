
/*
  Przyklad biblioteki standardowych operacji IO dla trybu znakowego (Graphics 0) (zrodla AtariWiki)

  POSXY   (BYTE,BYTE)	- ustawia nowa pozycje X,Y kursora
  PUTCHAR (BYTE)	- wyprowadza znak na ekran, na wczesniej ustalonej pozycji kursora X,Y
  PUTLINE (WORD)	- wyprowadza ciag znakow ograniczony wartoscia $9B na ekran,
  	                  na wczesniej ustalonej pozycji kursora X,Y
  GETLINE		- odczyt znakow z klawiatury i zapisanie ich pod wskazanym adresem

  PRINTF		- wyprowadza ciag znakow ograniczony wartoscia $9B na ekran,
  	                  na wczesniej ustalonej pozycji kursora X,Y  
*/

	org $2000

main
	putchar	#'}'		; clear screen

	posxy	#14 , #11	; set cursor position x,y

	putline	#text		; print text


	lda	#'#'
	sta	text+12		; PRINTF pod znak '#' podstawi wskazany ciag znakowy (STRING)
	
	posxy	#20 , #5
	putchar	#'>'
	getline	#string

	jsr	printf
	.by	$9b
	.by	$9b
text	.by 'Hello World  ' $9b 0
	.wo	string

	jmp	*

	.link 'lib\posxy.obx'
	.link 'lib\putchar.obx'
	.link 'lib\putline.obx'
	.link 'lib\printf.obx'
	.link 'lib\getline.obx'

string

	run main
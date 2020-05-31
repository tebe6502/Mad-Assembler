
/*

  Przyklad wykorzystania bliblioteki procedur dla operacji input/output:

  OPEN		(BYTE,BYTE,WORD)
  READ		(BYTE,BYTE,WORD,WORD)
  CLOSE		(BYTE)
  PCIOV

  PUTLINE	(WORD)		- procedura PUTLINE z biblioteki STDIO

  Przykladowy program odczytuje katalog dyskietki wg podanej maski

*/

	org $2000
main
	putchar #'>'		; znak zachêty '>'

	getline #fnam		; odczyt znaków, wprowadzana jest nazwa urz¹dzenia i maska

	open #$10,#6,#fnam	; otwierany jest #1 kana³ do transmisji
	bmi stop
				; czytamy nazwy plików z katalogu
loop	read #$10,#5,#buf,#128
	bmi stop		; jeœli wyst¹pi b³¹d to koñczymy odczyt nazw plików
	putline #buf		; wyœwietlamy na ekranie odczytan¹ nazwê pliku
	jmp loop

stop	close #$10		; zamykamy #1 kana³

	printf
	.by $9b 'Press any key' $9b $00

	mwa #$ff 764

wait	ldy:iny 764
	beq wait

	mwa #$ff 764
	rts

	.link 'stdio\printf.obx'
	.link 'stdio\putchar.obx'
	.link 'stdio\getline.obx'
	.link 'stdio\putline.obx'
	.link 'io\io_lib.obx'

fnam	.ds 128

buf	equ *

*---
	run main

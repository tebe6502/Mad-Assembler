
/*
  Przyklad uzycia biblioteki FP, oraz procedur z biblioteki STDIO (GETLINE, PRINTF).

  Program prosi o wpisanie dwoch liczb zmiennoprzecinkowych FP0 i FP1, nastepnie dokonuje na nich operacji.
  Dodaje, odejmuje, mnozy, dzieli, oblicza sinus, cosinus, wyniki dzialan wypisuje na ekranie.


  Zmienna FASTCHIP okresla czy ma zostac uzyty standardowy pakiet zmiennoprzecinkowy, czy szybszy tzw. FASTCHIP.

  Obliczenie sinusa dla standardowego pakietu trwa srednio 5 ramek, dla FASTCHIP-a sa to juz srednio 2 ramki.
*/

fastchip	= 1

	ift fastchip

	 icl '..\..\os2ram.asm'		; przepisuje ROM do RAM

	 ini start

	 org $d800
	 ins '..\..\math\fastchip\fastfp.bin'

	eif


	org $2000

main
	jsr printf
	.he 'Input FP0 >' 0
	getline	#afp0		; wprowadzamy z klawiatury liczbe FP - zapisujemy ja pod adresem AFP0

	jsr printf
	.he 'Input FP1 >' 0
	getline	#afp1		; wprowadzamy z klawiatury liczbe FP - zapisujemy ja pod adresem AFP1

	lda:cmp:req $14		; synchronizujemy sie z ramka obrazu

	mwa	#0	$13	; resetujemy zegar systemowy

	_atofp	#afp0 , #fp0		; zamieniamy ASCII AFP0 na liczbe FP0
	_atofp	#afp1 , #fp1		; zamieniamy ASCII AFP1 na liczbe FP1

	_fpadd	#fp0 , #fp1 , #fp2	; dodajemy FP0+FP1, wynik w FP2
	jsr printf			; wypisujemy wynik na ekran
	.he 9b '@ + @ = @' 9b 0
	.wo fp0 fp1 fp2

	_fpsub	#fp0 , #fp1 , #fp2	; odejmujemy FP0-FP1, wynik w FP2
	jsr printf			; wypisujemy wynik na ekran
	.he '@ - @ = @' 9b 0
	.wo fp0 fp1 fp2

	_fpmul	#fp0 , #fp1 , #fp2	; mnozymy FP0*FP1, wynik w FP2
	jsr printf			; wypisujemy wynik na ekran
	.he '@ * @ = @' 9b 0
	.wo fp0 fp1 fp2

	_fpdiv	#fp0 , #fp1 , #fp2	; dzielimy FP0/FP1, wynik w FP2
	jsr printf			; wypisujemy wynik na ekran
	.he '@ / @ = @' 9b 0
	.wo fp0 fp1 fp2

	_degtorad #fp0			; deg -> rad -> fp2
	_fpsin #fp2			; fp2 = sin(fp0)
	_fst0r #fp2			; fr0 -> fp2
	jsr printf
	.he 'SIN(@) = @' 9b 00		; wypisujemy wynik na ekran
	.wo fp0 fp2

	_degtorad #fp0			; deg -> rad -> fr0
	_fpcos #fr0			; fr0 = cos(fr0)
	_fst0r #fp2			; fr0 -> fp2
	jsr printf
	.he 'COS(@) = @' 9b 00		; wypisujemy wynik na ekran
	.wo fp0 fp2

	_degtorad #fp1			; deg -> rad -> fr0
	_fpsin #fr0			; fr0 = sin(fr0)
	_fst0r #fp2			; fr0 -> fp2
	jsr printf
	.he 'SIN(@) = @' 9b 00		; wypisujemy wynik na ekran
	.wo fp1 fp2

	_degtorad #fp1			; deg -> rad -> fr0
	_fpcos #fr0			; fr0 = cos(fr0)
	_fst0r #fp2			; fr0 -> fp2
	jsr printf
	.he 'COS(@) = @' 9b 00		; wypisujemy wynik na ekran
	.wo fp1 fp2

	mva	$14	$600	; pzepisujemy zegar do swoich komorek $600..$601
	mva	$13	$601

	jsr printf		; wyswietlamy czas w ramkach
	.he 9b 'Speed -> % frames' 9b 9b 00
	.wo $600

	jmp main		; loop


	.link 'lib\fp.obx'
	.link 'lib\sincos.obx'

	.link '..\stdio\lib\getline.obx'
	.link '..\stdio\lib\printf.obx'

fp0	.ds 6		; bufor na liczbe FP0
fp1	.ds 6		; bufor na liczbe FP1
fp2	.ds 6		; bufor na liczbe FP2

afp0	.ds 32		; bufor na liczbe FP0 zapisana jako ASCII
afp1	.ds 32		; bufor na liczbe FP1 zapisana jako ASCII
	run main

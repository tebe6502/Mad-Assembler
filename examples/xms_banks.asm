
/*
  Przyklad programu umieszczonego w 2-óch bankach pamieci dodatkowej 16Kb ($4000..$7FFF)
  (na koncu pierwszego od adresu $7FF7 i poczatku drugiego banku od adresu $4000)

  OPT B+ powoduje przelaczenie MADS'a w tryb BANKED, tzn:

  - uzycie pseudorozkazu LMB, NMB, RMB oprocz zmiany numeru banku, wymusza wykonanie makra @ADD_BANK
  - jesli aktualny bank<>0 to MADS sprawdza czy kod programu miesci sie obszarze <$4000..$7FFF>
  - jesli aktualny bank=0 to MADS sprawdza czy kod programu miesci sie poza obszarem <$4000..$7FFF>

  27.03.2006
*/

	opt b+

@TAB_MEM_BANKS	equ $0400
@PROC_ADD_BANK	equ $0600


	org $2000

detect
	jsr @mem_detect
	
	cmp #0
	beq no_mem

	rts

no_mem	jsr printf
	.by 'No XMS memmory !' $9b $9b
	.by 'Press any key' $9b 0

	mva #$ff 764

loop	ldy:iny 764
	beq loop

	pla
	pla
	rts
 
 	opt l-
	icl 'procedures/@mem_detect.asm'
	opt l+

	.link 'libraries/stdio/lib/printf.obx'

	ini detect



* bank #1 EXT
	lmb #1

	.pages $40

bnk1
	mva	#"1"	$bc40

	lda $d20a

	@bank_jmp :bnk2

	.print 'bank #1: ',bnk1,'..',*

	.endpg



* bank #2 EXT
	lmb #2

	.pages $40

bnk2
	sta $d01a

	mva	#"2"	$bc40

	@bank_jmp :bnk1

	.print 'bank #2: ',bnk2,'..',*

	.endpg


* bank #0 RAM
	rmb
;	org $8000

main
	@bank_jmp bnk1


* w pliku @BANK_JMP.MAC znajduje sie deklaracja makra @BANK_JMP i procedury @BANK_JMP_PROC
* dlatego musimy zasemblowac to tutaj poza obszarem <$4000..$7FFF>

	icl 'macros/@bank_jmp.mac'

;---
	run main

	opt l-
	icl 'macros/@bank_add.mac'

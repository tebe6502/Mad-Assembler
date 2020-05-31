
/*
  MPT Player Demo

  Przyklad wykorzystania relocatora dla plikow MPT (MPT_RELOCATOR.MAC)
  oraz playera MPT (MPT_PLAYER.ASM)

  Makro MPT_RELOCATOR.MAC odczytuje z pliku informacje na temat dlugosci
  patternow (etykieta globalna LENPAT) i tempa gry (etykieta globalna SPEED)

  Nowy adres dla modulu MPT definiuje etykieta MSX
*/

msx	equ $4123

	mpt_relocator 'porazka.mpt' , msx

	org msx

	.sav [6] ?length

main
	lda:cmp:req 20

@	lda $d40b
	cmp #16
	bne @-

	mva #$0f $d01a

        jsr mpt_player.play

	mva #$00 $d01a

        jmp main

        icl '..\mpt_player.asm'

;---
        run main

	opt l-
	icl '..\mpt_relocator.mac'

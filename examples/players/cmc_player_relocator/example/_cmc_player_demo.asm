
/*
  MPT Player Demo

  Przyklad wykorzystania relocatora dla plikow CMC (CMC_RELOCATOR.MAC)
  oraz playera CMC (CMC_PLAYER.ASM)

  Nowy adres dla modulu CMC definiuje etykieta MSX
*/

msx	equ $4123

	cmc_relocator 'tekkno.cmc' , msx

	org msx

	.sav [6] ?length

main	LDX <msx
	LDY >msx
	LDA #$70
	JSR cmc_player+3	;Initialize

	LDX #0
	TXA
	JSR cmc_player+3	;Play the first song

loop	lda $d40b
	cmp #16
	bne loop

	mva #$0f $d01a

        jsr cmc_player+6

	mva #$00 $d01a
	
        jmp loop

        icl '..\cmc_player.asm'

;---
        run main

	opt l-
	icl '..\cmc_relocator.mac'

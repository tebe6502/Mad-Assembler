
/*
  TMC Player Demo

  Przyklad wykorzystania relocatora dla modulow TMC i playera TMC
  (player jest wywolywany 1x, 2x, 3x, 4x na ramke w zaleznosci od muzyczki)

  W definicji etykiety MSX podajemy adres pod ktory ma zostac zaladowany plik TMC,
  relokacji adresow instrumentow i patternow dokonuje makro TMC_RELOCATOR

  09.11.2005
*/

msx	equ $6fef			// nowy adres modulu TMC

	tmc_relocator 'reflex00.tmc' , msx

	org msx

// dlugosc pliku mozna odczytac z etykiety LENGTH (globalna zdefiniowana w makrze) lub wyjatkowo
// w tym przypadku z TMC_RELOCATOR0.LENGTH (lokalna zdefiniowana w makrze przy "zerowym" wywolaniu makra)

// jest dla dyrektywy .SAV nie podano nazwy pliku do zapisania, wowczas dane zostana dolaczone do asemblowanego pliku

	.sav [6] ?length			// pomijamy 6 bajtow z naglowka pliku, reszte dolaczamy

main
	lda #0
	sta 559		; SCREEN OFF

	lda #$70
	ldx >msx
	ldy <msx
	jsr player.init

	ldx #0		;TMC
	txa
	jsr player.init

	lda #$10
	ldx #0
	jsr player.init

loop    lda 20
        cmp 20
        beq *-2

        jsr player.play		// pierwsze glowne wywolanie playera (1x na ramke)


	ift fps = 2		// player wywolywany 2x na ramke

	play 48

	eli fps = 3		// player wywolywany 3x na ramke

	play 20
	play 76

	eli fps = 4		// player wywolywany 4x na ramke

	play 8
	play 48
	play 88

	eif

        jmp loop


        icl '..\tmc_player.asm'

        run main

;---
	opt l-
	icl '..\tmc_relocator.mac'


.macro	play

wait    lda $d40b
        cmp #:1
        bne wait

	lda #:1
	sta $d01a

       	jsr player.sound

	lda #0
	sta $d01a
.endm
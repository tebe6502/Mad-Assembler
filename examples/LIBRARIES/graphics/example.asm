
/*
  Przyklad biblioteki prymitywow graficznych z wykorzystaniem procedur deklarowanych
  przez .PROC i modulow relokowalnych .RELOC

  Procedury PLOT, CIRCLE sa najszybsze dzieki deklaracji procedury jako .REG, czyli parametry
  przekazywane sa do nich przez rejestry CPU

  Procedura LINE zadeklarowana jest jako .VAR czyli parametry beda zapisywane w zmiennych wskazanych
  w deklaracji takiej procedury

  W przypadku braku deklaracji procedury jako .REG lub .VAR zostalaby przyjeta domyslna
  forma z udzialem stosu programowrego MADS'a, wtedy parametry przekazywane i zdejmowane bylyby
  przez stos programowy, realizowalyby to makra @CALL, @PULL, @EXIT

  19.06.2006 by Tebe/Madteam
*/

gfx_mem		equ	$a010

adr		equ	$80	;(2)
zpage		equ 	adr+2

	org $2000

.local scr

ant	antic f , ant

l_adr	:200 dta l(gfx_mem + #*32)
h_adr	:200 dta h(gfx_mem + #*32)

div	:256 dta #/8

mask	:32 dta %10000000,%01000000,%00100000,%00010000,%00001000,%00000100,%00000010,%00000001

.endl

main
        mwa    #scr.ant        560
        mva    #%00100001      559
/*
	ldx #24
	ldy #0
	tya
clr	sta gfx_mem,y
	iny
	bne clr
	inc clr+2
	dex
	bne clr
*/
	plot #220 , #32

	circle #32 , #70 , #27

	line #72 , #22 , #170 , #50

	jmp *

	.link 'lib\plot.obx'
	.link 'lib\circle.obx'
	.link 'lib\line.obx'

	run main

; MACROS

	opt l-

	.macro antic

	dta d'ppp' , $4:1 , a(gfx_mem)
	:+127 dta $:1
	dta $4:1 , a(gfx_mem+$1000)
	:+63 dta $:1
	dta $41 , a(:2)

	.endm

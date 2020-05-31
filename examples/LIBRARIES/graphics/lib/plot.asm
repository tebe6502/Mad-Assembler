// PLOT (19.06.2006)

	.extrn	adr	.byte

	.extrn	scr.l_adr, scr.h_adr, scr.div, scr.mask	.word


	.public	plot


	.reloc

/********************************************************************
  PLOT

  wywolanie procedury:
                      PLOT #x , #y
                      PLOT X , Y

  X -> wspolrzedna pozioma
  Y -> wspolrzedna pionowa

  adr  -> globalna deklaracja etykiety na stronie zerowej ($80) 

********************************************************************/

.proc plot (.byte x .byte y )  .reg

 sty oldY+1		; jedynie rejestr Y wymaga zachowania

 lda scr.l_adr,y
 sta adr
 lda scr.h_adr,y
 sta adr+1

 ldy scr.div,x

 lda (adr),y
 ora scr.mask,x
 sta (adr),y

oldY ldy #0		; zwracamy wartosci pozycji X i Y przekazane do procedury PLOT
 rts

.endp

	blk update address
	blk update external
	blk update public

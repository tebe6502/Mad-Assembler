
/*
  @PULL_PROC

  procedura wykorzystywana przez makro @PULL_2.MAC

*/

.proc @pull_proc

	sta lop+1

	lda <@stack_address
	sec
	sbc lop+1
	sta adr+1
	lda >@stack_address
	sbc #0
	sta adr+2

	ldx @stack_pointer
	ldy #0

adr	lda $ffff,x
	sta @proc_vars_adr,y

	inc adr+1
	bne skp
	inc adr+2
skp
	iny
lop	cpy #0
	bne adr

ResReg
regA	lda #0
regX	ldx #0
regY	ldy #0
	rts

SavReg  sta regA+1
	stx regX+1
	sty regY+1
	rts

.endp

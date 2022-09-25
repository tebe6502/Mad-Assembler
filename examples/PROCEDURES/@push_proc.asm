
/*
  @PUSH_PROC

  procedura wykorzystywana przez makro @CALL_2.MAC

*/

.proc @push_proc

        pha
	stx lop+1

	lda <@stack_address
	sec
	sbc lop+1
	sta adr+1
	lda >@stack_address
	sbc #0
	sta adr+2

	ldx @stack_pointer
	ldy #0
lp
	lda @proc_vars_adr,y
adr	sta $ffff,x

        inx
	iny
lop	cpy #0
	bne lp

        pla
        rts

.endp

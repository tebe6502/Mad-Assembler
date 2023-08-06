	.macro jne
	beq *+5
	jmp %1
	.endm

	.macro jeq
	bne *+5
	jmp %1
	.endm

	.macro dic
	inc %1
	.if %1<256
	bne *+4
	.else
	bne *+5
	.endif
	inc %1+1
	.endm
	
	.macro set
	lda #<%2
	sta %1
	lda #>%2
	sta %1+1
	.endm

	.macro add
	clc
	lda %1
	adc #<%2
	sta %1
	lda %1+1
	adc #>%2
	sta %1+1
	.endm

	.macro sub
	sec
	lda %1
	sbc #<%2
	sta %1
	lda %1+1
	sbc #>%2
	sta %1+1
	.endm

	.macro pok
	sta (p1),y
	inc p1
	bne *+4
	inc p1+1
	.endm

	.macro wor
	lda #<%1 ;<$d012
	pok
	lda #>%1 ;>$d012
	pok
	.endm
	
	.macro x_lda
	lda #$a9
	pok
	adr %1
	pok
	.endm

	.macro x_ldx
	lda #$a2
	pok
	adr %1
	pok
	.endm

	.macro x_ldy
	lda #$a0
	pok
	adr %1
	pok
	.endm

	.macro x_sta
	lda #$8d
	pok
	wor %1
	.endm
	
	.macro x_stx
	lda #$8e
	pok
	wor %1
	.endm

	.macro x_sty
	lda #$8c
	pok
	wor %1
	.endm


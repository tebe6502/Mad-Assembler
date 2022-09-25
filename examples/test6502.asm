* test na poprawnosc asemblacji
* program sklada sie z wszystkich mozliwych
* trybow i rozkazow CPU6502

        opt h-
        org $1000
        
	adc ($80,X)
	adc $a0
	adc #$08
	adc $a000
	adc ($80),y
	adc $80,X
	adc $2000,Y
	adc $2000,X
	
	brk
	
	clc
	cli
	clv
	cld
	
	php
	plp
	pha
	pla
	
	rti
	rts
	
	sec
	sei
	sed
	
	iny
	inx
	
	dey
	dex
	
	txa
	tya
	txs
	tay
	tax
	tsx
	
	nop
	
	bpl *+4
	bmi *+4
	bne *+4
	bcc *+4
	bcs *+4
	beq *+4
	bvc *+4
	bvs *+4
	
	adc ($80,X)
	adc $a0
	adc #$08
	adc $a000
	adc ($80),y
	adc $80,X
	adc $2000,Y
	adc $2000,X
	
	and ($80,X)
	and $a0
	and #$08
	and $a000
	and ($80),y
	and $80,X
	and $2000,Y
	and $2000,X
	
	asl $a0
	asl @
	asl $a000
	asl $80,X
	asl $2000,X
	
	bit $a0
	bit $a000
	
	cmp ($80,X)
	cmp $a0
	cmp #$08
	cmp $a000
	cmp ($80),y
	cmp $80,X
	cmp $2000,Y
	cmp $2000,X
	
	cpy #$08
	cpy $a0
	cpy $a000
	
	cpx #$08
	cpx $a0
	cpx $a000
	
	dec $a0
	dec $a000
	dec $80,X
	dec $2000,X
	
	inc $a0
	inc $a000
	inc $80,X
	inc $2000,X
	
	eor ($80,X)
	eor $a0
	eor #$08
	eor $a000
	eor ($80),y
	eor $80,X
	eor $2000,Y
	eor $2000,X
	
	jsr $a000
	jmp $a000
	jmp ($0600)
	
	lda ($80,X)
	lda $a0
	lda #$08
	lda $a000
	lda ($80),y
	lda $80,X
	lda $2000,Y
	lda $2000,X
	
	ldx #$08
	ldx $a0
	ldx $a000
	ldx $80,Y
	ldx $2000,Y
	
	ldy #$08
	ldy $a0
	ldy $a000
	ldy $80,X
	ldy $2000,X
	
	lsr $a0
	lsr @
	lsr $a000
	lsr $80,X
	lsr $2000,X
	
	ora ($80,X)
	ora $a0
	ora #$08
	ora $a000
	ora ($80),y
	ora $80,X
	ora $2000,Y
	ora $2000,X
	
	rol $a0
	rol @
	rol $a000
	rol $80,X
	rol $2000,X
	
	ror $a0
	ror @
	ror $a000
	ror $80,X
	ror $2000,X
	
	sbc ($80,X)
	sbc $a0
	sbc #$08
	sbc $a000
	sbc ($80),y
	sbc $80,X
	sbc $2000,Y
	sbc $2000,X
	
	sta ($80,X)
	sta $a0
	sta $a000
	sta ($80),y
	sta $80,X
	sta $2000,Y
	sta $2000,X
	
	stx $a0
	stx $a000
	stx $80,Y
	
	sty $a0
	sty $a000
	sty $80,X

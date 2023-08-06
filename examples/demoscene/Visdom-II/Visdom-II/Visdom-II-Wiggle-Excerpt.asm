;	Wiggle-X-Width: 8 to 64 = 57 Pixels
;
;	(r)_03-03-1993_by_JAC! Wiggle_works_100%.

xtab	= base			;Animated_Sine_value_table.
btab	= base+$100		;Branch_offset_table.

...
	clc			;Convert_xpos_table_to_..
	adc #48
	sta mtab,x		;Missile_HPOS.
	lda htab,y
	sta btab,x
...

;================================================================
bragen	ldx #0			;Generate branch offset tab
	ldy #0
bragen1	lda braxtab,x
	cmp x1
	beq bragen3
	sta x1
	cmp #$ff
	beq bragend
	lda branch,x
bragen2	sta htab,y
	iny
	cpy x1
	bne bragen2
bragen3	inx
	jmp bragen1
bragend	rts

braxtab	.byte 8,15,24,32,40,48,56,64,72,76,80,84,88,92,96
	.byte 100,104,108,112,112,114,116,120,127,$ff

branch	.byte 12,k+13,11,k+11,10,k+10,9,k+9,8,k+8,7,k+7
	.byte 6,k+6,5,k+5,4,k+4,3,k+3,2,k+2,1,k+1,0,k

;================================================================

kernel	lda wcol1
	ora whell
	sta kernel2+1
	lda wcol2
	ora whell
	sta $d019
	tay
	clc
	ldx #0
kernel1	sta $d40a
	lda mtab,x
	sta $d004
kernel2	lda #$00
	sta $d01a
	lda btab,x
	sta kernel3+1
kernel3	bne *+0
kernel4	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	sty $d01a
	inx
	bpl kernel1
	rts

kernel5	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bit $00
	sty $d01a
	inx
	bpl kernel1
	rts

k	= kernel5-kernel4

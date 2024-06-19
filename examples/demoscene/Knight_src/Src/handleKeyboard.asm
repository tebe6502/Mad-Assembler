
repetitionDelay	.by 0
lastKey	.by 0


handleKeyboard
	jsr getKey
	cmp #$FF
	bne handleKeyboard1
	rts
handleKeyboard1
	cmp #KEY_1
	bne handleKeyboard11
	lda #$01
	sta mode
	rts
handleKeyboard11
	cmp #KEY_2
	bne handleKeyboard12
	lda #$02
	sta mode
	rts
handleKeyboard12
	cmp #KEY_3
	bne handleKeyboard13
	lda #$03
	sta mode
	rts
handleKeyboard13
	cmp #KEY_4
	bne handleKeyboard14
	lda #$04
	sta mode
	rts
handleKeyboard14
	cmp #KEY_5
	bne handleKeyboard15
	lda #$05
	sta mode
	rts
handleKeyboard15
	cmp #KEY_SPACE
	bne handleKeyboard16
	lda stopScroll
	eor #$01
	sta stopScroll
	rts
handleKeyboard16
	;cmp #KEY_S
	;bne handleKeyboard17
	;lda dgfStability
	;eor #$01
	;sta dgfStability
	;rts
handleKeyboard17
	cmp #KEY_ESCAPE
	bne handleKeyboard18
	lda #$01
	sta quit
handleKeyboard18
	rts


getKey
	;test regular keys
	lda skstat    ;test if any key pressed
	and #$04
	beq kbdHnd10
	lda #$FF
	sta lastKey
kbdHnd9:
	lda #$FF
	rts
kbdHnd10:
	;handle regular keys
	lda kbcode
	tax
	cmp lastKey
	bne kbdHnd11
	lda repetitionDelay
	beq kbdHnd10a ;no repetition
	;beq kbdHnd10b
	dec repetitionDelay
kbdHnd10a:
	jmp kbdHnd9
kbdHnd10b:
	lda #$04
	bne kbdHnd11b
	;lda #$00
	;beq kbdHnd11b
kbdHnd11:
	lda #$14
kbdHnd11b:
	sta repetitionDelay
	txa
	sta lastKey
	rts

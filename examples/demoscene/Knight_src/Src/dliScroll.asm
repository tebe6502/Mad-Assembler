
dliScroll
	sta wsync
	lda #.hi(STD_CHARS_DEF_ADR)
	sta chbase

	lda #COLOR_GREY3
	sta colpf2
	lda #$0A
;	lda #$06
;	lda #$00
	sta colpf1

	sta wsync
	sta wsync
	sta wsync
	sta wsync
	sta wsync
	sta wsync
	lda #$0E
;	lda #$0C
;	lda #$02
	sta colpf1
	sta wsync
	sta wsync
	lda #$0C
;	lda #$0A
;	lda #$02
	sta colpf1
	sta wsync
	sta wsync
	lda #$0A
;	lda #$08
;	lda #$00
	sta colpf1
	sta wsync
	sta wsync
	lda #$08
;	lda #$06
;	lda #$00
	sta colpf1

	rts

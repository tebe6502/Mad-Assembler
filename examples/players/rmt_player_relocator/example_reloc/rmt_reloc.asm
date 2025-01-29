
	opt ?+

;STEREOMODE = 0
STEREOMODE = 1

	icl "ilusia.feat"

FEAT_RECALCADDR = 1
FEAT_PATCH = 0


COLOR4 = $2C8
CH = $2FC

COLBAK = $D01A
VCOUNT = $D40B


	.zpvar = $e0


	org $8000

start:
	IFT FEAT_PATCH
	lda #RMT_STANDARD		;applied patch
;	lda #RMT_PATCH0A
	sta RMTPATCH
	EIF
	IFT FEAT_RECALCADDR
	ldx #<$4000			;original module address
	ldy #>$4000
	stx RMTORIGINALADDR
	sty RMTORIGINALADDR+1
	EIF

	IFT FEAT_GLOBALVOLUMEFADE
	lda #$00
	sta RMTGLOBALVOLUMEFADE
	EIF
	IFT FEAT_SFX
	lda #$F0
	sta RMTSFXVOLUME
	EIF

	ldx #<music
	ldy #>music
	lda #0
	jsr RASTERMUSICTRACKER		;initialize

?loop	lda music+6
	cmp #1
	bcc ?skip1
	lda #[000/2]
	jsr playmusicon
?skip1
	lda music+6
	cmp #2
	bcc ?skip2
	lda #[078/2]
	jsr playmusicon
?skip2
	lda music+6
	cmp #3
	bcc ?skip3
	lda #[156/2]
	jsr playmusicon
?skip3
	lda music+6
	cmp #4
	bcc ?skip4
	lda #[234/2]
	jsr playmusicon
?skip4

	lda CH
	cmp #$1C			;escape
	bne ?loop

	jmp RASTERMUSICTRACKER+9	;silence

playmusicon:
?sync	cmp VCOUNT
	bne ?sync

	lda #$7C
	sta COLBAK

	jsr RASTERMUSICTRACKER+3	;play

	lda COLOR4
	sta COLBAK
	rts


player	icl "..\rmt_player_reloc.asm"

music
	ins "ilusia.rmt",6	;4 $4000 RMT_STANDARD
;	ins "hightide.rmt",6	;8 $4000 RMT_STANDARD
;	ins "flimbo.rmt",6	;4 $4000 RMT_PATCH0A
;	ins "plastic.rmt",6	;4 $4000 RMT_PATCH0A


	run start


	end

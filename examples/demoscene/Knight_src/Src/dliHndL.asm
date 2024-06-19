

dliHndL
	pha
	txa
	pha
	tya
	pha
	;lda tmpChBase
	;clc
	;adc #4
	;sta wsync
	;sta tmpChBase
	;sta chbase
	lda #.lo(tileMapLAdr)
	sta tileMapPtr
	lda #.hi(tileMapLAdr)
	sta tileMapPtr+1
	lda #.hi(pmLAdr)
	sta pmbase
	;lda #.hi(picLAdr)
	lda #.hi(STD_CHARS_DEF_ADR)
	sta chbase
	lda #$22+$1C
	sta dmactls
	sta dmactl      ;enable screen and PMG DMA


;before empty text line

;before empty line 0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;;lda #$08 ;even
	;;ldx #$00 ;even
	;;sta colbak ;even
	sta wsync ;even
	;;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$04
	sta gtiactl
	lda #COLOR_GREY3
	sta colbak
	lda #COLOR_BLACK
	sta colpf0
	lda #COLOR_GREY1
	sta colpf1
	lda #COLOR_GREY2
	sta colpf2
	lda #COLOR_PINK
	sta colpf3

;before empty line 1
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$C0
	sta sizem           ;M3 size 3, M2 size 0, M1 size 0, M0 size 0
	lda #$00
	sta sizep3
	lda #COLOR_WHITE
	sta colpm3
	lda #LEFT_BORDER+73
	sta hposm3
	lda #LEFT_BORDER+42
	sta hposp3

;before empty line 2
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+62
	sta hposp2          ;may be deferred
	lda #$03
	sta sizep2          ;may be deferred
	lda #LEFT_BORDER+75
	sta hposm2          ;may be deferred
	lda #COLOR_YELLOW
	sta colpm2          ;may be deferred

;before empty line 3
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+66
	sta hposp1          ;may be deferred
	lda #LEFT_BORDER+74
	sta hposm1          ;may be deferred
	lda #$00
	sta sizep1          ;may be deferred
	lda #COLOR_LBROWN
	sta colpm1          ;may be deferred

;before empty line 4
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	;lda #LEFT_BORDER+80
	;sta hposp0          ;may be deferred
	lda #LEFT_BORDER-1
	sta hposp0          ;for stability control pos set to -1
	lda #LEFT_BORDER+62
	sta hposm0          ;may be deferred
	lda #$00
	sta sizep0          ;may be deferred
	;lda #COLOR_PINK
	;sta colpm0          ;may be deferred
	lda #COLOR_GREY3
	sta colpm0          ;for stability control pos set to grey3

;before empty line 5
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #1
	sta frameStability    ;for stability control set to 1

;before empty line 6
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before empty line 7
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before regular screen

;before line 0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	lda #.hi(picLAdr)
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 1
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 2
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 3
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 4
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 5
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 6
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 7
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 8
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 9
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 10
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 11
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 12
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$40
	sta grafp3

;before line 13
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 14
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 15
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	jsr dliCheckStability

;before line 16
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_BLACK
	sta colpf0

;before line 17
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+80
	sta hposp0          ;may be deferred
	lda #COLOR_PINK
	sta colpm0          ;may be deferred

;before line 18
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 19
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 20
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+45
	sta hposp3

;before line 21
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 22
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+46
	sta hposp3

;before line 23
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 24
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*1
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+48
	sta hposp3

;before line 25
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 26
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+50
	sta hposp3

;before line 27
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+72
	sta hposm3
	lda #LEFT_BORDER+49
	sta hposp3

;before line 28
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+79
	sta hposm3
	lda #LEFT_BORDER+51
	sta hposp3
	lda #$38
	sta grafp1

;before line 29
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposm3          ;may be deferred 2 lines
	lda #$40
	sta sizem           ;M3 size 1 may be deferred 2 lines, M0 size 0, M1 size 0, M2 size 0

;before line 30
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+53
	sta hposp3
	lda #LEFT_BORDER+82
	sta hposp2
	lda #$80
	sta grafp1
	lda #$28
	sta grafm

;before line 31
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+75
	sta hposp1

;before line 32
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$00
	sta grafp3
	lda #LEFT_BORDER+76
	sta hposm2
	lda #$60
	sta grafm

;before line 33
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+54
	sta hposp3

;before line 34
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+56
	sta hposp3
	lda #LEFT_BORDER+78
	sta hposm2
	lda #LEFT_BORDER+77
	sta hposp1

;before line 35
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 36
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+58
	sta hposp3
	lda #LEFT_BORDER+79
	sta hposm2
	lda #$00
	sta grafp1

;before line 37
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+59
	sta hposp3
	lda #LEFT_BORDER+78
	sta hposp1
	lda #COLOR_LBROWN
	sta colpm0

;before line 38
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$80
	sta grafp3
	lda #LEFT_BORDER+63
	sta hposp2
	lda #LEFT_BORDER+66
	sta hposp1
	lda #$01
	sta sizep1
	lda #$28
	sta grafm
	lda #LEFT_BORDER+80
	sta hposm2

;before line 39
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREEN
	sta colpf3
	lda #LEFT_BORDER+65
	sta hposp1
	lda #LEFT_BORDER+75
	sta hposm2
	;lda #LEFT_BORDER+75
	sta hposm1

;before line 40
	lda #COLOR_GREEN
	sta colpm0
	lda #LEFT_BORDER+74
	sta hposm1
	lda #LEFT_BORDER+62
	sta hposp1
	lda #$80
	sta grafp1
	lda #COLOR_LBROWN
	sta colpm0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
;	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+61
	sta hposp3
	lda #LEFT_BORDER+73
	sta hposp2
	lda #$01
	sta sizep2
	;lda #LEFT_BORDER+74
	;sta hposm1
	;lda #LEFT_BORDER+62
	;sta hposp1
	;lda #$80
	;sta grafp1

;before line 41
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+62
	sta hposp3
	lda #LEFT_BORDER+68
	sta hposp2
	lda #LEFT_BORDER+66
	sta hposp1
	lda #$00
	sta sizep1
	lda #$03
	sta sizep2          ;may be deferred 1 line
	lda #LEFT_BORDER+81
	sta hposm2          ;may be deferred 2 lines
	lda #$70
	sta sizem           ;M2 size 3 may be deferred 2 lines, M0 size 0, M1 size 0, M3 size 1
	lda #LEFT_BORDER+74
	sta hposm0          ;may be deferred

;before line 42
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$80
	sta grafp3
	lda #LEFT_BORDER+64
	sta hposp2
	lda #$89
	sta grafp1
	lda #$48
	sta grafp0

;before line 43
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+67
	sta hposm3          ;may be deferred
	lda #LEFT_BORDER+63
	sta hposm1

;before line 44
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+64
	sta hposp3
	lda #LEFT_BORDER+80
	sta hposm2          ;may be deferred 1 line
	lda #$18
	sta grafp1
	lda #$E0
	sta grafp0
	lda #LEFT_BORDER+81
	sta hposm1          ;may be deferred

;before line 45
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+63
	sta hposp3
	lda #$00
	sta sizep2
	lda #LEFT_BORDER+80
	sta hposp1

;before line 46
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+65
	sta hposp2
	lda #LEFT_BORDER+63
	sta hposp1
	lda #COLOR_GREEN
	sta colpm0

;before line 47
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+77
	sta hposp3
	lda #LEFT_BORDER+68
	sta hposp2
	lda #LEFT_BORDER+80
	sta hposp1

;before line 48
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*2
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+81
	sta hposm2          ;may be deferred
	lda #LEFT_BORDER+78
	sta hposp1

;before line 49
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+49
	sta hposp3          ;may be deferred
	lda #$03
	sta sizep3          ;may be deferred
	lda #LEFT_BORDER+67
	sta hposp1

;before line 50
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_LBROWN
	sta colpm0          ;may be deferred 2 lines

;before line 51
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+83
	sta hposm1

;before line 52
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+76
	sta hposp2

;before line 53
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+75
	sta hposp1
	lda #COLOR_GREEN
	sta colpm0          ;may be deferred 3 lines
	lda #LEFT_BORDER+80
	sta hposm1          ;may be deferred

;before line 54
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+77
	sta hposp2
	lda #LEFT_BORDER+78
	sta hposp1

;before line 55
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 56
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+79
	sta hposp2
	lda #$70
	sta grafp0

;before line 57
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+97
	sta hposm3          ;may be deferred 4 lines
	lda #$D0
	sta sizem           ;M3 size 3 may be deferred 4 lines, M2 size 1 may be deferred, M0 size 0, M1 size 0

;before line 58
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+53
	sta hposp2
	lda #$03
	sta sizep2
	lda #LEFT_BORDER+87
	sta hposm2
	lda #LEFT_BORDER+80
	sta hposp1
	lda #$70
	sta grafp0
	lda #LEFT_BORDER+69
	sta hposp0          ;may be deferred

;before line 59
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+65
	sta hposp1

;before line 60
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+55
	sta hposp2
	lda #$3B
	sta grafp2
	lda #$83
	sta grafp1
	lda #LEFT_BORDER+83
	sta hposm1

;before line 61
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+81
	sta hposm2
	lda #LEFT_BORDER+63
	sta hposp1
	lda #LEFT_BORDER+73
	sta hposm1

;before line 62
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+57
	sta hposp2
	lda #LEFT_BORDER+88
	sta hposm2
	lda #LEFT_BORDER+62
	sta hposp1
	lda #$01
	sta sizep1
	lda #LEFT_BORDER+85
	sta hposm1

;before line 63
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+60
	sta hposp1
	lda #LEFT_BORDER+77
	sta hposm1

	nop
	nop
	nop
	nop
	nop

;before line 64
	lda #$80
	sta grafp1
	lda #$98
	sta grafm
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_PURPLE
	sta colpf3
	lda #$00
	sta grafp2
	lda #LEFT_BORDER+86
	sta hposm2
	;lda #$80
	;sta grafp1
	;lda #$98
	;sta grafm

;before line 65
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+54
	sta hposp2
	lda #LEFT_BORDER+78
	sta hposp1          ;may be deferred 1 line
	lda #$00
	sta sizep1          ;may be deferred 1 line

;before line 66
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+55
	sta hposp2
	lda #LEFT_BORDER+104
	sta hposm1          ;may be deferred

;before line 67
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 68
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+87
	sta hposm2

;before line 69
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 70
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+50
	sta hposp3

;before line 71
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+49
	sta hposp3
	lda #LEFT_BORDER+47
	sta hposm3          ;may be deferred

;before line 72
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*3
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+104
	sta hposm2          ;may be deferred
	;lda #LEFT_BORDER+104
	sta hposm0          ;may be deferred

;before line 73
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+81
	sta hposp1          ;may be deferred

;before line 74
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 75
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+78
	sta hposp0

;before line 76
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 77
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+58
	sta hposp2

;before line 78
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$D9
	sta grafp0

;before line 79
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposp3

;before line 80
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$08
	sta grafp0

;before line 81
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+69
	sta hposp3

;before line 82
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$02
	sta grafp0
	lda #LEFT_BORDER+43
	sta hposp2          ;may be deferred
	lda #$00
	sta sizep2          ;may be deferred
	lda #COLOR_GREEN
	sta colpm2          ;may be deferred

;before line 83
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+44
	sta hposp1          ;may be deferred
	lda #$00
	sta sizep1          ;may be deferred
	lda #COLOR_YELLOW
	sta colpm1          ;may be deferred

;before line 84
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+71
	sta hposp3

;before line 85
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+81
	sta hposp0          ;may be deferred
	lda #COLOR_BLUE
	sta colpm0          ;may be deferred

;before line 86
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 87
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+95
	sta hposp3
	lda #$00
	sta sizep3          ;may be deferred 1 line but with data change to $80
	lda #LEFT_BORDER+46
	sta hposm3          ;may be deferred

;before line 88
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$20
	sta grafp3

;before line 89
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 90
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$20
	sta grafp3

;before line 91
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 92
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 93
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+66
	sta hposp3          ;may be deferred
	lda #$03
	sta sizep3          ;may be deferred

;before line 94
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 95
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+118
	sta hposm3          ;may be deferred

;before line 96
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*4
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 97
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$C4
	sta sizem           ;M2 size 0 may be deferred, M1 size 1 may be deferred, M0 size 0, M3 size 3
	lda #COLOR_LBROWN
	sta colpm0          ;may be deferred

;before line 98
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$3C
	sta grafp1

;before line 99
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+45
	sta hposp2          ;may be deferred 2 lines

;before line 100
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$0C
	sta grafp1

;before line 101
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_BROWN
	sta colpm1          ;may be deferred
	lda #LEFT_BORDER+57
	sta hposp1          ;may be deferred

;before line 102
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$0E
	sta grafp2

;before line 103
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 104
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$03
	sta grafp2

;before line 105
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+108
	sta hposm1          ;may be deferred 4 lines

;before line 106
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$03
	sta grafp2
	lda #LEFT_BORDER+106
	sta hposm2
	lda #COLOR_YELLOW
	sta colpm0
	lda #LEFT_BORDER+105
	sta hposm0

;before line 107
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_LBROWN
	sta colpm2          ;may be deferred 1 line
	lda #LEFT_BORDER+36
	sta hposp2          ;may be deferred 1 line
	lda #$03
	sta sizep2          ;may be deferred 1 line

;before line 108
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$02
	sta grafp2
	lda #$08
	sta grafp1
	lda #LEFT_BORDER+107
	sta hposm0

;before line 109
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+107
	sta hposm2          ;may be deferred 1 line
	lda #LEFT_BORDER+106
	sta hposm0

;before line 110
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$1F
	sta grafp1
	lda #LEFT_BORDER+109
	sta hposm1
	lda #COLOR_PURPLE
	sta colpm0          ;may be deferred
	lda #LEFT_BORDER+33
	sta hposp0          ;may be deferred

;before line 111
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+63
	sta hposp3
	;lda #LEFT_BORDER+63
	sta hposm1
	lda #LEFT_BORDER+55
	sta hposp1
	lda #$01
	sta sizep0          ;may be deferred

;before line 112
	nop
	nop
	nop
	lda #$CC
	sta grafm
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+34
	sta hposp2
	lda #$FF
	sta grafp1
	lda #LEFT_BORDER+62
	sta hposm1
	;lda #$CC
	;sta grafm

;before line 113
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+120
	sta hposm3          ;may be deferred up to before line 118
	lda #LEFT_BORDER+33
	sta hposm2          ;may be deferred

;before line 114
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$A0
	sta grafp1
	lda #$C0
	sta grafm

;before line 115
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+63
	sta hposm1

;before line 116
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$42
	sta grafp1

;before line 117
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+54
	sta hposp1
	lda #LEFT_BORDER+66
	sta hposm1

;before line 118
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_RED
	sta colpf3
	lda #LEFT_BORDER+48
	sta hposp1
	lda #$1A
	sta grafp1
	lda #$C8
	sta grafm
	lda #$10
	sta grafp0

;before line 119
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+37
	sta hposp2
	lda #LEFT_BORDER+47
	sta hposm1

;before line 120
	nop
	nop
	nop
	nop
	nop
	lda #$88
	sta grafm
	lda #$E8
	sta grafp0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*5
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+53
	sta hposp1
	lda #$01
	sta sizep1
	;lda #$88
	;sta grafm
	;lda #$E8
	;sta grafp0

;before line 121
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+46
	sta hposp1
	lda #$00
	sta sizep1          ;may be deferred 1 line
	lda #LEFT_BORDER+63
	sta hposm1
	lda #LEFT_BORDER+47
	sta hposm3          ;may be deferred

;before line 122
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$40
	sta grafp1
	lda #$00
	sta grafp0
	lda #COLOR_YELLOW
	sta colpm0          ;may be deferred 1 line
	lda #LEFT_BORDER+46
	sta hposm0          ;may be deferred 4 lines

;before line 123
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+34
	sta hposp3
	lda #$01
	sta sizep3
	lda #COLOR_PURPLE
	sta colpm3
	lda #LEFT_BORDER+67
	sta hposm1

;before line 124
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$56
	sta grafp1
	lda #LEFT_BORDER+68
	sta hposm1
	lda #LEFT_BORDER+35
	sta hposp0
	lda #$CC
	sta sizem           ;M1 size 3 may be deferred 2 lines, M0 size 0, M2 size 0, M3 size 3

;before line 125
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+35
	sta hposp2
	lda #COLOR_WHITE
	sta colpm3          ;may be deferred 2 lines
	lda #LEFT_BORDER+34
	sta hposp0
	lda #LEFT_BORDER+66
	sta hposm1

;before line 126
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$70
	sta grafp0
	lda #LEFT_BORDER+35
	sta hposp0
	lda #$2E
	sta grafm
	lda #$7F
	sta grafp1
	lda #LEFT_BORDER+65
	sta hposm1

;before line 127
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+38
	sta hposp2
	lda #LEFT_BORDER+36
	sta hposm2
	lda #LEFT_BORDER+49
	sta hposp1
	lda #LEFT_BORDER+63
	sta hposm1
	lda #$00
	sta sizep0

;before line 128
	lda #LEFT_BORDER+54
	sta hposp1
	lda #$12
	sta grafp1
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	;sta wsync ;even ; <--
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$3F
	sta grafp2
	lda #$0D
	sta grafm
	lda #LEFT_BORDER+47
	sta hposm0
	;lda #LEFT_BORDER+47
	sta hposp0
	;lda #LEFT_BORDER+54
	;sta hposp1
	;lda #$12
	;sta grafp1

;before line 129
	nop
	nop
	ldy #LEFT_BORDER+97
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sty hposm0
	;sta wsync ;odd ; <--
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+55
	sta hposm2
	lda #$FF
	sta sizem           ;M2 size 3, M0 size 3, M1 size 3, M3 size 3
	lda #LEFT_BORDER+49
	sta hposp2
	lda #LEFT_BORDER+61
	sta hposm1
	;lda #LEFT_BORDER+97
	;sta hposm0

;before line 130
	lda #LEFT_BORDER+42
	sta hposp0          ;may be deferred
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$81
	sta grafp1
	lda #LEFT_BORDER+62
	sta hposm1
	lda #$00
	sta sizep2
	;lda #$00
	sta grafp0
	lda #$6A
	sta grafp2

;before line 131
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 132
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$42
	sta grafp1
	lda #LEFT_BORDER+63
	sta hposm1
	lda #$39
	sta grafp2
	lda #LEFT_BORDER+96
	sta hposm0

;before line 133
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+52
	sta hposp1
	lda #LEFT_BORDER+61
	sta hposm1
	lda #LEFT_BORDER+97
	sta hposm0

	ldx #COLOR_PURPLE
	lda #COLOR_GREY2
	stx colpf2          ;purple glove and others
	sta colpf2

;before line 134
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$A7
	sta grafp1
	lda #LEFT_BORDER+60
	sta hposm1
	lda #$03
	sta grafp2
	lda #$07
	sta grafp0

	ldy 0
	;ldx #COLOR_PURPLE
	lda #COLOR_GREY2
	stx colpf2          ;purple glove and others
	sta colpf2

;before line 135
	;nop
	;nop
	;nop
	lda #LEFT_BORDER+98
	sta hposm0
	lda #LEFT_BORDER+41
	sta hposp0          ;may be deferred 5 lines
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+50
	sta hposp1
	lda #LEFT_BORDER+47
	sta hposp2
	;lda #LEFT_BORDER+98
	;sta hposm0
	;lda #LEFT_BORDER+41
	;sta hposp0          ;may be deferred 5 lines

	ldy 0
	nop
	nop
	ldx #COLOR_PURPLE
	lda #COLOR_GREY2
	stx colpf2          ;purple glove and others
	sta colpf2

;before line 136
	nop
	lda #LEFT_BORDER+44
	sta hposp2
	lda #$20
	sta grafp2
	lda #LEFT_BORDER+59
	sta hposm1
	lda #$18
	sta grafp0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	;sta wsync ;even ; <--
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+51
	sta hposp1
	;lda #LEFT_BORDER+51
	sta hposm2
	lda #$0F
	sta grafp1
	;lda #LEFT_BORDER+59
	;sta hposm1
	;lda #LEFT_BORDER+44
	;sta hposp2
	;lda #$20
	;sta grafp2
	;lda #$18
	;sta grafp0
	nop

;before line 137
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	;sta wsync ;odd ; <--
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+96
	sta hposm0

	nop
	nop
	nop
	nop
	ldy 0
	ldx #COLOR_PURPLE
	lda #COLOR_GREY2
	stx colpf2          ;purple glove and others
	nop
	sta colpf2

;before line 138
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$A8
	sta grafp1
	lda #LEFT_BORDER+98
	sta hposm0

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	nop
	nop
	lda #COLOR_GREY2
	sta colpf2

;before line 139
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+54
	sta hposm2
	lda #LEFT_BORDER+59
	sta hposp1
	;lda #LEFT_BORDER+55
	;sta hposm1          ;may be deferred 1 line
	lda #$F3
	sta sizem           ;M1 size 0 may be deferred 1 line, M0 size 3, M2 size 3, M3 size 3

	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others

	lda #LEFT_BORDER+40
	sta hposp2          ;may be deferred 3 lines

	lda #COLOR_GREY2
	sta colpf2

	lda #$01
	sta sizep2          ;may be deferred 3 lines

;before line 140
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+55
	sta hposm2
	;lda #LEFT_BORDER+55
	sta hposm1
	lda #$0F
	sta grafp1
	lda #$3B
	sta grafm

	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	nop
	ldy 0
	lda #COLOR_GREY2
	sta colpf2

;before line 141
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$01
	sta sizep0

;before line 142
	nop
	nop
	nop
	nop
	;nop
	;nop

	lda #$E8

	ldx #COLOR_GREY2
	ldy #COLOR_PURPLE
	sty colpf2          ;purple glove and others ;these changes during line 141
	ldy 0

	sta grafp0

	stx colpf2

	;nop
	;nop
	lda #LEFT_BORDER+41
	sta hposm0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even ; <--
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$0F
	sta grafp1
	lda #LEFT_BORDER+57
	sta hposm1
	lda #$00
	sta sizep0
	lda #LEFT_BORDER+51
	sta hposp0
	;lda #$E8
	;sta grafp0
	;lda #LEFT_BORDER+41
	;sta hposm0

	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	lda #COLOR_GREY2
	sta colpf2

;before line 143
	lda #LEFT_BORDER+47
	sta hposp3          ;may be deferred 4 lines
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$01
	sta sizep0
	lda #LEFT_BORDER+41
	sta hposp0
	lda #LEFT_BORDER+98
	sta hposm0
	;lda #LEFT_BORDER+47
	;sta hposp3          ;may be deferred 4 lines

	ldx #COLOR_PURPLE
	lda #COLOR_GREY2
	stx colpf2          ;purple glove and others
	sta colpf2

;before line 144
	lda #$81
	sta grafp0
	lda #LEFT_BORDER+42
	sta hposp0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	;nop
	;nop
	;nop
	lda #(.hi(picLAdr))+4*6
	;sta wsync ;even ; <--
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$1E
	sta grafm
	lda #LEFT_BORDER+101
	sta hposm0
	lda #$00
	sta sizep0
	;lda #LEFT_BORDER+42
	;sta hposp0
	;lda #$81
	;sta grafp0

;before line 145
	nop
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	ldy #LEFT_BORDER+99
	sty hposm0
	;sta colbak ;odd
	;sta wsync ;odd ; <--
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+41
	sta hposp2
	lda #LEFT_BORDER+40
	sta hposp0
	lda #LEFT_BORDER+58
	sta hposm1
	;lda #LEFT_BORDER+99
	;sta hposm0

	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	nop
	nop
	lda #COLOR_GREY2
	sta colpf2

;before line 146
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$08
	sta grafp2
	lda #LEFT_BORDER+100
	sta hposm0
	lda #$41
	sta grafp0
	lda #LEFT_BORDER+40
	sta hposp2          ;may be deferred 1 line with data change

	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	ldy 0
	lda #COLOR_GREY2
	sta colpf2

;before line 147
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$F1
	sta sizem           ;M0 size 1, M1 size 0, M2 size 3, M3 size 3
	lda #LEFT_BORDER+53
	sta hposm0

	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	ldy 0
	lda #COLOR_GREY2
	sta colpf2

;before line 148
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$01
	sta grafp2
	lda #$02
	sta grafm
	lda #$46
	sta grafp0
	lda #LEFT_BORDER+61
	sta hposm2          ;may be deferred 1 line

	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	lda #COLOR_GREY2
	sta colpf2

;before line 149
	ldy #COLOR_PURPLE
 
	nop
	lda #LEFT_BORDER+58
	sta hposp1          ;may be deferred 3 lines
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+50
	sta hposm0
	lda #LEFT_BORDER+64
	sta hposm1          ;may be deferred 1 line
	lda #COLOR_YELLOW
	sta colpm1          ;may be deferred 1 line
	lda #$FD
	sta sizem           ;M1 size 3 may be deferred 2 lines, M0 size 1, M2 size 3, M3 size 3
	;lda #LEFT_BORDER+58
	;sta hposp1          ;may be deferred 3 lines

	sty colpf2          ;purple glove and others
	lda #COLOR_GREY2
	sta colpf2
	nop

;before line 150
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	;sta wsync ;even ; <--
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_PINK
	sta colpf1
	lda #COLOR_GREY1
	sta colpm3
	lda #$CC
	sta grafp3
	lda #$8A
	sta grafm
	lda #LEFT_BORDER+65
	sta hposm3
	lda #$48
	sta grafp0


;before line 151
	lda #COLOR_WHITE
	sta colpm1
	ldx #COLOR_GREY2
	lda #LEFT_BORDER+48
	sta hposm0

	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others ;these changes during line 150
	stx colpf2

	lda #LEFT_BORDER+47
	sta hposm3
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+52
	sta hposm1
	lda #COLOR_YELLOW
	sta colpm2
	lda #LEFT_BORDER+49
	sta hposp3
	;lda #LEFT_BORDER+47
	;sta hposm3
	;lda #COLOR_WHITE
	;sta colpm1
	;lda #LEFT_BORDER+48
	;sta hposm0

	nop
	nop
	lda #COLOR_PURPLE
	sta colpf2          ;purple glove and others
	lda #COLOR_GREY2
	sta colpf2

;before line 152
	lda #$50
	sta grafp0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$96
	sta grafm
	lda #$FF
	sta grafp1
	lda #COLOR_LBROWN
	sta colpm2
	;lda #$50
	;sta grafp0

;before line 153
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+41
	sta hposp2
	lda #LEFT_BORDER+65
	sta hposm0

	nop
	ldy 0
	ldx #COLOR_RED
	ldy #COLOR_GREY2
	lda #COLOR_PURPLE
	sta colpf3
	sta colpf2          ;purple glove and others
	stx colpf3
	sty colpf2

;before line 154
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$3E
	sta grafp3
	lda #$50
	sta grafp2
	lda #$01
	sta grafm
	;lda #$00
	;sta grafp1
	lda #LEFT_BORDER+96
	sta hposp1
	lda #COLOR_PURPLE
	sta colpm1

;before line 155
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+94
	sta hposp1

;before line 156
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_LBROWN
	sta colpf2
	lda #$02
	sta grafp0
	lda #$20
	sta grafp1

;before line 157
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+64
	sta hposm0          ;may be deferred 1 line
	lda #LEFT_BORDER+69
	sta hposp3          ;may be deferred
	lda #$03
	sta sizep3          ;may be deferred
	lda #COLOR_BROWN
	sta colpm3          ;may be deferred

;before line 158
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$01
	sta grafm
	lda #LEFT_BORDER+77
	sta hposp2          ;may be deferred
	lda #$00
	sta sizep2          ;may be deferred
	lda #COLOR_LBLUE
	sta colpm2          ;may be deferred

;before line 159
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+81
	sta hposm2          ;may be deferred
	;lda #LEFT_BORDER+81
	sta hposp1          ;may be deferred
	lda #COLOR_GREY1
	sta colpm1          ;may be deferred
	lda #LEFT_BORDER+95
	sta hposm1          ;may be deferred
	lda #$F1
	sta sizem           ;M1 size 0 may be deferred, M0 size 1, M2 size 3, M3 size 3

;before line 160
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$01
	sta grafm

;before line 161
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+38
	sta hposp0

;before line 162
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$00
	sta grafm
	lda #$62
	sta grafp0

;before line 163
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 164
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 165
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 166
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 167
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 168
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picLAdr))+4*7
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 169
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 170
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 171
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 172
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$0F
	sta grafp1

;before line 173
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+72
	sta hposp0          ;may be deferred
	lda #COLOR_GREY2
	sta colpm0          ;may be deferred

;before line 174
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$20
	sta grafp2

;before line 175
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+67
	sta hposp3
	lda #LEFT_BORDER+89
	sta hposp2

;before line 176
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #$02
	sta grafp1
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$C9
	sta grafp2
	lda #$38
	sta grafm
	lda #LEFT_BORDER+86
	sta hposp1
	;lda #$02
	;sta grafp1

;before line 177
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 178
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+69
	sta hposp3
	lda #$00
	sta grafm
	;lda #$00
	sta grafp2
	lda #$3C
	sta grafp0
	lda #$93
	sta grafp1
	lda #COLOR_LBLUE
	sta colpm1

;before line 179
	lda #COLOR_BROWN
	sta colpm2
	lda #$01
	sta sizep2
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREY1
	sta colpf3
	lda #LEFT_BORDER+71
	sta hposp3
	lda #COLOR_GREY1
	sta colpm3
	lda #$01
	sta sizep3

;before line 180
	nop
	nop
	lda #COLOR_LBROWN
	sta colpm1
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_GREY2
	sta colpf2
	lda #$70
	sta grafp3
	lda #$18
	sta grafp0
	lda #COLOR_WHITE
	sta colpm0
	lda #$10
	sta grafm
	lda #$28
	sta grafp1
	;lda #COLOR_LBROWN
	;sta colpm1

;before line 181
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 182
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$F8
	sta grafp3
	lda #$3F
	sta grafp0

;before line 183
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 184
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$FC
	sta grafp3
	lda #$3E
	sta grafp0

;before line 185
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 186
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$0C
	sta grafp0

;before line 187
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 188
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 189
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 190
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$08 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 191
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	lda #$84 ;odd
	ldx #$04 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	sta gtiactl ;odd
	stx gtiactl ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd


	;lda #$08 ;even
	;sta colbak ;even

	lda #$00
	sta anticLock
	lda dgfStability
	beq dlHL1
	lda mode
	cmp #$01   ;only left sub-picture
	beq dlHL2
	cmp #$05   ;tv interlace right sub-picture higher
	bne dlHL1
	lda #$0F
	sta anticLock
dlHL1
	lda #.lo(dliHndR)   ;setup DLI vector
	sta dliv
	lda #.hi(dliHndR)
	sta dliv+1
dlHL2

	jsr dliScroll

	lda anticLock
	cmp #$0F
	bne dlHL3
	sta wsync
	lda #COLOR_BLACK
	sta colpf1
	sta colpf2
	lda #$23+$1C
	sta dmactls
	sta dmactl      ;enable wide screen and PMG DMA
dlHL3

	pla
	tay
	pla
	tax
	pla
	rti

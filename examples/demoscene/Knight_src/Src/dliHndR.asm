

dliHndR
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
	lda #.lo(tileMapRAdr)
	sta tileMapPtr
	lda #.hi(tileMapRAdr)
	sta tileMapPtr+1
	lda #.hi(pmRAdr)
	sta pmbase
	;lda #.hi(picRAdr)
	lda #.hi(STD_CHARS_DEF_ADR)
	sta chbase

	ldx #COLOR_GREY3
	lda blinkingCnt
	and #$20
	beq dliHndR1
	ldx #COLOR_WHITE
dliHndR1
	stx colpf1
	lda #COLOR_GREY3
	sta colpf2

;before empty text line

;before empty line 0
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;;lda #$00 ;even
	;;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$22+$1C
	sta dmactls
	sta dmactl      ;enable screen and PMG DMA

;before empty line 1
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$04
	sta gtiactl
	lda #COLOR_GREY3
	sta colbak
	lda #COLOR_BLACK
	sta colpf0
	lda #COLOR_PINK
	sta colpf3

;before empty line 2
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$C0+$30+$0+$0
	sta sizem           ;M3 size 3, M2 size 3, M1 size 0, M0 size 0
	lda #$00
	sta sizep3
	lda #COLOR_WHITE
	sta colpm3
	lda #LEFT_BORDER+72
	sta hposm3
	lda #LEFT_BORDER+43
	sta hposp3

;before empty line 3
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+66
	sta hposp2          ;may be deferred
	lda #$00
	sta sizep2          ;may be deferred
	lda #LEFT_BORDER+81
	sta hposm2          ;may be deferred
	lda #COLOR_YELLOW
	sta colpm2          ;may be deferred

;before empty line 4
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+66
	sta hposp1          ;may be deferred
	lda #LEFT_BORDER+66
	sta hposm1          ;may be deferred
	lda #$00
	sta sizep1          ;may be deferred
	lda #COLOR_LBROWN
	sta colpm1          ;may be deferred

;before empty line 5
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+81
	sta hposp0          ;may be deferred
	lda #LEFT_BORDER+74
	sta hposm0          ;may be deferred
	lda #$00
	sta sizep0          ;may be deferred
	lda #COLOR_PINK
	sta colpm0          ;may be deferred

;before empty line 6
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #.hi(picRAdr)
	sta chbase
	lda #COLOR_GREY1
	sta colpf1
	lda #COLOR_GREY2
	sta colpf2

;before line 1
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 2
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 4
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 6
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 8
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 10
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 12
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 13
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 14
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 16
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 17
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 18
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 21
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 23
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*1
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 25
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+73
	sta hposm3

;before line 26
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 27
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+72
	sta hposp3
	lda #$00+$30+$0+$0
	sta sizem           ;M3 size 0, continued: M2 size 3, M1 size 0, M0 size 0
	lda #LEFT_BORDER+50
	sta hposm3

;before line 28
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+52
	sta hposp3          ;may be deferred

;before line 29
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+69
	sta hposm3          ;may be deferred

;before line 30
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+74
	sta hposp2

;before line 31
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+72
	sta hposp1

;before line 32
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 33
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposm3          ;may be deferred

;before line 34
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 35
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+80
	sta hposm2          ;may be deferred 2 lines

;before line 37
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+95
	sta hposm3          ;may be deferred
	lda #$C0+$30+$0+$0
	sta sizem           ;M3 size 3 may be deferred, continued: M2 size 3, M1 size 0, M0 size 0

;before line 38
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+63
	sta hposp2
	lda #$01
	sta sizep2          ;may be deferred 1 line but data change required

;before line 39
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREEN
	sta colpf3
	sta colpm0
	lda #LEFT_BORDER+73
	sta hposp1
	lda #LEFT_BORDER+60
	sta hposp3         ;may be deferred

;before line 40
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp2
	lda #LEFT_BORDER+71
	sta hposm1
	lda #COLOR_PINK
	sta colpm0

;before line 41
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+65
	sta hposp2

;before line 42
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+68
	sta hposp1
	lda #LEFT_BORDER+78
	sta hposm1

;before line 43
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+64
	sta hposp1
	lda #LEFT_BORDER+81
	sta hposm1

;before line 44
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+82
	sta hposm1         ;may be deferred

;before line 45
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+77
	sta hposp3         ;may be deferred

;before line 46
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 47
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 48
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*2
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+66
	sta hposp2
	lda #LEFT_BORDER+78
	sta hposp1
	lda #COLOR_GREEN
	sta colpm0

;before line 49
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+69
	sta hposp1

;before line 50
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposm0         ;may be deferred

;before line 51
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+76
	sta hposp1         ;may be deferred 3 lines

;before line 52
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+67
	sta hposp3
	lda #LEFT_BORDER+81
	sta hposm1         ;may be deferred 2 lines
	lda #$C0+$30+$4+$0
	sta sizem          ;M1 size 1 may be deferred 2 lines, continued: M3 size 3, M2 size 3, M0 size 0

;before line 53
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 54
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 55
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	sta hposm2

;before line 57
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+48
	sta hposp3          ;may be deferred
	lda #$03
	sta sizep3          ;may be deferred

;before line 58
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp2
	lda #$03
	sta sizep2
	lda #COLOR_LBROWN
	sta colpm0

;before line 59
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+61
	sta hposp2
	lda #LEFT_BORDER+65
	sta hposp1
	sta hposp0
	lda #$01
	sta sizep1

;before line 60
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+59
	sta hposp2
	lda #LEFT_BORDER+85
	sta hposm2
	lda #$00
	sta sizep1

;before line 61
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+59
	sta hposp1
	lda #LEFT_BORDER+72
	sta hposm1
	lda #COLOR_GREEN
	sta colpm0

;before line 62
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+61
	sta hposp2
	lda #$C0+$00+$0+$0
	sta sizem           ;M2 size 0, M1 size 0, continued: M3 size 3, M0 size 0
	lda #LEFT_BORDER+97
	sta hposm3          ;may be deferred 1 line

;before line 63
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+60
	sta hposp2
	lda #LEFT_BORDER+85
	sta hposm1          ;may be deferred 2 lines

;before line 64
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	lda #LEFT_BORDER+71
	sta hposp0

;before line 65
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+59
	sta hposp2          ;may be deferred 3 lines
	lda #LEFT_BORDER+77
	sta hposp1
	lda #LEFT_BORDER+33
	sta hposm2          ;may be deferred

;before line 66
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+86
	sta hposm1          ;may be deferred

;before line 67
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 69
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+61
	sta hposp2          ;may be deferred 5 lines

;before line 70
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+48
	sta hposm3          ;may be deferred

;before line 71
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 72
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*3
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+76
	sta hposp0
	lda #LEFT_BORDER+63
	sta hposp1
	lda #COLOR_PURPLE
	sta colpm1

;before line 73
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 74
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp1
	lda #COLOR_LBROWN
	sta colpm1

;before line 75
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+70
	sta hposp1          ;may be deferred
	lda #$03
	sta sizep1          ;may be deferred

;before line 76
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+65
	sta hposp3

;before line 78
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+81
	sta hposp0          ;may be deferred 2 lines

;before line 79
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 80
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+43
	sta hposp2          ;may be deferred

;before line 81
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+69
	sta hposp3
	lda #COLOR_PURPLE
	sta colpm1          ;may be deferred

;before line 82
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 83
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+42
	sta hposp0         ;may be deferred

;before line 84
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+70
	sta hposp3

;before line 85
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 86
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+96
	sta hposm3
	lda #$00+$00+$0+$0
	sta sizem           ;M3 size 0, continued: M2 size 0, M1 size 0, M0 size 0
	lda #LEFT_BORDER+46
	sta hposp3

;before line 88
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 89
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+118
	sta hposm3
	lda #$C0+$00+$C+$0
	sta sizem           ;M3 size 3, M1 size 3, continued: M2 size 0, M0 size 0, M1 size 3 may be deferred

;before line 91
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_BLUE
	sta colpm1          ;may be deferred 1 line

;before line 94
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+102
	sta hposm1          ;may be deferred

;before line 95
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+66
	sta hposp3          ;may be deferred

;before line 96
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*4
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 98
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp1          ;may be deferred

;before line 99
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_LBROWN
	sta colpm1          ;may be deferred

;before line 100
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 101
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	lda #LEFT_BORDER+104
	sta hposp2          ;may be deferred
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 102
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 103
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	sta hposp0          ;may be deferred

;before line 105
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 106
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 107
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 108
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_BROWN
	sta colpm0
	lda #LEFT_BORDER+46
	sta hposm0          ;may be deferred

;before line 109
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_LBROWN
	sta colpm2          ;may be deferred
	lda #LEFT_BORDER+38
	sta hposp2          ;may be deferred
	lda #$03
	sta sizep2          ;may be deferred

;before line 110
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta colpm0
	lda #COLOR_BROWN
	sta colpm1          ;may be deferred

;before line 111
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$C0+$00+$0+$3
	sta sizem           ;M1 size 0, M0 size 3, continued: M3 size 3, M2 size 0, M1 size 0 may be deferred, M0 size 3 may be deferred
	lda #LEFT_BORDER+49
	sta hposm1          ;may be deferred

;before line 112
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp0          ;may be deferred 4 lines

;before line 113
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 114
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 115
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 116
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 117
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposp3          ;may be deferred
	lda #LEFT_BORDER+33
	sta hposp0          ;may be deferred 1 line


;before line 118
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	lda #LEFT_BORDER+54
	sta hposp1
	lda #$00
	sta sizep1
	lda #COLOR_PURPLE
	sta colpm0

;before line 119
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+60
	sta hposp1
	lda #LEFT_BORDER+41
	sta hposm0
	lda #LEFT_BORDER+104
	sta hposm3          ;may be deferred

;before line 120
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*5
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #$C0+$00+$C+$0
	sta sizem           ;M1 size 3, M0 size 0, continued: M3 size 3, M2 size 0
	;lda #LEFT_BORDER+49
	;sta hposm1          ;may be deferred

;before line 121
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$01
	sta sizep1
	lda #LEFT_BORDER+45
	sta hposm1

;before line 122
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_YELLOW
	sta colpm0
	lda #LEFT_BORDER+100
	sta hposm0
	lda #LEFT_BORDER+34
	sta hposp3          ;may be deferred 1 line
	lda #$00
	sta sizep3          ;may be deferred 1 line

;before line 123
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposm1
	lda #LEFT_BORDER+46
	sta hposp1
	lda #$00
	sta sizep1
	lda #COLOR_PURPLE
	sta colpm3

;before line 124
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+67
	sta hposm1

;before line 125
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+34
	sta hposp0
	lda #$01
	sta sizep0
	lda #LEFT_BORDER+66
	sta hposm1
	lda #COLOR_YELLOW
	sta colpm3

;before line 126
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+35
	sta hposm2
	;lda #LEFT_BORDER+35
	sta hposp0
	lda #LEFT_BORDER+65
	sta hposm1
	lda #LEFT_BORDER+48
	sta hposp1
	lda #$01
	sta sizep3          ;may be deferred 2 lines
	lda #COLOR_WHITE
	sta colpm3          ;may be deferred 2 lines

;before line 127
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+37
	sta hposm2
	lda #LEFT_BORDER+41
	sta hposp0
	lda #$00
	sta sizep0
	lda #LEFT_BORDER+63
	sta hposm1

;before line 128
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposm1
	lda #LEFT_BORDER+49
	sta hposp1
	lda #LEFT_BORDER+39
	sta hposp2

;before line 129
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_LBROWN
	sta colpm1
	lda #COLOR_BROWN
	sta colpm2
	lda #LEFT_BORDER+57
	sta hposm1
	lda #$C0+$00+$4+$0
	sta sizem           ;M1 size 1, continued: M3 size 3, M2 size 0, M0 size 0, may be deferred 1 line

;before line 130
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+40
	sta hposp2
	lda #LEFT_BORDER+65
	sta hposm2          ;may be deferred

;before line 131
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+48
	sta hposp0
	;lda #LEFT_BORDER+48
	sta hposp1
	lda #LEFT_BORDER+56
	sta hposm1
	lda #LEFT_BORDER+38
	sta hposp2

	ldy #COLOR_PURPLE

;before line 132
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta colpm0
	lda #COLOR_YELLOW
	sta colpm1
	lda #$C0+$00+$0+$1
	sta sizem           ;M0 size 1, M1 size 0, continued: M3 size 3, M2 size 0
	lda #LEFT_BORDER+56
	sta hposm0

	;lda #COLOR_PURPLE
	lda 0
	ldx #COLOR_GREY2
	sty colpf2
	stx colpf2

	lda #LEFT_BORDER+97
	sta hposm1          ;may be deferred 1 line
	lda #LEFT_BORDER+41
	sta hposp1          ;may be deferred 2 lines
	

;before line 133
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+51
	sta hposp0
	lda #LEFT_BORDER+46
	sta hposm0          ;may be deferred 2 lines

	lda 0
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	ldx #COLOR_GREY2
	sta colpf2
	stx colpf2

;before line 134
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+54
	sta hposp0
	lda #$00+$00+$C+$1
	sta sizem           ;M3 size 0, M1 size 3, continued: M2 size 0, M0 size 1, M1 size 3 may be deferred 1 line, M3 size 0 may be deferred 1 line

	lda 0
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	ldx #COLOR_GREY2
	sta colpf2
	stx colpf2

;before line 135
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+52
	sta hposp0

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy #COLOR_YELLOW
	lda #COLOR_PURPLE
	ldx #COLOR_GREY2
	sta colpf2
	sty colpm3
	stx colpf2
	lda #COLOR_WHITE
	sta colpm3

;before line 136
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+41
	sta hposm3          ;may be deferred

;before line 137
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+40
	sta hposp2
	lda #LEFT_BORDER+41
	sta hposm0          ;may be deferred 2 lines
	lda #LEFT_BORDER+95
	sta hposm2          ;may be deferred 1 line

	nop
	nop
	nop
	lda #COLOR_PURPLE
	ldx #COLOR_RED
	sta colpf3
	nop
	nop
	stx colpf3

;before line 138
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

	;lda 0
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
	lda #COLOR_PURPLE
	ldy #COLOR_BROWN
	ldx #COLOR_RED
	sta colpf3
	sta colpm2
	stx colpf3	
	sty colpm2

;before line 139
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+56
	sta hposp0
	lda #LEFT_BORDER+99
	sta hposm1

	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	ldy #COLOR_BROWN
	ldx #COLOR_RED
	sta colpf3
	sta colpm2
	stx colpf3	
	sty colpm2

;before line 140
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+97
	sta hposm1
	lda #LEFT_BORDER+94
	sta hposm2          ;may be deferred

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 141
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #$01
	sta sizep1
	lda #LEFT_BORDER+40
	sta hposp1          ;may be deferred 1 line
	lda #LEFT_BORDER+99
	sta hposm1          ;may be deferred 1 line
	lda #COLOR_YELLOW
	sta colpm3          ;may be deferred

	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 142
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+51
	sta hposm0
	lda #LEFT_BORDER+55
	sta hposp0          ;may be deferred 1 line
	lda #LEFT_BORDER+44
	sta hposp3          ;may be deferred

	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 143
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+100
	sta hposm1          ;may be deferred 1 line

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
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 144
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*6
	sta wsync ;even
	sta chbase
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+50
	sta hposm0

;before line 145
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+46
	sta hposm0          ;may be deferred 3 lines

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
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	nop
	sta colpf3	

;before line 146
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+66
	sta hposm1          ;may be deferred
	lda #$00+$10+$0+$1
	sta sizem           ;M2 size 1, M1 size 0, continued: M3 size 0, M0 size 1, M2 size 1 may be deferred, M1 size 0 may be deferred
	lda #COLOR_WHITE
	sta colpm1          ;may be deferred 1 line

	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	nop
	sta colpf3	

;before line 147
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

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
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	nop
	sta colpf3	

;before line 148
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+41
	sta hposp2

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
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 149
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+66
	sta hposm0          ;may be deferred 1 line
	lda #LEFT_BORDER+46
	sta hposp0
	lda #$03
	sta sizep3

	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpf3
	lda #COLOR_RED
	nop
	sta colpf3	

;before line 150
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #COLOR_PINK
	sta colpf1
	lda #LEFT_BORDER+44
	sta hposp0
	lda #COLOR_GREY1
	sta colpm2

	nop
	nop
	nop
	nop
	ldx #COLOR_GREY1
	ldy #COLOR_GREY3
	lda #COLOR_PURPLE
	sta colpm2
	lda #COLOR_RED
	sta colbak
	stx colpm2
	sty colbak

	ldx #COLOR_PURPLE
	ldy #COLOR_RED

;before line 151
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
;	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+49
	sta hposp3
	lda #$01
	sta sizep3
	lda #COLOR_WHITE
	sta colpm3
	lda #COLOR_YELLOW
	sta colpm1
	lda #LEFT_BORDER+41
	sta hposp1
	lda #LEFT_BORDER+68
	sta hposm3

	stx colpm3
	nop
	nop
	sty colbak
	lda #COLOR_WHITE
	sta colpm3
	lda #COLOR_GREY3
	sta colbak

;before line 152
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta sizep2
	lda #LEFT_BORDER+52
	sta hposp2
	lda #LEFT_BORDER+62
	sta hposm2

;before line 153
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+40
	sta hposp0
	lda #$00
	sta sizep1
	lda #LEFT_BORDER+48
	sta hposp3
	lda #LEFT_BORDER+94
	sta hposm3

	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpm3
	lda #COLOR_WHITE
	sta colpm3

;before line 154
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	sta hposp2
	lda #$40+$00+$0+$0
	sta sizem           ;M3 size 1, M2 size 0, M0 size 0, continued: M1 size 0, M0 size 0 may be deferred, M2 size 0 may be deferred
	lda #LEFT_BORDER+38
	sta hposm0

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpm3
	lda #COLOR_WHITE
	sta colpm3

;before line 155
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+95
	sta hposm3
	lda #LEFT_BORDER+67
	sta hposp3          ;may be deferred
	lda #$03
	sta sizep3          ;may be deferred

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda #COLOR_PURPLE
	sta colpm3
	lda #COLOR_WHITE
	sta colpm3

;before line 156
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+83
	sta hposp0          ;may be deferred
	lda #COLOR_BROWN
	sta colpm3

;before line 157
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_LBROWN
	sta colpf2
	lda #LEFT_BORDER+78
	sta hposp2          ;may be deferred
	lda #LEFT_BORDER+95
	sta hposm2          ;may be deferred
	lda #COLOR_LBLUE
	sta colpm2          ;may be deferred

;before line 158
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+38
	sta hposp1
	lda #$01
	sta sizep2          ;may be deferred

;before line 159
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 160
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 161
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd

;before line 162
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 163
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	lda #(.hi(picRAdr))+4*7
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREY1
	sta colpm0
	lda #LEFT_BORDER+78
	sta hposm0          ;may be deferred 2 lines

;before line 172
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 173
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREY2
	sta colpm1          ;may be deferred 5 lines
	lda #LEFT_BORDER+72
	sta hposp1          ;may be deferred 5 lines

;before line 174
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+81
	sta hposp0
	lda #LEFT_BORDER+95
	sta hposm0          ;may be deferred 1 line

;before line 175
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+85
	sta hposp0
	lda #LEFT_BORDER+77
	sta hposp2

;before line 176
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+78
	sta hposp2
	lda #LEFT_BORDER+50
	sta hposm0          ;may be deferred 4 lines
	lda #$40+$00+$0+$1
	sta sizem           ;M0 size 1, continued: M3 size 1, M2 size 0, M1 size 0, M0 size 1 may be deferred 4 lines

;before line 177
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+68
	sta hposp3

;before line 178
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even
	lda #LEFT_BORDER+74
	sta hposp0

;before line 179
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #COLOR_GREY1
	sta colpf3
	lda #LEFT_BORDER+69
	sta hposp3
	lda #LEFT_BORDER+92
	sta hposm2
	lda #LEFT_BORDER+71
	sta hposp2

;before line 180
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
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
	lda #LEFT_BORDER+67
	sta hposp3
	lda #COLOR_WHITE
	sta colpm1
	lda #COLOR_GREY1
	sta colpm2
	lda #COLOR_RED
	sta colpm0

;before line 181
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd
	lda #LEFT_BORDER+80
	sta hposm2

;before line 182
	;cmd0 ;even
	;cmd1 ;even
	;cmd2 ;even
	;cmd3 ;even
	;cmd4 ;even
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 183
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 185
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
	;ldx #$00 ;even
	;sta colbak ;even
	sta wsync ;even
	;stx colbak ;even
	;cmd5 ;even
	;cmd6 ;even
	;cmd7 ;even
	;cmd8 ;even
	;cmd9 ;even

;before line 187
	;cmd0 ;odd
	;cmd1 ;odd
	;cmd2 ;odd
	;cmd3 ;odd
	;cmd4 ;odd
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;stx colbak ;odd
	;cmd5 ;odd
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
	;lda #$00 ;even
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
	;lda #$00 ;odd
	;ldx #$08 ;odd
	;sta colbak ;odd
	sta wsync ;odd
	;;stx colbak ;odd
	;cmd5 ;odd
	;cmd6 ;odd
	;cmd7 ;odd
	;cmd8 ;odd
	;cmd9 ;odd


	lda #$00
	sta anticLock
	lda dgfStability
	beq dlHR2
	lda mode
	cmp #$02   ;only right sub-picture
	beq dlHR2
	cmp #$04   ;tv interlace left sub-picture higher
	bne dlHR1
	lda #$0F
	sta anticLock
dlHR1
	lda #.lo(dliHndL)   ;setup DLI vector
	sta dliv
	lda #.hi(dliHndL)
	sta dliv+1
dlHR2

	jsr dliScroll

	lda anticLock
	cmp #$0F
	bne dlHR3
	sta wsync
	lda #COLOR_BLACK
	sta colpf1
	sta colpf2
	lda #$23+$1C
	sta dmactls
	sta dmactl      ;enable wide screen and PMG DMA
dlHR3

	pla
	tay
	pla
	tax
	pla
	rti

// https://forums.atariage.com/topic/165509-overcoming-the-scanline-240-bug/#comment-2044499

;
; Defeat the Scanline 240 bug
;
sdslst	= $230
sdmctl	= $22f
wsync	= $d40a
nmien	= $d40e
dmactl	= $d400
;
	org $4000
;

main
	ldx 20
	inx
wait1
	cpx 20
	bne wait1
	lda #<dlist
	ldx #>dlist
	sta sdslst
	stx sdslst+1
	lda #<dli1
	ldx #>dli1
	sta $200
	stx $201
	lda #<vbi
	ldx #>vbi
	sta $222
	stx $223
	lda #$20
	sta sdmctl
	lda #$c0
	sta nmien
	ldx #3
setcols
	lda colour_table,x
	sta $2c5,x
	dex
	bpl setcols
wait2
	jmp wait2

vbi
	lda #<dli1
	ldx #>dli1
	sta $200
	stx $201
	jmp $e45f

;

dli1
	pha
	lda sdmctl
	ora #2
	sta dmactl
	lda #<dli2
	sta $200
	lda #>dli2
	sta $201
	pla
	rti

dli2
	pha
	lda sdmctl
	and #$fc
	sta wsync
	sta dmactl
	pla
	rti

colour_table
	.byte $ca,$82,$48,$32
;
dlist
	.byte $f0
	.byte $42
	.word screen1
	.byte 2,2,2,2,2
	.byte 2,2,2,2,2
	.byte 2,2,2,2,2
	.byte 2,2,2,2,2
	.byte 2,2,2,2,2
	.byte 2
	.byte 2,$82,$41
	.word dlist

screen1
	.sb "                                        " ; 1
	.sb "                                        " ; 2
	.sb " How to defeat the Scanline 240 bug     " ; 3
	.sb " Method 1                               " ; 4
	.sb "                                        " ; 5
	.sb " This method uses a DLI at the top of   " ; 6
	.sb " screen and bottom of screen.           " ; 7
	.sb " The advantage is we use less CPU.      " ; 8
	.sb " But the disadvantage is that we lose   " ; 9
	.sb " The top scanline of the display, which " ; 10
	.sb " sort of defeats the purpose.           " ; 11
	.sb "                                        " ; 12
	.sb " Note that the blank 8 lines above      " ; 13
	.sb " are just filler in this example.  ANTIC" ; 14
	.sb " won't run a DLI on a text line that is " ; 15
	.sb " truncated by the last scanline, but    " ; 16
	.sb " that problem could be overcome by      " ; 17
	.sb " generating a shortened character line  " ; 18
	.sb " by using V-Scrolling.                  " ; 19
	.sb "                                        " ; 20
	.sb "                                        " ; 21
	.sb "                                        " ; 22
	.sb "                                        " ; 23
	.sb "                                        " ; 24
	.sb "                                        " ; 25
	.sb "                                        " ; 26
	.sb "                                        " ; 27
	.sb "                                        " ; 28
	.sb " Last visible line of the display here. " ; 29

	run  main

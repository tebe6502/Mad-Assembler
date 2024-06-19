;The main code starts here (see demomain.asm).

	;wait for new screen frame
	lda rtclock+2
	cmp rtclock+2
	beq *-2
	;lda #$4F
	;cmp vcount
	;bcs *-3
	;cmp vcount
	;bcc *-3

	;save original vblki vector
	lda	vvblki
	sta tmpVvblki
	lda	vvblki+1
	sta tmpVvblki+1
	;set new vblki vector
	lda #6
	ldx #.hi(vBlkInt)
	ldy #.lo(vBlkInt)
	jsr setvbv

	lda #1
	sta critic      ;delayed part of system VBLK handler will be off

	lda #$00
	sta nmien       ;disable all NMI
	sta nmires

	sei ;turn off all IRQ

	lda #$00
	sta dmactls
	sta dmactl      ;disable screen dma

	;save original dli vector
	lda	dliv
	sta tmpDliv
	lda	dliv+1
	sta tmpDliv+1
	;set new dli vector
	lda #.lo(dliHndR)   ;setup DLI vector
	sta dliv
	lda #.hi(dliHndR)
	sta dliv+1

	lda #.lo(dList)  ;setup Display List vector
	sta dlptrs
	sta dlptr
	lda #.hi(dList)
	sta dlptrs+1
	sta dlptr+1

	lda #$C0
	sta nmien       ;enable VBLKI and DLI
	lda #$22+$1C
	sta dmactls
	sta dmactl      ;enable screen and PMG DMA
	lda #$03
	sta pmctl       ;enable PMG DMA in GTIA
	lda #$00
	sta vdelay
	sta colpm0s ; 704
	sta colpm1s ; 705
	sta colpm2s ; 706
	sta colpm3s ; 707
	sta colpf0s ; 708
	sta colpf1s ; 709
	sta colpf2s ; 710
	sta colpf3s ; 711
	sta colbaks ; 712
	lda #$04
	sta gtiactls
	;cli

	lda #$00
	sta quit
	sta stopScroll

	lda #$01
	sta scrShft
	sta frameStability
	sta dgfStability
	sta dgfStabilityPrev

	lda #$03
	sta mode

	jsr reinitScroll

loop
	lda quit
	beq loop

;quit program

	;restore original vblki vector
	lda #6
	ldx tmpVvblki+1
	ldy tmpVvblki
	jsr setvbv

	lda #0
	sta critic

	lda #$40
	sta nmien       ;enable VBLKI only
	lda #$22
	sta dmactls
	sta dmactl      ;enable screen only
	lda #$00
	sta pmctl       ;disable PMG DMA in GTIA

	lda #.lo(dListEmpty)  ;setup Display List vector for empty screen
	sta dlptrs
	sta dlptr
	lda #.hi(dListEmpty)
	sta dlptrs+1
	sta dlptr+1

	;restore original dli vector
	lda tmpDliv
	sta dliv
	lda tmpDliv+1
	sta dliv+1

	lda #$00
	sta colbaks
	sta colbak

	cli ;turn on all IRQ

	lda #$FF
	sta kbcodes

	jsr reopenSysScreen

	lda #$00
	tax
	tay

	;rts ;quit to OS/DOS
	jmp (dosvec)


reopenSysScreen
	ldx #$00
	lda #$0C
	jsr ropnSyScr1
	ldx #$00
	lda #.lo(screenDev)
	sta ICBAL,x ;$0344,X
	lda #.hi(screenDev)
	sta ICBAH,x ;$0345,X
	;lda #$03
	;sta ICBLL,x ;$0348,X
	lda #$0C
	sta ICAX1,x ;$034A,X
	lda #$00
	sta ICAX2,x ;$034B,X
	;sta ICBLH,x ;$0349,X
	lda #$03
ropnSyScr1
	sta ICCOM,x ;$0342,X
	jmp ciov ;$E456

screenDev
	dta c "E:", $9B


quit		.by 0 ;1 - signal to quit the program
mode		.by 3 ;1 - left sub-pic, 2 - right sub-pic, 3 - interlaced,
				 ;4 - x interlace - left sub-picture higher, 5 - x interlace - right sub-picture higher
scrShft		.by 1 ;current shift of scroll
stopScroll	.by 0 ;0 - scroll runs normally, 1 - scroll stopped

frameStability		.by 1 ;stability of left sub-picture within one frame, 1 = stable
dgfStability		.by 1 ;DGF stability, 1 = stable, 0 = not stable
dgfStabilityPrev 	.by 1
blinkingCnt			.by 0

tmpVvblki	.wo 0
tmpDliv		.wo 0


vBlkInt
	;pha
	;txa
	;pha
	;tya
	;pha

	jsr handleKeyboard
	jsr handleScroll
	jsr handleTvInterlace
	lda frameStability
	sta dgfStability
	jsr handleStabilityChange

	inc blinkingCnt

	lda #$00
	sta atract

	;pla
	;tay
	;pla
	;tax
	;pla
	;rti
	jmp sysvbv



scrDatPtr = gpPointer1

scroll
	ldx #11
	ldy #0
scrl1
	lda (scrDatPtr),Y
	sta scrollMem,Y
	iny
	lda (scrDatPtr),Y
	sta scrollMem,Y
	iny
	lda (scrDatPtr),Y
	sta scrollMem,Y
	iny
	lda (scrDatPtr),Y
	sta scrollMem,Y
	iny
	dex
	bne scrl1
	rts

handleScroll
	lda stopScroll
	bne hndScrl4
	ldx scrShft
	dex
	txa
	and #$03
	sta scrShft
	eor #$03
	bne hndScrl3
	lda scrDatPtr+1
hndScrlDataLastHi = *+1
	cmp #.hi(scrollDataLast)
	bne hndScrl1
	lda scrDatPtr
hndScrlDataLastLo = *+1
	cmp #.lo(scrollDataLast)
	bcc hndScrl1
reinitScrollInt
	;set scroll data pointer to beginning
hndScrlDataLo = *+1
	lda #.lo(scrollData)
	sta scrDatPtr
hndScrlDataHi = *+1
	lda #.hi(scrollData)
	sta scrDatPtr+1
	jmp hndScrl2
hndScrl1
	;increment scroll data pointer by 1
	lda scrDatPtr
	clc
	adc #1
	sta scrDatPtr
	lda scrDatPtr+1
	adc #0
	sta scrDatPtr+1
hndScrl2
	jsr scroll
hndScrl3
	lda scrShft
	sta hscrol
hndScrl4
	rts

reinitScroll
	;init scroll data pointers in code (dependent on dgf stability we have different content)
	;set scroll data pointer to beginning
	lda dgfStability
	beq reinitScr1
	lda #.lo(scrollData)
	sta hndScrlDataLo
	lda #.hi(scrollData)
	sta hndScrlDataHi
	lda #.lo(scrollDataLast)
	sta hndScrlDataLastLo
	lda #.hi(scrollDataLast)
	sta hndScrlDataLastHi
	jmp reinitScrollInt
reinitScr1
	lda #.lo(scrollNotReadyData)
	sta hndScrlDataLo
	lda #.hi(scrollNotReadyData)
	sta hndScrlDataHi
	lda #.lo(scrollNotReadyDataLast)
	sta hndScrlDataLastLo
	lda #.hi(scrollNotReadyDataLast)
	sta hndScrlDataLastHi
	jmp reinitScrollInt


handleStabilityChange
	lda dgfStability		;1 = stable, 0 = not stable
	beq hndStbChg1
	;reload dlptr always when dlist for stable dgf is used - this dlist contains 240 scanlines so jvb is ignored
	;actually, the above is not a reason any longer as we switched to use system VBLK handling (and dlptr is set every frame anyway)
	lda #.lo(dList)
	sta dlptrs
	sta dlptr
	lda #.hi(dList)
	sta dlptrs+1
	sta dlptr+1
	lda dgfStabilityPrev
	bne hndStbChg3
	;lda #.lo(dList)
	;sta dlptrs
	;sta dlptr
	;lda #.hi(dList)
	;sta dlptrs+1
	;sta dlptr+1
	jmp hndStbChg2
hndStbChg1
	lda dgfStabilityPrev
	beq hndStbChg3
	lda #.lo(dListNotReady)
	sta dlptrs
	sta dlptr
	lda #.hi(dListNotReady)
	sta dlptrs+1
	sta dlptr+1
	lda #.lo(dliHndR)   ;setup DLI vector to right sub-picture DLI handler
	sta dliv
	lda #.hi(dliHndR)
	sta dliv+1
hndStbChg2
	jsr reinitScroll
	lda dgfStability
	sta dgfStabilityPrev
hndStbChg3
	rts


handleTvInterlace
	lda anticLock
	cmp #$0F
	bne hndTvIntl1
	jsr tvField2VSync
	;lda #$23+$1C  ;this works allowing for PMG visible on high border
	lda #$20+$1C
	sta dmactls
	sta dmactl      ;enable wide screen and PMG DMA
	;lda #COLOR_BLACK ;not needed as it is
	;sta colpf1       ;done by tvField2VSync
	;sta colpf2       ;and also only needed when dmactl = $23 + X
	lda #COLOR_GREY3
	sta colbak
hndTvIntl1
	rts


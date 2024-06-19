 icl "system.inc"
 icl "demo.inc"

 org startAdr

 ;The initial checks start here.
 ;This code is executed before loading main part of XEX into memory and stops loading in case any test fails.

	jsr checkMem
	beq chk1
	jsr wait3Sec
	jmp quitDos
chk1
	rts

wait3Sec
	ldx #150
wait3Sec1
	lda rtclock+2
wait3Sec2
	cmp rtclock+2
	beq wait3Sec2
	dex
	bne wait3Sec1
	rts

outputText
	pha
	lda #$00
	sta ICBLH ;$0349
	pla
outputLongText
	sty ICBAL ;$0344
	stx ICBAH ;$0345
	sta ICBLL ;$0348
	ldx #$00
	lda #$0B
	sta ICCOM,x ;$0342,X
	jmp ciov ;$E456

quitDos
	jsr closeIOChns
	jmp (dosvec)

;close all IOCBs except 0
closeIOChns
	ldx	#0
	beq	closeIOChns2
closeIOChns1
	lda #$0C
	sta ICCOM,x ;$0342,X
	jsr CIOV ;$E456
closeIOChns2
	txa
	clc
	adc #$10
	tax
	bpl closeIOChns1
	rts

insufMem
	dta c "Insufficient memory! Required 48K RAM", $9B
insufMemEnd

remCart
	dta c "Remove cartridge. Turn off Basic.", $9B
remCartEnd

insufMemLen = insufMemEnd - insufMem
remCartLen = remCartEnd - remCart

memCheckCnt	dta 0 ;number of test try 0-1; basic absence is checked twice as DOS may restore Basic if we turn it off

checkMem
memTestAdr  = $BFFE ;cell within cartridge A/Basic
memTestAdrB = $9FFE ;cell within cartridge B
	lda memCheckCnt
	bne checkBas	;if it is a second try then check Basic only as DOS may have restored it after we turned it off
	;check if RAM available for OS is at least 32K (ignore both cartridges at the moment)
	lda ramtop
	cmp #$80	;check if 32K RAM available in OS (ignore both cartridges)
	bcc chkm2
	;check presence of RAM or ROM within cartridge B area (does not detect absence of memory on emulators but is required by cardridge absence test on real machine)
	ldy #$00
chkm0
	lda memTestAdrB
	cmp memTestAdrB
	bne chkm2
	dey
	bne chkm0
	;check absence of cartridge B
	lda memTestAdrB
	inc memTestAdrB
	cmp memTestAdrB
	beq chkm3
	sta memTestAdrB
	;check if RAM available for OS is at least 40K (ignore Basic at the moment)
	lda ramtop
	;cmp #$C0	;check if 48K RAM available in OS
	cmp #$A0	;check if 40K RAM available in OS (ignore Basic)
	bcc chkm2
	;check presence of RAM or ROM within cartridge A area (does not detect absence of memory on emulators but is required by cardridge absence test on real machine)
	ldy #$00
chkm1
	lda memTestAdr
	cmp memTestAdr
	bne chkm2
	dey
	bne chkm1
checkBas
	;check absence of cartridge A/Basic
	lda memTestAdr
	inc memTestAdr
	cmp memTestAdr
	beq chkm5	;cartridge A/Basic present
	sta memTestAdr
	bne chkm6	;all tests ok
chkm2
	;show message "INSUFFICIENT MEMORY! REQUIRED 48K OF RAM"
	ldy #.lo(insufMem)
	ldx #.hi(insufMem)
	lda #insufMemLen
	bne chkm4	;branch always
chkm3
	;show message "REMOVE CARTRIDGE/TURN OFF BASIC"
	ldy #.lo(remCart)
	ldx #.hi(remCart)
	lda #remCartLen
chkm4
	jsr outputText
	lda #$FF	;memory tests not passed
	rts
chkm5
	lda memCheckCnt
	bne chkm3	;if it is a second try then cartridge A/Basic absence test fails
	;turn off basic
	lda #$3C
	sta pbctl
	lda portb
	ora #$02
	sta portb
chkm6
	inc memCheckCnt
	lda #$00	;memory tests passed
	rts

 ini startAdr
 ini startAdr	;run tests twice to check if DOS does not restore Basic if we turn it off


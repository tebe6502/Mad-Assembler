*
*
*
	.subttl		"Remnants of old Maria OS"
*
	.include	"maria.s"
*
ramcode	equ	$2300		;AREA RESERVED FOR CODE
tiaram	equ	$480
*
*
;
;  STELLA (TIA) REGISTER ADDRESSES USED BY THIS MODULE
;
VBLANK	equ	$01	; BIT	     1	VERTICAL BLANK SET-CLR
TWSYNC	equ	$02	; STROBE	WAIT FOR HORIZ BLANK
RSYNC	equ	$03	; STROBE	RESET HORIZ SYNC COUNTER
COLUP0	equ	$06	; BITS 7654321	COLOR(4)-LUM(3) PLAYER 0
COLUPF	equ	$08	; BITS 7654321	COLOR(4)-LUM(3) PLAYFIELD
COLUBK	equ	$09	; BITS 7654321	COLOR(4)-LUM(3) BACKGROUND
PF2	equ	$0F	; BITS ALL	PLAYFIELD REG BYTE 2
RESP0	equ	$10	; STROBE	RESET PLAYER 0
RESP1	equ	$11	; STROBE	RESET PLAYER 1
GRP0	equ	$1B	; BITS ALL	GRAPHICS FOR PLAYER 0
GRP1	equ	$1C	; BITS ALL	GRAPHICS FOR PLAYER 1
CXCLR	equ	$2C	; STROBE	CLEAR COLLISION LATCHES
;
;  READ ADDRESSES -	BIT 7	BIT 6 (ONLY)
;
CXP0FB	equ	$32	;	P0.PF	P0.BL
CXP1FB	equ	$33	;	P1.PF	P1.BL
*
	.org	$f000
*
fakedli	equ	$2700
fakelist:
	.dc.b	$0,$40,$f0,$1f,$bb
	.dc.b	0,0
	.dc.b	$0f,$27,0
*
*
*
NMI:
IRQ:
	rti

*
*
startup:
	SEI			;INITIALIZE
	CLD
*
	LDA	#$07		;PUT BASE UNIT INTO MARIA ENABLE
	STA	PTCTRL
*
	ldx	#$ff
	txs
*
*
	LDA	#$7F
	STA	CTRL		;TURN OFF DMA
	LDA	#$00
	STA	BACKGRND	;BACKGROUND COLOR TO BLACK
*
*
*
*   copy 2600 code to tia RAM
*
	LDX	#$7F		;LOCK CART IN 2600 MODE, CART ON
L2LOOP:
	LDA	SYNC,X		;MOVE CODE TO RAM
	STA	tiaram,X	;MOVE INTO 6532 RAM
	DEX
	BPL	L2LOOP
*
*
*   Copy 7800 validation code from rom to ram..
*
*
	ldx	#ROMEND-ROMCODE
copylp:
	lda	ROMCODE-1,x
	sta	ramcode-1,x
	dex
	bne	copylp
*
*  Now, zero out the TIA
*
	lda	#0		;zero out the TIA
	tax
tia0loop:
	sta	VBLANK,x
	inx
	cpx	#CXCLR
	bne	tia0loop
*
	LDA	#$02		;PUT BASE UNIT INTO MARIA ENABLE
	STA	PTCTRL
*
*
*   7800 One-on-One Basketball needs ram initialized to $ff (for shame!!!)
*      it also needs a fake display list initialized since it
*      turns on Maria before loading the display list pointer
*
	.if	0
basktptr	equ	$90
*
	lda	#0
	sta	basktptr
	lda	#$18
	sta	basktptr+1
*
	ldx	#15
	ldy	#0
onelp:
	lda	#$ff
oneonlp:
	sta	(basktptr),y
	dey
	bne	oneonlp
	inc	basktptr+1
	lda	basktptr+1
	and	#(%11011110)&255	;check for $20 or $21
	bne	.10
	lda	#$ff
	sta	(basktptr),y
	ldy	#$3f
	bne	oneonlp	
.10:	
	dex
	bpl	onelp
*
	.endif
*
*
	ldx	#9
fakeload:
	lda	fakelist,x
	sta	fakedli,x
	dex
	bpl	fakeload
*
	inx			;x=0
	ldy	#80
fakeinc:
	lda	fakedli+7,x
	sta	fakedli+10,x
	inx
	dey
	bne	fakeinc
*
	jsr	wait00
*
*
	lda	#$27
	sta	DPPH
	lda	#07
	sta	DPPL
	lda	#$43
	sta	CTRL
*	sta	NMICTRL
*
*
	ldx	#$7f
frame4:
	jsr	wait00
	dex
	bpl	frame4
	lda	#$60
	sta	CTRL
*
	brk
*
wait00:
	bit	MSTAT
	bmi	wait00
wait01:
	bit	MSTAT
	bpl	wait01
	rts
*
*   the following code is copied to ram for execution
*
ROMCODE:
NOCART:
	lda	#2
	sta	PTCTRL			;turn "security" ROM on
	JMP	startup			;NO CART, do asteroids
*
CARTTEST:
	LDA	#$16			;TURN EXTERNAL CART ON
	STA	PTCTRL

	LDY	#$FF
	LDX	#$7F			;SEE IF A CART PLUGGED IN
CTSTLOOP:
	LDA	$FE00,X
	CMP	$FD80,Y
	BNE	NOCART
	DEY
	DEX
	BPL	CTSTLOOP		;X LEFT = FF, Y LEFT = 7F
*
	LDA	$FFFC			;SEE IF START AT FFFF
	AND	$FFFD
	CMP	#$FF
	BEQ	NOCART			;ALL LINES DRAWN HIGH, NO CART
	LDA	$FFFC			;SEE IF START AT 0000
	ORA	$FFFD
	BEQ	NOCART			;ALL LINES DRAWN LOW, NO CART
*
	LDA	$FFF8			;CHECK FOR REGION VERIFICATION
	ORA	#$fe
	CMP	#$FF
	BNE	CART26
 	LDA	$FFF8			;TOP 4 BITS OF FFF8 SHOULD BE 0F0
	EOR	#$F0
	AND	#$F0
	BNE	CART26
	LDA	$FFF9			;SEE IF MARIA SIGNATURE EXISTS
	AND	#$0B			;0X7 OR 0X3 VALID
	CMP	#$03
	BNE	CART26
	LDA	$FFF9			;GET BOTTOM OF CART ADDRESS
	AND	#$F0
	cmp	#$40			;not too low
	bcc	CART26
	sbc	#1
	cmp	$fffd
	bcs	CART26
*
	lda	$1BEA		;2600 ROM responds to this address
	eor	#$FF
	sta	$1BEA		;stuff some data in MARIA ram space
	tay
*
	ldx	#5		;check hardware vectors
vecheck:
	lda	$FFFA,x		;   2600 should always
	cmp	$DFFA,x		;     read the same data
	bne	SETMARIA	;       in DXXX as in FXXX
	dex
	bpl	vecheck
*
*  Some 7800 carts get here...
*
	cpy	$1BEA		;does this act like 7800 ram or 2600 ROM?
	bne	CART26
*	jmp	CART26		;1 chance in 2**48 it's still a 7800 cart
*
*     We favor 7800 more than before so 2600 might get run in 7800 mode 
*     ...may need to do more 2600/7800 discrimination here...
*
*
*  we must be 7800 cart;  go to it...
*
SETMARIA:
	LDX	#$16	;PUT CART IN 7800 MODE, CART ON
	STX	PTCTRL
	TXS
	SED
	JMP	($FFFC)	;VECTOR INTO THE CART IN 3600 MODE
*
*  tests indicate we must be a 2600 cart...
*
CART26:
	LDA	#$02
	STA	PTCTRL			;TURN SECURITY ROM ON
	jmp	tiaram			;perform this from tia ram
*
ROMEND:
*
*
; First zero out TIA without doing a TWSYNC. This must be done in a loop that
; counts up so that graphics are turned off before the collision registers are
; cleared. RSYNC should turn case C into a case A. Note also that the stores
; of zero puts the system in TIA space but does not lock it there. This code
; must all run out of 6532 RAM since the memory map will change as we change
; mode.	The 6532 RAM exists in all memory maps.
*
SYNC:
	LDA	#0
	TAX
	STA	VBLANK
ZEROLP:
	STA	RSYNC,X
	INX
	CPX	#(CXCLR-RSYNC+1)
	BNE	ZEROLP

; Test now for a possible E case. In some E cases, TWSYNCs do not work properly
; and this must be detected. In an E case failure, the LDA is prefetched and
; the 04 following it is skipped over and NOP ($EA) is loaded into A causing
; the branch on minus to be taken. If this happens the E case can now be
; corrected.	NOTE: All E cases do not get trapped here and must be handled
; latter by collisions.
	STA	TWSYNC
	LDA	#4
	NOP
	BMI	ECASE

; Position player 0 on the left side of the screen and player 1 on the right
; side of the screen so that they will overlap (or not overlap as the case may
; be) playfield 2 that has a copy on both sides of the screen.	Resets occur at
; the 38th and 65th cycle.
	LDX	#4
STALL4:
	DEX				;Stall loop
	BPL	STALL4
	TXS				;Set the stack to 0FF for stall JSRs
	STA	RESP0+$100		;38th cylce
	JSR	DUMMY+1-SYNC+$480	;12 cycle stall
	JSR	DUMMY+1-SYNC+$480	;Ditto
	STA	RESP1	;65th cycle

; Turn on graphics to cause the collisions
	STA	GRP0	;68th cycle
	STA	GRP1	;71st cycle
	STA	PF2	;74th cycle

; Stall an entire scan line to allow collisions to take place.	The E case test
; should follow all TWSYNCs to be safe.
	NOP		;76th cycle
	STA	TWSYNC	;3rd cycle
	LDA	#0
	NOP
	BMI	ECASE

; Test now for a collision between player 1 and playfield.	If there is no
; collision, we must shift the clock once. If there is a collision, we must
; do further testing.
	BIT	CXP1FB-$30
	BMI	NOCOL2

; This section shifts the clock once.	Storing a 2 switches the system into
; MARIA MODe and the following store to 0FXXX causes a clock speed-up for one
; cycle and thus shifts the clock once.
ECASE:
	LDA	#2
	STA	COLUBK	;changes to MARIA MODe
	STA	$F112
	BNE	DONE	;JMP

; Test now for a collision between player 0 and playfield.	If there is no
; collision, we must shift the clock twice. If there is a collision, we must
; do further testing.
NOCOL2:
	BIT	CXP0FB-$30
	BMI	NOCOL0

; This section shifts the clock twice.	Storing a 2 switches the system into
; MARIA MODe and the following stores to 0FXXX causes two clock speed-ups for
; one cycle and thus shifts the clock twice.
	LDA	#2
	STA	COLUP0	;changes to MARIA MODe
	STA	$F118
DUMMY:
	STA	$F460	;Note that the 060 is a RTS
	BNE	DONE

; If we've fotten to this point the only possible failure left is an E case that
; was not detected by the TWSYNC trap.	Test for this by clearing the collision
; registers, shifting the graphics for player 0 to the left one pixel by
; changing GRP0 from a 4 to an 8, and then retesting for a collision.	If there
; is still a collision between player 0 and the playfield, we have an E case,
; otherwise we are done. Be careful not to test for collisions until after they
; occur (about the 40th cycle).
NOCOL0:
	STA	CXCLR			;21st cycle
	LDA	#8			;23rd cycle - one pixel to the left
	STA	GRP0			;26th cycle
	JSR	DUMMY+1-SYNC+$480	;12 cycle stall
	NOP				;40th cycle - just to be safe
	BIT	CXP0FB-$30		;43rd cycle
	BMI	ECASE

; We are now synced and should lock ourselves into TIA mopde with the external
; cart enabled and jump to the reset vector.	Thanks for stopping by...
DONE:
	LDA	#$FD
	STA	COLUPF	;Change MODes to TIA with EXT and lock.
	JMP	($FFFC)
NROM:
*
*  some necessary code from HISCORE.S module that was omitted...
*
HSCSUCK:
*	JSR	ZEROHS
*
HSCDOENT:
*
* HSCSETDM -- SET DIFF/MODE LEVEL ARGUMENT BASED ON DIFF AND MODE
*
HSCSETDM:
*	LDA	MODE		;COMPUTE DIFF/MODE LEVEL VALUE BYTE
	BPL	ZHSCMOK
	LDA	#0
ZHSCMOK:
	ASL
	ASL
	CLC
*	ADC	DIFF
*	STA	TEMP		;SAVE IT WHERE WE CAN INSERT LATER
HSCSHOW:
	LDA	#1
HSCRET:
	RTS
*
*
HSCTAB:
	.dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.dc.b	$4F,$68,$21,$20,$57,$68,$61,$74,$20,$61
	.dc.b	$20,$66,$69,$6E,$65,$20,$62,$6F,$79,$20   
	.dc.b	$69,$73,$20,$44,$61,$76,$65,$20,$53,$74   
	.dc.b	$61,$75,$67,$61,$73,$2E           
	.dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
*
CODEDIF	equ	ROMCODE-ramcode		;DIFFERENCE BETWEEN OLD AND NEW ADDRESS
*
	.org	$FFFA
	.dc.w	NMI
	.dc.w	startup
	.dc.w	IRQ

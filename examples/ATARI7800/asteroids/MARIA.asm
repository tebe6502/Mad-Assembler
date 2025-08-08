;	.6502
;	.SUBTTL	"MARIA EQUATES -- ATARI CONFIDENTIAL"
*************************************************************************
*	THIS DOCUMENT CONTAINS CONFIDENTIAL PROPRIETARY INFORMATION	*
*	OF ATARI WHICH MAY NOT BE COPIED, DISCLOSED, OR USED EXCEPT	*
*	AS EXPRESSLY AUTHORIZED IN WRITING BY ATARI.               	*
*************************************************************************
*
*	MEMORY MAP USAGE OF THE 7800
*
*	00-1F		TIA REGISTERS
*	20-3F		MARIA REGISTERS
*	40-FF		ZERO PAGE RAM
*	100-13F		SHADOW OF TIA AND MARIA REGISTERS -- USED FOR 
*			PUSHING ACCUMULATOR ONTO REGISTERS
*	140-1FF		RAM (STACK)
*	200-27F		NOT USED
*	280-2FF		PIA PORTS AND TIMERS
*	300-17FF	NOT USED
*	1800-203F	RAM
*	2040-20FF	SHADOW OF ZERO PAGE RAM
*	2100-213F	RAM
*	2140-21FF	SHADOW OF STACK RAM
*	2200-27FF	RAM
*	2800-3FFF	DUPLICATION OF ADDRESS SPACE 2000-27FF
*	4000-FF7F	UNUSED ADDRESS SPACE
*	FF80-FFF9	RESERVED FOR ENCRYPTION
*	FFFA-FFFF	6502 VECTORS
*
	org	0
TIA:	.ds	1	;BASE ADDRESS FOR TIA CHIP

PTCTRL:	.ds	1	;INPUT PORT CONTROL ("VBLANK" IN TIA )
	.ds	6
*
*   AFTER INITIALIZING SWCHB AS FOLLOWS:
*
*	LDA  #$14
*	STA  CTLSWB
*	LDA  #0
*	STA  SWCHB
*
*   ...LEFT AND RIGHT FIRE BUTTONS CAN BE READ FROM THE FOLLOWING 4 LOCATIONS:
*
*			   THESE ARE ALSO USED FOR PADDLE INPUT
INPT4B:	.ds	1	;PLAYER 0, RIGHT FIRE BUTTON (D7=1 WHEN PUSHED)
INPT4A:	.ds	1	;PLAYER 0, LEFT FIRE BUTTON  (D7=1 WHEN PUSHED)
INPT5B:	.ds	1	;PLAYER 1, RIGHT FIRE BUTTON (D7=1 WHEN PUSHED)
INPT5A:	.ds	1	;PLAYER 1, LEFT FIRE BUTTON  (D7=1 WHEN PUSHED)
*
*   LEFT OR RIGHT FIRE BUTTONS READ FROM THESE LOCATIONS:
*
INPT4:	.ds	1	;PLAYER 0 FIRE BUTTON INPUT (D7=0 WHEN PUSHED)
INPT5:	.ds	1	;PLAYER 1 FIRE BUTTON INPUT (D7=0 WHEN PUSHED)
	.ds	7
*
AUDC0:	.ds	1	;AUDIO CONTROL CHANNEL 0
AUDC1:	.ds	1	;AUDIO CONTROL CHANNEL 1
AUDF0:	.ds	1	;AUDIO FREQUENCY CHANNEL 0
AUDF1:	.ds	1	;AUDIO FREQUENCY CHANNEL 1
AUDV0:	.ds	1	;AUDIO VOLUME CHANNEL 0
AUDV1:	.ds	1	;AUDIO VOLUME CHANNEL 1
;
;******************************************************************************
;
	org	$20
*
MARIA:				;BASE ADDRESS FOR MARIA CHIP

BKGRND:				;BACKGROUND COLOR
BACKGRND:	.ds	1	;synonym used by GCC
P0C1:		.ds	1	;PALETTE 0 - COLOR 1
P0C2:		.ds	1	;          - COLOR 2
P0C3:		.ds	1	;          - COLOR 3
WSYNC:		.ds	1	;WAIT FOR SYNC
P1C1:		.ds	1	;PALETTE 1 - COLOR 1
P1C2:		.ds	1	;          - COLOR 2
P1C3:		.ds	1	;          - COLOR 3
MSTAT:		.ds	1	;MARIA STATUS
P2C1:		.ds	1	;PALETTE 2 - COLOR 1
P2C2:		.ds	1	;          - COLOR 2
P2C3:		.ds	1	;          - COLOR 3
DPPH:		.ds	1	;DISPLAY LIST LIST POINT HIGH BYTE
P3C1:		.ds	1	;PALETTE 3 - COLOR 1
P3C2:		.ds	1	;          - COLOR 2
P3C3:		.ds	1	;          - COLOR 3
DPPL:		.ds	1	;DISPLAY LIST LIST POINT LOW BYTE
P4C1:		.ds	1	;PALETTE 4 - COLOR 1
P4C2:		.ds	1	;          - COLOR 2
P4C3:		.ds	1	;          - COLOR 3
CHARBASE:	.ds	1	;CHARACTER BASE ADDRESS
P5C1:		.ds	1	;PALETTE 5 - COLOR 1
P5C2:		.ds	1	;          - COLOR 2
P5C3:		.ds	1	;          - COLOR 3
OFFSET:		.ds	1	;FOR FUTURE EXPANSION HERE - STORE ZER0 HERE
P6C1:		.ds	1	;PALETTE 6 - COLOR 1
P6C2:		.ds	1	;          - COLOR 2
P6C3:		.ds	1	;          - COLOR 3
CTRL:		.ds	1	;MARIA CONTROL REGISTER
P7C1:		.ds	1	;PALETTE 7 - COLOR 1
P7C2:		.ds	1	;          - COLOR 2
P7C3:		.ds	1	;          - COLOR 3
*
	ORG     $40
RANDPTR0:
	.ds		1
RANDPTR1:
	.ds		1

HISCORE:
	.ds		4		;HIGH SCORE

SCORE:
	.ds		4		;PLAYER ONE SCORE DEC. MODE
SCORE2:
	.ds		4		;PLAYER TWO SCORE DEC. MODE
COMBSCOR:
	.ds		4		;COMBINED SCORE DEC. MODE

MENLEFT:
	.ds		1		;PLAYER1 NUMBER OF MEN LEFT
MENLEFT2:
	.ds		1		;PLAYER2 NUMBER OF MEN LEFT
MENLEFTC:
	.ds		1		;POOL OF LIVES FOR TEAM PLAY

TEMP:
	.ds		16		;GAMEPLAY TEMP
TEMPI:
	.ds		5		;LOADER TEMP

FREE:
	.ds		12		;FREE POINTERS, NOT FREE SPACE


FRMCNT:
	.ds		1
LASTFRMC:
	.ds		1

NMICTRL:
	.ds		1		;VALUE OF CTRL FOR HSC SPECIAL NMIHNDL

PLAYER:
	.ds		1		;WHICH PLAYER
SCORER:
	.ds		1		;WHICH PLAYER IS CURRENTLY SCORING
GAMSTATE:
	.ds		1		;STATE FOR DRIVER.
DTIMER:
	.ds		2		;TIMER FOR DRIVER - TWO BYTES ACCURACY
STATE:
	.ds		2		;STATE FOR FSM, ONE FOR EACH PLAYER
TIMER:
	.ds		2		;TIMER FOR FSM, ONE FOR EACH PLAYER
MODE:
	.ds		1		;GAME MODE: FF = 1PL, 0=2PL, 1=TP, 2=CP
DIFF:
	.ds		1		;GAME DIFFICULTY LEVEL
MAXLVL:
	.ds		1		;MAXIMIUM LEVEL AT THIS DIFF SETTING
LVLINC:
	.ds		4		;INCREMENTS TO LEVEL
LEVEL:
	.ds		2
OFFPLAY2:
	.ds		1		;OFFSET FOR PLAYER2 DATA SET

STATUS:
	.ds		32		;OBJECT STATUS FOR PLAYER1 GAME
SH2STAT:
	.ds		1		;SHIP STATUS FOR 2 PLAYER GAME
MSGICONS:
	.ds		3		;STATUS FOR MESSAGE ICONS
PARTSTAT:
	.ds		8		;STATUS FOR SHIP'S PARTS FOR COLLISIONS

FIREBUT1:
	.ds		1		;SOFT REGISTERS
FIREBUT2:
	.ds		1
HYPBUT1:
	.ds		1
HYPBUT2:
	.ds		1
STARTBUT:
	.ds		1		;FIREBUT1 EXCEPT DURING AUTOST
SWCHAVAL:
	.ds		1
SWCHBVAL:
	.ds		1
SWCHBITS:
	.ds		1
ONEBUT:
	.ds		1		;PLAYER HAS 1 BUTTON JOYSTICK:
					; BIT 4 = P0, BIT 3 = P1

SHIPDIR:
	.ds		1		;PLAYER1 SHIP DIRECTION
SHIPDIR2:
	.ds		1		;PLAYER2 SHIP DIRECTION
RACKNUM:
	.ds		1		;PLAYER1 RACK NUMBER
RACKNUM2:
	.ds		1		;PLAYER2 RACK NUMBER
ROCKTOT:
	.ds		1		;PLAYER1 ROCK TOTAL
ROCKTOT2:
	.ds		1		;PLAYER2 ROCK TOTAL
STARTNUM:
	.ds		2		;STARTING NUMBER OF ROCKS FOR EACH

BCOUNTER:
	.ds		1		;BEAT COUNTER FOR BACKGROUND TUNE
BEATVAL:
	.ds		1		;BEAT VALUE FOR COUNTER, DECREASES
BEATRATE:
	.ds		1		;BEAT RATE, FOR CHANGE OF BEATVAL
WHICHBT:
	.ds		1		;BEAT NUMBER, TOGGLES BETWEEN 0 AND 1
TUNNUM:
	.ds		2		;NUMBER OF TUNE IN EACH CHANNEL
TINDEX:
	.ds		6		;INDEX INTO TUNE TABLE
TDURCNT:
	.ds		6		;TUNE DURATION COUNTERS
TTEMP     EQU     TEMPI		;THIS IS PROBABLY SAFE, SINCE TUNER
				; AND LOADER NEVER INTERRUPT EACH OTHER

FIRESTAT:
	.ds		2
SHOTCNT:
	.ds		6		;TIMER FOR ALL SHOTS
USHOTCNT:
	.ds		1		;COUNTDOWN TIMER FOR UFO SHOTS
RTIMER:
	.ds		1		;TIMER FOR UFO ENTRY
SDELAY:
	.ds		1		;PERCENTAGE OF LARGE
EDELAY:
	.ds		1		;COUNTDOWN TIL NEXT
UFOACC:
	.ds		1		;THRESHOLD OF UFO ACCURACY
SOFTCOLR:
	.ds		16		;SOFT COPY OF FIRST 4 PALETTES.

CLAMP:
	.ds		1		;CLAMP, USED BY DAMPING SYSTEM TO
					; STOP DRIFT
LOADFLAG:
	.ds		1		;FLAG CLEARED AT END OF LOADER.

SELCNT:
	.ds		1		;DEBOUNCER/COUNTER FOR MENU SELECT
RACKDLY:
	.ds		1		;TIMER FOR NEW RACK START
COMPFLAG:
	.ds		1		;FLAG FOR COMP PLAY TERMINATION
RUBFLAG:
	.ds		1		;RUBBER SHIP BOUNCE FLAG.
TURKEY:
	.ds		1
CHICKEN:
	.ds		1

*	PIA AND TIMER (6532) LOCATIONS
*
	ORG	$280
*
SWCHA:	.ds	1	;LEFT & RIGHT JOYSTICKS
*
*	LEFT RITE
*	7654 3210	;BIT POSITION (=0 IF SWITCH IS CLOSED)
*	---- ----
*	RLDU RLDU	;RIGHT/LEFT/DOWN/UP
*
CTLSWA:	.ds	1	;SWCHA DATA DIRECTION (0=INPUT)
*
SWCHB:	.ds	1	;CONSOLE SWITCHES
*
*	D7-RITE DIFFICULTY
*	D6-LEFT DIFFICULTY
*	D5/D4 NOT USED
*	D3-PAUSE
*	D2-NOT USED
*	D1-GAME SELECT
*	D0-GAME RESET
*
CTLSWB:	.ds	1	;SWCHB DATA DIRECTION (0=INPUT)
*
INTIM:	.ds	1	;INTERVAL TIMER READ
	.ds	15
TIM1T:	.ds	1	;SET 1    CLK INTERVAL (838   NSEC/INTERVAL)
TIM8T:	.ds	1	;SET 8    CLK INTERVAL (6.7   USEC/INTERVAL)
TIM64T:	.ds	1	;SET 64   CLK INTERVAL (53.6  USEC/INTERVAL)
T1024T:	.ds	1	;SET 1024 CLK INTERVAL (858.2 USEC/INTERVAL)
	.ds	6
TIM64TI:
	.ds	1	;INTERRUPT TIMER 64T
*
*
*
*
RESET	=	1	;bits for consle switches
SELECT	=	2
PAUSE	=	8

RAM1	=	$1800	;FIRST SEGMENT OF MEMORY MINUS THE ZP,STACK, AND CHIPS
RAM2	=	$2100	;FIRST SEGMENT OF MEMORY MINUS THE ZP,STACK, AND CHIPS
RAM3	=	$2200	;FIRST SEGMENT OF MEMORY MINUS THE ZP,STACK, AND CHIPS
R1SIZE	=	($2040-RAM1)	;SIZE OF THE RAM1 BLOCK
R2SIZE	=	($2140-RAM2)	;SIZE OF THE RAM2 BLOCK
R3SIZE	=	($2800-RAM3)	;SIZE OF THE RAM3 BLOCK

;	.subttl	"system macros 7800"
*********************************************************
*	MARIA MACROS FOR EASIER GRAPHICS CONSTRUCTION	*
*********************************************************
*
*
*this macro constructs a 4 byte header for display lists
*
	.macro	header	address,palette,width,hpos
	dc.b	\address & $ff
	dc.b	(\palette*$20) | ($1f & -\width)
	dc.b	\address >> 8
	dc.b	\hpos
	.endm
;
;this macro constructs a 5 byte header for display lists
;
	.macro	xheader	address,palette,width,hpos,wm,ind

	dc.b	\address & $ff
	dc.b	((\wm*$80) | $40 | (\ind*$20))
	dc.b	\address >> 8
	dc.b	((\palette*$20) | ($1F & -\width))
	dc.b	\hpos
	.endm

;
;this macro constructs a end-of-display-list header
;
	.macro	nullhdr

	dc.b	0,0
	.endm

;
;this macro constructs a display list entry for the display list list
;
	.macro	display	dli,h16,h8,offset,address

	dc.b	((\dli*$80) | (\h16*$40) | (\h8*$20) | \offset)
	dc.b	\address >> 8
	dc.b	\address & $ff
	.endm

;
;this macro loads a palette register with a color
;
	.macro	paint	palnum,colornum,color,lum

	lda	#(\color*$10) | \lum
	sta	\bkgrnd | ((\palnum*4) | (\colornum))
	.endm

;
;this macro writes to the crtl register
;
ckoff	=	$0	;normal color
ckon	=	$1	;kill the color

dmaoff	=	$3	;turn off dma
dmaon	=	$2	;normal dma

char1b	=	$0	;one byte character definition
char2b	=	$1	;two byte character definition

bcoff	=	$0	;black border
bcback	=	$1	;background colored border

kangoff	=	$0	;transparency
kangon	=	$1	;"kangaroo" mode : no transparency!

mode1	=	$0	;160x2 or 160x4 modes
modebd	=	$2	;320b or 320d modes
modeac	=	$3	;320a or 320c modes

	.macro	screen	ck,dma,cw,bc,km,mode
	lda	#((\ck*$80) | (\dma*$20) | (\cw*$10) | (\bc*8) | (\km*4)|\mode)
	sta	CTRL
	.endm

	.macro	dppload	adr
	lda	#\adr & $ff
	sta	DPPL
	sta	sdppl
	lda	#\adr >> 8
	sta	DPPH
	sta	sdpph
	.endm

;********************************************************
;	end of the system macros definitions		*
;********************************************************


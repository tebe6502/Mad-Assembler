; WarRoom by Eric Henneke and Rob Schlortt
; Special thanks to 
; -- Paul Lay (Playsoft) for Atari Player Editor: http://www.playsoft.co.uk/aplayed.html
; -- Peter Dell (Jac!) for WUDSN IDE: http://www.wudsn.com/index.php/ide
; -- Avery Lee (Phaeron) for Altirra for Rob's favorite emulator
; -- Jaskier for Atari800WinPlus for Eric's favorite emulator
; -- The entire 8 Bit community for everything - We have learned so much from you and thank you for your support, interest, feedback and keeping this platform alive.
; Additional Sources:
; https://www.atariarchives.org/alp/chapter_10.php
; http://www.wudsn.com/index.php/productions-atari800/tutorials/tips 
; 
; *************************************************************************
; * 1.a.                         Literal Values
; *************************************************************************
;AttractcountdownSeconds=45
	.def :MusicLoopsBeforeAttract=2 ; number of music loops before game goes into demo mode.
	.def :showTitleScreen=1 ; 0 off, 1 on - TURN OFF TO GO DIRECTLY TO GAME (ONLY USED TO SAVE TIME DEBUGGING)
	.def :p0height=15 ; All Players have same Height.  Create them as 15 Pixels tall
	.def :p1height=15 ; All Players have same Height.  Create them as 15 Pixels tall
	.def :rotatespeed=6; higher is slower: THIS IS HOW FAST THE IMAGE Flips While Running

;fighter0 settings
	.def :yvalue=166 ; fighter0 starting Y position
	.def :player0width=0 ; Player 0 Width Setting
	.def :player1width=0 ; Player 1 Width Setting
;fighter1 settings
	.def :yvalues1=75 ; fighter1 starting y position
	.def :player2width=0
	.def :player3width=0
; PLAYFIELD COLORS
PFCOLOR0=$72 ; PLAYFIELD COLOR 0 (LATER LOADED AND STORED IN COLOR0)
PFCOLOR1=$24 ; PlayField Color 1 - SLIME Color
PFCOLOR2=$72 ; Playfield Color 2 
INVERSECOLOR=12 ; ANTIC Mode 4 Inverse Color
BULLETCOLOR=inversecolor ; Set Bullets to Inversecolor
;FRAME is defined as one VBI Cycle
vpixelmaxspeed=3 ; Maximum number of pixels a fighter can travel VERTICALLY in one frame. 
hpixelmaxspeed=2 ; Maximum number of pixels a fighter can travel HORIZONTALLY in one frame.
; BULLET SPEED & COLOR
HORBULLETSPEED=6; Number of Pixels a bullet can travel horizontally in one frame.
; values based on Horizontal Bullet Speed
RIGHTBULLETSPEED=HORBULLETSPEED
LEFTBULLETSPEED=255-HORBULLETSPEED+1
DIAGLEFTBULLETSPEED=255-(HORBULLETSPEED/2)+1

VERTBULLETSPEED=11; Number of Pixels a bullet can travel vertically in one frame.
; values based on Vertical Bullet Speed
DOWNBULLETSPEED=VERTBULLETSPEED
UPBULLETSPEED=255-VERTBULLETSPEED+1
DIAGUPBULLETSPEED=255-(VERTBULLETSPEED/2)+1
VERTBULLHOROFFSET=VERTBULLETSPEED/2
UPVBH=255-VERTBULLHOROFFSET+1
DOWNVBH=VERTBULLHOROFFSET

; JOYSTICK LITERALS
UP=14
RIGHT=7
DOWN=13
LEFT=11
NOACTION=15
UPRIGHT=6
DOWNRIGHT=5
UPLEFT=10
DOWNLEFT=9
dli=$ab80 ; Used to Turn on DLI Lines

;**************************************************************************
; 1.b. Memory Configuration
;**************************************************************************
	TotalMemoryinK=48 ; This will work on your Atari 800!
	TotalPages=TotalMemoryinK*4 ; Calculate Number of Pages
;**************************************************************************
; GRAPHICS 12 WIT HI RES PLAYERS
;**************************************************************************
	GRAPHICSMODE=12+16 ; Set to Graphics 12 with no text window.  
	ANTICMODE=$4 ; Antic Mode 4.  This information is necessary so that we can modify the Display List Later
	PagesToReserve=16 ; Used to calculate PMBASE
	SCRTotalPages=PMBASEPage-31
	SCR=SCRTotalPages*256+80 ;41056 ;43104 ;45152 ;MEMLOCS 88, 89 $58,$59
	DLTotalPages=PMBASEPage-32
	DL=DLTotalPages*256+80 ; 40866 ;42914 ; 44962 ; MEMLOCS 560, 561 $230,$231

; The following Graphics Mode info is not used in WarRoom
;**************************************************************************
; GRAPHICS 15 WITH HI RES PLAYERS
;**************************************************************************
;	GRAPHICSMODE=15
;	ANTICMODE=$E
;	PagesToReserve=16 ; 32
;	SCRTotalPages=PMBASEPage-31
;	SCR=SCRTotalPages*256+80 ;41056 ;43104 ;45152 ;MEMLOCS 88, 89 $58,$59
;	DLTotalPages=PMBASEPage-32
;	DL=DLTotalPages*256+80 ; 40866 ;42914 ; 44962 ; MEMLOCS 560, 561 $230,$231
	
;**************************************************************************
; GRAPHICS 7 WITH HI RES PLAYERS
;**************************************************************************
;	GRAPHICSMODE=7
;	ANTICMODE=$D
;	PagesToReserve=16
;	SCRTotalPages=PMBASEPage-16
;	SCR=SCRTotalPages*256+96 ;41056 ;43104 ;45152 ;MEMLOCS 88, 89 $58,$59
;	DLTotalPages=PMBASEPage-17
;	DL=DLTotalPages*256+162 ; 40866 ;42914 ; 44962 ; MEMLOCS 560, 561 $230,$231
; *********************************************************************************
; Derivative Graphics Calculations
; *********************************************************************************

	PMBASEPAGE=totalPages-PAGESTORESERVE ;  Let MADS do all those tedious PM calculations.
	M0=(PMBASEPAGE + 3)*256 ; 41728
	P0=(PMBASEPAGE + 4)*256 ;41984	
	P1=(PMBASEPAGE + 5)*256 ;42240
	P2=(PMBASEPAGE + 6)*256 ;42496	
	P3=(PMBASEPAGE + 7)*256 ;42752

; 1.c. Variable Memory Addresses
	DLION=ANTICMODE+128 ; DLI on = Antic Mode + 128 or $84
	DLIOFF=ANTICMODE ; A line in the display list with No DLI = $4
	LMSLOW=DL+4 ; Somewhat hardcoded values on where to start manipulating the display list
	LMSHIGH=DL+5; Somewhat hardcoded values on where to start manipulating the display list

	; ******************************
	; CIO equates
	; ******************************
	RTCLOCKJiffy=20 ; increments every vbi cycle - Using register 20 - See Mapping the Atari
	PMBASE=54279 ; Player-missile base pointer
	RAMTOP=106   ; OS top of RAM pointer
	SDMCTL=559   ;RAM shadow of DMACTL register
	GRACTL=53277  ; CTIA graphics control register 
	CURSORINHIBIT=752 
	SKCTL=53775
	CHBAS =    $2f4
	ICHID =    $0340
	ICDNO =    $0341
	ICCOM =    $0342
	ICSTA =    $0343
	ICBAL =    $0344
	ICBAH =    $0345
	ICPTL =    $0346
	ICPTH =    $0347
	ICBLL =    $0348
	ICBLH =    $0349
	ICAX1 =    $034A
	ICAX2 =    $034B
	CONSOL =   $D01F
	CIOV  =    $E456
	; ******************************
    ; Other equates needed
    ; ******************************
	COLCRS =   $55
	ROWCRS =   $54
	x1=245
	x2=246
	x3=247
	x4=248
	
; *****************************************
; MUST BE ZERO PAGE AND CONSECUTIVE
	SCRLO=204 ; screenstart lo byte - See Mapping the Atari
	SCRHI=205 ; screenstart hi byte- See Mapping the Atari
	Stick0=632 
	Stick1=633

	strig0=644
	strig1=645
	COLOR0=708
	COLOR1=709
	COLOR2=710	
	COLOR3=711
	COLOR4=712
	RANDOM=$D20A ; This is used for bullet pack placement	
	P0X=53248
	P1X=53249
	P2X=53250
	P3X=53251
	M0X=53252
	M1X=53253
	
	M2X=53254
	M3X=53255
	M0cd=53256
	M1CD=53257
	M2cd=53258
	M3CD=53259
	p0pl=53260
	p1pl=53261
	p0pf=m0x
	p1pf=m1x
	p2pf=m2x
	p3pf=m3x
	SIZEM=53260
	VCOUNT=54283

;3.  Start will be executed first
	run  start
; Sound - Theme Song
	org $CB ; Eric's Sound and Music which I don't understand...
NOTEPTR		.word $5833			; change this to end of notes
PLAYPTR		.word $5005			; change this to beginning of notes
PLAYTIMER	.word 0
TV			.word 0
; Sound - Theme Song

; ************************************************************************************************************************************************
; 2. DLI Start
; ************************************************************************************************************************************************
; PLACEHOLDER FOR DLI
	org $600 ; Page 6
dlistart	PHA ;	3 push a to S
	txa
	pha
	ldx #$d4
	lda RANDOM
	sta 54282 ; wsync ; wait for sync
	stx 53271 ; store color #$D4 in Slime color register - This is necessary because the custom display list changed mode from ANTIC 2 to ANTIC 4 
	sta 53272 ; Store random color in Bullet Packs to make them glow.  Again, done here because of custom display list.
	pla
	tax	
	PLA
	RTI

; ************************************************************************************************************************************************
; DLI END
; ************************************************************************************************************************************************
	org $6000
	
; The different Player Definitions are below.  Players are two color and created in player editor: http://www.playsoft.co.uk/aplayed.html
; Each direction has two frames - 8 different directions for 16 frames.
; Direction order: Left x2, Right x2, DownLeft x2, DownRight x2, UpLeft x2, Up x2, Down x2	
; *********************************************************************************************************************
;SOLDIER - Jake and Paul
;********************************************************************************
P0DATA:
; FRAME 1
 .BYTE $1c,$22,$3c,$7d,$7b,$3e,$3e,$3b
 .BYTE $3d,$0f,$76,$38,$22,$1a,$06
; FRAME 2
 .BYTE $1c,$22,$3c,$7d,$7b,$3e,$3e,$3d
 .BYTE $3b,$67,$36,$2a,$02,$0e,$18
; FRAME 3
 .BYTE $38,$44,$3c,$be,$de,$7c,$7c,$dc
 .BYTE $8c,$b4,$78,$78,$28,$2c,$30
; FRAME 4
 .BYTE $38,$44,$3c,$fe,$de,$7c,$7c,$dc
 .BYTE $bc,$f8,$66,$34,$3c,$38,$0c
; FRAME 5
 .BYTE $1c,$26,$1e,$5f,$6f,$3e,$3e,$fe
 .BYTE $7e,$6e,$36,$08,$16,$32,$06
; FRAME 6
 .BYTE $1c,$26,$1e,$5f,$6f,$3e,$3e,$3e
 .BYTE $fe,$6e,$76,$08,$34,$1c,$30
; FRAME 7
 .BYTE $38,$64,$78,$fa,$f6,$7c,$7c,$7f
 .BYTE $7e,$76,$6c,$14,$68,$4c,$60
; FRAME 8
 .BYTE $38,$64,$78,$fa,$f6,$7c,$7c,$7c
 .BYTE $7f,$76,$6e,$50,$2c,$38,$0c
; FRAME 9
 .BYTE $1c,$2a,$1c,$7d,$7b,$3e,$3e,$3c
 .BYTE $7f,$6f,$37,$18,$16,$32,$06
; FRAME 10
 .BYTE $1c,$2a,$1c,$7d,$7b,$3e,$3e,$3c
 .BYTE $3e,$2e,$36,$38,$32,$16,$30
; FRAME 11
 .BYTE $38,$54,$38,$be,$de,$7c,$7d,$3e
 .BYTE $7e,$f6,$ec,$18,$68,$4c,$60
; FRAME 12
 .BYTE $38,$54,$38,$be,$de,$7c,$7c,$3c
 .BYTE $7a,$74,$6c,$1c,$4c,$68,$0c
; FRAME 13
 .BYTE $38,$64,$78,$fa,$f6,$7c,$ba,$44
 .BYTE $6e,$b6,$7c,$5c,$5c,$2c,$60
; FRAME 14
 .BYTE $38,$64,$78,$fa,$f6,$7c,$ba,$44
 .BYTE $ec,$36,$6c,$78,$74,$68,$0c
; FRAME 15
 .BYTE $1c,$26,$1e,$5f,$6f,$3e,$3f,$7f
 .BYTE $5f,$4c,$37,$0e,$26,$16,$30
; FRAME 16
 .BYTE $1c,$26,$1e,$5f,$6f,$3e,$3f,$3f
 .BYTE $1f,$4d,$76,$38,$36,$34,$06
P1DATA:
; FRAME 1
 .BYTE $00,$1c,$02,$02,$04,$00,$2e,$3c
 .BYTE $3a,$14,$0c,$26,$2a,$1a,$06
; FRAME 2
 .BYTE $00,$1c,$02,$02,$04,$00,$2e,$3a
 .BYTE $3c,$1a,$2a,$34,$0a,$0e,$18
; FRAME 3
 .BYTE $00,$38,$40,$40,$20,$00,$74,$3c
 .BYTE $7c,$48,$10,$10,$08,$2c,$30
; FRAME 4
 .BYTE $00,$38,$40,$00,$20,$00,$74,$3c
 .BYTE $5c,$20,$38,$0c,$24,$38,$0c
; FRAME 5
 .BYTE $00,$18,$20,$20,$10,$00,$16,$3c
 .BYTE $7c,$52,$0a,$36,$18,$32,$06
; FRAME 6
 .BYTE $00,$18,$20,$20,$10,$00,$16,$3c
 .BYTE $3e,$52,$48,$36,$0c,$1c,$30
; FRAME 7
 .BYTE $00,$18,$04,$04,$08,$00,$68,$3c
 .BYTE $3e,$4a,$50,$68,$18,$4c,$60
; FRAME 8
 .BYTE $00,$18,$04,$04,$08,$00,$68,$3c
 .BYTE $7c,$4a,$12,$2c,$30,$38,$0c
; FRAME 9
 .BYTE $00,$14,$22,$02,$04,$00,$20,$3c
 .BYTE $5c,$51,$09,$26,$18,$32,$06
; FRAME 10
 .BYTE $00,$14,$22,$02,$04,$00,$20,$3c
 .BYTE $1c,$10,$28,$26,$0a,$16,$30
; FRAME 11
 .BYTE $00,$28,$44,$40,$20,$00,$04,$3c
 .BYTE $3a,$8a,$90,$64,$18,$4c,$60
; FRAME 12
 .BYTE $00,$28,$44,$40,$20,$00,$04,$3c
 .BYTE $3c,$08,$14,$64,$50,$68,$0c
; FRAME 13
 .BYTE $00,$18,$04,$04,$08,$00,$44,$ba
 .BYTE $90,$c8,$00,$2c,$2c,$4c,$60
; FRAME 14
 .BYTE $00,$18,$04,$04,$08,$00,$44,$ba
 .BYTE $12,$4a,$10,$64,$68,$64,$0c
; FRAME 15
 .BYTE $00,$18,$20,$20,$10,$00,$6a,$3e
 .BYTE $7c,$73,$09,$36,$1e,$26,$30
; FRAME 16
 .BYTE $00,$18,$20,$20,$10,$00,$6a,$7e
 .BYTE $7d,$33,$48,$36,$38,$32,$06

;********************************************************************************
;COWBOY
;********************************************************************************


COWBOYP0DATA:
; FRAME 1
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$1c,$3c
 .BYTE $18,$18,$60,$3e,$00,$14,$3c
; FRAME 2
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$1c,$3c
 .BYTE $18,$78,$20,$1e,$00,$0c,$18
; FRAME 3
 .BYTE $10,$38,$38,$ba,$c6,$7c,$38,$3c
 .BYTE $38,$1e,$08,$78,$00,$28,$3c
; FRAME 4
 .BYTE $10,$38,$38,$ba,$c6,$7c,$38,$3c
 .BYTE $38,$18,$0e,$78,$00,$30,$18
; FRAME 5
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$fe
 .BYTE $7e,$78,$02,$3e,$18,$3e,$0e
; FRAME 6
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $fe,$7a,$40,$1e,$00,$1e,$38
; FRAME 7
 .BYTE $10,$38,$38,$ba,$c6,$7c,$7c,$7c
 .BYTE $7c,$1c,$38,$60,$10,$58,$60
; FRAME 8
 .BYTE $10,$38,$38,$ba,$c6,$7c,$7c,$7c
 .BYTE $7c,$1c,$1c,$78,$20,$30,$18
; FRAME 9
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $00,$22,$3c,$02,$3e,$74,$20
; FRAME 10
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $40,$60,$1e,$20,$76,$2e,$04
; FRAME 11
 .BYTE $10,$38,$38,$ba,$c6,$7c,$7d,$7f
 .BYTE $02,$42,$3c,$44,$7c,$2e,$04
; FRAME 12
 .BYTE $10,$38,$38,$ba,$c6,$7d,$7f,$7e
 .BYTE $02,$00,$7c,$04,$6e,$74,$20
; FRAME 13
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3f
 .BYTE $00,$00,$3f,$01,$3e,$17,$02
; FRAME 14
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $01,$00,$3f,$01,$37,$3a,$10
; FRAME 15
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $5c,$5d,$40,$7e,$70,$36,$06
; FRAME 16
 .BYTE $08,$1c,$1c,$5d,$63,$3e,$3e,$3e
 .BYTE $1d,$5c,$40,$7e,$46,$76,$30
COWBOYP1DATA:
; FRAME 1
 .BYTE $00,$00,$00,$00,$1c,$00,$08,$3c
 .BYTE $0c,$16,$1e,$24,$1e,$00,$02
; FRAME 2
 .BYTE $00,$00,$00,$00,$1c,$00,$08,$3c
 .BYTE $0c,$16,$3e,$02,$1e,$00,$04
; FRAME 3
 .BYTE $00,$00,$00,$00,$38,$00,$10,$3c
 .BYTE $30,$60,$78,$00,$38,$00,$40
; FRAME 4
 .BYTE $00,$00,$00,$00,$38,$00,$10,$3c
 .BYTE $30,$68,$70,$08,$78,$00,$20
; FRAME 5
 .BYTE $00,$00,$00,$00,$1c,$00,$16,$3c
 .BYTE $6c,$56,$3e,$00,$06,$00,$01
; FRAME 6
 .BYTE $00,$00,$00,$00,$1c,$00,$16,$3c
 .BYTE $2c,$56,$7e,$20,$1e,$01,$04
; FRAME 7
 .BYTE $00,$00,$00,$00,$38,$00,$68,$3c
 .BYTE $34,$68,$44,$38,$60,$00,$00
; FRAME 8
 .BYTE $00,$00,$00,$00,$38,$00,$68,$3c
 .BYTE $34,$68,$60,$10,$58,$00,$00
; FRAME 9
 .BYTE $00,$00,$00,$00,$1c,$00,$20,$30
 .BYTE $3c,$3c,$22,$1c,$00,$02,$10
; FRAME 10
 .BYTE $00,$00,$00,$00,$1c,$00,$20,$30
 .BYTE $7c,$5e,$20,$1e,$00,$10,$02
; FRAME 11
 .BYTE $00,$00,$00,$00,$38,$00,$04,$0c
 .BYTE $3c,$3e,$40,$38,$00,$40,$08
; FRAME 12
 .BYTE $00,$00,$00,$00,$38,$00,$04,$0c
 .BYTE $3e,$7e,$00,$78,$00,$08,$40
; FRAME 13
 .BYTE $00,$00,$00,$00,$1c,$00,$00,$22
 .BYTE $3f,$7f,$40,$3e,$00,$20,$04
; FRAME 14
 .BYTE $00,$00,$00,$00,$1c,$00,$00,$22
 .BYTE $7e,$7f,$00,$3e,$00,$04,$20
; FRAME 15
 .BYTE $00,$00,$00,$00,$1c,$00,$2a,$3e
 .BYTE $37,$2b,$7e,$00,$0e,$00,$00
; FRAME 16
 .BYTE $00,$00,$00,$00,$1c,$00,$2a,$3f
 .BYTE $77,$2a,$3e,$40,$38,$00,$00


;********************************************************************************
;Chad
;********************************************************************************


ManP0DATA:
; FRAME 1
 .BYTE $1c,$1e,$1e,$3e,$1e,$1e,$18,$e0
 .BYTE $64,$24,$20,$1e,$1e,$3e,$0e
; FRAME 2
 .BYTE $1c,$1e,$1e,$3e,$1e,$1e,$f8,$60
 .BYTE $20,$22,$02,$1e,$1e,$1e,$38
; FRAME 3
 .BYTE $38,$78,$78,$7c,$78,$78,$1e,$0c
 .BYTE $08,$08,$00,$78,$78,$78,$1c
; FRAME 4
 .BYTE $38,$78,$78,$7c,$78,$78,$18,$1c
 .BYTE $1c,$14,$10,$78,$78,$7c,$70
; FRAME 5
 .BYTE $0e,$1f,$1f,$1f,$1f,$1f,$ff,$6e
 .BYTE $20,$22,$12,$1f,$1b,$3b,$07
; FRAME 6
 .BYTE $0e,$1f,$1f,$1f,$1f,$1f,$1f,$ee
 .BYTE $60,$24,$25,$1f,$1b,$1f,$38
; FRAME 7
 .BYTE $70,$f8,$f8,$f8,$f8,$f8,$f8,$70
 .BYTE $64,$54,$48,$f8,$d8,$dc,$e0
; FRAME 8
 .BYTE $70,$f8,$f8,$f8,$f8,$f8,$f8,$78
 .BYTE $30,$3c,$a4,$f8,$d8,$f8,$1c
; FRAME 9
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$3c,$5c
 .BYTE $41,$01,$38,$3e,$76,$3e,$06
; FRAME 10
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$3c,$1c
 .BYTE $20,$20,$02,$3e,$3e,$76,$30
; FRAME 11
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$3f,$3a
 .BYTE $82,$80,$1c,$7c,$6e,$7c,$60
; FRAME 12
 .BYTE $70,$f8,$f8,$f8,$f8,$f8,$78,$7e
 .BYTE $0c,$08,$80,$f8,$f8,$dc,$18
; FRAME 13
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$38,$00
 .BYTE $00,$80,$40,$7c,$7c,$6c,$60
; FRAME 14
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$38,$00
 .BYTE $00,$02,$04,$7c,$7c,$6c,$0c
; FRAME 15
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$3e,$7e
 .BYTE $5c,$40,$01,$26,$3e,$36,$30
; FRAME 16
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$3e,$3e
 .BYTE $1d,$41,$40,$32,$3e,$36,$06
ManP1DATA:
; FRAME 1
 .BYTE $00,$18,$18,$28,$1c,$1e,$1f,$1f
 .BYTE $1f,$3e,$3e,$00,$00,$38,$0e
; FRAME 2
 .BYTE $00,$18,$18,$28,$1c,$1e,$1f,$1f
 .BYTE $3f,$3f,$1e,$00,$00,$1e,$38
; FRAME 3
 .BYTE $00,$18,$18,$14,$38,$78,$70,$70
 .BYTE $f8,$f8,$f8,$00,$00,$78,$1c
; FRAME 4
 .BYTE $00,$18,$18,$14,$38,$78,$78,$60
 .BYTE $64,$fc,$f8,$00,$00,$1c,$70
; FRAME 5
 .BYTE $00,$00,$00,$12,$1e,$0b,$1e,$1e
 .BYTE $3f,$3f,$0f,$00,$00,$38,$07
; FRAME 6
 .BYTE $00,$00,$00,$12,$1e,$0b,$1e,$1e
 .BYTE $1f,$3f,$3e,$00,$00,$07,$38
; FRAME 7
 .BYTE $00,$00,$00,$48,$78,$d0,$78,$38
 .BYTE $9c,$ec,$f0,$00,$00,$1c,$e0
; FRAME 8
 .BYTE $00,$00,$00,$48,$78,$d0,$78,$58
 .BYTE $c8,$e4,$7c,$00,$00,$e0,$1c
; FRAME 9
 .BYTE $00,$00,$00,$20,$20,$30,$3c,$7e
 .BYTE $7f,$3f,$06,$00,$40,$38,$06
; FRAME 10
 .BYTE $00,$00,$00,$20,$30,$30,$3c,$1e
 .BYTE $3e,$3e,$3c,$00,$08,$46,$30
; FRAME 11
 .BYTE $00,$00,$00,$04,$04,$0c,$3c,$7c
 .BYTE $fe,$fc,$60,$00,$02,$1c,$60
; FRAME 12
 .BYTE $00,$00,$00,$08,$18,$18,$78,$f0
 .BYTE $f0,$f8,$78,$00,$20,$c4,$18
; FRAME 13
 .BYTE $00,$00,$04,$04,$04,$04,$c6,$fe
 .BYTE $fe,$fe,$3c,$0c,$0c,$2c,$60
; FRAME 14
 .BYTE $00,$00,$04,$04,$04,$04,$c6,$fe
 .BYTE $fe,$fe,$78,$60,$60,$68,$0c
; FRAME 15
 .BYTE $00,$00,$00,$00,$22,$3e,$6b,$3f
 .BYTE $7f,$7f,$3f,$1e,$06,$06,$30
; FRAME 16
 .BYTE $00,$00,$00,$00,$22,$3e,$6b,$7f
 .BYTE $7f,$3f,$7e,$3c,$30,$34,$06



;Chad
ChadP0DATA:
; FRAME 1
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3b
 .BYTE $75,$0f,$3e,$38,$1e,$06,$00
; FRAME 2
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3f
 .BYTE $35,$6f,$1f,$3c,$3e,$18,$00
; FRAME 3
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$fc
 .BYTE $ec,$f6,$f8,$fc,$7c,$18,$00
; FRAME 4
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$dc
 .BYTE $ee,$f0,$fc,$7c,$78,$60,$00
; FRAME 5
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3b
 .BYTE $75,$0f,$3e,$38,$1e,$06,$00
; FRAME 6
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3f
 .BYTE $35,$6f,$1f,$3c,$3e,$18,$00
; FRAME 7
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$dc
 .BYTE $ee,$f0,$fc,$7c,$78,$60,$00
; FRAME 8
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$fc
 .BYTE $ec,$f6,$f8,$fc,$7c,$18,$00
; FRAME 9
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3b
 .BYTE $75,$0f,$3e,$38,$1e,$06,$00
; FRAME 10
 .BYTE $1c,$3e,$3e,$7f,$5f,$3e,$3e,$3f
 .BYTE $35,$6f,$1f,$3c,$3e,$18,$00
; FRAME 11
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$dc
 .BYTE $ee,$f0,$fc,$7c,$78,$60,$00
; FRAME 12
 .BYTE $38,$7c,$7c,$fe,$fa,$7c,$7c,$fc
 .BYTE $ec,$f6,$f8,$fc,$7c,$18,$00
; FRAME 13
 .BYTE $38,$7c,$fe,$fe,$fe,$7c,$de,$c6
 .BYTE $fe,$7e,$7c,$1c,$1c,$08,$0c
; FRAME 14
 .BYTE $38,$7c,$fe,$fe,$fe,$3c,$be,$c6
 .BYTE $fe,$fc,$7c,$70,$70,$20,$60
; FRAME 15
 .BYTE $1c,$3c,$7d,$69,$69,$28,$75,$7d
 .BYTE $23,$7f,$3f,$38,$38,$30,$00
; FRAME 16
 .BYTE $1c,$3e,$7d,$69,$69,$28,$75,$7d
 .BYTE $62,$7f,$7e,$0e,$0e,$06,$00
ChadP1DATA:
; FRAME 1
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$0c
 .BYTE $1a,$74,$24,$26,$00,$38,$0e
; FRAME 2
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$08
 .BYTE $3a,$12,$62,$22,$20,$06,$38
; FRAME 3
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$10
 .BYTE $1c,$08,$06,$04,$04,$60,$1c
; FRAME 4
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$30
 .BYTE $18,$0e,$04,$04,$00,$1c,$70
; FRAME 5
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$0c
 .BYTE $1a,$74,$24,$26,$00,$38,$0e
; FRAME 6
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$08
 .BYTE $3a,$12,$62,$22,$20,$06,$38
; FRAME 7
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$30
 .BYTE $18,$0e,$04,$04,$00,$1c,$70
; FRAME 8
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$10
 .BYTE $1c,$08,$06,$04,$04,$60,$1c
; FRAME 9
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$0c
 .BYTE $1a,$74,$24,$26,$00,$38,$0e
; FRAME 10
 .BYTE $1c,$3e,$38,$50,$70,$74,$1e,$08
 .BYTE $3a,$12,$62,$22,$20,$06,$38
; FRAME 11
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$30
 .BYTE $18,$0e,$04,$04,$00,$1c,$70
; FRAME 12
 .BYTE $38,$7c,$1c,$0a,$0e,$2e,$78,$10
 .BYTE $1c,$08,$06,$04,$04,$60,$1c
; FRAME 13
 .BYTE $38,$7c,$7c,$38,$00,$7c,$3c,$38
 .BYTE $00,$02,$00,$60,$60,$64,$0c
; FRAME 14
 .BYTE $38,$7c,$7c,$38,$10,$44,$78,$38
 .BYTE $00,$80,$00,$0c,$0c,$4c,$60
; FRAME 15
 .BYTE $1c,$3e,$22,$3e,$2a,$3e,$2a,$22
 .BYTE $5c,$40,$01,$06,$06,$36,$30
; FRAME 16
 .BYTE $1c,$3e,$22,$3e,$2a,$3e,$2a,$22
 .BYTE $1d,$01,$40,$30,$30,$36,$06
 
 HankP0DATA:
; FRAME 1
 .BYTE $1c,$20,$1e,$3f,$3f,$2f,$3f,$1f
 .BYTE $17,$0f,$7e,$3e,$02,$1a,$06
; FRAME 2
 .BYTE $00,$1c,$3e,$3f,$3f,$2f,$3f,$1f
 .BYTE $1f,$7f,$3e,$3e,$02,$0e,$18
; FRAME 3
 .BYTE $38,$04,$78,$fc,$fc,$f4,$7c,$f8
 .BYTE $f8,$fc,$78,$78,$28,$2c,$30
; FRAME 4
 .BYTE $00,$38,$7c,$fc,$fc,$f4,$7c,$f8
 .BYTE $f8,$fc,$7e,$3c,$3c,$38,$0c
; FRAME 5
 .BYTE $2c,$42,$2c,$7e,$7e,$56,$7e,$fe
 .BYTE $0e,$0e,$3e,$3e,$16,$32,$06
; FRAME 6
 .BYTE $00,$2c,$6e,$7e,$7e,$56,$7e,$3e
 .BYTE $ce,$4e,$7e,$3e,$3c,$1c,$30
; FRAME 7
 .BYTE $34,$42,$34,$7e,$7e,$6a,$7e,$7f
 .BYTE $72,$70,$7c,$7c,$68,$4c,$60
; FRAME 8
 .BYTE $00,$34,$76,$7e,$7e,$6a,$7e,$7c
 .BYTE $70,$73,$7e,$7c,$3c,$38,$0c
; FRAME 9
 .BYTE $00,$36,$7e,$7f,$7f,$7f,$7e,$3e
 .BYTE $1e,$7f,$7f,$3f,$16,$32,$06
; FRAME 10
 .BYTE $36,$40,$3e,$7f,$7f,$7f,$3e,$3e
 .BYTE $3e,$3e,$3e,$3e,$32,$16,$30
; FRAME 11
 .BYTE $00,$6c,$7e,$fe,$fe,$fe,$7c,$3e
 .BYTE $7e,$fe,$fc,$7c,$68,$4c,$60
; FRAME 12
 .BYTE $6c,$02,$7c,$fe,$fe,$fe,$7e,$3c
 .BYTE $78,$7c,$7c,$7c,$5c,$68,$0c
; FRAME 13
 .BYTE $00,$6c,$fe,$fe,$fe,$fe,$fe,$fe
 .BYTE $fe,$fe,$7c,$7c,$7c,$6c,$60
; FRAME 14
 .BYTE $6c,$82,$7c,$fe,$fe,$fe,$fe,$fe
 .BYTE $fe,$7e,$7c,$7c,$7c,$6c,$0c
; FRAME 15
 .BYTE $00,$36,$77,$7f,$7f,$6b,$7f,$7f
 .BYTE $77,$07,$07,$3e,$3e,$36,$30
; FRAME 16
 .BYTE $36,$41,$36,$7f,$7f,$6b,$7f,$7f
 .BYTE $77,$07,$47,$3e,$3e,$36,$06
hankP1DATA:
; FRAME 1
 .BYTE $00,$00,$1e,$3f,$3f,$3f,$2f,$fe
 .BYTE $78,$10,$20,$20,$0a,$1a,$06
; FRAME 2
 .BYTE $00,$00,$1e,$3f,$3f,$3f,$2f,$f8
 .BYTE $78,$02,$22,$20,$0a,$0e,$18
; FRAME 3
 .BYTE $00,$00,$78,$fc,$fc,$fc,$74,$1f
 .BYTE $0e,$00,$10,$10,$08,$2c,$30
; FRAME 4
 .BYTE $00,$00,$78,$fc,$fc,$fc,$74,$1f
 .BYTE $1e,$20,$20,$04,$24,$38,$0c
; FRAME 5
 .BYTE $00,$00,$3c,$7e,$7e,$7e,$56,$3c
 .BYTE $fc,$72,$02,$00,$10,$32,$06
; FRAME 6
 .BYTE $00,$00,$3c,$7e,$7e,$7e,$56,$3c
 .BYTE $3e,$f2,$40,$00,$04,$1c,$30
; FRAME 7
 .BYTE $00,$00,$3c,$7e,$7e,$7e,$6a,$3c
 .BYTE $3f,$4e,$40,$00,$08,$4c,$60
; FRAME 8
 .BYTE $00,$00,$3c,$7e,$7e,$7e,$6a,$3c
 .BYTE $7f,$4c,$02,$00,$20,$38,$0c
; FRAME 9
 .BYTE $00,$00,$3e,$7f,$7f,$7f,$fe,$fc
 .BYTE $78,$40,$41,$01,$10,$32,$06
; FRAME 10
 .BYTE $00,$00,$3e,$7f,$7f,$7f,$3e,$1c
 .BYTE $00,$00,$20,$20,$02,$16,$30
; FRAME 11
 .BYTE $00,$00,$7c,$fe,$fe,$fe,$7c,$38
 .BYTE $02,$82,$80,$00,$08,$4c,$60
; FRAME 12
 .BYTE $00,$00,$7c,$fe,$fe,$fe,$7f,$3f
 .BYTE $1e,$00,$04,$04,$40,$68,$0c
; FRAME 13
 .BYTE $00,$00,$7c,$fe,$fe,$fe,$7c,$38
 .BYTE $00,$80,$00,$0c,$0c,$0c,$60
; FRAME 14
 .BYTE $00,$00,$7c,$fe,$fe,$fe,$7c,$38
 .BYTE $00,$02,$00,$60,$60,$60,$0c
; FRAME 15
 .BYTE $00,$00,$3e,$7f,$7f,$7f,$2a,$3e
 .BYTE $7e,$78,$39,$06,$06,$06,$30
; FRAME 16
 .BYTE $00,$00,$3e,$7f,$7f,$7f,$2a,$3e
 .BYTE $3f,$79,$78,$30,$30,$30,$06

kateP0DATA:
; FRAME 1
 .BYTE $3c,$7e,$7e,$7f,$5f,$ff,$5e,$3f
 .BYTE $03,$41,$00,$02,$20,$64,$08
; FRAME 2
 .BYTE $3c,$7e,$7e,$7f,$5f,$ff,$5f,$3e
 .BYTE $03,$03,$01,$48,$00,$18,$38
; FRAME 3
 .BYTE $3c,$7e,$7e,$fe,$fa,$ff,$fa,$7c
 .BYTE $c0,$c0,$80,$12,$00,$18,$1c
; FRAME 4
 .BYTE $3c,$7e,$7e,$fe,$fa,$ff,$fa,$7c
 .BYTE $c4,$82,$80,$40,$00,$26,$10
; FRAME 5
 .BYTE $3c,$7e,$7e,$ff,$d7,$ff,$ee,$fe
 .BYTE $53,$41,$00,$08,$00,$64,$08
; FRAME 6
 .BYTE $3c,$7e,$7e,$ff,$d7,$ff,$ee,$fe
 .BYTE $53,$41,$04,$20,$04,$28,$40
; FRAME 7
 .BYTE $3c,$7e,$7e,$ff,$eb,$ff,$77,$7f
 .BYTE $ca,$82,$20,$04,$20,$14,$02
; FRAME 8
 .BYTE $3c,$7e,$7e,$ff,$eb,$ff,$77,$7f
 .BYTE $ca,$82,$00,$10,$00,$26,$10
; FRAME 9
 .BYTE $3c,$7e,$7e,$7e,$7e,$7f,$3d,$3c
 .BYTE $0e,$2f,$06,$04,$60,$28,$08
; FRAME 10
 .BYTE $3c,$7e,$7e,$7e,$3f,$7f,$7c,$3e
 .BYTE $0f,$0f,$06,$10,$00,$34,$10
; FRAME 11
 .BYTE $3c,$7e,$7e,$7e,$fc,$fe,$3e,$7c
 .BYTE $f0,$f0,$60,$08,$00,$2c,$08
; FRAME 12
 .BYTE $3c,$7e,$7e,$7e,$7e,$fe,$bc,$3c
 .BYTE $70,$f4,$70,$20,$06,$14,$10
; FRAME 13
 .BYTE $3c,$7e,$7e,$ff,$ff,$ff,$7e,$7f
 .BYTE $c3,$82,$40,$00,$00,$14,$10
; FRAME 14
 .BYTE $3c,$7e,$7e,$ff,$ff,$ff,$7e,$fe
 .BYTE $c3,$41,$02,$00,$00,$28,$08
; FRAME 15
 .BYTE $3c,$7e,$ff,$ff,$eb,$ff,$76,$fe
 .BYTE $c3,$41,$02,$00,$20,$28,$08
; FRAME 16
 .BYTE $3c,$7e,$ff,$ff,$eb,$ff,$76,$7f
 .BYTE $c3,$82,$40,$00,$04,$14,$10
kateP1DATA:
; FRAME 1
 .BYTE $3c,$7e,$5e,$2f,$2f,$0f,$26,$07
 .BYTE $1b,$39,$1c,$38,$1c,$64,$08
; FRAME 2
 .BYTE $3c,$7e,$5e,$2f,$2f,$0f,$27,$06
 .BYTE $1b,$1b,$39,$10,$3c,$00,$38
; FRAME 3
 .BYTE $3c,$7e,$7a,$f4,$f4,$f0,$e4,$60
 .BYTE $d8,$d8,$9c,$08,$3c,$00,$1c
; FRAME 4
 .BYTE $3c,$7e,$7a,$f4,$f4,$f0,$e4,$60
 .BYTE $dc,$9c,$b8,$1c,$3c,$26,$10
; FRAME 5
 .BYTE $3c,$66,$42,$ab,$ab,$83,$d6,$c6
 .BYTE $6b,$39,$18,$30,$7c,$64,$08
; FRAME 6
 .BYTE $3c,$66,$42,$ab,$ab,$83,$d6,$c6
 .BYTE $6b,$79,$38,$1c,$7c,$28,$40
; FRAME 7
 .BYTE $3c,$66,$42,$d5,$d5,$c1,$6b,$63
 .BYTE $d6,$9e,$1c,$38,$3e,$14,$02
; FRAME 8
 .BYTE $3c,$66,$42,$d5,$d5,$c1,$6b,$63
 .BYTE $d6,$9c,$18,$0c,$3e,$26,$10
; FRAME 9
 .BYTE $3c,$7e,$7e,$3e,$3e,$1f,$1d,$1c
 .BYTE $1e,$1f,$1e,$38,$5c,$20,$08
; FRAME 10
 .BYTE $3c,$7e,$7e,$3e,$5f,$1f,$1c,$1e
 .BYTE $1f,$1f,$1e,$08,$3c,$24,$10
; FRAME 11
 .BYTE $3c,$7e,$7e,$7c,$fa,$f8,$38,$78
 .BYTE $f8,$f8,$78,$10,$3c,$24,$08
; FRAME 12
 .BYTE $3c,$7e,$7e,$7c,$7c,$f8,$b8,$38
 .BYTE $78,$f8,$78,$1c,$3a,$04,$10
; FRAME 13
 .BYTE $3c,$7e,$7e,$ff,$ff,$ff,$7e,$7f
 .BYTE $db,$bc,$18,$1c,$3c,$04,$10
; FRAME 14
 .BYTE $3c,$7e,$7e,$ff,$ff,$ff,$7e,$fe
 .BYTE $db,$3d,$18,$38,$3c,$20,$08
; FRAME 15
 .BYTE $3c,$66,$c3,$95,$95,$c3,$6e,$e6
 .BYTE $db,$3d,$18,$38,$1c,$20,$08
; FRAME 16
 .BYTE $3c,$66,$c3,$95,$95,$c3,$6e,$67
 .BYTE $db,$bc,$18,$1c,$38,$04,$10

nerdP0DATA
; FRAME 1
 .BYTE $40,$40,$7e,$7e,$42,$42,$18,$3c
 .BYTE $3c,$3c,$3c,$1c,$18,$18,$38
; FRAME 2
 .BYTE $40,$40,$7e,$7e,$42,$42,$18,$3c
 .BYTE $fc,$3e,$1e,$3e,$36,$36,$7c
; FRAME 3
 .BYTE $02,$02,$7e,$7e,$42,$42,$18,$3c
 .BYTE $3f,$7c,$78,$7c,$6c,$6c,$3e
; FRAME 4
 .BYTE $02,$02,$7e,$7e,$42,$42,$18,$3c
 .BYTE $3c,$3c,$3c,$38,$18,$18,$1c
; FRAME 5
 .BYTE $50,$78,$ae,$ac,$78,$50,$08,$1c
 .BYTE $3c,$3e,$7e,$b8,$18,$10,$30
; FRAME 6
 .BYTE $50,$78,$ae,$ac,$78,$50,$08,$1c
 .BYTE $3c,$3c,$3c,$3e,$36,$6c,$6c
; FRAME 7
 .BYTE $0a,$1e,$75,$35,$1e,$0a,$10,$38
 .BYTE $3c,$3c,$3c,$7c,$6c,$36,$36
; FRAME 8
 .BYTE $0a,$1e,$75,$35,$1e,$0a,$10,$38
 .BYTE $3c,$7c,$7e,$1d,$18,$08,$0c
; FRAME 9
 .BYTE $40,$70,$7c,$4e,$42,$12,$18,$38
 .BYTE $3c,$3c,$1c,$1c,$38,$38,$18
; FRAME 10
 .BYTE $40,$70,$7c,$4e,$42,$12,$98,$78
 .BYTE $3c,$3c,$3e,$7e,$6c,$2c,$04
; FRAME 11
 .BYTE $02,$0e,$3e,$72,$42,$48,$19,$1e
 .BYTE $3c,$3c,$7c,$7e,$36,$34,$20
; FRAME 12
 .BYTE $02,$0e,$3e,$72,$42,$48,$18,$1c
 .BYTE $3c,$3c,$38,$38,$1c,$1c,$18
; FRAME 13
 .BYTE $c3,$81,$81,$81,$00,$18,$7e,$ff
 .BYTE $ff,$bd,$a5,$a4,$64,$04,$06
; FRAME 14
 .BYTE $c3,$81,$81,$81,$00,$18,$7e,$ff
 .BYTE $ff,$bd,$a5,$25,$26,$20,$60
; FRAME 15
 .BYTE $00,$e7,$bd,$e7,$42,$18,$7e,$ff
 .BYTE $ff,$bd,$a5,$a4,$64,$04,$06
; FRAME 16
 .BYTE $00,$e7,$bd,$e7,$42,$18,$7e,$ff
 .BYTE $ff,$bd,$a5,$25,$26,$20,$60
nerdP1DATA:
; FRAME 1
 .BYTE $58,$7c,$7e,$7e,$7e,$5a,$18,$3c
 .BYTE $34,$34,$34,$14,$10,$18,$38
; FRAME 2
 .BYTE $58,$7c,$7e,$7e,$7e,$5a,$18,$3c
 .BYTE $0c,$3c,$1c,$3c,$34,$36,$7c
; FRAME 3
 .BYTE $1a,$3e,$7e,$7e,$7e,$5a,$18,$3c
 .BYTE $30,$3c,$38,$3c,$2c,$6c,$3e
; FRAME 4
 .BYTE $1a,$3e,$7e,$7e,$7e,$5a,$18,$3c
 .BYTE $2c,$2c,$2c,$28,$08,$18,$1c
; FRAME 5
 .BYTE $78,$7c,$fe,$ae,$7c,$78,$18,$1c
 .BYTE $38,$38,$3c,$38,$18,$10,$30
; FRAME 6
 .BYTE $78,$7c,$fe,$ae,$7c,$78,$18,$1c
 .BYTE $34,$34,$2c,$2e,$36,$6c,$6c
; FRAME 7
 .BYTE $1e,$3e,$7f,$75,$3e,$1e,$18,$38
 .BYTE $2c,$2c,$34,$74,$6c,$36,$36
; FRAME 8
 .BYTE $1e,$3e,$7f,$75,$3e,$1e,$18,$38
 .BYTE $1c,$1c,$3c,$1c,$18,$08,$0c
; FRAME 9
 .BYTE $78,$7c,$7c,$7e,$7e,$1e,$18,$38
 .BYTE $2c,$2c,$0c,$0c,$28,$38,$18
; FRAME 10
 .BYTE $78,$7c,$7c,$7e,$7e,$1e,$18,$38
 .BYTE $1c,$3c,$3c,$7c,$6c,$2c,$04
; FRAME 11
 .BYTE $1e,$3e,$3e,$7e,$7e,$78,$18,$1c
 .BYTE $38,$3c,$3c,$3e,$36,$34,$20
; FRAME 12
 .BYTE $1e,$3e,$3e,$7e,$7e,$78,$18,$1c
 .BYTE $34,$34,$30,$30,$14,$1c,$18
; FRAME 13
 .BYTE $ff,$ff,$ff,$ff,$3c,$18,$7e,$7e
 .BYTE $7e,$3c,$24,$24,$64,$04,$06
; FRAME 14
 .BYTE $ff,$ff,$ff,$ff,$3c,$18,$7e,$7e
 .BYTE $7e,$3c,$24,$24,$26,$20,$60
; FRAME 15
 .BYTE $3c,$ff,$bd,$ff,$7e,$18,$66,$66
 .BYTE $66,$24,$24,$24,$64,$04,$06
; FRAME 16
 .BYTE $3c,$ff,$bd,$ff,$7e,$18,$66,$66
 .BYTE $66,$24,$24,$24,$26,$20,$60

;********************************************************************************
;DEAD
;********************************************************************************
DEADP0DATA:
; FRAME 1
 .BYTE $1C,$3e,$3e,$3e,$3e,$3e,$3c,$38
 .BYTE $3f,$3f,$7e,$20,$38,$1e,$06
; FRAME 2
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$3c,$38
 .BYTE $3c,$7f,$3b,$20,$06,$1e,$18
; FRAME 3
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$3c,$1c
 .BYTE $fc,$fc,$7e,$04,$1c,$78,$60
; FRAME 4
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$3c,$1c
 .BYTE $3c,$fe,$dc,$04,$60,$78,$18
; FRAME 5
 .BYTE $1c,$3e,$3f,$3f,$3f,$3e,$3e,$fc
 .BYTE $7f,$7f,$3f,$0e,$30,$36,$06
; FRAME 6
 .BYTE $1c,$3e,$3f,$3f,$3f,$3e,$3e,$3c
 .BYTE $fe,$7e,$7e,$08,$06,$36,$30
; FRAME 7
 .BYTE $38,$7c,$fc,$fc,$fc,$7c,$7c,$3f
 .BYTE $fe,$fe,$fc,$70,$0c,$6c,$60
; FRAME 8
 .BYTE $38,$7c,$fc,$fc,$fc,$7c,$7c,$3c
 .BYTE $7f,$7e,$7e,$10,$60,$6c,$0c
; FRAME 9
 .BYTE $1c,$3e,$3e,$3e,$3e,$3c,$bc,$7c
 .BYTE $7c,$7f,$3f,$06,$00,$46,$30
; FRAME 10
 .BYTE $1c,$3e,$3e,$3e,$3e,$3c,$3c,$bc
 .BYTE $7c,$6e,$76,$06,$40,$38,$06
; FRAME 11
 .BYTE $38,$7c,$7c,$7c,$7c,$3c,$3d,$3e
 .BYTE $3e,$fe,$fc,$60,$00,$62,$0c
; FRAME 12
 .BYTE $38,$7c,$7c,$7c,$7c,$3c,$3c,$3d
 .BYTE $3e,$76,$6e,$60,$02,$1c,$60
; FRAME 13
 .BYTE $18,$4c,$6c,$6c,$7c,$7d,$3b,$ff
 .BYTE $fe,$fc,$60,$0c,$0c,$0c,$60
; FRAME 14
 .BYTE $18,$4c,$6c,$6c,$7c,$7c,$b9,$ff
 .BYTE $ff,$7e,$0c,$60,$60,$60,$0c
; FRAME 15
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$1e,$7f
 .BYTE $ff,$ff,$7e,$06,$30,$30,$06
; FRAME 16
 .BYTE $1c,$3e,$3e,$3e,$3e,$3e,$5c,$fc
 .BYTE $ff,$7f,$3f,$30,$06,$36,$30
DEADP1DATA:
; FRAME 1
 .BYTE $1c,$3e,$2e,$2e,$1e,$38,$24,$0f
 .BYTE $38,$33,$00,$3e,$3e,$1e,$06
; FRAME 2
 .BYTE $1c,$3e,$2e,$2e,$1e,$34,$0c,$3c
 .BYTE $33,$00,$27,$3e,$1e,$1e,$18
; FRAME 3
 .BYTE $38,$7c,$74,$74,$78,$1c,$24,$f0
 .BYTE $1c,$cc,$00,$7c,$7c,$78,$60
; FRAME 4
 .BYTE $38,$7c,$74,$74,$78,$2c,$30,$3c
 .BYTE $cc,$00,$e4,$7c,$78,$78,$18
; FRAME 5
 .BYTE $1c,$3e,$3f,$2b,$2b,$36,$3e,$23
 .BYTE $7c,$41,$01,$30,$3e,$36,$06
; FRAME 6
 .BYTE $1c,$3e,$3f,$17,$17,$2e,$3a,$26
 .BYTE $1c,$5a,$42,$36,$3e,$36,$30
; FRAME 7
 .BYTE $38,$7c,$fc,$d4,$d4,$6c,$7c,$c4
 .BYTE $3e,$82,$80,$0c,$7c,$6c,$60
; FRAME 8
 .BYTE $38,$7c,$fc,$e8,$e8,$74,$5c,$64
 .BYTE $38,$5a,$42,$6c,$7c,$6c,$0c
; FRAME 9
 .BYTE $1c,$3e,$3e,$3e,$3e,$3c,$0c,$3c
 .BYTE $5a,$41,$01,$38,$3e,$76,$30
; FRAME 10
 .BYTE $1c,$3e,$3e,$3e,$3e,$3c,$1c,$3c
 .BYTE $1a,$50,$48,$38,$7e,$3e,$06
; FRAME 11
 .BYTE $38,$7c,$7c,$7c,$7c,$3c,$30,$3c
 .BYTE $5a,$82,$80,$1c,$7c,$6e,$0c
; FRAME 12
 .BYTE $38,$7c,$7c,$7c,$7c,$3c,$38,$3c
 .BYTE $58,$0a,$12,$1c,$7e,$7c,$60
; FRAME 13
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$7c,$3a
 .BYTE $82,$80,$1c,$7c,$7c,$6c,$60
; FRAME 14
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$7c,$38
 .BYTE $82,$02,$70,$7c,$7c,$6c,$0c
; FRAME 15
 .BYTE $1c,$3e,$3e,$2a,$2a,$36,$7d,$00
 .BYTE $1d,$49,$40,$38,$3e,$36,$06
; FRAME 16
 .BYTE $1c,$3e,$3e,$2a,$2a,$76,$3c,$03
 .BYTE $40,$5d,$09,$0e,$3e,$36,$30
;********************************************************************************
; Jack O Lantern
;********************************************************************************
JakoP0DATA:
; FRAME 1
 .BYTE $00,$36,$7e,$7f,$5f,$7f,$27,$0f
 .BYTE $4f,$3e,$3e,$24,$18,$1e,$06
; FRAME 2
 .BYTE $00,$36,$7e,$7f,$5f,$7f,$77,$2f
 .BYTE $1f,$7e,$7e,$00,$06,$1e,$18
; FRAME 3
 .BYTE $00,$6c,$7e,$fe,$fa,$fe,$ee,$f4
 .BYTE $f8,$7e,$7e,$00,$60,$78,$18
; FRAME 4
 .BYTE $00,$6c,$7e,$fe,$fa,$fe,$e4,$f0
 .BYTE $f2,$7c,$7c,$24,$18,$78,$60
; FRAME 5
 .BYTE $00,$2c,$7e,$7f,$d7,$ff,$ab,$43
 .BYTE $66,$7e,$3c,$0c,$30,$36,$06
; FRAME 6
 .BYTE $00,$2c,$7e,$7f,$d7,$ff,$ab,$43
 .BYTE $7e,$7e,$3c,$0c,$06,$36,$30
; FRAME 7
 .BYTE $00,$34,$7e,$fe,$eb,$ff,$d5,$c2
 .BYTE $7e,$7e,$3c,$30,$60,$6c,$0c
; FRAME 8
 .BYTE $00,$34,$7e,$fe,$eb,$ff,$d5,$c2
 .BYTE $66,$7e,$3c,$30,$0c,$6c,$60
; FRAME 9
 .BYTE $36,$73,$7f,$7f,$7f,$7f,$3e,$3c
 .BYTE $3e,$7f,$7f,$00,$30,$36,$06
; FRAME 10
 .BYTE $32,$77,$7f,$7f,$7f,$7f,$7f,$3e
 .BYTE $1e,$1e,$3e,$20,$06,$36,$30
; FRAME 11
 .BYTE $6c,$ce,$fe,$fe,$fe,$fe,$7c,$3c
 .BYTE $7c,$fe,$fe,$00,$0c,$6c,$60
; FRAME 12
 .BYTE $4c,$ee,$fe,$fe,$fe,$fe,$fe,$7c
 .BYTE $78,$78,$7c,$04,$60,$6c,$0c
; FRAME 13
 .BYTE $64,$fe,$fe,$fe,$fe,$fe,$fe,$fe
 .BYTE $fe,$fe,$70,$0c,$0c,$6c,$60
; FRAME 14
 .BYTE $6c,$f6,$fe,$fe,$fe,$fe,$fe,$fe
 .BYTE $fe,$7e,$1c,$60,$60,$6c,$0c
; FRAME 15
 .BYTE $00,$36,$7f,$7f,$6b,$7f,$55,$63
 .BYTE $3e,$3f,$3f,$61,$46,$36,$30
; FRAME 16
 .BYTE $00,$36,$7f,$7f,$6b,$7f,$55,$41
 .BYTE $2b,$3e,$7f,$61,$31,$36,$06
JakoP1DATA:
; FRAME 1
 .BYTE $0c,$08,$00,$20,$30,$00,$00,$00
 .BYTE $00,$c0,$3a,$3a,$06,$00,$00
; FRAME 2
 .BYTE $0c,$08,$00,$20,$30,$00,$00,$00
 .BYTE $c0,$20,$3a,$1e,$18,$00,$00
; FRAME 3
 .BYTE $30,$10,$00,$04,$0c,$00,$00,$00
 .BYTE $03,$04,$5c,$78,$18,$00,$00
; FRAME 4
 .BYTE $30,$10,$00,$04,$0c,$00,$00,$00
 .BYTE $00,$03,$5c,$5c,$60,$00,$00
; FRAME 5
 .BYTE $18,$10,$00,$28,$6c,$00,$00,$80
 .BYTE $40,$42,$26,$3e,$06,$00,$00
; FRAME 6
 .BYTE $18,$10,$00,$28,$6c,$00,$00,$80
 .BYTE $40,$42,$26,$3e,$30,$00,$00
; FRAME 7
 .BYTE $0c,$08,$00,$14,$36,$00,$00,$01
 .BYTE $02,$42,$64,$7c,$0c,$00,$00
; FRAME 8
 .BYTE $0c,$08,$00,$14,$36,$00,$00,$01
 .BYTE $02,$42,$64,$7c,$60,$00,$00
; FRAME 9
 .BYTE $08,$0c,$00,$00,$00,$00,$80,$e0
 .BYTE $7e,$3e,$3e,$3e,$06,$00,$00
; FRAME 10
 .BYTE $0c,$08,$00,$00,$00,$00,$00,$80
 .BYTE $fe,$7e,$1e,$1e,$38,$00,$00
; FRAME 11
 .BYTE $10,$30,$00,$00,$00,$00,$01,$07
 .BYTE $7e,$7c,$7c,$7c,$60,$00,$00
; FRAME 12
 .BYTE $30,$10,$00,$00,$00,$00,$00,$01
 .BYTE $7f,$7e,$78,$78,$1c,$00,$00
; FRAME 13
 .BYTE $18,$00,$00,$00,$00,$00,$82,$c6
 .BYTE $ff,$7d,$7c,$70,$70,$00,$00
; FRAME 14
 .BYTE $10,$08,$00,$00,$00,$00,$82,$c7
 .BYTE $fd,$7e,$7c,$1c,$1c,$00,$00
; FRAME 15
 .BYTE $0c,$08,$00,$14,$36,$00,$00,$00
 .BYTE $00,$03,$7e,$3e,$38,$00,$00
; FRAME 16
 .BYTE $0c,$08,$00,$14,$36,$00,$00,$00
 .BYTE $00,$42,$3f,$3e,$0e,$00,$00
;********************************************************************************
;JSon
;********************************************************************************
JsonP0DATA:
; FRAME 1
 .BYTE $10,$18,$08,$28,$3c,$1e,$18,$e0
 .BYTE $64,$24,$20,$1e,$1e,$3e,$0e
; FRAME 2
 .BYTE $10,$18,$08,$28,$3c,$1e,$f8,$70
 .BYTE $20,$22,$02,$1e,$1e,$1e,$38
; FRAME 3
 .BYTE $08,$18,$10,$14,$3c,$78,$1e,$0c
 .BYTE $08,$08,$00,$78,$78,$78,$1c
; FRAME 4
 .BYTE $08,$18,$10,$14,$3c,$78,$18,$1c
 .BYTE $1c,$14,$10,$78,$78,$7c,$70
; FRAME 5
 .BYTE $0c,$1e,$1e,$0a,$0a,$1f,$ff,$6c
 .BYTE $28,$22,$12,$1f,$1b,$3b,$07
; FRAME 6
 .BYTE $08,$1e,$1e,$0a,$0a,$1f,$1f,$fc
 .BYTE $68,$24,$25,$1f,$1b,$1f,$38
; FRAME 7
 .BYTE $30,$78,$78,$78,$50,$d0,$f8,$38
 .BYTE $7c,$64,$48,$f8,$d8,$dc,$e0
; FRAME 8
 .BYTE $10,$78,$78,$78,$50,$d0,$f8,$78
 .BYTE $38,$34,$a4,$f8,$d8,$f8,$1c
; FRAME 9
 .BYTE $00,$20,$20,$20,$20,$20,$20,$5c
 .BYTE $41,$01,$38,$3e,$76,$3e,$06
; FRAME 10
 .BYTE $00,$20,$20,$20,$20,$20,$20,$1c
 .BYTE $20,$20,$02,$3e,$3e,$76,$30
; FRAME 11
 .BYTE $00,$04,$04,$04,$04,$04,$07,$3a
 .BYTE $82,$80,$1c,$7c,$6e,$7c,$60
; FRAME 12
 .BYTE $00,$08,$08,$08,$08,$08,$08,$7e
 .BYTE $0c,$08,$80,$f8,$f8,$dc,$18
; FRAME 13
 .BYTE $00,$00,$00,$00,$00,$44,$38,$00
 .BYTE $00,$80,$40,$7c,$7c,$6c,$60
; FRAME 14
 .BYTE $00,$00,$00,$00,$00,$44,$38,$00
 .BYTE $00,$02,$04,$7c,$7c,$6c,$0c
; FRAME 15
 .BYTE $00,$1c,$3e,$2a,$2a,$3e,$3e,$7e
 .BYTE $5c,$48,$01,$26,$3e,$36,$30
; FRAME 16
 .BYTE $00,$1c,$3e,$3e,$2a,$2a,$3e,$3e
 .BYTE $1d,$49,$40,$32,$3e,$36,$06
JsonP1DATA:
; FRAME 1
 .BYTE $0c,$06,$16,$16,$06,$06,$0f,$1f
 .BYTE $1f,$3e,$3e,$00,$00,$38,$0e
; FRAME 2
 .BYTE $0c,$06,$16,$16,$06,$06,$0f,$0f
 .BYTE $3f,$3f,$1e,$00,$00,$1e,$38
; FRAME 3
 .BYTE $30,$60,$68,$68,$60,$60,$60,$70
 .BYTE $f8,$f8,$f8,$00,$00,$78,$1c
; FRAME 4
 .BYTE $30,$60,$68,$68,$60,$60,$70,$60
 .BYTE $64,$fc,$f8,$00,$00,$1c,$70
; FRAME 5
 .BYTE $02,$01,$01,$15,$15,$01,$01,$12
 .BYTE $37,$3f,$0f,$00,$00,$38,$07
; FRAME 6
 .BYTE $06,$01,$01,$15,$15,$01,$01,$02
 .BYTE $17,$3f,$3e,$00,$00,$07,$38
; FRAME 7
 .BYTE $40,$80,$80,$80,$a8,$a8,$80,$40
 .BYTE $84,$dc,$f0,$00,$00,$1c,$e0
; FRAME 8
 .BYTE $60,$80,$80,$80,$a8,$a8,$80,$00
 .BYTE $c0,$ec,$7c,$00,$00,$e0,$1c
; FRAME 9
 .BYTE $1c,$1e,$1e,$1e,$1e,$1e,$1c,$7e
 .BYTE $7f,$3f,$06,$00,$40,$38,$06
; FRAME 10
 .BYTE $1c,$1e,$1e,$1e,$1e,$1e,$1c,$1e
 .BYTE $3e,$3e,$3c,$00,$08,$46,$30
; FRAME 11
 .BYTE $38,$78,$78,$78,$78,$78,$38,$7c
 .BYTE $fe,$fc,$60,$00,$02,$1c,$60
; FRAME 12
 .BYTE $70,$f0,$f0,$f0,$f0,$f0,$70,$f0
 .BYTE $f0,$f8,$78,$00,$20,$c4,$18
; FRAME 13
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$fe,$fe
 .BYTE $fe,$fe,$3c,$0c,$0c,$2c,$60
; FRAME 14
 .BYTE $38,$7c,$7c,$7c,$7c,$7c,$fe,$fe
 .BYTE $fe,$fe,$78,$60,$60,$68,$0c
; FRAME 15
 .BYTE $1c,$22,$08,$14,$14,$08,$41,$01
 .BYTE $63,$77,$3f,$1e,$06,$06,$30
; FRAME 16
 .BYTE $1c,$22,$00,$08,$14,$14,$49,$41
 .BYTE $63,$37,$7e,$3c,$30,$34,$06
;********************************************************************************
;Drac
;********************************************************************************
DracP0DATA:
; FRAME 1
 .BYTE $00,$1c,$26,$07,$06,$35,$24,$ca
 .BYTE $67,$6f,$3a,$3a,$06,$00,$00
; FRAME 2
 .BYTE $1c,$26,$07,$06,$35,$25,$08,$02
 .BYTE $e7,$6b,$5a,$1e,$18,$00,$00
; FRAME 3
 .BYTE $38,$64,$e0,$60,$ac,$a4,$00,$ef
 .BYTE $fc,$fc,$78,$78,$70,$00,$00
; FRAME 4
 .BYTE $00,$38,$64,$e0,$60,$ac,$04,$e0
 .BYTE $e7,$fc,$7c,$78,$08,$00,$00
; FRAME 5
 .BYTE $1e,$3f,$2d,$09,$37,$14,$00,$f5
 .BYTE $55,$03,$1f,$1f,$03,$00,$00
; FRAME 6
 .BYTE $1e,$3e,$2d,$09,$36,$14,$00,$01
 .BYTE $f4,$56,$1f,$1f,$18,$00,$00
; FRAME 7
 .BYTE $3e,$7e,$6d,$44,$1b,$4a,$00,$20
 .BYTE $7a,$5a,$5e,$3e,$30,$00,$00
; FRAME 8
 .BYTE $3e,$3e,$4d,$44,$1b,$4a,$00,$2a
 .BYTE $7e,$60,$6e,$3e,$06,$00,$00
; FRAME 9
 .BYTE $3e,$7f,$7f,$7f,$7f,$7f,$9e,$e0
 .BYTE $7e,$3e,$3e,$3e,$06,$00,$00
; FRAME 10
 .BYTE $3e,$7f,$7f,$7f,$7f,$7f,$3e,$98
 .BYTE $e6,$7e,$1e,$1e,$38,$00,$00
; FRAME 11
 .BYTE $7c,$fe,$fe,$fe,$fe,$fe,$79,$07
 .BYTE $7e,$7c,$7c,$7c,$60,$00,$00
; FRAME 12
 .BYTE $7c,$fe,$fe,$fe,$fe,$fe,$7c,$19
 .BYTE $67,$7e,$78,$78,$1c,$00,$00
; FRAME 13
 .BYTE $7c,$fe,$fc,$7c,$7c,$78,$ba,$c6
 .BYTE $fe,$7c,$7c,$1c,$1c,$00,$00
; FRAME 14
 .BYTE $7c,$fe,$7e,$7c,$7c,$3c,$9a,$c6
 .BYTE $fe,$7c,$7c,$70,$70,$00,$00
; FRAME 15
 .BYTE $3e,$7f,$5d,$49,$36,$14,$41,$d5
 .BYTE $f7,$20,$3e,$3f,$0e,$06,$00
; FRAME 16
 .BYTE $3e,$7f,$5d,$49,$36,$14,$41,$41
 .BYTE $76,$d4,$9f,$3f,$38,$30,$00
DracP1DATA:
; FRAME 1
 .BYTE $00,$00,$18,$38,$39,$0a,$5a,$34
 .BYTE $38,$30,$04,$04,$18,$1e,$06
; FRAME 2
 .BYTE $00,$18,$38,$39,$0a,$5a,$76,$3c
 .BYTE $38,$34,$24,$20,$06,$1e,$18
; FRAME 3
 .BYTE $00,$18,$1c,$9c,$50,$5a,$7e,$10
 .BYTE $04,$04,$00,$00,$0c,$6c,$60
; FRAME 4
 .BYTE $00,$00,$18,$1c,$9c,$50,$7a,$1e
 .BYTE $18,$04,$04,$00,$60,$6c,$0c
; FRAME 5
 .BYTE $00,$00,$12,$36,$08,$2b,$3f,$16
 .BYTE $36,$7d,$01,$00,$18,$1b,$03
; FRAME 6
 .BYTE $00,$00,$12,$36,$09,$2b,$3f,$1e
 .BYTE $17,$3d,$20,$00,$06,$1e,$18
; FRAME 7
 .BYTE $00,$00,$12,$3b,$64,$35,$3f,$1e
 .BYTE $03,$2f,$20,$00,$06,$36,$30
; FRAME 8
 .BYTE $00,$00,$32,$3b,$64,$35,$3f,$1a
 .BYTE $02,$1e,$10,$00,$18,$1e,$06
; FRAME 9
 .BYTE $00,$00,$00,$00,$00,$00,$20,$1c
 .BYTE $00,$41,$41,$00,$30,$36,$06
; FRAME 10
 .BYTE $00,$00,$00,$00,$00,$00,$40,$26
 .BYTE $18,$00,$20,$20,$06,$36,$30
; FRAME 11
 .BYTE $00,$00,$00,$00,$00,$00,$04,$38
 .BYTE $00,$82,$82,$00,$0c,$6c,$60
; FRAME 12
 .BYTE $00,$00,$00,$00,$00,$00,$02,$64
 .BYTE $18,$00,$04,$04,$60,$6c,$0c
; FRAME 13
 .BYTE $00,$00,$02,$82,$82,$86,$44,$38
 .BYTE $00,$02,$00,$60,$60,$6c,$0c
; FRAME 14
 .BYTE $00,$00,$80,$82,$82,$c2,$64,$38
 .BYTE $00,$80,$00,$0c,$0c,$6c,$60
; FRAME 15
 .BYTE $00,$00,$22,$36,$49,$6b,$3e,$36
 .BYTE $14,$5f,$41,$00,$30,$30,$06
; FRAME 16
 .BYTE $00,$00,$22,$36,$49,$6b,$3e,$3e
 .BYTE $15,$3f,$60,$40,$06,$06,$30
;********************************************************************************
;Fran
;********************************************************************************
franP0DATA:
; FRAME 1
 .BYTE $1f,$1f,$1f,$3f,$0f,$09,$03,$06
 .BYTE $31,$1f,$07,$0f,$3f,$07,$00
; FRAME 2
 .BYTE $1f,$1f,$1f,$3f,$0f,$09,$03,$06
 .BYTE $01,$3f,$1f,$07,$1f,$38,$00
; FRAME 3
 .BYTE $f8,$f8,$e8,$f4,$f0,$90,$c0,$60
 .BYTE $8c,$f8,$e0,$f0,$f8,$c0,$00
; FRAME 4
 .BYTE $f8,$f8,$e8,$f4,$f0,$90,$c0,$60
 .BYTE $80,$fc,$f8,$e0,$f8,$1c,$00
; FRAME 5
 .BYTE $1f,$1f,$07,$1f,$1d,$09,$19,$1c
 .BYTE $31,$6f,$0f,$1f,$3b,$03,$04
; FRAME 6
 .BYTE $1f,$1f,$07,$1f,$1d,$09,$19,$1c
 .BYTE $11,$3f,$6f,$0f,$1f,$38,$00
; FRAME 7
 .BYTE $f8,$f8,$e0,$f8,$b8,$90,$98,$38
 .BYTE $8e,$fe,$f0,$f8,$dc,$c0,$20
; FRAME 8
 .BYTE $f8,$f8,$e0,$f8,$b8,$90,$98,$38
 .BYTE $88,$fc,$f8,$f0,$f8,$1c,$00
; FRAME 9
 .BYTE $1f,$1f,$0f,$0f,$0f,$0f,$0f,$0e
 .BYTE $41,$3f,$3f,$0f,$1f,$38,$00
; FRAME 10
 .BYTE $1f,$1f,$0f,$0f,$0f,$0f,$0f,$4e
 .BYTE $31,$3f,$0f,$1f,$3b,$07,$00
; FRAME 11
 .BYTE $f8,$f8,$f0,$f0,$f0,$f0,$f1,$72
 .BYTE $82,$fc,$fc,$f0,$f8,$1c,$00
; FRAME 12
 .BYTE $f8,$f8,$f0,$f0,$f0,$f1,$f2,$72
 .BYTE $8c,$fc,$f0,$f8,$dc,$e0,$00
; FRAME 13
 .BYTE $3e,$3e,$3e,$3e,$3e,$3e,$7f,$5d
 .BYTE $63,$3f,$3e,$3e,$36,$30,$00
; FRAME 14
 .BYTE $3e,$3e,$3e,$3e,$3e,$3e,$7f,$5d
 .BYTE $63,$7e,$3e,$3e,$36,$06,$00
; FRAME 15
 .BYTE $3e,$2a,$3a,$3e,$14,$08,$63,$5d
 .BYTE $63,$3f,$3e,$38,$30,$30,$00
; FRAME 16
 .BYTE $3e,$2a,$14,$3e,$14,$08,$7f,$5d
 .BYTE $63,$7e,$3e,$0e,$06,$06,$00
franP1DATA:
; FRAME 1
 .BYTE $00,$14,$1c,$34,$3e,$3e,$1c,$1d
 .BYTE $0e,$08,$08,$00,$30,$3f,$07
; FRAME 2
 .BYTE $00,$14,$1c,$34,$3e,$3e,$1c,$1d
 .BYTE $0e,$00,$08,$08,$07,$3f,$38
; FRAME 3
 .BYTE $00,$28,$38,$2c,$7c,$78,$38,$b8
 .BYTE $70,$10,$10,$00,$0c,$fc,$e0
; FRAME 4
 .BYTE $00,$28,$38,$2c,$7c,$78,$38,$b8
 .BYTE $70,$00,$10,$10,$e0,$fc,$1c
; FRAME 5
 .BYTE $00,$14,$1c,$1e,$0a,$1e,$1e,$02
 .BYTE $1e,$10,$04,$00,$30,$3b,$07
; FRAME 6
 .BYTE $00,$14,$1c,$1e,$0a,$1e,$1e,$02
 .BYTE $1e,$04,$10,$00,$06,$37,$38
; FRAME 7
 .BYTE $00,$28,$38,$78,$50,$78,$78,$40
 .BYTE $7a,$02,$10,$00,$0c,$dc,$e0
; FRAME 8
 .BYTE $00,$28,$38,$78,$50,$78,$78,$40
 .BYTE $78,$04,$24,$00,$60,$ec,$1c
; FRAME 9
 .BYTE $00,$10,$10,$30,$18,$18,$10,$11
 .BYTE $4e,$40,$00,$00,$04,$23,$18
; FRAME 10
 .BYTE $00,$10,$10,$30,$18,$18,$10,$50
 .BYTE $4e,$00,$00,$00,$20,$1c,$03
; FRAME 11
 .BYTE $00,$08,$08,$0c,$18,$18,$08,$88
 .BYTE $72,$02,$00,$00,$20,$c4,$18
; FRAME 12
 .BYTE $00,$08,$08,$0c,$18,$18,$08,$0a
 .BYTE $72,$00,$00,$00,$04,$38,$c0
; FRAME 13
 .BYTE $00,$00,$00,$00,$00,$00,$22,$22
 .BYTE $1c,$40,$01,$00,$00,$06,$30
; FRAME 14
 .BYTE $00,$00,$00,$00,$00,$00,$22,$22
 .BYTE $1c,$01,$40,$00,$00,$30,$06
; FRAME 15
 .BYTE $00,$14,$3e,$3e,$2a,$3e,$3e,$22
 .BYTE $5c,$41,$01,$06,$06,$36,$30
; FRAME 16
 .BYTE $00,$14,$3e,$3e,$2a,$3e,$22,$22
 .BYTE $1d,$41,$40,$30,$30,$36,$06
;********************************************************************************
; Grim
;********************************************************************************
GrimP0DATA:
; FRAME 1
 .BYTE $1e,$3c,$4c,$6c,$2c,$4c,$6c,$5e
 .BYTE $7f,$3f,$5f,$5f,$5f,$5f,$5f
; FRAME 2
 .BYTE $1e,$1e,$0c,$2c,$2c,$0c,$6d,$7e
 .BYTE $1f,$3f,$3f,$3f,$3f,$3f,$3f
; FRAME 3
 .BYTE $78,$3c,$22,$1a,$38,$38,$3a,$7a
 .BYTE $fe,$fc,$fa,$fa,$fa,$fa,$fa
; FRAME 4
 .BYTE $78,$40,$38,$38,$3c,$3c,$3c,$7c
 .BYTE $f8,$fc,$fc,$fc,$fc,$fc,$fc
; FRAME 5
 .BYTE $1f,$3e,$6e,$6a,$12,$06,$7e,$7e
 .BYTE $7f,$3f,$5f,$5f,$5f,$5f,$5f
; FRAME 6
 .BYTE $1f,$3e,$3a,$2a,$52,$46,$7e,$7e
 .BYTE $3e,$7f,$7f,$5f,$5f,$5f,$3f
; FRAME 7
 .BYTE $7c,$3e,$3b,$6b,$84,$20,$3e,$3e
 .BYTE $7e,$7e,$7e,$fc,$fc,$7c,$7c
; FRAME 8
 .BYTE $7c,$3e,$7b,$8b,$24,$30,$3e,$3e
 .BYTE $7e,$7e,$7e,$fe,$fc,$7c,$7c
; FRAME 9
 .BYTE $3c,$78,$78,$78,$78,$78,$38,$f8
 .BYTE $7c,$7c,$7c,$7c,$7e,$3f,$1e
; FRAME 10
 .BYTE $3c,$78,$78,$78,$78,$78,$38,$7c
 .BYTE $7c,$7c,$7c,$7e,$3e,$3e,$1f
; FRAME 11
 .BYTE $7c,$3e,$31,$2f,$1e,$3e,$3f,$3f
 .BYTE $3f,$7e,$7d,$7d,$fd,$fd,$79
; FRAME 12
 .BYTE $7e,$30,$2e,$1e,$3f,$3f,$3f,$3f
 .BYTE $3e,$7f,$7f,$7d,$7d,$fd,$fe
; FRAME 13
 .BYTE $f8,$7c,$62,$5e,$3c,$7c,$7e,$7e
 .BYTE $fe,$fc,$fa,$fa,$fa,$fa,$fa
; FRAME 14
 .BYTE $fc,$60,$5c,$3c,$7e,$7e,$7e,$7e
 .BYTE $7c,$fe,$fe,$fa,$fa,$fa,$fc
; FRAME 15
 .BYTE $1f,$3e,$6e,$6a,$12,$06,$7e,$7e
 .BYTE $7f,$3f,$5f,$5f,$5f,$5f,$5f
; FRAME 16
 .BYTE $1f,$3e,$3a,$2a,$52,$46,$7e,$7e
 .BYTE $3e,$7f,$7f,$5f,$5f,$5f,$3f
GrimP1DATA:
; FRAME 1
 .BYTE $00,$20,$70,$50,$52,$70,$70,$20
 .BYTE $40,$40,$00,$00,$00,$00,$1c
; FRAME 2
 .BYTE $00,$22,$72,$51,$50,$70,$70,$60
 .BYTE $60,$00,$00,$00,$00,$00,$0e
; FRAME 3
 .BYTE $00,$1c,$3e,$26,$42,$06,$00,$00
 .BYTE $02,$02,$00,$00,$00,$00,$38
; FRAME 4
 .BYTE $38,$7c,$44,$84,$00,$00,$00,$04
 .BYTE $04,$00,$00,$00,$00,$00,$70
; FRAME 5
 .BYTE $00,$38,$54,$54,$6c,$78,$00,$38
 .BYTE $40,$46,$06,$00,$00,$00,$00
; FRAME 6
 .BYTE $00,$78,$54,$54,$2c,$38,$38,$40
 .BYTE $40,$0c,$0c,$00,$00,$00,$00
; FRAME 7
 .BYTE $00,$0e,$15,$75,$fb,$9f,$00,$0e
 .BYTE $00,$32,$32,$00,$00,$00,$00
; FRAME 8
 .BYTE $00,$0e,$75,$f5,$9b,$0f,$00,$0e
 .BYTE $30,$30,$02,$02,$00,$00,$00
; FRAME 9
 .BYTE $00,$00,$00,$00,$04,$00,$00,$80
 .BYTE $80,$00,$00,$00,$00,$00,$00
; FRAME 10
 .BYTE $00,$00,$00,$04,$00,$00,$00,$00
 .BYTE $80,$80,$00,$00,$00,$00,$00
; FRAME 11
 .BYTE $00,$0e,$1f,$11,$21,$01,$00,$00
 .BYTE $01,$01,$00,$00,$00,$00,$00
; FRAME 12
 .BYTE $0e,$1f,$11,$21,$00,$00,$00,$01
 .BYTE $01,$00,$00,$00,$00,$00,$00
; FRAME 13
 .BYTE $00,$1c,$3e,$22,$42,$02,$00,$00
 .BYTE $02,$02,$00,$00,$00,$00,$00
; FRAME 14
 .BYTE $1c,$3e,$22,$42,$00,$00,$00,$02
 .BYTE $02,$00,$00,$00,$00,$00,$00
; FRAME 15
 .BYTE $00,$38,$54,$54,$6c,$78,$00,$38
 .BYTE $40,$46,$06,$00,$00,$00,$00
; FRAME 16
 .BYTE $00,$78,$54,$54,$2c,$38,$38,$40
 .BYTE $40,$0c,$0c,$00,$00,$00,$00


 ; *********************************************************************************************************************
; END fighter facing Left Data
; *********************************************************************************************************************
; Player Data for Grave
graveP0DATA:
; FRAME 1
 .BYTE $0e,$1b,$11,$1b,$1b,$1f,$1f,$1f
 .BYTE $1f,$1f,$19,$10,$00,$13,$05,$0c
 .BYTE $00,$4a,$40,$00,$08,$00,$00,$00
graveP1DATA:
; FRAME 1
 .BYTE $00,$00,$00,$00,$00,$00,$00,$00
 .BYTE $00,$0c,$1e,$1f,$3f,$3f,$7f,$7e
 .BYTE $7e,$fe,$fc,$fc,$78,$00,$00,$00

; **********************************************************************************************************
; Multiple Character Data
; **********************************************************************************************************
; Data for Names
NAMES .BYTE "Paul","Jake","Jimi","Todd","Chad","Hank","Kate","Nerd","Drac","Fran","Bone","grim","Jako","JSon"
READY .BYTE "Ready "
spaces .BYTE "      "
LOSER	.BYTE "LOSER " 
WINNER	.BYTE "WINNER" 

FIGHTER1CHARPOS .byte 0
FIGHTER2CHARPOS .byte 1
char1ColorOptions=3
; Color Data for Characters
char1colors .byte $A4,$cA,$44,$4A,$72,$8C ; Paul (Lay)
char2colors .byte $D2,$E8,$F4,$18,$E2,$D6 ; Jake
char3colors .byte $14,$08,$f4,$0c,$24,$1a ; Jim
char4colors .byte $f2,$84,$f2,$b4,$f2,$24 ; Todd
char5colors .byte $0c,$f8,$02,$f8,$f2,$18 ; Chad
char6colors .byte $34,$ea,$44,$ea,$88,$f2 ; Hank   $44,$ea,$34,$ea
char7colors .byte $6e,$8c,$1a,$34,$1a,$c6 ; Kate   $44,$ea,$34,$ea
char8colors .byte $88,$f2,$44,$0e,$34,$ea ; Nerd   $44,$ea,$34,$ea
char9colors .byte $04,$fa,$04,$0a,$04,$0a ; Drac
char10colors .byte $02,$b4,$02,$b4,$02,$b4 ; Fran
hchar11colors .byte $04,$0A,$04,$0A,$04,$0A ; Dead
hchar12colors .byte $04,$0c,$04,$0c,$04,$0c ; Grim
hchar13colors .byte $1a,$c4,$1a,$c4,$1a,$c4 ; Jako
hchar14colors .byte $0c,$22,$0c,$22,$0c,$22 ; JSon

char1currColor .byte 2
char2currColor .byte 2
NAME    .BYTE 'S:',$9B ; $9B is end of line
ROB		.BYTE ' rob schlortt',$9B
Chu1	.BYTE '3456G8%&/(/()*',$9B ; EBH added for top row of WAR ROOM"
bot1	.BYTE '   ^_^_?@-.;<;<=>',$9B ; EBH added for bot row of WAR ROOM" 
ERIC	.BYTE ' eric henneke  ',$9B 
Chu2	.BYTE '!"#$%&G89[9[\]',$9B	; EBH added for top row of WAR ROOM"
bot2	.BYTE '   +,+,-.?@XZXZMQ',$9B ; EBH added for bot row of WAR ROOM"
BY		.BYTE 'by',$9B
VS		.BYTE 'VS',$9B
CPU		.byte     "  CPU:   "
Player1		.byte "Player 1"
Player2		.byte "Player 2"


;5. Reserve Space for Variables
;******************************************************************************
; START of FIGHTER MOVEMENT BLOCK
;******************************************************************************
; EVERYTHING IN THE "STICK 0 VARIABLES" AREA MUST HAVE AN EQUIVALENT VALUE IN THE "STICK 1 VARIABLES" AREA
; AND EACH VARIABLE HAS TO BE IN THE SAME ORDER
;STICK 0 VARIABLES
fighterhordirection NOP ; 0 = left 1=right
fighterhoradding nop
fighterHorState NOP ; 0 - STILL, 1 - WALK, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
LASTfighterHorState NOP
hspeedsum NOP
hsubspeedsum NOP
hsubhspeedadd nop
hspeedmax NOP
hspeedadd NOP
currrotate nop ; Fighter0 frame rotation counter
fightervertdirection NOP ; 0 = left 1=right
fighterVERTadding nop
fighterVERTState NOP ; 0 - STILL, 1 - WALK, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
LASTfighterVERTState NOP
vspeedsum NOP
vsubspeedsum NOP
vsubvspeedadd nop
vspeedmax NOP
vspeedadd NOP
ACTIONS0 NOP
NEWACTIONS0 NOP
legsstate nop ; 0 still facing right, 1 walking right, 2 facing left, 3 walking left
pixeladd nop
vpixeladd nop
PREVfighterX NOP
prevfightery nop
ychanged nop
currframePTR nop
fighterx NOP
fightertopy nop
HPIXREMAINDER NOP
fighter1p0datalo NOP
fighter1p0datahi nop
fighter1p1datalo NOP
fighter1p1datahi nop
currfighter1char .byte 1 ;nop
;STICK 1 VARIABLES
fighterhordirection1 NOP ; 0 = left 1=right
fighterhoradding1 nop
fighterHorState1 NOP ; 0 - STILL, 1 - WALK, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
LASTfighterHorState1 NOP
hspeedsum1 NOP
hsubspeedsum1 NOP
hsubhspeedadd1 nop
hspeedmax1 NOP
hspeedadd1 NOP
currrotate1 nop ; Fighter1 frame rotation counter

fightervertdirection1 NOP ; 0 = left 1=right
fighterVERTadding1 nop
fighterVERTState1 NOP ; 0 - STILL, 1 - WALK, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
LASTfighterVERTState1 NOP
vspeedsum1 NOP
vsubspeedsum1 NOP
vsubvspeedadd1 nop
vspeedmax1 NOP
vspeedadd1 NOP
ACTIONS1 NOP
NEWACTIONS1 NOP
legsstate1 nop ; 0 still facing right, 1 walking right, 2 facing left, 3 walking left
pixeladd1 nop
vpixeladd1 nop
PREVfighterX1 NOP
prevfightery1 nop
ychanged1 nop
currframePTR1 nop
fighterx1 NOP
fightertopy1 nop
HPIXREMAINDER1 NOP
fighter2p0datalo NOP
fighter2p0datahi nop
fighter2p1datalo NOP
fighter2p1datahi nop
currfighter2char .byte 0
printmode nop
Bullets0 nop
Bullets1 nop
lifes0 nop
lifes1 nop
last20 nop
lastdeath0 NOP
LASTDEATH1 NOP

;******************************************************************************
; End of FIGHTER MOVEMENT BLOCK
;******************************************************************************

;******************************************************************************
; Character Control Mapping Addresses
;******************************************************************************
currchar1control .byte 0;0 ; Default to Stick 0
currchar2control .byte 2;1 ; Default to cpu
currchar1controlhold nop
currchar2controlhold nop

LeftCharControl NOP
RightCharControl NOP
leftcharbutton nop
Rightcharbutton nop

defaultbgc .byte 0
BACKGROUNDCOLOR .byte 0

; *****************************************************************************
; START OF PAIR VARIABLES BLOCK
; ****************************************************************************
; EVERYTHING IN THIS BLOCK MUST HAVE A VARIABLE FOR FIGHTER0 FOLLOWED BY A VARIABLE FOR FIGHTER1
CHECKVERT NOP
bulldef nop
bull1def nop
prevbulletx nop
prevbullet1x nop
bulletx nop
bullet1x nop
bullety nop
bullet1y nop
prevbullety nop
prevbullet1y nop
bulletinair nop
bullet1inair nop
HORBULLETINC NOP
HORBULLETINC1 NOP
VERTBULLETINC NOP
VERTBULLETINC1 NOP
releaseordelay nop
releaseordelay1 nop
firedelay .byte 0
firedelay2 .byte 0
slowshot .byte 0
slowshot2 .byte 0
; *****************************************************************************
; END OF PAIRS VARIABLES BLOCK
; ****************************************************************************
DLICTR NOP ; ONLY LEFT IN BECAUSE DEAD CODE REFERENCES IT.
tempx nop
TEMPY NOP
GAMEON NOP
hasrunonce nop ; Flag to determine whether to run initial setup (set up, turn on vbi, config memory, etc)
LMSHIGHHOLD nop ; used in screen setup
LMSLOWHOLD nop
Flash1 nop ; not currently used.  Used to make a color register flash
Flash2 nop ; not currently used.  Used to make a color register flash
LEFTPIXEL nop
GRAVEDELAY NOP
BULLETDISPLAYED .BYTE 0
BULLETDISPLAYED1 .BYTE 0

BULLETPACKY NOP
BULLETPACKY1 NOP
BULLETPACKX NOP
BULLETPACKX1 NOP
BULLETTIMER NOP
BULLETTIMER1 NOP

PREVCHAR NOP
PREVCHAR1 NOP

bulletpackpy .byte 0
bulletpackpy1 .byte 0

bulletpackpx .byte 0 
bulletpackpx1 .byte 0 

reachedxtarget .byte 0
reachedx2target .byte 0
reachedytarget .byte 0
reachedy2target .byte 0
;***************************************************************************
; AI Memlocs
;***************************************************************************
CPULeftAggression nop
CPURightAggression nop
currgraphicsmode nop
ydiff nop
xdiff nop
shootatplayer nop
lastshootatplayer nop
asrun nop
shootatplayerright nop
lastshootatplayerright nop
asrunright nop

distaboveslime nop
distbelowslime nop
distleftofslime nop
distrightofslime nop

;abbuc .byte "ABBUC Software Wettbewerb 2017"
;abbuc .byte  " xxxx v2 Eval " 
abbuc .byte "Copyright 2017"
fighter1wins .byte 0
fighter2wins .byte 0
fighter1winshold .byte 0
fighter2winshold .byte 0
player1ready .byte 0
player2ready .byte 0
winsrequired .byte 3
Round .byte 0
hween .byte "Halloween 2017"
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - VARIABLES - START
freq1 nop
ofreq1 nop
cntrl1 nop
trgt1 nop
dura1 nop
dstp1 nop
fad1 nop
lopc1 nop
freq2 nop
ofreq2 nop
cntrl2 nop
trgt2 nop
dura2 nop
dstp2 nop
fad2 nop
lopc2 nop
dlirun nop
consoldelay=12
consolcheck .byte 0

NOTE		.byte 0, 0
NOTETIMER	.word 0, 0, 0, 0
PLAYAUDC	.byte 0
PLAYNOTE	.byte 0
POKEYOffset	.byte 0, 2, 4, 6
SAVANTIC nop ; EBH - variable to save antic value
attracton .byte 0
ATTRACT = $4d
CH = $2fc
TRIG0 = $d010
TRIG1 = $d011
AUDF1 = $d200
AUDC1 = $d201
AUDC2 = $d203
AUDC3 = $d205
AUDC4 = $d207
AUDCTL = $d208



; SOUND - VARIABLES - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Courtesy of Peter Dell - Disable Basic
LOADER LDA $d301   ;Disable BASIC bit in PORTB for MMU
       ORA #$02
       STA $d301
       LDA #$01    ;Set BASICF for OS, so BASIC remains OFF after RESET
       STA $3f8

       lda #$c0    ;Check if RAMTOP is already OK
       CMP $6a     ;This prevent flickering if BASIC is already off
       BEQ RAMOK
       STA $6a     ;Set RAMTOP to end of BASIC

       LDA $e401   ;Open "E:" to ensure screen is not at $9C00
       PHA         ;This prevents garbage when loading up to $bc000
       LDA $e400
       PHA
RAMOK  RTS

       INI LOADER  ;Make sure the loader is execute before main program is loaded
; *************************************************************************************************************
; 6. Assembly Execution Starts Here. Program Initialization
;*************************************************************************************************************
start
	lda LMSHIGH
	sta LMSHIGHHOLD
	LDA LMSLOW
	STA LMSLOWHOLD
	LDA #0
	STA GAMEON ; GameOn has GameState.  0=Game Over 1=Active Game
	sta hasrunonce
	JSR RUNONCE
	lda #showTitleScreen ; allows developer to skip title screen when debugging
	beq gamescreen 
	jmp titleScreen 
gamescreen	LDA #GRAPHICSMODE ; graphics 12
	jsr Graphics
	LDA #PFCOLOR0  ; EBH - added here to prevent border from changing between rounds on NTSC
	STA COLOR0 ; EBH - added here to prevent border from changing between rounds on NTSC
	lda #1 ; ebh 
	sta $5691 ; ebh set $5691 = #1, to reset grave drawn flag to NOT drawn yet
; ******************************************************************************************************
; FOR ATARI 800 - Manually update the Display list since our 800 didn't know what GR 12 is.
; ******************************************************************************************************	
	lda $230
	sta storedlistupdate+1
	sta loaddlistupdate+1
	sta setdliline+1
	lda $231
	sta storedlistupdate+2
	sta loaddlistupdate+2
	sta setdliline+2
	ldx #29
loaddlistupdate lda $ac20,x ; temp placeholder
	cmp #2
	Beq changeto4
	cmp #$42
	bne skipstore
changeto4	and #%11111101 ; remove 2
	ora #%00000100 ; add 4
storedlistupdate sta $AC20,x ; temp placeholder
skipstore	dex
	cpx #3
	bcs loaddlistupdate
; ******************************************************************************************************
; FOR ATARI 800 end - 
; ******************************************************************************************************
; Turn On DLI on 2nd line
	lda #dlion
	ldx #6
setdliline	sta dli,x
	LDA #192
	STA 54286 ; Enable DLI
	lda >charset ; Load HighByte of Charset
	sta chbas ; Store in CHBAS to reference custom character set
	
	lda #62 ; 32+16+12+2
	sta SDMCTL ; turn on FETCH DMA, HI-RES PLAYERS, PLAYERS AND MISSILES AND STANDARD PLAYFIELD WIDTH 
	lda #3
	sta GRACTL ; TURN ON PLAYERS AND MISSILES
	jsr initvariables
	
	; SET BULLET X&Y POSITIONS TO 0
	LDA #0 
	sta bulletpackpx
	sta bulletpackpx1
	sta bulletpackpy
	sta bulletpackpy1
	
	; Set all Player and Missile Horizontal Values to 0
	sta	P0X ;=53248
	sta P1X;=53249
	sta P2X;=53250
	sta P3X;=53251
	sta M0X;=53252
	sta M2X;=53254
	sta M3X;=53255

	sta 40018 ; I don't know what this address is... 
	sta 40016 ; no clue about this one either.
	jsr clearplayers	
	lda #1
	sta CURSORINHIBIT ; Don't show the cursor (on the title screen)
	JSR screenSetup ; Go Setup the screen
; Transfer our color stores to the color shadow registers
	LDA #PFCOLOR0 
	STA COLOR0 
	lda #PFCOLOR2
	sta COLOR2
	LDA #INVERSECOLOR
	STA COLOR3
	LDA BACKGROUNDCOLOR
	STA COLOR4 	
	
	gprior=623	; this should really be in the CIO equates section.  Who put it here?
	LDA #49 ; #32 OVERLAPPED PLAYERS HAVE 3RD COLOR + #16 4 MISSILES = 5TH PLAYER - + #8 - PF 0&1, PM, PF 2,3,BAK priority
	Sta GPRIOR  ; SET MISSILES AND PLAYERS with above attributes and priorities 
	lda #0   ; More of Eric's sound stuff.
	sta $D208 ; initiatlize pokey to address audio registers directly
	lda #3 
	sta $D20F ; initiatlize pokey to address audio registers directly
	sta $232  ; initiatlize pokey to address audio registers directly
	JMP MAINLOOP
jmprunoncepersecond jmp runoncepersecond ; JMP because too many bytes away for a branch.
JMPRUNFULLSPEED JMP RUNFULLSPEED ; another JMP - wow - that is really inefficient...

; *************************************************************************
;* 7.                        START of  MAIN LOOP
; *************************************************************************
mainloop    ; start of mainloop
; attract mode bail on Joystick or button press
	lda AttractOn ; Attract is our demo mode.  If AttractOn=1 we are in Demo Mode.  0 = real game
	beq realgame
	lda strig0
	and strig1
	bne checkjoystick ; IF Both Strig0 and Strig1 = 1 then a person didn't push a button.
jmpenddemo	jmp enddemo
checkjoystick lda #15
	cmp stick0
	bne jmpenddemo
	cmp stick1
	bne jmpenddemo ; if someone moved a stick then stop the demo
	lda fighter1wins
	ora fighter2wins
	bne jmpenddemo ; if one of the CPUs won a round then stop the demo
;attractmode bailout end
realgame	lda #3 ; we are in a real game
	sta gractl ; Not sure why we need another #3 in gractl
	lda rtclockJiffy ;  Load RTClock address 20
	cmp LAST20 ; compare to the last time you saved it
	bEQ jmprunFULLSPEED ; If it = the last save then go run the full speed code
	CMP #60 ; If 20=#60 then we will reset it
	BNE CHECKGAMEOVER ; otherwise, we will go run the once per jiffy code
	lda #0
	sta rtclockJiffy
;	JMP RUNONCEPERSECOND
;******************************************************************
;* 7.a.                  start of once per jiffy JSRs                 *
;******************************************************************
;****************************************************************************************************
;****************************************************************************************************
;JJJJJJJJJ 
;    jj                                           kk
;    jj                       tt    ii            kk
;    jj   ooo  yy   yy  sss   tt           ccc    kk        
;    jj  oo oo  yy yy  sss   ttttt  ii    cc  c   kk  kk
;jj  jj  oo oo   yy      ss   tt    ii    cc      kkkk
; jjjj    ooo    yy    sss    tt    ii     ccc    kk  kk
;****************************************************************************************************
;****************************************************************************************************
; STICK 0/
CHECKGAMEOVER 
	LDX LIFES0
	bne checkfighter2 ; if LifeS0>0 then check fighter 2's lives
	inc fighter2wins ; if LifeS0=0 then inc Fighter 2 wins.  Note: if there is a tie, both fighter's wins get incremented
	; this is really tricky - before calling Drawgrave, you have to load the player number in x.  Since X=0 because LifeS0=0, we already have the correct number in X.
	jsr Drawgrave ; draw Player 0's grave. 
checkfighter2	lda LIFES1 ; Same checks we did for fighter 0
	BNE checkgameover2
	inc fighter1wins
	ldx #1 ; but we have to load the one this time
	jsr Drawgrave
	jmp gameover0	
checkgameover2 
	lda $5691 ; ebh check if grave was drawn $5691 = #0, set in drawgrave routine
	bne jmpCheckCPULeft
gameover0
	jsr GraveSound ; ebh - added to make gravesound a callable routine 
	jmp checkfighter1win ; ebh - added to make gravesound a callable routine
GraveSound  ; ; ebh - added to make gravesound a callable routine
;SOUND - ENDOFGAME - START
    lda #206 ; 202
    sta CNTRL1
	lda #200
	sta $d200
	lda #201
	sta $d202
	lda #14
	sta dura1
	lda #255 
	sta dura2
	jmp eogsnd
jmpCheckCPULeft jmp CheckCPULeft
eogsnd 
    lda CNTRL1
	sta $d201
	sta $d203
	DEC CNTRL1
	ldy dura1
	BNE DECDURAEOG
	jmp XSNDEOG
DECDURAEOG	
	LDX #5
DELOOP	
	sta $d40a    ; wsync
	DEX
	BNE DELOOP
	dec dura2
	lda dura2
	BNE DECDURAEOG
	LDA #190
	STA dura2
	DEC dura1
	jmp eogsnd
XSNDEOG
	RTS ; ebh - added to make gravesound a callable routine 
;SOUND - ENDOFGAME - END 	
checkfighter1win ; ebh - added to make gravesound a callable routine
	LDA fighter1wins
	cmp fighter2wins
	beq startnextround ; we can't end the game in a tie...
	cmp winsrequired ; if fighter1wins> wins required then game over
	bcs gameisover
checkfighter2win	LDA fighter2wins
	cmp winsrequired
	bcs gameisover	; if fighter2wins> wins required then game over
startnextround ldx #255 ; game is not over so we are "falling through" to start next round
countdown	dex	
	bne countdown ; we are counting down from #255 to give the players a chance to look at my beautiful grave graphic.
; Since one of the players was changed to grave colors and I am too lazy to bother to figure out which fighter needs its colors fixed, i will just reset both of the fighters' colors.
	lda char1currColor
	ldY currfighter1char 
	jsr changecolorssub
	sty 704
	sta 705
	lda currfighter1char
	jsr stacurrfighter1char ;changefighter1character
 	lda char2currColor	
	ldY currfighter2char 
	jsr changecolorssub
	sty 706
	sta 707
	inc round ; next round let's inc.  Have you ever wondered why INC takes up so many cycles?
	jmp startround ; GOTO Start New Round. Apologies to Edsger Dijkstra, may he rest in peace.
gameisover lda #24  ; change color at EOG to a lovely brown color
    sta 708
writeGAMEOVER ; have fun digesting this part.  I got a headache, but somehow, the characters look like the words "GAME OVER" but in a really bad font.
	JSR SETTOPOFSCREENMEMORY ;reset scrlo
	LDy #12 
	JSR SETYLINE ; MOVE ONE LINE DOWN TO LINE 6
	LDY #14 ; 20-(11/2)-1
	ldx #0
writegameoverloop	LDA #42+128 ; GAMEOVER STARTS WITH THE 42nd Character - Inverse (+128) is white.
	STA (SCRLO),Y
    iny
    inc writegameoverloop+1
    inx
    cpx #11
    bcc writegameoverloop  
; WOW!  That block above is a perfect example of the code you write when the ABBUC deadline is approaching.  Completely unreadable!

    lda #42+128 ; reset for next time
	sta writegameoverloop+1 ; This is a very poor example of self-modifying code.   
donewithwriteGameover	LDA #0
	STA releaseordelay ; Release or delay are used to make sure that holding the button down doesn't just jump right into another game unless a human releases and presses the button or there is a small delay.
	STA releaseordelay1
	STA 19 ; Reset RTCLOCK 19.
GRAVEDELAYLOOP	LDA GRAVEDELAY ; somehow this leaves the grave on the screen for a while.
	BEQ GAMEOVERLOOP
	LDA 19
	BEQ GRAVEDELAYLOOP
	LDA 0
	STA 19
	DEC GRAVEDELAY
	JMP GRAVEDELAYLOOP
GAMEOVERLOOP
	LDA #255  
	STA $21C
	LDA #4    ; EBH - adjust to shorten or lengthen delay on GAME OVER screen
	STA $21D	
gameoverloopin ; inc 708  ; if you want border to flash at EOG	
	ldx $21c ; EBH - added to rotate colors at GAME OVER 
	stx 711  ; EBH - added to rotate colors at GAME OVER 
	lda $21d
	BEQ jmpgototitlescreen
; I hate to complain about my beloved 8 bit, but those CONSOL keys are a bit convoluted.
	lda CONSOL ; EBH - added bail out of game with start key - start 
	cmp #7
	bcs STRIGEOG ; if >= 7 no consol button pressed;  EBH skip check for skid and skid sound stuff
	lda $22f
	sta SAVANTIC
	lda #0
	sta $22f
	jsr clearplayers
	JSR KEYLOOPE
STRIGEOG	
	lda strig0 ;leftcharbutton
	beq jmpgototitlescreen
	lda strig1 ;Rightcharbutton
	bne gameoverloopin
	lda #1
	sta gameon
jmpgototitlescreen		sta attract ; reset attract mode
	JMP gotoTITLESCREEN
; #########################################################################################
; CurrChar1Control: 2=CPU, 1=Stick1, 0=Stick0
; CurrChar2Control: 2=CPU, 1=Stick1, 0=Stick0
; The control scheme for this game is that Fighter 0 is controlled by the values in CurrChar1Control. 
; All movement is made with joystick values so that CPU movement is translated to Joystick directions. 

; (JOYSTICK 0)
; set fighter Move State
CheckCPULeft lda Currchar1Control
	CMP #2
	bne checkCPURight
	jsr CPULeftChar
CheckCPURight lda Currchar2Control
	cmp #2
	bne loadleftCharcontrol
	jsr CPURightChar


loadLeftCharControl	lda LeftCharControl 
; CHECK TO SEE IF STICK HAS BEEN CHANGED
	CMP ACTIONS0
	BNE NEWACTIONS0TRUE
	LDX #0
	beq STXNEWACTIONS0
bails0 jmp checkRightCharControl	
NEWACTIONS0TRUE	LDX #1
STXNEWACTIONS0 STX NEWACTIONS0
	sta ACTIONS0
;####################################################################
; 1. check and update hor fighterstate
;  - if accel set to run (may change to walk later)
;  States: Accelerate, Skid, Decel or do nothing 
;####################################################################
	;PASS SOME SORT OF X VALUE
	LDX #0 ; FOR LeftCharControl
	JSR UPDATEHORSTATE
;####################################################################
; 2. check and update vert fighterstate
;  - if accel set to run (may change to walk later) 
;  States: Accelerate, Skid, Decel or do nothing
;####################################################################
	LDX #0 ; FOR LeftCharControl
	JSR UPDATEVERTSTATE	

;####################################################################
; 3. Change fighterhorstate and Set Hor Speed based on Hor fighter State and vert fighter state
; H    V     - HORIZONTAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################
	LDX #0
	JSR CHECKDIAGONALHORIZONTAL

;####################################################################
; 4. Set Vert Speed based on vert fighter state and Hor fighter State 
; V    H     - VERTICAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################

	LDX #0 ;PASS SOME SORT OF X VALUE	
	JSR CHECKDIAGONALVERTICal
;####################################################################
; 5. Set currframeptr based on STICK
;####################################################################
	lda LeftCharControl
	LDX #0
	JSR POINTCHARACTERDIRECTION

;####################################################################
; 6. set horizontal physics based on fighterhorstate
;####################################################################
	;PASS SOME SORT OF X VALUE	
	LDX #0
	jsr hphysicsS0
;####################################################################
; 7. set vertical physics based on fightervertstate
;####################################################################
	;PASS SOME SORT OF X VALUE	
	LDX #0
	jsr vphysics

;####################################################################
; 8. Check For Decel
;####################################################################
	ldx #0
	JSR CHECKFORDECEL
;####################################################################
; 9. Check Fire Button
;####################################################################
; testtest
; (JOYSTICK 1)
checkRightCharControl	lda RightCharControl ; 632	
; CHECK TO SEE IF STICK HAS BEEN CHANGED
	CMP ACTIONS1
	BNE NEWACTIONS1TRUE
	LDX #0
	beq STXNEWACTIONS1
	
;bails1 jmp checkshoot	
NEWACTIONS1TRUE	LDX #1
STXNEWACTIONS1 STX NEWACTIONS1
	sta ACTIONS1
;####################################################################
; 1. check and update hor fighterstate
;  - if accel set to run (may change to walk later)
;  States: Accelerate, Skid, Decel or do nothing 
;####################################################################
	;PASS SOME SORT OF X VALUE
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR UPDATEHORSTATE
;####################################################################
; 2. check and update vert fighterstate
;  - if accel set to run (may change to walk later) 
;  States: Accelerate, Skid, Decel or do nothing
;####################################################################
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR UPDATEVERTSTATE	

;####################################################################
; 3. Change fighterhorstate and Set Hor Speed based on Hor fighter State and vert fighter state
; H    V     - HORIZONTAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR CHECKDIAGONALHORIZONTAL

;####################################################################
; 4. Set Vert Speed based on vert fighter state and Hor fighter State 
; V    H     - VERTICAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################

	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR CHECKDIAGONALVERTICal
;####################################################################
; 5. Set currframeptr based on STICK
;####################################################################
	LDA RightCharControl
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR POINTCHARACTERDIRECTION

;####################################################################
; 6. set horizontal physics based on fighterhorstate
;####################################################################
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl

	jsr hphysicsS0
;####################################################################
; 7. set vertical physics based on fightervertstate
;####################################################################
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl

	jsr vphysics
;####################################################################
; 8. Check For Decel
;####################################################################
	LDX #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR CHECKFORDECEL
;####################################################################
; 9. Check Fire Button
;####################################################################
	LDX #0
	LDY #0
	JSR CHECKSHOOT
CHECKRightcharbutton	LDX #1
	LDY #fighterhordirection1-fighterhordirection ; FOR RightCharControl
	JSR CHECKSHOOT
endjoystick 
;****************************************************************************************************
;****************************************************************************************************
;END JOYSTICK
;****************************************************************************************************
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	lda CONSOL ; EBH - added bail out of game with start key - start 
	cmp #7 ; 7 means no key is pressed
	bcs sound ;If >=7 no consol button pressed  EBH skip check for skid and skid sound stuff - RES - Added Option and Select Bail
; Our Demo is over, we need to clean everything up
enddemo	jsr quiet ; jsr to routine to silence all channels
	lda $22f ; you get 10 points if you knew this was SDMCTL
	sta SAVANTIC ; Store the current value in SDMCTL because we are going to...
	lda #0 ;..turn off..
	sta $22f ; ...ANTIC!  Look how fast that happened
	sta AttractOn ; Turn Demo Mode Off
	lda fighter1winshold ; restore Fighter 1 wins to value before demo so we can see who won the last game
	sta fighter1wins
	lda fighter2winshold ; do the same thing for fighter 2
	sta fighter2wins	
	jsr clearplayers ; erase the players
KEYLOOPE lda CONSOL 
	and #%00000001 ; start not pressed
	BEQ KEYLOOPE ; EBH - changed to delay start until start key is released after pressed
	lda SAVANTIC ; restore previous value to SDMCTL
	sta $22f ; back on already?  That was fast.
	lda currchar1controlhold ; restore the fighter 1 control to the value it had before the demo
	sta currchar1control
	lda currchar2controlhold ; same for fighter 2
	stA currchar2control
	jmp gototitlescreen ; EBH - added bail out of game with start key - END
 

sound ; ask Eric about this because Rob has no clue...
    lda freq1
	sta $d200
	lda cntrl1
	sta $d201
	ldy dura1
	cpy	#0
	BNE DECDURA1
	LDA #0
	STA $d200
	STA $D201
	sta freq1
	sta cntrl1
	jmp XSND1
DECDURA1	
	DEC dura1
	INC freq1
	INC freq1
XSND1 NOP
	lda freq2
	sta $d202
	lda cntrl2
	sta $d203
	ldy dura2
	cpy	#0
	BNE DECDURA2
	LDA #0
	STA $d202
	STA $D203
	sta freq2
	sta cntrl2
	jmp XSND2
DECDURA2
;	LDA lopc2
;	CMP #0
;	BEQ DECLOP2
;	jmp xsnd2
DECLOP2 
;    DEC lopc2	
	DEC dura2
;;	ldy trgt2
;;	cpy freq2
;;	BNE INCFREQ2
;;	lda ofreq2
;;	sta freq2
;;	jmp xsnd2
INCFREQ2
    INC freq2
	INC freq2
XSND2 NOP
; SOUND - MAINTENANCE IN 1 JIFFY INTERVALS  - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;******************************************************************	
;*                    end of once per jiffy JSRs                  *
;******************************************************************
runOncePerSecond	LDA rtClockJiffy
	BEQ INC20TIMER 
	JMP runFullSpeed
INC20TIMER	INC rtclockJiffy
	lda slowshot
	beq firedelay2dec
	sec
	sbc #1
	sta slowshot	
firedelay2dec 	lda slowshot2
	beq donewithfiredelay2
	sec
	sbc #1
	sta slowshot2
donewithfiredelay2	
;******************************************************************
;*  7.b.                 start of once per Second JSRs                 *
;******************************************************************
; DRAW BULLET PACKS

	ldx #0
	jsr drawbulletpacks; bullet packs only appear once per second...
	ldx #bulletdisplayed1-bulletdisplayed
	jsr drawbulletpacks
	LDA #0 ; CHANGE SLIME TO ONLY REDUCE 1 LIFE PER SECONDE
	STA	lastdeath1
	STA lastdeath0
	jsr slimelogic
	
;******************************************************************
;*                   end of once per Second JSRs                 *
;******************************************************************
runfullSpeed

;******************************************************************
;*                   start of Full Speed JSRs                 *
;******************************************************************
; Looks like nothing runs full speed
;******************************************************************
;*                   end of Full Speed JSRs                 *
;******************************************************************
	jmp mainloop ; end of mainloop
; *************************************************************************
;*                         END of  MAIN LOOP
; *************************************************************************

; **********************************************************************************************************
; 8. Subroutines Start
; **********************************************************************************************************
SLIMELOGIC
; GROWING SLIME
; Slime was intended to be a wild card in the game, but most games don't last long enough for it to matter.
	LDA RANDOM
	BMI VERTSLIME	
	LDA RANDOM
	BMI SUBTRACT
	lda slimex
	clc
	adc #1
	cmp SlimeMaxx ; SlimeMaxx is the largest X value of slime.  Used to help CPU Avoid slime
	beq staslimex
	bcc staslimex
	tax
	sta SlimeMaxx
	lda slimemaxpx
	clc
	adc #4
	sta slimemaxpx
	txa
staslimex	STA SLIMEX
	JMP VERTSLIME
SUBTRACT lda SLIMEX
	sec
	sbc #1
	cmp SlimeMinX ;Used to help CPU Avoid slime
	bcs staslimex2
	sta slimeminx
	tax
	lda slimeminPx
	sec
	sbc #4
	sta slimeminPx
	txa
staslimex2 sta slimex
VERTSLIME	LDA $D20A
	BMI PLOTSLIME
	LDA $D20A
	BMI SUBTRACTVERT
	lda slimey
	clc 
	adc #1
	cmp #24; fix Slime Bug
	bcc csmxy ; fix Slime Bug
	lda #23 ; Fix Slime Bug
csmxy	cmp slimemaxy ;Used to help CPU Avoid slime
	beq staslimey
	bcc staslimey
	sta slimemaxy
	tax
	lda slimemaxpy
	clc
	adc #8
	sta slimemaxpy
	txa
staslimey	sta SLIMEY
	JMP PLOTSLIME
SUBTRACTVERT lda slimey
	sec
	sbc #1
	bpl csm ; fix Slime Bug
	lda #1 ; Fix Slime Bug
csm	cmp slimeminy
	bcs staslimey2
	sta slimeminy ;Used to help CPU Avoid slime
	tax
	lda slimeminpy
	sec
	sbc #8
	sta slimeminpy
	txa
staslimey2 sta slimey 
PLOTSLIME 	JSR SETTOPOFSCREENMEMORY ;reset scrlo
	LDy SLIMEY 
	JSR SETYLINE ; MOVE ONE LINE DOWN TO LINE 6
	LDY SLIMEX ;HERE HERE HERE
	LDA (SCRLO),Y
;NEXT LINES PROTECT WALLS FROM SLIME. IF EXISTING CHARACTER IS 11 OR 10, DON'T DRAW THE SLIME
	CMP #0 ;12
	BNE DONEWITHSLIME
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - SLIME GROWING - START
; we chose not to use a slime growing sound because it would have been too scary
; SOUND - SLIME GROWING  - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	LDA #1
	STA (SCRLO),Y
DONEWITHSLIME rts
convertoPAL ldy #7 ; RES Convert PAL Speed - Adjustments to make PAL as fast as NTSC.
PWDYLOOP	lda PalRUNdata,y
	sta RUNdata,y
	dey
	bpl pwdyloop
	lda PALskids 
	sta SKID+1
	sta vSkid+1
	lda PALskidss
	sta firstSkidss+1
	sta secondSkidSS+1
    lda #0
;	sta missilewidth+1  ; EBH - commented this line out so bullets stay wide in PAL
	rts ; END RES Convert PAL Speed
CPUEvacuate rts ;wow, this looks like dead code.
	lda #0
	sta reachedxtarget,x
	sta reachedytarget,x
	lda fighterx,y
	cmp #128
	bcc load192
	lda #64
	bPL stabpxx
load192 lda #192
stabpxx	sta BULLETPACKpx,x
CPUEvacuateY	; the idea behind evacuate was that if the CPU was being hit, it should run away (to anywhere)
	lda fightertopy,y
	cmp #128
	bcc lda192y
	lda #64
	bne stabppyx
lda192y lda #192
stabppyx	sta BULLETPACKpy,x
	rts	
;##############################################################################################################
; Sound - Theme Song - start
;##############################################################################################################
musicsub ; All this music stuff is Eric's	
playloop	; EBH - changed delay so PAL and NTSC music is same speed - start

			ldy tv
MULOOP	
			sta $d40a    ; wsync
			dey
			bne MULOOP	; EBH - changed delay so PAL and NTSC music is same speed - end
			lda #1
			sta ATTRACT

			inc NOTETIMER			; increase timer
			bne donetimer0
donetimer0	inc NOTETIMER+2
			bne donetimer1
donetimer1	inc NOTETIMER+4
			bne donetimer2
donetimer2	inc NOTETIMER+6
			bne exitcond
exitcond	lda PLAYPTR+1			; check end of music
			cmp NOTEPTR+1
			bcc doplay
			lda PLAYPTR
			cmp NOTEPTR
			bcs exitplay

doplay		ldy #0
			lda (PLAYPTR),y
			tax						; voice to X
			iny
			lda (PLAYPTR),y
			sta PLAYAUDC			; save AUDC-value
			iny
			lda (PLAYPTR),y
			sta PLAYNOTE			; save note
			iny
			lda (PLAYPTR),y
			sta PLAYTIMER			; save timer low-byte
			iny
			lda POKEYOffset,x
			tay						; Offset to Y
waittimer	lda NOTETIMER,y
			cmp PLAYTIMER			; Playtimer >= Notetimer (low byte)?
			bcc jmploop
			lda #0					; First reset counters...
			sta PLAYTIMER
			sta NOTETIMER,y
			lda PLAYAUDC			; then play note...
			sta AUDC1,y
			lda PLAYNOTE
			sta AUDF1,y
			clc
			lda PLAYPTR
			adc #$04	; increase pointer (was #$05, changed to compress music data)
			sta PLAYPTR
			bcc exitcond
			lda PLAYPTR+1
			adc #0
			sta PLAYPTR+1
			jmp exitcond
jmploop		RTS   ;jmp playloop
			
exitplay	ldy #3
			lda #0
clearplayer	sta NOTETIMER,y
			sta NOTETIMER+4,y
			sta AUDC1,y
			sta AUDC1+4,y
			dey
			bpl clearplayer
			lda #$04 ; low byte of starting position
            sta $cd
            lda #$50 ; high byte of starting position
            sta $ce
            ldy $5690  ; EBH - MEMLOC TO STORE HOW MANY TIME MUSIC LOOP PLAYED - START
			iny
			cpy #MusicLoopsBeforeAttract      ; EBH - HOM MANY TIME YOU WANT MUSIC TO LOOP
			beq demotime  ; EBH - JUMP OUT IF PLAYED 2 TIMES
			sty $5690   ;EBH - MUSIC LOOP COUNT - END 
            jmp DOPLAY	
;##############################################################################################################
; Sound - Theme Song - END
;##############################################################################################################

demotime jmp startdemo  ; EBH - STUB ENDLESS LOOP

;##############################################################################################################
; Display Bullets and Lives at top of GameScreen - Start
;##############################################################################################################

calcbulletdisp sec
	sbc bullets0,x
	beq twobullets ; if 0, there are no bullets
	bmi twobullets 
	cmp #1
	beq writebullets ; 1 bullet 
nobullets1 lda #0 ; if here, there are no bullets
	beq writebullets	
twobullets lda #2
writebullets clc	
	adc #13+inverse ;will be 13, 14 or 15 - 0 bullets, 1 bullet or 2 bullets
; The Bullets were defined as Character #13, 14 and 15.  The +128 uses 5th (inverse) color.
	rts
calclivesdisp cmp #3
	bcs threelives
	clc
	rts  
threelives lda #3
	clc	
	rts

;##############################################################################################################
; Display Bullets and Lives at top of GameScreen - End
;##############################################################################################################
;##############################################################################################################
; Change Fighter Subroutine - Start
;##############################################################################################################
; This routine will read the high and low addresses from the tables:
; characterp0datalo
; characterp0datahi
; characterp1datalo
; characterp1datahi
; This information is then used to override the target address of the data read.
; For Example: 
; Command at Compile time: LOADPO LDA P0Data
; LDA #<FranP0Data ; Load lo byte address of Fran's player Data
; STA LOADP0+1
; LDA #>FranP0Data ; Load hi byte address of Fran's player Data
; STA LOADP0+2
; Result after: LOADPO LDA FranP0Data
changefighter2character 	lda currfighter2char
retry clc	
	adc #1
checkdouble	cmp currfighter1char
	beq retry ; if same character as player 1, skip that character
	cmp numcharacters
	bcc stacurrfighter2char
	lda #0
	beq checkdouble
changefighter2characterleft 	lda currfighter2char
retryleft sec	
	sbc #1
	bmi lessthan0
checkdoubleleft	cmp currfighter1char
	bne stacurrfighter2char
	jmp retryleft
lessthan0	lda numcharacters
	sec
	sbc #1
	jmp checkdoubleleft
stacurrfighter2char sta currfighter2char
demochangefighter2char	tax ; democharchange
 	lda characterp0datalo,x
	sta	fighter2p0datalo
 	lda characterp0datahi,x
	sta	fighter2p0datahi
 	lda characterp1datalo,x
	sta	fighter2p1datalo
 	lda characterp1datahi,x
	sta	fighter2p1datahi
	rts

changefighter1character	lda currfighter1char
retryc0 clc	
	adc #1
checkdoublec0	cmp currfighter2char
	beq retryc0 ; if same character as player 1, skip that character
	cmp numcharacters
	bcc stacurrfighter1char
	lda #0
	beq checkdoublec0
changefighter1characterleft 	lda currfighter1char
retryleft1 sec	
	sbc #1
	bmi lessthan01
checkdoubleleft1	cmp currfighter2char
	bne stacurrfighter1char
	jmp retryleft1
lessthan01	lda numcharacters
	sec
	sbc #1
	jmp checkdoubleleft1
stacurrfighter1char sta currfighter1char
demochangefighter1char	tax
 	lda characterp0datalo,x
	sta	fighter1p0datalo
 	lda characterp0datahi,x
	sta	fighter1p0datahi
 	lda characterp1datalo,x
	sta	fighter1p1datalo
 	lda characterp1datahi,x
	sta	fighter1p1datahi
	lda #0
	rts
;##############################################################################################################
; Change Fighter Subroutine - End
;##############################################################################################################
;##############################################################################################################
; Adjust Bullet Pack X & Y positions to make sure they stay in bounds - Start
;##############################################################################################################
	
setbulletpackPx tax
	lda #120
	cpx #20
	bcs reduce
	lda #122
increase	inx
	sec   
	sbc #4
	cpx #20
	bcc increase
	jmp stybppx
reduce	dex
	clc   
	adc #4
	cpx #20-1
	bcs reduce
stybppx	rts 
setbulletpackPy tax
	lda #126
	cpx #12
	bcs reducey
increasey	inx
	sec   
	sbc #8
	cpx #12
	bcc increasey
	jmp stybppy
reducey	dex
	clc   
	adc #7
	cpx #12-1
	bcs reducey
stybppy	rts 
;##############################################################################################################
; Adjust Bullet Pack X & Y positions to make sure they stay in bounds - End
;##############################################################################################################


; ************************************************************************
; ************************************************************************
; AI Logic Left START
; ************************************************************************
; ************************************************************************
	
; ************************************************************************
; AI Chase Bullet Packs	
; ************************************************************************
chasebulletpacks LDA reachedxtarget
	beq chbp
	lda reachedytarget
	beq chbp
	jsr cpuevacuate
chbp	lda fighterx
	cmp bulletpackpx
	bne checkgoleft
	sta reachedxtarget
checkgoleft	bcs cpuleftgoleft
cpuleftgoright lda #7
	bne checkvertbp
cpuleftgoleft	lda #11
checkvertbp
; compare bulletpackpx to fighterx
	ldy fightertopy
	cpy bulletpackpy
	bne checkgreaterthan
	sta reachedytarget
checkgreaterthan	bcs cpuleftgoup
cpuleftgodown and #%00001101
	bne jmpaiaimandshoot ;jmpavoidslime
cpuleftgoup	and #%00001110
jmpAIAimAndShoot	jmp AIAimAndShoot
	
jmpaggressivecpuLeft jmp aggressivecpuLeft
CPULeftChar ldx #0 ; to chase bulletpacks 
	lda #15 
	sta leftcharcontrol ; reset stick 
	lda #0
	sta asrun ; debug code to see if avoid slime is executed
	lda #1
	sta leftcharbutton ; reset trigger

	lda bulletpackpx ; check if bulletpack is available
	beq jmpaggressivecpuLeft ; if unavailable be aggressive (start of game)
	ldy bullets0; check if bullet is available
	bne checkbulletinair ; if available, see if bullet is already in air
	jmp chasebulletpacks ; if not available, chase bullet packs
checkbulletinair	lda bulletinair ; check if bullet is in air
	beq setaggression ; if not, set aggression
	jmp chasebulletpacks ; bullet is in air, let's grab bullet packs	
	
; ************************************************************************
; AI Set Aggression	
; ************************************************************************
setaggression	LDA #0
	LDy lifes0
	Cpy lifes1
	beq checkOppBullets 
	bcs add5tox
reducex lda #250
	bne checkOppBullets
add5tox	lda #5
checkOppBullets ldx bullets1
	beq add5moretoagg
	sec
	sbc #5
	jmp checkCPUhasBullets
add5moretoagg clc
	adc #5
checkCPUhasBullets ldx bullets0
	beq subtract10fromagg
	clc
	adc #5
	jmp storeaggression	
subtract10fromagg	sec
	sbc #10		 
storeaggression	stA CPULeftAggression
	bpl jmpaggressivecpuLeft
; ************************************************************************
; AI Aggressive Logic	
; ************************************************************************
aggressivecpuLeft
; 1 - Get Diagonal
; a. Get CPUX - PX
; 2 - if Diagonal, Shoot
	lda LeftCharControl
; xdiff is less than ydiff
	ldx fighterx
	cpx fighterx1
	bcc moveright
moveleft ora #%00001000
	and #%00001011
	bne checkvert2
moveright ora #%00000100
	and #%00000111

checkvert2	ldx fightertopy
	cpx fightertopy1
	bcc movedown
moveup ora #%00000010
	and #%00001110
	bne AIAimandShoot
movedown ora #%00000001
	and #%00001101

; ************************************************************************
; AI Aim and Shoot?	
; ************************************************************************
AIAimandShoot sta leftcharcontrol 
avoidembrace
ldxbulletinair	ldx bulletinair
	bne jmpavoidslime ; bullet is in air - avoid slime
	ldx bullets0
	beq jmpavoidslime	; no bullets avoid slime
	lda fighterx
	cmp fighterx1
	bcc x1isgreater
	sec
	sbc fighterx1
	jmp staxdiff
jmpavoidslime jmp avoidslime
jmpAIStoreDirectionandButton jmp AIStoreDirectionandButton;;
jmpchasebulletpacks jmp chasebulletpacks	
x1isgreater	lda fighterx1
	sec
	sbc fighterx
staxdiff	sta xdiff
; b. Get CPUY - PY
	lda fightertopy
	cmp fightertopy1
	bcc y1isgreater
	sec
	sbc fightertopy1
	jmp staydiff
y1isgreater	lda fightertopy1
	sec
	sbc fightertopy
staydiff sta ydiff
	beq shootleftright
	cmp xdiff
	bne checkstraightshots
	ldx #0 ; 0 means fire because translated to Strig
stxsap	stx shootatplayer
; 2 - if Diagonal, Shoot
;	lda LeftCharControl
; xdiff is less than ydiff
aimdiagonally	ldx fighterx
	cpx fighterx1
	bcc aimright
aimleft lda #11 ;ora #%00001000
;	and #%00001011
	bne checkvertAim
aimright lda #7 ;ora #%00000100
;	and #%00000111
checkvertaim	ldx fightertopy
	cpx fightertopy1
	bcs aimup
aimdown and #%00001101
	jmp AIStoreDirectionandButton
aimup and #%00001110
	jmp AIStoreDirectionandButton
checkstraightshots	lda fightertopy
	sec
	sbc fightertopy1
	and #%01111111
	tax
	lda leftcharcontrol
	cpx #4
	bcc shootleftright
	ldx fighterx
	cpx fighterx1
	bne avoidslime	
shootdownup lda #0
	sta shootatplayer
	lda fightertopy
	cmp fightertopy1
	bcc shootdown
	lda #14
	bne AIStoreDirectionandButton
shootdown	lda #13
	bne AIStoreDirectionandButton
shootleftright lda #0
	sta shootatplayer
	lda fighterx
	cmp fighterx1
	bcc shootright
	lda #11
	bne AIStoreDirectionandButton
shootright	lda #7
	bne AIStoreDirectionandButton
; ************************************************************************
; Help the CPU Avoid Slime	 
; ************************************************************************
avoidslime ldy #1
	sty asrun ; debug code
	sta leftcharcontrol
; gather distances from slime
	lda slimeminpy
	sec
	sbc fightertopy
	sta distaboveslime
	lda fightertopy
	sec
	sbc slimemaxpy
	sta distbelowslime
	lda slimeminpx
	sec
	sbc fighterx
	sta distleftofslime
	lda fighterx
	sec
	sbc slimemaxpx
	sta distrightofslime
	lda leftcharcontrol
	ldx distrightofslime
	bpl rightofslime
leftofslime ldx distaboveslime
	bmi leftandbelowslime
leftandaboveslime	cmp #5
	bne aistoredirectionandbutton
; if here, CPU is running toward slime
	lda #7 ; go right
	bne aistoredirectionandbutton
leftandbelowslime	cmp #6
	bne aistoredirectionandbutton
	lda #14 ; go up
	bne aistoredirectionandbutton
rightofslime ldx distaboveslime
	bmi rightandbelowslime
rightandaboveslime	cmp #9
	bne aistoredirectionandbutton
; if here, CPU is running toward slime
	lda #11 ; go Left
	bne aistoredirectionandbutton
rightandbelowslime	cmp #10
	bne aistoredirectionandbutton
	lda #14 ; go down
	bne aistoredirectionandbutton
; ************************************************************************
; AI Store Direction and bullet	
; ************************************************************************
AIStoreDirectionandButton 	sta leftcharcontrol
;stlcandRTS	
	lda lastshootatplayer
	bne checkfire 
	sta attract ; reset attract mode

	lda #1
	sta shootatplayer
	sta lastshootatplayer
	rts
checkfire	lda shootatplayer
	ora bulletinair
	sta lastshootatplayer
	bne slcright
	nop
slcright	sta leftcharbutton
	rts
; ************************************************************************
; ************************************************************************
; AI Logic Left END
; ************************************************************************
; ************************************************************************
; ************************************************************************
; ************************************************************************
; AI Logic Right START
; ************************************************************************
; Rob's Note - The AI for left and right should be identical, but it is not.  
; .....For some reason, P2 almost always wins CPU vs CPU
; ************************************************************************
	
; ************************************************************************
; AI Chase Bullet Packs	
; ************************************************************************
chasebulletpacksRight	lda fighterx1
	cmp bulletpackpx1
	bcs CPURightgoleft
CPURightgoright lda #7
	bne checkvertbpright
CPURightgoleft	lda #11
checkvertbpright
; compare bulletpackpx to fighterx
	ldy fightertopy1
	cpy bulletpackpy1
	bcs CPURightgoup
CPURightgodown and #%00001101
	bne jmpaiaimandshootright ;jmpavoidslime
CPURightgoup	and #%00001110
jmpAIAimAndShootright	jmp AIAimAndShootright
	
jmpaggressiveCPURight jmp aggressiveCPURight
CPURightChar ldx #0 ; to chase bulletpacks 
	lda #15 
	sta rightcharcontrol ; reset stick 
	lda #0
	sta asrun ; debug code to see if avoid slime is executed
	lda #1
	sta rightcharbutton ; reset trigger

	lda bulletpackpx1 ; check if bulletpack is available
	beq jmpaggressiveCPURight ; if unavailable be aggressive (start of game)
	ldy bullets1; check if bullet is available
	bne checkbulletinairRight ; if available, see if bullet is already in air
	jmp chasebulletpacksRight ; if not available, chase bullet packs
checkbulletinairRight	lda bullet1inair ; check if bullet is in air
	beq setaggressionRight ; if not, set aggression
	jmp chasebulletpacksright ; bullet is in air, let's grab bullet packs	
	
; ************************************************************************
; AI Set Aggression	
; ************************************************************************
setaggressionRight	LDA #0
	LDy lifes1
	Cpy lifes0
	beq checkOppBulletsright 
	bcs add5toxRight
reducexRight lda #250
	bne checkOppBulletsRight
add5toxRight	lda #5
checkOppBulletsRight ldx bullets0
	beq add5moretoaggRight
	sec
	sbc #5
	jmp checkCPUhasBulletsRight
add5moretoaggRight clc
	adc #5
checkCPUhasBulletsRight ldx bullets0
	beq subtract10fromaggRight
	clc
	adc #5
	jmp storeaggressionRight	
subtract10fromaggRight	sec
	sbc #10		 
storeaggressionRight	stA CPURightAggression
	bpl jmpaggressiveCPURight
; ************************************************************************
; AI Aggressive Logic	
; ************************************************************************
aggressiveCPURight
; 1 - Get Diagonal
; a. Get CPUX - PX
; 2 - if Diagonal, Shoot
	lda rightcharcontrol
; xdiff is less than ydiff
	ldx fighterx1
	cpx fighterx
	bcc moverightRight
moveleftRIght ora #%00001000
	and #%00001011
	bne checkvert2Right
moverightRight ora #%00000100
	and #%00000111

checkvert2Right	ldx fightertopy1
	cpx fightertopy
	bcc movedownRIght
moveupRight ora #%00000010
	and #%00001110
	bne AIAimandShootRight
movedownRight ora #%00000001
	and #%00001101

; ************************************************************************
; AI Aim and Shoot?	
; ************************************************************************
AIAimandShootRight sta rightcharcontrol 
avoidembraceRight
ldxbulletinairRight	ldx bullet1inair
	bne jmpavoidslimeRight ; bullet is in air - avoid slime
	ldx bullets1
	beq jmpavoidslimeright	; no bullets avoid slime
	lda fighterx1
	cmp fighterx
	bcc x1isgreaterright
	sec
	sbc fighterx
	jmp staxdiffright
jmpavoidslimeright jmp avoidslimeright
jmpAIStoreDirectionandButtonright jmp AIStoreDirectionandButtonright
jmpchasebulletpacksright jmp chasebulletpacksright	
x1isgreaterright	lda fighterx
	sec
	sbc fighterx1
staxdiffright	sta xdiff
;	beq shootupdown
; b. Get CPUY - PY
	lda fightertopy1
	cmp fightertopy
	bcc y1isgreaterright
	sec
	sbc fightertopy
	jmp staydiffright
y1isgreaterright	lda fightertopy
	sec
	sbc fightertopy1
staydiffright sta ydiff
	beq shootleftrightright
	cmp xdiff
	bne checkstraightshotsright
	ldx #0 ; 0 means fire because translated to Strig
stxsapright	stx shootatplayerright
; 2 - if Diagonal, Shoot
;	lda rightcharcontrol
; xdiff is less than ydiff
aimdiagonallyright	ldx fighterx1
	cpx fighterx
	bcc aimrightright
aimleftright lda #11 ;ora #%00001000
;	and #%00001011
	bne checkvertAimright
aimrightright lda #7 ;ora #%00000100
;	and #%00000111
checkvertaimright	ldx fightertopy1
	cpx fightertopy
	bcs aimupright
aimdownright and #%00001101
	jmp AIStoreDirectionandButtonright
aimupright and #%00001110
	jmp AIStoreDirectionandButtonright
checkstraightshotsright	lda fightertopy1
	sec
	sbc fightertopy
	and #%01111111
	tax
	lda rightcharcontrol
	cpx #4
	bcc shootleftrightright
	ldx fighterx1
	cpx fighterx
	bne avoidslimeright	
shootdownupright lda #0
	sta shootatplayerright
	lda fightertopy1
	cmp fightertopy
	bcc shootdownright
	lda #14
	bne AIStoreDirectionandButtonright
shootdownright	lda #13
	bne AIStoreDirectionandButtonright
shootleftrightright lda #0
	sta shootatplayerright
	lda fighterx1
	cmp fighterx
	bcc shootrightright
	lda #11
	bne AIStoreDirectionandButtonright
shootrightright	lda #7
	bne AIStoreDirectionandButtonright
; ************************************************************************
; Avoid Slime	
; ************************************************************************
;stopped here
avoidslimeright 	ldy #1
	sty asrunright ; debug code
	sta rightcharcontrol
; gather distances from slime
	lda slimeminpy
	sec
	sbc fightertopy1
	sta distaboveslime
	lda fightertopy1
	sec
	sbc slimemaxpy
	sta distbelowslime
	lda slimeminpx
	sec
	sbc fighterx1
	sta distleftofslime
	lda fighterx1
	sec
	sbc slimemaxpx
	sta distrightofslime
	lda rightcharcontrol
	ldx distrightofslime
	bpl rightofslimeright
leftofslimeright ldx distaboveslime
	bmi leftandbelowslimeright
leftandaboveslimeright	cmp #5
	bne aistoredirectionandbuttonright
; if here, CPU is running toward slime
	lda #7 ; go right
	bne aistoredirectionandbuttonright
leftandbelowslimeright	cmp #6
	bne aistoredirectionandbuttonright
	lda #14 ; go up
	bne aistoredirectionandbuttonright
rightofslimeright ldx distaboveslime
	bmi rightandbelowslimeright
rightandaboveslimeright	cmp #9
	bne aistoredirectionandbuttonright
; if here, CPU is running toward slime
	lda #11 ; go Left
	bne aistoredirectionandbuttonright
rightandbelowslimeright	cmp #10
	bne aistoredirectionandbuttonright
	lda #14 ; go down
	bne aistoredirectionandbuttonright
; ************************************************************************
; AI Store Direction and bullet	
; ************************************************************************
AIStoreDirectionandButtonright 	sta rightcharcontrol
	lda lastshootatplayerright
	bne checkfireright 
	lda #1
	sta shootatplayerright
	sta lastshootatplayerright
	rts
checkfireright	lda shootatplayerright
	ora bullet1inair
	sta lastshootatplayerright
	bne slc
	nop
slc	sta rightcharbutton
	rts
; ************************************************************************
; ************************************************************************
; AI Logic right END
; ************************************************************************
; ************************************************************************
;##############################################################################################################
; When Fighter picks up a bullet pack or when the bullet timer runs out, clear both bullet packs - Start  
; Must be replaced with the previous character
;##############################################################################################################
	
resetbullet LDA #0
	STA BULLETDISPLAYED,x
	JSR SETTOPOFSCREENMEMORY ;reset scrlo
	LDY BULLETPACKY,x
	JSR SETYLINE
	LDY BULLETPACKX,x
	LDA PREVCHAR,x
	STA (SCRLO),Y
	rts
;##############################################################################################################
; When Fighter picks up a bullet pack, clear both - End
;##############################################################################################################

;##############################################################################################################
; Put the bullet packs on the screen - Start
;##############################################################################################################
	
drawbulletpacks	LDA BULLETDISPLAYED,x
	BNE CHECKBULLETTIMER
	JSR SETTOPOFSCREENMEMORY ;reset scrlo
	LDA RANDOM ; $D20A
	AND #20 ;96
	clc
	adc #2
TRANSFERTOYA	TAY
	STA BULLETPACKY,x
	stx tempx
	jsr setbulletpackPY
	ldx tempx
	sta bulletpackpy,x
jsrsyl	JSR SETYLINE
	LDA $D20A
	AND #35  ;#37   ;160   ; EBH - adjusted to 35 to limit bullet positions
	clc 
	adc #2 ; #1   ; EBH - adjusted to 2 to limit bullet positions
TRANSFERTOY	TAY
	STA BULLETPACKX,x
	stx tempx
	jsr setbulletpackPx
	ldx tempx ;#0 ; set x back to 0
	sta bulletpackpx,x
ldascrloy	LDA (SCRLO),Y
; make sure that bullet pack doesn't erase a wall, slime or another bullet pack
	CMP #10
	Bcc stapcx
	CMP #14
	Bcc dbprts

stapcx	STA PREVCHAR,x
	LDA #12
	STA (SCRLO),Y

	LDA #5
	STA BULLETTIMER,x
	STA BULLETDISPLAYED,x
	rts
CHECKBULLETTIMER DEC BULLETTIMER,x
	BNE dbprts
	jMP resetbullet	
dbprts rts	

;##############################################################################################################
; Put the bullet packs on the screen - End
;##############################################################################################################

;##############################################################################################################
;  title screen logic to make sure both players are ready before starting - Start
; - A higher level language would have been very handy here - especially since speed was not important here.
;##############################################################################################################
printready lda player1ready ; title screen logic to make sure both players are ready before starting
	bne checkleftorright
	lda currchar1control
	beq printf2ready ; Controller 2 is ready, if left controller is left player then print ready under right player
	bne printf1ready; Controller 2 is ready, if left controller is right player then print ready under left player
checkleftorright lda currchar1control ; Check if Controller1 is controlling left or right
	bne printf2ready
printf1ready lDX #5
LOOPf1r LDA ready,x
	STA $AFbA,X  ; 8
	lda spaces,x
	sta $afc8,x  ; 6
	DEX
	Bpl LOOPf1r
	rts
printf2ready lDX #5
LOOPf2r LDA spaces,x
	STA $AFbA,X   ; 8
	lda ready,x
	sta $afc8,x   ; 6
	DEX
	Bpl LOOPf2r
	rts
p1notready lDX #5
LOOPnr LDA spaces,x
	STA $AFbA,X   ; 8
;	sta $afc8,x   ; 6
	DEX
	Bpl LOOPnr
	rts
p2notready lDX #5
LOOP2nr LDA spaces,x
	sta $afc8,x   ; 6
	DEX
	Bpl LOOP2nr
	rts

;##############################################################################################################
;  Title screen logic to make sure both players are ready before starting - End
;##############################################################################################################


;##############################################################################################################
;  EOG - Tell everyone who won the last game. - Start
;##############################################################################################################

PRINTWINNERLOSER 	lda fighter1wins
	cmp fighter2wins
	bcc fighter2winner
fighter1winner lDX #5
LOOPf1w LDA winner,x
	clc 
	adc #128
	STA $AFba,X
	lda loser,x
	sta $afc8,x
	DEX
	Bpl LOOPf1w
	rts
fighter2winner lDX #5
LOOPf2w LDA loser,x
	STA $AFba,X
	lda Winner,x
	clc 
	adc #128
	sta $afc8,x
	DEX
	Bpl LOOPf2w
	rts

;##############################################################################################################
;  EOG - Tell everyone who won the last game. - Start
;##############################################################################################################


; *************************************************************************
;*                         Initialize
; *************************************************************************
	 ; start of one time only initialization
; The following should only be done once per bootup
runonce lda #15
	sta 19 
	lda #1
	sta 580 ; cold restart when "RESET" Pressed - Should be listed as COLDST in CIO Equates
	sta $3f8 ; disable basic
	lda #64 ; disable break key
	sta 16 ; disable break key
	sta 53774 ; disable break key
	lda <dlistart ; Set DLI lo address
	sta 512
	lda >dlistart ; Set DLI Hi address
	sta 513
	lda #16
	sta bull1def
	lda #1
	sta bulldef
	sta hasrunonce
	sta 741 ; low byte of memtop
	lda #player0width
	sta 53256 ; P0 Width
	lda #player1width
	sta 53257 ; p1 width
	lda #player2width
	sta 53258 ; p2 width
	lda #player3width
	sta 53259 ; p3 width
	jsr setVBI ; set up VBI
	lda RAMTOP ; load RAMTOP
	sec
	sbc #PagesToReserve ; 8 ; Reserve 8 pages for HiRes PM Graphics
	sta PMBASE ; Set PMBASE. PMBASE must be Set before ramtop 
	sta RAMTOP ; Set Ramtop - see Mr. Chadwick for more details.	
	lda #0
	sta legsstate ; Reset the legstate (flipflop flag) to 0.
	sta legsstate1
	
;detect PAL or NTSC and set appropriate music offset in "TV" - EBH -  start
	ldy #178 
    sei
    lda #130
detectwait130
    cmp VCOUNT
    bne detectwait130
    clc
detectloop
    lda VCOUNT
    beq detectdone
    cmp #132
    bcc detectloop
detectdone
	LDA #0
	ADC #0   ; Carry set = PAL   /   Carry clear = NTSC
	BEQ detect800
	jsr convertoPAL
	ldy #194  ;195
detect800 	; detect if OSA or OSB and adjust music offset appropriately in "TV" -start
	lda $fff9
	cmp #230
	beq Y800
	cmp #87
	bne tvdone 
Y800	tya    
	sbc	#27
	tay     ; detect if OSA or OSB and adjust music offset appropriately in "TV" -end
TVdone	sty tv  
	cli
;detect pal or ntsc and set appropriate music offset in "TV" - EBH -  end
		
	rts
;end of one time only initialization
; *************************************************************************
;* END Initialize
; *************************************************************************
; *************************************************************************
; turn on VBI 
; *************************************************************************
setVBI	lda #7 ; 7=deferred VBI because I like to procrastinate
	ldy <VBISTART ; load lo byte of VBI address into Y
	ldx >VBISTART ; load hi byte of VBI address into X
	jsr 58460 ; go set up the VBI - Should be listed as SETVB in CIO Equates
	rts
; *************************************************************************
; END OF turn on VBI 
; *************************************************************************
; Routines to clear players
clearplayers	LDA #0	
	LDY #255 ; start of clear players
loop STA M0,Y
	STA P0,Y
	STA P1,Y
	STA P2,Y
	STA P3,Y
	DEY
	Bne loop	;end of clear players
	rts
	
; Routine to clear missiles	
clearmissiles lda #0
	ldy #255
cmloop	sta m0,y
	dey
	bne cmloop
	rts
; *************************************************************************
;* Eric's routine to shut Pokey up - Start
; *************************************************************************

quiet lda #0 ; EBH 9-26 routine to silence all channels - start
	ldy #0
quietlp sta $d200,y   ; EBH - silence all sound channels
	iny
	cpy #8
	BNE quietlp  ; routine to silence all channels - end	
	rts	
; *************************************************************************
;* Eric's routine to shut Pokey up - End
; *************************************************************************
	
; *************************************************************************
;* Start TITLE SCREEN
; *************************************************************************
titleScreen lda #15
	sta leftcharcontrol
	sta rightcharcontrol

	lda $ff ; reset keypresses 
	sta $2f2 ; reset keypresses 
	sta $2dc ; reset keypresses 

; Theme Song Music - initialize - start 			
			lda #$8f ; low byte of END OF NOTES
            sta $CB
            lda #$56 ; high byte of END OF NOTES
            sta $CC
            
			lda #$04 ; low byte of starting position
            sta $cd
            lda #$50 ; high byte of starting position
            sta $ce
            
			lda #3
			sta SKCTL
			lda #0
			sta AUDCTL
			sta rtclockJiffy
			ldy #3

cleartimer	sta NOTETIMER,y
			sta NOTETIMER+4,y    
			dey
			bpl cleartimer
; Theme Song Music - initialize - end

	LDA #2 ; LOAD GRAPHICS 2
	jsr Graphics
;player setup
; changes colors of Player 0 and Player 1	
	lda #62 ; Enable DMA, Hi Res Players, turn on Players and Missiles, Standard Playfield 
	sta SDMCTL ; See Mapping the Atari
	lda #3
	sta GRACTL ; PM Priority
	LDA #56 ; #32 OVERLAPPED PLAYERS HAVE 3RD COLOR + #16 4 MISSILES = 5TH PLAYER - + #8 - PF 0&1, PM, PF 2,3,BAK priority
	Sta 623 ; SET MISSILES AND PLAYERS
 	lda char1currColor	
	ldY currfighter1char 
	jsr changecolorssub
	sty 704
	sta 705
	lda currfighter1char
	jsr stacurrfighter1char ;changefighter1character
 	lda char2currColor	
	ldY currfighter2char 
	jsr changecolorssub
	sty 706
	sta 707
	lda currfighter2char
	jsr stacurrfighter2char ;changefighter1character
	lda #96 ; title screen player X
	sta P0x
	sta P1x
	lda #151 ; title screen player X
	sta P2x
	sta P3x	
	jsr clearplayers
	lda #15
	LDX #0
	JSR POINTCHARACTERDIRECTION
	ldy #176
	sty fightertopy
	STY FIGHTERTOPY1
	LDX #0
	stx currrotate
	STX CURRROTATE1
	STX LEGSSTATE

	stx fighterhorstate
	stx fighterhorstate1
	stx fightervertstate
	stx fightervertstate1
	jsr changeimage
	LDX #fighterhorstate1-fighterhorstate
	lda legsstate1
	eor #15
	sta legsstate1 ; make secondfighter be in diff state than first
	lda #15		
	jsr pointcharacterdirection
	JSR CHANGEIMAGE ; Draw Second Fighter

tsnoGrafx	
	lda #0
	sta 710
	LDA #250
	sta FLASH1
	sta FLASH2

printBY	lda #$60
	sta printmode
	ldx #9 ; LOW BYTE OF X
	lda #0 ; HIGH BYTE OF X ; 0 FOR ANY NUMBER LESS THAN 256
	LDY #3 ; Y VALUE
	JSR POSITION
	ldY #BY&255 ; Lowbyte
	lda #BY/256 ; hi byte
	jsr Print
printVS	ldx #9 ; LOW BYTE OF X
	lda #0 ; HIGH BYTE OF X ; 0 FOR ANY NUMBER LESS THAN 256
	LDY #9 ; Y VALUE
	JSR POSITION
	ldY #VS&255 ; Lowbyte
	lda #VS/256 ; hi byte
	jsr Print
	
; Who will get top billing?  Eric or Rob? Rob or Eric?	
whowillbefirst	LDA $d20a ; get random number
	and #1 ; cmp #127 ; Find 1 bit to determine odd or even 
	Bne ericsfirst
	lda #5
	sta x2
	lda #7
	Sta x1
	jmp PrintEric
ericsfirst	lda #5
	sta x1
	lda #7
	Sta x2
PrintEric	ldx #3 ; LOW BYTE OF X
	lda #0 ; HIGH BYTE OF X ; 0 FOR ANY NUMBER LESS THAN 256
	LDY x1 ; Y VALUE
	JSR POSITION
	ldY #ERIC&255 ; Lowbyte
	lda #ERIC/256 ; hi byte
	jsr Print
printRob	ldx #3 ; LOW BYTE OF X
	lda #0 ; HIGH BYTE OF X ; 0 FOR ANY NUMBER LESS THAN 256
	LDY x2 ; Y VALUE
	JSR POSITION
	ldY #ROB&255 ; Lowbyte
	lda #ROB/256 ; hi byte
	jsr Print
	
jpwl lda fighter1wins
	ora fighter2wins	
	BEQ CHANGE710 ; If neither fighter won, don't print the last winner
	JSR PRINTWINNERLOSER
CHANGE710	lda #0
	sta 710 ; color 2 shadow register
AltTitleLetters
 
PRINTNAMES ; Print Fighter Names
STORENAMEPTR LDX currFIGHTER1CHAR	
	ldA #0
	CLC
ADDCHARPOS	ADC #4
	DEX
	BPL ADDCHARPOS
	SEC
	SBC #1
	STA FIGHTER1CHARPOS
	LDX currFIGHTER2CHAR	
	ldA #0
	CLC
ADDCHARPOS2	ADC #4
	DEX
	BPL ADDCHARPOS2
	SEC
	SBC #1
	STA FIGHTER2CHARPOS

	LDX #3
LOOPNAMES LDY FIGHTER2CHARPOS 	
	LDA NAMES,y
	STA $AF79,X
	LDY FIGHTER1CHARPOS
	LDA NAMES,y
	STA $AF6b,X
	DEC FIGHTER1CHARPOS
	DEC FIGHTER2CHARPOS
	DEX
	Bpl LOOPNAMES
	lda currchar1control
	beq char1p1
	cmp #1
	bne char1cpu
	lda <player2
	jmp stalc1	
char1p1 lda <player1	
	jmp stalc1
char1cpu	lda <cpu
stalc1	sta leftcharloop+1
currchar2controlset	lda currchar2control
	beq char2p1
	cmp #1
	bne char2cpu
	lda <player2
	jmp starc1	
char2p1 lda <player1	
	jmp starc1
char2cpu	lda <cpu
starc1	sta rightcharloop+1

	ldx #7
leftcharloop	lda cpu,x
	sta $af91,x
	dex
	bpl leftcharloop

	ldx #7
rightcharloop	lda player2,x
	sta $af9f,x  ;e
	dex
	bpl rightcharloop
softwareContest	LDX #13    ;29
LOOPswc	LDA abbuc,x
	STA $AFe5,X    ; afdd
	DEX
	Bpl LOOPswc

	
;AltTitleLetters 
;Halloween Egg Start ; Figure this out on your own - not too hard to do...	
	lda $2f2
	cmp #$39
	bne checkspace
	jmp Eggs
Checkspace 
	cmp #33
	bne checkhelp
	jmp Eggs	
Checkhelp
	lda $2DC ; check help key register
	cmp #17 ; 17 means help pressed
	bne noEggs
Eggs
	lda #52
	sta 708
	lda #12
	sta currfighter1char
	lda #8 
	sta currfighter2char
	jsr quiet   ; EBH - quiet all channels before gravesound when easter egg unlocked
	jsr gravesound  ; EBH - call gravesound when easter egg unlocked
	lda #14
	sta numcharacters
	lda $ff
	sta $2f2
	sta $2dc
	ldy #14 ; EBH had #15
hweentext
	lda hween,y-1 ; Eric wrote this part and I just learned something new.  MADS is so great.
	sta abbuc,y-1 ; If i understand this, STA abbuc-1,y would be the same thing?
	dey
	bne hweentext
	jmp titlescreen	
;Halloween Egg End	
noEggs	inc 708 ; they didn't find the Easter Egg...
	lda #$60	
	sta printmode   
	ldx #3 ; LOW BYTE OF X         ;EBH changed from 3 to 2   
	lda #0 ; HIGH BYTE OF X ; 0 FOR ANY NUMBER LESS THAN 256
	LDY #0 ; Y VALUE				;EBH changed from 1 to 0
	JSR POSITION
	LDA x3
	BEQ TitleLetters1
	ldY #CHU2&255 ; Lowbyte
	lda #chu2/256 ; hi byte
	jsr Print
;EBH added chunk below to display bottom row of "WAR ROOM" - START  	
	ldY #bot2&255 ; Lowbyte
	lda #bot2/256 ; hi byte
	jsr Print
;EBH added chunk below to display bottom row of "WAR ROOM"	- END
	LDA #0
	STA x3
	lda player1ready
	ora player2ready
	beq jpwl2
	jsr printready
	jmp donewithwinner
	
jpwl2 lda fighter1wins
	ora fighter2wins	
	BEQ donewithwinner
	JSR PRINTWINNERLOSER
donewithwinner
	LDX #fighterhorstate1-fighterhorstate
	lda legsstate1
	eor #15
	sta legsstate1 ; make secondfighter be in diff state than first
	JSR CHANGEIMAGE ; Draw Second Fighter
	LDX #0
	lda legsstate
	eor #15
	sta legsstate ; make secondfighter be in diff state than first
	JSR CHANGEIMAGE ; Draw Second Fighter

	jmp ptrigwait
TitleLetters1
	ldY #CHU1&255 ; Lowbyte
	lda #chu1/256 ; hi byte
	jsr Print
;EBH added chunk below to display bottom row of "WAR ROOM" - START
	ldY #bot1&255 ; Lowbyte
	lda #bot1/256 ; hi byte
	jsr Print
;EBH added chunk below to display bottom row of "WAR ROOM" - END 
	LDA #1
	STA x3
	jmp ptrigwait
	
Print; rts  ; This code was modified from Chapter 10 of the book referenced in "sources" at the top of this file.
	; PHA ; Push Hi to Stack 
;	TXA
;	PHA ; Push Low
	LDX printmode ;#$60 ;IOCB 6 like PRINT #6 - use 0 for regular text
;	lda iccom,x
;	PLA ;Str high byte
	STA ICBAH,X
;	PLA  ;Str low byte
	TYA
	STA ICBAL,X
	LDA #$09 ;Put Cmd Val
	STA ICCOM,X ;Set it as the cmd

	LDA #$FF ;Str Len low byte
	STA ICBLL,X
;	LDA #$FF ;Str Len high byte
	STA ICBLH,X
    JSR CIOV ; Call CIO
	LDA #0
	STA TEMPX 
;	lda #3
;	sta $03a2
	rts
; sound theme song
ptrigwait ;jsr musicsub
; sound theme song
	lda gameon
	cmp #255
	bcc jsms
	jmp mainloop 
jsms	jsr musicsub
;	sta 708  ; EBH - uncomment this if you want the WAR ROOM colors to sync with drum beat
; sound theme song
; Attract Mode Start
	jmp checkcontrollers
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; SETUP Demo Start	
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
startdemo 
; use multiple demo Characters Start
	lda RANDOM
	and #15
	cmp numcharacters
	BCS startdemo
	sta dstp2  ; store the character selected in temporary location
	tay
	jsr demochangefighter2char
rc1	lda RANDOM
	and #3
	cmp #3
	BCS rc1
	jsr changecolorssub
	sty 706
	sta 707
rp2	lda RANDOM
	and #15
	cmp numcharacters
	BCS rp2
	cmp dstp2  ; check to see if its the same character as player 1, if so re-shuffle
	bcs startdemo
	tay
	jsr demochangefighter1char	
rc2	lda RANDOM
	and #3
	cmp #3
	BCS rc2
	jsr changecolorssub
	sty 704
	sta 705
; use multiple demo Characters End
	
	lda #1
	sta AttractOn
	lda currchar1control
	sta currchar1controlhold
	LDA currchar2control
	sta currchar2controlhold
		ldx #0
	ldy #0
	jsr CPUEvacuate	
		ldx #1
	ldy #fighterx1-fighterx
	jsr CPUEvacuate	
	lda #255
	sta gameon
	lda #2
	sta currchar1control
	sta currchar2control
	lda fighter1wins
	sta fighter1winshold
	lda fighter2wins
	sta fighter2winshold
ame	jsr stopmusic
	jmp mainloop
; Attract Mode End
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; SETUP Demo End	
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; Check Console Keys and Keyboard Input
checkcontrollers 	lda consolcheck ; consolcheck adds delay so that we don't read on console button press as multiple presses 
	sec 
	sbc #1
	bpl stacc
	lda #0
stacc sta consolcheck
	bne checkfor1key 
	lda CONSOL ; this looks dead to me
	and #%00000010 ; select not pressed
	beq changecont1
checkfor1key	lda $2fc ; Last Key Pressed
	cmp #$1f ; "1" key
	bne check2key
changecont1		lda #consoldelay
	sta consolcheck
	lda currchar1control
	clc
	adc #1
	cmp #3
	bcc stacc1c
	lda #0
stacc1c sta currchar1control
	lda #0
	sta $5690   ; EBH reset music loop counter to zero if user does something	
	sta player1ready
	jsr p1notready ; erases ready from player1
check2key lda consolcheck
	bne checkfor2key
	 
	lda CONSOL
	and #%00000100 ; option not pressed
	beq changecont2
	lda #consoldelay
	sta consolcheck
	
		
checkfor2key	lda $2fc ; Last Key Pressed
	cmp #$1e ; "2" key
	bne clearlastkey
changecont2 lda #consoldelay
	sta consolcheck	
	lda currchar2control
	clc
	adc #1
	cmp #3
	bcc stacc2c
	lda #0
stacc2c sta currchar2control	
	lda #0
	sta $5690 ; EBH reset music loop counter to zero if user does something	
	sta player1ready
	jsr p2notready ; erases ready from player1
	
clearlastkey lda #$ff
	sta $2fc
 	lda #8
 	sta consol
 ;######################################################################################
; Fighter 1 color and character change Start	
 ;######################################################################################
	lda LeftCharControl ; Fighter 1 color and character change Start
	cmp actions0
	beq fighter2color
	sta actions0
	cmp	#down
	bne CHECKupcolorchange ;P0CHARCHANGE
	lda char1currColor
	clc
	adc #1
	cmp #char1ColorOptions  ; CHANGE TO VARIABLE...
	bcc changecolors
	lda #0
	jmp changecolors
checkupcolorchange	cmp	#up ; Up changes character colors
	bne checkP0CHARCHANGE
	lda char1currColor
	sec
	SBc #1
	bpl changecolors
	lda #Char1ColorOptions-1
changecolors sta char1currColor	
	ldY currfighter1char 
	jsr changecolorssub 
;	needs to store based o fighter 1 or fighter 2	
	sty 704
	sta 705
	JMP FIGHTER2COLOR
	lda LeftCharControl
CHECKP0CHARCHANGE CMP #RIGHT ; Right changes character
	bne checkleftchange1
	jsr changefighter1character
	jmp changecolors
checkleftchange1 cmp #left ; Left changes character
	bne fighter2color
	jsr changefighter1characterleft
	jmp changecolors
;######################################################################################
; Fighter 1 color and character change End	
 ;######################################################################################
	
;######################################################################################
; Fighter 2 color and character change Start	
 ;######################################################################################	
fighter2color 		lda RightCharControl
	cmp actions1
	beq LDAleftcharbutton
	sta actions1
	cmp	#down
	bne checkupcolorchange2
	lda char2currColor
	clc
	adc #1
	cmp #char1ColorOptions
	bcc changecolors2
	lda #0
	jmp changecolors2
checkupcolorchange2	cmp	#up
	bne checkf2charchange
	lda char2currColor
	sec
	SBc #1
	bpl changecolors2
	lda #Char1ColorOptions-1
changecolors2 sta char2currColor
	ldY currfighter2char
	jsr changecolorssub 
;	needs to store based o fighter 1 or fighter 2	
	sty 706
	sta 707
	lda RightCharControl
	cmp actions1
	beq donewithcharacters
	sta actions1
CHECKf2CHARCHANGE CMP #RIGHT
	bne checkleftchange
	jsr changefighter2character
	jmp resetrightcontrol
checkleftchange cmp #left
	bne donewithcharacters
	jsr changefighter2characterleft
resetrightcontrol	lda #0
	jmp changecolors2
;######################################################################################
; Fighter 2 color and character change End	
 ;######################################################################################

donewithcharacters

LDAleftcharbutton lda CONSOL
	and #%00000001 ; start not pushed
	bne checktwoplayer ; EBH - changed to add wait until the start key released - start	
	jsr quiet ; jsr to routine to silence all channels
	lda $22f    ; EBH
	sta SAVANTIC
	lda #0
	sta $22f     ; EBH
KEYLOOP lda CONSOL   
	and #%00000001 ; start not pressed
	BEQ KEYLOOP    
	lda SAVANTIC ; EBH
	sta $22f     ; EBH
	jmp startgame ; EBH - changed to delay start until start key released - end
checktwoplayer lda currchar1control
	cmp currchar2control
	beq onetrigger ; if character1 and character2 are controlled by same controller, only need one trigger pushed
	cmp #2 ; CPU Control
	beq onetrigger
	lda currchar2control
	cmp #2 ; CPU Control
	beq onetrigger
	lda strig0
	bne checktrigger2
	lda #1
	sta player1ready
	lda #0 
	sta $5690 ; EBH - reset music loop counter if user does something
; missing time based attract code here.
checktrigger2 lda strig1
	bne checkbothready
	lda #1
	sta player2ready
	lda #0 
	sta $5690 ; EBH - reset music loop counter if user does something
checkbothready lda player1ready
	and player2ready
	bne startgame
jmpcheckrotate	jmp checkrotate	
jmpLOADTIMER jmp LOADTIMER		
onetrigger lda #0
	sta player1ready
	sta player2ready	
	LDA strig0 ;;if you are in one trigger and strig 0 is pressed, make sure the character is controlled stick 0 - leftcharbutton	; convoluted way to wait for ptrig and rotate screen text 
	bne checkstrig1
	lda currchar1control
	beq ldarod
	lda currchar2control
	beq ldarod 
checkstrig1	lda strig1 ;if you are in one trigger and strig 1 is pressed, make sure the character is controlled stick 1 - Rightcharbutton
	BNE jmpcheckrotate
	lda #1
	cmp currchar1control
	beq ldarod
	cmp currchar2control
	bne jmpcheckrotate

ldarod	LDA RELEASEORDELAY
	AND RELEASEORDELAY1
	BEQ jmpLOADTIMER
;######################################################################################
; GAME START	
 ;######################################################################################

startgame	lda currchar1control
	sta currchar1controlhold
	lda currchar2control
	stA currchar2controlhold
 	lda #0
	sta $5690 ; EBH reset music loop counter to zero 


; re-initilize all the theme song music before restarting titlescreen - start
stopmusic			ldy #3
			lda #0
clearplayS  sta NOTETIMER,y
			sta NOTETIMER+4,y
			sta AUDC1,y
			sta AUDC1+4,y
			dey
			bpl clearplayS
; EBH - reset the pointer back to the beginning 
			lda #$04 ; low byte of starting position
            sta $cd
            lda #$50 ; high byte of starting position
            sta $ce
; re-initilize all the theme song music before restarting titlescreen - end
; Reset wins and players ready memlocs			
	lda #0
	sta fighter1wins
	sta fighter2wins
	sta player1ready
	sta player2ready	
	lda #1
	sta round
	
startround jsr clearmissiles ; sub to clear missile memory
	LDA #0 ; reset bullet positions
	sta bullety ; fix for remaining bullet
	sta bullet1y ; fix for remaining bullet
	sta prevbullety; fix for remaining bullet
	sta prevbullet1y; fix for remaining bullet
	STA releaseordelay 
	STA releaseordelay1
	lda #255
	ldy attracton
	beq stago 
	
sta1gameon	lda #1
stago	STA GAMEON ; set game to active 	
flashstuff	LDA #$b8  ; Flash1 and Flash2 are used for flashing colors
	sta FLASH1
	LDA #$b8 
	STA FLASH2
	lda #20 
	sta SLIMEX ; slime starts in the middle horizontallay
	sta SlimeMinX ; This is used for CPU to help avoid slime
	sta SlimeMaxx ; This is used for CPU to help avoid slime
	lda #12
	sta SLIMEY ; Slime starts in the middle vertically
	sta SlimeMinY ; This is used for CPU to help avoid slime
	sta SlimeMaxY ; This is used for CPU to help avoid slime
	lda #120
	sta slimeminPx ; Maps Slime GR 12 coordinates to Player coordinates - Very Imprecise
	lda #135
	sta slimemaxPx ; Maps Slime GR 12 coordinates to Player coordinates - Very Imprecise
	lda #120
	sta SlimeMinPy ; Maps Slime GR 12 coordinates to Player coordinates - Very Imprecise
	lda #140
	Sta SlimeMaxPy ; Maps Slime GR 12 coordinates to Player coordinates - Very Imprecise
	
	jmp gamescreen ; Go to gamescreen
checkrotate lda #1
	STA releaseordelay
	STA RELEASEORDELAY1 
LOADTIMER	lda rtclockJiffy ; timer location 
	CMP #5
	bcS RESETTIMER 
	JMP ptrigwait
RESETTIMER	lda #0
	sta rtclockJiffy ; loc 20?
	jmp altTitleLetters
; *************************************************************************
;* end TITLE SCREEN
; *************************************************************************
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; SUBROUTINES - Start
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;**************************************************************
; SOUND - No Bullets
clicksound 
	lda #2
    sta freq2
    sta ofreq2 ; EBH - added to prevent rare high beep sound
    lda #172
    sta cntrl2
    lda #4
    sta dura2
    lda #1
    sta trgt2
	lda $ea  ; EBH - added to prevent rare high beep sound
	sta dstp2 ; EBH - added to prevent rare high beep sound
	rts
;****************************************************************

;****************************************************************
; Increment bullets, erase old bullets, display in new location
moveanddrawbullets lda bulletinair,x
	beq bailbullets
	lda	bulletx,x
	clc
	adc horbulletinc,x
	cmp #200 ; BULLET BOUNDARY
	bcs stopbullet
	cmp #50; BULLET BOUNDARY
	bcc stopbullet
	sta bulletx,x
	sta m0x,y
	lda bullety,x
	clc
	adc vertbulletinc,x
	cmp #46; BULLET BOUNDARY
	bcc stopbullet
	cmp #220; BULLET BOUNDARY
	bcs stopbullet
	sta bullety,x
	sta prevbullety,x
	tay	
	lda m0,y
	ora bulldef,x
	sta m0,y
	lda m0+1,y ; double height bullets
	ora bulldef,x ; double height bullets
	sta m0+1,y ; double height bullets
	jmp bailbullets
stopbullet JSR stopbulletsub
bailbullets	
; Eliminate Horizontal Misses Start	
	cpx #0
	bne checkbullet1
	lda VERTBULLETINC,x 
	bne noprevbullet
	lda prevbulletx
	sta m1x
	ldy prevbullety
	lda m0,y
	ora #4 ; first byte of m1
	sta m0,y
noprevbullet	rts	
checkbullet1	lda VERTBULLETINC1 
	bne noprevbullet
	lda prevbullet1x
	sta m3x
	ldy prevbullet1y
	lda m0,y
	ora #64 ; first byte of m3
	sta m0,y
; Eliminate Horizontal Misses end
	rts	
;****************************************************************	
jmpclicksound jmp clicksound  ; EBH added JMPclicksound 
jmpdonewithleftcharbutton jmp donewithleftcharbutton
checkshoot lda leftcharbutton,X
	beq checkreleaseordelay
	sta	firedelay,X
	jmp donewithleftcharbutton
checkreleaseordelay lda slowshot,x
	bne jmpDonewithleftcharbutton 
	lda firedelay,X
	beq jmpDONEWITHleftcharbutton ;jdws0
	lda currchar1control,x
	cmp #2
	bne humanplayer
	cpx #0
	beq checkopponentwins
	lda fighter1wins
	cmp #2
	bcc humanplayer
	jmp storeslowshot
	
checkopponentwins lda fighter2wins
	cmp #2
	bcs humanplayer
storeslowshot	lda #2
	sta slowshot,x
humanplayer	lda LeftCharControl,X
	cmp #15
JDWS0	beq jmpDONEWITHleftcharbutton
	LDA BULLETINAIR,X ; IF BULLET IS ALREADY IN AIR, DON'T SHOOT AGAIN
	BNE JMPdonewithleftcharbutton ;JDWS0
	lda leftcharbutton,X
	bne JMPdonewithleftcharbutton ;JDWS0 ;CHECKGRAVITYCHANGE ; 1 button not pressed
	sta firedelay,X
	lda bullets0,X
	beq jmpclicksound ;jmpdonewithleftcharbutton ;JDWS0  ; EBH change to JMPclicksound
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - BULLET FIRING KICKOFF - START
   	lda #3
    sta freq1
    sta ofreq1
    lda #202
    sta cntrl1
    lda #60
    sta dura1
    lda #0
    sta trgt1
    lda #2
    sta dstp1   
; SOUND - BULLET FIRING KICKOFF - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	dec bullets0,x ; Deplete bullets by one when firing
; set bullet direction based on stick and set missile y value/x value based on fighter position and shooting direction
	lda #1
	lda LeftCharControl,X
	CMP #15
	BEQ donewithleftcharbutton ;JDWS0 ; IF NOT MOVED, RTS
	sta bulletinair,X
	LDA fighterTOPY,Y
	clc
	adc #6
	STA BULLETY,X
	LDA fighterX,Y
	STA BULLETX,X
	LDA LeftCharControl,X
	BIT LEFTBIT
	BEQ checkleftFIREs
	BIT RIGHTBIT
	BNE checkupdownFIREs	
checkrightFIREs LDY #RIGHTBULLETSPEED/2	
	bit upbit 
	beq SETDIAGUP
	bit downbit
	bne rightFIRE
SETDIAGDOWN lda #DOWNBULLETSPEED/2		
	bne storeHORBULLETX ;jmp
SETDIAGUP lda #DIAGUPBULLETSPEED
	bne storeHORBULLETX ;jmp
rightFIRE LDA #0 
	LDy #RIGHTBULLETSPEED
	BNE storeHORBULLETX ;jmp
checkleftFIREs LDy #DIAGLEFTBULLETSPEED
	bit upbit
	beq SETDIAGUP ;upleftFIRE
	bit downbit
	BEQ SETDIAGDOWN
leftFIRE LDA #0
	LDy #LEFTBULLETSPEED	
	BNE storeHORBULLETX ;jmp
checkupdownFIREs bit upbit
	beq upFIRE
	LDa #DOWNBULLETSPEED
	LDy #0 ; #254 for 3d fire
	beq storeHORBULLETX ; jmp
upFIRE lda #UPBULLETSPEED
	LDy #0 ; #2 for 3d firing
storeHORBULLETX STA vertBULLETINC,X 
	TYA
	STA horBULLETINC,X
donewithleftcharbutton	RTS


GOTOTITLESCREEN LDA #0
	STA GAMEON
	ldx #8
movepl	sta p0x,x
	dex
	bpl movepl
	JMP TITLESCREEN

;####################################################################
; 1. check and update hor fighterstate
;  - if accel set to run (may change to walk later)
;  States: Accelerate, Skid, Decel or do nothing 
;####################################################################


UPDATEHORSTATE	BIT RIGHTBIT
	BNE TESTLEFT ; If True, stick not pushed right
	LDY #2 ; ACCELERATE RIGHT
 	LDA fighterHorState,X ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
    bpl HORACCELERATE ; fighter is still - run left
    LDA #$83
    BNE HORSKID ; JMP IF fighter IS movING RIGHT - SKID
TESTLEFT BIT LEFTBIT
	BNE UHSRTS
	LDY #$82 ; ACCELERATE LEFT
 	LDA fighterHorState,X ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
    beq HORACCELERATE ; fighter is still - run left
    bmi HORACCELERATE ; fighter is going left - run left
	LDA #3 ;SKID RIGHT
    jmp HORSKID ; IF fighter IS movING RIGHT - SKID
HORACCELERATE TYA 
	STA fighterHORSTATE,X
	LDA #1
	STA fighterHORADDING,X
	BNE UHSRTS
HORSKID STA fighterHORSTATE,X
	LDA #0
	STA fighterHORADDING,X
UHSRTS	RTS
;####################################################################
; 2. check and update vert fighterstate
;  - if accel set to run
;  States: Accelerate, Skid, Decel or do nothing
;####################################################################
UPDATEVERTSTATE LDA ACTIONS0,X
TESTDOWN	BIT DOWNBIT
	BNE TESTUP
	LDY #2 ; ACCELERATE DOWN
 	LDA fighterVERTState,X ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
    bpl VERTACCELERATE ; fighter is still - run left
	LDA #$83 ; SKID UP
    jmp VERTSKID ; IF fighter IS movING RIGHT - SKID
TESTUP 	BIT UPBIT
	BNE DONEWITHBITS
	LDY #$82 ; ACCELERATE LEFT
 	LDA fighterVERTState,X ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
    beq VERTACCELERATE ; fighter is still - run left    
    BMI VERTACCELERATE ; fighter is still - run left    
	LDA #3 ;SKID DOWN
VERTSKID STA fighterVERTSTATE,X
	LDA #0
	STA fighterVERTADDING,X
	BEQ DONEWITHBITS
VERTACCELERATE TYA 
	STA fighterVERTSTATE,X
	LDA #1
	STA fighterVERTADDING,X
	JMP DONEWITHBITS
DONEWITHBITS RTS

;####################################################################
; 3. Change fighterhorstate and Set Hor Speed based on Hor fighter State and vert fighter state
; H    V     - HORIZONTAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################
CHECKDIAGONALHORIZONTAL	lda fighterhorstate,X ; 0 - STILL, 1 - WALK, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT
	AND #3
	CMP #2 ; testing to see if bit 2 is on
	bNE donewithsethorspeed ; if bit 2 is not on skip.
	lda fightervertstate,X ; 
	and #127 ; GET RID OF BIT 7 | if fightervertstate = 1 or 2 or 3 then slow down to walk
	bEQ donewithsethorspeed
	cmp #4
	bcs donewithsethorspeed
	lda fighterhorstate,X
	and #253 ; this will change a 2 to a 1 or $82 to $81
	ora #1
	sta fighterhorstate	,X
donewithsethorspeed RTS

;####################################################################
; 4. Set Vert Speed based on vert fighter state and Hor fighter State 
; V    H     - VERTICAL Speed
;----------------------------------
; A    A     - Walk
; A    S     - Walk
; A    D     - Run
; A    N     - Run
;####################################################################
CHECKDIAGONALVERTICAL lda actions0,x
	cmp #15
	beq cdv
	cmp #13
	bcc cdv
	jmp donewithsetvertspeed ;afsdafsdsdaf adfssadf
		
cdv	lda fightervertstate,X
	AND #3
	CMP #2 ; testing to see if FIGHTERVSTATE IS $82 OR $02 is on
	bNE donewithsetvertspeed
	lda fighterhorstate,X
	and #127 ; if fighterhorstate = 1 or 2 or 3 then slow down to walk
	bEQ donewithsetVERTspeed
	cmp #4
	bcs donewithsetvertspeed
	lda fightervertstate,X
	and #253 ; this will change a 2 to a 1 or $82 to $81
	ora #1
	sta fightervertstate,X
	jmp donewithcdv	
donewithsetvertspeed RTS 
donewithcdv	RTS

;####################################################################
; 5. Set currframeptr based on STICK
;####################################################################
POINTCHARACTERDIRECTION
	BIT LEFTBIT
	BEQ checkleftptrs
	BIT RIGHTBIT
	BNE checkupdownptrs	
checkrightptrs	bit upbit 
	beq uprightptr
	bit downbit
	bne rightptr
downrightptr lda #facedownright*p0height		
	bne storecurrframeptr ;jmp
uprightptr lda #faceupright*p0height
	bne storecurrframeptr ;jmp
rightptr lda #faceright*p0height
	bne storecurrframeptr ;jmp
checkleftptrs bit upbit
	beq upleftptr
	bit downbit
	bne leftptr
downleftptr lda #facedownleft*p0height		
	bne storecurrframeptr ;jmp
upleftptr lda #faceupleft*p0height
	bne storecurrframeptr ;jmp
leftptr lda #faceleft*p0height
	beq storecurrframeptr ;jmp
checkupdownptrs bit upbit
	beq upptr
	lda #facedown*p0height
	bne storecurrframeptr ; jmp
upptr lda #faceup*p0height
storecurrframeptr sta currframeptr,X
	RTS
initvariables	
	lda #3
	sta bullets0
	sta bullets1
	lda #10 ; number of lives
	sta lifes0
	sta lifes1
	lda #255
; EBH - re-initialize sound variables for consistent 'start round sound' - START	
	lda #0   
	sta $D208 ; initiatlixe pokey to address audio registers directly
	lda #3 
	sta $D20F ; initiatlixe pokey to address audio registers directly
	sta $232  ; initiatlixe pokey to address audio registers directly
	lda #$ea ;ea
	sta freq1
	sta ofreq1
	sta cntrl1
	sta trgt1
	sta dura1
	sta dstp1
	sta cntrl2
	sta trgt2	
	sta dura2
	sta dstp2 
	sta freq2
	sta ofreq2
		
; EBH - re-initialize sound variables for consistent 'start round sound' - END
	lda #0
	sta bulletinair
	sta bullet1inair
	STA LEGSSTATE
	ldx #23
resetfightervalues	sta fighterhorADDING,x
	STA fighterHORADDING1,X
	dex
	bpl resetfightervalues
	LDA #BULLETCOLOR
	sta Color3 ; SET BULLETCOLOR
	lda #1
	sta fighterhordirection
	sta fighterhordirection1
	lda #15
	sta ACTIONS0
	lda fighterhordirection ;psum
	lda #60
	sta fighterX
	lda #100
	sta fighterx1
	lda #yvalue
	sta fightertopy
	lda #yvalues1
	sta fightertopy1
	STA PREVfighterY 
	
	rts 

stopbulletsub lda #0
	sta m0x,Y
	ldy prevbullety,x
	sta m0,y
	sta m0+1,y
	sta bulletinair,x
	sta bullety,x
	sta prevbullety,x
	LDA #1
	STA releaseordelay,X
	rts
;****************************************************************	
; Change Player Image - START	
;****************************************************************
changeimage	LDA CURRROTATE,X
	Beq newdraw
	lda newACTIONS0,X
	bne newdraw
	lda ychanged,X
	beq dcfrts
newdraw	lda #0
	sta ychanged,X
; NOTE: Very simple example of self-modifying code	
; The following lines change the target for LOADP0 LDA P0Data,x 	
; This is done by loading the lobyte target to LOADP0+1
; and the hibyte target is stored in LoadP0+2	
	LDA fighter1p0datahi,x 	
	STA loadp0+2
	LDA fighter1p0datalo,x 
	clc
	ADC LEGSSTATE,X ; MAKE IT ROTATE
	adc CURRFRAMEPTR,X ; #p1height
	sta loadp0+1
	bcc doplayer1
	inc loadp0+2
doplayer1	;lda loadP1+1
	LDA fighter1p1datahi,x ;>P1DATA
	STA LOADP1+2
	LDA fighter1p1datalo,x ;<P1DATA
	clc
	ADC LEGSSTATE,X ; MAKE IT ROTATE
	adc CURRFRAMEPTR,X ; #p1height
	sta loadp1+1
	bcc inccurrframe
	inc loadp1+2
inccurrframe	Ldy fightertopy,x
	tya
	CMP prevfightery,X
	beq loadplayerloopx
	LDA  #0
	ldy fightervertstate,X
	bpl jep
	lda #12
jep clc
	adc prevfightery,X
	jsr eraseprevfighter
	ldy fightertopy,X
loadplayerloopx; TAY 
	CPX #0
	BNE PLAYER2AND3
	LDX >p0
	LDA >P1
	JMP DRAWPLAYERS
PLAYER2AND3 LDx >p2
	LDA >P3
DRAWPLAYERS STX	P0Y+2
	STA P1Y+2	 		
	ldx #0
LOADP0	lda p0data,x
P0Y	sta p0,y
LOADP1	lda p1data,x
P1Y	sta p1,y
	iny
	inx
	cpx #p0height
	bcc loadp0
dcfrts	rts
;****************************************************************	
; Change Player Image -  END	
;****************************************************************


;****************************************************************	
; STOPEVERYTHING START -The following stops all movement - might be used when dead or hitting walls.	
;****************************************************************

STOPEVERYTHING 	LDA #0 ; STOPEVERYTHINGSUB 
	cpx #0
	bne stopeverythings1
	STA fighterHorState,Y ; CHANGE fighterSTATE TO 0
	sta hspeedsum,Y
	sta hsubspeedsum,Y
	STA hspeedadd,Y
	STA hsubhspeedadd,Y
	STA ACTIONS0
	STA LASTfighterHorState,Y
	rts
stopeverythings1
	STA fighterHorState1,Y ; CHANGE fighterSTATE TO 0
	sta hspeedsum1,Y
	sta hsubspeedsum1,Y
	STA hspeedadd1,Y
	STA hsubhspeedadd1,Y
	STA ACTIONS1
	STA LASTfighterHorState1,Y
	RTS
;****************************************************************	
; StopEveryThing end	
;****************************************************************
;****************************************************************	
; Vertical Deceleration 	
;****************************************************************
vDecel LDA #0	
	stA vspeedadd,X
	lda #Decelss
	sta vsubvspeedadd,X
	rts

;****************************************************************	
; Horizontal Deceleration	
;****************************************************************
Decel LDA #0	
	stA hspeedadd,X
	lda #Decelss
stassaddld sta hsubhspeedadd,X
	rts
	
;****************************************************************	
; Horizontal Skid	
;****************************************************************
SKID LDA #skids
	STA hspeedadd,X
firstSkidss	LDA #skidss
	STA hsubhspeedadd,X
	RTS
;****************************************************************	
; Vertical Skid	
;****************************************************************
vsKID LDA #skids
	STA vspeedadd,X
secondskidss	LDA #skidss
	STA vsubVspeedadd,X
	RTS

; Not sure Walk is used....	
vwalk LDA >vRUNdata
	stA ldaphysicsdata+2 
	ldA <vRUNdata
	ldy #3+fightervertadding-fighterhoradding
	CPX #0
	BNE JMPSETUPS1
	JMP setupphysics ;INCLUDES RTS
JMPSETUPS1 JMP SETUPPHYSICSS1

walk LDA >RUNdata
	stA ldaphysicsdata+2 
	ldA <RUNdata
	ldy #3
	CPX #0
	BNE JMPSETUPS1
	JMP setupphysics ;INCLUDES RTS

;****************************************************************	
; Running	
;****************************************************************
runACTIONS0 ldA >rundata
	stA ldaphysicsdata+2
	lda ACTIONS0,x
	Cmp #RIGHT
	BNE GOINGLEFT
	LDA #1
	BNE STAfighterhordirection
GOINGLEFT	LDA #0
STAfighterhordirection	STA fighterhordirection,x
	ldA <rundata
	ldy #3
	CPX #0
	BEQ setupphysics ;INCLUDES RTS
	JMP SETUPPHYSICSS1
;****************************************************************	
; Physics	
;****************************************************************
setupphysics	stA ldaphysicsdata+1 
	lda #1
	sta fighterhoradding-3,y ; to compensate for y=3  
; Min (s,ss,sss), accel (ss, sss), max (p,s)
	ldx #3
ldaphysicsdata	lda rundata,x
	cpx #2
	bcs storehspeedsumdata 
	cmp hspeedsum,y
	bcc dexlpd	
storehspeedsumdata	sta hspeedsum,y ;x
dexlpd	dey
	dex
	bpl ldaphysicsdata
	rts
	
setupphysicsS1		stA ldaphysicsdataS1+1 
	LDA ldaphysicsdata+2
	STA ldaphysicsdataS1+2
	lda #1
	sta fighterhoradding1-3,y ; to compensate for y=3  
; Min (s,ss,sss), accel (ss, sss), max (p,s)
	ldx #3
ldaphysicsdataS1	lda rundata,x
	cpx #2
	bcs storehspeedsumdataS1 
	cmp hspeedsum1,y
	bcc dexlpdS1	
storehspeedsumdataS1	sta hspeedsum1,y ;x
dexlpdS1	dey
	dex
	bpl ldaphysicsdataS1
	rts

vrunACTIONS0 ldy ACTIONS0,X	
	ldA >vrundata
	stA ldaphysicsdata+2
	CPY #down
	BNE GOINGup
	LDA #1
	BNE STAfightervertdirection
GOINGup	LDA #0
STAfightervertdirection	STA fightervertdirection,X
	ldA <vrundata
	ldy #3+fightervertadding-fighterhoradding
	CPX #0
	BNE JMPtoSETUPS1
	JMP setupphysics ;INCLUDES RTS
JMPtoSETUPS1 JMP SETUPPHYSICSS1
	jmp setupphysics ; includes rts
;****************************************************************	
; Erase Previous Fighter - Start	
;****************************************************************
eraseprevfighter stx tempx 
	STY TEMPY
	sta erasefighter+1
	sta erasefighter1+1
	CPX #0
	BNE ERASEPLAYER2AND3
	LDX >p0
	LDA >P1
	bne erasePLAYERS ;jmp
ERASEPLAYER2AND3 LDx >p2
	LDA >P3
ERASEPLAYERS STX	erasefighter+2
	STA erasefighter1+2
	lda #0
	ldy #4
erasefighter sta p0,y
erasefighter1 sta p1,y
	dey
	bpl erasefighter
	ldx tempX
	lda fightertopy,x
	sta prevfightery,X
	LDY TEMPY	
	rts
;****************************************************************	
; Erase Previous Fighter - End	
;****************************************************************


fighterwalk
	ldA legsstate,x
	EOR #15
stxlg	stA legsstate,x ; make legs walk
	rts
	
; Physics should only be updated if
; a. new stick direction is chosen 
; - OR - 
; b. State is Skid and PSUM = 0 

hphysicsS0 LDA fighterHorState,X
	CMP LASTfighterHorState,X
	beq donephysics; IF fighterSTATE HASN'T CHANGED, JUST NEED TO ADD CURRENT ACCELERATION
	STA LASTfighterHorState,X
	AND #127
RightStates cmp #$4
	bne checkrunr ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT 
setupdecel	jmp Decel  ; includes rts bi-directional
checkrunr cmp #2 ; run
	bne checkskidr 
	jmp runACTIONS0 ; rts bi-directional 
checkskidr	cmp #3 ; skid
	bne checkwalk
	jmp skid       ; includes rts one way
checkwalk jmp walk ; includes rts bi-directional
donephysics rts


;SUBSUBSUB PIXEL
ADDTOSPEED	lda fighterhoradding,x
	beq decelerating
accelerating	lda hsubhspeedadd,x
	beq subpixel
	CLC
	adc hsubspeedsum,x
	bcc addagain
  	INC hspeedsum,x
addagain clc
	adc hsubhspeedadd,x
	bcc stasubspeed
  	INC hspeedsum,x
STAsubspeed STA hsubspeedsum,x


SUBpiXEL
	LDA hspeedsum,x
	clc
	adc hspeedadd,x
	CMP hspeedmax,x
 	BCC stahspeedsum
 	lda hspeedmax,x
stahspeedsum jmp staspsum

decelerating lda hsubspeedsum,x
	sec
	sbc hsubhspeedadd,x
	beq dhss1 ; 10/17/2017
	bcs subtractagain ;stassspsumn
dhss1	dec hspeedsum,x ; 10/17/2017
	bmi jmpgostopeverything ; If it is negative, set everything to 0
subtractagain	sec
	sbc hsubhspeedadd,x
	beq dhss2 ; 10/17/2017
	bcs stassspsumn
dhss2	dec hspeedsum,x ; 10/17/2017
	bmi JMPgostopeverything
stassspsumn sta hsubspeedsum,x
	lda hspeedsum,x
setcarry	sec
	sbc hspeedadd,x
JMPGOSTOPEVERYTHING	bmi gostopeverything
STASPSUM STA hspeedsum,x
	cmp #0
	bne addtox
	LDY #0
	jsr stopeverything
ADDTOX	lsr 
	lsr 
	lsr	
	LSR 
	BCS ADDTOPIXSPEED
	LDY #0
	JMP STYPIXREMAINDER 
ADDTOPIXSPEED LDY HPIXREMAINDER,x
	BEQ INCPIXREMAINDER
	CLC
	ADC #1
	LDY #0
	JMP STYPIXREMAINDER
INCPIXREMAINDER LDY #1
STYPIXREMAINDER cpx #0
	beq styhpr0 
	sty hpixremainder1
	jmp stapx
styhpr0	STY HPIXREMAINDER
stapx	sta pixeladd,x
	CMP #0
	BEQ ADDRTS
ADDTOfighterX lda fighterHorState,x
	bmi subtractpixels	
	lda pixeladd,x
	CLC
	ADC fighterX,x
	jmp stafighterx
subtractpixels	lda fighterx,x
	sec
	sbc pixeladd,x
stafighterx 
MAXXBOUNDARY=195
MINXBOUNDARY=52

checkxboundariesa	CMP #MAXXBOUNDARY
	BCC checkminxa
	lda #0
	sta hsubspeedsum,x
	STA hspeedsum,X
	STA hsubhspeedadd,X
	STA hspeedadd,X
	LDA #MAXXBOUNDARY
	bne stafighterxmaxa
checkminxa	CMP #MINXBOUNDARY
	BCS STAFIGHTERXmaxa
	lda #0
	sta hsubspeedsum,x
	STA hspeedsum,X
	STA hsubhspeedadd,X
	STA hspeedadd,X
	LDA #MINXBOUNDARY
stafighterxmaxa	STA fighterX,x
addrts	RTS	

gostopeverything LDY #0 
	JMP stopeverything ; INCLUDES rts

vPHYSICS LDA fightervertState,X
	CMP LASTfightervertState,X
	beq vdonephysics ; IF fighterSTATE HASN'T CHANGED, JUST NEED TO ADD CURRENT ACCELERATION
	STA LASTfightervertState,X
	AND #127
vRightStates cmp #$4
	bne vcheckrunr ;0 - STILL, 1 - DIAG, 2 - RUN, 3 - SKID, 4-DECEL, 128 - GOING LEFT 
vsetupdecel	jmp vDecel  ;includes rts bi-directional
vcheckrunr cmp #2 ; run
	bne vcheckskidr 
	jmp vrunACTIONS0 ; includes rts bi-directional 
vcheckskidr	cmp #3 ; skid
	bne vcheckwalk
	jmp vskid       ; includes rts one way
vcheckwalk jmp vwalk ; includes rts bi-directional
vdonephysics rts



;SUBSUBSUB PIXEL
vADDTOSPEED	lda fightervertadding,x
	beq vdecelerating
vaccelerating	lda vsubvspeedadd,x
	beq vsubpixel
	CLC
	adc vsubspeedsum,x
	bcc vaddagain
  	INC vspeedsum,x
vaddagain	CLC ; 9/27 - Increase PAL Speed
	adc vsubvspeedadd,x
	bcc vstasubspeed
  	INC vspeedsum,x

vSTAsubspeed STA vsubspeedsum,x
vSUBpiXEL
	LDA vspeedsum,x
	clc
	adc vspeedadd,x
	CMP vspeedmax,x
 	BCC stavspeedsum
 	lda vspeedmax,x
stavspeedsum jmp vstaspsum

vdecelerating lda vsubspeedsum,x
	sec
	sbc vsubvspeedadd,x
	bcs vstassspsumn
	dec vspeedsum,x
	bmi vgostopeverything
vstassspsumn sta vsubspeedsum,x
	lda vspeedsum,x

vsetcarry	sec
	sbc vspeedadd,x
	bmi vgostopeverything
vSTASPSUM STA vspeedsum,x
	cmp #0
	bne vaddtox
	LDY #fightervertdirection-fighterHORdirection
	jsr stopeverything ; INCLUDES RTS v
vADDTOX	lsr 
	lsr 
	lsr	
	LSR
	cmp #vpixelmaxspeed
	bcc stavpx
	lda #vpixelmaxspeed
stavpx	sta vpixeladd,x ; temp variable?
	BEQ vADDRTS
vADDTOfighterX lda fightervertState,x
	bmi vsubtractpixels	
	lda vpixeladd,x
	CLC
	ADC fightertopy,x
; VERTICAL BOUNDARY CHECK
	cmp #maxyboundary
	bcc stafightery
	lda #0
	sta Vsubspeedsum,x
	STA Vspeedsum,X
	STA VsubVspeedadd,X
	STA Vspeedadd,X


	lda #maxyboundary ;199
	jmp stafightery
vsubtractpixels	lda fightertopy,x
	sec
	sbc vpixeladd,x
	cmp #minyboundary ;48
	bcs stafightery
	lda #0
	sta Vsubspeedsum,x
	STA Vspeedsum,X
	STA VsubVspeedadd,X
	STA Vspeedadd,X
	lda #minyboundary ;48
stafightery	STA fightertopy,x
	sta ychanged,x
	jsr changeimage
vaddrts	RTS	

vgostopeverything 	LDY #fightervertdirection-fighterHORdirection
	JMP stopeverything ; INCLUDES RTS
;	rts
stillhorcollision 
	lda fighterhorstate,y
	sta fighterhorstate,x
	lda #0	
	sta fighterhoradding,x
	lda hspeedsum,y
	sta hspeedsum,x
	lsr
	sta hspeedsum,y
	rts
stillvertcollision 
	lda fightervertstate,y
	sta fightervertstate,x
	lda #0	
	sta fightervertadding,x
	lda vspeedsum,y
	sta vspeedsum,x
	lsr
	sta vspeedsum,y
	rts
	
mazecollisions	
CheckSlime 	lda p0pf,X ; P0toPfCD OR ; P2toPfCD
	ora p1pf,X ; P1toPfCD OR ; P3toPfCD
	bit two
	beq noslime
	LDA #24
	STA BACKGROUNDCOLOR


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - HIT SLIME - START
	lda #0
    sta freq1
    lda #76
    sta cntrl1
    lda #20
    sta dura1
    lda #0
    sta trgt1
; SOUND - HIT SLIME KICKOFF - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	
	cpx #0
	bne declifes1
	lda lastdeath0
	bne nowall
	dec lifes0 ;,x
	lda #1
	sta lastdeath0
	jmp nowall ; don't let them lose two lives
declifes1 	lda lastdeath1
	bne nowall
	dec lifes1 ;,x
	lda #1
	sta lastdeath1
	jmp nowall ; don't let them lose two lives
noslime
; UNCOMMENT THE BELOW TO MAKE WALLS DEADLY
;ElectricWallCollide 	lda p0pf,X ; P0toPfCD OR ; P2toPfCD
;	ora p1pf,X ; P1toPfCD OR ; P3toPfCD
;	bit one
;	beq nowall
;	cpx #0
;	bne declifes1a
;	dec lifes0 ;,x
;	jmp nowall
;declifes1a dec lifes1
nowall
; when you hit the walls, the life and bullet counts screw up
checkbullets lda p0pf,x
	ora p1pf,x
	and #4
	beq nobullets

; EBH - BULLET PACK PICK-UP SOUND - START 	
	LDA #12   ;8
; 	LDA #$b
 	sta freq1
    sta ofreq1
    lda #11   ;7
;    LDA #$a
    sta freq2
    sta ofreq2
    lda #166
;    LDA #$ea
    sta cntrl1
    sta cntrl2
    lda #36 ; 36    ; 12
    LDA #$6a
    sta dura1
    sta dura2 
    lda #0  ; 0
;	LDA #$ea
    sta trgt1
    sta trgt2
    lda #-4 ; -2
;    LDA #$ea
    sta dstp1
    sta dstp2
; EBH - BULLET PACK PICK-UP SOUND - END
	
	cpx #0
	beq ldabs0x
	ldx #1
ldabs0x	lda bullets0,x
	clc
	adc #3
	cmp #11
	bcc stabullets
	lda #10
	;here here
stabullets	sta bullets0,x
	LDX #0
	jsr resetbullet
	
	ldx #bulletdisplayed1-bulletdisplayed
	JSR RESETBULLET

nobullets
MCDRTS	rts

;**********************************************************************************************************
; ACTIONS0 Routines - All Jump to checkshoot
;**********************************************************************************************************
;*** No ACTIONS0	
CHECKFORDECEL	lda actions0,x
	cmp #15
	beq cfd
cfd	lda fighterHorState,x
	BMI CHECKLEFTDECEL
CHECKRIGHTDECEL 	LDA ACTIONS0,x	
	AND #8
	BEQ CHECKUPDOWNDECEL
	JMP RIGHTDECEL
CHECKLEFTDECEL	LDA ACTIONS0,x 
	AND #4
	BEQ CHECKUPDOWNDECEL
	JMP LEFTDECEL		
CHECKUPDOWNDECEL cpx #0
	bne loadRightCharControl 
	LDA LeftCharControl
	bne ldyevs
loadRightCharControl lda RightCharControl	
ldyevs	LDy fighterVERTSTATE,x
	BMI CHECKUPDECEL
	AND #2
	BEQ DONEWITHCHECKFORDECEL
	JMP DOWNDECEL
CHECKUPDECEL AND #1
	BEQ DONEWITHCHECKFORDECEL
	JMP UPDECEL	
DONEWITHCHECKFORDECEL RTS 
		 
leftdecel lda #$84
	ldy #0; fighterhordirection IS FACING LEFT
stahorDECEL 	STA fighterHorState,x
	tya
	STa fighterhordirection,x
	lda #0
	STa fighterhoradding,x ;ADDSTATE
 	jsr horcheckifstill
 	jmp checkupdowndecel
RIGHTDECEL lda #4
	ldy #1 ; fighterhordirection IS FACING Right
	BNE STAHORDECEL ; JMP
updecel lda #$84
	ldy #0; fighterhordirection IS FACING LEFT
	BEQ STAVERTDECEL ;JMP
DOWNDECEL lda #4
	ldy #1 ; fighterhordirection IS FACING Right
staVERTDECEL 	STA fighterVERTState,x
	tya 
	STa fighterVERTdirection,x
	lda #0
	STa fighterVERTadding,x ;ADDSTATE
 	jmp vertcheckifstill
 ; 	RTS
	
horcheckifstill lda fighterHorState,x
	and #7
	cmp #4
	beq dohorcheckifstill
	cmp #3 ; skidding
	bne bailNOACTION
dohorcheckifstill lda hspeedsum,x ;fighterstate is going right
	bmi jsrstopeverything ; If sum is negative, set everything to 0
	lda hspeedsum,x
	bne bailNOACTION
jsrstopeverything LDY #0	
	jmp stopeverything ;has rts will return to horcheckifstillcall
bailNOACTION	rts ; jmp CHECKUPDOWNDECEL ;checkshoot

vertcheckifstill lda fightervertState,x
	and #7
	cmp #4
	beq dovertcheckifstill
	cmp #3 ; skidding
	bne vbailNOACTION
dovertcheckifstill lda vspeedsum,x ;fighterstate is going right
	bmi jsrstopeverythingV ; If sum is negative, set everything to 0
	lda vspeedsum,x
	bne vbailNOACTION
jsrstopeverythingv		LDY #fightervertdirection-fighterHORdirection
	jMP stopeverything ; INCLUDES RTS
vbailNOACTION rts	

changecolorssub	asl ; Why?
	tax	
	stx tempx
	lda #0
	jmp cpy0
addagaincc dey
	add #6	
cpy0	cpy #0
	bne addagaincc
	add tempx
	tax
	lda char1colors,x
	tay
	lda char1colors+1,x
	ldx #0
	stx $5690 ; EBH reset music loop counter to zero if user does something
	ldx tempx ; to be safe
	rts

; **********************************************************************************************************
; ****************Common Routines That mimic Basic Commands***************************************	 
; Source: https://www.atariarchives.org/alp/chapter_10.php
; **********************************************************************************************************

Graphics sta currgraphicsmode	
;	PHA ; Call BASIC Graphics Mode. LDA BASIC#, JSR Graphics 
	LDX #$60 ; IOCB6 for screen
    LDA #$C       ; CLOSE command
    STA ICCOM,X   ; in command byte
    JSR CIOV      ; Do the CLOSE
    LDX #$60      ; The screen again
    LDA #3        ; OPEN command
    STA ICCOM,X   ; in command byte
    LDA #NAME&255 ; Name is "S:"
    STA ICBAL,X   ; Low byte
    LDA #NAME/256 ; High byte
    STA ICBAH,X
 	lda currgraphicsmode;   PLA
   	STA ICAX2,X   ; Graphics mode
    AND #$F0      ; Get high 4 bits
    EOR #$10      ; Flip high bit
    ORA #$C       ; Read or write
    STA ICAX1,X   ; n+16, n+32 etc.
    JSR CIOV      ; end of Setup GRAPHICS 7
	LDA >font ;#$38     ; EBH - added to point to redefined charset - START
	STA CHBAS ;$2f4   ; EBH - added to point to redefined charset - END	
	RTS
		    ; ******************************
            ; The POSITION command
            ; ******************************
            ; Identical to the BASIC
            ; POSITION X,Y command.
            ; Since X may be greater than
            ; 255 in GRAPHICS 8, we need to
            ; use the accumulator for the
            ; high byte of X.
POSITION
	STX COLCRS    ; Low byte of X
	STA COLCRS+1  ; High byte of X
	STY ROWCRS    ; Y position
	RTS           ; All done
SETTOPOFSCREENMEMORY
	LDA 89
	STA SCRHI
	LDA 88
	STA SCRLO
	RTS
; **********************************************************************************************************
; SET UP PLAYFIELD
; *********************************************************************************************************
screenSetup ; rts ; remove rts to draw border
; FIND TOP CORNER OF SCREEN MEMORY
	JSR SETTOPOFSCREENMEMORY
; top border
	jsr topborder
	ldx #21
borderloop	
; Left border
	LDy #1 
	JSR SETYLINE ; MOVE ONE LINE DOWN TO LINE 6
	LDY #255 ; LEFT PIXEL
	STY LEFTPIXEL
	LDY #0 ; RIGHT PIXEL
	LDA #11
	jsr drawloop
; right border	
	LDY #38 ; LEFT PIXEL
	STY LEFTPIXEL
	LDY #39 ; RIGHT PIXEL
	ldA #11
	jsr drawloop
	dex
	bne borderloop
	jsr topborder
	RTS
topborder	
	;FIND VERT AREA TO DRAW GROUND
	LDy #1; WANT TO START DRAW  ON 5TH LINE
	JSR SETYLINE ; CALL SUBROUTINE TO INCREASE Y POSITION
; SCREEN DRAW GOES FROM RIGHT TO LEFT - LEFT PIXEL AND RIGHT PIXEL ARE STARTING AND ENDING POSITIONS
	lda #8+128
	STA (SCRLO),Y

	ldy #39
	lda #8+128
	STA (SCRLO),Y
	
	LDY #0 ;255 ; LEFT PIXEL - 1 ;
	STY LEFTPIXEL
	LDY #38 ; RIGHT PIXEL
	ldA #10
	jsr drawloop ; SUBROUTINE TO PLACE CHARACTERS ON THE SCREEN AT YPOSITION FROM RIGHT PIXEL TO LEFT PIXEL
	rts
DRAWLOOP ;LDA #11+128 ;LDA MAZE,x
	STA (SCRLO),Y
	DEY
	CPY LEFTPIXEL
	bne DRAWLOOP
	RTS

SETYLINE	lda scrlo
ADDLOOP	CLC
	ADC #40 ; MOVE TO NEXT VERTICAL LINE - 40 BYTES PER LINE IN ATARI GRAPHICS
	BCC DEyANDLOOP
	INC SCRHI
DEyANDLOOP DEy
	BNE ADDLOOP
	STA SCRLO  ; UPDATE CURSOR POSITION ON SCREEN
	RTS
; **********************************************************************************************************
; end of PLAYFIELD SETUP
; **********************************************************************************************************
; **********************************************************************************************************
; 9. Start of VBI
; **********************************************************************************************************
VBISTART
; VBI has:
; - COLLISION DETECTION
; - PLAYER DRAWS
; - UPDATE HORIZONTAL VALUES
	lda #1
	sta 580 ; cold restart
	lda #64 ; disable break key
	sta 16; disable break key
	sta 53774; disable break key
	lda bulletx
	sta prevbulletx
	lda bullet1x
	sta prevbullet1x
MissileWidth	lda #85 ; EBH - brute force the correct bullet size
	sta sizem 
; convert correct stick to Left Character Control	
	ldx currchar1control
	cpx #2
	beq rightCharacterControl
	lda strig0,x
	sta leftcharbutton
	lda stick0,x
	sta LeftCharControl
; convert correct stick to Right Character Control		
RightCharacterControl
	ldx currchar2control
	cpx #2
	beq CPUrightCharacterControl
	lda strig0,x
	sta rightCharButton
	lda stick0,x
	sta	RightCharControl
CPUrightcharactercontrol
	LDA BACKGROUNDCOLOR
	STA COLOR4 	
	cmp defaultbgc
	beq flashingcolor
	SEC
	SBC #2	
	STA backgroundcolor
FLASHINGCOLOR
	LDA FLASH1
	LDX FLASH2
	STA COLOR1 
	STA FLASH2
	STX FLASH1
; END FLASHING COLOR
;**********************************************************************************************
; ROTATE IMAGES FOR LeftCharControl AND RightCharControl
;**********************************************************************************************
maxyboundary=201
minyboundary=48
; check y boundaries
	ldx #0
checkyboundaries	lda fightertopy,x
	cmp #maxyboundary ;199
	bcc checkmaxylda
	lda #maxyboundary ;199
	jmp stafighteryboundary
checkmaxylda 	cmp #minyboundary ;48
	bcs stafighteryboundary
	lda #minyboundary ;48
stafighteryboundary	STA fightertopy,x
	cpx #0
	bne checkxboundaries
	ldx #fightertopy1-fightertopy 
	bne checkyboundaries
checkxboundaries	;lda fighterX,x
;	CMP #MAXXBOUNDARY
;	BCC checkminx
;	LDA #MAXXBOUNDARY
;	jmp stafighterxmax
;checkminx	CMP #MINXBOUNDARY
;	BCS STAFIGHTERXmax
;	LDA #MINXBOUNDARY
;stafighterxmax	STA fighterX,x
;	cpx #0
;	beq donewithboundaries
;	ldx #0
;	jmp checkxboundaries
donewithboundaries


; STICK 0
	LDX #7
SLIMELOOP	LDA RANDOM
	;STA COLOR1
	AND RANDOM
	and #170 
	STA charset+8,x ;$3008,X
; electric walls
;	lda $d20a
	
;	and #85
;	sta $3050;,X
;	STA $3057
;	AND #128+64+1+2
;	sta $3058,x
	DEX
	BPL SLIMELOOP
;	STA $300A
;	STA $300B
	LDA GAMEON
	BNE LDACR
	JMP CLEARCD 
;	jmp 58466 ; end of VBI
LDACR	lda currrotate
	clc
	adc #1
	cmp #rotatespeed
	bcc storerotate
	LDA PIXELADD
	ORA VPIXELADD
	BEQ LDA0 
	lda LeftCharControl
	cmp #15
	beq lda0
	ldx #0
	JSR fighterWALK
LDA0	LDA #0
storerotate	sta currrotate
;RightCharControl
	lda currrotate1
	clc
	adc #1
	cmp #rotatespeed
	bcc storerotate1
	LDA PIXELADD1
	ORA VPIXELADD1
	BEQ LDA01 
	lda RightCharControl
	cmp #15
	beq lda01
	LDX #fighterhordirection1-fighterhordirection
	JSR fighterWALK 
LDA01	LDA #0
storerotate1	sta currrotate1
;**********************************************************************************************
; END ROTATE IMAGES FOR LeftCharControl AND RightCharControl
;**********************************************************************************************
;LeftCharControl speed 
	lda fighterHorState
	and #127
	beq verticalmovement ; if fighterstate is 0, skip physics and feet and go to vertical movement
	ldx #0
	JSR addtospeed
verticalMovement LDA fighterVertState
	and #127
	beq checkrotateimage
	ldx #0
	JSR vaddtospeed ;vPHYSICS
	jmp over
checkrotateimage 	lda currrotate
	bne over
	ldx #0
	jsr changeimage
over ;LDA #0 ;CLR HORIZONTAL SHADOWS

	lda fighterHorState1
	and #127
	beq verticalmovement1 ; if fighterstate is 0, skip physics and feet and go to vertical movement
	LDX #fighterhordirection1-fighterhordirection
	JSR addtospeed ;check this out
verticalMovement1 LDA fighterVertState1
	and #127
	beq checkrotateimage1
	LDX #fighterhordirection1-fighterhordirection

	JSR vaddtospeed 
	jmp over1
checkrotateimage1 	lda currrotate1
	bne over1
	LDX #fighterhordirection1-fighterhordirection
	jsr changeimage ;check this out
over1 ;LDA #0 ;CLR HORIZONTAL SHADOWS

; PM Horizontals
	LDx fighterX
	stx p0x
	STX P1X
	STX PREVfighterX
	LDx fighterX1
	stx p2x
	STX P3X
	STX PREVfighterX1
;eraseprevious bullets
	lda #0
	ldy prevbullety
	sta m0,y
	sta m0+1,y
	ldy prevbullet1y
	sta m0,y
	sta m0+1,y
;move bullets
	ldx #0 ; for LeftCharControl bullets
	ldy #0
	jsr moveanddrawbullets
	ldx #1 ; for RightCharControl bullets
	ldy #2
	jsr moveanddrawbullets

COLLISIONDETECTION
CHECKPLAYER0SHOT	LDA M0CD ; PLAYER 0 USES MISSILES 1&2
	ora m1cd ; Eliminate Horizontal Misses
	AND #12
	BEQ CHECKPLAYER1SHOT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - PLAYER (1) HIT BY BULLET - START
	LDA #24
	STA BACKGROUNDCOLOR
	lda #180
    sta freq2
    sta ofreq2
    lda #170
    sta cntrl2
    lda #50
    sta dura2
    lda #200
    sta trgt2
; SOUND - PLAYER (1) HIT BY BULLET  - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Difficult CPU - removes stutter
	lda #2
	cmp currchar2control
	bne decreaselife1
;	cmp fighter1wins
;	bne decreaselife1
	ldx #1
	ldy #fighterx1-fighterx
	jsr CPUEvacuate	
decreaselife1 DEC LIFES1 ; BULLET HIT PLAYER 1
	ldx #0
	jsr stopbulletsub
CHECKPLAYER1SHOT LDA M2CD ; PLAYER 1 USES MISSILES 2&3	
	ora m3cd ; Eliminate Horizontal Misses
	AND #3
	BEQ CheckPlayerCollision
	LDA #24
	STA BACKGROUNDCOLOR

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - PLAYER (0) HIT BY BULLET - START
	lda #180
    sta freq2
    sta ofreq2
    lda #170
    sta cntrl2
    lda #50
    sta dura2
    lda #200
    sta trgt2
; SOUND - PLAYER (0) HIT BY BULLET  - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Difficult CPU - removes stutter
	lda #2
	cmp currchar1control
	bne decreaselife0
;	cmp fighter2wins
;	bne decreaselife0
	ldx #0
	ldy #0
	jsr CPUEvacuate	
decreaselife0	DEC LIFES0 ; BULLET HIT PLAYER 0
	ldx #1
	jsr stopbulletsub

CheckPlayerCollision LDA P0PL
	ORA P1PL
	AND #12
	Bne ldafighterx
	jmp playfieldcollisions

ldafighterx
; SOUND - WHEN PLAYERS BUMP INTO EACH OTHER	- START
    lda #200  
    sta freq2
    lda #170
    sta cntrl2
    lda #28   
    sta dura2
    lda #254
    sta trgt2
; SOUND - WHEN PLAYERS BUMP INTO EACH OTHER - END
	lda fighterx
	cmp fighterx1
	bcs p0right
	sec
	sbc #1
	cmp #minxboundary
	bcs stafighterxbump
	lda fighterx1
	clc
	adc #3
	sta fighterx1
	lda #minxboundary

stafighterxbump sta fighterx
	lda fighterx1
	clc
	adc #1
	cmp #maxxboundary
	bcc stafighterx1bump
	lda fighterx
	sec
	sbc #3
	sta fighterx
	lda #maxxboundary

stafighterx1bump sta fighterx1
	jmp ldyfhs
p0right lda fighterx1
	sec
	sbc #1
	cmp #minxboundary
	bcs stafighterx1bumpa
	lda fighterx
	clc 
	adc #3
	sta fighterx
	lda #minxboundary
stafighterx1bumpa sta fighterx1
	lda fighterx
	clc
	adc #1
	cmp #maxxboundary
	bcc stafighterxbumpa
	lda fighterx1
	sec
	sbc #3
	sta fighterx1
	lda #maxxboundary
stafighterxbumpa sta fighterx

	

ldyfhs	ldy fighterhorstate
	beq f0horstill
	lda fighterhorstate1
	beq F1horstill
bothmoving sta fighterhorstate
	sty fighterhorstate1
	lda #0	
	sta fighterhoradding
	sta fighterhoradding1
	lda hspeedsum
	ldy hspeedsum1
	sta hspeedsum1
	sty hspeedsum
	jmp setvertcollision
f0horstill ldx #0
	ldy #fighterhorstate1-fighterhorstate
	jsr stillhorcollision 
	jmp setvertcollision
f1horstill	ldy #0
	ldx #fighterhorstate1-fighterhorstate
	jsr stillhorcollision

setvertcollision ldy fightervertstate
	beq f0vertstill
	lda fightervertstate1
	beq F1vertstill
bothmovingvert sta fightervertstate
	sty fightervertstate1
	lda #0	
	sta fightervertadding
	sta fightervertadding1
	lda vspeedsum
	ldy vspeedsum1
	sta vspeedsum1
	sty vspeedsum
	jmp playfieldcollisions
f0vertstill ldx #0
	ldy #fightervertstate1-fightervertstate
	jsr stillvertcollision 
	jmp playfieldcollisions
f1vertstill	ldy #0
	ldx #fightervertstate1-fightervertstate
	jsr stillvertcollision
; if moving down or right, stop when hitting (c2 or c3) AND (c0 or c1)
; if moving up or left, stop when hitting c0 or c1
playfieldcollisions 
Checkfighter1pf ldY #0
	ldX #0	
	jsr mazecollisions
	LDY #fighterHORstate1-fighterHORstate 
 	ldX #2 ; 2 TO CHECK COLLISION FOR P2& P3 WITH PLAYFIELD
	JSR MAZECOLLISIONS
CLEARCD	STA 53278 ; CLEARS cd REGISTERS 
; print bullets and lives 
printbulletsandlives
printlives	;ldy #0
;	ldx #2 ; LOW BYTE OF X
;	JSR POSITION
;	lda #0
;	sta printmode
;	ldY #lives&255 ; Lowbyte
;	lda #lives/256 ; hi byte
;	jsr Print
bulls0pos=2
lifes0pos=5
bulls1pos=38
lifes1pos=35
	lda currgraphicsmode
	cmp #2
	bne GAMESCREENON 
	JMP DONEWITHLIVESDISPLAY 
inverse=128
gamescreenon	
;bullet status bar
; 13 - no bullets
; 14 - 1 bullet
;15 - 2 bullets
	ldx #0
	lda #2
	jsr calcbulletdisp
	ldy #1
	sta (88),y
	lda #4
	jsr calcbulletdisp
	ldy #2
	sta (88),y
	lda #6
	jsr calcbulletdisp
	ldy #3
	sta (88),y
	lda #8
	jsr calcbulletdisp
	ldy #4
	sta (88),y
	lda #10
	jsr calcbulletdisp
	ldy #5
	sta (88),y



; left lifebar
	lda lifes0
	cmp #3
	bcc jsrcld
	lda #3
jsrcld	jsr calclivesdisp
	adc #16+128
	ldy #7
	sta (88),y
	
; mid lifebar
	lda lifes0
	cmp #7
	bcs load4
	cmp #4
	bcc load0
	sec
	sbc #3
	jsr calclivesdisp
	jmp add20
load0 lda #0
	jmp add20	
load4 lda #4
add20 clc	
	adc #20+128
	ldy	#8 ;lifes0pos
	sta (88),y
; right lifebar
	lda lifes0
	cmp #10
	beq load3lives
	cmp #7
	bcc draw0lives
	sec
	sbc #7
	jmp jsrcld2
load3lives lda #3
	bne addanddraw
draw0lives lda #0
	beq addanddraw	
jsrcld2	jsr calclivesdisp
addanddraw clc
	adc #25+128
	ldy #9
	sta (88),y
;live live 
; write Left W
	lda #40+128 
	ldy #10
	sta (88),y
fasdfa
; write Right W
	lda #41+128 
	ldy #11
	sta (88),y
; Write Fighter1 wins
	lda Fighter1wins
	clc
	adc #29+128 
	ldy #12
	sta (88),y

; write an R
	lda #39+128 
	ldy #19
	sta (88),y

; round number	
	lda round
	clc
	adc #29+128 
	ldy #20
	sta (88),y
; write Left W
	lda #40+128 
	ldy #26
	sta (88),y
; write Right W
	lda #41+128 
	ldy #27
	sta (88),y
; Write Fighter2 wins
	lda Fighter2wins
	clc
	adc #29+128 
	ldy #28
	sta (88),y
	
;right player Lives display	
	lda lifes1
	cmp #3
	bcc jsrcldr
	lda #3
jsrcldr	jsr calclivesdisp
	adc #16+128
	ldy #30
	sta (88),y
	
; mid lifebar
	lda lifes1
	cmp #7
	bcs load4r
	cmp #4
	bcc load0r
	sec
	sbc #3
	jsr calclivesdisp
	jmp add20r
load0r lda #0
	jmp add20r	
load4r lda #4
add20r clc	
	adc #20+128
	ldy	#31 ;lifes0pos
	sta (88),y
; right lifebar
	lda lifes1
	cmp #10
	beq load3livesr
	cmp #7
	bcc draw0livesr
	sec
	sbc #7
	jmp jsrcld2r
load3livesr lda #3
	bne addanddrawr
draw0livesr lda #0
	beq addanddrawr	
jsrcld2r	jsr calclivesdisp
addanddrawr clc
	adc #25+128
	ldy #32
	sta (88),y
;right player bullets display
	LDX #1
	lda #2
	jsr calcbulletdisp
	ldy #BULLS1POS-4
	sta (88),y
	lda #4
	jsr calcbulletdisp
	ldy #BULLS1POS-3
	sta (88),y
	lda #6
	jsr calcbulletdisp
	ldy #BULLS1POS-2
	sta (88),y
	lda #8
	jsr calcbulletdisp
	ldy #BULLS1POS-1
	sta (88),y
	lda #10
	jsr calcbulletdisp
	ldy #BULLS1POS
	sta (88),y


donewithlivesdisplay
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; SOUND - MAINTENANCE IN VBI - START
; USE THIS AREA SPARINGLY...


; SOUND - MAINTENANCE IN VBI  - END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

endofvbi	jmp 58466 ; end of VBI		
; **********************************************************************************************************
; end of VBI
; **********************************************************************************************************
; 10 Data Storage
; *********************************************************************************************************************
; fighter Direction Group Numbers
; *********************************************************************************************************************
faceLEFT=0
faceRIGHT=2
faceDOWNLEFT=4
faceDOWNRIGHT=6
faceUPLEFT=8
faceUPRIGHT=10
faceUP=12
faceDOWN=14
; bit definition for joystick direction.
RIGHTBIT:
.BYTE 8
LEFTBIT:
.BYTE 4
DOWNBIT:
.BYTE 2
UPBIT:
.BYTE 1
three
.byte 3
two
.byte 2
one
.byte 1
; Physics Data
; Min (s,ss:sss), accel (ss:sss), max (p:s)
; Defaults to NTSC
; If PAL is detected, Copies PAL VALUES OVER Default (no switching Back and Forth)
RunData:
.byte $3,$30,        $48,       $28
vRunData:
.byte $6,$60,        $80,       $50
Decelss=$d0 ;d0 ;243 ;755-13+1 ;$d
skids=$01 ; was $1
skidss=$a0
; Min (s,ss:sss), accel (ss:sss), max (p:s)
PALRunData:
.byte $4,$3a,        $6a,       $38
PALvRunData:
.byte $8,$78,        $bb,       $66
PALskids .byte $01 ; was $1
PALskidss .byte $c0

numcharacters
.byte 8 ;14 ;9 ; must be EQUAL to number of available characters
characterp0datalo
.byte <p0data,<p0data,<cowboyp0data,<manp0data,<Chadp0data,<hankp0data,<katep0data,<nerdp0data,<Dracp0data,<franp0data,<deadp0data,<Grimp0data,<Jakop0data,<JSonp0data
characterp0datahi
.byte >p0data,>p0data,>cowboyp0data,>manp0data,>Chadp0data,>hankp0data,>katep0data,>nerdp0data,>Dracp0data,>franp0data,>deadp0data,>Grimp0data,>Jakop0data,>JSonp0data

characterp1datalo
.byte <p1data,<p1data,<cowboyp1data,<manp1data,<Chadp1data,<hankp1data,<katep1data,<nerdp1data,<Dracp1data,<franp1data,<deadp1data,<Grimp1data,<Jakop1data,<Jsonp1data
characterp1datahi
.byte >p1data,>p1data,>cowboyp1data,>manp1data,>Chadp1data,>hankp1data,>katep1data,>nerdp1data,>Dracp1data,>franp1data,>deadp1data,>Grimp1data,>Jakop1data,>Jsonp1data
; *************************************************************************
; Grave Graphics
; *************************************************************************
SLIMEX .BYTE 20
SLIMEY .BYTE 12
SlimeMinX .byte 20
SlimeMaxx .byte 20
SlimeMinY .byte 12
SlimeMaxY .byte 12

SlimeMinPX .byte 127
SlimeMaxPx .byte 127
SlimeMinPY .byte 131
SlimeMaxPY .byte 131


graveHEIGHT=23
GraveP0COLORS=$0a
GraveP1COLORS=$f8


drawgrave	
	lda #0 ; ebh  
	sta $5691 ; ebh  set $5691 = #0, to indicate grave was drawn
	lda fighterx ; reposition fighters
	sta P0x ; reposition fighters
	sta p1x; reposition fighters
	lda fighterx1; reposition fighters
	sta p2x; reposition fighters
	sta p3x; reposition fighters
 
	jsr clearmissiles ; fix for remaining bullet	 	
	LDA #0 ; SHOW GRAVE FOR 5 SECONDS.
	sta gameon
	sta bullety	; fix for remaining bullet
	sta bullet1y	; fix for remaining bullet
	sta prevbullety; fix for remaining bullet
	sta prevbullet1y; fix for remaining bullet
	STA GRAVEDELAY
	cpx #0
	bne Fighter2isDead
	ldx >p0
	stx gravep0store+2
	inx
	stx gravep1store+2
	ldx #0
	ldy fightertopy
	cpy #maxyboundary-8
	bcc jscdg
	ldy #maxyboundary-8
	sty fightertopy
	
jscdg	jmp storecolors
fighter2isdead 	ldx >p2
	stx gravep0store+2
	inx
	stx gravep1store+2	
	ldx #2
	ldy fightertopy1
	cpy #maxyboundary-8
	bcc storecolors
	ldy #maxyboundary-8
	sty fightertopy1

storecolors	lda #GraveP0Colors
	sta 704,x
	lda #Gravep1Colors
	sta 705,x
stygp0	sty gravep0store+1
	sty gravep1store+1
	ldx #graveheight
graveloop lda gravep0data,x	
gravep0store	sta p0,x 
	lda gravep1data,x
gravep1store sta p1,x
	dex
	bpl graveloop
	rts

;MAZE   .BYTE 0,1,2,3
;MAZE2 .BYTE 4,5,6,7
;MAZE3 .BYTE 8,136,9,10	
;MAZE   .BYTE 2,2,2
	org $A000	
Charset 
.byte 0,0,0,0,0,0,0,0 ;   0
.byte 0,0,0,0,1,5,21,85 ; 1 left top square
.byte 0,0,0,0,85,85,85,85 ; 2 right top square
.byte 0,0,0,0,85,87,95,127 ; 3 left mid square
.byte 1,5,21,85,170,170,170,170 ; 4 right mid square	
.byte 85,85,85,85,170,170,170,170 ; 5 left bottom square
.byte 85,87,95,127,255,255,255,255 ;  6 left bottom square
.byte 255,255,255,255,255,255,255,255 ;  7 left bottom square
.byte 85,85,125,125,125,125,85,85 ;   8 corner

.byte 255,255,255,252,240,192,0,0 ; 9
.byte 85,85,85,0,0,85,85,85 ; 10
.byte 69,69,69,69,69,69,69,69 ; 11 pattern
.byte 0,48,0,48,0,48,0,0 ; 12 bullets
.byte 0,0,0,0,0,0,0,0 ; 13 bullets
.byte 0,64,192,192,192,192,0,0 ; 14 bullet
.byte 0,68,204,204,204,204,0,0 ; 15 bullets

;Life Status Bar Data
left0
.byte 255,192,192,192,192,192,255,0 ; 16

left1
.byte 255,224,224,224,224,224,255,0 ; 17
left2

.byte 255,232,232,232,232,232,255,0 ; 18
left3
.byte 255,234,234,234,234,234,255,0 ; 19


mid0
.byte 255,0,0,0,0,0,255,0 ; 20
mid1
.byte 255,128,128,128,128,128,255,0 ; 21
mid2
.byte 255,160,160,160,160,160,255,0 ; 22
mid3
.byte 255,168,168,168,168,168,255,0 ; 23
mid4
.byte 255,170,170,170,170,170,255,0 ; 24

right0
.byte 255,3,3,3,3,3,255,0 ; 25
right1
.byte 255,131,131,131,131,131,255,0 ; 26
right2
.byte 255,163,163,163,163,163,255,0 ; 27
right3
.byte 255,171,171,171,171,171,255,0 ; 28

numbers
.byte 0,60,195,207,243,195,60,0 ; 0
.byte 0,12,60,12,12,12,63,0 ; 1
;.byte 0,60,195,3,12,48,255,0 ; 2
.byte 0,12,51,3,12,48,63,0  ; 2

.byte 0,60,3,12,3,3,60,0 ; 3
.byte 0,12,60,60,204,255,12,0 ; 4
.byte 0,255,192,252,3,195,60,0 ; 5
.byte 0,60,192,252,195,195,60,0 ; 6
.byte 0,255,3,12,60,48,48,0 ; 7
.byte 0,60,195,60,195,195,60,0 ; 8
.byte 0,60,195,195,63,3,60,0 ; 9
.byte 0,252,195,195,252,204,195,0; r +39
.byte 0,12,12,12,12,15,3,0; Wleft +40
.byte 0,12,12,204,204,252,48,0; Wright +41
GAMEOVER
.byte 60,195,195,192,207,195,195,60 ; G
.byte 15,48,48,48,63,48,48,48 ; space, A start
.byte 12,204,207,207,204,204,204,204; A,space,M
.byte 12,12,60,252,204,12,12,12 ; M, Space
.byte 255,192,192,252,192,192,192,255; E
.byte 0,0,0,0,0,0,0,0 ; space
.byte 60,195,195,195,195,195,195,60; O
.byte 48,48,48,60,12,15,3,3; space, V
.byte 51,51,51,243,195,195,3,3 ;v,space,e
.byte 252,0,0,240,0,0,0,252; e, space
.byte 252,195,195,195,252,204,195,195;R
; EBH added below for character set redefinition for title screen
; Character set redefinition - START
	ORG charset+$400;$9800   
FONT
.BYTE 0,0,0,0,0,0,0,0
.BYTE 96,144,144,147,148,136,128,128
.BYTE 12,18,18,146,82,34,2,2
.BYTE 7,8,16,32,67,132,136,135
.BYTE 192,32,16,8,132,66,34,194
.BYTE 127,128,128,128,135,136,136,135
.BYTE 224,16,8,4,130,66,34,194
.BYTE 7,8,16,32,67,132,136,143
.BYTE 192,32,16,8,132,66,34,226
.BYTE 112,136,132,130,129,128,128,128
.BYTE 28,34,66,130,2,2,2,2
.BYTE 128,128,128,129,130,132,136,112
.BYTE 2,2,2,2,130,66,34,28
.BYTE 128,128,140,138,137,136,136,112
.BYTE 4,24,32,16,8,132,66,60
.BYTE 7,8,16,32,67,132,136,143
.BYTE 0,60,98,102,106,114,60,0
.BYTE 0,24,56,24,24,24,24,0
.BYTE 0,60,70,12,24,50,126,0
.BYTE 0,96,96,96,99,119,127,127
.BYTE 0,12,12,12,140,220,252,252
.BYTE 0,7,15,31,60,123,119,120
.BYTE 0,192,224,240,120,188,220,60
.BYTE 0,124,6,6,6,6,6,0
.BYTE 0,224,240,248,124,188,220,60
.BYTE 0,7,15,31,60,123,119,112
;.BYTE 0,0,24,24,0,24,24,0
.BYTE 0,42,42,42,42,73,73,0  ; redefined the colon ":" as a fuji
.BYTE 143,136,132,67,32,16,8,7
.BYTE 226,34,66,132,8,16,32,192
.BYTE 128,128,136,148,147,144,144,96
.BYTE 2,2,34,82,146,18,18,12
.BYTE 127,127,115,113,112,112,112,0
.BYTE 248,224,192,224,240,120,60,0
.BYTE 0,60,98,98,98,126,98,0
.BYTE 0,60,98,98,124,98,124,0
.BYTE 0,60,98,96,96,98,60,0
.BYTE 0,56,100,98,98,98,124,0
.BYTE 0,62,96,96,124,96,126,0
.BYTE 0,62,96,96,124,96,96,0
.BYTE 0,127,127,127,120,119,119,120
.BYTE 0,98,98,98,126,102,102,0
.BYTE 0,60,24,24,24,24,60,0
.BYTE 0,6,6,6,102,102,60,0
.BYTE 0,102,108,120,112,108,102,0
.BYTE 0,96,96,96,96,96,62,0
.BYTE 127,127,119,99,96,96,96,0
.BYTE 0,98,114,122,94,78,70,0
.BYTE 0,60,98,98,98,98,60,0
.BYTE 0,60,102,102,102,124,96,0
.BYTE 252,252,220,140,12,12,12,0
.BYTE 0,60,98,98,98,124,102,0
.BYTE 0,62,64,124,62,2,124,0
.BYTE 0,126,24,24,24,24,24,0
.BYTE 0,98,98,98,98,98,60,0
.BYTE 0,102,102,102,102,36,24,0
.BYTE 0,97,97,105,125,119,99,0
.BYTE 112,119,123,60,31,15,7,0
.BYTE 0,98,98,98,60,24,24,0
.BYTE 28,220,188,120,240,224,192,0
.BYTE 0,192,224,240,120,188,220,28
.BYTE 0,112,120,124,126,127,127,127
.BYTE 0,28,60,124,252,252,252,252
.BYTE 127,127,127,126,124,120,112,0
.BYTE 252,252,252,252,124,60,28,0
.BYTE 0,54,127,127,62,28,8,0
.BYTE 60,126,227,227,227,227,227,227
.BYTE 227,230,252,254,231,227,227,227
.BYTE 60,126,227,227,227,227,227,227
.BYTE 227,227,255,255,227,227,227,227
.BYTE 126,126,24,24,24,24,24,24
.BYTE 24,24,24,24,24,24,126,126
.BYTE 195,195,195,195,227,227,243,211
.BYTE 15,31,63,63,63,63,31,15
.BYTE 219,203,207,199,199,195,195,195
.BYTE 240,248,252,252,252,252,248,240
.BYTE 60,126,227,227,227,227,227,227
.BYTE 227,227,227,227,227,227,126,60
.BYTE 255,255,24,24,24,24,24,24
.BYTE 24,24,24,24,24,24,24,24
.BYTE 63,127,240,224,224,224,224,224
.BYTE 224,254,254,224,224,224,255,255
.BYTE 0,0,0,31,31,24,24,24
.BYTE 0,0,0,255,255,0,0,0
.BYTE 24,24,24,255,255,24,24,24
.BYTE 0,0,60,126,126,126,60,0
.BYTE 0,0,0,0,255,255,255,255
.BYTE 192,192,192,192,192,192,192,192
.BYTE 0,0,0,255,255,24,24,24
.BYTE 24,24,24,255,255,0,0,0
.BYTE 240,240,240,240,240,240,240,240
.BYTE 24,24,24,31,31,0,0,0
.BYTE 120,96,120,96,126,24,30,0
.BYTE 0,24,60,126,24,24,24,0
.BYTE 0,24,24,24,126,60,24,0
.BYTE 0,24,48,126,48,24,0,0
.BYTE 0,24,12,126,12,24,0,0
.BYTE 0,24,60,126,126,60,24,0
.BYTE 0,0,60,6,62,70,62,0
.BYTE 0,96,124,70,70,70,124,0
.BYTE 0,0,60,98,96,98,60,0
.BYTE 0,6,62,98,98,98,62,0
.BYTE 0,0,60,98,124,96,62,0
.BYTE 0,60,98,96,120,96,96,0
.BYTE 0,0,60,98,98,62,6,124
.BYTE 0,96,108,118,102,102,102,0
.BYTE 0,24,0,24,24,24,24,0
.BYTE 0,6,0,6,6,70,70,60
.BYTE 0,96,108,120,112,108,102,0
.BYTE 0,56,24,24,24,24,24,0
.BYTE 0,0,54,107,107,107,99,0
.BYTE 0,0,60,102,102,102,102,0
.BYTE 0,0,60,98,98,98,60,0
.BYTE 0,0,124,70,70,70,124,96
.BYTE 0,0,62,98,98,98,62,6
.BYTE 0,0,124,98,96,96,96,0
.BYTE 0,0,62,96,60,2,124,0
.BYTE 0,24,126,24,24,24,24,0
.BYTE 0,0,102,102,102,102,60,0
.BYTE 0,0,98,98,98,52,24,0
.BYTE 0,0,99,107,107,127,54,0
.BYTE 0,0,102,52,24,44,102,0
.BYTE 0,0,98,98,98,62,12,120
.BYTE 0,0,126,12,24,48,126,0
.BYTE 0,24,60,126,126,24,60,0
.BYTE 24,24,24,24,24,24,24,24
.BYTE 0,126,120,124,110,102,6,0
.BYTE 8,24,56,120,56,24,8,0
.BYTE 16,24,28,30,28,24,16,0

; Character set redefinition - END 
; *************************************************************************
; turn on VBI 
; *************************************************************************
; Put nothing below VARIABLES label!!!!!!!!!!!!!!!!
VARIABLES
; sound - theme song
	org $4ffa
	ins 'batcmp9.xex'
; sound - theme song


;	@com.wudsn.ide.asm.mainsourcefile=PACMAN.ASM

;	SPACE	2
;	Operating System Equates  ------------------------
;	SPACE	1
DOSVEC	EQU	$000A	;this program's start vector
DOSINI	EQU	$000C	;this program's init vector
POKMSK	EQU	$0010	;mask for POKEY IRQ enable
BRKKEY	EQU	$0011	;BREAK flag
RTCLOK	EQU	$0012	;60 Hz clock

ATRACT	EQU	$4D
DRKMSK	EQU	$4E
COLRSH	EQU	$4F

VDSLST	EQU	$0200
VIMIRQ	EQU	$0216	;immediate IRQ vector
SRTIMR	EQU	$022B	;software-driven keydown timer
SDMCTL	EQU	$022F	;DMA control shadow
SDLSTL	EQU	$0230	;display list pointer (low byte)
SDLSTH	EQU	$0231	;display List pointer (high byte)
SSKCTL	EQU	$0232	;serial port control
LPENH	EQU	$0234	;light pen horizontal position
LPENV	EQU	$0235	;light pen vertical postion
GPRIOR	EQU	$026F	;player priority select
PADDL0	EQU	$0270	;pot 0
STICK0	EQU	$0278	;joystick 0 shadow
STRIG0	EQU	$0284	;red button 0 shadow
STRIG1	EQU	$0285	;red button 1 shadow
SHFLK	EQU	$02BE	;shift-lock flag
PCOLR0	EQU	$02C0	;player color shadow
PCOLR1	EQU	$02C1	
PCOLR2	EQU	$02C2	
PCOLR3	EQU	$02C3	
COLOR0	EQU	$02C4	;playfield color shadow
COLOR1	EQU	$02C5
COLOR2	EQU	$02C6
COLOR3	EQU	$02C7
MEMLO	EQU	$02E7	;start of user memory
KEYDEL	EQU	$02F1	;KEY DELAY
CHART	EQU	$2F3	;character control
CHBAS	EQU	$2F4	;character base address
CH	EQU	$02FC	;character buffer
DDEVIC	EQU	$0300	;peripheral bus ID number
DUNIT	EQU	$0301	;unit number
DCOMND	EQU	$0302	;bus command ordinal
DSTATS	EQU	$0303	;command type/status return
DBUFLO	EQU	$0304	;data buffer pointer
DBUFHI	EQU	$0305
DTIMLO	EQU	$0306	;device timeout in seconds
DBYTLO	EQU	$0308	;number of bytes transferred
DBYTHI	EQU	$0309
DAUX1	EQU	$030A	;command auxiliary bytes
DAUX2	EQU	$030B
ICCOM	EQU	$0342	;CIO command block
ICBAL	EQU	$0344
ICBAH	EQU	$0345
ICBLL	EQU	$0348
ICBLH	EQU	$0349
ICAX1	EQU	$034A
ICAX2	EQU	$034B

CHRORG	EQU	$E000	;OS charset
CIOV	EQU	$E456	;CIO request vector
SIOV	EQU	$E459	;SIO request vector
SETVBV	EQU	$E45C	;system interrupt init vector
XITVBV	EQU	$E462	;system VBLANK return handler
OSRETN	EQU	$E474	;system WARM START entry
CLICK	EQU	$FCD8	;keyclick routine
;	EJECT
;	Hardware Registers  --------------------------------
;	SPACE	1
HPOSP0	EQU	$D000	;player position registers
HPOSP1	EQU	$D001
HPOSP2	EQU	$D002
HPOSP3	EQU	$D003
M0PF	EQU	$D000	;missile 0 to playfield collision
M1PF	EQU	$D001
M2PF	EQU	$D002
M3PF	EQU	$D003
HPOSM0	EQU	$D004	;horizontal position of missile 0
HPOSM1	EQU	$D005
HPOSM2	EQU	$D006
HPOSM3	EQU	$D007
P0PF	EQU	$D004	;player 0 to playfield collision
M0PL	EQU	$D008	;missile 0 to player collision
M1PL	EQU	$D009
M2PL	EQU	$D00A
M3PL	EQU	$D00B
SIZEP0	EQU	$D008	;player size registers
P0PL	EQU	$D00C	;player 0 to player collision
SIZEM	EQU	$D00C	;sizes for all missiles
GRAFP0	EQU	$D00D	;graphics for player0
TRIG0	EQU	$D010	;joystick controller trigger 0
GRAFM	EQU	$D011	;grahics for all missiles
COLPM0	EQU	$D012	;player color registers
COLPM1	EQU	$D013
COLPM2	EQU	$D014
COLPM3	EQU	$D015
COLPF0	EQU	$D016	;playfield color registers
COLPF1	EQU	$D017
COLPF2	EQU	$D018
COLPF3	EQU	$D019
COLBK	EQU	$D01A	;color-luminance of background
PRIOR	EQU	$D01B	;priority select
VDELAY	EQU	$D01C	;vertical delay
GRACTL	EQU	$D01D	;graphics control register
HITCLR	EQU	$D01E	;collision clear
CONSOL	EQU	$D01F	;console key register
POT0	EQU	$D200	;pot 0
AUDF1	EQU	$D200	;audio channel 1 frequency
AUDC1	EQU	$D201	;audio channel 1 control
AUDF2	EQU	$D202	;audio channel 1 frequency

AUDC2	EQU	$D203	;audio channel 1 control

AUDF3	EQU	$D204	;audio channel 1 frequency

AUDC3	EQU	$D205	;audio channel 1 control

AUDF4	EQU	$D206	;audio channel 1 frequency

AUDC4	EQU	$D207	;audio channel 1 control

AUDCTL	EQU	$D208	;audio control
ALLPOT	EQU	$D208	;read 8 line pot port status
KBCODE	EQU	$D209	;keyboard code
STIMER	EQU	$D209	;start timer
RANDOM	EQU	$D20A	;random number generator
SERIN	EQU	$D20A	;serial port input
SKREST	EQU	$D20A	;reset serial port status
POTGO	EQU	$D20B	;start POT scan sequence
SEROUT	EQU	$D20C	;serial port output
IRQEN	EQU	$D20E	;IRQ enable mask
IRQST	EQU	$D20E	;IRQ status
SKCTL	EQU	$D20F	;serial port control
SKSTAT	EQU	$D20F	;keyboard status register
PORTA	EQU	$D300	;port A
DMACTL	EQU	$D400	;DMA control register
CHACTL	EQU	$D401	;character control
DLISTL	EQU	$D402	;display list pointer (low byte)
DLISTH	EQU	$D403	;display list pointer (high byte)
HSCROL	EQU	$D404	;horizontal scroll register
VSCROL	EQU	$D405	;vertical scroll register
PMBASE	EQU	$D407	;player base address
CHBASE	EQU	$D409	;character base address
WSYNC	EQU	$D40A	;wait for horizontal sync
VCOUNT	EQU	$D40B	;scan line counter
PENH	EQU	$D40C	;light pen horizontal position
PENV	EQU	$D40D	;light pen vertical position
NMIEN	EQU	$D40E	;interrupt enable register
NMIRES	EQU	$D40F	;NMI reset
NMIST	EQU	$D40F	;NMI status

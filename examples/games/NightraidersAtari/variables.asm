;--------------------------------
; DATA STORAGE AND VARIABLES
;--------------------------------
DATA
;--------------------------------
VDCNT      .BYTE $00        ; Vertical Blank Counte
SPARE      .BYTE $00
WINDOWVAR  .BYTE $00        ; Window Burning animation counter 0-2
RADARVAR   .BYTE $00        ; Radars Animation Counter 0-7
DELAYER    .BYTE $00        ; Delay Counter
TANKFLAG   .BYTE $00        ; Tank Flag to delay tank animations
TANKVAR    .BYTE $00        ; Tank Animations Counter 0-3
DELBAS     .BYTE $00        ; Base Animation Delay Counter
GUNSX      .BYTE $00,$00
GUNSX2     .BYTE $00,$00
GUNSY      .BYTE $00,$00
PRESS      .BYTE $00
HOLDER     .BYTE $00
SNDFLG     .BYTE $00
KILCNT     .BYTE $00
SPACFLG    .BYTE $00
BASFLG     .BYTE $00
BASER      .BYTE $00
TRNCNT     .BYTE $00
TRNFLG     .BYTE $00
TRNPNT1    .BYTE $00
TRNPNT2    .BYTE $00
TRNVAR1    .BYTE $00
TRNVAR2    .BYTE $00
SMISY      .BYTE $00
SAUCT      .BYTE $00
SAUCPNT    .BYTE $00
SAUCPNT2   .BYTE $00
SAUCFLG    .BYTE $00
SAUCDIR    .BYTE $00
SAUCY      .BYTE $00
SAUCNT     .BYTE $00
WRNCNT     .BYTE $00
VOLUM      .BYTE $00
VOLFLG     .BYTE $00
SNDCNT     .BYTE $00
BRDFLG     .BYTE $00
BRDPNT     .BYTE $00
CRUD       .BYTE $00
MISDIR     .BYTE $00
MISCNT     .BYTE $00
UFOEXP     .BYTE $00
UFKFLG     .BYTE $00
UFCNT      .BYTE $00
STRCNT     .BYTE $00
STRFAS     .BYTE $00
MUSCNT     .BYTE $00
MUSDEL     .BYTE $00
PSTRING    .BYTE $00
PSTATUS    .BYTE $00
FLYFLG     .BYTE $00
PATHPNT    .BYTE $00
WAVES      .BYTE $00
MIKEY      .BYTE $00
MIKEY2     .BYTE $00
MXDELAY    .BYTE $00
MXFLAG     .BYTE $00
MXSCRL     .BYTE $00
MXDEATH    .BYTE $00
MCNT       .BYTE $00
BASDEAD    .BYTE $00
CNTFIRE    .BYTE $00
;--------------------------------
; CHARACTER HIT TABLES
; USED BY THE CHARATER DESTROY
; ROUTINES
; EACH OBJECT IT IS RESERVED
; FIVE BYTES IN MEMORY
; BYTE 0 = EXPLOSION STATUS
; BYTE 1 & 2 = ADRESS HIT AT
; BYTE 3 = CHARACTER HIT   
; THERE IS ENOUGH ROOM FOR 
; TWENTY EXPLOSIONS AT ONCE
; THAT SHOULD BE ENOUGH!
;--------------------------------
HITABLE    .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00
ENDAT      .BYTE $FF
;--------------------------------
; NONZERO VARIABLES TO BE
; FILLED
;--------------------------------
NONDAT
;--------------------------------
TPL        .BYTE $40,$40
SNDFLG2    .BYTE $01
PNTBAS     .BYTE $07
FLYCNT     .BYTE $01
FLCNT      .BYTE $01
FLCNT2     .BYTE $1C
SPS1       .BYTE $FF
SPS2       .BYTE $A0
MISAUC     .BYTE $50
EXPSND     .BYTE $FF
BRDCNT     .BYTE $FF
MUSCOM     .BYTE $FF
NONEND     .BYTE $00
;--------------------------------
STRGFIL    .BYTE $40,$40,$01,$07,$01,$01,$1C,$FF,$A0,$50,$FF,$FF,$FF
;--------------------------------
INITVAR    LDX #ENDAT-DATA-1
           LDA #$00
FDS7       STA DATA,X
           DEX
           BPL FDS7
           LDX #$0C 
FDS8       LDA STRGFIL,X 
           STA NONDAT,X
           DEX
           BPL FDS8
           RTS

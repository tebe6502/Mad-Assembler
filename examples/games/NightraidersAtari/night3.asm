;--------------------------------
; NIGHT 3
; SPACE ROUTINES
;--------------------------------
; SPACE ATTACKER ROUTINES
; ATTACKS PLAYER WITH ANDROID
; SHIPS
;--------------------------------
SPCATK     LDA SPACFLG
           BNE PF82
PF81       RTS
PF82       LDA MUSCNT
           CMP #$1A
           BEQ PF83
           CMP #$19
           BNE PF85
           LDA LEVEL
           CLC
           ADC #$01
           STA WAVES
PF85       LDA #$00   
           STA MUSDEL
           INC MUSCNT
           RTS
PF83       LDA #$2
           ADC MUSDEL
           STA MUSDEL
           CMP #$F0
           BCS PF84
           RTS
PF84       LDA #$00
           STA MUSDEL
           LDA WAVES
           BNE PF89
           INC MIKEY2
           LDA MIKEY2
           CMP #$30
           BNE PF87
           DEC SPACFLG
PF87       RTS
PF89       LDA FLYFLG  
           BNE ALLDEAD
;--------------------------------
; IF FLYFLAG NOT SET THEN WE
; INITIALIZE STRING PICK A
; RANDOM PATH AND INITIALIZE
; NUMBER OF PLANES TO KILL
;--------------------------------
           INC FLYFLG
           LDA RANDOM
           AND #$07
           CMP #$05
           BCC PF86
           LSR
PF86       ASL
           STA PATHPNT
           LDA #$00
           STA PSTRING
           STA PSTATUS
           LDX #$5F
PF88       LDA SPACL1,X
           STA $7380,X
           DEX
           BPL PF88
;--------------------------------
; PLOT SHIPS
;--------------------------------
ALLDEAD    LDA PSTATUS
           CMP #$FF
           BNE PF91
           DEC WAVES
           BNE PF92
           RTS
PF92       DEC FLYFLG
           RTS
PF91       LDX PATHPNT
           LDA PATHX,X
           STA TEMP1
           LDA PATHX+1,X
           STA TEMP2
           LDA PATHY,X
           STA TEMP3
           LDA PATHY+1,X
           STA TEMP4
           LDA PSHIP,X
           STA TEMP5
           LDA PSHIP+1,X
           STA TEMP6
           JSR ERASEPLN   ; PUTPLN lable was not used
           LDY PSTRING
           LDA (TEMP1),Y
           CMP #$FF
           BEQ PF94
           LDA (TEMP3),Y
           TAX
           LDA (TEMP5),Y
           PHA
           LDA (TEMP1),Y
           TAY
           LDA YLOW,X
           STA TEMP7
           LDA YHI,X
           STA TEMP8
           PLA
           PHA
           CMP #$74
           BNE PF93
           LDA SMISY
           ORA WRNCNT 
           ORA SAUCFLG
           BNE PF93
           TXA
           ASL
           ASL
           ASL
           CLC
           ADC #$19
           STA SMISY
           TYA
           ASL
           ASL
           CLC
           ADC #$2F
           STA HPOS3
           LDA #$00
           STA MISDIR
PF93       PLA
           STA (TEMP7),Y
           INY
           CLC
           ADC #$01
           STA (TEMP7),Y
           ADC #$01
           PHA
           TYA
           CLC
           ADC #$27
           TAY
           PLA
           STA (TEMP7),Y
           INY
           CLC
           ADC #$01
           STA (TEMP7),Y
           INC PSTRING
           RTS  
PF94       DEC FLYFLG
           RTS
;--------------------------------
; ERASE PLANES
;--------------------------------
ERASEPLN   LDY PSTRING
           BEQ FDS111
           DEY
           LDA (TEMP1),Y
           CMP #$FF
           BEQ FDS111
           LDA (TEMP3),Y
           TAX
           LDA (TEMP1),Y
           TAY
           LDA YLOW,X
           STA TEMP7
           LDA YHI,X
           STA TEMP8
           LDA #$00
           STA (TEMP7),Y
           INY
           STA (TEMP7),Y
           TYA
           CLC
           ADC #$27
           TAY
           LDA #$00
           STA (TEMP7),Y
           INY
           STA (TEMP7),Y
FDS111     RTS
;--------------------------------
; SPACE COLLISION HANDLER
;--------------------------------
SPACKIL    LDA #$00  
           TAY
           TAX
PF101      LDA PLANCHR,X
           CMP #$FF
           BEQ PF106
           CMP (IRQVAR1),Y
           BEQ PF102
           INX
PF106      CMP #$FF 
           BNE PF101
           JMP COLREND
PF102      LDA IRQVAR1
           SEC
           SBC PLANDIF,X 
           STA IRQVAR1
           BCS PF103
           DEC IRQVAR2
PF103      LDX #$00
PF104      LDA PLANFIND,X 
           BEQ PF105
           INX
           CMP #$FF
           BNE PF104
           JMP COLREND
PF105      LDA #$5 
           STA PLANFIND,X
           TXA
           ASL
           TAX
           LDA IRQVAR1
           STA PLANTIME,X
           LDA IRQVAR2
           STA PLANTIME+1,X
           LDA #$00
           STA EXPSND
           LDA #$FF
           STA PSTATUS
           LDX LEVEL
           INX
PF107      LDA BSCOR0
           CLC 
           ADC #$64 
           STA BSCOR0
           LDA BSCOR1  
           ADC #$00
           STA BSCOR1
           DEX
           BNE PF107
           JMP COLREND


PLANCHR    .BYTE $70,$71,$72,$73,$74,$75,$76,$77
           .BYTE $78,$79,$7A,$7B,$FF
PLANDIF    .BYTE $00,$01,$28,$29,$00,$01,$28,$29
           .BYTE $00,$01,$28,$29,$FF
PLANFIND   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $FF
PLANTIME   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
;--------------------------------
; KILLER2 KILLS SPACE CHARACTERS
;--------------------------------
KILLER2    LDA SPACFLG
           BNE STYX
           RTS
STYX       INC MIKEY
           LDA MIKEY
           CMP #$20
           BEQ RJS1
           RTS
RJS1       LDA #$00
           STA MIKEY
           TAX
RJS2       LDA PLANFIND,X
           CMP #$FF
           BNE RJS3
           RTS
RJS3       CMP #$00
           BNE RJS4
           INX
           BNE RJS2
RJS4       STX TEMP3
           DEC PLANFIND,X
           TXA
           ASL
           TAX
           LDA PLANTIME,X
           STA TEMP1
           LDA PLANTIME+1,X
           STA TEMP2
           LDX TEMP3
           LDA PLANFIND,X  
           BNE RJS5
           BEQ RJS6
RJS5       LDA #$30
RJS6       LDY #$00
           STA (TEMP1),Y
           INY
           STA (TEMP1),Y
           LDY #$28
           STA (TEMP1),Y
           INY
           STA (TEMP1),Y
           INX
           JMP RJS2

;--------------------------------
; MX SHOOTS MISSLES
;--------------------------------
MX         INC MXDELAY
           LDA MXDELAY
           CMP #$10
           BEQ RJS14
           RTS
RJS14      LDA #$00
           STA MXDELAY
           JSR MXKILL 
           LDA MXFLAG
           BNE MX2
           LDA LIST2+3
           CLC
           ADC #$40
           STA TEMP1
           LDA LIST2+4
           STA TEMP2
           BCC RJS11
           INC TEMP2
RJS11      INC TEMP2
           LDY #$27
RJS12      LDA (TEMP1),Y
           CMP #$E6
           BEQ RJS13
           DEY
           BPL RJS12
           RTS
RJS13      TYA
           ASL
           ASL
           ADC #$2E
           STA HPOS4
           INC MXFLAG
           LDA #$00
           STA MXSCRL
           RTS

MX2        LDA MXSCRL 
           CMP #$0F
           BCS MX3 
           LDA #$0E
           SEC 
           SBC MXSCRL
           TAY 
           LDX #$FF
FDS121         INX
           LDA MXDAT,X  
           STA $374B,Y
           INY
           CPX MXSCRL
           BNE FDS121
           INC MXSCRL
           RTS

MX3        INC $2C3
           LDX #$00
FDS131     LDA $3700,X  
           STA $36FF,X  
           INX
           CPX #$60
           BNE FDS131
           INC MXSCRL
           LDA MXSCRL
           CMP #$FF
           BEQ FDS132
           STA AUDF2
           LDA #$8F
           STA AUDC2
           RTS
FDS132     DEC MXFLAG
           LDA #$50
           STA AUDF2
           LDA #$88
           STA AUDC2
           RTS
;--------------------------------
; MXKILL CHECK FOR MX DEATH!
;--------------------------------
MXKILL     LDA MXDEATH
           BNE RJS24
           LDX #$03
RJS21      LDA HIT1,X
           AND #$08
           BNE RJS22
           DEX
           BPL RJS21
           RTS
RJS22      LDX #$03
RJS23      LDA HIT1,X
           AND #$07
           STA HIT1,X
           DEX
           BPL RJS23
           INC MXDEATH
           LDA #$00
           STA EXPSND 
           STA MXFLAG
           LDA #$28
           STA MCNT
           LDA LEVEL
           CLC
           ADC #$01
           ADC BSCOR1
           STA BSCOR1
           RTS
;--------------------------------
; KILL MISSLE!
;--------------------------------
RJS24      LDA #$50
           STA AUDF2
           LDA #$88
           STA AUDC2
           LDX #$60  
RJS25      LDA $3700,X
           BNE RJS29
           DEX
           BNE RJS25
RJS29      LDY #$0E
RJS28      DEX
           LDA RANDOM
           AND MXDAT,Y
           STA $3700,X  
           DEY
           BPL RJS28
           DEC MCNT
           BNE RJS27
           LDA #$00
           STA MXDEATH
           LDX #$60
RJS26      STA $3700,X
           DEX
           BPL RJS26
RJS27      PLA
           PLA
           RTS

MXDAT      .BYTE $10,$10,$10,$38,$38,$38,$38,$38 
           .BYTE $38,$38,$38,$7C,$7C,$44,$44


;--------------------------------
; The Enemy Base has been Destroyed
; Explode it ending the round and display
; any Bonus
;--------------------------------
EXPLOB     LDA BASDEAD
           CMP #$03
           BEQ RJS31
           RTS
;
RJS31      LDA #$00
           STA MOVFLG
           STA ACTFLG
           LDA #$54
           STA $2C8 
           LDA #$00
           STA HPOS1
           STA HPOS2
           STA HPOS3
           STA HPOS4
           STA AUDC3
           STA AUDC4
           LDA #$8F
           STA AUDC1
           LDA #$CF
           STA AUDC2
           LDX #$00
           TXA
RJS32      STA $48C0,X
           STA $49C0,X
           STA $4AC0,X
           INX
           INX
           BNE RJS32
           LDA #$CF 
           STA AUDC1
           LDA #$8F
           STA AUDC2
           LDX #$FF
RJS33      STX AUDF1
           TXA
           PHA
           EOR #$FF
           STA AUDF2
           TXA
           AND #$0F
           BNE RJS37
           LDX #$15
           LDA #$C0
           STA TEMP1
           LDA #$48
           STA TEMP2
RJS34      LDY #$00
RJS36      LDA (TEMP1),Y
           DEY
           STA (TEMP1),Y
           INY
           INY
           CPY #$15
           BCC RJS36
           LDY #$28 
RJS35      LDA (TEMP1),Y
           INY
           STA (TEMP1),Y
           DEY
           DEY
           CPY #$14
           BCS RJS35
           LDA TEMP1
           CLC
           ADC #$28
           STA TEMP1
           LDA TEMP2
           ADC #$00
           STA TEMP2
           DEX
           BNE RJS34
           LDX #$28
           LDY #$00
RJS38      LDA $49C0,Y
           STA $48C0,Y
           LDA $4AC0,Y
           STA $49C0,Y
           LDA $4BC0,Y
           STA $4AC0,Y
           LDA #$00
           STA $4BC0,Y
           INY
           BNE RJS38
RJS37      LDY #$00
           LDX #$05
RJS39      DEY
           BNE RJS39
           DEX
           BNE RJS39
           PLA
           TAX
           DEX
           BNE RJS33
           LDA #$00
           STA AUDC1
           STA AUDC2
           STA $2C8
           LDA #$2C
           STA CHBAS

BONUS      LDX #$0E
RJS41      LDA BONSTR,X
           STA $4995,X
           DEX
           BPL RJS41
           LDX #$0F 
RJS42      LDY MUSDATA,X
           STY AUDF1
           DEY
           STY AUDF2
           LDA #$AF
           STA AUDC1
           STA AUDC2
           INY
           CPY #$00
           BNE RJS44
           STY AUDC1
           STY AUDC2
RJS44      LDA MUSDLY,X
           LDY #$00
RJS43      DEY
           BNE RJS43
           SEC
           SBC #$01
           BNE RJS43
           DEX
           BPL RJS42
           LDX #$10
           JSR DELAY
           LDA #$01
           STA $49EC
           STA $49ED
           STA $49EE
           LDY LEVEL
           INY
           LDX #$02 
RJS45      STX $49EB
           LDA BSCOR0
           CLC
           ADC #$E8
           STA BSCOR0
           BCC RJS48
           INC BSCOR1
RJS48      INC BSCOR1
           INC BSCOR1
           INC BSCOR1
           TXA
           PHA
           TYA
           PHA
           JSR BOOP
           PLA
           TAY
           PLA
           TAX
           INX
           DEY
           BNE RJS45
           LDX #$50
           JSR DLONG
           LDA LEVEL
           CMP #$04
           BNE RJS46
           INC SHIPS
RJS46      CMP #$05
           BEQ RJS47
           INC LEVEL
RJS47      LDA #$58
           STA LIST2+3
           LDA #$4C
           STA LIST2+4
           LDA #$50     ; $50 is 80 initial fuel amt Plus Also $50 is 1st Map Hi Byte
           STA FUEL     ; Init Fuel Value
           JSR MAPFIL   ; Fill Screen Data with 1st Map
           JSR INITVAR
           LDX #$0C
           JMP CURRAN

BONSTR     .BYTE $0F,$18,$0F,$17,$23,$00,$0E,$0F,$1D,$1E,$1C,$19,$23,$0F,$0E
MUSDATA    .BYTE $00,$58,$00,$68,$00,$58,$00,$46,$00,$68,$00,$73,$00,$75,$00,$80
MUSDLY     .BYTE $0A,$64,$0A,$7D,$0A,$7D,$0A,$7D,$0A,$7D,$0A,$64,$0A,$AF,$0A,$64
;--------------------------------
; BASKILER BASE CHARACTER KILL ROUTINES!
;--------------------------------
BASKILER   LDA (IRQVAR1),Y
           CMP #$3F
           BEQ FDS142
           CMP #$40
           BEQ FDS141
           JMP RETRY
FDS141     LDA IRQVAR1
           SEC
           SBC #$01
           STA IRQVAR1
           BCS FDS142
           DEC IRQVAR2
FDS142     LDA #$B0
           STA (IRQVAR1),Y
           INY
           STA (IRQVAR1),Y
           LDA #$00 
           STA EXPSND
           INC BASDEAD
           LDA BASDEAD
           SEC
           SBC #$01
           ASL
           TAX
           LDA IRQVAR1
           STA BASOLD,X
           LDA IRQVAR2
           STA BASOLD+1,X
           JMP COLREND

BASOLD     .BYTE $00,$00
           .BYTE $00,$00
           .BYTE $00,$00
;--------------------------------
; ENDGAME
;--------------------------------
ENDGAME    LDA #$00
           LDA #$00
           STA AUDC1
           STA AUDC2
           STA AUDC3
           STA AUDC4
           LDA #$3D 
           STA HPOS1
           LDA #$5D
           STA HPOS2
           LDA #$85
           STA HPOS3
           LDA #$AD
           STA HPOS4
           LDX #$00
           TXA
FDS143     STA $3400,X
           STA $3500,X
           STA $3600,X
           STA $3700,X
           DEX
           BNE FDS143
           LDX #$5F
FDS144     LDA GDAT,X
           STA $3420,X
           LDA ADAT,X
           STA $3520,X 
           LDA MDAT,X  
           STA $3620,X
           LDA EDAT,X
           STA $3720,X
           DEX
           BPL FDS144
           LDA #$03
           STA SIZEP0     ;Set sizes of players
           STA SIZEP1
           STA SIZEP2
           STA SIZEP3
           LDA #$94
           STA PCOLR0
           STA PCOLR1
           STA PCOLR2
           STA PCOLR3
           LDA SCORE1
           STA OLSCORE1
           LDA SCORE2
           STA OLSCORE2
           LDA SCORE3
           STA OLSCORE3
HSER       LDA SCORE3
           CMP HISCORE3
           BCC NOHI
           BNE HIER
           LDA SCORE2
           CMP HISCORE2
           BCC NOHI 
           BNE HIER
           LDA SCORE1
           CMP HISCORE1
           BCC NOHI 
HIER       LDA SCORE1
           STA HISCORE1
           LDA SCORE2
           STA HISCORE2
           LDA SCORE3
           STA HISCORE3
NOHI       LDX #$30
           JSR DLONG
           LDY TEMP5
           JMP WARMSTART

;--------------------------------
; GAME OVER DATA
;--------------------------------
GDAT      .BYTE $FC,$FC,$FC,$FC,$FC,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$80
          .BYTE $9C,$9C,$9C,$9C,$9C,$84,$84,$84
          .BYTE $84,$84,$84,$84,$84,$84,$FC,$FC
          .BYTE $FC,$FC,$FC,$00,$00,$00,$00,$00
          .BYTE $00,$00,$00,$00,$00,$FC,$FC,$FC
          .BYTE $FC,$84,$84,$84,$84,$84,$84,$84
          .BYTE $84,$84,$84,$84,$84,$84,$84,$84
          .BYTE $84,$84,$84,$84,$84,$84,$84,$84
          .BYTE $84,$84,$84,$84,$84,$84,$84,$84
          .BYTE $84,$84,$84,$84,$FC,$FC,$FC,$FC
ADAT      .BYTE $18,$18,$18,$18,$24,$24,$24,$24
          .BYTE $42,$42,$42,$42,$42,$42,$42,$42
          .BYTE $42,$42,$42,$42,$42,$42,$42,$7E
          .BYTE $7E,$7E,$7E,$42,$42,$42,$42,$42
          .BYTE $42,$42,$42,$42,$42,$42,$42,$42
          .BYTE $42,$42,$42,$00,$00,$00,$00,$00
          .BYTE $00,$00,$00,$00,$00,$81,$81,$81
          .BYTE $81,$81,$81,$81,$81,$81,$81,$81
          .BYTE $81,$81,$81,$81,$81,$42,$42,$42
          .BYTE $42,$42,$42,$42,$42,$42,$24,$24
          .BYTE $24,$24,$24,$24,$24,$24,$24,$24
          .BYTE $18,$18,$18,$18,$18,$18,$18,$00
MDAT      .BYTE $C3,$C3,$C3,$C3,$A5,$A5,$A5,$A5
          .BYTE $99,$99,$99,$99,$99,$99,$99,$99
          .BYTE $99,$99,$99,$99,$99,$99,$99,$99
          .BYTE $99,$99,$99,$99,$99,$99,$81,$81
          .BYTE $81,$81,$81,$81,$81,$81,$81,$81
          .BYTE $81,$81,$81,$00,$00,$00,$00,$00
          .BYTE $00,$00,$00,$00,$00,$FC,$FC,$FC
          .BYTE $FC,$80,$80,$80,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$F0
          .BYTE $F0,$F0,$F0,$80,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$FC,$FC,$FC,$FC
EDAT      .BYTE $FC,$FC,$FC,$FC,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$80
          .BYTE $80,$80,$F0,$F0,$F0,$F0,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$80
          .BYTE $80,$80,$80,$80,$80,$80,$80,$FC
          .BYTE $FC,$FC,$FC,$00,$00,$00,$00,$00
          .BYTE $00,$00,$00,$00,$00,$F8,$F8,$F8
          .BYTE $F8,$F8,$88,$88,$88,$88,$88,$88
          .BYTE $88,$88,$88,$88,$88,$F8,$F8,$F8
          .BYTE $F8,$F8,$F8,$A0,$A0,$A0,$A0,$A0
          .BYTE $A0,$A0,$90,$90,$90,$90,$90,$90
          .BYTE $88,$88,$88,$88,$88,$84,$84,$84
          .BYTE $84,$00,$00,$00,$00,$00,$00,$00

;--------------------------------
; PAUSER ROUTINE CHECK FOR
; PAUSE AND GAME RESTART!
;--------------------------------
PAUSER     LDA CONSOL       ; Read Console Switches
           ROR              ; Bit0 = Start
           BCS PNOTSTART    ; If not pressed branch
           JMP WARMSTART    ; else jump to Warmstart
;
PNOTSTART  ROR              ; Bit1 = Select
           ROR              ; Bit2 = Option
           BCC POPTION      ; if Option pressed branch
           RTS              ; else return
;           
POPTION    LDA CONSOL       ; Re-Read Switches
           AND #$04         ; Mask bit 2 Option
           BEQ POPTION      ; If still pressed loop (debounce)
;           
           LDA MOVFLG       ; Get MOVFLG
           PHA              ; Save on Stack
           LDA ACTFLG       ; Get ACTFLG
           PHA              ; Save on Stack
           LDA #$00         ; a = 0
           STA MOVFLG       ; Set MOVFLAG 0
           STA ACTFLG       ; Set ACTFLAG 0
           STA AUDC1        ; Clear Audio Control 1
           STA AUDC2        ; Clear Audio Control 2
           STA AUDC3        ; Clear Audio Control 3
           STA AUDC4        ; Clear Audio Control 4
           LDA #$FF         ; A = FF
           STA KEY          ; RESET KEYPRESS REG
FDS153     LDA KEY          ; Read KEYPRESS REG
           CMP #$FF         ; IF FF no Keys Pressed
           BEQ FDS153       ; So loop until so
           PLA              ; get A from Stack
           STA ACTFLG       ; restore ACTFLG
           PLA              ; get A from Stack
           STA MOVFLG       ; restore MOVFLG
           LDA #50          ; Get Audio Freq
           STA AUDF2        ; Set Audio Freq Reg 2
           LDA #$83         ; Get Audio Control Data
           STA AUDC2        ; Set Audio Control Reg 2
           RTS

;--------------------------------
; FIREPOWER! FIRE FROM BASE AND
; FIRE FROM TANKS!
;--------------------------------
FIREPOWER  INC CNTFIRE
           BPL RJS55 
           LDA #$00
           STA CNTFIRE
           LDA SMISY
           ORA WRNCNT
           ORA SAUCFLG
           BEQ RJS51
RJS55      RTS 
RJS51      LDA LIST2+3
           CLC
           ADC #$C8
           STA TEMP1
           LDA LIST2+4
           ADC #$00
           STA TEMP2
           LDX #$08 
RJS52      LDY #$27
RJS53      LDA (TEMP1),Y
           CMP #$10
           BEQ RJS54
           CMP #$40
           BEQ RJS54
           DEY
           BPL RJS53
           LDA TEMP1
           CLC
           ADC #$28
           STA TEMP1
           LDA TEMP2
           ADC #$00
           STA TEMP2
           DEX
           BNE RJS53
           RTS
RJS54      DEY
           TYA
           ASL
           ASL
           CLC
           ADC #$2F
           STA HPOS3
           TXA
           EOR #$08 
           CLC
           ADC #$05
           ASL
           ASL
           ASL
           CLC
           ADC #$14 
           STA SMISY
           LDA #$00
           STA MISDIR
           RTS

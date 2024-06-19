;--------------------------------
; NIGHTRAIDER GAME LOOPS
;--------------------------------
           LDA #$2C         ; Set Character Font Address to $2C00
           STA CHBAS        ; to Select Font for Game Intro
           LDX #$0C         ; Copy 12 bytes
CURRAN     LDA BMES1-1,X    ; from BMES1 to Sceen Memory at $4CFF
           STA $4CFF,X
           DEX              ; Loop till x=0 done
           BNE CURRAN 
           JSR BOOP         ; Make a Boop Sound
           LDY LEVEL        ; Y = Game Level
           INY              ; add 1 to enter loop cause we sub1
FINDLEV    DEY              ; Y=Y=1
           BEQ GOGO         ; if Y=0 we are done branch x= offset to level text
                            ; enter here x=0 from above
LOPFIND    INX              ; x=x+1
           LDA LEVNAM,X     ; get next char from level text data
           BNE LOPFIND      ; if not 0 branch skip over this msg
           INX              ; we found 0 inx to point to first char of msg
           BNE FINDLEV      ; this is equivalent of a jmp we assume x will never be 0!
                            ; jump up to see if this is the msg we want (y=0 after DEY)
;--------------------------------
GOGO       LDA LEVNAM,X     ; here we found our msg get a char
           BEQ TERR         ; if 0 we are at end of msg txt branch
           CMP #$20         ; is it a ' ' char?
           BNE SIRS         ; if a space branch
           LDA #$36         ; else force to $36 so subtract = 0 our space char
SIRS       SEC              ; set carry
           SBC #$36         ; subtract $36 to adjust for our ascii
           ORA #$80         ; set hi bit for font selection
           STA $4D0F,Y      ; copy to screen memory
           INY              ; bump index into screen memory
           INX              ; bump index into our msg
           JMP GOGO         ; continue copying msg to sceen
;--------------------------------
TERR       JSR BEEPS        ; makes 3 beeps
;--------------------------------
           LDX #17          ; copy 17 bytes
MIO        LDA BMES2-1,X    ; of BMESG2 to screen 
           STA $4D72,X      ; at $4D72
           DEX              ; dec x counter/offset
           BNE MIO          ; loop till complete x=0
;
           JSR BOOP         ; make boop sound
;  
           LDX #$0D         ; copy 13 bytes
MIO2       LDA BMES3-1,X    ; of BMES3 to screen
           STA $4D86,X      ; at $4D86
           DEX              ; dec x counter/offset
           BNE MIO2         ; loop till complete x=0
;
           JSR BEEPS        ; makes 3 beeps
;    
           LDX #$6          ; copy 6 bytes
MIO3       LDA BMES4-1,X    ; of BMES4 to screen
           STA $4DF5,X      ; at $4DF5
           DEX              ; dec x counter/offset
           BNE MIO3         ; loop till complete x=0
;
           JSR BOOP         ; make boop sound
;  
           LDX #$6          ; copy 6 bytes
MIO4       LDA BMES5-1,X    ; of BMES5 to screen
           STA $4DFE,X      ; at $4DFE
           DEX              ; dec x counter/offset
           BNE MIO4         ; loop till complete x=0
;
           JSR BEEPS        ; makes 3 beeps
;    
; The following code produces the countdown timer
;
           LDX #$5          ; countdown from 5 x=count
MIO5       LDA #$A8         ; A8 does what?
           STA AUDC2        ; Set Audio Control Reg 2
           STA AUDC3        ; Set Audio Control Reg 3
           LDA #85          ; Get frequency
           STA AUDF2        ; Set Audio Freq Reg 2
           LDA #86          ; Get frequency
           STA AUDF3        ; Set Audio Freq Reg 3
           TXA              ; a=x
           PHA              ; save x our counter on stack
           CLC              ; clear carry for addition
           ADC #$01         ; add 1 to our count
           STA $4E25        ; write to screen memory to show count
           LDX #$04         ; x=4 (delay val)
           JSR DLONG        ; do long delay
           LDA #$00         ; a=0
           STA AUDC2        ; clear our Audio Control Reg 2
           STA AUDC3        ; clear our Audio Control Reg 3
           LDX #$10         ; x=16 (delay val)
           JSR DLONG        ; do long delay
           PLA              ; pull our counter from stack
           TAX              ; put back in x
           DEX              ; count = count -1
           BNE MIO5         ; if not 0 continue countdown
;           
           LDA #$01         ; a=1
           STA $4E25        ; write to screen to erase our count
           LDA #$A8         ; A= setting for audio control
           STA AUDC2        ; Set Audio Control Reg 2
           STA AUDC3        ; Set Audio Control Reg 3
           LDA #50          ; Get frequency
           STA AUDF2        ; Set Audio Freq Reg 2
           LDA #51          ; Get frequency
           STA AUDF3        ; Set Audio Freq Reg 3
           LDA #$88         ; A= setting for audio control
           STA AUDC1        ; Set Audio Control Reg 1
 ;                          ; create increasing audio effect
           LDX #$05         ; x=audio freq
MYOMY      STX AUDF1        ; Set Audio Freq Reg 1
           TXA              ; a = x
           PHA              ; save ons tack
           LDX #$3          ; x=3 (Delay Val)
           JSR DLONG        ; do long delay
           PLA              ; a = stack
           TAX              ; x = a restore our counter
           INX              ; x=x+1
           CPX #25          ; is it 25?
           BNE MYOMY        ; if not loop 
;
           LDA #$00         ; a=0
           STA AUDC1        ; clear our Audio Control Reg 1
           STA AUDC3        ; clear our Audio Control Reg 3
           LDA #$84         ; A= setting for audio control
           STA AUDC2        ; Set Audio Control Reg 2
           LDA #$50         ; Get frequency
           STA AUDF2        ; Set Audio Freq Reg 2
           JSR DELAY        ; Small Delay
           LDX #$00         ; X = Screen Offset
           LDA #$50         ; A = Hi Byte of 1st Map Address $5000
           JSR MAPFIL       ; Go Fill Screen with Scrolling Map
           LDA #$70         ; Set Character Font Address to $7000
           STA CHBAS        ; to Select Font for Game Play
           INC MOVFLG       ; Set MOV FLAG
           INC ACTFLG       ; Set ACT FLAG
;--------------------------------
; BEGINING GAME INTRO SHOWN
; NOW CLEAR THE BULSHIT AND
; LETS GET ON WITH SOME ACTION!
;--------------------------------
           JMP GM1          ; Jump into Game
;
;--------------------------------
; Some Beep and Boop Sound Routines
;--------------------------------
BOOP       LDA #$AF         ; A= setting for audio control
           STA AUDC1        ; Set Audio Control Reg 1
           LDA #$70         ; Get frequency
           STA AUDF1        ; Set Audio Freq Reg 1
           LDX #$4          ; x=4 (delay val)
           JSR DLONG        ; do long delay
           LDA #$00         ; a=0
           STA AUDC1        ; clear our Audio Control Reg 1
           LDX #$5          ; x=5 (delay val)
           JSR DLONG        ; do long delay
           RTS
;--------------------------------
BEEPS      LDA #$03         ; A=3 count of beeps
BEEPS2     PHA              ; save on stack
           LDA #$AF         ; A= setting for audio control
           STA AUDC1        ; Set Audio Control Reg 1
           LDA #$10         ; Get frequency
           STA AUDF1        ; Set Audio Freq Reg 1
           LDX #$02         ; x=2 (delay val)
           JSR DLONG        ; do long delay
           LDA #$00         ; a=0
           STA AUDC1        ; clear our Audio Control Reg 1
           LDX #$02         ; x=2 (delay val)
           JSR DLONG        ; do long delay
           PLA              ; a = saved stack count
           SEC              ; sec carry for sub
           SBC #$01         ; a=a-1
           BNE BEEPS2       ; if not 0 continue
;           
           LDX #$5          ; x=5 (delay val)
           JSR DLONG        ; do long delay
           RTS

; Start of Game Message Data
BMES1      .BYTE $0D,$1F,$1C,$1C,$0F,$18,$1E,$00
           .BYTE $1C,$0B,$18,$15
BMES2      .BYTE $17,$13,$1D,$1D,$13,$19,$18,$00
           .BYTE $19,$0C,$14,$0F,$0D,$1E,$13,$20,$0F
BMES3      .BYTE $8E,$8F,$9D,$9E,$9C,$99,$A3,$00,$8F
           .BYTE $98,$8F,$97,$A3
BMES4      .BYTE $1D,$1E,$0B,$1E,$1F,$1D
BMES5      .BYTE $96,$8B,$9F,$98,$8D,$92

;--------------------------------
; MAIN GAME LOOP #1
;--------------------------------
GM1        LDA #COLRUT&255   ;SETUP
           STA COLLAD        ;COLLISION
           LDA #COLRUT/255   ;ROUTINE
           STA COLLAD+1      ;VECTOR
;
GMLOOP     JSR PAUSER       ; Check for any Pause or Game Restart
           LDA BASER        ; Check if Base has been destroyed
           BEQ PF5          ; If not Branch
           JSR EXPLOB       ; Process Base Explosion
;
PF5        JSR TRAINER      ; Process Moving Trains
           JSR BRIDGER      ; Process any Collapsing Bridge
           JSR MX           ; Process Moving MX Missles
           JSR SOUND        ; Process Sound
           JSR MISSLES      ; Process Missle Fire 
           JSR SPCATK       ; Process Space Attack
           JSR UFODIE       ; Process UFO Hit Explosion
           JSR ATTACK       ; Process Attacks against player
           JSR FIREPOWER    ; Process Shots from Tanks and Base
           LDA SPACFLG      ; Are we in Space?
           BEQ PF6          ; If not branch
           JSR KILLER2      ; Kill Space Characters
           JMP GMLOOP       ; Loop
;  
PF6        JSR KILLER       ; Process Deaths of objects or plane
           JMP GMLOOP       ; Loop
           
;--------------------------------
; SUBROUTINE KILLER
; EXPLODES KILLED OBJECTS
; AND HANDLES DEATH!
;--------------------------------
KILLER     JSR CONTROL
           INC KILCNT 
           LDA KILCNT
           CMP #$40
           BNE KILEND
           LDA #$00
           STA KILCNT
           LDX #$00 
KIL2       LDA HITABLE,X
           CMP #$FF
           BEQ KILEND
           CMP #$00
           BNE KIL4
KIL3       INX  
           INX
           INX
           INX
           INX
           BNE KIL2
KIL4       STX TEMP3 
           DEC HITABLE,X
           PHA
           LDA HITABLE+1,X 
           STA TEMP1 
           LDA HITABLE+2,X
           STA TEMP2
           PLA
           CMP #$06
           BNE KIL10
           LDA HITABLE+3,X
           LDX #$00
KIL5       CMP CHATBL,X 
           BEQ KIL6
           CMP #$FF
           BEQ KIL8
           INX
           BNE KIL5
KIL6       LDA #$00
           TAY
KIL7       STA (TEMP1),Y
           INX
           LDY CHTBL2,X
           BNE KIL7
KIL8       LDX TEMP3
           JMP KIL3
KILEND     RTS
KIL10      EOR #$FF
           CLC
           ADC #$06
           ASL
           STA TEMP4
           CMP #$08
           BNE TI
           JMP KIL12  
TI         LDA HITABLE+3,X
           LDX #$03
TJ         CMP EXPTBL,X  
           BNE TK  
           JMP KIL11  
TK         DEX
           BPL TJ  
           LDX TEMP3 
           LDA #$00
           STA HITABLE,X
           LDA HITABLE+3,X
           CMP #$15
           BCC KBRIDGE
           LDA TEMP1
           SEC
           SBC #$20
           STA TEMP1
           BCS PF22
           DEC TEMP2
PF22       LDY #$20
PF23       LDA (TEMP1),Y
           BEQ PF24
           CMP #$19   
           BEQ PF24
           CMP #$9E
           BEQ PF24
           DEY
           BNE PF23
           JMP KIL8
PF24       INY
           LDA #$9B
           STA (TEMP1),Y
PF25       LDA (TEMP1),Y
           CMP #$11
           BEQ PF26
           CMP #$19
           BEQ PF26
           CMP #$9A
           BEQ PF26
           LDA #$00
           STA (TEMP1),Y
           INY
           BNE PF25
PF26       LDA #$00
           STA TRNFLG
           LDA LEVEL
           ASL
           CLC
           ADC BSCOR1
           STA BSCOR1
           JMP KIL8

KBRIDGE    LDA TEMP1
           SEC
           SBC #$20
           STA TEMP1
           BCS FDS15
           DEC TEMP2
FDS15      LDY #$20
FDS16      LDA (TEMP1),Y
           CMP #$11
           BEQ FDS17
           DEY
           BNE FDS16
FDS17      LDA #$15
           STA (TEMP1),Y
           INY
           LDA #$16
           STA (TEMP1),Y
           INY
           LDA #$17
           STA (TEMP1),Y
           INY
           LDA #$18
           STA (TEMP1),Y
           LDA BSCOR0
           CLC
           ADC #$C8
           STA BSCOR0
           BCC FDS18
           INC BSCOR1
FDS18      INC BRDFLG
           JMP KIL8
KIL11      LDY EXPTBL2,X
           LDX TEMP4  
           LDA EXPTBL3,X
           STA (TEMP1),Y
           INY
           LDA EXPTBL3+1,X
           STA (TEMP1),Y
           JMP KIL8

KIL12      LDA HITABLE+3,X 
           LDX #$00
FDS19      CMP PNTBL,X
           BEQ FDS20
           INX
           BNE FDS19
FDS20      PHA
           LDA PNTBL+1,X
           CLC
           ADC BSCOR0
           STA BSCOR0
           LDA PNTBL+2,X
           ADC BSCOR1
           STA BSCOR1
           PLA
           LDX #$00
FDS21      CMP EXPTBL,X   
           BEQ KIL13
           INX
           BNE FDS21

KIL13      LDY EXPTBL2,X
           LDA TEMP1 
           SEC
           SBC #$01
           STA TEMP1
           BCS KIL14
           DEC TEMP2
KIL14      LDA #$2C   
           STA (TEMP1),Y
           INY
           LDA #$2D
           STA (TEMP1),Y
           INY
           LDA #$2E
           STA (TEMP1),Y
           INY
           LDA #$2F
           STA (TEMP1),Y
           JMP KIL8


;--------------------------------
; CONTROL SUBROUTINE
; SETS FLAGS FOR OTHER ROUTINES
; DEPENDING ON GAME PLAY. IT IS CALLED
; UPON ENTRY TO MANY OF THE GAME ROUTINES
; TO UPDATE GAME STATES
;--------------------------------
CONTROL    LDA BASER
           BEQ FDS22
           JMP CON4
FDS22      LDA SPACFLG
           BNE CONEND
           LDA LIST2+3
           BNE CONEND
           LDA LIST2+4  
           CMP #$40  
           BNE CONEND
           LDA BASFLG
           BNE CON2
           LDA MOVFLG
           BEQ CON3
           LDA #$00
           STA MOVFLG 
           INC SPACFLG
CONEND     RTS 
CON3       LDA #$58 
           STA LIST2+3
           LDA #$4C
           STA LIST2+4
           LDA #$60     ; A = Hi byte of second map address $6000
           JSR MAPFIL   ; Fill Screen Data with 2nd Map
           INC MOVFLG
           INC BASFLG
           RTS

CON2       LDA #$40
           STA TEMP2
           LDA #$00
           STA TEMP1
           LDY #00
PF11       TYA
PF12       STA (TEMP1),Y
           DEY
           BNE PF12
           INC TEMP2
           LDA TEMP2
           CMP #$50
           BNE PF11
           LDX #$00
PF13       LDA $6000,X
           STA $48C0,X
           LDA $6100,X
           STA $49C0,X
           LDA $6200,X
           STA $4AC0,X
           DEX
           BNE PF13
           LDX #$6F
PF14       LDA $6300,X
           STA $4BC0,X
           DEX
           BNE PF14
           LDA #$58
           STA LIST2+3    
           LDA #$4C
           STA LIST2+4
           LDA #$FF
           STA BASER  
           LDA BASDEAD
           BEQ PF15
           ASL
           TAX
PF16       LDA BASOLD-2,X 
           STA TEMP1
           LDA BASOLD-1,X
           STA TEMP2
           LDY #$00
           LDA #$B0
           STA (TEMP1),Y
           INY
           STA (TEMP1),Y
           DEX
           DEX
           BNE PF16
PF15       RTS

CON4       LDA LIST2+3
           CMP #$78
           BNE FDS23
           LDA LIST2+4
           CMP #$45
           BNE FDS23
           LDA #$58
           STA LIST2+3
           LDA #$4C
           STA LIST2+4
           LDA #$50     ; A = Hi Byte of 1st Map Address $5000
           JSR MAPFIL   ; Fill Screen Data with 1st Map
           LDA #$00
           STA SPACFLG
           STA BASER
           STA BASFLG
           LDX #$08
FDS24      STA MUSCNT,X
           DEX
           BPL FDS24
FDS23      RTS

;--------------------------------
; SUBROUTINE TRAINER
; CHECKS FOR BRIDGES ON THE SCREEN
; AND ROLLS TRAINS ACROSS THEM
;--------------------------------
TRAINER    JSR CONTROL
           INC TRNCNT  
           LDA TRNCNT
           CMP #$30 
           BEQ FDS25
           RTS
FDS25      LDA #$00
           STA TRNCNT
           LDA TRNFLG  
           BNE TRAIN5
           LDA LIST2+3
           STA TEMP1
           LDA LIST2+4
           STA TEMP2
           LDY #$00
           LDA (TEMP1),Y
           CMP #$11
           BNE TRAIN3
           INY
           LDA (TEMP1),Y
           CMP #$12
           BEQ TRAIN2
TRAIN3     RTS  
TRAIN2     LDA TEMP1
           SEC
           SBC #$28
           STA TRNVAR1
           BCS TRAIN4
           DEC TEMP2
TRAIN4     LDA TEMP2  
           STA TRNVAR2
           INC TRNFLG
           LDA #$0
           STA TRNPNT1
           LDA #$21
           STA TRNPNT2
           RTS

TRAIN5     LDA TRNVAR1
           STA TEMP1
           LDA TRNVAR2
           STA TEMP2
           LDA TRNPNT1
           CMP #$27
           BEQ TRAIN6
           LDY TRNPNT1
           LDX TRNPNT2   
FDS26      CPX #$FF
           BEQ FDS27
           LDA TRNSTR,X
           DEX
           JMP FDS28
FDS27      LDA #$19
FDS28      STA (TEMP1),Y
           DEY
           BPL FDS26
           INC TRNPNT1
           RTS

TRAIN6     LDY #$27
           LDX TRNPNT2
           BMI TRAIN7
FDS29      CPX #$FF
           BEQ FDS30
           LDA TRNSTR,X
           DEX
           JMP FDS31
FDS30      LDA #$19
FDS31      STA (TEMP1),Y
           DEY
           BPL FDS29
           DEC TRNPNT2 
           RTS

TRAIN7     LDY #$27
           LDA #$19
FDS32      STA (TEMP1),Y
           DEY
           BPL FDS32
           DEC TRNFLG
           RTS

TRNSTR     .BYTE $19,$9A,$9B,$9B,$9B,$9B,$9E,$9A
           .BYTE $9B,$9B,$9B,$9B,$9E,$9A,$9B,$9B
           .BYTE $9B,$9B,$9E,$9A,$9B,$9B,$9B,$9B
           .BYTE $9E,$9A,$9B,$9B,$9B,$9B,$9B,$9B
           .BYTE $9C,$9D
;--------------------------------
; ATTACK ROUTINES ATTACKS 
; PLAYER DEPENDING ON
; WHAT FLAGS ARE SET
;--------------------------------
ATTACK     JSR CONTROL
           DEC FLCNT2
           BNE PF33
           LDA #$1C
           STA FLCNT2
           DEC FLCNT 
           BNE PF33
           LDA CRUD
           BNE PF33
PF32       LDA LEVEL
           ASL
           ASL
           ASL
           STA TEMP1
           LDA #59
           SEC
           SBC TEMP1
           STA FLCNT
           DEC FUEL 
           BNE PF33
           JSR PLANEGON   
PF33       LDA SPACFLG  
           BEQ PF36
           LDA WRNCNT
           BNE PF36
           LDA SAUCFLG
           BNE PF35
PF36       LDA SAUCFLG
           BNE PF35
           LDA SPS1  
           INC LEVEL 
           INC LEVEL 
           SEC
           SBC LEVEL
           DEC LEVEL 
           DEC LEVEL
           STA SPS1
           BCS PF31
           DEC SPS2
           BNE PF31
           LDA #$A0
           STA SPS2
           LDA #$FF
           STA SPS1
           INC SAUCFLG  
           LDY #$00
           LDX #$00
           LDA RANDOM
           BMI PF34
           INX
           LDY #$FF
PF34       STX SAUCDIR   
           STY HPOS1
           STY HPOS2
           LDA #$35
           STA SAUCY
           LDA #$20
           STA WRNCNT  
           LDX #$60
           LDA #$00
PF37       STA $3400,X
           STA $3500,X
           DEX
           BNE PF37
PF31       RTS


PF35       LDA WRNCNT
           BEQ MOVSAUC 
           INC FLYCNT
           LDA FLYCNT
           CMP #$50
           BNE PF31
           LDA #$00
           STA FLYCNT
           LDA WRNCNT
           AND #$01
           BEQ TONE2
           LDA #25
           BNE TONE1
TONE2      LDA #100
TONE1      STA AUDF4  
           LDA #$AF
           STA AUDC4
           LDX #$09
FDS34      LDA WRNMES-1,X
           STA $3E99,X
           DEX
           BNE FDS34
           DEC WRNCNT
           BNE FDS33
           LDA #$00
           STA AUDF4
           STA AUDC4
           LDX #$09
FDS35      STA $3E99,X
           DEX
           BNE FDS35
FDS33      RTS
;

MOVSAUC    INC SAUCNT
           LDA SAUCNT
           CMP #$10 
           BEQ PF46
           RTS
PF46       LDA #$00   
           STA SAUCNT
           LDA SAUCDIR  
           BEQ PF41
           DEC HPOS1
           DEC HPOS2
           JMP PF42
PF41       INC HPOS1
           INC HPOS2
PF42       LDA SAUCT
           BEQ PF43
           BMI PF44
           INC SAUCY 
           LDA SAUCY
           CMP #$60
           BNE PF43
           LDA #$00
           STA SAUCT
           JMP PF43
PF44       DEC SAUCY
           LDA SAUCY
           CMP #$20
           BNE PF43
           LDA #$00
           STA SAUCT
PF43       LDX SAUCY  
           INX
           LDY #$0A
           LDA #$00
PF45       STA $3400,X
           STA $3500,X
           DEX  
           DEY    
           BPL PF45
           LDA #$44
           STA PCOLR0
           LDA #$84
           STA PCOLR1
           LDA SAUCPNT
           CMP #$04
           BNE PLOTSAUC
           LDA #$00
           STA SAUCPNT

PLOTSAUC   ASL
           TAX
           LDA SAUCTBL,X
           STA TEMP1
           LDA SAUCTBL+1,X
           STA TEMP2
           LDX SAUCY
           LDY #$00
FDS36      LDA (TEMP1),Y
           STA $3400,X  
           TYA
           CLC  
           ADC #$08
           TAY
           LDA (TEMP1),Y
           STA $3500,X
           TYA
           SEC
           SBC #$08
           TAY
           DEX
           INY
           CPY #$08
           BNE FDS36
           INC SAUCPNT2
           LDA SAUCPNT2
           CMP #$06
           BNE FDS37
           LDA #$00
           STA SAUCPNT2
           INC SAUCPNT
FDS37      LDA SAUCT 
           BNE MISCHK
           LDA RANDOM
           BMI FDS38
           LDA SAUCY
           CMP #$20
           BEQ MISCHK
           DEC SAUCT 
           JMP MISCHK  
FDS38      LDA SAUCY

           CMP #$60
           BEQ MISCHK
           INC SAUCT
MISCHK     LDA SMISY 
           BNE NOMISL   
           LDA ACTFLG
           BEQ NOMISL
           LDA MISAUC
           SEC
           SBC LEVEL
           STA MISAUC
           BCS NOMISL  
           LDA #$50
           STA MISAUC
           LDA HPOS1
           STA HPOS3
           LDA SAUCY
           STA SMISY
           LDA #$00
           STA MISDIR
           LDA HPOS1
           SEC
           SBC CROSSX
           BCC FDS39
           CMP #$0D
           BCC NOMISL
           DEC MISDIR  
           BNE NOMISL
FDS39      EOR #$FF
           CLC
           ADC #$01
           CMP #$0D
           BCC NOMISL
           INC MISDIR
NOMISL     LDA HPOS1
           BNE FDS40
           LDA #$00
           STA SAUCFLG
           STA AUDC4
FDS40      RTS 
WRNMES     .BYTE $1C,$0F,$0E,$00,$0B,$16,$0F,$1C,$1E
;
SAUCTBL    .WORD SAUCER1
           .WORD SAUCER2
           .WORD SAUCER3
           .WORD SAUCER4
;--------------------------------
; SOUND GENERATOR
; GENERATES SOUNDS FOR GAME
;--------------------------------
SOUND      JSR CONTROL
           INC SNDCNT
           LDA SNDCNT
           CMP #$8 
           BNE SOUND3
           LDA #$00
           STA SNDCNT
           LDA EXPSND
           CMP #$FE
           BEQ SOUND2
           CMP #$FF
           BEQ SOUND3
           INC EXPSND
           LDA EXPSND
           STA AUDF3
           LDA #$68
           STA AUDC3
           BNE SOUND3
SOUND2     LDA #$00
           STA AUDC3
           INC EXPSND
SOUND3     LDA SMISY
           BNE FDS41
           LDA WRNCNT
           BNE FDS43
           LDA SAUCFLG
           BNE FDS42
           LDA #$00
           STA AUDF4
           STA AUDC4
FDS43      RTS
FDS41      LDA #$A8
           STA AUDC4
           LDA SMISY
           STA AUDF4
           RTS
FDS42      LDA VOLFLG    
           BNE FDS44
           LDA #$1
           STA AUDF4
           LDA #$60
           ORA VOLUM
           STA AUDC4
           INC VOLUM
           LDA VOLUM
           CMP #$0F
           BNE FDS43
           INC VOLFLG
           JMP FDS43
FDS44      LDA #$1
           STA AUDF4
           LDA #$60
           ORA VOLUM
           STA AUDC4
           DEC VOLUM
           BNE FDS43
           DEC VOLFLG
           JMP FDS43

;--------------------------------
; OBJECT COLLISION HANDLER
;--------------------------------
COLRUT     LDA LIST2+3
           STA IRQVAR1
           LDA LIST2+4
           STA IRQVAR2
           LDA GUNSY,X
           SEC
           SBC #$19
           CLC
           ADC SCRCNT
           LSR
           LSR
           LSR
           STA IRQVAR3
           ASL
           ASL
           CLC
           ADC IRQVAR3
           ASL
           ASL
           ASL
           BCC NOCAT
           INC IRQVAR2
NOCAT      CLC
           ADC IRQVAR1
           STA IRQVAR1
           LDA IRQVAR2
           ADC #$00
           STA IRQVAR2
           LDA GUNSX,X
           SEC
           SBC #$2F
           LSR
           LSR
           CLC
           ADC IRQVAR1
           STA IRQVAR1
           LDA IRQVAR2
           ADC #$00
           STA IRQVAR2
           LDY #$00
           LDA SPACFLG

           BEQ FDS45
           JMP SPACKIL
FDS45      LDA BASER
           BEQ RETRY
           JMP BASKILER
RETRY      LDA (IRQVAR1),Y 
           CMP #$06
           BNE COLRU2
           LDA #$8D
           STA (IRQVAR1),Y
           LDA BSCOR0
           CLC
           ADC #$01
           STA BSCOR0
           LDA BSCOR1
           ADC #$00
           STA BSCOR1
           JMP COLREND
COLRU2     LDX #$00
COLRU3     LDA CHATBL,X
           CMP (IRQVAR1),Y
           BEQ COLRU4
           CMP #$FF
           BEQ COLRU5
           INX
           BNE COLRU3
COLRU5     LDX #$00
FDS46      LDA CHTBL3,X
           CMP (IRQVAR1),Y
           BEQ COLRU8
           CMP #$FF
           BEQ COLREND
           INX
           BNE FDS46

COLRU4     CMP #$22
           BCC FDS48
           CMP #$2A
           BCS FDS48
           INC FUEL
           INC FUEL
           INC FUEL
           LDA LEVEL
           ASL
           CLC
           ADC FUEL
           CMP #$51
           BCC FDS47
           LDA #$50
FDS47      STA FUEL
FDS48      LDA IRQVAR1   
           SEC
           SBC CHTBL2,X
           STA IRQVAR1
           BCS FDS49
           DEC IRQVAR2  
FDS49      LDA #$06
           STA IRQVAR3
           JMP COLRU9
COLRU8     LDA #$05
           STA IRQVAR3
COLRU9     LDX #$00
COLRU6     LDA HITABLE,X
           BEQ COLRU7
           CMP #$FF
           BEQ COLREND
           INX
           INX
           INX
           INX
           INX
           BNE COLRU6
COLRU7     LDA IRQVAR3
           STA HITABLE,X
           LDA IRQVAR1
           STA HITABLE+1,X
           LDA IRQVAR2
           STA HITABLE+2,X
           LDA (IRQVAR1),Y
           STA HITABLE+3,X
           LDA #$00
           STA EXPSND
COLREND    STA $D01E
           JMP RTEND
;--------------------------------
; BRIDGE COLLAPSE ROUTINE
;--------------------------------
BRIDGER    JSR CONTROL
           LDA BRDFLG 
           BNE FDS51
FDS52      RTS  
FDS51      DEC BRDCNT
           BNE FDS52
           LDA BRDPNT
           CMP #$03
           BNE FDS53
           LDA #$00
           STA BRDFLG
           STA BRDCNT
           STA BRDPNT
           RTS
FDS53      ASL
           TAX
           LDA BRDTAB,X
           STA TEMP1
           LDA BRDTAB+1,X
           STA TEMP2
           LDY #$1F
FDS54      LDA (TEMP1),Y
           STA $70A8,Y
           DEY
           BPL FDS54
           INC BRDPNT
           RTS

BRDTAB     .WORD BRIDGE1
           .WORD BRIDGE2
           .WORD BRIDGE3
;--------------------------------
; EXPLODE PLANE ON SCREEN
;--------------------------------
PLANEGON   JSR CONTROL
           LDA #$00
           STA HPOS3
           DEC ACTFLG
           LDA #$20
           STA TEMP1
           LDA #$50
           STA CRUD
PF51       LDX #$0D
PF52       LDA RANDOM  
           PHA
           EOR $3490,X   ;SCREEN addresses
           AND P1-1,X
           STA $3490,X
           PLA
           ROR
           EOR $3590,X
           AND P2-1,X
           STA $3590,X
           DEX
           BNE PF52
           LDA RANDOM
           AND #$3F
           STA AUDF2
           LDA #$8F
           STA AUDC2
           LDA TEMP1
           PHA
           LDX #$30
PF60       TXA
           PHA
           JSR TRAINER
           JSR KILLER
           JSR ATTACK
           JSR SOUND
           JSR UFODIE
           JSR SPCATK
           JSR KILLER2
           JSR MX
           PLA
           TAX
           DEX
           BNE PF60
           PLA
           STA TEMP1
           DEC TEMP1
           BNE PF51
           DEC TEMP1
PF53       LDA TEMP1
           STA AUDF2
           LDA TEMP1
           AND #$0F
           BNE PF54
           LDA TEMP1
           CMP #$90
           BCS PF55
           LDX #$10
PF58       LDA $3490,X    ;Writing to SCREEN
           LSR
           STA $3490,X
           LDA $3590,X
           ASL
           STA $3590,X
           DEX
           BNE PF58
           BEQ PF54
PF55       LDX #$0C
PF56       LDA $3690,X
           LSR
           STA $3690,X
           LDA $3790,X
           ASL
           STA $3790,X
           DEX
           BNE PF56
PF54       LDX #$6 
PF59       TXA  
           PHA
           LDA TEMP1
           PHA
           JSR TRAINER
           JSR KILLER
           JSR ATTACK
           JSR SOUND
           JSR UFODIE
           JSR SPCATK
           JSR KILLER2
           JSR MX
           PLA
           STA TEMP1
           PLA
           TAX
           DEX
           BNE PF59
           DEC TEMP1      
           BNE PF53
           LDA #$00
           STA AUDC2
           DEC SHIPS
           BNE PF57
           JMP ENDGAME
PF57       JSR PMAKER
           LDA #$35
           STA AUDF2
           LDA #$AF
           STA AUDC2
           LDY #$00
SUP        DEY
           BNE SUP
           LDA #$84
           STA AUDC2  
           LDA #$50 
           STA AUDF2
           INC ACTFLG  
           STA FUEL
           LDA #$00
           STA CRUD
           RTS

;--------------------------------
; MISSLE FIRE ROUTINE
;--------------------------------
MISSLES    INC MISCNT
           LDA MISCNT
           CMP #$10
           BNE ENDMIS
           LDA #$00
           STA MISCNT
           LDA SMISY  
           BEQ ENDMIS
           LDX SMISY
           LDA #$00
PF71       STA $3600,X
           DEX
           BNE PF71
           LDA MISDIR
           BEQ PF72
           BMI PF73
           INC HPOS3
           BEQ CKMISKL
           BNE PF72
PF73       DEC HPOS3 
           BEQ CKMISKL
PF72       INC SMISY
           INC SMISY
           INC SMISY
           INC SMISY
           LDA SMISY
           CMP #$84
           BCS CKMISKL
           LDX SMISY 
           LDY #$04
           LDA #$08
PF74       STA $3600,X 
           DEX 
           DEY
           BNE PF74
           LDA #$FF
           STA $2C2
ENDMIS     RTS 

CKMISKL    LDA HPOS3
           SEC
           SBC CROSSX    
           BEQ FDS72
           BCC FDS71 
           CMP #$0D
           BCS FDS73
           JMP FDS72
FDS71      EOR #$FF
           CMP #$0C
           BCS FDS73
FDS72      JSR PLANEGON  
FDS73      LDA #$00  
           STA HPOS3
           STA SMISY
           RTS
;--------------------------------
; SAUCDEATH!!!!
; CHECK FOR SAUCER HIT
;--------------------------------
UFODIE     JSR CONTROL
           JSR KILUFO
           LDX #$03  
FDS81      LDA HIT1,X
           AND #$3
           BNE FDS82
           DEX
           BPL FDS81
           RTS
FDS82       INC UFOEXP  
           LDA #$00
           STA EXPSND
           LDX #$03
FDS83      LDA HIT1,X  
           AND #$8
           STA HIT1,X  
           DEX
           BPL FDS83
           LDA LEVEL
           CLC
           ADC #$01
           ADC BSCOR1
           STA BSCOR1
           INC HPOS2
           INC HPOS2 
           INC HPOS2 
           INC HPOS2  
           LDA #$0F
           STA PCOLR0
           STA PCOLR1
           LDA #$28
           STA UFCNT
           RTS

KILUFO     LDA UFOEXP
           BNE FDS91
FDS92      RTS   
FDS91      LDA #$00
           STA SAUCFLG
           INC UFKFLG
           LDA UFKFLG
           CMP #$60
           BNE FDS96
           LDA #$00
           STA UFKFLG
           LDX #$60
FDS93      LDA $3400,X  
           ASL 
           STA $3400,X  
           LDA $3500,X 
           LSR
           STA $3500,X 
           DEX
           BNE FDS93
           DEC UFCNT   
           BNE FDS96
           LDA #$00
           STA UFOEXP
           LDX #$60
FDS94       STA $3400,X
           STA $3500,X
           DEX
           BNE FDS94
           LDX #$03
FDS95      LDA HIT1,X
           AND #$08
           STA HIT1,X
           DEX
           BPL FDS95
FDS96      PLA  
           PLA
           RTS

;--------------------------------
; STAR ROUTINE
;--------------------------------
STARS      INC STRCNT
           LDA STRCNT
           CMP #$02
           BEQ FDS101
           RTS
FDS101     LDA #$00
           STA STRCNT
           LDX STRFAS
           STA $73F8,X
           INC STRFAS
           LDA STRFAS
           CMP #$08
           BNE FDS102
           LDA #$00
           STA STRFAS
           JSR STARPLOT
FDS102     LDX STRFAS    
           LDA #$0C
           STA $73F8,X  
           RTS

;--------------------------------
; STARPLOT SUBROUTINES
;--------------------------------
STARPLOT   LDX #$0D
PF711        LDY STARY,X
           LDA YLOW,Y
           STA IRQVAR1
           LDA YHI,Y
           STA IRQVAR2
           LDY STARX,X
           LDA (IRQVAR1),Y
           BEQ PF721
           CMP #$7F
           BEQ PF721
           CMP #$FF
           BNE PF751
PF721      LDA #$00
           STA (IRQVAR1),Y
PF751      INC STARY,X
           LDA STARY,X
           CMP #$15
           BNE PF761
           LDA #$00
           STA STARY,X
PF761      TAY
           LDA YLOW,Y
           STA IRQVAR1
           LDA YHI,Y
           STA IRQVAR2
           LDY STARX,X
           LDA (IRQVAR1),Y
           BNE PF771
           LDA #$7F
           BIT RANDOM
           BMI PF781
           LDA #$FF
PF781      STA (IRQVAR1),Y  
PF771      DEX   
           BPL PF711
           RTS

STARX      .BYTE $02,$05,$02,$0A,$0C,$0E,$13,$15,$19
           .BYTE $1D,$20,$24,$26,$28
STARY      .BYTE $01,$0A,$07,$00,$03,$11,$02,$05,$08
           .BYTE $13,$04,$00,$14,$04
YLOW       .BYTE $00,$28,$50,$78,$A0,$C8,$F0,$18  
           .BYTE $40,$68,$90,$B8,$E0,$08,$30,$58
           .BYTE $80,$A8,$D0,$F8,$20
YHI        .BYTE $40,$40,$40,$40,$40,$40,$40,$41
           .BYTE $41,$41,$41,$41,$41,$42,$42,$42
           .BYTE $42,$42,$42,$42,$43

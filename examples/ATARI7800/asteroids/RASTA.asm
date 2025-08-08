*         1900    200684
*
*
** RASTLOAD.S *
** ASTEROIDS FOR THE ATARI 3600. **
** THIS FILE CONTAINS THE LOADER ASSUMING 16 HIGH ZONES. *

** TRASHES ALL REGISTERS, TEMPI+0,+1,+2,+3,+4 **
** USES FREE THRU FREE+11 AS POINTERS TO NEXT FREE POSITION IN HEADER. **

LOADER    LDA     #4                     ;SET POINTER PAST FIRST HEADER FOR
          LDX     #11                    ; EACH DISPLAY LIST
ZAPFREE   STA     FREE,X
          DEX
          BPL     ZAPFREE

          LDX     #35
LOADLOOP  LDA     STATUS,X               ;CHECK STATUS OF EACH OBJECT
          BEQ     NEXTLOAD               ;CHECK IF ZERO.
          CMP     #$FF                   ;FORGET IF NULL, FF.
          BEQ     NEXTLOAD               ;OTHERWISE, LOAD IT

          AND     #$0F                   ;CHECK LOW NYBBLE
          CMP     #6                     ;IF = 6 THEN SHOT
          BNE     LOADOBJ

LOADSHOT  LDA     YPOSH,X                ;A <- Y POSITION OF OBJECT
          EOR     #$FF                   ;NEGATE POSITION
          AND     #$0F                   ;MOD 16 IS LINE IN ZONE
          STA     TEMPI+4
          LDA     YPOSH,X                ;A <- Y POSITION OF OBJECT
          LSR     A                      ;DIV 16 IS WHICH ZONE
          LSR     A
          LSR     A
          LSR     A
          TAY                            ;Y <- WHICH ZONE
          LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
          CLC
          ADC     LOWZONE,Y
          STA     TEMPI                  ;TEMPI = LO ADDR FOR FIRST FREE POS
          LDA     HIGHZONE,Y
          STA     TEMPI+1                ;TEMPI+1 = HI ADDRESS
          LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
;         CLC                            ;OPTIONAL
          ADC     #4                     ;INCREMENT FREE POINTER
          STA     FREE,Y
          LDY     #0
          LDA     #L(SHOT1)
          STA     (TEMPI),Y              ;STORE LOW ADDRESS IN HEADER - 1ST BYTE
          INY
          LDA     #$7F                   ;PALETTE 4, WIDTH 1
          STA     (TEMPI),Y              ;STORE IN HEADER - 2ND BYTE
          INY
          LDA     TEMPI+4                ;GET LINE IN ZONE
          ORA     #H(GRAPHICS)           ;ADD TO START OF GRAPHICS DATA
          STA     (TEMPI),Y              ;STORE HIGH ADDR IN HEADER - 3RD BYTE
          INY
          LDA     XPOSH,X                ;GET HORIZONTAL POSITION
          STA     (TEMPI),Y              ;STORE IN HEADER - 4TH BYTE

NEXTLOAD  DEX                            ;DECREMENT INDEX
          BPL     LOADLOOP               ;CONTINUE IF NOT FINISHED
          JMP     LOADSCOR               ;LOAD SCORE AT END OF DL IF DONE

* LOAD A STANDARD OBJECT INTO TWO ZONES
LOADOBJ   LDA     YPOSH,X                ;A <- Y POSITION OF OBJECT
          EOR     #$FF                   ;NEGATE POSITION
          AND     #$F                    ;MOD 16 IS LINE IN ZONE
          STA     TEMPI+4
          LDA     YPOSH,X                ;A <- Y POSITION OF OBJECT
          LSR     A                      ;DIV 16 IS WHICH ZONE
          LSR     A
          LSR     A
          LSR     A
          TAY                            ;Y <- WHICH ZONE
          LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
          CLC
          ADC     LOWZONE,Y
          STA     TEMPI                  ;TEMPI = LO ADDR FOR FIRST FREE POS
          LDA     HIGHZONE,Y
          STA     TEMPI+1                ;TEMPI+1 = HI ADDRESS
          LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
;         CLC                            ;OPTIONAL
          ADC     #4                     ;INCREMENT FREE POINTER
          STA     FREE,Y
          INY                            ;ALSO LOAD INTO HIGHER ZONE
          CPY     #12
          BCC     YOK                    ;NEW ZONE NUMBER OK?
          LDY     #0                     ;NO, RESET TO LOWEST ZONE
          CLC
YOK       LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
          ADC     LOWZONE,Y
          STA     TEMPI+2                ;TEMPI = LO ADDR FOR FIRST FREE POS
          LDA     HIGHZONE,Y
          STA     TEMPI+3                ;TEMPI+1 = HI ADDRESS
          LDA     FREE,Y                 ;A <- FREE POINTER FOR THAT ZONE
;         CLC                            ;OPTIONAL
          ADC     #4                     ;INCREMENT FREE POINTER
          STA     FREE,Y
          LDY     #0
          LDA     ACYC,X
          STA     (TEMPI),Y              ;STORE LO ADDR IN HEADER - 1ST BYTE
          STA     (TEMPI+2),Y
          INY
          LDA     PALS,X
          STA     (TEMPI),Y              ;STORE PALETTE + WIDTH INFO - 2ND BYTE
          STA     (TEMPI+2),Y
          INY
          LDA     STATUS,X               ;FOR STATUS = ICON USES CHARS AS BASE
          CMP     #ICON
          CLC
          BNE     ZHADSTMP               ;OTHERWISE USE GRAPHICS AS BASE
          LDA     TEMPI+4
          ADC     #H(CHARS-$0F00)
          BNE     ZSTHADDR               ;BNE = JMP HERE
ZHADSTMP  LDA     TEMPI+4
          ADC     #H(GRAPHICS-$0F00)
ZSTHADDR  STA     (TEMPI),Y              ;STORE HI ADDR IN HEADER - 3RD BYTE
;         CLC                            ;OPTIONAL
          ADC     #$10
          STA     (TEMPI+2),Y            ;STORE HI ADDR IN HEADER - 3RD BYTE
          INY
          LDA     XPOSH,X
          STA     (TEMPI),Y              ;STORE HOR POS IN HEADER - 4TH BYTE
          STA     (TEMPI+2),Y

* THIS CODE CHECKS FOR HORIZONTAL WRAP AROUND, AND LOADS THE OBJECT AGAIN
* IF IT NEEDS TO, IN ORDER TO WRAP SMOOTHLY
          CMP     #XPOSMAX-8             ;IS IT WITHIN A MARGIN OF THE EDGE?
          BCC     NEXTLOAD               ;NO.  IT'S OK, GO ON TO NEXT OBJECT.
          CPX     #25                    ;UFO IS CURRENTLY THE ONLY EXCEPTION
          BEQ     STEPNEXT               ; TO X-WRAPPING.
          CMP     #$F0                   ;HAS IT BEEN WRAPPED ALREADY?
          BCS     UNWRAP                 ;YES.  UNWRAP IT
          SBC     #XPOSMAX               ;WRAP IT: SUBTRACT OFF A SCREEN OFFSET
          STA     XPOSH,X                ;WANTS.  WRAP IT.
          JMP     LOADOBJ                ;LOAD IT AGAIN
UNWRAP    ADC     #XPOSMAX               ;UNWRAP IT: ADD BACK THE OFFSET
          STA     XPOSH,X
STEPNEXT  JMP     NEXTLOAD


LOADSCOR

**        HIGH SCORE
          LDY     #0
          LDA     FREE+11                ;GET POINTER FOR TOP ZONE
          CLC
          ADC     LOWZONE+11             ;GET LOW ADDR FOR DL
          STA     TEMPI
          LDA     HIGHZONE+11            ;GET HIGH ADDR FOR DL
          STA     TEMPI+1
          LDA     #L(SCORCMHS)             ;ADD TOP SCORE
          STA     (TEMPI),Y              ;LOW ADDR
          INY
          LDA     #$60                   ;WRITE MODE 0, INDIRECT
          STA     (TEMPI),Y
          INY
          LDA     #H(SCORCMHS)
          STA     (TEMPI),Y              ;HIGH ADDR
          INY
          LDA     #$78                   ;PALETTE 4, WIDTH 8
          STA     (TEMPI),Y
          INY
          LDA     #$39
          STA     (TEMPI),Y              ;HOR POSITION 39 HEX

**        COMBINED SCORE
          LDA     MODE                   ;ONLY DO FOR MODE 1
          CMP     #1
          BNE     LOADP1S

          INY
          LDA     #L(SCORECMC)
          STA     (TEMPI),Y              ;STORE LOW ADDRESS OF CHARS.
          INY
          LDA     #$60                   ;WRITE MODE 0, INDIRECT
          STA     (TEMPI),Y
          INY
          LDA     #H(SCORECMC)
          STA     (TEMPI),Y              ;STORE HIGH ADDRESS OF CHARS.
          INY
          LDA     #$90                   ;PALETTE 4, WIDTH 16
          STA     (TEMPI),Y
          INY
          LDA     #$39                   ;HOR POS 39 HEX
          STA     (TEMPI),Y

**        PLAYER 1 SCORE
LOADP1S   LDY     #0
          LDA     FREE+10                ;GET POINTER FOR NEXT ZONE
          CLC
          ADC     LOWZONE+10             ;GET LOW ADDR FOR DL
          STA     TEMPI
          LDA     HIGHZONE+10            ;GET HIGH ADDR FOR DL
          STA     TEMPI+1
          LDA     #L(SCORMAP1)
          STA     (TEMPI),Y              ;STORE LOW ADDRESS OF CHARS.
          INY
          LDA     #$60                   ;WRITE MODE 0, INDIRECT
          STA     (TEMPI),Y
          INY
          LDA     #H(SCORMAP1)
          STA     (TEMPI),Y              ;STORE HIGH ADDRESS OF CHARS.
          INY
          LDA     #$10                   ;PALETTE 0, WIDTH 16
          STA     (TEMPI),Y
          INY
          LDA     #$7                    ;HOR POS 7
          STA     (TEMPI),Y

**        PLAYER 2 SCORE
          INY
          LDA     #L(SCORMAP2)
          STA     (TEMPI),Y              ;STORE LOW ADDRESS OF CHARS.
          INY
          LDA     #$60                   ;WRITE MODE 0, INDIRECT
          STA     (TEMPI),Y
          INY
          LDA     #H(SCORMAP2)
          STA     (TEMPI),Y              ;STORE HIGH ADDRESS OF CHARS.
          INY
          LDA     #$30                   ;PALETTE 1, WIDTH 16
          STA     (TEMPI),Y
          INY
          LDA     #$65                   ;HOR POS 65 HEX
          STA     (TEMPI),Y

          LDA     FREE+11                ;INCREMENT POINTERS
          CLC
          ADC     #5
          STA     FREE+11

          LDX     MODE
          CPX     #1
          BNE     ZADDZ10
          CLC
          ADC     #5
          STA     FREE+11

ZADDZ10   LDA     FREE+10
          CLC
          ADC     #10
          STA     FREE+10

LOADZERO  LDX     #11                    ;LOAD ZEROS AT END OF DISPLAY LIST, DL
          LDY     #1
LOADZLP   LDA     FREE,X
          CLC
          ADC     LOWZONE,X
          STA     TEMPI
          LDA     HIGHZONE,X
          STA     TEMPI+1
          LDA     #0
          STA     (TEMPI),Y
          DEX
          BPL     LOADZLP
          STA     LOADFLAG               ;CLEAR FLAG SINCE DONE.
          RTS

LOADSTAR  LDX     #11
STARLOOP  LDA     LOWZONE,X              ;ESTABLISH LO ADDR
          STA     TEMPI
          LDA     HIGHZONE,X             ;ESTABLISH HI ADDR
          STA     TEMPI+1

          JSR     NEWRAND                ;PICK A RANDOM STAR (0 TO 3)
          AND     #$03
          CLC
          ADC     #L(STARS)              ;ADD IN BASE OF STARS

          LDY     #0
          STA     (TEMPI),Y              ;STORE LO ADDR

          INY
          LDA     STARPW,X
          STA     (TEMPI),Y              ;STORE PALETTE & WIDTH INFO

          INY
          LDA     #H(CHARS)
          STA     (TEMPI),Y              ;STORE HI ADDR

          JSR     NEWRAND                ;GET A RANDOM HORIZONTAL POSITION

          LSR     A                      ;BANG INTO RANGE
          ADC     #$10

          LDY     #3
          STA     (TEMPI),Y              ;STORE HOR POS

          DEX
          BPL     STARLOOP
          RTS

STARPW    DB      $7F,$9F,$7F,$7F,$BF,$7F,$DF,$7F,$7F,$FF,$9F,$DF
          EJE

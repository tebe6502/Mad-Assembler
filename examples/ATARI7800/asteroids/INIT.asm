*         1522    030784
*
*
*
** INIT.S **
** ASTEROIDS FOR THE ATARI 3600 **
** THIS FILE CONTAINS VARIOUS INITIALIZATION ROUTINES. **

* ROCK INITIALIZATION ROUTINE, SOFT PALETTES, RANDPOS AND VELOCITY TO ROCKS
INITROCK:
          LDA     #$FF                   ;FOR NEW RACK NULL OUT ROCKS.
          LDX     #23
NULLROCK: STA     STATUS,X
          DEX
          BPL     NULLROCK

*         ;PUT UP DIFFICULTY ICON.
*         LDA     #10
*         CLC
*         ADC     DIFF
*         TAY
*         LDX     #33
*         JSR     DOICON
*         LDA     #16                    ;REPOSITION ICON DURING GAMEPLAY
*         STA     XPOSH,X

          LDY     PLAYER
          LDX     ROCKTOT,Y
          DEX
NROKLOOP: LDA     #LARGE                 ;INITIALIZE ROCKS
          STA     STATUS,X
          LDA     ASPIN,X
          AND     #$7F
          TAY
          LDA     LBOUND,Y
          STA     ACYC,X                 ;STORE INITIAL ANIMATION
          JSR     RANDPOS                ;STORE A RANDOM BORDER POSITION
          JSR     RANDVEL                ; AND RANDOM VELOCITY.
          DEX
          BPL     NROKLOOP

COPYPALS: LDX     #32
ZOPYPALS: LDA     PALTAB,X               ;LOAD UP SOFT PALETTE/WIDTH TABLE
          STA     PALS,X
          DEX
          BPL     ZOPYPALS

          RTS

** ROUTINE TO INITIALIZE THE SCORE DISPLAY THE FIRST TIME. **
INITSCOR:
*         FIRST ZERO SCORE FOR BOTH PLAYERS
          LDX     #11
          LDA     #0
ZEROSCOR: STA     SCORE,X
          DEX
          BPL     ZEROSCOR

          RTS

* ROUTINE TO ZERO OUT THE HIGH SCORE
ZEROHS:   LDA     #0
          STA     HISCORE                ;ZAP THE HIGH SCORE
          STA     HISCORE+1
          STA     HISCORE+2
          STA     HISCORE+3
          RTS

INITPLAY:
          JSR     CLEARTUN               ;CLEAR OUT AUDIO CHANNELS

          ;SET UP STATUS FOR SHIP PARTS TO BE USED IN COLLIDE.
          LDA     #7                     ;SHIP'S PARTS = #7
          TAX                            ;THERE ARE EIGHT PARTS TO SET UP
NXTPART:  STA     STATUS+36,X
          DEX
          BPL     NXTPART

          ;SET UP TABLES FOR DIFF LEVELS.
          LDY     DIFF
          LDA     MAXLVLS,Y              ;HIGHEST ATTAINABLE LEVEL FOR DIFF
          STA     MAXLVL
          INY
          TYA
          LDX     #3                     ;FOUR TYPES OF INCREMENTS
ZNXTDLVL: STA     LVLINC,X               ; THE INCREMENT IS BASED ON
          ASL                            ; DIFF+1, SHIFTED LEFT BY
          DEX                            ; THE TYPE.  I.E:
          BPL     ZNXTDLVL               ; 8,4,2,1; 16,8,4,2; 24,12,6,3; ETC.

          LDA     #3                     ;3 SHIPS FOR EACH PLAYER
          STA     MENLEFT
          STA     MENLEFT+1
          LDA     #6                     ;6 FOR TEAM PLAY
          STA     MENLEFT+2

          LDA     #$FF                   ;INITIALIZE FOR BOTH PLAYERS
          STA     RACKNUM
          STA     RACKNUM+1
          STA     RUBFLAG                ;PRIME 'RUBBER SHIP' FLAG

          LDA     #0
          STA     ROCKTOT
          STA     ROCKTOT+1
          STA     PLAYER
          STA     OFFPLAY2
          STA     SHIPDIR
          STA     SHIPDIR2
          STA     RACKDLY
          STA     COMPFLAG

          LDA     #BIRTH                 ;START PLAYER 1 AS BIRTH
          STA     STATE

          LDA     #$20                   ;EVERYBODY STARTS AT LEVEL $20
          STA     LEVEL
          STA     LEVEL+1

          LDA     MODE
          BPL     ZSETTWO

          LDA     #DEAD                  ;IN ONE PLAYER GAME,
          STA     STATE+1                ; OTHER PLAYER IS DEAD.

          LDA     #RESINT+$10            ;START PLAYER 1 AT RESINT+10
          STA     TIMER
          RTS

ZSETTWO:  LDA     #BIRTH                 ;IN > 1 PLAYER GAME,
          STA     STATE+1                ; SECOND PLAYER WILL BE BORN.

          LDA     #PMSGT+1               ;TWO AND TEAM PLAY
          STA     TIMER
          STA     TIMER+1
          RTS

MAXLVLS:  .byte   $40,$60,$80,$DF        ;$DF = "AVOID WRAP" WHEN ADDING $20!

** ROUTINES THAT USED TO BE IN MAIN.S **

* ZERO OUT RAM. *
* ZERO OUT MEMORY PAGES 1F-18
ZERORAM:  LDA     #0
          TAY
          STA     TEMP                   ;LOADDR ALWAYS = 0 (Y IS LOADDR INDEX)

          LDX     #$1F                   ;START WITH PAGE 1F
NEXTX:    STX     TEMP+1

          ; ZAP ONE PAGE:
NEXTY:    STA     (TEMP),Y
          DEY
          BNE     NEXTY

          ; MOVE ON TO NEXT PAGE
          DEX
          CPX     #$17                   ;DON'T GO INTO PAGE 17
          BNE     NEXTX

* ZERO OUT THE ZEROPAGE (FF-86), BUT NOT THE RANDOMS (40-41)
          LDX     #$BE
ZPLOOP:   STA     $41,X
          DEX
          BNE     ZPLOOP
          RTS

* LOAD UP SOFTWARE COPY OF COLOR RAM FROM ROM COLORS
INITPALS: LDX     #$0F
ZNITPALS: LDA     COLORS,X
          STA     SOFTCOLR,X
          DEX
          BPL     ZNITPALS
          RTS

* NULL OUT ALL THE OBJECTS. *
NULLOBJS: LDX     #35                    ;NULL OUT OBJECTS
          LDA     #$FF
NEWNULL:  STA     STATUS,X
          STA     STATUS2,X
          DEX
          BPL     NEWNULL
          RTS


* SET UP MARIA 2 LISTS, DUMMY DL HEADER FOR BLANK ZONES AT TOP AND BOTTOM,
* SET UP DUMMY DL HEADER FOR TOP AND BOTTOM OF SCREEN:
INITDMA:
*         BUILD DLL.  ACTUALLLY, JUST COPY ROM TABLE INTO FASTER RAM.
          LDX     #$33                   ;TABLE IS $33 BYTES LONG
ZDLLOP:   LDA     DLLTAB,X
          STA     DLL,X
          DEX
          BPL     ZDLLOP

*         WAIT 'TILL VBLANK BEFORE DOING DELICATE OPERATIONS
ZDODMA:   BIT     MSTAT
          BPL     ZDODMA

          LDA     #DLL&255                ;POINT DPP TO DLL
          STA     DPPL
          LDA     #DLL>>8
          STA     DPPH

          LDA     #0
          STA     BLANKDL+1              ;SECOND BYTE ZERO = END OF DMA
          STA     NMICTRL                ;TELL NMI HANDLER TO DO NORMAL DLI'S

          LDA     #CHARS>>8            ;POINT CHARBASE TO OUR CHARACTERS
          STA     CHARBASE

          LDA     #$40                   ;TURN ON DMA
          STA     CTRL

          RTS

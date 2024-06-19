;--------------------------------
; NIGHTRAIDERS
; WRITTEN BY : PETER FILIBERTI
; COPYRIGHT 1982
;--------------------------------
       ORG $6B0               ; mads assembler
;       .OR  $6B0              ; original
;        * = $6b0              ; ATasm
;       .TF  OBJ               ;Stores object file directly to disk
;--------------------------------
; ZERO PAGE VARIABLES
;--------------------------------
HISCORE1   = $80             ;These are the three locations where
HISCORE2   = HISCORE1+1      ;the high score is saved in BCD
HISCORE3   = HISCORE2+1      ;for later use.
OLSCORE1   = HISCORE3+1      ;These are the three locations where
OLSCORE2   = OLSCORE1+1      ;the last score achieved is placed
OLSCORE3   = OLSCORE2+1      ;for use in menu screen also BCD.
BSCOR0     = OLSCORE3+1      ;This is a binary score used as a
BSCOR1     = BSCOR0+1        ;temporary score holder by the game.
SCORE1     = BSCOR1+1        ;This is the actual game score
SCORE2     = SCORE1+1        ;stored in BCD it is also the same
SCORE3     = SCORE2+1        ;score put on game screen while playing.
;--------------------------------
TEMP1      = SCORE3+1        ;TEMP1 through TEMP8 are temporary
TEMP2      = TEMP1+1         ;locations used by main program and
TEMP3      = TEMP2+1         ;subroutines. The INTERRUPT routines
TEMP4      = TEMP3+1         ;must not touch these locatons!
TEMP5      = TEMP4+1         ;""
TEMP6      = TEMP5+1         ;""
TEMP7      = TEMP6+1         ;""
TEMP8      = TEMP7+1         ;""
CLRVAR     = TEMP8+1
;--------------------------------
LEVEL      = CLRVAR+1        ;Games level of play 0-6
SCRCNT     = LEVEL+1         ;Screen fine scroll counter
;--------------------------------
HPOS1      = SCRCNT+1        ;Horizontal position player1
HPOS2      = HPOS1+1         ;Horizontal position player2
HPOS3      = HPOS2+1         ;Horizontal position player3
HPOS4      = HPOS3+1         ;Horizontal position player4
;--------------------------------
MOVFLG     = HPOS4+1         ;Flag for screen movement
FUEL       = MOVFLG+1        ;Fuel in planes tank 0-$50
CROSSX     = FUEL+1          ;Plane horizontal axis position
MISSLEX    = CROSSX+1        ;Missle horizontal position
SHIPS      = MISSLEX+1       ;Number of ships left. start=3
;--------------------------------
IRQVAR1    = SHIPS+1         ;IRQVAR1 through IRQVAR2 are
IRQVAR2    = IRQVAR1+1       ;temporary locations to be
IRQVAR3    = IRQVAR2+2       ;used by interrupt routines only.
IRQVAR4    = IRQVAR3+3       ;Main program should not use these!
;--------------------------------
TPOINT     = IRQVAR4+1       ;Target point positioner.
HIT1       = TPOINT+1        ;HIT1-HIT4 are copies of the
HIT2       = HIT1+1          ;colision register updated every
HIT3       = HIT2+1          ;60 hz. It is used by main program
HIT4       = HIT3+1          ;interrupts logicaly or data in these.
;--------------------------------
COLLAD     = HIT4+1          ;Screen collision address (TWO BYTES)
ACTFLG     = COLLAD+2        ;Plane action flag.
;--------------------------------
; ATARI I/O HARDWARE LOCATIONS
;--------------------------------
M0PF       = $D000           ;Missile 0 to playfield collision
M1PF       = $D001           ;Missile 1 to playfield collision
M2PF       = $D002           ;Missile 2 to playfield collision
M3PF       = $D003           ;Missile 3 to playfield collision

HPOSP0     = $D000           ; Player 0 Horizontal Position
HPOSP1     = $D001           ; Player 1 Horizontal Position
HPOSP2     = $D002           ; Player 2 Horizontal Position
HPOSP3     = $D003           ; Player 3 Horizontal Position

HPOSM0     = $D004           ; Missile 0 Horizontal Position
HPOSM1     = $D005           ; Missile 1 Horizontal Position
HPOSM2     = $D006           ; Missile 2 Horizontal Position
HPOSM3     = $D007           ; Missile 3 Horizontal Position

SIZEP0     = $D008           ;Size of player 0
SIZEP1     = $D009           ;Size of player 1
SIZEP2     = $D00A           ;Size of player 2
SIZEP3     = $D00B           ;Size of player 3

TRIG0      = $D010           ;Read trigger button 0
TRIG1      = $D011           ;Read trigger button 1
TRIG2      = $D012           ;Read trigger button 2
TRIG3      = $D013           ;Read trigger button 3

COLPM0     = $D012           ;Color of player and missile 0
COLPM1     = $D013           ;Color of player and missile 1
COLPM2     = $D014           ;Color of player and missile 2
COLPM3     = $D015           ;Color of player and missile 3

COLPF0     = $D016           ;Color of playfield 0
COLPF1     = $D017           ;Color of playfield 1
COLPF2     = $D018           ;Color of playfield 2
COLPF3     = $D019           ;Color of playfield 3
COLBK      = $D01A           ;Playfield Background color

PRIOR      = $D01B           ;Priority select
HITCLR     = $D01E           ;Clear Player/Missile Collisions
GRAFP3     = $D010           ;Graphics for player 3
VSCROLL    = $D405           ;Vertical scroll register

; Audio registers
AUDF1      = $D200           ;Audio channel 1 frequency
AUDC1      = $D201           ;Audio channel 1 control
AUDF2      = $D202
AUDC2      = $D203
AUDF3      = $D204
AUDC3      = $D205
AUDF4      = $D206           ;Audio channel 4 frequency
AUDC4      = $D207           ;Audio channel 4 control
AUDCTL     = $D208           ;Audio control
ALLPOT     = $D208           ; (Read) Read 8 line POT port state

SKRES      = $D20A           ; (Write) Reset status (SKSTAT)
RANDOM     = $D20A           ; (Read) Random number
SKCTL      = $D20F           ;Serial Port Control
SKSTAT     = $D20F           ;(Read) Serial port status

PORTA      = $D300           ;Jack 0 & 1
PORTB      = $D301           ;Jack 2 & 3
PACTL      = $D302           ; Porta A control
PABTL      = $D303           ; Porta B control

PMBASE     = $D407           ;Player missle base address
CHBASE     = $D409           ;Character Set Base Address (high)
WSYNC      = $D40A           ;Wait for horizontal blank sync.
VCOUNT     = $D40B           ;Vertical line counter
NMIEN      = $D40E           ;NMI control register

CONSOL     = $D01F           ;Console switch address
GRACTL     = $D01D           ;Graphic control address
;--------------------------------
; Memory locations mapped to display 
;--------------------------------
SCREEN     = $4000           ;Location in Memory of our Menu Screen Data
DISPLA     = $3F00           ;Another menu screen location
;--------------------------------
VDLST      = $200            ;Display list interrupt vector
VBLK       = $224            ;Vertical blank interrupt vector
DLISTP     = $230            ;Display list pointer
SSKCTL     = $232            ;SKCTL (POKEY)
GPRIOR     = $26F            ;data from CTIA PRIOR (D01B)
CLB        = $2C8            ;Color register background
COLOR0     = $2C4            ;COLPF0 - Playfield 0 color
COLOR1     = $2C5            ;COLPF1 - Playfield 1 color
COLOR2     = $2C6            ;COLPF2 - Playfield 2 color
COLOR3     = $2C7            ;COLPF3 - Playfield 3 color
PCOLR0     = $2C0            ;Color player 1
PCOLR1     = $2C1            ;Color player 2
PCOLR2     = $2C2            ;Color player 3
PCOLR3     = $2C3            ;Color player 4
KEY        = $2FC            ;Read Keypress  
CHBAS      = $2F4            ;Shadow register for hardware register - Character set base address - Font-Start
STRIG0     = $284            ;Joystick trigger
DMACTL     = $22F            ;Dma control register
;--------------------------------
; GAME COLD START
;--------------------------------
COLDSTART  LDX #HISCORE1       ;Clear all of zero page variables
           JSR INIT            
           JMP INTRO           ;Goto menu routines
;
WARMSTART  LDX #BSCOR0         ;Erase all of zero page variables starting @ BSCOR0 (retain high scores).
           JSR INIT            
           JMP INTRO           ;Goto menu routines
;--------------------------------
; WORDS USED BY INTRODUCTION
;--------------------------------
       .DEF WORDS 
       .BYTE 00
       .BYTE 'BY PETER FILIBERTI    DATAMOST INC  8@?:'
       .BYTE 00
       .BYTE 'HIGH SCORE      YOUR SCORE      '
       .BYTE 00
       .BYTE 'CURRENT RANK'
       .BYTE 00
LEVNAM .BYTE 'NOVICE'
       .BYTE 00
       .BYTE 'CADET'
       .BYTE 00
       .BYTE 'ENSIGN'
       .BYTE 00
       .BYTE 'CAPTAIN'
       .BYTE 00
       .BYTE 'COMMANDER'
       .BYTE 00
       .BYTE 'NIGHTRAIDER'
       .BYTE 00
       .BYTE 'PRESS SELECT TO CHANGE STARTING RANK'
       .BYTE 00
       .BYTE 'PRESS START OR FIRE BUTTON TO PLAY'
       .BYTE 00
       .BYTE 'TODAYS TOP TEN HIGH SCORES'
       .BYTE 00
       .BYTE ' CONGRAULATIONS YOU HAVE THE HIGH SCORE '
       .BYTE 00
       .BYTE '    YOUR SCORE IS ONE OF THE TOP TEN    '
       .BYTE 00
       .BYTE '           ENTER YOUR INITIALS          '
       .BYTE 00
;--------------------------------
TBL1   .BYTE $12,$19,$17,$0B
COLORT .BYTE $8D,$94,$CA,$45,$00 
P1     .BYTE $00,$18,$24,$24,$7E,$FF,$FF,$FF     ;P1-P4 are plane shapes 
       .BYTE $FF,$FF,$81,$FF                     ;I just felt like putting
P2     .BYTE $00,$00,$18,$18,$00,$00,$42,$42     ;them here!??
       .BYTE $5A,$FF,$FF,$FF
P3     .BYTE $00,$00,$00,$00,$00,$01,$03,$0F
       .BYTE $1F,$7F,$00,$00
P4     .BYTE $00,$00,$00,$00,$00,$80,$C0,$F0    
       .BYTE $F8,$FE,$00,$00
;--------------------------------
; INTRODUCTION ROUTINE
;--------------------------------
INTRO  LDA #$2C                 ;Setup character base address
       STA CHBAS                ;for our font $2C00
;--------------------------------
       LDA #LIST1&255           ;Setup our display list pointers
       STA DLISTP               ;to point to our display list LIST1
       LDA #LIST1/255
       STA DLISTP+1
;--------------------------------
       LDA #$00
       STA VSCROLL              ;Put a zero in horizontal scroll reg
       LDA #$3A
       STA DMACTL               ;Enable player DMA
       LDA #$03
       STA GRACTL               ;Enable player graphics
;--------------------------------
       JSR CLRMEN               ;Clear menu page
;--------------------------------
       LDA #MIRQ1&255           ;Setup the irq vectors to
       STA VDLST                ;point to our Irq routines
       LDA #MIRQ1/255           ;for use during Menu 
       STA VDLST+1              ;operations.
;--------------------------------
VSYNC  LDA VCOUNT               ;Is scan line at the top of the screen?
       CMP #$80                 ;For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BCC VSYNC                ;If not then loop
       LDA #$C0                 ;NMIEN_DLI($80) | NMIEN_VBI($40) - activate display list interrupt and vertical blank interrupt
       STA NMIEN                ;Enable Display list interrupts
;--------------------------------
       LDA #$00                 ;ACC = 0
       STA TEMP1                ;Setup for Line 0 on Screen
       STA TEMP7                ;No offset for charset
       LDX #$01                 ;Print MSG #1
       LDY #$00                 ;Offset on Screen line is 0
       JSR PRINT                ;Go Print By peter filiberti etc....
;--------------------------------
       INC TEMP1                ;Next line on Screen
       LDX #$02                 ;Print MSG #2
       LDY #$07                 ;Offset on Screen line is 7
       JSR PRINT                ;Go Print High score    Your score
;--------------------------------
; Now Print Score Data on Screen
;--------------------------------
SCORER LDX #$02                 ;# of BCD Bytes to print for each score
       LDY #$00                 ;Init Screen offset to 0
FDS9   LDA HISCORE1,X           ;Get a BCD byte
       LSR                      ;Shifting right 4 bits 
       LSR                      ;to get the left bcd digit.
       LSR                      ;
       LSR                      ;
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird internal ascii
       STA SCREEN+$59,Y         ;Put on screen
;--------------------------------
       LDA OLSCORE1,X
       LSR                      ;Shifting right 4 bits 
       LSR                      ;to get the left bcd digit.
       LSR                      ;
       LSR                      ;
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird ascii
       STA SCREEN+$69,Y         ;Put on Screen
;--------------------------------
       INY                      ;Bump Screen Offset
;--------------------------------
       LDA HISCORE1,X           ;Get a BCD byte
       AND #$0F                 ;Only want right digit
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird ascii
       STA SCREEN+$59,Y         ;Put on screen
;--------------------------------
       LDA OLSCORE1,X           ;Get a BCD byte
       AND #$0F                 ;Only want right digit
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird ascii
       STA SCREEN+$69,Y         ;put on screen
;--------------------------------
       INY                      ;Bump Screen Offset
       DEX                      ;Dec # of BCD bytes to do
       BPL FDS9                 ;if not done loop
;--------------------------------
       LDA #$80                 ;set charset offset to $80
       STA TEMP7                ;set in TEMP7 for print routine
       LDA #$98                 ;get color for playfied
       STA COLOR3               ;set this for 3rd playfield color
;--------------------------------
       LDA #$06                 ;Set line offset to 6
       STA TEMP1                ;Setup for Line 6 on Screen
       LDX #$0A                 ;Print MSG #10
       LDY #$02                 ;with line horiz offset of 2
       JSR PRINT                ;PRESS SELECT TO CHANGE STARTING RANK
;--------------------------------
       INC TEMP1                ;advance a line
       LDX #$0B                 ;Print MSG #11
       LDY #$03                 ;with line horiz offset of 3
       JSR PRINT                ;PRESS START OR FIRE BUTTON TO PLAY
;--------------------------------
       LDA #$0A                 ;Set line offset to 10
       STA TEMP1                ;Setup for line 10 on screen
       LDA #$00                 ;Set charset offset to 0
       STA TEMP7                ;set in TEMP7 for print routine
       LDX #$03                 ;print MSG #3
       LDY #$04                 ;with horiz offset of 4
       JSR PRINT                ;CURRENT RANK
;--------------------------------
       LDA #$00
       STA LEVEL                ; Init default game level to 0
;--------------------------------
SELECT LDX #$14                 ; Erase 20 bytes of screen data
       LDA #$00                 ; A=0
FDS10  STA SCREEN+$1A4,X        ; Erase at Level screen location offset
       DEX                      ; dec counter if not 0 more bytes to clear loop
       BNE FDS10
;--------------------------------
       LDA #$0A                 ;Set line offset to 10
       STA TEMP1                ;Setup for line 10 on screen
       LDA #$80                 ;set charset offset to $80
       STA TEMP7                ;set in TEMP7 for print routine
       LDA LEVEL                ;get game level
       CLC
       ADC #$04                 ;add 4 to compute msg # to print
       TAX                      ;and store in x for print routine
       LDY #$17                 ;horizontal offset of 23
       JSR PRINT                ;print level
;--------------------------------
       JSR BEEPS                ;play a few beep sounds
;--------------------------------
       LDA #$00                 ;zero out TEMP6 7 and 8
       STA TEMP6                ;not sure why...
       STA TEMP7
       STA TEMP8
;--------------------------------
CKEY   LDA CONSOL               ; Read console keys
       ROR                      ; look at bit 0 Start
       BCS PF1                  ; if not pressed branch
       JMP GAME                 ; otherwise start game
;--------------------------------
PF1    ROR                      ; look at bit 1 Select
       BCS PF2                  ; if not pressed branch
;--------------------------------
PF3    LDA CONSOL               ; Read console keys
       AND #$02                 ; check bit 1 Select
       BEQ PF3                  ; if still pressed branch
       INC LEVEL                ; else bump level
       LDA LEVEL                ; get level
       CMP #$06                 ; is it 6?
       BNE PF4                  ; if not branch
       LDA #$00                 ; else wrap reset it back
       STA LEVEL                ; to level 0
PF4    JMP SELECT               ; go print new level and repeat
PF2    LDA TRIG0                ; read game control fire button
       BNE CKEY                 ; if not pressed branch
       JMP GAME                 ; else start game

;--------------------------------
; CLRMEN Clears our Menu Screen
; $4000 - $4FFF
;--------------------------------
CLRMEN LDA #$40                 ;Set TEMP1/TEMP2 as indirect pointer
       STA TEMP2                ;to $4000
       LDY #$00                 ;start y offset at 0
       STY TEMP1                
FDS12  TYA                      ; acc = 0;
FDS11  STA (TEMP1),Y            ; zero a location in memory indirect index,y
       INY                      ; bump index 
       BNE FDS11                ; if not 0 yet loop until all 256 bytes are erased
;       
       INC TEMP2                ; bump high byte of pointer
       LDA TEMP2                ; get it
       CMP #$50                 ; are we at $50 = $5000 yet?
       BNE FDS12                ; if not repeat until we are
       RTS

;--------------------------------
; MIRQ1 Vertical Display List Interrupt Handler
; Enabled during Menu Screen Presentation. Rotates
; Colors of Nightraiders Logo and other screen fields
;--------------------------------
MIRQ1  PHA              ; Save ACC
       TXA              ; A=X
       PHA              ; Save X
       LDA VCOUNT       ; Get Vertical Line Count of screen display
       CMP #$30         ;For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BCS MIRQ2        ;if > 48 branch
       LDA COLOR2       ;Get Color2
       LDX #$11         ;Set X as counter for 17 lines this will animate Nightraiders Logo Colors
FDS13  STA WSYNC        ;Wait for Sync 0 A write to WSYNC causes the CPU to halt execution until the start of horizontal blank.
       STA COLPF2       ;save color in color playfield register
       CLC              ;add 2 to color for next line
       ADC #$02         ;for colo shift
       DEX              ;Done for all 17 horiz lines?
       BNE FDS13        ;if not loop
       INC CCNT         ;inc CCNT = ?
       LDA CCNT         ;load it
       CMP #$08         ;is it 8?
       BNE FDS14        ;if not branch
       LDA #$00         ;else reset back to 0 
       STA CCNT         
       INC COLOR2       ;Advance color2 for next screen frame
FDS14  LDA #$28         ;we are past Nightraiders LOGO restore playfield
       STA COLPF2       ;color2 for rest of display
       PLA              ;get a
       TAX              ;restore x
       PLA              ;restore a
       RTI    
CCNT   .BYTE 00
;--------------------------------
; handle field colors after lin 48
;
MIRQ2  TYA    ; Do we really need to save y here?
       PHA    ; looks unecessary.
       LDA #$C8     
       STA COLPF2
       LDA #$0F
       STA COLPF3   
       PLA
       TAY
       PLA
       TAX
       PLA
       RTI

;--------------------------------
; GAME - Game Play Starts Here
;--------------------------------
GAME   LDA #$00
       STA NMIEN            ;Disable NMI
       STA DMACTL           ;Disable DMACTL
       LDX #$05             ;Init 5 Colors x=index to colorT table
COLFIL LDA COLORT-1,X       ;Get Color from table
       STA COLOR0-1,X       ;Set Color Register
       DEX                  ;Dec index
       BNE COLFIL           ;If not 0 loop until all 5 done
;       
       LDA #IRQ1&255        ;Setup the irq vectors to
       STA VDLST            ;point to our Irq routines
       LDA #IRQ1/255        ;for use during Game
       STA VDLST+1          ;operations.
;       
       LDA #VBLANK&255      ;setup vertical blank interrupt vector
       STA VBLK
       LDA #VBLANK/255
       STA VBLK+1
;       
       LDA #LIST2&255       ;Game uses display list LIST2 so 
       STA DLISTP           ;setup pointer to that 
       LDA #LIST2/255
       STA DLISTP+1
;--------------------------------
; Modify Display List 2 to point the screen data initially
; to $4C58. Note: This gets modfied on the fly as screen 
; scrolls.
;--------------------------------
       LDA #$58
       STA LIST2+3
       LDA #$4C
       STA LIST2+4
;--------------------------------
; There are 8 vertical lines per char on screen and so we scroll
; using the scroll register 8 times then reset it and
; move the display list memory pointers LIST2+3 LIST2+4
;
       LDA #$07
       STA SCRCNT    ; Initialize our scroll count to 7
       STA VSCROLL   ; Set Vertical Scroll Register to match
;
       JSR CLRMIS    ; Clear Missle player disp data
       JSR SETSCREEN ; Setup our Screen Data from Map
;       
       LDA #$0F
       STA $D404
       JSR PMAKER    ; Build Image Data of Plane
;       
       LDA #$70      ; Change our Character Set Data to
       STA CHBAS     ; Character set at $7000
;       
       LDA #$50      ; Fill Screen Data with 1st Map
       JSR MAPFIL
;       
       LDA #$31
       STA GPRIOR
;       
CS     STA WSYNC     ; Wait for Horizontal Sync (Stops Processor until Sync)
       LDA VCOUNT    ; Get vertical line we are displaying
       CMP #$78      ; For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BNE CS        ; if not = $78 loop until so
       STA WSYNC     ; Wait for Horizontal Sync (Stops Processor until Sync)
;
       LDA #$C0      ;NMIEN_DLI($80) | NMIEN_VBI($40) - activate display list interrupt and vertical blank interrupt
       STA NMIEN
       LDA #$3E      ;Init DMA 
       STA DMACTL 
;
       LDA #$00      
       STA BSCOR0    ;Initalize Binary Score data
       STA BSCOR1
       STA SCORE1    ;And BCD Score Data to 0
       STA SCORE2
       STA SCORE3
;
       LDA #$50      ;Initialize Starting Fuel Amount (80)
       STA FUEL
       LDA #$04      ;Initialize # of Ships
       STA SHIPS

       ICL "night2.asm"
       ICL "night3.asm"
       ICL "interrupts.asm"
       ICL "subroutines.asm"
       ICL "shapes.asm"
       ICL "variables.asm"

       ; Load in character sets and maps where game expects to be
       ORG $2C00  
       INS "charset2.bin"
       ORG $5000
       INS "maps.bin"

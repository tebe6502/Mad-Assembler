                run $2000

                ROWS = 11
                COLS = 13
                LINESPERROW = 16
                ROWSIZE = LINESPERROW * 3 + 1
                SCREEN = $3030

                RTCLOK = $14
                ATRACT = $4d
                STICK0 = $278
                STRIG0 = $284
                CH = $2fc
                COLPF0 = $d016
                COLPF1 = $d017
                COLPF2 = $d018
                COLPF3 = $d019
                COLBK = $d01a
                PRIOR = $d01b
                CONSOL = $d01f
                AUDF1 = $d200
                AUDC1 = $d201
                AUDCTL = $d208
                RANDOM = $d20a
				NMIEN = $d40e
				WSYNC = $d40a
				VCOUNT = $d40b

DLITABLE        = $80
ENDDLITABLE     = DLITABLE+16
/*
DLITABLE        .byte 0, 2, 4, 6, 8, 10, 12, 14, 14, 12, 10, 8, 6, 4, 2, 0
ENDDLITABLE     .byte 0, 2, 4, 6, 8, 10, 12, 14
*/
DIV1            = $98
DIV2            = $99
TEMP            = $9a
TILEPOS         = $9b
OLDTILEPOS      = $9c
TILECOLOR       = $9d           ; Can also use TEMP if more space in zeropage is needed
SCORE           = $9e
                org $9f
OLDRANDOM       .byte 0
TILESET         .byte %00010001
DLITABVEC       .word DLITABLE
PALETTELIST     .byte $33, $44, $55, $66, $77, $88, $99, $aa, $bb, $cc, $dd, $ee, $ff
ENDPALETTELIST
WINNERFLAG      .byte 0         ; WINNERFLAG's 0 is also used for MULTITABLE
MULTITABLE      .byte 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36
MOVETEXT        dta d "MOVES:000"
SCORETEXT       dta d "SCORE"
textline1       dta d "1K RAINBOX - F.HOLST"*
textline2       dta d " ASC 2024   LEVEL:"
LEVEL           dta d "1"

                org $2000

                ldx #7
                ldy #14
tableloop       tya
                sta DLITABLE,X
                sta ENDDLITABLE,X
;                sec                ; SEC and CLC should be used here, but since color are the same for two adjacent values, it doesn't make a difference here.
                sbc #14
                eor #$ff
;                clc
                adc #1
                sta DLITABLE+8,X
;                sta ENDDLITABLE+8,X
                dey
                dey
                dex
                bpl tableloop

                ldx #LINESPERROW        ; Create the displaylist with LINESPERROW number of lines per row.
                ldy #0                  
nextline        lda #$0f+$40            ; Every line is ANTIC mode $0F with a Load Memory Scan (LMS)
;                ora TEMP                ; Every such command is OR'ed with the content of the TEMP variable to add a DLI every two lines
                sta DLISTGEN,y          ; Store it in the display list
;                eor #$80                ; Flip the valie of the TEMP variable between 0 and $80 in order to de-/activate the DLI bit
;                sta TEMP
                iny
                lda #<SCREEN            ; Now comes the LMS address. Since we store the first line at $3030, we can save two byte here
                sta DLISTGEN,y          ; Store the LSB of the LMS address
                iny
                sta DLISTGEN,y          ; Store the MSB of the LMS address
                iny
                dex                     ; Done one line
                bne nextline            ; Have we done all 16 lines per row?
                lda #$80                ; At the end of each row is one blank scan line to separate the rows
                sta DLISTGEN,y          ; Store in display list

                ldy #0                  ; now copy this one row 10 more times. Y contains the byte position in each line (0 to 49)
                ldx #0                  ; X counts from 0 to 2. On 2 (i.e. every third byte), TEMP is increased
dlloop          lda #0
                sta TEMP                ; TEMP contains the value from 1 to 11 to be added to the MSB of the LMS address (i.e. $3030, $3130, $3230 etc.)
                lda DLISTGEN,y          ; Load value from first row
                cpx #2                  ; Third byte already?
                bne @+                  ; No?
                ldx #0                  ; Otherwise reset X counter
                inc TEMP                ; And increase TEMP
                bne @+1                 ; Always non-zero, so skip increasing X register
@               inx                     ; Next byte
@               clc                     ; Clear carry just in case
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*1,y     ; Store it in second row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*2,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*3,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*4,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*5,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*6,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*7,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*8,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*9,y     ; Store it in next row
                adc TEMP                ; Add 1 to 11 to MSB of LSB
                sta DLISTGEN+ROWSIZE*10,y    ; Store it in next row
                iny                     ; Next byte
                cpy #ROWSIZE           ; All lines already?
                bne dlloop              ; No? Then next one.

                ldx #ENDPALETTELIST-PALETTELIST-1
createtile      lda MULTITABLE-1,X      ; MULTITABLE reuses preceding WINNERFLAG's initial 0 as the multiplicaton table is only used after boot.
                tay
                lda PALETTELIST,X
                sta TILE+1,y
                iny
                sta TILE+1,Y
                iny
                and #$f0
                sta TILE+1,y
                dex
                bpl createtile

/*
                lda #<VBI               ; Load LSB of VBI routine
                sta 548                 ; And store it in vector
                lda #>VBI               ; Load MSB of VBI routine
                sta 549                 ; And store it in vector
*/
				lda #<DLI               ; Load LSB of DLI routine
				sta 512                 ; And store it in vector
				lda #>DLI               ; Load MSB of DLI routine
				sta 513                 ; And store it in vector
                lda #<DLIST             ; Load LSB of display list
                sta 560                 ; And store it in vector
                lda #>DLIST             ; Load MSB of display list
                sta 561                 ; And store it in vector
                lda #192
                sta NMIEN               ; Enable VBI and DLI

newgame         lda #>SCREEN            ; Before each new game
                sta SMC1+2              ; restore address of self-modified code
                ldy #ROWS-1             ; Y is line counter
fillloop        ldx #ENDTILE-TILE       ; X is the index to the line's tile representations, start at the end
fillline        lda TILE,x              ; Load the color from the palettelist
;                beq SMC1
;                and TILE,x              ; And AND it with the respective byte of the tile representation
SMC1            sta SCREEN,x            ; Store it in SCREEN memory area. The target address gets modified during runtime.
                dex                     ; Next byte of tile representation
                bne fillline            ; Not done? Then next tile in line.
                inc SMC1+2              ; Since we put each line in increments of $100 starting from $3030, we can just modify the MSB here by adding 1.
                dey                     ; Next line
                bpl fillloop            ; Not done? Then next line.

waitstart       lda WINNERFLAG
                beq @+
                lda 20
                sta WINNERFLAG
                bne waitstart
@               lda STRIG0
                beq startgame
                lda STICK0
                cmp #7
                beq select
                lda CONSOL
                cmp #6
                beq startgame
                cmp #5
                beq select
                cmp #3
                bne waitstart
                jsr option
                bne waitstart
select          inc LEVEL
                lda LEVEL
                cmp #":"
                bne @+
                lda #"1"
                sta LEVEL
@               jsr movesound
                bne waitstart

option          lda TILESET
                pha
                rol
                pla
                rol
                sta TILESET
                lda DLITABVEC
                eor #8
                sta DLITABVEC
                jsr movesound
                rts

startgame       lda #COLS
                sta DIV2                    ; divisor (columns)
                lda RANDOM                  ; generate random tile number
                and #127                    ; bitmask will result in first 128 positions
                sta TILEPOS
                sta OLDTILEPOS
                sta DIV1                    ; dividend (tile number)
                jsr calctileaddr
                lda #0
                sta SCORE
                jsr filltile

                ldx #8
@               lda MOVETEXT,X
                sta textline2+1,X
                dex
                bpl @-
                lda #15
                adc #"0"
                sbc LEVEL                    ; save memory here by just starting with STA CLICKSPEED+1
                sta CLICKSPEED+1
                lda LEVEL
                and #$0F
                asl
                asl
                asl
                asl
                tax
nextstep        txa
                pha
tryagain        lda RANDOM
                and #%00000011
                tay
                and #%00000001
                eor OLDRANDOM
                beq tryagain
                tya
                bne @+
                jsr moveup
@               tya
                cmp #2
                bne @+
                jsr movedown
@               tya
                cmp #1
                bne @+
                jsr moveleft
@               tya
                cmp #3
                bne @+
                jsr moveright
@               lda TILEPOS
                cmp OLDTILEPOS
                beq tryagain
                pha
                tya
                and #%00000001
                sta OLDRANDOM
                pla
                jsr movetiles
                ldy #2
movesloop       lda textline2+7,y
                inc SCORE
                clc
                adc #1
                cmp #":"
                bne writemoves
                lda #"0"
                sta textline2+7,y
                dey
                bpl movesloop
writemoves      sta textline2+7,y
                pla
                tax
                dex
                bne nextstep

                ldy #4
scoretextloop   lda SCORETEXT,y
                sta textline2+1,y
                dey
                bpl scoretextloop

loop            lda CONSOL
                cmp #7
                beq contloop
                cmp #3
                bne jmpnewgame
                jsr option

contloop        rol
                sta CLICKSPEED+1
                lda STICK0
                sta ATRACT
                tay
                cmp #15
                beq loop
                tya
up              cmp #13
                bne down
                jsr moveup
down            tya
                cmp #14
                bne left
                jsr movedown
left            tya
                cmp #7
                bne right
                jsr moveleft
right           tya
                cmp #11
                bne endstick
                jsr moveright
endstick        lda TILEPOS
                cmp OLDTILEPOS
                beq loop
                jsr movetiles
                ldy #2
scoreloop       lda SCORE
                beq jmpcheckwin
                dec SCORE
                lda textline2+7,y
                sec
                sbc #1
                cmp #"/"
                bne writescore
                lda #"9"
                sta textline2+7,y
                dey
                bpl scoreloop
writescore      sta textline2+7,y
jmpcheckwin     jsr checkwin
                lda WINNERFLAG
                beq loop
jmpnewgame      jmp newgame

moveup          lda TILEPOS
                cmp #COLS
                bcc exitmoveup
                sec
                sbc #COLS
                sta TILEPOS
exitmoveup      rts

movedown        lda TILEPOS
                cmp #130
                bcs exitmovedown
                clc
                adc #COLS
                sta TILEPOS
exitmovedown    rts

moveleft        lda TILEPOS
                beq exitmoveleft
                sec
leftcheck       sbc #COLS
                beq exitmoveleft
                bmi execleft
                bne leftcheck
execleft        dec TILEPOS
exitmoveleft    rts

moveright       lda TILEPOS
                cmp #COLS*ROWS-1
                beq exitmoveright
                clc
                adc #1
                sec
rightcheck      sbc #COLS
                beq exitmoveright
                bmi execright
                bne rightcheck
execright       inc TILEPOS
exitmoveright   rts

movetiles       beq exitmove
                jsr movesound
                lda TILEPOS
                sta DIV1
                lda #COLS
                sta DIV2
                jsr calctileaddr
                ldy #0
                lda (DIV1),y
                sta TILECOLOR
                tya
                jsr filltile
                lda OLDTILEPOS
                sta DIV1
                lda #13
                sta DIV2
                jsr calctileaddr
                lda TILECOLOR
                jsr filltile
                lda TILEPOS
                sta OLDTILEPOS
exitmove        rts

movesound       lda #0
                sta AUDCTL
                lda #$ff
                sta AUDC1
                lda RTCLOK
CLICKSPEED      adc #14
                sta TEMP
soundloop       sta AUDF1
                lda RTCLOK
                cmp TEMP
                bne soundloop
                lda #$a0
                sta AUDC1
                rts

checkwin        lda #>SCREEN
                sta checkline+2                  ; restore self-modified code
checkloop       ldy #0
                ldx #0
checkline       lda SCREEN+1,X
                beq nextcheck
;                and TILE,X
;                beq nextcheck
                cmp PALETTELIST,y
                beq nextcheck
                rts
nextcheck       inx
                inx
                inx
;                cpx #36
                iny
                cpy #ENDPALETTELIST-PALETTELIST
                bne checkline
                inc checkline+2                  ; since we put each line in increments of $100 starting from $3030, we can just modify the code here
                lda checkline+2
                cmp #$3b
                bne checkloop
                lda #1                 ; set to non-zero while at the same time use it later on as a counter for the winner effect
                sta WINNERFLAG
                sta 20
                rts

calctileaddr    lda DIV1        ; potential for saving space by having the accumulator already properly loaded
                ldx #$ff
                sec
@               inx
                sbc DIV2
                bcs @-
                adc DIV2         ; A contains remainder
                tay
                lda MULTITABLE-1,y
                clc
                adc #$31         ; Tile data starts at $XX31
                sta DIV1
                txa              ; X contains result
                clc
                adc #$30
                sta DIV2
                rts

filltile        ldy #2           ; each tile consists of three bytes, i.e. six pixels
                tax              ; save the original value
                and #$f0         ; mask the sixth pixel to 0 in order to create a black frame
tileloop        sta (DIV1),y
                txa              ; restore the original value (actually only necessary for the second iteration, but doesn't do harm)
                dey
                bpl tileloop
                rts

/*
VBI             lda WINNERFLAG
                beq exitvbi
                ldx #31
                inc WINNERFLAG
colorloop       lda DLITABLE,x
                sta DLITABLE+1,x
                dex
                bpl colorloop
                lda DLITABLE+32
                sta DLITABLE
exitvbi         jmp $e462
*/

DLI             pha
                tya
                pha
                txa
                pha
                lda VCOUNT
                cmp #$6D            ; change here if the DL is changed above this line
                bpl textline
                cmp #20
                bmi textline

                lda #192
                sta PRIOR
                ldy #ENDDLITABLE-DLITABLE-1
                lda TILESET
                and #%00001100
                beq dliloop1
                ldy #(ENDDLITABLE-DLITABLE-1)/2
dliloop1        lda (DLITABVEC),y
                ldx WINNERFLAG
                beq @+
                clc
                adc 20
                and #%00001111
@               sta WSYNC
                sta COLBK
                lda TILESET
                and #%00001100
                beq singleline
                sta WSYNC
singleline      dey
                bpl dliloop1
                bmi dliexit

textline        ldx #0
                stx COLBK
                stx PRIOR
dliloop2        lda DLITABLE,x
                sta WSYNC
                sta COLBK
                eor #$0f
                clc
                adc #$10
                sta COLPF0
                ldy textline2+4
                bne @+
                sbc 20
@               adc #$10
                sta COLPF2
                inx
                cpx #8
                bne dliloop2
                lda #0
                sta WSYNC
                sta COLBK
/*
                ldx #0
                stx TABLEFLAG
                stx COLBK
                stx PRIOR
dliloop         stx WSYNC
                stx COLBK
                txa
                eor #$0f
                clc
                adc #$10
                sta COLPF0
                adc #$10
                sta COLPF2
                lda TABLEFLAG
                bne decrease
                inx
                inx
                cpx #16
                bne dliloop
                lda #1
                sta TABLEFLAG
decrease        dex
                dex
                bpl dliloop
*/
dliexit         pla
                tax
                pla
                tay
                pla
                rti

                org $2400

DLIST           .byte 112, 112, 112+128
                .byte 6+64
                .word textline1
                .byte 128
DLISTGEN
                org DLISTGEN+ROWSIZE*ROWS
                .byte 6+64
                .word textline2
                .byte 65
                .word DLIST

TILE            .byte $00
/*
                .byte $ff,$ff,$f0
                .byte $ee,$ee,$e0
                .byte $dd,$dd,$d0
                .byte $cc,$cc,$c0
                .byte $bb,$bb,$b0
                .byte $aa,$aa,$a0
                .byte $99,$99,$90
                .byte $88,$88,$80
                .byte $77,$77,$70
                .byte $66,$66,$60
                .byte $55,$55,$50
                .byte $44,$44,$40
                .byte $33,$33,$30
*/
;                .byte $22,$22,$20
;                .byte $11,$11,$10

ENDTILE = TILE+(ENDPALETTELIST-PALETTELIST)*3

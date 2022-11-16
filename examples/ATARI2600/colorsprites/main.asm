/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Fcolorsprites.a&platform=vcs#

    We can draw a color sprite by setting two registers
    on every scanline:
    GRP0 (the bitmap) and COLUP0 (the player color).
    There's a separate lookup table for each.
*/

//=============================================================================

                icl '..\vcs.h'
                opt f+h-

//=============================================================================

CARADR          = $f000
CARVEC          = CARADR+$ffc

spriteHeight    = 8

.zpvar          = $80
.zpvar yPos     .byte       

//=============================================================================

                org CARADR

//=============================================================================

start           INIT_SYSTEM

                mva #5 yPos

mainLoop        lsr SWCHB               ; test Game Reset switch
                bcc start               ; reset?

                VERTICAL_SYNC           ; 1 + 3 lines of VSYNC

                WAIT_X_SCANLINES 37     ; 37 lines of underscan
                
                ldx #192                ; X = 192 scanlines
lvScan          txa                     ; X -> A
                sec                     ; set carry for subtract
                sbc yPos                ; local coordinate
                cmp #spriteHeight       ; in sprite?
                bcc inSprite            ; yes, skip over next
                lda #0                  ; not in sprite, load 0
inSprite        tay		                ; local coord -> Y
                lda dataframe0,y        ; lookup color
                W_SYNC                  ; sync w/ scanline
                sta GRP0                ; store bitmap
                lda colorFrame0,y       ; lookup color
                sta COLUP0              ; store color
                dex
                bne lvScan
                
                WAIT_X_SCANLINES 29     ; 29 lines of overscan             

                jmp mainLoop            ; total = 262 lines, go to next frame

//=============================================================================

dataframe0                              ; Cat-head graphics data
    .by 0                               ; zero padding, also clears register
    .by %00111100
    .by %01000010
    .by %11100111
    .by %11111111
    .by %10011001
    .by %01111110
    .by %11000011
    .by %10000001   

colorFrame0                             ; Cat-head color data
    .by 0                               ; unused (for now)
    .he AE
    .he AC
    .he A8
    .he AC
    .he 8E
    .he 8E
    .he 98
    .he 94

//=============================================================================

                org	CARVEC
                
                .word start     ; reset vector
                .word start     ; interrupt vector at $fffe (unused in VCS)                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================
/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Fsprite.a&platform=vcs#

    Sprites are a tricky beast on the 2600.
    You only have two of them.
    They are 8 bits wide and 1 bit high.
    There's no way to position the X or Y coordinate directly.
    To position X, you have to wait until the TIA clock hits a
    given X position and then write to a register to lock it in.
    To position Y, you simply wait until the desired scanline and
    set the bits of your sprite to a non-zero value.
    Having fun yet? :)
*/

//=============================================================================

                icl '..\vcs.h'
                opt f+h-

//=============================================================================

CARADR      = $f000
CARVEC      = CARADR+$ffc

counter     = $81

//=============================================================================

                org CARADR

//=============================================================================

start           INIT_SYSTEM

mainLoop        VERTICAL_SYNC           ; This macro efficiently gives us 1 + 3 lines of VSYNC

                WAIT_X_SCANLINES 36     ; 36 lines of VBLANK

                /*               
                    For the last VBLANK line, we'll lock in our sprites' X position.
                    The first one will be 20 TIA clocks from the left, plus whatever the
                    DEX and BNE instructions in the previous loop took.
                    There are 68 TIA clocks *before* the scanline starts, and there are
                    3 TIA clocks per CPU cycle, so counting clocks (or trial-and-error)
                    is neccessary to get exact positioning.
                */     
                #CYCLE #20              ; this macro hard-codes a 20 cycle delay (60 TIA clocks)
                sta RESP0               ; set position of sprite #1
                #CYCLE #35              ; wait 35 more cycles (105 TIA clocks)
                sta RESP1               ; set position of sprite #2
                
                /*
                    We'll draw both sprites all the way down the screen
                */
                ldx #192                ; Draw the 192 scanlines
                lda #0                  ; changes every scanline
                ldy counter             ; changes every frame
@               W_SYNC                  ; wait for next scanline
                sta COLUBK              ; set the background color
                sta GRP0                ; set sprite 0 pixels
                sta GRP1                ; set sprite 1 pixels
                adc #1                  ; increment A to cycle through colors and bitmaps
                dex
                bne @-
                
                /*
                    Clear the background color and sprites before overscan
                    (We don't need to use VBLANK neccessarily...)
                */
                stx COLUBK
                stx GRP0
                stx GRP1

                WAIT_X_SCANLINES 30     ; 30 lines of overscan

                inc counter             ; Cycle the sprite colors for the next frame
                lda counter
                sta COLUP0
                sta COLUP1                

                jmp mainLoop            ; Go back and do another frame

//=============================================================================

                org	CARVEC
                
                .word start     ; reset vector
                .word start     ; interrupt vector at $fffe (unused in VCS)                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================
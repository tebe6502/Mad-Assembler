/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Ftiming2.a&platform=vcs#

    We're going to use a more clever way to position sprites
    ("players") which relies on additional TIA features.
    Because the CPU timing is 3 times as coarse as the TIA's,
    we can only access 1 out of 3 possible positions using
    CPU delays alone.
    Additional TIA registers let us nudge the final position
    by discrete TIA clocks and thus target all 160 positions.

    QUESTION: What if you don't set the fine offset?
    QUESTION: What if you don't set the coarse offset?    
*/

//=============================================================================

                icl '..\vcs.h'
                opt f+h-

//=============================================================================

CARADR          = $f000
CARVEC          = CARADR+$ffc

.zpvar          = $80
.zpvar counter  .byte       

//=============================================================================

                org CARADR

//=============================================================================

start           INIT_SYSTEM

mainLoop        VERTICAL_SYNC

                WAIT_X_SCANLINES 34     ; 34 lines of VBLANK

                /*
                    Instead of representing the horizontal position in CPU clocks,
                    we're going to use TIA clocks.
                */
                lda counter             ; load the counter as horizontal position
                and #$7f                ; force range to (0-127)         

                /*              
                    We're going to divide the horizontal position by 15.
                    The easy way on the 6502 is to subtract in a loop.
                    Note that this also conveniently adds 5 CPU cycles
                    (15 TIA clocks) per iteration.
                */
                W_SYNC                  ; 35th line
                HM_CLR                  ; reset the old horizontal position
divideLoop      sbc #15                 ; subtract 15
                bcs divideLoop          ; branch until negative

                /*
                    A now contains (the remainder - 15).
                    We'll convert that into a fine adjustment, which has
                    the range -8 to +7.
                */
                eor #7
            :4  asl                     ; HMOVE only uses the top 4 bits, so shift by 4
                sta HMP0                ; The fine offset goes into HMP0

                /*
                    Now let's fix the coarse position of the player, which as you
                    remember is solely based on timing. If you rearrange any of the
                    previous instructions, position 0 won't be exactly on the left side.
                */
                RES_P0

                /*                
                    Finally we'll do a WSYNC followed by HMOVE to apply the fine offset.
                */
                W_SYNC                  ; 36th line
                H_MOVE                  ; apply offset

                /*
                    We'll see this method again, and it can be made into a subroutine
                    that works on multiple objects.
                */

                /*
                    Now draw the 192 scanlines, drawing the sprite.
                    We've already set its horizontal position for the entire frame,
                    but we'll try to draw something real this time, some digits
                    lifted from another game.
                */
                ldx #192                
                lda #0                  ; changes every scanline
                ldy #0                  ; sprite data index                
lvScan          W_SYNC                  ; wait for next scanline
                sty COLUBK              ; set the background color
                mva numbers,y GRP0      ; set sprite 0 pixels
                iny
                cpy #60
                scc:ldy #0
                dex
                bne lvScan

                /*               
                    Clear the background color and sprites before overscan
                */
                stx COLUBK
                stx GRP0

                WAIT_X_SCANLINES 30     ; 30 lines of overscan             

                /*
                    Cycle the sprite colors for the next frame
                */
                inc counter
                mva counter COLUP0

                jmp mainLoop            ; total = 262 lines, go to next frame

//=============================================================================

/*
    Bitmap pattern for digits
    w:8,h:6,count:10,brev:1
*/
numbers
    .he EE AA AA AA EE 00
    .he 22 22 22 22 22 00
    .he EE 22 EE 88 EE 00
    .he EE 22 66 22 EE 00
    .he AA AA EE 22 22 00
    .he EE 88 EE 22 EE 00
    .he EE 88 EE AA EE 00
    .he EE 22 22 22 22 00
    .he EE AA EE AA EE 00
    .he EE AA EE 22 EE 00

//=============================================================================

                org	CARVEC
                
                .word start     ; reset vector
                .word start     ; interrupt vector at $fffe (unused in VCS)                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================
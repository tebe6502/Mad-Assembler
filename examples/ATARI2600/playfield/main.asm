/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Fplayfield.a&platform=vcs#

    We're going to mess with the playfield registers, PF0, PF1 and PF2.
    Between them, they represent 20 bits of bitmap information
    which are replicated over 40 wide pixels for each scanline.
    By changing the registers before each scanline, we can draw bitmaps.
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
               
                stx VBLANK              ; Disable VBLANK, X = 0

                mva #$82 COLUPF         ; Set foreground color

                ldx #192                ; Draw the 192 scanlines
                lda #0                  ; changes every scanline
                lda counter             ; uncomment to scroll!
scanLoop        W_SYNC                  ; wait for next scanline
                sta PF0                 ; set the PF1 playfield pattern register
                sta PF1                 ; set the PF1 playfield pattern register
                sta PF2                 ; set the PF2 playfield pattern register
                stx COLUBK              ; set the background color
                adc #1                  ; increment A
                dex
                bne scanLoop

                mva #2 VBLANK           ; Reenable VBLANK for bottom (and top of next frame)

                WAIT_X_SCANLINES 30     ; 30 lines of overscan

                inc counter

                jmp mainLoop            ; Go back and do another frame

//=============================================================================

                org	CARVEC
                
                .word start     ; reset vector
                .word start     ; interrupt vector at $fffe (unused in VCS)                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================
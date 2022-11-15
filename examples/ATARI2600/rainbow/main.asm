/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Fvsync.a&platform=vcs

    Now we're going to drive the TV signal properly.
    Assuming NTSC standards, we need the following:
    - 3 scanlines of VSYNC
    - 37 blank lines
    - 192 visible scanlines
    - 30 blank lines

    We'll use the VSYNC register to generate the VSYNC signal,
    and the VBLANK register to force a blank screen above
    and below the visible frame (it'll look letterboxed on
    the emulator, but not on a real TV)
*/

//=============================================================================

                icl '..\vcs.h'
                opt f+h-

//=============================================================================

/*
    Let's define a variable to hold the starting color
    at memory address $81
*/
bg_color    = $81

//=============================================================================

                org $f000

//=============================================================================

start           INIT_SYSTEM

mainLoop        mva #2 VBLANK           ; Enable VBLANK (disable output)

                sta VSYNC               ; At the beginning of the frame we set the VSYNC bit...

            :3  W_SYNC                  ; And hold it on for 3 scanlines...

                mva #0 VSYNC            ; Now we turn VSYNC off.

                WAIT_X_SCANLINES 37     ; Now we need 37 lines of VBLANK...

                mva #0 VBLANK           ; Re-enable output (disable VBLANK)

                ldx #192                ; 192 scanlines are visible
                lda bg_color
@               adc #1
                sta COLUBK              ; set the background color
                W_SYNC                  ; WSYNC doesn't care what value is stored
                dex
                bne @-

                mva #2 VBLANK           ; Enable VBLANK again

                WAIT_X_SCANLINES 30     ; 30 lines of overscan to complete the frame

                /*
                    The next frame will start with current color value - 1
                    to get a downwards scrolling effect
                */                
                dec bg_color

                jmp mainLoop    ; Go back and do another frame

//=============================================================================

                org	$fffc
                
                .word start     ; reset vector
                .word start     ; break vector                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================
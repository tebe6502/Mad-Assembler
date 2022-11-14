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

                opt f+h-

//=============================================================================

/*
    dasm atari2600/vcs.h
*/
VSYNC       = $00 ; 0000 00x0   Vertical Sync Set-Clear
VBLANK      = $01 ; xx00 00x0   Vertical Blank Set-Clear
WSYNC       = $02 ; ---- ----   Wait for Horizontal Blank
COLUBK      = $09 ; xxxx xxx0   Color-Luminance Background

//=============================================================================

/*
    Let's define a variable to hold the starting color
    at memory address $81
*/
bg_color    = $81

//=============================================================================

/*
    Stack, TIA and RAM share the same place on ZP

    Standardised start-up code, clears stack, all TIA registers and RAM to 0
    Sets stack pointer to $FF, and all registers to 0
    Sets decimal mode off, sets interrupt flag (kind of un-necessary)
    Use as very first section of code on boot (ie: at reset)
*/
.macro INIT_SYSTEM
    sei
    cld
    ldx #$ff
    txs
    inx
    txa
    sta:rne 0,x+
.endm

//=============================================================================

                org $f000

//=============================================================================

start           INIT_SYSTEM

mainLoop        mva #2 VBLANK   ; Enable VBLANK (disable output)

                sta VSYNC       ; At the beginning of the frame we set the VSYNC bit...

            :3  sta WSYNC       ; And hold it on for 3 scanlines...

                mva #0 VSYNC    ; Now we turn VSYNC off.

                ldx #37         ; Now we need 37 lines of VBLANK...
@               sta WSYNC       ; accessing WSYNC stops the CPU until next scanline
                dex
                bne @-

                mva #0 VBLANK   ; Re-enable output (disable VBLANK)

                ldx #192        ; 192 scanlines are visible
                lda bg_color
@               adc #1
                sta COLUBK      ; set the background color
                sta WSYNC       ; WSYNC doesn't care what value is stored
                dex
                bne @-

                mva #2 VBLANK   ; Enable VBLANK again

                ldx #30         ; 30 lines of overscan to complete the frame
@               sta WSYNC
                dex
                bne @-

                /*
                    The next frame will start with current color value - 1
                    to get a downwards scrolling effect
                */                
                dec bg_color

                jmp mainLoop    ; Go back and do another frame

//=============================================================================

                org	$fffc

//=============================================================================

                .word start     ; reset vector
                .word start     ; break vector                

//=============================================================================                
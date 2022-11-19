/*
    Example taken from:
    https://8bitworkshop.com/v3.10.0/?file=examples%2Fmissiles.a&platform=vcs#

    Besides the two 8x1 sprites ("players") the TIA has
    two "missiles" and one "ball", which are just variable-length
    dots or dashes. They have similar positioning and display
    requirements, so we're going to make a subroutine that can
    set the horizontal position of any of them.
    But we can also use the HMPx/HMOVE registers directly to move the
    objects by small offsets without using this routine every time.    
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

start           INIT_SYSTEM             ; Initialize and set initial offsets of objects.
                lda #10
                ldx #0
                jsr setHorizPos         ; set player 0 horiz. pos
                inx
                lda #130
                jsr setHorizPos         ; set player 1 horiz. pos
                inx
                lda #40
                jsr setHorizPos         ; set missile 0 horiz. pos
                mva #$10 NUSIZ0         ; make missile 0 2x-wide
                inx
                lda #70
                jsr setHorizPos         ; set missile 1 horiz. pos
                mva #$20 NUSIZ1         ; make missile 1 4x-wide
                inx
                lda #100
                jsr setHorizPos         ; set ball horiz. pos
                mva #$30 CTRLPF         ; set ball 8x-wide
                W_SYNC
                H_MOVE

/*
    We've technically generated an invalid frame because
    these operations have generated superfluous WSYNCs.
    But it's just at the beginning of our program, so whatever.
*/

mainLoop        VERTICAL_SYNC           ; Next frame loop

                WAIT_X_SCANLINES 36     ; 36 lines of VBLANK

                /*
                    Draw 192 scanlines
                    We're going to draw both players, both missiles, and the ball
                    straight down the screen. We can draw various kinds of vertical
                    lines this way.                
                */           
                ldx #192
                stx COLUBK              ; set the background color
                lda #0                  ; A changes every scanline
                ldy #0                  ; Y is sprite data index
lvScan          W_SYNC                  ; wait for next scanline
                lda numbers,y
                sta GRP0                ; set sprite 0 pixels
                sta GRP1                ; set sprite 1 pixels
                tya                     ; we'll use the Y position, only the 2nd bit matters
                sta ENAM0               ; enable/disable missile 0
                sta ENAM1               ; enable/disable missile 1
                sta ENABL               ; enable/disable ball
                iny
                cpy #60
                sne:ldy #0              ; wrap Y at 60 to 0
                dex
                bne lvScan              ; repeat next scanline until finished

                /*	
                    Clear all colors to black before overscan
                */
                stx COLUBK
                stx COLUP0
                stx COLUP1
                stx COLUPF

                WAIT_X_SCANLINES 36     ; 30 lines of overscan

                /*
                    Move all the objects by a different offset using HMP/HMOVE registers
                    We'll hard-code the offsets in a table for now
                */
                ldx #0
hmoveloop       lda movement,x
                sta HMCLR
                sta HMP0,x
                W_SYNC
                H_MOVE
                inx
                cpx #5
                bcc hmoveloop           ; This loop also gave us 5 extra scanlines = 30 total

                /*
                    Cycle the sprite colors for the next frame
                */
                inc counter
                mva counter COLUP0
                clc
                ror
                sta COLUP1
                clc
                ror
                sta COLUPF                

                jmp mainLoop            ; total = 262 lines, go to next frame

//=============================================================================

/*
    SetHorizPos - Sets the horizontal position of an object.
    The X register contains the index of the desired object:
        X=0: player 0
        X=1: player 1
        X=2: missile 0
        X=3: missile 1
        X=4: ball
    This routine does a WSYNC and HMOVE before executing,
    so whatever you do here will not take effect until you
    call the routine again or do your own WSYNC and HMOVE.
*/
setHorizPos     W_SYNC                  ; start a new line
                H_MOVE                  ; apply the previous fine position(s)
                HM_CLR                  ; reset the old horizontal position(s)
                sec                     ; set carry flag
@               sbc #15                 ; subtract 15
                bcs @-                  ; branch until negative
                eor #7                  ; calculate fine offset
            :4  asl
                sta RESP0,x             ; fix coarse position
                sta HMP0,x              ; set fine offset
                rts                     ; return to caller

//=============================================================================

/*
    Hard-coded  values for movement registers
*/
movement
    .he F0 ; +1 pixels
    .he E0 ; +2 pixels
    .he C0 ; +4 pixels
    .he 10 ; -1 pixels
    .he 20 ; -2 pixels

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
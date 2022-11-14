                opt f+h-

//==============================================================

VSYNC       = $00 ; 0000 00x0   Vertical Sync Set-Clear
VBLANK      = $01 ; xx00 00x0   Vertical Blank Set-Clear
WSYNC       = $02 ; ---- ----   Wait for Horizontal Blank
COLUBK      = $09 ; xxxx xxx0   Color-Luminance Background

//==============================================================

bg_color    = $81

//==============================================================

                org $f000

start           sei
                cld
                ldx #0
                txa
                tay
@               dex
                txs
                pha
                bne @-

mainloop        lda #2
                sta VBLANK
                lda #2
                sta VSYNC

                sta WSYNC
                sta WSYNC
                sta WSYNC

                lda #0
                sta VSYNC

                ldx #37
@               sta WSYNC
                dex
                bne @-

                lda #0
                sta VBLANK


                ldx #192
                lda bg_color

@               adc #1		
                sta COLUBK	
                sta WSYNC
                dex
                bne @-

                lda #2
                sta VBLANK

                ldx #30
@               sta WSYNC
                dex
                bne @-

                dec bg_color

                jmp mainloop

//==============================================================

                org	$fffc

                .word start     ; reset vector
                .word start     ; break vector                
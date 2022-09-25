; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************

joy1up              dta $ff
joy1down            dta $ff
joy1left            dta $ff
joy1right           dta $ff
joy1fire            dta $ff
joy1fire_released   dta $ff ; 1 joyfire released

;*******************************************
;* Reads joystick status into joy1 locations
;* bit 7 is current state of joystick
;* bit 7 is 1 when joystick not moved
;*          0 when joystick is moved or fired
;*******************************************
readjoy     lda STICK0
            lsr
            ror joy1up
            lsr
            ror joy1down
            lsr
            ror joy1left
            lsr
            ror joy1right
            lda TRIG0
            lsr
            ror joy1fire

; check for joy1 fire release
            ldx #0
            lda joy1fire
            and #%11000000
            cmp #%10000000
            bne @+
            ldx #1
@
            stx joy1fire_released

            rts

;******************************************************************
last_key_pressed    .byte 0
key_pressed         .byte $ff

key_released        .byte 0

read_keyboard
                    lda KBCODE
                    sta last_key_pressed
                    
                    lda SKSTAT
                    and #4
                    lsr
                    lsr
                    lsr
                    ror key_pressed
                    
; check for key release
                    ldx #0
                    lda key_pressed
                    and #%11000000
                    cmp #%10000000
                    bne @+
                    ldx #1
@
                    stx key_released
        
                    rts
    
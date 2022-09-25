; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************

nmi_handler     bit NMIST
                bpl nmi_not_dli
                bmi dli_handler
nmi_not_vbi     lda #%00100000
                bit NMIST
                bne nmi_not_reset
                sta nmires
                rti
nmi_not_reset   pla
                rti
nmi_not_dli     pha
                bvc nmi_not_vbi
                txa
                pha
                tya
                pha
                sta NMIRES
vbi_handler_jmp jmp vbi_handler

dli_handler     sta ACC
                ; stx REGX
                sty REGY
                
                ldy dli_index
lab_lda_chrset
                lda chr_pointers1,y
                sta WSYNC
                sta CHBASE
                inc dli_index
                
                cpy #24
                beq last_dli_irq
                
                lda ACC
                ldy REGY
                rti
last_dli_irq
.ifdef          VBICOLORIZE
                STA WSYNC
                MVA #color_Cyan COLBK
                STA WSYNC
                MVA #color_Black COLBK
.endif
                lda frame_counter
                ora max_frame
                sta max_frame
                asl frame_counter

                lda buffer_rendered
                bne need_to_switch
                jmp skip_switching
need_to_switch
                lda #1
                sta frame_counter
                lda #0
                sta buffer_rendered

; switch char buffer pointer
; and table address for loading charset address in display interrupt
                lda char_buffer
                ;eor #((>charbase)^(>(charbase+$400)))
                eor #CHARSET_EOR
                sta char_buffer

                lda lab_lda_chrset+2
                eor #>(chr_pointers1 ^ chr_pointers2)
                sta lab_lda_chrset+2

; put new screen address into Display list
                lda screen_buffer
                ;sta DLIST_SCREEN+2

; switch screen buffer to buffer not currently showed
                eor #((>(EKR1+$03f0))^(>(EKR2+$03f0)))
                sta screen_buffer

                ldx current_dlist
                lda tab_dlist_lo,x
                sta DLISTL
                lda tab_dlist_hi,x
                sta DLISTH
                lda current_dlist
                eor #1
                sta current_dlist
                
                lda #1
                sta buffer_switched

                dec scroll_value
                lda scroll_value
                cmp #255
                bne skip_inc_scroll_value
                dec scroll_value+1
skip_inc_scroll_value
                lda scroll_value
                and #15
                sta HSCROL
                cmp #0
                bne skip_scroll_screen
                
                ;lda #$FF
                ;sta COLBK

                ldx #3
loop_scroll_screen_row_copy
                lda back_row+0*48+0,x
                sta back_row+0*48+44,x
                lda back_row+1*48+0,x
                sta back_row+1*48+44,x
                lda back_row+2*48+0,x
                sta back_row+2*48+44,x
                lda back_row+3*48+0,x
                sta back_row+3*48+44,x
                lda back_row+4*48+0,x
                sta back_row+4*48+44,x

                dex
                bpl loop_scroll_screen_row_copy



                ldx #0
loop_scroll_screen_row
                lda back_row+0*48+4,x
                sta back_row+0*48+0,x
                lda back_row+1*48+4,x
                sta back_row+1*48+0,x
                lda back_row+2*48+4,x
                sta back_row+2*48+0,x
                lda back_row+3*48+4,x
                sta back_row+3*48+0,x
                lda back_row+4*48+4,x
                sta back_row+4*48+0,x

                inx
                cpx #44
                bne loop_scroll_screen_row
                ;lda #0
                ;sta COLBK
skip_scroll_screen

skip_switching


                lda ACC
                ldy REGY
                rti
                
vbi_handler0    
                lda #%11000000
                sta NMIEN
                
                pla
                tay
                pla
                tax
                pla
                rti

vbi_handler     sei
                
                lda #0
                sta dli_index

;                MVA #color_Cyan COLBK
.ifdef          PLAYMUSIC
                jsr music_play  ;normal music play (second of two per frame)
.endif
;                MVA #color_Black COLBK
                
                lda #%11000000
                sta NMIEN
                
                pla
                tay
                pla
                tax
                pla
                rti

                

.align 256
chr_pointers1   .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)
                .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)
                .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)
                .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)
                .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)
                .byte >charbase
                .byte >(charbase+$0400)
                .byte >(charbase+$0800)
                .byte >(charbase+$0c00)

.align 256
chr_pointers2   .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
                .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
                .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
                .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
                .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
                .byte >charbase2
                .byte >(charbase2+$0400)
                .byte >(charbase2+$0800)
                .byte >(charbase2+$0c00)
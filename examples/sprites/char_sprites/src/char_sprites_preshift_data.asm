; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************


;*******************************
;* a - x coord                 *
;* x - y coord                 *
;* y - sprite no               *
;* pom - sprite def no         *
;* screen_buffer - bufer ad hi *
;* char_buffer - bufer ad hi   *
;*******************************
drawsoftsprite_new          sta sprx ;ad - adress of sprite definition
                            stx spry
                            txa
                            and #7
                            sta yand7        ;pom1=spry and 7
                            
                            sty sprno
                            
;;;;; set up c0,c1,c2,c3
                            txa             
                            lsr
                            lsr
                            lsr
                            tax             ;y = spry/8 (y coord in chars)
                            
;calculate character address where sprite is drawn into
; char row 0
                            clc             ; clean C flag from lsr
                            
                            lda tabl32_00,y
                            sta c00
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_00,y
                            sta c00+1
                            
                            clc
                            lda tabl32_10,y
                            sta c10
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_10,y
                            sta c10+1

                            clc
                            lda tabl32_20,y
                            sta c20
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_20,y
                            sta c20+1

                            clc
                            lda tabl32_30,y
                            sta c30
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_30,y
                            sta c30+1
                            
                            inx
; char row 1
                            clc
                            lda tabl32_01,y
                            sta c01
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_01,y
                            sta c01+1
                            
                            clc
                            lda tabl32_11,y
                            sta c11
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_11,y
                            sta c11+1

                            clc
                            lda tabl32_21,y
                            sta c21
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_21,y
                            sta c21+1

                            clc
                            lda tabl32_31,y
                            sta c31
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_31,y
                            sta c31+1
                            
                            inx
; char row 2
                            clc
                            lda tabl32_02,y
                            sta c02
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_02,y
                            sta c02+1

                            clc
                            lda tabl32_12,y
                            sta c12
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_12,y
                            sta c12+1

                            clc
                            lda tabl32_22,y
                            sta c22
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_22,y
                            sta c22+1

                            clc
                            lda tabl32_32,y
                            sta c32
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_32,y
                            sta c32+1
                            
                            inx
; char row 3
                            clc
                            lda tabl32_03,y
                            sta c03
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_03,y
                            sta c03+1

                            clc
                            lda tabl32_13,y
                            sta c13
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_13,y
                            sta c13+1

                            clc
                            lda tabl32_23,y
                            sta c23
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_23,y
                            sta c23+1

                            clc
                            lda tabl32_33,y
                            sta c33
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh32_33,y
                            sta c33+1


;calculate sprite definition address  (sprdefno*768 (192*4 shifts))                            
                            ;ignore sprite number in pom for now...

                            lda sprx        ;sprx and 3 is shift value
                            and #3
                            tax
                            
                            lda tab_sprdef_lo,x     ;ad=sprdef+(192*sprdefno)
                            sta sprad0              ;sprdef_vertical is where
                            lda tab_sprdef_hi,x     ;sprite shapes in vertical byte layout
                            sta sprad0+1            ;are loaded

                            sec                         ;sprite ad=sprad - y and 7
                            lda sprad0
                            sbc yand7
                            sta sprad0
                            lda sprad0+1
                            sbc #0
                            sta sprad0+1
                            
                            clc                         ;sprad1 = sprad0+24
                            lda sprad0
                            adc #24
                            sta sprad1
                            lda sprad0+1
                            adc #0
                            sta sprad1+1
                            
                            clc                         ;sprad2 = sprad1+24
                            lda sprad1
                            adc #24
                            sta sprad2
                            lda sprad1+1
                            adc #0
                            sta sprad2+1

                            clc                         ;sprad3 = sprad2+24
                            lda sprad2
                            adc #24
                            sta sprad3
                            lda sprad2+1
                            adc #0
                            sta sprad3+1

                            clc                         ;mskad0 = sprad3+24
                            lda sprad3
                            adc #24
                            sta mskad0
                            lda sprad3+1
                            adc #0
                            sta mskad0+1

                            clc                         ;mskad1 = mskad0+24
                            lda mskad0
                            adc #24
                            sta mskad1
                            lda mskad0+1
                            adc #0
                            sta mskad1+1

                            clc                         ;mskad2 = mskad1+24
                            lda mskad1
                            adc #24
                            sta mskad2
                            lda mskad1+1
                            adc #0
                            sta mskad2+1

                            clc                         ;mskad3 = mskad2+24
                            lda mskad2
                            adc #24
                            sta mskad3
                            lda mskad2+1
                            adc #0
                            sta mskad3+1

;;;;; set b0,b1,b2,b3
;;;;; starts with "b00" at $A0 $A1
;;;;; lo-hi bytes up to "b33" at $BE and $BF

;;;;; set jmp in address and RTS position

                            ldy yand7
                            lda tab_rendersprite_rts_lo,y
                            sta rendersprite_set_rts+1
                            sta rendersprite_set_iny+1
                            lda tab_rendersprite_rts_hi,y
                            sta rendersprite_set_rts+2
                            sta rendersprite_set_iny+2
                            
                            lda tab_rendersprite_jmp_lo,y
                            sta rendersprite_jmp+1 
                            lda tab_rendersprite_jmp_hi,y
                            sta rendersprite_jmp+2
                            
                            lda #$60    ;RTS code is $60
rendersprite_set_rts        sta $FFFF

rendersprite_jmp            jsr $FFFF
                            jsr rendersprite2

                            lda #$C8    ;INY code is $C8
rendersprite_set_iny        sta $FFFF

                            rts

rendersprite
.rept 8
                            lda (b00),y
                            and (mskad0),y
                            ora (sprad0),y
                            sta (c00),y
                            
                            lda (b10),y
                            and (mskad1),y
                            ora (sprad1),y
                            sta (c10),y
                            
                            lda (b20),y
                            and (mskad2),y
                            ora (sprad2),y
                            sta (c20),y
                            
                            lda (b30),y
                            and (mskad3),y
                            ora (sprad3),y
                            sta (c30),y
                            
                            iny
.endr
.rept 8
                            lda (b01),y
                            and (mskad0),y
                            ora (sprad0),y
                            sta (c01),y
                            
                            lda (b11),y
                            and (mskad1),y
                            ora (sprad1),y
                            sta (c11),y
                            
                            lda (b21),y
                            and (mskad2),y
                            ora (sprad2),y
                            sta (c21),y
                            
                            lda (b31),y
                            and (mskad3),y
                            ora (sprad3),y
                            sta (c31),y
                            
                            iny
.endr
.rept 8
                            lda (b02),y
                            and (mskad0),y
                            ora (sprad0),y
                            sta (c02),y
                            
                            lda (b12),y
                            and (mskad1),y
                            ora (sprad1),y
                            sta (c12),y
                            
                            lda (b22),y
                            and (mskad2),y
                            ora (sprad2),y
                            sta (c22),y
                            
                            lda (b32),y
                            and (mskad3),y
                            ora (sprad3),y
                            sta (c32),y
                            
                            iny
.endr
.rept 8
                            lda (b03),y
                            and (mskad0),y
                            ora (sprad0),y
                            sta (c03),y
                            
                            lda (b13),y
                            and (mskad1),y
                            ora (sprad1),y
                            sta (c13),y
                            
                            lda (b23),y
                            and (mskad2),y
                            ora (sprad2),y
                            sta (c23),y
                            
                            lda (b33),y
                            and (mskad3),y
                            ora (sprad3),y
                            sta (c33),y
                            
                            iny
.endr

; --------------------------------------------------------------------------------------
; call this somehow to copy upper and bottom part of sprite without mask and sprite data
; --------------------------------------------------------------------------------------
rendersprite2

                            ldy yand7
                            beq skip_render_sprite_top_part
                            
                            dey
render_sprite_top_part
                            lda (b00),y
                            sta (c00),y
                            lda (b10),y
                            sta (c10),y
                            lda (b20),y
                            sta (c20),y
                            lda (b30),y
                            sta (c30),y
                            
                            dey
                            bpl render_sprite_top_part

skip_render_sprite_top_part
                            ldy #31
                            
                            lda yand7
                            clc
                            adc #23
                            sta yand7

render_sprite_bottom_part
                            lda (b03),y
                            sta (c03),y
                            lda (b13),y
                            sta (c13),y
                            lda (b23),y
                            sta (c23),y
                            lda (b33),y
                            sta (c33),y
                            
                            dey
                            cpy yand7
                            bne render_sprite_bottom_part
                            
                            rts
;----------------------------------------------


.align
tab_rendersprite_rts_lo                     ;RTS is at end of one of 8 (out of 24) last render blocks
:8     DTA l(rendersprite + 33*23 + 32 + 33*#)

tab_rendersprite_rts_hi
:8     DTA h(rendersprite + 33*23 + 32 + 33*#)

tab_rendersprite_jmp_lo                     ;JMP into begining of one of 8 blocks
:8     DTA l(rendersprite + 33*#)

tab_rendersprite_jmp_hi
:8     DTA h(rendersprite + 33*#)

; tables for row 0
tabl32_00
:8          DTA l(32*#)
tabh32_00
:8          DTA h(32*#)

tabl32_01
:8          DTA l(32*#-8)
tabh32_01
:8          DTA h(32*#-8)

tabl32_02
:8          DTA l([32*#]-16)
tabh32_02
:8          DTA h([32*#]-16)

tabl32_03
:8          DTA l([32*#]-24)
tabh32_03
:8          DTA h([32*#]-24)

; tables for row 1
tabl32_10
:8          DTA l([32*#]+8)
tabh32_10
:8          DTA h([32*#]+8)

tabl32_11
:8          DTA l(32*#)
tabh32_11
:8          DTA h(32*#)

tabl32_12
:8          DTA l([32*#]-8)
tabh32_12
:8          DTA h([32*#]-8)

tabl32_13
:8          DTA l([32*#]-16)
tabh32_13
:8          DTA h([32*#]-16)

; tables for row 2
tabl32_20
:8          DTA l([32*#]+16)
tabh32_20
:8          DTA h([32*#]+16)

tabl32_21
:8          DTA l([32*#]+8)
tabh32_21
:8          DTA h([32*#]+8)

tabl32_22
:8          DTA l([32*#])
tabh32_22
:8          DTA h([32*#])

tabl32_23
:8          DTA l([32*#]-8)
tabh32_23
:8          DTA h([32*#]-8)

; tables for row 3
tabl32_30
:8          DTA l([32*#]+24)
tabh32_30
:8          DTA h([32*#]+24)

tabl32_31
:8          DTA l([32*#]+16)
tabh32_31
:8          DTA h([32*#]+16)

tabl32_32
:8          DTA l([32*#]+8)
tabh32_32
:8          DTA h([32*#]+8)

tabl32_33
:8          DTA l([32*#])
tabh32_33
:8          DTA h([32*#])


tab_cy_hi   .byte $00,$04,$08,$0C           ;table for charset offset per screen row
            .byte $00,$04,$08,$0C
            .byte $00,$04,$08,$0C
            .byte $00,$04,$08,$0C
            .byte $00,$04,$08,$0C
            .byte $00,$04,$08,$0C
            .byte $00

/*
;*******************************
;* ekr+y - screen address      *
;* char_buffer - bufer ad hi   *
;* returns address in:         *
;* a - lo byte of char address *
;* x - hi byte of char address *
;* Destroyes y !!!             *
;*******************************
calc_char_address           lda (ek),y
                            and #127
                            tay
                            lda tabh8,y
                            ;clc
                            adc char_buffer
                            adc tab_cy_hi 
                            tax
                            lda tabl8,y
                            rts
*/


/*
tab_8_yand7     .byte 8,7,6,5,4,3,2,1   ;table for calculating: 8-yand7
                                        ;counter counts on which byte of character we are

                                        ;bit 7 of counter is used as flag in which part of character we are
tab_x_div_4     .byte 0,0,0,0
                .byte 1,1,1,1
                .byte 2,2,2,2
                .byte 3,3,3,3
                .byte 4,4,4,4
                .byte 5,5,5,5
                .byte 6,6,6,6
                .byte 7,7,7,7
                .byte 8,8,8,8
                .byte 9,9,9,9
                .byte 10,10,10,10
                .byte 11,11,11,11
                .byte 12,12,12,12
                .byte 13,13,13,13
                .byte 14,14,14,14
                .byte 15,15,15,15
                .byte 16,16,16,16
                .byte 17,17,17,17
                .byte 18,18,18,18
                .byte 19,19,19,19
                .byte 20,20,20,20
                .byte 21,21,21,21
                .byte 22,22,22,22
                .byte 23,23,23,23
                .byte 24,24,24,24
                .byte 25,25,25,25
                .byte 26,26,26,26
                .byte 27,27,27,27
                .byte 28,28,28,28
                .byte 29,29,29,29
                .byte 30,30,30,30
                .byte 31,31,31,31
                .byte 32,32,32,32
                .byte 33,33,33,33
                .byte 34,34,34,34
                .byte 35,35,35,35
                .byte 36,36,36,36
                .byte 37,37,37,37
                .byte 38,38,38,38
                .byte 39,39,39,39

tab_x_div_8     .byte 0,0,0,0,0,0,0,0
                .byte 1,1,1,1,1,1,1,1
                .byte 2,2,2,2,2,2,2,2
                .byte 3,3,3,3,3,3,3,3
                .byte 4,4,4,4,4,4,4,4
                .byte 5,5,5,5,5,5,5,5
                .byte 6,6,6,6,6,6,6,6
                .byte 7,7,7,7,7,7,7,7
                .byte 8,8,8,8,8,8,8,8
                .byte 9,9,9,9,9,9,9,9
                .byte 10,10,10,10,10,10,10,10
                .byte 11,11,11,11,11,11,11,11
                .byte 12,12,12,12,12,12,12,12
                .byte 13,13,13,13,13,13,13,13
                .byte 14,14,14,14,14,14,14,14
                .byte 15,15,15,15,15,15,15,15
                .byte 16,16,16,16,16,16,16,16
                .byte 17,17,17,17,17,17,17,17
                .byte 18,18,18,18,18,18,18,18
                .byte 19,19,19,19,19,19,19,19
                .byte 20,20,20,20,20,20,20,20
                .byte 21,21,21,21,21,21,21,21
                .byte 22,22,22,22,22,22,22,22
                .byte 23,23,23,23,23,23,23,23
                .byte 24,24,24,24,24,24,24,24
*/



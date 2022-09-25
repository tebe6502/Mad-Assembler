; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************


;**********************
; y - sprite no       *
;**********************
;----- Paragraph @Char sprite erase@ -----
;---------------------------------------------------
charspriteerase_2x2     sta pom1
                        sty pom2
                        stx pom3
        
        
                        lda charspritepx,y
                        ldx charspritepy,y
        
                        clc             ;ad=ekr+y*40+x
                        adc tabl40,x
                        sta ad
                        lda tabh40,x
                        adc screen_buffer
                        sta ad+1
                        clc
                        ldx #3
charspriteerase_2x2_2   lda #125
                        ldy #2
charspriteerase_2x2_1   sta (ad),y
                        dey
                        bpl charspriteerase_2x2_1
                        dex
                        beq charspriteerase_2x2_3
                        lda ad
                        adc #40
                        sta ad
                        bcc charspriteerase_2x2_4
                        inc ad+1
                        clc
charspriteerase_2x2_4   jmp charspriteerase_2x2_2
charspriteerase_2x2_3
                        lda pom1
                        ldy pom2
                        ldx pom3
                        rts


;**********************
;* a - x coord        *
;* x - y coord        *
;* y - sprite no...   *
;**********************
;----- Paragraph @Draw char sprite@ -----

drawcharsprite_2x2  sta pom1
                    sty pom2
                    stx pom3
    
                    lsr
                    lsr
                    sta ad
                    sta charspritepx,y
                    txa
                    lsr
                    lsr
                    lsr
                    sta charspritepy,y
                    tax
                    lda ad
                    clc             ;ad=ekr+y*40+x
                    adc tabl40,x
                    sta ad
                    lda tabh40,x
                    adc screen_buffer
                    sta ad+1
                
;---------------------------------
; calc charset bases for 4 rows of sprite.
; depends on charspritey and 3
;---------------------------------
                    txa
                    and #3
                    tax
                    ldy #0
@               
                    lda char_buffer
                    ora tab_spr_charsets_pattern,x
                    sta tab_spr_charsets,y
                    inx
                    iny
                    cpy #3  ; instead of 4 I guess
                    bne @-
;---------------------------------
; calc b00-b22 9 addresses for background chars
;---------------------------------
;---------------------------------
; calc b00-b02 4 addresses for background chars
;---------------------------------
                    ldy #0          ;draw column 0
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b00
                    lda tabh8,x
                    ora tab_spr_charsets+0
                    sta b00+1
                    
                    ldy #40
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b01
                    lda tabh8,x
                    ora tab_spr_charsets+1
                    sta b01+1
                    
                    ldy #80
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b02
                    lda tabh8,x
                    ora tab_spr_charsets+2
                    sta b02+1
    
;---------------------------------
; calc b10-b12 4 addresses for background chars
;---------------------------------
                    ldy #1          ;draw column 0
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b10
                    lda tabh8,x
                    ora tab_spr_charsets+0
                    sta b10+1
                    
                    ldy #41
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b11
                    lda tabh8,x
                    ora tab_spr_charsets+1
                    sta b11+1
                    
                    ldy #81
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b12
                    lda tabh8,x
                    ora tab_spr_charsets+2
                    sta b12+1
    
;---------------------------------
; calc b20-b22 4 addresses for background chars
;---------------------------------
                    ldy #2          ;draw column 0
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b20
                    lda tabh8,x
                    ora tab_spr_charsets+0
                    sta b20+1
                    
                    ldy #42
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b21
                    lda tabh8,x
                    ora tab_spr_charsets+1
                    sta b21+1
                    
                    ldy #82
                    lda (ad),y
                    tax
                    lda tabl8,x
                    sta b22
                    lda tabh8,x
                    ora tab_spr_charsets+2
                    sta b22+1
    
;--------------------------------
; correct row 1,2,3 addresses by subtractign 8,16
;--------------------------------
                    sec
                    lda b01
                    sbc #8
                    sta b01
                    bcs @+
                    dec b01+1
                    sec
@               
                    lda b11
                    sbc #8
                    sta b11
                    bcs @+
                    dec b11+1
                    sec
@               
                    lda b21
                    sbc #8
                    sta b21
                    bcs @+
                    dec b21+1
                    sec
@               
                    lda b02
                    sbc #16
                    sta b02
                    bcs @+
                    dec b02+1
                    sec
@               
                    lda b12
                    sbc #16
                    sta b12
                    bcs @+
                    dec b12+1
                    sec
@               
                    lda b22
                    sbc #16
                    sta b22
                    bcs @+
                    dec b22+1
                    ;sec
@               
                
;--------------------------------
; draw 0-15 chars into sprites place in screen ram
;--------------------------------
                    lda pom2
                    clc
                    asl             ;multiply with 3 to get first character code in sprite block
                    adc pom2
                    ldy #0          ;draw column 0
                    sta (ad),y
                    ldy #40
                    sta (ad),y
                    ldy #80
                    sta (ad),y
    
                    adc #1          ;next column
                    ldy #1
                    sta (ad),y
                    ldy #41
                    sta (ad),y
                    ldy #81
                    sta (ad),y
    
                    adc #1
                    ldy #2          ;draw column 2
                    sta (ad),y
                    ldy #42
                    sta (ad),y
                    ldy #82
                    sta (ad),y
    
                    lda pom1
                    ldy pom2
                    ldx pom3
                    rts


;*******************************
;* a - x coord                 *
;* x - y coord                 *
;* y - sprite no               *
;* pom - sprite def no         *
;* screen_buffer - bufer ad hi *
;* char_buffer - bufer ad hi   *
;*******************************
drawsoftsprite_new_2x2      sta sprx ;ad - adress of sprite definition
                            stx spry
                            txa
                            and #7
                            sta yand7        ;pom1=spry and 7
                            
                            sty sprno
                            
;;;;; set up c0,c1,c2
                            txa             
                            lsr
                            lsr
                            lsr
                            tax             ;y = spry/8 (y coord in chars)
                            
;calculate character address where sprite is drawn into
; char row 0
                            clc             ; clean C flag from lsr
                            
                            lda tabl24_00,y
                            sta c00
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_00,y
                            sta c00+1
                            
                            clc
                            lda tabl24_10,y
                            sta c10
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_10,y
                            sta c10+1

                            clc
                            lda tabl24_20,y
                            sta c20
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_20,y
                            sta c20+1
                            
                            inx
; char row 1
                            clc
                            lda tabl24_01,y
                            sta c01
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_01,y
                            sta c01+1
                            
                            clc
                            lda tabl24_11,y
                            sta c11
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_11,y
                            sta c11+1

                            clc
                            lda tabl24_21,y
                            sta c21
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_21,y
                            sta c21+1

                            inx
; char row 2
                            clc
                            lda tabl24_02,y
                            sta c02
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_02,y
                            sta c02+1

                            clc
                            lda tabl24_12,y
                            sta c12
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_12,y
                            sta c12+1

                            clc
                            lda tabl24_22,y
                            sta c22
                            lda tab_cy_hi,x     ;get charset offset for row Y
                            adc char_buffer    ;Add current buffers address
                            adc tabh24_22,y
                            sta c22+1

                            inx

;calculate sprite definition address  (sprdefno*768 (192*4 shifts))                            
                            ;ignore sprite number in pom for now...

                            lda sprx        ;sprx and 3 is shift value
                            and #3
                            tax
                            
                            lda tab_sprdef_lo_2x2,x     ;ad=sprdef+(192*sprdefno)
                            sta sprad0              ;sprdef_vertical is where
                            lda tab_sprdef_hi_2x2,x     ;sprite shapes in vertical byte layout
                            sta sprad0+1            ;are loaded

                            sec                         ;sprite ad=sprad - y and 7
                            lda sprad0
                            sbc yand7
                            sta sprad0
                            lda sprad0+1
                            sbc #0
                            sta sprad0+1
                            
                            clc                         ;sprad1 = sprad0+16
                            lda sprad0
                            adc #16
                            sta sprad1
                            lda sprad0+1
                            adc #0
                            sta sprad1+1
                            
                            clc                         ;sprad2 = sprad1+16
                            lda sprad1
                            adc #16
                            sta sprad2
                            lda sprad1+1
                            adc #0
                            sta sprad2+1

                            clc                         ;mskad0 = sprad2+16
                            lda sprad2
                            adc #16
                            sta mskad0
                            lda sprad2+1
                            adc #0
                            sta mskad0+1

                            clc                         ;mskad1 = mskad0+16
                            lda mskad0
                            adc #16
                            sta mskad1
                            lda mskad0+1
                            adc #0
                            sta mskad1+1

                            clc                         ;mskad2 = mskad1+16
                            lda mskad1
                            adc #16
                            sta mskad2
                            lda mskad1+1
                            adc #0
                            sta mskad2+1

;;;;; set b0,b1,b2,b3
;;;;; starts with "b00" at $A0 $A1
;;;;; lo-hi bytes up to "b33" at $BE and $BF

;;;;; set jmp in address and RTS position

                            ldy yand7
                            lda tab_rendersprite_rts_lo_2x2,y
                            sta rendersprite_set_rts_2x2+1
                            sta rendersprite_set_iny_2x2+1
                            lda tab_rendersprite_rts_hi_2x2,y
                            sta rendersprite_set_rts_2x2+2
                            sta rendersprite_set_iny_2x2+2
                            
                            lda tab_rendersprite_jmp_lo_2x2,y
                            sta rendersprite_jmp_2x2+1 
                            lda tab_rendersprite_jmp_hi_2x2,y
                            sta rendersprite_jmp_2x2+2
                            
                            lda #$60    ;RTS code is $60
rendersprite_set_rts_2x2    sta $FFFF

rendersprite_jmp_2x2        jsr $FFFF
                            jsr rendersprite2_2x2

                            lda #$C8    ;INY code is $C8
rendersprite_set_iny_2x2    sta $FFFF

                            rts

rendersprite_2x2
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
                            
                            iny
.endr

; --------------------------------------------------------------------------------------
; call this somehow to copy upper and bottom part of sprite without mask and sprite data
; --------------------------------------------------------------------------------------
rendersprite2_2x2

                            ldy yand7
                            beq skip_render_sprite_top_part_2x2
                            
                            dey
render_sprite_top_part_2x2
                            lda (b00),y
                            sta (c00),y
                            lda (b10),y
                            sta (c10),y
                            lda (b20),y
                            sta (c20),y
                            
                            dey
                            bpl render_sprite_top_part_2x2

skip_render_sprite_top_part_2x2
                            ldy #23
                            
                            lda yand7
                            clc
                            adc #15
                            sta yand7

render_sprite_bottom_part_2x2
                            lda (b02),y
                            sta (c02),y
                            lda (b12),y
                            sta (c12),y
                            lda (b22),y
                            sta (c22),y
                            
                            dey
                            cpy yand7
                            bne render_sprite_bottom_part_2x2
                            
                            rts
;----------------------------------------------
.align
tab_rendersprite_rts_lo_2x2                  ;RTS is at end of one of 8 (out of 16) last render blocks
:8     DTA l(rendersprite_2x2 + 25*15 + 24 + 25*#) ; 24+1

tab_rendersprite_rts_hi_2x2
:8     DTA h(rendersprite_2x2 + 25*15 + 24 + 25*#)

tab_rendersprite_jmp_lo_2x2                     ;JMP into begining of one of 8 blocks
:8     DTA l(rendersprite_2x2 + 25*#)   ; 24+1

tab_rendersprite_jmp_hi_2x2
:8     DTA h(rendersprite_2x2 + 25*#)

tab_sprdef_lo_2x2   ; sprdef+96*i
:4              DTA l(sprdef_vertical+96*#)

tab_sprdef_hi_2x2   ; sprdef+96*i
:4              DTA h(sprdef_vertical+96*#)


; tables for row 0
tabl24_00
:16         DTA l(24*#)
tabh24_00
:16         DTA h(24*#)

tabl24_01
:16         DTA l(24*#-8)
tabh24_01
:16         DTA h(24*#-8)

tabl24_02
:16         DTA l([24*#]-16)
tabh24_02
:16         DTA h([24*#]-16)

; tables for row 1
tabl24_10
:16         DTA l([24*#]+8)
tabh24_10
:16         DTA h([24*#]+8)

tabl24_11
:16         DTA l(24*#)
tabh24_11
:16         DTA h(24*#)

tabl24_12
:16         DTA l([24*#]-8)
tabh24_12
:16         DTA h([24*#]-8)

; tables for row 2
tabl24_20
:16         DTA l([24*#]+16)
tabh24_20
:16         DTA h([24*#]+16)

tabl24_21
:16         DTA l([24*#]+8)
tabh24_21
:16         DTA h([24*#]+8)

tabl24_22
:16         DTA l([24*#])
tabh24_22
:16         DTA h([24*#])

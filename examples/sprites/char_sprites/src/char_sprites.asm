; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************
                ORG $2000

sprites	        sei

                jsr main_init

;-----------------------------------------
;limit sprite coords for testing
.ifdef TESTSPRITEDRAW

                ldy #0
@
                ;tya
                ;and #$7F
                ;sta tabx,y
                lda taby,y
                clc
                adc #28
                sta taby,y
                dey
                bne @-
.endif
;------------------------------------------

                lda #$00
                sta i
                jsr drawsprites
;                MVA #color_Black COLBK
                inc i
                
                lda #1
                sta buffer_rendered


glavni 	        lda buffer_switched
                beq glavni
                
                ;lda #$FF
                ;sta COLBK
                jsr drawsprites
                ;lda #0
                ;sta COLBK

                lda #1
                sta buffer_rendered
                
                lda #0
                sta buffer_switched
                
                inc i   ; increase counter for looping
                inc i
                
                jmp glavni
                
;----------------------------------------------------------
drawsprites
;--------------------------------------------------------
; clear all sprite positions with 4x4 empty chars ...
;--------------------------------------------------------
.ifdef          RASTERCOLORIZE
                MVA #color_Red_orange COLBK ;erase screen Red orange
.endif

                ldy #NO_SPR-1
@               ;jsr charspriteerase
                jsr charspriteerase_2x2
                dey
                bpl @-

;                jsr brute_erase

.ifdef          RASTERCOLORIZE
                MVA #color_Black COLBK ;erase screen Red orange
.endif
                
                ;jsr rotateback
                jsr drawbacklayer

                ;jsr drawrandomchars
                
                lda #0
                sta j

draw_sprites_loop
                asl
                asl
                asl
                ;asl
                asl
                clc
                adc i
                tay
                sty sprajt_index

;--------------------------------------------------------
; draw char sprite and get background character addresses
;--------------------------------------------------------
                
                lda scroll_value
                sec
                sbc #1
                and #15
                sta POM
                lda tabx,y
                sec
                sbc POM

                ;lda tabx,y

                ldx taby,y
                ldy j
                
.ifdef          RASTERCOLORIZE
                pha
                MVA #color_Cobalt_blue COLBK ;erase screen Red orange
                pla
.endif
                ;jsr drawcharsprite
                jsr drawcharsprite_2x2
                
/*
     ; ----------- FILL LINE WITH X coord
                lda #200    ; row 5
                sta AD
                lda screen_buffer
                sta AD+1

                ldy sprajt_index
                lda tabx,y

                tay

                lda #126
@               sta (AD),y
                dey
                bpl @-
*/
                
;--------------------------------------------------------
; draw soft sprite
;------------------------------------------
                
                ldy sprajt_index

                ;lda tabx,y
                lda scroll_value
                sec
                sbc #1
                and #15
                sta POM
                lda tabx,y
                sec
                sbc POM

                ldx taby,y
                ldy j
.ifdef          RASTERCOLORIZE
                pha
                MVA #color_Medium_green COLBK ;erase screen Red orange
                pla
.endif

                ;jsr drawsoftsprite_new
                jsr drawsoftsprite_new_2x2
.ifdef          RASTERCOLORIZE
                MVA #color_Black COLBK ;erase screen Red orange
.endif
                inc j
                lda j
                cmp #NO_SPR
                bne draw_sprites_loop

                ;jsr drawfrontlayer
;--------------------------------------------------------
;swap PX,PY coordinate buffers
                ldy #NO_SPR-1
@
                lda charspritepx2,y
                sta POM5
                lda charspritepx,y
                sta charspritepx2,y
                lda POM5
                sta charspritepx,y
                
                lda charspritepy2,y
                sta POM5
                lda charspritepy,y
                sta charspritepy2,y
                lda POM5
                sta charspritepy,y
                dey
                bpl @-
                
                rts

;**********************
; y - sprite no       *
;**********************
;----- Paragraph @Char sprite erase@ -----
;---------------------------------------------------
charspriteerase sta pom1
                sty pom2
                stx pom3


                lda charspritepx,y
                ldx charspritepy,y

                clc				;ad=ekr+y*40+x
                adc tabl40,x
                sta ad
                lda tabh40,x
                adc screen_buffer
                sta ad+1
                clc
                ldx #4
charspriteerase2    lda #125
                ldy #3
charspriteerase1    sta (ad),y
                dey
                bpl charspriteerase1
                dex
                beq charspriteerase3
                lda ad
                adc #40
                sta ad
                bcc charspriteerase4
                inc ad+1
                clc
charspriteerase4    jmp charspriteerase2
charspriteerase3
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

drawcharsprite	sta pom1
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
                clc				;ad=ekr+y*40+x
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
                cpy #4
                bne @-
;---------------------------------
; calc b00-b33 16 addresses for background chars
;---------------------------------
;---------------------------------
; calc b00-b03 4 addresses for background chars
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

                ldy #120
                lda (ad),y
                tax
                lda tabl8,x
                sta b03
                lda tabh8,x
                ora tab_spr_charsets+3
                sta b03+1
                
;---------------------------------
; calc b10-b13 4 addresses for background chars
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

                ldy #121
                lda (ad),y
                tax
                lda tabl8,x
                sta b13
                lda tabh8,x
                ora tab_spr_charsets+3
                sta b13+1
                
;---------------------------------
; calc b20-b23 4 addresses for background chars
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

                ldy #122
                lda (ad),y
                tax
                lda tabl8,x
                sta b23
                lda tabh8,x
                ora tab_spr_charsets+3
                sta b23+1
                
;---------------------------------
; calc b20-b23 4 addresses for background chars
;---------------------------------
                ldy #3          ;draw column 0
                lda (ad),y
                tax
                lda tabl8,x
                sta b30
                lda tabh8,x
                ora tab_spr_charsets+0
                sta b30+1
                
                ldy #43
                lda (ad),y
                tax
                lda tabl8,x
                sta b31
                lda tabh8,x
                ora tab_spr_charsets+1
                sta b31+1
                
                ldy #83
                lda (ad),y
                tax
                lda tabl8,x
                sta b32
                lda tabh8,x
                ora tab_spr_charsets+2
                sta b32+1

                ldy #123
                lda (ad),y
                tax
                lda tabl8,x
                sta b33
                lda tabh8,x
                ora tab_spr_charsets+3
                sta b33+1
                

;--------------------------------
; correct row 1,2,3 addresses by subtractign 8,16 and 24
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
                lda b31
                sbc #8
                sta b31
                bcs @+
                dec b31+1
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
                sec
@               
                lda b32
                sbc #16
                sta b32
                bcs @+
                dec b32+1
                sec
@               
                lda b03
                sbc #24
                sta b03
                bcs @+
                dec b03+1
                sec
@               
                lda b13
                sbc #24
                sta b13
                bcs @+
                dec b13+1
                sec
@               
                lda b23
                sbc #24
                sta b23
                bcs @+
                dec b23+1
                sec
@               
                lda b33
                sbc #24
                sta b33
                bcs @+
                dec b33+1
;                sec
@               
                
;--------------------------------
; draw 0-15 chars into sprites place in screen ram
;--------------------------------
                lda pom2
                asl				;multiply with 4 to get first character code in sprite block
                asl
                ldy #0			;draw column 0
                sta (ad),y
                ldy #40
                sta (ad),y
                ldy #80
                sta (ad),y
                ldy #120
                sta (ad),y

                adc #1          ;next column
                ldy #1
                sta (ad),y
                ldy #41
                sta (ad),y
                ldy #81
                sta (ad),y
                ldy #121
                sta (ad),y

                adc #1
                ldy #2			;draw column 2
                sta (ad),y
                ldy #42
                sta (ad),y
                ldy #82
                sta (ad),y
                ldy #122
                sta (ad),y

                adc #1
                ldy #3			;draw column 3
                sta (ad),y
                ldy #43
                sta (ad),y
                ldy #83
                sta (ad),y
                ldy #123
                sta (ad),y

                lda pom1
                ldy pom2
                ldx pom3
                rts

;**********************
; draw front layer
;**********************
STARTX          equ 7
STARTY          equ 2
drawfrontlayer  
                lda #5
                sta POM5
                
                lda #>front_row
                sta ad1+1
                lda #<front_row
                sta ad1
                
                clc
                ldy #STARTY
                lda tabl40,y
                adc #STARTX
                sta ad2
                lda screen_buffer
                adc tabh40,y
                sta ad2+1
loop_row
                ldy #front_row_width-1
                
@
                lda (ad1),y
                cmp #$21    ; check if char is '!'
                bne @+

                lda #126+128
                sta (ad2),y
@
                dey
                bpl @-1
                
                dec POM5
                beq @+
                clc
                lda ad1
                adc #front_row_width
                sta ad1
                lda ad1+1
                adc #0
                sta ad1+1
                lda ad2
                adc #40
                sta ad2
                lda ad2+1
                adc #0
                sta ad2+1
                jmp loop_row
                
@
                rts

front_row_width EQU 15
                     ;0         1         2         3         
                     ;0123456789012345678901234567890123456789
front_row       DTA c" !  !!! ! ! !!!"
                DTA c"!!  ! ! ! !   !"
                DTA c" !  !!! !!! !!!"
                DTA c" !    !   ! !  "
                DTA c"!!! !!!   ! !!!"
;**********************
; draw back layer
;**********************
STARTXB         equ 0
STARTYB         equ 15
drawbacklayer  
                lda #5
                sta POM5
                
                lda #>back_row
                sta ad1+1
                lda #<back_row
                sta ad1
                
                clc
                ldy #STARTYB
                lda tabl40,y
                adc #STARTXB
                sta ad2
                lda screen_buffer
                adc tabh40,y
                sta ad2+1
loop_rowb
                ldy #39+0
                
@
                lda (ad1),y
                /*
                cmp #$21    ; check if char is '!'
                bne @+

                lda #126
                */
                sta (ad2),y
@
                dey
                bpl @-1
                
                dec POM5
                beq @+
                clc
                lda ad1
                adc #back_row_width
                sta ad1
                lda ad1+1
                adc #0
                sta ad1+1
                lda ad2
                adc #40
                sta ad2
                lda ad2+1
                adc #0
                sta ad2+1
                jmp loop_rowb
                
@
                rts

back_row_width  EQU 48
                     ;0         1         2         3         
                     ;0123456789012345678901234567890123456789
/*
back_row        DTA c" !  !!! ! ! !!!"
                DTA c"!!  ! ! ! !   !"
                DTA c" !  !!! !!! !!!"
                DTA c" !    !   !   !"
                DTA c"!!! !!!   ! !!!"
*/
back_row                
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,126,125,125,126,126,126,125,126,125,126,125,126,126,126
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,126,126,125,125,126,125,126,125,126,125,126,125,125,125,126
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,126,125,125,126,126,126,125,126,126,126,125,126,126,126
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,126,125,125,125,125,126,125,125,125,126,125,125,125,126
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,126,126,126,125,126,126,126,125,125,125,126,125,126,126,126
                DTA   125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125

;**********************
rotateback      clc
                lda char_buffer
                ;eor #CHARSET_EOR
                
                adc #3
                sta b00+1
                adc #4
                sta b01+1
                adc #4
                sta b02+1
                adc #4
                sta b03+1
                
                lda char_buffer
                eor #CHARSET_EOR
                adc #3
                sta b10+1
                adc #4
                sta b11+1
                adc #4
                sta b12+1
                adc #4
                sta b13+1
                
                lda #$e8
                sta b00
                sta b01
                sta b02
                sta b03
                sta b10
                sta b11
                sta b12
                sta b13
                
                ldy #7
rotateback4     lda (b00),y
                asl
                lda (b00),y
                rol
                sta (b00),y
                dey
                bpl rotateback4

                ldy #7
rotateback5     lda (b00),y
                asl
                lda (b00),y
                rol
                sta (b00),y
                sta (b01),y
                sta (b02),y
                sta (b03),y
                sta (b10),y
                sta (b11),y
                sta (b12),y
                sta (b13),y
                dey
                bpl rotateback5

                rts

;**********************

                icl "char_sprites_memory_map"

                icl "char_sprites_main_init"

                icl "char_sprites_interrupts"

                icl "char_sprites_dlist"

                icl "char_sprites_preshift_data"
                
                icl "char_sprites_2x2"
                
                icl "char_sprites_joystick"

                icl "music"
                
;**********************
tabl40
:25            DTA l(40*#)

tabh40
:25            DTA h(40*#)

tabl8
:128            DTA l(8*#)
:128            DTA l(8*#)

tabh8
:128            DTA h(8*#)
:128            DTA h(8*#)

tab_sprdef_lo   ; sprdef+192*i
:4              DTA l(sprdef_vertical+192*#)

tab_sprdef_hi   ; sprdef+192*i
:4              DTA h(sprdef_vertical+192*#)

tab_spr_charsets
:4              DTA 0

tab_spr_charsets_pattern
                DTA $00, $04, $08, $0C, $00, $04, $08
                
tab84           DTA 0,84,84+84,84+84+84

;**********************
charspritepx    .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0

charspritepy    .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                
; second sprite px,py array
charspritepx2   .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                
charspritepy2   .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                
;                icl "circle"
.align 256
;tabx            DTA sin(72,60,256,0,255)
tabx            DTA sin(72,20,256,0,255)

.align 256
taby            DTA sin(90,85,256,-64,192)

rand40_table    DTA 0,0,1,2,3,4,5,5
                DTA 6,7,7,8,9,9,10,10
                DTA 10,11,12,13,14,15,16,17
                DTA 18,18,19,20,21,22,23,20
                DTA 20,21,22,23,23,24,24,25
                DTA 25,25,26,27,28,29,29,30
                DTA 30,31,31,32,33,33,34,34
                DTA 35,36,36,37,38,38,39,39

rand24_table    DTA 0,0,2,2,3,4,5,5
                DTA 6,7,7,8,9,9,10,11
                DTA 12,13,13,14,15,15,16,17
                DTA 18,18,19,20,21,22,23,23


                ;icl "wiggly_circle"
;----- Paragraph @Sprite definitions@ -----

;                ORG $4000
.align 256
sprdef_vertical
/*
:192            DTA $00
:192            DTA $55
:192            DTA $AA
:192            DTA $FF
 */

;                ins "../resources/sprites.bin"
                ins "../resources/aircraft.bin"

;sprdef_vertical     ins "../resources/sprite_vertical.bin"
;maskdef_vertical    ins "../resources/mask_vertical.bin"

.align 256
                        ORG RMT_MODULE_LOAD
                        ;opt h-                      ;RMT module is standard Atari binary file already
                        ;ins "amulet.rmt",6             ;include music RMT module
                        ;opt h+
                        ins "turrican.rmt",6             ;include music RMT module
                        
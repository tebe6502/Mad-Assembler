;====================================
; Compute pixel positions of blocks
;====================================

setup_constants ldx #0 ; Compute pixel start positions of blocks
setcon_1        lda block_pos1,x
                clc
                asl
                sta pix_pos1,x
                lda block_pos2,x
                rol
                sta pix_pos2,x
                asl pix_pos1,x
                rol pix_pos2,x
                asl pix_pos1,x
                lda pix_pos2,x
                rol
                ora #96
                sta pix_pos2,x
                inx
                cpx #192
                bne setcon_1

                ldx #0 ; Build mask data from templates
                lda #128
                sta 224
                lda #169
                sta 225
setcon_2        ldy #0
setcon_3        lda mask_template,x
                sta (224),y
                iny
                lda mask_template+1,x
                sta (224),y
                iny
                lda mask_template+2,x
                sta (224),y
                iny
                cpy #24
                bne setcon_3
                lda 224
                clc
                adc #24
                sta 224
                lda 225
                adc #0
                sta 225
                inx
                inx
                inx
                cpx #96
                bne setcon_2

                rts

;=================================
; Clear the bitmap
; Set mid colors to black
; and foreground to white
;=================================

clear_screen    lda #$60
                sta 252
                lda #0
                sta 251
                tay
                ldx #32
clear_loop1     sta (251),y
                iny
                bne clear_loop1
                inc 252
                dex
                bne clear_loop1
        
                ldx #0
clear_loop2     lda #1          ; White foreground color
                sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $db00,x
                lda #0          ; Black mid colors
                sta $5c00,x
                sta $5d00,x
                sta $5e00,x
                sta $5f00,x
                inx
                bne clear_loop2
                rts

hide_sprites    lda #0          ; Put sprites offscreen
                sta 53264       ; Clear most significant bits
                tax
hidespr_1       sta 53248,x
                inx
                cpx #16
                bne hidespr_1
                rts

;=================================
; Draw the logo
;=================================
draw_logo       lda #<logo_pixels
                sta 251
                lda #>logo_pixels
                sta 252
                lda #48                 
                sta 253
                lda #96
                sta 254
                ldx #8
logo_loop2      ldy #0
logo_loop1      lda (251),y
                sta (253),y
                iny
                cpy #208
                bne logo_loop1
                clc
                lda 251
                adc #208
                sta 251
                lda 252
                adc #0
                sta 252
                lda 253
                adc #64
                sta 253
                lda 254
                adc #1
                sta 254
                dex
                bne logo_loop2

                lda #<logo_midcolor
                sta 251
                lda #>logo_midcolor
                sta 252
                lda #6                 
                sta 253
                lda #92
                sta 254
                ldx #8
logo_loop4      ldy #0
logo_loop3      lda (251),y
                sta (253),y
                iny
                cpy #26
                bne logo_loop3
                clc
                lda 251
                adc #26
                sta 251
                lda 252
                adc #0
                sta 252
                lda 253
                adc #40
                sta 253
                lda 254
                adc #0
                sta 254
                dex
                bne logo_loop4

                lda #<logo_fgcolor
                sta 251
                lda #>logo_fgcolor
                sta 252
                lda #6                 
                sta 253
                lda #$d8
                sta 254
                ldx #8
logo_loop6      ldy #0
logo_loop5      lda (251),y
                sta (253),y
                iny
                cpy #26
                bne logo_loop5
                clc
                lda 251
                adc #26
                sta 251
                lda 252
                adc #0
                sta 252
                lda 253
                adc #40
                sta 253
                lda 254
                adc #0
                sta 254
                dex
                bne logo_loop6

                rts

;==============================
; Set the gradient colors 
;==============================

set_gradient_colors     lda #104
                        sta 253
                        lda #93
                        sta 254
                        ldx #0
gracol_loop1            lda gradient_color,x
                        ldy #0
gracol_loop2            sta (253),y
                        iny
                        cpy #40
                        bne gracol_loop2
                        clc
                        lda 253
                        adc #40
                        sta 253
                        lda 254
                        adc #0
                        sta 254
                        inx
                        cpx #16
                        bne gracol_loop1

                        rts

;================================
; Display credit text at the
; start of the game
;================================

show_credits    lda #250 ; 5-second wait
                sta irq_target
                lda #1
                sta game_state
                lda #0
                sta next_game_state
                jsr setup_countdown_irq

                sei
                lda 1       ; Make character set readable
                and #251
                sta 1

                lda #24
                sta 224
                lda #111
                sta 225
                lda #<credits
                sta 226
                lda #>credits
                sta 227

shocre_5        lda #0
                sta 222
shocre_3        lda 226
                sta charset1+1
                lda 227
                sta charset1+2
                lda 224
                ora 222
                sta 220
                lda 225
                sta 221
                jsr drawline
                inc 222
                lda 222
                cmp #8
                bne shocre_3

                lda 226
                clc
                adc #17
                sta 226
                lda 227
                adc #0
                sta 227

                lda 224
                clc
                adc #64
                sta 224
                lda 225
                adc #1
                sta 225
                cmp #119
                bne shocre_5

                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli

                lda #60 ; Dots over the o
                sta 28888
                sta 28896

                rts


;=======================
; Change state methods
;=======================

;===================================
; Begin intro is called after
; the initially shown credits to
; start the intro animations
;===================================

begin_intro     jsr setup_intro_irq
                rts


start_new_game          lda #<irq_levelintro   ; Set IRQ to leve intro countdown
                        ldx #>irq_levelintro 
                        sta $314    ; store in $314/$315
                        stx $315

                        lda irq_counter ; Randomize, use last IRQ counter as seed
                        adc random_pos
                        sta random_pos

                        lda #0
                        sta irq_counter
                        lda #150        ; 3 second delay
                        sta irq_target
                        lda #2
                        sta next_game_state
                        jsr hide_sprites
                        jsr clear_screen
                        lda #0          ; Initialize game variables
                        sta score
                        sta score+1
                        lda #0
                        sta level
                        sta level_bcd
                        lda #3
                        sta lives
                        lda #80         ; Score sprite frames
                        sta topsprite_frame
                        sta topsprite_frame+1
                        sta topsprite_frame+2
                        sta topsprite_frame+3
                        lda #55
                        sta topsprite_frame+4
                        sta topsprite_frame+5
                        sta topsprite_frame+6
                        jsr draw_level
                        rts

increase_level          inc level
                        lda #0 ; Reset cheat code counter
                        sta cheat_counter

                        lda #<irq_levelintro   ; Set IRQ to level intro countdown
                        ldx #>irq_levelintro 
                        sta $314    ; store in $314/$315
                        stx $315

                        lda irq_counter ; Randomize, use last IRQ counter as seed

                        lda #0
                        sta irq_counter
                        lda #150        ; 3 second delay
                        sta irq_target
                        lda #2
                        sta next_game_state
                        jsr hide_sprites
                        jsr clear_screen
                        jsr draw_level
                        rts

start_level             lda #<irq_dummy   ; Set IRQ to dummy (temporary)
                        ldx #>irq_dummy 
                        sta $314
                        stx $315
                        jsr hide_sprites
                        jsr load_level
                        jsr clear_level
                        jsr place_top_sprites

                        jsr build_level

                        jsr draw_bitmap

                        ; Check cheat code
                        ldx #1
                        lda cheat_counter
                        cmp #5 ; Joystick pulled up exactly 5 times?
                        bne stalev_1
                        dex ; Turn collisions off
stalev_1                stx collisions_on

                        sei
                        lda #<paint_level   ; Set IRQ to paint level
                        ldx #>paint_level 
                        sta $314
                        stx $315
                        lda #242    ; trigger  interrupt at end of playing field
                        sta $d012
                        lda #0
                        sta irq_counter
                        cli

                        rts

game_over       lda #0 ; Set countdown to 150 cycles
                sta irq_counter
                lda #200
                sta irq_target
                ldx #7
                lda highscores1+7
                sec
                sbc score
                lda highscores2+7
                sbc score+1
                bcs gamove_4
                ldx #8 ; New highscore
gamove_4        stx next_game_state
                lda #<irq_countdown
                ldx #>irq_countdown 
                sta $314
                stx $315
                jsr hide_sprites
                jsr place_top_sprites
                lda #0
                sta 53262 ; Hide sound symbol sprite

                ldx #0
                txa
gamove_1        sta 27856,x ; Clear rectangle in middle
                sta 28176,x
                sta 28496,x
                sta 28816,x
                sta 29136,x
                inx
                cpx #160
                bne gamove_1
                ldx #0
                lda #1
gamove_2        sta 55706,x
                sta 55746,x
                sta 55786,x
                sta 55826,x
                sta 55866,x
                inx
                cpx #20
                bne gamove_2
                ; Draw GAME OVER text
                sei
                lda #0
                sta 222
                lda 1       ; Make character set readable
                and #251
                sta 1
gamove_3        lda #<gameovertext
                sta charset1+1
                lda #>gameovertext
                sta charset1+2
                lda #24
                ora 222
                sta 220
                lda #111
                sta 221
                jsr drawline
                inc 222
                lda 222
                cmp #7
                bne gamove_3

                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli

                rts

back_to_intro   jsr hide_sprites
                jsr clear_screen
                jsr draw_logo
                jsr set_gradient_colors
                jsr setup_intro_irq
                rts

prep_highscore  lda #<enter_name   ; Set IRQ to highscore enter name routine
                ldx #>enter_name 
                sta $314
                stx $315
                lda #0 ; Clear middle line in box
                tax
prephi_1        sta 28496,x
                inx
                cpx #160
                bne prephi_1
                lda #46
                sta initials ; Clear initials
                sta initials+1
                sta initials+2
                lda #0
                sta cursor_pos
                lda #97 ; Set cursor sprite frame
                sta 24575
                lda #150 ; Set cursor Y position
                sta 53263

                ; Draw YOUR NAME text
                sei
                lda #0
                sta 222
                lda 1       ; Make character set readable
                and #251
                sta 1
prephi_2        lda #<nametext
                sta charset1+1
                lda #>nametext
                sta charset1+2
                lda #216
                ora 222
                sta 220
                lda #109
                sta 221
                jsr drawline
                inc 222
                lda 222
                cmp #7
                bne prephi_2

                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli

                rts


; Party scene after level 16
prep_party      lda #<irq_dummy   ; Set IRQ to dummy, temporarily
                ldx #>irq_dummy 
                sta $314
                stx $315

                ; Clear blocks
                lda #0
                tax
prepar_1        sta 43008,x
                inx
                cpx #192
                bne prepar_1

                lda #2 ; Two blocks of ice in the middle
                sta 43142
                sta 43143

                lda #1 ; Set text color
                ldx #0
prepar_4        sta 55616,x
                inx
                cpx #160
                bne prepar_4

                sei
                lda 1       ; Make character set readable
                and #251
                sta 1

                lda #24
                sta 224
                lda #106
                sta 225
                lda #<party_text
                sta 226
                lda #>party_text
                sta 227

prepar_3        lda #0
                sta 222
prepar_2        lda 226
                sta charset1+1
                lda 227
                sta charset1+2
                lda 224
                ora 222
                sta 220
                lda 225
                sta 221
                jsr drawline
                inc 222
                lda 222
                cmp #8
                bne prepar_2

                lda 226
                clc
                adc #17
                sta 226
                lda 227
                adc #0
                sta 227

                lda 224
                clc
                adc #64
                sta 224
                lda 225
                adc #1
                sta 225
                cmp #111
                bne prepar_3

                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli

                sei
                ldx #117
                jsr change_block
                ldx #118
                jsr change_block
                ldx #119
                jsr change_block
                ldx #120
                jsr change_block
                ldx #133
                jsr change_block
                ldx #134
                jsr change_block
                ldx #135
                jsr change_block
                ldx #136
                jsr change_block
                ldx #149
                jsr change_block
                ldx #150
                jsr change_block
                ldx #151
                jsr change_block
                ldx #152
                jsr change_block

                ldx #117
                jsr change_pixels
                ldx #118
                jsr change_pixels
                ldx #119
                jsr change_pixels
                ldx #120
                jsr change_pixels
                ldx #133
                jsr change_pixels
                ldx #134
                jsr change_pixels
                ldx #135
                jsr change_pixels
                ldx #136
                jsr change_pixels
                ldx #149
                jsr change_pixels
                ldx #150
                jsr change_pixels
                ldx #151
                jsr change_pixels
                ldx #152
                jsr change_pixels

                cli

                ; Set sprite colors, frames and positions
                lda #7
                sta 53287
                lda #11
                sta 53288
                lda #0
                sta 53289
                lda #175
                sta 53249
                lda #181
                sta 53251
                lda #184
                sta 53253
                lda #168
                sta 53248
                lda #172
                sta 53250
                lda #176
                sta 53252
                lda #100
                sta 24568
                lda #3
                sta 24569
                lda #35
                sta 24570

                jsr start_party_music

                lda #0 ; Start countdown
                sta irq_counter
                sta slow_counter
                lda #170
                sta irq_target
                lda #<irq_party
                ldx #>irq_party 
                sta $314
                stx $315

                rts


insert_highscore        lda #<irq_dummy   ; Set IRQ to dummy
                        ldx #>irq_dummy 
                        sta $314
                        stx $315
                        ldx #8 ; Determine list position
inshi_2                 lda highscores1-1,x
                        sec
                        sbc score
                        lda highscores2-1,x
                        sbc score+1
                        bcs inshi_1
                        dex
                        lda highscores1,x
                        sta highscores1+1,x
                        lda highscores2,x
                        sta highscores2+1,x
                        cpx #0
                        bne inshi_2
inshi_1                 lda score ; Insert score into highscore list
                        sta highscores1,x
                        lda score+1
                        sta highscores2,x
                        stx 224 ; Update list text
                        txa
                        asl
                        asl
                        asl
                        asl
                        ora 224
                        sta 224
                        ldy #136
inshi_5                 ldx #0
inshi_4                 lda line17-15,y ; Move text lines down
                        sta line17+2,y
                        iny
                        inx
                        cpx #15
                        bne inshi_4
                        tya
                        sec
                        sbc #32
                        tay
                        cpy 224
                        bne inshi_5
inshi_3                 lda initials ; Insert initials
                        sta line17+13,y
                        lda initials+1
                        sta line17+14,y
                        lda initials+2
                        sta line17+15,y

                        ldx #0 ; Insert score digits
inshi_6                 lda topsprite_frame,x
                        and #15
                        ora #48
                        sta line17+4,y
                        iny
                        inx
                        cpx #4
                        bne inshi_6

                        jmp back_to_intro

;===============================
; Make all the sprites active
; and start the in-game IRQ
;===============================

activate_level          jsr setup_pete
                        jsr deactivate_flames
                        jsr start_ingame_music
                        lda #<game_loop   ; Set IRQ to main game loop
                        ldx #>game_loop 
                        sta $314
                        stx $315

                        rts

;==================================
; Called after completing a level.
;==================================

finish_level            lda #0
                        sta irq_counter
                        lda #<irq_fade   ; Set IRQ to fade out
                        ldx #>irq_fade 
                        sta $314
                        stx $315
                        jsr hide_sprites
                        rts

;===============================
; Place Pete in top left corner
;===============================

setup_pete      lda #0
                tax
setpet_1        sta 43200,x ; Clear block buffer
                inx
                cpx #192
                bne setpet_1
                sta pete_state ; Initiate pete at top left position
                sta pete_dir
                sta pete_delta
                sta pete_y
                lda #17
                sta pete_block
                lda #4
                sta pete_frame
                lda #64
                sta pete_x1
                lda #1
                sta pete_x2
                lda #144
                sta pete_y1
                lda #2
                sta pete_y2
                rts

;================================
; Revive Pete after death
;================================

revive_pete     lda #0
                sta pete_state
                lda #4
                sta pete_frame
                dec lives
                ldx lives ; Remove one life symbol
                lda #51
                sta topsprite_frame+4,x
                rts

;================================
; Deactivate all flames
;================================

deactivate_flames       lda #0
                        tax
deafla_1                sta flame_state,x
                        sta flame_y1,x
                        sta flame_y2,x
                        sta flame_dir,x
                        sta flame_delta,x
                        sta flame_y,x
                        inx
                        cpx #4
                        bne deafla_1
                        rts

;================================
; Place top sprites
;================================

place_top_sprites       lda #112        ; Put all the top panel sprites in their proper positions
                        sta 53264
                        ldx #0
                        ldy #0
platop_1                lda #0          ; Color
                        sta 53287,x
                        lda #45         ; Position
                        sta 53249,y
                        lda topsprite_x,x
                        sta 53248,y
                        lda topsprite_frame,x   ; Frame
                        sta 24568,x
                        inx
                        iny
                        iny
                        cpx #8
                        bne platop_1
                        rts

;========================
; Place mid sprites
;========================

place_mid_sprites       lda midsprite_msb   ; Put all the game sprites in their proper positions
                        sta 53264
                        ldx #0
                        ldy #0
plamid_1                lda midsprite_col,x          ; Color
                        sta 53287,x
                        lda midsprite_y,x         ; Position
                        sta 53249,y
                        lda midsprite_x,x
                        sta 53248,y
                        lda midsprite_frame,x   ; Frame
                        sta 24568,x
                        inx
                        iny
                        iny
                        cpx #8
                        bne plamid_1
                        rts


;========================
; Draw level screen
;========================

draw_level      sei

                lda level_bcd          ; Set level digits
                sed
                clc
                adc #1
                cld
                sta level_bcd
                and #15
                ora #48
                sta leveltext+11
                lda level_bcd
                lsr 
                lsr
                lsr
                lsr
                ora #48
                sta leveltext+10

                lda 1       ; Make character set readable
                and #251
                sta 1

                lda #0
                sta 222
drawlev_1       lda #<leveltext
                sta charset1+1
                lda #>leveltext
                sta charset1+2
                lda #152
                ora 222
                sta 220
                lda #108
                sta 221
                jsr drawline
                inc 222
                lda 222
                cmp #7
                bne drawlev_1

                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli

                ; Set up flame types
                ldx level
                cpx #16 ; Maximum difficulty reached at level 15
                bcc drawlev_9
                ldx #15
drawlev_9       lda level_flames,x
                sta 251
                ldy #0
                sty levflame_types+1
                sty levflame_types+2
                sty levflame_types+3
drawlev_4       cpy 251
                beq drawlev_3
                lda #1
                sta levflame_types,y
                lda #4
                sta flame_speed,y
                iny
                jmp drawlev_4
drawlev_3       clc
                lda 251
                adc level_sparks,x
                sta 251
drawlev_6       cpy 251
                beq drawlev_5
                lda #2
                sta levflame_types,y
                lda #8
                sta flame_speed,y
                iny
                jmp drawlev_6
drawlev_5       lda 251
                eor #7
                asl
                asl
                asl
                asl
                adc #76
                sta 252
                ldx #0
                ldy #0
drawlev_2       lda #7          ; Color
                sta 53287,x
                lda levflame_types,x
                cmp #1
                bne drawlev_7
                lda #21         ; Flame frame
                jmp drawlev_8
drawlev_7       lda #29         ; Spark frame
drawlev_8       sta 24568,x
                lda #150        ; Position
                sta 53249,y
                lda 252 
                sta 53248,y
                clc
                adc #32
                sta 252
                iny
                iny
                inx
                cpx 251
                bne drawlev_2

                rts

;=======================================
; Copy current level pixels and colors
;=======================================

load_level      lda level
                lsr
                and #7 ; Only 8 graphics sets, changed every 2 levels
                tax
                lda level_pixels1,x      ; Copy pixels
                sta 251
                lda level_pixels2,x
                sta 252
                ldy #0
loadlev_1       lda (251),y
                sta buf_pixels,y
                iny
                bne loadlev_1
                lda level_midcol1,x      ; Copy colors
                sta 251
                lda level_midcol2,x
                sta 252
                lda level_fgcol1,x      ; Copy colors
                sta 253
                lda level_fgcol2,x
                sta 254
                ldy #0
loadlev_2       lda (251),y
                sta buf_midcolor,y
                lda (253),y
                sta buf_fgcolor,y
                iny
                cpy #32
                bne loadlev_2
                rts

;============================================
; Set the character data of the level screen
; and decorations background, without blocks.
; Clear block holder.
; Clear coin counter
;============================================

clear_level     ldx #0          ; Block data
                lda #4
clelev_7        sta 43008,x     ; First fill
                inx
                cpx #192
                bne clelev_7
                lda #0          ; Then erase in the middle
                ldy #17
clelev_9        ldx #12
clelev_8        sta 43008,y
                iny
                dex
                bne clelev_8
                iny
                iny
                iny
                iny
                cpy #177
                bne clelev_9
                ldx #0          ; Copy to second buffer, used
clelev_10       lda 43008,x     ; for initially drawing level
                sta 43200,x
                inx
                cpx #192
                bne clelev_10

                ldx #0
                stx 226
                lda level
                and #14 ; Only 8 different graphics sets, changed every other level
                asl
                asl
                sta 227
clelev_15       lda block_pos1,x
                ora block_pos2,x
                beq clelev_3 ; Skip irrelevant positions
                lda block_pos1,x
                sta 224
                lda block_pos2,x
                ora #164
                sta 225
                ldx 227
                ldy #40
                lda level_ground,x
                sta (224),y
                inx
                iny
                lda level_ground,x
                sta (224),y
                inx
                iny
                lda level_ground,x
                sta (224),y
                ldy #80
                inx
                lda level_ground,x
                sta (224),y
                inx
                iny
                lda level_ground,x
                sta (224),y
                inx
                iny
                lda level_ground,x
                sta (224),y
clelev_3        inc 226
                ldx 226
                cpx #188
                bne clelev_15


                lda level
                and #14 ; Only 8 different graphics sets, changed every other level
                asl
                asl
                sta 224
                tay
clelev_14       lda level_deco+1,y
                tax
                beq clelev_11
clelev_13       inc random_pos
                ldy random_pos
                lda random_table,y
                sta clelev_12+1
                iny
                sty random_pos
                lda random_table,y
                and #3
                ora #164
                sta clelev_12+2
                ldy 224
                lda level_deco,y
clelev_12       sta 41984
                dex
                bne clelev_13
clelev_11       iny
                iny
                sty 224
                tya
                and #7
                bne clelev_14

                ldx #0          ; Set top decoration
clelev_1        lda #20
                sta 40960,x
                lda #21
                sta 40961,x
                lda #22
                sta 40962,x
                lda #23
                sta 40963,x
                lda #24
                sta 41000,x
                lda #25
                sta 41001,x
                lda #26
                sta 41002,x
                lda #27
                sta 41003,x
                inx
                inx
                inx
                inx
                cpx #40
                bne clelev_1
                ldx #2          ; Top and bottom walls
clelev_2        lda #28
                sta 41040,x
                sta 41920,x
                lda #29
                sta 41041,x
                sta 41921,x
                lda #30
                sta 41042,x
                sta 41922,x
                lda #31
                sta 41080,x
                lda #32
                sta 41081,x
                lda #33
                sta 41082,x
                lda #34
                sta 41120,x
                lda #35
                sta 41121,x
                lda #36
                sta 41122,x
                inx
                inx
                inx
                cpx #38
                bne clelev_2
                lda #37           ; Wall shadow
                sta 41122
                lda #200          ; Copy ground data
                sta 224
                sta 226
                lda #160
                sta 225
                lda #164
                sta 227
                ldx #0
clelev_4        ldy #2
                lda (226),y
                clc
                adc #1
                sta (224),y
                iny
clelev_5        lda (226),y
                sta (224),y
                iny
                cpy #38
                bne clelev_5
                clc
                lda 224
                adc #40
                sta 224
                sta 226
                lda 225
                adc #0
                sta 225
                ora #4
                sta 227
                inx
                cpx #19
                bne clelev_4
                lda #80         ; Draw side walls
                sta 224
                lda #160
                sta 225
                ldx #0
clelev_6        lda #29
                ldy #0
                sta (224),y
                ldy #39
                sta (224),y
                lda #30
                ldy #1
                sta (224),y
                lda #28
                ldy #38
                sta (224),y
                lda #32
                ldy #40
                sta (224),y
                ldy #79
                sta (224),y
                lda #33
                ldy #41
                sta (224),y
                lda #31
                ldy #78
                sta (224),y
                clc
                lda 224
                adc #80
                sta 224
                lda 225
                adc #0
                sta 225
                inx
                cpx #12
                bne clelev_6

                lda #0
                sta coin_counter
                rts              

;=============================================
; Use the character representation at 40960
; to draw bitmap and color data to the screen
;=============================================

draw_bitmap     lda #0          
                sta drawbit_5+1         ; Screen bitmap pos
                sta drawbit_2+1         ; Screen mid color pos
                sta drawbit_3+1         ; FG color pos
                sta drawbit_1+1         ; Character map
                lda #96
                sta drawbit_5+2
                lda #92
                sta drawbit_2+2
                lda #$d8
                sta drawbit_3+2
                lda #160
                sta drawbit_1+2
                lda #25         ; Row counter
                sta 224
drawbit_6       ldx #0
drawbit_1       lda 40960,x
                tay
                lda ice_midcolor,y
drawbit_2       sta 23552,x
                lda ice_fgcolor,y
drawbit_3       sta $d800,x
                tya 
                clc
                asl
                asl
                asl
                sta drawbit_4+1
                lda #0
                rol
                clc
                adc #128
                sta drawbit_4+2
                ldy #0
drawbit_4       lda 32768,y
drawbit_5       sta 24576,y
                iny
                cpy #8
                bne drawbit_4
                clc
                lda drawbit_5+1
                adc #8
                sta drawbit_5+1
                lda drawbit_5+2
                adc #0
                sta drawbit_5+2
                inx
                cpx #40
                bne drawbit_1

                clc
                lda drawbit_1+1
                adc #40
                sta drawbit_1+1
                lda drawbit_1+2
                adc #0
                sta drawbit_1+2
                lda drawbit_2+1
                adc #40
                sta drawbit_2+1
                lda drawbit_2+2
                adc #0
                sta drawbit_2+2
                lda drawbit_3+1
                adc #40
                sta drawbit_3+1
                lda drawbit_3+2
                adc #0
                sta drawbit_3+2

                dec 224
                bne drawbit_6
                rts

;===========================================
; Change character data for block given in x
;===========================================

change_block    lda block_pos1,x ; Compute positions of character and background data
                sta 224
                sta 226
                lda block_pos2,x
                ora #160
                sta 225
                ora #4
                sta 227
                lda 43008,x
                cmp #2
                bcc chablo_14
                jmp chablo_1
                ; Empty block
chablo_14       lda 42992,x     ; Check north
                bne chablo_2
                ldy #0          ; Also empty
                lda (226),y
                sta (224),y
                lda 42991,x ; Check north west
                beq chablo_3
                lda (224),y ; Needs ground shadow
                clc
                adc #1
                sta (224),y
chablo_3        iny
                lda (226),y
                sta (224),y
                iny
                lda (226),y
                sta (224),y
                iny
                lda 43009,x ; Check east
                bne chablo_5
                lda 42993,x ; Check north east
                bne chablo_4
                lda (226),y ; Empty
                sta (224),y
                jmp chablo_5
chablo_4        cmp #2          ; Ice?
                bne chablo_6
                lda #6
                sta (224),y
                jmp chablo_5
chablo_6        cmp #3          ; Frozen coin?
                bne chablo_29
                lda #16
                sta (224),y
                jmp chablo_5
chablo_29       lda #34         ; Block
                sta (224),y
                jmp chablo_5
chablo_2        cmp #2          ; Ice north
                bne chablo_7
                ldy #0
                lda #6
                sta (224),y
                iny
                lda #7
                sta (224),y
                iny
                lda #8
                sta (224),y
                jmp chablo_9
chablo_7        cmp #3          ; Coin north
                bne chablo_8
                ldy #0
                lda #16
                sta (224),y
                iny
                lda #17
                sta (224),y
                iny
                lda #18
                sta (224),y
                jmp chablo_9
chablo_8        ldy #0 ; Block north
                lda #34
                sta (224),y
                iny
                lda #35
                sta (224),y
                iny
                lda #36
                sta (224),y
chablo_9        lda 43007,x     ; Check west
                beq chablo_5
                ldy #0          ; Set shadow on north block
                lda (224),y
                clc
                adc #3
                sta (224),y
chablo_5        ldy #40          ; Second line. Copy ground
                lda (226),y
                sta (224),y
                iny
                lda (226),y
                sta (224),y
                iny
                lda (226),y
                sta (224),y
                lda 43007,x     ; Check west
                beq chablo_10
                ldy #40          ; Add ground shadow
                lda (224),y
                clc
                adc #1
                sta (224),y
chablo_10       lda 43009,x     ; Check east
                bne chablo_11
                ldy #43         ; Empty. Copy ground
                lda (226),y
                sta (224),y
                ldy #3 ; Check if there is a shadow that needs to be removed
                lda (224),y
                cmp #9
                beq chablo_28
                cmp #19
                beq chablo_28
                cmp #37
                beq chablo_28
                jmp chablo_11
chablo_28       sec
                sbc #3
                sta (224),y
chablo_11       lda 43024,x     ; Check south
                bne chablo_12
                ldy #80         ; Empty. Copy ground
                lda (226),y
                sta (224),y
                iny
                lda (226),y
                sta (224),y
                iny
                lda (226),y
                sta (224),y
                lda 43007,x     ; Check west
                beq chablo_12
                ldy #80         ; Add shadow
                lda (224),y
                clc
                adc #1
                sta (224),y
chablo_12       lda 43009,x     ; Check east
                bne chablo_13
                lda 43025,x     ; Check south east
                bne chablo_13
                ldy #83         ; Empty. Copy ground
                lda (226),y
                sta (224),y
chablo_13       rts             ; All done with empty block
                ; Filled block. First check if we need shadows
chablo_1        lda 43009,x ; Check east
                bne chablo_15
                ldy #3
                lda 42993,x ; Check north east
                bne chablo_16
                lda (226),y ; Empty. Copy ground
                sta (224),y
                lda 42992,x ; Check north
                beq chablo_19
                lda (224),y ; Needs shadow
                clc
                adc #1
                sta (224),y
                jmp chablo_19
chablo_16       cmp #2 ; Ice
                bne chablo_17
                lda #9
                sta (224),y
                jmp chablo_19
chablo_17       cmp #3 ; Coin
                bne chablo_18
                lda #19
                sta (224),y
                jmp chablo_19
chablo_18       lda #37
                sta (224),y
chablo_19       ldy #43 ; Set middle line ground shadow
                lda (226),y
                clc
                adc #1
                sta (224),y
                lda 43025,x ; Check south east
                bne chablo_15
                ldy #83 ; Set bottom line ground shadow
                lda (226),y
                clc
                adc #1
                sta (224),y
chablo_15       lda 43008,x ; Check which block top we need to draw
                cmp #2
                bne chablo_20
                ldy #0 ; Ice
                lda #0
                sta (224),y
                iny
                lda #1
                sta (224),y
                iny
                lda #2
                sta (224),y
                ldy #40
                lda #3
                sta (224),y
                iny
                lda #4
                sta (224),y
                iny
                lda #5
                sta (224),y
                jmp chablo_22
chablo_20       cmp #3
                bne chablo_21
                ldy #0 ; Coin
                lda #10
                sta (224),y
                iny
                lda #11
                sta (224),y
                iny
                lda #12
                sta (224),y
                ldy #40
                lda #13
                sta (224),y
                iny
                lda #14
                sta (224),y
                iny
                lda #15
                sta (224),y
                jmp chablo_22
chablo_21       ldy #0 ; Block
                lda #28
                sta (224),y
                iny
                lda #29
                sta (224),y
                iny
                lda #30
                sta (224),y
                ldy #40
                lda #31
                sta (224),y
                iny
                lda #32
                sta (224),y
                iny
                lda #33
                sta (224),y
chablo_22       lda 43024,x ; Check south
                beq chablo_23
                rts ; All done with block
chablo_23       ldy #80
                lda 43008,x
                cmp #2
                bne chablo_24
                lda #6 ; Ice bottom
                sta (224),y
                iny
                lda #7
                sta (224),y
                iny
                lda #8
                sta (224),y
                jmp chablo_26
chablo_24       cmp #3
                bne chablo_25
                lda #16 ; Coin bottom
                sta (224),y
                iny
                lda #17
                sta (224),y
                iny
                lda #18
                sta (224),y
                jmp chablo_26
chablo_25       lda #34 ; Block bottom
                sta (224),y
                iny
                lda #35
                sta (224),y
                iny
                lda #36
                sta (224),y
chablo_26       lda 43023,x ; Check south west
                bne chablo_27
                rts     ; All done with bottom
chablo_27       ldy #80 ; Add bottom wall shadow
                lda (224),y
                clc
                adc #3
                sta (224),y
                rts

;========================================
; Update 4x3 group with colors and pixels
; Position given in x
;========================================

change_pixels   stx 231
                lda block_pos1,x
                sta 224 ; Character map
                sta 226 ; Mid color
                sta 228 ; FG color
                lda block_pos2,x
                ora #160
                sta 225
                and #3
                ora #92
                sta 227
                and #3
                ora #216
                sta 229
                lda #0
                sta 230
                tay
chapix_3        lda char_offset,y
                tay
                lda (224),y
                asl
                asl
                asl
                sta chapix_2+1 ; Pixel source
                lda #0
                adc #128
                sta chapix_2+2
                lda (224),y
                tax
                lda ice_midcolor,x
                sta (226),y
                lda ice_fgcolor,x
                sta (228),y
                ldy 230
                ldx 231
                clc
                lda pix_pos1,x
                adc pix_offset1,y
                sta chapix_1+1
                lda pix_pos2,x
                adc pix_offset2,y
                sta chapix_1+2
                ldx #0
chapix_2        lda 32768,x
chapix_1        sta 24576,x
                inx
                cpx #8
                bne chapix_2
                iny
                sty 230
                cpy #12
                bne chapix_3
                rts

;==========================
; Stop moving ice block
;==========================

stop_ice        lda ice_state ; Stop moving when reached obstacle
                ldx ice_block
                sta 43008,x
                jsr change_block
                ldx ice_block
                jsr change_pixels
                lda #0
                sta ice_delta
                sta ice_dir
                sta ice_state
                sta ice_y1
                sta ice_y2
                sta ice_y
                sta ice_active
                ldx #3
                jsr start_sound
                rts

;=========================================
; Find mask offset
; x : block pos
; 221 : dir
; 222 : y pos
; 223 : delta
; Return in 220
;=========================================

find_mask       lda #0
                sta 220
                lda 221
                cmp #3
                bcs finma_1
                ; Vertical motion or standing still
                cmp #2
                bcs finma_2
                lda 43024,x
                jmp finma_3
finma_2         lda 43040,x
finma_3         cmp #2
                bcs finma_4
                rts
finma_4         lda 222 ; Blocked below
                sec
                sbc #3
                and #15
                cmp #15
                bne finma_16
                ldy 221
                cpy #2
                bne finma_16
                lda #0 ; Special case when moving down
                sta 220
                rts
finma_16        sec
                sbc #7
                bpl finma_6
                lda #0
finma_6         sta 220
                rts
finma_1        ; Horizontal motion
                cmp #4
                beq finma_7
                lda 223 ; Going left
                beq finma_15 ; Special case. Skip adjustments
                dex
                lda #192 ; Going left
                sec
                sbc 223
                lsr
                and #248
finma_15        sta 220
                lda 43024,x ; Check below
                cmp #2
                bcs finma_8
                lda 43025,x ; Empty below. Check south east
                cmp #2
                bcs finma_9
                lda #0 ; All empty below
                sta 220
                rts
finma_9         lda 220 ; Block south east
                clc
                adc #104
                sta 220
                rts
finma_8         lda 43025,x ; Block below. Check south east
                cmp #2
                bcs finma_10
                lda 220 ; Block below, clear south east
                clc
                adc #8
                sta 220
                rts
finma_10        lda #8 ; Completely blocked below
                sta 220
                rts
finma_7         lda 223 ; Going right
                lsr
                and #248
                sta 220
                lda 43024,x ; Check below
                cmp #2
                bcs finma_11
                lda 43025,x ; Empty below. Check south east
                cmp #2
                bcs finma_12
                lda #0 ; All empty below
                sta 220
                rts
finma_12        lda 220 ; Block south east
                clc
                adc #104
                sta 220
                rts
finma_11        lda 43025,x ; Block below. Check south east
                cmp #2
                bcs finma_13
                lda 220 ; Block below, clear south east
                clc
                adc #8
                sta 220
                rts
finma_13        lda #8 ; Completely blocked below
                sta 220
                rts

;===============================
; Adds y register to score and
; updates sprite frames
;===============================

update_score    tya
                sed
                clc
                adc score
                sta score
                lda score+1
                adc #0
                sta score+1
                cld
                and #15
                ora #80
                sta topsprite_frame+1
                lda score+1
                lsr
                lsr
                lsr
                lsr
                and #15
                ora #80
                sta topsprite_frame
                lda score
                and #15
                ora #80
                sta topsprite_frame+3
                lda score
                lsr
                lsr
                lsr
                lsr
                and #15
                ora #80
                sta topsprite_frame+2
                rts


;=========================================
; Randomly generate level in block buffer
;=========================================

build_level     lda level
                cmp #16
                bcc builev_12
                lda #15 ; Set maximum level difficulty to 15
builev_12       sta 226
                lda #4
                sta 43217 ; Block top left position
                ldx #0 ; Place random blocks
builev_1        inc random_pos
                ldy random_pos
                lda random_table,y
                cmp #192
                bcs builev_1
                tay
                lda 43200,y
                bne builev_1
                lda #4
                sta 43200,y
                inx
                txa
                ldy 226
                cmp level_blocks,y
                bne builev_1
                ; Now check level integrity.
                ; There should be no walled-in areas.
                lda #16
                sta 43217
                lda #17
                sta buffer
                lda #0
                sta 224
                lda #1
                sta 225
builev_4        ldx 224
                lda buffer,x
                tax
                ldy 225
                lda 43184,x ; Check north
                bne builev_5
                lda #16
                sta 43184,x
                txa
                sec 
                sbc #16
                sta buffer,y
                iny
builev_5        lda 43216,x ; Check south
                bne builev_6
                lda #16
                sta 43216,x
                txa
                clc 
                adc #16
                sta buffer,y
                iny
builev_6        lda 43199,x ; Check west
                bne builev_7
                lda #16
                sta 43199,x
                txa
                sec 
                sbc #1
                sta buffer,y
                iny
builev_7        lda 43201,x ; Check east
                bne builev_8
                lda #16
                sta 43201,x
                txa
                clc 
                adc #1
                sta buffer,y
                iny
builev_8        sty 225
                inc 224
                lda 224
                cmp 225
                bne builev_4
                ldx 226
                lda #120
                sec
                sbc level_blocks,x
                cmp 225
                beq builev_9 
                ldx #16 ; Not OK. Restore empty board and start over
builev_11       lda 43008,x
                sta 43200,x
                inx
                cpx #176
                bne builev_11
                jmp build_level
builev_9        ldx #16 ; All OK. Clean up board.
builev_10       lda 43200,x
                and #7
                sta 43200,x
                inx
                cpx #176
                bne builev_10
                lda #4 ; Put back top left block
                sta 43217

                ldx #0 ; Place random coins
builev_2        inc random_pos
                ldy random_pos
                lda random_table,y
                cmp #192
                bcs builev_2
                tay
                lda 43200,y
                bne builev_2
                lda #3
                sta 43200,y
                inx
                cpx #5
                bne builev_2
                ldx #0 ; Place random ice
builev_3        inc random_pos
                ldy random_pos
                lda random_table,y
                cmp #192
                bcs builev_3
                tay
                lda 43200,y
                bne builev_3
                lda #2
                sta 43200,y
                inx
                txa
                ldy 226
                cmp level_ice,y
                bne builev_3
                lda #0
                sta 43217 ; Clear top left position
                rts                

;========================================
; Draw one-pixel horizontal line of text
;========================================
drawline        ldx #0
charset1        lda line1,x
                cmp #32
                beq charset7
                asl
                sta 251
                ldy #0
                sty 252
                asl 251
                rol 252
                asl 251
                rol 252
                lda 252
                adc #216
                sta 252
                lda 220
                and #7
                tay
                lda (251),y
                ldy #0
                sty 251
                sty 252
                asl
                ldy #7
charset3        asl 252
                rol 251
                asl 252
                rol 251
                asl
                bcc charset2
                sta 2
                lda #3
                ora 252
                sta 252
                lda 2
charset2        cpy #2
                bne charset4
                sta 2
                lda #255
                sta 253
                sta 254
                lda 220
                and #7
                cmp #7
                beq charset4
                lda 251
                eor #255
                sta 253
                lda 252
                eor #255
                sta 254
                lda 2
charset4        dey
                bne charset3
                lda 251
                ora (220),y
                sta (220),y
                iny
                lda 253
                and (220),y
                sta (220),y
                ldy #8
                lda 252
                ora (220),y
                sta (220),y
                iny
                lda 254
                and (220),y
                sta (220),y

charset7        clc
                lda 220
                adc #16
                sta 220
                bcc charset5
                inc 221

charset5        inx
                cpx #17
                beq charset6
                jmp charset1

charset6        rts


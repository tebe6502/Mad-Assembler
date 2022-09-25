
;=================================
; Various IRQ routines
;=================================

setup_countdown_irq
				sei         ; set interrupt disable flag
                ldy #$7f    ; $7f = %01111111
                sty $dc0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                sty $dd0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                lda $dc0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
                lda $dd0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed

                lda #$01    ; Set Interrupt Request Mask...
                sta $d01a   ; ...we want IRQ by Rasterbeam (%00000001)

                lda $d011   ; Bit#0 of $d011 indicates if we have passed line 255 on the screen
                and #$7f    ; it is basically the 9th Bit for $d012
                sta $d011

                lda #0          ; Set up initial intro state and counter
                sta irq_counter

                lda #<irq_countdown
                ldx #>irq_countdown
                sta $314    ; store in $314/$315
                stx $315

                lda #0    ; trigger first interrupt at row 0
                sta $d012

                cli       ; clear interrupt disable flag
                rts

;=====================
; Intro IRQ setup
;=====================
setup_intro_irq sei         ; set interrupt disable flag
                ldy #$7f    ; $7f = %01111111
                sty $dc0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                sty $dd0d   ; Turn off CIAs Timer interrupts ($7f = %01111111)
                lda $dc0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed
                lda $dd0d   ; by reading $dc0d and $dd0d we cancel all CIA-IRQs in queue/unprocessed

                lda #$01    ; Set Interrupt Request Mask...
                sta $d01a   ; ...we want IRQ by Rasterbeam (%00000001)

                lda $d011   ; Bit#0 of $d011 indicates if we have passed line 255 on the screen
                and #$7f    ; it is basically the 9th Bit for $d012
                sta $d011

                jsr start_menu_music

                lda #<irq_intro   ; point IRQ Vector to our custom irq routine
                ldx #>irq_intro
                sta $314    ; store in $314/$315
                stx $315

                lda #0    ; trigger first interrupt at row 0
                sta $d012

                lda #0          ; Set up initial intro state and counter
                sta irq_counter
                sta intro_state
                lda #1
                sta irq_target

                cli       ; clear interrupt disable flag
                rts


;=====================
; Intro management
;=====================

irq_intro       ldx intro_state     ; Handle current state
                lda irq_jumptab3,x
                sta irq_handle+1
                lda irq_jumptab4,x
                sta irq_handle+2

irq_handle      jsr handle_curtain

                inc irq_counter
         		lda irq_counter
                cmp irq_target     ; Have we reached the counter target?
				bne irq_skip1
                lda #0
                sta irq_counter
				inc intro_state     ; Prepare for new state
				ldx intro_state
                cpx #33              ; End of intro states reached?
                bne irq_skip2
                ldx #3				; Restart from first top text lines
                stx intro_state
irq_skip2       lda irq_targets,x   ; Set new counter max value
                sta irq_target
				lda irq_jumptab1,x  ; Set jump address
				sta irq_prep+1
				lda irq_jumptab2,x
				sta irq_prep+2
irq_prep		jsr prepare_dummy
irq_skip1
                jsr play_music

				lda 56320		; Check joystick fire button (and space)
				and 56321
				and #16
				bne irq_skip3
				lda #1			; Change game state to start new game
				sta game_state
irq_skip3		asl $d019
              	jmp $ea81

;=========================
; IRQ routine that does nothing --
; used between scenes
;=========================

irq_dummy       asl $d019
				jmp $ea81


;=================================================
; IRQ routine that waits until
; target is reached and then changes the game state
;==================================================

irq_countdown   inc irq_counter
                lda irq_counter
                cmp irq_target
                bne irqcou_1
                lda next_game_state
                sta game_state
irqcou_1        asl $d019
                jmp $ea81

;=================================================
; Simple animations while the pre-level
; screen is visible
;==================================================

irq_levelintro  inc irq_counter
                ; Animate flame sprites
                ldx #0
irqlev_4        lda levflame_types,x
                cmp #1
                bne irqlev_2
                lda irq_counter ; Flame frames
                lsr
                lsr
                and #7
                tay
                lda flame_frames,y
                sta 24568,x
                jmp irqlev_3
irqlev_2        lda irq_counter
                lsr
                lsr
                and #3
                ora #28
                sta 24568,x
irqlev_3        inx
                cpx #4
                bne irqlev_4

                ; Check joystick for cheat code
                lda 56320
                and 56321
                sta joystick
                cmp joystick_old
                beq irqlev_5
                sta joystick_old
                cmp #126 ; Count the number of times the joystick is pulled up
                bne irqlev_5
                inc cheat_counter
irqlev_5

                lda irq_counter
                cmp irq_target
                bne irqlev_1
                lda next_game_state
                sta game_state
irqlev_1        asl $d019
                jmp $ea81

;=============================
; Top of screen IRQ routine,
; used during game session
;=============================

irq_screentop	lda #112	; Put all the top panel sprites in their proper positions
				sta 53264
				ldx #0
				ldy #0
irqtop_1		lda #0		; Color
				sta 53287,x
				lda #50		; Position
				sta 53249,y
				lda topsprite_x,x
				sta 53248,y
				lda topsprite_frame,x 	; Frame
				sta 24568,x
				inx
				iny
				iny
				cpx #7
				bne irqtop_1

				asl $d019
				jmp $ea81


;===================================
; Paint level
; Fill up playing field with blocks
;===================================

paint_level     inc irq_counter
                ldx irq_counter
                cpx #176
                beq pailev_1
                lda 43200,x
                cmp 43008,x
                beq paint_level
                sta 43008,x
                jsr change_block
                ldx irq_counter
                jsr change_pixels
                jmp pailev_2
pailev_1        lda #3 ; Signal to activate level
                sta game_state
pailev_2        asl $d019
                jmp $ea81


;===========================
; Game loop
;===========================

game_loop       inc irq_counter

                ; Set sprite pixel source data addresses
                lda pete_frame
                sta gloop_1+2
                lda #0
                lsr gloop_1+2
                ror
                lsr gloop_1+2
                ror
                sta gloop_1+1
                sta gloop_2+1 ; Shadow
                lda gloop_1+2
                ora #64
                sta gloop_1+2
                ora #8
                sta gloop_2+2 ; Shadow

                lda flame_frame
                sta gloop_3+2
                lda #0
                lsr gloop_3+2
                ror
                lsr gloop_3+2
                ror
                sta gloop_3+1
                lda gloop_3+2
                ora #64
                sta gloop_3+2

                lda flame_frame+1
                sta gloop_4+2
                lda #0
                lsr gloop_4+2
                ror
                lsr gloop_4+2
                ror
                sta gloop_4+1
                lda gloop_4+2
                ora #64
                sta gloop_4+2

                lda flame_frame+2
                sta gloop_5+2
                lda #0
                lsr gloop_5+2
                ror
                lsr gloop_5+2
                ror
                sta gloop_5+1
                lda gloop_5+2
                ora #64
                sta gloop_5+2

                lda flame_frame+3
                sta gloop_6+2
                lda #0
                lsr gloop_6+2
                ror
                lsr gloop_6+2
                ror
                sta gloop_6+1
                lda gloop_6+2
                ora #64
                sta gloop_6+2

                lda ice_frame
                sec
                sbc #12
                sta gloop_13+2
                lda #0
                lsr gloop_13+2
                ror
                lsr gloop_13+2
                ror
                ora #39
                sta gloop_13+1
                lda gloop_13+2
                ora #64
                sta gloop_13+2


                ; Compute masking offset
                ldx pete_block ; Pete
                lda pete_dir
                sta 221
                lda pete_y
                sta 222
                lda pete_delta
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_7+1
				lda mask_pos2,y
				sta gloop_7+2

				ldx flame_block ; Flames
                lda flame_dir
                sta 221
                lda flame_y
                sta 222
                lda flame_delta
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_8+1
				lda mask_pos2,y
				sta gloop_8+2

				ldx flame_block+1
                lda flame_dir+1
                sta 221
                lda flame_y+1
                sta 222
                lda flame_delta+1
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_9+1
				lda mask_pos2,y
				sta gloop_9+2

				ldx flame_block+2
                lda flame_dir+2
                sta 221
                lda flame_y+2
                sta 222
                lda flame_delta+2
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_10+1
				lda mask_pos2,y
				sta gloop_10+2

				ldx flame_block+3
                lda flame_dir+3
                sta 221
                lda flame_y+3
                sta 222
                lda flame_delta+3
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_11+1
				lda mask_pos2,y
				sta gloop_11+2

				ldx ice_block ; Ice
                lda ice_dir
                sta 221
                lda ice_y
                sta 222
                lda ice_delta
                sta 223
                jsr find_mask
      			ldy 220
				lda mask_pos1,y
				sta gloop_14+1
				lda mask_pos2,y
				sta gloop_14+2

				; Determine shadow mask pos

				lda pete_dir
                cmp #1
                beq shad_1
                cmp #2
                beq shad_1
				cmp #3
				bne shad_3
				ldx pete_block
				dex
				lda #192 ; Going left
				sec
				sbc pete_delta
				jmp shad_9
shad_3			lda pete_delta ; Going right
				ldx pete_dir
				cpx #4
				beq shad_4
				lda #0 ; Treat delta as 0 for up/down movement
shad_4			ldx pete_block
shad_9			clc
				adc #32
				cmp #192
				bcc shad_5
				inx ; Adjust block position 1 step right
				sec
				sbc #192
shad_5			lsr
				and #248
				tay
                lda 43024,x ; Check below
                cmp #2
                bcs shad_6
                lda 43025,x ; Empty below. Check south east
                cmp #2
                bcs shad_7
                lda 43009,x ; Also check east
                cmp #2
                bcs shad_7
                ldy #0 ; All empty below
                jmp shad_2
shad_7        	tya ; Block south east
                clc
                adc #104
                tay
                jmp shad_2
shad_6        	lda 43025,x ; Block below. Check south east
                cmp #2
                bcs shad_8
                lda 43009,x ; Also check east
                cmp #2
                bcs shad_8
                tya ; Block below, clear south east
                clc
                adc #8
                tay
                jmp shad_2
shad_8        	ldy #8 ; Completely blocked below
				jmp shad_2
shad_1			ldx pete_block ; Vertical motion
				cmp #1
				bne shad_25
                lda pete_delta
                bne shad_10
                lda 43024,x ; Special case for up with delta 0
                cmp #2
                bcs shad_22
				lda 43025,x ; Empty below, check south east
				ora 43009,x ; and east
				cmp #2
				bcs shad_24
				ldy #0 ; No masking necessary
				jmp shad_2
shad_24 		ldy #224 ; Shadow masked but not bottom
				jmp shad_2
shad_22			lda 43025,x ; Blocked below, check south east
				ora 43009,x ; and east
				cmp #2
				bcs shad_23
				ldy #208 ; Bottom but not shadow masked
				jmp shad_2
shad_23			ldy #8 ; Both bottom and shadow masked
                jmp shad_2
shad_10			txa
				sec
				sbc #16
				tax
shad_25			ldy #0
				lda 43040,x ; Check below
				cmp #2
				bcs shad_11
				lda 43025,x ; Empty below. Check shouth east
				cmp #2
				bcc shad_12
				ldy #224 ; Completely hidden right shadow part, rest visible
				jmp shad_2
shad_12			lda pete_y
				sec
				sbc #2
				and #15
				cmp #8
				bne shad_13
				ldy #0 ; Special case, fully visible shadow
				jmp shad_2
shad_13 		cmp #8
				bcs shad_14
				tay ; Check to the right
				lda 43009,x
				cmp #2
				bcs shad_15
				ldy #0 ; Empty. Fully visible shadow
				jmp shad_2
shad_15			tya
				clc ; Mask top part of right shadow
				adc #240
				tay
				jmp shad_2
shad_14			tay
				lda 43041,x ; Check south, south east
				cmp #2
				bcs shad_16
				ldy #0 ; Fully visible shadow
				jmp shad_2
shad_16			tya
				clc
				adc #208
				tay
				jmp shad_2
shad_11			lda 43025,x ; Blocked below. Check east.
                cmp #2
                bcs shad_17
                lda pete_y ; East free. Check y position
                sec
                sbc #2
                and #15
                cmp #8
                bcs shad_19
                tay
                lda 43009,x ; Check north east to see if we need to mask right shadow
                cmp #2
                bcc shad_21
                tya
                ora #240
                tay
                jmp shad_2
shad_21         ldy #0 ; No masking necessary
                jmp shad_2
shad_19         tay
                lda 43041,x ; Check south east
                cmp #2
                bcs shad_20
                tya ; South east free. Mask bottom but not right shadow
                clc
                adc #192
                tay
                jmp shad_2
shad_20         tya ; Mask bottom and right shadow similarly
				and #7
                tay
                jmp shad_2
shad_17         lda pete_y
                sec
                sbc #2
                and #15
                cmp #8
                bcs shad_18
                ldy #240 ; Block only right shadow part
                jmp shad_2
shad_18         clc ; Block all right shadow and partly bottom
                adc #216
                tay
shad_2			lda mask_pos1,y
				sta gloop_33+1
				lda mask_pos2,y
				sta gloop_33+2


                jsr place_top_sprites

                ldx #0 ; Copy sprite frame data for Pete, shadow and flames
gloop_1         lda 16384,x
                sta 22144,x
gloop_2         lda 16384,x
                sta 22208,x
gloop_3         lda 16384,x
                sta 22272,x
gloop_4         lda 16384,x
                sta 22336,x
gloop_5         lda 16384,x
                sta 22400,x
gloop_6         lda 16384,x
                sta 22464,x
                inx
                cpx #63
                bne gloop_1

                ldx #0 ; Mask sprite frame data for Pete and flames
gloop_12        lda 22192,x
gloop_7         and 43392,x
                sta 22192,x
                lda 22320,x
gloop_8         and 43392,x
                sta 22320,x
                lda 22384,x
gloop_9         and 43392,x
                sta 22384,x
                lda 22448,x
gloop_10        and 43392,x
                sta 22448,x
                lda 22512,x
gloop_11        and 43392,x
                sta 22512,x
                inx
                cpx #15
                bne gloop_12

                ; Copy and mask block bottom. Also mask shadow
                ldx #0
gloop_13        lda 16384,x
gloop_14        and 43392,x
                sta 22567,x
        		lda 22247,x
gloop_33        and 43392,x
                sta 22247,x
                inx
                cpx #24
                bne gloop_13

                ; Set midsprite values according to sort order

                lda #1
                sta 220 ; Sprite x msb bit counter
                ldx #0 ; Sort counter
                stx midsprite_msb ; msb holder
                stx 222 ; Sprite counter
gloop_19        ldy 222
                lda sort_ix,x
                bne gloop_20
                ; Pete
                lda #11
                sta midsprite_col,y
                lda #90
                sta midsprite_frame,y
                lda pete_x2
                sta 223
                lda pete_x1
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                and #254
                sta midsprite_x,y
                lda 223
                beq gloop_21
                lda midsprite_msb
                ora 220
                sta midsprite_msb
gloop_21        asl 220
                lda midsprite_x,y
                clc
                adc #4
                sta midsprite_x+1,y
                lda 223
                adc #0
                beq gloop_22
                lda midsprite_msb
                ora 220
                sta midsprite_msb
gloop_22        asl 220
                lda pete_y
                sta midsprite_y,y
                clc
                adc #3
                sta midsprite_y+1,y
                iny
                lda #0
                sta midsprite_col,y
                lda #91
                sta midsprite_frame,y
                iny
                sty 222
                jmp gloop_23
gloop_20        cmp #5
                beq gloop_24
                ; Flames
                clc
                adc #91
                sta midsprite_frame,y
                lda sort_ix,x
                tay
                lda flame_color-1,y
                ldy 222
                sta midsprite_col,y
                lda sort_ix,x
                tay
                lda flame_x2-1,y
                sta 223
                lda flame_x1-1,y
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                and #254
                ldy 222
                sta midsprite_x,y
                lda 223
                beq gloop_25
                lda midsprite_msb
                ora 220
                sta midsprite_msb
gloop_25        asl 220
                lda sort_ix,x
                tay
                lda flame_y-1,y
                ldy 222
                sta midsprite_y,y
                iny
                sty 222
                jmp gloop_23
gloop_24        ; Ice
                lda #3
                sta midsprite_col,y
                lda ice_frame
                sta midsprite_frame,y
                lda ice_x2
                sta 223
                lda ice_x1
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                and #254
                sta midsprite_x,y
                sta midsprite_x+1,y
                lda 223
                beq gloop_27
                lda midsprite_msb
                ora 220
                sta midsprite_msb
gloop_27        asl 220
                lda 223
                beq gloop_28
                lda midsprite_msb
                ora 220
                sta midsprite_msb
gloop_28        asl 220
                lda ice_y
                sta midsprite_y,y
                clc
                adc #3
                sta midsprite_y+1,y
                iny
                lda #14
                sta midsprite_col,y
                lda #96
                sta midsprite_frame,y
                iny
                sty 222
gloop_23        inx
                cpx #6
                beq gloop_26
                jmp gloop_19
gloop_26        ; All done


                ; Time to draw the game sprites on screen
                jsr place_mid_sprites

                jsr play_sound

                ; Handle changed block
                ldx changed_block
                beq gloop_32
                jsr change_block
                ldx changed_block
                jsr change_pixels
                lda #0
                sta changed_block
gloop_32

                ; Control routine
                lda 56320       ; Check joystick, combine ports 1 and 2
                and 56321
				sta joystick

                lda pete_dir     ; Handle directional motion
                ldx pete_state      ; Skip if not in interactive state
                cpx #0
                beq pete_19
                cpx #1
                bne pete_33
                ; Level cleared
                lda irq_counter
                lsr
                lsr
                lsr
                and #1
                ora #12
                sta pete_frame
                lda irq_counter
                and #7
                bne pete_37
                ldx #5
                jsr start_sound
pete_37         ldy #1
                jsr update_score
                lda irq_counter
                cmp #100
                bne pete_34
                ; Level complete
                lda #4
                sta game_state
pete_34         jmp pete_done
pete_33         ; Death
                lda irq_counter
                cmp #40
                bcs pete_38
                lsr
                lsr
                lsr
                clc
                adc #14
                sta pete_frame
                jmp pete_done
pete_38         cmp #150
                bcs pete_39
                jmp pete_done
pete_39         lda lives
                beq pete_40
                jsr revive_pete
                jmp pete_done
pete_40         lda #6 ; Change state to game over
				sta game_state
				jmp pete_done
pete_19         tax
                lda pete_dir_jumptable1,x
                sta pete_50+1
                lda pete_dir_jumptable2,x
                sta pete_50+2
pete_50         jmp pete_done
                ; Going up
pete_up         lda pete_y1
                sec
                sbc #10
                sta pete_y1
                lda pete_y2
                sbc #0
                sta pete_y2
                lda irq_counter ; Animate
                lsr
                lsr
                and #3
                tax
                lda penguin_up,x
                sta pete_frame
                lda pete_delta ; Update delta
                clc
                adc #10
                sta pete_delta
                cmp #128
                bcs pete_41
                lda joystick
                and #2
                bne pete_5
                lda #128 ; Switch direction to down
                sec
                sbc pete_delta
                sta pete_delta
                lda pete_block
                sec
                sbc #16
                sta pete_block
                lda #2
                sta pete_dir
                jmp pete_done
pete_41         sec ; Reached new block
                sbc #128
                sta pete_delta
                lda pete_block
                sec
                sbc #16
                sta pete_block
                ldx pete_block
                lda 42992,x ; Check north
                bne pete_6
                lda joystick
                and #1
                bne pete_6
pete_5          jmp pete_done ; Just keep moving
pete_6          lda pete_y1 ; Stop moving at block boundary
                clc
                adc pete_delta
                sta pete_y1
                lda pete_y2
                adc #0
                sta pete_y2
                lda #0
                sta pete_delta
                sta pete_dir
                jmp pete_done
pete_down       ; Going down
                lda pete_y1
                clc
                adc #10
                sta pete_y1
                lda pete_y2
                adc #0
                sta pete_y2
                lda irq_counter ; Animate
                lsr
                lsr
                and #3
                tax
                lda penguin_down,x
                sta pete_frame
                lda pete_delta ; Update delta
                clc
                adc #10
                sta pete_delta
                cmp #128
                bcs pete_42
                lda joystick
                and #1
                bne pete_7
                lda #128 ; Switch direction to up
                sec
                sbc pete_delta
                sta pete_delta
                lda pete_block
                clc
                adc #16
                sta pete_block
                lda #1
                sta pete_dir
                jmp pete_done
pete_42         sec ; Reached new block
                sbc #128
                sta pete_delta
                lda pete_block
                clc
                adc #16
                sta pete_block
                ldx pete_block
                lda 43024,x ; Check south
                bne pete_8
                lda joystick
                and #2
                bne pete_8
pete_7          jmp pete_done ; Just keep moving
pete_8          lda pete_y1 ; Stop moving at block boundary
                sec
                sbc pete_delta
                sta pete_y1
                lda pete_y2
                sbc #0
                sta pete_y2
                lda #0
                sta pete_delta
                sta pete_dir
                jmp pete_done
pete_left       ; Going left
                lda pete_x1
                sec
                sbc #10
                sta pete_x1
                lda pete_x2
                sbc #0
                sta pete_x2
                lda irq_counter ; Animate
                lsr
                lsr
                and #3
                tax
                lda penguin_left,x
                sta pete_frame
                lda pete_delta ; Update delta
                clc
                adc #10
                sta pete_delta
                cmp #192
                bcs pete_43
                lda joystick
                and #8
                bne pete_9
                lda #192 ; Switch direction to right
                sec
                sbc pete_delta
                sta pete_delta
                lda pete_block
                sec
                sbc #1
                sta pete_block
                lda #4
                sta pete_dir
                jmp pete_done
pete_43         sec ; Reached new block
                sbc #192
                sta pete_delta
                lda pete_block
                sec
                sbc #1
                sta pete_block
                ldx pete_block
                lda 43007,x ; Check west
                bne pete_10
                lda joystick
                and #4
                bne pete_10
pete_9          jmp pete_done ; Just keep moving
pete_10         lda pete_x1 ; Stop moving at block boundary
                clc
                adc pete_delta
                sta pete_x1
                lda pete_x2
                adc #0
                sta pete_x2
                lda #0
                sta pete_delta
                sta pete_dir
                jmp pete_done
pete_right      lda pete_x1
                clc
                adc #10
                sta pete_x1
                lda pete_x2
                adc #0
                sta pete_x2
                lda irq_counter ; Animate
                lsr
                lsr
                and #3
                tax
                lda penguin_right,x
                sta pete_frame
                lda pete_delta ; Update delta
                clc
                adc #10
                sta pete_delta
                cmp #192
                bcs pete_44
                lda joystick
                and #4
                bne pete_11
                lda #192 ; Switch direction to left
                sec
                sbc pete_delta
                sta pete_delta
                lda pete_block
                clc
                adc #1
                sta pete_block
                lda #3
                sta pete_dir
                jmp pete_done
pete_44         sec ; Reached new block
                sbc #192
                sta pete_delta
                lda pete_block
                clc
                adc #1
                sta pete_block
                ldx pete_block
                lda 43009,x ; Check east
                bne pete_12
                lda joystick
                and #8
                bne pete_12
pete_11         jmp pete_done ; Just keep moving
pete_12         lda pete_x1 ; Stop moving at block boundary
                sec
                sbc pete_delta
                sta pete_x1
                lda pete_x2
                sbc #0
                sta pete_x2
                lda #0
                sta pete_delta
                sta pete_dir
                jmp pete_done
pete_done       ; Check for new motion

                lda pete_state
                bne pete_13 ; Ignore joystick input for inactive state
                lda pete_dir
                bne pete_13
                lda pete_state
                beq pete_14
pete_13         jmp pete_15
pete_14         ; Check joystick input
                lda joystick
                and #1
                bne pete_16
                ldx pete_block
                lda 42992,x ; Check north
                bne pete_21
                lda #1 ; Free to move
                sta pete_dir
                jmp pete_15
pete_21			ldy ice_active
				bne pete_16
				cmp #2
				beq pete_20
				cmp #3
				beq pete_20
				jmp pete_16
pete_20			sta ice_state ; Ice or coin
				lda penguin_up+1
				sta pete_frame
				txa
				sec
				sbc #16
				sta ice_block
				sta changed_block
				tax
				lda #1 ; Set placeholder block
				sta 43008,x
				sta ice_active
				lda pete_x1
				sta ice_x1
				lda pete_x2
				sta ice_x2
				lda pete_y1
				sec
				sbc #128
				sta ice_y1
				lda pete_y2
				sbc #0
				sta ice_y2
				lda #0
				sta ice_delta
				sta ice_dir
				lda 42992,x ; Check far north
				bne pete_30
 				lda #1 ; Moving ice
				jmp move_ice
pete_30         ldx #1
                jsr start_sound
			    jmp pete_15
pete_16         lda joystick
                and #2
                bne pete_17
                ldx pete_block
                lda 43024,x ; Check south
                bne pete_22
                lda #2 ; Free to move
                sta pete_dir
                jmp pete_15
pete_22			ldy ice_active
				bne pete_17
				cmp #2
				beq pete_23
				cmp #3
				beq pete_23
				jmp pete_17
pete_23			sta ice_state ; Ice or coin
				lda penguin_down+1
				sta pete_frame
				txa
				clc
				adc #16
				sta ice_block
				sta changed_block
				tax
				lda #1 ; Set placeholder block
				sta 43008,x
				sta ice_active
				lda pete_x1
				sta ice_x1
				lda pete_x2
				sta ice_x2
				lda pete_y1
				clc
				adc #128
				sta ice_y1
				lda pete_y2
				adc #0
				sta ice_y2
				lda #0
				sta ice_delta
				sta ice_dir ; Temporary
				lda 43024,x ; Check far south
				bne pete_31
 				lda #2 ; Moving ice
				jmp move_ice
pete_31			ldx #1
                jsr start_sound
                jmp pete_15
pete_17         lda joystick
                and #4
                bne pete_18
                ldx pete_block
                lda 43007,x ; Check west
                bne pete_24
                lda #3 ; Free to move
                sta pete_dir
                jmp pete_15
pete_24			ldy ice_active
				bne pete_18
				cmp #2
				beq pete_25
				cmp #3
				beq pete_25
				jmp pete_18
pete_25			sta ice_state ; Ice or coin
				lda penguin_left+1
				sta pete_frame
				txa
				sec
				sbc #1
				sta ice_block
				sta changed_block
				tax
				lda #1 ; Set placeholder block
				sta 43008,x
				sta ice_active
				lda pete_x1
				sec
				sbc #192
				sta ice_x1
				lda pete_x2
				sbc #0
				sta ice_x2
				lda pete_y1
				sta ice_y1
				lda pete_y2
				sta ice_y2
				lda #0
				sta ice_delta
				sta ice_dir ; Temporary
				lda 43007,x ; Check far west
				bne pete_32
 				lda #3 ; Moving ice
				jmp move_ice
pete_32			ldx #1
                jsr start_sound
                jmp pete_15
pete_18         lda joystick
                and #8
                beq pete_36
                jmp pete_15
pete_36         ldx pete_block
                lda 43009,x ; Check east
                bne pete_26
                lda #4 ; Free to move
                sta pete_dir
                jmp pete_15
pete_26			ldy ice_active
				bne pete_15
				cmp #2
				beq pete_27
				cmp #3
				beq pete_27
				jmp pete_15
pete_27			sta ice_state ; Ice or coin
				lda penguin_right+1
				sta pete_frame
				txa
				clc
				adc #1
				sta ice_block
				sta changed_block
				tax
				lda #1 ; Set placeholder block
				sta 43008,x
				sta ice_active
				lda pete_x1
				clc
				adc #192
				sta ice_x1
				lda pete_x2
				adc #0
				sta ice_x2
				lda pete_y1
				sta ice_y1
				lda pete_y2
				sta ice_y2
				lda #0
				sta ice_delta
				sta ice_dir
				lda 43009,x ; Check far east
				bne pete_35
 				lda #4 ; Moving ice
				jmp move_ice
pete_35         ldx #1
                jsr start_sound
                jmp pete_15

move_ice        sta ice_dir
                lda #0
                sta 43008,x ; Remove placeholde block
                ldx #2
                jsr start_sound
pete_15

				ldx ice_state
				bne ice_1
				jmp ice_5
ice_1 			lda ice_dir
				bne ice_2
				inc ice_delta ; Cracking ice
				lda ice_delta
				lsr
				lsr
				lsr
				cmp #5
				bcs ice_3
				clc ; Animate cracking ice
				adc #69
				cpx #3
				bne ice_4
				clc
				adc #6
ice_4 			sta ice_frame
				jmp ice_5
ice_3 			lda ice_state ; Completely crushed
				cmp #2
				bne ice_14
				ldy #$5 ; Ordinary ice
                jsr update_score
				jmp ice_15
ice_14			ldy #$25 ; Coin
                jsr update_score
                ldx #4
                jsr start_sound
				inc coin_counter
				lda coin_counter
				cmp #5
				bne ice_15
                ; All coins taken
                lda #1
                sta pete_state
                jsr deactivate_flames
                lda #0
                sta irq_counter

ice_15			lda #0
				sta ice_active
				ldx ice_block
				sta 43008,x ; Clear block
				sta ice_state
				sta ice_x1
				sta ice_x2
				sta ice_delta
				jmp ice_5
ice_2 			lda #68
				sta ice_frame
				lda ice_state
				cmp #3
				bne ice_7
				lda #74
				sta ice_frame
ice_7			lda ice_dir
 				cmp #1
				bne ice_6
				lda ice_y1 ; Going up
                sec
                sbc #16
                sta ice_y1
                lda ice_y2
                sbc #0
                sta ice_y2
                lda ice_delta ; Update delta
                clc
                adc #16
                sta ice_delta
                cmp #128
                bcc ice_8
                sec ; Reached new block
                sbc #128
                sta ice_delta
                lda ice_block
                sec
                sbc #16
                sta ice_block
                ldx ice_block
                lda 42992,x ; Check north
                beq ice_8
                jsr stop_ice
ice_8          	jmp ice_5
ice_6 			cmp #2
				bne ice_10
				lda ice_y1 ; Going down
                clc
                adc #16
                sta ice_y1
                lda ice_y2
                adc #0
                sta ice_y2
                lda ice_delta ; Update delta
                clc
                adc #16
                sta ice_delta
                cmp #128
                bcc ice_11
                sec ; Reached new block
                sbc #128
                sta ice_delta
                lda ice_block
                clc
                adc #16
                sta ice_block
                ldx ice_block
                lda 43024,x ; Check south
                beq ice_11
                jsr stop_ice
ice_11          jmp ice_5 ; Just keep moving
ice_10			cmp #3
				bne ice_12
				lda ice_x1 ; Going left
                sec
                sbc #16
                sta ice_x1
                lda ice_x2
                sbc #0
                sta ice_x2
                lda ice_delta ; Update delta
                clc
                adc #16
                sta ice_delta
                cmp #192
                bcc ice_13
                sec ; Reached new block
                sbc #192
                sta ice_delta
                lda ice_block
                sec
                sbc #1
                sta ice_block
                ldx ice_block
                lda 43007,x ; Check west
                beq ice_13
                jsr stop_ice
ice_13          jmp ice_5
ice_12 			cmp #4
				bne ice_5
				lda ice_x1 ; Going right
                clc
                adc #16
                sta ice_x1
                lda ice_x2
                adc #0
                sta ice_x2
                lda ice_delta ; Update delta
                clc
                adc #16
                sta ice_delta
                cmp #192
                bcc ice_5
                sec ; Reached new block
                sbc #192
                sta ice_delta
                lda ice_block
                clc
                adc #1
                sta ice_block
                ldx ice_block
                lda 43009,x ; Check east
                beq ice_5
                jsr stop_ice
ice_5


                ; Handle flames
                ldy #0
flame_2         lda levflame_types,y
                bne flame_1
                jmp flame_3
flame_1         lda flame_state,y
                beq flame_14
                jmp flame_4
flame_14        inc random_pos ; Not active yet. Try to place at side of screen
                ldx random_pos
                lda random_table,x
                and #112
                clc
                adc #32
                tax
                lda pete_state
                beq flame_18
                ldx #0 ; Don't start new flames if Pete is inactive
flame_18        lda pete_x2
                cmp #5
                bcc flame_9
                txa ; Put flame at left side of screen
                ora #1
                jmp flame_13
flame_9         txa ; Put flame at right side of screen
                ora #12
flame_13        tax
                lda 43008,x
                bne flame_8
                txa ; Empty space. Put flame here.
                sta flame_block,y
                and #1 ; Set x depending on screen position
                beq flame_10
                lda #1 ; Left side
                sta flame_x2,y
                lda #64
                sta flame_x1,y
                jmp flame_11
flame_10        lda #9 ; Right side
                sta flame_x2,y
                lda #128
                sta flame_x1,y
flame_11        lda #0
                sta flame_dir,y
                sta flame_count,y
                sta flame_delta,y
                lda #7
                sta flame_color,y
                lda #51
                sta flame_frame,y ; Invisible in first cycle
                lda #1
                sta flame_state,y
                lda flame_block,y
                and #240
                sta 224
                lda #0
                asl 224
                rol
                asl 224
                rol
                asl 224
                rol
                sta 225
                lda 224
                clc
                adc #16
                sta flame_y1,y
                lda 225
                adc #2
                sta flame_y2,y ; All done
                ldx #6
                jsr start_sound
flame_8         jmp flame_3
flame_4         cmp #1 ; Check if initiating
                bne flame_5
                lda irq_counter
                lsr
                lsr
                and #3
                ora #24
                sta flame_frame,y
                lda flame_count,y
                tax
                inx
                txa
                sta flame_count,y
                cmp #100
                bne flame_6
                lda #2 ; Initiation done. Activate.
                sta flame_state,y
flame_6         jmp flame_3
flame_5         cmp #3 ; Check if score symbol
                bne flame_15
                lda #0 ; Black color
                sta flame_color,y
                lda irq_counter
                lsr
                lsr
                and #1
                ora #52
                sta flame_frame,y
                lda flame_y1,y
                sec
                sbc #2
                sta flame_y1,y
                lda flame_y2,y
                sbc #0
                sta flame_y2,y
                lda flame_count,y
                tax
                inx
                txa
                sta flame_count,y
                cmp #50
                bcc flame_19
                cmp #100
                bcs flame_7
                lda irq_counter
                and #1
                bne flame_19
                lda #51
                sta flame_frame,y  ; Make score symbol flicker
flame_19        jmp flame_3
flame_7         lda #0 ; Reached end of life
                sta flame_state,y
                sta flame_y1,y
                sta flame_y2,y
                jmp flame_3
flame_15        ; Active state
                lda irq_counter
                lsr
                lsr
                tax
                lda levflame_types,y
                cmp #1
                bne flame_16
                txa
                and #7
                tax
                lda flame_frames,x
                jmp flame_17
flame_16        txa
                and #3
                ora #28
flame_17        sta flame_frame,y
				; Handle motion
				lda flame_dir,y
 				cmp #1
				bne flame_21
				lda flame_y1,y ; Going up
                sec
                sbc flame_speed,y
                sta flame_y1,y
                lda flame_y2,y
                sbc #0
                sta flame_y2,y
                lda flame_delta,y ; Update delta
                clc
                adc flame_speed,y
                sta flame_delta,y
                cmp #128
                bcc flame_22
                sec ; Reached new block
                sbc #128
                sta flame_delta,y
                lda flame_block,y
                sec
                sbc #16
                sta flame_block,y
                lda flame_block,y
                tax
                lda 42992,x ; Check north
                beq flame_22
                lda flame_delta,y ; Stop flame
                clc
                adc flame_y1,y
                sta flame_y1,y
                lda flame_y2,y
                adc #0
                sta flame_y2,y
                lda #0
                sta flame_dir,y
                sta flame_delta,y
flame_22        jmp flame_30
flame_21 		cmp #2
				bne flame_23
				lda flame_y1,y ; Going down
                clc
                adc flame_speed,y
                sta flame_y1,y
                lda flame_y2,y
                adc #0
                sta flame_y2,y
                lda flame_delta,y ; Update delta
                clc
                adc flame_speed,y
                sta flame_delta,y
                cmp #128
                bcc flame_24
                sec ; Reached new block
                sbc #128
                sta flame_delta,y
                lda flame_block,y
                clc
                adc #16
                sta flame_block,y
                lda flame_block,y
                tax
                lda 43024,x ; Check south
                beq flame_24
                lda flame_y1,y ; Stop flame
                sec
                sbc flame_delta,y
                sta flame_y1,y
                lda flame_y2,y
                sbc #0
                sta flame_y2,y
                lda #0
                sta flame_dir,y
                sta flame_delta,y
flame_24        jmp flame_30 ; Just keep moving
flame_23		cmp #3
				bne flame_25
				lda flame_x1,y ; Going left
                sec
                sbc flame_speed,y
                sta flame_x1,y
                lda flame_x2,y
                sbc #0
                sta flame_x2,y
                lda flame_delta,y ; Update delta
                clc
                adc flame_speed,y
                sta flame_delta,y
                cmp #192
                bcc flame_26
                sec ; Reached new block
                sbc #192
                sta flame_delta,y
                lda flame_block,y
                sec
                sbc #1
                sta flame_block,y
                lda flame_block,y
                tax
                lda 43007,x ; Check west
                beq flame_26
                lda flame_delta,y ; Stop flame
                clc
                adc flame_x1,y
                sta flame_x1,y
                lda flame_x2,y
                adc #0
                sta flame_x2,y
                lda #0
                sta flame_dir,y
                sta flame_delta,y
flame_26        jmp flame_30
flame_25 		cmp #4
				bne flame_30
				lda flame_x1,y ; Going right
                clc
                adc flame_speed,y
                sta flame_x1,y
                lda flame_x2,y
                adc #0
                sta flame_x2,y
                lda flame_delta,y ; Update delta
                clc
                adc flame_speed,y
                sta flame_delta,y
                cmp #192
                bcc flame_30
                sec ; Reached new block
                sbc #192
                sta flame_delta,y
                lda flame_block,y
                clc
                adc #1
                sta flame_block,y
                lda flame_block,y
                tax
                lda 43009,x ; Check east
                beq flame_30
                lda flame_x1,y ; Stop flame
                sec
                sbc flame_delta,y
                sta flame_x1,y
                lda flame_x2,y
                sbc #0
                sta flame_x2,y
                lda #0
                sta flame_dir,y
                sta flame_delta,y

flame_30 		; Find new direction
				lda flame_dir,y
				bne flame_31
				inc random_pos ; Random direction
				ldx random_pos
				lda random_table,x
				and #3
				clc
				adc #1
				sta flame_dir,y

flame_31 		lda flame_block,y ; Track penguin
				tax
				lda pete_block
				and #15
				sta 224
				lda pete_block
				and #240
				sta 227
				lda flame_delta,y
				bne flame_37
				lda flame_block,y
				and #15
				sta 225
				clc
				adc #1
				sec
				sbc 224
				bcc flame_38
				cmp #3
				bcs flame_38
				; Sideways block difference is between -1 and 1
				lda flame_block,y
				and #240
				cmp 227
				beq flame_38 ; Don't move vertically if objects are already equal level
				bcs flame_39
				lda 43024,x
				bne flame_37
				lda #2
				sta flame_dir,y
				jmp flame_37
flame_39		lda 42992,x
				bne flame_37
				lda #1
				sta flame_dir,y
				jmp flame_37
flame_38 		lda 227
				lsr
				lsr
				lsr
				lsr
				sta 226
				lda flame_block,y
				and #240
				lsr
				lsr
				lsr
				lsr
				clc
				adc #1
				sec
				sbc 226
				bcc flame_37
				cmp #3
				bcs flame_37
				; Vertical block difference is between -1 and 1
				lda 225
				cmp 224
				bcs flame_40
				lda 43009,x
				bne flame_37
				lda #4
				sta flame_dir,y
				jmp flame_37
flame_40		lda 43007,x
				bne flame_37
				lda #3
				sta flame_dir,y
flame_37

				lda flame_dir,y ; Check viability of chosen direction
				cmp #1
				bne flame_32
				lda 42992,x ; Check north
				beq flame_36
				lda #0
				sta flame_dir,y
				jmp flame_36
flame_32 		cmp #2
				bne flame_33
				lda 43024,x ; Check south
				beq flame_36
				lda #0
				sta flame_dir,y
				jmp flame_36
flame_33 		cmp #3
				bne flame_34
				lda 43007,x ; Check west
				beq flame_36
				lda #0
				sta flame_dir,y
				jmp flame_36
flame_34 		cmp #4
				bne flame_36
				lda 43009,x ; Check east
				beq flame_36
				lda #0
				sta flame_dir,y
flame_36

                ; Check if ice is moving
		        lda ice_state
                beq flame_20
                lda ice_dir
                beq flame_20
                ; Check ice collision
                lda flame_y,y
                clc
                adc #10 ; Check if y diff is between -10 and +10
                sec
                sbc ice_y
                sta 224
                and #128
                bne flame_20
                lda 224
                cmp #20
                bcs flame_20
                lda flame_x1,y ; Check if x diff is between -128 and +128
                clc
                adc #128
                sta 224
                lda flame_x2,y
                adc #0
                sta 225
                lda 224
                sec
                sbc ice_x1
                lda 225
                sbc ice_x2
                bne flame_20
                lda #3 ; Time to snuff flame
                sta flame_state,y
                lda #0
                sta flame_count,y
                lda #200
                sta flame_block,y
                ldx #7
                jsr start_sound
                tya
                tax
                ldy #$50 ; Award 50 points
                jsr update_score
                txa
                tay
flame_20        ; Check for player collision
                lda collisions_on ; Only check if penguin/flame collisions are turned on
                beq flame_3
                lda flame_y,y
                clc
                adc #10 ; Check if y diff is between -10 and +10
                sec
                sbc pete_y
                sta 224
                and #128
                bne flame_3
                lda 224
                cmp #20
                bcs flame_3
                lda flame_x1,y ; Check if x diff is between -128 and +128
                clc
                adc #128
                sta 224
                lda flame_x2,y
                adc #0
                sta 225
                lda 224
                sec
                sbc pete_x1
                lda 225
                sbc pete_x2
                bne flame_3
                ; Kill player and deactivate flames
                lda #2
                sta pete_state
                jsr deactivate_flames
                ldx #8
                jsr start_sound
                lda #0
                sta irq_counter
flame_3         iny
                cpy #4
                beq flame_12
                jmp flame_2
flame_12        ; All done


                ; Sorting of positions

                ; Compute screen y values
                lda pete_y2 ; Pete
                sta 223
                lda pete_y1
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                sta pete_y

                ldx #0 ; Flames
gloop_30        lda flame_y2,x
                sta 223
                lda flame_y1,x
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                sta flame_y,x
                inx
                cpx #4
                bne gloop_30

                lda ice_y2 ; Ice
                sta 223
                lda ice_y1
                lsr 223
                ror
                lsr 223
                ror
                lsr 223
                ror
                sta ice_y

                lda pete_x2 ; Pete sorting value
                sta 221
                lda pete_x1
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                sta 220
                lda pete_y
                lsr
                clc
                adc 220
                sta sort_val

                ldx #0
gloop_31        lda flame_x2,x ; Flame sorting value
                sta 221
                lda flame_x1,x
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                sta 220
                lda flame_y,x
                lsr
                clc
                adc 220
                sta sort_val+1,x
                inx
                cpx #4
                bne gloop_31

                lda ice_x2 ; Ice sorting value
                sta 221
                lda ice_x1
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                lsr 221
                ror
                sta 220
                lda ice_y
                lsr
                clc
                adc 220
                sta sort_val+5


                ldx #0 ; Set sorting indexes
gloop_15        txa
                sta sort_ix,x
                inx
                cpx #6
                bne gloop_15

                ; Begin sorting algorithm
                ldy #0
gloop_17        tya
                tax
                inx
gloop_18        lda sort_val,y
                cmp sort_val,x
                bcs gloop_16
                sta 220
                lda sort_val,x
                sta sort_val,y
                lda 220
                sta sort_val,x
                lda sort_ix,y
                sta 220
                lda sort_ix,x
                sta sort_ix,y
                lda 220
                sta sort_ix,x
gloop_16        inx
                cpx #6
                bne gloop_18
                iny
                cpy #5
                bne gloop_17

                lda joystick ; Music on/off switch
                and #16
                cmp joystick_old
                beq gloop_35
                sta joystick_old
                cmp #0
                bne gloop_35
                lda topsprite_frame+7
                eor #1
                sta topsprite_frame+7
gloop_35
                lda topsprite_frame+7
                cmp #98
                bne gloop_34
                lda pete_state
                bne gloop_34
                jsr play_music
gloop_34

                asl $d019
                jmp $ea81

;=========================
; Highscore initials
;=========================

enter_name      inc irq_counter

                lda 56320       ; Check joystick
                and 56321
                cmp joystick_old
                beq entnam_1
                sta joystick_old
                and #4
                bne entnam_2
                lda cursor_pos
                beq entnam_1
                dec cursor_pos ; Move left
entnam_2        lda joystick_old
                and #8
                bne entnam_3
                lda cursor_pos
                cmp #2
                beq entnam_1
                inc cursor_pos
entnam_3        lda joystick_old
                and #1
                bne entnam_4
                ldx cursor_pos
                lda initials,x
                tay
                iny
                cpy #47
                bne entnam_6
                ldy #65
entnam_6        cpy #91
                bne entnam_7
                ldy #46
entnam_7        tya
                sta initials,x
entnam_4        lda joystick_old
                and #2
                bne entnam_5
                ldx cursor_pos
                lda initials,x
                tay
                dey
                cpy #45
                bne entnam_8
                ldy #90
entnam_8        cpy #64
                bne entnam_9
                ldy #46
entnam_9        tya
                sta initials,x
entnam_5        lda joystick_old
                and #16
                bne entnam_1
                ; All done
                lda #9
                sta game_state

entnam_1 		lda irq_counter ; Set cursor color
                lsr
                lsr
                and #7
                tax
                lda cursor_colors,x
                sta 53294

                lda cursor_pos ; Set cursor X position
                asl
                asl
                asl
                asl
                clc
                adc #158
                sta 53262

                ; Draw initials
                sei
                lda 1       ; Make character set readable
                and #251
                sta 1

                lda #200 ; Initial bitmap position
                sta 226
                lda #112
                sta 227
                lda #0
                sta 223
entnam_10       ldx 223
                lda initials,x
                asl
                sta 224 ; Character set data
                ldy #0
                sty 225
                asl 224
                rol 225
                asl 224
                rol 225
                lda 225
                adc #216
                sta 225

       			ldx #0
entnam_11		lda #0
				sta 228
				sta 229
				txa
				tay
				lda (224),y
				sta 230
				ldy #0
entnam_13		asl 228
				rol 229
				asl 228
				rol 229
				asl 230
				bcc entnam_12
				lda 228
				ora #3
				sta 228
entnam_12		iny
				cpy #8
				bne entnam_13
				txa
				tay
				lda 229
				sta (226),y
				tya
				ora #8
				tay
				lda 228
				sta (226),y
                inx
                cpx #8
                bne entnam_11

                lda 226
                clc
                adc #16
                sta 226
                lda 227
                adc #0
                sta 227

                inc 223
                lda 223
                cmp #3
                bne entnam_10

				lda 1       ; Turn off character set readability
                ora #4
                sta 1
                cli


                asl $d019
                jmp $ea81


;======================
; Intro state change management
;=======================

prepare_dummy       nop
                    rts

prepare_firstline   lda #0
                    sta line_counter
                    rts

prepare_toplines    lda #34
                    clc
                    adc line_counter
                    sta line_counter
                    rts

prepare_walkin      lda #11     ; Set penguin and shadow colors
                    sta 53291
                    lda #0
                    sta 53292
                    lda #192    ; Set y positions
                    sta 53257
                    lda #195
                    sta 53259
                    rts

prepare_ice1        lda #3      ; Ice block and shadow colors
                    sta 53287
                    sta 53289
                    lda #14
                    sta 53288
                    sta 53290
                    lda #0
                    sta 53293
                    sta 53294
                    lda #68     ; Frames
                    sta 24568
                    lda #56
                    sta 24569
                    lda #74
                    sta 24570
                    lda #62
                    sta 24571
                    lda #54
                    sta 24574
                    sta 24575
                    lda #4     ; New penguin frame
                    sta 24572
                    lda #36
                    sta 24573
                    lda #192    ; Y values
                    sta 53249
                    sta 53253
                    lda #195
                    sta 53251
                    sta 53255
                    lda #200
                    sta 53261
                    sta 53263
                    rts

prepare_flame1      lda #64     ; Move sprite 6 to right of screen
                    sta 53264
                    lda #255
                    sta 53260
                    lda #192
                    sta 53261
                    lda #7      ; Set to yellow
                    sta 53293
                    lda #4     ; New penguin frame
                    sta 24572
                    lda #36
                    sta 24573
                    rts

prepare_flame2      lda #0      ; Move flame to the left of the screen
                    sta 53264
                    sta 53260
                    rts

prepare_ice3        lda #207    ; Move them all to the righ of the screen
                    sta 53264
                    lda #255
                    sta 53248
                    sta 53250
                    sta 53252
                    sta 53254
                    sta 53260
                    sta 53262
                    lda #200    ; Set Y value
                    sta 53261
                    sta 53263
                    lda #0      ; Set color
                    sta 53293
                    lda #54     ; Set frames
                    sta 24574
                    lda #68
                    sta 24568
                    lda #56
                    sta 24569
                    rts

prepare_highscore   lda #68
                    clc
                    adc line_counter
                    sta line_counter
                    rts

;=====================
; Intro management
;=====================

handle_dummy        nop
                    rts


handle_curtain      lda #107 ; Base position
                    sta 252
                    lda #64
                    sta 251
            		ldx #0
handcur_1			lda curtain,x      ; Draw even lines
					clc
					adc irq_counter
                    cmp #16
                    bcc handcur_2
                    cmp #80
                    bcs handcur_2
                    sec
                    sbc #16
                    asl
                    ldy 251
                    sty 253
                    ldy 252
                    sty 254
                    tay
                    and #248
                    lsr
                    lsr
                    lsr
                    sta 221
                    clc
                    adc 254
                    sta 254
                    lda #0
                    sta 220
                    lsr 221
                    ror 220
                    lsr 221
                    ror 220
                    tya
                    and #7
                    adc 220
                    adc 253
                    sta 253
                    lda 221
                    adc 254
                    sta 254
                    lda gradient_pixels,y
                    ldy #0
                    sta (253),y

handcur_2           lda curtain,x   ; Draw odd lines
                    clc
                    adc irq_counter
                    cmp #32
                    bcc handcur_3
                    cmp #96
                    bcs handcur_3
                    sec
                    sbc #32
                    asl
                    ora #1
                    ldy 251
                    sty 253
                    ldy 252
                    sty 254
                    tay
                    and #248
                    lsr
                    lsr
                    lsr
                    sta 221
                    clc
                    adc 254
                    sta 254
                    lda #0
                    sta 220
                    lsr 221
                    ror 220
                    lsr 221
                    ror 220
                    tya
                    and #7
                    adc 220
                    adc 253
                    sta 253
                    lda 221
                    adc 254
                    sta 254
                    lda gradient_pixels,y
                    ldy #0
                    sta (253),y

handcur_3           clc
                    lda #8 ; Move base pos 8 pixels to the right
                    adc 251
                    sta 251
                    lda #0
                    adc 252
                    sta 252
					inx
					cpx #40
					beq handcur_4
                    jmp handcur_1
handcur_4			rts

handle_firetext lda #<line1 ; Fire to start
                sta charset1+1
                lda #>line1
                sta charset1+2
                lda irq_counter
                ora #208
                sta 220
                lda #124
                sta 221
                lda 1       ; Make character set readable
                and #251
                sta 1
                jsr drawline
                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                rts

handle_toptext  lda #<line2     ; Obtain address of text
                sta charset1+1
                lda #>line2
                sta charset1+2
                lda line_counter
                ldy irq_counter
                cpy #8
                bcc handtop_2
                clc
                adc #17
handtop_2       adc charset1+1
                sta charset1+1
                lda charset1+2
                adc #0
                sta charset1+2

                lda #88     ; Determine screen position
                sta 220
                lda #112
                sta 221
                ldy irq_counter
                cpy #8
                bcc handtop_1
                lda #216
                sta 220
                lda #114
                sta 221
handtop_1       tya
                and #7
                ora 220
                sta 220
                lda 1       ; Make character set readable
                and #251
                sta 1
                jsr drawline
                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                rts

handle_wipe     lda #64 ; Base position
                sta 251
                lda #112
                sta 252
                lda irq_counter ; Compute draw position
                asl
                asl
                asl
                tay
                lda 252
                adc #0
                sta 254
                tya
                adc 251
                sta 253
                lda 254
                adc #0
                sta 254
                ldx #0
handwipe_2      ldy #0          ; Clear pass
handwipe_1      lda (251),y
                sta (253),y
                iny
                cpy #8
                bne handwipe_1
                clc
                lda 253
                adc #24
                sta 253
                lda 254
                adc #0
                sta 254
                ldy #0
handwipe_3      lda (253),y     ; Semi-clear pass
                and #51
                sta (253),y
                lda (251),y
                and #204
                ora (253),y
                sta (253),y
                iny
                cpy #8
                bne handwipe_3
                sec
                lda 253
                sbc #24
                sta 253
                lda 254
                sbc #0
                sta 254

                clc
                lda 251
                adc #64
                sta 251
                lda 252
                adc #1
                sta 252
                lda 253
                adc #64
                sta 253
                lda 254
                adc #1
                sta 254
                inx
                cpx #6
                bne handwipe_2
                rts

handle_walkin   lda irq_counter
                asl
                sta 53256   ; Set positions
                clc
                adc #4
                sta 53258
                lda irq_counter ; Set animation frame
                lsr
                lsr
                and #3
                tax
                lda penguin_right,x
                sta 24572
                ora #32
                sta 24573
                rts

handle_ice1     lda irq_counter     ; Move ice onto screen
                cmp #92
                bcs handice1_1
                asl
                sta 53248
                sta 53250
                clc
                adc #24
                sta 53260
                rts
handice1_1      sec
                sbc #92
                asl
                sta 53252
                sta 53254
                adc #24
                sta 53262
                rts

handle_ice2     lda irq_counter
                cmp #16
                bcs handice2_1
                eor #15 ; Move penguin
                clc
                adc #104
                asl
                sta 53256   ; Set positions
                clc
                adc #4
                sta 53258
                lda irq_counter
                lsr
                lsr
                and #3
                tax
                lda penguin_left,x
                sta 24572
                ora #32
                sta 24573
                rts
handice2_1      and #15     ; Move ice
                eor #15
                clc
                adc #76
                asl
                sta 53248
                sta 53250
                clc
                adc #24
                sta 53260
                rts

handle_crush1   lda irq_counter
                cmp #16
                bcs handcru1_1
                eor #15 ; Move penguin
                clc
                adc #88
                asl
                sta 53256   ; Set positions
                clc
                adc #4
                sta 53258
                lda irq_counter
                lsr
                lsr
                and #3
                tax
                lda penguin_left,x
                sta 24572
                ora #32
                sta 24573
                rts
handcru1_1      ldy #0      ; Remove shadow
                sty 53260
                cmp #36     ; Crush ice
                bcs handcru1_2
                sec
                sbc #16
                lsr
                lsr
                clc
                adc #69     ; Frames
                sta 24568
                sec
                sbc #12
                sta 24569
                rts
handcru1_2      lda #0      ; Move sprites offscreen
                sta 53248
                sta 53250
                rts

handle_flame1   lda irq_counter
                cmp #100
                bcs handfla1_1
                lda #100
                sec
                sbc irq_counter
                sta 53260
                jmp handfla1_2
handfla1_1      sec
                sbc #100
                sta 53260
handfla1_2      lsr
                lsr
                clc
                and #7
                tax
                lda flame_frames,x
                sta 24574
                rts

handle_flame2   lda irq_counter
                cmp #80
                bcs handfla2_1
                sta 53260          ; Move flame in
                jmp handfla2_3
handfla2_1      cmp #92
                bcs handfla2_2
                lda #91     ; Move penguin
                sec
                sbc irq_counter
                clc
                adc #76
                asl
                sta 53256   ; Set positions
                clc
                adc #4
                sta 53258
                lda irq_counter
                lsr
                lsr
                and #3
                tax
                lda penguin_left,x
                sta 24572
                ora #32
                sta 24573
                jmp handfla2_3
handfla2_2      lda #156
                sec
                sbc irq_counter
                asl
                sta 53252
                sta 53254
                adc #24
                sta 53262
handfla2_3      lda irq_counter
                cmp #124
                bcs handfla2_4
                lsr         ; Normal flame animation
                lsr
                clc
                and #7
                tax
                lda flame_frames,x
                sta 24574
                rts
handfla2_4      dec 53261
                lda #0      ; Move shadow offscreen
                sta 53263
                sta 53293   ; Set color of score sprite
                lda irq_counter
                lsr
                lsr
                and #1
                ora #52
                sta 24574
                rts

handle_flame3   dec 53261       ; Keep moving score up
                lda irq_counter
                lsr
                lsr
                and #1
                ora #52
                sta 24574
                lda irq_counter ; Flicker on/off
                and #1
                beq handfla3_1
                lda #0
                sta 53260
                rts
handfla3_1      lda #79
                sta 53260
                rts

handle_ice3     lda irq_counter
                cmp #60
                bcs handice3_1
                lda #59     ; Move coin block
                sec
                sbc irq_counter
                asl
                sta 53252
                sta 53254
                adc #24
                sta 53262
                rts
handice3_1      cmp #110
                bcs handice3_2
                lda #121
                sec
                sbc irq_counter
                asl
                sta 53248
                sta 53250
                adc #24
                sta 53260
handice3_2      rts

handle_ice4		lda irq_counter
				cmp #41
				bcs handice4_1
				clc
				adc #76
				asl
				sta 53256   ; Set positions
                clc
                adc #4
                sta 53258
                lda irq_counter
                lsr
                lsr
                and #3
                tax
                lda penguin_right,x
                sta 24572
                ora #32
                sta 24573
                rts
handice4_1		cmp #61
				bcs handice4_2
				sec
				sbc #41
				lsr
				lsr
				clc
				adc #75     ; Frames
                sta 24570
                sec
                sbc #12
                sta 24571
				rts
handice4_2		ldy #0		; Remove ice
				sty 53253
				sty 53255
				lsr			; Animate penguin
				lsr
				lsr
				lsr
				and #1
				ora #12
				sta 24572
                ora #32
                sta 24573
				rts

handle_highscore lda #<line16     ; Obtain address of text
                sta charset1+1
                lda #>line16
                sta charset1+2
				lda #88     ; Determine screen position
                sta 220
                lda #112
                sta 221
                ldy irq_counter
                cpy #8
				bcc handhigh_1
				tya
				and #248
				asl
				sta 251
				lsr
				lsr
				lsr
				lsr
				ora 251
				clc
				adc line_counter
				adc charset1+1
				sta charset1+1
                lda charset1+2
                adc #0
                sta charset1+2
                tya
                lsr
                lsr
                lsr
                tax
                inx
                clc
handhigh_2      lda 220
                adc #64
                sta 220
                lda 221
                adc #1
                sta 221
                dex
                bne handhigh_2
handhigh_1		tya
                and #7
                ora 220
                sta 220
                lda 1       ; Make character set readable
                and #251
                sta 1
                jsr drawline
                lda 1       ; Turn off character set readability
                ora #4
                sta 1
                rts

;========================================
; Clear entire screen from top to bottom
;=========================================

irq_fade            lda #96 ; Base position
                    sta 252
                    lda #0
                    sta 251
                    ldx #0
irqfad_1            lda curtain,x      ; Draw even lines
                    clc
                    adc irq_counter
                    cmp #16
                    bcc irqfad_2
                    cmp #116
                    bcs irqfad_2
                    sec
                    sbc #16
                    asl
                    ldy 251
                    sty 253
                    ldy 252
                    sty 254
                    tay
                    and #248
                    lsr
                    lsr
                    lsr
                    sta 221
                    clc
                    adc 254
                    sta 254
                    lda #0
                    sta 220
                    lsr 221
                    ror 220
                    lsr 221
                    ror 220
                    tya
                    and #7
                    adc 220
                    adc 253
                    sta 253
                    lda 221
                    adc 254
                    sta 254
                    lda #0
                    tay
                    sta (253),y

irqfad_2            lda curtain,x   ; Draw odd lines
                    clc
                    adc irq_counter
                    cmp #32
                    bcc irqfad_3
                    cmp #132
                    bcs irqfad_3
                    sec
                    sbc #32
                    asl
                    ora #1
                    ldy 251
                    sty 253
                    ldy 252
                    sty 254
                    tay
                    and #248
                    lsr
                    lsr
                    lsr
                    sta 221
                    clc
                    adc 254
                    sta 254
                    lda #0
                    sta 220
                    lsr 221
                    ror 220
                    lsr 221
                    ror 220
                    tya
                    and #7
                    adc 220
                    adc 253
                    sta 253
                    lda 221
                    adc 254
                    sta 254
                    lda #0
                    tay
                    sta (253),y

irqfad_3            clc
                    lda #8 ; Move base pos 8 pixels to the right
                    adc 251
                    sta 251
                    lda #0
                    adc 252
                    sta 252
                    inx
                    cpx #40
                    beq irqfad_4
                    jmp irqfad_1
irqfad_4
                    inc irq_counter
                    lda irq_counter
                    cmp #132
                    bne irqfad_5
                    ldx #5 ; New game state -- increase level
                    lda level
                    cmp #15
                    bne irqfad_6
                    ldx #10 ; Special case after level 16 -- party
irqfad_6            stx game_state

irqfad_5            asl $d019
                    jmp $ea81


;=================================================
; Party sequence, animate Pete
;==================================================

irq_party       inc irq_counter
                lda irq_counter
                and #1
                beq irqpar_2
                inc slow_counter
irqpar_2        lda slow_counter
                lsr
                lsr
                and #3
                tax
                lda penguin_down,x
                sta 24569
                ora #32
                sta 24570
                clc
                adc #65
                sta 24568

                jsr play_music

                lda slow_counter
                cmp irq_target
                bne irqpar_1
                lda #5
                sta game_state
irqpar_1        asl $d019
                jmp $ea81


;====================================
; Start sound effect with x register
; value
;====================================

start_sound     cpx sound_effect ; Must have higher priority
                bcs startsou_2
                lda sound_counter
                cmp #10 ; or current sound has less than 10 cycles left
                bcs startsou_1
startsou_2      stx sound_effect
                lda #0
                sta 54290
                lda snd_attack,x
                sta 54291
                lda snd_decay,x
                sta 54292
                lda snd_freq2,x
                sta 54287
                lda snd_wave,x
                sta 54290
                lda snd_time,x
                sta sound_counter
startsou_1      rts

;==================================
; Play sound effect
;==================================

play_sound      lda sound_effect
                bne playsou_1
                rts
playsou_1       cmp #1
                bne playsou_5
                lda sound_counter ; Crushed ice
                clc
                adc #90
                sta 54287
                ldx #33
                and #2
                beq playsou_3
                ldx #129
playsou_3       stx 54290
                jmp playsou_2
playsou_5       cmp #2
                bne playsou_6
                lda sound_counter ; Pushed ice
                asl
                asl
                asl
                adc #40
                sta 54287
playsou_6       cmp #4
                bne playsou_7
                lda irq_counter ; Taken coin
                and #7
                asl
                asl
                asl
                asl
                adc #60
                sta 54287
                jmp playsou_2
playsou_7       cmp #6
                bne playsou_8
                lda irq_counter ; Starting flame
                and #7
                asl
                asl
                asl
                asl
                adc #80
                sta 54287
                jmp playsou_2
playsou_8       cmp #7
                bne playsou_9
                lda irq_counter ; Snuff flame
                and #7
                asl
                asl
                asl
                asl
                adc #20
                sta 54287
                jmp playsou_2
playsou_9       cmp #8
                bne playsou_11
                lda sound_counter
                asl
                asl
                sta 54287
                lda sound_counter
                ldx #17
                and #1
                beq playsou_10
                ldx #129
playsou_10      stx 54290
                jmp playsou_2
playsou_11      nop
playsou_2       dec sound_counter
                lda sound_counter
                bne playsou_4
                lda #0
                sta sound_effect
playsou_4       rts

;===================================
; Start music
;===================================

start_menu_music
                lda #<song_voice1
                sta voice1start1
                lda #>song_voice1
                sta voice1start2
                lda #<song_voice2
                sta voice2start1
                lda #>song_voice2
                sta voice2start2
                jmp start_music

start_ingame_music
                lda #<ingame_voice1
                sta voice1start1
                lda #>ingame_voice1
                sta voice1start2
                lda #<ingame_voice2
                sta voice2start1
                lda #>ingame_voice2
                sta voice2start2
                jmp start_music

start_party_music
                lda #<party_voice1
                sta voice1start1
                lda #>party_voice1
                sta voice1start2
                lda #<party_voice2
                sta voice2start1
                lda #>party_voice2
                sta voice2start2
                jmp start_music

start_music     lda #0
                sta voice1count
                sta voice1arp
                sta voice2count
                sta voice2arp
                lda #<song_reset
                sta voice1pos1
                sta voice2pos1
                lda #>song_reset
                sta voice1pos2
                sta voice2pos2
                rts

;===================================
; Play music
;===================================

play_music      lda voice1pos1
                sta 220
                lda voice1pos2
                sta 221
                ldy #0
                lda (220),y
                cmp voice1count
                bne playmus_1
                lda #0
                sta voice1count
                sta voice1arp
                ldy #1
                lda (220),y
                clc
                adc #2
                adc 220
                sta 220
                lda 221
                adc #0
                sta 221
                ldy #0
                lda (220),y
                cmp #255
                bne playmus_2
                lda voice1start1
                sta 220
                lda voice1start2
                sta 221
playmus_2       lda 220
                sta voice1pos1
                lda 221
                sta voice1pos2
                lda #0 ; Restart note
                sta 54276
                lda #8
                sta 54277
                lda #0
                sta 54278
                lda #17
                sta 54276
playmus_1       ldy voice1arp
                iny
                iny
                lda (220),y
                tax
                lda notes_low,x
                sta 54272
                lda notes_high,x
                sta 54273
                inc voice1arp
                ldy #1
                lda (220),y
                cmp voice1arp
                bne playmus_3
                lda #0
                sta voice1arp
playmus_3       inc voice1count

                lda voice2pos1
                sta 220
                lda voice2pos2
                sta 221
                ldy #0
                lda (220),y
                cmp voice2count
                bne playmus_4
                lda #0
                sta voice2count
                sta voice2arp
                ldy #1
                lda (220),y
                clc
                adc #2
                adc 220
                sta 220
                lda 221
                adc #0
                sta 221
                ldy #0
                lda (220),y
                cmp #255
                bne playmus_5
                lda voice2start1
                sta 220
                lda voice2start2
                sta 221
playmus_5       lda 220
                sta voice2pos1
                lda 221
                sta voice2pos2
                lda #0 ; Restart note
                sta 54283
                lda #8
                sta 54284
                lda #0
                sta 54285
                lda #17
                sta 54283
playmus_4       ldy voice2arp
                iny
                iny
                lda (220),y
                tax
                lda notes_low,x
                sta 54279
                lda notes_high,x
                sta 54280
                inc voice2arp
                ldy #1
                lda (220),y
                cmp voice2arp
                bne playmus_6
                lda #0
                sta voice2arp
playmus_6       inc voice2count

                rts




;======================
; Counter length of each intro state
;======================

irq_targets     .byte 1,100,8,16,120,157,37,16,32,116,37,16,100,37,16,220,37,16,157,16
                .byte 37,16,200,37,16,200,37,40,200,37,40,200,37

;========================
; Jump tables for changing and handling
; Intro states
;========================

irq_jumptab1	.byte <prepare_dummy,<prepare_dummy,<prepare_dummy,<prepare_firstline
                .byte <prepare_walkin,<prepare_ice1,<prepare_dummy,<prepare_toplines
                .byte <prepare_dummy,<prepare_dummy,<prepare_dummy,<prepare_toplines
                .byte <prepare_dummy,<prepare_dummy,<prepare_toplines,<prepare_flame1
                .byte <prepare_dummy,<prepare_toplines,<prepare_flame2,<prepare_dummy
                .byte <prepare_dummy,<prepare_toplines,<prepare_ice3,<prepare_dummy
                .byte <prepare_toplines,<prepare_dummy,<hide_sprites,<prepare_firstline
                .byte <prepare_dummy,<prepare_dummy,<prepare_highscore,<prepare_dummy
                .byte <prepare_dummy
irq_jumptab2	.byte >prepare_dummy,>prepare_dummy,>prepare_dummy,>prepare_firstline
                .byte >prepare_walkin,>prepare_ice1,>prepare_dummy,>prepare_toplines
                .byte >prepare_dummy,>prepare_dummy,>prepare_dummy,>prepare_toplines
                .byte >prepare_dummy,>prepare_dummy,>prepare_toplines,>prepare_flame1
                .byte >prepare_dummy,>prepare_toplines,>prepare_flame2,>prepare_dummy
                .byte >prepare_dummy,>prepare_toplines,>prepare_ice3,>prepare_dummy
                .byte >prepare_toplines,>prepare_dummy,>hide_sprites,>prepare_firstline
                .byte >prepare_dummy,>prepare_dummy,>prepare_highscore,>prepare_dummy
                .byte >prepare_dummy
irq_jumptab3	.byte <handle_dummy,<handle_curtain,<handle_firetext,<handle_toptext
                .byte <handle_walkin,<handle_ice1,<handle_wipe,<handle_toptext
                .byte <handle_ice2,<handle_dummy,<handle_wipe,<handle_toptext
                .byte <handle_crush1,<handle_wipe,<handle_toptext,<handle_flame1
                .byte <handle_wipe,<handle_toptext,<handle_flame2,<handle_flame3
                .byte <handle_wipe,<handle_toptext,<handle_ice3,<handle_wipe
                .byte <handle_toptext,<handle_ice4,<handle_wipe,<handle_highscore
                .byte <handle_dummy,<handle_wipe,<handle_highscore,<handle_dummy
                .byte <handle_wipe
irq_jumptab4	.byte >handle_dummy,>handle_curtain,>handle_firetext,>handle_toptext
                .byte >handle_walkin,>handle_ice1,>handle_wipe,>handle_toptext
                .byte >handle_ice2,>handle_dummy,>handle_wipe,>handle_toptext
                .byte >handle_crush1,>handle_wipe,>handle_toptext,>handle_flame1
                .byte >handle_wipe,>handle_toptext,>handle_flame2,>handle_flame3
                .byte >handle_wipe,>handle_toptext,>handle_ice3,>handle_wipe
                .byte >handle_toptext,>handle_ice4,>handle_wipe,>handle_highscore
                .byte >handle_dummy,>handle_wipe,>handle_highscore,>handle_dummy
                .byte >handle_wipe

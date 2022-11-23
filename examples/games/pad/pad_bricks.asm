
; register A: have the brick type mask [0..15]
; register X: have the brick index [0..MAX_BRICK_NUM-1]
; trash all registers at exit

HitBrick
	cmp #15			; "cross" (unbreakable brick)
	bne HB_check_easy_brick


; the mega ball bonus effect destroy every type of brick (give score for this?)
	bit m_bonusMegaIsActive
	bpl HB_unbreakable_logic

	jsr EraseBrick

	lda #0
	sta m_ballHardHitsCounter

	lda #2
	sta m_soundFlag
	jmp HB_exit


HB_unbreakable_logic
	jsr InitBrickHighlightAnim

; update hard hits counter
	lda m_numberOfBallsInPlay
	cmp #1					; update with only one ball in play
	bne HB_unbreakable_sound
	lda m_currentBallIndex		; just to be sure that this is ball one..
	bne HB_unbreakable_sound

; 	lda m_ballHardHitsCounter
; 	cmp #MAX_BALL_HARD_HITS
; 	bcs HB_unbreakable_sound

	inc m_ballHardHitsCounter
	lda m_ballHardHitsCounter
	cmp #MAX_BALL_HARD_HITS
	bcc HB_unbreakable_sound

; change ball direction or set a flag to change it
	jsr ChangeFirstBallDirection

	lda #0
	sta m_ballHardHitsCounter


HB_unbreakable_sound
	lda #4
	sta m_soundFlag
	jmp HB_exit


;-------------------------------

HB_check_easy_brick
	cmp #1			; "easy" (one hit brick)
	bne HB_check_restore_brick

	jsr EraseBrick

	dec brick_lev_num

	ldy #$00		; high byte of the score in BCD
	ldx #$08		; low byte of the score in BCD

	bit m_bonusReduceIsActive	; give double the score for some actions
	bpl HB_easy_score
	ldx #$16
HB_easy_score

	jsr AddScore

	lda #0
	sta m_ballHardHitsCounter

	lda #2
	sta m_soundFlag
	jmp HB_exit


;-------------------------------

HB_check_restore_brick
	cmp #2			; "gold", "restore" brick (come back after some seconds)
	bne HB_check_bonus_brick

	stx gold_index
	jsr EraseBrick
	jsr HitRestoreBrick

	lda #0
	sta m_ballHardHitsCounter

	lda #5
	sta m_soundFlag
	jmp HB_exit


;-------------------------------

HB_check_bonus_brick
	cmp #3			; "easy+bonus" (drop a bonus)
	bne HB_check_hard_brick

	jsr EraseBrick

	dec brick_lev_num

	ldy #$00			; high byte of the score in BCD
	ldx #$08			; low byte of the score in BCD

	bit m_bonusReduceIsActive	; give double the score for some actions
	bpl HB_bonus_score
	ldx #$16
HB_bonus_score

	jsr AddScore

	lda #0
	sta m_ballHardHitsCounter

; abort the first "ABORT_BONUS_NUM" bonuses (behavior or bug from arkanoid 1)
; 	lda m_firstBonusDelayCounter
; 	beq HB_check_active_bonus
; 	dec m_firstBonusDelayCounter
; 	jmp HB_bonus_brick_sound

; don't try to create a bonus if there is another one still falling
HB_check_active_bonus
	lda bonus_flag
	bne HB_bonus_brick_sound
	lda m_bonusType
	bmi HB_bonus_brick_sound

; don't try to create a bonus if there is more than one ball in play
	lda m_numberOfBallsInPlay
	cmp #2
	bcs HB_bonus_brick_sound

	jsr CreateRandomBonus


HB_bonus_brick_sound
	lda #2
	sta m_soundFlag
	jmp HB_exit


;-------------------------------

HB_check_hard_brick
	cmp #9			; bricks that need a number of hits
	bcc HB_exit		; (9 --> 14: from 1 to 6 hits)


; the mega ball bonus effect destroy every type of brick
	bit m_bonusMegaIsActive
	bmi HB_clear_hard_brick


	dec TabLevel,x		; "hard"
	lda TabLevel,x
	and #15
	cmp #8
	beq HB_clear_hard_brick

	jsr InitBrickHighlightAnim

	ldy #$00		; high byte of the score in BCD
	ldx #$05		; low byte of the score in BCD

	bit m_bonusReduceIsActive	; give double the score for some actions
	bpl HB_hard_hit_score
	ldx #$10
HB_hard_hit_score

	jsr AddScore

	lda #0
	sta m_ballHardHitsCounter

	lda #3
	sta m_soundFlag

	jmp HB_exit


HB_clear_hard_brick
	jsr EraseBrick		; last hit for the hard brick

	dec brick_lev_num

	ldy #$00		; high byte of the score in BCD
	ldx #$05		; low byte of the score in BCD

	bit m_bonusReduceIsActive	; give double the score for some actions
	bpl HB_hard_clear_score
	ldx #$10
HB_hard_clear_score

	jsr AddScore

	lda #0
	sta m_ballHardHitsCounter

	lda #2
	sta m_soundFlag


; check if there is a highlight animation active
	ldx #0

; after the call to "EraseBrick" (that calls "GetBrickPointer"), we know that
; "ptr_1, ptr_1+1" have a pointer to the char of the hard brick, in the screen
HB_check_highlight_loop
	lda tab_anim_lsb,x
	cmp ptr_1
	bne HB_next_anim_entry
	lda tab_anim_msb,x
	cmp ptr_1+1
	bne HB_next_anim_entry

; clear this entry in the tables of the highlight animation
	lda #0
	sta tab_anim_lsb,x
	sta tab_anim_msb,x
	sta tab_anim_ctd,x
	sta tab_anim_end,x
	dec anim_num
	jmp HB_exit

HB_next_anim_entry
	inx
	cpx #MAX_ACTIVE_HIGHLIGHT_ANIMS
	bne HB_check_highlight_loop


;-------------------------------

HB_exit
	rts


;================================================================================

; register X: have the brick index [0..MAX_BRICK_NUM-1]
; trash registers A and Y at exit

EraseBrick
	lda #0
	sta TabLevel,x

; now update the background and the shadows
	jsr GetBrickPointer

	lda brick_ychar
	and #%11
	asl
	sta temp_1
	lda brick_xchar
	and #%01
	ora temp_1
	tay

	lda TabBackgroundCharDef,y
	sta temp_1			; background char 1
	clc
	adc #1
	sta temp_2			; background char 2

; check special cases
	lda brick_xchar		; left column always in shadow
	beq EB_set_shadow_left_char
	lda brick_ychar		; top line always in shadow
	beq EB_set_shadow_left_char

; check top left brick
	lda TabLevel-[NUM_BRICKS_X+1],x
	and #%1111			; brick mask
	beq EB_check_top_line

EB_set_shadow_left_char
	lda temp_1
	ora #%10000			; set shadow bit
	sta temp_1

; check special case
EB_check_top_line
	lda brick_ychar		; top line always in shadow
	beq EB_set_shadow_right_char

; check top brick
	lda TabLevel-NUM_BRICKS_X,x
	and #%1111			; brick mask
	beq EB_restore_background

EB_set_shadow_right_char
	lda temp_2
	ora #%10000			; set shadow bit
	sta temp_2

EB_restore_background
	ldy #0				; restore background
	lda temp_1
	sta (ptr_1),y
	iny
	lda temp_2
	sta (ptr_1),y

	ldy #BYTES_LINE+1
	lda (ptr_1),y
	and #%01111111
	cmp #32				; last char of the background + shadows
	bcs EB_second_char		; a >= 32
	lda (ptr_1),y
	and #%11101111			; clear shadow bit (only for background)
	sta (ptr_1),y

EB_second_char
	iny
	lda (ptr_1),y
	and #%01111111
	cmp #32				; last char of the background + shadows
	bcs EB_exit			; a >= 32
	lda (ptr_1),y
	and #%11101111			; clear shadow bit (only for background)
	sta (ptr_1),y

EB_exit
	rts


;-------------------------------

;DrawBrick


	;rts


;================================================================================

InitBrickHighlightAnim
    jsr GetBrickPointer

    ldx #0			; hit before?
ba1 lda tab_anim_lsb,x
    cmp ptr_1
    bne ba2
    lda tab_anim_msb,x
    cmp ptr_1+1
    bne ba2

    lda #HIGHLIGHT_ANIM_FRAMES
    sec
    sbc tab_anim_ctd,x
    asl		; *2
    sta temp_1

    lda vbi_anim_ctd
    clc
    adc #HIGHLIGHT_ANIM_TIME
    sta tab_anim_end,x
    lda #HIGHLIGHT_ANIM_FRAMES
    sta tab_anim_ctd,x
    ldy #0
    lda (ptr_1),y
    sec
    sbc temp_1
    sta (ptr_1),y
    iny
    clc
    adc #1
    sta (ptr_1),y

    jmp eba

ba2 inx
    cpx #MAX_ACTIVE_HIGHLIGHT_ANIMS
    bne ba1

    lda anim_num		; one empty?
    cmp #MAX_ACTIVE_HIGHLIGHT_ANIMS
    bne ba5

    lda #0			; find lower
    sta temp_1
    ldx #1
    lda tab_anim_ctd
ba3 cmp tab_anim_ctd,x
    bcc ba4			; a < m
    lda tab_anim_ctd,x
    stx temp_1
ba4 inx
    cpx #MAX_ACTIVE_HIGHLIGHT_ANIMS
    bne ba3
    ldx temp_1

    lda tab_anim_lsb,x
    sta ptr_2
    lda tab_anim_msb,x
    sta ptr_2+1
    lda #HIGHLIGHT_ANIM_FRAMES+1
    sec
    sbc tab_anim_ctd,x
    asl		; *2
    sta temp_1
    ldy #0
    lda (ptr_2),y
    sec
    sbc temp_1
    sta (ptr_2),y
    iny
    clc
    adc #1
    sta (ptr_2),y
    jmp ba7

ba5 inc anim_num

    ldx #255
ba6 inx
    lda tab_anim_ctd,x
    bne ba6

ba7 lda vbi_anim_ctd
    clc
    adc #HIGHLIGHT_ANIM_TIME
    sta tab_anim_end,x
    lda #HIGHLIGHT_ANIM_FRAMES
    sta tab_anim_ctd,x
    lda ptr_1
    sta tab_anim_lsb,x
    lda ptr_1+1
    sta tab_anim_msb,x
    ldy #0
    lda (ptr_1),y
    clc
    adc #2
    sta (ptr_1),y
    iny
    clc
    adc #1
    sta (ptr_1),y

eba rts


;-------------------------------

AnimateBrickHighlight
;   lda anim_num
;   beq exit_anim

    ldx #0
ab1 lda tab_anim_ctd,x
    beq ab3

    lda vbi_anim_ctd
    cmp tab_anim_end,x
    bne ab3

    lda tab_anim_lsb,x
    sta ptr_1
    lda tab_anim_msb,x
    sta ptr_1+1
    ldy #0

    dec tab_anim_ctd,x
    bne ab2

    lda (ptr_1),y
    sec
    sbc #HIGHLIGHT_ANIM_FRAMES*2
    sta (ptr_1),y		; anim char 1 left
    iny
    clc
    adc #1
    sta (ptr_1),y		; anim char 1 right
    lda #0
    sta tab_anim_lsb,x
    sta tab_anim_msb,x
    sta tab_anim_end,x
    dec anim_num
    jmp ab3

ab2 lda (ptr_1),y
    clc
    adc #2
    sta (ptr_1),y
    iny
    clc
    adc #1
    sta (ptr_1),y
    lda vbi_anim_ctd
    clc
    adc #HIGHLIGHT_ANIM_TIME
    sta tab_anim_end,x

ab3 inx
    cpx #MAX_ACTIVE_HIGHLIGHT_ANIMS
    bne ab1

exit_anim
    rts


;================================================================================
UpdateStartLevelHighlight
	dec m_startLevelHighlightTimer
	beq USLH_check_step
	jmp USLH_exit


USLH_check_step
	lda m_startLevelHighlightStep
	beq USLH_step1
	jmp USLH_step2

; save graphic data for the original hard bricks
; (to restore it at the end of the animation)
USLH_step1
	?charLine = 0
	.rept 8
		lda Font1_address+70*8+?charLine
		sta TabSaveHighlightChar+?charLine

		lda Font1_address+71*8+?charLine
		sta TabSaveHighlightChar+8+?charLine

		lda Font1_address+80*8+?charLine
		sta TabSaveHighlightChar+16+?charLine

		lda Font1_address+81*8+?charLine
		sta TabSaveHighlightChar+24+?charLine

		?charLine ++
	.endr

	ldx #0
	jmp USLH_copy_highlight_frame


USLH_step2
	cmp #1
	bne USLH_step3

	ldx #16
	jmp USLH_copy_highlight_frame


USLH_step3
	cmp #2
	bne USLH_step4

	ldx #32
	jmp USLH_copy_highlight_frame


USLH_step4
	cmp #3
	beq USLH_do_step4
	jmp USLH_step5

USLH_do_step4
	ldx #48

; copy next animation frame data
USLH_copy_highlight_frame
	?charLine = 0
	.rept 8
		lda Font1_address+72*8+?charLine,x
		sta Font1_address+70*8+?charLine

		lda Font1_address+73*8+?charLine,x
		sta Font1_address+71*8+?charLine

		lda Font1_address+82*8+?charLine,x
		sta Font1_address+80*8+?charLine

		lda Font1_address+83*8+?charLine,x
		sta Font1_address+81*8+?charLine

		?charLine ++
	.endr


; update step and restart timer for the next animation frame
	inc m_startLevelHighlightStep

	lda #HIGHLIGHT_ANIM_TIME
	sta m_startLevelHighlightTimer

	jmp USLH_exit


; end the animation, recover the original char data
USLH_step5
	?charLine = 0
	.rept 8
		lda TabSaveHighlightChar+?charLine
		sta Font1_address+70*8+?charLine

		lda TabSaveHighlightChar+8+?charLine
		sta Font1_address+71*8+?charLine

		lda TabSaveHighlightChar+16+?charLine
		sta Font1_address+80*8+?charLine

		lda TabSaveHighlightChar+24+?charLine
		sta Font1_address+81*8+?charLine

		?charLine ++
	.endr

	lda #0		; not really needed
	sta m_startLevelHighlightStep


USLH_exit
	rts


;================================================================================

HitRestoreBrick
    lda gold_num
    cmp #MAX_ACTIVE_RESTORE_BRICKS
    bne hg1

    ldx gold_init
    jsr RecoverRestoreBrick

hg1 lda gold_init
    clc
    adc gold_num
    cmp #MAX_ACTIVE_RESTORE_BRICKS
    bcc hg2
    sbc #MAX_ACTIVE_RESTORE_BRICKS
hg2 tax

    lda ptr_1
    sta TabRestoreBrick_lsb,x
    lda ptr_1+1
    sta TabRestoreBrick_msb,x
    lda gold_index
    sta TabRestoreBrick_idx,x
    lda vbi_gold_ctd
    clc
    adc #RESTORE_BRICK_TIME
    sta TabRestoreBrick_end,x

    inc gold_num

    rts


;-------------------------------

CheckRestoreBrickList
	lda gold_num
	beq CRBL_exit

	ldx gold_init
	lda TabRestoreBrick_end,x
	cmp vbi_gold_ctd
	bne CRBL_exit

	jsr RecoverRestoreBrick

CRBL_exit
	rts


;-------------------------------

RecoverRestoreBrick
    lda TabRestoreBrick_lsb,x
    sta ptr_2
    lda TabRestoreBrick_msb,x
    sta ptr_2+1

    ldy #0
    lda #RESTORE_BRICK_LEFT_CHAR
    sta (ptr_2),y
    iny
    lda #RESTORE_BRICK_RIGHT_CHAR
    sta (ptr_2),y

    ldy #BYTES_LINE+1
    lda (ptr_2),y
    and #%01111111
    cmp #32			; last char of the background + shadows
    bcs rg1
    lda (ptr_2),y
    ora #%10000		; shadow bit
    sta (ptr_2),y
rg1 iny
    lda (ptr_2),y
    and #%01111111
    cmp #32			; last char of the background + shadows
    bcs rg2
    lda (ptr_2),y
    ora #%10000		; shadow bit
    sta (ptr_2),y

rg2 lda TabRestoreBrick_idx,x
    tay
    lda #RESTORE_BRICK_VALUE
    sta TabLevel,y
    lda #0
    sta TabRestoreBrick_lsb,x
    sta TabRestoreBrick_msb,x
    sta TabRestoreBrick_end,x
    sta TabRestoreBrick_idx,x

    dec gold_num

    inx
    cpx #MAX_ACTIVE_RESTORE_BRICKS
    bne rg3
    ldx #0
rg3 stx gold_init

    rts


;-------------------------------

DrawRestoreBrickList
	lda gold_num
	beq DRBL_exit

DRBL_loop
	ldx gold_init
	jsr RecoverRestoreBrick

	lda gold_num
	bne DRBL_loop

DRBL_exit
	rts


;================================================================================

GetBrickPointer
	ldy brick_ychar

	lda TabMulBytesLineMSB,y
	sta ptr_1+1

	lda brick_xchar
	asl		; *2
	clc
	adc TabMulBytesLineLSB,y
	bcc gbp
	inc ptr_1+1
	clc

gbp	adc #<[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET]
	sta ptr_1
	lda ptr_1+1
	adc #>[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET]
	sta ptr_1+1

	rts


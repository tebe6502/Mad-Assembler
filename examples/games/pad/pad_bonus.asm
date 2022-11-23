
CreateRandomBonus

; in arkanoid 1 it seems there is a small possibility of not generating the bonus
	lda RANDOM
	cmp #16		; in this case 6.25% of probability
	bcs CRB_start
	jmp CRB_exit

CRB_start
; init bonus position
	lda brick_xchar
	asl
	asl
	asl		; *8
	sta bonus_xpos

	lda brick_ychar
	asl
	asl
	asl		; *8
	sta bonus_ypos

	lda #0
	sta bonus_ypos_decimal


; select random bonus type (from 1 to MAX_BONUS_NUM)
	ldx #0
	lda RANDOM

CRB_loop
	inx
	cpx #MAX_BONUS_NUM
	beq CRB_choose_bonus
	cmp tab_bonus_prob-1,x
; if RANDOM is greater than the value in the tab, then check the next one
	beq CRB_choose_bonus		; RANDOM == rnd_tab ? .. then this is the one
	bcs CRB_loop				; RANDOM > rnd_tab ? .. then check the next one

; here: RANDOM <= rnd_tab , or we reached the last possible bonus

CRB_choose_bonus
; do not allow two consecutives bonuses of the same type
	cpx m_lastBonusType
	beq CRB_change_bonus

; if there is a powerup effect active, don't allow the same one to appear
; (in this case I'm just aborting the bonus generation, this is to not
; give that much of "disrupt" powerups and to account for the behavior in
; arkanoid 1, where sometimes some bricks marked with powerups don't give them)

	cpx #BONUS_TYPE_BREAK
	bne CRB_checked_break
	bit m_bonusBreakIsActive
	;bmi CRB_change_bonus
	bmi CRB_exit
	bpl CRB_save_bonus
CRB_checked_break

	cpx #BONUS_TYPE_EXPAND
	bne CRB_checked_expand
	bit m_bonusExpandIsActive
	;bmi CRB_change_bonus
	bmi CRB_exit
	bpl CRB_save_bonus
CRB_checked_expand

	cpx #BONUS_TYPE_REDUCE
	bne CRB_checked_reduce
	bit m_bonusReduceIsActive
	;bmi CRB_change_bonus
	bmi CRB_exit
	bpl CRB_save_bonus
CRB_checked_reduce

	cpx #BONUS_TYPE_MEGA
	bne CRB_checked_mega
	bit m_bonusMegaIsActive
	;bmi CRB_change_bonus
	bmi CRB_exit
	bpl CRB_save_bonus
CRB_checked_mega

	cpx #BONUS_TYPE_CATCH
	bne CRB_checked_catch
	bit m_bonusCatchIsActive
	;bmi CRB_change_bonus
	bmi CRB_exit
	bpl CRB_save_bonus
CRB_checked_catch

; if we are moving at min speed don't give the "slow" bonus
	cpx #BONUS_TYPE_SLOW
	bne CRB_checked_slow
	lda m_currentBallSpeed
	cmp #MIN_BALL_SPEED
	beq CRB_change_bonus
	bne CRB_save_bonus
CRB_checked_slow

; if we are moving at max speed don't give the "fast" bonus
	cpx #BONUS_TYPE_FAST
	bne CRB_checked_fast
	lda m_currentBallSpeed
	cmp m_maxBallSpeed
	beq CRB_change_bonus
	bne CRB_save_bonus
CRB_checked_fast

; allow only one extra player bonus per level
	cpx #BONUS_TYPE_PLAYER
	bne CRB_save_bonus
	bit m_extraPlayerBonusFlag
	bmi CRB_change_bonus

	lda #128
	sta m_extraPlayerBonusFlag
	jmp CRB_save_bonus

CRB_change_bonus
	ldx #BONUS_TYPE_DISRUPT		; by arkanoid 1 definition..

CRB_save_bonus
	stx m_bonusType
	stx m_lastBonusType

	lda tab_bonus_color-1,x
	sta bonus_color
	lda tab_bonus_lsb-1,x
	sta ptr_bonus_sh
	lda tab_bonus_msb-1,x
	sta ptr_bonus_sh+1

	lda #0
	sta bonus_sh_line
	lda #BONUS_ANIM_SPEED
	sta bonus_sh_ctd
	lda #128
	sta bonus_flag

CRB_exit
	rts


;-------------------------------

StartBonusAction
	lda m_bonusType
	and #%01111111

	cmp #BONUS_TYPE_EXPAND
	beq SBA_bonus_expand

	cmp #BONUS_TYPE_DISRUPT
	beq SBA_bonus_disrupt

	cmp #BONUS_TYPE_PLAYER
	beq SBA_bonus_player

	cmp #BONUS_TYPE_REDUCE
	bne SBA_check_bonus_slow
	jmp SBA_bonus_reduce

SBA_check_bonus_slow
	cmp #BONUS_TYPE_SLOW
	bne SBA_check_bonus_mega
	jmp SBA_bonus_slow

SBA_check_bonus_mega
	cmp #BONUS_TYPE_MEGA
	bne SBA_check_bonus_break
	jmp SBA_bonus_mega

SBA_check_bonus_break
	cmp #BONUS_TYPE_BREAK
	bne SBA_check_bonus_catch
	jmp SBA_bonus_break

SBA_check_bonus_catch
	cmp #BONUS_TYPE_CATCH
	bne SBA_check_bonus_fast
	jmp SBA_bonus_catch

SBA_check_bonus_fast
	cmp #BONUS_TYPE_FAST
	bne SBA_end_bonus_check
	jmp SBA_bonus_fast


SBA_end_bonus_check
	jmp SBA_exit


;-------------------------------
SBA_bonus_expand
	lda #128
	sta m_bonusExpandIsActive

; get pad middle position
	jsr GetPadMiddlePoint


; clear the effect of other bonus if is active
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


	jsr SetLargePadInfo


; set pad position according to middle point and new size
	jsr SetPadWithMiddlePoint

	
; play sound
	jsr PlayGetBonusSound
	

	jmp SBA_exit


;-------------------------------
SBA_bonus_disrupt
	lda #3
	sta m_numberOfBallsInPlay

; duplicate info of the first ball to the other two
	jsr CopyFirstBallInfo

; update steps X for ball 2 and step Y for ball 3
	jsr SetDirectionForNewBalls


; draw balls 2 and 3 (not necessary)


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


; play sound
	jsr PlayGetBonusSound
	

; set colors for new balls (after the "mega" bonus effect clear)
	lda #BALL_COLOR
	sta COLPM1
	sta COLPM2


; reset hard hits counter when in multi ball
	lda #0
	sta m_ballHardHitsCounter


	jmp SBA_exit



;-------------------------------
SBA_bonus_player
	inc m_numberOfBallsLeft
	jsr IncreaseBallsInHud

	;jsr DisplayLives

	jsr PlayExtraLifeSound

	
; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


	jmp SBA_exit


;-------------------------------
SBA_bonus_reduce
	lda #128
	sta m_bonusReduceIsActive

; get pad middle position
	jsr GetPadMiddlePoint


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


	jsr SetSmallPadInfo


; set pad position according to middle point and new size
	jsr SetPadWithMiddlePoint

	
; play sound
	jsr PlayGetBonusSound

	
	jmp SBA_exit


;-------------------------------
SBA_bonus_slow
; 	ldx m_currentBallSpeed
; 	dex
; 	dex
; 	cpx #MIN_BALL_SPEED
; 	bcs SBA_update_speed
; 	ldx #MIN_BALL_SPEED
; SBA_update_speed
; 	stx m_currentBallSpeed

	lda m_currentBallSpeed
	sec
	sbc #SLOW_BONUS_SLOWDOWN_STEP
	bcc SBA_min_speed
	cmp #MIN_BALL_SPEED
	bcs SBA_update_speed

SBA_min_speed
	lda #MIN_BALL_SPEED

SBA_update_speed
	sta m_currentBallSpeed


	;lda #0
	;sta m_ballHitsCounter		; reset speedup counter
	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer		; reset speedup timer


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


; play sound
	jsr PlayGetBonusSound

	
	jmp SBA_exit


;-------------------------------
SBA_bonus_mega
	lda #128
	sta m_bonusMegaIsActive

	lda #BALL_MEGA_COLOR
	sta COLPM0
	lda #BALL_MEGA_BACKG_COLOR
	sta m_ballAntialiasColor
	sta COLPM1


; speed up the ball a little
	lda m_currentBallSpeed
	cmp m_maxBallSpeed
	bcs SBA_ball_at_top_speed

	inc m_currentBallSpeed

	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer		; reset speedup timer

SBA_ball_at_top_speed


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusCatchEffect


; play sound
	jsr PlayGetBonusSound

	
	jmp SBA_exit


;-------------------------------
SBA_bonus_break
	lda #0
	sta m_padAtRightLimitFlag
	sta m_padAtLeftLimitFlag

	lda #128
	sta m_bonusBreakIsActive


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


	jsr ForceOpenSideHoles


; play sound
	jsr PlayGetBonusSound

	
	jmp SBA_exit


;-------------------------------
SBA_bonus_catch
	lda #128
	sta m_bonusCatchIsActive


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect


; play sound
	jsr PlayGetBonusSound

	
	jmp SBA_exit


;-------------------------------
SBA_bonus_fast
	lda m_currentBallSpeed
	clc
	adc #FAST_BONUS_SPEEDUP_STEP
;	bcs SBA_max_speed
	cmp m_maxBallSpeed
	bcc SBA_update_speed_faster

;SBA_max_speed
	lda m_maxBallSpeed

SBA_update_speed_faster
	sta m_currentBallSpeed


	;lda #0
	;sta m_ballHitsCounter		; reset speedup counter
	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer		; reset speedup timer


; clear the effect of other bonus if is active
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	jsr ClearBonusCatchEffect


; play sound
	jsr PlayGetBonusSound

	
;	jmp SBA_exit


;-------------------------------
SBA_exit
	lda #0
	sta m_bonusType

; 	lda m_difficultyIndex
; 	cmp #2		; give the score only for the arcade difficulty
; 	bcc SBA_return

; add 1000 points to the score
	ldy #$01		; high byte of the score in BCD
	ldx #$00		; low byte of the score in BCD

; this one doesn't make sense..
; 	bit m_bonusReduceIsActive	; give double the score for some actions
; 	bpl SBA_get_bonus_score
; 	ldy #$02
; SBA_get_bonus_score

	jsr AddScore

SBA_return
	rts


;-------------------------------

ForceOpenSideHoles
; create "hole" of the break bonus, in the right border (4 chars)
/*	lda #2
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]
	lda #3
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1
	lda #6
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]
	lda #7
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1

; create "hole" of the break bonus, in the left border (4 chars)
	lda #BLANK_CHAR
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	lda #3+16
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1
	lda #BLANK_CHAR
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	lda #7+16
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1*/

	ldx #0
	stx m_exitsAnimationIndex
	
	lda #EXIT_ANIMATION_TIME+1
	sta m_animateExitsTimer

DrawOpenSideFrames
; draw open side effect frame, in the right border and left borders (8 chars)
	lda TabExitAnimationChar1,x
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]

	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	
	lda TabExitAnimationChar2,x
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1

	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1

	rts


;-------------------------------

PlayExtraLifeSound
	lda #8
	sta m_soundFlag

	rts
	
	
PlayGetBonusSound
	lda #6
	sta m_soundFlag

	rts
	
	
;-------------------------------

GetPadMiddlePoint
	lda pad_xpos
	clc
	adc m_padHalfSizeX
	sta m_padMiddlePos

	rts


SetPadWithMiddlePoint
	lda m_padMiddlePos
	sec
	sbc m_padHalfSizeX
	bcs SPWMP_check_right_limit


; check that we don't crossed the left or right limits
; (only needed if the pad is growing, but we do it in every case..)
SPWMP_left_limit
	lda #0
	sta pad_xpos

; force the change of position here, not in the VBI, so to not wait one frame
	clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3

	rts


SPWMP_check_right_limit
	cmp m_maxPadPosXPlusOne
	bcc SPWMP_update_pos
	lda m_maxPadPosX

SPWMP_update_pos
	sta pad_xpos

; force the change of position here, not in the VBI, so to not wait one frame
	clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3

	rts


;--------------------------------------------------------------------------------

ClearBonus
	lda #0
	sta bonus_flag

	ldx #BONUS_SIZEY
	ldy bonus_ypos

CB_loop
	lda #0
	sta p1_adr+PM_OFFSET_Y,y
	lda m0_adr+PM_OFFSET_Y,y
	and #%11111100
	sta m0_adr+PM_OFFSET_Y,y

	iny
	dex
	bne CB_loop

	lda #0
	sta HPOSM0

; recover ball color
	lda m_ballAntialiasColor
	sta COLPM1

	rts


;-------------------------------

ClearBonusExpandEffect
	bit m_bonusExpandIsActive
	bpl CBEE_exit

	lda #0
	sta m_bonusExpandIsActive

; if we are clearing the expand effect to set the reduce effect, then continue..
; if not, we need to update here the new position of the normal pad
	bit m_bonusReduceIsActive
	bmi CBEE_normal_clear

; get pad middle position
	jsr GetPadMiddlePoint

	jsr SetNormalPadInfo

; set pad position according to middle point and new size
	jsr SetPadWithMiddlePoint

	rts


CBEE_normal_clear
	jsr SetNormalPadInfo

CBEE_exit
	rts


;-------------------------------

ClearBonusReduceEffect
	bit m_bonusReduceIsActive
	bpl CBRE_exit

	lda #0
	sta m_bonusReduceIsActive

; if we are clearing the reduce effect to set the expand effect, then continue..
; if not, we need to update here the new position of the normal pad
	bit m_bonusExpandIsActive
	bmi CBRE_normal_clear

; get pad middle position
	jsr GetPadMiddlePoint

	jsr SetNormalPadInfo

; set pad position according to middle point and new size
	jsr SetPadWithMiddlePoint

	rts


CBRE_normal_clear
	jsr SetNormalPadInfo

CBRE_exit
	rts


;-------------------------------

ClearBonusMegaEffect
	bit m_bonusMegaIsActive
	bpl CBME_exit

	lda #0
	sta m_bonusMegaIsActive

	lda #BALL_COLOR
	sta COLPM0
	lda m_ballBackgroundColor
	sta m_ballAntialiasColor
	sta COLPM1

CBME_exit
	rts


;-------------------------------

; ClearBonusDisruptEffect
; 	lda m_numberOfBallsInPlay
; 	cmp #1
; 	beq CBDE_exit
; 
; 
; CBDE_exit
; 	rts


;-------------------------------

ClearBonusBreakEffect
	bit m_bonusBreakIsActive
	bpl CBBE_exit

	lda #0
	sta m_bonusBreakIsActive

ForceCloseSideHoles
; restore "hole" of the break bonus, in the right border (4 chars)
	lda #38+128
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]
	lda #39+128
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1
	lda #38+128
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]
	lda #39+128
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET+NUM_BRICKS_X*2]+1

; restore "hole" of the break bonus, in the left border (4 chars)
	lda #38+128
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	lda #39+128
	sta DL1_data_address+[[[PAD_BRICK_LINE-1]*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1
	lda #38+128
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]
	lda #39+128
	sta DL1_data_address+[[PAD_BRICK_LINE*BYTES_LINE]+LEFT_BRICK_OFFSET-2]+1


CBBE_exit
	rts


;-------------------------------

ClearBonusCatchEffect
	bit m_bonusCatchIsActive
	bpl CBCE_exit

	lda #0
	sta m_bonusCatchIsActive

	sta m_ballCatchedByPadFlag
	sta m_ballCatchedByPadTimer


CBCE_exit
	rts


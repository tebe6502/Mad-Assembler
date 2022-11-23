
; this is no longer used in a real VBI, now is called from the last DLI in the DL
VBI_address
; 	lda #8
; 	sta CONSOL		; not using consol right now

	.if .def SHOW_TIMING_AREAS
	sta COLBK
	.endif


; 	lda #0			; this is now updated in the last DLI
; 	sta dli_index


; info line logic
; 	lda #>Font1_address
; 	sta CHBASE


	;jsr DisplayBallSteps

/*
;-------------------------------
; update RMT usage for the song at the start of a level
	lda m_waitForSongEndCounter
	beq VBI_update_pause_key
	
	dec m_waitForSongEndCounter
	bne VBI_update_start_music
	
	; stop RMT menu music
	jsr RASTERMUSICTRACKER+9

	jmp VBI_update_pause_key
	
VBI_update_start_music

; worst hack ever.. but it doesn't sound that bad
.if .def PAL_VERSION
	jsr RASTERMUSICTRACKER+3		; play one frame
.endif

; play RMT music
	jsr RASTERMUSICTRACKER+3		; play one frame
	jsr RASTERMUSICTRACKER+3		; play one frame
	jsr RASTERMUSICTRACKER+3		; play one frame
*/

;================================================================================
; update pause key state
;================================================================================
VBI_update_pause_key
	lda m_keyPausePressed
	sta m_oldKeyPausePressed

	lda #0
	sta m_keyPausePressed

	lda SKCTL
	and #4			; a key pressed ?
	bne VBI_check_pause_key_just_pressed

	lda KBCODE
	and #%00111111		; bit7 -> control, bit6 -> shift
	cmp #33			; "space bar", pause key
	bne VBI_check_pause_key_just_pressed

	lda #128
	sta m_keyPausePressed

VBI_check_pause_key_just_pressed
	bit m_oldKeyPausePressed
	bmi VBI_end_check_pause
	bit m_keyPausePressed
	bpl VBI_end_check_pause

; pause key just pressed, change pause state
	lda m_pauseModeFlag
	eor #128
	sta m_pauseModeFlag

	bpl VBI_update_counters		; exiting pause, continue with normal events

	lda #0
	sta AUDC1					; clear sounds at the start of the pause
	sta AUDC3
	sta m_padFrameDeltaStep		; clear accumulated mouse movement

	jmp VBI_exit

VBI_end_check_pause

	bit m_pauseModeFlag
	bpl VBI_update_counters

; still in pause mode
	lda #0
	sta m_padFrameDeltaStep		; clear accumulated mouse movement

	jmp VBI_exit


;================================================================================
; update vbi counters
;================================================================================
VBI_update_counters
	inc vbi_anim_ctd

	dec vbi_jif_ctd
	bne VBI_update_ball_catched_timer
	lda #VBI_COUNTER_FRAMES
	sta vbi_jif_ctd


; update restore brick global counter
	inc vbi_gold_ctd


; update ball speed up timer
	lda m_ballSpeedUpTimer
	beq VBI_update_ball_catched_timer
	dec m_ballSpeedUpTimer
	bne VBI_update_ball_catched_timer

	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer		; reset speedup timer

	lda m_currentBallSpeed
	clc
	adc #BALL_HITS_SPEEDUP_STEP
	cmp m_maxBallSpeed
	;beq VBI_update_ball_speed
	bcc VBI_update_ball_speed

	lda m_maxBallSpeed

VBI_update_ball_speed
	sta m_currentBallSpeed


; update catched ball timer and flag state
VBI_update_ball_catched_timer
	lda m_ballCatchedByPadTimer
	beq VBI_update_open_exits_timer
	dec m_ballCatchedByPadTimer
	bne VBI_update_open_exits_timer

	lda #0
	sta m_ballCatchedByPadFlag


; update timer to open side exits at the end of the level
VBI_update_open_exits_timer
	lda m_openSidesWaitTimer
	beq VBI_update_exits_animation
	dec m_openSidesWaitTimer
	bne VBI_update_exits_animation

; open both sides holes to exit
	lda #0
	sta m_padAtRightLimitFlag
	sta m_padAtLeftLimitFlag

	jsr ForceOpenSideHoles


; update timer to animate the exits electricity effect
VBI_update_exits_animation
	lda m_animateExitsTimer
	beq VBI_update_start_game_timer
	dec m_animateExitsTimer
	bne VBI_update_start_game_timer
	
	lda #EXIT_ANIMATION_TIME
	sta m_animateExitsTimer
	
	ldx m_exitsAnimationIndex
	inx
	cpx #EXIT_ANIMATION_FRAMES
	bne VBI_exits_update_frame
	ldx #0
VBI_exits_update_frame
	stx m_exitsAnimationIndex

	jsr DrawOpenSideFrames


; update timer to wait some time, at the start of a level (before creating a ball)
VBI_update_start_game_timer
	lda m_startGameWaitTimer
	beq VBI_update_start_level_highlight
	dec m_startGameWaitTimer


; update timer for the highlight animation, at the start of a level
VBI_update_start_level_highlight
	lda m_startLevelHighlightTimer
	beq VBI_set_ball_pos

	jsr UpdateStartLevelHighlight


;================================================================================
; draw ball at correct position
;================================================================================
VBI_set_ball_pos
	lda ball_rxpos			; multiball code change
	clc
	adc #PM_OFFSET_X
	sta HPOSP0

	ldx bonus_flag
	bne VBI_draw_balls		; don't update P1 if there is a bonus falling

	ldx m_numberOfBallsInPlay
	cpx #2
	bcs VBI_set_multiball	; don't update P1 if there are 2 or more balls in play

	sta HPOSP1			; set second player of first ball (antialiasing part)
	jmp VBI_draw_balls


VBI_set_multiball
	lda ball_rxpos+1
	clc
	adc #PM_OFFSET_X
	sta HPOSP1

	lda ball_rxpos+2
	clc
	adc #PM_OFFSET_X
	sta HPOSP2


VBI_draw_balls
	lda m_numberOfBallsInPlay
	beq VBI_update_pad_pos

	cmp #3
	bcc VBI_check_draw_second

	lda ball_rypos+2
	cmp old_ball_rypos+2
	beq VBI_check_draw_second

	jsr UpdateSpriteBall3


VBI_check_draw_second
	lda m_numberOfBallsInPlay
	cmp #2
	bcc VBI_draw_first

	lda ball_rypos+1
	cmp old_ball_rypos+1
	beq VBI_draw_first

	jsr UpdateSpriteBall2


VBI_draw_first
	lda ball_rypos
	cmp old_ball_rypos
	beq VBI_update_pad_pos

	jsr UpdateSpriteBall1


;================================================================================
; update pad position
;================================================================================
VBI_update_pad_pos
	bit m_usePaddleControllerFlag
	bmi VBI_use_paddle_controller

	lda m_padFrameDeltaStep
	;beq VBI_exit_move_pad
	beq VBI_force_pad_update		; this is for the cases when the pad change size
	bmi VBI_move_pad_left

	// cmp #1
	// beq VBI_move_pad_right
	// cmp #64
	// bcs VBI_move_pad_right
	// asl		; delta x2
	
VBI_move_pad_right
	clc
	adc pad_xpos

; check if there is a "hole" and we can skip the level ("break" bonus)
; 	bit m_bonusBreakIsActive
; 	bmi VBI_update_pad_right		; let the pad move to the right, over the limit

	cmp m_maxPadPosXPlusOne
	bcc VBI_update_pad_right

	lda #128
	sta m_padAtRightLimitFlag

	lda m_maxPadPosX

VBI_update_pad_right
	sta pad_xpos

	jmp VBI_end_move_pad


VBI_move_pad_left
; 	lda #0
; 	sec
; 	sbc m_padFrameDeltaStep
; 	sta m_padFrameDeltaStep
;
; 	lda pad_xpos
; 	sec

	eor #255
	sta m_padFrameDeltaStep

	lda pad_xpos
	clc		; an extra -1
	sbc m_padFrameDeltaStep
	bcs VBI_update_pad_left

	lda #128
	sta m_padAtLeftLimitFlag

	lda #0

VBI_update_pad_left
	sta pad_xpos

VBI_end_move_pad
	lda #0
	sta m_padFrameDeltaStep

VBI_force_pad_update
	lda pad_xpos
	clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3

VBI_exit_move_pad
	jmp VBI_enemy_logic


;================================================================================
; move player pad using a paddle
;================================================================================
VBI_use_paddle_controller
POT_address1
	lda POT0		; (240?) 228 --> 0 (229 values) (Basic in Altirra: 1 to 227)

	eor #255		; 27 --> 255 (229 values)

	ldx m_selectedPaddleAngleIndex
	beq VBI_paddle_angle_25
	cpx #1
	beq VBI_paddle_angle_50
	cpx #2
	beq VBI_paddle_angle_75

VBI_paddle_angle_100
	lsr			; 13 --> 127 (115 values)
	sec
	sbc #[13+6]	; use almost the full angle of the paddle controller

	jmp VBI_check_paddle_at_left_limit


VBI_paddle_angle_25
	tax
	lda TabPaddleConversionPercent25,x
	sec

	jmp VBI_check_paddle_size_limit


VBI_paddle_angle_75
	tax
	lda TabPaddleConversionPercent75,x
	sec

	jmp VBI_check_paddle_size_limit


VBI_paddle_angle_50
	sec
	sbc #[27+60]	; use almost half the max angle of the paddle controller

	;jmp VBI_check_paddle_at_left_limit


VBI_check_paddle_at_left_limit
	bcc VBI_set_paddle_at_left_limit

; need to use the different offsets for the 3 pad sizes
; use "m_padHalfSizeX" and maybe "GAME_AREA_SIZEX" = 104
VBI_check_paddle_size_limit
	;sec
	sbc m_padHalfSizeX
	bcs VBI_check_paddle_at_right_limit

VBI_set_paddle_at_left_limit
	lda #128
	sta m_padAtLeftLimitFlag

	lda #0
	jmp VBI_set_paddle_position

VBI_check_paddle_at_right_limit
	cmp m_maxPadPosXPlusOne
	bcc VBI_set_paddle_position

	lda #128
	sta m_padAtRightLimitFlag

	lda m_maxPadPosX


VBI_set_paddle_position
	sta pad_xpos


	lda pad_xpos
	clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3


	lda #0					; not really needed, but..
	sta m_padFrameDeltaStep


;================================================================================
; update enemies logic
;================================================================================
VBI_enemy_logic

.if .def USE_ENEMY_CODE
	lda m_difficultyIndex
	cmp #3		; only extra game mode use enemies
	beq VBI_do_enemies
	jmp VBI_bonus_logic

; check active enemies

; ENEMY_STATE_OFF			= 0
; ENEMY_STATE_MOVING		= 1
; ENEMY_STATE_HOVERING		= 2
; ENEMY_STATE_DESTRUCTION	= 3
; ENEMY_STATE_WAIT_RESPAWN	= 4

VBI_do_enemies
	lda m_enemy1State
	cmp #ENEMY_STATE_MOVING
	beq VBI_moving_or_hovering
	cmp #ENEMY_STATE_HOVERING
	bne VBI_check_state_wait
VBI_moving_or_hovering
	jmp VBI_enemy_collisions
	
VBI_check_state_wait
	cmp #ENEMY_STATE_WAIT_RESPAWN
	bne VBI_check_state_destruction
	jmp VBI_enemy_wait_respawn

VBI_check_state_destruction
	cmp #ENEMY_STATE_DESTRUCTION
	beq VBI_enemy_destruction
	
	jmp VBI_bonus_logic

;----------------------------------------
VBI_enemy_destruction
	dec m_enemy1AnimCounter
	bne VBI_exit_enemy_destruction

; update enemy explosion animation
	ldy m_enemy1PosY
	jsr EraseExplosion1

	ldy m_enemy1AnimIndex
	iny
	cpy #EXPLOSION1_ANIM1_FRAMES
	beq VBI_end_enemy_destruction
	sty m_enemy1AnimIndex
	
	lda TabExplosionAnimFrameTime,y
	sta m_enemy1AnimCounter

	lda TabExplosionAnimOffsetM3,y
	sta m_enemy1OffsetM3
	lda TabExplosionAnimOffsetM2,y
	sta m_enemy1OffsetM2
	lda TabExplosionAnimOffsetM1,y
	sta m_enemy1OffsetM1
	
	ldy m_enemy1PosY
	jsr DrawExplosion1

	jmp VBI_bonus_logic

VBI_end_enemy_destruction
	lda #ENEMY_STATE_WAIT_RESPAWN
	sta m_enemy1State
	
	lda #<[13*FRAMES_ONE_SECOND/2]		; time without enemies in screen
	sta m_enemy1StateTimer
	lda #>[13*FRAMES_ONE_SECOND/2]
	sta m_enemy1StateTimer+1

VBI_exit_enemy_destruction	
	jmp VBI_bonus_logic
	
;----------------------------------------
VBI_enemy_wait_respawn
	bit m_startGameBallCatchedFlag		; don't update the timer if the ball is catched at the start of a level
	bpl VBI_enemy_respawn_time
	jmp VBI_bonus_logic

VBI_enemy_respawn_time
	lda m_enemy1StateTimer		; update state timer
	bne VBI_enemy_wr
	dec m_enemy1StateTimer+1
VBI_enemy_wr
	dec m_enemy1StateTimer
	lda m_enemy1StateTimer
	ora m_enemy1StateTimer+1
	beq VBI_enemy_do_respawn		; if both are zero, create a new enemy

	jmp VBI_bonus_logic

VBI_enemy_do_respawn	
	lda #0
	sta m_enemy1SineIndex
	sta m_enemy1AnimIndex
	
	lda TabEnemyAnimFrameTime		; first value of this table
	sta m_enemy1AnimCounter
	
	lda RANDOM
	and #%111111			; 0 to 63
	sta m_enemy1PosX
	lda RANDOM
	and #%1111			; 0 to 15
	clc
	adc m_enemy1PosX		; 0 to 78 (is not a linear probability but it works good enough)
	adc #[[128-39]-6]		; (screen center X) - (78 / 2) - (sprite width / 2) .. from 83 to 161
	sta m_enemy1PosX		; starting descend coordinate X

	lda #0
	sta m_enemy1PosY
	sta m_enemy1OldPosY
	sta m_enemy1BasePosY
	
	sta m_enemy1PosX_L1
	sta m_enemy1BasePosY_L1
	sta m_enemy1StepX
	sta m_enemy1StepX_L1

	lda #%11000000				; XY000000 two high bits equal to 1, implies add the offsets (move right and down)
	sta m_enemy1DirectionsFlag

	lda #3					; offsets for the normal sprite of the enemies
	sta m_enemy1OffsetM3
	lda #2
	sta m_enemy1OffsetM2
	lda #2
	sta m_enemy1OffsetM1

; enemy type hard coded probabilities: green 50%, blue 30%, red 20%
	ldx #ENEMY_TYPE_RED
	lda RANDOM
	bmi VBI_set_enemy_green
	cmp #51					; 2/5 of 128 approx.
	bcc VBI_set_enemy_type
	ldx #ENEMY_TYPE_BLUE
	bpl VBI_set_enemy_type		; forced jump
VBI_set_enemy_green
	ldx #ENEMY_TYPE_GREEN
VBI_set_enemy_type
	stx m_enemy1Type

	lda TabEnemyColor,x
	sta m_enemy1ColorP3

.if .def PAL_VERSION
	lda #>[222*2]			; starting descend speed in PAL
	sta m_enemy1StepY
	lda #<[222*2]
	sta m_enemy1StepY_L1
.else
	lda #>[185*2]			; starting descend speed in NTSC
	sta m_enemy1StepY
	lda #<[185*2]
	sta m_enemy1StepY_L1
.endif

	lda TabEnemyTopLimit,x		; descend to this height the first time
	clc
	adc #20
	sta m_enemy1LimitY
	lda #255					; just to be sure.. should be ENEMY_LIMIT_RIGHT
	sta m_enemy1LimitX
	
	lda #1
	sta m_enemy1SizeP3
	
	lda #ENEMY_STATE_MOVING
	sta m_enemy1State
	
	jmp VBI_bonus_logic

	
/*
; check collision by distance
check_collision_1_1_x
	lda m_ball1CenterX
	sec
	sbc m_enemy1CenterX
	bcs collision_1_1_x_plus

	eor #255
	adc #1

collision_1_1_x_plus
	cmp #[COLLISION_DIST_X-1]
	bcs no_collision_1_1

check_collision_1_1_y
	lda m_ball1CenterY
	sec
	sbc m_enemy1CenterY
	bcs collision_1_1_y_plus

	eor #255
	adc #1

collision_1_1_y_plus
	cmp #[COLLISION_DIST_Y-1]
	bcs no_collision_1_1

; do collision effect (destroy the enemy)
collision_1_1

no_collision_1_1
*/

;----------------------------------------
; check enemy collisions (P3) against balls (P0, P1, P2)
VBI_enemy_collisions
	lda m_numberOfBallsInPlay
	bne VBI_check_enemy_collisions
	jmp VBI_enemy_state_moving

VBI_check_enemy_collisions
	cmp #3
	bcc VBI_enemy_check_two_balls

	ldx #2		; ball 3 index
	lda m_dliP3PL
	and #%100		; collision of P3 with P2
	bne VBI_destroy_enemy

VBI_enemy_check_two_balls
	lda m_numberOfBallsInPlay
	cmp #2
	bcc VBI_enemy_check_one_ball

	ldx #1		; ball 2 index
	lda m_dliP3PL
	and #%010		; collision of P3 with P1
	bne VBI_destroy_enemy

VBI_enemy_check_one_ball
	ldx #0		; ball 1 index
	lda m_dliP3PL
	and #%001		; collision of P3 with P0
	bne VBI_destroy_enemy
	
	jmp VBI_enemy_state_moving

;----------------------------------------
; destroy the enemy (register X has the index of the collided ball)
VBI_destroy_enemy

; don't change ball direction if the "X" powerup is active?
	bit m_bonusMegaIsActive
	bmi VBI_do_destruction

; all enemy types can change the direction steps
	lda RANDOM
	and #%11		; select one between 4 angles (could be the same)
	tay
	iny		; index value from 1 to 4 for the normal paddle angles
	
	lda tab_pad_xstep1,y
	sta ball_xstep_1,x
	lda tab_pad_xstep2,y
	sta ball_xstep_2,x
	
	lda tab_pad_ystep1,y
	sta ball_ystep_1,x
	lda tab_pad_ystep2,y
	sta ball_ystep_2,x

;----------------------------------------
; change reaction according to enemy type!
	lda m_enemy1Type
	;cmp #ENEMY_TYPE_RED
	beq VBI_enemy_red_collision
	cmp #ENEMY_TYPE_BLUE
	beq VBI_enemy_blue_collision

VBI_enemy_green_collision		; change only the horizontal direction
	lda ball_xdir,x
	eor #[1+2]	; should be a binary xor of the two values
	sta ball_xdir,x

	jmp VBI_do_destruction


VBI_enemy_red_collision			; may change direction horizontal and may change vertical
	lda RANDOM
	bmi VBI_enemy_red_ball_ydir

	lda ball_xdir,x
	eor #[1+2]	; should be a binary xor of the two values
	sta ball_xdir,x

	jmp VBI_do_destruction

VBI_enemy_red_ball_ydir
	lda RANDOM
	bmi VBI_do_destruction

	lda ball_ydir,x
	eor #[1+2]	; should be a binary xor of the two values
	sta ball_ydir,x

	jmp VBI_do_destruction


VBI_enemy_blue_collision			; if going up, go down, if not change horizontal direction
	lda ball_ydir,x
	cmp #1			; going up
	beq VBI_enemy_blue_ball_down

	lda ball_xdir,x
	eor #[1+2]	; should be a binary xor of the two values
	sta ball_xdir,x

	jmp VBI_do_destruction

VBI_enemy_blue_ball_down
	lda #2			; go down now
	sta ball_ydir,x

	;jmp VBI_do_destruction

;----------------------------------------
VBI_do_destruction
	lda #ENEMY_STATE_DESTRUCTION
	sta m_enemy1State

	ldy m_enemy1OldPosY
	jsr EraseEnemy1

	lda #7
	sta m_soundFlag

	lda TabExplosionAnimOffsetM3		; first value of this table
	sta m_enemy1OffsetM3
	lda TabExplosionAnimOffsetM2		; first value of this table
	sta m_enemy1OffsetM2
	lda TabExplosionAnimOffsetM1		; first value of this table
	sta m_enemy1OffsetM1
	
	lda #$06
	sta m_enemy1ColorP3

	lda #0
	sta m_enemy1SizeP3

	lda #0
	sta m_enemy1AnimIndex
	lda TabExplosionAnimFrameTime		; first value of this table
	sta m_enemy1AnimCounter
	
	; update m_enemy1PosX and m_enemy1PosY ?
	;sta m_enemy1PosX
	;sta m_enemy1PosY
	
	ldy m_enemy1PosY
	jsr DrawExplosion1				; draw first frame of the explosion
	
	jmp VBI_bonus_logic

;----------------------------------------
; update enemy moving state
VBI_enemy_state_moving

; TabEnemyShapeP3	(X, Y+7, Lines:5)
; TabEnemyShapeM3M2M1 (X+3, Y, Lines:14)

; erase enemies at old position
	ldy m_enemy1OldPosY
	jsr EraseEnemy1

;----------------------------------------
; move enemies
	lda m_enemy1State
	cmp #ENEMY_STATE_MOVING
	beq VBI_enemy_moving
	jmp VBI_hovering_timer

VBI_enemy_moving	
	bit m_enemy1DirectionsFlag
	bpl VBI_enemy_move_left
	
	clc
	lda m_enemy1PosX_L1
	adc m_enemy1StepX_L1
	sta m_enemy1PosX_L1
	lda m_enemy1PosX
	adc m_enemy1StepX
	sta m_enemy1PosX

	jmp VBI_enemy_check_move_down

VBI_enemy_move_left
	sec
	lda m_enemy1PosX_L1
	sbc m_enemy1StepX_L1
	sta m_enemy1PosX_L1
	lda m_enemy1PosX
	sbc m_enemy1StepX
	sta m_enemy1PosX

VBI_enemy_check_move_down
	bit m_enemy1DirectionsFlag
	bvc VBI_enemy_move_up
	
	clc
	lda m_enemy1BasePosY_L1
	adc m_enemy1StepY_L1
	sta m_enemy1BasePosY_L1
	lda m_enemy1BasePosY
	adc m_enemy1StepY
	sta m_enemy1BasePosY

	jmp VBI_enemy_check_limits
	
VBI_enemy_move_up
	sec
	lda m_enemy1BasePosY_L1
	sbc m_enemy1StepY_L1
	sta m_enemy1BasePosY_L1
	lda m_enemy1BasePosY
	sbc m_enemy1StepY
	sta m_enemy1BasePosY

;----------------------------------------
; check screen limits to start the slowdown
VBI_enemy_check_limits
	bit m_enemy1DirectionsFlag
	bpl VBI_enemy_check_limit_left

	lda m_enemy1PosX
	cmp m_enemy1LimitX
	bcs VBI_enemy_over_limit
	bcc VBI_enemy_check_limit_down
	
VBI_enemy_check_limit_left
	lda m_enemy1PosX
	cmp m_enemy1LimitX
	bcc VBI_enemy_over_limit

VBI_enemy_check_limit_down
	bit m_enemy1DirectionsFlag
	bvc VBI_enemy_check_limit_up
	
	lda m_enemy1BasePosY
	cmp m_enemy1LimitY
	bcs VBI_enemy_over_limit
	bcc VBI_enemy_no_move_limit

VBI_enemy_check_limit_up	
	lda m_enemy1BasePosY
	cmp m_enemy1LimitY
	bcc VBI_enemy_over_limit
	bcs VBI_enemy_no_move_limit

; slowdown speed in both steps
VBI_enemy_over_limit
	lsr m_enemy1StepX
	ror m_enemy1StepX_L1
	lsr m_enemy1StepY
	ror m_enemy1StepY_L1

; check if one of direction steps are zero	
	lda m_enemy1StepX_L1
	ora m_enemy1StepX
	beq VBI_enemy_move_limit
	
	lda m_enemy1StepY_L1
	ora m_enemy1StepY
	bne VBI_enemy_no_move_limit

; one of them is zero, change to hovering
VBI_enemy_move_limit
	lda #ENEMY_STATE_HOVERING
	sta m_enemy1State

	ldx m_enemy1Type
	lda TabEnemyHoverTime_LSB,x
	sta m_enemy1StateTimer
	lda TabEnemyHoverTime_MSB,x
	sta m_enemy1StateTimer+1
	
VBI_enemy_no_move_limit
	jmp VBI_enemy_draw

;----------------------------------------
; update hovering timer
VBI_hovering_timer	
	lda m_enemy1StateTimer		; update state timer
	bne VBI_enemy_ht
	dec m_enemy1StateTimer+1
VBI_enemy_ht
	dec m_enemy1StateTimer
	lda m_enemy1StateTimer
	ora m_enemy1StateTimer+1
	beq VBI_enemy_change_to_move
	jmp VBI_enemy_draw

;----------------------------------------
; change to moving state in a new direction (init directions, steps and limits.. use other direction if passed a hard limit)
VBI_enemy_change_to_move

; use total deltaX and deltaY for next move (acording to enemy type)
	ldy m_enemy1Type

; for the movement in X the red enemy try to follow the player and the green enemy try to move away from the player

VBI_enemy_set_directionX
	cpy #ENEMY_TYPE_BLUE
	beq VBI_enemy_blue_directionX

	lda RANDOM
	cmp #64
	bcc VBI_enemy_blue_directionX		; 25% of the time, red and green behavior is equal to blue (to add a little randomness also)

	lda pad_xpos				; init m_padMiddlePosPM
	clc
	adc m_padHalfSizeX
	adc #PM_OFFSET_X
	sta m_padMiddlePosPM
	
	lda m_enemy1PosX
	clc
	adc #6					; center X position of the normal enemy sprite
	
	cpy #ENEMY_TYPE_RED
	beq VBI_enemy_red_directionX

VBI_enemy_green_directionX
	cmp m_padMiddlePosPM		; compare center X positions of pad and enemy
	bcs VBI_enemy_try_go_right
	bcc VBI_enemy_try_go_left

VBI_enemy_red_directionX
	cmp m_padMiddlePosPM		; compare center X positions of pad and enemy
	bcs VBI_enemy_try_go_left
	bcc VBI_enemy_try_go_right

VBI_enemy_blue_directionX
	lda RANDOM
	bmi VBI_enemy_try_go_left


VBI_enemy_try_go_right
	lda m_enemy1PosX
	clc
	adc TabEnemyDeltaMoveX,y
	bcs VBI_enemy_set_go_left
	cmp #ENEMY_LIMIT_RIGHT
	bcs VBI_enemy_set_go_left
VBI_enemy_go_right
	sta m_enemy1LimitX

	lda #128		; go right bit on
	sta m_enemy1DirectionsFlag

	jmp VBI_enemy_set_directionY

VBI_enemy_try_go_left
	lda m_enemy1PosX
	sec
	sbc TabEnemyDeltaMoveX,y
	bcc VBI_enemy_set_go_right
	cmp #ENEMY_LIMIT_LEFT
	bcc VBI_enemy_set_go_right
VBI_enemy_go_left
	sta m_enemy1LimitX

	lda #0		; go right bit off
	sta m_enemy1DirectionsFlag

	jmp VBI_enemy_set_directionY

VBI_enemy_set_go_right
	lda m_enemy1PosX
	clc
	adc TabEnemyDeltaMoveX,y
	jmp VBI_enemy_go_right

VBI_enemy_set_go_left
	lda m_enemy1PosX
	sec
	sbc TabEnemyDeltaMoveX,y
	jmp VBI_enemy_go_left

;----------------------------------------
VBI_enemy_set_directionY
	lda RANDOM
	bmi VBI_enemy_try_go_up
	
	lda m_enemy1BasePosY
	clc
	adc TabEnemyDeltaMoveY,y
	bcs VBI_enemy_set_go_up
	cmp TabEnemyBottomLimit,y
	bcs VBI_enemy_set_go_up
VBI_enemy_go_down
	sta m_enemy1LimitY

	lda m_enemy1DirectionsFlag
	ora #%01000000		; go down bit on
	sta m_enemy1DirectionsFlag

	jmp VBI_enemy_set_steps

VBI_enemy_try_go_up
	lda m_enemy1BasePosY
	sec
	sbc TabEnemyDeltaMoveY,y
	bcc VBI_enemy_set_go_down
	cmp TabEnemyTopLimit,y		;#ENEMY_LIMIT_TOP
	bcc VBI_enemy_set_go_down
VBI_enemy_go_up
	sta m_enemy1LimitY

	lda m_enemy1DirectionsFlag
	and #%10111111		; go down bit off
	sta m_enemy1DirectionsFlag

	jmp VBI_enemy_set_steps

VBI_enemy_set_go_down
	lda m_enemy1BasePosY
	clc
	adc TabEnemyDeltaMoveY,y
	jmp VBI_enemy_go_down

VBI_enemy_set_go_up
	lda m_enemy1BasePosY
	sec
	sbc TabEnemyDeltaMoveY,y
	jmp VBI_enemy_go_up

;----------------------------------------
VBI_enemy_set_steps
	lda RANDOM
	;and #%1111
	and #%11
	tax
	;lda TabRandomEnemyDirection,x		; transform a number in [0, 15] to a number in [0, 4] (2 has a little higher probability)
	;tax

; use the pad angles and steps to set the direction steps of the enemy	
	lda tab_pad_xstep1,x
	sta m_enemy1StepX_L1
	lda tab_pad_ystep1,x
	sta m_enemy1StepY_L1

	lda #0				; not using the higher values for now (could delete them)
	sta m_enemy1StepX
	sta m_enemy1StepY

	asl m_enemy1StepX_L1
	rol m_enemy1StepX
	asl m_enemy1StepY_L1
	rol m_enemy1StepY

	lda #ENEMY_STATE_MOVING
	sta m_enemy1State
	
;----------------------------------------
; draw enemies at new position
VBI_enemy_draw
	ldy m_enemy1SineIndex
	iny
	cpy #ENEMY1_SINE_TAB_SIZE
	bne VBI_enemy_update_sine
	ldy #0
VBI_enemy_update_sine	
	sty m_enemy1SineIndex
	
	lda m_enemy1BasePosY
	clc
	adc TabEnemySineY,y
	sta m_enemy1PosY
	
	tay
	jsr DrawEnemy1

	lda m_enemy1PosY
	sta m_enemy1OldPosY

;----------------------------------------
; update enemy animation
	dec m_enemy1AnimCounter
	bne VBI_bonus_logic
	
	ldy m_enemy1AnimIndex
	iny
	cpy #ENEMY1_ANIM1_FRAMES
	bne VBI_enemy_reset_anim
	ldy #0
VBI_enemy_reset_anim	
	sty m_enemy1AnimIndex
	
	lda TabEnemyAnimFrameTime,y
	sta m_enemy1AnimCounter

.endif


;================================================================================
; update falling bonus logic
;================================================================================
VBI_bonus_logic
	lda bonus_flag
	bne bvb
	jmp VBI_exit_bonus_logic


bvb	bpl bv2

; do this init of the bonus only one time, just after the creation
; of the bonus powerup, when bonus_flag is 128
	lda #1
	sta bonus_flag
	lda bonus_color
	sta COLPM1
	lda bonus_xpos
	clc
	adc #PM_OFFSET_X
	sta HPOSP1
	adc #2		; offset between P1 and M0
	sta HPOSM0

	ldy old_ball_rypos
	lda #0
	ldx #BALL_SIZEY
bv1	sta p1_adr+PM_OFFSET_Y,y
	iny
	dex
	bne bv1

	jmp bv5


;-------------------------------
; check collision between bonus and pad, using the hardware register
bv2	ldx bonus_ypos
	cpx #PAD_POSY1-BONUS_SIZEY+1
	bcc bv3

	lda P1PL		; p1 & ...
	and #8		; ... p3 ?
	beq bv3

	jsr ClearBonus

	lda m_bonusType
	ora #128
	sta m_bonusType

	jmp VBI_exit_bonus_logic


; clear old bonus first two lines (assuming the speed is below two lines per frame)
bv3	lda #0
	sta p1_adr+PM_OFFSET_Y,x
	sta p1_adr+PM_OFFSET_Y+1,x
	lda m0_adr+PM_OFFSET_Y,x
	and #%11111100
	sta m0_adr+PM_OFFSET_Y,x
	lda m0_adr+PM_OFFSET_Y+1,x
	and #%11111100
	sta m0_adr+PM_OFFSET_Y+1,x


; bonus falling speed
	lda bonus_ypos_decimal
	clc
	adc #BONUS_FALL_SPEED_LSB
	sta bonus_ypos_decimal
	txa
	adc #BONUS_FALL_SPEED_MSB

	cmp #MAX_BONUS_POSY
	bcc bv4

; bonus reached the bottom of the screen, clear it
	jsr ClearBonus

	lda #0
	sta m_bonusType
	jmp VBI_exit_bonus_logic


bv4	sta bonus_ypos

	dec bonus_sh_ctd
	bne bv5
	lda #BONUS_ANIM_SPEED
	sta bonus_sh_ctd
	dec bonus_sh_line
	bpl bv5
	lda #BONUS_SIZEY+8-1
	sta bonus_sh_line

bv5	ldx bonus_ypos
	ldy bonus_sh_line

; draw bonus, over P1 and M0
	lda (ptr_bonus_sh),y
	and #%01111110					; clear first and last pixels
	sta p1_adr+PM_OFFSET_Y,x
	lda m0_adr+PM_OFFSET_Y,x
	ora #%11      ; m0
	sta m0_adr+PM_OFFSET_Y,x

	.rept 6
	iny
	lda (ptr_bonus_sh),y
	sta p1_adr+PM_OFFSET_Y+#+1,x
	lda m0_adr+PM_OFFSET_Y+#+1,x
	ora #%11      ; m0
	sta m0_adr+PM_OFFSET_Y+#+1,x
	.endr

	iny
	lda (ptr_bonus_sh),y
	and #%01111110					; clear first and last pixels
	sta p1_adr+PM_OFFSET_Y+7,x
	lda m0_adr+PM_OFFSET_Y+7,x
	ora #%11      ; m0
	sta m0_adr+PM_OFFSET_Y+7,x


;-------------------------------
VBI_exit_bonus_logic
	lda #255
	sta HITCLR


;-------------------------------
; update old ball real pos
	lda ball_rypos		; multiball code change
	sta old_ball_rypos	; multiball code change

	lda ball_rypos+1
	sta old_ball_rypos+1
	lda ball_rypos+2
	sta old_ball_rypos+2


;================================================================================
; update sound effects logic
;================================================================================
VBI_sound_logic
	ldx m_soundFlag
	beq VBI_old_sound

; check new sound priority against the one of the old sound (if there was no sound, old priority would be 0)
	lda TabSoundPriority-1,x
	cmp m_soundPriority		; old sound priority, if there was one
	bcc VBI_old_sound		; new sound has lower priority
	bne VBI_sound_higher_priority		; new sound has higher priority, just override
	
; don't allow new sounds (of the same priority) before completing at least 3 steps of the old sound
	lda m_soundIndex
	beq VBI_new_sound		; sound index 0 should mean there was no sound playing (with the priority check this should not be needed)
	cmp #3
	bcs VBI_new_sound

	lda #0			; don't buffer the new sound request (is just lost)
	sta m_soundFlag
	jmp VBI_old_sound


VBI_sound_higher_priority
	sta m_soundPriority
	
VBI_new_sound
	dex		; sound flag values start from 1

	lda tab_snd_len,x
	sta m_soundSize
	lda #0
	sta m_soundIndex

; init the 4 hard coded pointers
	lda tab_lsb_snd,x
	sta VBI_pointerSound_F1+1
	lda tab_msb_snd,x
	sta VBI_pointerSound_F1+2

	lda VBI_pointerSound_F1+1
	clc
	adc m_soundSize
	sta VBI_pointerSound_C1+1
	lda VBI_pointerSound_F1+2
	adc #0
	sta VBI_pointerSound_C1+2

	lda VBI_pointerSound_C1+1
	clc
	adc m_soundSize
	sta VBI_pointerSound_F3+1
	lda VBI_pointerSound_C1+2
	adc #0
	sta VBI_pointerSound_F3+2

	lda VBI_pointerSound_F3+1
	clc
	adc m_soundSize
	sta VBI_pointerSound_C3+1
	lda VBI_pointerSound_F3+2
	adc #0
	sta VBI_pointerSound_C3+2

	lda tab_snd_ctl,x
	sta AUDCTL

	lda #0
	sta m_soundFlag


VBI_old_sound
	lda m_soundSize
	beq VBI_exit

	ldy m_soundIndex

VBI_pointerSound_F1
	lda $FFFF,y
	sta AUDF1

VBI_pointerSound_C1
	lda $FFFF,y
	sta AUDC1

VBI_pointerSound_F3
	lda $FFFF,y
	sta AUDF3

VBI_pointerSound_C3
	lda $FFFF,y
	sta AUDC3

	iny
	cpy m_soundSize
	bne VBI_update_sound_index

; clear sound info
	ldy #0
	sty m_soundSize
	sty m_soundPriority

VBI_update_sound_index
	sty m_soundIndex


;================================================================================
VBI_exit

.if .def USE_ENEMY_CODE
; do enemy late update, this is for the pause and also because P3 is also used for the paddle
	lda m_enemy1PosX
	sta HPOSP3

	clc
	adc m_enemy1OffsetM3
	sta HPOSM3
	adc m_enemy1OffsetM2
	sta HPOSM2
	adc m_enemy1OffsetM1
	sta HPOSM1

; hack to set the enemy color
	lda m_enemy1ColorP3
	sta COLPM3

; also need to change the size for P3
	lda m_enemy1SizeP3
	sta SIZEP3
.endif


	.if .def SHOW_TIMING_AREAS
	lda m_mainAreaColor
	sta COLBK
	.endif

	sta POTGO			; reset all POT counters

	;jmp XITVB_D		; this is no longer a VBI..
	;rts

	lda save_a
	ldx save_x
	ldy save_y

	rti


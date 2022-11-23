
; set starting high score and level
	lda #0
	sta m_sessionHighLevel

	sta m_sessionHighScore
	sta m_sessionHighScore+2
	lda #$10		; start with a high score of 10000 (for casual difficulty)
	sta m_sessionHighScore+1

; init options
	lda #0
	;sta m_selectedVausIndex
	sta m_selectedLevelIndex
	sta m_selectedControllerIndex
	sta m_usePaddleControllerFlag
	;lda #1	; casual
	lda #3	; extra
	sta m_difficultyIndex
	lda #2
	sta m_selectedMouseAccel
	lda #3	; 100%
	sta m_selectedPaddleAngleIndex

	lda #%11111111
	sta m_triggerTypeMask

; init difficulty parameters (for arcade)
; 	lda #STARTING_BALL_SPEED
; 	sta m_startingBallSpeed
; 	lda #TOP_BORDER_BALL_SPEED
; 	sta m_topBorderBallSpeed
; 	lda #MAX_BALL_SPEED
; 	sta m_maxBallSpeed
; 	lda #BALL_SPEEDUP_HALF_SECONDS
; 	sta m_ballSpeedUpHalfSeconds

; init difficulty parameters (for casual and extra modes)
	lda #[STARTING_BALL_SPEED-2]
	sta m_startingBallSpeed
	lda #[TOP_BORDER_BALL_SPEED-1]
	sta m_topBorderBallSpeed
	lda #[MAX_BALL_SPEED-1]
	sta m_maxBallSpeed
	lda #[BALL_SPEEDUP_HALF_SECONDS*2]
	sta m_ballSpeedUpHalfSeconds

; unlock first 3 normal and extra levels
	lda #128
	sta TabLevelUnlocked
	sta TabLevelUnlocked+1
	sta TabLevelUnlocked+2

	sta TabLevelUnlockedExtra
	sta TabLevelUnlockedExtra+1
	sta TabLevelUnlockedExtra+2


StartGame
	jsr InitAll

	SetDisplayListAddress DL2_address

	SetFontAddress Atari_font_address

	SetColor 1, 12
	SetColor 2, 0

.if .def PAL_VERSION
	lda #$10
.else
	lda #$20
.endif
	sta COLPM0
	sta COLPM1
	sta COLPM2
	sta COLPM3

	lda #3
	sta SIZEP0
	sta SIZEP1
	sta SIZEP2
	sta SIZEP3

	lda #0
	sta SIZEM

	VcountWait 128

; show presentation screen
	lda #[DV_DMA_ON | DV_NARROW_PF]
	sta DMACTL


; only run in the correct system (show "wrong system" message)
	lda PAL
	and #14

.if .def PAL_VERSION
	beq CorrectVideoSystem
	
	//SetDisplayListAddress DL_PAL_address
	
	SetDisplayListAddress DL_NTSC_address
	lda #<DL_PAL_data_address
	sta DL_NTSC_message
	lda #>DL_PAL_data_address
	sta DL_NTSC_message+1
.else
	bne CorrectVideoSystem
	
	SetDisplayListAddress DL_NTSC_address
.endif

IncorrectVideoSystem
	jmp IncorrectVideoSystem

CorrectVideoSystem

; init DLI for the tittle screen
	SetVector NMIH_VECTOR, Tittle_score_DLI1_address


; init RMT menu music
	lda #0
	sta RMTGLOBALVOLUMEFADE

	ldx #<RMT_song_address		; low byte of RMT module to X reg
	ldy #>RMT_song_address		; hi byte of RMT module to Y reg
	lda #0					; starting song line 0-255 to A reg
	jsr RASTERMUSICTRACKER		; Init


; init interruptions
	lda #%10000000		; only DLI's on
	sta NMIEN


;----------------------------------------
; init old input vars
	lda #0
	sta m_oldKeyPressedFlag
	lda #255
	sta m_oldKeyPressedValue

	lda #128		; to fix a problem when selecting paddles with a mouse connected
	sta m_oldTriggerPressedFlag


; init RMT vcount update system
	lda VCOUNT
	sta m_currentVcountLineRMT


sg_loop

; update RMT vcount update system
	lda m_currentVcountLineRMT
	clc
	adc #RMT_UPDATE_VCOUNT_LINES
	cmp #[MAX_VCOUNT_VALUE+1]
	bcc sg_vcount_normal

sg_vcount_overflow
	sbc #[MAX_VCOUNT_VALUE+1]

sg_vcount_normal
	sta m_nextVcountLineRMT		; set next target value


; wait until reached or surpassed target vcount value
	cmp m_currentVcountLineRMT
	bcc sg_next_vcount_lower

sg_next_vcount_bigger
	lda VCOUNT
	cmp m_currentVcountLineRMT
	bcc sg_play_music_frame
	cmp m_nextVcountLineRMT
	bcs sg_play_music_frame

	jmp sg_next_vcount_bigger	; jmp sg_check_input_logic?, return to a special point!


sg_next_vcount_lower
	lda VCOUNT
	cmp m_currentVcountLineRMT
	bcs sg_next_vcount_lower		; bcs sg_check_input_logic?, return to a special point!
	cmp m_nextVcountLineRMT
	bcs sg_play_music_frame

	jmp sg_next_vcount_lower		; jmp sg_check_input_logic?, return to a special point!


sg_play_music_frame
; play RMT music
	jsr RASTERMUSICTRACKER+3		; play one frame


	lda m_nextVcountLineRMT
	sta m_currentVcountLineRMT


;----------------------------------------
; check fade out logic
	lda RMTGLOBALVOLUMEFADE
	beq sg_check_input_logic

	dec m_musicFadeOutCounter
	bne sg_loop

	lda #MUSIC_FADEOUT_VCOUNT_STEPS
	sta m_musicFadeOutCounter

	lda RMTGLOBALVOLUMEFADE
	clc
	adc #$10		; this uses only the high 4 bits
	sta RMTGLOBALVOLUMEFADE

	cmp #$D0		; max fade out substract value
	bcc sg_loop

	jmp sg_start_game


;----------------------------------------
; check keys input logic
sg_check_input_logic
	lda SKCTL
	and #4	; a key pressed ?
	beq sg_key_pressed_logic

; no key pressed
	lda #0
	sta m_newKeyPressedFlag

	lda #255		; A + SHIFT + CONTROL (used as a "no-key" value)
	sta m_newKeyPressedValue

	jmp sg_check_trigger_pressed		; could be key released logic..


sg_key_pressed_logic
	lda #128
	sta m_newKeyPressedFlag

	lda KBCODE
	and #%00111111		; bit7 -> control, bit6 -> shift
	sta m_newKeyPressedValue

	cmp m_oldKeyPressedValue
	bne sg_check_difficulty_key

	jmp sg_check_trigger_pressed		; could be key released logic..


;----------------------------------------
sg_check_difficulty_key
	;cmp #58		; "D"
	cmp #61		; "G"
	beq sg_change_difficulty
	jmp sg_check_controller_key

; change difficulty level
sg_change_difficulty
	ldx m_difficultyIndex
	inx
	cpx #4
	bne sg_set_difficulty
	ldx #0
sg_set_difficulty
	stx m_difficultyIndex

	beq sg_difficulty1			; difficulty easy (speed is always the minimun)

	cpx #1
	beq sg_difficulty2

	cpx #2
	beq sg_difficulty3

sg_difficulty4					; difficulty extra (casual speed)
	ldx #[6*3]

; reset selected extra level
	lda #0
	sta m_selectedLevelIndex
	lda TabLevelNameExtra
	sta DL2_options_line+BYTES_LINE*3+23
	lda TabLevelNameExtra+1
	sta DL2_options_line+BYTES_LINE*3+24

	jmp sg_difficulty_speed_med


sg_difficulty2					; difficulty casual
	ldx #6

	jmp sg_difficulty_speed_med


sg_difficulty1					; difficulty easy
; reset selected normal level
	lda #0
	sta m_selectedLevelIndex
	lda TabLevelName
	sta DL2_options_line+BYTES_LINE*3+23
	lda TabLevelName+1
	sta DL2_options_line+BYTES_LINE*3+24

	jmp sg_set_difficulty_text


sg_difficulty3					; difficulty arcade
	ldx #[6*2]


sg_difficulty_speed_hard
	lda #STARTING_BALL_SPEED
	sta m_startingBallSpeed
	lda #TOP_BORDER_BALL_SPEED
	sta m_topBorderBallSpeed
	lda #MAX_BALL_SPEED
	sta m_maxBallSpeed
	lda #BALL_SPEEDUP_HALF_SECONDS
	sta m_ballSpeedUpHalfSeconds

	jmp sg_set_difficulty_text


sg_difficulty_speed_med
	lda #[STARTING_BALL_SPEED-2]
	sta m_startingBallSpeed
	lda #[TOP_BORDER_BALL_SPEED-1]
	sta m_topBorderBallSpeed
	lda #[MAX_BALL_SPEED-1]
	sta m_maxBallSpeed
	lda #[BALL_SPEEDUP_HALF_SECONDS*2]
	sta m_ballSpeedUpHalfSeconds


sg_set_difficulty_text
	?rowNum = 0
	.rept 6
		lda Text_difficulty1+?rowNum,x
		sta DL2_options_line+18+?rowNum
		?rowNum ++
	.endr


	jsr RestoreGameTypeHighScore


	jmp sg_end_input_logic


;----------------------------------------
; sg_check_vaus_key
; 	cmp #16		; "V"
; 	bne sg_check_controller_key
;
; ; change vaus type (not working yet!)
; 	ldx m_selectedVausIndex
; 	inx
; 	cpx #1 ;2
; 	bne sg_set_vaus_type
; 	ldx #0
; sg_set_vaus_type
; 	stx m_selectedVausIndex
;
; 	beq sg_vaus1
;
; 	ldx #6
;
; sg_vaus1
; 	lda Text_vaus_type1,x
; 	sta DL2_options_line+BYTES_LINE+18
; 	lda Text_vaus_type1+1,x
; 	sta DL2_options_line+BYTES_LINE+19
; 	lda Text_vaus_type1+2,x
; 	sta DL2_options_line+BYTES_LINE+20
; 	lda Text_vaus_type1+3,x
; 	sta DL2_options_line+BYTES_LINE+21
; 	lda Text_vaus_type1+4,x
; 	sta DL2_options_line+BYTES_LINE+22
; 	lda Text_vaus_type1+5,x
; 	sta DL2_options_line+BYTES_LINE+23
;
; 	jmp sg_end_input_logic


;----------------------------------------
sg_check_controller_key
	cmp #18		; "C"
	beq sg_controller_key
	jmp sg_check_mouse_key

sg_controller_key
; change controller type
	ldx m_selectedControllerIndex
	inx
	cpx #8
	bne sg_set_controller_index
	ldx #0
sg_set_controller_index
	stx m_selectedControllerIndex

	beq sg_controller_type1
	cpx #1
	beq sg_controller_type2
	cpx #2
	beq sg_controller_type3
	cpx #3
	bne sg_check_paddle_controllers

sg_controller_type4
	ldx #[8*3]

	jmp sg_controller_type_amiga


sg_controller_type1
	lda #<TabGetLowNibble
	sta IG_nibbleTable+1
	lda #>TabGetLowNibble
	sta IG_nibbleTable+2

	lda #<TabGetLowNibble
	sta DLI_nibbleTable+1
	lda #>TabGetLowNibble
	sta DLI_nibbleTable+2

; use TRIG0 ($D010) to get the trigger value
	lda #<TRIG0
	sta TRIGGER_address1+1
	sta TRIGGER_address3+1
	sta TRIGGER_address4+1

	lda #>TRIG0
	sta TRIGGER_address1+2
	sta TRIGGER_address3+2
	sta TRIGGER_address4+2

	lda #0
	sta m_usePaddleControllerFlag

	lda #%11111111
	sta m_triggerTypeMask

; show mouse accel info line
	lda #<[DL2_options_line+BYTES_LINE*2]
	sta DL2_LMS_options_line3
	lda #>[DL2_options_line+BYTES_LINE*2]
	sta DL2_LMS_options_line3+1

	jmp sg_controller_type_atari


sg_controller_type3
	ldx #[8*2]

	lda #<TabGetHighNibble
	sta IG_nibbleTable+1
	lda #>TabGetHighNibble
	sta IG_nibbleTable+2

	lda #<TabGetHighNibble
	sta DLI_nibbleTable+1
	lda #>TabGetHighNibble
	sta DLI_nibbleTable+2

; use TRIG1 ($D011) to get the trigger value
	inc TRIGGER_address1+1
	inc TRIGGER_address3+1
	inc TRIGGER_address4+1

	jmp sg_controller_type_atari


sg_controller_type2
	ldx #8

; 	lda #<TabGetLowNibble
; 	sta IG_nibbleTable+1
; 	lda #>TabGetLowNibble
; 	sta IG_nibbleTable+2
;
; 	lda #<TabGetLowNibble
; 	sta DLI_nibbleTable+1
; 	lda #>TabGetLowNibble
; 	sta DLI_nibbleTable+2

	jmp sg_controller_type_amiga


sg_check_paddle_controllers
; 	cpx #4
; 	beq sg_controller_type5
	cpx #5
	beq sg_controller_type6
	cpx #6
	beq sg_controller_type7
	cpx #7
	beq sg_controller_type8

sg_controller_type5
	ldx #[8*4]

	lda #128
	sta m_usePaddleControllerFlag

; use PORTA ($D300) to get the triggers (PTRIG0..3)
	lda #<PORTA
	sta TRIGGER_address1+1
	sta TRIGGER_address3+1
	sta TRIGGER_address4+1

	lda #>PORTA
	sta TRIGGER_address1+2
	sta TRIGGER_address3+2
	sta TRIGGER_address4+2

	lda #%00000100			; PTRIG0
	sta m_triggerTypeMask

	lda #<POT0
	sta POT_address1+1

; show paddle angle info line
	lda #<[DL2_options_line+BYTES_LINE*4]
	sta DL2_LMS_options_line3
	lda #>[DL2_options_line+BYTES_LINE*4]
	sta DL2_LMS_options_line3+1

	jmp sg_set_controller_text

sg_controller_type6
	ldx #[8*5]

	lda #%00001000			; PTRIG1
	sta m_triggerTypeMask

	inc POT_address1+1

	jmp sg_set_controller_text

sg_controller_type7
	ldx #[8*6]

	lda #%01000000			; PTRIG2
	sta m_triggerTypeMask

	inc POT_address1+1

	jmp sg_set_controller_text

sg_controller_type8
	ldx #[8*7]

	lda #%10000000			; PTRIG3
	sta m_triggerTypeMask

	inc POT_address1+1

	jmp sg_set_controller_text


sg_controller_type_amiga
	lda #%1010
	sta dli_mouseTypeHMoveMask+1

	lda #<TabNextValueMovingRightAmiga
	sta dli_checkMoveRight+1
	lda #>TabNextValueMovingRightAmiga
	sta dli_checkMoveRight+2

	lda #<TabNextValueMovingLeftAmiga
	sta dli_checkMoveLeft+1
	lda #>TabNextValueMovingLeftAmiga
	sta dli_checkMoveLeft+2

	jmp sg_set_controller_text


sg_controller_type_atari
	lda #%11
	sta dli_mouseTypeHMoveMask+1

	lda #<TabNextValueMovingRight
	sta dli_checkMoveRight+1
	lda #>TabNextValueMovingRight
	sta dli_checkMoveRight+2

	lda #<TabNextValueMovingLeft
	sta dli_checkMoveLeft+1
	lda #>TabNextValueMovingLeft
	sta dli_checkMoveLeft+2


sg_set_controller_text
	?rowNum = 0
	.rept 8
		lda Text_controller_type1+?rowNum,x
		sta DL2_options_line+BYTES_LINE+19+?rowNum
		?rowNum ++
	.endr

	jmp sg_end_input_logic


;----------------------------------------
sg_check_mouse_key
	cmp #37		; "M"
	bne sg_check_level_key

; change max mouse speed step value, two hard coded values in the DLI code
	ldx m_selectedMouseAccel
	inx
	cpx #6
	bne sg_set_max_accel
	ldx #MIN_MOUSE_STEP		; (2)
sg_set_max_accel
	stx m_selectedMouseAccel

	txa
	clc
	adc #"0"
	sta DL2_options_line+BYTES_LINE*2+23

	;inx		; add 1 to displayed value (min mouse step should be 1, for no acceleration)
	stx dli_mouse_accel_step_value1+1
	stx dli_mouse_accel_step_value2+1

	jmp sg_end_input_logic


;----------------------------------------
sg_check_level_key
	cmp #62		; "S"
	bne sg_check_paddle_key

; change starting level
	ldx m_selectedLevelIndex

	lda m_difficultyIndex
	cmp #3	; "extra" game mode
	bcs sg_find_extra_level_loop

sg_find_level_loop
	inx
	cpx #MAX_LEVEL_NUM
	bne sg_set_level
	ldx #0
sg_set_level
	stx m_selectedLevelIndex

	lda TabLevelUnlocked,x
	bpl sg_find_level_loop

	txa
	asl
	tax
	lda TabLevelName,x
	sta DL2_options_line+BYTES_LINE*3+23
	lda TabLevelName+1,x
	sta DL2_options_line+BYTES_LINE*3+24

	jmp sg_end_input_logic


sg_find_extra_level_loop
	inx
	cpx #MAX_LEVEL_NUM_EXTRA
	bne sg_set_extra_level
	ldx #0
sg_set_extra_level
	stx m_selectedLevelIndex

	lda TabLevelUnlockedExtra,x
	bpl sg_find_extra_level_loop

	txa
	asl
	tax
	lda TabLevelNameExtra,x
	sta DL2_options_line+BYTES_LINE*3+23
	lda TabLevelNameExtra+1,x
	sta DL2_options_line+BYTES_LINE*3+24

	jmp sg_end_input_logic


;----------------------------------------
sg_check_paddle_key
	cmp #10		; "P"
	bne sg_check_return_key

; change paddle angle factor
	ldx m_selectedPaddleAngleIndex
	inx
	cpx #4
	bne sg_set_paddle_angle
	ldx #0
sg_set_paddle_angle
	stx m_selectedPaddleAngleIndex

	beq sg_set_paddle_angle_text
	cpx #1
	beq sg_set_paddle_angle_2
	cpx #2
	beq sg_set_paddle_angle_3

sg_set_paddle_angle_4
	ldx #[4*3]
	jmp sg_set_paddle_angle_text

sg_set_paddle_angle_2
	ldx #4
	jmp sg_set_paddle_angle_text

sg_set_paddle_angle_3
	ldx #[4*2]

sg_set_paddle_angle_text
	?rowNum = 0
	.rept 4
		lda Text_paddle_angle1+?rowNum,x
		sta DL2_options_line+BYTES_LINE*4+21+?rowNum
		?rowNum ++
	.endr

	jmp sg_end_input_logic


;----------------------------------------
; check for a "just pressed" of the return key, to start the game
sg_check_return_key
	cmp #12			; "return" key
	;beq sg_start_game
	beq sg_start_fade_out


;----------------------------------------
; check for a "just pressed" of the trigger, to start the game
sg_check_trigger_pressed
TRIGGER_address1
	lda TRIG0
	and m_triggerTypeMask
	beq sg_trigger_pressed

	lda #0
	sta m_newTriggerPressedFlag

	jmp sg_end_input_logic


sg_trigger_pressed
	lda #128
	sta m_newTriggerPressedFlag

	lda m_oldTriggerPressedFlag
	;beq sg_start_game			; trigger just pressed
	beq sg_start_fade_out


;----------------------------------------
sg_end_input_logic
; at the end of the step, save old values for the next frame
	lda m_newKeyPressedFlag
	sta m_oldKeyPressedFlag

	lda m_newKeyPressedValue
	sta m_oldKeyPressedValue

	lda m_newTriggerPressedFlag
	sta m_oldTriggerPressedFlag

	jmp sg_loop


;----------------------------------------
sg_start_fade_out
	lda #$10		; this uses only the high 4 bits
	sta RMTGLOBALVOLUMEFADE

	lda #MUSIC_FADEOUT_VCOUNT_STEPS
	sta m_musicFadeOutCounter

	jmp sg_loop


;----------------------------------------
sg_start_game
	;jsr InitAll

	VcountWait 128

	lda #0
	sta DMACTL

	sta NMIEN

	sta GRAFP0
	sta GRAFP1
	sta GRAFP2
	sta GRAFP3
	sta GRAFM

; stop RMT menu music
	jsr RASTERMUSICTRACKER+9

	jmp InitGame


;--------------------------------------------------------------------------------

InitAll

	VcountWait 128

; disable interruptions, clear graphics and sound
	ClearSystem


; clear P/M area
	lda #0
	tax

ia_clear_pm_area
	sta m0_adr,x
	sta p0_adr,x
	sta p1_adr,x
	sta p2_adr,x
	sta p3_adr,x
	inx
	bne ia_clear_pm_area


; clear vars area in page 0 (200 bytes)
	tax

ia_clear_page0_area
	sta Vars_address,x
	inx
	cpx #Static_vars_address
	bne ia_clear_page0_area

	rts

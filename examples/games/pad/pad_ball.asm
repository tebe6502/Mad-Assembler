
UpdateBallPosition

; the register X must have the current ball index
	ldx m_currentBallIndex


; first check if the ball is catched by the paddle
	bit m_ballCatchedByPadFlag		; OPTIMIZE: this check should be done only once per frame
	bpl hmv

	lda pad_xpos
	clc
	adc m_catchedBallPadOffset
	sta ball_xpos_1,x

	jmp md_exit


;--------------------------------------------------------------
; check horizontal movement of the ball

hmv	lda ball_xdir,x				; OPTIMIZE:  should be 0 or 128, bmi/bpl check instead (there is no "0" case right now)
clf	cmp #1			; move left
	bne crg

; update position of the ball (step below one pixel)
move_left
	lda ball_xpos_3,x				; OPTIMIZE: probably there is no need for the xpos_3, xstep_2
	sec
	sbc ball_xstep_2,x
	sta ball_xpos_3,x
	lda ball_xpos_2,x
	sbc ball_xstep_1,x
	bcs ml1
	dec ball_xpos_1,x
ml1	sta ball_xpos_2,x

; check left border collision first
	lda ball_xpos_1,x				; OPTIMIZE?: normally only need this check once per frame (enemies can change that!), do this check #3
	cmp #MIN_BALL_POSX-1
	bne ml2

	jsr DoHitLeft					; OPTIMIZE: inside..
	jmp ml_exit


; check bottom limit of the bricks zone (zone without bricks, could do the same for the top zone).. OPTIMIZE: do these checks #2!
ml2	lda ball_ypos_1,x
	cmp #BRICK_SIZEY*BOTTOM_BRICK_NUM
	bcs ml_exit

; check if we are touching the right limit of a brick.. OPTIMIZE: do this check #4!
	lda ball_xpos_1,x
	and #%111			; x offset (0 to 7)
	cmp #BRICK_SIZEX-1	; offset bx = 7 (ball width pixels in offsets: 7 0 1)
	bne ml_exit

; check if we crossed the limit in this step
	lda ball_xpos_1,x				; OPTIMIZE: do this check #1! (this check is not equal when moving right)
	cmp ball_rxpos,x	; old x pos (the pos before adding the step)
	beq ml_exit		; "deja vu" (we were already at this pixel, so we didn't cross any border)

	jsr ChangePosToChar				; OPTMIZE: do "inline"

	jsr CheckTopBottomBricks
	beq ml_exit		; there was no collision

	jsr DoHitLeft

ml_exit
	jmp vmv


;-------------------------------
crg	cmp #2			; move right
	bne mr_exit

; update position of the ball (step below one pixel)
move_right
	lda ball_xpos_3,x
	clc
	adc ball_xstep_2,x
	sta ball_xpos_3,x
	lda ball_xpos_2,x
	adc ball_xstep_1,x
	bcc mr1
	inc ball_xpos_1,x
mr1	sta ball_xpos_2,x

; check right border collision first
	lda ball_xpos_1,x
	cmp #MAX_BALL_POSX+1
	bne mr2

	jsr DoHitRight
	jmp mr_exit


; check bottom limit of the bricks zone
mr2	lda ball_ypos_1,x
	cmp #BRICK_SIZEY*BOTTOM_BRICK_NUM
	bcs mr_exit

; check if we are touching the left limit of a brick
	lda ball_xpos_1,x
	and #%111			; x offset (0 to 7)
	cmp #[BRICK_SIZEX-BALL_SIZEX]+1	; offset bx = 6 (ball in: 6 7 0)
	bne mr_exit

; check if we crossed the limit in this step
	lda ball_xpos_1,x				; FIX this, when the old pos offset was 0, then we always cross a limit!
	cmp ball_rxpos,x	; old x pos (the pos before adding the step)
	beq mr_exit		; "deja vu" (we were already at this pixel)

	jsr ChangePosToChar

	inc brick_xchar

	jsr CheckTopBottomBricks
	beq mr_exit
	jsr DoHitRight

mr_exit


;--------------------------------------------------------------

; check vertical movement of the ball
vmv	ldx m_currentBallIndex

	lda ball_ydir,x
cup	cmp #1			; move up
	bne cdw

; update position of the ball (step below one pixel)
move_up
	lda ball_ypos_3,x
	sec
	sbc ball_ystep_2,x
	sta ball_ypos_3,x
	lda ball_ypos_2,x
	sbc ball_ystep_1,x
	bcs mu1
	dec ball_ypos_1,x
mu1	sta ball_ypos_2,x

; check top border collision first
	lda ball_ypos_1,x
	cmp #MIN_BALL_POSY-1
	bne mu2

	jsr DoHitUp

; update speed if is the first time that the ball hit the top border..
; 	bit m_ballHitTopBorderFlag
; 	bmi mu_exit
; 	lda #128
; 	sta m_ballHitTopBorderFlag
; 	lda m_topBorderBallSpeed
; 	sta m_currentBallSpeed

; ..or set a min speed after hitting the top border always
	lda m_currentBallSpeed
	cmp m_topBorderBallSpeed
	bcs mu_exit

	lda m_topBorderBallSpeed
	sta m_currentBallSpeed

	;lda #0
	;sta m_ballHitsCounter		; reset speedup counter
	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer		; reset speedup timer

	jmp mu_exit


; check bottom limit of the bricks zone
mu2	lda ball_ypos_1,x
	cmp #BRICK_SIZEY*BOTTOM_BRICK_NUM
	bcs mu_exit

; check if we are touching the bottom limit of a brick
	lda ball_ypos_1,x
	and #%111			; y offset (0 to 7)
	cmp #BRICK_SIZEY-1	; offset by = 7 (ball in: 7 0 1 2 3 4)
	bne mu_exit

	lda ball_ypos_1,x
	cmp ball_rypos,x	; old y pos (the pos before adding the step)
	beq mu_exit		; "deja vu" (we were already at this pixel)

	jsr ChangePosToChar

	jsr CheckLeftRightBricks
	beq mu_exit
	jsr DoHitUp

mu_exit
	jmp UpdateRealCoords


;-------------------------------

cdw	cmp #2			; move down
	bne md_exit

; update position of the ball (step below one pixel)
move_down
	lda ball_ypos_3,x
	clc
	adc ball_ystep_2,x
	sta ball_ypos_3,x
	lda ball_ypos_2,x
	adc ball_ystep_1,x
	bcc md1
	inc ball_ypos_1,x
md1	sta ball_ypos_2,x

; check bottom limit of the bricks zone (-1)
	lda ball_ypos_1,x
	cmp #BRICK_SIZEY*[BOTTOM_BRICK_NUM-1]
	bcs md2

; check if we are touching the top limit of a brick
	lda ball_ypos_1,x
	and #%111			; y offset (0 to 7)
	cmp #[BRICK_SIZEY-BALL_SIZEY]+1	; offset by = 3 (ball in: 3 4 5 6 7 0)
	bne md_exit

	lda ball_ypos_1,x
	cmp ball_rypos,x	; old y pos (the pos before adding the step)
	beq md_exit		; "deja vu" (we were already at this pixel)

	jsr ChangePosToChar

	inc brick_ychar

	jsr CheckLeftRightBricks
	beq md_exit
	jsr DoHitDown

	jmp md_exit


; check lost ball condition, at the bottom of the screen
md2	lda ball_ypos_1,x
	cmp #MAX_BALL_POSY
	bcc md3

; HACK to never lost a ball
; 	lda #1
; 	sta ball_ydir,x

	lda #128
	sta m_ballLostFlag,x

	jmp UpdateRealCoords


; check hit paddle condition, at the bottom of the screen
md3	jsr CheckPadCollision


md_exit
	jmp UpdateRealCoords


;================================================================================

; the register X must have the current ball index

CheckPadCollision
	ldx m_currentBallIndex

	lda ball_ypos_1,x
	cmp #PAD_BALL_POSY1
	bcc CPC_exit
	cmp #PAD_BALL_POSY2+1
	bcs CPC_exit

	lda ball_xpos_1,x
	clc
	adc #BALL_SIZEX

	sec
	sbc pad_xpos

	cmp m_padCollisionSizeX			;#[PAD_SIZEX+BALL_SIZEX+1]
	bcs CPC_exit

; there is a collision
	tay

	sta m_catchedBallPadOffset		; just in case we need it..

	;lda tab_pad_xdir,y

; this "half size" method works for a ball with an odd number of pixels in X (width)
; (also, the paddle should have and even number of pixels in X)
	lda #1			; left(1) direction
	cpy m_padCollisionHalfSizeX		;#[[BALL_SIZEX+PAD_SIZEX+1]/2]
	bcc CPC_left_side_collision
	lda #2			; right(2) direction

CPC_left_side_collision
	sta ball_xdir,x

	lda TabCurrentPadAngleIndex,y
	tay

	lda tab_pad_xstep1,y
	sta ball_xstep_1,x
	lda tab_pad_xstep2,y
	sta ball_xstep_2,x

	lda tab_pad_ystep1,y
	sta ball_ystep_1,x
	lda tab_pad_ystep2,y
	sta ball_ystep_2,x

	lda #1				; always up(1) direction
	sta ball_ydir,x

	lda #1
	sta m_soundFlag


	;jsr UpdateBallHits

	lda #0
	sta m_ballHardHitsCounter


	bit m_bonusCatchIsActive
	bpl CPC_exit

; catch bonus is active, trap the ball in the correct position
	lda #128
	sta m_ballCatchedByPadFlag

	lda #[FRAMES_TIMER_UNIT*12]
	sta m_ballCatchedByPadTimer

	lda m_catchedBallPadOffset
	sec
	sbc #BALL_SIZEX

	bcs CPC_check_catch_right_limit

	lda #0
	jmp CPC_reset_catch_ball_pos

CPC_check_catch_right_limit
; this works only for a normal size pad right now!
	cmp #[[PAD_SIZEX-BALL_SIZEX]+1]	; m_padCollisionSizeX-BALL_SIZEX+1
	bcc CPC_reset_catch_ball_pos

	lda #[PAD_SIZEX-BALL_SIZEX]

CPC_reset_catch_ball_pos
	sta m_catchedBallPadOffset

	clc
	adc pad_xpos
	sta ball_xpos_1,x

	lda #PAD_BALL_POSY1
	sta ball_ypos_1,x

	lda #0
	sta ball_xpos_2,x
	sta ball_xpos_3,x
	sta ball_ypos_2,x
	sta ball_ypos_3,x


CPC_exit
	rts


;================================================================================

; UpdateBallHits
; 	lda m_currentBallIndex
; 	bne UBH_exit
;
; ; use this counter to update the speed of the ball
; 	inc m_ballHitsCounter
;
; 	lda m_ballHitsCounter
; 	cmp #BALL_HITS_TO_SPEEDUP
; 	bne UBH_exit
; 	lda #0
; 	sta m_ballHitsCounter
;
; ; 	lda m_currentBallSpeed
; ; 	cmp m_maxBallSpeed
; ; 	beq UBH_exit
; ; 	inc m_currentBallSpeed
;
; 	lda m_currentBallSpeed
; 	clc
; 	adc #BALL_HITS_SPEEDUP_STEP
; 	cmp m_maxBallSpeed
; 	;beq UBH_update_ball_speed
; 	bcc UBH_update_ball_speed
;
; 	lda m_maxBallSpeed
;
; UBH_update_ball_speed
; 	sta m_currentBallSpeed
;
; UBH_exit
; 	rts


;================================================================================

; for all the DoHit* methods, the register X must have the current ball index

DoHitLeft
	ldx m_currentBallIndex			; OPTIMIZE: should come with the correct value?

	lda #2		; now go right
	sta ball_xdir,x

	inc ball_xpos_1,x

	lda #0
	sec
	sbc ball_xpos_3,x
	sta ball_xpos_3,x				; OPTIMIZE: probably don't need that much precision
	lda #0
	sbc ball_xpos_2,x
	sta ball_xpos_2,x

	;jsr UpdateBallHits

	rts


;-------------------------------

DoHitRight
	ldx m_currentBallIndex

	lda #1		; now go left
	sta ball_xdir,x

	dec ball_xpos_1,x

	lda #254
	sec
	sbc ball_xpos_3,x
	sta ball_xpos_3,x
	lda #255
	sbc ball_xpos_2,x
	sta ball_xpos_2,x

	;jsr UpdateBallHits

	rts


;-------------------------------

DoHitUp
	ldx m_currentBallIndex

	lda #2		; now go down
	sta ball_ydir,x

	inc ball_ypos_1,x

	lda #0
	sec
	sbc ball_ypos_3,x
	sta ball_ypos_3,x
	lda #0
	sbc ball_ypos_2,x
	sta ball_ypos_2,x

	;jsr UpdateBallHits

	rts


;-------------------------------

DoHitDown
	ldx m_currentBallIndex

	lda #1		; now go up
	sta ball_ydir,x

	dec ball_ypos_1,x

	lda #254
	sec
	sbc ball_ypos_3,x
	sta ball_ypos_3,x
	lda #255
	sbc ball_ypos_2,x
	sta ball_ypos_2,x

	;jsr UpdateBallHits

	rts


;================================================================================

; the register X must have the current ball index

ChangePosToChar				; OPTIMIZE: doesn't need to be a subroutine
	ldx m_currentBallIndex		; OPTIMIZE: should have the correct value already

	lda ball_xpos_1,x
	lsr						; OPTIMIZE: could use a table: ldy ball_xpos_1,x ; lda TabDivBy8,y
	lsr
	lsr
	sta brick_xchar

	lda ball_ypos_1,x
	lsr
	lsr
	lsr
	sta brick_ychar

	rts


;================================================================================

; check top and bottom bricks in a side collision
CheckTopBottomBricks
	ldx brick_ychar
	lda TabMulBricksInX,x
	clc
	adc brick_xchar
	tax		; put top brick index in register x

	stx m_tempBrickIndex

; check if there is only one possible brick to hit
	lda brick_ychar
	cmp #BOTTOM_BRICK_NUM-1		; max line
	beq ch2

; check both bricks for a collision (top and bottom)
; first check where the middle of the ball is, to give priority to that brick
	ldy m_currentBallIndex
	lda ball_ypos_1,y

	and #%111			; Y offset (0 to 7)
;ch1	cmp #6			; ball Y in (6 7 0 1 2), size Y = 5
ch1	cmp #5			; ball Y in (5 6 7 0 1 2), size Y = 6
	bcc ch3			; a < threshold

; give priority to the bottom brick
	lda TabLevel+NUM_BRICKS_X,x
	and #%1111		; brick mask
	beq ch2

	tay	; add NUM_BRICKS_X to index in x
	txa
	clc
	adc #NUM_BRICKS_X
	tax
	tya
	inc brick_ychar
	jsr HitBrick		; hit bottom brick

	bit m_bonusMegaIsActive
	bpl ch_hit_exit	; check both bricks when this powerup is active! .. OPTIMIZE: do a special subroutine for this powerup (or check always all near bricks)

	ldx m_tempBrickIndex
	dec brick_ychar
	;jmp ch_hit_exit

; now check the top brick
ch2	lda TabLevel,x
	and #%1111		; brick mask
	beq ch_clr_exit

	jsr HitBrick		; hit top brick
	jmp ch_hit_exit


; give priority to the top brick, but first check the case where the
; ball is totally inside the top brick (cannot touch the bottom brick)
ch3	cmp #[BRICK_SIZEY-BALL_SIZEY]+1	; ball Y in (2 3 4 5 6 7) or lower
	bcc ch2			; a < threshold

	lda TabLevel,x
	and #%1111		; brick mask
	beq ch4

	jsr HitBrick		; hit top brick

	bit m_bonusMegaIsActive
	bpl ch_hit_exit	; check both bricks when this powerup is active!

	ldx m_tempBrickIndex
	;jmp ch_hit_exit

; now check the bottom brick
ch4	lda TabLevel+NUM_BRICKS_X,x
	and #%1111		; brick mask
	beq ch_clr_exit

	tay	; add NUM_BRICKS_X to index in x
	txa
	clc
	adc #NUM_BRICKS_X
	tax
	tya
	inc brick_ychar
	jsr HitBrick		; hit bottom brick


ch_hit_exit
	lda #0
	bit m_bonusMegaIsActive
	bmi ch_clr_exit	; don't do the hit reaction if the mega bonus is active

	lda #1	; there was a collision (exit with 0 in the other case)

ch_clr_exit
	rts


;================================================================================

; check left and right bricks in a vertical collision
CheckLeftRightBricks
	ldx brick_ychar
	lda TabMulBricksInX,x
	clc
	adc brick_xchar
	tax		; put left brick index in register x

	stx m_tempBrickIndex

; check both bricks for a collision (left and right)
; first check where the middle of the ball is, to give priority to that brick
	ldy m_currentBallIndex
	lda ball_xpos_1,y

	and #%111			; X offset (0 to 7)
cv1	cmp #7			; ball X in: (7 0 1), size X = 3
	bne cv3			; only case where we can give priority to the right brick!

; ..well, in reality there are also the cases greater than 6.5 and below "8" (7.999..)
; where the middle point of the ball in X, is between the offset 0 and 0.5
; (but visually speaking, probably is going to look "better" the way it is right now)

; give priority to the right brick
	lda TabLevel+1,x
	and #%1111		; brick mask
	beq cv2

	inx
	inc brick_xchar
	jsr HitBrick		; hit right brick

	bit m_bonusMegaIsActive
	bpl cv_hit_exit	; check both bricks when this powerup is active!

	ldx m_tempBrickIndex
	dec brick_xchar
	;jmp cv_hit_exit

; now check the left brick
cv2	lda TabLevel,x
	and #%1111		; brick mask
	beq cv_clr_exit

	jsr HitBrick		; hit left brick
	jmp cv_hit_exit

; give priority to the left brick, but first check the case where the
; ball is totally inside the left brick (cannot touch the right brick)
cv3	cmp #[BRICK_SIZEX-BALL_SIZEX]+1	; ball X in: (5 6 7) or lower
	bne cv2

	lda TabLevel,x
	and #%1111		; brick mask
	beq cv4

	jsr HitBrick		; hit left brick

	bit m_bonusMegaIsActive
	bpl cv_hit_exit	; check both bricks when this powerup is active!

	ldx m_tempBrickIndex
	;jmp cv_hit_exit

; now check the right brick
cv4	lda TabLevel+1,x
	and #%1111		; brick mask
	beq cv_clr_exit

	inx
	inc brick_xchar
	jsr HitBrick		; hit right brick


cv_hit_exit
	lda #0
	bit m_bonusMegaIsActive
	bmi cv_clr_exit	; don't do the hit reaction if the mega bonus is active

	lda #1	; there was a collision (exit with 0 in the other case)

cv_clr_exit
	rts


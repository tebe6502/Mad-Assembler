
; using a RMT song with 4 updates per frame in PAL
; NTSC: 262 scan lines (0-130 vcount) /4 = 65.5 (needs 197 scan lines app.)
; PAL: 312 scan lines (0-155 vcount) /4 = 78 (needs 235 scan lines)
; normal G0 screen: 24 + 24*8 = 216 scan lines
; PAL --> 200 updates per second
; would be better to do it counting vcount lines and waitin in the main loop
; NTSC: 33 vcount lines app. ; PAL: 39 vcount lines

Tittle_score_DLI1_address
	sta save_a
	stx save_x
	sty save_y

.if .def PAL_VERSION
	lda #$10
.else
	lda #$20
.endif
	sta COLPM0
	sta COLPM1

	lda #128-44
	ldx #128-20
	ldy #128
	sta WSYNC

	sta HPOSP0
	stx HPOSP1
	sty HPOSP2
	lda #128+28
	sta HPOSP3
	sta HPOSM0
	lda #128+44
	sta HPOSM1

	lda #%11100000
	ldx #%11110000
	ldy #%11111000
	sta WSYNC
	sta GRAFP0
	stx GRAFP1
	sty GRAFP2
	lda #%01110000
	sta GRAFP3
	lda #%00001111
	sta GRAFM


	:5 sta WSYNC

	lda #%11111000
	sta GRAFP3

	lda #0
	sta WSYNC

	sta GRAFP0
	sta GRAFP1
	sta GRAFP2
	sta GRAFP3
	sta GRAFM

	sta HPOSP0
	sta HPOSP1
	sta HPOSP2
	sta HPOSP3


Tittle_score_DLI1_exit
	SetVector NMIH_VECTOR, Tittle_name_DLI1_address

	lda save_a
	ldx save_x
	ldy save_y

	rti


;-------------------------------
Tittle_name_DLI1_address
	sta save_a
	stx save_x

	lda #128-60
	ldx #128+8
	sta WSYNC
	sta HPOSP0
	stx HPOSP1

.if .def PAL_VERSION
	lda #$20
	ldx #$90
.else
	lda #$30
	ldx #$A0
.endif
	sta COLPM0
	stx COLPM1

	lda #%11100000
	sta WSYNC
	sta GRAFP0
	sta GRAFP1

	:5 sta WSYNC

	lda #0
	sta WSYNC
	sta GRAFP0
	sta GRAFP1
	sta HPOSP0
	sta HPOSP1


Tittle_name_DLI1_exit
	SetVector NMIH_VECTOR, Tittle_music_DLI1_address

	lda save_a
	ldx save_x

	rti


;-------------------------------
Tittle_music_DLI1_address
	sta save_a

	lda #128+8
	sta WSYNC
	sta HPOSP0

.if .def PAL_VERSION
	lda #$90
.else
	lda #$A0
.endif
	sta COLPM0

	lda #%11111000
	sta WSYNC
	sta GRAFP0

	:5 sta WSYNC

	lda #0
	sta WSYNC
	sta GRAFP0
	sta HPOSP0


Tittle_music_DLI1_exit
	SetVector NMIH_VECTOR, Tittle_options_DLI1_address

	lda save_a

	rti


;-------------------------------
Tittle_options_DLI1_address
	sta save_a

.if .def PAL_VERSION
	lda #$A0
.else
	lda #$B0
.endif
	sta COLPM0

	lda #128-36
	sta HPOSP0

	lda #%10000000
	sta WSYNC
	sta GRAFP0


Tittle_options_DLI1_exit
	SetVector NMIH_VECTOR, Tittle_options_DLI2_address

	lda save_a

	rti


;-------------------------------
Tittle_options_DLI2_address
	sta save_a

	lda #0
	sta WSYNC
	sta COLPM0

	:3 sta WSYNC

.if .def PAL_VERSION
	lda #$B0
.else
	lda #$C0
.endif
	sta WSYNC
	sta COLPM0


Tittle_options_DLI2_exit
	SetVector NMIH_VECTOR, Tittle_options_DLI3_address

	lda save_a

	rti


;-------------------------------
Tittle_options_DLI3_address
	sta save_a

	lda #0
	sta WSYNC
	sta COLPM0

	:3 sta WSYNC

.if .def PAL_VERSION
	lda #$B0
.else
	lda #$C0
.endif
	sta WSYNC
	sta COLPM0


Tittle_options_DLI3_exit
	SetVector NMIH_VECTOR, Tittle_options_DLI4_address

	lda save_a

	rti


;-------------------------------
Tittle_options_DLI4_address
	sta save_a

	lda #0
	sta WSYNC
	sta COLPM0

	:3 sta WSYNC

.if .def PAL_VERSION
	lda #$C0
.else
	lda #$D0
.endif
	sta WSYNC
	sta COLPM0


Tittle_options_DLI4_exit
	SetVector NMIH_VECTOR, Tittle_options_DLI5_address

	lda save_a

	rti


;-------------------------------
Tittle_options_DLI5_address
	sta save_a

	lda #0
	sta WSYNC
	sta COLPM0
	sta HPOSP0
	sta GRAFP0


Tittle_options_DLI5_exit
	SetVector NMIH_VECTOR, Tittle_score_DLI1_address

	lda save_a

	rti


;================================================================================

; for NTSC: 25 lines with dli's: (24 read the mouse, 1440Hz)
; for PAL: 28 lines with dli's: (27 read the mouse, 1350Hz)
; 20 first lines for colors (COLPF2/1), last line for the pad colors (COLPM3)

DLI1_address
	sta save_a
	stx save_x

	ldx dli_index
	lda TabDLI_COLPF1,x

	sta WSYNC

	sta COLPF1
	lda TabDLI_COLPF2,x
	sta COLPF2

	.if .def SHOW_TIMING_AREAS
	lda #$36
	sta COLBK
	.endif

	cld

	inc dli_index

	cpx #[2+NUM_BRICKS_Y]-1		; 2+ ==> include the top border lines
	bne dli_readMouse

; change start address for dli's that only read the mouse
	lda #<DLI2_address
	sta NMIH_VECTOR		;VDSLST
	lda #>DLI2_address
	sta NMIH_VECTOR+1		;VDSLST+1

	jmp dli_readMouse


;-------------------------------
DLI2_address
	sta save_a
	stx save_x

	.if .def SHOW_TIMING_AREAS
	lda #$32
	sta COLBK
	.endif

	cld

	inc dli_index

	lda dli_index
	cmp #DLI_READ_MOUSE_LINES
	bne dli_readMouse


; save state of the collision register P3PL, to detect the collision between enemies and balls
	lda P3PL
	sta m_dliP3PL
	lda #255
	sta HITCLR

; change start address for the final dli
	lda #<DLI3_address
	sta NMIH_VECTOR		;VDSLST
	lda #>DLI3_address
	sta NMIH_VECTOR+1		;VDSLST+1

	jmp dli_readMouse


;-------------------------------
DLI3_address
	sta save_a
	stx save_x

	.if .def SHOW_TIMING_AREAS
	lda #$12
	sta COLBK
	.endif

	lda m_padHPOSP3
	sta HPOSP3
	lda m_padSizeP3
	sta SIZEP3

	ldx #0
dli_setPadColors
	lda TabCurrentPadColor,x

	sta WSYNC

	sta COLPM3

	inx
	cpx #PAD_SIZEY
	bne dli_setPadColors


	cld


; change font for the info line
; 	sta WSYNC
; 	sta WSYNC
;
; 	lda #>Atari_font_address
; 	sta WSYNC
; 	sta CHBASE


; reset dli line index (now that there is no real VBI)
	lda #0
	sta dli_index


; recover start address for the first dli, after the vbi
	lda #<DLI1_address
	sta NMIH_VECTOR		;VDSLST
	lda #>DLI1_address
	sta NMIH_VECTOR+1		;VDSLST+1


; final dli, do the old vbi code here and after that exit
	sty save_y			; do not use register Y before this point!

	jmp VBI_address		; not a VBI anymore..
; 	jsr VBI_address
;
; 	.if .def SHOW_TIMING_AREAS
; 	lda m_mainAreaColor
; 	sta COLBK
; 	.endif
;
; 	lda save_a
; 	ldx save_x
; 	ldy save_y
;
; 	rti


;--------------------------------------------------------------------------------
; common area for all dli's, read the mouse in port 1
dli_readMouse
	ldx PORTA

DLI_nibbleTable
	lda TabGetLowNibble,x
	;lda TabGetHighNibble,x

	;and #15

;--------------------------------------------------------------------------------
; this method seems to work for a mouse and a trackball, but
; it doesn't work that good for a mouse

; 	tax
; 	eor old_port
; 	and old_port
; 	and #8+2    ; valid bits
; 	sta temp_port
;
; 	stx old_port
; 	txa
; 	and #4+1    ; dir bits
; 	ora temp_port
;
; 	tax
; 	lda tab_conv_mov,x
; 	sta mouse_mov


;--------------------------------------------------------------------------------
; this is wrong, it seems this method only works for a trackball!
; check only horizontal changes in mouse direction and movement
; 	tax			; save new PORTA value
;
; ; first bits (+1, direction) should be equal (between new and old values)
; ; second bits (+2, rate) should be different (between new and old values)
; 	eor old_port
; 	and #%0011	; if same X direction, with movement, then result should be %10
; 	cmp #%10
; 	stx old_port	; update old value before the branch..
; 	beq dli_sameDirAndMoved
;
; ; invalid, different direction or no movement, exit
; 	jmp exit_dli
;
; dli_sameDirAndMoved
; 	txa
; 	and #%0001	; get X direction bit (0 left, 1 right)
; 	beq dli_mouseLeft
;
; dli_mouseRight
; 	lda #%1000	; right bit value
; 	bne dli_updateMouseMov
;
; dli_mouseLeft
; 	lda #%0100	; left bit value
;
; dli_updateMouseMov
; 	sta mouse_mov


;--------------------------------------------------------------------------------
; in reality the Atari mouse does this: (for the first 2 bits, movement in X)
; left 0 1 3 2 (%00 %01 %11 %10) --> 0100 1101 1011 0010 ==> move left (4)
; right 1 0 2 3 (%01 %00 %10 %11) --> 0001 1000 1110 0111 ==> move right (8)

;--------------------------------------------------------------------------------
; method 1 (this works well)
; 	and #%11
; 	tax
; 	asl
; 	asl
; 	ora old_port
;
; 	stx old_port
; 	tax
; 	lda TabMouseMoveX,x
; 	sta mouse_mov


;--------------------------------------------------------------------------------
; method 2 (accumulate the delta of movement over all 26 dli's, then use it in
; the VBI and apply the acceleration there) (the delta can go from -26 to +26)
; 	and #%11		; only these 2 bits are needed for a left/right movement
; 	ldx old_port
; 	cmp TabNextValueMovingRight,x
; 	bne dli_checkMoveLeft
;
; ; move right
; 	;lda #1
; 	;sta m_padFrameDirection
; 	inc m_padFrameDeltaStep
;
; 	jmp dli_updateOldPort
;
; dli_checkMoveLeft
; 	cmp TabNextValueMovingLeft,x
; 	bne dli_noMovement
; 
; ; move left
; 	;lda #2
; 	;sta m_padFrameDirection
; 	dec m_padFrameDeltaStep
; 
; 	jmp dli_updateOldPort
;
; dli_noMovement
; 	;lda #0
; 	;sta m_padFrameDirection
;
; dli_updateOldPort
; 	sta old_port


;--------------------------------------------------------------------------------
; method 3 (accumulate the delta of movement over all 26 dli's, using acceleration,
; and apply the result in the VBI) (the delta can go from -127 to +127)

dli_mouseTypeHMoveMask
	and #%11		; only these 2 bits are needed for a left/right movement
	;and #%1010	; .. and these 2 with an Amiga mouse
	sta m_portAHorizontalBits	; temporal save

	ldx old_port

dli_checkMoveRight
	cmp TabNextValueMovingRight,x
	bne dli_checkMoveLeft


;----------------------------------------
; move right, check acceleration
	lda #0
	sta m_mouseAccelMemoryCounter		; reset acceleration "memory"

	lda m_oldMouseReadDirection
	cmp #1						; check if old direction was to the right..
	bne dli_noMouseAccelRight		; no acceleration (old direction != current direction, skip acceleration logic)
	dec m_mouseAccelCounter
	bne dli_updatePadStepRight		; must still wait for counter, skip acceleration logic

	lda m_mouseStep			; this was called m_mouseAccelStep before
dli_mouse_accel_step_value1
	cmp #MAX_MOUSE_STEP		; (2)
	bcs dli_restartMouseAccelRight	; a >= m
	inc m_mouseStep
	
	bne dli_restartMouseAccelRight	; forced "jump"
	; beq branch of this should never happen.. but if does, reset the mouse step to 1

dli_noMouseAccelRight
	lda #MIN_MOUSE_STEP		; (2)
	sta m_mouseStep
dli_restartMouseAccelRight
	lda #MOUSE_READS_TO_ACCELERATE	; (3)
	sta m_mouseAccelCounter


dli_updatePadStepRight
	lda m_padFrameDeltaStep
	clc
	adc m_mouseStep
	sta m_padFrameDeltaStep

	lda #1
	sta m_oldMouseReadDirection

	jmp dli_updateOldPort


;----------------------------------------
dli_checkMoveLeft
	cmp TabNextValueMovingLeft,x
	bne dli_noMovement


;----------------------------------------
; move left, check acceleration
	lda #0
	sta m_mouseAccelMemoryCounter		; reset acceleration "memory"

	lda m_oldMouseReadDirection
	cmp #2
	bne dli_noMouseAccelLeft			; no acceleration
	dec m_mouseAccelCounter
	bne dli_updatePadStepLeft

	lda m_mouseStep
dli_mouse_accel_step_value2
	cmp #MAX_MOUSE_STEP		; (2)
	bcs dli_restartMouseAccelLeft		; a >= m
	inc m_mouseStep
	
	bne dli_restartMouseAccelLeft		; forced "jump"

dli_noMouseAccelLeft
	lda #MIN_MOUSE_STEP		; (2)
	sta m_mouseStep
dli_restartMouseAccelLeft
	lda #MOUSE_READS_TO_ACCELERATE	; (3)
	sta m_mouseAccelCounter


dli_updatePadStepLeft
	lda m_padFrameDeltaStep
	sec
	sbc m_mouseStep
	sta m_padFrameDeltaStep

	lda #2
	sta m_oldMouseReadDirection

	jmp dli_updateOldPort


;----------------------------------------
dli_noMovement
	ldx m_mouseAccelMemoryCounter		; [0, MOUSE_ACCEL_MEMORY] mouse reads
	inx
	cpx #MOUSE_ACCEL_MEMORY+1
	bcs dli_resetOldMoveInfo		; x >= m, reset "m_oldMouseReadDirection"

	stx m_mouseAccelMemoryCounter
	bcc dli_updateOldPort		; "jump", do not reset "m_oldMouseReadDirection"

dli_resetOldMoveInfo
	lda #MIN_MOUSE_STEP		; (1)
	sta m_mouseStep
	lda #MOUSE_READS_TO_ACCELERATE	; (3)
	sta m_mouseAccelCounter

	lda #0
	sta m_oldMouseReadDirection


;----------------------------------------
dli_updateOldPort
	lda m_portAHorizontalBits
	sta old_port


;--------------------------------------------------------------------------------
; old acceleration logic
; 	lda mouse_mov
; 	and #8+4
; 	bne ac1
;
; ; if no left/right move, then increment "m_mouseAccelMemoryCounter"
; 	ldx m_mouseAccelMemoryCounter		; [0, MOUSE_ACCEL_MEMORY] mouse reads
; 	inx
; 	cpx #MOUSE_ACCEL_MEMORY+1
; 	bcs ac4			; x >= m, already at the limit, update "old_mov"
; 	stx m_mouseAccelMemoryCounter
; 	bcc mpd			; "jump", do not update "old_mov"
;
; ; if there is no movement, before 2 seconds, do not update "old_mov"
; ; (keep alive old direction for 2 seconds! so if we start moving again in
; ; that same direction we continue with the acceleration that we already have!
; ; this could be useful if we lose "reads" from the mouse..)
;
; ; if there is no movement, after 2 seconds, start updating "old_mov"
; ; if there is movement, always update "old_mov"
;
; ; there is a left or right move
; ac1	ldx #0
; 	stx m_mouseAccelMemoryCounter		; reset "m_mouseAccelMemoryCounter"
;
; 	cmp old_mov
; 	bne ac2			; if different move direction, then reset the acceleration
; 	dec m_mouseAccelCounter		; number of frames between increments of the speed
; 	bne ac4
;
; 	lda m_mouseStep
; 	cmp #MAX_MOUSE_STEP	; (2)
; 	bcs ac3			; a >= m
; 	inc m_mouseStep
; 	bne ac3		; "jump"
;
; ac2	lda #MIN_MOUSE_STEP	; (1)
; 	sta m_mouseStep
; ac3	lda #MOUSE_READS_TO_ACCELERATE	; (3)
; 	sta m_mouseAccelCounter
;
; ac4	lda mouse_mov
; 	and #8+4
; 	sta old_mov


;--------------------------------------------------------------------------------
; move paddle left or right, applying acceleration
; mpd	lda mouse_mov	; 0000=rldu
; 	and #%1100
; 	beq exit_dli
;
; 	and #%0100		; left?
; 	bne mpl
;
; ; move right
; mpr	lda pad_xpos
; 	clc
; 	adc m_mouseStep
; 	cmp #MAX_PAD_POSX+1
; 	bcc mp1     ; a < m
; 	lda #MAX_PAD_POSX
; mp1	sta pad_xpos
;
; 	jmp exit_dli
;
; ; move left
; mpl	lda pad_xpos
; 	sec
; 	sbc m_mouseStep
; 	bcs mp2
; 	lda #0
; mp2	sta pad_xpos


exit_dli
	.if .def SHOW_TIMING_AREAS
	lda m_mainAreaColor
	sta COLBK
	.endif

	lda save_a
	ldx save_x

	rti

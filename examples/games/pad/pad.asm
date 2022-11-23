;================================================================================
; Pad 1.84   NRV 1995 - 2018
;================================================================================

;--------------------------------------------------------------------------------
; Changelog 1.84:

; - created pad_title.asm
; - changed to new RMT file, with intro jingle (is also a song of speed 4!)
; - played intro jingle at the start of a level (with a "kernel", should sound
;   perfect in NTSC and PAL)
; - increased min mouse speed to 2, movement feels better (at least in emulation)
; - minimum "max mouse step" selectable in the menu is now 2
; - changed font and map files to add the new "gate open" effect animation
; - added "electricity" animation effect, when opening the exits of a level
; - added sound priority system
; - added new sound for the "extra life" event
; - added new sound for the "pick bonus" event
; - added new sound for the "lost life" event
; - fixed old hidden bug, when destroying an enemy too high in the screen
; - changed MAX_BALL_HARD_HITS to 50 (was 100), these are the hits needed for the
;   ball to change trajectory, after too much time without hitting the pad

;--------------------------------------------------------------------------------
; Changelog 1.83:

; - added 2 more angles to the paddle, for a smoother control of the ball direction
; - fixed multi ball start angles and "anti loop" logic for the new paddle angles
; - changed default mouse accel to 2 (for a better control speed)
; - tested double step when using the mouse, but is just better to increase the accel
; - changed default starting speed of the ball in casual and extra modes (slower)
; - put enemy code and data behind define blocks (USE_ENEMY_CODE)
; - added enemy code for logic states, creation, destruction, movement and animation
; - added different behaviors for the 3 types of enemies (zones of movement, collision
;   reaction against balls, avoid/follow player, hover time, probabilities)
; - added new sound for enemy destruction
; - added rule for the enemies hit when using the "X" powerup (no deflection)
; - added rule so enemies don't reappear until the ball is in play
; - fixed some size and color bugs for the enemies (in normal game and in the pause)
; - fixed bug where a pad hardware collision against a ball destroyed an enemy
; - added "Fast" powerup, to increase the ball speed (probability taken from "Slow")
; - added error message when trying NTSC or PAL version in incorrect system
; - changed max ball hard hits to 100
; - changed a little the paddle colors
; - changed some comments and added some new ones

;--------------------------------------------------------------------------------
; Changelog 1.82:

; - added paddle controller angles 25% and 75%
; - added some colors and changed some things in the tittle screen
; - integrated RMT code and added "4x" song from Miker
; - new vcount system to play RMT music with "4x" updates (it plays the song at
;   the same speed in PAL and NTSC, without the need to drop music steps)
; - modified input system to work with the new RMT vcount logic in the main loop
; - added volume decay to the song when starting a game
; - fixed lives display bug when ending the game with more than 3 balls
; - better handling of a problem when selecting paddles with a mouse connected
;   (but still exists in some degree)
; - added new game mode "extra" (changed option name to "Game mode"), with a
;   different level sequence (instead of a "tree" is more like Arkanoid 2)
; - changed balance and difficulty of some levels, removed one level and added a
;   new one in the "extra" game mode (the first one)
; - changed some brick colors in some levels
; - changed some sounds from 15Khz to 64Khz (to be able to add some new ones)

;--------------------------------------------------------------------------------
; Changelog 1.81:

; - first extra ball is at $20000 and then after every $100000
; - added small ball speed up when starting the "mega ball" powerup
; - when pressing RESET we do a cold start now
; - fixed: unable to select "arcade" after changing the difficulty
; - fixed: giving unwanted score when opening the exits at the end of a level
; - added paddle controllers from 1 to 4 (select with "C" option)
; - added "Paddle angle" option: 50% or 100% (use half or the full rotation to move)
; - modified high score (and level) logic, so when you select easy, casual or
;   arcade you see the score and level info for that difficulty only
; - added "highlight" effect for all hard bricks at the start of a level

;--------------------------------------------------------------------------------
; To do:

; - give score for destroying enemies? special actions (like red speedup ball)?

; - new levels

; + destroy pad animation and state

; + sound effects for win, lose
; + sound effect when passing the high score? show score in game?
; + small random variation to the frequency of the sound effects?

; - check "m_usePaddleControllerFlag" to not init the position of the pad?

; - another input methods: trackball, joystick, keyboard
; - add speed parameter for the mouse, to slowdown the movement?
;  (decimal part with 3 or 4 bits?)

; - use button to really use the exits? (need to touch and press the button
;  at the same time)
; - open exits when there is only one brick left? (or the number of lives)
; - use PM2 for bonus (don't steal the one of the ball), bonus with 2 PM's
; - new paddle colors for some powerups (mega, capture), color rotation?

; - vaus type "smooth" (change "disrupt" starting ball angles), add m_ballAngleIndex

; + check open two sides at the end of the level
; + check the sound system
; + check highlight animation system (losing a ball, multiball or fast balls)
; + check restore brick system

; - try to fix NTSC / PAL small differences (brick animations?, sfx?)

; + laser powerup?, curve ball?, confuse? (rotate the background down or up),
;  dizzy?, zig zag ball? control ball until the first collision,
;  avoid powerups (like falling rocks), brick powerup (acts like a brick,
;  descending at first, then blocking the ball and powerup generation
;  until destroyed), magnetic pad (for bonus)

; + change BALL_HITS_TO_SPEEDUP usage, different per level? only sides + pad hits?
; + "m_firstBonusDelayCounter" could be updated also for bricks without a bonus
; + do the "player" bonus clear the effect of other powerups?

; ++ new movement, step and collision system, once per frame

; ++ change balls to use 4 chars instead of the PM's (can use white color)
; ++ change pads to use some chars instead (and more color and detail)
; ++ free PM's for the enemies
; ++ maybe do falling bonus also with chars

; * counted number of updates per frame (near 44 in NTSC, 64 in PAL)


;--------------------------------------------------------------------------------
; Final version?

; - define screen, colors, use of P/M, 3 enemies, paddle, 3 balls, bricks,
;	levels, powerup effects (laser shot), use of DLI's, midline changes
;	(P/M's should be used to add color to the bricks and the paddle; the balls,
;	the enemies, the laser shot, the powerups can be software sprites)
;	(should be able to render stage 2, 30 and 31.. also 4 and 7)
; - new graphics: backgrounds, bricks, enemies, paddles, powerups and effects
; - complete all levels
; - new sound effects, better sound engine (add priorities), music
; - other screens (presentation, game start, game complete, hi score)
; - complete all powerups
; - add logic for all enemies (movement, AI, creation, destruction)
; - boss level, win game logic

; - scoring and records system
; White (50) 	Orange (60) 	Cyan (70) 	Green (80) 	Red(90)
; Blue(100) 	Violet(110) 	Yellow(120)
; hard silver bricks: 50 x level
; use break powerup exit: 10000
; catch powerups: 1000, hit enemies: 100
; laser shots count as ball hits (also give score and generate new powerups)

; in my version: 80 per simple brick, 50 per hit to a hard brick,
;  1000 per powerup, bricks x2 with "reduce" powerup, 10000 using "break" exit,
;  one extra player after 20000 points, 5000 per completing a level without
;  losing a ball (all bricks)

; + from A2: add powerups, moving bricks, new enemies, new levels, bosses

; * enemies only reflect one of the axis of the ball direction?
;  no, sometimes they change the angle, without changing the direction
; * slow powerup override effects of other powerups (like laser)
; * with 3 balls all of them change speed at the same time
; * strange things in arkanoid 1: enemies passing through a zone with bricks
;  connected in "diagonal" (level 2); ball hitting the corner of a brick and
;  reflecting both directions; bonus at the first brick; two "laser" bonus
;  one after another


;--------------------------------------------------------------------------------
; current hardware usage:

; Graphics:
; - mode antic 4, colbk = 0, colpf3 = 14 (used for missiles also)
; - colpf2 used for plain bricks (changed by dli's)
; - colpf1 = 8, grey for hard bricks (also changed by dli's)
; - colpf0 = $x4 (main background color)

; P/M's:
; - pad: player3 (colpm3)
; - one ball: player 0 and player 1 (colpm0 and colpm1)
; - bonus pill (powerup): player 1 (borrowed from ball) and missile 0 (colpf3)
; - multi ball: ball 1 - player 0, ball 2 - player 1, ball 3 - player 2
; - enemy: player 3, missiles 1, 2 and 3 (colpf3)

; + could use a software sprite for the paddle and the enemies, players 0 and 1 for
;	one ball, players 0, 1 and 2 for the 3 balls, missile 1 and 2 for the shots,
;	player 3 and missile 0 for the bonus (missiles 1, 2, 3 can be used for the pad)
; + maybe is better to reserve 3 players for the enemies, and do the balls and the
;	paddle as software sprites

; mouse input:
; - reads per frame: 24 in NTSC (1440Hz) and 27 in PAL (1350Hz))
; (NTSC: 20-> 1200,1260,1320,1380,1440,1500,1560 (26))
; (PAL: 24-> 1200,1250,1300,1350,1400 (28))

; max movement for a paddle of 8 pixels in a screen with 13 bricks:
; 104 - 8 = 96, so max movement in a frame should be capped to this value
; (-96 or +96), so we can have any type of acceleration..
; if we don't want to check the limit, then assuming 27 reads in a frame,
; with a max acceleration of 5 pixels per read, the max value = 1x1 + 2x1 +
; 3x1 + 4x1 + 5x23 = 125 .. good enough

; sound:
; - audctl per effect, 2 voices per effect (1 and 3), one effect at a time


;--------------------------------------------------------------------------------
; includes:

	icl "base/sys_equates.asm"

	icl "base/sys_macros.asm"


;--------------------------------------------------------------------------------
; constants:

;SHOW_TIMING_AREAS = 1
PAL_VERSION = 1
;SKIP_LEVEL_HACK = 1
USE_ENEMY_CODE = 1

; this is the area covered by the level background, where the ball can move
GAME_AREA_SIZEX = 104
GAME_AREA_SIZEY = 208

BYTES_LINE = 32

LEFT_BRICK_OFFSET = 3
NUM_BRICKS_X = 13
NUM_BRICKS_Y = 18

BOTTOM_BRICK_NUM = NUM_BRICKS_Y

BRICK_SIZEX = 8
BRICK_SIZEY = 8
PAD_SIZEX = 16
PAD_SIZEY = 6
BALL_SIZEX = 3
BALL_SIZEY = 6

PAD_SMALL_SIZEX = 8
PAD_LARGE_SIZEX = 24

STARTING_BALL_SPEED = 5
MIN_BALL_SPEED = 2
TOP_BORDER_BALL_SPEED = 6
MAX_BALL_SPEED = 7
BALL_HITS_SPEEDUP_STEP = 1
SLOW_BONUS_SLOWDOWN_STEP = 1
FAST_BONUS_SPEEDUP_STEP = 1

;BALL_HITS_TO_SPEEDUP = 128
BALL_SPEEDUP_HALF_SECONDS = 40

MAX_BALL_HARD_HITS = 50

BALL_START_ANGLE_INDEX = 4

MIN_PAD_POSX = 0
MAX_PAD_POSX = GAME_AREA_SIZEX-PAD_SIZEX

MAX_PAD_SMALL_POSX = GAME_AREA_SIZEX-PAD_SMALL_SIZEX
MAX_PAD_LARGE_POSX = GAME_AREA_SIZEX-PAD_LARGE_SIZEX

PAD_POSY1 = 200
PAD_POSY2 = PAD_POSY1+PAD_SIZEY
PAD_BRICK_LINE = 2+NUM_BRICKS_Y+7
PAD_START_POSITION = 50

PAD_BALL_POSY1 = PAD_POSY1-BALL_SIZEY
PAD_BALL_POSY2 = PAD_POSY2-BALL_SIZEY

MIN_BALL_POSX = 0
MAX_BALL_POSX = GAME_AREA_SIZEX-BALL_SIZEX
MIN_BALL_POSY = 0
MAX_BALL_POSY = GAME_AREA_SIZEY-[BALL_SIZEY-2]


BALL_COLOR = $0E
;BALL_BACKG_COLOR1 = $98

.if .def PAL_VERSION
BALL_MEGA_COLOR = $2C
BALL_MEGA_BACKG_COLOR = $26
.else
BALL_MEGA_COLOR = $3C
BALL_MEGA_BACKG_COLOR = $36
.endif


BONUS_SIZEX = 8
BONUS_SIZEY = 8
MAX_BONUS_POSY = GAME_AREA_SIZEY-[BONUS_SIZEY-4]
MAX_BONUS_NUM = 9
BONUS_ANIM_SPEED = 3
ABORT_BONUS_NUM = 2

.if .def PAL_VERSION
BONUS_FALL_SPEED_LSB = 109
BONUS_FALL_SPEED_MSB = 1
.else
BONUS_FALL_SPEED_LSB = 48
BONUS_FALL_SPEED_MSB = 1
.endif

MAX_LEVEL_NUM = 28
LAST_LEVEL_GROUP_INDEX = 21

MAX_LEVEL_NUM_EXTRA = 27
LAST_LEVEL_GROUP_INDEX_EXTRA = 25

STARTING_BALLS = 3
MAX_BALLS_IN_PLAY = 3

PM_OFFSET_X = 76
PM_OFFSET_Y = 28

MAX_ACTIVE_HIGHLIGHT_ANIMS = 8
HIGHLIGHT_ANIM_FRAMES = 4

.if .def PAL_VERSION
HIGHLIGHT_ANIM_TIME = 2
.else
HIGHLIGHT_ANIM_TIME = 2
.endif

MAX_ACTIVE_RESTORE_BRICKS = 24
RESTORE_BRICK_TIME = 14

; half a second resolution for this counter (30 NTSC, 25 PAL)
.if .def PAL_VERSION
VBI_COUNTER_FRAMES = 25
FRAMES_TIMER_UNIT = 5
FRAMES_ONE_SECOND = 50
.else
VBI_COUNTER_FRAMES = 30
FRAMES_TIMER_UNIT = 6
FRAMES_ONE_SECOND = 60
.endif

MIN_MOUSE_STEP = 2
MAX_MOUSE_STEP = 2
MOUSE_READS_TO_ACCELERATE = 3
MOUSE_ACCEL_MEMORY = 10

.if .def PAL_VERSION
DLI_READ_MOUSE_LINES = 27
.else
DLI_READ_MOUSE_LINES = 24
.endif

RESTORE_BRICK_LEFT_CHAR = 52+128
RESTORE_BRICK_RIGHT_CHAR = RESTORE_BRICK_LEFT_CHAR+1
RESTORE_BRICK_VALUE = $52

BALL_CHAR = 44+128
BLANK_CHAR = 45
MAX_BALLS_IN_HUD = 10

.if .def PAL_VERSION
MAX_VCOUNT_VALUE = 155
RMT_UPDATE_VCOUNT_LINES = 39
.else
MAX_VCOUNT_VALUE = 130
RMT_UPDATE_VCOUNT_LINES = 39
.endif

MUSIC_FADEOUT_VCOUNT_STEPS = 28

START_GAME_SOUND_TIME = FRAMES_TIMER_UNIT*25

RMT_SONG_SPEED = 4


; enemy states
ENEMY_STATE_OFF			= 0
ENEMY_STATE_MOVING			= 1
ENEMY_STATE_HOVERING		= 2
ENEMY_STATE_DESTRUCTION		= 3
ENEMY_STATE_WAIT_RESPAWN		= 4

; enemy types
ENEMY_TYPE_RED				= 0
ENEMY_TYPE_BLUE			= 1
ENEMY_TYPE_GREEN			= 2

; enemy screen limits
;ENEMY_LIMIT_TOP			= 30
ENEMY_LIMIT_BOTTOM			= 180
ENEMY_LIMIT_LEFT			= 78
ENEMY_LIMIT_RIGHT			= 166


; game states
;GS_LEVEL_START		= 10
GS_LEVEL_PLAY		= 20
GS_LEVEL_WIN		= 30


;--------------------------------------------------------------------------------
; memory map:

; remember that some move/copy macros use the last 6 bytes of page zero!

Vars_address				= 0
Static_vars_address			= 210
Macros_vars_address			= 250
RMT_vars_address			= [Macros_vars_address-19]

RMT_song_address			= $2800		; 10K (3K zone) (1722 bytes) (2362 bytes)
RMT_end_song_address		= [RMT_song_address+2362]
RMT_address				= $3400		; 13K (?K zone)

Prog_start				= $4000		; 16K (24K available)

PM_zone_address			= $A000		; 40K (uses <2K)
DL1_address				= $A000		; 40K (DL1 and DL2 area, uses <0.5K)
DL1_data_address			= $A800		; 42K (uses <2K)

Atari_font_address			= $B000		; 44K (uses 1K)
Font1_address				= $B400		; 45K (uses 1K)
Font_background_address		= $B800		; 46K (uses 2K)

;System_font_address		= $E000		; (OS rom should be active)


;--------------------------------------------------------------------------------
; variables:

	org Vars_address

save_a						org *+1
save_x						org *+1
save_y						org *+1

old_port						org *+1
temp_port						org *+1
mouse_mov						org *+1
old_mov							org *+1

m_portAHorizontalBits			org *+1

pad_xpos						org *+1

m_padAtRightLimitFlag			org *+1
m_padAtLeftLimitFlag			org *+1


; this group of vars have a version for every ball in play (MAX_BALLS_IN_PLAY)
ball_xstep_1					org *+MAX_BALLS_IN_PLAY
ball_xstep_2					org *+MAX_BALLS_IN_PLAY
ball_ystep_1					org *+MAX_BALLS_IN_PLAY
ball_ystep_2					org *+MAX_BALLS_IN_PLAY
ball_xdir						org *+MAX_BALLS_IN_PLAY
ball_ydir						org *+MAX_BALLS_IN_PLAY

ball_xpos_1						org *+MAX_BALLS_IN_PLAY
ball_xpos_2						org *+MAX_BALLS_IN_PLAY
ball_xpos_3						org *+MAX_BALLS_IN_PLAY
ball_ypos_1						org *+MAX_BALLS_IN_PLAY
ball_ypos_2						org *+MAX_BALLS_IN_PLAY
ball_ypos_3						org *+MAX_BALLS_IN_PLAY
ball_rxpos						org *+MAX_BALLS_IN_PLAY
ball_rypos						org *+MAX_BALLS_IN_PLAY
old_ball_rypos					org *+MAX_BALLS_IN_PLAY

m_ballLostFlag					org *+MAX_BALLS_IN_PLAY


ptr_1						org *+2
ptr_2						org *+2
ctd_1						org *+1
ctd_2						org *+1
temp_1						org *+1
temp_2						org *+1

dli_index						org *+1

brick_xchar						org *+1
brick_ychar						org *+1

m_tempBrickIndex				org *+1

m_soundFlag						org *+1
m_soundSize						org *+1
m_soundIndex					org *+1
; ptr_snd						org *+2
; ptr_snd_bak					org *+2
m_soundPriority					org *+1

vbi_anim_ctd					org *+1
anim_num						org *+1
vbi_jif_ctd						org *+1
vbi_gold_ctd					org *+1

gold_init						org *+1
gold_num						org *+1
gold_index						org *+1

m_levelIndex					org *+1
m_nextLevelIsLeft				org *+1

brick_lev_num					org *+1

m_backgroundIndex				org *+1
m_backgroundColor				org *+1

m_numberOfBallsLeft				org *+1
m_ballNumHud					org *+1

; bonus_flag = 0 --> no bonus powerup is active
; bonus_flag = 128 --> bonus powerup just created, needs init in VBI (for one frame only)
; bonus_flag = 1 --> bonus powerup falling, updated in the VBI
bonus_flag					org *+1

bonus_xpos					org *+1
bonus_ypos					org *+1
bonus_ypos_decimal				org *+1
bonus_sh_line					org *+1
bonus_sh_ctd					org *+1
ptr_bonus_sh					org *+2
bonus_color					org *+1

m_bonusType					org *+1
m_lastBonusType				org *+1

m_extraPlayerBonusFlag			org *+1
m_bonusExpandIsActive			org *+1
m_bonusCatchIsActive			org *+1
;m_bonusLaserIsActive			org *+1
m_bonusBreakIsActive			org *+1

m_bonusReduceIsActive			org *+1
m_bonusMegaIsActive				org *+1

;m_firstBonusDelayCounter			org *+1

m_mouseAccelCounter				org *+1
m_mouseStep						org *+1			; this was called m_mouseAccelStep before
m_mouseAccelMemoryCounter		org *+1

m_oldMouseReadDirection			org *+1

;m_padFrameDirection				org *+1
m_padFrameDeltaStep				org *+1

m_ballSpeedCounter				org *+1
m_currentBallSpeed				org *+1

m_ballLostThisLevelFlag			org *+1

m_ballSpeedUpTimer				org *+1
m_ballHardHitsCounter			org *+1

m_catchedBallPadOffset			org *+1
m_ballCatchedByPadFlag			org *+1
m_ballCatchedByPadTimer			org *+1

m_ballAntialiasColor			org *+1
m_ballBackgroundColor			org *+1

m_numberOfBallsInPlay			org *+1
m_currentBallIndex				org *+1

m_ballHitTopBorderFlag			org *+1
;m_ballHitsCounter				org *+1

m_maxPadPosX					org *+1
m_maxPadPosXPlusOne				org *+1
m_padCollisionSizeX				org *+1
m_padCollisionHalfSizeX			org *+1
m_padHalfSizeX					org *+1

m_padMiddlePos					org *+1
m_padMiddlePosPM				org *+1

m_padSizeP3					org *+1

m_playerScore					org *+3
;m_sessionHighScore				org *+3
m_tempScore					org *+1

m_padHPOSP3					org *+1

.if .def USE_ENEMY_CODE
m_enemy1PosX					org *+1
m_enemy1PosX_L1				org *+1
m_enemy1PosY					org *+1
m_enemy1BasePosY				org *+1
m_enemy1BasePosY_L1				org *+1

m_enemy1OldPosY				org *+1
m_enemy1SineIndex				org *+1

m_enemy1StepX					org *+1
m_enemy1StepY					org *+1
m_enemy1StepX_L1				org *+1
m_enemy1StepY_L1				org *+1

m_enemy1LimitX					org *+1
m_enemy1LimitY					org *+1

m_enemy1DirectionsFlag			org *+1

m_enemy1Type					org *+1

m_enemy1State					org *+1
m_enemy1StateTimer				org *+2

m_enemy1AnimIndex				org *+1
m_enemy1AnimCounter				org *+1

m_enemy1SizeP3					org *+1

m_enemy1OffsetM1				org *+1
m_enemy1OffsetM2				org *+1
m_enemy1OffsetM3				org *+1

m_enemy1ColorP3				org *+1
.endif

m_startGameFlag				org *+1

m_gameState					org *+1

m_startGameBallCatchedFlag		org *+1

m_waitForSongEndCounter			org *+1
m_rmtSongSpeedCounter			org *+1

m_openSidesWaitTimer			org *+1
m_animateExitsTimer				org *+1
m_exitsAnimationIndex			org *+1

m_startGameWaitTimer			org *+1

m_keyPausePressed				org *+1
m_oldKeyPausePressed			org *+1
m_pauseModeFlag				org *+1

m_leftDigit					org *+1
m_rightDigit					org *+1

m_startLevelHighlightTimer		org *+1
m_startLevelHighlightStep		org *+1

m_newKeyPressedFlag				org *+1
m_oldKeyPressedFlag				org *+1
m_newKeyPressedValue			org *+1
m_oldKeyPressedValue			org *+1

m_newTriggerPressedFlag			org *+1
m_oldTriggerPressedFlag			org *+1

m_currentVcountLineRMT			org *+1
m_nextVcountLineRMT				org *+1
m_musicFadeOutCounter			org *+1

m_dliP3PL						org *+1

.if .def SHOW_TIMING_AREAS
m_mainAreaColor				org *+1
.endif


;================================================================================

END_VARS_AREA
	.if END_VARS_AREA > Static_vars_address
		.error "Vars area overwrite static vars area!"
	.endif

;================================================================================

	org Static_vars_address

m_sessionHighScore				org *+3
m_sessionHighLevel				org *+1

m_difficultyIndex				org *+1
;m_selectedVausIndex				org *+1
m_selectedMouseAccel			org *+1
m_selectedLevelIndex			org *+1
m_selectedControllerIndex		org *+1
m_selectedPaddleAngleIndex		org *+1

m_triggerTypeMask				org *+1

m_startingBallSpeed				org *+1
m_topBorderBallSpeed			org *+1
m_maxBallSpeed					org *+1
m_ballSpeedUpHalfSeconds			org *+1

m_usePaddleControllerFlag		org *+1


;================================================================================

END_STATIC_VARS_AREA
	.if END_STATIC_VARS_AREA > RMT_vars_address
		.error "Static vars area overwrite RMT vars area!"
	.endif

;================================================================================

; RMT music (use the address from the header of the music file,
; must be equal to RMT_song_address, or $2800 in this case)

	opt h-					; RMT module is standard Atari binary file already

	ins "RMT/ark_2a_exp.rmt"		; include music RMT module

	opt h+


;================================================================================

	org RMT_end_song_address

END_RMT_SONG_AREA
	.if END_RMT_SONG_AREA > [PLAYER-$0320]
		.error "RMT song area overwrite the RMT code area!"
	.endif

;================================================================================

; RMT code (the first 1K is almost used for vars)
; (from PLAYER-$0320 to PLAYER for mono RMT player)

	org RMT_address+$400

STEREOMODE equ 0				; 0 => compile RMT player for mono 4 tracks

	icl "RMT/rmtplayr_v3.asm"	; include hacked RMT player routine


;================================================================================

END_RMT_PLAYER_AREA

;================================================================================

	org Prog_start

InitSystem
	lda #1
	sta COLDST		; do cold start when pressing reset key

	ClearSystem

	DisableBasic
	DisableOperativeSystem


;================================================================================

	icl "pad_title.asm"


;================================================================================

SetNormalPadInfo
	lda #1		; P/M 3 double size
	sta m_padSizeP3

	lda #MAX_PAD_POSX
	sta m_maxPadPosX
	lda #[MAX_PAD_POSX+1]
	sta m_maxPadPosXPlusOne

	lda #[PAD_SIZEX+BALL_SIZEX+1]
	sta m_padCollisionSizeX
	lsr
	sta m_padCollisionHalfSizeX

	lda #[PAD_SIZEX/2]
	sta m_padHalfSizeX


	ldx #0

SNPI_loop1
; 	lda TabNormalPadShape,x
; 	sta TabCurrentPadShape,x
	lda TabNormalPadColor,x
	sta TabCurrentPadColor,x

	inx
	cpx #PAD_SIZEY
	bne SNPI_loop1


	ldx #0

SNPI_loop2
	lda TabNormalPadAngleIndex,x
	sta TabCurrentPadAngleIndex,x

	inx
	cpx #[PAD_SIZEX+BALL_SIZEX+1]
	bne SNPI_loop2


	ldx #0
	ldy #PAD_POSY1

SNPI_loop3
;	lda TabCurrentPadShape,x
	lda TabNormalPadShape,x
	sta p3_adr+PM_OFFSET_Y,y
	inx
	iny
	cpx #PAD_SIZEY
	bne SNPI_loop3


	rts


;-------------------------------
SetSmallPadInfo
	lda #1		; P/M 3 double size
	sta m_padSizeP3

	lda #MAX_PAD_SMALL_POSX
	sta m_maxPadPosX
	lda #[MAX_PAD_SMALL_POSX+1]
	sta m_maxPadPosXPlusOne

	lda #[PAD_SMALL_SIZEX+BALL_SIZEX+1]
	sta m_padCollisionSizeX
	lsr
	sta m_padCollisionHalfSizeX

	lda #[PAD_SMALL_SIZEX/2]
	sta m_padHalfSizeX


	ldx #0

SSPI_loop1
; 	lda TabSmallPadShape,x
; 	sta TabCurrentPadShape,x
	lda TabSmallPadColor,x
	sta TabCurrentPadColor,x

	inx
	cpx #PAD_SIZEY
	bne SSPI_loop1


	ldx #0

SSPI_loop2
	lda TabSmallPadAngleIndex,x
	sta TabCurrentPadAngleIndex,x

	inx
	cpx #[PAD_SMALL_SIZEX+BALL_SIZEX+1]
	bne SSPI_loop2


	ldx #0
	ldy #PAD_POSY1

SSPI_loop3
;	lda TabCurrentPadShape,x
	lda TabSmallPadShape,x
	sta p3_adr+PM_OFFSET_Y,y
	inx
	iny
	cpx #PAD_SIZEY
	bne SSPI_loop3


	rts


;-------------------------------
SetLargePadInfo
	lda #3		; P/M 3 quad size
	sta m_padSizeP3

	lda #MAX_PAD_LARGE_POSX
	sta m_maxPadPosX
	lda #[MAX_PAD_LARGE_POSX+1]
	sta m_maxPadPosXPlusOne

	lda #[PAD_LARGE_SIZEX+BALL_SIZEX+1]
	sta m_padCollisionSizeX
	lsr
	sta m_padCollisionHalfSizeX

	lda #[PAD_LARGE_SIZEX/2]
	sta m_padHalfSizeX


	ldx #0

SLPI_loop1
; 	lda TabLargePadShape,x
; 	sta TabCurrentPadShape,x
	lda TabLargePadColor,x
	sta TabCurrentPadColor,x

	inx
	cpx #PAD_SIZEY
	bne SLPI_loop1


	ldx #0

SLPI_loop2
	lda TabLargePadAngleIndex,x
	sta TabCurrentPadAngleIndex,x

	inx
	cpx #[PAD_LARGE_SIZEX+BALL_SIZEX+1]
	bne SLPI_loop2


	ldx #0
	ldy #PAD_POSY1

SLPI_loop3
;	lda TabCurrentPadShape,x
	lda TabLargePadShape,x
	sta p3_adr+PM_OFFSET_Y,y
	inx
	iny
	cpx #PAD_SIZEY
	bne SLPI_loop3


	rts


;================================================================================

PlayStartLevelSong
	lda #RMT_SONG_SPEED
	sta m_rmtSongSpeedCounter

; init RMT vcount update system
	lda VCOUNT
	sta m_currentVcountLineRMT

psls_loop
; update RMT vcount update system
	lda m_currentVcountLineRMT
	clc
	adc #RMT_UPDATE_VCOUNT_LINES
	cmp #[MAX_VCOUNT_VALUE+1]
	bcc psls_vcount_normal

psls_vcount_overflow
	sbc #[MAX_VCOUNT_VALUE+1]

psls_vcount_normal
	sta m_nextVcountLineRMT		; set next target value


; wait until reached or surpassed target vcount value
	cmp m_currentVcountLineRMT
	bcc psls_next_vcount_lower

psls_next_vcount_bigger
	lda VCOUNT
	cmp m_currentVcountLineRMT
	bcc psls_play_music_frame
	cmp m_nextVcountLineRMT
	bcs psls_play_music_frame

	jmp psls_next_vcount_bigger


psls_next_vcount_lower
	lda VCOUNT
	cmp m_currentVcountLineRMT
	bcs psls_next_vcount_lower
	cmp m_nextVcountLineRMT
	bcs psls_play_music_frame

	jmp psls_next_vcount_lower


psls_play_music_frame
; play RMT music
	jsr RASTERMUSICTRACKER+3		; play one frame

; update catched ball (more than necessary)
	lda pad_xpos
	clc
	adc m_catchedBallPadOffset
	sta ball_xpos_1
	sta ball_rxpos

	lda m_nextVcountLineRMT
	sta m_currentVcountLineRMT

	dec m_rmtSongSpeedCounter
	bne psls_loop

	lda #RMT_SONG_SPEED
	sta m_rmtSongSpeedCounter

	dec m_waitForSongEndCounter
	bne psls_loop

	; stop RMT menu music
	jsr RASTERMUSICTRACKER+9

	rts


;================================================================================

InitGame
	ldx PORTA

IG_nibbleTable
	lda TabGetLowNibble,x
	;lda TabGetHighNibble,x

	sta old_port

	lda #BALL_COLOR
	sta COLPM0

; 	lda #BALL_BACKG_COLOR1
; 	sta m_ballBackgroundColor
; 	sta m_ballAntialiasColor
; 	sta COLPM1

	lda #$94
	sta COLPF0

	lda #$08
	sta COLPF1

	lda #$0C
	sta COLPF2

	lda #$0E
	sta COLPF3

	lda #0
	sta COLBK

; init pad position and graphics
	jsr SetNormalPadInfo

	lda #PAD_START_POSITION
	sta pad_xpos
    	clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3

; 	ldx #0
; 	ldy #PAD_POSY1
; ipd	lda TabCurrentPadShape,x
; 	sta p3_adr+PM_OFFSET_Y,y
; 	inx
; 	iny
; 	cpx #PAD_SIZEY
; 	bne ipd

	lda #0
	sta dli_index
	sta m_soundFlag
	sta m_soundSize
	sta m_soundIndex
	sta m_soundPriority

	sta bonus_flag
	sta m_bonusType
	sta m_lastBonusType

	sta vbi_anim_ctd
	sta vbi_gold_ctd

; 	lda #ABORT_BONUS_NUM	; don't give a bonus for the first hits to bricks
; 	sta m_firstBonusDelayCounter

	lda #VBI_COUNTER_FRAMES
	sta vbi_jif_ctd

	lda #0
	sta old_ball_rypos
	sta ball_rypos
	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos

.if .def	USE_ENEMY_CODE
	lda #0
	sta m_enemy1OldPosY
.endif

	lda m_selectedLevelIndex
	sta m_levelIndex

	lda #0
	sta m_playerScore
	sta m_playerScore+1
	sta m_playerScore+2
	jsr DisplayScore

	lda #STARTING_BALLS
	sta m_numberOfBallsLeft

; clear ball hud at the start of the game
	jsr ClearAllBallsInHud

	lda #0
	sta m_ballNumHud
	jsr IncreaseBallsInHud
	jsr IncreaseBallsInHud
	jsr IncreaseBallsInHud

	;jsr DisplayLives


	SetDisplayListAddress DL1_address

	lda #<DLI1_address
	sta NMIH_VECTOR		;VDSLST
	lda #>DLI1_address
	sta NMIH_VECTOR+1		;VDSLST+1

	lda #0
	sta SIZEP0
	lda #0
	sta SIZEP1
	lda #0
	sta SIZEP2
	;lda #1
	;sta SIZEP3
	lda #%00000001
	sta SIZEM

	SetPMBaseAddress PM_zone_address

	lda #[PRV_FIFTH_PLAYER | PRV_PM_PRIORITY_1]
	sta PRIOR

; 	lda #<VBI_address
; 	sta VVBLKI
; 	lda #>VBI_address
; 	sta VVBLKI+1

	SetFontAddress Font1_address

; ial lda VCOUNT
; 	bne ial
;
; 	lda #[DV_DMA_ON | DV_PLAYERS_ON | DV_MISSILES_ON | DV_PM_ONE_LINE | DV_NARROW_PF]
; 	sta DMACTL
; 	lda #%10000000		; only DLI's on
; 	sta NMIEN

	lda #255
	sta m_startGameFlag


;--------------------------------------------------------------------------------

InitLevel
	lda #GS_LEVEL_PLAY		; GS_LEVEL_START
	sta m_gameState

; wait some frames before starting the global highlight effect
	lda #FRAMES_TIMER_UNIT*4
	sta m_startLevelHighlightTimer
	lda #0
	sta m_startLevelHighlightStep

	lda #0
	sta anim_num
	sta gold_init
	sta gold_num

	sta m_extraPlayerBonusFlag

	sta m_ballLostThisLevelFlag


; init animations table
	ldx #0
cat	sta tab_anim_lsb,x
	inx
	cpx #MAX_ACTIVE_HIGHLIGHT_ANIMS*4		; 4 tables
	bne cat


;init gold brick memory table
	ldx #0
cgt	sta TabRestoreBrick_lsb,x
	inx
	cpx #MAX_ACTIVE_RESTORE_BRICKS*4		; 4 tables
	bne cgt


; reset pad position
	lda #PAD_START_POSITION
	sta pad_xpos
    clc
	adc #PM_OFFSET_X
	sta m_padHPOSP3


; force the redraw of the "holes" to exit a level
	jsr ForceCloseSideHoles

	lda #0
	sta m_animateExitsTimer
	sta m_exitsAnimationIndex


; init background for empty level (?)
	lda #<[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET]
	sta ptr_1
	lda #>[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET]
	sta ptr_1+1
	lda #0
	sta ctd_1
	sta ctd_2

bk1	lda ctd_2
	and #3
	asl
	sta temp_1
	lda ctd_1
	and #1
	ora temp_1
	tax
	lda TabBackgroundCharDef,x
	sta temp_1
	clc
	adc #1
	sta temp_2

; add shadow for the left row of the play area
	ldx ctd_1
	bne bk2
	lda temp_1
	ora #%10000     ; shadow bit
	sta temp_1

; add shadow for the top line of the play area
bk2	ldy ctd_2
	bne bk3
	lda temp_1
	ora #%10000     ; shadow bit
	sta temp_1
	lda temp_2
	ora #%10000     ; shadow bit
	sta temp_2

bk3	txa
	asl		; *2
	tay
	lda temp_1
	sta (ptr_1),y
	iny
	lda temp_2
	sta (ptr_1),y

	inx
	cpx #[GAME_AREA_SIZEX/BRICK_SIZEX]
	bne bk5
	ldx #0
	inc ctd_2
	lda ptr_1
	clc
	adc #BYTES_LINE
	bcc bk4
	inc ptr_1+1
bk4	sta ptr_1
bk5	stx ctd_1

	lda ctd_2
	cmp #[GAME_AREA_SIZEY/BRICK_SIZEY]
	bne bk1


; init bricks for this level
	ldx m_levelIndex

	lda m_difficultyIndex
	cmp #3	; "extra" game mode
	bcs IL_extra_level_address

	lda TabLevelAddress_LSB,x
	sta ptr_1
	lda TabLevelAddress_MSB,x
	sta ptr_1+1

	jmp IL_end_level_address

IL_extra_level_address
	lda TabLevelExtraAddress_LSB,x
	sta ptr_1
	lda TabLevelExtraAddress_MSB,x
	sta ptr_1+1

IL_end_level_address


; copy bricks definition to "current level table"
	ldy #0
il1	lda (ptr_1),y
	sta TabLevel,y
	iny
	cpy #[NUM_BRICKS_X*NUM_BRICKS_Y]
	bne il1

; update pointer, because we are going to go over 256 bytes
	lda ptr_1
	clc
	adc #[NUM_BRICKS_X*NUM_BRICKS_Y]
	bcc il1b
	inc ptr_1+1
il1b	sta ptr_1

	ldy #0

; copy color table for white bricks
	ldx #0
il2	lda (ptr_1),y
	sta TabDLI_COLPF2,x
	iny
	inx
	cpx #[2+NUM_BRICKS_Y]		; 2+ ==> first 2 border lines
	bne il2

; copy color table for grey bricks
	ldx #0
il2b	lda (ptr_1),y
	sta TabDLI_COLPF1,x
	iny
	inx
	cpx #[2+NUM_BRICKS_Y]		; 2+ ==> first 2 border lines
	bne il2b

; init background index
	lda (ptr_1),y
	sta m_backgroundIndex

; init background color
	iny
	lda (ptr_1),y
	sta m_backgroundColor
	sta COLPF0

; use background color to set the default antialias color for the ball
	and #%11110000		; get the color part
	ora #$08			; set a fixed lum
	sta m_ballBackgroundColor
	sta m_ballAntialiasColor
	sta COLPM1

; init number of bricks to complete the level
	iny
	lda (ptr_1),y
	sta brick_lev_num


; init font 1 with the correct background data (copy 32 chars, 256 bytes)
	lda #>Font_background_address
	clc
	adc m_backgroundIndex
	sta ptr_1+1

	ldy #0
	sty ptr_1
IL_background_loop
	lda (ptr_1),y
	sta Font1_address,y
	iny
	bne IL_background_loop


; init screen with all the bricks in this level and the shadows
; (bricks start at line 2 of the screen, shadows at line 3)
	lda #0
	sta ctd_1
	lda #<[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET] ; pointer for the brick
	sta ptr_1
	lda #>[DL1_data_address+BYTES_LINE*2+LEFT_BRICK_OFFSET]
	sta ptr_1+1
	lda #<[DL1_data_address+BYTES_LINE*3+LEFT_BRICK_OFFSET+1] ; pointer for the shadow
	sta ptr_2
	lda #>[DL1_data_address+BYTES_LINE*3+LEFT_BRICK_OFFSET+1]
	sta ptr_2+1

	ldy #0
il3	ldx ctd_1
	lda TabLevel,x
	lsr
	lsr
	lsr
	lsr
	bne il4
	iny
	jmp il5

il4	tax
	lda TabLeftBrickCharDef,x
	sta (ptr_1),y
	lda (ptr_2),y		; put the shadow inclusive if it's going to be overwritten
	ora #%10000		; shadow bit
	sta (ptr_2),y

	iny				; every brick has a left and a right char

	lda TabRightBrickCharDef,x
	sta (ptr_1),y
	cpy #NUM_BRICKS_X*2-1	; check if it's the right border brick
	beq il5
	lda (ptr_2),y		; put the shadow inclusive if is going to be overwritten
	ora #%10000		; shadow bit
	sta (ptr_2),y

il5	iny

	inc ctd_1
	cpy #NUM_BRICKS_X*2		; check if we completed the line of bricks
	bne il3

	ldy #0

	lda ptr_1
	clc
	adc #BYTES_LINE
	bcc il6
	inc ptr_1+1
il6	sta ptr_1

	lda ptr_2
	clc
	adc #BYTES_LINE
	bcc il7
	inc ptr_2+1
il7	sta ptr_2

	ldx ctd_1
	cpx #[NUM_BRICKS_X*NUM_BRICKS_Y]
	bne il3


; init rmt player for the intro
	lda #0
	sta RMTGLOBALVOLUMEFADE

	ldx #<RMT_song_address		; low byte of RMT module to X reg
	ldy #>RMT_song_address		; hi byte of RMT module to Y reg
	lda #10						; starting song line 0-255 to A reg
	jsr RASTERMUSICTRACKER		; Init

	lda #START_GAME_SOUND_TIME
	sta m_waitForSongEndCounter

; clear all sound effect info? (and the hardware sound registers?)
	// lda #0
	// sta m_soundFlag
	// sta m_soundSize
	// sta m_soundIndex
	// sta m_soundPriority


;--------------------------------------------------------------------------------

InitBall

.if .def SHOW_TIMING_AREAS
	lda #0
	sta m_mainAreaColor
	sta COLBK
.endif

	lda #1
	sta m_numberOfBallsInPlay

; 	lda #2
; 	sta ball_xdir
; 	lda #2
; 	sta ball_ydir
;
; 	lda #0
; 	sta ball_xstep_2
; 	sta ball_ystep_2
;
; ; starting speed of the ball
; .if .def PAL_VERSION
; 	lda #48
; 	sta ball_xstep_1
; 	lda #96
; 	sta ball_ystep_1
; .else
; 	lda #40
; 	sta ball_xstep_1
; 	lda #80
; 	sta ball_ystep_1
; .endif

	lda #0
	sta ball_xpos_2
	sta ball_xpos_3
	sta ball_ypos_2
	sta ball_ypos_3

	sta m_ballHitTopBorderFlag
	;sta m_ballHitsCounter
	sta m_ballSpeedUpTimer

	lda m_startingBallSpeed
	sta m_currentBallSpeed

; restore ball antialiasing color
	lda m_ballBackgroundColor
	sta m_ballAntialiasColor
	sta COLPM1


; start ball at position (5,18) approx, in brick coordinates
; but now, put it outside the screen, until the player press the button
; 	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
; 	sta ball_xpos_1
; 	sta ball_rxpos
; 	lda #BRICK_SIZEY*BOTTOM_BRICK_NUM+1
; 	sta ball_ypos_1
; 	sta ball_rypos


.if .def USE_ENEMY_CODE
; init enemies
	lda #ENEMY_STATE_WAIT_RESPAWN
	sta m_enemy1State

	lda #<[4*FRAMES_ONE_SECOND]		; time for the first enemy to appear after puting the ball in play
	sta m_enemy1StateTimer
	lda #>[4*FRAMES_ONE_SECOND]
	sta m_enemy1StateTimer+1

	ldy m_enemy1OldPosY
	;jsr EraseEnemy1		; move this to other part of the code or clear the P/M after losing a ball? (ClearCurrentLevel, EndGame ..)
	jsr EraseExplosion1		; use this just to be sure (the area erased is bigger)
.endif


; init mouse read logic
; 	lda #0
; 	sta old_mov
	lda #MOUSE_READS_TO_ACCELERATE
	sta m_mouseAccelCounter
	lda #MIN_MOUSE_STEP
	sta m_mouseStep

	lda #0
	sta m_mouseAccelMemoryCounter

	sta m_oldMouseReadDirection

	;sta m_padFrameDirection
	sta m_padFrameDeltaStep


; reset active bonus
	jsr ClearBonusExpandEffect
	jsr ClearBonusReduceEffect
	jsr ClearBonusMegaEffect
	;jsr ClearBonusDisruptEffect
	jsr ClearBonusBreakEffect
	jsr ClearBonusCatchEffect


; check to see if we come from the presentation screen
	bit m_startGameFlag
	bpl ib_launch_ball

	lda #0
	sta m_startGameFlag

; this need to be >= 124 (the VBI signal line), is this a bug in emulation? (don't think so..)
	VcountWait 128

	lda #3
	sta GRACTL

	lda #%10000000		; only DLI's on
	sta NMIEN

	lda #[DV_DMA_ON | DV_PLAYERS_ON | DV_MISSILES_ON | DV_PM_ONE_LINE | DV_NARROW_PF]
	sta DMACTL


ib_launch_ball
	lda m_waitForSongEndCounter
	beq ib_launch_normal_time

	lda #[FRAMES_TIMER_UNIT*1]		// if we play the intro song, no need to wait that much
	sta m_startGameWaitTimer
	jmp ib_start_delay

ib_launch_normal_time
	lda #[FRAMES_TIMER_UNIT*8]
	sta m_startGameWaitTimer

ib_start_delay
	lda m_startGameWaitTimer
	bne ib_start_delay


	VcountSync 32

	jsr DecreaseBallsInHud


; start with the ball catched, set direction, step and position
	lda #[PAD_SIZEX/2-1]	; middle pixel (the right one) of the normal pad
	sta m_catchedBallPadOffset

	lda #2				; going to the right
	sta ball_xdir
	lda #1				; going up
	sta ball_ydir

	lda tab_pad_xstep1+BALL_START_ANGLE_INDEX
	sta ball_xstep_1
	lda tab_pad_xstep2+BALL_START_ANGLE_INDEX
	sta ball_xstep_2

	lda tab_pad_ystep1+BALL_START_ANGLE_INDEX
	sta ball_ystep_1
	lda tab_pad_ystep2+BALL_START_ANGLE_INDEX
	sta ball_ystep_2

	lda #PAD_BALL_POSY1
	sta ball_ypos_1
	sta ball_rypos
	jsr UpdateSpriteBall1

	lda pad_xpos
	clc
	adc m_catchedBallPadOffset
	sta ball_xpos_1
	sta ball_rxpos


	lda #128
	sta m_startGameBallCatchedFlag

	lda m_waitForSongEndCounter
	beq ib_launch_ball_loop
	jsr PlayStartLevelSong


; wait here to launch the ball (by trigger or the space bar)
ib_launch_ball_loop

	VcountWait 32

	// lda m_waitForSongEndCounter		// only if we were updating this in the VBI
	// bne ib_launch_ball_loop

	bit m_pauseModeFlag
	bmi ib_launch_ball_loop


; update catched ball
	lda pad_xpos
	clc
	adc m_catchedBallPadOffset
	sta ball_xpos_1
	sta ball_rxpos


TRIGGER_address3
	lda TRIG0
	and m_triggerTypeMask
	beq ib_launch_ball_release

	lda SKCTL
	and #4			; a key pressed ?
	bne ib_launch_ball_loop

	lda KBCODE
	and #%00111111		; bit7 -> control, bit6 -> shift
	cmp #12			; "return" key
	beq ib_launch_ball_key_release

	jmp ib_launch_ball_loop


ib_launch_ball_release
; 	lda TRIG0
; 	beq ib_launch_ball_release
; 	jmp ib_ball_launched

ib_launch_ball_key_release
; 	lda SKCTL
; 	and #4			; a key pressed ?
; 	bne ib_launch_ball_key_release


ib_ball_launched
;	jsr DecreaseBallsInHud

	lda #0
	sta m_startGameBallCatchedFlag


; show ball at correct X position now
; 	lda #BRICK_SIZEX*5+1
; 	sta ball_xpos_1
; 	sta ball_rxpos


; start ball speed up timer
	lda m_ballSpeedUpHalfSeconds
	sta m_ballSpeedUpTimer


;================================================================================

GameLoop

.if .def SHOW_TIMING_AREAS
	lda #0
	sta m_mainAreaColor
	sta COLBK
.endif

	VcountWait 16

.if .def SHOW_TIMING_AREAS
	lda #$52
	sta m_mainAreaColor
	sta COLBK
.endif


	bit m_pauseModeFlag
	bmi GameLoop


;-------------------------------
; check game state

	lda m_gameState
	cmp #GS_LEVEL_PLAY
	beq GL_playing_state

; do also GS_LEVEL_START with capture bonus behavior?

	cmp #GS_LEVEL_WIN
	bne GL_playing_state


;-------------------------------
; do events after winning the level

	jsr AnimateBrickHighlight


	jsr CheckRestoreBrickList


GLLW_check_side_exit
	lda m_openSidesWaitTimer
	bne GameLoop

	bit m_padAtLeftLimitFlag
	bmi GLLW_exit_left
	bit m_padAtRightLimitFlag
	bpl GameLoop


	lda #0			; go to the "right" level
	jmp GLLW_exit_update

GLLW_exit_left
	lda #128			; go to the "left" level

GLLW_exit_update
	sta m_nextLevelIsLeft


; check effect of the "break" bonus
	bit m_bonusBreakIsActive
	bpl GLLW_exit

; add $10000 to the score
	ldy #$10			; high byte of the score in BCD
	ldx #$00			; low byte of the score in BCD
	jsr AddScore


GLLW_exit
	jmp GoToNextLevel


;-------------------------------

GL_playing_state

	bit m_ballCatchedByPadFlag
	bpl GL_check_difficulty

; check input to drop the ball(s)
TRIGGER_address4
	lda TRIG0
	and m_triggerTypeMask
	beq GL_drop_ball

	lda SKCTL
	and #4			; a key pressed ?
	bne GL_check_difficulty

	lda KBCODE
	and #%00111111		; bit7 -> control, bit6 -> shift
	cmp #12			; "return" key
	bne GL_check_difficulty

GL_drop_ball
	lda #0
	sta m_ballCatchedByPadFlag


GL_check_difficulty
	lda m_difficultyIndex
	bne GL_ps_not_easy_difficulty

; use minimun speed if we are playing in "easy" mode
	lda #MIN_BALL_SPEED
	sta m_ballSpeedCounter
	jmp MoveAllBallsLoop

GL_ps_not_easy_difficulty
	lda m_currentBallSpeed
	sta m_ballSpeedCounter


;-------------------------------

; This is the current main loop to move all the balls, all active balls are moved one step in X and Y
; inside the loop "MoveBallLoop" (updating "m_currentBallIndex" every time) and then the group is moved
; again according to the value in m_ballSpeedCounter (the current max speed normal value is 6, and in
; arcade is 7) in the external loop "MoveAllBallsLoop" (also the max step (X,Y) is ($56.EC, $AD.D8) in
; NTSC, and ($68.4E, $D0.9D) in pal).

; With this we can assume that cannot be more than 2 collisions in the vertical axis in the same frame
; (and maybe only one in the horizontal axis), but we should really try to optimize the general case
; where the balls don't cross any limit anyway (if we want to add more balls, like 5 or 6 max).

MoveAllBallsLoop
	lda #0
	sta m_currentBallIndex

	sta m_ballLostFlag
	sta m_ballLostFlag+1
	sta m_ballLostFlag+2


MoveBallLoop

.if .def SHOW_TIMING_AREAS
	lda m_currentBallIndex
	asl
	adc #4
	sta m_mainAreaColor
	sta COLBK
.endif

; init ball data for multi ball case


; after this we always return to "UpdateRealCoords", at least we lose the level
	jmp UpdateBallPosition


;-------------------------------

; remember the new pixel position for the next step
UpdateRealCoords
	ldx m_currentBallIndex
	lda ball_xpos_1,x
	sta ball_rxpos,x
	lda ball_ypos_1,x
	sta ball_rypos,x


	;inc m_ballStepsInFrame


; save ball data for multi ball case


; loop over all active balls
	inc m_currentBallIndex
	lda m_currentBallIndex
	cmp m_numberOfBallsInPlay
	bne MoveBallLoop


.if .def SHOW_TIMING_AREAS
	lda #$52
	sta m_mainAreaColor
	sta COLBK
.endif


;-------------------------------

; check here all the cases for when we lose balls
	jsr CheckBallsLost

	lda m_numberOfBallsInPlay
	beq LostPlayer


;-------------------------------

; iterate the balls movement, according to the current speed
	dec m_ballSpeedCounter
	bne MoveAllBallsLoop


;-------------------------------

	lda m_bonusType
	bpl GL_animate_highlight

	jsr StartBonusAction


;-------------------------------

GL_animate_highlight

	jsr AnimateBrickHighlight


;-------------------------------

	jsr CheckRestoreBrickList


;-------------------------------

; if the number of current bricks is low or equal than the number of extra balls for the player, then we open the exits
; - still need to check for no bricks to clear the level!
; - don't give the break bonus this way! (maybe use another flag like m_exitIsOpenFlag)
GL_check_balls_exit_rule
	/*bit m_bonusBreakIsActive
	bmi GL_forced_break_exit

	lda m_numberOfBallsLeft
	cmp brick_lev_num
	bcc GL_check_end_level

	lda #0
	sta m_padAtRightLimitFlag
	sta m_padAtLeftLimitFlag

	lda #128
	sta m_bonusBreakIsActive

	jsr ForceOpenSideHoles

	jmp GL_forced_break_exit*/


GL_check_end_level
	lda brick_lev_num
	bne GL_check_break_exit

; 	lda #128			; go to the "left" level
; 	sta m_nextLevelIsLeft

	jmp NextLevelStart


GL_check_break_exit
; check effect of the "break" bonus
	bit m_bonusBreakIsActive
	bpl GL_check_left_key

GL_forced_break_exit
	bit m_padAtLeftLimitFlag
	bmi GL_break_exit_left
	bit m_padAtRightLimitFlag
	bpl GL_check_left_key

	lda #0			; go to the "right" level
	jmp GL_break_exit_update

GL_break_exit_left
	lda #128			; go to the "left" level

GL_break_exit_update
	sta m_nextLevelIsLeft

; 	lda pad_xpos
; 	cmp m_maxPadPosXPlusOne
; 	bcc GL_check_shift_key

; add $10000 to the score
	ldy #$10			; high byte of the score in BCD
	ldx #$00			; low byte of the score in BCD
	jsr AddScore

	jsr ClearCurrentLevel
	jmp GoToNextLevel


; hack to pass a level using the SHIFT key (go left) or another key (go right)
GL_check_left_key

.if .def SKIP_LEVEL_HACK
	lda SKCTL
	and #4			; any key pressed?
	bne GL_end_check_keys

	lda KBCODE
	and #%00111111		; bit7 -> control, bit6 -> shift
	cmp #6			; left arrow key
	bne GL_check_right_key

	lda #128			; go to the "left" level
	sta m_nextLevelIsLeft

	jsr ClearCurrentLevel
	jmp GoToNextLevel


GL_check_right_key
	cmp #7			; right arrow key
	bne GL_end_check_keys

	lda #0			; go to the "right" level
	sta m_nextLevelIsLeft

	jsr ClearCurrentLevel
	jmp GoToNextLevel
.endif

GL_end_check_keys


;-------------------------------

	jmp GameLoop


;================================================================================

LostPlayer
	lda bonus_flag
	beq LP_no_bonus

	jsr ClearBonus

LP_no_bonus
	lda #0
	sta m_bonusType

	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos

	dec m_numberOfBallsLeft
	bne LP_next_ball

	jmp EndGame

LP_next_ball
	;jsr DisplayLives

	jsr DrawRestoreBrickList

	lda #128
	sta m_ballLostThisLevelFlag

// add code for the "ball lost" state here	and also start the pad destruction animation
// (that should be updated in the VBI)
	lda #9
	sta m_soundFlag


	jmp InitBall


;--------------------------------------------------------------------------------

NextLevelStart
	lda #GS_LEVEL_WIN
	sta m_gameState


	jsr ClearCurrentLevel


; set a timer to open both sides holes in the VBI code
	lda #[FRAMES_TIMER_UNIT*7]
	sta m_openSidesWaitTimer


	jmp GameLoop


;--------------------------------------------------------------------------------

ClearCurrentLevel

; clear falling bonus
CCL_check_bonus_active
	lda bonus_flag
	beq CCL_no_bonus_active

	jsr ClearBonus

CCL_no_bonus_active
	lda #0
	sta m_bonusType


; clear balls
	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos		; multiball code change

; check if we ended the level with more than one active ball
	lda m_numberOfBallsInPlay
	cmp #2
	bcc CCL_no_multiball

	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos+1
	sta ball_rxpos+2

	ldy old_ball_rypos+1
	jsr EraseBall2
	ldy old_ball_rypos+2
	jsr EraseBall3

	lda #1		; trick the VBI to not draw them again in this frame
	sta m_numberOfBallsInPlay
CCL_no_multiball


	jsr IncreaseBallsInHud


	rts


;--------------------------------------------------------------------------------

GoToNextLevel

; add $5000 to the score if we passed the level without losing a ball
	bit m_ballLostThisLevelFlag
	bmi GTNL_end_perfect_bonus

	lda brick_lev_num		; check also that there are no bricks left
	bne GTNL_end_perfect_bonus

	ldy #$05			; high byte of the score in BCD
	ldx #$00			; low byte of the score in BCD
	jsr AddScore

GTNL_end_perfect_bonus


	lda m_difficultyIndex
	cmp #3	; "extra" game mode
	bcc GTNL_game_mode_tree


; "game mode extra" logic
GTNL_game_mode_extra
	ldx m_levelIndex

; unlock the completed level
	lda #128
	sta TabLevelUnlockedExtra,x


; check if there are no more levels
	cpx #LAST_LEVEL_GROUP_INDEX_EXTRA
	bcs GTNL_end_game

	lda TabLevelLeftExitExtra,x
	tax

	bit m_nextLevelIsLeft
	bmi GTNL_set_next_level

	inx		; the "right" level is always the "left" level plus one

	jmp GTNL_set_next_level


; "game mode tree" logic
GTNL_game_mode_tree
	ldx m_levelIndex

; unlock the completed level
	lda #128
	sta TabLevelUnlocked,x


; check if there are no more levels
	cpx #LAST_LEVEL_GROUP_INDEX
	bcs GTNL_end_game

	lda TabLevelLeftExit,x
	tax

	bit m_nextLevelIsLeft
	bmi GTNL_set_next_level

	inx		; the "right" level is always the "left" level plus one

	jmp GTNL_set_next_level


; end the game (or restart from first level)
GTNL_end_game
	;ldx #0			; restart from first level
	jmp EndGame


GTNL_set_next_level
	stx m_levelIndex

	jmp InitLevel


;--------------------------------------------------------------------------------

EndGame
	ldy old_ball_rypos
	jsr EraseBall1
	jsr EraseBall2


; don't update the score if we are playing in "easy" mode
; 	lda m_difficultyIndex
; 	beq EG_end_high_score


	jsr DisplayLastScore

; update session high score
	lda m_sessionHighScore+2
	cmp m_playerScore+2
	bcc EG_new_high_score
	bne EG_end_high_score

	lda m_sessionHighScore+1
	cmp m_playerScore+1
	bcc EG_new_high_score
	bne EG_end_high_score

	lda m_sessionHighScore
	cmp m_playerScore
	bcs EG_end_high_score

EG_new_high_score
	lda m_playerScore
	sta m_sessionHighScore
	lda m_playerScore+1
	sta m_sessionHighScore+1
	lda m_playerScore+2
	sta m_sessionHighScore+2

	jsr DisplaySessionScore

	jsr DisplayHighScoreLevel

EG_end_high_score

	jsr SaveGameTypeHighScore


	jmp StartGame


;================================================================================
SaveGameTypeHighScore
	lda m_difficultyIndex
	cmp #1
	beq SGTHS_casual
	cmp #2
	beq SGTHS_arcade
	cmp #3
	beq SGTHS_extra

SGTHS_easy
	ldx #0

SGTHS_easy_loop
	lda DL2_score_line,x
	sta Tab_score_line_easy,x

	inx
	cpx #BYTES_LINE
	bne SGTHS_easy_loop

	lda m_sessionHighScore
	sta TabHighScoreEasy
	lda m_sessionHighScore+1
	sta TabHighScoreEasy+1
	lda m_sessionHighScore+2
	sta TabHighScoreEasy+2

	lda m_sessionHighLevel
	sta TabHighLevelEasy

	jmp SGTHS_exit


SGTHS_casual
	ldx #0

SGTHS_casual_loop
	lda DL2_score_line,x
	sta Tab_score_line_casual,x

	inx
	cpx #BYTES_LINE
	bne SGTHS_casual_loop

	lda m_sessionHighScore
	sta TabHighScoreCasual
	lda m_sessionHighScore+1
	sta TabHighScoreCasual+1
	lda m_sessionHighScore+2
	sta TabHighScoreCasual+2

	lda m_sessionHighLevel
	sta TabHighLevelCasual

	jmp SGTHS_exit


SGTHS_arcade
	ldx #0

SGTHS_arcade_loop
	lda DL2_score_line,x
	sta Tab_score_line_arcade,x

	inx
	cpx #BYTES_LINE
	bne SGTHS_arcade_loop

	lda m_sessionHighScore
	sta TabHighScoreArcade
	lda m_sessionHighScore+1
	sta TabHighScoreArcade+1
	lda m_sessionHighScore+2
	sta TabHighScoreArcade+2

	lda m_sessionHighLevel
	sta TabHighLevelArcade

	jmp SGTHS_exit


SGTHS_extra
	ldx #0

SGTHS_extra_loop
	lda DL2_score_line,x
	sta Tab_score_line_extra,x

	inx
	cpx #BYTES_LINE
	bne SGTHS_extra_loop

	lda m_sessionHighScore
	sta TabHighScoreExtra
	lda m_sessionHighScore+1
	sta TabHighScoreExtra+1
	lda m_sessionHighScore+2
	sta TabHighScoreExtra+2

	lda m_sessionHighLevel
	sta TabHighLevelExtra


SGTHS_exit
	rts


RestoreGameTypeHighScore
	lda m_difficultyIndex
	cmp #1
	beq RGTHS_casual
	cmp #2
	beq RGTHS_arcade
	cmp #3
	beq RGTHS_extra

RGTHS_easy
	ldx #0

RGTHS_easy_loop
	lda Tab_score_line_easy,x
	sta DL2_score_line,x

	inx
	cpx #BYTES_LINE
	bne RGTHS_easy_loop

	lda TabHighScoreEasy
	sta m_sessionHighScore
	lda TabHighScoreEasy+1
	sta m_sessionHighScore+1
	lda TabHighScoreEasy+2
	sta m_sessionHighScore+2

	lda TabHighLevelEasy
	sta m_sessionHighLevel

	jmp RGTHS_exit


RGTHS_casual
	ldx #0

RGTHS_casual_loop
	lda Tab_score_line_casual,x
	sta DL2_score_line,x

	inx
	cpx #BYTES_LINE
	bne RGTHS_casual_loop

	lda TabHighScoreCasual
	sta m_sessionHighScore
	lda TabHighScoreCasual+1
	sta m_sessionHighScore+1
	lda TabHighScoreCasual+2
	sta m_sessionHighScore+2

	lda TabHighLevelCasual
	sta m_sessionHighLevel

	jmp RGTHS_exit


RGTHS_arcade
	ldx #0

RGTHS_arcade_loop
	lda Tab_score_line_arcade,x
	sta DL2_score_line,x

	inx
	cpx #BYTES_LINE
	bne RGTHS_arcade_loop

	lda TabHighScoreArcade
	sta m_sessionHighScore
	lda TabHighScoreArcade+1
	sta m_sessionHighScore+1
	lda TabHighScoreArcade+2
	sta m_sessionHighScore+2

	lda TabHighLevelArcade
	sta m_sessionHighLevel

	jmp RGTHS_exit


RGTHS_extra
	ldx #0

RGTHS_extra_loop
	lda Tab_score_line_extra,x
	sta DL2_score_line,x

	inx
	cpx #BYTES_LINE
	bne RGTHS_extra_loop

	lda TabHighScoreExtra
	sta m_sessionHighScore
	lda TabHighScoreExtra+1
	sta m_sessionHighScore+1
	lda TabHighScoreExtra+2
	sta m_sessionHighScore+2

	lda TabHighLevelExtra
	sta m_sessionHighLevel


RGTHS_exit
	rts


;================================================================================

CheckBallsLost

; first erase the PM and move it out the screen for every ball lost
	bit m_ballLostFlag+2
	bpl CBL_check_erase_ball2

	ldy old_ball_rypos+2
	jsr EraseBall3

	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos+2

CBL_check_erase_ball2
	bit m_ballLostFlag+1
	bpl CBL_check_erase_ball1

	ldy old_ball_rypos+1
	jsr EraseBall2

	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos+1

CBL_check_erase_ball1
	bit m_ballLostFlag
	bpl CBL_update_ball_info

	ldy old_ball_rypos
	jsr EraseBall1

	lda #[[256-BALL_SIZEX]-PM_OFFSET_X]
	sta ball_rxpos


;-------------------------------
; now update the number of balls in play and move the active ball info around,
; so the "alive" balls are always at the start of the list
CBL_update_ball_info
	lda m_numberOfBallsInPlay
	cmp #3
	bne CBL_check_for_two

; playing with 3 balls
	bit m_ballLostFlag+2
	bpl CBL_3balls_check_second
	dec m_numberOfBallsInPlay

CBL_3balls_check_second
	bit m_ballLostFlag+1
	bpl CBL_3balls_check_first
	jsr MoveThirdBallInfo
	dec m_numberOfBallsInPlay

CBL_3balls_check_first
	bit m_ballLostFlag
	bpl CBL_check_antialias
	jsr MoveSecondBallInfo
	jsr MoveThirdBallInfo
	dec m_numberOfBallsInPlay

	jmp CBL_check_antialias


;-------------------------------

CBL_check_for_two
	cmp #2
	bne CBL_check_for_one

CBL_playing_with_two
; playing with 2 balls
	bit m_ballLostFlag+1
	bpl CBL_2balls_check_first
	dec m_numberOfBallsInPlay

CBL_2balls_check_first
	bit m_ballLostFlag
	bpl CBL_check_antialias
	jsr MoveSecondBallInfo
	dec m_numberOfBallsInPlay

CBL_check_antialias
	lda m_numberOfBallsInPlay
	cmp #1
	bne CBL_end

; restore one ball antialiasing color
	lda m_ballAntialiasColor
	sta COLPM1

	jmp CBL_end


;-------------------------------

CBL_check_for_one
; playing with 1 ball
	bit m_ballLostFlag
	bpl CBL_end

; lost the last ball
	dec m_numberOfBallsInPlay


CBL_end
	rts


;================================================================================

MoveSecondBallInfo
	lda ball_xstep_1+1
	sta ball_xstep_1
	lda ball_xstep_2+1
	sta ball_xstep_2
	lda ball_ystep_1+1
	sta ball_ystep_1
	lda ball_ystep_2+1
	sta ball_ystep_2

	lda ball_xdir+1
	sta ball_xdir
	lda ball_ydir+1
	sta ball_ydir

	lda ball_xpos_1+1
	sta ball_xpos_1
	lda ball_xpos_2+1
	sta ball_xpos_2
	lda ball_xpos_3+1
	sta ball_xpos_3

	lda ball_ypos_1+1
	sta ball_ypos_1
	lda ball_ypos_2+1
	sta ball_ypos_2
	lda ball_ypos_3+1
	sta ball_ypos_3

	lda ball_rxpos+1
	sta ball_rxpos
	lda ball_rypos+1
	sta ball_rypos
	lda old_ball_rypos+1
	sta old_ball_rypos


	ldy old_ball_rypos+1
	jmp EraseBall2

	;rts


MoveThirdBallInfo
	lda ball_xstep_1+2
	sta ball_xstep_1+1
	lda ball_xstep_2+2
	sta ball_xstep_2+1
	lda ball_ystep_1+2
	sta ball_ystep_1+1
	lda ball_ystep_2+2
	sta ball_ystep_2+1

	lda ball_xdir+2
	sta ball_xdir+1
	lda ball_ydir+2
	sta ball_ydir+1

	lda ball_xpos_1+2
	sta ball_xpos_1+1
	lda ball_xpos_2+2
	sta ball_xpos_2+1
	lda ball_xpos_3+2
	sta ball_xpos_3+1

	lda ball_ypos_1+2
	sta ball_ypos_1+1
	lda ball_ypos_2+2
	sta ball_ypos_2+1
	lda ball_ypos_3+2
	sta ball_ypos_3+1

	lda ball_rxpos+2
	sta ball_rxpos+1
	lda ball_rypos+2
	sta ball_rypos+1
	lda old_ball_rypos+2
	sta old_ball_rypos+1


	ldy old_ball_rypos+2
	jmp EraseBall3

	;rts


CopyFirstBallInfo
	lda ball_xstep_1
	sta ball_xstep_1+1
	sta ball_xstep_1+2
	lda ball_xstep_2
	sta ball_xstep_2+1
	sta ball_xstep_2+2
	lda ball_ystep_1
	sta ball_ystep_1+1
	sta ball_ystep_1+2
	lda ball_ystep_2
	sta ball_ystep_2+1
	sta ball_ystep_2+2

	lda ball_xdir
	sta ball_xdir+1
	sta ball_xdir+2
	lda ball_ydir
	sta ball_ydir+1
	sta ball_ydir+2

	lda ball_xpos_1
	sta ball_xpos_1+1
	sta ball_xpos_1+2
	lda ball_xpos_2
	sta ball_xpos_2+1
	sta ball_xpos_2+2
	lda ball_xpos_3
	sta ball_xpos_3+1
	sta ball_xpos_3+2

	lda ball_ypos_1
	sta ball_ypos_1+1
	sta ball_ypos_1+2
	lda ball_ypos_2
	sta ball_ypos_2+1
	sta ball_ypos_2+2
	lda ball_ypos_3
	sta ball_ypos_3+1
	sta ball_ypos_3+2

	lda ball_rxpos
	sta ball_rxpos+1
	sta ball_rxpos+2
	lda ball_rypos
	sta ball_rypos+1
	sta ball_rypos+2
	lda old_ball_rypos
	sta old_ball_rypos+1
	sta old_ball_rypos+2

	rts


;================================================================================

; this is used to set the direction of the new balls when using a multi ball powerup
SetDirectionForNewBalls
; 	lda ball_xstep_1
; 	sec
; 	sbc #16
; 	sta ball_xstep_1+1
;
; 	lda ball_xstep_1
; 	clc
; 	adc #16
; 	sta ball_xstep_1+2

	/*lda ball_xstep_1
	cmp tab_pad_xstep1
	bne SDFNB_check_second_step

	lda tab_pad_xstep1+1		; set X step for ball 2
	sta ball_xstep_1+1
	lda tab_pad_xstep2+1
	sta ball_xstep_2+1
	lda tab_pad_ystep1+1		; set Y step for ball 2
	sta ball_ystep_1+1
	lda tab_pad_ystep2+1
	sta ball_ystep_2+1

	lda tab_pad_xstep1+2		; set X step for ball 3
	sta ball_xstep_1+2
	lda tab_pad_xstep2+2
	sta ball_xstep_2+2
	lda tab_pad_ystep1+2		; set Y step for ball 3
	sta ball_ystep_1+2
	lda tab_pad_ystep2+2
	sta ball_ystep_2+2

	jmp SDFNB_end_check_step

SDFNB_check_second_step
	cmp tab_pad_xstep1+1
	bne SDFNB_is_third_step

	lda tab_pad_xstep1			; set X step for ball 2
	sta ball_xstep_1+1
	lda tab_pad_xstep2
	sta ball_xstep_2+1
	lda tab_pad_ystep1			; set Y step for ball 2
	sta ball_ystep_1+1
	lda tab_pad_ystep2
	sta ball_ystep_2+1

	lda tab_pad_xstep1+2		; set X step for ball 3
	sta ball_xstep_1+2
	lda tab_pad_xstep2+2
	sta ball_xstep_2+2
	lda tab_pad_ystep1+2		; set Y step for ball 3
	sta ball_ystep_1+2
	lda tab_pad_ystep2+2
	sta ball_ystep_2+2

	jmp SDFNB_end_check_step

SDFNB_is_third_step
	lda tab_pad_xstep1			; set X step for ball 2
	sta ball_xstep_1+1
	lda tab_pad_xstep2
	sta ball_xstep_2+1
	lda tab_pad_ystep1			; set Y step for ball 2
	sta ball_ystep_1+1
	lda tab_pad_ystep2
	sta ball_ystep_2+1

	lda tab_pad_xstep1+1		; set X step for ball 3
	sta ball_xstep_1+2
	lda tab_pad_xstep2+1
	sta ball_xstep_2+2
	lda tab_pad_ystep1+1		; set Y step for ball 3
	sta ball_ystep_1+2
	lda tab_pad_ystep2+1
	sta ball_ystep_2+2

SDFNB_end_check_step
	rts*/

; use 20 degrees for the first
	lda tab_pad_xstep1+0
	sta ball_xstep_1
	lda tab_pad_xstep2+0
	sta ball_xstep_2

	lda tab_pad_ystep1+0
	sta ball_ystep_1
	lda tab_pad_ystep2+0
	sta ball_ystep_2

; use 45 degrees for the second
	lda tab_pad_xstep1+2
	sta ball_xstep_1+1
	lda tab_pad_xstep2+2
	sta ball_xstep_2+1

	lda tab_pad_ystep1+2
	sta ball_ystep_1+1
	lda tab_pad_ystep2+2
	sta ball_ystep_2+1

; use 70 degrees for the third
	lda tab_pad_xstep1+4
	sta ball_xstep_1+2
	lda tab_pad_xstep2+4
	sta ball_xstep_2+2

	lda tab_pad_ystep1+4
	sta ball_ystep_1+2
	lda tab_pad_ystep2+4
	sta ball_ystep_2+2

	rts


;================================================================================

; this is used to change the first ball angle, after too many hits without hitting the paddle (to avoid a possible loop)
ChangeFirstBallDirection
	lda ball_xstep_1
	cmp tab_pad_xstep1
	bne CFBD_check_second_step

; if 20 use 45 degrees..
	lda tab_pad_xstep1+2
	sta ball_xstep_1
	lda tab_pad_xstep2+2
	sta ball_xstep_2

	lda tab_pad_ystep1+2
	sta ball_ystep_1
	lda tab_pad_ystep2+2
	sta ball_ystep_2

	rts


CFBD_check_second_step
	cmp tab_pad_xstep1+2
	bne CFBD_check_third_step

; if 45 use 70 degrees..
	lda tab_pad_xstep1+4
	sta ball_xstep_1
	lda tab_pad_xstep2+4
	sta ball_xstep_2

	lda tab_pad_ystep1+4
	sta ball_ystep_1
	lda tab_pad_ystep2+4
	sta ball_ystep_2

	rts


CFBD_check_third_step
	cmp tab_pad_xstep1+4
	bne CFBD_check_forth_step

; if 70 use 32.5 degrees..
	lda tab_pad_xstep1+1
	sta ball_xstep_1
	lda tab_pad_xstep2+1
	sta ball_xstep_2

	lda tab_pad_ystep1+1
	sta ball_ystep_1
	lda tab_pad_ystep2+1
	sta ball_ystep_2

	rts


CFBD_check_forth_step
	cmp tab_pad_xstep1+1
	bne CFBD_is_fifth_step

; if 32.5 use 57.5 degrees..
	lda tab_pad_xstep1+3
	sta ball_xstep_1
	lda tab_pad_xstep2+3
	sta ball_xstep_2

	lda tab_pad_ystep1+3
	sta ball_ystep_1
	lda tab_pad_ystep2+3
	sta ball_ystep_2

	rts


CFBD_is_fifth_step
; if 57.5 use 20 degrees..
	lda tab_pad_xstep1+0
	sta ball_xstep_1
	lda tab_pad_xstep2+0
	sta ball_xstep_2

	lda tab_pad_ystep1+0
	sta ball_ystep_1
	lda tab_pad_ystep2+0
	sta ball_ystep_2

	rts


;================================================================================

	icl "pad_ball.asm"


;================================================================================

	icl "pad_bricks.asm"


;================================================================================

	icl "pad_bonus.asm"


;================================================================================

UpdateSpriteBall1
	lda bonus_flag
	bne USB1_plain_ball

	lda m_numberOfBallsInPlay
	cmp #1
	bne USB1_plain_ball


; 	ldy old_ball_rypos		; multiball code change
; 	lda #0
; 	ldx #BALL_SIZEY
; db1	sta p0_adr+PM_OFFSET_Y,y
; 	sta p1_adr+PM_OFFSET_Y,y
; 	iny
; 	dex
; 	bne db1
;
; 	ldy ball_rypos			; multiball code change
; db2	lda TabBallShape1,x
; 	sta p0_adr+PM_OFFSET_Y,y
; 	lda TabBallShape2,x
; 	sta p1_adr+PM_OFFSET_Y,y
; 	iny
; 	inx
; 	cpx #BALL_SIZEY
; 	bne db2
;
; 	rts
;
;
; db3	ldy old_ball_rypos		; multiball code change
; 	lda #0
; 	ldx #BALL_SIZEY
; db4	sta p0_adr+PM_OFFSET_Y,y
; 	iny
; 	dex
; 	bne db4
;
; 	ldy ball_rypos		 	; multiball code change
; db5	lda TabBallShape1,x
; 	sta p0_adr+PM_OFFSET_Y,y
; 	iny
; 	inx
; 	cpx #BALL_SIZEY
; 	bne db5


	ldy old_ball_rypos
	jsr EraseFullBall1

	ldy ball_rypos
	jsr DrawFullBall1

	rts


USB1_plain_ball
	ldy old_ball_rypos
	jsr EraseBall1

	ldy ball_rypos
	jsr DrawBall1

	rts


UpdateSpriteBall2
	ldy old_ball_rypos+1
	jsr EraseBall2

	ldy ball_rypos+1
	jsr DrawBall2

	rts


UpdateSpriteBall3
	ldy old_ball_rypos+2
	jsr EraseBall3

	ldy ball_rypos+2
	jsr DrawBall3

	rts


;-------------------------------

EraseFullBall1
	lda #0

	.rept 6
	sta p0_adr+PM_OFFSET_Y+#,y
	sta p1_adr+PM_OFFSET_Y+#,y
	.endr

	rts


DrawFullBall1
	.rept 6
	lda TabBallShape1+#
	sta p0_adr+PM_OFFSET_Y+#,y
	lda TabBallShape2+#
	sta p1_adr+PM_OFFSET_Y+#,y
	.endr

	rts


;-------------------------------

EraseBall1
	lda #0
	:6 sta p0_adr+PM_OFFSET_Y+#,y

	rts


DrawBall1
	.rept 6
	lda TabBallShape1+#
	sta p0_adr+PM_OFFSET_Y+#,y
	.endr

	rts


;-------------------------------

EraseBall2
	lda #0
	:6 sta p1_adr+PM_OFFSET_Y+#,y

	rts


DrawBall2
	.rept 6
	lda TabBallShape1+#
	sta p1_adr+PM_OFFSET_Y+#,y
	.endr

	rts


;-------------------------------

EraseBall3
	lda #0
	:6 sta p2_adr+PM_OFFSET_Y+#,y

	rts


DrawBall3
	.rept 6
	lda TabBallShape1+#
	sta p2_adr+PM_OFFSET_Y+#,y
	.endr

	rts


;-------------------------------

.if .def USE_ENEMY_CODE

; TabEnemyShapeP3	(X, Y+7, L:5)
; TabEnemyShapeM3M2M1 (X+3, Y, L:14)

EraseEnemy1
	lda #0

	:5 sta p3_adr+7+#,y

	:14 sta m0_adr+#,y

	rts


DrawEnemy1
	.rept 5
		lda TabEnemyShapeP3+#
		sta p3_adr+7+#,y
	.endr

	lda TabEnemyShapeM3M2M1+0
	sta m0_adr+0,y
	// lda TabEnemyShapeM3M2M1+1
	// sta m0_adr+1,y
	// lda TabEnemyShapeM3M2M1+2
	// sta m0_adr+2,y
	// lda TabEnemyShapeM3M2M1+3
	// sta m0_adr+3,y
	// lda TabEnemyShapeM3M2M1+4
	// sta m0_adr+4,y
	// lda TabEnemyShapeM3M2M1+5
	// sta m0_adr+5,y
	// lda TabEnemyShapeM3M2M1+6
	// sta m0_adr+6,y
	// lda TabEnemyShapeM3M2M1+7
	// sta m0_adr+7,y
	lda TabEnemyShapeM3M2M1+8
	sta m0_adr+8,y
	lda TabEnemyShapeM3M2M1+9
	sta m0_adr+9,y
	lda TabEnemyShapeM3M2M1+10
	sta m0_adr+10,y
	lda TabEnemyShapeM3M2M1+11
	sta m0_adr+11,y
	lda TabEnemyShapeM3M2M1+12
	sta m0_adr+12,y
	lda TabEnemyShapeM3M2M1+13
	sta m0_adr+13,y

; the animation frames overwrite only some bytes
	ldx m_enemy1AnimIndex
	lda TabEnemyAnimM3M2M1_LSB,x
	sta DrawEnemy1_loop+1
	lda TabEnemyAnimM3M2M1_MSB,x
	sta DrawEnemy1_loop+2

	/*ldx #ENEMY1_ANIM1_FRAME_SIZE

// this doesn't work for y < ENEMY1_ANIM1_FRAME_SIZE (7) .. at some point y is going to be < 0 (and that is not -1, but 255!)
DrawEnemy1_loop
	lda $FFFF,x
	sta m0_adr+ENEMY1_ANIM1_FRAME_SIZE,y
	dey
	dex
	bne DrawEnemy1_loop*/

	ldx #0
	iny		// animation data starts at second line of the enemy

DrawEnemy1_loop
	lda $FFFF,x
	sta m0_adr,y
	iny
	//beq _exit		// add this if needed, to not wrap around at the bottom
	inx
	cpx #ENEMY1_ANIM1_FRAME_SIZE
	bne DrawEnemy1_loop

	rts


EraseExplosion1
	lda #0

	:EXPLOSION1_ANIM1_FRAME_SIZE sta p3_adr+#,y

	:EXPLOSION1_ANIM1_FRAME_SIZE sta m0_adr+#,y

	rts

DrawExplosion1
	ldx m_enemy1AnimIndex

	lda TabExplosionAnimP3_LSB,x
	sta DrawExplosion1_loop+1
	lda TabExplosionAnimP3_MSB,x
	sta DrawExplosion1_loop+2

	lda TabExplosionAnimM3M2M1_LSB,x
	sta DrawExplosion1_m0+1
	lda TabExplosionAnimM3M2M1_MSB,x
	sta DrawExplosion1_m0+2

	/*ldx #EXPLOSION1_ANIM1_FRAME_SIZE

// this doesn't work for y < EXPLOSION1_ANIM1_FRAME_SIZE (22) .. at some point y is going to be < 0 (and that is not -1, but 255!)
DrawExplosion1_loop
	lda $FFFF,x
	sta p3_adr+EXPLOSION1_ANIM1_FRAME_SIZE-1,y

DrawExplosion1_m0
	lda $FFFF,x
	sta m0_adr+EXPLOSION1_ANIM1_FRAME_SIZE-1,y

	dey
	dex
	bne DrawExplosion1_loop*/

	ldx #0

DrawExplosion1_loop
	lda $FFFF,x
	sta p3_adr,y

DrawExplosion1_m0
	lda $FFFF,x
	sta m0_adr,y

	iny
	//beq _exit		// add this if needed, to not wrap around at the bottom
	inx
	cpx #EXPLOSION1_ANIM1_FRAME_SIZE
	bne DrawExplosion1_loop

	rts

.endif


;================================================================================
;================================================================================

	icl "pad_vbi.asm"


;================================================================================

	icl "pad_dli.asm"


;================================================================================

; DisplayBallSteps
; 	ldx m_ballStepsInFrame
; 	ldy #9
; 	jsr DisplayInfoByte99
;
; 	lda #0
; 	sta m_ballStepsInFrame
;
; 	rts
;
;
; m_ballStepsInFrame		.byte 0


;================================================================================

DisplayLives
	ldx m_numberOfBallsLeft
	ldy #28
	jmp DisplayInfoByte99

	;rts


;================================================================================

IncreaseBallsInHud
	ldx m_ballNumHud
	cpx #MAX_BALLS_IN_HUD		; show a max of 10 balls in the left column
	beq IBIH_exit

	inc m_ballNumHud

	lda TabDL1LineAddressInverse_LSB,x
	sta IBIH_pointer+1
	lda TabDL1LineAddressInverse_MSB,x
	sta IBIH_pointer+2

	lda #BALL_CHAR
IBIH_pointer
	sta $FFFF

IBIH_exit
	rts


DecreaseBallsInHud
	ldx m_ballNumHud
	beq DBIH_exit

	dex
	stx m_ballNumHud

	lda TabDL1LineAddressInverse_LSB,x
	sta DBIH_pointer+1
	lda TabDL1LineAddressInverse_MSB,x
	sta DBIH_pointer+2

	lda #BLANK_CHAR
DBIH_pointer
	sta $FFFF

DBIH_exit
	rts


ClearAllBallsInHud
	ldx #0

CABIH_loop
	lda TabDL1LineAddressInverse_LSB,x
	sta CABIH_pointer+1
	lda TabDL1LineAddressInverse_MSB,x
	sta CABIH_pointer+2

	lda #BLANK_CHAR
CABIH_pointer
	sta $FFFF

	inx
	cpx #MAX_BALLS_IN_HUD
	bne CABIH_loop

	rts


;================================================================================
; this one use the decimal flag mode for the score
; pass in X the low byte of the score (BCD)
; pass in Y the high (middle) byte of the score (BCD)

AddScore

; this is also to check if we crossed the 20000 score barrier, to give an extra player
	lda m_playerScore+1
	sta m_tempScore


	txa
	clc
	sed		; remember: just because of this we need to use "cld" in every DLI

	adc m_playerScore
	sta m_playerScore

	tya
	adc m_playerScore+1
	sta m_playerScore+1

	lda m_playerScore+2
	adc #0
	sta m_playerScore+2

	cld

; this is to check if we crossed the 20000 score barrier, to give an extra player
	lda m_tempScore
	cmp #$20
	bcs AS_exit			; old score >= 20000
	lda m_playerScore+1
	cmp #$20
	bcc AS_exit			; new score < 20000

	inc m_numberOfBallsLeft
	jsr IncreaseBallsInHud

	;jsr DisplayLives

	jsr PlayExtraLifeSound


AS_exit
	;jmp DisplayScore

	rts


;================================================================================

DisplayScore
	lda m_playerScore
	ldy #13
	jsr DisplayDebugInfoHexFF

	lda m_playerScore+1
	ldy #11
	jsr DisplayDebugInfoHexFF

	lda m_playerScore+2
	ldy #9
	jmp DisplayDebugInfoHexFF

	;rts


;================================================================================

DisplaySessionScore
	lda m_sessionHighScore
	jsr GetDebugInfoHexFF

	ldy #16
	lda m_leftDigit
	sta DL2_score_line,y
	lda m_rightDigit
	sta DL2_score_line+1,y

	lda m_sessionHighScore+1
	jsr GetDebugInfoHexFF

	ldy #14
	lda m_leftDigit
	sta DL2_score_line,y
	lda m_rightDigit
	sta DL2_score_line+1,y

	lda m_sessionHighScore+2
	jsr GetDebugInfoHexFF


; don't display both high digits if they are 0
	lda m_leftDigit
	clc
	adc m_rightDigit
	cmp #["0"+"0"]
	beq DSS_exit

; don't display high digit if it is 0
	ldy #12
	lda m_leftDigit
	cmp #"0"
	beq DSS_skip_high_digit
	sta DL2_score_line,y

DSS_skip_high_digit
	lda m_rightDigit
	sta DL2_score_line+1,y


; second method, erase after
; 	ldy #12
; 	lda m_leftDigit
; 	sta DL2_score_line,y
; 	lda m_rightDigit
; 	sta DL2_score_line+1,y
;
; ; erase the chars that are equal to zero
; 	ldx #" "
; 	lda #"0"
;
; 	cmp DL2_score_line+12
; 	bne DSS_exit
; 	stx DL2_score_line+12
;
; 	cmp DL2_score_line+12+1
; 	bne DSS_exit
; 	stx DL2_score_line+12+1


DSS_exit
	rts


DisplayHighScoreLevel
	lda m_levelIndex
	asl				; x2, the level has two chars for description
	tax

	lda m_difficultyIndex
	cmp #3	; "extra" game mode
	bcs DHSL_extra_level

	lda TabLevelName,x
	sta DL2_score_line+25
	lda TabLevelName+1,x
	sta DL2_score_line+26

	rts

DHSL_extra_level
	lda TabLevelNameExtra,x
	sta DL2_score_line+25
	lda TabLevelNameExtra+1,x
	sta DL2_score_line+26

	rts


DisplayLastScore
	lda m_playerScore
	jsr GetDebugInfoHexFF

	ldy #6
	lda m_leftDigit
	sta DL2_score_line,y
	lda m_rightDigit
	sta DL2_score_line+1,y

	lda m_playerScore+1
	jsr GetDebugInfoHexFF

	ldy #4
	lda m_leftDigit
	sta DL2_score_line,y
	lda m_rightDigit
	sta DL2_score_line+1,y

	lda m_playerScore+2
	jsr GetDebugInfoHexFF

	ldy #2
	lda m_leftDigit
	sta DL2_score_line,y
	lda m_rightDigit
	sta DL2_score_line+1,y


; check and erase zeros for the first 5 digits
	ldx #" "
	lda #"0"

	cmp DL2_score_line+2
	bne DLS_exit
	stx DL2_score_line+2

	cmp DL2_score_line+2+1
	bne DLS_exit
	stx DL2_score_line+2+1

	cmp DL2_score_line+2+2
	bne DLS_exit
	stx DL2_score_line+2+2

	cmp DL2_score_line+2+3
	bne DLS_exit
	stx DL2_score_line+2+3

	cmp DL2_score_line+2+4
	bne DLS_exit
	stx DL2_score_line+2+4


DLS_exit
	rts


;================================================================================
; display 2 digits with values from 00 to 99
; pass the value in X and the line row in Y

DisplayInfoByte99

; add this check only if we are not sure about the values
	cpx #100
	bcc NoOverflow
	ldx #99
NoOverflow

	lda TabBinaryToBCD,x
	tax

; display 2 digits
	lsr
	lsr
	lsr
	lsr
	ora #16			; add the "0" character value
	sta DLInfoLine,y

	txa
	and #15
	ora #16			; add the "0" character value
	sta DLInfoLine+1,y

	rts


;================================================================================
; display 2 digits with values from 00 to FF
; pass the value in A and the line row in Y

DisplayDebugInfoHexFF
	sta DDIH_save_value+1

; display 2 digits (from 0 to F)
	lsr
	lsr
	lsr
	lsr
	tax
	lda TabHexNibbleToScreenDigit,x
	sta DLInfoLine,y

DDIH_save_value
	lda #$FF

	and #15
	tax
	lda TabHexNibbleToScreenDigit,x
	sta DLInfoLine+1,y

	rts


;================================================================================
; get 2 digits with values from 00 to FF
; pass the value in A
; return digits in m_leftDigit and m_rightDigit

GetDebugInfoHexFF
	tay

; display 2 digits (from 0 to F)
	lsr
	lsr
	lsr
	lsr
	tax
	lda TabHexNibbleToScreenDigit,x
	sta m_leftDigit

	tya

	and #15
	tax
	lda TabHexNibbleToScreenDigit,x
	sta m_rightDigit

	rts


;================================================================================

START_LEVELS_AREA
	icl "padlvls.asm"

END_LEVELS_AREA


;================================================================================

; align to the start of a page
?currentAddress = *
.if ((<?currentAddress) != 0)
	?currentAddress = ?currentAddress/256
	?currentAddress = ?currentAddress*256+256
	org ?currentAddress
.endif

START_TABLES_AREA
	icl "padtabs.asm"


;================================================================================

END_CODE_AREA
	.if END_CODE_AREA > DL1_address
		.error "over limit DL1_address"
	.endif

;================================================================================

	org DL1_address

	.byte DL_BLANK_4+DL_DLI_MASK

	.byte GM_CHAR_A4+DL_LMS_MASK+DL_DLI_MASK
	.word DL1_data_address

	:18 .byte GM_CHAR_A4+DL_DLI_MASK		; dli's for the 18 lines of bricks

.if .def PAL_VERSION
	.byte GM_CHAR_A4+DL_DLI_MASK			; extra dli's to read the mouse
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4+DL_DLI_MASK
.else
	.byte GM_CHAR_A4+DL_DLI_MASK			; extra dli's to read the mouse
	.byte GM_CHAR_A4
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4
	.byte GM_CHAR_A4+DL_DLI_MASK
	.byte GM_CHAR_A4
	.byte GM_CHAR_A4+DL_DLI_MASK
.endif

	.byte GM_CHAR_A4+DL_DLI_MASK			; dli for the paddle colors
	.byte GM_CHAR_A4

; 	.byte GM_CHAR_G0+DL_LMS_MASK
; 	.word DLInfoLine

	.byte DL_JVB
	.word DL1_address


;----------------------------------------
; tittle screen display list
DL2_address
	:2 .byte DL_BLANK_8
	.byte DL_BLANK_8+DL_DLI_MASK

	.byte GM_CHAR_G0+DL_LMS_MASK			; score text
	.word DL2_data_address
	.byte GM_CHAR_G0					; score values

	:4 .byte DL_BLANK_8
	.byte DL_BLANK_8+DL_DLI_MASK

	.byte GM_CHAR_G0					; name
	.byte DL_BLANK_8
	.byte DL_BLANK_8+DL_DLI_MASK
	.byte GM_CHAR_G0					; music

	:3 .byte DL_BLANK_8
	.byte DL_BLANK_8+DL_DLI_MASK

	.byte GM_CHAR_G0+DL_LMS_MASK+DL_DLI_MASK	; options 1
	.word DL2_options_line
	.byte DL_BLANK_4
	.byte GM_CHAR_G0+DL_LMS_MASK+DL_DLI_MASK	; options 2
	.word DL2_options_line+BYTES_LINE
	.byte DL_BLANK_4

	.byte GM_CHAR_G0+DL_LMS_MASK+DL_DLI_MASK	; options 3
DL2_LMS_options_line3
	.word DL2_options_line+BYTES_LINE*2
	.byte DL_BLANK_4
	.byte GM_CHAR_G0+DL_LMS_MASK+DL_DLI_MASK	; options 4
	.word DL2_options_line+BYTES_LINE*3
	.byte DL_BLANK_4

	:2 .byte DL_BLANK_8

	.byte GM_CHAR_G0+DL_LMS_MASK			; credits
	.word DL2_credits_line

	.byte DL_JVB
	.word DL2_address


;----------------------------------------
DL2_data_address
	.sb "     1UP   HIGH SCORE  LEVEL    "
DL2_score_line
	;.sb "       00     10000      1A     "
	.sb "       00     20000      A1     "

.if .def PAL_VERSION
	.sb " PAD 1.84 PAL     NRV 1995-2018 "
.else
	.sb " PAD 1.84 NTSC    NRV 1995-2018 "
.endif

	;.sb "       Insert coin & play!      "
	.sb "         Music by MIKER!        "

DL2_options_line
	.sb "       ","G"+128,"ame mode: Extra         "
	;.sb "       ","D"+128,"ifficulty: Casual       "
	;.sb "       ","V"+128,"aus type: Normal        "
	.sb "       ","C"+128,"ontroller: Atari        "
	.sb "       ","M"+128,"ouse max step: 2        "
	.sb "       ","S"+128,"tarting level: A1       "
	.sb "       ","P"+128,"addle angle: 100%       "

DL2_credits_line
	.sb "                    CREDIT  1   "


DLInfoLine
	;.sb "  steps: 00                     "
	.sb "  score: 0000000     lives: 00  "


Text_difficulty1
	.sb "Easy  "

Text_difficulty2
	.sb "Casual"

Text_difficulty3
	.sb "Arcade"

Text_difficulty4
	.sb "Extra "


; Text_vaus_type1
; 	.sb "Normal"
;
; Text_vaus_type2
; 	.sb "Smooth"


Text_controller_type1
	.sb "Atari   "

Text_controller_type2
	.sb "Amiga   "

Text_controller_type3
	.sb "Atari P2"

Text_controller_type4
	.sb "Amiga P2"

Text_controller_type5
	.sb "Paddle 1"

Text_controller_type6
	.sb "Paddle 2"

Text_controller_type7
	.sb "Paddle 3"

Text_controller_type8
	.sb "Paddle 4"


Text_paddle_angle1
	.sb "25% "

Text_paddle_angle2
	.sb "50% "

Text_paddle_angle3
	.sb "75% "

Text_paddle_angle4
	.sb "100%"


Tab_score_line_easy
	.sb "       00     10000      1A     "

Tab_score_line_casual
	.sb "       00     10000      1A     "

Tab_score_line_arcade
	.sb "       00     50000      1A     "

Tab_score_line_extra
	.sb "       00     20000      A1     "

TabHighScoreEasy
	.byte $00, $10, $00
TabHighLevelEasy
	.byte 0

TabHighScoreCasual
	.byte $00, $10, $00
TabHighLevelCasual
	.byte 0

TabHighScoreArcade
	.byte $00, $50, $00
TabHighLevelArcade
	.byte 0

TabHighScoreExtra
	.byte $00, $20, $00
TabHighLevelExtra
	.byte 0


;----------------------------------------
DL_NTSC_address
	:7 .byte DL_BLANK_8

	.byte GM_CHAR_G0+DL_LMS_MASK
DL_NTSC_message
	.word DL_NTSC_data_address

	.byte DL_JVB
	.word DL_NTSC_address

DL_NTSC_data_address
	.sb "      NEEDS A NTSC SYSTEM!      "


/*DL_PAL_address
	:7 .byte DL_BLANK_8

	.byte GM_CHAR_G0+DL_LMS_MASK
	.word DL_PAL_data_address

	.byte DL_JVB
	.word DL_PAL_address*/

DL_PAL_data_address
	.sb "      NEEDS A PAL SYSTEM!       "

; beware, this area is almost full

;================================================================================

END_DL_AREA
	.if END_DL_AREA > m0_adr
		.error "over limit m0_adr"
	.endif

;================================================================================

	org PM_zone_address

m0_adr = PM_zone_address+768

p0_adr = m0_adr+256
p1_adr = p0_adr+256
p2_adr = p1_adr+256
p3_adr = p2_adr+256


;================================================================================

	org DL1_data_address

	ins "data/padmap2.raw"


;================================================================================

	org Atari_font_address

	ins "data/atari.fnt"


;================================================================================

	org Font1_address

	ins "data/pad2.fnt"


;================================================================================

	org Font_background_address

	ins "data/padbkg1b.fnt"
	ins "data/padbkg2.fnt"


;================================================================================

	.print "------------------------------------------------------------"
	.print "Vars area: ", Vars_address, " [", END_VARS_AREA-Vars_address, "] (free: ", Static_vars_address-END_VARS_AREA,")"
	.print "Static vars area: ", Static_vars_address, " [", END_STATIC_VARS_AREA-Static_vars_address, "] (free: ", RMT_vars_address-END_STATIC_VARS_AREA,")"
	.print " "
	.print "RMT song: ", RMT_song_address, " [", END_RMT_SONG_AREA-RMT_song_address, "]"
	.print "RMT player: ", RMT_address, " [", END_RMT_PLAYER_AREA-RMT_address, "]"
	.print " "
	.print "Code area: ", Prog_start, " [", START_LEVELS_AREA-Prog_start, "]"
	.print "Levels area: ", START_LEVELS_AREA, " [", END_LEVELS_AREA-START_LEVELS_AREA, "]"
	.print "Tables area: ", START_TABLES_AREA, " [", END_CODE_AREA-START_TABLES_AREA, "]"
	.print " "
	.print "DL area: ", DL1_address, " [", END_DL_AREA-DL1_address, "]"
	.print "------------------------------------------------------------"
	.print " "


;================================================================================

	org $02e0
	.word Prog_start




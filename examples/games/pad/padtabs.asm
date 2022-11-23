
; tables to get the low and high nibble of a byte (256 bytes each)
TabGetLowNibble
	.rept 16
		:16 .byte #
	.endr

TabGetHighNibble
	?nibbleValue = 0
	.rept 16
		:16 .byte ?nibbleValue
		?nibbleValue ++
	.endr


; tables to convert a paddle value to a position in X (256 bytes each)
; GAME_AREA_SIZEX = 104 , paddle values: 228 --> 0 (from left to right) (255..229 [27])
; paddle xor 255: 27 --> 255 (from left to right) (0..26 [27])

; TabPaddleConversionPercent100
; 	:27 .byte 0
; 	:10 .byte 0
; 	:104 .byte #, #		; 208 useful values (null: 48)
; 	:11 .byte 255

TabPaddleConversionPercent75		; non linear
	:27 .byte 0
	:36 .byte 0
	:52 .byte #*2, #*2+1, #*2+1	; 104+52 useful values (null: 100)
	:37 .byte 255

; TabPaddleConversionPercent50
; 	:27 .byte 0
; 	:62 .byte 0
; 	:104 .byte #			; 104 useful values (null: 152)
; 	:63 .byte 255

TabPaddleConversionPercent25		; miss odd values
	:27 .byte 0
	:88 .byte 0
	:52 .byte #*2			; 52 useful values (null: 204)
	:89 .byte 255


; (100 bytes)
TabBinaryToBCD
	.byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
	.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
	.byte $20, $21, $22, $23, $24, $25, $26, $27, $28, $29
	.byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39
	.byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49
	.byte $50, $51, $52, $53, $54, $55, $56, $57, $58, $59
	.byte $60, $61, $62, $63, $64, $65, $66, $67, $68, $69
	.byte $70, $71, $72, $73, $74, $75, $76, $77, $78, $79
	.byte $80, $81, $82, $83, $84, $85, $86, $87, $88, $89
	.byte $90, $91, $92, $93, $94, $95, $96, $97, $98, $99


TabHexNibbleToScreenDigit
	.sb "0123456789ABCDEF"


; tab_conv_mov
;     .byte 0,0,4,8,0,0,4,8
;     .byte 1,1,5,9,2,2,6,10

; TabMouseMoveX
; 	.byte 0,8,4,0, 4,0,0,8, 8,0,0,4, 0,4,8,0

TabNextValueMovingRight
	.byte %10, %00, %11, %01

TabNextValueMovingRightAmiga		; for the Amiga mouse (needs 11 values, max = %1010)
	.byte %0010, %0000, %1010, %0000, %0000, %0000, %0000, %0000
	.byte %0000, %0000, %1000

TabNextValueMovingLeft
	.byte %01, %11, %00, %10

TabNextValueMovingLeftAmiga		; for the Amiga mouse (needs 11 values, max = %1010)
	.byte %1000, %0000, %0000, %0000, %0000, %0000, %0000, %0000
	.byte %1010, %0000, %0010


; (beware that 18*15 goes over one byte, but not 18*13)
TabMulBricksInX
	:BOTTOM_BRICK_NUM .byte <[#*NUM_BRICKS_X]

TabMulBytesLineLSB
	:BOTTOM_BRICK_NUM .byte <[#*BYTES_LINE]
TabMulBytesLineMSB
	:BOTTOM_BRICK_NUM .byte >[#*BYTES_LINE]


TabBallShape1
	.byte %01000000
	.byte %11100000
	.byte %11100000
	.byte %11100000
	.byte %11100000
	.byte %01000000

TabBallShape2
	.byte %10100000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10100000

; TabCurrentPadShape
; 	:PAD_SIZEY .byte 0

TabNormalPadShape		; 8 double pixels (16)
	.byte %11111111,%11111111,%11111111,%11111111,%11111111,%11111111
TabSmallPadShape		; 4 double pixels (8)
	.byte %11110000,%11110000,%11110000,%11110000,%11110000,%11110000
TabLargePadShape		; 6 quad pixels (24)
	.byte %11111100,%11111100,%11111100,%11111100,%11111100,%11111100

TabCurrentPadColor
	:PAD_SIZEY .byte 0

.if .def PAL_VERSION
TabNormalPadColor
	;.by +$B0, 10,12,14,12,10,8
	.byte $BA, $BC, $BE, $BC, $BA, $A8
TabSmallPadColor
	;.by +$20, 10,12,14,12,10,8
	.byte $2A, $2C, $2E, $2C, $2A, $38
TabLargePadColor
	;.by +$80, 10,12,14,12,10,8
	.byte $8A, $8C, $8E, $8C, $8A, $98

.else

TabNormalPadColor
	;.by +$C0, 10,12,14,12,10,8
	.byte $CA, $CC, $CE, $CC, $CA, $B8
TabSmallPadColor
	;.by +$30, 10,12,14,12,10,8
	.byte $3A, $3C, $3E, $3C, $3A, $48
TabLargePadColor
	;.by +$90, 10,12,14,12,10,8
	.byte $9A, $9C, $9E, $9C, $9A, $A8
.endif

    ;.byte $06,$08,$0E,$08,$08,$06,$06		; arkanoid gray degradation (7 lines)


; the direction tables should have a size of (PAD_SIZEX + BALL_SIZEX + 1)
; tab_pad_xdir
;     .byte 1,1, 1,1,1,1, 1,1,1,1
;     .byte 2,2,2,2, 2,2,2,2, 2,2

TabCurrentPadAngleIndex
	:[PAD_LARGE_SIZEX+BALL_SIZEX+1] .byte 0

TabNormalPadAngleIndex
	;.byte 0,0, 0,1,1,1, 2,2,2,2
	;.byte 2,2,2,2, 1,1,1,0, 0,0
	.byte 0,0, 1,1,2,2, 3,3,4,4
	.byte 4,4,3,3, 2,2,1,1, 0,0

TabSmallPadAngleIndex
	;.byte 0,0, 1,1, 2,2
	;.byte 2,2, 1,1, 0,0
	.byte 0,0, 1,2, 3,4
	.byte 4,3, 2,1, 0,0

TabLargePadAngleIndex
	;.byte 0,0, 0,1,1,1,1, 2,2,2,2,2,2,2
	;.byte 2,2,2,2,2,2,2, 1,1,1,1,0, 0,0
	.byte 0,0, 0,1,1,1,2, 2,2,3,3,3,4,4
	.byte 4,4,3,3,3,2,2, 2,1,1,1,0, 0,0


; .if .def PAL_VERSION
; ; speed 156 in Y (in 2:1 pixels), angles 22.5, 45 and 67,5 (this is for PAL)
; tab_pad_xstep1
; 	.byte 72, 55, 29
; tab_pad_xstep2
; 	.byte 16, 40, 217
; tab_pad_ystep1
; 	.byte 59, 110, 144
; tab_pad_ystep2
; 	.byte 179, 79, 32
; 
; .else
; 
; ; speed 130 in Y (in 2:1 pixels), angles 22.5, 45 and 67,5 (this is for NTSC)
; tab_pad_xstep1
; 	.byte 60, 45, 24
; tab_pad_xstep2
; 	.byte 13, 246, 224
; tab_pad_ystep1
; 	.byte 49, 91, 120
; tab_pad_ystep2
; 	.byte 192, 237, 27
; .endif


.if .def PAL_VERSION
; speed 222 in Y (in 2:1 pixels), angles 20, 32.5, 45, 57.5 and 70 (this is for PAL)
; (or angles from 0.0 to 90.0, with a step of 2.5 degrees)
tab_pad_xstep1
	;.byte 102, 78, 42
	.byte $68, $5D, $4E, $3B, $25
	;.byte $6F,$6E,$6E,$6E,$6D, $6C,$6B,$69,$68, $66,$64,$62,$60, $5D,$5A,$58,$55, $51,$4E,$4A,$47, $43,$3F,$3B,$37, $33,$2E,$2A,$25, $21,$1C,$18,$13, $0E,$09,$04,$00
tab_pad_xstep2
	;.byte 141, 125, 122
	.byte $4E, $9E, $7D, $A4, $F7
	;.byte $00,$E5,$94,$0D,$50, $5E,$38,$DD,$4E, $8D,$9A,$75,$21, $9E,$ED,$10,$08, $D6,$7D,$FE,$59, $93,$AB,$A4,$80, $41,$E9,$7A,$F7, $61,$BB,$06,$46, $7D,$AD,$D7,$00
tab_pad_ystep1
	;.byte 84, 156, 205
	.byte $4B, $77, $9C, $BB, $D0
	;.byte $00,$09,$13,$1C,$26, $30,$39,$42,$4B, $54,$5D,$66,$6F, $77,$7F,$87,$8E, $95,$9C,$A3,$AA, $B0,$B5,$BB,$C0, $C4,$C9,$CD,$D0, $D3,$D6,$D8,$DA, $DC,$DD,$DD,$DE
tab_pad_ystep2
	;.byte 245, 250, 26
	.byte $EE, $48, $FA, $3C, $9D
	;.byte $00,$AF,$59,$FA,$8D, $0D,$75,$C2,$EE, $F5,$D2,$82,$00, $48,$55,$25,$B3, $FB,$FA,$AD,$10, $20,$DA,$3C,$42, $EB,$33,$1A,$9D, $BA,$6F,$BD,$A1, $1A,$28,$CA,$00

.else

; speed 185 in Y (in 2:1 pixels), angles 20, 32.5, 45, 57.5 and 70 (this is for NTSC)
; (or angles from 0.0 to 90.0, with a step of 2.5 degrees)
tab_pad_xstep1
	;.byte 85, 65, 35
	.byte $56, $4E, $41, $31, $23
	;.byte $5C,$5C,$5C,$5B,$5B, $5A,$59,$58,.$56, _$55,$53,$52,$50, .$4E,$4B,$49,$46, $44,_$41,$3E,$3B, $38,$35,.$31,$2E, $2A,$27,_$23,.$1F, $1B,$17,$14,$10, $0C,$08,$04,$00
tab_pad_xstep2
	;.byte 117, 104, 102
	.byte $EC, $04, $68, $B3, $A3
	;.byte $80,$69,$26,$B5,$18, $4F,$59,$38,.$EC, _$75,$D5,$0C,$1B, .$04,$C6,$63,$DC, $33,_$68,$7E,$75, $4F,$0E,.$B3,$40, $B6,$18,_$66,.$A3, $D1,$F1,$05,$10, $13,$10,$09,$00
tab_pad_ystep1
	;.byte 70, 130, 170
	.byte $3F, $63, $82, $9C, $AD
	;.byte $00,$08,$10,$18,$20, $28,$2F,$37,.$3F, _$46,$4E,$55,$5C, .$63,$6A,$70,$76, $7C,_$82,$88,$8D, $92,$97,.$9C,$A0, $A4,$A7,_$AA,.$AD, $B0,$B2,$B4,$B6, $B7,$B8,$B8,$B9
tab_pad_ystep2
	;.byte 204, 209, 235
	.byte $46, $67, $D1, $07, $D8
	;.byte $00,$12,$20,$26,$20, $0B,$E2,$A1,.$46, _$CC,$2F,$6C,$80, .$67,$1D,$9F,$EA, $FC,_$D1,$65,$B8, $C5,$8B,.$07,$37, $19,$AB,_$EB,.$D8, $70,$B2,$9D,$30, $6B,$4C,$D3,$00
.endif


; .if .def PAL_VERSION
; ; speed 252 in Y (in 2:1 pixels), angles 22.5, 45 and 67,5 (this is for PAL)
; .else
; ; speed 210 in Y (in 2:1 pixels), angles 22.5, 45 and 67,5 (this is for NTSC)
; .endif


; 8 chars for the background, plus 8 more for the shadow version
TabBackgroundCharDef
	.by +128, 0,2,4,6,8,10,12,14

; 15 different bricks, 30 chars
; current list:
; - dark blue [0]
; - grey [1]
; - white dli, white [2,3]
; - "checkered" dli, white [4,5]
; - "diagonal" dli, white [6,7]
; - "pad" dli, white [8,9]
; - black (empty) [10] ($A)
; - "hard" dli, white [11,12] ($B,$C)
; - "cross" dli, white [13,14] ($D,$E)

TabLeftBrickCharDef
	.by +0, 46+128, 48+128, 50,50+128, 52,52+128, 54,54+128, 56,56+128
	.by +0, 58, 70,70+128, 80,80+128
TabRightBrickCharDef
	.by +1, 46+128, 48+128, 50,50+128, 52,52+128, 54,54+128, 56,56+128
	.by +1, 58, 70,70+128, 80,80+128


tab_anim_lsb
	:MAX_ACTIVE_HIGHLIGHT_ANIMS .byte 0
tab_anim_msb
	:MAX_ACTIVE_HIGHLIGHT_ANIMS .byte 0
tab_anim_ctd
	:MAX_ACTIVE_HIGHLIGHT_ANIMS .byte 0
tab_anim_end
	:MAX_ACTIVE_HIGHLIGHT_ANIMS .byte 0


TabRestoreBrick_lsb
	:MAX_ACTIVE_RESTORE_BRICKS .byte 0
TabRestoreBrick_msb
	:MAX_ACTIVE_RESTORE_BRICKS .byte 0
TabRestoreBrick_idx
	:MAX_ACTIVE_RESTORE_BRICKS .byte 0
TabRestoreBrick_end
	:MAX_ACTIVE_RESTORE_BRICKS .byte 0


TabExitAnimationChar1
	.by +128, 110, 112, 114
TabExitAnimationChar2
	.by +128, 111, 113, 115

EXIT_ANIMATION_FRAMES = 3
.if .def PAL_VERSION
	EXIT_ANIMATION_TIME = 3
.else
	EXIT_ANIMATION_TIME = 3
.endif
	

tab_bonus_color
.if .def PAL_VERSION
	.byte $74,$8A,$06,$12,$1A,$56,$4A,$B8,$34		; bonus: E D P R S X(M) B C F
.else
	;.byte $84,$9A,$06,$C8,$28,$34,$5A				; bonus: E D P C S L B
	.byte $84,$9A,$06,$22,$2A,$66,$5A,$C8,$44		; bonus: E D P R S X(M) B C F
.endif

tab_bonus_lsb
	.byte <TabBonusShape_E, <TabBonusShape_D, <TabBonusShape_P, <TabBonusShape_R
	.byte <TabBonusShape_S, <TabBonusShape_X, <TabBonusShape_B, <TabBonusShape_C
	.byte <TabBonusShape_F
tab_bonus_msb
	.byte >TabBonusShape_E, >TabBonusShape_D, >TabBonusShape_P, >TabBonusShape_R
	.byte >TabBonusShape_S, >TabBonusShape_X, >TabBonusShape_B, >TabBonusShape_C
	.byte >TabBonusShape_F

tab_bonus_prob
	.byte 50
	.byte 50+40
	.byte 50+40+4
	.byte 50+40+4+51
	.byte 50+40+4+51+31
	.byte 50+40+4+51+31+6
	.byte 50+40+4+51+31+6+2
	.byte 50+40+4+51+31+6+2+51
	.byte 50+40+4+51+31+6+2+51+20		; this must add to 255

BONUS_TYPE_EXPAND = 1
BONUS_TYPE_DISRUPT = 2
BONUS_TYPE_PLAYER = 3
BONUS_TYPE_REDUCE = 4
BONUS_TYPE_SLOW = 5
BONUS_TYPE_MEGA = 6
BONUS_TYPE_BREAK = 7
BONUS_TYPE_CATCH = 8
BONUS_TYPE_FAST = 9
;BONUS_TYPE_LASER = 10


; arkanoid def: (probabilities distribution to fit in one byte: 256 = 42 x 6 + 4)
; (assuming the player and the break powerups have half the probability)

; E: enlarge, expand (normal size: 1.8x bricks, expanded: 2.8x bricks)
; D: disrupt (multi ball, x3) (cannot get other powerups while this is active)
; P: extra player
; C: capture ball, catch (when the pad moves the ball movement is "elastic")
; S: slow ball
; L: laser (2 groups of shots alive at the same time max, when one shot collides
;	the other one can destroy the brick at the side, but doesn't continue going up,
;	also if the powerup is changed the shots disappear in mid air)
; B: next board, break (exit appears at the right side, stays forever)

; arkanoid 2 adds:
; +B: break, open two exits (left and right)
; +D: disrupt, multi ball x8
; R: reduce pad to half size, score x2 (black)
; T: twin, two pads side by side (dark blue)
; I: illusion, ghost pads that follow the pad (dark green)
; N: new, splits ball x3 every time you lose one (light grey)
; M: mega, red ball that destroy every type of brick (purple)
; Flashing pill: 5 different effects

; don't throw the same bonus when that power is still active (E,C,S,L, maybe D)
; don't throw the same bonus two times in a row (?)

TabBonusShape_E
	.byte 255,%11000011,%11011111,%11000111,%11011111,%11011111,%11000011,255 ; "E"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11000011,%11011111,%11000111,%11011111,%11011111,%11000011
TabBonusShape_D
	.byte 255,%11000111,%11011011,%11011011,%11011011,%11011011,%11000111,255 ; "D"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11000111,%11011011,%11011011,%11011011,%11011011,%11000111
TabBonusShape_P
	.byte 255,199,219,219,199,223,223,255 ; "P"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,199,219,219,199,223,223
TabBonusShape_C
	.byte 255,%11100111,%11011011,%11011111,%11011111,%11011011,%11100111,255 ; "C"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11100111,%11011011,%11011111,%11011111,%11011011,%11100111
TabBonusShape_S
	.byte 255,%11100011,%11011111,%11100111,%11111011,%11011011,%11100111,255 ; "S"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11100011,%11011111,%11100111,%11111011,%11011011,%11100111
; TabBonusShape_L
; 	.byte 255,%11011111,%11011111,%11011111,%11011111,%11011111,%11000011,255 ; "L"
; 	.byte 255,255,255,255,255,255,255,255
; 	.byte 255,%11011111,%11011111,%11011111,%11011111,%11011111,%11000011
TabBonusShape_B
	.byte 255,199,219,199,219,219,199,255 ; "B"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,199,219,199,219,219,199

TabBonusShape_X
	.byte 255,219,219,231,231,219,219,255 ; "X"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,219,219,231,231,219,219
; TabBonusShape_J
; 	.byte 255,227,247,247,247,215,199,255 ; "J"
; 	.byte 255,255,255,255,255,255,255,255
; 	.byte 255,227,247,247,247,215,199

TabBonusShape_R
	.byte 255,%11000111,%11011011,%11011011,%11000111,%11011011,%11011011,255 ; "R"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11000111,%11011011,%11011011,%11000111,%11011011,%11011011
; TabBonusShape_M
; 	.byte 255,%10111011,%10010011,%10000011,%10101011,%10111011,%10111011,255 ; "M"
; 	.byte 255,255,255,255,255,255,255,255
; 	.byte 255,%10111011,%10010011,%10000011,%10101011,%10111011,%10111011
TabBonusShape_F
	.byte 255,%11000011,%11011111,%11000111,%11011111,%11011111,%11011111,255 ; "E"
	.byte 255,255,255,255,255,255,255,255
	.byte 255,%11000011,%11011111,%11000111,%11011111,%11011111,%11011111


tab_lsb_snd
	.byte  <snd_1, <snd_2, <snd_3, <snd_4, <snd_5
	.byte  <snd_6, <snd_7, <snd_8, <snd_9

tab_msb_snd
	.byte  >snd_1, >snd_2, >snd_3, >snd_4, >snd_5
	.byte  >snd_6, >snd_7, >snd_8, >snd_9

tab_snd_len
	;.byte 20,14,15,14,15
	.byte 17,14,15,14,15, 8,15,16,16

tab_snd_ctl
	;.byte 5,0,0,0,5
	.byte 4,0,0,0,4, 4,0,4,4

TabSoundPriority	; min priority should be 1 (0 would mean nothing is playing))
	.byte 1,1,1,1,1, 3,5,10,10
	
; AUDCTL: +1: 15KHz main clock, +4: high pass filter in channels 1+3 (+2: 2+4 channels)

snd_1		; hit pad
	;.by +70, 4,0,3,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
	;.by +$A0, 1,2,3,4,5,4,4,3,3,3,2,2,2,2,1,1,1,1,1,0
	.by +251, 4,0,3,0,2,0,1,0,1,0,1,0,1,0,1,0,0
	.by +$A0, 1,2,3,4,5,4,4,3,3,3,2,2,2,1,1,1,0

	;.by +66, 4,0,3,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
	;.by +$A0, 1,2,3,4,5,4,4,3,3,3,2,2,2,2,1,1,1,1,1,0
	.by +247, 4,0,3,0,2,0,1,0,1,0,1,0,1,0,1,0,0
	.by +$A0, 1,2,3,4,5,4,4,3,3,3,2,2,2,1,1,1,0

snd_2		; hit "easy"
	.by +75, 0,0,75,75,0,0,75,75,0,0,75,75,0,0
	.by +$A0, 5,11,9,7,6,5,4,4,3,2,2,1,1,0
	
	.by +75, 0,0,0,0,0,0,0,0,0,0,0,75,75,0
	.by +$A0, 0,0,0,0,0,0,0,0,0,1,3,2,1,0
	
snd_3		; hit "hard"
	.by +33, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.by +$A0, 9,7,6,6,5,5,4,4,3,3,2,2,1,1,0

	.by +22, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.by +$A0, 9,6,6,5,5,4,4,3,3,2,2,1,1,0,0

snd_4		; hit "cross 1" (unbreakable)
	.by +75, 0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.by +$A0, 9,6,4,3,3,2,2,1,3,2,2,1,1,0

	.by +60, 0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.by +$A0, 7,4,3,2,2,1,1,0,2,1,1,0,0,0

snd_5		; hit "gold" (restore brick)
	;.by +55, 0,1,2,3,2,3,2,1,0,1,2,3,2,1,0
	;.by +238, 0,4,8,13,8,13,8,4,0,4,8,13,8,4,0
	;.by +242, 0,4,8,13,8,13,8,4,0,4,8,13,8,4,0
	;.by +242, 0,2,4,6,4,6,4,2,0,2,4,6,4,2,0
	.by +249, 0,2,4,6,4,6,4,2,0,2,4,6,4,2,0
	.by +$A0, 6,8,7,7,6,6,5,5,4,4,3,3,2,1,0

	;.by +48, 0,1,2,3,2,3,2,1,0,1,2,3,2,1,0
	;.by +208, 0,4,9,13,9,13,9,4,0,4,9,13,9,4,0
	;.by +212, 0,4,9,13,9,13,9,4,0,4,9,13,9,4,0
	;.by +212, 0,2,4,6,4,6,4,2,0,2,4,6,4,2,0
	.by +219, 0,2,4,6,4,6,4,2,0,2,4,6,4,2,0
	.by +$A0, 3,5,5,4,4,3,3,2,2,1,1,1,1,1,0

snd_6		; get bonus
	.by +6, 7,6,5,4,3,2,1,0
	.by +$80, 2,4,5,4,3,2,1,0

	.by +240, 0,2,4,6,8,10,12,0,
	.by +$A0, 1,2,3,3,2,2,1,0

snd_7		; destroy enemy
	.by +128, 0,2,4,6,8,10,12,14,16,18,20,22,24,26,0
	.by +$00, 6,8,7,6,5,5,4,4,3,3,2,2,1,1,0

	.by +126, 0,2,4,6,8,10,12,14,16,18,20,22,24,26,0
	.by +$00, 3,5,5,4,3,3,2,2,1,1,1,1,1,1,0

snd_8		; extra life
	.by +22, 2,2,2,0,0,0,1,1,1,0,0,0,0,0,0,0
	.by +$A0, 5,6,5,0,0,0,4,5,4,0,0,0,3,4,3,0

	.by +20, 2,2,2,0,0,0,1,1,1,0,0,0,0,0,0,0
	.by +$A0, 5,6,5,0,0,0,4,5,4,0,0,0,3,4,3,0

snd_9		; ball lost (same as get life, change it!)
	.by +12, 1,1,1,0,0,0,7,7,7,0,0,0,14,14,14,0
	.by +$80, 7,6,5,0,0,0,6,5,4,0,0,0,5,4,3,0

	.by +10, 1,1,1,0,0,0,7,7,7,0,0,0,14,14,14,0
	.by +$80, 7,6,5,0,0,0,6,5,4,0,0,0,5,4,3,0
	

.if .def USE_ENEMY_CODE

; ordered by type: red, blue (purple), green
TabEnemyColor
.if .def PAL_VERSION
	.byte $36, $68, $B8
.else
	.byte $46, $78, $C8
.endif

TabEnemyTopLimit
	.byte ENEMY_LIMIT_BOTTOM-[30*2], [ENEMY_LIMIT_BOTTOM-8]-[32*2], [ENEMY_LIMIT_BOTTOM-16]-[28*2]
TabEnemyBottomLimit
	.byte ENEMY_LIMIT_BOTTOM, [ENEMY_LIMIT_BOTTOM-8], [ENEMY_LIMIT_BOTTOM-16]

TabEnemyHoverTime_LSB
	.byte <[4*FRAMES_ONE_SECOND/2], <[6*FRAMES_ONE_SECOND/2], <[8*FRAMES_ONE_SECOND/2]
TabEnemyHoverTime_MSB
	.byte >[4*FRAMES_ONE_SECOND/2], >[6*FRAMES_ONE_SECOND/2], >[8*FRAMES_ONE_SECOND/2]

TabEnemyDeltaMoveX
	.byte 19, 20, 18
TabEnemyDeltaMoveY
	.byte 30, 32, 28

;TabRandomEnemyDirection
;	.byte 0,0,0, 1,1,1, 2,2,2,2, 3,3,3, 4,4,4

;----------------------------------------
TabEnemyShapeP3
; 	.byte %00000000
; 	.byte %00000000
; 	.byte %00000000
; 	.byte %00000000
; 	.byte %00000000

; 	.byte %00000000
; 	.byte %00000000
	.byte %00110000
	.byte %01001000
	.byte %11111100

	.byte %11111100
	.byte %01111000
; 	.byte %00000000
; 	.byte %00000000

TabEnemyShapeM3M2M1
	.byte %00110000
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000

	.byte %01001000
	.byte %01001000
	.byte %10000100
	.byte %01111000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %01111000
	.byte %00110000

TabEnemyAnimM3M2M1_S1
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %10000100
	
TabEnemyAnimM3M2M1_S2
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %00000000
	
TabEnemyAnimM3M2M1_S3
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %10000100
	
TabEnemyAnimM3M2M1_S4
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %00000000
	
TabEnemyAnimM3M2M1_S5
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %10000100

TabEnemyAnimM3M2M1_S6
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %10000100
TabEnemyAnimM3M2M1_S7
	.byte %01101000
	.byte %01101000
	.byte %01101000
	.byte %01101000
	.byte %01101000
	.byte %01101000
	.byte %10000100
TabEnemyAnimM3M2M1_S8
	.byte %01111000
	.byte %01111000
	.byte %01111000
	.byte %01111000
	.byte %01111000
	.byte %01111000
	.byte %10000100
TabEnemyAnimM3M2M1_S9
	.byte %01011000
	.byte %01011000
	.byte %01011000
	.byte %01011000
	.byte %01011000
	.byte %01011000
	.byte %10000100

TabEnemyAnimM3M2M1_S10
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %10000100
	
TabEnemyAnimM3M2M1_S11
	.byte %01101000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %01001000
	.byte %00000000

ENEMY1_ANIM1_FRAMES = 11
ENEMY1_ANIM1_FRAME_SIZE = 7

TabEnemyAnimFrameTime
	.byte 6, 6, 6, 30, 90, 3, 3, 1, 3, 90, 30
	
TabEnemyAnimM3M2M1_LSB
	// .byte <[TabEnemyAnimM3M2M1_S1-1], <[TabEnemyAnimM3M2M1_S2-1], <[TabEnemyAnimM3M2M1_S3-1]
	// .byte <[TabEnemyAnimM3M2M1_S4-1], <[TabEnemyAnimM3M2M1_S5-1], <[TabEnemyAnimM3M2M1_S6-1]
	// .byte <[TabEnemyAnimM3M2M1_S7-1], <[TabEnemyAnimM3M2M1_S8-1], <[TabEnemyAnimM3M2M1_S8-1]
	// .byte <[TabEnemyAnimM3M2M1_S10-1], <[TabEnemyAnimM3M2M1_S11-1]
	.byte <TabEnemyAnimM3M2M1_S1, <TabEnemyAnimM3M2M1_S2, <TabEnemyAnimM3M2M1_S3
	.byte <TabEnemyAnimM3M2M1_S4, <TabEnemyAnimM3M2M1_S5, <TabEnemyAnimM3M2M1_S6
	.byte <TabEnemyAnimM3M2M1_S7, <TabEnemyAnimM3M2M1_S8, <TabEnemyAnimM3M2M1_S8
	.byte <TabEnemyAnimM3M2M1_S10, <TabEnemyAnimM3M2M1_S11
	
TabEnemyAnimM3M2M1_MSB
	// .byte >[TabEnemyAnimM3M2M1_S1-1], >[TabEnemyAnimM3M2M1_S2-1], >[TabEnemyAnimM3M2M1_S3-1]
	// .byte >[TabEnemyAnimM3M2M1_S4-1], >[TabEnemyAnimM3M2M1_S5-1], >[TabEnemyAnimM3M2M1_S6-1]
	// .byte >[TabEnemyAnimM3M2M1_S7-1], >[TabEnemyAnimM3M2M1_S8-1], >[TabEnemyAnimM3M2M1_S8-1]
	// .byte >[TabEnemyAnimM3M2M1_S10-1], >[TabEnemyAnimM3M2M1_S11-1]
	.byte >TabEnemyAnimM3M2M1_S1, >TabEnemyAnimM3M2M1_S2, >TabEnemyAnimM3M2M1_S3
	.byte >TabEnemyAnimM3M2M1_S4, >TabEnemyAnimM3M2M1_S5, >TabEnemyAnimM3M2M1_S6
	.byte >TabEnemyAnimM3M2M1_S7, >TabEnemyAnimM3M2M1_S8, >TabEnemyAnimM3M2M1_S8
	.byte >TabEnemyAnimM3M2M1_S10, >TabEnemyAnimM3M2M1_S11
	
;----------------------------------------
TabExplosionAnimP3_S1
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00001000
	.byte %00111110

	.byte %00111110
	.byte %00001000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

TabExplosionAnimP3_S2
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00001000
	.byte %00001000
	.byte %00010100
	.byte %00010100
	.byte %00000000

	.byte %00000000
	.byte %00010100
	.byte %00010100
	.byte %00001000
	.byte %00001000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

TabExplosionAnimP3_S3
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00001000
	.byte %00001000
	.byte %00100010
	.byte %00100010
	.byte %00000000
	.byte %00000000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00100010
	.byte %00100010
	.byte %00001000
	.byte %00001000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

TabExplosionAnimP3_S4
	.byte %00000000
	.byte %00000000
	.byte %00001000
	.byte %00001000
	.byte %01000001
	.byte %01000001
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %01000001
	.byte %01000001
	.byte %00001000
	.byte %00001000
	.byte %00000000
	.byte %00000000


TabExplosionAnimM3M2M1_S1
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00100000
	.byte %10101000
	.byte %10001000
	.byte %00000000

	.byte %00000000
	.byte %10001000
	.byte %10101000
	.byte %00100000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

TabExplosionAnimM3M2M1_S2
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00100000
	.byte %00100000
	.byte %10001000
	.byte %10001000
	.byte %00000000
	.byte %00000000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10001000
	.byte %10001000
	.byte %00100000
	.byte %00100000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

TabExplosionAnimM3M2M1_S3
	.byte %00000000
	.byte %00000000
	.byte %00100000
	.byte %00100000
	.byte %10001000
	.byte %10001000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10001000
	.byte %10001000
	.byte %00100000
	.byte %00100000
	.byte %00000000
	.byte %00000000

TabExplosionAnimM3M2M1_S4
	.byte %00100000
	.byte %00100000
	.byte %10001000
	.byte %10001000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10001000
	.byte %10001000
	.byte %00100000
	.byte %00100000


TabExplosionAnimOffsetM3
	.byte 3, 2, 1, 0
TabExplosionAnimOffsetM2
	.byte 1, 2, 3, 4
TabExplosionAnimOffsetM1
	.byte 1, 2, 3, 4
	
EXPLOSION1_ANIM1_FRAMES = 4
EXPLOSION1_ANIM1_FRAME_SIZE = 22

TabExplosionAnimFrameTime
	.byte 3, 3, 3, 4
	
TabExplosionAnimP3_LSB
	// .byte <[TabExplosionAnimP3_S1-1], <[TabExplosionAnimP3_S2-1], <[TabExplosionAnimP3_S3-1], <[TabExplosionAnimP3_S4-1]
	.byte <TabExplosionAnimP3_S1, <TabExplosionAnimP3_S2, <TabExplosionAnimP3_S3, <TabExplosionAnimP3_S4
	
TabExplosionAnimP3_MSB
	// .byte >[TabExplosionAnimP3_S1-1], >[TabExplosionAnimP3_S2-1], >[TabExplosionAnimP3_S3-1], >[TabExplosionAnimP3_S4-1]
	.byte >TabExplosionAnimP3_S1, >TabExplosionAnimP3_S2, >TabExplosionAnimP3_S3, >TabExplosionAnimP3_S4
	
TabExplosionAnimM3M2M1_LSB
	// .byte <[TabExplosionAnimM3M2M1_S1-1], <[TabExplosionAnimM3M2M1_S2-1], <[TabExplosionAnimM3M2M1_S3-1], <[TabExplosionAnimM3M2M1_S4-1]
	.byte <TabExplosionAnimM3M2M1_S1, <TabExplosionAnimM3M2M1_S2, <TabExplosionAnimM3M2M1_S3, <TabExplosionAnimM3M2M1_S4
	
TabExplosionAnimM3M2M1_MSB
	// .byte >[TabExplosionAnimM3M2M1_S1-1], >[TabExplosionAnimM3M2M1_S2-1], >[TabExplosionAnimM3M2M1_S3-1], >[TabExplosionAnimM3M2M1_S4-1]
	.byte >TabExplosionAnimM3M2M1_S1, >TabExplosionAnimM3M2M1_S2, >TabExplosionAnimM3M2M1_S3, >TabExplosionAnimM3M2M1_S4
	
;----------------------------------------
.if .def PAL_VERSION
ENEMY1_SINE_TAB_SIZE = 85
.else
ENEMY1_SINE_TAB_SIZE = 102
.endif

TabEnemySineY
	.byte sin(7,7,ENEMY1_SINE_TAB_SIZE)
	
.endif


; this is for a game display list of 28 lines (should be only MAX_BALLS_IN_HUD..)
TabDL1LineAddressInverse_LSB
	:28 .byte <[DL1_data_address+[27-#]*BYTES_LINE]

TabDL1LineAddressInverse_MSB
	:28 .byte >[DL1_data_address+[27-#]*BYTES_LINE]


; these tables are for the normal game mode (tree)
TabLevelName
	.sb "1A2A2B3A3B3C4A4B4C4D5A5B5C5D5E6A6B6C6D6E6F7A7B7C7D7E7F7G"
;		0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7

TabLevelLeftExit
	.byte 1, 3,4, 6,7,8, 10,11,12,13, 15,16,17,18,19, 21,22,23,24,25,26

; TabLevelRightExit
; 	.by +1, 1, 3,4, 6,7,8, 10,11,12,13, 15,16,17,18,19, 21,22,23,24,25,26

TabLevelUnlocked
	:MAX_LEVEL_NUM .byte 0


; these tables are for the extra game mode (linear)
TabLevelNameExtra
	.sb "A1B1B2C1C2D1D2E1E2F1F2G1G2H1H2I1I2J1J2K1K2L1L2M1M2N1N2"
;		0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6

TabLevelLeftExitExtra
	.byte 1, 3,3, 5,5, 7,7, 9,9, 11,11, 13,13, 15,15, 17,17, 19,19, 21,21, 23,23, 25,25

; TabLevelRightExitExtra
;	.by +1, 1, 3,3, 5,5, 7,7, 9,9, 11,11, 13,13, 15,15, 17,17, 19,19, 21,21, 23,23, 25,25

TabLevelUnlockedExtra
	:MAX_LEVEL_NUM_EXTRA .byte 0


; table to save the 4 chars used for the start level highlight effect (2 hard bricks)
TabSaveHighlightChar
	:32 .byte 0


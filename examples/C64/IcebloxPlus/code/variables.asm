
;=================================
; Memory locations
; used as variables
;=================================

game_state      .byte 0
next_game_state	.byte 0 ; Set by IRQ when the counter hits the target
irq_counter     .byte 0
slow_counter 	.byte 0
irq_target	.byte 0
joystick	.byte 255
joystick_old	.byte 0
intro_state     .byte 0
; For gradually clearing screen
line_counter	.byte 0
curtain         .byte 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12

; Pete animation frames
penguin_stand	.byte 0,0,0,0
penguin_up	.byte 0,1,2,1
penguin_down	.byte 3,4,5,4
penguin_left	.byte 6,7,8,7
penguin_right	.byte 9,10,11,10

flame_frames	.byte 19,20,21,22,23,22,21,20
score		.byte 0,0
level		.byte 0
level_bcd	.byte 0
lives		.byte 0
coin_counter 	.byte 0
level_flames	.byte 1,2,2,3, 3,1,1,2, 2,3,3,2, 2,1,1,0
level_sparks	.byte 0,0,0,0, 0,1,1,1, 1,1,1,2, 2,3,3,4	; The more aggressive flames
levflame_types	.byte 0,0,0,0					; Specific flame types for the level
level_pixels1	.byte <dirt_pixels,<lego_pixels,<beach_pixels,<grass_pixels,<weird_pixels
		.byte <dice_pixels,<boxes_pixels,<apples_pixels
level_pixels2	.byte >dirt_pixels,>lego_pixels,>beach_pixels,>grass_pixels,>weird_pixels
		.byte >dice_pixels,>boxes_pixels,>apples_pixels
level_midcol1 	.byte <dirt_midcolor,<lego_midcolor,<beach_midcolor,<grass_midcolor,<weird_midcolor
		.byte <dice_midcolor,<boxes_midcolor,<apples_midcolor
level_midcol2 	.byte >dirt_midcolor,>lego_midcolor,>beach_midcolor,>grass_midcolor,>weird_midcolor
		.byte >dice_midcolor,>boxes_midcolor,>apples_midcolor
level_fgcol1 	.byte <dirt_fgcolor,<lego_fgcolor,<beach_fgcolor,<grass_fgcolor,<weird_fgcolor
		.byte <dice_fgcolor,<boxes_fgcolor,<apples_fgcolor
level_fgcol2 	.byte >dirt_fgcolor,>lego_fgcolor,>beach_fgcolor,>grass_fgcolor,>weird_fgcolor
		.byte >dice_fgcolor,>boxes_fgcolor,>apples_fgcolor
level_ice	.byte 12,12,12,11, 11,11,10,10, 10,9,9,8, 8,7,7,7
level_blocks	.byte 6,6,7,7, 8,8,9,9, 10,10,11,11, 12,12,13,13
level_deco	.byte 40,20,42,15,44,10,0,0	; Background 0
		.byte 0,0,0,0,0,0,0,0		; Background 1
		.byte 46,10,48,15,50,30,0,0	; Background 2
		.byte 46,30,48,30,50,30,0,0	; Background 3
		.byte 0,0,0,0,0,0,0,0 		; Background 4
		.byte 40,20,42,20,44,20,0,0	; Background 5
		.byte 40,15,42,20,44,20,46,15	; Background 6
		.byte 46,30,48,30,50,30,0,0	; Background 7

level_ground	.byte 38,38,38,38,38,38,0,0	; Background 0
		.byte 38,40,41,38,40,41,0,0	; Background 1
		.byte 38,40,41,42,44,45,0,0	; Background 2
		.byte 38,40,41,42,44,45,0,0	; Background 3
		.byte 38,40,41,42,44,45,0,0	; Background 4
		.byte 38,38,38,38,38,38,0,0	; Background 5
		.byte 38,38,38,38,38,38,0,0	; Background 6
		.byte 38,40,41,42,44,45,0,0	; Background 7

topsprite_x	.byte 26,46,66,86, 64,40,16,208 ; Score, life and music symbols
topsprite_frame	.byte 80,80,80,80, 55,55,55,98

midsprite_x	.byte 0,0,0,0,0,0,0,0		; The sprites in the playing area
midsprite_y	.byte 0,0,0,0,0,0,0,0
midsprite_msb	.byte 0
midsprite_frame	.byte 0,0,0,0,0,0,0,0
midsprite_col	.byte 0,0,0,0,0,0,0,0

pete_state	.byte 0
pete_block	.byte 0
pete_dir	.byte 0
pete_delta	.byte 0
pete_x1 	.byte 0 ; x and y coordinates are in 1/8 of pixels, to
pete_x2		.byte 0	; make it easier to fine-tune the speed
pete_y1 	.byte 0
pete_y2		.byte 0
pete_frame	.byte 0
pete_y 		.byte 0 ; Separate convenience value in pixel units

pete_dir_jumptable1 .byte <pete_done,<pete_up,<pete_down,<pete_left,<pete_right
pete_dir_jumptable2 .byte >pete_done,>pete_up,>pete_down,>pete_left,>pete_right

flame_state	.byte 0,0,0,0
flame_block	.byte 0,0,0,0
flame_dir	.byte 0,0,0,0
flame_delta	.byte 0,0,0,0
flame_x1 	.byte 0,0,0,0
flame_x2	.byte 0,0,0,0
flame_y1 	.byte 0,0,0,0
flame_y2	.byte 0,0,0,0
flame_frame	.byte 0,0,0,0
flame_color	.byte 0,0,0,0
flame_y 	.byte 0,0,0,0
flame_count	.byte 0,0,0,0
flame_speed	.byte 4,4,4,4

ice_state	.byte 0
ice_block	.byte 0
ice_dir		.byte 0
ice_delta	.byte 0
ice_x1 		.byte 0
ice_x2		.byte 0
ice_y1 		.byte 0
ice_y2		.byte 0
ice_frame	.byte 0
ice_y 		.byte 0
ice_active 	.byte 0

sort_val	.byte 0,0,0,0,0,0 ; For sorting the sprites in 3D order
sort_ix		.byte 0,1,2,3,4,5

changed_block 	.byte 0

sound_effect	.byte 0
sound_counter	.byte 0

; For cheating
cheat_counter 	.byte 0
collisions_on 	.byte 1

; Blank, Crush, Push, Stop, Coin, Bonus, Flame, Snuffed, Death
snd_wave 	.byte 0,33,129,129,33,33,129,17,17 ; Sound effect initial data
snd_attack 	.byte 0,9,9,6,10,7,10,9,10
snd_decay	.byte 0,0,0,0,0,0,0,0,0
snd_freq2	.byte 0,0,0,25,0,150,0,0,0
snd_time 	.byte 0,25,20,1,60,1,40,40,50

; Music variables
voice1pos1 	.byte 0
voice1pos2 	.byte 0
voice2pos1 	.byte 0
voice2pos2 	.byte 0
voice1start1 	.byte 0
voice1start2 	.byte 0
voice2start1 	.byte 0
voice2start2 	.byte 0
voice1count 	.byte 0
voice2count 	.byte 0
voice1arp	.byte 0
voice2arp	.byte 0

; Note frequency tables, low and high byte
notes_low	.byte $2a,$4b,$6e,$93,$ba,$e3,$0f,$3e,$6f,$a4,$db,$16
		.byte $54,$96,$dc,$26,$74,$c7,$1f,$7c,$df,$47,$b6,$2c
		.byte $a8,$2c,$b7,$4b,$e8,$8e,$3e,$f8,$be,$8f,$6c,$57
		.byte $50,$58,$6f,$96,$d0,$1c,$7c,$f0,$7b,$1e,$d9,$ae
		.byte $a0,$af,$dd,$2d,$a0,$38,$f8,$e1,$f6,$3b,$b2,$5c
		.byte $40,$5e,$bb,$5a,$3f,$6f,$ef,$c2,$ed,$76,$63,$b9
		.byte 0

notes_high	.byte $02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04
		.byte $04,$04,$04,$05,$05,$05,$06,$06,$06,$07,$07,$08
		.byte $08,$09,$09,$0a,$0a,$0b,$0c,$0c,$0d,$0e,$0f,$10
		.byte $11,$12,$13,$14,$15,$17,$18,$19,$1b,$1d,$1e,$20
		.byte $22,$24,$26,$29,$2b,$2e,$30,$33,$36,$3a,$3d,$41
		.byte $45,$49,$4d,$52,$57,$5c,$61,$67,$6d,$74,$7b,$82
		.byte 0

song_reset	.byte 0,1,0,255,1,0

line1           .cbm "  Fire to start  "
line2           .cbm "You control Pixel"
line3           .cbm "Pete, the penguin"
line4           .cbm " Move ice blocks "
line5           .cbm " by pushing them "
line6           .cbm "... or crush them"
line7           .cbm "against obstacles"
line8           .cbm "  Watch out for  "
line9           .cbm "    the flames   "
line10          .cbm "  You can snuff  "
line11          .cbm "  them with ice  "
line12          .cbm "Collect all five "
line13          .cbm "golden coins ... "
line14          .cbm "  ... to get to  "
line15          .cbm " the next level  "
line16          .cbm "   HIGHSCORES    "
line17		.cbm " 1. 0800 ... AAA "
		.cbm " 2. 0700 ... BBB "
		.cbm " 3. 0600 ... CCC "
		.cbm " 4. 0500 ... DDD "
		.cbm " 5. 0400 ... EEE "
		.cbm " 6. 0300 ... FFF "
		.cbm " 7. 0200 ... GGG "
		.cbm " 8. 0100 ... HHH "
		.cbm "                 "	; Buffer
leveltext	.cbm "    Level 00     "
gameovertext	.cbm "    GAME OVER    "
nametext 	.cbm "    Your name    "
initials 	.cbm "..."
credits		.cbm "  Programmed by  "
		.cbm "  Karl Hornell   "
		.cbm "                 "
		.cbm "    Music by     "
		.cbm "    M.D. Smit    "
		.cbm "                 "
		.cbm " (c) Eweguo 2018 "
party_text	.cbm " CONGRATULATIONS "
		.cbm "                 "
		.cbm "  Now you have   "
		.cbm " seen everything "

highscores1 	.byte 0,0,0,0,0,0,0,0, 0			; Low byte
highscores2	.byte $08,$07,$06,$05,$04,$03,$02,$01, 0	; High byte
cursor_pos 	.byte 0
cursor_colors 	.byte 0,11,12,15,1,15,12,11	; Blinking cursor colors when entering name

; Quick table of character and pixel offsets for 4x3 group
char_offset	.byte 0,1,2,3,40,41,42,43,80,81,82,83
pix_offset1	.byte 0,8,16,24,64,72,80,88,128,136,144,152
pix_offset2	.byte 0,0,0,0,1,1,1,1,2,2,2,2

; Color positions of top left corner of blocks, LSB
block_pos1	.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,162,165,168,171,174,177,180,183,186,189,192,195,0,0,0
		.byte 0,242,245,248,251,254,1,4,7,10,13,16,19,0,0,0
		.byte 0,66,69,72,75,78,81,84,87,90,93,96,99,0,0,0
		.byte 0,146,149,152,155,158,161,164,167,170,173,176,179,0,0,0
		.byte 0,226,229,232,235,238,241,244,247,250,253,0,3,0,0,0
		.byte 0,50,53,56,59,62,65,68,71,74,77,80,83,0,0,0
		.byte 0,130,133,136,139,142,145,148,151,154,157,160,163,0,0,0
		.byte 0,210,213,216,219,222,225,228,231,234,237,240,243,0,0,0
		.byte 0,34,37,40,43,46,49,52,55,58,61,64,67,0,0,0
		.byte 0,114,117,120,123,126,129,132,135,138,141,144,147,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

; Color positions of top left corner of blocks, MSB offset
block_pos2	.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,1,1, 1,1,1,1, 1,0,0,0
		.byte 0,1,1,1, 1,1,1,1, 1,1,1,1, 1,0,0,0
		.byte 0,1,1,1, 1,1,1,1, 1,1,1,1, 1,0,0,0
		.byte 0,1,1,1, 1,1,1,1, 1,1,1,2, 2,0,0,0
		.byte 0,2,2,2, 2,2,2,2, 2,2,2,2, 2,0,0,0
		.byte 0,2,2,2, 2,2,2,2, 2,2,2,2, 2,0,0,0
		.byte 0,2,2,2, 2,2,2,2, 2,2,2,2, 2,0,0,0
		.byte 0,3,3,3, 3,3,3,3, 3,3,3,3, 3,0,0,0
		.byte 0,3,3,3, 3,3,3,3, 3,3,3,3, 3,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

; Pixel positions of top left corner of blocks, LSB
; Computed later
pix_pos1	.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

; Pixel positions of top left corner of blocks, MSB offset
; Computed later
pix_pos2	.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

; Table of masking values, to use in 3D effects
mask_template	.byte 255,255,255
		.byte 0,0,0
		.byte 0,0,3
		.byte 0,0,15
		.byte 0,0,63
		.byte 0,0,255
		.byte 0,3,255
		.byte 0,15,255
		.byte 0,63,255
		.byte 0,255,255
		.byte 3,255,255
		.byte 15,255,255
		.byte 63,255,255

		.byte 255,255,255
		.byte 255,255,252
		.byte 255,255,240
		.byte 255,255,192
		.byte 255,255,0
		.byte 255,252,0
		.byte 255,240,0
		.byte 255,192,0
		.byte 255,0,0
		.byte 252,0,0
		.byte 240,0,0
		.byte 192,0,0

		.byte 255,255,255 ; Auxiliary mask data for Pete's shadow
		.byte 0,0,15
		.byte 255,255,255
		.byte 255,255,240
		.byte 0,0,0
		.byte 255,255,240
		.byte 255,255,255

; Table for quicker computing
mask_pos1 	.byte 128,131,134,137,140,143,146,149
		.byte 152,155,158,161,164,167,170,173
		.byte 176,179,182,185,188,191,194,197
		.byte 200,203,206,209,212,215,218,221
		.byte 224,227,230,233,236,239,242,245
		.byte 248,251,254,1,4,7,10,13
		.byte 16,19,22,25,28,31,34,37
		.byte 40,43,46,49,52,55,58,61
		.byte 64,67,70,73,76,79,82,85
		.byte 88,91,94,97,100,103,106,109
		.byte 112,115,118,121,124,127,130,133
		.byte 136,139,142,145,148,151,154,157
		.byte 160,163,166,169,172,175,178,181

		.byte 184,187,190,193,196,199,202,205
		.byte 208,211,214,217,220,223,226,229
		.byte 232,235,238,241,244,247,250,253
		.byte 0,3,6,9,12,15,18,21
		.byte 24,27,30,33,36,39,42,45
		.byte 48,51,54,57,60,63,66,69
		.byte 72,75,78,81,84,87,90,93
		.byte 96,99,102,105,108,111,114,117
		.byte 120,123,126,129,132,135,138,141
		.byte 144,147,150,153,156,159,162,165
		.byte 168,171,174,177,180,183,186,189
		.byte 192,195,198,201,204,207,210,213

		.byte 216,219,222,225,228,231,234,237
		.byte 240,243,246,249,252,255,2,5
		.byte 8,11,14,17,20,23,26,29
		.byte 32,35,38,41,44,47,50,53
		.byte 56,59,62,65,68,71,74,77
		.byte 80,83,86,89,92,95,98,101
		.byte 104,107,110,113,116,119,122,125

mask_pos2 	.byte 169,169,169,169,169,169,169,169
		.byte 169,169,169,169,169,169,169,169
		.byte 169,169,169,169,169,169,169,169
		.byte 169,169,169,169,169,169,169,169
		.byte 169,169,169,169,169,169,169,169
		.byte 169,169,169,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170

		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 170,170,170,170,170,170,170,170
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,171,171

		.byte 171,171,171,171,171,171,171,171
		.byte 171,171,171,171,171,171,172,172
		.byte 172,172,172,172,172,172,172,172
		.byte 172,172,172,172,172,172,172,172
		.byte 172,172,172,172,172,172,172,172
		.byte 172,172,172,172,172,172,172,172
		.byte 172,172,172,172,172,172,172,172

; For random number generation
random_pos	.byte 0
random_table
		.byte $a7,$95,$73,$b4,$dd,$78,$df,$63,$42,$bd,$ff,$56,$73,$56,$17,$4
		.byte $d4,$1e,$71,$a9,$9d,$9,$77,$23,$b0,$ed,$fd,$5e,$42,$8d,$33,$1f
		.byte $97,$65,$fc,$d9,$fb,$45,$7b,$ae,$ed,$b2,$9a,$b1,$2c,$53,$d1,$64
		.byte $14,$23,$61,$24,$9c,$6e,$8d,$3b,$b6,$5d,$1f,$d5,$da,$4e,$8d,$34
		.byte $41,$28,$53,$93,$c2,$fa,$66,$ad,$b7,$2a,$48,$af,$2d,$e9,$7d,$20
		.byte $92,$bd,$7a,$72,$10,$25,$6f,$33,$c1,$c,$ad,$7b,$52,$7a,$10,$b8
		.byte $b3,$69,$6d,$70,$47,$f6,$25,$dc,$ea,$d6,$36,$53,$e3,$d5,$bb,$1e
		.byte $db,$b7,$b4,$cc,$e3,$68,$85,$db,$bd,$92,$db,$5c,$7c,$42,$5a,$1f
		.byte $70,$df,$98,$e2,$9c,$a6,$35,$33,$dd,$ff,$6,$11,$84,$cf,$93,$c6
		.byte $f,$6d,$cd,$96,$2e,$8c,$3d,$fb,$bb,$83,$5e,$42,$15,$58,$af,$9c
		.byte $30,$4d,$4b,$6d,$ed,$de,$71,$86,$51,$f9,$cc,$c9,$3b,$da,$a4,$22
		.byte $f8,$e1,$d8,$5f,$12,$e2,$e0,$a,$f6,$3b,$fe,$5,$3,$d7,$5b,$26
		.byte $f5,$f1,$1b,$9c,$bb,$58,$f5,$ab,$c2,$4f,$ce,$99,$10,$e5,$5e,$f8
		.byte $c6,$ae,$3a,$e8,$3,$f5,$19,$ee,$15,$8e,$2c,$6,$9c,$b8,$73,$bb
		.byte $5,$12,$58,$35,$cc,$dc,$f4,$fe,$39,$2c,$93,$18,$2f,$30,$e2,$45
		.byte $e0,$4f,$81,$a6,$f9,$bb,$b8,$56,$2e,$0,$1b,$46,$76,$4b,$61,$49

; For computations
buffer 		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
		.byte 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

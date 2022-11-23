;********************************************************************************
;
;    5 dots
;    anticShop
;    bocianu@gmail.com
;
;********************************************************************************

;*************************************  INCLUDES

 icl 'atari.hea'
MODUL   equ $9200               ;address of RMT module
STEREOMODE  equ 0               ;0 => compile RMTplayer for mono 4 tracks

    icl "rmtplayr.asm"          ;include RMT player routine

    opt h-
    ins "assets/music.rmt"
    opt h+


;debug_mode = 1                             ; uncomment this line to get on screen debug info

;*************************************  DEFINES

VERSION_H           equ "0"
VERSION_Lh          equ "9"
VERSION_Ll          equ "6"

BOARD_SIZE          equ 22                  ; board size

CURSOR_OFFSET_X     equ 52                  ; offsets for pmg
CURSOR_OFFSET_Y     equ 20

STATE_TITLE         equ 0
STATE_GAME_ON       equ 1
STATE_GAME_NEXT     equ 2
STATE_GAME_OVER     equ 3
STATE_HELP          equ 4

JOY_SKIP_TIME       equ 4                   ; timeout (in vsync cycles) between cursor jumps, when joy keeped in one direction
KEY_SKIP_TIME       equ 16                   ; timeout (in vsync cycles) between console keypresses

MODE_ARCADE         equ 0
MODE_PUZZLE         equ 1
MODE_EXPLORE        equ 2

CURSOR_COLOR_LIGHT  equ $8b
CURSOR_COLOR_DARK   equ $86

GAMEOVER_COLOR_0    equ $16
GAMEOVER_COLOR_1    equ $18
GAMEOVER_COLOR_2    equ $1a
GAMEOVER_COLOR_3    equ $1c
GAMEOVER_COLOR_4    equ $ec
GAMEOVER_COLOR_5    equ $ea
GAMEOVER_COLOR_6    equ $e8
GAMEOVER_COLOR_7    equ $e6

WELLDONE_COLOR_0    equ $96
WELLDONE_COLOR_1    equ $98
WELLDONE_COLOR_2    equ $9a
WELLDONE_COLOR_3    equ $9c
WELLDONE_COLOR_4    equ $ac
WELLDONE_COLOR_5    equ $aa
WELLDONE_COLOR_6    equ $a8
WELLDONE_COLOR_7    equ $a6

GAME_BG_COLOR       equ $02
GAME_BG_RED         equ $24
GAME_BG_GREEN       equ $c0
TITLE_BG_COLOR      equ $10

SCROLL_COLOR_LIGHT  equ $da
SCROLL_COLOR_DARK   equ $d6

LEVEL_PREVIEW_X     equ 162
LEVEL_PREVIEW_Y     equ $80

;*************************************  ZERO PAGE GLOBAL VARIABLES
            org $80
src             .wo 0                       ; source addres
dest            .wo 0                       ; destination addres
dataw           .wo 0
boardPos        .wo 0
cursorX         .by 10                      ; stores actual cursor coordinates
cursorY         .by 10
cursorYprev     .by 0                       ; stores previous cursor coordinates
cursorYlast     .by 20
cursorXlast     .by 52
cursor_moves    .by 0
joyTimer        .by JOY_SKIP_TIME
start_x         .by 0                       ; starting coordinates for some high level arithmetics ;)
start_y         .by 0
start_offset    .wo 0
cx              .by 0                       ; and other useful variables
cy              .by 0
sx              .by 0
sy              .by 0
dx              .by 0
dy              .by 0
line_bit        .by 0
pos_offset      .by 0
is_line         .by 0
x_limit         .by 0
step            .by 0
current_cell    .by 0
bit1            .by 1                       ; always cointains '1' - used to cmp
bit7            .by %10000000               ; always cointains '1' - used to cmp
zero_time       .ds 3
timer           .by 0
basetimer       .by 0
timerbarlast    .by 0
goal            .by 0
bombs           .by 0
hiscores        .wo 0

hline           .by 0
splitpmg        .by 50
hoffset         .by 0

LOW_COLOR_0     .by 0
LOW_COLOR_1     .by 0
LOW_COLOR_2     .by 0
LOW_COLOR_3     .by 0

;*************************************  VBI                      **************

            org $2000

VBLANK
            mva #0 hline
            sta 77          ; attract mode off

            lda gamestate
            ; cmp #STATE_TITLE
            seq
            jmp ingame
                                               ; *********** title screen routines

            lda charset_title+(126*8)+3        ; ****** horizontal dot movement
            lsr
            scc
            ora bit7
            sta charset_title+(126*8)+3
            sta charset_title+(126*8)+2

            lda charset_title+(127*8)+4
            asl
            scc
            ora bit1
            sta charset_title+(127*8)+4
            sta charset_title+(127*8)+5

            lda pmg+$300+40                     ; **************** vertical dot movement
            sta pmg+$300+200
            ldy #40
            ldx #200
@           lda pmg+$301,y
            and #%00100000
            sta dx
            lda pmg+$300,x
            and #%00100000
            asl:asl
            ora dx
            sta pmg+$300,y
            dex
            iny
            cpy #200
            bne @-

            dec hoffset         ; ********************** hscroll
            bne move
            mva #8 hoffset
            inw scrmem+1
            cpw scrmem+1 #scroll+550 ; reached text length
            bne move
            mwa #scroll scrmem+1 ; reset to start pos
move        mva hoffset hscrol

            lda rtclock+2       ; ********************* titlebar change
            bne notchange

            mwa #titlebar src
            lda rtclock+1
            and #7
            beq skipadd
            tay
add40       adw src #40 src
            dey
            bne add40
skipadd
            ldy #40
@           lda (src),y
            sta t_top,y
            dey
            bne @-

            lda rtclock+2

notchange   cmp #32
            bcs @+
            ror
            sta title_colors[2]
@
            jmp endvblk

ingame                                   ; *********** in game routines

			jsr RASTERMUSICTRACKER+3

            lda redblink            ; ******** blink red
            beq noblink
            dec redblink
            bit bit1
            bne notred
            ldx #GAME_BG_RED
            jmp @+
notred
            ldx #GAME_BG_COLOR

            lda game_mode           ; ****** keep bg colour change on goal
            ; cmp #MODE_ARCADE
            bne @+
            lda score
            cmp goal
            bmi @+
            ldx #GAME_BG_GREEN
@           stx 710
noblink
                            ; ******** bomb animaton
            lda game_mode
            cmp #MODE_PUZZLE
            bne @+
            lda bombs
            beq @+
            ldy #0
putfuse     tya:asl:tax
            mva #$56 vram_game+267,x
            lda 20
            and #4
            beq skip_fuse
            mva #$5c vram_game+267,x
skip_fuse   iny
            cpy bombs
            bne putfuse
@
endvblk

            jmp sysvbv


;*************************************  GLOBAL VARIABLES
            org $2200
board           .ds BOARD_SIZE*BOARD_SIZE   ; main board array
                                            ; each byte represents one cell (8 bits = 7 6 5 4 3 2 1 0)
                                            ; meaning of bits:
                                            ; 0 : 1 = dot already placed , 0 = no dot
                                            ; 1 : 1 = cell contains horizontal line '-'
                                            ; 2 : 1 = cell contains diagonal line '\'
                                            ; 3 : 1 = cell contains vertical line '|'
                                            ; 4 : 1 = cell contains diagonal line '/'
                                            ; 5 : not used
                                            ; 6 : not used
                                            ; 7 : 1 = cell has neighbours with dots - include it in search
                                            ;         for moves algorithm (lookup table)

level           .by 0                       ; current level
game_mode       .by 0                       ; current mode
game_mode_num   .by 3                       ; max number of modes
gamestate       .by STATE_TITLE
gamemusic     .by 1

redblink        .by 0
escape          .by 0
scrolldelay     .by 0

joyPos          .by 15
joyFire         .by 1

line_count      .by 0                       ; number of lines already drawn (stored in array below)
line_sx         .ds 255                     ; starting coords
line_sy         .ds 255
line_dir        .ds 255                     ; line direction bit
line_cx         .ds 255                     ; placed dot coords
line_cy         .ds 255

fline_count     .by 0                       ; number of lines found for 1 point (stored in array below)
fline_sx        .ds 255                     ; starting coords
fline_sy        .ds 255
fline_dir       .ds 255                     ; line direction bit
fline_cx        .ds 255                     ; dot coords
fline_cy        .ds 255

fline_sel       .by 0

score           .by 0
moves           .by 0
arcadescore     .wo 0

tabpp  dta 156,78,52,39         ;line counter spacing table for instrument speed from 1 to 4


modenames
    dta d'ARCADE  '
    dta d'PUZZLE  '
    dta d'EXPLORE '


savedata
hiscoresA .ds 100
hiscoresP .ds 100
unlocked  .wo 0
top5      .ds 10


;*************************************  MAIN                     **************

main


            cld
            mva #8 hoffset
            mva #MODE_ARCADE game_mode

            jsr dataLoad

            jsr setHiscore

            lda #$06
            ldx >VBLANK ;HIGH BYTE OF USER ROUTINE
            ldy <VBLANK ;LOW BYTE
            jsr setvbv


initTitle
            ldx #<MODUL
            ldy #>MODUL                 ;hi byte of RMT module to Y reg
            lda #0                      ;starting song line 0-255 to A reg
            jsr RASTERMUSICTRACKER      ;Init
;            tay
;            lda tabpp-1,y
;            sta acpapx2+1               ;sync counter spacing
;            lda #16+0
;            sta acpapx1+1
initTitle_
            jsr scrInitTitle
            jsr initPMG_title
            jsr updateTitleTop5
            mva #STATE_TITLE gamestate
            jsr showMode
            jsr showLevelT
            jsr showHiScoreT
            jsr showPreview
            mva consol joyPos
            mvx #KEY_SKIP_TIME joyTimer
            mwa #0 dataw
            sta 19
            sta 20
            sta helpfg

@           lda strig0  ; wait for fire up
            beq @-
            mva strig0 joyFire

loop_title

;acpapx1     lda #$ff                ;parameter overwrite (sync line counter value)
;            clc
;acpapx2     adc #$ff                ;parameter overwrite (sync line counter spacing)
;            cmp #156
;            bcc lop4
;            sbc #156
;lop4
;           sta acpapx1+1

            lda:cmp:req 20
            jsr RASTERMUSICTRACKER+3    ;1 playjsr RASTERMUSICTRACKER+3
            lda strig0  ; fire pressed?
            cmp joyFire
            seq
            jmp startit
            sta joyFire

            lda helpfg  ; HELP presed
            cmp #17
            bne @+
            mva #0 helpfg
            jmp initHelp

@
            lda consol  ; read CONSOL
            cmp joyPos
            beq @+
            sta joyPos
            mvx #KEY_SKIP_TIME joyTimer

            cmp #6      ; start
            bne option
startit     lda game_mode
            cmp #MODE_PUZZLE
            seq
            jmp initGame
            lda unlocked
            cmp level
            bmi option
            jmp initGame

option      cmp #3      ; option
            beq ModeUp

            cmp #5      ; select
            beq levelUp

@           dec joyTimer        ; joy move delay
            bpl @+
            mva #0 joyPos

@
            jmp loop_title

levelUp
            lda game_mode       ; check ARCADE MODE
            cmp #MODE_ARCADE
            beq @-1
            ldx #0
            inc level
            lda level
            cmp levelnum
            sne
            stx level
            jsr showLevelT
            jsr showHiscoreT
            jsr showPreview
            jmp @-1

ModeUp
            ldx #0
            inc game_mode
            lda game_mode
            cmp game_mode_num
            sne
            stx game_mode
            lda game_mode       ; check ARCADE MODE
            cmp #MODE_ARCADE
            sne
            stx level
            jsr showLevelT
            jsr showHiscoreT
            jsr showPreview

            jsr showMode
            jsr setHiscore
            jsr showHiscoreT
            jmp @-1

setHiscore
            mwa #hiscoresA hiscores
            lda game_mode
            cmp #MODE_PUZZLE
            sne
            mwa #hiscoresP hiscores
            rts

initGame    ; ****** game initialization (screen and data)

			lda #$f0
			sta RMTSFXVOLUME
			ldx #<MODUL
            ldy #>MODUL                 ;hi byte of RMT module to Y reg
			lda gamemusic
			bne music_on
			lda #$1a
            jsr RASTERMUSICTRACKER      ;Init
			jmp @+

music_on    lda #$0c                    ;starting song line 0-255 to A reg
            jsr RASTERMUSICTRACKER      ;Init

@           mva #STATE_GAME_ON gamestate

            mva #JOY_SKIP_TIME joyTimer
            mva #0 score
            sta escape
            sta moves
            sta line_count
            sta bombs

            lda level
            bne notlvl0
            mwa #0 arcadescore

notlvl0     jsr updateBombs
            jsr initBoard
            jsr scrInitGame
            jsr initPMG
            jsr showBoard
            jsr showLevelG
            jsr showCursor
            jsr updateScore
            jsr updateHiScore
            jsr countMoves

            lda game_mode       ; check ARCADE MODE
            cmp #MODE_ARCADE
            bne @+

            jsr showTimebar
            jsr zeroTimer        ; and set timer
            jsr showTimer
            jsr showGoal

@           lda strig0  ; wait for fire up
            beq @-

            mva #$ff keycode      ; clear char buffer

main_loop   ; ****** main Game loop

            lda:cmp:req 20      ; wait 4 VSYNC

            lda keycode         ; read keyboard
            and #%00111111
            cmp #28             ; esc pressed
            bne @+
            jmp escPressed
@
			cmp #37
			bne @+

			mva #$ff keycode
			ldx #<MODUL
            ldy #>MODUL                 ;hi byte of RMT module to Y reg
			lda gamemusic
			bne turn_off

			mva #1 gamemusic
			lda #$0c
            jsr RASTERMUSICTRACKER      ;Init
			jmp main_loop

turn_off	mva #0 gamemusic
			lda #$1a
            jsr RASTERMUSICTRACKER      ;Init
			jmp main_loop

@
            ldx game_mode       ; check EXPLORE MODE for hint and undo
            cpx #MODE_EXPLORE
            bne @+1

            cmp #57             ; h pressed
            bne @+
            jsr showHint
            jmp main_loop

@           cmp #11             ; u pressed
            bne @+
            jsr undo

@
            lda stick0          ; Check if stick moved
            cmp joyPos
            seq
            jsr movedStick
            dec joyTimer        ; joy move delay
            sne
            mva #0 joyPos       ; reset joyPos after delay

            lda strig0          ; check FIRE button
            cmp joyFire
            seq
            jsr pressedFire

            lda game_mode       ; check ARCADE MODE for Timer display
            cmp #MODE_ARCADE
            bne @+

            jsr updateTimer     ; update timer
            lda #0
            cmp timer
            bpl game_over       ; check time

@           lda gamestate
            cmp #STATE_GAME_OVER
            beq game_over

            jmp main_loop


updateTop5  ldx #0
@           mwa top5,x src
            cpw src arcadescore
            bcc new_record
            inx:inx
            cpx #10
            beq no_rec
            jmp @-

new_record  mwa arcadescore top5,x

@           inx:inx
            cpx #10
            beq savetop5
            mwa top5,x dest
            mwa src top5,x
            mwa dest src
            jmp @-

savetop5    jsr safeSave

no_rec      rts

game_over   ; ****** game over screen

            jsr hideGuide

@           lda game_mode       ; if EXPLORE MODE not save hiscore
            cmp #MODE_EXPLORE
            beq @+

            ldy level
            lda (hiscores),y
            cmp score
            bpl @+
            lda score
            sta (hiscores),y
            jsr safeSave

@           lda game_mode       ; if ARCADE MODE check if goal reached
            cmp #MODE_ARCADE
            bne @+

            lda score
            cmp goal
            bmi arcade_end
            jmp level_up
arcade_end
            jsr updateTop5

@           jsr showOver

            mva strig0 joyFire
@           lda:cmp:req 20          ; wait 4 VSYNC

			lda strig0
            cmp joyFire
            beq @-
@           lda strig0
            beq @-

            mva #42 splitpmg

            jmp initTitle

level_up
            jsr showLvlUp
            mva strig0 joyFire
@           lda:cmp:req 20          ; wait 4 VSYNC

			lda strig0
            cmp joyFire
            beq @-
@           lda strig0
            beq @-
            mva #42 splitpmg

			inc level
			lda level		; unlock level
			cmp unlocked
		 	beq @+
			bmi @+
		 	sta unlocked
		 	jsr safeSave

@
            lda levelnum
            cmp level
            beq endGame
            jmp initGame

endGame     dec level
            jsr updateTop5  ; LAST LEVEL REACHED
            jmp initTitle

undo
            lda line_count
            sne
            jmp undoend
            dec line_count
            dec score
            ldx line_count
            mva line_cx,x start_x
            mva line_cy,x start_y
            jsr getOffset
            mwa start_offset dataw


            ldy #0
            adw dataw #board src
            lda (src),y
            and #%11111110
            eor #%10000000
            sta (src),y

            ldx line_count
            mva line_dir,x line_bit
            mva line_sx,x start_x
            mva line_sy,x start_y
            jsr getOffset
            mwa start_offset boardPos

            mva #BOARD_SIZE+1 pos_offset    ; offset for linebit = 4 '\'

            lda #2
            bit line_bit
            beq @+
            mva #1 pos_offset;              ; offset for linebit = 2 '-'

@           lda #8
            bit line_bit
            beq @+
            mva #BOARD_SIZE pos_offset      ; offset for linebit = 8 '|'

@           lda #16
            bit line_bit
            beq @+
            dew boardPos
            mva #BOARD_SIZE-1 pos_offset    ; offset for linebit = 16 '/'

@           adw boardPos #board src
            ldy #0
            ldx #4
@           lda (src),y
            eor line_bit                    ; 'xor' line_bit with cell content
            sta (src),y
            tya
            adc pos_offset
            tay
            dex
            bne @-

            jsr updateSearch
            jsr countMoves
            jsr updateScore
            jsr showBoard


undoend     mva #$ff keycode
            rts

initHelp    ; ****** help initialization

            mva #STATE_HELP gamestate
            jsr scrInitHelp
            jsr initPMG

            lda #0
            :4 sta sizep:1
            :4 sta hposp:1
            :4 sta hposm:1
            :4 sta colpm:1

            mva strig0 joyFire
            ldx #0
            jsr frame0

loop_help
            lda:cmp:req 20

            jsr helpAnimate


            lda strig0  ; fire pressed?
            cmp joyFire
            seq
            jmp initTitle_
            sta joyFire

            jmp loop_help

sh_1_base   equ 513
sh_2_base   equ 364

helpAnimate
            lda 20
            :2 asl
            bne no_frame
            inx ;next frame
            cpx #4
            sne
            ldx #0
            cpx #0
            sne
            jmp frame0
            cpx #1
            sne
            jmp frame1
            cpx #2
            sne
            jmp frame2
            cpx #3
            sne
            jmp frame3
no_frame
            rts

frame0      lda #64
            sta vram_help+sh_1_base
            sta vram_help+sh_1_base+4
            sta vram_help+sh_1_base-36
            sta vram_help+sh_1_base-40
            sta vram_help+sh_1_base-40-39
            sta vram_help+sh_1_base-40-39-39
            sta vram_help+sh_1_base-40-39-39-39

            sta vram_help+sh_2_base+5

            lda #65
            sta vram_help+sh_1_base+1
            sta vram_help+sh_1_base+2
            sta vram_help+sh_1_base+3
            sta vram_help+sh_1_base-36-40
            sta vram_help+sh_1_base-36-40-40
            sta vram_help+sh_1_base-36-40-40-40

            sta vram_help+sh_2_base+1
            sta vram_help+sh_2_base+2
            sta vram_help+sh_2_base+3
            sta vram_help+sh_2_base+4

            rts

frame1      lda #65
            sta vram_help+sh_1_base

            lda #67
            sta vram_help+sh_2_base+0
            sta vram_help+sh_2_base+1
            sta vram_help+sh_2_base+2
            sta vram_help+sh_2_base+3

            lda #80
            sta vram_help+sh_1_base-40
            sta vram_help+sh_1_base-40-39
            sta vram_help+sh_1_base-40-39-39
            sta vram_help+sh_1_base-40-39-39-39
            rts

frame2      lda #67
            sta vram_help+sh_1_base
            sta vram_help+sh_1_base+1
            sta vram_help+sh_1_base+2
            sta vram_help+sh_1_base+3
            lda #65
            sta vram_help+sh_1_base+4

            sta vram_help+sh_2_base+1
            sta vram_help+sh_2_base+2
            sta vram_help+sh_2_base+3
            lda #64
            sta vram_help+sh_2_base

            rts

frame3      lda #73
            sta vram_help+sh_1_base-36
            sta vram_help+sh_1_base-36-40
            sta vram_help+sh_1_base-36-40-40
            sta vram_help+sh_1_base-36-40-40-40
            lda #67
            sta vram_help+sh_2_base+1
            sta vram_help+sh_2_base+2
            sta vram_help+sh_2_base+3
            sta vram_help+sh_2_base+4
            lda #65
            sta vram_help+sh_2_base+5


            rts

;*************************************  MAIN END                **************


;*************************************  CONTROLLER ROUTINES

escPressed  mva #$ff $02fc
            lda #2
            cmp escape
            sne

            jmp game_over
            inc escape
            jmp main_loop


movedStick  ; ******* Checkin stick position, if you know what I mean ;)
            sta joyPos          ; store previous state
            mvx #JOY_SKIP_TIME joyTimer
            cmp #15
            beq check_out
            mvx #0 escape
            eor #15
            lsr                 ; check bit 0001 - up
            bcc check_down
            ldx cursorY
            beq wrap_up
            dec cursorY
            bpl check_down
wrap_up     mvx #BOARD_SIZE-1 cursorY
            jsr showCursor

check_down  lsr                 ; check bit 0010 - down
            bcc check_left
            ldx cursorY
            cpx #BOARD_SIZE-1
            beq wrap_down
            inc cursorY
            bne check_left
wrap_down   mvx #0 cursorY
            jsr showCursor

check_left  lsr                 ; check bit 0100 - left
            bcc check_right
            ldx cursorX
            beq wrap_left
            dec cursorX
            bpl check_right
wrap_left   mvx #BOARD_SIZE-1 cursorX
            jsr showCursor

check_right lsr                 ; check bit 1000 - right
            bcc check_out
            ldx cursorX
            cpx #BOARD_SIZE-1
            beq wrap_right
            inc cursorX
            bne check_out
wrap_right  mvx #0 cursorX
            jsr showCursor

check_out
            jsr moveCursor
            rts

pressedFire ; ****** Check if fire pressed down
            sta joyFire                 ; store previous state
            cmp #1
            sne
            jmp button_up

placeDot    ; ****** Places dot at cursor position
            mva cursorX start_x
            mva cursorY start_y
            jsr getOffset

            adw start_offset #board dest    ; get cell address

            ldy #0
            lda (dest),y
            and #1
            seq
            jmp endDot
            lda (dest),y                ; swap last bit
            eor #1
            sta (dest),y

            jsr findLines

            lda fline_count
            beq nolines                 ; no lines

            jsr selectLine              ; more lines -> select

            jsr drawLine
            jsr showBoard               ; update board
            jsr countMoves
            jsr updateScore

            lda moves
            bne @+

            mva #STATE_GAME_OVER gamestate

@           lda game_mode       ; if ARCADE MODE check if goar reached and change color
            cmp #MODE_ARCADE
            bne @+
            lda score
            cmp goal
            bmi changebgcol
            mva #GAME_BG_GREEN 710
            jmp endDot

changebgcol mva #GAME_BG_COLOR 710
            jmp endDot

@           lda game_mode       ; check PUZZLE MODE for bomb check
            cmp #MODE_PUZZLE
            bne endDot
            lda #0
            cmp bombs
            beq endDot
            dec bombs
            jsr updateBombs
            jmp endDot

nolines     ldy	#$20						;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
			ldx #3						;X = 0			channel (0..3 or 0..7 for stereo module)
			lda #05						;A = 12			note (0..60)
			jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

			ldy #0
            lda (dest),y                ; swap last bit
            eor #1
            sta (dest),y

            lda game_mode       ; check PUZZLE MODE for bomb check
            cmp #MODE_PUZZLE
            beq ispuzzle

            lda game_mode       ; check ARCADE MODE for subtract score
            cmp #MODE_ARCADE
            beq isarcade

            jmp endDot

isarcade    cpw #0 arcadescore
            beq @+
            sed
            sbw arcadescore #1
            cld
@           lda score
            beq endDot
            dec score
            jsr updateScore
            mva #$10 redblink
            jmp endDot

ispuzzle    inc bombs
            jsr updateBombs
            lda #3
            cmp bombs
            beq bombs3
            mva #$10 redblink
            jmp endDot

bombs3      mva #STATE_GAME_OVER gamestate

button_up
endDot
            rts


;*************************************  GAME LOGIC ROUTINES

countMoves  ; ****** Counts remaining moves on board

            lda colpm1      ; toggle cursor color
            eor #$30
            sta colpm1

.ifdef debug_mode
            mva #0 20       ; timer reset
.endif

            mva #0 moves    ; reset counter
            sta start_x     ; and coordinates
            sta start_y
            sta start_offset
            sta start_offset+1
            mwa #board dest

            ldy #0
@                           ; main loop
            lda (dest),y
            bpl @+          ; check 7th bit (is cell qualified for search ?)
            sta current_cell
            eor #1          ; mark it used (or bit 0) for time of search
            sta (dest),y

            jsr findLines

            lda fline_count
            beq notfound

            clc
            adc moves       ; add number of found lines to avail moves
            sta moves

notfound    ldy #0
            lda current_cell ; reset bit 0 after search
            sta (dest),y
@           inw dest         ; increment positions
            inw start_offset ; and coordinates
            inc start_x
            lda #BOARD_SIZE
            cmp start_x
            bne @-1
            sty start_x      ; reset x value to 0
            inc start_y
            cmp start_y
            bne @-1

            jsr updateMoves ; update screen

.ifdef     debug_mode
            mwa #vram_end-3 dest ; show timer
            lda 20
            jsr printNum
.endif

            lda colpm1 ; toggle cursor color
            eor #$30
            sta colpm1

            jsr showBoard

            rts


findLines   ; ****** finds available lines for start_x start_y position

            mva #0 fline_count           ; reset lines counter
            sta x_limit

find2       mva #2 line_bit              ;  - 2
            mva #$a5 cy_change ; lda
            sta sy_change
            mva #$e6 cx_change ; inc
            mva #$c6 sx_change ; dec
            mva #1 pos_offset
            jsr find4Dir

find4       mva #4 line_bit              ;   \ 4
            mva #$e6 cy_change ; inc
            mva #$c6 sy_change ; dec
            mva #BOARD_SIZE+1 pos_offset
            jsr find4Dir

find8       mva #8 line_bit              ;   | 8
            mva #$a5 cx_change ; lda
            sta sx_change ; lda
            dec pos_offset
            jsr find4Dir

find16      mva #16 line_bit             ;   / 16
            mva #$c6 cx_change ; dec
            mva #$e6 sx_change ; inc
            inc x_limit
            dec pos_offset
            jsr find4Dir

            rts

find4Dir    ; ****** finds available lines in direction specified by line_bit : -2  \4  |8  /16
            ; ****** that is real rocket science. be carefull here - it was optimized 3 days.
            mva start_x sx
            mva start_y sy
            mwa start_offset boardPos

            mva #5 step
while5                                  ; while (step < 5)
            mva sx cx
            mva sy cy
            adw boardPos #board-1 src
            mva #1 is_line
            ldx #5
for5
            ldy #1
            lda (src),y
            and #1                     ; test bit 1
            beq no_line
            cpx #1                     ; dont test linebit for last line
            beq for_end
            lda x_limit                ; for linebit 16 test prev cell
            beq @+
            dey
@           lda (src),y
            and line_bit               ; test line bit
            bne no_line

cx_change   inc cx
cy_change   inc cy
            lda #BOARD_SIZE
            cmp cx
            beq no_line                 ; cx >= boardsize
            cmp cy
            beq no_line                 ; cy >= boardsize
            lda cx
            cmp x_limit
            bmi no_line                 ; cx < xlimit

            lda src                     ; increase offset
            clc
            adc pos_offset
            sta src
            scc
            inc src+1

            dex
            bne for5

no_line     dex
            mva #0 is_line
            beq @+
for_end
            lda is_line                 ; found line
            beq @+
            jsr addFline

@           dec step
            beq found

sy_change   dec sy
            bmi found                 ; sy < 0

sx_change   dec sx
            lda sx
            cmp x_limit
            bmi found                 ; sx < xlimit
            cmp #BOARD_SIZE
            bpl found                 ; sx >= boardsize

            sec                       ; decrease offset
            lda boardPos
            sbc pos_offset
            sta boardPos
            scs
            dec boardPos+1

            dex                       ; decrement sx,sy by remaining x (no need to check)
            seq
            bpl @-
            jmp while5
found
            rts

addFline    ; ******* adds line to found lines array

            ldy fline_count
            mva sx fline_sx,y
            mva sy fline_sy,y
            mva start_x fline_cx,y
            mva start_y fline_cy,y
            mva line_bit fline_dir,y
            inc fline_count

            rts

selectLine  ; ******* selects line from found lines array (sets last)

            mva #0 fline_sel

            jsr hideGuide
            jsr showGuide

            lda fline_count
            cmp #1
            jeq draw                    ; one line -> draw


@           lda strig0                  ; wait for trigger release
            cmp #1
            bne @-

            lda stick0
            sta joyPos

sel_loop    lda:cmp:req 20          ; wait 4 VSYNC


            lda game_mode       ; check ARCADE MODE for Timer display
            cmp #MODE_ARCADE
            bne @+
            jsr updateTimer
            lda timer
            bpl @+
            mva #STATE_GAME_OVER gamestate
            rts

@           lda stick0
            cmp joyPos              ; stick moved ?
            beq not_moved
            sta joyPos
            cmp #15                 ; moved to direction
            beq not_moved

            ldx #0

            lda joyPos
            eor #15
            lsr                 ; check bit 0001 - up
            bcs go_next
            lsr                 ; check bit 0010 - down
            bcs go_prev
            lsr                 ; check bit 0100 - left
            bcs go_next
            lsr                 ; check bit 1000 - right
            bcs go_prev
            bcc @+1

go_next     inc fline_sel           ; next line
            lda fline_sel
            cmp fline_count
            bne @+
            stx fline_sel           ; set 0
            jmp @+

go_prev     dec fline_sel           ; prev line
            bpl @+
            mva fline_count fline_sel      ; set max
            dec fline_sel

@			ldy	#$24						;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
			ldx #3						;X = 3			channel (0..3 or 0..7 for stereo module)
			lda #12						;A = 12			note (0..60)
			jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

@           jsr hideGuide
            jsr showGuide


not_moved   lda strig0                  ; wait for trigger press
            cmp #1
            beq sel_loop

draw        jsr hideGuide

            inc fline_sel
            mva fline_sel fline_count

            rts


add4Search  ; ****** Adds cell (at dataw offset) neighbours to search lookup array (sets 7th bit)
            tya                  ; push y on stack
            pha
            ldy #0

            adw dataw #board boardPos
            cpw boardPos #board
            bcc @+
            lda (boardPos),y
            and #%01111111      ; remove cell from lookup array
            sta (boardPos),y

@           adw dataw #board-BOARD_SIZE-1 boardPos    ; upper left
            cpw boardPos #board
            scc
            jsr setBit7

            inw boardPos                              ; upper
            cpw boardPos #board
            scc
            jsr setBit7

            inw boardPos                              ; upper right
            cpw boardPos #board
            scc
            jsr setBit7

            adw dataw #board-1 boardPos               ; on left
            cpw boardPos #board
            scc
            jsr setBit7

            inw boardPos                              ; right
            inw boardPos
            cpw boardPos #level
            scs
            jsr setBit7

            adw dataw #(board+BOARD_SIZE-1) boardPos  ; bottom left
            cpw boardPos #level
            scs
            jsr setBit7

            inw boardPos                              ; bottom
            cpw boardPos #level
            scs
            jsr setBit7

            inw boardPos                              ; bottom right
            cpw boardPos #level
            scs
            jsr setBit7

            pla             ; pull y from stack
            tay
            rts

setBit7     ; ****** sets bit 7 (adds cell at boardPos to lookup table)
            lda (boardPos),y
            bit bit1            ; only when there is no dot at this cell already
            bne @+
            ora #%10000000
            sta (boardPos),y
@
            rts


 icl 'board.asm'

 icl 'screen.asm'

 icl 'levels.asm'

 icl 'fonts.asm'

 icl 'io.asm'

            run main


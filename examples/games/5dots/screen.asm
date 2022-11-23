
;*************************************  SCREEN ROUTINES


scrInitTitle
            mva #0 sdmctl       ; turn off antic
            mva #$40 nmien
            mwa #dlist_title sdlstl   ; set Display List
            mwa #dli_title vdslst     ; set Display List interrupt
            mva >charset_title 756    ; set charset
            lda:cmp:req 20      ; wait 4 VSYNC
            mva #$c0 nmien
            mva #8 hscrol
            mva #34 sdmctl      ; turn on antic
            mva #TITLE_BG_COLOR 710          ; set colors
            mva #SCROLL_COLOR_LIGHT 708
            rts


scrInitGame
            mva #0 sdmctl       ; turn off antic
            mva #$40 nmien
            mwa #dlist_game sdlstl   ; set Display List
            mwa #dli_game vdslst     ; set Display List interrupt
            mva >charset_game 756    ; set charset
            lda:cmp:req 20      ; wait 4 VSYNC
            mva #$c0 nmien
            mva #34 sdmctl      ; turn on antic

            mva #GAME_BG_COLOR 710          ; set colors
            lda #14
            jsr setGameColors

            rts

scrInitHelp
            mva #0 sdmctl       ; turn off antic
            mva #$40 nmien
            mwa #dlist_help sdlstl   ; set Display List
            mwa #dli_help vdslst     ; set Display List interrupt
            mva >charset_game 756    ; set charset
            lda:cmp:req 20      ; wait 4 VSYNC
            mva #$c0 nmien
            mva #34 sdmctl      ; turn on antic

            mva #$e2 710          ; set colors
            jsr setHelpColors

            rts


setHelpColors
            ldx #23
@           lda #12

            cpx #3
            smi
            lda #10

            cpx #6
            smi
            lda #8

            cpx #10
            smi
            lda #6

            cpx #14
            smi
            lda #8

            cpx #17
            smi
            lda #10

            cpx #19
            smi
            lda #12

            cpx #21
            smi
            lda #14
            sta game_colors,x
            dex
            bpl @-
            rts


setGameColors
            ldx #23
@           sta game_colors,x
            dex
            bpl @-
            rts

outdec8s    ; ****** outputs 8bit decimal number without leading zeroes
            ; ****** stolen and adapted from:
            ; ****** http://6502org.wikidot.com/software-output-decimal
            ldx #1
            stx c
            inx
            ldy #$40
o1          sty b
            lsr
o2          rol
            bcs o3
            cmp a,x
            bcc o4
o3          sbc a,x
            sec
o4          rol b
            bcc o2
            tay
            cpx c
            lda b
            bcc o5
            beq o6
            stx c

o5          ora #$10
            jsr output
o6          tya
            ldy #$10
            dex
            bpl o1
            rts

a dta  128,160,200
b .ds  1
c .ds  1

output      sty cy
            ldy pos_offset
            sta (dest),y
            inc pos_offset
            ldy cy
            rts

printNum    ; *** prints 8bit numer from accumulator to position at dest
            mvy #0 pos_offset
            jsr outdec8s
            ldy pos_offset
            lda #0
            sta (dest),y
            rts





;*************************************  DISPLAY LISTS INTERRUPTS

.align $100
dli_game    pha:txa:pha


            ldx hline
            lda game_colors,x
            sta colpf1
            lda timebar_colors,x
            sta $D019
            inc hline
            cpx splitpmg
            bne @+



            mva LOW_COLOR_0 colpm0r     ; set PMG colors
            mva LOW_COLOR_1 colpm1r     ; set PMG colors
            mva LOW_COLOR_2 colpm2r     ; set PMG colors
            mva LOW_COLOR_3 colpm3r     ; set PMG colors

@           pla:tax:pla
            rti

dli_help    pha:txa:pha

            ldx hline
            lda game_colors,x
            sta wsync
            sta colpf1
            inc hline

            pla:tax:pla
            rti

.align $100
dli_title
            pha:txa:pha
            ldx hline
            inc hline
            lda title_colors,x
            sta wsync
            sta colpf1

            cpx #71
            bne @+
            mva >charset_scroll $D409    ; set scroll charset
@
            pla:tax:pla
            rti

;*************************************  PLAYER MISSLE GRAPHICS

initPMG     ; ****** Initializes Playes/Missle graphics
            mva #@dmactl(standard|dma|players|lineX2) sdmctl
            mva >pmg pmbase     ; missiles and players data address
            ldy #0              ; clearing pmg memory
            lda #0
clrPMG      :4 sta  pmg+$200+#*$80,y
            iny
            bpl clrPMG

            mva #17 gprior       ; set priority
            mva #3 pmcntl       ; enable players and missles only

            mva #0 sizem        ; clear PMG initial params

            :4 sta sizep:1
            :4 sta hposp:1
            :4 sta colpm:1
            :4 sta hposm:1

            mva #CURSOR_COLOR_LIGHT colpm0     ; set PMG colors
            sta colpm2
            mva #CURSOR_COLOR_DARK colpm1
            sta colpm3


            rts

initPMG_title  ; ****** Initializes Playes/Missle graphics
            mva #@dmactl(standard|dma|players|missiles|lineX1) sdmctl
            mva >pmg pmbase     ; missiles and players data address
            ldy #0              ; clearing pmg memory
            lda #0
clrPMGt
            :5 sta pmg+$300+#*$100,y
            iny
            bne clrPMGt

            ldy #40
vline1      tya
            sec
            sbc #5
            and #6
            cmp #6
            beq @+
            lda #%00000000
            sta pmg+$300,y
            jmp @+1
@           lda #%10100000
            sta pmg+$300,y
@
            iny
            cpy #200
            bne vline1


            mva #3 pmcntl       ; enable players and missles

            mva #0 sizem        ; clear PMG initial params

            :4 sta sizep:1
            :4 sta hposp:1
            :4 sta hposm:1
            :4 sta colpm:1

            mva #$04 pmg_colors     ; set PMG colors
            mva #$08 pmg_colors+1     ; set PMG colors
            mva #$0c pmg_colors+2     ; set PMG colors
            mva #$0f pmg_colors+3     ; set PMG colors
            mva #$1f 711     ; set PMG colors

            mva #49 hposm0
            mva #206 hposm1
            mva #49 hposm2
            mva #206 hposm3

            mva #17 gprior       ; set priority

            rts
pmg_colors  .ds 4


showOver    ; ****** Animated GAME OVER screen

			ldy	#$26						;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
			ldx #3						;X = 3			channel (0..3 or 0..7 for stereo module)
			lda #1						;A = 12			note (0..60)
			jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

            mva #12 splitpmg

            mva #GAMEOVER_COLOR_0 colpm0     ; set PMG colors
            mva #GAMEOVER_COLOR_1 colpm1     ; set PMG colors
            mva #GAMEOVER_COLOR_2 colpm2     ; set PMG colors
            mva #GAMEOVER_COLOR_3 colpm3     ; set PMG colors
            mva #GAMEOVER_COLOR_4 LOW_COLOR_0     ; set PMG colors
            mva #GAMEOVER_COLOR_5 LOW_COLOR_1     ; set PMG colors
            mva #GAMEOVER_COLOR_6 LOW_COLOR_2     ; set PMG colors
            mva #GAMEOVER_COLOR_7 LOW_COLOR_3     ; set PMG colors

            lda #76                  ; x pos
            sta hposp0
            add #10
            sta hposp1
            add #10
            sta hposp2
            add #10
            sta hposp3

            mva #63 sx

@           lda:cmp:req 20          ; wait 4 VSYNC

            mva sx cx
            mva sx dx
            ldx #23
@           lda sx
            lsr:lsr
            cmp game_colors_min,x
            scs
            lda game_colors_min,x
            sta game_colors,x
            dex
            bne @-


            phr
            sec
            lda #52
            sbc cx
            tay

            cpy #2
            bmi next_line_l-2
            mva #0 pmg+$200-2,y     ; y pos
            sta pmg+$280-2,y
            sta pmg+$300-2,y
            sta pmg+$380-2,y
            sta pmg+$200-1,y     ; y pos
            sta pmg+$280-1,y
            sta pmg+$300-1,y
            sta pmg+$380-1,y

            clc
            lda #49
            adc dx
            tay
            mva #0 pmg+$210+13,y     ; y pos
            sta pmg+$290+13,y
            sta pmg+$310+13,y
            sta pmg+$390+13,y
            sta pmg+$210+12,y     ; y pos
            sta pmg+$290+12,y
            sta pmg+$310+12,y
            sta pmg+$390+12,y


            ldx #0

next_line_u
            sec
            lda #52
            sbc cx
            tay
            bmi next_line_l
            mva GO_G,x pmg+$200,y     ; y pos
            mva GO_A,x pmg+$280,y
            mva GO_M,x pmg+$300,y
            mva GO_E,x pmg+$380,y

next_line_l

            clc
            lda #49
            adc dx
            tay
            cpy #108
            bpl next_step
            mva GO_O,x pmg+$210,y     ; y pos
            mva GO_V,x pmg+$290,y
            mva GO_E,x pmg+$310,y
            mva GO_R,x pmg+$390,y

next_step   dec cx
            inc dx
            inx
            cpx #12
            bne next_line_u

            plr
            dec sx
            dec sx

            smi
            jmp @-1

            rts

showLvlUp   ; ****** Animated WELL DONE screen

            ldy	#$28						;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
			ldx #3						;X = 3			channel (0..3 or 0..7 for stereo module)
			lda #1						;A = 12			note (0..60)
			jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

            mva #12 splitpmg

            mva #WELLDONE_COLOR_0 colpm0     ; set PMG colors
            mva #WELLDONE_COLOR_1 colpm1     ; set PMG colors
            mva #WELLDONE_COLOR_2 colpm2     ; set PMG colors
            mva #WELLDONE_COLOR_3 colpm3     ; set PMG colors
            mva #WELLDONE_COLOR_4 LOW_COLOR_0     ; set PMG colors
            mva #WELLDONE_COLOR_5 LOW_COLOR_1     ; set PMG colors
            mva #WELLDONE_COLOR_6 LOW_COLOR_2     ; set PMG colors
            mva #WELLDONE_COLOR_7 LOW_COLOR_3     ; set PMG colors



            lda #76                  ; x pos
            sta hposp0
            add #10
            sta hposp1
            add #10
            sta hposp2
            add #10
            sta hposp3

            mva #63 sx

@           lda:cmp:req 20          ; wait 4 VSYNC

            mva sx cx
            mva sx dx
            ldx #23
@           lda sx
            lsr:lsr
            cmp game_colors_min,x
            scs
            lda game_colors_min,x
            sta game_colors,x
            dex
            bne @-

            phr
            sec
            lda #52
            sbc cx
            tay

            cpy #2
            bmi n_line_l-2
            mva #0 pmg+$200-2,y     ; y pos
            sta pmg+$280-2,y
            sta pmg+$300-2,y
            sta pmg+$380-2,y
            sta pmg+$200-1,y     ; y pos
            sta pmg+$280-1,y
            sta pmg+$300-1,y
            sta pmg+$380-1,y

            clc
            lda #49
            adc dx
            tay
            mva #0 pmg+$210+13,y     ; y pos
            sta pmg+$290+13,y
            sta pmg+$310+13,y
            sta pmg+$390+13,y
            sta pmg+$210+12,y     ; y pos
            sta pmg+$290+12,y
            sta pmg+$310+12,y
            sta pmg+$390+12,y


            ldx #0

n_line_u
            sec
            lda #52
            sbc cx
            tay
            bmi n_line_l
            mva GO_W,x pmg+$200,y     ; y pos
            mva GO_E,x pmg+$280,y
            mva GO_L,x pmg+$300,y
            mva GO_L,x pmg+$380,y

n_line_l

            clc
            lda #49
            adc dx
            tay
            cpy #108
            bpl @+
            mva GO_D,x pmg+$210,y     ; y pos
            mva GO_O,x pmg+$290,y
            mva GO_N,x pmg+$310,y
            mva GO_E,x pmg+$390,y

@           dec cx
            inc dx
            inx
            cpx #12
            bne n_line_u

            plr
            dec sx
            dec sx

            smi
            jmp @-2

            rts


;*************************************  DISPLAY LISTS


     .align $100                                ; title screen
dlist_title dta b($70),b($70),b($70|128)
            dta b($42|128),a(vram_title)
:3          dta b($02|128)
:56         dta b($0F|128)
:11         dta b($02|128)
            dta b($20)
scrmem      dta b($06|128|16|$40),a(scroll)
            dta b($41),a(dlist_title)


        .align $100                             ; game screen
dlist_game  dta b($70),b($70),b($70|128)
            dta b($42|128),a(vram_game)
:23         dta b($02|128)
            dta b($41),a(dlist_game)


dlist_help  dta b($70),b($70),b($70|128)
            dta b($42|128),a(vram_help)
:23         dta b($02|128)
            dta b($41),a(dlist_game)


;*************************************  VIDEO RAM

; title screen

.align $1000,0
vram_title
            .by 94
:38         .by 126
            .by 94
            :1*40 .by 0
.array      t_top[1*40] .byte = 0
;"  idea_sst^code+msx_bocianu^gfx_kris3d"
"          AnticShop  presents:        "
.enda
            :1*40 .by 0
            :3*40 .by 0
            .by 0
logo        ins 'assets/logo.gr8' +0,+0,2119
            :1*40 .by 0

.array      t_bottom[9*40] .byte = 0
[1*40+3] = "START"*,"/","FIRE"*,"_start"
[3*40+3] = "OPTION"*,"_mode:           "
[5*40+3] = "SELECT"*,"_level:          "
[7*40+3] = "NAME: "
.enda
            .by 94
:38         .by 127
            .by 94
            :20 .by 0
            :400 .by 0


titlebar
.array      topline1[1*40] .byte = 0
"          AnticShop  presents:"
.enda
.array      topline2[1*40] .byte = 0
"  idea_sst^code+msx_bocianu^gfx_kris3d"
.enda
.array      topline3[1*40] .byte = 0
"        Arcade Mode ^ Top Scores"
.enda
.array      topscore1[1*40] .byte = 0
"            1st Place _"
.enda
.array      topscore2[1*40] .byte = 0
"            2nd Place _"
.enda
.array      topscore3[1*40] .byte = 0
"            3rd Place _"
.enda
.array      topscore4[1*40] .byte = 0
"            4th Place _"
.enda
.array      topscore5[1*40] .byte = 0
"            5th Place _"
.enda



.align $400,0 ; game screen

.array      vram_game [24*40] .byte = 0
$42,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$46
[40]:[80]:[120]:[160]:[200]:[240]:[280]:[320]:[360]:[400]:[440]:[480]:[520]:[560]:[600]:[640]:[680]:[720]:[760]:[800]:[840]:[880] = $52
[63]:[103]:[143]:[183]:[223]:[263]:[303]:[343]:[383]:[423]:[463]:[503]:[543]:[583]:[623]:[663]:[703]:[743]:[783]:[823]:[863]:[903] = $48
[920] = $4E,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4A
[106] = "SCORE:"
[186] = "MOVES:"
[466] = "HI SCORE:"
[786] = "LEVEL:"
.enda
vram_end
            ; help screen

.array      vram_help [24*40] .byte = 64
        $42,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$46
[40]:[80]:[120]:[160]:[200]:[240]:[280]:[320]:[360]:[400]:[440]:[480]:[520]:[560]:[600]:[640]:[680]:[720]:[760]:[800]:[840]:[880] = $52
[79]:[119]:[159]:[199]:[239]:[279]:[319]:[359]:[399]:[439]:[479]:[519]:[559]:[599]:[639]:[679]:[719]:[759]:[799]:[839]:[879]:[919] = $48
[920] = $4E,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4A

[41] =  "Game rules:"*,"       "
[73] =  "v",VERSION_H,".",VERSION_Lh,VERSION_Ll
[81] =  "                        "
[121] = "Your goal is to draw       "
[161] = "as many lines as possible.    "
[201] = "                                "
[241] = "To draw a line, put fifth dot in a "
[281] = "row of four other dots. Like this: "
[321] = "                                  "
[357] = 65
[396] = 65,65
[435] = 65,64,65
[474] = 65
[514] = 65,65,65

[361] = "                                 "
[362] = 64,64,64,65,65,65,65,64,64,64
[401] = "You may draw horizontal,        "
[441] = "vertical and diagonal lines    "
[481] = "                              "
[521] = "                             "
[561] = "In ","ARCADE"*," mode, your time is limited "
[601] = "and illegal moves are punished     "
[641] = "                                "
[681] = "In ","PUZZLE"*," you can beat hiscores  "
[721] = "                                   "
[761] = "In ","EXPLORE"*," you can try how to play "
[801] = "It is good starting point      "
[841] = "                            "
[868] = "press ","FIRE"*
.enda


.array  scroll[1024] .byte = 0
"                         "
" we - ANTICSHOP - are proud to present you our new game."
" press HELP to get game rules. if you will find our game"
" funny and/or enjoyable, do not hesitiate to write us     "
" bocianu@gmail.com"
"           "
" greetings and thanks to: "
"ILMENIT, "
"IRATA4, "
"IRON, "
"JHUSAK, "
"KOALA, "
"LAREK, "
"MAREKP, "
"MAROK7, "
"MIKER, "
"MONO, "
"NOSTY, "
"RJ1307, "
"PINOKIO, "
"TDC, "
"XEEN, "
"XXL, "
"YERZMYEY, "
"atarionline.pl  "
"           "
"special thanks for our two voluteer testers "
"MAROK7 and RJ1307"
"                 "
" that is enough of sweet shit for today, let's play! let's fu&*%ng play!"
"                                                                         "
.enda


.array game_colors[24] .byte = 0
.enda

.array timebar_colors[24] .byte = 0
$c6,$c6,$c6,$c6,$c6,$c6
$c8,$c8,$c8,$ca,$ca,$ca
$cd,$cd,$dd,$dd,$ed,$ed
$ea,$ea,$18,$16,$24,$22
.enda


.array game_colors_min[24] .byte = 0
15,14,13,12,11,10,9,8,7,6,5,4,4,5,6,7,8,9,10,11,12,13,14,15
.enda

.array title_colors[90] .byte = 0
15,15,15,15,15
$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
$0F
$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
$0F
$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
$0F
$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C

$0A,$0A,$0A,$0A,$08,$08,$06,$06,$04,$0F,$0f,SCROLL_COLOR_DARK

.enda

timer_label dta d'TIME:         '
goal_label  dta d'GOAL:         '
hiscore_label  dta d'HI SCORE:      '
arcade_label dta d'ARCADE:       '
hint_label  dta d'H'*
            dta d'INT          '
undo_label  dta d'U'*
            dta d'NDO          '


;*************************************  PMG MEMORY

            .align $800
pmg         .ds 2048


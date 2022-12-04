VSYNC   =  $00
VBLANK  =  $01
NUSIZ0  =  $04
NUSIZ1  =  $05
COLUPF  =  $08
COLUBK  =  $09
CTRLPF  =  $0A
REFP0   =  $0B
REFP1   =  $0C
PF0     =  $0D
PF1     =  $0E
PF2     =  $0F
RESP0   =  $10
RESP1   =  $11
RESM0   =  $12
RESM1   =  $13
RESBL   =  $14
_AUDC0   =  $15
_AUDC1   =  $16
_AUDF0   =  $17
_AUDF1   =  $18
_AUDV0   =  $19
_AUDV1   =  $1A
GRP0    =  $1B
GRP1    =  $1C
ENAM0   =  $1D
ENAM1   =  $1E
ENABL   =  $1F
HMP0    =  $20
HMP1    =  $21
HMM0    =  $22
HMM1    =  $23
HMBL    =  $24
HMOVE   =  $2A
HMCLR   =  $2B
INPT4   =  $3C
INPT5   =  $3D

ball_y	=	$40
msg_y	=	$41
pconsol	=	$42
audptr	=	$43

; $81 = background color
; $82 = upper bumper light color
; $83 = upper bumper color
; $84 = left bumper light color
; $85 = left bumper color
; $86 = right bumper light color
; $87 = right bumper color
; $88 = base playfield color (no flashing)
; $89 = playfield color
; $8A = side gradient base color
; $8C = flipper colors
; $8D = lane entry rollover colors
; $8E = left lanes and kicker color
; $8F = message color
; $90 = top thingamajig light color ($2A = extra ball)
; $91 = plunger color
; $92 = top rollover color
; $93 = right lanes and kicker color
; $94 = catch magnet color
; $95 = spinner color
; $96 = drop target 1 color
; $97 = drop target 2 color
; $98 = drop target 3 color
; $99 = drop target 4 color
; $9A = drop target 5 color
; $9B = other player score lo (BCD)
; $9C = other player score med (BCD)
; $9D = other player score hi (BCD)
; $9E = target alternation pattern index
; $9F = multiplier level (1=2x)
; $A0 = last console switch state
; $A1 = effect ID
; $A2 = effect delay
; $A3 = ball fine horizontal position
; $A4 = ball fine vertical position
; $A5 = flags
;	D7=0	Right flipper activated
;	D6=0	Left flipper activated
;	D5=0	Pulling out plunger
;	D4=0	Pushing in plunger
; $A7 = frame counter
; $A8 = flags
;	D7=1	Center post and kickbacks activated
;	D6=1	Player two active
;	D4=1	Spinner has gone around once
; $A9 = flags
;	D6=1	Autoplay mode
;	D1=1	Audio channel 1 active
;	D0=1	Audio channel 0 active
; $AA = high score lo (BCD)
; $AB = high score med (BCD)
; $AC = high score hi (BCD)
; $AD = collision info 1
; $AE = collision info 2
; $AF = collision ID
; $B0 = left flipper frame
; $B6, $B7 = gate/plunger graphic pointer
; $BC = right flipper frame
; $BD = score lo (BCD)
; $BE = score med (BCD)
; $BF = score hi (BCD)
; $C3-C7 = score graphic byte 1
; $C8-CC = score graphic byte 2
; $CD-D1 = score graphic byte 3
; $D2-D6 = score graphic byte 4
; $DC = ball horizontal velocity
; $DD = ball vertical velocity (+ = up)
; $DE = spinner phase
; $DF = spinner speed
; $E0 = ball horizontal position
; $E1 = temporary during rendering
; $E2 = ball vertical position
; $E6, $E7 = multiplier graphic pointer
; $E8, $E9 = left flipper graphic pointer
; $EA, $EB = message byte 1 graphic pointer
; $EC, $ED = message byte 2 graphic pointer
; $EE, $EF = message byte 3 graphic pointer
; $F0, $F1 = message byte 4 graphic pointer
; $F2, $F3 = right flipper graphic pointer
; $F5, $F6 = spinner graphic pointer
; $F7 = center post color

SWCHA   =  $0280
SWACNT  =  $0281
SWCHB   =  $0282
SWBCNT  =  $0283
INTIM   =  $0284
TIM64T  =  $0296

hposp0	equ		$d000
hposp1	equ		$d001
hposp2	equ		$d002
hposp3	equ		$d003
hposm0	equ		$d004
hposm1	equ		$d005
hposm2	equ		$d006
hposm3	equ		$d007
sizep2	equ		$d00a
sizep3	equ		$d00b
sizem	equ		$d00c
grafp0	equ		$d00d
grafp1	equ		$d00e
grafp2	equ		$d00f
grafp3	equ		$d010
trig0	equ		$d010
grafm	equ		$d011
trig1	equ		$d011
colpm0	equ		$d012
colpm1	equ		$d013
colpm2	equ		$d014
colpm3	equ		$d015
colpf0	equ		$d016
colpf1	equ		$d017
colpf2	equ		$d018
colpf3	equ		$d019
colbk	equ		$d01a
prior	equ		$d01b
gractl	equ		$d01d
consol	equ		$d01f
audf1	equ		$d200
audc1	equ		$d201
audf2	equ		$d202
audc2	equ		$d203
audf3	equ		$d204
audc3	equ		$d205
audf4	equ		$d206
audc4	equ		$d207
audctl	equ		$d208
stimer	equ		$d209
irqen	equ		$d20e
skctl	equ		$d20f
porta	equ		$d300
dmactl	equ		$d400
dlistl	equ		$d402
dlisth	equ		$d403
pmbase	equ		$d407
wsync	equ		$d40a
vcount	equ		$d40b
nmien	equ		$d40e


missile_data	equ		$3b00
player0_data	equ		$3c00
player1_data	equ		$3d00
player2_data	equ		$3e00
player3_data	equ		$3f00

		org	$2000
playfield:
		ins		'playfield.mic',0,6400

		org	$3900
dlist:
		dta		$70
		dta		$70
		dta		$70
		dta		$4e,a(playfield)
		:127 dta $0e
		dta		$4e,a(playfield+$1000)
		:64 dta $0e
		dta		$41,a(dlist)

		org	$7800

;==========================================================================
.proc _main
		lda		#0
		ldx		#$40
zp_clear:
		sta		$3f,x
		dex
		bne		zp_clear

		tax
clear_loop:
		sta		missile_data,x
		sta		player0_data,x
		sta		player1_data,x
		sta		player2_data,x
		sta		player3_data,x
		inx
		bne		clear_loop

		lda		#$60
		sta		player0_data+94
		sta		player1_data+94
		sta		player0_data+100
		sta		player1_data+100
		lda		#$f0
		sta		player0_data+95
		sta		player1_data+95
		sta		player0_data+96
		sta		player1_data+96
		sta		player0_data+97
		sta		player1_data+97
		sta		player0_data+98
		sta		player1_data+98
		sta		player0_data+99
		sta		player1_data+99

		lda		#$fe
		sta		player0_data+37
		sta		player0_data+38
		sta		player1_data+37
		sta		player1_data+38
		sta		player2_data+37
		sta		player2_data+38

		lda		#$c0
		sta		player0_data+166
		sta		player0_data+167
		sta		player0_data+168
		sta		player0_data+169
		sta		player1_data+166
		sta		player1_data+167
		sta		player1_data+168
		sta		player1_data+169

		lda		#$c0
		sta		player0_data+201
		sta		player1_data+202
		lda		#$30
		sta		player0_data+202
		sta		player1_data+201

		ldy		#5
arrow_loop:
		lda		LF317,y
		sta		player0_data+42,y
		dey
		bne		arrow_loop

		lda		#0
		sta		irqen
		sta		nmien
		sta		audc1
		sta		audc3

		lda		#124
		cmp:rne	vcount

		mva		#8 consol
		mva		#7 pconsol

		mwa		#dlist dlistl
		mva		#$3d dmactl		;enable display list, narrow playfield, P/M DMA, single line
		mva		#$38 pmbase		;set $3800 as P/M base
		mva		#$03 gractl		;enable P/M load

		mva		#$90 hposm0
		mva		#1 sizem
		mva		#$10 prior

		mva		#$f8 audctl
		mva		#$00 skctl
		sta		wsync
		mva		#$03 skctl
		sta		stimer

		;set B&W/color switch to color so player 2 doesn't go autoplay
		mwa		#8 swchb

		lda		#80
		cmp:rne	vcount
		jmp		start
.endp

;==========================================================================
.proc waitvbl
		;##ASSERT vpos<240
		lda		#240/2
		cmp:rne	vcount

		lda		trig0
		clc
		ror
		ror
		sta		inpt4

		lda		trig1
		clc
		ror
		ror
		sta		inpt5

		lda		porta
		tax
		asl
		asl
		asl
		asl
		sta		swcha
		txa
		lsr
		lsr
		lsr
		lsr
		ora		swcha
		sta		swcha

		;check for OPTION being newly pressed
		lda		consol
		and		#$04
		tax
		eor		#$04
		and		pconsol
		stx		pconsol
		beq		no_option

		;toggle difficulty switches
		lda		swchb
		eor		#$60
		sta		swchb

no_option:

		;copy START and SELECT into game reset/select switches
		lda		consol
		eor		swchb
		and		#3
		eor		swchb
		sta		swchb

		rts
.endp

;==========================================================================
.proc waitNonVbl
		;move ball vertically
		ldx		ball_y
		lda		#0
		sta		missile_data,x
		sta		missile_data+1,x
		sta		missile_data+2,x
		sta		missile_data+3,x
		lda		$e2
		add		#$1f
		cmp		#225
		scc:lda	#225
		tax
		stx		ball_y
		lda		#$02
		sta		missile_data,x
		sta		missile_data+1,x
		sta		missile_data+2,x
		sta		missile_data+3,x
		lda		#0
		sta		missile_data+225
		sta		missile_data+226
		sta		missile_data+227
		sta		missile_data+228
		rts
.endp

;==========================================================================
.proc	updateAudio
		mva		#0 audptr

		lda		_audc0
		and		#$0f
		tax
		lda		_audf0
		and		#$1f
		ora		audio_dtab,x
		tax
		mva		audio_tabs,x audf1
		mva		audio_tabs+$20,x audf2

		lda		_audc1
		and		#$0f
		tax
		lda		_audf1
		and		#$1f
		ora		audio_dtab,x
		tax
		mva		audio_tabs,x audf3
		mva		audio_tabs+$20,x audf4

		lda		_audc0
		and		#$0f
		tax
		lda		_audv0
		and		#$0f
		ora		audio_ctab,x
		sta		audc2

		lda		_audc1
		and		#$0f
		tax
		lda		_audv1
		and		#$0f
		ora		audio_ctab,x
		sta		audc4
		rts
.endp

		org		$7d00

audio_tabs:
audio_lotab:
		:32 dta <((#+1)*57-7)
		:32 dta >((#+1)*57-7)

audio_lotab6:
		:32 dta <((#+1)*57*3-7)
		:32 dta >((#+1)*57*3-7)

audio_lotab31:
		:32 dta <(((#+1)*57*31)/2-7)
		:32 dta >(((#+1)*57*31)/2-7)

audio_ctab:
		dta		$10
		dta		$10
		dta		$20
		dta		$30
		dta		$a0		;$4: pure tone
		dta		$a0		;$5: pure tone
		dta		$a0		;$6: pure tone
		dta		$70
		dta		$80
		dta		$90
		dta		$A0
		dta		$B0
		dta		$a0		;$C: pure tone, div 6
		dta		$D0
		dta		$E0
		dta		$20		;$F: 5-bit poly, div 6

audio_dtab:
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab31
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab6
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab6

		org		$7e00
expand_tab_left:
		:256 dta [#&128]+[#&64]/2+[#&32]/4+[#&16]/8
expand_tab_right:
		:256 dta [#&8]*16+[#&4]*8+[#&2]*4+[#&1]*2

;==========================================================================
		ORG $4000

;==========================================================================
; Playfield colors (based on multiplier)
;
L9004:	dta		$54		;purple
		dta		$84		;blue
		dta		$C4		;green
		dta		$14		;yellow
		dta		$34		;orange

;==========================================================================
; Scoring digit graphics
;
L9009:	dta		a(L901D)
		dta		a(L9022)
		dta		a(L9027)
		dta		a(L902C)
		dta		a(L9031)
		dta		a(L9036)
		dta		a(L903B)
		dta		a(L9040)
		dta		a(L9045)
		dta		a(L904A)

;0
L901D:	dta		%00011000
		dta		%00100100
		dta		%00000000
		dta		%00100100
		dta		%00011000

;1
L9022:	dta		%00000100
		dta		%00000100
		dta		%00000000
		dta		%00000100
		dta		%00000100

;2
L9027:	dta		%00011000
		dta		%00000100
		dta		%00011000
		dta		%00100000
		dta		%00011000

;3
L902C:	dta		%00011000
		dta		%00000100
		dta		%00011000
		dta		%00000100
		dta		%00011000

;4
L9031:	dta		%00100100
		dta		%00100100
		dta		%00011000
		dta		%00000100
		dta		%00000100

;5
L9036:	dta		%00011000
		dta		%00100000
		dta		%00011000
		dta		%00000100
		dta		%00011000

;6
L903B:	dta		%00011000
		dta		%00100000
		dta		%00011000
		dta		%00100100
		dta		%00011000

;7
L9040:	dta		%00011000
		dta		%00000100
		dta		%00000000
		dta		%00000100
		dta		%00000100

;8
L9045:	dta		%00011000
		dta		%00100100
		dta		%00011000
		dta		%00100100
		dta		%00011000

;9
L904A:	dta		%00011000
		dta		%00100100
		dta		%00011000
		dta		%00000100
		dta		%00011000

;==========================================================================
; drop target color tables (by multiplier level)
;
L904F:	dta		$40,$42,$44,$46,$48		;red
L9054:	dta		$32,$34,$36,$38,$3A		;orange
L9059:	dta		$14,$16,$18,$1A,$1C		;yellow
L905E:	dta		$C2,$C4,$C6,$C8,$CA		;green
L9063:	dta		$82,$84,$86,$88,$8A		;blue


;==========================================================================
L9068:	dta		$00,$FF,$00,$FF,$00,$FF,$00,$FF
L9070:	dta		$82,$C2,$82,$32

START:
L9074:
		SEI
		CLD
		LDX    #$00
		LDY    #$00
L907A: ADC    VSYNC,X
		STY    VSYNC,X
		TXS
		INX
		BNE    L907A
		STY    SWACNT
		STY    SWBCNT
		STA    $B9
		JSR    L92B8
L908D:	LDA    #$33
		JMP    L9655

;==========================================================================
L9092:
		JSR    L9153
		LDA    #$1D
		JMP    L96C0

;==========================================================================
L909F:
		jmp		L908D

;==========================================================================
; collision dispatcher
;
L90A6:	LDY    $AF			;load current state
		LDA    L96FA+1,Y
		PHA
		LDA    L96FA,Y
		PHA
		rts

;==========================================================================
; check for collision
;
L90B6:	LDX    $E0			;get horiz ball position
		LDY    $E2			;get vert ball position
		LDA    L9DDE,Y
		STA    $EA
		LDA    L9EA2,Y
		STA    $EB
		CPX    #$50			;check which side we're on
		BCC    L90CB		;branch if left
		JMP    L95A8		;do right side collision check
L90CB:	JMP    L953E		;do left side collision check

;==========================================================================
L90CE:
		jmp		L90B6

;==========================================================================
; advance physics step
;
L90D6:	LDA    #$04
		STA    $AD
		JSR    L9312		;update ball position
		JSR    L90B6		;check for collision
		BMI    L90F8		;branch if so
		JSR    L9312		;update ball position
		JSR    L90B6		;check for collision
		BMI    L90F8		;branch if so
		JSR    L9312		;update ball position
		JSR    L90B6		;check for collision
		BMI    L90F8		;branch if so
		JSR    L9312		;update ball position
		JSR    L90B6		;check for collision
L90F8:	RTS

;==========================================================================
L90F9:
		LDA		#$01
		BIT    SWCHB				;check if GAME RESET is pressed (0=pressed)
		BNE    L9109
		BIT    $A0
		BEQ    L9109
		LDA    #$33
		JMP    L9127
L9109: LDA    #$02
		BIT    SWCHB				;check if GAME SELECT is pressed
		BEQ    L9121
		LDA    INPT4
		AND    INPT5
		BMI    L912D
		LDA    #$08
		BIT    $A8
		BEQ    L912D
		LDA    #$33
		JMP    L9127
L9121: BIT    $A0
		BEQ    L912D
		LDA    #$3C
L9127: STA    $AF
		LDA    #$80
		STA    $AD
L912D:
		LDA    SWCHB
		STA		$A0
		RTS

;==========================================================================
L9133:
		JSR    L949E
		LDA    $A9
		ORA    #$40
		STA    $A9
		LDA    $A7
		AND    #$01
		ORA    #$80
		STA    $A7
		LDA    $A6
		AND    #$FE
		STA    $A6
		LDA    #$FF
		STA    $B8
		LDA    #$2D
		STA    $AF
		RTS

L9153:
		JMP		LF69F

;==========================================================================
; bump multiplier level
;
L915E:
		LDX    #<LD046
		LDY    #>LD046
		STX    $D5
		STY    $D6
		LDX    #<LD0AB
		LDY    #>LD0AB
		STX    $D9
		STY    $DA
		LDA    #$00
		STA    $D4
		STA    $D8
		LDA    $A9
		ORA    #$03
		STA    $A9
		LDX    $9F				;get multiplier level
		CPX    #$04				;see if we're already at 5x
		BCS    L9183			;skip if so
		INX						;bump up multiplier level
		STX    $9F				;store mult
L9183:	LDA    L9004,X			;get new playfield color
		STA    $88				;update base playfield color
		STA    $89				;update playfield color
		STA    $83				;update upper bumper color
		STA    $85				;update left bumper color
		STA    $87				;update right bumper color
		STA    $8E				;update left lanes color
		STA    $93				;update right lanes color
		LDA    L904F,X			;get drop target 1 color
		STA    $96				;update drop target 1 color
		LDA    L9054,X			;get drop target 2 color
		STA    $97				;update drop target 2 color
		LDA    L9059,X			;get drop target 3 color
		STA    $98				;update drop target 3 color
		LDA    L905E,X			;get drop target 4 color
		STA    $99				;update drop target 4 color
		LDA    L9063,X			;get drop target 5 color
		STA    $9A				;update drop target 5 color
		LDA    #$2A
		STA    $94				;light catch magnets
		LDA    #$38
		STA    $82				;light up upper bumper
		LDA    #$88
		STA    $84				;light up left bumper
		LDA    #$C8
		STA    $86				;light up right bumper
		LDA    #$38
		STA    $92				;light up top rollovers
		rts

;==========================================================================
L91C6: LDA    $A7
		AND    #$07
		TAX
		LDA    L9068,X
		BEQ    L91EF
		LDA    $DD
		BPL    L91D8
		CMP    #$C2
		BCC    L91DA
L91D8: DEC    $DD
L91DA: LDA    $DC
		BNE    L91EF
		LDA    $DD
		BNE    L91EF
		LDA    $E0
		CMP    #$50
		BCS    L91ED
		INC    $DC
		JMP    L91EF
L91ED: DEC    $DC
L91EF: RTS

;==========================================================================
; display other player score
;
L91F0:
		LDA    $9B
		LDX    $9C
		LDY    $9D
		JMP    L9208

;==========================================================================
; display high score
;
L91F9:
		LDA    $AA
		LDX    $AB
		LDY    $AC
		JMP    L9208

;==========================================================================
; display current player score
;
L9202:
		LDA    $BD
		LDX    $BE
		LDY    $BF

;==========================================================================
; display score
;
L9208:
		STA    $E4			;stash lo digits
		STX    $E5			;stash med digits
		STY    $E6			;stash hi digits
		JSR    L9283		;fetch ones digit graphic
		STX    $EA
		STA    $EB
		LDA    $E4
		JSR    L928E		;fetch tens digit graphic
		STX    $EC
		STA    $ED
		LDA    $E5
		JSR    L9283		;fetch hundreds digit graphic
		STX    $EE
		STA    $EF
		LDA    $E5
		JSR    L928E		;fetch thousands digit graphic
		STX    $F0
		STA    $F1
		LDA    $E6
		JSR    L9283		;fetch 10K digit graphic
		STX    $F2
		STA    $F3
		LDA    $E6
		JSR    L928E		;fetch 100K digit graphic
		STX    $F4
		STA    $F5
		LDX    #$04
		LDY    #$04
L9246:
		LDA    ($F4),Y
		ASL
		STA    $E4
		LDA    ($F2),Y
		LSR
		LSR
		LSR
		LSR
		ORA    $E4
		STA    $C0,X
		LDA    ($F2),Y
		ASL
		ASL
		ASL
		ASL
		STA    $E4
		LDA    ($F0),Y
		LSR
		ORA    $E4
		STA    $C5,X
		LDA    ($EE),Y
		ASL
		ASL
		STA    $E4
		LDA    ($EC),Y
		LSR
		LSR
		LSR
		ORA    $E4
		STA    $CA,X
		LDA    ($EC),Y
		ASL
		ASL
		ASL
		ASL
		ASL
		ORA    ($EA),Y
		STA    $CF,X
		DEX
		DEY
		BPL    L9246
		RTS

;==========================================================================
; fetch digit graphic for right BCD digit
;
L9283:
		AND    #$0F
		ASL
		TAY
		LDX    L9009,Y
		LDA    L9009+1,Y
		RTS

;==========================================================================
; fetch digit graphic for left BCD digit
;
L928E:	AND    #$F0
		LSR
		LSR
		LSR
		TAY
		LDX    L9009,Y
		LDA    L9009+1,Y
		RTS

;==========================================================================
L929B: BIT    $A9
		BMI    L92B7
		LDA    $8A
		CMP    #$12
		BEQ    L92A7
		INC    $8A
L92A7: LDA    $89
		CMP    $88
		BEQ    L92AF
		INC    $89
L92AF: LDA    $81
		CMP    #$00
		BEQ    L92B7
		INC    $81
L92B7: RTS

L92B8: JSR    L949E
		JSR    L951D
		JSR    L9202
		LDA    #$80
		STA    $AD
		LDA    #$48
		STA    $AF
		RTS

;==========================================================================
L92CA:
		JSR    L9312
		JMP    L90B6

;==========================================================================
L92D5:
		LDA    $AD
		AND    #$7F
		STA    $AD
		BEQ    L9309
		LDA    $AE
		STA    $E1
		LDA    $AF
		STA    $E3
		JSR    L9312
		JSR    L90B6
		BPL    L92D5
		LDA    $AF
		CMP    $E3
		BNE    L92F9
		LDA    $AE
		CMP    $E1
		BEQ    L92D5
L92F9: LDA    $B4
		STA    $E0
		LDA    $B5
		STA    $E2
		LDA    $B2
		STA    $A3
		LDA    $B3
		STA    $A4
L9309: LDA    #$00
		STA    $AD
		RTS

;==========================================================================
; ball motion update
;
L9312: DEC    $AD
		LDA    $E0
		STA    $B4
		LDA    $E2
		STA    $B5
		LDA    $A3
		STA    $B2
		LDA    $A4
		STA    $B3
		LDA    $DC
		ASL
		ASL
		CLC
		ADC    $A3
		STA    $A3
		BCC    L9331
		INC    $E0
L9331: LDA    $DC
		LSR
		LSR
		LSR
		LSR
		LSR
		LSR
		LDX    $DC
		BPL    L933F
		ORA    #$FC
L933F: CLC
		ADC    $E0
		STA    $E0
		LDA    $DD
		EOR    #$FF
		TAY
		INY					;apply gravity
		TYA
		ASL
		ASL
		CLC
		ADC    $A4
		STA    $A4
		BCC    L9356
		INC    $E2
L9356: TYA
		LSR
		LSR
		LSR
		LSR
		LSR
		LSR
		CPY    #$00
		BPL    L9363
		ORA    #$FC
L9363: CLC
		ADC    $E2
		STA    $E2
		RTS

;==========================================================================
L9369:
		JMP    L9312

;==========================================================================
; Flipper update routine
;
L9371:	LDX    $BC			;fetch right flipper index
		LDY    $B0			;fetch left flipper index
		LDA    $A5			;check if right flipper is activated
		BMI    L9386		;skip if not
		CPX    #$0B			;check if right flipper is fully activated
		BCS    L938E		;skip if so
		INX					;raise right flipper
		CPX    #$0B			;check if right flipper is fully activated
		BCS    L938E		;skip if so
		INX					;raise right flipper
		JMP    L938E
L9386:	CPX    #$00			;check if right flipper is fully deactivated
		BEQ    L938E		;skip if so
		DEX					;lower right flipper
		BEQ    L938E		;skip if fully deactivated
		DEX					;lower right flipper
L938E:	ASL
		BMI    L939E
		CPY    #$0B
		BCS    L93A6
		INY
		CPY    #$0B
		BCS    L93A6
		INY
		JMP    L93A6
L939E: CPY    #$00
		BEQ    L93A6
		DEY
		BEQ    L93A6
		DEY
L93A6:	STX    $BC			;store right flipper index
		STY    $B0			;store left flipper index
		RTS

;==========================================================================
L93AB:	LDA    $DF			;get spinner speed
		CLC
		ADC    $DE
		STA    $DE			;update spinner phase
		BCC    L93BA		;check if it's looped around
		LDA    $A8			;set spin flag
		ORA    #$10
		STA    $A8
L93BA: LDA    $9E
		AND    #$03
		TAX
		LDA    L9070,X
		STA    $8D
		LDA    $8C
		BIT    $DE
		BPL    L93CC
		AND    #$F6
L93CC: STA    $95
		LDA    $A7
		AND    #$0F
		BNE    L93DA
		LDA    $DF
		BEQ    L93DA
		DEC    $DF
L93DA: RTS

L93DB:
		JMP		LDCF5

L93E6:
		LDA    #$00
		LDX    #$02
L93EA: STA    $BD,X
		STA    $9B,X
		DEX
		BPL    L93EA
		LDA    $A8
		AND    #$20
		STA    $A8
		JSR    L951D
		LDX    #<LD16D
		LDY    #>LD16D
		STX    $D5
		STY    $D6
		LDX    #<LD110
		LDY    #>LD110
		STX    $D9
		STY    $DA
		LDA    $A9
		ORA    #$03
		STA    $A9
L9410:
		JSR    L949E
L9413:
		JSR    L9202
		LDA    $A8
		AND    #$E7
		STA    $A8
		LDA    $A9
		AND    #$1F
		STA    $A9
		LDA    #$00
		STA    $A2
		LDA    $A7
		AND    #$01
		ORA    #$80
		STA    $A7
		LDA    $A6
		AND    #$FE
		STA    $A6
		LDA    #$08
		BIT    $A0			;check B&W/color switch
		BNE    L9444		;skip if set to color
		BIT    $A8			;check current player
		BVC    L9444		;skip if player 1
		LDA    $A9			;load flags
		ORA    #$40			;turn on autoplay flag
		STA    $A9
L9444:	LDA    #$FF
		STA    $B8
		LDA    #$2D
		STA    $AF
		RTS

L944D:
		LDA    #$00
		STA    $A6
		LDA    $A8
		EOR    #$20
		STA    $A8
		LDA    $A9
		AND    #$7F
		STA    $A9
		JMP    L9621

;==========================================================================
; Input processing
;
L9460:	LDA    $A9
		AND    #$20
		BNE    L949D
		LDA    $A8
		AND    #$40
		BNE    L9484
		LDA    SWCHA
		AND    #$F0
		TAX
		AND    #$20
		BNE    L947A
		TXA
		AND    #$3F
		TAX
L947A:	TXA
		BIT    INPT4
		BPL    L9481
		ORA    #$08
L9481: JMP    L949B
L9484: LDA    SWCHA
		ASL
		ASL
		ASL
		ASL
		TAX
		AND    #$20
		BNE    L9494
		TXA
		AND    #$3F
		TAX
L9494: TXA
		BIT    INPT5
		BPL    L949B
		ORA    #$08
L949B: STA    $A5
L949D: RTS

L949E: LDA    #$00
		STA    $81
		LDA    L9004
		STA    $88
		STA    $89
		STA    $83
		STA    $85
		STA    $87
		STA    $8E
		STA    $93
		STA    $91
		LDA    L904F
		STA    $96
		LDA    L9054
		STA    $97
		LDA    L9059
		STA    $98
		LDA    L905E
		STA    $99
		LDA    L9063
		STA    $9A
		LDA    #$2A
		STA    $80
		LDA    #$32
		STA    $92
		LDA    #$24
		STA    $90
		LDA    #$32
		STA    $82
		LDA    #$82
		STA    $84
		LDA    #$C2
		STA    $86
		LDA    #$26
		STA    $94
		LDA    #$86
		STA    $8F
		LDA    #$0C
		STA    $8C
		LDA    #$12
		STA    $8A
		LDA    #$26
		STA    $8B

		LDA    #<LF5CE
		STA    $B6
		LDA    #>LF5CE
		STA    $B7

		LDA    #$00
		STA    $B8
		STA    $9E
		STA    $9F
		LDA    $A8
		AND    #$7F
		STA    $A8
		LDA    #$00
		STA    $DF
		LDA    #$94
		STA    $E0
		LDA    #$C9
		STA    $E2
		RTS

L951D: LDA    #$00
		STA    _AUDC0
		STA    _AUDV0
		STA    _AUDC1
		STA    _AUDV1
		STA    $D4
		STA    $D8
		LDA    #<LD32A
		STA    $D5
		STA    $D9
		LDA    #>LD32A
		STA    $D6
		STA    $DA
		LDA    $A9
		AND    #$FC
		STA    $A9
		RTS

L953E: LDX    $E0
		CPX    #$09
		BCS    L9552
		LDA    #$51
		STA    $AF
		LDA    #$08
		STA    $AE
		LDA    $AD
		ORA    #$80
		STA    $AD
L9552: LDA    #$00
		STA    $E4
L9556: LDY    $E4
		LDA    ($EA),Y
		CMP    #$FF
		BEQ    L95A5
		STA    $E5
		CMP    $E0
		BCC    L9570
		BEQ    L9570
L9566: LDA    $E4
		CLC
		ADC    #$05
		STA    $E4
		JMP    L9556
L9570: INY
		LDA    ($EA),Y
		STA    $E6
		CMP    $E0
		BCC    L9566
		INY
		LDA    ($EA),Y
		STA    $E4
		INY
		LDA    ($EA),Y
		TAX
		INY
		LDA    ($EA),Y
		STA    $AF
		LDA    $E6
		SEC
		SBC    $E5
		CLC
		ADC    #$01
		LSR
		CLC
		ADC    $E5
		STA    $E5
		LDA    $E0
		CMP    $E5
		BCS    L959D
		LDX    $E4
L959D: STX    $AE
		LDA    $AD
		ORA    #$80
		STA    $AD
L95A5: LDA    $AD
		RTS

;==========================================================================
; check for collision (right side)
;
; Inputs:
;	($EA)	Collision check row
;
L95A8:	LDX    $E0
		CPX    #$97
		BCC    L95BC
		LDA    #$51
		STA    $AF
		LDA    #$18
		STA    $AE
		LDA    $AD
		ORA    #$80
		STA    $AD
L95BC: LDA    #$00
		STA    $E4
		LDA    #$9F
		SEC
		SBC    $E0			;flip ball pos to left side
		STA    $E7			;stash reflected pos
L95C7:	LDY    $E4
		LDA    ($EA),Y
		CMP    #$FF			;check for terminator
		BEQ    L961E		;exit if so
		STA    $E5			;stash span left
		CMP    $E7
		BCC    L95E1
		BEQ    L95E1
L95D7:	LDA    $E4
		CLC
		ADC    #$05			;advance pointer
		STA    $E4
		JMP    L95C7		;keep going
L95E1:	INY
		LDA    ($EA),Y
		STA    $E6			;stash span right
		CMP    $E7			;check span right against xpos
		BCC    L95D7		;span is left of ball, skip it
		INY
		LDA    ($EA),Y
		STA    $E4
		INY
		LDA    ($EA),Y
		TAX
		INY
		LDA    ($EA),Y		;read collision ID
		STA    $AF			;stash collision ID
		LDA    $E6			;get span right
		SEC
		SBC    $E5			;subtract span left to get length
		CLC
		ADC    #$01			;add one
		LSR					;compute half length
		CLC
		ADC    $E5			;add span left -> center
		STA    $E5			;store span center
		LDA    $E7			;get xpos
		CMP    $E5			;check against span center
		BCS    L960E		;branch if left
		LDX    $E4
L960E:	TXA
		EOR    #$FF
		CLC
		ADC    #$01
		AND    #$1F
		STA    $AE
		LDA    $AD
		ORA    #$80
		STA    $AD
L961E:	LDA    $AD
		RTS

L9621: LDX    #$02
L9623: LDA    $AA,X
		STA    $BD,X
		DEX
		BPL    L9623
		JSR    L949E
		JSR    L951D
		LDA    $A8
		AND    #$20
		ORA    #$08
		STA    $A8
		LDA    $A9
		AND    #$9F
		STA    $A9
		LDA    $A7
		AND    #$01
		ORA    #$02
		STA    $A7
		LDA    $A6
		AND    #$FE
		STA    $A6
		LDA    #$04			;4 messages to display
		STA    $BA
		LDA    #$4B
		STA    $AF
		RTS

L9655:
		JSR    L90F9
		INC    $B9
		INC    $A7
		BNE    L966B
		INC    $A6
L966B: JSR    L929B
		JSR    L9460		;process input
		JSR    L91C6
		JSR    L93AB
		LDA    $AD
		BPL    L9695
		LDA    $AF
		CMP    #$1B
		BEQ    L9698
		CMP    #$1E
		BEQ    L9698
		CMP    #$27
		BEQ    L9698
		CMP    #$4E
		BEQ    L9698
L9695: JSR    L9371
L9698: LDA    $AD
		BMI    L96A5
		JSR    L9202
		JSR    L96B5
		JMP    L96A8
L96A5:
		JSR    L90A6		;dispatch collision
L96A8:
		JSR    L93DB
L96B2:	JMP    L9092

;==========================================================================
L96B5:
		JMP		LBF2A

;==========================================================================
L96C0:
		LDA    $DC
		BPL    L96CC
		EOR    #$FF
		CLC
		ADC    #$01
L96CC:
		CMP    #$40
		BCS    L96E7
		LDA    $DD
		BPL    L96D9
		EOR    #$FF
		CLC
		ADC    #$01
L96D9: CMP    #$40
		BCS    L96E7
		LDA    $AD
		BMI    L96E4
		JSR    L90D6			;run physics time steps
L96E4:	JMP    L909F
L96E7: LDA    $AD
		BMI    L96E4
		LDA    #$80
		STA    $AD
		LDA    $AF
		STA    $BA
		LDA    #$4E
		STA    $AF
		JMP    L96E4

;==========================================================================
; Collision dispatch table
;
L96FA:
		dta		a(LBA72-1),$01		;$00
		dta		a(LBDC1-1),$01		;$03 outlanes
		dta		a(LBA82-1),$01		;$06 bumper hit
		dta		a(L9133-1),$00		;$09
		dta		a(LBB0C-1),$01		;$0C drain
		dta		a(LD646-1),$02		;$0F
		dta		a(LBB4C-1),$01		;$12 drop target
		dta		a(LD6D6-1),$02		;$15
		dta		a(LD6FC-1),$02		;$18
		dta		a(LB8D3-1),$01		;$1B flippers
		dta		a(LD722-1),$02		;$1E
		dta		a(LBBEC-1),$01		;$21 kickbacks
		dta		a(LBC69-1),$01		;$24 low curves
		dta		a(LBA72-1),$01		;$27
		dta		a(LBA72-1),$01		;$2A
		dta		a(LBCF0-1),$01		;$2D
		dta		a(LBDC1-1),$01		;$30 inlanes
		dta		a(L93E6-1),$00		;$33
		dta		a(LBE19-1),$01		;$36 lower rollovers
		dta		a(LBE6F-1),$01		;$39 upper rollovers
		dta		a(L944D-1),$00		;$3C
		dta		a(LBEA0-1),$01		;$3F catch magnets
		dta		a(LBEEE-1),$01		;$42 spinner
		dta		a(LBEFC-1),$01		;$45
		dta		a(L9621-1),$00		;$48
		dta		a(LDBE5-1),$02		;$4B
		dta		a(LDC4C-1),$02		;$4E
		dta		a(LBA72-1),$01		;$51 verticall walls next to upper flippers
		dta		a(LBF5A-1),$01		;$54
		dta		a(LBF8F-1),$01		;$57 kickers

L9754:	dta		$04,$50,$10,$10,$51,$FF
L975A:	dta		$04,$27,$10,$10,$51,$28,$50,$10,$10,$12,$FF
L9765:	dta		$04,$18,$0F,$0F,$51,$FF
L976B:	dta		$04,$12,$0E,$0E,$51,$FF
L9771:	dta		$04,$0E,$0D,$0D,$51,$FF
L9777:	dta		$04,$0D,$0C,$0C,$51,$FF
L977D:	dta		$04,$0C,$0C,$0C,$51,$FF
L9783:	dta		$04,$0B,$0B,$0B,$51,$FF
L9789:	dta		$04,$0A,$0A,$0A,$51,$12,$13,$1E,$1F,$2A,$14,$17,$00,$01,$2A,$FF
L9799:	dta		$04,$0A,$0A,$0A,$51,$11,$18,$1D,$02,$2A,$FF
L97A4:	dta		$04,$0A,$0A,$0A,$51,$10,$19,$1C,$03,$2A,$FF
L97AF:	dta		$04,$0A,$0A,$0A,$51,$0F,$1A,$1B,$04,$2A,$FF
L97BA:	dta		$04,$09,$09,$09,$51,$0A,$0E,$00,$00,$39,$0F,$1A,$1A,$04,$2A,$FF
L97CA:	dta		$04,$09,$09,$09,$51,$0F,$1B,$1A,$05,$2A,$FF
L97D5:	dta		$04,$09,$09,$09,$51,$0F,$1B,$19,$05,$2A,$FF
L97E0:	dta		$04,$09,$09,$09,$51,$0F,$1C,$19,$06,$2A,$FF
L97EB:	dta		$04,$09,$09,$09,$51,$0F,$1C,$18,$06,$2A,$FF
L97F6:	dta		$04,$09,$09,$09,$51,$0F,$1C,$18,$07,$2A,$FF
L9801:	dta		$0F,$1C,$18,$07,$2A,$FF
L9807:	dta		$0F,$1C,$17,$07,$2A,$FF
L980D:	dta		$0F,$1C,$17,$08,$2A,$FF
L9813:	dta		$0F,$1C,$16,$08,$2A,$FF
L9819:	dta		$0F,$1C,$16,$09,$2A,$FF
L981F:	dta		$10,$1C,$15,$09,$2A,$FF
L9825:	dta		$04,$09,$07,$07,$51,$10,$1C,$15,$0A,$2A,$FF
L9830:	dta		$04,$09,$07,$07,$51,$11,$1C,$14,$0A,$2A,$FF
L983B:	dta		$04,$09,$07,$07,$51,$11,$1C,$14,$0B,$2A,$FF
L9846:	dta		$04,$09,$07,$07,$51,$12,$1B,$13,$0C,$2A,$FF
L9851:	dta		$04,$0A,$07,$07,$51,$13,$1A,$12,$0D,$2A,$4A,$4D,$1E,$1F,$06,$4E,$50,$00,$00,$06,$FF
L9866:	dta		$04,$0A,$07,$07,$51,$14,$17,$11,$10,$2A,$18,$19,$0F,$0E,$2A,$49,$50,$1D,$1D,$06,$FF
L987B:	dta		$04,$0A,$07,$07,$51,$48,$50,$1C,$1C,$06,$FF
L9886:	dta		$04,$0B,$06,$06,$51,$47,$50,$1B,$1B,$06,$FF
L9891:	dta		$04,$0B,$06,$06,$51,$47,$50,$1A,$1A,$06,$FF
L989C:	dta		$04,$0B,$06,$06,$51,$47,$50,$19,$19,$06,$FF
L98A7:	dta		$04,$0B,$06,$06,$51,$47,$50,$18,$18,$06,$FF
L98B2:	dta		$04,$0C,$06,$06,$51,$47,$50,$18,$18,$06,$FF
L98BD:	dta		$04,$0D,$07,$07,$51,$47,$50,$17,$17,$06,$FF
L98C8:	dta		$04,$0D,$07,$07,$51,$47,$50,$16,$16,$06,$FF
L98D3:	dta		$04,$0D,$07,$07,$51,$47,$50,$15,$15,$06,$FF
L98DE:	dta		$04,$0E,$07,$07,$51,$48,$50,$14,$14,$06,$FF
L98E9:	dta		$04,$0E,$07,$07,$51,$49,$50,$13,$13,$06,$FF
L98F4:	dta		$04,$0E,$08,$08,$51,$4A,$4D,$12,$11,$06,$4E,$50,$10,$10,$06,$FF
L9904:	dta		$04,$0E,$08,$08,$51,$FF
L990A:	dta		$04,$0E,$08,$08,$3F,$FF
L9910:	dta		$04,$0E,$0C,$0C,$3F,$FF
L9916:	dta		$04,$0C,$0E,$0E,$3F,$3A,$3D,$1E,$1F,$06,$3E,$41,$00,$00,$06,$42,$45,$01,$02,$06,$FF
L992B:	dta		$04,$0A,$0E,$0E,$3F,$39,$46,$1D,$03,$06,$FF
L9936:	dta		$38,$47,$1C,$04,$06,$FF
L993C:	dta		$37,$48,$1B,$05,$06,$FF
L9942:	dta		$37,$48,$1A,$06,$06,$FF
L9948:	dta		$37,$48,$19,$07,$06,$FF
L994E:	dta		$37,$48,$18,$08,$06,$FF
L9954:	dta		$37,$48,$17,$09,$06,$FF
L995A:	dta		$37,$48,$16,$0A,$06,$FF
L9960:	dta		$37,$48,$15,$0B,$06,$FF
L9966:	dta		$38,$47,$14,$0C,$06,$FF
L996C:	dta		$39,$46,$13,$0D,$06,$FF
L9972:	dta		$3A,$3D,$12,$11,$06,$3E,$41,$10,$10,$06,$42,$45,$0F,$0E,$06,$FF
L9982:	dta		$FF
L9983:	dta		$37,$38,$1C,$1E,$00,$39,$3E,$00,$01,$00,$FF
L998E:	dta		$37,$42,$1A,$02,$00,$FF
L9994:	dta		$37,$44,$18,$03,$00,$FF
L999A:	dta		$37,$46,$16,$03,$00,$FF
L99A0:	dta		$37,$38,$14,$13,$00,$39,$47,$12,$04,$00,$FF
L99AB:	dta		$3B,$48,$12,$05,$00,$FF
L99B1:	dta		$3D,$48,$13,$06,$00,$FF
L99B7:	dta		$04,$09,$07,$07,$51,$3F,$48,$14,$07,$00,$FF
L99C2:	dta		$04,$09,$07,$07,$51,$40,$48,$14,$08,$00,$49,$50,$00,$00,$42,$FF
L99D2:	dta		$04,$09,$07,$07,$51,$41,$48,$14,$0A,$00,$FF
L99DD:	dta		$04,$0A,$06,$06,$51,$42,$48,$13,$0C,$00,$FF
L99E8:	dta		$04,$0A,$06,$06,$54,$43,$44,$12,$11,$00,$45,$45,$10,$10,$00,$46,$47,$0F,$0E,$00,$FF
L99FD:	dta		$04,$0A,$06,$06,$51,$FF
L9A03:	dta		$04,$0B,$06,$06,$51,$FF
L9A09:	dta		$13,$18,$00,$00,$1B,$04,$0B,$06,$06,$54,$FF
L9A14:	dta		$0F,$18,$00,$00,$1B,$04,$0C,$07,$07,$54,$FF
L9A1F:	dta		$0D,$18,$00,$00,$1B,$04,$0C,$07,$07,$54,$FF
L9A2A:	dta		$0D,$18,$00,$00,$1B,$04,$0C,$08,$08,$54,$FF
L9A35:	dta		$12,$18,$00,$00,$1B,$04,$11,$02,$02,$27,$FF
L9A40:	dta		$16,$18,$00,$00,$1B,$04,$15,$02,$02,$27,$FF
L9A4B:	dta		$04,$17,$03,$03,$27,$18,$18,$04,$04,$27,$FF
L9A56:	dta		$04,$18,$06,$06,$51,$FF
L9A5C:	dta		$04,$18,$08,$08,$51,$FF
L9A62:	dta		$04,$18,$0A,$0A,$51,$FF
L9A68:	dta		$04,$16,$0E,$0E,$51,$17,$18,$0D,$0C,$51,$FF
L9A73:	dta		$04,$14,$0D,$0D,$51,$15,$15,$0E,$0E,$51,$FF
L9A7E:	dta		$04,$13,$0C,$0C,$51,$FF
L9A84:	dta		$04,$12,$0C,$0C,$51,$FF
L9A8A:	dta		$04,$11,$0C,$0C,$51,$FF
L9A90:	dta		$04,$10,$0C,$0C,$51,$FF
L9A96:	dta		$04,$0F,$0B,$0B,$51,$FF
L9A9C:	dta		$04,$0E,$0B,$0B,$51,$FF
L9AA2:	dta		$04,$0D,$0A,$0A,$51,$FF
L9AA8:	dta		$04,$0C,$0A,$0A,$51,$FF
L9AAE:	dta		$04,$0B,$09,$09,$51,$FF
L9AB4:	dta		$04,$0A,$08,$08,$51,$FF
L9ABA:	dta		$04,$0A,$08,$08,$51,$10,$11,$1C,$04,$51,$1A,$1B,$1C,$04,$51,$24,$26,$1C,$02,$57,$FF
L9ACF:	dta		$04,$0A,$08,$08,$51,$0F,$12,$1B,$05,$51,$19,$1C,$1B,$05,$51,$23,$28,$1B,$03,$57,$FF
L9AE4:	dta		$04,$0A,$08,$08,$51,$0F,$12,$1A,$06,$51,$19,$1C,$1A,$06,$51,$23,$29,$1A,$04,$57,$FF
L9AF9:	dta		$04,$0A,$08,$08,$51,$0E,$13,$19,$07,$51,$18,$1D,$19,$07,$51,$22,$29,$19,$05,$57,$FF
L9B0E:	dta		$04,$0A,$08,$08,$51,$0E,$13,$19,$07,$51,$18,$1D,$19,$07,$51,$22,$2A,$19,$06,$57,$FF
L9B23:	dta		$04,$0A,$07,$07,$51,$0D,$14,$19,$07,$51,$17,$1E,$19,$07,$51,$21,$2B,$19,$06,$57,$FF
L9B38:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$2B,$18,$06,$57,$FF
L9B4D:	dta		$04,$0A,$08,$08,$51,$0B,$20,$00,$00,$24,$21,$2C,$18,$06,$57,$FF
L9B5D:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$2D,$18,$06,$57,$FF
L9B72:	dta		$04,$0A,$08,$08,$51,$0B,$20,$00,$00,$21,$21,$2E,$18,$06,$57,$FF
L9B82:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$2E,$18,$06,$57,$FF
L9B97:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$2F,$18,$06,$57,$FF
L9BAC:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$30,$18,$06,$57,$FF
L9BC1:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$31,$18,$06,$57,$FF
L9BD6:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$18,$08,$51,$21,$32,$18,$06,$57,$FF
L9BEB:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$17,$1E,$17,$09,$51,$21,$33,$17,$06,$57,$FF
L9C00:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$18,$1D,$16,$0A,$51,$22,$33,$17,$06,$57,$FF
L9C15:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$18,$1D,$14,$0C,$51,$22,$34,$17,$06,$57,$FF
L9C2A:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$19,$1C,$12,$0E,$51,$22,$34,$16,$06,$57,$FF
L9C3F:	dta		$04,$0A,$08,$08,$51,$0D,$14,$18,$08,$51,$22,$34,$14,$07,$57,$FF
L9C4F:	dta		$04,$0A,$08,$08,$51,$0D,$15,$18,$06,$30,$23,$24,$14,$12,$57,$25,$34,$11,$08,$57,$FF
L9C64:	dta		$04,$0A,$08,$08,$51,$0D,$15,$18,$06,$30,$27,$34,$11,$08,$57,$FF
L9C74:	dta		$04,$0A,$08,$08,$51,$0D,$16,$17,$04,$30,$2B,$34,$11,$0A,$57,$FF
L9C84:	dta		$04,$0A,$08,$08,$51,$0E,$18,$17,$02,$30,$2F,$32,$11,$10,$57,$33,$34,$0E,$0C,$57,$FF
L9C99:	dta		$04,$0A,$08,$08,$51,$0E,$1C,$17,$01,$30,$2F,$2F,$00,$00,$36,$FF
L9CA9:	dta		$04,$0A,$08,$08,$51,$0E,$20,$17,$01,$30,$2F,$2F,$00,$00,$36,$FF
L9CB9:	dta		$04,$0A,$08,$08,$51,$0E,$24,$17,$01,$30,$2F,$2F,$00,$00,$36,$FF
L9CC9:	dta		$04,$0A,$08,$08,$51,$0E,$28,$17,$01,$30,$2F,$2F,$00,$00,$36,$FF
L9CD9:	dta		$04,$0A,$08,$08,$51,$0E,$2C,$17,$01,$30,$2F,$2F,$00,$00,$36,$FF
L9CE9:	dta		$43,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$0E,$30,$16,$01,$30,$FF
L9CF9:	dta		$3F,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$0E,$34,$14,$01,$30,$FF
L9D09:	dta		$3B,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$0F,$10,$14,$12,$30,$11,$38,$11,$01,$30,$FF
L9D1E:	dta		$39,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$17,$38,$11,$02,$30,$FF
L9D2E:	dta		$39,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$1F,$38,$11,$04,$30,$FF
L9D3E:	dta		$39,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$27,$38,$11,$08,$30,$FF
L9D4E:	dta		$39,$48,$00,$00,$1B,$04,$0A,$08,$08,$51,$2F,$36,$11,$10,$30,$37,$38,$10,$0C,$30,$FF
L9D63:	dta		$37,$48,$00,$00,$1B,$04,$0B,$06,$06,$03,$FF
L9D6E:	dta		$39,$48,$00,$00,$1B,$04,$0C,$04,$04,$03,$FF
L9D79:	dta		$3B,$48,$00,$00,$1B,$04,$0E,$02,$02,$03,$FF
L9D84:	dta		$3F,$48,$00,$00,$1B,$04,$10,$01,$01,$03,$FF
L9D8F:	dta		$43,$48,$00,$00,$1B,$04,$18,$01,$01,$03,$FF
L9D9A:	dta		$04,$20,$01,$01,$03,$FF
L9DA0:	dta		$04,$28,$01,$01,$03,$FF
L9DA6:	dta		$04,$30,$01,$01,$03,$FF
L9DAC:	dta		$04,$38,$01,$01,$03,$49,$50,$1F,$1F,$45,$FF
L9DB7:	dta		$04,$38,$04,$04,$03,$49,$50,$1C,$1C,$45,$FF
L9DC2:	dta		$04,$38,$06,$06,$03,$49,$50,$1A,$1A,$45,$FF
L9DCD:	dta		$04,$38,$08,$08,$03,$49,$50,$18,$18,$45,$FF
L9DD8:	dta		$04,$50,$00,$00,$0C,$FF

;==========================================================================
; Collision map row pointers
;
L9DDE:
		dta		<L9754
		dta		<L9754
		dta		<L9754
		dta		<L9754
		dta		<L9754
		dta		<L9754
		dta		<L9754
		dta		<L975A
		dta		<L9765
		dta		<L976B
		dta		<L9771
		dta		<L9777
		dta		<L977D
		dta		<L9783
		dta		<L9789
		dta		<L9799
		dta		<L97A4
		dta		<L97AF
		dta		<L97BA
		dta		<L97CA
		dta		<L97D5
		dta		<L97E0
		dta		<L97EB
		dta		<L97F6
		dta		<L9801
		dta		<L9807
		dta		<L980D
		dta		<L980D
		dta		<L9813
		dta		<L9819
		dta		<L981F
		dta		<L9825
		dta		<L9830
		dta		<L983B
		dta		<L9846
		dta		<L9851
		dta		<L9866
		dta		<L987B
		dta		<L9886
		dta		<L9891
		dta		<L989C
		dta		<L98A7
		dta		<L98B2
		dta		<L98B2
		dta		<L98B2
		dta		<L98BD
		dta		<L98C8
		dta		<L98D3
		dta		<L98DE
		dta		<L98E9
		dta		<L98F4
		dta		<L9904
		dta		<L990A
		dta		<L990A
		dta		<L990A
		dta		<L990A
		dta		<L9910
		dta		<L9916
		dta		<L992B
		dta		<L9936
		dta		<L993C
		dta		<L9942
		dta		<L9948
		dta		<L994E
		dta		<L994E
		dta		<L994E
		dta		<L994E
		dta		<L9954
		dta		<L995A
		dta		<L9960
		dta		<L9966
		dta		<L996C
		dta		<L9972
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9982
		dta		<L9983
		dta		<L998E
		dta		<L9994
		dta		<L999A
		dta		<L99A0
		dta		<L99AB
		dta		<L99B1
		dta		<L99B7
		dta		<L99C2
		dta		<L99D2
		dta		<L99DD
		dta		<L99E8
		dta		<L99FD
		dta		<L9A03
		dta		<L9A03
		dta		<L9A09
		dta		<L9A14
		dta		<L9A1F
		dta		<L9A2A
		dta		<L9A2A
		dta		<L9A2A
		dta		<L9A2A
		dta		<L9A2A
		dta		<L9A35
		dta		<L9A40
		dta		<L9A4B
		dta		<L9A56
		dta		<L9A5C
		dta		<L9A5C
		dta		<L9A62
		dta		<L9A68
		dta		<L9A73
		dta		<L9A7E
		dta		<L9A84
		dta		<L9A8A
		dta		<L9A90
		dta		<L9A96
		dta		<L9A96
		dta		<L9A9C
		dta		<L9A9C
		dta		<L9AA2
		dta		<L9AA2
		dta		<L9AA2
		dta		<L9AA8
		dta		<L9AA8
		dta		<L9AA8
		dta		<L9AAE
		dta		<L9AAE
		dta		<L9AAE
		dta		<L9AAE
		dta		<L9AB4
		dta		<L9AB4
		dta		<L9AB4
		dta		<L9AB4
		dta		<L9AB4
		dta		<L9AB4
		dta		<L9ABA
		dta		<L9ACF
		dta		<L9AE4
		dta		<L9AF9
		dta		<L9B0E
		dta		<L9B0E
		dta		<L9B23
		dta		<L9B38
		dta		<L9B4D
		dta		<L9B4D
		dta		<L9B5D
		dta		<L9B5D
		dta		<L9B72
		dta		<L9B82
		dta		<L9B97
		dta		<L9B97
		dta		<L9BAC
		dta		<L9BAC
		dta		<L9BC1
		dta		<L9BC1
		dta		<L9BD6
		dta		<L9BD6
		dta		<L9BEB
		dta		<L9C00
		dta		<L9C15
		dta		<L9C2A
		dta		<L9C3F
		dta		<L9C4F
		dta		<L9C64
		dta		<L9C74
		dta		<L9C84
		dta		<L9C99
		dta		<L9CA9
		dta		<L9CB9
		dta		<L9CC9
		dta		<L9CD9
		dta		<L9CE9
		dta		<L9CF9
		dta		<L9D09
		dta		<L9D1E
		dta		<L9D2E
		dta		<L9D3E
		dta		<L9D4E
		dta		<L9D63
		dta		<L9D63
		dta		<L9D6E
		dta		<L9D79
		dta		<L9D84
		dta		<L9D8F
		dta		<L9D9A
		dta		<L9DA0
		dta		<L9DA6
		dta		<L9DAC
		dta		<L9DB7
		dta		<L9DC2
		dta		<L9DCD
		dta		<L9DCD
		dta		<L9DD8
		dta		<L9DD8

L9EA2:
		dta		>L9754
		dta		>L9754
		dta		>L9754
		dta		>L9754
		dta		>L9754
		dta		>L9754
		dta		>L9754
		dta		>L975A
		dta		>L9765
		dta		>L976B
		dta		>L9771
		dta		>L9777
		dta		>L977D
		dta		>L9783
		dta		>L9789
		dta		>L9799
		dta		>L97A4
		dta		>L97AF
		dta		>L97BA
		dta		>L97CA
		dta		>L97D5
		dta		>L97E0
		dta		>L97EB
		dta		>L97F6
		dta		>L9801
		dta		>L9807
		dta		>L980D
		dta		>L980D
		dta		>L9813
		dta		>L9819
		dta		>L981F
		dta		>L9825
		dta		>L9830
		dta		>L983B
		dta		>L9846
		dta		>L9851
		dta		>L9866
		dta		>L987B
		dta		>L9886
		dta		>L9891
		dta		>L989C
		dta		>L98A7
		dta		>L98B2
		dta		>L98B2
		dta		>L98B2
		dta		>L98BD
		dta		>L98C8
		dta		>L98D3
		dta		>L98DE
		dta		>L98E9
		dta		>L98F4
		dta		>L9904
		dta		>L990A
		dta		>L990A
		dta		>L990A
		dta		>L990A
		dta		>L9910
		dta		>L9916
		dta		>L992B
		dta		>L9936
		dta		>L993C
		dta		>L9942
		dta		>L9948
		dta		>L994E
		dta		>L994E
		dta		>L994E
		dta		>L994E
		dta		>L9954
		dta		>L995A
		dta		>L9960
		dta		>L9966
		dta		>L996C
		dta		>L9972
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9982
		dta		>L9983
		dta		>L998E
		dta		>L9994
		dta		>L999A
		dta		>L99A0
		dta		>L99AB
		dta		>L99B1
		dta		>L99B7
		dta		>L99C2
		dta		>L99D2
		dta		>L99DD
		dta		>L99E8
		dta		>L99FD
		dta		>L9A03
		dta		>L9A03
		dta		>L9A09
		dta		>L9A14
		dta		>L9A1F
		dta		>L9A2A
		dta		>L9A2A
		dta		>L9A2A
		dta		>L9A2A
		dta		>L9A2A
		dta		>L9A35
		dta		>L9A40
		dta		>L9A4B
		dta		>L9A56
		dta		>L9A5C
		dta		>L9A5C
		dta		>L9A62
		dta		>L9A68
		dta		>L9A73
		dta		>L9A7E
		dta		>L9A84
		dta		>L9A8A
		dta		>L9A90
		dta		>L9A96
		dta		>L9A96
		dta		>L9A9C
		dta		>L9A9C
		dta		>L9AA2
		dta		>L9AA2
		dta		>L9AA2
		dta		>L9AA8
		dta		>L9AA8
		dta		>L9AA8
		dta		>L9AAE
		dta		>L9AAE
		dta		>L9AAE
		dta		>L9AAE
		dta		>L9AB4
		dta		>L9AB4
		dta		>L9AB4
		dta		>L9AB4
		dta		>L9AB4
		dta		>L9AB4
		dta		>L9ABA
		dta		>L9ACF
		dta		>L9AE4
		dta		>L9AF9
		dta		>L9B0E
		dta		>L9B0E
		dta		>L9B23
		dta		>L9B38
		dta		>L9B4D
		dta		>L9B4D
		dta		>L9B5D
		dta		>L9B5D
		dta		>L9B72
		dta		>L9B82
		dta		>L9B97
		dta		>L9B97
		dta		>L9BAC
		dta		>L9BAC
		dta		>L9BC1
		dta		>L9BC1
		dta		>L9BD6
		dta		>L9BD6
		dta		>L9BEB
		dta		>L9C00
		dta		>L9C15
		dta		>L9C2A
		dta		>L9C3F
		dta		>L9C4F
		dta		>L9C64
		dta		>L9C74
		dta		>L9C84
		dta		>L9C99
		dta		>L9CA9
		dta		>L9CB9
		dta		>L9CC9
		dta		>L9CD9
		dta		>L9CE9
		dta		>L9CF9
		dta		>L9D09
		dta		>L9D1E
		dta		>L9D2E
		dta		>L9D3E
		dta		>L9D4E
		dta		>L9D63
		dta		>L9D63
		dta		>L9D6E
		dta		>L9D79
		dta		>L9D84
		dta		>L9D8F
		dta		>L9D9A
		dta		>L9DA0
		dta		>L9DA6
		dta		>L9DAC
		dta		>L9DB7
		dta		>L9DC2
		dta		>L9DCD
		dta		>L9DCD
		dta		>L9DD8
		dta		>L9DD8

;==========================================================================

		ORG $5000
		;##ASSERT dw($0101+s)/4096=4+x
LB000: LDA    $FFF6,X
		RTS

LB004:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$01,$01,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$02,$02
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$02,$02,$80,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$02,$02,$80,$80,$80,$80,$80,$80,$38,$60
		dta		$60,$60,$60,$60,$40,$40,$40,$40,$40,$40,$02,$02,$80,$80,$80,$80
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$40,$40,$40,$40,$40,$40,$02,$02
		dta		$80,$80,$A0,$A0,$32,$32,$60,$60,$60,$60,$60,$60,$60,$60,$40,$40
		dta		$40,$40,$02,$02,$A0,$A0,$A0,$A0,$31,$31,$31,$31,$60,$60,$60,$60
		dta		$60,$60,$40,$40,$40,$08,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$31,$31
		dta		$31,$31,$60,$60,$60,$60,$60,$28,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$31,$31,$30,$2F,$2E

LB0EE:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$01,$01,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$02,$02
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$02,$02,$02,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$02,$02,$80,$80,$80,$80,$80,$38,$60
		dta		$60,$60,$60,$60,$40,$40,$40,$40,$40,$40,$40,$02,$02,$02,$80,$80
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$60,$60,$40,$40,$40,$40,$40,$40
		dta		$02,$02,$A0,$A0,$32,$32,$60,$60,$60,$60,$60,$60,$60,$60,$60,$40
		dta		$40,$40,$40,$08,$A0,$A0,$A0,$A0,$31,$31,$31,$31,$31,$31,$60,$60
		dta		$60,$60,$60,$60,$60,$28,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$31,$31,$31,$31,$31,$30,$2F,$2E

LB1C6:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$01,$01,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$02,$02
		dta		$02,$80,$80,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$02,$02,$02,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$02,$02,$02,$80,$80,$80,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$40,$40,$40,$40,$40,$40,$02,$02,$02
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$40,$40,$40,$40
		dta		$40,$08,$A0,$A0,$31,$30,$30,$30,$30,$30,$30,$60,$60,$60,$60,$60
		dta		$60,$60,$60,$28,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$30,$30,$30
		dta		$30,$30,$30,$30,$2F,$2E

LB28C:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$01,$01,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$01,$01
		dta		$01,$01,$80,$80,$80,$80,$80,$80,$80,$80,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$01,$01,$01,$01,$80,$80,$80,$80,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$01,$01,$01,$02,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$60,$40,$40,$40,$40,$40,$40,$40,$08
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60
		dta		$60,$28,$A0,$A0,$31,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
		dta		$30,$30,$2F,$2E

LB340:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$01,$01,$01,$01,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$01,$01,$01,$01,$01,$80,$80,$80,$80,$80,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$01,$01,$01,$01,$02,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$08,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$28
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$60,$60,$60,$30,$30,$30,$30,$30
		dta		$2F,$2E,$A0,$A0,$31,$30,$30,$30,$30,$30,$30,$30,$30,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0

LB3F4:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00
		dta		$00,$80,$80,$80,$80,$80,$80,$80,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$00,$00,$00,$00,$00,$01,$02,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$08,$18,$40,$40,$40
		dta		$40,$40,$40,$40,$60,$60,$60,$40,$40,$60,$60,$60,$60,$28,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$2F,$2F,$2F,$2F,$2E
		dta		$34,$32,$60,$60,$60,$60,$60,$60,$2F,$2F,$2F,$2F,$2F,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$30,$30,$2F,$2F,$2F,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0

LB4A8:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$88,$08,$08
		dta		$08,$08,$08,$08,$08,$08,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00
		dta		$00,$00,$00,$00,$00,$00,$01,$02,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$40,$08,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$40,$60,$60,$60,$28,$18,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$60,$60,$60,$60,$2F,$2F,$2F,$2E,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$60,$2F,$2F,$2F,$2F,$A0,$A0,$A0,$A0
		dta		$34,$32,$60,$60,$60,$60,$2F,$2F,$2F,$2F,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$30,$30,$2F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0

LB56E:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$00,$00,$00
		dta		$00,$00,$00,$00,$01,$02,$80,$80,$00,$00,$00,$00,$00,$00,$00,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$08,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$40,$60,$60,$28,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$60,$60,$60,$60,$60,$60,$2E,$2E,$2E,$18,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$60,$60,$2E,$2E,$2E,$A0,$A0,$A0,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$60,$2E,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$34,$32,$60,$60,$60,$60,$2E,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$30,$30,$2F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0

LB646:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$1F,$1F,$1F,$1F
		dta		$1F,$00,$01,$02,$80,$80,$80,$80,$1F,$1F,$1F,$1F,$1F,$1F,$40,$40
		dta		$40,$40,$40,$40,$40,$08,$80,$80,$1E,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$40,$40,$60,$28,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$40,$60,$60,$60,$60,$60,$2E,$2E,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$60,$2E,$2E,$2E,$A0,$A0,$18,$40,$40,$40
		dta		$60,$60,$60,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$2E,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$34,$32,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$30,$30,$2F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0

LB730:
		dta		$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$1F,$1F,$1F,$00
		dta		$01,$02,$80,$80,$80,$80,$80,$80,$80,$80,$1F,$1F,$1F,$1F,$40,$40
		dta		$40,$40,$40,$08,$80,$80,$80,$80,$1F,$1F,$1F,$1F,$40,$40,$40,$40
		dta		$40,$40,$40,$40,$60,$28,$80,$80,$1E,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$2E,$2E,$1C,$1E,$40,$40,$40,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$18,$40,$40,$40,$40,$40
		dta		$40,$40,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$18,$40,$40,$40
		dta		$60,$60,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$38,$60
		dta		$60,$60,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$34,$32,$60,$60,$60,$60,$2E,$2E,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$31,$30,$30,$2F,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
		dta		$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0

LB81A:
		dta		a(LB004)
		dta		a(LB004)
		dta		a(LB0EE)
		dta		a(LB1C6)
		dta		a(LB28C)
		dta		a(LB340)
		dta		a(LB3F4)
		dta		a(LB4A8)
		dta		a(LB56E)
		dta		a(LB646)
		dta		a(LB730)
		dta		a(LB730)

LB832: LDX    $E0
		LDY    $E2
		CPY    #$96
		BCC    LB844
		CPX    #$50
		BCC    LB841
		JMP    LB898
LB841: JMP    LB85D
LB844: CPX    #$50
		BCC    LB84B
		JMP    LB889
LB84B: JMP    LB84E
LB84E: LDA    $E0
		SEC
		SBC    #$07
		STA    $E1
		LDA    $E2
		SEC
		SBC    #$60
		JMP    LB869
LB85D: LDA    $E0
		SEC
		SBC    #$37
		STA    $E1
		LDA    $E2
		SEC
		SBC    #$AD
LB869: STA    $E3
		ASL
		ASL
		ASL
		CLC
		ADC    $E3
		ASL
		CLC
		ADC    $E1
		TAY
		LDA    $B0					;get left flipper frame
		ASL							;convert to pointer index
		TAX							;
		LDA    LB81A,X				;fetch graphic ptr lo
		STA    $EA					;
		LDA    LB81A+1,X			;fetch graphic ptr hi
		STA    $EB					;
		LDA    ($EA),Y
		STA    $E4
		RTS

LB889: LDA    #$98
		SEC
		SBC    $E0
		STA    $E1
		LDA    $E2
		SEC
		SBC    #$60
		JMP    LB8A4
LB898: LDA    #$68
		SEC
		SBC    $E0
		STA    $E1
		LDA    $E2
		SEC
		SBC    #$AD
LB8A4: STA    $E3
		ASL
		ASL
		ASL
		CLC
		ADC    $E3
		ASL
		CLC
		ADC    $E1
		TAY
		LDA    $BC
		ASL
		TAX
		LDA    LB81A,X
		STA    $EA
		LDA    LB81A+1,X
		STA    $EB
		LDA    ($EA),Y
		TAX
		AND    #$E0
		STA    $E1
		TXA
		EOR    #$FF
		CLC
		ADC    #$01
		AND    #$1F
		ORA    $E1
		STA    $E4
		RTS

;==========================================================================
; Flipper collision routine
;
LB8D3:
		LDA    #$20
		BIT    $A9
		BVC    LB901
		BNE    LB901
		LDA    $B9
		EOR    $A6
		AND    #$03
		BEQ    LB901
		LDA    $A9
		ORA    #$20
		STA    $A9
		LDX    #$08
		LDA    #$04
		JSR    LBD9F
		LDA    $A5
		LDX    $E0
		CPX    #$50
		BCS    LB8FD
		AND    #$BF
		JMP    LB8FF
LB8FD:	AND    #$7F
LB8FF:	STA    $A5
LB901:	JSR    LB832
		BPL    LB937
		LDA    $AD
		AND    #$03
		BEQ    LB921
		JSR    LBCC4
		LDA    $AD
		BMI    LB916
		JMP    LBCE8
LB916: LDA    $AF
		CMP    #$1B
		BEQ    LB901
LB91C:	rts

LB921: JSR    LB988
		JSR    LB832
		BPL    LB937
		JSR    LB988
		JSR    LB832
		BPL    LB937
		LDA    #$00
		STA    $AD
		BEQ    LB91C
LB937: LDA    $E4
		AND    #$1F
		CMP    #$08
		BEQ    LB958
		CMP    #$18
		BEQ    LB953
		LDA    $E4
		AND    #$20
		BNE    LB94E
		DEC    $E2
		JMP    LB95A
LB94E: INC    $E2
		JMP    LB95A
LB953: DEC    $E0
		JMP    LB95A
LB958: INC    $E0
LB95A: BIT    $E4
		BVC    LB964
		JSR    LB832
		JMP    LB937
LB964: LDA    $E4
		STA    $BA
		LDA    $E0
		STA    $B4
		LDA    $E2
		STA    $B5
		LDA    #$80
		STA    $A3
		STA    $B2
		STA    $A4
		STA    $B3
		LDA    #$1E
		STA    $AF
		JMP    LB91C

;==========================================================================
LB981:
		LDA    $A9
		AND    #$DF
		STA    $A9
		RTS

LB988: LDX    $BC
		LDY    $B0
		BIT    $A5
		BMI    LB999
		CPX    #$0B
		BCS    LB9B1
		INC    $BC
		JMP    LB9B1
LB999: CPX    #$00
		BEQ    LB9B1
		LDA    $E2
		CMP    #$96
		BCS    LB9AF
		LDA    $E0
		CMP    #$50
		BCC    LB9AF
		LDA    $E4
		AND    #$20
		BNE    LB9B1
LB9AF: DEC    $BC
LB9B1: BIT    $A5
		BVS    LB9BE
		CPY    #$0B
		BCS    LB9D6
		INC    $B0
		JMP    LB9D6
LB9BE: CPY    #$00
		BEQ    LB9D6
		LDA    $E2
		CMP    #$96
		BCS    LB9D4
		LDA    $E0
		CMP    #$50
		BCS    LB9D4
		LDA    $E4
		AND    #$20
		BNE    LB9D6
LB9D4: DEC    $B0
LB9D6: RTS

;==========================================================================
LB9D7:	dta		a(LBAED-1)		;$00  quiet all bumpers
		dta		a(LBB34-1)		;$02  cycle side gradient and award 5K
		dta		a(LB981-1)		;$04  flipper
		dta		a(LBC57-1)		;$06
		dta		a(LBE07-1)		;$08  lower rollover - 10 points
		dta		a(LBE2B-1)		;$0A  upper rollover
		dta		a(LBF88-1)		;$0C  stop kicker/lane flash

;==========================================================================
; drop target point values (BCD)
;
LB9E5:	dta		a($0100)
		dta		a($0200)
		dta		a($0300)
		dta		a($0200)
		dta		a($0100)

;==========================================================================
; sine/cosine table
;
LB9EF:	dta		$00,$03,$06,$09,$0B,$0D,$0F,$10
LB9F7:	dta		$10,$10,$0F,$0D,$0B,$09,$06,$03
		dta		$00,$FD,$FA,$F7,$F5,$F3,$F1,$F0
		dta		$F0,$F0,$F1,$F3,$F5,$F7,$FA,$FD
		dta		$00,$03,$06,$09,$0B,$0D,$0F,$10

;==========================================================================
LBA17:	dta		$80,$80,$18,$18,$18
		.byte $18,$08,$08,$08,$08,$81,$81,$18,$18,$18,$18,$08,$08,$08,$08,$82
		.byte $82
LBA2D: .byte $00,$1E,$22,$26,$29,$2C,$2F,$32,$34,$36,$38,$3A,$3B,$3C,$3D
LBA3C: .byte $00,$10,$20,$30,$40

;==========================================================================
; target (arrow) position lookup table
LBA41: .byte $02,$03,$04,$03,$02,$01,$00,$01

;==========================================================================
LBA49: .byte $01,$02,$01,$00

;==========================================================================
LBA4D:	LDA    #$08
		BIT    $A8
		BNE    LBA71
		SED
		LDY    $9F			;load multiplier
LBA56:	CLC
		LDA    $BD
		ADC    $E4
		STA    $BD
		LDA    $BE
		ADC    $E5
		STA    $BE
		LDA    $BF
		ADC    #$00
		STA    $BF
		BCC    LBA6D
		INC    $81
LBA6D:	DEY					;decrement mult count
		BPL    LBA56		;repeat until multiplier applied
		CLD
LBA71: RTS

;==========================================================================
; playfield wall collision routine
;
LBA72:	JSR    LBCAE
		BCS    LBA7A
		JMP    LBCE8
LBA7A:	jmp    LBDFC

;==========================================================================
; bumper hit routine (all 3 bumpers)
;
LBA82:
		JSR    LBBC9
		LDX    #<LD23C
		LDY    #>LD23C
		JSR    LBE85
		LDA    #$00
		LDX    #$04
		JSR    LBD9F
		LDA    #$00
		STA    $E4
		LDA    #$01					;100 points
		STA    $E5
		LDA    $88
		ORA    #$0E
		LDX    $E0
		LDY    $E2
		CPY    #$35
		BCS    LBAB3
		STA    $83
		LDA    $82
		CMP    #$38
		BNE    LBACF
		LDA    #$05
		BNE    LBACD
LBAB3:	CPX    #$50
		BCS    LBAC3
		STA    $85
		LDA    $84
		CMP    #$88					;left bumper lit?
		BNE    LBACF				;skip if not
		LDA    #$05					;500 points
		BNE    LBACD
LBAC3:	STA    $87
		LDA    $86
		CMP    #$C8					;right bumper lit?
		BNE    LBACF				;skip if not
		LDA    #$05					;500 points
LBACD:	STA    $E5
LBACF:	LDA    $82
		LDX    $84
		LDY    $86
		CMP    #$38					;upper bumper lit?
		BNE    LBAE5				;skip if not
		CPX    #$88					;left bumper lit?
		BNE    LBAE5				;skip if not
		CPY    #$C8					;right bumper lit?
		BNE    LBAE5				;skip if not
		LDA    #$10					;1000 points
		STA    $E5
LBAE5:	JMP    LBA4D				;award points

;============================================================================
; quiet all bumpers
;
LBAED:
		LDA    $88
		STA    $83
		STA    $85
		STA    $87
		RTS

;============================================================================
LBAF6:	jmp		L90CE

;==========================================================================
; effect dispatch routine
;
LBB01:	LDY    $A1
		LDA    LB9D7+1,Y
		PHA
		LDA    LB9D7,Y
		PHA
		RTS

;==========================================================================
; drain collision routine
;
LBB0C:
		LDA    $DF
		BEQ    LBB15
		DEC    $DF
		JMP    LBB2F
LBB15:
		LDX    #<LD289
		LDY    #>LD289
		JSR    LBE85
		LDA    $A2
		BEQ    LBB27
		LDA    #$00
		STA    $A2
		JSR    LBB01
LBB27: LDA    #$3C
		STA    $BA
		LDA    #$0F
		STA    $AF
LBB2F:	rts

;==========================================================================
LBB34:
		INC    $8A				;cycle side gradient
		LDA    #$00
		STA    $E4
		LDA    #$50
		STA    $E5
		JSR    LBA4D			;award 5000 points
		jmp		L915E

;==========================================================================
; drop target collision routine
;
LBB4C:
		LDX    #$00
		LDA    $E0				;get horizontal position
		CMP    #$38
		BCC    LBB64
		INX
		CMP    #$48
		BCC    LBB64
		INX
		CMP    #$58
		BCC    LBB64
		INX
		CMP    #$68
		BCC    LBB64
		INX
LBB64: STX    $E1
		LDA    $96,X
		CMP    $81
		BEQ    LBBC6
		LDX    #<LD2A2
		LDY    #>LD2A2
		JSR    LBE85
		LDX    $E1
		TXA
		ASL
		TAY
		LDA    LB9E5,Y
		STA    $E4
		LDA    LB9E5+1,Y
		STA    $E5
		LDA    $81				;load background color
		STA    $96,X			;kill drop target
		LDA    $9E
		AND    #$07
		TAY
		LDA    LBA41,Y			;get target position
		CMP    $E1				;check if we hit the target
		BNE    LBBB1
		LDY    #$04
LBB94:	ASL    $E4				;multiply point value 10x (BCD)
		ROL    $E5
		DEY
		BNE    LBB94
		LDA    $A8
		ORA    #$80				;enable center post and kickbacks
		STA    $A8
		LDA    #$2A
		STA    $94				;light up catch magnet
		LDA    #$38
		STA    $82				;light up upper bumper
		LDA    #$88
		STA    $84				;light up middle left bumper
		LDA    #$C8
		STA    $86				;light up middle right bumper
LBBB1:	JSR    LBA4D			;award points

		;check if all drop targets are dropped
		LDX    #$04
LBBB6:	LDA    $96,X			;get drop target color
		CMP    $81				;is it background?
		BNE    LBBC6			;if not, break
		DEX
		BPL    LBBB6

		;woohoo - boost multiplier!
		LDA    #$02
		LDX    #$10
		JSR    LBD9F

LBBC6:	JMP    LBA72

;==========================================================================
; kick routine
;
LBBC9:	JSR    LBCAE
		BCS    LBBD3
		PLA
		PLA
		JMP    LBCE8
LBBD3:	JSR    LBDFC
		LDA    $AE
		AND    #$1F
		TAX
		LDA    $DC
		CLC
		ADC    LB9EF,X
		STA    $DC
		LDA    $DD
		CLC
		ADC    LB9F7,X
		STA    $DD
		RTS

;==========================================================================
; kickback collision routine
;
LBBEC:
		LDY    #$FF
		LDX    $E0
		CPX    #$50
		BCC    LBBFC
		LDY    #$00
		LDA    #$9F
		SEC
		SBC    $E0
		TAX
LBBFC:	LDA    LBA17-11,X
		BMI    LBC0B
		INY
		BEQ    LBC06
		EOR    #$10
LBC06:	STA    $AE
		JMP    LBA72
LBC0B:	AND    #$03
		BNE    LBC1F
		LDA    #$40
		BIT    $A8				;is player 2 active?
		BEQ    LBC17			;if so, test right difficulty switch
		LDA    #$80				;test left difficulty switch
LBC17:	BIT    $A0				;check if we're on easy or hard
		BEQ    LBC22			;branch if easy
		LDA    $A8				;check if kickbacks activated
		BMI    LBC22			;jump if so
LBC1F:	JMP    LBCE8
LBC22:	LDA    #$00				;straight up
		STA    $AE				;set direction
		JSR    LBBC9			;apply kick
		LDX    #<LD23C
		LDY    #>LD23C
		JSR    LBE85
		LDA    #$0C
		LDX    #$04
		JSR    LBD9F
		LDA    $88				;get base playfield color
		ORA    #$0E				;brighten it
		LDX    $E0				;get ball hpos
		CPX    #$50				;check side
		BCS    LBC45			;branch if right
		STA    $8E				;light up left lanes and kicker
		BCC    LBC47
LBC45:	STA    $93				;light up right lanes and kicker
LBC47:	LDA    #$10
		STA    $E4
		LDA    #$00
		STA    $E5
		JMP    LBA4D			;award 10 points

;==========================================================================
LBC57:
		LDX    #<LD2BF
		LDY    #>LD2BF
		JSR    LBE85
		LDA    #$00
		STA    $E4
		LDA    #$05
		STA    $E5
		JMP    LBA4D			;award 5 points

;==========================================================================
; ? collision routine
;
LBC69:
		LDY    #$FF
		LDX    $E0				;get ball hpos
		CPX    #$50				;check which side we're on
		BCC    LBC79			;branch if left
		LDY    #$00
		LDA    #$9F				;reflect position
		SEC
		SBC    $E0
		TAX
LBC79:	LDA    LBA17-11,X
		BMI    LBC88
		INY
		BEQ    LBC83
		EOR    #$10
LBC83: STA    $AE
		JMP    LBA72
LBC88: AND    #$03
		STA    $E4
		LDA    $9E
		AND    #$03
		TAX
		LDA    LBA49,X
		CMP    $E4
		BNE    LBCA7
		LDA    #$06
		LDX    #$04
		CMP    $A1
		BNE    LBCA4
		LDY    #$00
		STY    $A2
LBCA4: JSR    LBD9F
LBCA7: LDA    #$00
		STA    $DC
		JMP    LBCE8

;==========================================================================
LBCAE:
		JMP		LD81D

;==========================================================================
LBCB9:
		jmp		L9369

;==========================================================================
LBCC4: LDA    $AD
		AND    #$7F
		STA    $AD
		jmp		L92CA

;==========================================================================
LBCD5:
		jmp		L92D5

LBCE0:
		jmp		LBCD5

LBCE8:	jmp		LBCD5

LBCF0:
		LDA    $A6
		AND    #$01
		BNE    LBD01
		LDX    #$A0
		BIT    $A8
		BVC    LBD11
		LDX    #$B0
		JMP    LBD11
LBD01: LDA    $A8
		AND    #$07
		TAY
		LDX    LBA3C,Y
		LDA    $90					;get top thingamajig color
		CMP    #$2A					;is it lit up?
		BNE    LBD11
		LDX    #$C0
LBD11: STX    $B1
		LDA    $B8
		CMP    #$0F
		BNE    LBD43
		LSR    $B8
		DEC    $E2
		LDA    #<LF5FD
		SEC
		SBC    $B6
		BPL    LBD29
		EOR    #$FF
		CLC
		ADC    #$01
LBD29: TAX
		LDA    $B9
		AND    #$01
		STA    $E4
		LDA    LBA2D,X
		BEQ    LBD8B
		SEC
		SBC    $E4
		STA    $DD
		LDX    #<LD23C
		LDY    #>LD23C
		JSR    LBE85
		LDA    #$00
LBD43: CMP    #$07
		BNE    LBD8B
		LDA    #$04
		STA    $E4
LBD4B: LDA    #$00
		STA    $DC
		JSR    LBCB9
		LDA    $E2
		CMP    #$AC
		BCC    LBD62
		LDA    #$AC
		STA    $E2
		LDA    #$1F
		STA    $B8
		BNE    LBD8B
LBD62: CMP    #$26
		BCC    LBD6C
		DEC    $E4
		BNE    LBD4B
		BEQ    LBD8B
LBD6C: LSR    $B8
		LDA    #$24
		STA    $90
		LDA    #$32
		STA    $92
		LDA    $A8
		AND    #$07
		TAX
		LDA    LBA3C,X
		STA    $B1
		LDX    #<LD32B
		LDY    #>LD32B
		JSR    LBE85
		LDA    #$00
		BEQ    LBD8D
LBD8B: LDA    #$80
LBD8D: STA    $AD
		rts

LBD94:
		jmp		L9074

;==========================================================================
; start effect routine
;
LBD9F:	STA    $E4
		STX    $E5
		LDA    $A2			;is effect already running?
		BNE    LBDB0		;yes, dispatch the existing one
LBDA7:	LDA    $E4
		STA    $A1			;set effect ID
		LDA    $E5
		STA    $A2			;set effect time
		RTS

;==========================================================================
LBDB0:	JSR    LBDB4
		RTS

;==========================================================================
; effect dispatch
;
LBDB4: LDY    $A1
		LDA    LB9D7+1,Y
		PHA
		LDA    LB9D7,Y
		PHA
		JMP    LBDA7

;==========================================================================
; inlane collision routine
;
LBDC1:	JSR    LBCAE
		LDA    $AE
		BCS    LBDD8
		CMP    #$01
		BEQ    LBDD0
		CMP    #$1F
		BNE    LBDD2
LBDD0: DEC    $E2
LBDD2: JSR    LBCD5
		JMP    LBDF7
LBDD8: CMP    #$01
		BEQ    LBDE0
		CMP    #$1F
		BNE    LBDF4
LBDE0: LDA    $E0
		STA    $B4
		LDA    $A3
		STA    $B2
		DEC    $E2
		LDA    $E2
		STA    $B5
		LDA    #$80
		STA    $A4
		STA    $B3
LBDF4: JSR    LBDFC
LBDF7:	rts

;==========================================================================
LBDFC:
		jmp		LDA6A

LBE07:
		LDX    #<LD2BF
		LDY    #>LD2BF
		JSR    LBE85
		LDA    #$10
		STA    $E4
		LDA    #$00
		STA    $E5
		JMP    LBA4D				;award 10 points

;==========================================================================
; lower rollover collision routine
;
LBE19:
		LDA    #$08
		LDX    #$04
		CMP    $A1
		BNE    LBE25
		LDY    #$00
		STY    $A2
LBE25:	JSR    LBD9F
		JMP    LBCE8

;==========================================================================
; upper rollover collision routine
;
LBE2B:
		LDX    #<LD2BF
		LDY    #>LD2BF
		JSR    LBE85
		LDA    #$38
		STA    $82
		LDA    $92					;get top rollover color
		CMP    #$38					;check if it's lit up
		BNE    LBE62				;skip if not
		LDA    #$2A
		CMP    $90					;check if top thingamajigs are lit up
		BEQ    LBE62				;skip if not
		STA    $90					;light 'er up (this awards extra ball)
		INC    $89
		LDX    #<LD004
		LDY    #>LD004
		STX    $D5
		STY    $D6
		LDX    #<LD025
		LDY    #>LD025
		STX    $D9
		STY    $DA
		LDA    #$00
		STA    $D4
		STA    $D8
		LDA    $A9
		ORA    #$03
		STA    $A9
LBE62:	INC    $9E					;shift target
		LDA    #$00
		STA    $E4
		LDA    #$05
		STA    $E5
		JMP    LBA4D				;award 5 points

;==========================================================================
; upper rollover collision routine
;
LBE6F:
		LDA    $B8
		BNE    LBE82
		LDA    #$0A
		LDX    #$04
		CMP    $A1
		BNE    LBE7F
		LDY    #$00
		STY    $A2
LBE7F: JSR    LBD9F
LBE82: JMP    LBCE8

;==========================================================================
; play sound effect routine
;
; X:Y = effect pointer
;
LBE85:	LDA    $A9			;get flags
		LSR					;check if channel 0 is in use
		BCS    LBE92		;skip if so
		STX    $D5			;set channel 0 to sound effect stream
		STY    $D6
		LDA    #$01			;mark channel 0 in use
		BNE    LBE9B
LBE92:	LSR					;check if channel 1 is in use
		BCS    LBE9F		;skip if so
		STX    $D9			;set channel 1 to sound effect stream
		STY    $DA
		LDA    #$02			;mark channel 1 in use
LBE9B:	ORA    $A9
		STA    $A9
LBE9F:	RTS

;==========================================================================
; catch magnet collision routine
;
LBEA0:
		JSR    LBCAE
		BCS    LBEA8
		JMP    LBCE8
LBEA8:	LDX    #<LD2F8
		LDY    #>LD2F8
		JSR    LBE85
		LDA    $B4
		STA    $E0
		LDA    $B5
		STA    $E2
		LDA    $B2
		STA    $A3
		LDA    $B3
		STA    $A4
		LDA    #$00
		STA    $AD
		STA    $DC					;clear ball horizontal velocity
		STA    $DD					;clear ball vertical velocity
		STA    $E4					;clear point low
		LDA    $E0					;get ball horizontal position
		CMP    #$50					;check if we hit the left or right
		BCS    LBED6				;jump if right
		LDA    #$88
		STA    $84					;light up left bumper
		JMP    LBEDA
LBED6:	LDA    #$C8
		STA    $86					;light up right bumper
LBEDA: LDX    #$01					;100 points for unlit
		LDA    $94					;get catch magnet color
		CMP    #$2A					;check if catch magnets are lit up
		BNE    LBEE4				;skip if not
		LDX    #$10					;1000 points for lit
LBEE4:	STX    $E5
		jmp    LBA4D				;award points

;==========================================================================
; spinner collision routine
;
LBEEE:
		LDA    $DD					;get vertical velocity
		BPL    LBEF7				;jump if positive
		EOR    #$FF					;negate (absolute value)
		CLC							;
		ADC    #$01					;
LBEF7:	STA    $DF					;set spinner speed to ball vertical speed
		JMP    LBCE8

;==========================================================================
LBEFC:
		LDA    #$40
		BIT    $A8
		BEQ    LBF04
		LDA    #$80
LBF04: BIT    SWCHB
		BEQ    LBF27
		LDA    $A8
		BMI    LBF27
LBF0D: LDA    $AD
		AND    #$03
		BNE    LBF19
		LDA    #$00
		STA    $AD
		BEQ    LBF22
LBF19: JSR    LBCC4
		LDA    $AF
		CMP    #$45
		BEQ    LBF0D
LBF22:	rts
LBF27: JMP    LBDC1

;==========================================================================
LBF2A:
		LDA    $A2				;check effect time
		BEQ    LBF35			;skip if no active effect
		DEC    $A2				;decrement effect delay
		BNE    LBF35			;skip if not time yet
		JSR    LBB01			;call effect handler
LBF35:	LDA    $A8				;load flags
		AND    #$10				;check if spinner has gone around
		BEQ    LBF55			;skip if not
		LDX    #<LD319
		LDY    #>LD319
		JSR    LBE85
		LDA    $A8
		AND    #$EF
		STA    $A8				;clear the spin flag
		INC    $9E				;advance target position
		LDA    #$10
		STA    $E4
		LDA    #$00
		STA    $E5
		JSR    LBA4D			;award 10 points
LBF55:	rts
LBF5A:
		JSR    LBCAE
		BCC    LBF62
		JSR    LBDFC
LBF62: LDA    #$00
		STA    $AD
		JSR    LBAF6
		LDA    $AD
		BPL    LBF83
		LDA    $AF
		CMP    #$54
		BNE    LBF83
		LDA    #$10
		BIT    $AE
		BNE    LBF7E
		INC    $E0
		JMP    LBF62
LBF7E: DEC    $E0
		JMP    LBF62
LBF83:	rts
LBF88:
		LDA    $88
		STA    $8E
		STA    $93
		RTS

;==========================================================================
; kicker collision routine
;
LBF8F:
		LDA    $AE
		LDX    $E0
		CPX    #$50
		BCS    LBF9D
		CMP    #$06
		BEQ    LBFA4
		BNE    LBFA1
LBF9D: CMP    #$1A
		BEQ    LBFA4
LBFA1: JMP    LBA72
LBFA4: JSR    LBBC9
		LDX    #<LD23C
		LDY    #>LD23C
		JSR    LBE85
		LDA    #$0C
		LDX    #$04
		JSR    LBD9F
		LDA    $88
		ORA    #$0E
		LDX    $E0
		CPX    #$50
		BCS    LBFC4
		STA    $8E
		JMP    LBFC6
LBFC4: STA    $93
LBFC6: LDA    #$25
		STA    $E4
		LDA    #$00
		STA    $E5
		jmp    LBA4D				;award 25 points

		ORG $6000
		;##ASSERT dw($0101+s)/4096=4+x
LD000: LDA    $FFF6,X
		RTS

;==========================================================================
; sound data
;
;	if bit 7 of first byte is 0:
;		control
;		pitch
;		volume (bit 7 = apply decay)
;		duration
;	else:
;		jump address
;
;

;extra ball (high)
LD004:	dta		$04,$1F,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$0F,$88,$03
		dta		$0B,$00,$00,$0B
		dta		$04,$12,$88,$07
		dta		$04,$0F,$0F,$0F
		dta		$04,$0F,$8F,$0F
		dta		$00

;extra ball (low)
LD025:
		dta		$0C,$1F,$88,$07
		dta		$04,$1F,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$12,$88,$03
		dta		$0B,$00,$00,$0B
		dta		$04,$17,$88,$07
		dta		$04,$12,$0F,$0F
		dta		$04,$12,$8F,$0F
		dta		$00

;multiplier up effect (high)
LD046:
		dta		$04,$17,$08,$07
		dta		$04,$17,$88,$07
		dta		$04,$17,$08,$07
		dta		$04,$17,$88,$07
		dta		$04,$14,$88,$07
		dta		$04,$11,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$14,$88,$07
		dta		$04,$0F,$08,$07
		dta		$04,$0F,$88,$07
		dta		$04,$0F,$08,$07
		dta		$04,$0F,$88,$07
		dta		$04,$0F,$88,$07
		dta		$04,$0D,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$11,$88,$07
		dta		$04,$14,$08,$07
		dta		$04,$14,$88,$07
		dta		$04,$14,$08,$07
		dta		$04,$14,$88,$07
		dta		$04,$14,$88,$07
		dta		$04,$11,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$14,$88,$07
		dta		$04,$17,$88,$07
		dta		$00

;multiplier up effect (low)
LD0AB:
		dta		$04,$1F,$08,$07
		dta		$04,$1F,$88,$07
		dta		$04,$1F,$08,$07
		dta		$04,$1F,$88,$07
		dta		$04,$18,$88,$07
		dta		$04,$14,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$18,$88,$07
		dta		$04,$12,$08,$07
		dta		$04,$12,$88,$07
		dta		$04,$12,$08,$07
		dta		$04,$12,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$18,$08,$07
		dta		$04,$18,$88,$07
		dta		$04,$18,$08,$07
		dta		$04,$18,$88,$07
		dta		$04,$18,$88,$07
		dta		$04,$1F,$88,$07
		dta		$04,$1B,$88,$07
		dta		$04,$18,$88,$07
		dta		$04,$1F,$88,$07
		dta		$00

;new game music	(high)
LD110:
		dta		$04,$1F,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$0F,$88,$07
		dta		$0B,$00,$00,$07
		dta		$04,$0F,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$0F,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$0F,$88,$07
		dta		$04,$12,$88,$07
		dta		$0B,$00,$00,$07
		dta		$04,$12,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$12,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$12,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$12,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$1F,$08,$0F
		dta		$04,$1F,$08,$07
		dta		$04,$1F,$88,$07
		dta		$00

;new game music	(low)
LD16D:
		dta		$0C,$1F,$88,$07
		dta		$04,$1F,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$12,$88,$07
		dta		$0B,$00,$00,$07
		dta		$04,$12,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$12,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$12,$88,$07
		dta		$04,$17,$88,$07
		dta		$0B,$00,$00,$07
		dta		$04,$17,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$17,$88,$01
		dta		$0B,$00,$00,$01
		dta		$04,$17,$88,$07
		dta		$04,$1F,$88,$07
		dta		$04,$17,$88,$07
		dta		$04,$1F,$88,$07
		dta		$0C,$1F,$08,$0F
		dta		$0C,$1F,$08,$07
		dta		$0C,$1F,$88,$07
		dta		$00

;game over (high)
LD1CA:
		dta		$04,$0D,$08,$03
		dta		$04,$0D,$88,$07
		dta		$04,$12,$88,$03
		dta		$04,$13,$88,$03
		dta		$04,$12,$88,$03
		dta		$04,$10,$08,$03
		dta		$04,$10,$88,$07
		dta		$04,$12,$08,$03
		dta		$04,$12,$88,$07
		dta		$0B,$00,$00,$0B
		dta		$04,$0E,$08,$03
		dta		$04,$0E,$88,$07
		dta		$04,$0D,$08,$03
		dta		$04,$0D,$88,$07
		dta		$00

;game over (low)
LD203:
		dta		$04,$12,$08,$03
		dta		$04,$12,$88,$07
		dta		$04,$16,$88,$03
		dta		$04,$17,$88,$03
		dta		$04,$16,$88,$03
		dta		$04,$1B,$08,$03
		dta		$04,$1B,$88,$07
		dta		$04,$16,$08,$03
		dta		$04,$16,$88,$07
		dta		$0B,$00,$00,$0B
		dta		$04,$12,$08,$03
		dta		$04,$12,$88,$07
		dta		$04,$16,$08,$03
		dta		$04,$16,$88,$07
		dta		$00

;launch
LD23C:
		dta		$06,$00,$08,$00
		dta		$06,$01,$08,$00
		dta		$06,$02,$08,$00
		dta		$06,$00,$08,$00
		dta		$06,$01,$08,$00
		dta		$06,$02,$08,$00
		dta		$06,$03,$08,$00
		dta		$06,$04,$08,$00
		dta		$06,$05,$08,$00
		dta		$06,$06,$08,$00
		dta		$06,$07,$08,$00
		dta		$06,$08,$08,$00
		dta		$06,$09,$07,$00
		dta		$06,$0A,$06,$00
		dta		$06,$0B,$05,$00
		dta		$06,$0C,$04,$00
		dta		$06,$0D,$03,$00
		dta		$06,$0E,$02,$00
		dta		$06,$0F,$01,$00
		dta		$00

;drain
LD289:
		dta		$0C,$1A,$08,$03
		dta		$0C,$1B,$07,$03
		dta		$0C,$1C,$06,$03
		dta		$0C,$1D,$05,$03
		dta		$0C,$1E,$04,$03
		dta		$0C,$1F,$03,$03
		dta		$00

;drop target
LD2A2:
		dta		$0F,$00,$08,$01
		dta		$0F,$01,$08,$01
		dta		$0F,$02,$08,$01
		dta		$0F,$03,$08,$01
		dta		$0F,$02,$08,$01
		dta		$0F,$01,$08,$01
		dta		$0F,$00,$08,$01
		dta		$00

;rollover
LD2BF:
		dta		$0C,$08,$08,$00
		dta		$0C,$06,$08,$00
		dta		$0C,$07,$08,$00
		dta		$0C,$05,$08,$00
		dta		$0C,$06,$08,$00
		dta		$0C,$04,$08,$00
		dta		$0C,$05,$08,$00
		dta		$0C,$03,$08,$00
		dta		$0C,$04,$08,$00
		dta		$0C,$02,$08,$00
		dta		$0C,$03,$08,$00
		dta		$0C,$01,$08,$00
		dta		$0C,$02,$08,$00
		dta		$0C,$00,$08,$00
		dta		$00

;catch magnet
LD2F8:
		dta		$0F,$07,$08,$00
		dta		$0F,$06,$08,$00
		dta		$0F,$05,$08,$00
		dta		$0F,$04,$08,$00
		dta		$0F,$03,$08,$00
		dta		$0F,$02,$08,$00
		dta		$0F,$01,$08,$00
		dta		$0F,$00,$08,$00
		dta		$00

;spinner
LD319:
		dta		$06,$03,$08,$00
		dta		$06,$02,$08,$00
		dta		$06,$01,$08,$00
		dta		$06,$00,$08,$00
		dta		$00

;silence
LD32A:
		dta		$00

;emerge
LD32B:
		dta		$04,$1F,$08,$00
		dta		$04,$1E,$08,$00
		dta		$04,$1D,$08,$00
		dta		$04,$1C,$08,$00
		dta		$04,$1B,$08,$00
		dta		$04,$1A,$08,$00
		dta		$04,$19,$08,$00
		dta		$04,$18,$08,$00
		dta		$04,$17,$08,$00
		dta		$04,$16,$08,$00
		dta		$04,$15,$08,$00
		dta		$04,$14,$08,$00
		dta		$04,$13,$08,$00
		dta		$04,$12,$08,$00
		dta		$00

;==========================================================================
; score sequences?
;
LD364:	dta		$60,a(L9202-1)
		dta		$A0,a(L9202-1)
		dta		$70,a(L91F9-1)

LD36D:	dta		$60,a(L91F0-1)
		dta		$A0,a(L9202-1)
		dta		$B0,a(L91F0-1)
		dta		$70,a(L91F9-1)

;==========================================================================
LD379:	dta		$00,$02,$03,$05,$06,$08,$09,$0B,$0C,$0E,$0F,$0F,$0F,$0F,$0F,$0F
		dta		$0F,$0F

LD38B:	dta		$00,$01,$02,$04,$05,$06,$07,$08,$0A,$0B,$0C,$0C,$0C,$0C,$0C,$0C
		dta		$0C,$0C

LD39D:	dta		$00,$0A,$02,$03,$04,$04,$05,$06,$07,$08,$09,$09,$09,$09,$09,$09
		dta		$09,$09

LD3AF:	dta		$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05
		dta		$05,$05

LD3C1:	dta		$00,$00,$00,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02,$02
		dta		$02,$02

LD3D3:	dta		$00,$05,$0A,$0E,$13,$18,$1D,$21,$26,$2B,$30,$30,$30,$30,$30,$30
		dta		$30,$30

LD3E5:	dta		$00,$05,$0A,$0F,$13,$18,$1D,$22,$27,$2C,$31,$31,$31,$31,$31,$31
		dta		$31,$31

LD3F7:	dta		$00,$05,$0A,$0F,$14,$19,$1E,$22,$27,$2C,$31,$31,$31,$31,$31,$31
		dta		$31,$31

LD409:	dta		$00,$05,$0A,$0F,$14,$19,$1E,$23,$28,$2D,$32,$32,$32,$32,$32,$32
		dta		$32,$32

LD41B:	dta		$00,$05,$0A,$0F,$14,$19,$1E,$23,$28,$2D,$32,$32,$32,$32,$32,$32
		dta		$32,$32

LD42D:
		dta		a(LD379)
		dta		a(LD379)
		dta		a(LD38B)
		dta		a(LD39D)
		dta		a(LD3AF)
		dta		a(LD3C1)
		dta		a(LD3C1)
		dta		a(LD3AF)
		dta		a(LD39D)
		dta		a(LD38B)
		dta		a(LD379)
		dta		a(LD379)

LD445:
		dta		a(LD3D3)
		dta		a(LD3D3)
		dta		a(LD3E5)
		dta		a(LD3F7)
		dta		a(LD409)
		dta		a(LD41B)
		dta		a(LD41B)
		dta		a(LD409)
		dta		a(LD3F7)
		dta		a(LD3E5)
		dta		a(LD3D3)
		dta		a(LD3D3)

LD45D: .byte $80,$77,$5F,$3A,$10,$1A,$3F,$57
LD465: .byte $60,$57,$3F,$1A,$10,$3A,$5F,$77,$80,$77,$5F,$3A,$10,$1A,$3F,$57
LD475: .byte $00,$2A,$4F,$67,$70,$67,$4F,$2A,$00,$2A,$4F,$67,$70,$67,$4F,$2A
LD485: .byte $00,$7A,$32,$DC,$00,$DC,$32,$7A
LD48D: .byte $00,$7A,$32,$DC,$00,$DC,$32,$7A,$00,$7A,$32,$DC,$00,$DC,$32,$7A
LD49D: .byte $00,$DC,$32,$79,$00,$79,$32,$DC,$00,$DC,$32,$79,$00,$79,$32,$DC
LD4AD: .byte $00,$00,$00,$00
LD4B1: .byte $00,$FF,$FF,$FF
LD4B5: .byte $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF

;==========================================================================
; Message pointer table
;
LD4C5:
		dta		a(LF13A),a(LF143),a(LF14C),a(LF155),a(LF15E),a(LF23F),a(LF248),a(LF15E)
		dta		a(LF13A),a(LF143),a(LF14C),a(LF155),a(LF15E),a(LF305),a(LF30E),a(LF15E)
		dta		a(LF13A),a(LF143),a(LF14C),a(LF155),a(LF2E1),a(LF2EA),a(LF2F3),a(LF2FC)
		dta		a(LF13A),a(LF143),a(LF14C),a(LF155),a(LF19D),a(LF1A6),a(LF1AF),a(LF1B8)
		dta		a(LF13A),a(LF143),a(LF14C),a(LF155),a(LF15E),a(LF18B),a(LF194),a(LF15E)
		dta		a(LF167),a(LF170),a(LF179),a(LF182),a(LF116),a(LF11F),a(LF128),a(LF131)
		dta		a(LF1C1),a(LF1CA),a(LF1D3),a(LF1DC),a(LF251),a(LF25A),a(LF263),a(LF26C)
		dta		a(LF15E),a(LF1E5),a(LF1EE),a(LF15E),a(LF299),a(LF2A2),a(LF2AB),a(LF2B4)
		dta		a(LF21B),a(LF224),a(LF22D),a(LF236),a(LF1F7),a(LF200),a(LF209),a(LF212)
		dta		a(LF15E),a(LF23F),a(LF248),a(LF15E),a(LF275),a(LF27E),a(LF287),a(LF290)
		dta		a(LF275),a(LF27E),a(LF287),a(LF290),a(LF15E),a(LF23F),a(LF248),a(LF15E)
		dta		a(LF275),a(LF27E),a(LF287),a(LF290),a(LF15E),a(LF305),a(LF30E),a(LF15E)
		dta		a(LF2BD),a(LF2C6),a(LF2CF),a(LF2D8),a(LF0F2),a(LF0FB),a(LF104),a(LF10D)
		dta		a(LF15E),a(LF305),a(LF30E),a(LF15E),a(LF275),a(LF27E),a(LF287),a(LF290)

LD5A5:
		.byte $88,$00,$78,$F0,$68,$E0,$58,$D0,$48,$C0,$38,$B0,$28,$A0,$18,$90
		.byte $08,$80,$09,$81,$0A,$82,$0B,$83,$0C,$84,$0D,$85,$0E,$86,$0F,$87
		.byte $00,$88,$F0,$78,$E0,$68,$D0,$58,$C0,$48,$B0,$38,$A0,$28,$90,$18
		.byte $80,$08,$81,$09,$82,$0A,$83,$0B,$84,$0C,$85,$0D,$86,$0E,$87,$0F
LD5E5: .byte $00
LD5E6: .byte $00,$32,$00,$6A,$00,$AB,$00,$00,$01,$7F,$01,$6A,$02,$06,$05
LD5F5: SED
		SEC
		LDA    $AA
		SBC    $BD
		LDA    $AB
		SBC    $BE
		LDA    $AC
		SBC    $BF
		CLD
		BCS    LD60F
		LDX    #$02
LD608: LDA    $BD,X
		STA    $AA,X
		DEX
		BPL    LD608
LD60F: RTS

LD610: LDA    #$00
		LDX    #$04
LD614: ROL    $EC
		ROL
		CMP    $EE
		BCC    LD61D
		SBC    $EE
LD61D: ROL    $ED
		ROL    $EC
		ROL
		CMP    $EE
		BCC    LD628
		SBC    $EE
LD628: ROL    $ED
		ROL    $EC
		ROL
		CMP    $EE
		BCC    LD633
		SBC    $EE
LD633: ROL    $ED
		ROL    $EC
		ROL
		CMP    $EE
		BCC    LD63E
		SBC    $EE
LD63E: ROL    $ED
		DEX
		BNE    LD614
		ROL    $EC
		RTS

;==========================================================================
LD646:
		LDA    $BA
		BEQ    LD64F
		DEC    $BA
		JMP    LD6D1
LD64F:	LDA    #$03
		BIT    $A9
		BNE    LD6D1
		LDA    #$08
		BIT    $A8
		BEQ    LD662
		LDA    #$48
		STA    $AF
		JMP    LD6D1
LD662:	JSR    LD5F5
		LDA    $90				;check top thingamajig light color
		CMP    #$2A				;is it lit up?
		BNE    LD674			;yes -- we have an extra ball!
		LDA    #>(L9413-1)
		PHA
		LDA    #<(L9413-1)
		PHA
		JMP    LD6D1
LD674:	LDA    $A8
		AND    #$20
		BNE    LD67F
		INC    $A8
		JMP    LD68E
LD67F:	BIT    $A8
		BVC    LD685
		INC    $A8
LD685:	JSR    LDBD7
		LDA    $A8
		EOR    #$40
		STA    $A8
LD68E:	LDA    $A8
		AND    #$07
		CMP    #$05
		BCC    LD6CB
		LDX    #<LD1CA
		LDY    #>LD1CA
		STX    $D5
		STY    $D6
		LDX    #<LD203
		LDY    #>LD203
		STX    $D9
		STY    $DA
		LDA    #$00
		STA    $D4
		STA    $D8
		LDA    $A9
		ORA    #$03
		STA    $A9
		LDX    #$15
		LDA    $A8
		AND    #$20
		BEQ    LD6BC
		LDX    #$18
LD6BC: STX    $AF
		LDA    $A7
		AND    #$01
		STA    $A7
		LDA    #$00
		STA    $A6
		JMP    LD6D1

LD6CB:	jmp		L9410
LD6D1:	rts

LD6D6:
		LDA    $A6
		CMP    #$03
		BCC    LD6E6
		LDA    #$48
		STA    $AF
		LDA    #$00
		STA    $A6
		BEQ    LD6F7
LD6E6: ASL
		ADC    $A6
		TAY
		LDA    LD364,Y
		STA    $B1
		LDA    LD364+2,Y
		PHA
		LDA    LD364+1,Y
		PHA
LD6F7:	rts
LD6FC:
		LDA    $A6
		CMP    #$04
		BCC    LD70C
		LDA    #$48
		STA    $AF
		LDA    #$00
		STA    $A6
		BEQ    LD71D
LD70C: ASL
		ADC    $A6
		TAY
		LDA    LD36D,Y
		STA    $B1
		LDA    LD36D+1,Y
		PHA
		LDA    LD36D+2,Y
		PHA
LD71D:	rts
LD722:
		LDA    #$1B
		STA    $AF
		LDA    $BA
		AND    #$1F
		STA    $AE
		LDA    $A5
		LDY    $BC
		LDX    $E0
		CPX    #$50
		BCS    LD739
		LDY    $B0
		ASL
LD739: STA    $BB
		CPY    #$00
		BEQ    LD753
		CPY    #$0B
		BEQ    LD753
		LDA    $BA
		AND    #$20
		BNE    LD74F
		BIT    $BB
		BMI    LD753
		BPL    LD770
LD74F: BIT    $BB
		BMI    LD770
LD753: JSR    LD825
		BCS    LD762
		LDA    #$00
		STA    $AE
		JSR    LD8AE
		JMP    LD765
LD762: JSR    LDA72
LD765: LDA    #$00
		STA    $AD
		STA    $AE
		rts
LD770: JSR    LD825
		BCC    LD778
		JSR    LDA72
LD778: JSR    LD7A2
		BIT    $BB
		BPL    LD791
		LDA    $E1
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $E1
		LDA    $E3
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $E3
LD791: LDA    $DC
		CLC
		ADC    $E1
		STA    $DC
		LDA    $DD
		CLC
		ADC    $E3
		STA    $DD
		JMP    LD765
LD7A2: LDX    #$00
		LDA    $E2
		CMP    #$96
		BCC    LD7D2
		LDA    $E0
		CMP    #$50
		BCC    LD7C1
		LDA    #$68
		SEC
		SBC    $E0
		TAY
		LDA    $BC
		CMP    #$06
		BCS    LD7BE
		LDX    #$FF
LD7BE: JMP    LD7F7
LD7C1: LDA    $E0
		SEC
		SBC    #$37
		TAY
		LDA    $B0
		CMP    #$06
		BCC    LD7CF
		LDX    #$FF
LD7CF: JMP    LD7F7
LD7D2: LDA    $E0
		CMP    #$50
		BCC    LD7E9
		LDA    #$98
		SEC
		SBC    $E0
		TAY
		LDA    $BC
		CMP    #$06
		BCS    LD7E6
		LDX    #$FF
LD7E6: JMP    LD7F7
LD7E9: LDA    $E0
		SEC
		SBC    #$07
		TAY
		LDA    $B0
		CMP    #$06
		BCC    LD7F7
		LDX    #$FF
LD7F7: STX    $E1
		ASL
		TAX
		LDA    LD42D,X
		STA    $EA
		LDA    LD42D+1,X
		STA    $EB
		LDA    LD445,X
		STA    $EC
		LDA    LD445+1,X
		STA    $ED
		LDA    ($EA),Y
		EOR    $E1
		SEC
		SBC    $E1
		STA    $E1
		LDA    ($EC),Y
		STA    $E3
		RTS

LD81D:
		jmp    LD825

LD825: LDA    $DC
		BPL    LD82E
		EOR    #$FF
		CLC
		ADC    #$01
LD82E: STA    $EC
		LDA    $DD
		BPL    LD839
		EOR    #$FF
		CLC
		ADC    #$01
LD839: STA    $EE
		LDA    #$00
		STA    $ED
		JSR    LD610
		LDA    $AE
		ASL
		CLC
		ADC    #<LD5A5
		STA    $EA
		LDA    #$00
		ADC    #>LD5A5
		STA    $EB
		LDY    #$00
		BIT    $DD
		BPL    LD857
		INY
LD857: LDA    ($EA),Y
		BIT    $DD
		BMI    LD863
		BIT    $DC
		BPL    LD867
		BMI    LD86B
LD863: BIT    $DC
		BPL    LD86B
LD867: AND    #$0F
		BPL    LD86F
LD86B: LSR
		LSR
		LSR
		LSR
LD86F: TAX
		AND    #$07
		ASL
		TAY
		TXA
		CMP    #$08
		BNE    LD87B
		CLC
		RTS

LD87B: CMP    #$08
		BCC    LD88A
		LDA    LD5E5,Y
		SBC    $ED
		LDA    LD5E6,Y
		SBC    $EC
		RTS

LD88A: SEC
		LDA    $ED
		SBC    LD5E5,Y
		LDA    $EC
		SBC    LD5E6,Y
		RTS

LD896: LDA    $A7
		AND    #$01
		ASL
		ASL
		ASL
		ADC    $B1
		TAY
		LDX    #$00
LD8A2:	LDA    LD4C5,Y
		STA    $EA,X
		INY
		INX
		CPX    #$08
		BCC    LD8A2
		RTS

;==========================================================================
LD8AE:	jmp		LBCE0

;==========================================================================
LD8B9: LDA    $B8
		BEQ    LD8DE
		BPL    LD8DF
		LSR    $B8
		LDA    #<LF5CE
		STA    $B6
		LDA    #>LF5CE
		STA    $B7
		LDA    $88
		STA    $91
		LDA    #$94
		STA    $E0
		LDA    #$C9
		STA    $E2
		LDA    $B9
		AND    #$07
		CLC
		ADC    #<LF5EF
		STA    $BA
LD8DE: RTS

LD8DF: ASL
		BPL    LD8FD
		LDA    $A7
		AND    #$01
		BNE    LD8FC
		LDA    $B6
		CMP    #<LF5C7
		BNE    LD94D
		LSR    $B8
		LDA    #<LF5E0
		STA    $B6
		LDA    #>LF5E0
		STA    $B7
		LDA    $8C
		STA    $91
LD8FC: RTS

LD8FD: ASL
		BPL    LD90F
		LDA    $A7
		AND    #$01
		BNE    LD90E
		LDA    $B6
		CMP    #<LF5FD
		BNE    LD956
		LSR    $B8
LD90E: RTS

LD90F: ASL
		BPL    LD95F
		LDX    $B6
		LDA    #$03
		BIT    $A9
		BNE    LD947
		BVC    LD920
		CPX    $BA
		BEQ    LD92A
LD920: LDA    #$08
		BIT    $A5
		BNE    LD92D
		CPX    #<LF5FD
		BEQ    LD92D
LD92A: LSR    $B8
		RTS

LD92D: LDA    $A7
		AND    #$03
		BNE    LD947
		BIT    $A9
		BVS    LD94D
		LDA    $A5
		AND    #$30
		CMP    #$30
		BEQ    LD947
		AND    #$20
		BNE    LD948
		CPX    #<LF5EF
		BNE    LD94D
LD947: RTS

LD948: CPX    #<LF5FD
		BNE    LD958
		RTS

;==========================================================================
; Lower plunger
;
LD94D:	LDA    $B6
		BNE    LD953
		DEC    $B7
LD953:	DEC    $B6
		RTS

;==========================================================================
; Raise plunger
LD956:	DEC    $E2
LD958:	INC    $B6
		BNE    LD95E
		INC    $B7
LD95E:	RTS

;==========================================================================
LD95F:	ASL
		BPL    LD963
		RTS

;==========================================================================
; Reset plunger
;
LD963:	ASL
		BPL    LD96F
		LDA    #<LF5FD
		STA    $B6
		LDA    #>LF5FD
		STA    $B7
		RTS

LD96F: ASL
		BPL    LD98D
		LDA    $A7
		AND    #$01
		BNE    LD98C
		LDA    $B6
		CMP    #<LF5E0
		BNE    LD94D
		LSR    $B8
		LDA    $89
		STA    $91
		LDA    #<LF5C7
		STA    $B6
		LDA    #>LF5C7
		STA    $B7
LD98C: RTS

LD98D: LDA    $A7
		AND    #$01
		BNE    LD99B
		LDA    $B6
		CMP    #<LF5CE
		BNE    LD958
		LSR    $B8
LD99B: RTS

LD99C: LDA    $EC
		BPL    LD9AC
		EOR    #$FF
		TAY
		INY
		STY    $EC
		LDA    $EF
		EOR    #$FF
		STA    $EF
LD9AC: LSR    $EC
		LDA    #$00
		STA    $EE
		BCC    LD9BF
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LD9BF: ROR
		ROR    $EE
		ROR    $EC
		BCC    LD9D1
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LD9D1: ROR
		ROR    $EE
		ROR    $EC
		BCC    LD9E3
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LD9E3: ROR
		ROR    $EE
		ROR    $EC
		BCC    LD9F5
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LD9F5: ROR
		ROR    $EE
		ROR    $EC
		BCC    LDA07
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LDA07: ROR
		ROR    $EE
		ROR    $EC
		BCC    LDA19
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LDA19: ROR
		ROR    $EE
		ROR    $EC
		BCC    LDA2B
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LDA2B: ROR
		ROR    $EE
		ROR    $EC
		BCC    LDA3D
		TAY
		CLC
		LDA    $EE
		ADC    $EB
		STA    $EE
		TYA
		ADC    $EA
LDA3D: STA    $ED
		BIT    $EF
		BPL    LDA5E
		EOR    #$FF
		STA    $ED
		LDA    $EE
		EOR    #$FF
		STA    $EE
		LDA    $EC
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $EC
		BNE    LDA5E
		INC    $EE
		BNE    LDA5E
		INC    $ED
LDA5E: RTS


LDA5F:
		jmp		L9074

LDA6A:
		JMP    LDA72

LDA72: LDA    $AE
		AND    #$0F
		TAX
		LDA    $DD
		STA    $E3
		LDA    $DC
		STA    $E1
		STA    $EC
		LDA    LD45D,X
		STA    $EA
		LDA    LD485,X
		STA    $EB
		LDA    LD4AD,X
		STA    $EF
		JSR    LD99C
		LDA    $EC
		STA    $E4
		LDA    $EE
		STA    $E5
		LDA    $ED
		STA    $E6
		LDA    $E3
		STA    $EC
		LDA    LD475,X
		STA    $EA
		LDA    LD49D,X
		STA    $EB
		LDA    LD4B1,X
		STA    $EF
		JSR    LD99C
		LDA    $EC
		CLC
		ADC    $E4
		LDA    $EE
		ADC    $E5
		LDA    $ED
		ADC    $E6
		STA    $DC
		LDA    $E1
		STA    $EC
		LDA    LD475,X
		STA    $EA
		LDA    LD49D,X
		STA    $EB
		LDA    LD4B1,X
		STA    $EF
		JSR    LD99C
		LDA    $EC
		STA    $E4
		LDA    $EE
		STA    $E5
		LDA    $ED
		STA    $E6
		LDA    $E3
		STA    $EC
		LDA    LD465,X
		STA    $EA
		LDA    LD48D,X
		STA    $EB
		LDA    LD4B5,X
		STA    $EF
		JSR    LD99C
		LDA    $EC
		CLC
		ADC    $E4
		LDA    $EE
		ADC    $E5
		LDA    $ED
		ADC    $E6
		STA    $DD
		CMP    $E3
		BNE    LDB15
		LDA    $DC
		CMP    $E1
		BEQ    LDB25
LDB15: LDA    $B4
		STA    $E0
		LDA    $B2
		STA    $A3
		LDA    $B5
		STA    $E2
		LDA    $B3
		STA    $A4
LDB25: LDA    #$00
		STA    $AD
		RTS

;==========================================================================
; audio routine
;
LDB2A:	LDY    $D4
		BEQ    LDB3C
		DEC    $D4
		LDX    $D7
		BPL    LDB77
		DEX					;decay volume
		BPL    LDB77
		STX    $D7
		JMP    LDB77
LDB3C:	LDA    ($D5),Y
		STA    _AUDC0
		BNE    LDB4D		;check if we're playing a sound
		STA    $D7			;clear duration counter
		LDA    $A9
		AND    #$FE			;mark channel 0 no longer in use
		STA    $A9
		JMP    LDB77
LDB4D:	BPL    LDB5D		;check for a jump
		INY
		LDA    ($D5),Y
		TAX
		INY
		LDA    ($D5),Y
		STX    $D5
		STA    $D6
		JMP    LDB77
LDB5D: INY
		LDA    ($D5),Y		;get frequency
		STA    _AUDF0
		INY
		LDA    ($D5),Y		;get volume
		STA    $D7			;set volume
		INY
		LDA    ($D5),Y		;get duration
		STA    $D4			;set duration
		LDA    $D5
		CLC
		ADC    #$04			;next tone
		STA    $D5
		BCC    LDB77
		INC    $D6
LDB77: LDY    $D8
		BEQ    LDB89
		DEC    $D8
		LDX    $DB
		BPL    LDBC4
		DEX
		BPL    LDBC4
		STX    $DB
		JMP    LDBC4
LDB89: LDA    ($D9),Y
		STA    _AUDC1
		BNE    LDB9A
		STA    $DB
		LDA    $A9
		AND    #$FD			;mark channel 1 no longer in use
		STA    $A9
		JMP    LDBC4
LDB9A: BPL    LDBAA
		INY
		LDA    ($D9),Y
		TAX
		INY
		LDA    ($D9),Y
		STX    $D9
		STA    $DA
		JMP    LDBC4
LDBAA: INY
		LDA    ($D9),Y
		STA    _AUDF1
		INY
		LDA    ($D9),Y
		STA    $DB
		INY
		LDA    ($D9),Y
		STA    $D8
		LDA    $D9
		CLC
		ADC    #$04
		STA    $D9
		BCC    LDBC4
		INC    $DA
LDBC4:
		LDX		$D7
		LDY		$DB
		LDA		#$08
		BIT		$A8
		BEQ		LDBD2
		LDX		#$00
		LDY		#$00
LDBD2:
		STX    _AUDV0
		STY    _AUDV1

		jsr		updateAudio
		RTS

;==========================================================================
; Swap player 1/2 scores
;
LDBD7:	LDX    #$02
LDBD9:	LDY    $BD,X
		LDA    $9B,X
		STA    $BD,X
		STY    $9B,X
		DEX
		BPL    LDBD9
		RTS

;==========================================================================
LDBE5:
		LDX    #$80
		LDA    $A6
		AND    #$01
		BEQ    LDBEF
		LDX    #$50
LDBEF: LDA    $A0
		AND    #$02
		BNE    LDC07
		LDA    $A7
		AND    #$01
		ORA    #$02
		STA    $A7
		LDA    #$20
		LDX    #$90
		BIT    $A8
		BEQ    LDC07
		LDX    #$D0
LDC07: STX    $B1
		LDA    $A9
		BMI    LDC2D
		BIT    $A6
		BPL    LDC1C
		ORA    #$80
		STA    $A9
		LDA    #$80
		STA    $A6
		JMP    LDC47
LDC1C: INC    $8F
		LDA    $A7
		BNE    LDC47
		DEC    $BA
		BNE    LDC47
		LDA    #$09
		STA    $AF
		JMP    LDC47
LDC2D: LDA    $A7
		BNE    LDC47
		LDX    $A6
		STX    $E4
		DEX
		STX    $E5
		LDX    #$1A
LDC3A: LDA    $80,X
		EOR    $E4
		EOR    $E5
		AND    #$F6
		STA    $80,X
		DEX
		BPL    LDC3A
LDC47:	rts
LDC4C:
		LDX    #$00
		LDA    $DC
		BPL    LDC5B
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $DC
		LDX    #$FF
LDC5B: STX    $E1
		LDY    #$00
		LDA    $DD
		BPL    LDC6C
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $DD
		LDY    #$FF
LDC6C: STY    $E3
		LDA    #$3F
		STA    $EC
		LDA    #$00
		STA    $ED
		LDA    $DC
		CMP    $DD
		BCC    LDCA3
		LDA    $DC
		STA    $EE
		JSR    LD610
		LDA    #$3F
		STA    $DC
		LDA    $ED
		LSR    $EC
		ROR
		STA    $EA
		LDA    #$00
		STA    $EF
		ROR
		STA    $EB
		LDA    $DD
		STA    $EC
		JSR    LD99C
		LDA    $ED
		STA    $DD
		JMP    LDCC7
LDCA3: LDA    $DD
		STA    $EE
		JSR    LD610
		LDA    #$3F
		STA    $DD
		LDA    $ED
		LSR    $EC
		ROR
		STA    $EA
		LDA    #$00
		STA    $EF
		ROR
		STA    $EB
		LDA    $DC
		STA    $EC
		JSR    LD99C
		LDA    $ED
		STA    $DC
LDCC7: LDA    $E1
		BPL    LDCD4
		LDA    $DC
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $DC
LDCD4: LDA    $E3
		BPL    LDCE1
		LDA    $DD
		EOR    #$FF
		CLC
		ADC    #$01
		STA    $DD
LDCE1: LDA    #$04
		STA    $AD
		JSR    LD8AE
		BIT    $AD
		BMI    LDCF0
		LDA    $BA
		STA    $AF
LDCF0:	rts
LDCF5:
		JSR    LD896
		JSR    LD8B9
		jmp    LDB2A

;==========================================================================
; Signature and copyright notice
;
LDD03: .byte $44,$45,$53,$49,$47,$4E,$45,$44,$20,$41,$4E,$44,$20,$50,$52,$4F
		.byte $47,$52,$41,$4D,$4D,$45,$44,$20,$42,$59,$20,$47,$4C,$45,$4E,$4E
		.byte $20,$41,$58,$57,$4F,$52,$54,$48,$59,$2E,$43,$4F,$50,$59,$52,$49
		.byte $47,$48,$54,$20,$41,$54,$41,$52,$49,$20,$31,$39,$38,$34,$2E

		ORG $7000

;==========================================================================
; bonus multiplier graphic table
;
bonus_lo:
		dta		<LF15E
		dta		<LF4D2
		dta		<LF4D9
		dta		<LF4E0
		dta		<LF4E7

bonus_hi:
		dta		>LF15E
		dta		>LF4D2
		dta		>LF4D9
		dta		>LF4E0
		dta		>LF4E7

;==========================================================================
; Message graphics
;
LF0F2:	dta		$04,$04,$04,$04,$03,$04,$04,$04,$03
LF0FB:	dta		$99,$A5,$A5,$A5,$0C,$A1,$A1,$A1,$18
LF104:	dta		$2A,$2A,$2A,$2A,$C0,$2A,$2A,$2A,$CB
LF10D:	dta		$40,$40,$40,$40,$00,$40,$40,$40,$80
LF116:	dta		$04,$04,$04,$04,$03,$04,$04,$04,$03
LF11F:	dta		$88,$88,$88,$88,$00,$88,$88,$88,$3E
LF128:	dta		$94,$94
LF12A:	dta		$94,$94,$60,$94,$94,$94,$67
LF131:	dta		$20,$20,$20,$20,$00,$A0,$A0,$A0,$20

LF13A:	dta		$03,$02,$02,$02,$01,$02,$02,$02,$03
LF143:	dta		$92,$52,$52,$52,$8C,$52,$52,$52,$8C
LF14C:	dta		$73,$84,$84,$84,$00,$84,$84,$84,$84
LF155:	dta		$80,$00,$00,$00,$00,$00,$00,$00,$00
LF15E:	dta		$00,$00,$00,$00,$00,$00,$00,$00,$00		;doubles as empty bonus graphic!!
LF167:	dta		$07,$08,$0B,$0A,$00,$0A,$0B,$08,$07
LF170:	dta		$89,$48,$48,$48,$01,$4A,$4A,$4A,$89
LF179:	dta		$8C,$52,$52,$52,$8C,$52,$52,$52,$8C
LF182:	dta		$10,$10,$10,$10,$60,$90,$90,$90,$90
LF18B:	dta		$44,$44,$44,$44,$30,$45,$45,$45,$75
LF194:	dta		$47,$A8,$A8,$A8,$07,$28,$28,$28,$27
LF19D:	dta		$01,$01,$01,$01,$00,$01,$01,$01,$01
LF1A6:	dta		$0C,$12,$12,$12,$C0,$12,$12,$12,$CC
LF1AF:	dta		$64,$94,$94,$94,$00,$94,$94,$94,$97
LF1B8:	dta		$00,$00,$00,$00,$00,$80,$80,$80,$00
LF1C1:	dta		$01,$02,$02,$02,$00,$02,$02,$02,$01
LF1CA:	dta		$92,$52,$52,$52,$CC,$12,$12,$12,$8C
LF1D3:	dta		$A9,$AA,$AA,$AA,$01,$AA,$AA,$AA,$51
LF1DC:	dta		$C0,$00,$00,$00,$C0,$00,$00,$00,$C0
LF1E5:	dta		$94,$95,$95,$95,$60,$95,$95,$95,$94
LF1EE:	dta		$C9,$29,$29,$29,$66,$09,$09,$09,$C9
LF1F7:	dta		$05,$05,$05,$05,$00,$05,$05,$05,$02
LF200:	dta		$52,$52,$52,$52,$0C,$52,$52,$52,$8C
LF209:	dta		$64,$95,$95,$95,$B0,$85,$85,$85,$64
LF212:	dta		$E0,$00,$00,$00,$00,$00,$00,$00,$E0
LF21B:	dta		$55,$55,$55,$55,$00,$55,$55,$55,$29
LF224:	dta		$72,$4A,$4A,$4A,$00,$4A,$4A,$4A,$73
LF22D:	dta		$51,$51,$51,$51,$00,$51,$51,$51,$97
LF236:	dta		$0E,$10,$10,$10,$0E,$10,$10,$10,$CE
LF23F:	dta		$32,$4A,$4A,$4A,$00,$4A,$4A,$4A,$33
LF248:	dta		$4E,$50,$50,$50,$0E,$50,$50,$50,$8E
LF251:	dta		$01,$02,$02,$02,$00,$02,$02,$02,$01
LF25A:	dta		$84,$4A,$4A,$4A,$00,$52,$52,$52,$92
LF263:	dta		$74,$84,$84,$84,$70,$84,$84,$84,$73
LF26C:	dta		$00,$00,$00,$00,$00,$80,$80,$80,$00
LF275:	dta		$20,$21,$21,$21,$18,$25,$25,$25,$39
LF27E:	dta		$E9,$09,$09,$09,$06,$09,$09,$09,$06
LF287:	dta		$31,$0A,$0A,$0A,$31,$4A,$4A,$4A,$49
LF290:	dta		$D0,$10,$10,$10,$C0,$12,$12,$12,$DC
LF299:	dta		$0E,$01,$01,$01,$06,$08,$08,$08,$07
LF2A2:	dta		$39,$42,$42,$42,$00,$42,$42,$42,$39
LF2AB:	dta		$90,$50,$50,$50,$00,$52,$52,$52,$9C
LF2B4:	dta		$70,$80,$80,$80,$70,$80,$80,$80,$70
LF2BD:	dta		$1C,$02,$02,$02,$0C,$10,$10,$10,$0E
LF2C6:	dta		$93,$94,$94,$94,$60,$94,$94,$94,$93
LF2CF:	dta		$18,$A4,$A4,$A4,$00,$A4,$A4,$A4,$19
LF2D8:	dta		$40,$40,$40,$40,$00,$40,$40,$40,$F0
LF2E1:	dta		$04,$04,$04,$04,$00,$04,$04,$04,$1F
LF2EA:	dta		$4A,$4A,$4A,$4A,$30,$4A,$4A,$4A,$4B
LF2F3:	dta		$0E,$10,$10,$10,$0E,$50,$50,$50,$8E
LF2FC:	dta		$70,$80,$80,$80,$70,$80,$80,$80,$70
LF305:	dta		$21,$22,$22,$22,$00,$22,$22,$22,$FA
LF30E:	dta		$46,$A9,$A9,$A9,$00,$A9,$A9,$A9,$A6

;==========================================================================
; arrow sprite
;
LF317:	dta		%00000000
		dta		%00001000
		dta		%00011100
		dta		%00001000
		dta		%00001000
		dta		%00001000

;==========================================================================
; bonus multiplier graphics
;
LF4D2:
		dta		$00		;........
		dta		$00		;........
		dta		$E0		;###.....
		dta		$20		;..#.....
		dta		$E5		;###..#.#
		dta		$82		;#.....#.
		dta		$E5		;###..#.#

LF4D9:
		dta		$00		;........
		dta		$00		;........
		dta		$E0		;###.....
		dta		$20		;..#.....
		dta		$E5		;###..#.#
		dta		$22		;..#...#.
		dta		$E5		;###..#.#

LF4E0:
		dta		$00		;........
		dta		$00		;........
		dta		$A0		;#.#.....
		dta		$A0		;#.#.....
		dta		$E5		;###..#.#
		dta		$22		;..#...#.
		dta		$25		;..#..#.#

LF4E7:
		dta		$00		;........
		dta		$00		;........
		dta		$E0		;###.....
		dta		$80		;#.......
		dta		$E5		;###..#.#
		dta		$22		;..#...#.
		dta		$E5		;###..#.#

;==========================================================================
; Left flipper graphics
;
LF54B:	dta		$00,$00,$00,$40,$E0,$F0,$78,$3C,$0E,$03
LF555:	dta		$00,$00,$00,$40,$F0,$FC,$7F,$00,$00,$00
LF55F:	dta		$00,$00,$00,$7F,$FC,$F0,$40,$00,$00,$00
LF569:	dta		$03,$0E,$3C,$78,$F0,$E0,$40,$00,$00,$00

;==========================================================================
; Left flipper pointer table
;
LF573:
		dta		a(LF54B)
		dta		a(LF54B)
		dta		a(LF54B)
		dta		a(LF555)
		dta		a(LF555)
		dta		a(LF555)
		dta		a(LF55F)
		dta		a(LF55F)
		dta		a(LF55F)
		dta		a(LF569)
		dta		a(LF569)
		dta		a(LF569)

;==========================================================================
; Plunger graphic
;
; This must NOT cross a page as the limit checks only use the LSB of the
; address.
;
.pages 1
LF5C7:	dta		$00,$00,$00,$00,$00,$00,$00
LF5CE:
		dta		$00,$00
		dta		$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F

LF5E0:
		dta		$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LF5EF:	dta		$10
		dta		$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10

LF5FD:
		dta		$16,$16,$16,$1E,$16,$17,$16,$16,$1E,$16,$17,$16,$16,$1E,$16,$17
		dta		$16,$16,$1E,$16,$17,$16,$16
.endpg

;==========================================================================
; Right flipper graphics
;
LF614:	dta		$00,$00,$00,$02,$07,$0F,$1E,$3C,$70,$C0
LF61E:	dta		$00,$00,$00,$02,$0F,$3F,$FE,$00,$00,$00
LF628:	dta		$00,$00,$00,$FE,$3F,$0F,$02,$00,$00,$00
LF632:	dta		$C0,$70,$3C,$1E,$0F,$07,$02,$00,$00,$00

;==========================================================================
; Right flipper graphics pointer table
;
LF63C:
		dta		a(LF614)
		dta		a(LF614)
		dta		a(LF614)
		dta		a(LF61E)
		dta		a(LF61E)
		dta		a(LF61E)
		dta		a(LF628)
		dta		a(LF628)
		dta		a(LF628)
		dta		a(LF632)
		dta		a(LF632)
		dta		a(LF632)

;==========================================================================
; Spinner graphics
;
LF667:	dta		$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00
LF671:	dta		$00,$00,$00,$00,$00,$7E,$C3,$7E,$00,$00
LF67B:	dta		$00,$00,$00,$00,$7E,$42,$DB,$42,$7E,$00
LF685:	dta		$00,$00,$00,$7E,$42,$5A,$DB,$5A,$42,$7E

;==========================================================================
; Spinner graphic pointer table
;
LF68F:	dta		a(LF667)
		dta		a(LF671)
		dta		a(LF67B)
		dta		a(LF685)
		dta		a(LF685)
		dta		a(LF67B)
		dta		a(LF671)
		dta		a(LF667)

;==========================================================================
;
; DISPLAY KERNEL
;
;==========================================================================

LF69F:
		mva		$81 colbk
		mva		$89 colpf0
		mva		$89 colpf3

		;set ball horizontal position
		ldx		$E0
		inx
		txa
		lsr
		add		#$57
		sta		hposm0

		;set up center post color
		ldx		$89					;use playfield color
		lda		$A8					;check if center post has been activated
		bmi		center_post_active
		ldy		#$80				;check difficulty B
		and		#$40				;check if player two active
		bne		player_two
		ldy		#$40				;check difficulty A
player_two:
		tya
		bit		$A0
		beq		center_post_active
		ldx		$81					;use background color
center_post_active:
		stx		$F7					;set center post color

		;draw flippers into player 0+1 graphics
		lda		$b0
		asl
		tay
		mwa		LF573,y $e8

		lda		$bc
		asl
		tay
		mwa		LF63C,y $f2

		ldy		#9
flipper_loop:
		lda		($e8),y				;fetch left flipper data
		sta		player0_data+130,y
		sta		player0_data+207,y
		lda		($f2),y				;fetch right flipper data
		sta		player1_data+130,y
		sta		player1_data+207,y
		dey
		bpl		flipper_loop

		;draw spinner
		lda		$de
		and		#$70
		lsr
		lsr
		lsr
		tay
		mwa		LF68F,y $f5

		ldy		#9
spinner_loop:
		lda		($f5),y
		sta		player0_data+115,y
		dey
		bpl		spinner_loop

		;draw bonus multiplier
		ldy		$9f
		mva		bonus_lo,y $e6
		mva		bonus_hi,y $e7

		ldy		#6
bonus_loop:
		lda		($e6),y
		sta		player0_data+82,y
		dey
		bpl		bonus_loop

		;draw plunger
		ldy		#17
plunger_loop:
		lda		($b6),y
		sta		player2_data+207,y
		dey
		bpl		plunger_loop

		;set up bonus bumpers
		mva		$96 colpf1
		mva		$97 colpf2
		mva		$98 colpm0
		mva		$99 colpm1
		mva		$9a colpm2
		mva		#$7d hposp0
		mva		#$85 hposp1
		mva		#$8d hposp2

		;--- BEGIN DISPLAY

		jsr		waitNonVbl

		;turn on P/M graphics DMA
		mva		#$3d dmactl
		mva		#$03 gractl

		;set up bonus arrow
		;##ASSERT vpos<43 or vpos>250
		lda		#43/2
		cmp:rne	vcount
		sta		wsync

		lda		$9e
		and		#$07
		tax
		lda		arrow_pos,x
		sta		hposp0
		mva		$80 colpm0

		lda		#48/2
		cmp:rne	vcount
		sta		wsync

		mva		$92 colpf1
		sta		wsync
		sta		wsync
		sta		wsync
		sta		wsync
		mva		$90 colpf1

		;------ set up upper bumper
		lda		#66/2
		cmp:rne	vcount
		sta		wsync

		mva		$83 colpf1
		mva		$82 colpf2

		;------ draw message
		ldy		#8
		sty		msg_y
		ldx		#104

		lda		$a7				;check for alternate frame
		lsr
		bcs		odd_message
message_loop_left_1:
		mva		($ea),y player0_data,x
		mva		($ec),y player1_data,x
		inx
		dey
		bpl		message_loop_left_1

		ldx		#0
message_loop_left_2:
		ldy		msg_y
		lda		($ee),y
		tay
		mva		expand_tab_left,y playfield+72*32+2,x
		mva		expand_tab_right,y playfield+72*32+3,x
		ldy		msg_y
		lda		($f0),y
		tay
		mva		expand_tab_left,y playfield+72*32+4,x
		mva		expand_tab_right,y playfield+72*32+5,x
		txa
		add		#$20
		tax
		dec		msg_y
		bne		message_loop_left_2

		ldy		#0
		lda		($ee),y
		tay
		mva		expand_tab_left,y playfield+80*32+2
		mva		expand_tab_right,y playfield+80*32+3
		ldy		#0
		lda		($f0),y
		tay
		mva		expand_tab_left,y playfield+80*32+4
		mva		expand_tab_right,y playfield+80*32+5
		jmp		even_message

odd_message:
message_loop_right_1:
		mva		($ee),y player2_data,x
		mva		($f0),y player3_data,x
		inx
		dey
		bpl		message_loop_right_1

		ldx		#0
message_loop_right_2:
		ldy		msg_y
		lda		($ea),y
		tay
		mva		expand_tab_left,y playfield+72*32+26,x
		mva		expand_tab_right,y playfield+72*32+27,x
		ldy		msg_y
		lda		($ec),y
		tay
		mva		expand_tab_left,y playfield+72*32+28,x
		mva		expand_tab_right,y playfield+72*32+29,x
		txa
		add		#$20
		tax
		dec		msg_y
		bne		message_loop_right_2

		ldy		#0
		lda		($ea),y
		tay
		mva		expand_tab_left,y playfield+80*32+26
		mva		expand_tab_right,y playfield+80*32+27
		ldy		#0
		lda		($ec),y
		tay
		mva		expand_tab_left,y playfield+80*32+28
		mva		expand_tab_right,y playfield+80*32+29

even_message:

		;------ set up catch magnets and multiplier indicator
		lda		#82/2
		cmp:rne	vcount
		sta		wsync
		lda		$94
		sta		colpm0
		sta		colpf1
		mva		#$7c hposp0

		;------ setup middle bumpers
		lda		#88/2
		cmp:rne	vcount
		sta		wsync
		mva		#$76 hposp0
		mva		#$86 hposp1

		sta		wsync

		mva		$85 colpf1		;load bumper left outside color
		mva		$87 colpf2		;load bumper right outside color
		mva		$84 colpm0		;load bumper left center color
		mva		$86 colpm1		;load bumper right center color

		;set up message
		lda		#100/2
		cmp:rne	vcount
		sta		wsync
		mva		#$38 hposp0
		mva		#$40 hposp1
		mva		#$b8 hposp2
		mva		#$c0 hposp3

		lda		$8f
		sta		colpm0
		sta		colpm1
		sta		colpm2
		sta		colpm3
		sta		wsync
		sta		wsync
		sta		wsync

		sta		colpf1

		;position and color spinner
		lda		#113/2
		cmp:rne	vcount
		sta		wsync
		sta		wsync

		mva		#$7c hposp0
		mva		$95 colpm0

		ldx		$89				;load base color
		ldy		#10
mid_gradient_loop:
		sta		wsync
		stx		colpf1
		inx
		dey
		bne		mid_gradient_loop

		;set up upper flippers
		lda		#124/2
		cmp:rne	vcount
		sta		wsync

		lda		$8c
		sta		colpm0
		sta		colpm1

		mva		#$5c hposp0
		mva		#$9c hposp1

		;do side gradients
		lda		#133/2
		cmp:rne	vcount

		sta		wsync
		ldx		$8a
		ldy		#14
side_grad_loop:
		sta		wsync
		stx		colpf1
		bit		$a9
		smi:inx
		dey
		bne		side_grad_loop

		;draw kickback into sprites 2 and 3, if center post enabled
		ldy		#7
		lda		$f7					;get center post color
		eor		$81					;check if same as background
		beq		clear_kickback_loop
draw_kickback_loop:
		lda		kickback_left_tab,y
		sta		player2_data+183,y
		lda		kickback_right_tab,y
		sta		player3_data+183,y
		dey
		bpl		draw_kickback_loop
		bmi		after_kickback
clear_kickback_loop:
		sta		player2_data+183,y
		sta		player3_data+183,y
		dey
		bpl		clear_kickback_loop
after_kickback:

		;setup score
		lda		$8B
		sta		colpm0
		sta		colpm1
		sta		colpm2
		sta		colpm3
		lda		#$70
		ldx		#$78
		sta		wsync
		sta		hposp0
		stx		hposp1
		mva		#$80 hposp2
		mva		#$88 hposp3
		mva		#$35 dmactl
		mva		#1 gractl

		lda		#154/2
		cmp:rne	vcount

		sta		wsync

		;##ASSERT vpos=154
		ldy		#$f7
score_draw_loop:
		ldx		score_tab-$f7,y
		sta		wsync
		mva		$c0,x grafp0
		mva		$c5,x grafp1
		mva		$ca,x grafp2
		mva		$cf,x grafp3
		iny
		bne		score_draw_loop

		lda		#$3d
		ldx		#3
		sta		wsync
		sta		dmactl
		stx		gractl

		;setup entry rollovers
		lda		#165/2
		cmp:rne	vcount

		lda		$8d
		sta		wsync
		sta		colpm0
		sta		colpm1

		lda		$9e
		and		#3
		tax
		mva		left_entry_pos,x hposp0
		mva		right_entry_pos,x hposp1

		;set left and right kicker/kickback colors

		lda		#170/2
		cmp:rne	vcount
		sta		wsync

		lda		$8e
		sta		colpf1
		sta		colpm2
		lda		$93
		sta		colpf2
		sta		colpm3

		;position kickback sprites
		mva		#$5a hposp2
		mva		#$9e hposp3

		;set lower rollover and flipper colors
		lda		$8c
		sta		colpm0
		sta		colpm1

		;draw rollovers
		lda		#200/2
		cmp:rne	vcount
		lda		#$6c
		ldx		#$90
		sta		wsync
		sta		hposp0
		stx		hposp1

		;position lower flippers
		lda		#$74
		ldx		#$84
		sta		wsync
		sta		wsync
		sta		hposp0
		stx		hposp1
		mva		#$9c hposp2

		;set plunger/entry plug color
		ldx		$91
		lda		$b8
		sne:ldx	$89
		stx		colpm2

		;set up center post
		lda		#218/2
		cmp:rne	vcount

		mva		$f7 colpf1

		;turn off P/M graphics DMA to save cycles
		lda		#225/2
		ldx		#$31
		ldy		#0
		cmp:rne	vcount
		sta		wsync
		sta		wsync
		stx		dmactl
		sty		gractl

		jmp		display_end

display_end:
		jmp		waitvbl

delay27:
		NOP
delay26:
		NOP
delay25:
		NOP
delay24:
		NOP
delay23:
		NOP
delay22:
		NOP
delay21:
		NOP
delay20:
		NOP
delay19:
		NOP
delay18:
LFFD3:	NOP
delay17:
		NOP
delay16:
		NOP
delay15:
LFFD6:	NOP
delay14:
LFFD7:	NOP
delay13:
		NOP
delay12:
LFFD9:	RTS

arrow_pos:
		dta		$7c
		dta		$84
		dta		$8c
		dta		$84
		dta		$7c
		dta		$74
		dta		$6c
		dta		$74

left_entry_pos:
		dta		$63-1
		dta		$63+4
		dta		$63-1
		dta		$63-6

right_entry_pos:
		dta		$9c-0
		dta		$9c-5
		dta		$9c-0
		dta		$9c+5

score_tab:
		dta		0
		dta		1
		dta		1
		dta		1
		dta		2
		dta		3
		dta		3
		dta		3
		dta		4

kickback_right_tab:
		dta		$18		;...**...
		dta		$18		;...**...
		dta		$08		;....*...
		dta		$10		;...*....
		dta		$08		;....*...
		dta		$10		;...*....
		dta		$08		;....*...
		dta		$10		;...*....

kickback_left_tab:
		dta		$18		;...**...
		dta		$18		;...**...
		dta		$10		;...*....
		dta		$08		;....*...
		dta		$10		;...*....
		dta		$08		;....*...
		dta		$10		;...*....
		dta		$08		;....*...

		run		_main

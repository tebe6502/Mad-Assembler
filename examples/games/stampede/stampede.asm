; Disassembly of Stampede.bin
; Disassembled Sun Jan 12 18:02:21 2014
; Using DiStella v3.0
;
; Command Line: ..\pinball\distella\distella.exe Stampede.bin
;

vdslst	= $0200
vvblki	= $0222
pupbt1	= $033d			;(XL/XE) Power-up boot flag #1 - $5C
pupbt2	= $033e			;(XL/XE) Power-up boot flag #2 - $93
pupbt3	= $033f			;(XL/XE) Power-up boot flag #3 - $25

m0pf	= $d000
hposp0	= $d000
m1pf	= $d001
hposp1	= $d001
hposp2	= $d002
hposp3	= $d003
p0pf	= $d004
hposm0	= $d004
p1pf	= $d005
hposm1	= $d005
p2pf	= $d006
p3pf	= $d007
sizep0	= $d008
sizep1	= $d009
sizep2	= $d00a
sizep3	= $d00b
sizem	= $d00c
p1pl	= $d00d
grafp0	= $d00d
grafp1	= $d00e
trig0	= $d010
colpm0	= $d012
colpm1	= $d013
colpm2	= $d014
colpm3	= $d015
colpf0	= $d016
colpf1	= $d017
colpf2	= $d018
colbk	= $d01a
prior	= $d01b
gractl	= $d01d
hitclr	= $d01e
consol	= $d01f

audf1	= $d200
audc1	= $d201
audf2	= $d202
audc2	= $d203
audf3	= $d204
audc3	= $d205
audf4	= $d206
audc4	= $d207
audctl	= $d208
kbcode	= $d209
random	= $d20a
irqen	= $d20e
skctl	= $d20f

porta	= $d300

dmactl	= $d400
chactl	= $d401
dlistl	= $d402
hscrol	= $d404
vscrol	= $d405
pmbase	= $d407
chbase	= $d409
wsync	= $d40a
vcount	= $d40b
nmien	= $d40e

xitvbv	= $e462

_audc0   =  $15
_audc1   =  $16
_audf0   =  $17
_audf1   =  $18
_audv0   =  $19
_audv1   =  $1A

pcoll_flags		= $30
mcoll_flags		= $36

_inpt4	= $40
_tmp0	= $43
_tmp1	= $44
_cowpos	= $45
_frame	= $46
_shift	= $47
_frameptr = $48
_hmptr = $4a
_tile1ptr = $4c
_tile2ptr = $4e
_hmoveval	= $50
_hmacc		= $51
_lane	= $52
_cowboy_frame	= $53
_ypos	= $54
_dli_done		= $55
_pal			= $56
_pal_counter	= $57
_lasso_pos		= $58

SWCHA   =  $59
SWCHB   =  $5a

_consol_prev	= $5b

_lane_colors	= $70
_lane_hscrol	= $78

;$8B-8C = player HMOVE pointer
;$8D-8E = player/lasso HMM0/ENAM0/NUSIZ0 data
;$8F-90 = player graphic pointer
;$91-92 = cow graphic pointer
;$93-94 = cow HMOVE pointer
;$95    = kernel temporary
;$98    = cow lane counter
;$99    = game mode (0-7)
;$9A    = game over state ($00 = game on, $FF = game over)
;$9B-A0 = cow pattern bits
;$A7-AC = cow type
;	$03 = bull
;	$04 = skull
;$B3    = player/lasso state
;		  $FF = rearing
;		  $00-03 = normal animation frames
;		  $04+ = lasso being thrown
;$B4    = frame counter
;$B5    = fence position
;$B6    = player vertical position
;$B8    = score low byte
;$BC    = score high byte
;$BE    = stray count ($40-$80)
;$BF    = advance speed (no longer used)
;$C0    = playfield vertical offset (0-9); higher values move lanes up
;$C8    = score 10K digit
;$CA-CF = cow NUSIZ mode
;$D0-D5 = cow horizontal positions
;$DD-E2 = cow collision flags
;	D7 = player+cow collision
;	D6 = m0m1 + m0p1 collision
;	D5 = m0p0 collision
;$E3-E8 = cow animation frame ($00, $08, $10, $18)
;$EC-F1 = cow graphic table pointer LSB
;$F2-F7 = cow HMOVE table pointer LSB
;$F8    = cowboy color
;$FA    = fence color

;==========================================================================	
.if 0
		org	$2300
.proc _randomize
		mwa		#$2400 $80
		ldx		#$80
pageloop:
		mva:rne	random ($80),y+
		inc		$81
		dex
		bne		pageloop
		rts
.endp

		ini		_randomize
.endif

;==========================================================================	
hmove_tab = $2300

		org	$2400

;==========================================================================
		.pages 1
audio_tabs:
audio_lotab:
		:32 dta <((#+1)*57-7)
		:32 dta >((#+1)*57-7)

audio_poly4tab:
		:32 dta <((#+1)*57-(((#+1)*57)%15)-1-7)
		:32 dta >((#+1)*57-(((#+1)*57)%15)-1-7)

audio_lotab6:
		:32 dta <((#+1)*57*3-7)
		:32 dta >((#+1)*57*3-7)

audio_lotab31:
		:32 dta <(((#+1)*57*31)/2-7)
		:32 dta >(((#+1)*57*31)/2-7)
		.endpg

;==========================================================================
.proc	updateAudio
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

audio_ctab:
		dta		$10
		dta		$c0		;$1: 4-bit polynomial
		dta		$20
		dta		$30
		dta		$a0		;$4: pure tone
		dta		$a0		;$5: pure tone
		dta		$a0		;$6: pure tone
		dta		$70
		dta		$80		;$8: 9-bit polynomial
		dta		$90
		dta		$A0
		dta		$B0
		dta		$a0		;$C: pure tone, div 6
		dta		$D0
		dta		$E0
		dta		$20		;$F: 5-bit poly, div 6
		
audio_dtab:
		dta		<audio_lotab
		dta		<audio_poly4tab
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

;==========================================================================	
.proc AdvanceHMOVE
		tax
		lda		_hmoveval
		clc
		adc		hmove_tab,x
		sta		_hmoveval
		rts
.endp

.proc UpdateHMOVE
		;shift accumulator by shift value
		ldx		_hmoveval
		beq		no_shift
rshift_loop:
		lsr		_hmacc
		ror		_hmacc+1
		dex
		bne		rshift_loop
no_shift:
		rts
.endp

;==========================================================================	
__init:
		;shut off all interrupts and the display
		sei
		cld
		lda		#0
		sta		irqen
		sta		nmien
		sta		dmactl
		
		;clear page zero and font
		tax
clear_loop:
		sta		0,x
		sta		pupbt1,x
		sta		font+$a0,x
		sta		font+$100,x
		sta		pf_score,x
		sta		cattle_lanes,x
		sta		cattle_lanes+$100,x
		sta		pm_missiles,x
		sta		pm_player0,x
		sta		pm_player1,x
		sta		pm_player2,x
		sta		pm_player3,x
		inx
		bne		clear_loop
		
		jsr		InitMotion
		
		mva		#$08 consol
		mva		#$07 _consol_prev

		;init HMOVE table
		ldx		#0
hmove_init:
		txa
		eor		#$f0
		clc
		adc		#$10
		lsr
		lsr
		lsr
		lsr
		clc
		adc		#$f8
		eor		#$f8
		sta		hmove_tab,x
		inx
		bne		hmove_init
		
		;decode graphics into tiles
		mva		#0 _frame
		mwa		#font+[$20]*8 _tile1ptr
		mwa		#font+[$30]*8 _tile2ptr
frame_loop:
		;set up frame graphics pointer
		mva		#>LF67E _frameptr+1
		mva		#>LF67E _hmptr+1
		lda		_frame
		asl
		asl
		asl
		tax
		ldy		LF607,x
		sty		_frameptr
		ldy		LF637,x
		sty		_hmptr
		mva		#4 _hmoveval
		
		;process 15 scanlines
		ldy		#15
tilescan_loop:
		;initialize hmove accumulator
		mva		(_frameptr),y _hmacc
		mva		#0 _hmacc+1
		
		;frame 4 needs to be reflected
		lda		_frame
		cmp		#4
		bne		no_reflect
		
		lda		_hmacc
		tax
		and		#$55
		asl
		sta		_hmacc
		txa
		lsr
		and		#$55
		ora		_hmacc
		sta		_hmacc

		lda		_hmacc
		tax
		and		#$33
		asl
		asl
		sta		_hmacc
		txa
		lsr
		lsr
		and		#$33
		ora		_hmacc
		sta		_hmacc

		lda		_hmacc
		tax
		asl
		asl
		asl
		asl
		sta		_hmacc
		txa
		lsr
		lsr
		lsr
		lsr
		ora		_hmacc
		sta		_hmacc
		
no_reflect:

		;apply HMOVE value
		lda		(_hmptr),y
		jsr		AdvanceHMOVE
		jsr		UpdateHMOVE

		;store shifted result
		ldx		#0
		mva		_hmacc (_tile1ptr,x)
		mva		_hmacc+1 (_tile2ptr,x)
		inc		_tile1ptr
		inc		_tile2ptr
		dey
		bne		tilescan_loop
		
		;skip last scanline in tiles
		inw		_tile1ptr
		inw		_tile2ptr
		
		inc		_frame
		lda		_frame
		cmp		#6
		jne		frame_loop
		
		;----------------------------------------
		;decode player frames (26 scanlines x 5 images)
		;
		mva		#0 _frame
		mwa		#player_frames0 _tile1ptr
		mwa		#player_frames1 _tile2ptr
player_frame_loop:
		;set up frame graphics pointer
		mva		#>LF71A _frameptr+1
		mva		#>LF71A _hmptr+1
		ldx		_frame
		ldy		LF5F6,x
		sty		_frameptr
		ldy		LF7AB,x
		sty		_hmptr
		mva		#8 _hmoveval
		
		;process 26 scanlines
		ldy		#25
playerscan_loop:
		;initialize hmove accumulator
		mva		(_frameptr),y _hmacc
		mva		#0 _hmacc+1

		;apply HMOVE value
		lda		(_hmptr),y
		jsr		AdvanceHMOVE
		jsr		UpdateHMOVE

		;store shifted result
		ldx		#0
		mva		_hmacc (_tile1ptr,x)
		mva		_hmacc+1 (_tile2ptr,x)
		inc		_tile1ptr
		inc		_tile2ptr

		dey
		bpl		playerscan_loop
		
		;skip last scanline in tiles
		inw		_tile1ptr
		inw		_tile2ptr

		inc		_frame
		lda		_frame
		cmp		#5
		bne		player_frame_loop
		
		;----------------------------------------
		;wait for vertical blank
		lda		#124
		cmp:rne	vcount
		
		mwa		#Dli vdslst
		mwa		#Vbi vvblki
		
		mwa		#dlist dlistl
		mva		#$3a dmactl
		mva		#>font chbase
		mva		#>[pm_missiles-$300] pmbase
		mva		#0 chactl
		mva		#$03 gractl
		
		mva		#$f8 audctl
		mva		#$80 _inpt4
		
		mva		#$36 hposp0
		mva		#$3e hposp1
		mva		#$46 hposp2
		mva		#$4e hposp3
		mva		#$00 sizep0
		mva		#$00 sizep1
		mva		#$00 sizep2
		mva		#$00 sizep3
		mva		#$00 sizem
		mva		#$01 prior
		
		mva		#$c0 nmien
		mva		#$03 skctl
		
		;turn on keyboard IRQ (but note we are still masked)
		mva		#$40 irqen
				
		jmp		start
	
;==========================================================================	
.proc InitMotion
		;check for PAL ANTIC
		ldx:rmi	vcount
		ldx:rpl	vcount
pal_test:
		lda		vcount
		bpl		pal_test_done
		tax
		bmi		pal_test
pal_test_done:
		lsr		_pal
		cpx		#300/2
		ror		_pal
		ldx		#1
		stx		_pal_counter
		rts
.endp
	
;==========================================================================	
.proc update8
		jsr		updateAudio
		jsr		updateCattle
		jsr		UpdatePlayer
		jsr		UpdateLasso
		rts
.endp
	
;==========================================================================	
.proc UpdateInput
		lda		porta
		asl
		asl
		asl
		asl
		sta		swcha
		lda		consol
		tax
		and		#$03
		ora		#$08
		eor		swchb
		and		#$bf
		eor		swchb
		sta		swchb
		
		;check for option being pressed
		txa
		eor		#$04
		and		_consol_prev
		and		#$04
		beq		no_option
		
		;toggle left difficulty
		lda		swchb
		eor		#$40
		sta		swchb
		
no_option:
		stx		_consol_prev
		
		;update trigger
		lda		trig0
		lsr
		ror
		sta		_inpt4
		
		;check for key
		bit		irqen
		bvs		no_key
		lda		#$00
		sta		irqen
		lda		#$40
		sta		irqen
		
		;get key
		lda		kbcode
		
		;check if it is P
		cmp		#$0a
		bne		no_key
		
		;toggle the pal flag
		lda		#$40
		eor		_pal
		sta		_pal
		
no_key:
		rts
.endp

;==========================================================================	
.proc UpdatePlayer
		;invert player vertical position
		lda		#$a6
		sec
		sbc		$b6
		tax
				
		;draw player sprite
		lda		#0
		sta		pm_player0-1,x
		sta		pm_player1-1,x
		sta		pm_player2-1,x
		sta		pm_player3-1,x
		sta		pm_missiles-1,x
		sta		pm_player0,x
		sta		pm_player1,x
		sta		pm_player2,x
		sta		pm_player3,x
		sta		pm_missiles,x
		inx
		stx		_ypos
		
		ldy		#$1a
		sty		_frame
		ldy		_cowboy_frame
		lda		player_frame_offsets,y
		tay
draw_player:
		mva		player_frames_a,y pm_player0,x
		mva		player_frames_b,y pm_player1,x
		mva		player_frames_c,y pm_player2,x
		mva		player_frames_d,y pm_player3,x
		inx
		iny
		dec		_frame
		bne		draw_player

		ldy		#$19
		sty		_tmp0
		ldx		_ypos
draw_missile:
		lda		($8d),y
		lsr
		lsr
		bcc		clear_m0
		lsr
		lsr
		and		#3
		tay
		lda		m0_dat,y
		dta		{bit $0100}
clear_m0:
		lda		#0
		sta		pm_missiles,x+
		
		dec		_tmp0
		ldy		_tmp0
		bpl		draw_missile
		
		lda		#0
		sta		pm_player0,x
		sta		pm_player1,x
		sta		pm_player2,x
		sta		pm_player3,x
		sta		pm_missiles,x		
		rts
		
player_frame_offsets:
		dta		26*0, 26*1, 26*2, 26*1, 26*3
		
m0_dat:
		dta		$0f,$0f,$02,$03
.endp

;==========================================================================	
.proc UpdateLasso
		;setup HPOSP0 table based on HMOVE data
		lda		_lasso_pos
		clc
		adc		#$4b-$1f
		sta		_tmp1
		ldy		#$19
update_loop:
		lda		($8d),y
		tax
		lda		hmove_tab,x
		clc
		adc		_tmp1
		sta		_tmp1
		sta		hposm0_table,y
		
		dey
		bpl		update_loop
		rts
.endp

;==========================================================================	
.proc updateCattle
		lda		#5
		sta		_lane
lane_loop:
		;get animation frame
		ldx		_lane
		lda		$e3,x
		lsr
		lsr
		lsr
		
		pha
		ldy		$9b,x
		lda		pattern_tab,y
		sta		_tmp0
		mva		#5 _tmp1
		pla
		
		;get lane pointer
		ldy		lane_tab,x
		
		;set characters
		asl
		eor		#$20
		
cow_loop:
		lsr		_tmp0
		bcc		no_cow
		
		sta		cattle_lanes+$15,y
		eor		#$10
		sta		cattle_lanes+$16,y
		eor		#$11
		sta		cattle_lanes+$115,y
		eor		#$10
		sta		cattle_lanes+$116,y
		eor		#$11
		bne		after_cow
no_cow:
		pha
		lda		#0
		sta		cattle_lanes+$15,y
		sta		cattle_lanes+$16,y
		sta		cattle_lanes+$115,y
		sta		cattle_lanes+$116,y
		pla
after_cow:
		iny
		iny
		dec		_tmp1
		bne		cow_loop
		
		;update horizontal position
		lda		#$a7
		sec
		sbc		$d0,x
		lsr
		lsr
		lsr
		clc
		adc		lane_tab,x
		ldy		lane_lms_tab,x
		sta		dlist_cattle_lanes+1,y
		sta		dlist_cattle_lanes+4,y

		dec		_lane
		bpl		lane_loop
		
		;update hscrol positions
		ldx		#5
hscrol_update:
		lda		$d0,x
		and		#$07
		sta		_lane_hscrol,x
		iny
		dex
		bpl		hscrol_update
		rts

lane_tab:
		:6 dta	32*(5-#)

lane_lms_tab:
		:6 dta	7*(5-#)
		
pattern_tab:
		dta		%00000
		dta		%00001
		dta		%00011
		dta		%00101
		dta		%00111
		dta		%10001
		dta		%10101
		dta		%00001
.endp


;==========================================================================	
.proc Vbi
		mwa		#dlist dlistl
		
		lda		$f8
		sta		colpm0
		sta		colpm1
		sta		colpm2
		sta		colpm3
		sta		colpf1
		lda		$f9
		sta		colpf2
		lda		$fb
		sta		colbk
		
		;adjust vertical playfield
;		lda		$c0
;		mva		blank_tab1,x dlist_postblanks
;		mva		blank_tab1+1,x dlist_postblanks+1
		lda		#<dlist_postblanks2
		sec
		sbc		$c0
		sta		dlist_postblanks+1
		
		lda		#10
		sec
		sbc		$c0
		tax
		mva		blank_tab1,x dlist_preblanks
		mva		blank_tab1+1,x dlist_preblanks+1		

		jmp		xitvbv
		
blank_tab1:
		dta		$00,$00,$10,$10,$20,$20,$30,$30,$40,$40,$50,$50
.endp

;==========================================================================	
.proc	Dli
		pha
		txa
		pha
		tya
		pha
		sta		wsync
		cld
		
		LDA    #$83
		sec
		SBC    $B6
		TAY
		LDA    #$0A
		SBC    $C0
		TAX
		LDA    #$07
		STA    $98
		JSR    LF04A		;run kernel with X = pad row height (nominally 3)
		
		;set up fence horizontal scroll
		ldx		$fa
		lda		$b5
		eor		#$ff
		lsr
		lsr
		lsr
		sta		wsync
		stx		colpf0
		sta		hscrol
		mva		#1 _dli_done
		pla
		tay
		pla
		tax
		pla
		rti
.endp

;==========================================================================	
		org	$3000

start:
		;reset stack pointer
		ldx    #$ff
		txs
		inx
		txa
		tay
		DEC    $99
		jsr		LF1F0
		jmp		post_advance_update

;==========================================================================
LF011:	LDX    #$08
		LDY    #<LF6A5			;load blank tile
LF015:	asl						;multiply by 8
		asl
		asl
LF018:	AND    #$78
		BEQ    LF020
		LDY    #$00
		BEQ    LF024
LF020:	TXA
		BEQ    LF024
		TYA
LF024:	STA    $81,X
		DEX
		DEX
		RTS

;==========================================================================
LF035:	LDX		$C0
		INX
		jmp		LF04A			;unconditional branch

;--------------------------------------------------------------------------
LF03E:
		LDY		$95
LF04A:	DEY
		STY		$95
		
		lda		hposm0_table,y
		clc
		sta		wsync			;needed now since original kernel was cycle-locked
		sta		hposm0
		adc		#2
		sta		hposm1
		
LF067:	
		DEX						;decrement cow height counter
		BNE    LF03E
		
		DEC    $98				;decrement lane counter
		BEQ    LF035
		BMI    LF0B9
	
		DEY						;decrement scan counter
		lda		hposm0_table,y
		clc
		sta		wsync
		sta		hposm0
		adc		#2
		sta		hposm1

		DEY
		lda		hposm0_table,y
		clc
		sta		wsync
		sta		hposm0
		adc		#2
		sta		hposm1
		
		DEY
		lda		hposm0_table,y
		clc
		STA    WSYNC
		sta		hposm0
		adc		#2
		sta		hposm1
		
		DEY
		lda		hposm0_table,y
		clc
		LDX    $98
		STA    WSYNC
		sta		hposm0
		adc		#2
		sta		hposm1
		
		lda		_lane_hscrol-1,x
		sta		hscrol
		LDA    _lane_colors-1,X
		STA    colpf0

		;get collision status		
		lda		p0pf				;4
		ora		p1pf				;4
		ora		p2pf				;4
		ora		p3pf				;4
		sta		pcoll_flags,x		;4
		lda		m0pf				;4
		ora		m1pf				;4
		sta		mcoll_flags,x		;4
		
		STA    hitclr
		
		LDX    #$10				;load cow height
		JMP    LF04A

LF0B9:
		;update collision status for last lane
		lda		p0pf
		ora		p1pf
		ora		p2pf
		ora		p3pf
		sta		pcoll_flags
		lda		m0pf
		ora		m1pf
		sta		mcoll_flags
		
;		mva		#$0f colbk
		jmp		LF157
		
;==========================================================================
; Railing routine
;
LF157:	ldx		#0
		STX    _audc0
LF15B: 	LDX    #$35
		STX    _audv0
		LDY    #$13
		STY    _audf1
		RTS

;==========================================================================
LF1B5:
		ldy		#0
		
		INC    $80
		BNE    LF1C8
		INC    $BB
		BNE    LF1C8
		STX    $BA
LF1C8: TXA
		EOR    SWCHB
		AND    #$08
		asl
		SBC    #$00
		BIT    $BA
		BPL    LF1D7
		AND    #$F7
LF1D7: STA    $E9
		LDX    #$04
LF1DB: LDA    $BB
		AND    $BA
		EOR    LF6FB,X
		AND    $E9
		STA    $F7,X
		DEX
		STX    $E2
		BNE    LF1DB
		LDA    SWCHB
LF1F0: LDX    #$2D
		lsr
		ror
		BMI    LF219
		
		;reset game variables
		LDX    #$0C
LF1FF: LDA    LF798,X
		STA    $BD,X
		STA    $CB,X
		STY    $99,X
		STY    $A5,X
		STY    $B1,X
		DEX
		BNE    LF1FF
		
		;need to clear sprites
		txa
sprclear_loop:
		sta		pm_missiles,x
		sta		pm_player0,x
		sta		pm_player1,x
		sta		pm_player2,x
		sta		pm_player3,x
		inx
		bne		sprclear_loop
		
		LDA    $99
		AND    #$02
		BEQ    LF219
		ORA    $80
		STA    $C7
LF219:
		TYA
		BCS    LF23A
		LDX    $99
		DEC    $97
		BPL    LF23C
		INX
		TXA
		AND    #$07
		STA    $99
		ADC    #$01
		STA    $B8
		STA    $B9
		LDX    #$04
		TYA
LF231: STA    $BA,X
		DEX
		BPL    LF231
		STX    $9A
		LDA    #$1D
LF23A: STA    $97
LF23C: LDX    $B6
		LDA    SWCHA
		asl
		asl
		asl
		BCS    LF249
		DEX
		BCC    LF24C
LF249: BMI    LF250
		INX
LF24C: STY    $BA
		STY    $BB
LF250: TXA
		CMP    #$69
		BIT    $9A
		LDX    $B3
		BVS    LF2D7
		BCS    LF261
		CPX    #$04
		BCS    LF261
		STA    $B6
LF261: LDA    $BF
		lsr
		lsr
		lsr
		CLC
		ADC    $B5
		TAY
		BNE    LF27C
		BIT    $BF
		BMI    LF27C
		INC    $BF
		LDX    #$03
		CPX    $99
		BCS    LF27C
		LDX    #$80
		STX    $BF
LF27C: EOR    $B5
		STA    $EA
		AND    #$38
		BEQ    LF29C
		DEC    $E2
		CMP    #$20
		AND    #$08
		BNE    LF28E
		DEC    $E2
LF28E: LDX    #$01
		BIT    $B3			;check if horse is rearing
		BMI    LF29A		;skip gallup sound if so
		BCC    LF29C
		TYA
		BMI    LF29C
		INX
LF29A: STX    _audc0
LF29C: STY    $B5
		TYA
		INC    $B4			;bump frame counter
		asl					;extract bits 5-6 (div8)
		rol					;(cont'd)
		rol					;(cont'd)
		rol					;(cont'd)
		AND    #$03
		TAY
		LDA    $B4			;load frame counter
		LDX    $B3			;get animation frame
		BMI    LF2BE		;skip if horse is rearing
		CPX    #$04			;check if lasso is being thrown
		BCS    LF2BA		;skip trigger check if so
		BIT    _inpt4		;read trigger
		BMI    LF2BC		;skip if trigger not pressed
		LDX    #$24			;start lasso animation
		LSR    $EB
LF2BA:
		AND    $EB
LF2BC:
		AND    #$07
LF2BE:
		asl
		BNE    LF2D7
		CPX    #$14
		BEQ    LF2D0
		CPX    #$18
		BNE    LF2D2
		BIT    SWCHB		;check left difficulty
		BVC    LF2D2		;skip if difficulty B
		LDX    #$10			;clamp lasso to short length
LF2D0:	ROL    $EB
LF2D2:	DEX					;prev animation frame
		BPL    LF2D7		;check for wrap from frame 0
		LDX    #$03			;reset to frame 3
LF2D7:	STX    $B3			;update animation frame
		BPL    LF2DD
		LDY    #$04
LF2DD:
		sty		_cowboy_frame
		LDA    LF5F6,Y
		STA    $8F
		LDA    LF7AB,Y
		STA    $8B
		LDA    #$13
		LDY    #<LF6C7
		INX
		BNE    LF2F3
		LDA    $B4
		lsr
		LDY    #$C3
LF2F3:	STA    _audf0

		LDA    LF5F1,X
		CPX    #$05
		BCC    LF30B
		TXA
		SBC    #$05
		CMP    #$10
		BCC    LF305
		EOR    #$1F
LF305: CLC
		ADC    #<LF6C7
		TAY
		LDA    #$1F
LF30B:	STY    $8D
		LDX    #$02
		;JSR    LF5BD
		sta		_lasso_pos
		
		;update cows
		LDX    #$05
LF317:
		LDY    $A7,X
		LDA    $AD,X
		BPL    LF334
		INC    $D0,X
		SEC
		LDA    #$30
		SBC    $A1,X
		BCC    LF32E
		SBC    $AD,X
		CMP    $D0,X
		LDA    #$F7
		BCS    LF35C
LF32E: LDA    $AD,X
		SBC    #$9C
		STA    $AD,X
LF334: CPY    #$03
		BCS    LF33F
		LDA    LF7FD,Y
		BIT    $EA
		BEQ    LF34B
LF33F: LDA    $E2
		BCS    LF346
		CMP    #$80
		ror
LF346:
		;update cow horizontal position
		CLC
		ADC    $D0,X
		STA    $D0,X
		
LF34B: LDA    LF6D8,Y
		EOR    #$F8
		BPL    LF362
		BIT    $EA
		BEQ    LF364
		LDA    $E2
		AND    #$3E
		asl
		asl
LF35C:	ADC    $E3,X		;advance animation frame
		BPL    LF362
		LDA    #$18
LF362:	STA    $E3,X		;update animation frame
LF364: LDA    $BB
		AND    $BA
		EOR    LF5FB,Y
		AND    $E9			;attract cow color
		;STA    $DC,X
		sta		_lane_colors,x
		LDA    #$FF
		JSR    LF585
		BCS    LF3EA
		CPY    #$04
		BCC    LF38E
		LDA    #$04
		CMP    $A7,X
		BEQ    LF38E
		STA    _audc1
		LDA    #$FF
		
		;!! cheat miss count
		;lda		#$04
		;sta		$be
		
		DEC    $BE
		BPL    LF38A
		INC    $BE
LF38A: BNE    LF38E
		STA    $9A
LF38E: LDY    $9B,X
		BNE    LF3EA
		STY    $E3,X
		LDA    $AD,X
		SEC
		SBC    #$0C
		BPL    LF39C
		TYA
LF39C: STA    $AD,X
		INC    $C1,X
		LDA    $99
		lsr
		lsr
		LDA    $C1,X
		BCC    LF3AA
		EOR    $C9
LF3AA: PHA
		AND    #$03
		TAY
		PLA
		PHP
		lsr
		lsr
		PLP
		AND    #$07
		BEQ    LF3BB
		EOR    #$07
		BNE    LF3C1
LF3BB: TAY
		INC    $A1,X
		BCC    LF3E2
		DEY
LF3C1: EOR    #$07
		CPY    #$03
		BCC    LF3E2
		LDA    $99
		lsr
		lsr
		LDA    $C7
		BCC    LF3D8
		STA    $C9
		asl
		EOR    $C7
		asl
		asl
		ROL    $C7
LF3D8: asl
		LDY    #$03
		ROL    $C7
		BMI    LF3E0
		INY
LF3E0: LDA    #$07
LF3E2: STA    $9B,X
		STY    $A7,X
		LDA    #$9F
		STA    $D0,X
LF3EA: LDA    $D0,X
		CMP    #$A0
		LDY    $9B,X
		BCS    LF3F6
		BNE    LF3F8
		STY    $A7,X
LF3F6: LDA    #$9F
LF3F8: JSR    LF5BD
		STY    $D6,X		;set cow coarse player position
		asl
		asl
		asl
		asl
		LDY    $9B,X
		ORA    LF7A3,Y
		AND    $96			;mask off invisible cows
		STA    $CA,X		;set cow NUSIZ and REFP mode
		LDA    $D6,X
		SBC    #$05
		EOR    #$80
		BPL    LF414
		STA    $D6,X
LF414:
		LDY		$E3,X		;get animation frame
		LDA		LF607,Y		;look up graphic pointer
		STA		$EC,X		;stash graphic pointer
		LDA		LF637,Y		;look up HMOVE pointer
		STA		$F2,X		;stash HMOVE pointer
		DEX					;next cow
		BMI		LF426		;exit if done
		JMP		LF317		;update next cow
LF426:
		LDA    $BE
		JSR    LF011
		rts
	
post_advance_update:
		;----- end vertical blank	
		jsr		update8

		;wait for DLI to complete before proceeding
		lda:req	_dli_done
		lda		#0
		sta		_dli_done
				
		;set up score
		ldy		#$40
		sty		_tmp0
		ldx		#7
		lda		$be			;get miss count
		jsr		WriteDigit
		ldy		#$80
		sty		_tmp0
		ldy		#0
		inx
		lda		$bc
		jsr		WriteDigitPair
		lda		$b8
		jsr		WriteDigitPair
		and		#$3f
		bne		score_nonzero
		mva		#$8a pf_score+12
		
		;set up 10K digit
		lda		$c8
		and		#$07
		tax
		lda		LF6F0,x
		sta		pf_banner+7
score_nonzero:
		
		;draw railing
		JSR    LF15B

		jsr		UpdateInput
		bit		_pal
		bpl		is_ntsc
		jsr		vbl_update
		bit		_pal
		bvs		skip_vbl
		dec		_pal_counter
		bne		skip_vbl
		mva		#5 _pal_counter
do_vbl:
		jsr		vbl_update
skip_vbl:
		jmp		post_advance_update
is_ntsc:
		bvc		do_vbl
		dec		_pal_counter
		bne		do_vbl
		mva		#5 _pal_counter
		bne		skip_vbl

vbl_update:
		LDA    #$07
		STA    $98
		LDA    #$1E
		STA    $F8
		LDX    #$0A
		STX    _audv1
		LDA    #<$4670
		LDY    #>$4670
LF480:	STY    $80,X
		STY    $8A,X
		DEX
		STA    $80,X
		SBC    #$08
		DEX
		BNE    LF480
		STX    _audc1
		
		LDX    #$1C
		INC    $8C
		INC    $90
		LDA    #$23
		
		SEC
		LDA    $B8				;get score low digits
		SBC    $B9
		LDA    $BC
		SBC    $BD
		BEQ    LF4D0
		LDA    $80
		lsr
		SED
		lda		#0
		ADC    $B8
		STA    $B8
		AND    #$01
		BNE    LF4CA
		STX    _audc1
LF4CA:	lda		#0
		ADC    $BC
		STA    $BC
		CLD
LF4D0: LDX    #$FF
		LDA    $B3
		SEC
		SBC    #$14
		CMP    #$0E
		BCS    LF52D
		TAY
		ADC    #$0A
		SBC    $C0
		ADC    $B6
LF4E2: INX
		SBC    #$14
		BPL    LF4E2
		LDA    $9B,X			;load cow pattern
		BEQ    LF52D			;branch if no cows
		LDA    $A7,X			;load cow type
		CMP    #$04				;check if actually not cow (skull)
		BCS    LF52D			;skip if so
		lda		mcoll_flags,X	;check for lasso collision
		lsr
		bcc    LF52D
		clc
		TYA
		EOR    #$0F
		asl
		asl
		;ADC    #$2A
		ADC    #$26
		JSR    LF585
		BCS    LF52D
		LDA    #$28
		SBC    $B3
		STA    $B3
		LDY    $A7,X			;load cow type
		STY    $DC,X			;
		LDA    LF6F8,Y			;load scoring value
		
		;update score
		SED
		ADC    $B9				;add to low two digits
		STA    $B9				;update low two digits
		BCC    LF52C			;exit if no carry
		LDA    #$00				;
		ADC    $BD				;add to high two digits
		STA    $BD				;update high two digits
		BCC    LF520
		INC    $C8
LF520: AND    #$0F
		BNE    LF52C
		LDA    $BE
		CMP    #$09
		BCS    LF52C
		INC    $BE
LF52C: CLD

LF52D: LDX    #$05
		LDA    $B6
		CLC
		ADC    #$7C
		SBC    $C0
LF536: CLC
		ADC    #$14
		TAY
		CMP    #$E1
		rol
		AND    pcoll_flags,X	;check for cowboy-cow collision
		lsr
		Bcc    LF553
		LDA    $A7,X
		CMP    #$03
		BCS    LF575
		LDA    $AD,X
		BMI    LF553
		ADC    #$A0
		BCC    LF551
		LDA    #$FF
LF551: STA    $AD,X
LF553: TYA
		DEX
		BPL    LF536
		LDA    $99
		lsr
		BCC    LF572
		LDA    $B5
		ORA    $9A
		AND    #$3C
		BNE    LF572
LF564: EOR    $B7
		STA    $B7
		ADC    $C0
		STA    $C0
		CMP    #$0A
		LDA    #$FE
		BCS    LF564
LF572: JMP    LF1B5
LF575: BEQ    LF57B
		CPY    #$EB
		BCC    LF553
LF57B: LDA    #$E1
		STA    $B4
		LDA    #$FF				;make horse rear
		STA    $B3				;(cont'd)
		BNE    LF553			;unconditional branch

LF585: SEC
		SBC    $D0,X			;subtract cow position
		lsr						;divide by 16
		lsr						;
		lsr						;
		lsr						;
		TAY						;
		LDA    LF5ED,Y			;get bit
		CPY    #$04				;check if first three cow positions
		BCC    LF597			;proceed if so
		BNE    LF5BC			;exit if >4
		DEY						;count slot 4 as slot 3
LF597:	STY    $95				;stash position test slot (0-3)
		LDY    $9B,X			;load cow pattern index
		AND    LF5E6,Y			;test cow pattern against hit bit
		SEC
		BEQ    LF5BC
		LDA    $95				;load position test slot
		BNE    LF5AF			;skip if not position 0
		LDA    LF5E6,Y			;load byte with position adjustment
		CLC						;
		AND    #$70				;mask to just adjustment
		ADC    $D0,X			;shift position
		STA    $D0,X			;update position
LF5AF:	TYA						;reload cow pattern index
		asl						;
		asl						;x4
		ORA    $95				;merge in hit slot
		TAY						;
		LDA    LF6A7,Y			;fetch byte with new cow pattern
		AND    #$07				;mask to cow pattern
		STA    $9B,X			;update cow pattern
LF5BC: RTS

;==========================================================================
.proc LF5BD
		TAY
		CPY    #$60
		rol
		CPY    #$80
		rol
		CPY    #$90
		rol
		ORA    #$F8
		EOR    #$07
		STA    $96
		INY
		TYA
		AND    #$0F
		STA    $95
		TYA
		lsr
		lsr
		lsr
		lsr
		TAY
		CLC
		ADC    $95
		CMP    #$0F
		BCC    LF5E3
		SBC    #$0F
		INY
LF5E3: EOR    #$07
		RTS
.endp

;==========================================================================
.proc WriteDigitPair
		pha
		lsr
		lsr
		lsr
		lsr
		jsr		WriteDigit
		pla
		and		#$0f
.def :WriteDigit=*
		beq		is_blank
		ldy		#10
		bne		write
is_blank:
		tya
write:
		ora		_tmp0
		sta		pf_score,x
		inx
		rts
.endp

;==========================================================================
		org		$5000
font:
		;$0x
		dta		$00,$00,$00,$00,$00,$00,$00,$00		;blank
		dta		$38,$78,$18,$18,$18,$18,$7E,$00		;1
		dta		$7C,$46,$06,$3C,$60,$60,$7E,$00		;2
		dta		$3C,$46,$06,$0C,$06,$46,$3C,$00		;3
		dta		$0C,$1C,$2C,$4C,$7E,$0C,$0C,$00		;4
		dta		$7E,$60,$60,$7C,$06,$46,$7C,$00		;5
		dta		$3C,$62,$60,$7C,$66,$66,$3C,$00		;6
		dta		$7E,$42,$06,$0C,$18,$18,$18,$00		;7
		dta		$3C,$66,$66,$3C,$66,$66,$3C,$00		;8
		dta		$3C,$66,$66,$3E,$06,$46,$3C,$00		;9
		dta		$3C,$66,$66,$66,$66,$66,$3C,$00		;0
		dta		$0F,$41,$ED,$A9,$E9,$A9,$AD,$00		;ACT
		dta		$F0,$11,$53,$56,$5C,$58,$50,$00		;IV
		dta		$FE,$80,$3A,$A2,$BA,$8A,$BA,$00		;ISI
		dta		$00,$00,$E9,$AD,$AF,$AB,$E9,$00		;ON
		dta		$FF,$FF,$30,$30,$30,$FF,$FF,$60		;rail 1
		;$1x
		dta		$60,$60,$FF,$FF,$C0,$C0,$C0,$00		;rail 2
		dta		$FF,$FF,$00,$00,$00,$FF,$FF,$00		;rail 3
		dta		$00,$00,$FF,$FF,$00,$00,$00,$00		;rail 4
		dta		$00,$12,$0C,$0E,$3F,$FA,$F8,$00		;cow head (for 10K digit)

		org		$5200
dlist:
		dta		$70
		dta		$70
		dta		$70
		dta		$20
		dta		$46,a(pf_score)
		dta		$00
		dta		$56,a(pf_railing)
		dta		$16
		dta		$80
		dta		$30
dlist_preblanks:
		dta		$70
		dta		$70
dlist_cattle_lanes:
		:5 dta	$56,a(cattle_lanes+#*32),$56,a(cattle_lanes+#*32+256),$30
		dta		$56,a(cattle_lanes+5*32),$56,a(cattle_lanes+5*32+256)
dlist_postblanks:
		dta		$01,a(dlist_postblanks2)
		:9		dta	$00
dlist_postblanks2:
		dta		$56,a(pf_railing)
		dta		$16
		dta		$30
		dta		$46,a(pf_banner)
		dta		$41,a(dlist)

pf_railing:
		:12 dta $0f,$11
		:12 dta $10,$12
		
pf_banner:
		dta		$00,$00,$00,$00,$00,$00,$00,$00
		dta		$00,$8B,$8C,$8D,$8E,$00,$00,$00
		dta		$00,$00,$00,$00

		opt		o-
pf_score:
		.ds		20

		org		$5400
cattle_lanes:
		.ds		96*6
		
		org		$5b00
pm_missiles:
		org		$5c00
pm_player0:
		org		$5d00
pm_player1:
		org		$5e00
pm_player2:
		org		$5f00
pm_player3:

		org		$6000
player_frames0:

		org		$6100
player_frames1:

		org		$6200
hposp0_table:

		org		$6240
hposm0_table:

		org		$6280
sizep0_table:

		opt		o+
		org		$6800
		
_PLAYER_FRAMESCAN_A .macro
		dta		:1
		.endm
		
_PLAYER_FRAMESCAN_B .macro
		dta		:2
		.endm
		
_PLAYER_FRAMESCAN_C .macro
		dta		:3
		.endm
		
_PLAYER_FRAMESCAN_D .macro
		dta		:4
		.endm
		
;1A/4D
;               00011000
;                 11110001
;                 01100011
;              0000110011000000
;                 1111110000000000
;                 1111001111000000
;                1111001111110000
;               1111001111111100
;              1111111111111111
;             0011001111110011
;            1111111111111111
;       0011111111111111
;        1111111111111100
;       1111111111111100
;       1111111111111100
;       1111111111111111
;       1111111111111111
;       1100110000110011
;      0011001100000000
;        0000000011001100
;     0000110011000000
;         0000001100110000
;    0000001100000000
;          0000110011000000
;   0000000011001100
;           0000000000000000
;
;474D: 26 75 A5 55 C5 35 E5 15-05 05 05 05 15 F5 55 15 |&u.U.5........U.|
;475D: 15 15 15 15 05 D5 45 00-E0 00 E5 25 F5 05 05 F5 |......E....%....|

_PLAYER_FRAME0 .macro 
		:1		%00000000,%00000000,%00110000,%00000000
		:1		%00000000,%00000000,%01111000,%10000000
		:1		%00000000,%00000000,%00110001,%10000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000000,%00000000,%01111110,%00000000
		:1		%00000000,%00000000,%01111001,%11100000
		:1		%00000000,%00000000,%11110011,%11110000
		:1		%00000000,%00000001,%11100111,%11111000
		:1		%00000000,%00000011,%11111111,%11111100
		:1		%00000000,%00000001,%10011111,%10011000
		:1		%00000000,%00001111,%11111111,%11110000
		:1		%00000000,%01111111,%11111110,%00000000
		:1		%00000000,%11111111,%11111100,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%10011000,%01100110,%00000000
		:1		%00000000,%11001100,%00000000,%00000000
		:1		%00000000,%00000000,%11001100,%00000000
		:1		%00000000,%01100110,%00000000,%00000000
		:1		%00000000,%00000001,%10011000,%00000000
		:1		%00000000,%00110000,%00000000,%00000000
		:1		%00000000,%00000011,%00110000,%00000000
		:1		%00000000,%00011001,%10000000,%00000000
		:1		%00000000,%00000000,%00000000,%00000000
.endm

;00/66
;               00011000
;                 11110001
;                 01100011
;             0000110011000000
;                1111110000000000
;                1111001111000000
;               1111001111110000
;              1111001111111100
;             1111111111111111
;            0011001111110011
;           1111111111111111
;      0011111111111111
;       1111111111111100
;      1111111111111100
;      1111111111111100
;      1111111111111111
;      1111111111111111
;      1100110000110011
;      1100110000000000
;       0000000000110011
;       1100110000000000
;       0000000000110011
;        1100110000000000
;      0000000000110011
;        1100110000000000
;        0000000000000000
;
;4766: 00 E5 25 F5 05 05 F5 05-05 05 05 05 15 F5 55 15
;4776: 15 15 15 15 05 D5 45 00-E0 00

_PLAYER_FRAME1 .macro 
		:1		%00000000,%00000000,%00110000,%00000000
		:1		%00000000,%00000000,%01111000,%10000000
		:1		%00000000,%00000000,%00110001,%10000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000000,%00000000,%01111110,%00000000
		:1		%00000000,%00000000,%01111001,%11100000
		:1		%00000000,%00000000,%11110011,%11110000
		:1		%00000000,%00000001,%11100111,%11111000
		:1		%00000000,%00000011,%11111111,%11111100
		:1		%00000000,%00000001,%10011111,%10011000
		:1		%00000000,%00001111,%11111111,%11110000
		:1		%00000000,%01111111,%11111110,%00000000
		:1		%00000000,%11111111,%11111100,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%10011000,%01100110,%00000000
		:1		%00000001,%10011000,%00000000,%00000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000000,%11001100,%00000000,%00000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000000,%01100110,%00000000,%00000000
		:1		%00000000,%00000000,%01100110,%00000000
		:1		%00000000,%01100110,%00000000,%00000000
		:1		%00000000,%00000000,%00000000,%00000000
.endm


;00/4D
;
;               00011000
;                 11110001
;                 01100011
;             0000110011000000
;                1111110000000000
;                1111001111000000
;               1111001111110000
;              1111001111111100
;             1111111111111111
;            0011001111110011
;           1111111111111111
;      0011111111111111
;       1111111111111100
;      1111111111111100
;      1111111111111100
;      1111111111111111
;      1111111111111111
;      1100110000110011
;     1100110000000000
;       0000000000110011
;    1100110000000000
;        0000000000110011
;   1100110000000000
;         0000000000110011
;  1100110000000000
;0000000000000000
;
;474D: 26 75 A5 55 C5 35 E5 15-05 05 05 05 15 F5 55 15
;475D: 15 15 15 15 05 D5 45 00-E0 00

_PLAYER_FRAME2 .macro 
		:1		%00000000,%00000000,%00110000,%00000000
		:1		%00000000,%00000000,%01111000,%10000000
		:1		%00000000,%00000000,%00110001,%10000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000000,%00000000,%01111110,%00000000
		:1		%00000000,%00000000,%01111001,%11100000
		:1		%00000000,%00000000,%11110011,%11110000
		:1		%00000000,%00000001,%11100111,%11111000
		:1		%00000000,%00000011,%11111111,%11111100
		:1		%00000000,%00000001,%10011111,%10011000
		:1		%00000000,%00001111,%11111111,%11110000
		:1		%00000000,%01111111,%11111110,%00000000
		:1		%00000000,%11111111,%11111100,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111000,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%11111111,%11111110,%00000000
		:1		%00000001,%10011000,%01100110,%00000000
		:1		%00000011,%00110000,%00000000,%00000000
		:1		%00000000,%00000000,%00110011,%00000000
		:1		%00000110,%01100000,%00000000,%00000000
		:1		%00000000,%00000000,%00011001,%10000000
		:1		%00001100,%11000000,%00000000,%00000000
		:1		%00000000,%00000000,%00001100,%11000000
		:1		%00011001,%10000000,%00000000,%00000000
		:1		%00000000,%00000000,%00000000,%00000000
.endm

;34/7F
;         00100110
;         01100110
;         01100110
;         00101111
;             1111001111000000
;            1111111111110000
;           1111001111111100
;          1111111111111111
;         0011001111110011
;        0000111111111111
;   0000000011111111
;    0000001111111100
;     0000111111111100
;    0000111111111111
;    0000111111110011
;   0000111111110011
;  0000111111110011
; 0000111111110011
;     11111111
;     11111111
;     11110111
;      11100111
;      11100011
;       11000011
;        11000011
;        01100001
;
;477F: 00 F0 F2 02 F0 00 02 B0-17 15 1D 0F 1D F5 F7 55
;478F: 15 1F 1F 15 1F D7 00 00-00 70

_PLAYER_FRAME4 .macro
		:1		%00000000,%00100110,%00000000,%00000000
		:1		%00000000,%01100110,%00000000,%00000000
		:1		%00000000,%01100110,%00000000,%00000000
		:1		%00000000,%00101111,%00000000,%00000000
		:1		%00000000,%00001111,%00111100,%00000000
		:1		%00000000,%00011111,%11111110,%00000000
		:1		%00000000,%00111100,%11111111,%00000000
		:1		%00000000,%01111111,%11111111,%10000000
		:1		%00000000,%00110011,%11110011,%00000000
		:1		%00000000,%00011111,%11111110,%00000000
		:1		%00000000,%00111111,%11000000,%00000000
		:1		%00000000,%01111111,%10000000,%00000000
		:1		%00000000,%11111111,%11000000,%00000000
		:1		%00000001,%11111111,%11100000,%00000000
		:1		%00000001,%11111110,%01100000,%00000000
		:1		%00000011,%11111100,%11000000,%00000000
		:1		%00000111,%11111001,%10000000,%00000000
		:1		%00001111,%11110011,%00000000,%00000000
		:1		%00001111,%11110000,%00000000,%00000000
		:1		%00001111,%11110000,%00000000,%00000000
		:1		%00001111,%01110000,%00000000,%00000000
		:1		%00000111,%00111000,%00000000,%00000000
		:1		%00000111,%00011000,%00000000,%00000000
		:1		%00000011,%00001100,%00000000,%00000000
		:1		%00000001,%10000110,%00000000,%00000000
		:1		%00000000,%11000010,%00000000,%00000000
.endm

player_frames_a:
		_PLAYER_FRAME0	_PLAYER_FRAMESCAN_A
		_PLAYER_FRAME1	_PLAYER_FRAMESCAN_A
		_PLAYER_FRAME2	_PLAYER_FRAMESCAN_A
		_PLAYER_FRAME4	_PLAYER_FRAMESCAN_A
		
player_frames_b:
		_PLAYER_FRAME0	_PLAYER_FRAMESCAN_B
		_PLAYER_FRAME1	_PLAYER_FRAMESCAN_B
		_PLAYER_FRAME2	_PLAYER_FRAMESCAN_B
		_PLAYER_FRAME4	_PLAYER_FRAMESCAN_B
		
player_frames_c:
		_PLAYER_FRAME0	_PLAYER_FRAMESCAN_C
		_PLAYER_FRAME1	_PLAYER_FRAMESCAN_C
		_PLAYER_FRAME2	_PLAYER_FRAMESCAN_C
		_PLAYER_FRAME4	_PLAYER_FRAMESCAN_C
		
player_frames_d:
		_PLAYER_FRAME0	_PLAYER_FRAMESCAN_D
		_PLAYER_FRAME1	_PLAYER_FRAMESCAN_D
		_PLAYER_FRAME2	_PLAYER_FRAMESCAN_D
		_PLAYER_FRAME4	_PLAYER_FRAMESCAN_D

;==========================================================================
		org		$45e6

;==========================================================================
; Cow pattern collision table
;
; D0-D3: Bits indicating where cows are
; D4-D7: Horizontal position adjustment when first cow removed
;
LF5E6:	.byte	$01		;*--	+0
		.byte	$01		;*--	+0
		.byte	$13		;**-	+1 position
		.byte	$25		;*-*	+2 positions
		.byte	$17		;***	+1 position
		.byte	$49		;*---*	+4 positions
		.byte	$2D		;*-*-*	+2 positions
		
;==========================================================================
LF5ED: .byte $01,$02,$04,$00
LF5F1: .byte $08,$21,$1F,$1A,$1F

;==========================================================================
; player animation frame pointers
;
LF5F6:	.byte	<LF71A
		.byte	<LF700
		.byte	<LF700
		.byte	<LF700
		.byte	<LF734

;==========================================================================
LF5FB:	.byte $2E
		.byte	$2A
		.byte	$22
		.byte	$00
		.byte	$0E

;==========================================================================
; Tiles (digits 0-9, Activision logo) and interleaved tables
;
		.byte	$3C			;--****--
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$3C			;--****--

;cow animation frame pointers
LF607:	.byte	<[LF68C-1]
		.byte	$7E			;-******-
		.byte	$18			;---**---
		.byte	$18			;---**---
		.byte	$18			;---**---
		.byte	$18			;---**---
		.byte	$78			;-****---
		.byte	$38			;---**---
		.byte	<[LF67E-1]
		.byte	$7E			;-******-
		.byte	$60			;-**-----
		.byte	$60			;-**-----
		.byte	$3C			;--****--
		.byte	$06			;-----**-
		.byte	$46			;-*---**-
		.byte	$7C			;-*****--
		.byte	<[LF66F-1]
		.byte	$3C			;--****--
		.byte	$46			;-*---**-
		.byte	$06			;-----**-
		.byte	$0C			;----**--
		.byte	$06			;-----**-
		.byte	$46			;-*---**-
		.byte	$3C			;--****--
		.byte	<[LF67E-1]
		.byte	$0C			;----**--
		.byte	$0C			;----**--
		.byte	$7E			;-******-
		.byte	$4C			;-*--**--
		.byte	$2C			;--*-**--
		.byte	$1C			;---***--
		.byte	$0C			;----**--
		.byte	<[LF67E-1]
		.byte	$7C			;-*****--
		.byte	$46			;-*---**-
		.byte	$06			;-----**-
		.byte	$7C			;-*****--
		.byte	$60			;-**-----
		.byte	$60			;-**-----
		.byte	$7E			;-******-
		.byte	<[LF69C-1]
		.byte	$3C			;--****--
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$7C			;-*****--
		.byte	$60			;-**-----
		.byte	$62			;-**---*-
		.byte	$3C			;--****--
		
;cow HMOVE frame pointers
LF637:	.byte	<[LF6AD-1]
		.byte	$18			;---**---
		.byte	$18			;---**---
		.byte	$18			;---**---
		.byte	$0C			;----**--
		.byte	$06			;-----**-
		.byte	$42			;-*----*-
		.byte	$7E			;-******-
		.byte	<[LF6CA-1]
		.byte	$3C			;--****--
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$3C			;--****--
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$3C			;--****--
		.byte	<[LF6CA-1]
		.byte	$3C			;--****--
		.byte	$46			;-*---**-
		.byte	$06			;-----**-
		.byte	$3E			;--*****-
		.byte	$66			;-**--**-
		.byte	$66			;-**--**-
		.byte	$3C			;--****--
		.byte	<[LF6CA-1]
		.byte	$E9			;***-*--*    --------
		.byte	$AB			;*-*-*-**    --------
		.byte	$AF			;*-*-****    ***-*--*
		.byte	$AD			;*-*-**-* -> *-*-**-*
		.byte	$E9			;***-*--*    *-*-****
		.byte	$00			;--------    *-*-*-**
		.byte	$00			;--------    ***-*--*
		.byte	<[LF6BB-1]
		.byte	$BA			;*-***-*-    *******-
		.byte	$8A			;*---*-*-    *-------
		.byte	$BA			;*-***-*-    --***-*-
		.byte	$A2			;*-*---*- -> *-*---*-
		.byte	$3A			;--***-*-    *-***-*-
		.byte	$80			;*-------    *---*-*-
		.byte	$FE			;*******-    *-***-*-
		.byte	<[LF6A5-1]
		.byte	$50			;-*-*----    ****----
		.byte	$58			;-*-**---    ---*---*
		.byte	$5C			;-*-***--    -*-*--**
		.byte	$56			;-*-*-**- -> -*-*-**-
		.byte	$53			;-*-*--**    -*-***--
		.byte	$11			;---*---*    -*-**---
		.byte	$F0			;****----    -*-*----
		
		.byte $00
		.byte	$AD			;*-*-**-*    ----****
		.byte	$A9			;*-*-*--*    -*-----*
		.byte	$E9			;***-*--*    ***-**-*
		.byte	$A9			;*-*-*--* -> *-*-*--*
		.byte	$ED			;***-**-*    ***-*--*
		.byte	$41			;-*-----*    *-*-*--*
		.byte	$0F			;----****    *-*-**-*

LF66F:	.byte	$0C		;----**--
		.byte	$28		;--*-*---
		.byte	$54		;-*-*-*--
		.byte	$AC		;*-*-**--
		.byte	$AA		;*-*-*-*-
		.byte	$FE		;*******-
		.byte	$7F		;-*******
		.byte	$7E		;-******-
		.byte	$7E		;-******-
		.byte	$FD		;******-*
		.byte	$7F		;-*******
		.byte	$1C		;---***--
		.byte	$18		;---**---
		.byte	$24		;--*--*--
		.byte	$00		;--------
LF67E:	.byte	$15		;---*-*-*      --------
		.byte	$A5		;*-*--*-*    -*--*---
		.byte	$A5		;*-*--*-*    --**----
		.byte	$A5		;*-*--*-*    --***---
		.byte	$AA		;*-*-*-*-     -******-
		.byte	$FE		;*******-      *****-*-
		.byte	$BF		;**-*****        -*****--
		.byte	$FE		;*******-         *******-
		.byte	$7C		;-*****--          **-*****
		.byte	$FA		;*****-*-        *******-
		.byte	$7E		;-******-        *-*-*-*-
		.byte	$38		;--***---        *-*--*-*
		.byte	$30		;--**----        *-*--*-*
		.byte	$48		;-*--*---        *-*--*-*
						;               ---*-*-*
		
LF68C:	.byte	$00		;--------          --------		(shared!)
		.byte	$A0		;*-*-----        ---*--*-
		.byte	$85		;*----*-*        ----**--
		.byte	$A2		;*-*---*-        ----***-
		.byte	$A5		;*-*--*-*        --******
		.byte	$AA		;*-*-*-*-        *****-*-
		.byte	$FE		;*******-       *****---
		.byte	$7F		;-*******    *-******
		.byte	$BF		;*-******    -*******
		.byte	$F8		;*****---      *******-
		.byte	$FA		;*****-*-      *-*-*-*-
		.byte	$3F		;--******      *-*--*-*
		.byte	$0E		;----***-     *-*---*-
		.byte	$0C		;----**--       *----*-*
		.byte	$12		;---*--*-    *-*-----
		
		.byte	$00		;--------    --------

LF69C:	.byte	$03		;------**
		.byte	$05		;-----*-*
		.byte	$0E		;----***-
		.byte	$1E		;---****-
		.byte	$3C		;--****--
		.byte	$54		;-*-*-*--
		.byte	$BA		;*-***-*-
		.byte	$82		;*-----*-
		.byte	$44		;-*---*--
LF6A5:	.byte	$00
		.byte	$00
LF6A7:	.byte	$00		;!! also start of state table for cow removal!
		.byte	$00
		.byte	$00
		.byte	$00	
		.byte	$00
		.byte	$00
LF6AD:	.byte	$00		;none		(frame 0 start)
		.byte	$30		;left 3
		.byte	$E1		;right 2
		.byte	$11		;left 1
		.byte	$00		;none
		.byte	$00		;none
		.byte	$E1		;right 2
		.byte	$00		;none
		.byte	$31		;left 3
		.byte	$10		;left 1
		.byte	$02		;none
		.byte	$03		;none
		.byte	$02		;none
		.byte	$00		;none
LF6BB:	.byte	$E1		;left 2
		.byte	$00		;none
		.byte	$00		;none
		.byte	$01		;none
		.byte	$03		;none
		.byte	$20		;left 2
		.byte	$F5		;right 1
		.byte	$F3		;right 1
		.byte	$E0		;right 2
		.byte	$F0		;right 1
		.byte	$F0		;right 1
		.byte	$00		;none
LF6C7:	.byte	$00		;none
		.byte	$20		;left 2
		.byte	$00		;none
		
LF6CA:
		.byte	$20		;left 2
		.byte	$00		;none
		.byte	$00		;none
		.byte	$00		;none
		.byte	$00		;none
		.byte	$E0		;right 2
		.byte	$10		;left 1
		.byte	$10		;left 1
		.byte	$20		;left 2
		.byte	$10		;left 1
		.byte	$10		;left 1
		.byte	$00		;none
		.byte	$00		;none
		.byte	$90		;right 7
LF6D8:	.byte	$38		;left 3
		.byte	$18
		.byte	$08
		.byte	$D8
		.byte	$D0
		.byte	$42		;4 clock missile
		.byte	$B2		;2 clock missile
		.byte	$22		;1 clock missile
		.byte	$C2		;4 clock missile
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		.byte	$C2
		
;==========================================================================
; Bonus rollover table
;
; This drives the 10K digit to the left of the Activision logo. After 10K,
; a cow shows up to the left, and beyond that, 2-7. It loops after every
; 80K.
;
LF6F0: .byte $80,$93,$82,$83,$84,$85,$86,$87

;==========================================================================
LF6F8: .byte $24,$14,$02
LF6FB: .byte $99,$2C,$8C,$0C,$D6

;==========================================================================
; player graphic and HMOVE tables
;
LF700:	.byte	$00,$A0,$05,$A0,$05,$A0,$05,$A0,$A5,$FF,$FF,$FE,$FE,$FE,$7F,$FF
		.byte	$5D,$FF,$DE,$DC,$D8,$E0,$28,$63,$F1,$18
LF71A:	.byte	$00,$0A,$28,$10,$14,$28,$0A,$50,$A5,$FF,$FF,$FE,$FE,$FE,$7F,$FF
		.byte	$5D,$FF,$DE,$DC,$D8,$E0,$28,$63,$F1,$18
LF734:	.byte	$61,$C3,$C3,$E3,$E7,$F7,$FF,$FF,$3D,$3D,$3D,$3D,$3F,$3E,$1E,$0F
		.byte	$3F,$5D,$FF,$DE,$FC,$D8,$2F,$66,$66		;!! 1 byte shared with next table!
LF74D:	.byte	$26,$75,$A5,$55,$C5,$35,$E5,$15,$05,$05,$05,$05,$15,$F5,$55,$15
		.byte	$15,$15,$15,$15,$05,$D5,$45,$00,$E0
LF766:	.byte	$00,$E5,$25,$F5,$05,$05,$F5,$05,$05,$05,$05,$05,$15,$F5,$55,$15
		.byte	$15,$15,$15,$15,$05,$D5,$45,$00,$E0
LF77F:	.byte	$00,$F0,$F2,$02,$F0,$00,$02,$B0,$17,$15,$1D,$0F,$1D,$F5,$F7,$55
		.byte	$15,$1F,$1F,$15,$1F,$D7,$00,$00,$00

;==========================================================================
; Reset data (12 bytes)
;
LF798:	.byte	$70,$03,$40,$03,$03,$24,$63,$05,$44,$25,$AA

;==========================================================================
; cow NUSIZ / reflect table
LF7A3:
		dta		$00		;single
		dta		$00		;single
		dta		$01		;two copies close
		dta		$02		;two copies medium
		dta		$03		;three copies close
		dta		$04		;two copies wide
		dta		$06		;three copies medium
		dta		$08		;single, reflected
		
;==========================================================================
; player HMOVE animation frame pointers
;
LF7AB:	.byte	<LF74D
		.byte	<LF766
		.byte	<LF74D
		.byte	<LF766
		.byte	<LF77F

;==========================================================================
		org		$47fc
LF7FC: .byte $00
LF7FD: .byte $F0,$E0,$C0

		run		__init

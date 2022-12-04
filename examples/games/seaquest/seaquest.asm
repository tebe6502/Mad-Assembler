; Disassembly of Seaquest.bin
; Disassembled Fri Jun 08 22:14:00 2012
; Using DiStella v3.0
;
; Command Line: ..\pinball\distella\distella.exe Seaquest.bin
;

SPRITE_HOFFSET = $28

; $81 = frame counter
; $82 = random number seed
; $85 = attract mode XOR mask
; $86 = attract mode AND mask
; $87 = player 1 color
; $88 = player 2 color
; $89 = water color
; $8A = player 1 underwater color
; $8B =	player 2 underwater color
; $8C = header color
; $8D = water color #2
; $8E = oxygen bar color
; $8F = sea bed color
; $90 = used up O2 bar color
; $91 = logo and diver color
; $92,$93 = score digit 1 temp
; $94,$95 = score digit 2 temp
; $96,$97 = score digit 3 temp
; $98,$99 = score digit 4 temp, player sub graphics pointer
; $9A,$9B = score digit 5 temp
; $9C,$9D = score digit 6 temp
; $9E-A1 = enemy positions
; $A2 = attract counter (inc on $81 rollover, cleared on movement)
; $A4-A7 = enemy repeat flags
;	D2 = 1	left
;	D1 = 1	middle
;	D0 = 1	right
; $A8-AB = visible enemy repeat flags
; $AC-AF = shark/sub colors
; $B0-B3 = diver hurry-up flags
; $B4 = row index of enemy hit by missile ($FF = none)
; $B5 = row index of enemy hit by player ($FF = none)
; $B6 = row index of diver rescued by player ($FF = none)
; $B7 = current player (0/1)
; $B8 = score hi byte
; $B9 = score med byte
; $BA = score low byte
; $BB = lives left
; $BD = wave (0+)
; $BE = diver count (0-6)
; $BF = other player score hi byte
; $C0 = other player score med byte
; $C1 = other player score low byte
; $C6 = player horizontal position
; $C7-CA = diver/shot horizontal position
; $CE = shark/sub point value
; $D6 = player reflect bit (bit 3)
; $D9-DC = enemy flags
;	D4 = 1		diver present
;	D3 = 1		reflect horizontally
;	D0-D2		shark/sub frame
; $DD = shark vertical offset (0-7)
; $E0 = player sub frame
; $E1 = player vertical location
; $E6 = O2 level (0-64)
; $E7 = player missile position
; $E8 = victory flags
;	0	normal
;	1	refilling (NOT when surfacing with less than 6 divers)
;	6	awarding points for remaining O2
; $E9 = death effect downcounter
; $EA = diver sound effect counter
; $F6 = enemy patrol boat position
; $F8 = player/enemy collision byte

hposp0	equ		$d000
m0pf	equ		$d000
hposp1	equ		$d001
hposp2	equ		$d002
hposp3	equ		$d003
hposm0	equ		$d004
p0pf	equ		$d004
hposm1	equ		$d005
hposm2	equ		$d006
hposm3	equ		$d007
p3pf	equ		$d007
sizep0	equ		$d008
m0pl	equ		$d008
sizep1	equ		$d009
sizep2	equ		$d00a
m2pl	equ		$d00a
sizep3	equ		$d00b
sizem	equ		$d00c
grafp0	equ		$d00d
p1pl	equ		$d00d
grafp1	equ		$d00e
p2pl	equ		$d00e
grafp2	equ		$d00f
p3pl	equ		$d00f
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
hitclr	equ		$d01e
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
chactl	equ		$d401
dlistl	equ		$d402
dlisth	equ		$d403
hscrol	equ		$d404
vscrol	equ		$d405
pmbase	equ		$d407
chbase	equ		$d409
wsync	equ		$d40a
vcount	equ		$d40b
nmien	equ		$d40e

_audc0   =  $06
_audc1   =  $07
_audf0   =  $08
_audf1   =  $09
AUDV0   =  $0a
AUDV1   =  $0b
ballptr	= $10
m0_ypos	= $12
pconsol	= $13
qfbpos	= $14
p0_ypos	= $15

INPT4	=  $18
INPT5	=  $19
SWCHB   =  $1b

;The quick framebuffer is used to emulate the repeating sprites with a
;mode C hscrolled normal playfield (20 bytes displayed, 24 bytes fetched).
;Wide fetch places the first byte at $20, so we display starting at $24.
quick_fb = $20		;$20-5F

missile_data	= $3300
player0_data	= $3400
player1_data	= $3500
player2_data	= $3600
player3_data	= $3700

		org		$2000
		
;==========================================================================
		.pages 1
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
		.endpg

;==========================================================================
.proc _main
		lda		#248/2
		cmp:rne	vcount

		lda		#0
		sei
		sta		irqen
		sta		nmien

		tax
clear_loop:
		sta		0,x
		sta		missile_data,x
		sta		player0_data,x
		sta		player1_data,x
		sta		player2_data,x
		sta		player3_data,x
		sta		playfield,x
		sta		playfield_logo,x
		inx
		bne		clear_loop
		
		ldx		#$00
		ldy		#$0F
init_logo:
		lda		LFE5B,y
		sta		playfield_logo+4,x
		lda		LFE6B,y
		sta		playfield_logo+5,x
		lda		LFE7B,y
		sta		playfield_logo+6,x
		lda		LFE8B,y
		sta		playfield_logo+7,x
		lda		LFE9B,y
		sta		playfield_logo+8,x
		lda		LFEAB,y
		sta		playfield_logo+9,x
		txa
		add		#$10
		tax
		dey
		bpl		init_logo
		
		ldx		#4
		ldy		#195
init_o2meter:
		mva		LFF66,x player0_data,y
		mva		LFF6B,x player1_data,y
		mva		LFF70,x player2_data,y
		iny
		dex
		bpl		init_o2meter

		lda		#0		
		sta		audc1
		sta		audc3
		sta		sizep0
		sta		sizep1
		sta		sizep2
		sta		sizep3
		sta		chactl
		sta		vscrol
		sta		skctl
		mwa		#dlist dlistl
		lda		#3
		sta		sizem
		sta		gractl
		sta		skctl
		mva		#$3d dmactl
		mva		#>charset chbase
		mva		#$3f swchb
		mva		#8 consol
		mva		consol pconsol
		mva		#>[missile_data-$0300] pmbase
		mva		#$f8 audctl
		sta		stimer
		jmp		start
.endp

startvbl:
		jsr		updateAudio

		;copy START and SELECT into game reset/select switches
		lda		consol
		eor		swchb
		and		#3
		eor		swchb
		sta		swchb
		
		;check for OPTION and flip difficulty switches
		lda		consol
		tax
		eor		#$04
		and		pconsol
		stx		pconsol
		ldy		#0
		and		#$04
		seq:ldy	#$c0
		tya
		eor		swchb
		sta		swchb
		rts

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
		lda		audv0
		and		#$0f
		ora		audio_ctab,x
		sta		audc2		

		lda		_audc1
		and		#$0f
		tax
		lda		audv1
		and		#$0f
		ora		audio_ctab,x
		sta		audc4
		rts
.endp

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

;==========================================================================
START:
		SEI
		CLD
		LDX		#$FF
		TXS
		ldx		#$80
		JSR		LFB56
		INC		$82
		JMP		LF716
		
;==========================================================================
; GAME LOOP
;
LF00E:	LDX		#$02
		LDY		$E7
		
		;position missile 0 (sub fire)
		tya
		seq:add	#SPRITE_HOFFSET
		sta		hposm0
		
		;attract colors
		LDX		#$0A
LF01A:	LDA		LFCF0,X			;load color from color table
		EOR		$85				;attract
		AND		$86				;attract
		STA		$87,X			;store into active color table
		DEX
		BPL		LF01A

		LDX		#$03
LF03C:	LDY		#$08
		LDA		$9E,X			;load enemy position
		CMP		#$80
		BCC		LF04A
		SBC		#$80
		JSR		LFFAF			;shr4
		TAY
LF04A:	LDA		$A4,X
		AND		LFEEB,Y
		STA		$A8,X
		DEX
		BPL		LF03C
		LDY		#$02
LF056:	TYA
		asl
		TAX
		LDA		$00B8,Y			;load score byte
		jsr		LFFAF			;shr4
		add		#2
		sta		score_playfield+4,x
		LDA		$00B8,Y
		AND		#$0F			;get low digit
		add		#2
		sta		score_playfield+5,x
		DEY
		BPL		LF056
		INY
		
		;trim off leading zeroes on score
LF070:	LDA		score_playfield+4,y
		cmp		#2
		BNE		LF080
		LDA		#0				;blank
		sta		score_playfield+4,y
		INY
		CPY		#5
		BNE		LF070
LF080:

		;draw extra lives
		ldx		#6
		lda		#0
clear_lives:
		dex
		sta		playfield_lives+4,x
		bne		clear_lives
		
		lda		#1
		ldx		$bb
		beq		no_lives
set_lives:
		dex
		sta		playfield_lives+4,x
		bne		set_lives
no_lives:		

		;draw divers
		ldx		#6
		lda		#0
clear_divers:
		dex
		sta		playfield_divers+4,x
		sta		playfield_divers+4+16,x
		bne		clear_divers
		ldx		$be
		beq		no_divers
set_divers:
		mva		#$0c playfield_divers+4-1,x
		mva		#$0d playfield_divers+4+16-1,x
		dex
		bne		set_divers
no_divers:

		;draw O2 meter
		lda		$E6
		lsr
		lsr
		pha
		tax
		tay
		beq		empty_o2
		lda		#$aa
set_o2:
		dex
		sta		playfield_o2meter+6,x
		bne		set_o2
empty_o2:
		lda		#$55
		bne		clear_o2_entry
o2_table:
		dta		$55,$95,$a5,$a9
clear_o2:
		sta		playfield_o2meter+6,y
		iny
clear_o2_entry:
		cpy		#$10
		bne		clear_o2
		pla
		tay
		lda		$E6
		and		#3
		beq		even_o2
		tax
		lda		o2_table,x
		sta		playfield_o2meter+6,y
even_o2:

		;--- display kernel address setup
		mva		#>sub_graphics $93

		;erase player sub
		lda		#0
		ldx		p0_ypos
		ldy		#$0c
erase_player:
		sta		player0_data,x
		inx
		dey
		bne		erase_player

		lda		$D6					;get player reflect bit
		lsr							;move to bit 2
		ora		$E0					;merge in current player frame
		tax
		LDA		LFCFB,X				;look up frame
		STA		$98					;set LSB of frame pointer
		
		LDX		$E9					;check death counter
		BEQ		LF18F_a				;skip if no death
		CPX		#$0F
		BCS		LF18F_a
		CPX		#$0A
		BCS		LF18A_a
		LDX		#$0A
LF18A_a:
		LDA		LFDFA-10,X
		STA		$98
LF18F_a:
		mva		#>sub_graphics $99

		lda		$e1					;get vertical position
		beq		no_player			;skip if invisible (game over)
		add		#57					;convert to beam pos
		sta		p0_ypos

		;draw player sub
		tax
		ldy		#$0c
draw_player:
		lda		($98),y
		sta		player0_data,x
		inx
		dey
		bne		draw_player
		
		;blank out lines near sea entry
		lda		#0
		sta		player0_data+78
		sta		player0_data+79
		sta		player0_data+80
		sta		player0_data+81
no_player:
				
		;----- draw patrol boat
		lda		$E0					;get sub frame
		ora		#$04				;use reflected version for patrol sub
		tax
		LDA		LFCFB,X
		add		#$04
		STA		$92		

		ldx		#71
		ldy		#7
patrol_boat_loop:
		lda		($92),y
		sta		player1_data,x
		inx
		dey
		bpl		patrol_boat_loop

;----- draw divers
		mva		#>diver0 ballptr+1
		ldx		#3
diver_loop:
		stx		$e3
		lda		$D9,X
		and		#$0f
		tay
		mva		ball_frames,y ballptr
		lda		lane_ypos_table,x
		tax
		ldy		#$0e
diver_scan_loop:
		lda		(ballptr),y
		sta		player3_data,x
		inx
		dey
		bpl		diver_scan_loop
		ldx		$e3
		dex
		bpl		diver_loop

		;update missile
		ldx		m0_ypos
		mva		#0 missile_data,x
		lda		$e1
		cmp		#$11
		bcc		missile_hidden
		add		#$41
		tax
		stx		m0_ypos
		mva		#3 missile_data,x
missile_hidden:

vbl_wait:
		lda		vcount
		bpl		vbl_ok
		cmp		#248/2
		bcc		vbl_wait
vbl_ok

;--- BEGIN DISPLAY KERNEL
		
		ldy		$8C
		ldx		$B7				;get player index
		lda		$87,X			;get player color
		tax
		
		lda		#32/2
		cmp:rne	vcount		
		
		sty		colbk
		stx		colpm0
		;##ASSERT vpos=32
		stx		colpm1
		stx		colpf0
		
		lda		#42/2
		cmp:rne	vcount
		
		;previously lives code
		;##ASSERT vpos=42
		LDX		#$04
LF0D6:	STA		WSYNC
		DEX
		BPL		LF0D6

		LDX		#$08
LF0F3:	STA		WSYNC
		DEX						;next line
		BPL		LF0F3			;repeat until 9 lines drawn
		LDA		$CB
		AND		#$0F
		STA		$E2

		lda		$f6				;load patrol boat position
		seq:add	#SPRITE_HOFFSET
		sta		hposp1
		
		STA		WSYNC
		lda		$C6				;get sub position
		seq:add	#SPRITE_HOFFSET
		sta		hposp0

		LDX		$CB
		STX		$E2
		;##ASSERT vpos=57
		STA		WSYNC
		LDA		#$74
		EOR		$85
		AND		$86
		STA		colbk

		LDX		$B7
		LDA		$8A,X
		STA		colpm0
		LDA		#$35
		STA		WSYNC
		sta		sizep0
		LDX		$E9					;check death counter
		BEQ		LF18F				;skip if no death
		LDA		LFF17,X				;load explosion color
		STA		colpm0				;set explosion color
LF18F:		
		LDX		#$09
		STX		colpm1
		STX		hitclr
		LDX		#$09
LF199:	LDA		LFCE6,X
		EOR		$85
		AND		$86
		STA		WSYNC
		STA		colbk
		DEX
		BPL		LF199

		LDA		$82
		STA		$E3
		LDX		#$09
LF1BB:	LDA		$E3
		CMP		#$80
		ROL
		STA		$E3
		AND		#$02
		EOR		$89
		STA		WSYNC
		STA		colbk				;update water surface color
LF1E5:
		DEX
		BPL		LF1BB

		LDA		$8D
		STA		WSYNC
		STA		colbk
		LDA		#$FF
		LDX		#$06
LF206:	STA		$B0,X		;clear collision flags
		DEX
		BPL		LF206
		STA		WSYNC
		
		mva		#$3e dmactl
		
		LDA		$89
		STA		colbk
		LDX		#$03
		
		;check for player/enemy collision (P0/P1)
		LDA		p1pl
		STA		$F8
		
		;--------- lane loop start
		
LF219:	STX		$E5
		STA		WSYNC

		;position enemy
		LDA		$A8,X			;load enemy repeat flags
		BEQ		LF240			;skip if not visible
		TAY
		LDA		LFF51,Y			;load offset
		CLC
		ADC		$9E,X			;add base position
		CMP		#$A0
		BCC		LF240
		SBC		#$60
LF240:
		tax
		add	#SPRITE_HOFFSET
		tay
		and		#7
		sta		hscrol
		tya
		lsr
		lsr
		lsr
		sta		$cc				;save write position for enemy
		tax
		STA		WSYNC
		LDA		#$00
		sta		quick_fb,x
		sta		quick_fb+2,x
		sta		quick_fb+4,x
		STA		WSYNC

LF285:
		STA		WSYNC
		LDX		$E5
		LDA		$C7,X
		CMP		#$A0
		BCC		LF2A1
		LDA		#$00
LF2A1:
		tax
		seq:add	#SPRITE_HOFFSET

		sta		hposp3
		STA		WSYNC
		
LF2D4:	STA		WSYNC
		LDX		$E5
		LDA		$A8,X
		TAX
		mva		enemy_repeat_2,X enemy_write_2+1	;(!) CODE WRITE
		mva		enemy_repeat_3,X enemy_write_3+1	;(!) CODE WRITE

		LDX		$E5
		LDA		$D9,X			;load enemy data
		AND		#$0F			;mask off to frame and reflect bit
		TAX
		STA		WSYNC
		LDA		sub_table,x
		LSR
		LDA		LFFA2,X			;load shark/sprite table
		BCS		LF31C			;branch if sub
		ADC		$DD				;apply sinusoidal vertical motion
LF31C:	STA		$92
		STA		hitclr
		LDX		$E5				;get current lane
		LDA		$AC,X			;get shark/sub color
		STA		colpf0			;update shark/sub color
		ldx		$cc				;load playfield byte offset
		ldy		#$0E
		STA		WSYNC
LF34F:
		LDA		($92),Y			;load enemy graphics
		STA		quick_fb,x
enemy_write_2:
		STA		quick_fb+2,x
enemy_write_3:
		STA		quick_fb+4,x
		dey						;one scan down
		STA		WSYNC
		BPL		LF34F			;loop back for remaining scans
		BMI		LF382			;break

LF382:	STA		WSYNC
		LDX		$E5
		
		;check for player hitting diver or enemy shot (P0/BL)
		lda		p3pl
		lsr
		bcc		LF3A1
		STX		$B6			;store row index
LF3A1:
		;check for missile hitting enemy (M0/P1)
		lda		m0pf
		lsr
		bcc		LF3A7
		STX		$B4			;store row index
LF3A7:
		;check for enemy hitting diver (P1/BL)
		lda		p3pf
		lsr
		bcc		LF3AD
		STA		$B0,X		;set diver flag
LF3AD:
		;test for player hitting enemy (P0/P1)
		lda		p0pf
		lsr
		bcc		LF3B3
		STX		$B5			;store row index
LF3B3:	DEX
		BMI		LF3C1
		JMP		LF219

;==========================================================================
LF3B9:	.byte $C0,$C0,$C0,$C0,$B0,$B0,$A0,$A0

;==========================================================================
LF3C1:	LDX		#$07
LF3C3:	LDA		LF3B9,X
		EOR		$85
		AND		$86
		STA		WSYNC

		STA		colbk
		DEX
		BPL		LF3C3
		LDA		$8F
		STA		colpf2
		LDY		#$04
LF3DD:	STA		WSYNC
		DEY
		BNE		LF3DD
		LDA		$8F
		STA		WSYNC
		STA		colbk
		mva		#$37 hposp0
		mva		#$3f hposp1
		mva		#$47 hposp2
		mva		#0 sizep0
		
		AND		#$0F
		TAX
		STA		WSYNC
		LDA		$8D
		STA		colpm0
		STA		colpm1
		STA		colpm2
		mva		$90 colpf0
		lda		#$3d
		STA		WSYNC
		sta		dmactl
		
		
		
;==== oxygen bar
		STA		WSYNC
		STA		WSYNC
		LDY		#$00
		LDX		$8E
		LDA		$E1
		CMP		#$0D
		BEQ		LF46F
		LDA		$E6
		BEQ		LF46F
		LDA		$E9
		BNE		LF46F
		LDA		#$10
		CMP		$E6
		BCC		LF46F
		LDY		#$0F
		AND		$81
		BNE		LF46F
		LDX		$8D
LF46F:	STX		colpf1
		STY		$F9
		LDX		#$04
		
LF47E:	STA		WSYNC
		DEX
		BPL		LF47E

;==== divers
		STA		WSYNC

		mva		#$3d dmactl

		STA		WSYNC
		STA		WSYNC

		LDX		#$82
		LDA		$BE
		CMP		#$06
		BNE		LF4F9
		LDA		$E1
		CMP		#$0D
		BEQ		LF4F9
		LDA		$81
		AND		#$08
		BNE		LF4F9
		LDX		#$06
LF4F9:	TXA
		EOR		$85
		AND		$86
		STA		colpf0
		LDX		#$09
LF506:	STA		WSYNC			;formerly diver draw loop
		LDA		#$00
		DEX
		BNE		LF506
		STA		WSYNC
		STA		WSYNC
		
		LDA		$8D
		STA		colbk
		LDA		$91
		STA		colpm3		;!! used for next frame!
		STA		colpf0
		LDY		#$0F
		LDA		#$07
		STA		$E3
		STA		WSYNC
		LDA		$A3
		lsr
		lsr
		lsr
		CMP		#$14
		BCS		LF56A
		LDY		#$07
		CMP		#$0C
		BCC		LF56A
		SBC		#$04
		TAY
LF56A:	mva		logo_tab,y dlist_logo+1

;------ END DISPLAY KERNEL

		jsr		startvbl
		LDY		#$0C
		LDA		$EA
		BEQ		LF5D7
		DEC		$EA
		lsr
		STA		AUDV1
		STY		_audc1
		LDA		$BE
		CMP		#$06
		BCC		LF5CD
		LDY		#$03
LF5CD:	STY		_audf1
		LDA		#$00
		STA		$EB
		STA		$EC
		STA		$F9
LF5D7:	LDA		$F9
		BEQ		LF5F4
		LDA		#$01
		STA		$EB
		STA		$EC
		LDA		$81
		AND		#$10
		lsr
		ORA		#$04
		STA		_audc1
		LDA		#$18
		STA		_audf1
		LDA		#$08
		STA		AUDV1
		BPL		LF619
LF5F4:	LDY		#$0C
		LDA		$EB
		BEQ		LF605
		DEC		$EB
		lsr
		STA		_audf1
		AND		#$04
		STA		AUDV1
		STY		_audc1
LF605:	LDA		$EC
		BEQ		LF619
		DEC		$EC
		lsr
		STA		AUDV1
		lsr
		BCC		LF613
		LDY		#$14
LF613:	STY		_audf1
		LDA		#$08
		STA		_audc1
LF619:	LDX		#$03
LF61B:	LDA		$BD			;load current wave
		AND		#$07		;mask to 0-7
		TAY
		LDA		$D9,X		;load enemy flags
		asl					;
		AND		#$08		;check if it is a sub
		BNE		LF62A		;skip if so (use gray)
		LDA		LFF0F,Y		;load shark colors
LF62A:	EOR		$85			;attract color
		AND		$86			;attract color
		STA		$AC,X		;set enemy color
		DEX
		BPL		LF61B
		LDA		$BC
		CLC
		ADC		#$02
		CMP		#$09
		BCC		LF63E
		LDA		#$09
LF63E:	asl
		asl
		asl
		asl
		STA		$CE
		LDX		#$04
LF646:	LDA		$F0,X
		BPL		LF654
		DEX
		BNE		LF646
		LDY		#$03
LF64F:	STX		$F1,Y
		DEY
		BPL		LF64F
LF654:	LDA		$A3
		BEQ		LF672
		LDA		$BA
		AND		#$0F
		BNE		LF66C
		LDA		$81
		AND		#$7F
		BNE		LF66C
		LDA		$80
		lsr
		BCC		LF66C
		JSR		LFFDA
LF66C:	DEC		$A3
		BNE		LF672
		DEC		$A3
LF672:	LDA		$81
		AND		#$03
		BNE		LF680
		DEC		$E0
		BPL		LF680
		LDA		#$02
		STA		$E0
LF680:	LDA		$81
		AND		#$07
		BNE		LF689
		JSR		LFEDB			;update PRNG
LF689:	
		INC		$81			;increment frame counter
		BNE		LF6A7		;skip if no rollover (4.2s)
		INC		$A2			;increment attract counter
		BNE		LF6A7		;skip if no rollover (18.2 minutes)
		SEC
		ROR		$A2
LF6A7:	LDY		#$FF
		LDA		SWCHB
		AND		#$08		;test BW/Color switch
		BNE		LF6B2
		LDY		#$0F
LF6B2:	TYA
		LDY		#$00
		BIT		$A2
		BPL		LF6BD
		AND		#$F7
		LDY		$A2
LF6BD:	STY		$85
		ASL		$85
		STA		$86
		STA		WSYNC
		LDA		porta
		TAY
		LDX		$B7
		beq		LF6D5
		JSR		LFFAF
LF6D5:	AND		#$0F
		STA		$84
		INY
		BEQ		LF6E0
		LDA		#$00
		STA		$A2
LF6E0:	LDA		SWCHB
		lsr					;check GAME RESET switch
		BCS		LF6EC		;skip if not active
		JSR		LFB54
		JMP		LF00E		;restart game loop
		
LF6EC:	LDY		#$00
		lsr					;check GAME SELECT switch
		BCS		LF714		;skip if not active
		LDA		$83
		BEQ		LF6F9
		DEC		$83
		BPL		LF716
LF6F9:	INC		$80
		LDA		$80
		AND		#$01
		STA		$80
		STA		$A2
		TAY
		JSR		LFB54
		INY
		STY		$BA
		LDX		#$FF
		STX		$A3
		LDY		#$1E
		STY		$83
		BPL		LF755
LF714:	STY		$83
LF716:	LDA		$A3
		BEQ		LF71D
		JMP		LF7F6
LF71D:	LDA		$E8				;load game flags
		lsr
		lsr
		BCS		LF726			;skip if six diver victory
		JMP		LF7A6
LF726:	LDX		$B7
		LDA		$E6				;get O2 meter
		BEQ		LF758			;jump if it's emptied
		AND		#$0F
		EOR		#$FF
		STA		_audf0
		SEC
		SBC		#$05
		STA		_audf1
		LDA		#$0C
		STA		_audc0
		STA		_audc1
		lsr
		TAX
		LDA		$81
		AND		#$01
		BNE		LF755
		STA		$F9
		DEC		$E6
		BNE		LF74C
		TAX
LF74C:	STX		AUDV0
		STX		AUDV1
		LDA		$CE
		JSR		LFB9D			;award points
LF755:	JMP		LF00E			;restart game loop

		;full diver victory -- after O2 meter emptied
LF758:	LDA		$81
		AND		#$0F
		BEQ		LF768
		LSR		$ED
		LDA		$ED
		STA		AUDV0
		STA		AUDV1
		BPL		LF755

LF768:	LDA		$BE				;check if any divers left
		BNE		LF77F
		INC		$BC				;
		LDA		$BD
		CMP		$BC
		BCS		LF776
		INC		$BD
LF776:	JSR		LFC0A			;clear the water lanes
		LDA		#$01
		STA		$E8
		BNE		LF755
LF77F:	DEC		$BE
		LDA		#$1F
		STA		$ED
		STA		AUDV0
		STA		AUDV1
		LDA		#$0C
		STA		_audc0
		STA		_audc1
		STA		_audf0
		lsr
		STA		_audf1
		LDX		$BC
		CPX		#$13
		BCC		LF79C
		LDX		#$13
LF79C:	LDA		#$50
		JSR		LFB9D			;award 50 points
		DEX
		BPL		LF79C
		BMI		LF755
LF7A6:	LDY		$BC
		CPY		#$02
		BCC		LF7BB
		CPY		#$06
		BCC		LF7B2
		LDY		#$06
LF7B2:	LDA		$81			;load frame counter
		AND		LF7EF-2,Y
		BNE		LF7BB
		DEC		$F6
LF7BB:
		;respond to player/patrol collision (P0P1)
		lda		$F8			;load p0pf result
		lsr					;check for p0-p1 collision
		bcc		LF7C9		;skip if no collsion
		LDA		#$00
		STA		$F6
		STA		$E8
		LDA		#$17
		STA		$E9
LF7C9:	LDA		$E8
		lsr
		BCC		LF7F6
		JSR		LFFB4
		BCC		LF7EC
		LDA		$81
		LDX		#$03
LF7D7:	JSR		LFBCB
		LSR		$E2
		LDA		$E2
		DEX
		BPL		LF7D7
		INX
		STX		$E7
		STX		AUDV1
		LDA		$E8
		EOR		#$01
		STA		$E8
LF7EC:	JMP		LF00E		;restart game loop

;==========================================================================
LF7EF:	.byte $03,$03,$03,$01,$01,$01,$00

;==========================================================================
LF7F6:	LDY		#$00
		LDX		$B6			;check if the player hit a diver or enemy
		BMI		LF827		;skip if not
		LDA		$D9,X		;load enemy flag
		AND		#$04		;check if it's a sub
		BEQ		LF80A		;skip if it's a shark (hit diver)
		STY		$C7,X		;move shot into horizontal blank
		LDA		#$17		;load frame count
		STA		$E9			;initiate death effect - hit sub shot
		BNE		LF824		;exit
LF80A:	LDA		$BE			;load diver count
		CMP		#$06		;check if already have six divers
		BCS		LF827		;skip if so
		INC		$BE			;inc diver count
		LDA		#$17		;
		STA		$EA			;set diver sound effect
		LDA		$D9,X		;load enemy flags
		AND		#$0F		;clear diver flag
		STA		$D9,X		;save enemy flags
		STY		$C7,X		;move diver into horizontal blank
		LDA		#$FF
		STA		$F1,X
		BMI		LF827
LF824:	JMP		LF8BC

LF827:	LDX		$B4			;check if shot hit an enemy
		BMI		LF875		;skip if not
		LDA		$E7
		CMP		#$08
		BCC		LF875
		CMP		#$99
		BCS		LF875
		STY		$E7			;clear player missile
		STA		$E2			;save previous player missile position
		LDA		$CE			;load enemy point value
		JSR		LFB9D		;award points
		LDY		#$20
		LDA		$D9,X		;load enemy flags
		AND		#$0F		;clear bits 4-7 (???)
		STA		$D9,X		;save enemy flags
		AND		#$04		;check if a sub
		BNE		LF850
		LDY		#$10
		STY		$EB
		BPL		LF852
LF850:	STY		$EC
LF852:	LDA		$E2			;load player missile position
		ADC		#$08		;add rounding offset
		SEC					;
		SBC		$9E,X		;subtract enemy position
		JSR		LFFAF		;divide by 16
		TAY
		LDA		$A4,X		;load enemy pattern
		AND		LFF04,Y		;mask off enemy that was hit
LF862:	STA		$A4,X		;save enemy pattern
		BNE		LF875
		LDA		#$FF
		STA		$B0,X		;clear diver hurry up flag
		LDA		$D9,X		;load enemy flags
		AND		#$04		;check if a sub
		BNE		LF875		;skip if so
		LDA		$82
		JSR		LFBCB
LF875:	LDX		#$03
LF877:	LDA		$B0,X
		BMI		LF891
		LDA		$D9,X		;get enemy flags
		AND		#$04		;is it a sub?
		BNE		LF891		;skip if so
		LDA		$C7,X
		CMP		#$08
		BCC		LF891
		CMP		#$97
		BCS		LF891
		LDA		$D9,X
		ORA		#$10
		STA		$D9,X
LF891:	DEX
		BPL		LF877
		LDX		$B5			;check if player hit an enemy
		BMI		LF8BC		;skip if not
		LDA		#$FF		;clear enemy collision flag
		STA		$B5			;store
		LDA		$CE			;load enemy point value
		JSR		LFB9D		;award points
		LDA		#$17
		STA		$E9			;start death effect
		LDA		$C6			;get player horizontal position
		CLC
		ADC		#$10
		SEC
		SBC		$9E,X		;compare against enemy position
		BCS		LF8B1
		LDA		#$38
LF8B1:	lsr
		lsr
		lsr
		TAY
		LDA		$A4,X
		AND		LFF07,Y
		BPL		LF862
LF8BC:
		LDX		$81			;load frame counter
		TXA
		lsr					;div2
		lsr					;div4
		AND		#$0F		;mask to 0-15
		CMP		#$08		;check if <8
		BCC		LF8C9		;skip if so
		EOR		#$0F		;reflect 8-15 down to 0-7
LF8C9:	STA		$DD			;set shark vertical offset
		TXA
		AND		#$07
		BNE		LF8D8
		DEC		$DE
		BPL		LF8D8
		LDA		#$02
		STA		$DE
LF8D8:	TXA
		lsr
		AND		#$01
		STA		$E2
		LDX		#$03
LF8E0:	LDY		$D9,X
		TYA
		AND		#$04
		BEQ		LF8EF
		LDA		$D9,X
		AND		#$0C
		ORA		$E0
		BPL		LF900
LF8EF:	TYA
		CMP		#$10
		BCC		LF8FA
		AND		#$18
		ORA		$E2
		BPL		LF900
LF8FA:	LDA		$D9,X
		AND		#$08
		ORA		$DE
LF900:	STA		$D9,X
		DEX
		BPL		LF8E0
		LDA		$A3
		BNE		LF90D
		LDX		$E9
		BNE		LF910
LF90D:	JMP		LF983
LF910:	LDA		#$00
		STA		$E7
		STA		$F9
		LDA		$81
		AND		#$03
		BNE		LF980
		STA		$F6
		STA		AUDV1
		DEC		$E9
		BEQ		LF94E
		LDA		$E9
		CMP		#$0F
		BCC		LF93E
		LDX		#$03
		AND		#$01
		BNE		LF932
		LDX		#$10
LF932:	STX		_audf0
		LDA		#$06
		STA		AUDV0
		LDA		#$0F
		STA		_audc0
		BPL		LF94C
LF93E:	STA		AUDV0
		LDA		#$08
		STA		_audc0
		LDA		#$10
		STA		_audf0
		LDA		#$00
		STA		$E6
LF94C:	BPL		LF980
LF94E:	STA		AUDV0
		STA		_audc0
		STA		$D6
		JSR		LFC0A
		JSR		LFB7B
		LDX		$BE
		BEQ		LF960
		DEC		$BE
LF960:	LDX		#$03
LF962:	LDA		$D9,X
		AND		#$0F
		STA		$D9,X
		DEX
		BPL		LF962
		LDA		$E8
		ORA		#$01
		STA		$E8
		LDA		$BB
		ORA		$C2
		BNE		LF97D
		INC		$A3
		STA		$E1
		BPL		LF980
LF97D:	JSR		LFCCD		;go to next player
LF980:	JMP		LFB4F

;==========================================================================
LF983:	LDA		$BD
		CLC
		ADC		#$10
		STA		$E4
		SEC
		SBC		#$0A
		STA		$E3
		lsr
		STA		$E2
		LDX		#$02
LF994:	LDA		$E2,X
		JSR		LFB84
		DEX
		BPL		LF994
		
		LDX		#$03
LF99E:	LDA		$D9,X		;load enemy flags
		JSR		LFFAF		;test reflect bit (bit 3)
		STA		$E2
		LDA		$9E,X
		BCS		LF9B4		;jump if shark going left
		ADC		$93			;add speed
		STA		$9E,X
		AND		#$F8
		CMP		#$A0
		JMP		LF9BC
LF9B4:	SBC		$93			;subtract speed
		STA		$9E,X
		AND		#$F8
		CMP		#$D8
LF9BC:	BNE		LF9D5
		LDA		$D9,X		;load enemy flags
		AND		#$04		;isolate shark/sub flag
		EOR		#$04		;alternate between shark and sub
		STA		$E2
		LDA		$82			;get random number
		AND		#$08		;set random direction
		ORA		$E2
		STA		$D9,X
		LDA		$82
		STA		$E2
		JSR		LFBEB
LF9D5:	LDA		$D9,X
		lsr
		lsr
		lsr
		BCS		LFA19
		lsr
		LDY		$F1,X
		DEY
		BPL		LF9E5
		JMP		LFA5C
LF9E5:	BCS		LF9F5
		LSR		$E2
		LDA		$93
		BCS		LF9EF
		LDA		$92
LF9EF:	CLC
		ADC		$C7,X
		JMP		LFA0E
LF9F5:	LSR		$E2
		LDA		$93
		BCS		LF9FD
		LDA		$92
LF9FD:	STA		$E3
		BEQ		LFA5C
		LDA		$C7,X
		BNE		LFA07
		LDA		#$A0
LFA07:	SEC
		SBC		$E3
		BNE		LFA0E
		LDA		#$A0
LFA0E:	CMP		#$A0
		BCC		LFA5A
		LDA		#$00
		STA		$F1,X
		JMP		LFA5A
LFA19:	LDA		$C7,X
		STA		$E2
		BNE		LFA39
		LDY		$A4,X
		BEQ		LFA4D
		LDA		$D9,X
		AND		#$08
		ORA		$A4,X
		TAY
		LDA		$9E,X
		CLC
		ADC		LFC18,Y
		STA		$E2
		SEC
		SBC		#$27
		CMP		#$58
		BCS		LFA58
LFA39:	LDA		$D9,X
		JSR		LFFAF
		LDA		$E2
		BCS		LFA47
		ADC		$94
		JMP		LFA49
LFA47:	SBC		$94
LFA49:	CMP		#$A0
		BCC		LFA5A
LFA4D:	LDA		$A4,X
		BNE		LFA58
		LDA		$82
		ORA		#$80
		JSR		LFBCB
LFA58:	LDA		#$00
LFA5A:	STA		$C7,X
LFA5C:	DEX
		BMI		LFA62
		JMP		LF99E
LFA62:	LDA		$A3
		BNE		LFA7A
		LDA		$E1
		CMP		#$0D
		BNE		LFA94
		LDA		$E6
		CMP		#$40
		BEQ		LFA94
		LDA		$BE
		BNE		LFA7D
		LDA		#$17
		STA		$E9
LFA7A:	JMP		LFB4F
LFA7D:	CMP		#$06
		BNE		LFA85
		STA		$E8
		BPL		LFA7A
LFA85:	JSR		LFFB4
		BCC		LFA7A
		DEC		$BE
		INC		$BD
		LDA		#$00
		STA		AUDV0
		STA		AUDV1
LFA94:	LDA		$84				;load input
		AND		#$01			;up
		BNE		LFAA2
		LDX		$E1
		CPX		#$0E
		BCC		LFAA2
		DEC		$E1
LFAA2:	LDA		$84
		AND		#$02			;down
		BNE		LFAB0
		LDX		$E1
		CPX		#$6C
		BCS		LFAB0
		INC		$E1
LFAB0:	LDA		$84
		AND		#$04			;left
		BNE		LFAC2
		LDA		#$08
		STA		$D6
		LDA		$C6
		CMP		#$16
		BCC		LFAC2
		DEC		$C6
LFAC2:	LDA		$84
		AND		#$08			;right
		BNE		LFAD2
		STA		$D6
		LDA		$C6
		CMP		#$86
		BCS		LFAD2
		INC		$C6
LFAD2:	LDA		$E7
		BNE		LFAF6
		STA		AUDV0
		LDA		$D6
		STA		$D7
		LDY		$B7
		LDA		trig0,Y
		bne		LFB37
		LDA		$E1
		CMP		#$12
		BCC		LFB37
		LDA		#$10
		STA		$ED
		LDA		#$0F
		STA		_audc0
		LDA		$C6
		CLC
		ADC		#$08
LFAF6:	TAY
		LDA		$ED
		STA		_audf0
		LDX		$E6
		CPX		#$11
		BCS		LFB03
		LDA		#$00
LFB03:	lsr
		STA		AUDV0
		LDA		$81
		AND		#$03
		BNE		LFB0E
		DEC		$ED
LFB0E:	LDA		SWCHB
		STA		$E2
		LDA		$D7				;get player reflect bit
		lsr
		lsr
		lsr
		TAX
		TYA
		ADC		LFFAD,X
		ASL		$E2				;test P1 difficulty
		LDY		$B7				;check if player 2
		BNE		LFB25			;skip if so
		ASL		$E2				;test P0 difficulty
LFB25:	BCC		LFB2B			;skip if easy mode
		CLC						;
		ADC		LFB52,X			;
LFB2B:	STA		$E7
		CMP		#$A0
		BCC		LFB35
		LDA		#$00
		STA		AUDV0
LFB35:	STA		$E7
LFB37:	LDY		$E6
		LDA		$E1
		CMP		#$14
		BCC		LFB4D
		LDA		$81
		AND		#$1F
		BNE		LFB4D
		DEY
		BNE		LFB4D
		TAY
		LDA		#$17
		STA		$E9
LFB4D:	STY		$E6
LFB4F:	JMP		LF00E

;==========================================================================
; missile horizontal offset table
;
LFB52:	dta		$FE		;unreflected
		dta		$02		;reflected

;==========================================================================
LFB54:	LDX		#$A2
LFB56:	LDA		#$00
LFB58:	STA		$00,X
		INX
		CPX		#$FB
		BNE		LFB58
		LDX		#$03
LFB61:	LDA		#$B8
		STA		$AB,X
		DEX
		BNE		LFB61
		STX		AUDV0
		STX		AUDV1
		INX
		STX		$E8
		LDX		#$03		;three lives
		STX		$BB			;set life count
		INX
		LDA		$80
		lsr
		BCC		LFB7B
		STX		$C2
LFB7B:	LDA		#$0D
		STA		$E1
		LDA		#$4C
		STA		$C6
		RTS

LFB84:	STA		$FA
		JSR		LFFAF		;shr4
		STA		$92,X
		LDA		$FA
		AND		#$0F
		CLC
		ADC		$CF,X
		CMP		#$10
		BCC		LFB98
		INC		$92,X
LFB98:	AND		#$0F
		STA		$CF,X
		RTS

;==========================================================================
; award points
;
;  A = points to award (BCD)
;
LFB9D:	SED
		CLC
		ADC		$BA
		STA		$BA
		BCC		LFBC9
		LDA		$B9
		ADC		#$00
		STA		$B9
		LDA		$B8
		ADC		#$00
		BCC		LFBB9
		LDA		#$99
		STA		$B9
		STA		$BA
		INC		$A3
LFBB9:	STA		$B8
		LDA		$B9
		AND		#$FF
		BNE		LFBC9
		LDA		$BB				;get number of lives
		CMP		#$06			;check if there are already six
		BCS		LFBC9			;skip if so
		INC		$BB				;award extra life
LFBC9:	CLD
		RTS

;==========================================================================
LFBCB:	STA		$E2
		LDA		$BD
		AND		#$07
		TAY
		LDA		$E2
		AND		#$08
		STA		$D9,X
		BNE		LFBE3
		LDA		LFEFC,Y
		AND		#$0F
		STA		$A4,X
		BNE		LFBEB
LFBE3:	LDA		LFEFC,Y
		JSR		LFFAF			;shr4
		STA		$A4,X
LFBEB:	LDY		#$A8
		LDA		$D9,X			;load enemy flags
		AND		#$0F			;clear diver
		STA		$D9,X
		AND		#$08
		BEQ		LFBF9
		LDY		#$D7
LFBF9:	STY		$9E,X
		LDA		$E2
		LDY		$F1,X
		BMI		LFC09
		CMP		#$50
		BCC		LFC09
		LDY		#$01
		STY		$F1,X
LFC09:	RTS

;==========================================================================
; clear water lanes
;
LFC0A:	LDX		#$03
LFC0C:	LDA		#$D0
		STA		$9E,X			;reset enemy position
		LDA		#$00
		STA		$C7,X			;reset diver/shot positions
		DEX
		BPL		LFC0C
		RTS

;==========================================================================
; next player routine
;
LFCCD:	JSR		LFFDA			;swap players
		LDA		$BB				;check if any extra lives left
		BNE		LFCD7			;skip if so
		JSR		LFFDA			;whoops... swap players back!
LFCD7:	DEC		$BB				;decrement extra lives
		RTS

;==========================================================================
; random number generator
;
LFEDB:	LDY		#$02
LFEDD:	LDA		$82
		asl
		asl
		asl
		EOR		$82
		asl
		ROL		$82
		DEY
		BPL		LFEDD
		RTS

;==========================================================================
LFFAF:	lsr
LFFB0:	lsr
LFFB1:	lsr
		lsr
LFFB3:	RTS

;==========================================================================
LFFB4:	LDA		$81
		AND		#$01
		BNE		LFFBE
		STA		$F9
		INC		$E6
LFFBE:	LDA		$E6
		lsr
		EOR		#$FF
		STA		_audf0
		CLC
		ADC		#$07
		STA		_audf1
		LDA		#$08
		STA		_audc0
		STA		_audc1
		lsr
		STA		AUDV0
		STA		AUDV1
		LDA		$E6
		CMP		#$40
		RTS

;==========================================================================
; player swap routine
;
LFFDA:	LDX		#$06
LFFDC:	LDA		$B8,X		;load current score
		LDY		$BF,X		;load other score
		STA		$BF,X
		STY		$B8,X
		DEX
		BPL		LFFDC
		LDA		$B7			;load player flag
		EOR		#$01		;flip player
		STA		$B7
		RTS

;==========================================================================

ball_frames:
		dta		<diver0
		dta		<diver1
		dta		<diver2
		dta		<diver2
		dta		<shot0
		dta		<shot0
		dta		<shot0
		dta		<shot0
		dta		<diver3
		dta		<diver4
		dta		<diver5
		dta		<diver5
		dta		<shot1
		dta		<shot1
		dta		<shot1
		dta		<shot1

;==========================================================================
logo_tab:
		:16 dta [15-#]*16
		
;==========================================================================
playfield_seabed:
		:5 dta	$8E,$8F,$90,$91
		
;==========================================================================
lane_ypos_table:
		dta		161,137,112,89

;==========================================================================
		.pages 1
diver0:	dta		%00000000
		dta		%10000000
		dta		%01000000
		dta		%00100000
		dta		%11110000
		dta		%00011000
		dta		%00001111
		dta		%00001100
		dta		%00000010
		dta		%00000010
		dta		%00001000
		dta		%00000000
		dta		%00010000
		dta		%00100000
		dta		%00000000
			
diver1:	dta		%00000000
		dta		%00000000
		dta		%10000000
		dta		%01100000
		dta		%00110000
		dta		%00011000
		dta		%00001111
		dta		%00001100
		dta		%00000010
		dta		%00000010
		dta		%00000000
		dta		%00010000
		dta		%00100000
		dta		%00000000
		dta		%00000000

diver2:	dta		%00000000
		dta		%10000000
		dta		%01000000
		dta		%00100000
		dta		%11110000
		dta		%00011000
		dta		%00001111
		dta		%00001100
		dta		%00000010
		dta		%00000010
		dta		%00001000
		dta		%00001000
		dta		%00000000
		dta		%00100000
		dta		%00100000
		
diver3:	dta		%00000000
		dta		%00000001
		dta		%00000010
		dta		%00000100
		dta		%00001111
		dta		%00011000
		dta		%11110000
		dta		%00110000
		dta		%01000000
		dta		%01000000
		dta		%00010000
		dta		%00000000
		dta		%00001000
		dta		%00000100
		dta		%00000000

diver4:	dta		%00000000
		dta		%00000000
		dta		%00000001
		dta		%00000110
		dta		%00001100
		dta		%00011000
		dta		%11110000
		dta		%00110000
		dta		%01000000
		dta		%01000000
		dta		%00000000
		dta		%00001000
		dta		%00000100
		dta		%00000000
		dta		%00000100

diver5:	dta		%00000000
		dta		%00000001
		dta		%00000010
		dta		%00000100
		dta		%00001111
		dta		%00011000
		dta		%11110000
		dta		%00110000
		dta		%01000000
		dta		%01000000
		dta		%00010000
		dta		%00010000
		dta		%00000000
		dta		%00000100
		dta		%00000100
		dta		%00000000

shot0:	dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%11110000
		dta		%00000000
		dta		%00000000
		dta		%00001111
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		
shot1:	dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00001111
		dta		%00000000
		dta		%00000000
		dta		%11110000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
			
		.endpg

;==========================================================================
.if *>$2e00
.error "Segment too large"
.endif

		org		$2e00
charset:
		dta		$00,$00,$00,$00,$00,$00,$00,$00		;blank
		dta		$04,$0C,$0C,$BE,$FE,$FE,$FC,$80		;extra life
		dta		$3C,$66,$66,$66,$66,$66,$66,$3C		;0
		dta		$18,$38,$18,$18,$18,$18,$18,$3C		;1
		dta		$3C,$46,$06,$06,$3C,$60,$60,$7E		;2
		dta		$3C,$46,$06,$0C,$0C,$06,$46,$3C		;3
		dta		$0C,$1C,$2C,$4C,$7E,$0C,$0C,$0C		;4
		dta		$7E,$60,$60,$7C,$06,$06,$46,$7C		;5
		dta		$3C,$62,$60,$7C,$66,$66,$66,$3C		;6
		dta		$7E,$42,$06,$0C,$18,$18,$18,$18		;7
		dta		$3C,$66,$66,$3C,$3C,$66,$66,$3C		;8
		dta		$3C,$66,$66,$66,$3E,$06,$46,$3C		;9
		dta		$02,$02,$0C,$0F,$18,$F0,$20,$40		;diver top
		dta		$80,$00,$00,$00,$00,$00,$00,$00		;diver bottom
		dta		$00,$0F,$FF,$FF,$FF,$FF,$FF,$FF		;sea bed 0
		dta		$00,$F0,$FF,$FF,$FF,$FF,$FF,$FF		;sea bed 1
		dta		$00,$00,$00,$F0,$FF,$FF,$FF,$FF		;sea bed 2
		dta		$00,$00,$00,$0F,$FF,$FF,$FF,$FF		;sea bed 3
dlist:
		dta		$70			;8
		dta		$70			;16
		dta		$70			;24
		dta		$10			;32
		dta		$46,a(score_playfield)		;34
		dta		$40							;42
		dta		$46,a(playfield_lives)		;47
		dta		$30							;55
		dta		$70							;59
		dta		$70							;67
		dta		$70							;75
		dta		$50							;83
		:15 dta	$5C,a(quick_fb+4)			;89
		dta		$20							;104
		dta		$40							;107
		:15 dta	$5C,a(quick_fb+4)			;112		
		dta		$30							;127
		dta		$50							;131
		:15 dta	$5C,a(quick_fb+4)			;137
		dta		$20							;152
		dta		$50							;155
		:15 dta	$5C,a(quick_fb+4)			;161		
		dta		$20							;176
		dta		$60							;179
		dta		$46,a(playfield_seabed)		;186
		dta		$00							;194
		:5 dta	$4E,a(playfield_o2meter)	;195-199
		dta		$20							;200
		dta		$66,a(playfield_divers)		;203
		dta		$06							;211
		dta		$20							;212
dlist_logo:
		dta		$4C,a(playfield_logo)		;215
		:7 dta $0C
		dta		$41,a(dlist)				;223

;==========================================================================

		org		$3000

;==========================================================================
; player sub explosion graphics
;
sub_graphics:
		;explosion, sub, and shark graphics must be on the same page.
		.pages 1

LFD82:	dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00010000
		dta		%00101000
		dta		%00010000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
LFD8D:	dta		%00000000
		dta		%00000000
		dta		%01000100
		dta		%00010000
		dta		%00000000
		dta		%00101000
		dta		%00000000
		dta		%00010000
		dta		%01000100
		dta		%00000000
		dta		%00000000
		dta		%00000000
LFD99:	dta		%00000000
		dta		%10000010
		dta		%00010000
		dta		%00000000
		dta		%00000000
		dta		%01010100
		dta		%00000000
		dta		%00000000
		dta		%00010000
		dta		%10000010
		dta		%00000000

;sub frames
LFDA4:	dta		%00000000
		dta		%00000000
		dta		%11111110
		dta		%11111111
		dta		%01111101
		dta		%11111111
		dta		%10111111
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00000100
		dta		%00000000
		dta		%00000000
LFDB2:	dta		%00000000
		dta		%10000000
		dta		%11111110
		dta		%11111111
		dta		%11111101
		dta		%01111111
		dta		%10111111
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00000100
		dta		%00000000
		dta		%00000000
LFDC0:	dta		%00000000
		dta		%10000000
		dta		%11111110
		dta		%01111111
		dta		%11111101
		dta		%11111111
		dta		%00111111
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00001100
		dta		%00000100
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00100010
		dta		%00000000
		dta		%00000000
		dta		%00100010
		dta		%00000000
		
;shark frames
LFDD4:	dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00010000
		dta		%11011011
		dta		%01111111
		dta		%01111111
		dta		%11011111
		dta		%00001100
		dta		%00001000
LFDE3:	dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%10010001
		dta		%11011011
		dta		%01111110
		dta		%01111111
		dta		%11011111
		dta		%10001100
		dta		%00001000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000

;==========================================================================
; sub/shark graphics (reflected)
;
;sub frames
sub0r:	dta		%00000000
		dta		%00000000
		dta		%01111111
		dta		%11111111
		dta		%10111110
		dta		%11111111
		dta		%11111101
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00100000
		dta		%00000000
		dta		%00000000
sub1r:	dta		%00000000
		dta		%00000001
		dta		%01111111
		dta		%11111111
		dta		%10111111
		dta		%11111110
		dta		%11111101
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00100000
		dta		%00000000
		dta		%00000000
sub2r:	dta		%00000000
		dta		%00000001
		dta		%01111111
		dta		%11111110
		dta		%10111111
		dta		%11111111
		dta		%11111100
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00110000
		dta		%00100000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%01000100
		dta		%00000000
		dta		%00000000
		dta		%01000100
		dta		%00000000
		
;shark frames
shark0r:
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00001000
		dta		%11011011
		dta		%11111110
		dta		%11111110
		dta		%11111011
		dta		%00110000
		dta		%00010000
shark1r:
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%10001001
		dta		%11011011
		dta		%01111110
		dta		%11111110
		dta		%11111011
		dta		%00110001
		dta		%00010000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		dta		%00000000
		.endpg

;==========================================================================

LFC18:	.byte $00,$20,$10,$20,$00,$20,$10,$20,$00,$20,$10,$10,$00,$00,$00,$00

;==========================================================================
; horizon color table
;
LFCE6:	.byte $14,$24,$34,$34,$44,$44,$54,$54,$64,$64

;==========================================================================
; color table
;
LFCF0:	dta		$1A		;player 1
		dta		$AF		;player 2
		dta		$90		;water color #1
		dta		$18		;player 1 underwater
		dta		$AA		;player 2 underwater
		dta		$84		;header
		dta		$00		;water color #2
		dta		$0C		;oxygen bar color
		dta		$06		;sea bed color
		dta		$32		;used up O2 bar color
		dta		$86		;logo and diver color

;==========================================================================
; player sub frame lookup table
LFCFB:	dta		<LFDA4
		dta		<LFDB2
		dta		<LFDC0
		dta		0
		dta		<sub0r
		dta		<sub1r
		dta		<sub2r
		dta		0

;==========================================================================
; explosion graphics table
;
LFDFA:	dta		<LFD99
		dta		<LFD8D
		dta		<LFD8D
		dta		<LFD82
		dta		<LFD82

;==========================================================================
sub_table:
		dta		$00,$00,$00,$00
		dta		$01,$01,$01,$01
		dta		$00,$00,$00,$00
		dta		$01,$01,$01,$01

;==========================================================================
; Activision logo
;
LFE5B:	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$F7,$95,$87,$80,$90,$F0
LFE6B:	.byte $AD,$A9,$E9,$A9,$ED,$41,$0F,$00,$47,$41,$77,$55,$75,$00,$00,$00
LFE7B:	.byte $50,$58,$5C,$56,$53,$11,$F0,$00,$03,$00,$4B,$4A,$6B,$00,$08,$00
LFE8B:	.byte $BA,$8A,$BA,$A2,$3A,$80,$FE,$00,$80,$80,$AA,$AA,$BA,$22,$27,$02
LFE9B:	.byte $E9,$AB,$AF,$AD,$E9,$00,$00,$00,$00,$00,$11,$11,$17,$15,$17,$00
LFEAB:	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$77,$51,$73,$51,$77,$00

;==========================================================================
; enemy wave repeat table offsets (formerly NUSIZ1 table at $F3F4)
;
enemy_repeat_2:
		dta		quick_fb+0		;---
		dta		quick_fb+0		;--* 1x (with offset)
		dta		quick_fb+0		;-*- 1x (with offset)
		dta		quick_fb+2		;-** 2x close
		dta		quick_fb+0		;*-- 1x (with offset)
		dta		quick_fb+0		;*-* 2x med
		dta		quick_fb+2		;**- 2x close (with offset)
		dta		quick_fb+2		;*** 3x close

enemy_repeat_3:
		dta		quick_fb+0		;--- 1x
		dta		quick_fb+0		;--* 1x (with offset)
		dta		quick_fb+0		;-*- 1x (with offset)
		dta		quick_fb+0		;**- 2x close
		dta		quick_fb+0		;*-- 1x (with offset)
		dta		quick_fb+4		;*-* 2x med
		dta		quick_fb+0		;**- 2x close (with offset)
		dta		quick_fb+4		;*** 3x close
		
;==========================================================================
; repeated enemy masking table
;
LFEEB:	dta		$06		;$8x
		dta		$04		;$9x
		dta		$00		;$Ax
		dta		$00		;$Bx
		dta		$00		;$Cx
		dta		$00		;$Dx
		dta		$01		;$Ex
		dta		$03		;$Fx
		dta		$07		;$00-7F

;==========================================================================
LFEFC:	.byte $41,$41,$63,$63,$55,$55,$77,$77


;==========================================================================
; enemy kill table
;
; This determines which enemy bit to mask off in the pattern mask by the
; relative offset between the missile and the leftmost enemy.
;
LFF04:	dta		$03		;x**
		dta		$05		;*x*
		dta		$06		;**x

;==========================================================================
LFF07:	.byte $03,$03,$01,$05,$04,$06,$06,$04

;==========================================================================
; shark colors (based on wave)
;
LFF0F:	.byte $C8,$E8,$58,$36,$C6,$E8,$C8,$36

;==========================================================================
; explosion color table
;
LFF17:	.byte $90,$90,$90,$90,$90,$90,$92,$94,$96,$98,$9A,$9C,$9C,$9C,$9C,$0E
		.byte $00,$0E,$00,$0E,$00,$0E,$00,$0E
		
;==========================================================================
; enemy player pattern offset table
;
; This is used to offset the left hand side of the sprite.
;
LFF51:	dta		$00		;---
		dta		$20		;--*
		dta		$10		;-*-
		dta		$10		;-**
		dta		$00		;*--
		;		$00		;*-*	(borrowed from next table)
		;		$00		;**-	(borrowed from next table)
		;		$00		;***	(borrowed from next table)

;==========================================================================
; extra lives indicator -- sprite repeat values
;
;	bits 0-3: player 0 repeat
;	bits 4-7: player 1 repeat
;
LFF56:	.byte $00,$00,$00,$10,$11,$31,$33

;==========================================================================
; extra lives graphics (9 scanlines; inverted)
;
LFF5D:	.byte $00,$80,$FC,$FE,$FE,$BE,$0C,$0C,$04

;==========================================================================
; 'Oxygen' graphics
;
LFF66:	dta		%11101010
		dta		%10101110
		dta		%10100100
		dta		%10101110
		dta		%11101010
LFF6B:	dta		%01001110
		dta		%01001010
		dta		%01001010
		dta		%11101000
		dta		%10101110
LFF70:	dta		%11010010
		dta		%10010110
		dta		%11011110
		dta		%10011010
		dta		%11010010

;shark/sub sprite table
LFFA2:	dta		<LFDD4
		dta		<LFDE3
		dta		<LFDE3
		dta		$00		;not used
		dta		<LFDA4
		dta		<LFDB2
		dta		<LFDC0
		dta		$B8		;not used

		;reflected versions
		dta		<shark0r
		dta		<shark1r
		dta		<shark1r
		dta		$00		;not used
		dta		<sub0r
		dta		<sub1r
		dta		<sub2r
		dta		$B8		;not used

;missile offset table
LFFAD:	.byte $05,$FB

;==========================================================================
		org		$3800
		opt		o-
playfield:
score_playfield:
		:16 dta 0
playfield_lives:
		:16 dta 0
playfield_divers:
		:16 dta 0
		:16 dta 0
playfield_o2meter:
		:16 dta 0
		
		org		$3900
playfield_logo:
		:256 dta 0

		opt		o+

		run		_main

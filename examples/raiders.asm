; 2600 Raiders of the Lost Ark - 800 port
; by phaeron, Jan 1 2017
; http://atariage.com/forums/topic/260558-raiders-of-the-lost-ark/
;
; $81		Current room ($00-0D)
;	$00 - treasure room
;	$01 - marketplace
;	$02 - entrance room
;	$03 - black market
;	$04 - map room?
;	$05 - falling room
;	$06 - temple entrance
;	$07 - spider room
;	$08 - guardian room
;	$09 - mesa field
;	$0A - valley of death
;	$0B - thief room
;	$0C - inside the mesa
;	$0D - well of souls
; $82		Timer low (every vblank)
; $83		Timer high (every 64 vblanks)
; $84-89	Bank switch code (LDA $FFF8/FFF9, JMP target)
; $8A		In-bog flag
; $8B		Current mesa
; $8C		Correct mesa
; $8D		Bitfield
;	D6=1: Grappling hook active (ankh or hourglass)
; $8F
; $91		Marketplace flags
;	D6,D7:	Number of coin bags dropped; cleared when touching player 0
;	D4:D0:	Item to drop
;			$01: bullets
;			$02: flute
;			$03: parachute
;			$0B: shovel
; $93		Flags
;	D7=1: Tsetse flies enabled
;	D6=1: Snake enabled
; $94		Room CTRLPF/NUSIZ0 value
; $95
; $97		Dug flag; set to $FF when off dirt, incremented when using shovel on it
; $9A		Bitfield
;	D7=1: Grenade active
;	D0=1: Hole will be blasted when grenade goes off
; $9B		Grenade timer (compared against $83)	
; $9F		Extra life count (initially 2, which means three lives)
; $A0		Bullets left (initially 6)
; $A1		Indy stun time (from tsetse flies)
; $A5		Scoring bonus: -2 for blasting hole with grenade
; $A6		Scoring bonus: -13 for using secret exit in guardian room
; $A7		Scoring bonus: +10 for digging with shovel
; $A8		Scoring bonus: +3 for using parachute
; $A9		Scoring bonus: +9 for using Ankh outside of treasure room
; $AA		Scoring bonus: +5 for dropping chai to see yar
; $AB		Scoring bonus: +14 for lighting up correct mesa in map room
; $AC		Scoring bonus: -4 for shooting thief
; $AD		Scoring bonus: +3 for entering mesa
; $AE		Scoring bonus: (unused)
; $B1		Bitfield
;	D1=1: Hole blasted in entrance room
; $B2		Bitfield
;	D7=1: Raving lunatic paid off
; $B4		Bitfield
;	D7=1: Parachute is open
;	D6=1: Parachute torn
;	D1=1: Yar visible in falling room
; $B5		Temple door position (increments as it drops)
; $B6		Spider flag?
; $B7,B8	Inventory item 1 graphic pointer
; $B9,BA	Inventory item 2 graphic pointer
; $BB,BC	Inventory item 3 graphic pointer
; $BD,BE	Inventory item 4 graphic pointer
; $BF,C0	Inventory item 5 graphic pointer
; $C1,C2	Inventory item 6 graphic pointer
;	$**00 - blank
;	$**10 - flute
;	$**18 - parachute
;	$**20 - bag of coins
;	$**28 - grenade 1
;	$**30 - grenade 2
;	$**38 - key
;	$**50 - whip
;	$**58 - shovel
;	$**68 - revolver
;	$**70 - staff head
;	$**78 - timepiece
;	$**80 - ankh
;	$**88 - chai
;	$**90 - hourglass
;	$**98,A0,A8,B8,B8,C0,C8,D0 - timepiece showing time
;
; $C3		Inventory cursor
; $C4		Inventory item count
; $C5		Current inventory item (graphic low byte /8)
; $C6		Item tracking bitfield 1
;	D0=1: Grenade 1 collected
; $C7		Item tracking bitfield 2
;	D0=1: Whip collected
; $C9		Indy horizontal position
; $CB
; $CF		Indy vertical position
; $D0
; $D1
; $D2		
; $D4
; $D6,D7	Ball HMBL data stream
; $D9,DA	Player 1 data pointer (Indy)
; $DB		Indy render height
; $DD		Display kernel display list
; $DF		Playfield vertical scroll position in block lines (scrolling levels)
;			Item collected flag (treasure room)
; $E5-		Guardian graphics (kernel 1 + room 7) or thief positions (kernel 2)

STARTING_ROOM = $02
MAP_TEST = 0
ITEM_CHEAT = 0

HPOS_PLAYER_OFFSET = $30
HPOS_MISSILE_OFFSET = HPOS_PLAYER_OFFSET-1


hposp0	equ		$d000
m0pf	equ		$d000
hposp1	equ		$d001
m1pf	equ		$d001
hposp2	equ		$d002
hposp3	equ		$d003
hposm0	equ		$d004
p0pf	equ		$d004
hposm1	equ		$d005
p1pf	equ		$d005
hposm2	equ		$d006
hposm3	equ		$d007
p3pf	equ		$d007
sizep0	equ		$d008
m0pl	equ		$d008
sizep1	equ		$d009
m1pl	equ		$d009
sizep2	equ		$d00a
m2pl	equ		$d00a
sizep3	equ		$d00b
sizem	equ		$d00c
p0pl	equ		$d00c
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
vdelay	equ		$d01c
gractl	equ		$d01d
hitclr	equ		$d01e
consol	equ		$d01f
audf1	equ		$d200
pot0	equ		$d200
audc1	equ		$d201
pot1	equ		$d201
audf2	equ		$d202
audc2	equ		$d203
audf3	equ		$d204
audc3	equ		$d205
audf4	equ		$d206
audc4	equ		$d207
audctl	equ		$d208
stimer	equ		$d209
kbcode	equ		$d209
potgo	equ		$d20b
irqen	equ		$d20e
skctl	equ		$d20f
skstat	equ		$d20f
porta	equ		$d300
portb	equ		$d301
pactl	equ		$d302
pbctl	equ		$d303
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

vdslst	equ		$0200
vvblki	equ		$0222
coldst	equ		$0244
pcolr0	equ		$02C0
pcolr1	equ		$02C1
color0	equ		$02C4
color4	equ		$02C8
pupbt1	equ		$033D

COLUP0  =	colpm0
COLUP1  =	colpm1
COLUPF  =	colpf0
COLUBK	=	colbk
SWCHA   =  $08
SWCHB   =  $09
REFP0   =  $0B
_AUDC0   =  $15
_AUDC1   =  $16
_AUDF0   =  $17
_AUDF1   =  $18
AUDV0   =  $19
AUDV1   =  $1A
GRP0    =  grafp0
GRP1    =  grafp1
CXCLR   =  hitclr
CXM1FB  =  $35
INPT4   =  $3C
INPT5   =  $3D

use_c_button	= $63
c_button		= $64
reflect_p0		= $65
pending_dmactl	= $66
pending_gractl	= $67
dynpf_start		= $69
dynpf_stop		= $6A
p0_pos			= $6B
p0_len			= $6C
m0_mask			= $6D
m1_mask			= $6E
mb_mask			= $6F
m0_pos			= $70
m1_pos			= $71
mb_pos			= $72
m0_len			= $73
m1_len			= $74
mb_len			= $75
missile_pat		= $76
hposp0_offset	= $78
hposp1_offset	= $79
hposm0_offset	= $7A
hposm1_offset	= $7B
hposbl_offset	= $7C

scroll_temp		= $7E
teardown_disp	= $7F

;==========================================================================
bss_start = $1000

playfield_cursor = $10D8
playfield_status = $10EC

missile_dat = $1580
player0_dat = $1600
player1_dat = $1680
player2_dat = $1700
player3_dat = $1780

missilehi_dat	= $1300
player0hi_dat	= $1400
player1hi_dat	= $1500

p0pos_even_dat	= $1A00
p0pos_odd_dat	= $1A80
m2pos_even_dat	= $1B00
m2pos_odd_dat	= $1B80		;careful -- this sometimes gets overrun by a full page.

bss_end = $2000

;==========================================================================
		org		$2000

		.pages 1
revbits_tab:
		:256 dta [#&$80]/128+[#&$40]/32+[#&$20]/8+[#&$10]/2+[#&$08]*2+[#&$04]*8+[#&$02]*32+[#&$01]*128
		.endpg

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

audio_lotab93:
		:32 dta <((#+1)*57*93/2-7)
		:32 dta >((#+1)*57*93/2-7)
		.endpg

;==========================================================================
; Screen display lists
;
; In the original game, the main screen is 189 scanlines tall, with the
; playfield 167 scans tall. Screens that have playfield data use four-line
; scans until the bottom, where only three are displayed; screens without
; have three-scan top and bottom borders.
;
; !!CAUTION!! We have a close transition from a display kernels to DLI
; handlers here. The display kernel extends until the end of the main
; playfield including the bottom border, and resets the background color
; to black. The first DLI re-enables the playfield and changes the
; background color to red. It would be preferable if we could cut off
; the playfield with the DLI handler, but we can't do it without
; interfering with last line of the display kernel.
;

;display list 1 (used for kernel 1, which has a data-driven playfield)
dlist1:
		dta		$70,$70,$70
		dta		$49,a(pfdata_room06)
dlist1_pfaddr1 = *-2
		dta		$49,a(pfdata_room06)
dlist1_pfaddr2 = *-2
		:38 dta $09
		dta		$09
		dta		$49,a(pfdata_room06)
dlist1_pfaddr3 = *-2
		dta		$80
		dta		$40
		dta		$46,a(playfield_status)
		dta		$10
		dta		$4B,a(playfield_cursor)
		dta		$A0
		dta		$41,a(dlist1)

;display list 2 (used for kernels 0, 2, and 3, which just have borders)
dlist2:
		dta		$70,$70,$70

		;top border (3 scans)
		dta		$69,a(pfdata_room06)
dlist2_pfaddr1 = *-2

		;middle section 1 (2 scans)
		dta		$09

		;middle section 2 (5 scans)
		dta		$69,a(pfdata_room06)
dlist2_pfaddr2 = *-2
		dta		$09

		;middle section 3 (5 scans)
		dta		$69,a(pfdata_room06)
dlist2_pfaddr3 = *-2
		dta		$09

		;middle section 4 (149 scans)
		dta		$69,a(pfdata_room06)
dlist2_pfaddr4 = *-2
		:36 dta $29
		dta		$09

		;bottom border (3 scans)
		dta		$29
		dta		$90
		dta		$40
		dta		$46,a(playfield_status)
		dta		$10
		dta		$4B,a(playfield_cursor)
		dta		$A0
		dta		$41,a(dlist2)

.macro PFEXPAND
		;PF0 4..7
		dta		[((:1&$10)*4)+((:1&$20)/2)+((:1&$40)/16)+((:1&$80)/128)]*3

		;PF1 7..0
		dta		[((:2&$80)/2)+((:2&$40)/4)+((:2&$20)/8)+((:2&$10)/16)]*3
		dta		[((:2&$08)*8)+((:2&$04)*4)+((:2&$02)*2)+((:2&$01)* 1)]*3

		;PF2 0..7
		dta		[((:3&$01)*64)+((:3&$02)*8)+((:3&$04)/1)+((:3&$08)/8)]*3
		dta		[((:3&$10)*4)+((:3&$20)/2)+((:3&$40)/16)+((:3&$80)/128)]*3

		;PF2 7..0
		dta		[((:3&$80)/2)+((:3&$40)/4)+((:3&$20)/8)+((:3&$10)/16)]*3
		dta		[((:3&$08)*8)+((:3&$04)*4)+((:3&$02)*2)+((:3&$01)* 1)]*3

		;PF1 0..7
		dta		[((:2&$01)*64)+((:2&$02)*8)+((:2&$04)/1)+((:2&$08)/8)]*3
		dta		[((:2&$10)*4)+((:2&$20)/2)+((:2&$40)/16)+((:2&$80)/128)]*3

		;PF0 7..4
		dta		[((:1&$80)/2)+((:1&$40)/4)+((:1&$20)/8)+((:1&$10)/16)]*3
.endm

pfdata_emptyroom:
		PFEXPAND	$C0,$FF,$FF
	:38	PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$FF,$FF

;room 1 (marketplace)
pfdata_room01:
		PFEXPAND	$F0,$FF,$FF
	:38	PFEXPAND	$F0,$00,$E0
		PFEXPAND	$F0,$FF,$FF

;room 2 (entrance room)
pfdata_room02:
		PFEXPAND	$F0,$FF,$FF
	:38	PFEXPAND	$F0,$E0,$00
		PFEXPAND	$F0,$FF,$FF

;room 5 (falling)
pfdata_room05:
		PFEXPAND	$F0,$FF,$FF
	:38	PFEXPAND	$F0,$C0,$00
		PFEXPAND	$F0,$FF,$FF

;room 6 (timepiece room)
pfdata_room06:
		PFEXPAND	$C0,$FF,$FF
		PFEXPAND	$C0,$FF,$FF
		PFEXPAND	$C0,$FF,$FF
		PFEXPAND	$C0,$FF,$FC
		PFEXPAND	$C0,$FF,$F0
		PFEXPAND	$C0,$FC,$E0
		PFEXPAND	$C0,$F0,$E0
		PFEXPAND	$C0,$E0,$C0
		PFEXPAND	$C0,$E0,$80
		PFEXPAND	$C0,$C0,$00
		PFEXPAND	$C0,$80,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$C0,$00
		PFEXPAND	$C0,$F0,$00
		PFEXPAND	$C0,$F8,$00
		PFEXPAND	$C0,$FE,$00
		PFEXPAND	$C0,$FE,$00
		PFEXPAND	$C0,$F8,$00
		PFEXPAND	$C0,$F0,$00
		PFEXPAND	$C0,$E0,$00
		PFEXPAND	$C0,$C0,$00
		PFEXPAND	$C0,$80,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$F0
		PFEXPAND	$C0,$00,$FE
		PFEXPAND	$C0,$FF,$FF

;room 9 (mesa field)
pfdata_room09:
		PFEXPAND	$F0,$FF,$FF
		PFEXPAND	$F0,$07,$07
		PFEXPAND	$F0,$07,$07
		PFEXPAND	$F0,$07,$07
		PFEXPAND	$F0,$03,$03
		PFEXPAND	$F0,$03,$03
		PFEXPAND	$F0,$03,$03
		PFEXPAND	$F0,$01,$01
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$30,$C0
		PFEXPAND	$F0,$78,$E0
		PFEXPAND	$F0,$7C,$E0
		PFEXPAND	$F0,$3C,$C0
		PFEXPAND	$F0,$3C,$C0
		PFEXPAND	$F0,$18,$80
		PFEXPAND	$F0,$08,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$30
		PFEXPAND	$F0,$00,$38
		PFEXPAND	$F0,$00,$1C
		PFEXPAND	$F0,$00,$1E
		PFEXPAND	$F0,$00,$0E
		PFEXPAND	$F0,$00,$0C
		PFEXPAND	$F0,$00,$0C
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$00,$C0
		PFEXPAND	$F0,$00,$F0
		PFEXPAND	$F0,$00,$FC
		PFEXPAND	$F0,$01,$FF
		PFEXPAND	$F0,$0F,$FF
		PFEXPAND	$F0,$01,$FF
		PFEXPAND	$F0,$00,$FF
		PFEXPAND	$F0,$00,$FE
		PFEXPAND	$F0,$00,$FC
		PFEXPAND	$F0,$00,$F8
		PFEXPAND	$F0,$00,$F0
		PFEXPAND	$F0,$00,$E0
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$80,$00
		PFEXPAND	$F0,$C0,$00
		PFEXPAND	$F0,$E0,$00
		PFEXPAND	$F0,$F8,$00
		PFEXPAND	$F0,$FC,$00
		PFEXPAND	$F0,$FE,$00
		PFEXPAND	$F0,$FC,$00
		PFEXPAND	$F0,$F0,$00
		PFEXPAND	$F0,$E0,$00
		PFEXPAND	$F0,$C0,$80
		PFEXPAND	$F0,$C0,$E0
		PFEXPAND	$F0,$80,$F0
		PFEXPAND	$F0,$80,$E0
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$03
		PFEXPAND	$F0,$03,$07
		PFEXPAND	$F0,$07,$03
		PFEXPAND	$F0,$03,$03
		PFEXPAND	$F0,$01,$01
		PFEXPAND	$F0,$00,$01
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$80
		PFEXPAND	$F0,$80,$C0
		PFEXPAND	$F0,$E0,$F0
		PFEXPAND	$F0,$F8,$F0
		PFEXPAND	$F0,$F8,$E0
		PFEXPAND	$F0,$F8,$E0
		PFEXPAND	$F0,$F8,$C0
		PFEXPAND	$F0,$F0,$C0
		PFEXPAND	$F0,$C0,$80
		PFEXPAND	$F0,$80,$80
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$00
		PFEXPAND	$F0,$00,$03
		PFEXPAND	$F0,$03,$07
		PFEXPAND	$F0,$0F,$07
		PFEXPAND	$F0,$1F,$03
		PFEXPAND	$F0,$3F,$01
		PFEXPAND	$F0,$3E,$00
		PFEXPAND	$F0,$3C,$00
		PFEXPAND	$F0,$38,$C0
		PFEXPAND	$F0,$30,$E0
		PFEXPAND	$F0,$00,$F0
		PFEXPAND	$F0,$00,$F8
		PFEXPAND	$F0,$00,$F8
		PFEXPAND	$F0,$00,$FC
		PFEXPAND	$F0,$00,$FC
		PFEXPAND	$F0,$00,$FC
		PFEXPAND	$F0,$FF,$FF

		org		$3000

;room 7 (spider room)
pfdata_room07:
		PFEXPAND	$C0,$FF,$FF
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$02,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$0F,$00
		PFEXPAND	$C0,$0F,$00
		PFEXPAND	$C0,$0F,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$02,$00
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$04,$00
		PFEXPAND	$C0,$0E,$00
		PFEXPAND	$C0,$0E,$00
		PFEXPAND	$C0,$0F,$00
		PFEXPAND	$C0,$0E,$00
		PFEXPAND	$C0,$06,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$FF,$FF

;room 8 (guardian room)
pfdata_room08:
		PFEXPAND	$C0,$FF,$FF
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$02,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$0F,$01
		PFEXPAND	$C0,$1F,$03
		PFEXPAND	$C0,$0F,$01
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$07,$00
		PFEXPAND	$C0,$02,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$F8
		PFEXPAND	$C0,$00,$E0
		PFEXPAND	$C0,$00,$C0
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$00,$00
		PFEXPAND	$C0,$FF,$FF

;room 4 (map room)
pfdata_room04:
		PFEXPAND	$C0,$FF,$FF
	:38	PFEXPAND	$C0,$00,$80
		PFEXPAND	$C0,$FF,$FF

;room 11 (thief room)
pfdata_room0B:
		PFEXPAND	$F0,$FF,$FF
	:38	PFEXPAND	$F0,$F0,$C0
		PFEXPAND	$F0,$FF,$FF

;room 12 (inside the mesa)
pfdata_room0C:
		PFEXPAND	$F0,$FF,$FF
	:38	PFEXPAND	$F0,$F0,$00
		PFEXPAND	$F0,$FF,$FF

.macro PLAYFIELD_POINTERS
		dta		:1[pfdata_emptyroom]	;$00 - treasure room
		dta		:1[pfdata_room01]		;$01 - marketplace
		dta		:1[pfdata_room02]		;$02 - entrance room
		dta		:1[pfdata_room01]		;$03 - black market
		dta		:1[pfdata_room04]		;$04 - map room?
		dta		:1[pfdata_room05]		;$05 - falling room
		dta		:1[pfdata_room06]		;$06 - timepiece room
		dta		:1[pfdata_room07]		;$07 - spider room
		dta		:1[pfdata_room08]		;$08 - guardian room
		dta		:1[pfdata_room09]		;$09 - mesa field
		dta		:1[pfdata_room09]		;$0A - valley of death
		dta		:1[pfdata_room0B]		;$0B - thief room
		dta		:1[pfdata_room0C]		;$0C - inside the mesa
		dta		:1[pfdata_emptyroom]	;$0D - well of souls
.endm

playfield_ptrs_lo:
		PLAYFIELD_POINTERS	<

playfield_ptrs_hi:
		PLAYFIELD_POINTERS	>

;===========================================================================
.proc vbiHandler
		lda		color0
		sta		colpf0
		sta		colpm2
		sta		colpm3
		lda		color4
		sta		colbk
		lda		pcolr0
		sta		colpm0
		lda		pcolr1
		sta		colpm1

		;select display list
		lda		#<dlist1
		ldy		#>dlist1
		ldx		$81
		cpx		#11
		bcs		use_dlist2
		cpx		#6
		bcs		use_dlist1
use_dlist2:
		lda		#<dlist2
		ldy		#>dlist2
use_dlist1:
		sta		dlistl
		sty		dlisth

		mwa		#dliHandlerStatus1 vdslst
		mva		#$c0 nmien
		pla
		tay
		pla
		tax
		pla
		rti
.endp

;===========================================================================
.proc dliHandlerStatus1
		pha
		LDA		#$42
		sta		wsync
		STA		COLBK
		LDA		#$1A
		STA		colpf1
		lda		#$08
		sta		colpf0
		lda		#$22
		sta		dmactl
		mwa		#dliHandlerStatus2 vdslst
		pla
		rti
.endp

.proc dliHandlerStatus2
		pha
		lda		#0
		sta		wsync
		sta		colbk
		pla
		rti
.endp

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
		dta		$10		;$0: volume only mode
		dta		$C0		;$1: 4-bit poly
		dta		$20		;$2: 5-bit poly -> 4 bit poly
		dta		$20		;$3: 5-bit poly -> 4 bit poly
		dta		$a0		;$4: pure tone
		dta		$a0		;$5: pure tone
		dta		$a0		;$6: pure tone
		dta		$20		;$7: 5-bit poly, div 2
		dta		$80		;$8: 9-bit poly
		dta		$20		;$9: 5-bit poly mode
		dta		$A0		;$A: pure tone, div 31
		dta		$B0		;$B: volume only mode
		dta		$a0		;$C: pure tone, div 6
		dta		$a0		;$D: pure tone, div 6
		dta		$a0		;$E: pure tone, div 93
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
		dta		<audio_lotab6
		dta		<audio_lotab31
		dta		<audio_lotab
		dta		<audio_lotab6
		dta		<audio_lotab6
		dta		<audio_lotab93
		dta		<audio_lotab6

;===========================================================================
.proc main
		;stomp PUPBT1 and COLDST to force cold restart
		lda		#$ff
		sta		pupbt1
		sta		coldst

		;interrupts off
		sei
		lda		#0
		sta		nmien

		;reset ANTIC/GTIA/POKEY
		tax
hwinit_loop:
		dex
		sta		$d000,x
		sta		$d200,x
		sta		$d400,x
		bne		hwinit_loop

		;reinit PIA port A
		mva		#$38 pactl		;IRQs off, deassert motor, select DDRA
		mvx		#0 porta		;set all to inputs
		mvy		#$3c pactl		;select ORA
		sty		pbctl			;IRQs off, deassert command, select ORB
		lda		porta			;clear IRQA1/2
		lda		portb			;clear IRQB1/2

		;init POKEY for audio emulation
		mva		#$f8 audctl

		;enable keyboard scan and audio timers
		mva		#$03 skctl

		;enable keyboard IRQ (even though we keep IRQs masked)
		mva		#$40 irqen

		;init variables
		mva		#$3f swchb

		;clear BSS
ptr = $01
		mwa		#bss_start ptr
		ldx		#>(bss_end - bss_start)
		lda		#0
		tay
bssclear_loop:
		sta:rne	(ptr),y+
		inc		ptr+1
		dex
		bne		bssclear_loop

		;clear status line
		lda		#[LFB00 & $0100]/8
		ldx		#19
statusclear_loop:
		sta:rpl	playfield_status,x-

		;wait for vertical blank
		lda		#124
		cmp:rne	vcount

		;init ANTIC
		mva		#>missile_dat pmbase
		mva		#>LFB00 chbase

		;turn on playfield DMA and missile DMA
		mva		#$26 dmactl
		mva		#$04 chactl
		mva		#$01 gractl
		mva		#$ef vdelay
		mva		#$01 vscrol

		;set up VBI handler and turn on only VBI
		mwa		#vbiHandler vvblki
		mva		#$40 nmien

		jmp		start
.endp

;===========================================================================
.proc doVBlank
		;copy START and SELECT into game reset/select switches
		lda		consol
		eor		swchb
		and		#3
		eor		swchb
		sta		swchb

		;copy joysticks (note that we are swapping P1/P2 here)
		lda		porta
		sta		swcha

		lda		trig1
		lsr
		ror
		sta		inpt4
		lda		trig0
		lsr
		ror
		sta		inpt5

		;check for a key being pressed
		bit		irqen
		bvs		no_kbirq
		lda		#0
		sta		irqen
		lda		#$40
		sta		irqen
		bne		key_pressed
no_kbirq:
		;check if key is held down
		lda		skstat
		and		#4
		bne		no_key
key_pressed:
		;get key code
		lda		kbcode

		cmp		#$20
		bne		not_left
		lda		#$bf
		and		swcha
		jmp		add_joymove
not_left:
		cmp		#$22
		bne		not_right
		lda		#$7f
add_joymove:
		and		swcha
		sta		swcha
		jmp		no_key
not_right:
		cmp		#$21
		bne		not_space
		lda		#$00
		sta		inpt4
not_space:
no_key:

		;copy START and SELECT into game reset/select switches
		lda		consol
		eor		swchb
		and		#3
		eor		swchb
		sta		swchb

		;check if paddle A is active; if so, assume button C is pressed
		;on a Genesis controller, and reflect P2 left/right/down to
		;P1 left/right/trigger
		lda		pot0
		sta		potgo
		sta		c_button

		bit		use_c_button
		bpl		no_buttonC
		asl
		bcc		no_buttonC

		lda		swcha
		asl
		asl
		asl
		asl
		ora		#$3F
		and		swcha
		tax
		ora		#$0F
		sta		swcha
		txa
		lsr
		ror
		ror
		ora		#$7F
		and		inpt4
		sta		inpt4

no_buttonC:
		rts
.endp

;===========================================================================
.proc updateStatusLine
		ldx		#5
		ldy		#10
item_loop:
		lda		$b7,y
		dey
		dey
		lsr
		lsr
		lsr
		ora		#[[LFB00&$0100]/8]+$40
		sta		playfield_status+7,x
		dex
		bpl		item_loop
		rts
.endp

;===========================================================================
.proc waitFrameStart
		stx		pending_dmactl
		sty		pending_gractl

		jsr		updateAudio
		jsr		updateStatusLine

		lda		#15
		cmp:rne	vcount
		cmp:req	vcount
		sta		wsync
		ldx		pending_dmactl		;~104-107
		ldy		pending_gractl		;~110-113
		pha:pla						;~0-6
		pha:pla						;~7-13
		stx		dmactl
		sty		gractl				;~104-107
		sta		wsync

		rts
.endp

;===========================================================================
; Reposition objects
;

.proc LD006
		LDX		#$04
LD008:	LDA		$C8,X
		clc
		adc		hposp0_offset,x
		ldy		gtia_tab,x
		sta		hposp0,y

		DEX
		BPL		LD008
		jmp		LF844

gtia_tab:
		dta		0,1,4,5,6
	   .endp

;===========================================================================
LD024:	;--- valley of death / thief room / mesa checks
		lda		m1pl			;check for missile 1 collision with player 0
		and		#1
		beq		LD05C
		LDX		$81				;get current room
		CPX		#$0A			;check if valley of death, thief room, or inside mesa
		BCC		LD05C			;skip if not
		BEQ		LD03F			;jump if valley of death
		LDA		$D1				;compute thief index
		ADC		#$01
		LSR
		LSR
		LSR
		LSR
		TAX
		LDA		#$08			;flip movement direction for thief
		EOR		$DF,X
		STA		$DF,X
LD03F:	LDA		$8F
		BPL		LD054
		AND		#$7F
		STA		$8F
		LDA		$95
		AND		#$1F
		BEQ		LD050
		JSR		LDCE9
LD050:	LDA		#$40
		STA		$95
LD054:	LDA		#$7F
		STA		$D1
		LDA		#$04			;-4 score for shooting thief
		STA		$AC				;set penalty
LD05C:	;--- 
		lda		m1pl
		and		#$0c
		ora		m1pf
		beq		LD0AA
		LDX		$81				;get current room
		CPX		#$09			;check if mesa field
		BEQ		LD0BC			;jump if so
		CPX		#$06			;check if temple entrance
		BEQ		LD06E			;jump if so
		CPX		#$08			;check if guardian room
		BNE		LD0AA			;jump if not
LD06E:	LDA		$D1
		SBC		$D4
		LSR
		LSR
		BEQ		LD087
		TAX
		LDY		$CB
		CPY		#$12
		BCC		LD0A4
		CPY		#$8D
		BCS		LD0A4
		LDA		#$00
		STA		$E5,X
		BEQ		LD0A4
LD087:	LDA		$CB
		CMP		#$30
		BCS		LD09E
		SBC		#$10
		EOR		#$1F
LD091:	LSR
		LSR
		TAX
		LDA		LDC5C,X
		AND		$E5
		STA		$E5
		JMP		LD0A4

LD09E:	SBC		#$71
		CMP		#$20
		BCC		LD091
LD0A4:	LDY		#$7F
		STY		$8F
		STY		$D1
LD0AA:
		;Check for a shot hitting the snake (ball <-> m1 collision).
		;Unfortunately, we use M2 for the ball, so we can't detect this collision
		;directly in GTIA. To work around this, display kernel 0 also doubles up
		;P2 under the shot so we can detect a P2-M2 collision. Fortunately, the
		;snake doesn't activate with display kernel 1, where we use P2 for the
		;dynamic playfield.
		lda		m2pl			;check for ball collision with missile 1
		and		#4
		beq		LD0BC			;jump if not
		BIT		$93				;check if snake is enabled
		BVC		LD0BC			;jump if not
		LDA		#$5A			;nuke the snake
		STA		$D2
		STA		$DC
		STA		$8F
		STA		$D1
LD0BC:	lda		m2pl			;check for ball collision with Indy
		and		#2
		beq		LD0ED
		LDX		$81				;get current room
		CPX		#$06			;check if it's the timepiece room
		BEQ		LD0E2			;jump if so
		LDA		$C5				;get current inventory item
		CMP		#$02			;check if it's the flute
		BEQ		LD0ED			;skip if so
		BIT		$93				;check of tsetse flies are active
		BPL		LD0DA			;jump if not
		LDA		$83				;get ~seconds
		AND		#$07
		ORA		#$80
		STA		$A1				;stun Indy
		BNE		LD0ED

LD0DA:	BVC		LD0ED			;jump if snake not either anyway
		LDA		#$80
		STA		$9D				;kill Indy (snake bite)
		BNE		LD0ED

LD0E2:	LDA		$D6
		CMP		#<LFABA
		BNE		LD0ED
		LDA		#$0F			;timepiece
		JSR		LDCE9			;add to inventory
LD0ED:	LDX		#$05			;falling room
		CPX		$81				;current room?
		BNE		LD12D			;jump if not
		lda		m0pl			;check for missile 0 collision with Indy
		and		#2
		beq		LD106			;jump if not
		STX		$CF				;warp vertical pos
		LDA		#$0C			;inside the mesa
		STA		$81				;change room
		JSR		LD878			;set up new room
		LDA		#$4C			;middle
		STA		$C9				;reset horizontal position
		BNE		LD12B

LD106:	LDX		$CF				;get vertical position
		CPX		#$4F			;check if at bottom
		BCC		LD12D			;skip if not
		LDA		#$0A			;valley of death
		STA		$81				;change room
		JSR		LD878			;set up new room
		LDA		$EB
		STA		$DF
		LDA		$EC
		STA		$CF
		LDA		$ED
		STA		$C9
		LDA		#$FD			;turn off Yar flag
		AND		$B4
		STA		$B4
		BMI		LD12B
		LDA		#$80
		STA		$9D				;kill Indy
LD12B:	STA		CXCLR
LD12D:	lda		p1pl			;check for P0-P1 collision
		ror
		bcs		LD140			;jump if so
		LDX		#$00
		STX		$91
		DEX
		STX		$97
		ROL		$95
		CLC
		ROR		$95
LD13D:	JMP		LD2B4

LD140:	LDA		$81
		BNE		LD157
		LDA		$AF
		AND		#$07
		TAX
		LDA		LDF78,X
		JSR		LDCE9
		BCC		LD13D
		LDA		#$01
		STA		$DF
		BNE		LD13D

LD157:	ASL
		TAX
		LDA		LDC9B+1,X
		PHA
		LDA		LDC9B,X
		PHA
		RTS

;===========================================================================
; Player collision handler - room 12 (inside mesa)
;
LD162:	LDA		$CF
		CMP		#$3F
		BCC		LD18A
		LDA		$96
		CMP		#$54
		BNE		LD1C1
		LDA		$8C				;get correct mesa
		CMP		$8B				;check if current mesa is the correct one
		BNE		LD187			;jump if not
		LDA		#$58
		STA		$9C
		STA		$9E
		JSR		LDDDB			;compute score
		LDA		#$0D			;well of souls
		STA		$81				;change room
		JSR		LD878			;set up new room
		JMP		LD3D8

LD187:	JMP		LD2DA			;switch to falling screen

LD18A:	LDA		#$0B
		BNE		LD194

;===========================================================================
; Player collision handler - room 11 (thief room)
;
LD18E:	LDA		#$07			;key
		BNE		LD194			;steal something

;===========================================================================
; Player collision handler - room 10 (valley of death)
;
LD192:	LDA		#$04			;bag of coins
LD194:	BIT		$95
		BMI		LD1C1
		CLC
		JSR		LDA10			;try to steal the coins
		BCS		LD1A4
		SEC
		JSR		LDA10			;steal something else
		BCC		LD1C1
LD1A4:	CPY		#$0B
		BNE		LD1AD
		ROR		$B2
		CLC
		ROL		$B2
LD1AD:	LDA		$95
		JSR		LDD59
		TYA
		ORA		#$C0
		STA		$95
		BNE		LD1C1

;===========================================================================
; Player collision handler - room 7 (spider room)
;
LD1B9:	LDX		#$00
		STX		$B6
		LDA		#$80
		STA		$9D				;kill Indy
LD1C1:	JMP		LD2B4

;===========================================================================
; Player collision handler - room 5 (falling room)
;
LD1C4:	BIT		$B4				;check parachute
		BVS		LD1E8			;jump if parachute broken
		BPL		LD1E8			;jump if parachute not open
		LDA		$C9				;get Indy horizontal position
		CMP		#$2B			;check if within branch horizontal range
		BCC		LD1E2			;jump if above
		LDX		$CF				;get Indy vertical position
		CPX		#$27			;check if higher than branch
		BCC		LD1E2			;skip if so
		CPX		#$2B			;check if lower than branch
		BCS		LD1E2			;skip if so
		LDA		#$40			;break the parachute
		ORA		$B4
		STA		$B4
		BNE		LD1E8
LD1E2:	LDA		#$03			;parachute item
		SEC
		JSR		LDA10			;lose the parachute item
LD1E8:	JMP		LD2B4

;===========================================================================
; Player collision handler - room 1 (marketplace)
;
; If the player is overlapping the flute or the parachute icon, set flags
; for that. Otherwise, check for collision with a basket; drop the
; grenade, revolver, and keys as guaranteed drops, unless the high timer
; gives a 1-in-16 chance of overriding it with the Staff of Ra.
;
LD1EB:	lda		p1pf			;check if player is over playfield (median)
		beq		LD21A			;jump if not
		LDY		$CF				;get Indy's vertical position
		CPY		#$3A			;check if above $3A
		BCC		LD200			;jump if so
		LDA		#$E0
		AND		$91
		ORA		#$43
		STA		$91
		JMP		LD2B4

LD200:	CPY		#$20			;check if above $20
		BCC		LD20B			;jump if so
LD204:	LDA		#$00
		STA		$91
		JMP		LD2B4

LD20B:	CPY		#$09			;check if above $09
		BCC		LD204			;jump if so
		LDA		#$E0
		AND		$91
		ORA		#$42
		STA		$91
		JMP		LD2B4

LD21A:	LDA		$CF				;get Indy's vertical position
		CMP		#$3A			;check if above $3A
		BCC		LD224			;jump if so
		LDX		#$07			;select key (bottom basket)
		BNE		LD230			;attempt to drop

LD224:	LDA		$C9				;get Indy's horizontal position
		CMP		#$4C			;check if >= $4C
		BCS		LD22E			;jump if so
		LDX		#$05			;select grenade 1 (left basket)
		BNE		LD230			;attempt to drop

LD22E:	LDX		#$0D			;select revolver (right basket)
LD230:	LDA		#$40			;snake flag
		STA		$93				;enable snake
		LDA		$83				;get timer high
		AND		#$1F			;mask to 5 bits
		CMP		#$02			;check if 0 or 1 out of 32 (1/16 chance)
		BCS		LD23E
		LDX		#$0E			;select staff head
LD23E:	JSR		LDD43
		BCS		LD247
		TXA		
		JSR		LDCE9			;add item to inventory
LD247:	JMP		LD2B4

;===========================================================================
; Player collision handler - room 3 (black market)
;
LD24A:	lda		p1pf			;check if over median
		bne		LD26E			;jump if so
		LDA		$C9				;check horizontal position
		CMP		#$50			;to the right?
		BCS		LD262			;jump if so
		DEC		$C9				;bump Indy left
		ROL		$B2				;invalidate bribe
		CLC		
		ROR		$B2
LD25B:	LDA		#$00
		STA		$91
LD25F:	JMP		LD2B4

LD262:	LDX		#$06			;select grenade 2 (basket)
		LDA		$83				;get timer high
		CMP		#$40			;1-in-4 chance of key (every four minutes)
		BCS		LD23E
		LDX		#$07			;select key (basket)
		BNE		LD23E			;drop it

LD26E:	LDY		$CF
		CPY		#$44
		BCC		LD27E
		LDA		#$E0
		AND		$91
		ORA		#$0B			;set up for shovel; require two coins
LD27A:	STA		$91
		BNE		LD25F
LD27E:	CPY		#$20
		BCS		LD25B
		CPY		#$0B
		BCC		LD25B
		LDA		#$E0
		AND		$91
		ORA		#$41			;set up for bullets; require one coin
		BNE		LD27A

;==========================================================================
LD28E:	INC		$C9
		BNE		LD2B4

;==========================================================================
LD292:	LDA		$CF
		CMP		#$3F
		BCC		LD2AA
		LDA		#$0A			;whip
		JSR		LDCE9			;add to inventory
		BCC		LD2B4			;skip if failed to add
		ROR		$B1				;set bit 0 to indicate whip collected
		SEC						; "
		ROL		$B1				; "
		LDA		#$42
		STA		$DF
		BNE		LD2B4

LD2AA:	CMP		#$16
		BCC		LD2B2
		CMP		#$1F
		BCC		LD2B4
LD2B2:	DEC		$C9
LD2B4:	LDA		$81				;get current room
		ASL						;2x
		TAX						;-> index
		lda		p1pl
		and		#$0c
		ora		p1pf			;check for playfield collision
		beq		LD2C5			;use alternate jump table if not

		LDA		LDCB5+1,X
		PHA		
		LDA		LDCB5,X
		PHA		
		RTS

LD2C5:	LDA		LDCCF+1,X
		PHA
		LDA		LDCCF,X
		PHA
		RTS

;==========================================================================
; Collisionless update - room 9 (mesa field)
;
LD2CE:	LDA		$DF
		STA		$EB
		LDA		$CF
		STA		$EC
		LDA		$C9
LD2D8:	STA		$ED
LD2DA:	LDA		#$05		;falling room
		STA		$81			;change room
		JSR		LD878
		LDA		#$05
		STA		$CF
		LDA		#$50
		STA		$C9
		TSX		
		CPX		#$FE
		BCS		LD2EF
		RTS

LD2EF:	JMP		LD374

;==========================================================================
; Collisionless update - room 4 (map room)
;
LD2F2:	BIT		$B3
		BMI		LD2EF
		LDA		#$50
		STA		$EB
		LDA		#$41
		STA		$EC
		LDA		#$4C
		BNE		LD2D8

;==========================================================================
; Collision update - room 6 (temple entrance)
;
LD302:	LDY		$C9			;get Indy horizontal position
		CPY		#$2C		;check if on left
		BCC		LD31A		;if so, bump right
		CPY		#$6B		;check if on right
		BCS		LD31C		;if so, bump left
		LDY		$CF			;get Indy vertical position
		INY					;bump down
		CPY		#$1E		;check if near top
		BCC		LD315		;jump if so
		DEY					;undo bump down
		DEY					;bump up
LD315:	STY		$CF			;set Indy vertical position
		JMP		LD364

LD31A:	INY
		INY
LD31C:	DEY
		STY		$C9
		BNE		LD364

;==========================================================================
; Collision update - room 2 (entrance room)
;
LD321:	LDA		#$02		;hole bit
		AND		$B1			;check if hole blasted
		BEQ		LD331		;skip if not
		LDA		$CF			;get Indy vertical pos
		CMP		#$12		;check if too high
		BCC		LD331		;skip if so
		CMP		#$24		;check if too low
		BCC		LD36A		;jump if not (within hole vrange) - slow Indy
LD331:	DEC		$C9			;bump Indy left
		BNE		LD364

;==========================================================================
; Collision update - room 8 (guardian room)
;
LD335:	LDX		#$1A		;use left jail position
		LDA		$C9			;get Indy's horizontal position
		CMP		#$4C		;check if on the left side
		BCC		LD33F		;jump if so
		LDX		#$7D		;use right jail position
LD33F:	STX		$C9			;reset Indy's horizontal position
		LDX		#$40		;near bottom
		STX		$CF			;reset Indy's vertical position
		LDX		#$FF		;reinitialize jail graphics
		STX		$E5
		LDX		#$01
		STX		$E6
		STX		$E7
		STX		$E8
		STX		$E9
		STX		$EA
		BNE		LD364		;all done

;==========================================================================
; Collision update - room 5 (falling room)
; Collision update - room 7 (spider room)
;
LD357:	LDA		$92
		AND		#$0F
		TAY
		LDA		LDFD5,Y
		LDX		#$01
		JSR		LDFC0		;move Indy
LD364:	LDA		#$05
		STA		$A2			;play bump noise
		BNE		LD374

;==========================================================================
; Collision update - room 10 (valley of death)
;
LD36A:	ROL		$8A				;set bog flag
		SEC
		BCS		LD372

;==========================================================================
; Collisionless update - room 2 (entrance room)
; Collisionless update - room 10 (valley of death)
;
LD36F:	ROL		$8A
		CLC
LD372:	ROR		$8A
LD374:	lda		m0pl
		and		#2
		beq		LD396
		LDX		$81				;get current room
		CPX		#$07			;check if it's the spider room
		BEQ		LD386			;jump if so
		BCC		LD396			;jump if entrance room
		LDA		#$80
		STA		$9D				;it's the valley... kill Indy
		BNE		LD390

LD386:	ROL		$8A				;slow down Indy
		SEC
		ROR		$8A
		ROL		$B6
		SEC
		ROR		$B6
LD390:	LDA		#$7F
		STA		$8E
		STA		$D0
LD396:	BIT		$9A				;check if grenade is live
		BPL		LD3D8			;skip if not
		BVS		LD3A8
		LDA		$83				;get approx. seconds
		CMP		$9B				;check if time to go boom
		BNE		LD3D8			;skip if not
		LDA		#$A0			;
		STA		$D1				;turn off the grenade dot (missile 1)
		STA		$9D				;kill Indy
LD3A8:	LSR		$9A				;check if we should blast a hole
		BCC		LD3D4			;skip if not
		LDA		#$02			;-2 score for blasting hole
		STA		$A5				;do it
		ORA		$B1				;set hole blasted bit
		STA		$B1				;write back
		LDX		#$02
		CPX		$81
		BNE		LD3BD
		JSR		LD878
LD3BD:	LDA		$B5				;check temple door
		AND		#$0F			;is it closing?
		BEQ		LD3D4			;skip if not
		LDA		$B5				;reset the temple door, but keep it falling
		AND		#$F0
		ORA		#$01
		STA		$B5
		LDX		#$02
		CPX		$81
		BNE		LD3D4
		JSR		LD878
LD3D4:	SEC
		JSR		LDA10
LD3D8:	jsr		doVBlank
LD3DD:	LDA		#$50
		CMP		$D1
		BCS		LD3EB
		STA		$CB
LD3EB:	INC		$82				;increment low timer
		LDA		#$3F			;check if 64 vblanks have passed
		AND		$82				; "
		BNE		LD3FB			;skip if not
		INC		$83				;increment high timer
		LDA		$A1				;
		BPL		LD3FB			;
		DEC		$A1				;
LD3FB:	BIT		$9C
		BPL		LD409
		ROR		SWCHB
		BCS		LD409
		JMP		LDD68

LD409:	LDA		#$00
		LDX		$9D
		INX
		BNE		LD42A
		STX		$9D
		JSR		LDDDB
		LDA		#$0D			;well of souls
		STA		$81				;change room
		JSR		LD878			;set up new room
LD427:	JMP		LD80D

LD42A:	LDA		$81				;get current room
		CMP		#$0D			;check if it's the well of souls
		BNE		LD482			;jump if not

		LDA		#$9C
		STA		$A3
		LDY		$AA				;check Yar scoring bonus
		BEQ		LD44A			;jump if Yar not seen
		BIT		$9C				;check if correct mesa was found
		BMI		LD44A			;jump if not
		LDX		#$FF			;put HSW2 items in first two inventory slots
		STX		$B8
		STX		$BA
		LDA		#<hsw2_sprite1	;originally <LFF46
		STA		$B7
		LDA		#<hsw2_sprite2	;originally <LFF01
		STA		$B9
LD44A:	LDY		$CF
		CPY		#$7C
		BCS		LD465
		CPY		$9E
		BCC		LD45B
		BIT		INPT5
		BMI		LD427
		JMP		LDD68

LD45B:	LDA		$82
		ROR
		BCC		LD427
		INY
		STY		$CF
		BNE		LD427
LD465:	BIT		$9C
		BMI		LD46D
		LDA		#$0E
		STA		$A2
LD46D:	LDA		#$80
		STA		$9C
		BIT		INPT5			;check player 2 button
		BMI		LD427			;jump if not pressed
		LDA		$82				;get current time
		AND		#$0F			;mask to 0-15
		BNE		LD47D			;set Ark if nonzero
		LDA		#$05			;default to Ark 5
LD47D:	STA		$8C				;set mesa with the Ark
		JMP		LDDA6

LD482:	BIT		$93				;check if snake is active
		BVS		LD489			;jump if so
LD486:	JMP		LD51C
LD489:	LDA		$82				;get frame counter
		AND		#$03
		BNE		LD501
		LDX		$DC
		CPX		#$60
		BCC		LD4A5
		BIT		$9D
		BMI		LD486
		LDX		#$00
		LDA		$C9
		CMP		#$20
		BCS		LD4A3
		LDA		#$20
LD4A3:	STA		$CC
LD4A5:	INX
		STX		$DC
		TXA
		SEC
		SBC		#$07
		BPL		LD4B0
		LDA		#$00
LD4B0:	STA		$D2
		AND		#$F8
		CMP		$D5
		BEQ		LD501
		STA		$D5
		LDA		$D4
		AND		#$03
		TAX
		LDA		$D4
		LSR
		LSR
		TAY
		LDA		LDBFF,X
		CLC
		ADC		LDBFF,Y
		CLC
		ADC		$CC
		LDX		#$00
		CMP		#$87
		BCS		LD4E2
		CMP		#$18
		BCC		LD4DE
		SBC		$C9
		SBC		#$03
		BPL		LD4E2
LD4DE:	INX
		INX
		EOR		#$FF
LD4E2:	CMP		#$09
		BCC		LD4E7
		INX
LD4E7:	TXA
		ASL
		ASL
		STA		$84
		LDA		$D4
		AND		#$03
		TAX
		LDA		LDBFF,X
		CLC
		ADC		$CC
		STA		$CC
		LDA		$D4
		LSR
		LSR
		ORA		$84
		STA		$D4
LD501:	LDA		$D4
		AND		#$03
		TAX
		LDA		LDBFB,X
		STA		$D6
		LDA		#$7A			;!! - relocation hazard
		STA		$D7
		LDA		$D4
		LSR
		LSR
		TAX
		LDA		LDBFB,X
		SEC
		SBC		#$08
		STA		$D8
LD51C:	BIT		$9D
		BPL		LD523
		JMP		LD802

LD523:	BIT		$A1
		BPL		LD52A
		JMP		LD78C
LD52A:	LDA		$82
		ROR
		BCC		LD532
		JMP		LD627

LD532:	LDX		$81				;get current room
		CPX		#$05			;check if falling room
		BEQ		LD579			;block movement if so
		BIT		$8D				;check if grappling hook active
		BVC		LD56E			;jump if not

		;do grappling hook input
		LDX		$CB
		TXA
		SEC
		SBC		$C9
		TAY
		LDA		SWCHA			;read joystick
		ROR						;test for player 2 up
		BCC		LD55B			;jump if so
		ROR						;test for player 2 down
		BCS		LD579			;jump if not
		CPY		#$09
		BCC		LD579
		TYA
		BPL		LD556
LD553:	INX		
		BNE		LD557
LD556:	DEX		
LD557:	STX		$CB
		BNE		LD579
LD55B:	CPX		#$75
		BCS		LD579
		CPX		#$1A
		BCC		LD579
		DEY		
		DEY		
		CPY		#$07
		BCC		LD579
		TYA		
		BPL		LD553
		BMI		LD556

LD56E:	BIT		$B4				;check parachute
		BMI		LD579			;block movement if parachute open
		BIT		$8A				;check if in bog
		BPL		LD57C			;jump if not
		ROR						;check if we should skip movement this tick
		BCC		LD57C			;jump if not
LD579:	JMP		LD5E0			;skip movement
LD57C:	LDX		#$01
		LDA		SWCHA			;read joysticks
		STA		$85				;store for later use
		AND		#$0F			;mask to P2
		CMP		#$0F			;check if any inputs
		BEQ		LD579			;skip if not
		STA		$92
		JSR		LDFC0			;do movement
		;--- wall exit/bump tests
		LDX		$81
		LDY		#$00
		STY		$84
		BEQ		LD599

LD596:	TAX		
		INC		$84				;next test index
LD599:	LDA		$C9				;get Indy horizontal position
		PHA		
		LDA		$CF				;get Indy vertical position
		LDY		$84
		CPY		#$02
		BCS		LD5AC
		STA		$86
		PLA		
		STA		$87
		JMP		LD5B1

LD5AC:	STA		$87
		PLA		
		STA		$86
LD5B1:	ROR		$85
		BCS		LD5D1
		JSR		LD97C			;check for horizontal exit?
		BCS		LD5DB			;change room if so
		BVC		LD5D1
		LDY		$84				;get test index
		LDA		LDF6C,Y			;get position bump offset
		CPY		#$02			;check if horizontal test
		BCS		LD5CC			;jump if so
		ADC		$CF				;bump Indy vertically away from wall
		STA		$CF				;update Indy vertical position
		JMP		LD5D1

LD5CC:	CLC		
		ADC		$C9				;bump Indy horizontally away from wall
		STA		$C9				;update Indy horizontal position
LD5D1:	TXA
		CLC		
		ADC		#$0D			;advance to next test
		CMP		#$34
		BCC		LD596
		BCS		LD5E0

LD5DB:	STY		$81				;change room
		JSR		LD878			;set up new room
LD5E0:	BIT		INPT4			;check if item drop button pressed
		BMI		LD5F5			;jump if not
		BIT		$9A
		BMI		LD624
		LDA		$8A
		ROR		
		BCS		LD5FA
		SEC		
		JSR		LDA10
		INC		$8A
		BNE		LD5FA

LD5F5:	ROR		$8A
		CLC		
		ROL		$8A
LD5FA:	LDA		$91				;check marketplace buy status
		BPL		LD624			;jump if not enough coins
		AND		#$1F
		CMP		#$01
		BNE		LD60C
		INC		$A0
		INC		$A0
		INC		$A0
		BNE		LD620
LD60C:	CMP		#$0B			;check if it's the shovel
		BNE		LD61D
		ROR		$B2				;mark shovel collected
		SEC		
		ROL		$B2
		LDX		#$45
		STX		$DF
		LDX		#$7F
		STX		$D0
LD61D:	JSR		LDCE9			;try to drop item
LD620:	LDA		#$00
		STA		$91
LD624:	JMP		LD777
LD627:	BIT		$9A
		BMI		LD624
		BIT		INPT5
		BPL		LD638
		LDA		#$FD
		AND		$8A
		STA		$8A
		JMP		LD777

LD638:	LDA		#$02
		BIT		$8A
		BNE		LD696
		ORA		$8A
		STA		$8A
		LDX		$C5				;get current item
		CPX		#$05			;check if it's grenade #1
		BEQ		LD64C			;jump if so
		CPX		#$06			;check if it's grenade #2
		BNE		LD671			;jump if not
		;--- grenade routine
LD64C:	LDX		$CF				;get Indy vertical position
		STX		$D1				;position missile 1 there as 'grenade' dot
		LDY		$C9				;get Indy horizontal position
		STY		$CB				;position missile 1 there
		LDA		$83				;get current approx. seconds timer
		ADC		#$04			;add four seconds
		STA		$9B				;set as boom time
		LDA		#$80			;grenade live bit
		CPX		#$35			;check if Indy close enough to the top
		BCS		LD66C			;fail if not
		CPY		#$64			;check if Indy close enough to the right
		BCC		LD66C			;fail if not
		LDX		$81				;check current room
		CPX		#$02			;entrance room?
		BNE		LD66C			;skip if not
		ORA		#$01			;looks good, set bit to blast hole
LD66C:	STA		$9A				;set bitfield
		JMP		LD777

LD671:	CPX		#$03			;check if parachute is selected
		BNE		LD68B			;jump if not
		STX		$A8				;set +3 scoring bonus for using parachute
		LDA		$B4				;check if parachute already open
		BMI		LD696			;skip if so
		ORA		#$80			;set parachute flag
		STA		$B4				;
		LDA		$CF
		SBC		#$06
		BPL		LD687
		LDA		#$01
LD687:	STA		$CF
		BPL		LD6D2

LD68B:	BIT		$8D				;check flags
		BVC		LD6D5			;jump if grappling hook not active
		lda		m1pl
		and		#$0c
		ora		m1pf			;test for collision with playfield
		bne		LD699			;jump if so
		JSR		LD2CE			;start falling
LD696:	JMP		LD777

LD699:	LDA		$D1
		LSR		
		SEC		
		SBC		#$06
		CLC		
		ADC		$DF
		LSR		
		LSR		
		LSR		
		LSR		
		CMP		#$08
		BCC		LD6AC
		LDA		#$07
LD6AC:	STA		$84
		LDA		$CB
		SEC		
		SBC		#$10
		AND		#$60
		LSR		
		LSR		
		ADC		$84
		TAY		
		LDA		LDF7C,Y
		STA		$8B
		LDX		$D1
		DEX		
		STX		$D1
		STX		$CF
		LDX		$CB
		DEX		
		DEX		
		STX		$CB
		STX		$C9
		LDA		#$46
		STA		$8D
LD6D2:	JMP		LD773

LD6D5:	CPX		#$0B			;check if shovel is selected
		BNE		LD6F7			;jump if not

		;activate shovel
		LDA		$CF				;get Indy vertical position
		CMP		#$41			;check if low enough
		BCC		LD696			;exit otherwise
		lda		p1pl			;check for Indy overlapping dirt
		and		#1
		beq		LD696
		INC		$97
		BNE		LD696
		LDY		$96
		DEY		
		CPY		#$54
		BCS		LD6EF
		INY		
LD6EF:	STY		$96
		LDA		#$0A			;+10 bonus
		STA		$A7				;apply scoring bonus
		BNE		LD696

LD6F7:	CPX		#$10			;check if ankh is selected
		BNE		LD71E			;jump if not

		;activate ankh
		LDX		$81				;get current room
		CPX		#$00			;check if treasure room
		BEQ		LD696			;jump if so
		LDA		#$09			;
		STA		$A9
		STA		$81				;change room to mesa field
		JSR		LD878			;set up new room
		LDA		#$4C			;set Indy horizontal position
		STA		$C9
		STA		$CB
		LDA		#$46			;set Indy vertical position
		STA		$CF
		STA		$D1
		STA		$8D
		LDA		#$1D			;set playfield vertical scroll position
		STA		$DF
		BNE		LD777

LD71E:	LDA		SWCHA			;read joystick
		AND		#$0F			;mask to player 2
		CMP		#$0F			;check if any inputs
		BEQ		LD777			;skip if not
		CPX		#$0D
		BNE		LD747
		BIT		$8F
		BMI		LD777
		LDY		$A0
		BMI		LD777
		DEC		$A0
		ORA		#$80
		STA		$8F
		LDA		$CF
		ADC		#$04
		STA		$D1
		LDA		$C9
		ADC		#$04
		STA		$CB
		BNE		LD773
LD747:	CPX		#$0A
		BNE		LD777
		ORA		#$80
		STA		$8D
		LDY		#$04
		LDX		#$05
		ROR		
		BCS		LD758
		LDX		#$FA
LD758:	ROR
		BCS		LD75D
		LDX		#$0F
LD75D:	ROR
		BCS		LD762
		LDY		#$F7
LD762:	ROR
		BCS		LD767
		LDY		#$10
LD767:	TYA
		CLC
		ADC		$C9
		STA		$CB
		TXA
		CLC
		ADC		$CF
		STA		$D1
LD773:	LDA		#$0F
		STA		$A3
LD777:	BIT		$B4				;check if parachute is open
		BPL		LD783			;skip if not
		LDA		#$63			;parachute sprite
		STA		$D9				;set sprite
		LDA		#$0F			;tall parachute height
		BNE		LD792			;set Indy height
LD783:	LDA		SWCHA			;read joysticks
		AND		#$0F			;mask to P2
		CMP		#$0F			;check if any P2 inputs
		BNE		LD796			;skip if so
LD78C:	LDA		#$58			;idle Indy sprite
LD78E:	STA		$D9				;set Indy sprite
		LDA		#$0B			;standard Indy height
LD792:	STA		$DB				;set Indy height
		BNE		LD7B2

LD796:	LDA		#$03
		BIT		$8A
		BMI		LD79D
		LSR
LD79D:	AND		$82
		BNE		LD7B2
		LDA		#$0B
		CLC		
		ADC		$D9
		CMP		#$58
		BCC		LD78E
		LDA		#$02
		STA		$A3
		LDA		#$00
		BCS		LD78E
LD7B2:	LDX		$81
		CPX		#$09
		BEQ		LD7BC
		CPX		#$0A
		BNE		LD802
LD7BC:	LDA		$82
		BIT		$8A
		BPL		LD7C3
		LSR		
LD7C3:	LDY		$CF
		CPY		#$27
		BEQ		LD802
		LDX		$DF
		BCS		LD7E8
		BEQ		LD802
		INC		$CF
		INC		$D1
		AND		#$02
		BNE		LD802
		DEC		$DF
		INC		$CE
		INC		$D0
		INC		$D2
		INC		$CE
		INC		$D0
		INC		$D2
		JMP		LD802

LD7E8:	CPX		#$50
		BCS		LD802
		DEC		$CF
		DEC		$D1
		AND		#$02
		BNE		LD802
		INC		$DF
		DEC		$CE
		DEC		$D0
		DEC		$D2
		DEC		$CE
		DEC		$D0
		DEC		$D2
LD802:	LDA		$81
		ASL
		TAX
		LDA		LFC88+1,X
		PHA
		LDA		LFC88,X
		PHA
		RTS

LD80D:	LDA    $99
		BEQ    LD816
		JSR    LDD59
		LDA    #$00
LD816:	STA    $99

		;set up player 0 and missile 0 sizing
		LDX		$81
		lda		screen_player0_size,x
		sta		sizep0
		lda		LDB00,x
		lsr
		lsr
		lsr
		lsr
		tay
		lda		m0_mask_tab,y
		sta		m0_mask

		;set up missile 0 and ball sizing from CTRLPF value
		lda		$94
		lsr
		lsr
		lsr
		lsr
		tay
		lda		ball_size_lookup,y
		ora		screen_missile_size,x
		sta		sizem

		lda		#$08
		sta		m1_mask

		lda		ball_mask_tab,y
		sta		mb_mask

		;set priority
		lda		$94
		and		#$04
		sne:lda	#$01
		sta		prior

		LDA		LDBA0,X
		sta		color4
		LDA		LDBAE,X
		sta		color0
		LDA		LDBC3,X
		STA		pcolr0
		LDA		LDBBC,X
		STA		pcolr1
		CPX		#$0B
		BCC		LD84B
		LDA		#$20
		STA		$D4
		LDX		#$04
LD841:	LDY		$E5,X
		LDA		LDB00,Y
		STA		$EE,X
		DEX
		BPL		LD841
LD84B:	JMP		LD006

screen_player0_size:
		dta		0,0,1,0,3,0,0,0,0,0,0,0,0,1

screen_missile_size:
		dta		0,0,3,1,1,3,0,0,0,0,0,0,0,0

screen_player_offset:
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+1
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+1
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+0
		dta		HPOS_PLAYER_OFFSET+1

m0_mask_tab:
		dta		$02,$02,$02,$03

ball_size_lookup:
		dta		$00,$10,$30,$30

ball_mask_tab:
		dta		$20,$20,$20,$30

;==========================================================================
LD85B:	LDX		#$00
		TXA
LD85E:	STA		$DF,X
		STA		$E0,X
		STA		$E1,X
		STA		$E2,X
		STA		$E3,X
		STA		$E4,X
		TXA
		BNE		LD873
		LDX		#$06
		LDA		#$14
		BNE		LD85E

LD873:	LDA		#$7C			;!! - relocation hazard
		STA		$D7
		RTS

;==========================================================================
LD84E:	LDA		#$4D
		STA		$C9
		LDA		#$48
		STA		$C8
		LDA		#$1F
		STA		$CF
		RTS

;==========================================================================
; New room setup
;
LD878:	LDA		$9A
		BPL		LD880
		ORA		#$40
		STA		$9A
LD880:	LDA		#$5C
		STA		$96
		LDX		#$00
		STX		$93				;nuke snake and tsetse flies
		STX		$B6
		STX		$8E
		STX		$90
		LDA		$95
		STX		$95
		JSR		LDD59
		ROL		$8A
		CLC		
		ROR		$8A
		LDX		$81
		lda		playfield_ptrs_hi,x
		beq		no_playfield
		sta		dlist1_pfaddr1+1
		sta		dlist1_pfaddr3+1
		sta		dlist2_pfaddr1+1
		tay
		lda		playfield_ptrs_lo,x
		sta		dlist1_pfaddr1
		sta		dlist1_pfaddr3
		sta		dlist2_pfaddr1
		clc
		adc		#10
		sta		dlist2_pfaddr2
		sta		dlist2_pfaddr3
		sta		dlist2_pfaddr4
		scc:iny
		sty		dlist2_pfaddr2+1
		sty		dlist2_pfaddr3+1
		sty		dlist2_pfaddr4+1

no_playfield:
		lda		screen_player_offset,x
		sta		hposp0_offset

		lda		#HPOS_PLAYER_OFFSET
		sta		hposp1_offset

		lda		#HPOS_MISSILE_OFFSET
		sta		hposm0_offset
		sta		hposm1_offset
		sta		hposbl_offset

		LDA		LDB92,X
		STA		$94
		CPX		#$0D
		BEQ		LD84E
		CPX		#$05
		BEQ		LD8B1
		CPX		#$0C
		BEQ		LD8B1
		LDA		#$00
		STA		$8B
LD8B1:	LDA		LDBEE,X
		STA		$DD
		LDA		LDBE1,X
		STA		$DE
		LDA		LDBC9,X
		STA		$DC
		LDA		LDBD4,X
		STA		$C8
		LDA		LDC0E,X
		STA		$CA
		LDA		LDC1B,X
		STA		$D0
		CPX		#$0B
		scc:jmp	LD85B
		ADC		LDC03,X
		STA		$E0

		jsr		initDisplay
		ldx		$81

		;load stream 1 data pointer
		LDA		LDC28,X
		STA		$E1
		LDA		LDC33,X
		STA		$E2

		;load stream 2 data pointer
		LDA		LDC3E,X
		STA		$E3
		LDA		LDC49,X
		STA		$E4

		LDA		#$55
		STA		$D2
		STA		$D1
		CPX		#$06
		BCS		LD93E
		LDA		#$00
		CPX		#$00
		BEQ		LD91B
		CPX		#$02
		BEQ		LD92A
		STA		$CE
LD902:	LDY		#$4F
		CPX		#$02
		BCC		LD918
		LDA		$AF,X
		ROR
		BCC		LD918
		LDY		LDF72,X
		CPX		#$03
		BNE		LD918
		LDA		#$FF
		STA		$D0
LD918:	STY		$DF
		RTS

LD91B:	LDA		$AF
		AND		#$78
		STA		$AF
		LDA		#$1A
		STA		$CE
		LDA		#$26
		STA		$DF
		RTS

LD92A:	LDA		$B1			;get flags
		AND		#$07		;
		LSR
		BNE		LD935		;jump if hole blasted?
		LDY		#$FF
		STY		$D0
LD935:	TAY
		LDA		LDF70,Y
		STA		$CE
		JMP		LD902

LD93E:	CPX		#$08
		BEQ		LD950
		CPX		#$06
		BNE		LD968
		LDY		#$00
		STY		$D8
		LDY		#$40
		STY		$E5
		BNE		LD958

LD950:	LDY		#$FF
		STY		$E5
		INY
		STY		$D8
		INY
LD958:	STY		$E6
		STY		$E7
		STY		$E8
		STY		$E9
		STY		$EA
		LDY		#$39
		STY		$D4
		STY		$D5
LD968:	CPX		#$09
		BNE		LD977
		LDY		$CF
		CPY		#$49
		BCC		LD977
		LDA		#$50
		STA		$DF
		RTS

LD977:	LDA		#$00
		STA		$DF
		RTS

;==========================================================================
; Room exit check
;
; Inputs:
;	X - room+test index (test*13+room); index=0/1/2/3 -> top/bottom/left/right
;	$86 - current position on normal axis to border
;	$87 - current position on parallel axis to border
;
LD97C:	LDY		LDE00,X			;get exit position
		CPY		$86				;check against current position
		BEQ		LD986			;continue if so
		CLC
		CLV
		RTS

LD986:	LDY		LDE34,X			;get next room
		BMI		LD99B
LD98B:	LDA		LDF04,X			;get entry vertical position
		BEQ		LD992
LD990:	STA		$CF
LD992:	LDA		LDF38,X			;get entry horizontal position
		BEQ		LD999
		STA		$C9
LD999:	SEC						;signal room change
		RTS

LD99B:	INY						;check if $FF
		BEQ		LD9F9			;block exit if so
		INY						;check if $FE
		BNE		LD9B6			;do range check on position if not
		LDY		LDE68,X			;get split position
		CPY		$87				;test against other axis
		BCC		LD9AF			;jump if left/up
		LDY		LDE9C,X			;load room exit 2
		BMI		LD9C7			;jump to handler checks if special exit
		BPL		LD98B			;jump to new room if plain exit

LD9AF:	LDY		LDED0,X			;load room exit 1
		BMI		LD9C7
		BPL		LD98B

LD9B6:	LDA		$87				;get position on other axis
		CMP		LDE68,X			;test against lo bound
		BCC		LD9F9			;block if above/left
		CMP		LDE9C,X			;test against hi bound
		BCS		LD9F9			;block if below/right
		LDY		LDED0,X			;get next room
		BPL		LD98B			;jump to new room if plain exit
LD9C7:	INY
		BMI		LD9D4

		;$FF - exit left from treasure room
		LDY		#$08			;guardian room
		BIT		$AF				;check if treasure taken
		BPL		LD98B			;skip if not
		LDA		#$41			;force vpos to be within jail
		BNE		LD990

LD9D4:	INY
		BNE		LD9E1

		;$FE - temple entrance from guardian room
		LDA		$B5				;check temple door position
		AND		#$0F
		BNE		LD9F9			;skip if it has started coming down
		LDY		#$06			;go to temple entrance
		BNE		LD98B

LD9E1:	INY
		BNE		LD9F0

		;$FD - temple entrance from entrance room
		LDA		$B5				;check temple door position
		AND		#$0F
		CMP		#$0A			;see if it's dropped too low
		BCS		LD9F9			;skip if so
		LDY		#$06			;go to temple entrance
		BNE		LD98B

LD9F0:	INY
		BNE		LD9FE

		;$FC - exit north from valley of death
		LDY		#$01			;exit to marketplace
		BIT		$8A				;check if in bog
		BMI		LD98B			;allow exit if so
LD9F9:	CLC						;block exit
		BIT		LD9FD			;!! - set V flag
LD9FD:	RTS

LD9FE:	INY
		BNE		LD9F9

		;$FB - exit to temple entrance from marketplace
		LDY		#$06			;exit to temple entrance
		LDA		#$0E			;staff of ra
		CMP		$C5				;check if current item
		BNE		LD9F9			;block exit if not
		BIT		INPT5			;check if button is down
		BMI		LD9F9			;block exit if not
		JMP		LD98B

;==========================================================================
LDA10:	LDY		$C4				;check if inventory has something
		BNE		LDA16			;jump if so
		CLC
		RTS

LDA16:	BCS		LDA40			;if carry set, lose active item
		TAY						;save item
		ASL						;x2
		ASL						;x4
		ASL						;x8 (item code -> offset)
		LDX		#$0A			;start with slot 5
LDA1E:	CMP		$B7,X			;check if item is in this slot
		BNE		LDA3A			;jump if no match
		CPX		$C3				;check if it's the current slot
		BEQ		LDA3A			;if so, skip it
		DEC		$C4				;decrement inventory count
		LDA		#$00			;empty
		STA		$B7,X			;clear the slot
		CPY		#$05
		BCC		LDA37
		TYA
		TAX
		JSR		LDD1B
		TXA
		TAY
LDA37:	JMP		LDAF7

LDA3A:	DEX						;prev slot
		DEX						; "
		BPL		LDA1E			;keep going if more slots
		CLC
		RTS

LDA40:	LDA		#$00
		LDX		$C3				;get inventory cursor position
		STA		$B7,X			;get item graphic
		LDX		$C5				;get active item
		CPX		#$07			;check if key
		BCC		LDA4F
		JSR		LDD1B			;clear item collected flag
LDA4F:	TXA
		TAY
		ASL
		TAX
		LDA		LDC77-1,X
		PHA
		LDA		LDC77-2,X
		PHA
		LDX		$81				;get current room
		RTS						;invoke drop handler

;==========================================================================
; Item drop handler - parachute
;
LDA5E:	LDA		#$3F			;clear parachute flags
		AND		$B4
		STA		$B4
LDA64:	JMP		LDAD8

;==========================================================================
; Item drop handler - ankh and hourglass
;
LDA67:	STX		$8D
		LDA		#$70
		STA		$D1
		BNE		LDA64

;==========================================================================
; Item drop handler - chai
;
LDA6F:	LDA		#$42			;check if flute is the currently selected item
		CMP		$91
		BNE		LDA86			;jump if not
		LDA		#$03			;black market
		STA		$81				;change room
		JSR		LD878			;set up new room
		LDA		#$15
		STA		$C9
		LDA		#$1C
		STA		$CF
		BNE		LDAD8

LDA86:	CPX		#$05			;check if current room is the falling room
		BNE		LDAD8			;jump if not
		LDA		#$05			;flying saucer mesa
		CMP		$8B				;check if we're falling from the flying saucer
		BNE		LDAD8			;jump if not
		STA		$AA				;+5 points for seeing the yar
		LDA		#$00
		STA		$CE				;set player 0 position to 0
		LDA		#$02			;set Yar flag
		ORA		$B4
		STA		$B4
		BNE		LDAD8

;==========================================================================
; Item drop handler - whip
;
LDA9E:	ROR		$B1				;clear bit 0 to put the whip back
		CLC						; "
		ROL		$B1				; "
		CPX		#$02			;check if this is the entrance room
		BNE		LDAAB			;skip if not
		LDA		#$4E
		STA		$DF
LDAAB:	BNE		LDAD8

;==========================================================================
; Item drop handler - shovel
;
LDAAD:	ROR		$B2
		CLC
		ROL		$B2
		CPX		#$03
		BNE		LDABE
		LDA		#$4F
		STA		$DF
		LDA		#$4B
		STA		$D0
LDABE:	BNE		LDAD8

;==========================================================================
; Item drop handler - bag of coins
;
LDAC0:	LDX		$81				;get current room
		CPX		#$03			;check if it's the black market
		BNE		LDAD1			;jump if not
		LDA		$C9				;get horizontal position
		CMP		#$3C			;check if to the left of raving lunatic
		BCS		LDAD1			;skip if not
		ROL		$B2				;set bribe flag
		SEC		
		ROR		$B2
LDAD1:	LDA		$91				;increment coin drop counter
		CLC		
		ADC		#$40
		STA		$91
LDAD8:	DEC		$C4				;decrement item count
		BNE		LDAE2			;jump if cursor should be moved elsewhere
		LDA		#$00
		STA		$C5
		BEQ		LDAF7

LDAE2:	LDX		$C3
LDAE4:	INX		
		INX		
		CPX		#$0B
		BCC		LDAEC
		LDX		#$00
LDAEC:	LDA		$B7,X			;check inventory slot
		BEQ		LDAE4			;keep going if inventory is empty
		STX		$C3
		LSR		
		LSR		
		LSR		
		STA		$C5
LDAF7:	LDA		#$0D
		STA		$A2
		SEC
		RTS

;==========================================================================
; Try to drop item
;
; Input:
;	A = item to drop
;
LDCE9:	LDX		$C4				;get inventory count
		CPX		#$06			;check if inventory is full
		BCC		LDCF1			;proceed with drop if not
		CLC						;failure
		RTS

LDCF1:	LDX		#$0A			;start with inventory slot 5
LDCF3:	LDY		$B7,X			;check if slot is empty
		BEQ		LDCFC			;jump if so
		DEX						;prev slot
		DEX						; "
		BPL		LDCF3			;jump if there are still slots
		BRK						;wtf
LDCFC:	TAY						;save item
		ASL						;x2
		ASL						;x4
		ASL						;x8
		STA		$B7,X			;store in item slot
		LDA		$C4				;check if inventory was empty
		BNE		LDD0A			;jump if not
		STX		$C3				;set cursor to new slot
		STY		$C5				;stash current item
LDD0A:	INC		$C4				;increment item count
		CPY		#$04			;check if we got parachute or flute
		BCC		LDD15
		TYA
		TAX
		JSR		LDD2F
LDD15:	LDA		#$0C
		STA		$A2
		SEC
		RTS

;==========================================================================
; Clear item collected flag
;
; Input:
;	X = item
;
LDD1B:	LDA		LDC64,X
		LSR
		TAY
		LDA		LDC5C,Y
		BCS		LDD2A
		AND		$C6
		STA		$C6
		RTS

LDD2A:	AND		$C7
		STA		$C7
		RTS

;==========================================================================
LDD2F:	LDA		LDC64,X
		LSR
		TAX
		LDA		LDC54,X
		BCS		LDD3E
		ORA		$C6
		STA		$C6
		RTS

;==========================================================================
LDD3E:	ORA		$C7
		STA		$C7
		RTS

;==========================================================================
LDD43:	LDA		LDC64,X
		LSR
		TAY
		LDA		LDC54,Y			;get single bit mask
		BCS		LDD53
		AND		$C6
		BEQ		LDD52
		SEC
LDD52:	RTS

LDD53:	AND		$C7
		BNE		LDD52
		CLC
		RTS

;==========================================================================
LDD59:	AND		#$1F
		TAX
		LDA		$98
		CPX		#$0C
		BCS		LDD67
		ADC		LDFE5,X
		STA		$98
LDD67:	RTS


;==========================================================================
START:
LDD68:	SEI
		CLD
		LDX    #$FF
		TXS
		INX
		TXA
LDD6F:	STA    0,X
		DEX
		BNE    LDD6F
		DEX
		STX    $9E
	
		lda		#$ff
		sta		teardown_disp

		;initialize logo graphics
		LDA    #$7B			;!! - relocation hazard
		STA    $B8
		STA    $BA
		STA    $BC
		STA    $BE
		STA    $C0
		STA    $C2
		LDA    #$60
		STA    $B7
		LDA    #$48
		STA    $B9
		LDA    #$D8
		STA    $BD
		LDA    #$08
		STA    $BB
		LDA    #$E0
		STA    $BF
		LDA    #$0D			;well of souls
		STA    $81			;set initial room
		LSR
		STA    $A0			;set 6 bullets
		JSR    LD878
		JMP    LD3DD
LDDA6:	LDA    #$20			;put coins in slot 1
		STA    $B7
		LSR
		LSR
		LSR
		STA    $C5

		INC    $C4
		LDA    #$00
		STA    $B9
		STA    $BB
		STA    $BD
		STA    $BF
		LDA    #$64
		STA    $9E

.if ITEM_CHEAT
		INC    $C4
		INC    $C4
		INC    $C4
		INC    $C4
		INC    $C4
		lda		#$50		;bullwhip
		sta		$b9
		lda		#$80		;ankh
		sta		$bb
		lda		#$88		;chai
;		lda		#$58		;shovel
;		lda		#$90		;hourglass
;		lda		#$38		;key
		sta		$bd
		lda		#$18		;parachute
		sta		$bf
;		lda		#$88		;chai
;		lda		#$28		;grenade
		lda		#$70		;staff
		sta		$c1
.endif
	
		LDA		#<LFA58
		STA		$D9
		LDA		#>LFA58
		STA		$DA

		LDA		#$4C
		STA		$C9
		LDA		#$0F
		STA		$CF
		LDA		#STARTING_ROOM
		STA		$81
		lda		#2
		STA		$9F
		JSR		LD878

		;check if the C button is 'released' -- this means that a Genesis
		;controller is connected and we should enable two-button mode
		lda		c_button
		eor		#$80
		sta		use_c_button
		JMP		LD80D

;==========================================================================
; Compute score
;
LDDDB:	LDA		$9E
		SEC
		SBC		$A7			;+10 for digging with shovel
		SBC		$A8			;+3 for using parachute
		SBC		$A9			;+9 for using ankh outside of treasure room
		SBC		$AA			;+5 for seeing yar
		SBC		$9F			;+1 for each extra life, +2 max
		SBC		$AB			;+14 for lighting up correct mesa in map room
		SBC		$AD			;+3 for entering mesa
		SBC		$AE			;(unused)
		CLC
		ADC		$A5			;-2 score for blasting hole in entrance room
		ADC		$A6			;-13 score for using secret exit in guardian room
		ADC		$AC			;-4 score for shooting a thief
		STA		$9E
		RTS

;==========================================================================
; Move object routine
;
; Input:
;	A = joystick pattern
;
LDFC0:	ROR
		BCS		LDFC5
		DEC		$CE,X
LDFC5:	ROR
		BCS		LDFCA
		INC		$CE,X
LDFCA:	ROR
		BCS		LDFCF
		DEC		$C8,X
LDFCF:	ROR
		BCS		LDFD4
		INC		$C8,X
LDFD4:	RTS

;==========================================================================
.proc drawMissileFast
		lda		m0_pos,x
		cmp		#80
		bcs		no_missile
		tay

		lda		m0_mask,x
		sta		missile_pat

		lda		#80
		sec
		sbc		m0_pos,x
		cmp		m0_len,x
		scc:lda	m0_len,x
		tax
		beq		no_missile
		lda		missile_pat
draw_loop:
		sta		missile_dat+18,y
		iny
		dex
		bne		draw_loop
no_missile:
		rts
.endp

;==========================================================================
.proc drawMissile
		lda		m0_mask,x
		sta		missile_pat

		lda		m0_pos,x
		cmp		#80
		bcs		no_missile
		tay

		lda		#80
		sec
		sbc		m0_pos,x
		cmp		m0_len,x
		scc:lda	m0_len,x
		tax
		beq		no_missile
draw_loop:
		lda		missile_dat+18,y
		ora		missile_pat
		sta		missile_dat+18,y
		iny
		dex
		bne		draw_loop
no_missile:
		rts
.endp

;==========================================================================
.proc eraseMissile
		ldy		m0_pos,x
		lda		m0_len,x
		tax
		beq		no_missile
		lda		#0
		cpx		#64
		bcc		small_only
		ldy		#31
fast_erase_loop:
		sta		missile_dat,y
		sta		missile_dat+32,y
		sta		missile_dat+64,y
		sta		missile_dat+96,y
		dey
		bpl		fast_erase_loop
		rts

small_only:
erase_loop:
		sta		missile_dat+18,y
		iny
		dex
		bne		erase_loop
no_missile:
		rts
.endp

;==========================================================================
.proc drawIndy
		;The spider room has a bug where it allows Indy to go above the
		;ceiling, up to $F9. This sprite is clipped on the VCS because
		;Indy is drawn during the display kernel; for us, we instead draw
		;higher up and then re-clear the clipped portions. We don't need
		;to do this on the bottom since we turn off the players at the
		;end of the display kernel.
		lda		$cf
		clc
		adc		#18
		tay
		cmp		#80+18
		bcs		no_player
		adc		$db
		cmp		#80+18
		scc:lda	#80+18
		sta		missile_pat

		tya
		tax
		cpx		missile_pat
		bcs		no_player

		ldy		#0
draw_loop:
		lda		($d9),y
		iny
		sta		player1_dat,x
		inx
		cpx		missile_pat
		bne		draw_loop

		;check if we need to reflect the player; this is just based on
		;whether the player is holding right
		lda		swcha
		and		#8
		beq		no_reflect

		ldx		$cf
reflect_loop:
		ldy		player1_dat,x
		lda		revbits_tab,y
		sta		player1_dat,x
		inx
		cpx		missile_pat
		bne		reflect_loop
no_reflect:

		;clear above in case Indy was clipped on the top
		lda		#0
		:7 sta	player1_dat+17-#

no_player:
		rts
.endp

;==========================================================================
.proc drawIndyHi
		lda		$cf
		cmp		#80
		bcs		no_player
		adc		$db
		cmp		#80
		scc:lda	#80
		sta		missile_pat

		lda		$cf
		cmp		missile_pat
		bcs		no_player
		asl
		tax

		asl		missile_pat

		ldy		#0
draw_loop:
		lda		($d9),y
		iny
		sta		player1hi_dat+19*2,x
		sta		player1hi_dat+19*2+1,x
		inx
		inx
		cpx		missile_pat
		bne		draw_loop

		;check if we need to reflect the player; this is just based on
		;whether the player is holding right
		lda		swcha
		and		#8
		beq		no_reflect

		lda		$cf
		asl
		tax
reflect_loop:
		ldy		player1hi_dat+19*2,x
		lda		revbits_tab,y
		sta		player1hi_dat+19*2,x
		sta		player1hi_dat+19*2+1,x
		inx
		inx
		cpx		missile_pat
		bne		reflect_loop

no_reflect:
no_player:
		rts
.endp

;==========================================================================
.proc eraseIndy
		lda		$cf
		clc
		adc		#18		;see drawIndy for the reason for this adjustment
		tay
		lda		#0

		;Normal Indy is 11 high, but with parachute is 15.
		ldx		#5
clear_loop:
		sta		player1_dat,y
		sta		player1_dat+5,y
		sta		player1_dat+10,y
		iny
		dex
		bne		clear_loop
		rts
.endp

;==========================================================================
.proc eraseIndyHi
		lda		$cf
		asl
		tay
		lda		#0

		;Normal Indy is 11 high, but with parachute is 15.
		ldx		#10
clear_loop:
		sta		player1hi_dat+19*2,y
		sta		player1hi_dat+19*2+10,y
		sta		player1hi_dat+19*2+20,y
		iny
		dex
		bne		clear_loop
		rts
.endp

;==========================================================================
.proc initDisplay
		ldx		$81
		ldy		LF9EE,x
		lda		display_setup_tab+1,y
		pha
		lda		display_setup_tab,y
		pha
		rts

display_setup_tab:
		dta		a(initDisplay_0-1)
		dta		a(initDisplay_1-1)
		dta		a(initDisplay_2-1)
		dta		a(initDisplay_3-1)
.endp

;==========================================================================
.proc setupDisplay
		sty		teardown_disp
		ldx		LF9EE,y
		lda		display_setup_tab+1,x
		pha
		lda		display_setup_tab,x
		pha
		rts

display_setup_tab:
		dta		a(setupDisplay_0-1)
		dta		a(setupDisplay_1-1)
		dta		a(setupDisplay_2-1)
		dta		a(setupDisplay_3-1)
.endp

initDisplay_1:
initDisplay_2:
initDisplay_3:
teardownDisplay_3:
		rts

;==========================================================================
.proc teardownDisplay
		ldy		teardown_disp
		bmi		no_teardown
		lda		#$ff
		sta		teardown_disp

		ldx		LF9EE,y
		lda		display_tab+1,x
		pha
		lda		display_tab,x
		pha
no_teardown:
		rts

display_tab:
		dta		a(teardownDisplay_0-1)
		dta		a(teardownDisplay_1-1)
		dta		a(teardownDisplay_2-1)
		dta		a(teardownDisplay_3-1)
.endp

;==========================================================================
.proc setupDisplay_1
		mva		#0 vscrol

		;Display kernel 1 wrote GRP0/1 at the beginning, so the players were
		;always synced.
		mva		#$3f vdelay

		lda		$d0
		sta		m0_pos
		lda		$d1
		sta		m1_pos
		lda		#1
		sta		m0_len
		sta		m1_len

		ldx		#0
		jsr		drawMissile
		ldx		#1
		jsr		drawMissile

		;draw ball
		ldx		$d2
		cpx		#80
		bcs		invisible_ball
		ldy		#0
ball_loop:
		lda		($d6),y
		and		#2
		beq		skip_ball
		lda		missile_dat+18,x
		ora		#$20
		sta		missile_dat+18,x
skip_ball:
		inx
		iny
		cpy		#8
		bne		ball_loop
invisible_ball:

		;setup ball hmove
bl_pos = $01
		lda		$cc
		clc
		adc		#HPOS_MISSILE_OFFSET
		sta		bl_pos
		ldy		#0
		ldx		$d2
hmbl_loop:
		lda		bl_pos
		sta		m2pos_even_dat,x

		lda		($d6),y
		lsr
		lsr
		lsr
		lsr
		cmp		#8
		scc:ora	#$f0
		eor		#$ff
		sec
		pha
		adc		bl_pos
		sta		bl_pos
		sta		m2pos_odd_dat,x+
		pla
		sec
		adc		bl_pos
		sta		bl_pos

		iny
		cpy		#8
		bne		hmbl_loop

		;set up scrolling playfield ($00-50)
		lda		#0
		sta		scroll_temp
		lda		$df
		clc
		adc		#1
		asl					;x2
		asl					;x4
		rol		scroll_temp

		sec
		adc		$df
		scc:inc	scroll_temp
		asl
		rol		scroll_temp

		ldx		$81
		adc		playfield_ptrs_lo,x
		sta		dlist1_pfaddr2
		lda		scroll_temp
		adc		playfield_ptrs_hi,x
		sta		dlist1_pfaddr2+1

		;draw player 0
		lda		#0
		sta		p0_len
		lda		$ce
		tax
		cmp		#80
		bcs		p0_skip
		sta		p0_pos
		lda		#80
		sec
		sbc		p0_pos
		cmp		$dc
		scc:lda	$dc
		sta		p0_len
		ldy		#0
		cpy		p0_len
		beq		p0_skip
p0_draw_loop:
		lda		($dd),y
		sta		player0_dat+18,x+
		iny
		cpy		p0_len
		bne		p0_draw_loop

		;check if we need to reflect p0
p0_end = $01
		lda		reflect_p0
		beq		p0_no_reflect
		ldx		p0_pos
		txa
		clc
		adc		p0_len
		sta		p0_end
		ldy		$ce
p0_reflect_loop:
		ldx		player0_dat+18,y
		lda		revbits_tab,x
		sta		player0_dat+18,y
		iny
		cpy		p0_end
		bne		p0_reflect_loop
p0_no_reflect:

p0_skip:

		jsr		drawIndy

		mva		#$40 hposp2
		mva		#$a0 hposp3

		;draw dynamic playfield
		lda		#3
		sta		sizep2
		sta		sizep3

		;compute starting offset as max of clip and starting bounds
		lda		$e0
		cmp		$d4
		scs:lda	$d4

		sta		dynpf_start
		sta		dynpf_stop

		cmp		#$50
		bcs		dynpf_done

		tay
dynpf_loop:
		tya
		sec
		sbc		$d4
		lsr
		lsr
		tax
		cpx		$d5
		bcs		dynpf_done
		lda		$e5,x
		sta		player2_dat+18,y
		tax
		lda		revbits_tab,x
		sta		player3_dat+18,y
		iny
		cpy		#$50
		bcc		dynpf_loop
dynpf_done:
		sty		dynpf_stop

dynpf_clipped:

		ldx		#$2e	;dmactl
		ldy		#$03	;gractl
		rts

expand_tab_1:
		dta		$00,$03,$0c,$0f
		dta		$30,$33,$3c,$3f
		dta		$c0,$c3,$cc,$cf
		dta		$f0,$f3,$fc,$ff
.endp

;==========================================================================
.proc teardownDisplay_1
		ldx		#0
		jsr		eraseMissile
		ldx		#1
		jsr		eraseMissile

		;erase ball
		ldy		$d2
		cpy		#80
		bcs		skip_ball
		lda		#0
		:8 sta missile_dat+18+#,y
skip_ball:

		;erase player 0
		ldy		p0_len
		beq		no_p0
		ldx		p0_pos
		lda		#0
p0_erase:
		sta		player0_dat+18,x+
		dey
		bne		p0_erase
no_p0:
		jsr		eraseIndy

		;erase players 2 and 3
		ldy		dynpf_start
		cmp		dynpf_stop
		bcs		dynpf_noclear
		lda		#0
dynpf_clearloop:
		sta		player2_dat+18,y
		sta		player3_dat+18,y
		iny
		cpy		dynpf_stop
		bcc		dynpf_clearloop

dynpf_noclear:

		lda		#0
		sta		hposp2
		sta		hposp3
		rts
.endp

;==========================================================================
; Display kernel 1
;
; Used by:
;	Room 6 (temple entrance)
;	Room 7 (spider room)
;	Room 8 (guardian room)
;	Room 9 (mesa field)
;	Room 10 (valley of death)
;
; $CE - player 0 vertical position
; $CF - player 1 vertical position
; $D2 - ball vertical position (16 scans high)
; $D4 - dynamic playfield start
; $D5 - dynamic playfield height
; $D8 - dynamic playfield index (PF1/PF2)
; $D9 - player 1 graphics pointer
; $DB - player 1 height
; $DC - player 0 height
; $DD - player 0 graphics pointer
; $DF - playfield vertical scroll offset
; $E0 - dynamic playfield top clip
;
.proc LF003_kernel
		ldx		#$ff
loop:
		lda		m2pos_odd_dat,x
		inx
		sta		wsync
		sta		hposm2
		lda		m2pos_even_dat,x
		sta		wsync
		sta		hposm2
		cpx		#$4f
		bcc		loop

		JMP		LF1EA
.endp

;==========================================================================
.proc initDisplay_0
		;draw player 0
p0_pos = $02
p0_hm = $03

		lda		#0
		sta		p0_hm
		lda		$c8
		clc
		adc		hposp0_offset
		sta		p0_pos
		ldx		#0
		ldy		#0
p0pos_loop:
		lda		p0_pos
		sec
		sbc		p0_hm
		sta		p0pos_even_dat,x
		sec
		sbc		p0_hm
		sta		p0pos_odd_dat,x+
		sta		p0_pos

		lda		($dd),y				;read display list entry
		bpl		p0pos_nothmp0
		lsr
		bcc		p0pos_nothmp0
		lsr
		lsr
		and		#$0f
		cmp		#8
		scc:ora	#$f0
		sta		p0_hm
p0pos_nothmp0:

		iny
		cpy		#80
		bne		p0pos_loop
		rts
.endp

;==========================================================================
.proc setupDisplay_0
		mva		#1 vscrol

		;The P1 graphics write happens pretty late in the original kernel,
		;causing the graphics to be shifted down on the left side. For now,
		;we just ignore the one-scan shift in the left basket in the
		;marketplace.
		mva		#$bc vdelay

		;The original code contains a hack at $F865 to turn the ball on
		;prior to entering the display kernel for room 4 (map room), since
		;the kernel can't turn it on soon enough. We need to replicate that
		;here since it covers a one-scan gap on the bar on the right side.
		ldx		$81
		cpx		#4
		bne		skip_room_4_hack

		lda		#$30
		sta		missile_dat+17

skip_room_4_hack:

		;draw ball at [$D2, $DC).
		lda		$dc
		cmp		#80
		scc:lda	#80
		sec
		sbc		$d2
		scs:lda	#0
		sta		mb_len
		lda		$d2
		sta		mb_pos
		ldx		#2
		jsr		drawMissileFast

		;draw missile 0 from ($D0) to ($E0)
		lda		$e0
		sec
		sbc		$d0
		scs:lda	#0
		sta		m0_len
		lda		$d0
		sta		m0_pos
		ldx		#0
		jsr		drawMissile

		;draw missile 1 as two scanline dot at ($D1)
		lda		$d1
		sta		m1_pos
		lda		#1
		sta		m1_len
		ldx		#1
		jsr		drawMissile

		;double up missile 1 on player 2, so we can kill the snake with it (can't
		;detect missile-missile collision)
		lda		#$80
		ldx		$d1
		sta		player2_dat+18,x

		;fix color/size of P2
		lda		#0
		sta		sizep2
		lda		$cb
		clc
		adc		#HPOS_MISSILE_OFFSET
		sta		hposp2

		;draw player 1 (Indy)
		jsr		drawIndy

		;draw player 0
p0_end = $01
		lda		$df					;get end position
		cmp		#80					;clip to 80
		scc:lda	#80
		sta		p0_end
		lda		$ce					;get start position
		cmp		p0_end				;check against end position
		bcs		p0_skip				;skip if nothing to draw
		tay
p0_draw:
		lda		($dd),y				;read display list entry
		bmi		p0_command			;jump if stream write command
		sta		player0_dat+18,y
		iny
		cpy		p0_end
		bne		p0_draw
		beq		p0_done

p0_command:
		lda		player0_dat+17,y
		sta		player0_dat+18,y
		iny
		cpy		p0_end
		bne		p0_draw
p0_done:
		cpy		#80
		bcs		p0_skip
		;fill to end (required for map room)
p0_fill:
		lda		player0_dat+17,y
		sta		player0_dat+18,y
		iny
		cpy		#80
		bcc		p0_fill

p0_skip:

		;draw ball hpos
		lda		$d5
		cmp		#80
		bcs		no_hmbl
		tax

		;the snake starts at an odd position that we need to correct since GTIA
		;doesn't wrap sprites like TIA
		lda		$cc
		cmp		#160
		scc:sbc	#204
		clc
		adc		hposp0_offset+4
		ldy		#0
hmbl_loop1:
		sta		m2pos_even_dat,x
		sec
		sbc		($d6),y
		sta		m2pos_odd_dat,x
		sec
		sbc		($d6),y
		inx
		iny
		cpy		#8
		bne		hmbl_loop1
		pha
		mva		$d8 $d6
		pla
hmbl_loop2:
		sta		m2pos_even_dat,x
		sec
		sbc		($d6),y
		sta		m2pos_odd_dat,x
		sec
		sbc		($d6),y
		inx
		iny
		cpy		#16
		bne		hmbl_loop2
		sta		m2pos_even_dat,x
		sta		m2pos_odd_dat,x
		jmp		post_hmbl

no_hmbl:
		lda		$cc
		clc
		adc		hposp0_offset+4
		ldx		#39
fill_hmbl:
		sta		m2pos_even_dat,x
		sta		m2pos_even_dat+40,x
		sta		m2pos_odd_dat,x
		sta		m2pos_odd_dat+40,x
		dex
		bpl		fill_hmbl
post_hmbl:

		ldx		#$2e				;dmactl
		ldy		#$03				;gractl
		rts
.endp

;==========================================================================
.proc teardownDisplay_0
		ldx		#0
		stx		missile_dat+17		;undo room 4 ball hack
		jsr		eraseMissile
		ldx		#1
		jsr		eraseMissile
		ldx		#2
		jsr		eraseMissile
		jsr		eraseIndy

		;erase player-based missile 1
		lda		#0
		ldx		$d1
		sta		player2_dat+18,x

		;erase player 0
		ldx		#19
		lda		#0
p0_clear:
		sta		player0_dat+18,x
		sta		player0_dat+18+20,x
		sta		player0_dat+18+40,x
		sta		player0_dat+18+60,x
		dex
		bpl		p0_clear
		rts
.endp

;==========================================================================
; Display kernel 0
;
; Draws missile 0 at [$D0, $E0).
; Draws missile 1 at ($D1), vertically.
; Draws ball at [$D2, $DC) using HMOVE info from ($D6).
; $D5 
; Reads stream at $DD to load player 0 and change hmove/color.
;

LF09C:	lsr
		bcs		write_hmp0
		asl
		asl
		sta		colpm0
write_hmp0:

LF0A4:	INC		$80
LF0B5_kernel:
		ldy		$80
		lda		m2pos_even_dat,y
		ldx		p0pos_even_dat,y
		STA		WSYNC
		sta		hposm2
		stx		hposp0
		lda		m2pos_odd_dat,y
		ldx		p0pos_odd_dat,y
		LDY		$80
		STA		WSYNC
		sta		hposm2
		stx		hposp0

		LDA		($DD),Y			;read display list entry
		BMI		LF09C			;jump if stream write command
		cpy		#$4F
		BCC		LF0A4

		JMP		LF1EA

;==========================================================================
; Display kernel 2 (inside mesa / thief room)
;
;	$D0 - missile 0 vertical position
;	$D1 - missile 1 vertical position
;	$D2 - ball vertical position
;	$DC - height of player 0 sprites
;	($DD) - 16 byte graphics / color table
;
; Player 0 uses single-line resolution for this one, so we have to double
; up Indy and the missiles.
;
.proc setupDisplay_2
		mva		#0 vscrol
		sta		vdelay

		lda		$d0
		asl
		tay
		lda		#$01
		sta		missilehi_dat+37,y
		sta		missilehi_dat+37+1,y

		lda		$d1
		asl
		tay
		lda		#$04
		ora		missilehi_dat+37,y
		sta		missilehi_dat+37,y
		lda		#$04
		ora		missilehi_dat+38,y
		sta		missilehi_dat+38,y

		lda		$d2
		asl
		tay
		lda		#$10
		ora		missilehi_dat+37,y
		sta		missilehi_dat+37,y
		lda		#$10
		ora		missilehi_dat+38,y
		sta		missilehi_dat+38,y

		jsr		drawIndyHi

		;draw player 0
p0_index = $01
p0_refcount = $02

		lda		#4
		sta		p0_index

p0_draw_loop:
		ldy		p0_index
		lda		$00DF,y
		sta		$86

		;set up animation frame
		bpl		use_thief
		lda		$96
		jmp		set_frame
use_thief:
		and		#$08			;check if reflect bit is set
		seq:lda	#$03			;reverse frame order for backwards movement
		eor		$00E5,y			;load animation frame
		and		#$03			;mask to animation frame
		tax		
		lda		LFC40,x			;load animation frame low pointer
set_frame:
		sta		$DD

		;plot an image
		ldx		p0_pos_tab,y
		ldy		#0
p0plot_loop:
		lda		($DD),Y
		sta		player0hi_dat+18,x+
		iny		
		lda		($DD),Y
		sta		player0hi_dat+18,x+
		iny
		cpy		#$10
		bne		p0plot_loop

		;check if we should reflect
		lda		$86
		and		#8
		beq		no_reflect

		ldy		p0_index
		ldx		p0_pos_tab,y
		lda		#15
		sta		p0_refcount
reflect_loop:
		ldy		player0hi_dat+18,x
		lda		revbits_tab,y
		sta		player0hi_dat+18,x+
		dec		p0_refcount
		bne		reflect_loop
no_reflect:

		dec		p0_index
		bpl		p0_draw_loop

		ldx		#$3e			;dmactl
		ldy		#$03			;gractl
		rts

p0_pos_tab:
		:5 dta	$22+$20*#
.endp

.proc teardownDisplay_2
		ldx		#2
mclear_loop:
		lda		$d0,x
		asl
		tay
		lda		#0
		sta		missilehi_dat+37,y
		sta		missilehi_dat+38,y
		dex
		bpl		mclear_loop

		jsr		eraseIndyHi
		rts
.endp


LF115:	STA		WSYNC
		INX		
		LDA		$85
		STA		COLUP0
LF10B:	INX		
		CPX		#$A0
		BCC		LF140
		JMP		LF1EA

LF140_kernel:
LF140:
		STA		WSYNC
		BIT		$D4
		BPL		LF157
		LSR		$D4

		;check if the sprite is double-wide and apply 1cc adjustment if so
		lda		$86
		lsr

		lda		$88
		adc		#HPOS_PLAYER_OFFSET
		sta		hposp0

		BMI		LF115
LF157:	BVC		LF177
		TXA		
		AND		#$0F
		TAY		
		LDA		($D6),Y
		STA		COLUP0
		INY		
		LDA		($D6),Y
		STA		$85
		CPY		$DC
		BCC		LF115
LF1A2:	LSR		$D4
		JMP		LF115

LF177:	LDA		#$20
		BIT		$D4
		BEQ		LF1A7
		TXA		
		LSR		
		LSR		
		LSR		
		LSR		
		LSR		
		BCS		LF115
		TAY		
		STY		$87
		LDA		$00DF,Y
		STA		sizep0
		STA		$86
		BPL		LF1A2
		LDA		#$65
		STA		$D6
		LDA		#$00
		STA		$D4
		JMP		LF115

LF1A7:	LSR		
		BIT		$D4
		BEQ		LF1CE
		LDA		#$44
		STA		$D6
		LDA		#$0F
		STA		$DC
		LSR		$D4
		JMP		LF115

LF1CE:	TXA		
		AND		#$1F
		CMP		#$0C
		BEQ		LF1D8
		JMP		LF115

LF1D8:	LDY		$87
		LDA		$00E5,Y
		STA		$88
		LDA		#$80
		STA		$D4
		JMP		LF115

;==========================================================================
; End display kernel
;
LF1EA:	;turn off P/M DMA, since we'll be forcibly killing sprites soon
		lda		#$22
		sta		dmactl
		lda		#0
		sta		gractl

		;wait until just before the start of the bottom border
		STA		WSYNC

		;nuke all sprites
		sta		grafp0			;~105-109
		sta		grafp1			;~110-113
		sta		grafm			;~0,2-4
		sta		grafp2			;5-8
		sta		grafp3			;9-12

		;reset p0 reflect flag (will be updated by valley update if needed)
		sta		reflect_p0

		;wait until end of bottom border 1/3
		STA		WSYNC

		;advance time and temple door position
		LDA		#$3F			;check if 1024 vblanks have passed (~17 minutes)
		AND		$82
		BNE		LF26D
		LDA		#$3F
		AND		$83
		BNE		LF26D
		LDA		$B5				;load temple door position
		AND		#$0F			;check if it's started coming down
		BEQ		LF26D			;skip if not
		CMP		#$0F			;check if it's all the way down
		BEQ		LF26D			;skip if so
		INC		$B5				;bring down temple door by a tick
LF26D:	

		;wait until end of bottom border 2/3
		STA		WSYNC

		;clear inventory cursor
		lda		#0
		:6 sta		playfield_cursor+7+#

		;draw inventory cursor
		lda		$c3
		lsr
		tax
		lda		#$08
		ldy		$c4				;check if items
		beq		skip_cursor
		sta		playfield_cursor+7,x
skip_cursor:

		;wait until end of bottom border 3/3
		lda		#$20
		ldx		#0
		STA		WSYNC

		;kill the playfield -- note that one of the display lists will still have a
		;remaining 4th scanline which we are killing here
		sta		dmactl			;5-8

		;reset background color
		stx		colbk

		;begin vertical blank processing -- after this point, we let the DLI and VBI handlers
		;take over
		LDX		#$FF
		TXS

		jsr		teardownDisplay

		;update audio
		LDX		#$01
LF2E8:	LDA		$A2,X
		STA		_AUDC0,X
		STA		AUDV0,X
		BMI		LF2FB			;jump if we should be playing music
		LDY		#$00
		STY		$A2,X
LF2F4:	STA		_AUDF0,X
		DEX
		BPL		LF2E8
		BMI		LF320

LF2FB:	CMP		#$9C
		BNE		LF314
		LDA		#$0F
		AND		$82
		BNE		LF30D
		DEC		$A4
		BPL		LF30D
		LDA		#$17
		STA		$A4
LF30D:	LDY		$A4
		LDA		LFBE8,Y			;get next note for Indy theme
		BNE		LF2F4
LF314:	LDA		$82
		LSR
		LSR
		LSR
		LSR
		TAY
		LDA		LFAEE,Y
		BNE		LF2F4
LF320:	LDA		$C5				;get current item
		CMP		#$0F			;check if timepiece
		BEQ		LF330			;jump if so
		CMP		#$02			;check if flute
		BNE		LF344			;jump if not
		LDA		#$84
		STA		$A3
		BNE		LF348
LF330:	BIT		INPT5			;check P2 button
		BPL		LF338			;jump if depressed
		LDA		#$78
		BNE		LF340

LF338:	LDA		$83
		AND		#$E0
		LSR
		LSR
		ADC		#$98
LF340:	LDX		$C3				;get inventory index
		STA		$B7,X			;set timepiece sprite
LF344:	LDA		#$00
		STA		$A3
LF348:	BIT		$93				;check if tsetse flies are active
		BPL		LF371			;jump if not
		LDA		$82
		AND		#$07
		CMP		#$05
		BCC		LF365
		LDX		#$04
		LDY		#$01
		BIT		$9D
		BMI		LF360
		BIT		$A1
		BPL		LF362
LF360:	LDY		#$03
LF362:	JSR		LF8B3
LF365:	LDA		$82
		AND		#$06
		ASL
		ASL
		STA		$D6
		LDA		#$7D			;!! - relocation hazard
		STA		$D7
LF371:	LDX		#$02
LF373:	JSR		LFEF4
		INX
		CPX		#$05
		BCC		LF373
		BIT		$9D
		BPL		LF3BF
		LDA		$82
		BVS		LF39D
		AND		#$0F
		BNE		LF3C5
		LDX		$DB				;get Indy sprite height
		DEX						;remove scanline
		STX		$A3
		CPX		#$03
		BCC		LF398
		LDA		#$8F
		STA		$D1
		STX		$DB				;update Indy height
		BCS		LF3C5
LF398:	STA		$82
		SEC
		ROR		$9D
LF39D:	CMP		#$3C
		BCC		LF3A9
		BNE		LF3A5
		STA		$A3
LF3A5:	LDY		#$00
		STY		$DB
LF3A9:	CMP		#$78
		BCC		LF3C5
		LDA		#$0B
		STA		$DB
		STA		$A3
		STA		$9D
		DEC		$9F
		BPL		LF3C5
		LDA		#$FF
		STA		$9D
		BNE		LF3C5
LF3BF:	LDA		$81
		CMP		#$0D
		BNE		LF3D0
LF3C5:	JMP		LD3D8

LF3D0:	BIT		$8D				;check flags
		BVS		LF437			;skip if grappling hook is active
		BIT		$B4				;check parachute
		BMI		LF437			;skip if parachute open
		BIT		$9A				;check if grenade active
		BMI		LF437			;skip if grenade active
		LDA		#$07			;get current frame
		AND		$82				;mask to low 3 bits
		BNE		LF437			;only allow cursor movement every 8th frame
		LDA		$C4				;check inventory item count
		AND		#$06			;check if >=2 items
		BEQ		LF437			;block cursor movement if <2 items
		LDX		$C3				;get cursor position
		LDA		$B7,X			;check inventory
		CMP		#$98			;check if current item is an active timepiece
		BCC		LF3F2			;skip if not
		LDA		#$78			;replace with normal timepiece
LF3F2:	BIT		SWCHA			;check joysticks
		BMI		LF407			;jump if player 1 right not active
		STA		$B7,X			;reset timepiece
LF3F9:	INX						;next slot
		INX						; "
		CPX		#$0B			;check if past end
		BCC		LF401			;jump if not
		LDX		#$00			;switch to slot 0
LF401:	LDY		$B7,X			;check if slot empty
		BEQ		LF3F9			;keep moving if so
		BNE		LF415
LF407:	BVS		LF437			;jump if player 1 left not active
		STA		$B7,X			;reset timepiece
LF40B:	DEX						;prev slot
		DEX						; "
		BPL		LF411			;jump if no wrap
		LDX		#$0A			;switch to slot 5
LF411:	LDY		$B7,X			;check if slot empty
		BEQ		LF40B			;keep moving if so
LF415:	STX		$C3				;set new cursor position
		TYA						;get item at cursor
		LSR						;/2
		LSR						;/4
		LSR						;/8 (graphic -> item type)
		STA		$C5				;set current item type
		CPY		#$90			;check if item was the hourglass
		BNE		LF437			;jump if not
		LDY		#$09			;mesa field
		CPY		$81				;check if current room
		BNE		LF437			;jump if not
		LDA		#$49
		STA		$8D
		LDA		$CF
		ADC		#$09
		STA		$D1
		LDA		$C9
		ADC		#$09
		STA		$CB
LF437:	LDA		$8D
		BPL		LF454
		CMP		#$BF
		BCS		LF44B
		ADC		#$10
		STA		$8D
		LDX		#$03
		JSR		LFCEA
		JMP		LF48B

LF44B:	LDA		#$70
		STA		$D1
		LSR		
		STA		$8D
		BNE		LF48B
LF454:	BIT		$8D
		BVC		LF48B
		LDX		#$03
		JSR		LFCEA
		LDA		$CB
		SEC		
		SBC		#$04
		CMP		$C9
		BNE		LF46A
		LDA		#$03
		BNE		LF481

LF46A:	CMP		#$11
		BEQ		LF472
		CMP		#$84
		BNE		LF476
LF472:	LDA		#$0F
		BNE		LF481
LF476:	LDA		$D1
		SEC		
		SBC		#$05
		CMP		$CF
		BNE		LF487
		LDA		#$0C
LF481:	EOR		$8D
		STA		$8D
		BNE		LF48B
LF487:	CMP		#$4A
		BCS		LF472
LF48B:	JMP		LD024

;==========================================================================
; Display kernel 3 (well of souls)
;
.proc setupDisplay_3
		mva		#$01 vscrol

		ldx		#$22			;dmactl
		ldy		#$00			;gractl
		rts
.endp


LF4A6_kernel:
LF4A6:	STA		WSYNC
		CPX		#$12
		BCC		LF4D0
		TXA
		SBC		$CF
		BMI		LF4C9
		CMP		#$14
		BCS		LF4BD
		LSR
		TAY
		LDA		LFA58,Y
		JMP		LF4C3

LF4BD:	AND		#$03
		TAY
		LDA		LF9FC,Y
LF4C3:	STA		GRP1
		LDA		$CF
		STA		COLUP1			;set player 1 (Indy) color
LF4C9:	INX
		CPX		#$90
		BCS		LF4EA
		BCC		LF4A6
LF4D0:	BIT		$9C
		BMI		LF4E5
		TXA
		SBC		#$07
		BMI		LF4E5
		TAY
		LDA		LFB40,Y
		STA		GRP1
		TXA
		ADC		$82
		ASL
		STA		COLUP1
LF4E5:	INX
		CPX		#$0F
		BCC		LF4A6
LF4EA:	STA		WSYNC
		CPX		#$20
		BCS		LF511
		BIT		$9C
		BMI		LF504
		TXA
		LDY		#$7E
		AND		#$0E
		BNE		LF4FD
		LDY		#$FF
LF4FD:	STY		GRP0
		TXA
		EOR		#$FF
		STA		COLUP0
LF504:	INX
		CPX		#$1D
		BCC		LF4EA
		LDA		#$00
		STA		GRP0
		STA		GRP1
		BEQ		LF4A6
LF511:	TXA
		SBC		#$90
		CMP		#$0F
		BCC		LF51B
		JMP		LF1EA

LF51B:	LSR
		LSR
		TAY
		LDA    LFEF0,Y
		STA    GRP0
		STX    COLUP0
		INX
		BNE    LF4EA

;==========================================================================
LF535:	LDA    #$7F
		STA    $CE
		STA    $D0
		STA    $D2
		BNE    LF59A

;==========================================================================
; Room 7 update (spider room)
;
LF53F:	LDX		#$00
		LDY		#$01
		lda		p1pl
		and		#$0c
		ora		p1pf
		bne		LF55B
		BIT		$B6
		BMI		LF55B
		LDA		$82
		AND		#$07
		BNE		LF55E
		LDY		#$05
		LDA		#$4C
		STA		$CD
		LDA		#$23
		STA		$D3
LF55B:	JSR		LF8B3
LF55E:	LDA		#$80			;tsetse flies
		STA		$93				;enable flies
		LDA		$CE
		AND		#$01
		ROR		$C8
		ROL
		TAY
		ROR
		ROL		$C8
		LDA		LFAEA,Y
		STA		$DD
		LDA		#$7C			;!! - relocation hazard
		STA		$DE
		LDA		$8E
		BMI		LF59A
		LDX		#$50
		STX		$CA
		LDX		#$26
		STX		$D0
		LDA		$B6
		BMI		LF59A
		BIT		$9D
		BMI		LF59A
		AND		#$07
		BNE		LF592
		LDY		#$06
		STY		$B6
LF592:	TAX
		LDA		LFCD2,X
		STA		$8E
		DEC		$B6
LF59A:	JMP		LF833

;==========================================================================
; Update function - room 10 (valley of death)
;
LF59D:	LDA		#$80			;tsetse flies
		STA		$93				;enable flies
		LDX		#$00
		BIT		$9D
		BMI		LF5AB
		BIT		$95
		BVC		LF5B7
LF5AB:	LDY		#$05
		LDA		#$55
		STA		$CD
		STA		$D3
		LDA		#$01
		BNE		LF5BB

LF5B7:	LDY		#$01
		LDA		#$03
LF5BB:	AND		$82
		BNE		LF5CE
		JSR		LF8B3
		LDA		$CE
		BPL		LF5CE
		CMP		#$A0
		BCC		LF5CE
		INC		$CE
		INC		$CE
LF5CE:	BVC		LF5DE
		LDA		$CE
		CMP		#$51
		BCC		LF5DE
		LDA		$95
		STA		$99
		LDA		#$00
		STA		$95
LF5DE:	LDA		$C8				;get thief horizontal position
		CMP		$C9				;compare against Indy's horizontal position
		BCS		LF5E7			;jump if thief is to the right
		DEX
		EOR		#$03
LF5E7:	STX		reflect_p0
		AND		#$03
		ASL
		ASL
		ASL
		ASL
		STA		$DD
		LDA		$82
		AND		#$7F
		BNE		LF617
		LDA		$CE
		CMP		#$4A
		BCS		LF617
		LDY		$98
		BEQ		LF617
		DEY
		STY		$98
		LDY		#$8E
		ADC		#$03
		STA		$D0
		CMP		$CF
		BCS		LF60F
		DEY
LF60F:	LDA		$C8
		ADC		#$04
		STA		$CA
		STY		$8E
LF617:	LDY		#$7F
		LDA		$8E
		BMI		LF61F
		STY		$D0
LF61F:	LDA		$D1
		CMP		#$52
		BCC		LF627
		STY		$D1
LF627:	JMP		LF833

;==========================================================================
; Update function - room 12 (inside mesa)
;
LF62A:	LDX		#$3A
		STX		$E9
		LDX		#$85
		STX		$E3
		LDX		#$03
		STX		$AD			;set scoring bonus
		BNE		LF63A		;update thieves

;==========================================================================
; Update function - room 13 (thief room)
;
LF638: LDX    #$04
LF63A: LDA    LFCD8,X
       AND    $82
       BNE    LF656
       LDY    $E5,X
       LDA    #$08
       AND    $DF,X
       BNE    LF65C
       DEY
       CPY    #$14
       BCS    LF654
LF64E: LDA    #$08
       EOR    $DF,X
       STA    $DF,X
LF654: STY    $E5,X
LF656: DEX
       BPL    LF63A
       JMP    LF833

;==========================================================================
; Update function - room 12 (falling room)
;
LF65C:	INY					;move Indy down
		CPY		#$85		;check if at bottom
		BCS		LF64E		;die in valley if so
		BCC		LF654		;update position and exit if so

;==========================================================================
; Update function - room 5 (falling room)
;
LF663:	BIT		$B4			;check parachute flags
		BPL		LF685		;jump if parachute not open
		BVC		LF66D
		DEC		$C9
		BNE		LF685
LF66D:	LDA		$82
		ROR
		BCC		LF685
		LDA		SWCHA
		STA		$92
		ROR
		ROR
		ROR
		BCS		LF680
		DEC		$C9
		BNE		LF685
LF680:	ROR
		BCS		LF685
		INC		$C9
LF685:	LDA		#$02
		AND		$B4			;check if Yar shown
		BNE		LF691		;skip if so
		STA		$8D
		LDA		#$0B
		STA		$CE			;set player 0 position
LF691:	LDX		$CF
		LDA		$82			;get frame counter
		BIT		$B4			;check parachute
		BMI		LF6A3		;fall at 0.5/tick if so
		CPX		#$15		;check if in first third
		BCC		LF6A3		;if so, fall 0.5/tick
		CPX		#$30		;check if in second third
		BCC		LF6AA		;fall at 1/tick
		BCS		LF6A9		;fall at 2/tick

LF6A3:	ROR					;move Indy downward at half speed
		BCC		LF6AA
LF6A6:	JMP		LF833

LF6A9:	INX					;move Indy downward
LF6AA:	INX					;move Indy downward
		STX		$CF			;set Indy vertical position
		BNE		LF6A6

;==========================================================================
; room 3 update function (black market)
;
LF6AF:	LDA		$C9
		CMP		#$64
		BCC		LF6BC
		ROL		$B2
		CLC		
		ROR		$B2
		BPL		LF6DE
LF6BC:	CMP		#$2C
		BEQ		LF6C6
		LDA		#$7F
		STA		$D2
		BNE		LF6DE
LF6C6:	BIT		$B2			;check if raving lunatic was bribed
		BMI		LF6DE		;jump if so
		LDA		#$30
		STA		$CC			;set ball position
		LDY		#$00		;set ball sprite to full height
		STY		$D2
		LDY		#$7F
		STY		$DC
		STY		$D5
		INC		$C9			;bump Indy right so he can continue afterward
		LDA		#$80
		STA		$9D			;kill Indy
LF6DE:	JMP		LF833

;==========================================================================
; Room 0 update function (treasure room)
;
; The treasure that appears after the coins have been collected depends on
; the high timer byte. There is a 3-in-8 chance of getting the chai and a
; 1-in-4 chance each of getting the ankh and hourglass.
;
LF6E1:	LDY		$DF
		DEY
		BNE		LF6DE
		LDA		$AF
		AND		#$07
		BNE		LF71D
		LDA		#$40			;snake flag
		STA		$93				;enable the snake
		LDA		$83				;get timer high byte
		LSR						;divide by 32, giving 8 choices
		LSR
		LSR
		LSR
		LSR
		TAX
		LDY		LFCDC,X			;get choice (1-3)
		LDX		LFCAA,Y			;get item from choice (chai, ankh, hourglass)
		STY		$84
		JSR		LF89D			;check if the item is present
		BCC		LF70A			;jump if not
LF705:	INC		$DF
		BNE		LF6DE
		BRK

LF70A:	LDY		$84
		TYA
		ORA		$AF
		STA		$AF
		LDA		LFCA2,Y
		STA		$CE				;set player 0 start position
		LDA		LFCA6,Y
		STA		$DF				;set player 0 end position
		BNE		LF6DE

LF71D:	CMP		#$04
		BCS		LF705
		ROL		$AF
		SEC
		ROR		$AF
		BMI		LF705

;==========================================================================
; Room 5 update function (map room)
;
LF728:	LDY		#$00
		STY		$D2
		LDY		#$7F
		STY		$DC
		STY		$D5
		LDA		#$71
		STA		$CC
		LDY		#$4F
		LDA		#$3A
		CMP		$CF
		BNE		LF74A
		LDA		$C5				;get current item
		CMP		#$07			;check if key
		BEQ		LF74C			;jump if so
		LDA		#$5E
		CMP		$C9
		BEQ		LF74C
LF74A:	LDY		#$0D
LF74C:	STY		$DF
		LDA		$83				;get timer high

.if MAP_TEST
		dec		$8C
		bne		no_reset
		lda		#$0f
		sta		$8C
no_reset:
		lda		#$10
.endif

		SEC
		SBC		#$10
		BPL		LF75A
		EOR		#$FF
		SEC
		ADC		#$00
LF75A:	CMP		#$0B
		BCC		LF760
		LDA		#$0B
LF760:	STA		$CE
		BIT		$B3
		BPL		LF78B
		CMP		#$08
		BCS		LF787
		LDX		$C5				;get current item
		CPX		#$0E			;check if staff head
		BNE		LF787
		STX		$AB
		LDA		#$04
		AND		$82
		BNE		LF787
		LDA		$8C
		AND		#$0F
		TAX
		LDA		LFAC2,X
		STA		$CB				;set missile 1 horizontal position
		LDA		LFAD2,X
		BNE		LF789
LF787:	LDA		#$70
LF789:	STA		$D1				;set missile 1 vertical position
LF78B:	ROL		$B3
		LDA		#$3A
		CMP		$CF
		BNE		LF7A2
		CPY		#$4F
		BEQ		LF79D
		LDA		#$5E
		CMP		$C9
		BNE		LF7A2
LF79D:	SEC
		ROR		$B3
		BMI		LF7A5
LF7A2:	CLC
		ROR		$B3
LF7A5:	JMP		LF833

;==========================================================================
; room 6 update function (temple entrance)
;
LF7A8:	LDA		#$08
		AND		$C7
		BNE		LF7C0
		LDA		#$4C
		STA		$CC
		LDA		#$2A
		STA		$D2
		LDA		#<LFABA
		STA		$D6
		LDA		#$7A		;!! - relocation hazard
		STA		$D7
		BNE		LF7C4

LF7C0:	LDA		#$F0
		STA		$D2
LF7C4:	LDA		$B5			;get temple door position
		AND		#$0F
		BEQ		LF833
		STA		$DC			;set player 0 height
		LDY		#$14
		STY		$CE			;set player 0 position
		LDY		#$3B
		STY		$E0			;set dynamic playfield threshold
		INY
		STY		$D4			;set dynamic playfield start
		LDA		#$C1
		SEC
		SBC		$DC
		STA		$DD			;set player 0 graphics pointer low
		BNE		LF833

;==========================================================================
; Room 8 update function (guardian room)
;
LF7E0:	LDA		$82			;get timer lo
		AND		#$18
		ADC		#$E0
		STA		$DD
		LDA		$82
		AND		#$07
		BNE		LF80F
		LDX		#$00
		LDY		#$01
		LDA		$CF
		CMP		#$3A
		BCC		LF80C
		LDA		$C9
		CMP		#$2B
		BCC		LF802
		CMP		#$6D
		BCC		LF80C
LF802:	LDY		#$05
		LDA		#$4C
		STA		$CD
		LDA		#$0B
		STA		$D3
LF80C:	JSR		LF8B3
LF80F:	LDX		#$4E
		CPX		$CF
		BNE		LF833
		LDX		$C9				;get Indy's horizontal position
		CPX		#$76			;check if near right border (4 pels from edge)
		BEQ		LF81F
		CPX		#$14			;check if near left border (4 pels from edge)
		BNE		LF833
LF81F:	LDA		SWCHA			;check joystick
		AND		#$0F
		CMP		#$0D			;see if it's down
		BNE		LF833			;jump if not
		STA		$A6
		LDA		#$4C
		STA		$C9
		ROR		$B5				;start bringing down the temple door
		SEC
		ROL		$B5
LF833:	JMP		LD80D

;==========================================================================
; Room 2 update function (entrance room)
;
LF83E:	LDA		#$40
		STA		$93				;enable snake
		BNE		LF833

;==========================================================================
; Main display routine
;
.proc LF844
		ldy		$81
		jsr		setupDisplay
		jsr		waitFrameStart
		ldy		#0
		STY		$80
		LDY		$81
		STA		CXCLR
		STA		WSYNC

		;dispatch to display kernel
		LDX		LF9EE,Y
		LDA		LFAE2+1,X
		PHA		
		LDA		LFAE2,X
		PHA		
		LDA		#$00
		TAX		
		STA		$84
		RTS
.endp
		
;==========================================================================
LF89D:	LDA		LFC75,X
		LSR
		TAY
		LDA		LFCE2,Y
		BCS		LF8AD
		AND		$C6
		BEQ		LF8AC
		SEC
LF8AC:	RTS

LF8AD:	AND		$C7
		BNE		LF8AC
		CLC
		RTS

;==========================================================================
LF8B3:	CPY		#$01
		BNE		LF8BB
		LDA		$CF
		BMI		LF8CC
LF8BB:	LDA		$CE,X
		CMP		$00CE,Y
		BNE		LF8C6
		CPY		#$05
		BCS		LF8CE
LF8C6:	BCS		LF8CC
		INC		$CE,X
		BNE		LF8CE
LF8CC:	DEC		$CE,X
LF8CE:	LDA		$C8,X
		CMP		$00C8,Y
		BNE		LF8D9
		CPY		#$05
		BCS		LF8DD
LF8D9:	BCS		LF8DE
		INC		$C8,X
LF8DD:	RTS

LF8DE:	DEC		$C8,X
		RTS

LF8E1:	LDA		$CE,X
		CMP		#$53
		BCC		LF8F1
LF8E7:	ROL		$8C,X
		CLC
		ROR		$8C,X
		LDA		#$78
		STA		$CE,X
		RTS

LF8F1:	LDA		$C8,X
		CMP		#$10
		BCC		LF8E7
		CMP		#$8E
		BCS		LF8E7
		RTS

LFCEA:	ROR
		BCS		LFCEF
		DEC		$CE,X
LFCEF:	ROR
		BCS		LFCF4
		INC		$CE,X
LFCF4:	ROR
		BCS		LFCF9
		DEC		$C8,X
LFCF9:	ROR
		BCS		LFCFE
		INC		$C8,X
LFCFE:	RTS

LFEF4:	LDA		$8C,X
		BMI		LFEF9
		RTS

LFEF9:	JSR		LFCEA
		JSR		LF8E1
		RTS

		org		$5afd

LDAFD: .byte $00,$00,$00
LDB00:	.byte	$00,$00,$35,$10,$17,$30,$00,$00,$00,$00,$00,$00,$00
		.byte	$05,$00,$00
		.byte	$F0,$E0,$D0,$C0,$B0,$A0,$90,$71,$61,$51,$41,$31,$21,$11,$01,$F1
		.byte	$E1,$D1,$C1,$B1,$A1,$91,$72,$62,$52,$42,$32,$22,$12,$02,$F2,$E2
		.byte	$D2,$C2,$B2,$A2,$92,$73,$63,$53,$43,$33,$23,$13,$03,$F3,$E3,$D3
		.byte	$C3,$B3,$A3,$93,$74,$64,$54,$44,$34,$24,$14,$04,$F4,$E4,$D4,$C4
		.byte	$B4,$A4,$94,$75,$65,$55,$45,$35,$25,$15,$05,$F5,$E5,$D5,$C5,$B5
		.byte	$A5,$95,$76,$66,$56,$46,$36,$26,$16,$06,$F6,$E6,$D6,$C6,$B6,$A6
		.byte	$96,$77,$67,$57,$47,$37,$27,$17,$07,$F7,$E7,$D7,$C7,$B7,$A7,$97
		.byte	$78,$68,$58,$48,$38,$28,$18,$08,$F8,$E8,$D8,$C8,$B8,$A8,$98,$79
		.byte	$69,$59

;room CTRLPF value
LDB92: .byte	$11,$11,$11,$11,$31,$11,$25,$05,$05,$01,$01,$05,$05,$01

LDBA0: .byte	$00,$24,$96,$22,$72,$FC,$00,$00,$00,$72,$12,$00,$F8,$00
LDBAE: .byte	$08,$22,$08,$00,$1A,$28,$C8,$E8,$8A,$1A,$C6,$00,$28,$78
LDBBC: .byte	$CC,$EA,$5A,$26,$9E,$A6,$7C
LDBC3: .byte	$88,$28,$F8,$4A,$26,$A8
LDBC9: .byte	$CC,$CE,$4A,$98,$00,$00,$00,$08,$07,$01,$10

;sprite graphics low byte
LDBD4: .byte $78,$4C,$5D,$4C,$4F,$4C,$12,$4C,$4C,$4C,$4C,$12,$12

;room display list high byte
LDBE1:	dta		>LFF00		;room 0 (treasure room)
		dta		>LFF51		;room 1 (marketplace)
		dta		>LFFA1		;room 2 (entrance room)
		dta		>LF900		;room 3 (black market)
		dta		>LF951		;room 4 (map room)
		dta		>LF9A2		;room 5 (falling room)
		dta		>LFAC1		;room 6 (temple entrance)
		dta		>$00E5		;room 7 (spider room) (kernel 1 - 8 bytes)
		dta		>LFDE0		;room 8 (guardian room) (kernel 1 - 7 bytes)
		dta		>LFB00		;room 9 (mesa field) (kernel 1 - 1 byte)
		dta		>LFC00		;room 10 (valley of death) (kernel 1 - 10 bytes)
		dta		>LFC00		;room 11 (thief room) (kernel 2 - 16 bytes)
		dta		>LFC00		;room 12 (inside mesa) (kernel 2 - 16 bytes)

;room display list low byte
LDBEE:	dta		<LFF00		;room 0 (treasure room)
		dta		<LFF51		;room 1 (marketplace)
		dta		<LFFA1		;room 2 (entrance room)
		dta		<LF900		;room 3 (black market)
		dta		<LF951		;room 4 (map room)
		dta		<LF9A2		;room 5 (falling room)
		dta		<LFAC1		;room 6 (temple entrance)
		dta		<$00E5		;room 7 (spider room)
		dta		<LFDE0		;room 8 (guardian room)
		dta		<LFB00		;room 9 (mesa field)
		dta		<LFC00		;room 10 (valley of death)
		dta		<LFC00		;room 11 (thief room)
		dta		<LFC00		;room 12 (inside mesa)

LDBFB:	dta		<LFA72,<LFA7A,<LFA8A,<LFA82

LDBFF: .byte $FE,$FA,$02,$06
LDC03: .byte $00,$00,$18,$04,$03,$03,$85,$85,$3B,$85,$85
LDC0E: .byte $20,$78,$85,$4D,$62,$17,$50,$50,$50,$50,$50,$12,$12
LDC1B: .byte $FF,$FF,$14,$4B,$4A,$44,$FF,$27,$FF,$FF,$FF,$F0,$F0

;PF1 playfield pointer / stream 1 low byte
LDC28:	dta		$06,$06,$06,$06,$06,$06,$48,$68,$89,$00,$00

;PF1 playfield pointer / stream 1 high byte
LDC33:	dta		$00,$00,$00,$00,$00,$00,$FD,$FD,$FD,$FE,$FE

;PF2 playfield pointer / stream 2 low byte
LDC3E:	dta		$20,$20,$20,$20,$20,$20,$20,$B7,$9B,$78,$78

;PF2 playfield pointer / stream 2 high byte
LDC49:	dta		$00,$00,$00,$00,$00,$00,$FD,$FD,$FD,$FE,$FE

;bit mask table
LDC54: .byte $01,$02,$04,$08,$10,$20,$40,$80

;inverse bit mask table
LDC5C: .byte $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F

;item to tracking bit table
LDC64:	dta		$00
		dta		$00
		dta		$00
		dta		$00
		dta		$08			;bag of coins
		dta		$00
		dta		$02			;grenade 2
		dta		$0A			;key
		dta		$0C
		dta		$0E
		dta		$01			;whip
		dta		$03			;shovel
		dta		$04
		dta		$06			;revolver
		dta		$05			;staff head
		dta		$07			;timepiece
		dta		$0D			;ankh
		dta		$0F			;chai
		dta		$0B			;hourglass

;item drop handler (invoked with X = room)
LDC77:	dta		A(LDAD8-1)		;$08
		dta		A(LDAD8-1)		;$10 flute
		dta		A(LDA5E-1)		;$18 parachute
		dta		A(LDAC0-1)		;$20 bag of coins
		dta		A(LDAD8-1)		;$28 grenade 1
		dta		A(LDAD8-1)		;$30 grenade 2
		dta		A(LDAD8-1)		;$38 key
		dta		A(LDAD8-1)		;$40
		dta		A(LDAD8-1)		;$48
		dta		A(LDA9E-1)		;$50 whip
		dta		A(LDAAD-1)		;$58 shovel
		dta		A(LDAD8-1)		;$60 
		dta		A(LDAD8-1)		;$68 revolver
		dta		A(LDAD8-1)		;$70 staff head
		dta		A(LDAD8-1)		;$78 timepiece
		dta		A(LDA67-1)		;$80 ankh
		dta		A(LDA6F-1)		;$88 chai
		dta		A(LDA67-1)		;$90 hourglass

;room player collision jump table
LDC9B:	dta		A(LD2B4-1)		;room 0 (treasure room)
		dta		A(LD1EB-1)		;room 1 (marketplace)
		dta		A(LD292-1)		;room 2 (entrance room)
		dta		A(LD24A-1)		;room 3 (black market)
		dta		A(LD2B4-1)		;room 4 (map room)
		dta		A(LD1C4-1)		;room 5 (falling room)
		dta		A(LD28E-1)		;room 6 (temple entrance)
		dta		A(LD1B9-1)		;room 7 (spider room)
		dta		A(LD335-1)		;room 8 (guardian room)
		dta		A(LD2B4-1)		;room 9 (mesa field)
		dta		A(LD192-1)		;room 10 (valley of death)
		dta		A(LD18E-1)		;room 11 (thief room)
		dta		A(LD162-1)		;room 12 (inside mesa)

;room update jump table (playfield collision)
LDCB5:	dta		A(LD374-1)		;room 0 (treasure room)
		dta		A(LD374-1)		;room 1 (marketplace)
		dta		A(LD321-1)		;room 2 (entrance room)
		dta		A(LD374-1)		;room 3 (black market)
		dta		A(LD374-1)		;room 4 (map room)
		dta		A(LD357-1)		;room 5 (falling room)
		dta		A(LD302-1)		;room 6 (temple entrance)
		dta		A(LD357-1)		;room 7 (spider room)
		dta		A(LD335-1)		;room 8 (guardian room)
		dta		A(LD374-1)		;room 9 (mesa field)
		dta		A(LD36A-1)		;room 10 (valley of death)
		dta		A(LD374-1)		;room 11 (thief room)
		dta		A(LD374-1)		;room 12 (inside mesa)

;room update jump table (no collision)
LDCCF:	dta		A(LD374-1)		;room 0 (treasure room)
		dta		A(LD374-1)		;room 1 (marketplace)
		dta		A(LD36F-1)		;room 2 (entrance room)
		dta		A(LD374-1)		;room 3 (black market)
		dta		A(LD2F2-1)		;room 4 (map room)
		dta		A(LD374-1)		;room 5 (falling room)
		dta		A(LD374-1)		;room 6 (temple entrance)
		dta		A(LD374-1)		;room 7 (spider room)
		dta		A(LD374-1)		;room 8 (guardian room)
		dta		A(LD2CE-1)		;room 9 (mesa field)
		dta		A(LD36F-1)		;room 10 (valley of death)
		dta		A(LD374-1)		;room 11 (thief room)
		dta		A(LD374-1)		;room 12 (inside mesa)

		org		$5df8
LDDF8:	dta		$00,$00,$00,$00,$00,$00,$00,$00

;room exit horizontal/vertical positions
LDE00:	dta		$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F8,$FF,$FF,$FF,$FF,$FF		;top
		dta		$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$44,$44		;bottom
		dta		$0F,$0F,$1C,$0F,$0F,$18,$0F,$0F,$0F,$0F,$0F,$12,$12		;left
		dta		$89,$89,$8C,$89,$89,$86,$89,$89,$89,$89,$89,$86,$86		;right

;room exits (entire border)
;
; $FF - no exit
; $FE - lo/hi split
; $FD - lo/hi bounded
;
;				trs mkt ent blk map fal tpl spd grd msf vly thf msa
LDE34:	dta		$FF,$FD,$FF,$FF,$FD,$FF,$FF,$FF,$FD,$01,$FD,$04,$FD		;top
		dta		$FF,$FD,$01,$FF,$0B,$0A,$FF,$FF,$FF,$04,$FF,$FD,$FF		;bottom
		dta		$FD,$FF,$FF,$FF,$FF,$FF,$FE,$FD,$FD,$FF,$FF,$FF,$FF		;left
		dta		$FF,$FD,$FD,$FE,$FF,$FF,$FE,$FD,$FD,$FF,$FF,$FF,$FF		;right

;room exit lo bound
;				trs mkt ent blk map fal tpl spd grd msf vly thf msa
LDE68:	dta		$00,$1E,$00,$00,$11,$00,$00,$00,$11,$00,$10,$00,$60		;top
		dta		$00,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$70,$00		;bottom
		dta		$12,$00,$00,$00,$00,$00,$30,$15,$24,$00,$00,$00,$00		;left
		dta		$00,$18,$03,$27,$00,$00,$30,$20,$12,$00,$00,$00,$00		;right

;room exit 2 or hi bound
;				trs mkt ent blk map fal tpl spd grd msf vly thf msa
LDE9C:	dta		$00,$7A,$00,$00,$88,$00,$00,$00,$88,$00,$80,$00,$65
		dta		$00,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$72,$00
		dta		$16,$00,$00,$00,$00,$00,$02,$1F,$2F,$00,$00,$00,$00
		dta		$00,$1C,$40,$01,$00,$00,$07,$27,$16,$00,$00,$00,$00

;room exit 1
;				trs mkt ent blk map fal tpl spd grd msf vly thf msa
LDED0:	dta		$00,$02,$00,$00,$09,$00,$00,$00,$07,$00,$FC,$00,$05		;top
		dta		$00,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00		;bottom
		dta		$FF,$00,$00,$00,$00,$00,$01,$06,$FE,$00,$00,$00,$00		;left
		dta		$00,$FB,$FD,$0B,$00,$00,$08,$08,$00,$00,$00,$00,$00		;right

;room entry vertical position ($00 = keep current)
LDF04: .byte $00,$4E,$00,$00,$4E,$00,$00,$00,$4D,$4E,$4E,$4E,$04,$01,$03,$01
       .byte $01,$01,$01,$01,$01,$01,$01,$01,$40,$00,$23,$00,$00,$00,$00,$00
       .byte $00,$00,$41,$00,$00,$00,$00,$00,$45,$00,$42,$00,$00,$00,$42,$23
       .byte $28,$00,$00,$00

;room entry horizontal position ($00 = keep current)
LDF38: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4C,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$86,$00,$00,$00,$00,$00
       .byte $80,$86,$80,$00,$00,$00,$00,$00,$12,$12,$4C,$00,$00,$16,$80,$12
       .byte $50,$00,$00,$00

;room no-exit bump directions
LDF6C: .byte $01,$FF,$01,$FF

LDF70: .byte $35,$09
LDF72: .byte $00,$00,$42,$45,$0C,$20
LDF78: .byte $04,$11,$10,$12
LDF7C: .byte $07,$03,$05,$06,$09,$0B,$0E,$00,$01,$03,$05,$00,$09,$0C,$0E,$00
       .byte $01,$04,$05,$00,$0A,$0C,$0F,$00,$02,$04,$05,$08,$0A,$0D,$0F,$00

LDFD5: .byte $00,$00,$00,$00,$00,$0A,$09,$0B,$00,$06,$05,$07,$00,$0E,$0D,$0F
LDFE5: .byte $00,$06,$03,$03,$03,$00,$00,$06,$00,$00,$00,$06,$00,$00,$00,$00
       .byte $00,$00,$00
LDFF8: .byte $00,$00,$68,$DD,$68,$DD,$68,$DD

;Indy theme music for Well of Souls (relocated)
LFBE8:	dta		$14,$14,$14,$0F,$10,$12,$0B,$0B
		dta		$0B,$10,$12,$14,$17,$17,$17,$17,$18,$1B,$0F,$0F,$0F,$14,$17,$18

		org		$78fc
LF8FC: .byte $00,$00,$00,$00

;room 3 (black market) display list
LF900:	dta		$00,$E4,$7E,$9A,$E4,$A6,$5A,$7E,$E4,$7F,$00,$00,$84,$08,$2A,$22
		dta		$00,$22,$2A,$08,$00,$B9,$D4,$89,$6C,$7B,$7F,$81,$A6,$3F,$77,$07
		dta		$7F,$86,$89,$3F,$1F,$0E,$0C,$00,$C1,$B6,$00,$00,$00,$81,$1C,$2A
		dta		$55,$2A,$14,$3E,$00,$A9,$00,$E4,$89,$81,$7E,$9A,$E4,$A6,$5A,$7E
		dta		$E4,$7F,$00,$C9,$89,$82,$00,$7C,$18,$18,$92,$7F,$1F,$07,$00,$00
		dta		$00
		
;room 4 (map room) display list
LF951:	dta			$94,$00,$08,$1C,$3E,$3E,$3E,$3E,$1C,$08,$00,$8E,$7F,$7F,$7F
		dta		$14,$14,$00,$00,$2A,$2A,$00,$00,$14,$36,$22,$08,$08,$3E,$1C,$08
		dta		$00,$41,$63,$49,$08,$00,$00,$14,$14,$00,$00,$08,$6B,$6B,$08,$00
		dta		$22,$22,$00,$00,$08,$1C,$1C,$7F,$7F,$7F,$E4,$41,$41,$41,$41,$41
		dta		$41,$41,$41,$41,$41,$7F,$92,$77,$77,$63,$77,$14,$36,$55,$63,$77
		dta		$7F,$7F
		
;room 5 (falling room) display list
LF9A2:	dta				$00,$86,$24,$18,$24,$24,$7E,$5A,$5B,$3C,$00,$00,$00,$00
		dta		$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		dta		$00,$00,$00,$00,$00,$B9,$E4,$81,$89,$55,$F9,$89,$F9,$81,$FA,$32
		dta		$1C,$89,$3E,$91,$7F,$7F,$7F,$7F,$89,$1F,$07,$01,$00,$E9,$FE,$89
		dta		$3F,$7F,$F9,$91,$F9,$89,$3F,$F9,$7F,$3F,$7F,$7F,$00,$00

;display kernel selection by room
LF9EE: .byte $00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$04,$04,$06

LF9FC: .byte $1C,$36,$63,$36,$18,$3C,$00,$18,$1C,$18,$18,$0C,$62,$43,$00,$18
       .byte $3C,$00,$18,$38,$1C,$18,$14,$64,$46,$00,$18,$3C,$00,$38,$38,$18
       .byte $18,$28,$48,$8C,$00,$18,$3C,$00,$38,$58,$38,$10,$E8,$88,$0C,$00
       .byte $18,$3C,$00,$30,$78,$34,$18,$60,$50,$18,$00,$18,$3C,$00,$30,$38
       .byte $3C,$18,$38,$20,$30,$00,$18,$3C,$00,$18,$38,$1C,$18,$2C,$20,$30
       .byte $00,$18,$3C,$00,$18,$18,$18,$08,$16,$30,$20,$00
LFA58: .byte $18,$3C,$00,$18,$3C,$5A,$3C,$18,$18,$3C,$00,$3C,$7E,$FF,$A5,$42
       .byte $42,$18,$3C,$81,$5A,$3C,$3C,$38,$18,$00
	   
;snake hmove data
LFA72:	dta		$01,$01,$00,$FF,$FF,$00,$01,$00
LFA7A:	dta		$01,$01,$00,$FF,$00,$01,$01,$00
LFA82:	dta		$01,$00,$FF,$FF,$00,$FF,$FF,$00
LFA8A:	dta		$FF,$FF,$00,$01,$01,$00,$FF		;!! - 1 byte shared

;room constant PF1 data
LFA91:	dta		$00,$00,$E0,$00,$00,$C0,$FF,$FF,$00,$FF,$FF,$F0,$F0

;room constant PF2 data
LFA9E:	dta		$00,$E0,$00,$E0,$80,$00,$FF,$FF,$00,$FF,$FF,$C0,$00,$00

;common room PF0 data
LFAAC:	dta		$C0,$F0,$F0,$F0,$F0,$F0,$C0,$C0,$C0,$F0,$F0,$F0,$F0,$C0

;timepiece HMBL/ENABL data
LFABA:	dta		$F7,$F7,$F7,$F7,$F7,$37,$37,$00		;!! - 1 trailing shared
	   
;room 6 (temple entrance) display list
LFAC1:	dta		$00
LFAC2: .byte $63,$62,$6B,$5B,$6A,$5F,$5A,$5A,$6B,$5E,$67,$5A,$62,$6B,$5A,$6B
LFAD2: .byte $22,$13,$13,$18,$18,$1E,$21,$13,$21,$26,$26,$2B,$2A,$2B,$31,$31

		org		$7ae2

;display kernel dispatch table
LFAE2:	dta		a(LF0B5_kernel-1)
		dta		a(LF003_kernel-1)
		dta		a(LF140_kernel-1)
		dta		a(LF4A6_kernel-1)

LFAEA: .byte $AE,$C0,$B7,$C9

;Flute music (16 beats)
LFAEE: .byte $1B,$18,$17,$17,$18,$18,$1B,$1B,$1D,$18,$17,$12,$18,$17,$1B,$1D

       .byte $00,$00
	
		org		$7b00

;blank image
LFB00:	dta		$00,$00,$00,$00,$00,$00,$00,$00
	
;'2' and left pixel of 'W'
LFB08:	dta		%01110001	;$71
		dta		%01000001	;$41
		dta		%01000001	;$41
		dta		%01110001	;$71
		dta		%00010001	;$11
		dta		%01010001	;$51
		dta		%01110000	;$70
		dta		%00000000	;$00

;flute
LFB10:	dta		%00000000	;$00
		dta		%00000001	;$01
		dta		%00111111	;$3F
		dta		%01101011	;$6B
		dta		%01111111	;$7F
		dta		%00000001	;$01
		dta		%00000000	;$00
		dta		%00000000	;$00
		
;parachute graphic
LFB18:	dta		%01110111	;$77
		dta		%01110111	;$77
		dta		%01110111	;$77
		dta		%00000000	;$00
		dta		%00000000	;$00
		dta		%01110111	;$77
		dta		%01110111	;$77
		dta		%01110111	;$77
	
;bag of coins graphic
LFB20:	dta		%00011100	;$1C
		dta		%00101010	;$2A
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%00011100	;$1C
		dta		%00111110	;$3E

;grenade #1 graphic
LFB28:	dta		%00111010	;$3A
		dta		%00000001	;$01
		dta		%01111101	;$7D
		dta		%00000001	;$01
		dta		%00111001	;$39
		dta		%00000010	;$02
		dta		%00111100	;$3C
		dta		%00110000	;$30

;grenade #2 graphic
LFB30:	dta		%00101110	;$2E
		dta		%01000000	;$40
		dta		%01011111	;$5F
		dta		%01000000	;$40
		dta		%01001110	;$4E
		dta		%00100000	;$20
		dta		%00011110	;$1E
		dta		%00000110	;$06

;key graphic
LFB38:	dta		%00000000	;$00
		dta		%00100101	;$25
		dta		%01010010	;$52
		dta		%01111111	;$7F
		dta		%01010000	;$50
		dta		%00100000	;$20
		dta		%00000000	;$00
		dta		%00000000	;$00

;yar?
LFB40:	dta		%11111111	;$FF
		dta		%01100110	;$66
		dta		%00100100	;$24
		dta		%00100100	;$24
		dta		%01100110	;$66
		dta		%11100111	;$E7
		dta		%11000011	;$C3
		dta		%11100111	;$E7

;'98'
		dta		$17,$15,$15,$77,$55,$55,$77,$00

;whip graphic
LFB50:	dta		%00000001	;$21
		dta		%00010001	;$11
		dta		%00001001	;$09
		dta		%00010001	;$11
		dta		%00100010	;$22
		dta		%01000100	;$44
		dta		%00101000	;$28
		dta		%00010000	;$10

;shovel
LFB58:	dta		%00000001	;$01
		dta		%00000011	;$03
		dta		%00000111	;$07
		dta		%00001111	;$0F
		dta		%00000110	;$06
		dta		%00001100	;$0C
		dta		%00011000	;$18
		dta		%00111100	;$3C

;copyright
LFB60:	dta		%01111001	;$79
		dta		%10000101	;$85
		dta		%10110101	;$B5
		dta		%10100101	;$A5
		dta		%10110101	;$B5
		dta		%10000101	;$85
		dta		%01111001	;$79
		dta		%00000000	;$00

;revolver graphic
LFB68:	dta		%00000000	;$00
		dta		%01100000	;$60
		dta		%01100000	;$60
		dta		%01111000	;$78
		dta		%01101000	;$68
		dta		%00111111	;$3F
		dta		%01011111	;$5F
		dta		%00000000	;$00

;Staff of Ra
LFB70:	dta		%00001000	;$08
		dta		%00011100	;$1C
		dta		%00100010	;$22
		dta		%01001001	;$49
		dta		%01101011	;$6B
		dta		%00000000	;$00
		dta		%00011100	;$1C
		dta		%00000000	;$08

;timepiece
LFB78:	dta		%01111111	;$7F
		dta		%01011101	;$5D
		dta		%01110111	;$77
		dta		%01110111	;$77
		dta		%01011101	;$5D
		dta		%01111111	;$7F
		dta		%00001000	;$08
		dta		%00011100	;$1C

;ankh
LFB80:	dta		%00111110	;$3E
		dta		%00011100	;$1C
		dta		%01001001	;$49
		dta		%01111111	;$7F
		dta		%01001001	;$49
		dta		%00011100	;$1C
		dta		%00110110	;$36
		dta		%00011100	;$1C

;Chai
LFB88:	dta		%00010110	;$16
		dta		%00001011	;$0B
		dta		%00001101	;$0D
		dta		%00000101	;$05
		dta		%00010111	;$17
		dta		%00110110	;$36
		dta		%01100100	;$64
		dta		%00000100	;$04

;hourglass
LFB90:	dta		%01110111	;$77
		dta		%00110110	;$36
		dta		%00010100	;$14
		dta		%00100010	;$22
		dta		%00100010	;$22
		dta		%00010100	;$14
		dta		%00110110	;$36
		dta		%01110111	;$77

;timepiece activated (12:00)
LFB98:	dta		%00111110	;$3E
		dta		%01000001	;$41
		dta		%01000001	;$41
		dta		%01001001	;$49
		dta		%01001001	;$49
		dta		%01001001	;$49
		dta		%00111110	;$3E
		dta		%00011100	;$1C

;timepiece activated (1:30)
LFBA0:	dta		$3E,$41,$41,$49,$45,$43,$3E,$1C

;timepiece activated (3:00)
LFBA8:	dta		$3E,$41,$41,$4F,$41,$41,$3E,$1C

;timepiece activated (4:30)
LFBB0:	dta		$3E,$43,$45,$49,$41,$41,$3E,$1C

;timepiece activated (6:00)
LFBB8:	dta		$3E,$49,$49,$49,$41,$41,$3E,$1C

;timepiece activated (7:30)
LFBC0:	dta		$3E,$61,$51,$49,$41,$41,$3E,$1C

;timepiece activated (9:00)
LFBC8:	dta		$3E,$41,$41,$79,$41,$41,$3E,$1C

;timepiece activated (10:30)
LFBD0:	dta		$3E,$41,$41,$49,$51,$61,$3E,$1C

;'AT'
		dta		$49,$49,$49,$C9,$49,$49,$BE,$00

;'ARI'
       .byte $55,$55,$55,$D9,$55,$55,$99,$00

;==========================================================================
; Signature sprites
;
; In the original ROM, the "HSW2" signature is hidden as two inventory
; item sprites within the treasure room display list, where they are not
; normally displayed due to sprite masking. We can't use them there
; because they're misaligned for mode 6 rendering, so we put them here
; instead and flip CHBASE.
;
hsw2_sprite1:
		dta		%00000111	;$07
		dta		%00000001	;$01
		dta		%01010111	;$57
		dta		%01010100	;$54
		dta		%01110111	;$77
		dta		%01010000	;$50
		dta		%01010000	;$50
		dta		%00000000	;$00

hsw2_sprite2:
		dta		%00000000	;$00
		dta		%00000111	;$07
		dta		%00000100	;$04
		dta		%01110111	;$77
		dta		%01110001	;$71
		dta		%01110101	;$75
		dta		%01010111	;$57
		dta		%01010000	;$50
		dta		%00000000	;$00

		org		$7c00

;room 10-12 display list (valley of death, thief room, inside mesa)
LFC00:	dta		$14,$3C,$7E,$00,$30,$38,$3C,$3E,$3F,$7F,$7F,$7F,$11,$11,$33,$00
		dta		$14,$3C,$7E,$00,$30,$38,$3C,$3E
       .byte $3F,$7F,$7F,$7F,$22,$22,$66,$00,$14,$3C,$7E,$00,$30,$38,$3C,$3E
       .byte $3F,$7F,$7F,$7F,$44,$44,$CC,$00,$14,$3C,$7E,$00,$30,$38,$3C,$3E
       .byte $3F,$7F,$7F,$7F,$08,$08,$18,$00
LFC40: .byte $00,$10,$20,$30,$7C,$0F,$7C,$00,$0A,$02,$04,$06,$08,$0A,$08,$06
       .byte $98,$98,$9E,$9E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08
       .byte $1C,$3C,$3E,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$3E,$3C,$3A,$38
       .byte $36,$34,$32,$20,$10

LFC75: .byte $00,$00,$00,$00,$08,$00,$02,$0A,$0C,$0E,$01,$03,$04,$06,$05,$07
       .byte $0D,$0F,$0B

;room update function jump table (called with X = room, Y = Indy vert pos)
LFC88:	dta		A(LF6E1-1)		;room 0 (treasure room)
		dta		A(LF833-1)		;room 1 (marketplace)
		dta		A(LF83E-1)		;room 2 (entrance room)
		dta		A(LF6AF-1)		;room 3 (black market)
		dta		A(LF728-1)		;room 4 (map room)
		dta		A(LF663-1)		;room 5 (falling room)
		dta		A(LF7A8-1)		;room 6 (temple entrance)
		dta		A(LF53F-1)		;room 7 (spider room)
		dta		A(LF7E0-1)		;room 8 (guardian room)
		dta		A(LF535-1)		;room 9 (mesa field)
		dta		A(LF59D-1)		;room 10 (valley of death)
		dta		A(LF638-1)		;room 11 (thief room)
		dta		A(LF62A-1)		;room 12 (inside mesa)

LFCA2: .byte $1A,$38,$09,$26
LFCA6: .byte $26,$46,$1A,$38
LFCAA: .byte $04,$11,$10,$12,$54,$FC,$5F,$FE,$7F,$FA,$3F,$2A,$00,$54,$5F,$FC
       .byte $7F,$FE,$3F,$FA,$2A,$00,$2A,$FA,$3F,$FE,$7F,$FA,$5F,$54,$00,$2A
       .byte $3F,$FA,$7F,$FE,$5F,$FC,$54,$00
LFCD2: .byte $8B,$8A,$86,$87,$85,$89
LFCD8: .byte $03,$01,$00,$01

;treasure room selections (2 bytes overlap with bit masks!)
LFCDC: .byte $03,$02,$01,$03,$02,$03

;bit masks
LFCE2: .byte $01,$02,$04,$08,$10,$20,$40,$80

		org		$7cff
LFCFF: .byte $00,$F2,$40,$F2,$C0,$12,$10,$F2,$00,$12,$20,$02,$B0,$F2,$30,$12
       .byte $00,$F2,$40,$F2,$D0,$12,$10,$02,$00,$02,$30,$12,$B0,$02,$20,$12
       .byte $00
	
;room 6 PF1 data
LFD20:	.byte	$FF,$FF,$FC,$F0,$E0,$E0,$C0,$80,$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$80,$80,$C0,$E0,$E0,$F0,$FE

;room 6 PF2 data
LFD48:	.byte	$FF,$FF,$FF,$FF,$FC,$F0,$E0,$E0,$C0,$80,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$C0,$F0,$F8,$FE,$FE,$F8,$F0,$E0,$C0,$80,$00

;room 7 PF1 data
LFD68:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$02,$07,$07,$0F,$0F,$0F,$07,$07
		.byte	$02,$00,$00,$00,$00,$00,$00,$00

LFD80:	.byte	$00,$04,$0E,$0E,$0F,$0E,$06,$00,$00

;room 8 PF1 data
LFD89:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$02,$07,$07,$0F,$1F,$0F,$07,$07
		.byte	$02,$00

;room 8 PF2 data
LFD9B:	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$03,$01,$00,$00
		.byte	$00,$00,$00,$80,$80,$C0,$E0,$F8,$E0,$C0,$80,$80

;room 7 PF2 data
LFDB7:	.byte	$00,$00,$00,$C0,$E0,$E0,$C0,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$80,$80,$80,$80,$80,$80,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$C0,$E0,$E0,$C0,$00,$00,$00,$00

;room 8 (guardian room) display list
LFDE0:	.byte	$22,$41,$08,$14,$08,$41,$22

		dta		$00,$41,$08,$14,$2A,$14,$08,$41,$00
		.byte	$08,$14,$3E,$55,$3E,$14,$08,$00,$14,$3E,$63,$2A,$63,$3E,$14,$00

;room 9 (mesa field) PF1 data
LFE00:	.byte	$07,$07,$07,$03,$03,$03,$01,$00,$00,$00,$00,$00,$00,$00,$00,$30
		.byte	$78,$7C,$3C,$3C,$18,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$0F
		.byte	$01,$00,$00,$00,$00,$00,$00,$00,$80,$C0,$E0,$F8,$FC,$FE,$FC,$F0
		.byte	$E0,$C0,$C0,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$03,$07,$03,$01,$00,$00,$00,$00,$00,$80,$E0,$F8,$F8,$F8,$F8,$F0
		.byte	$C0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$03,$0F,$1F,$3F,$3E,$3C
		.byte	$38,$30,$00,$00,$00,$00,$00,$00

;room 9 (mesa field) PF2 data
LFE78:	.byte	$07,$07,$07,$03,$03,$03,$01,$00,$00,$00,$00,$00,$00,$80,$80,$C0
		.byte	$E0,$E0,$C0,$C0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30
		.byte	$38,$1C,$1E,$0E,$0C,$0C,$00,$00,$00,$80,$80,$C0,$F0,$FC,$FF,$FF
		.byte	$FF,$FF,$FE,$FC,$F8,$F0,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00
		.byte	$00,$80,$E0,$F0,$E0,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
		.byte	$07,$03,$03,$01,$01,$00,$00,$00,$80,$C0,$F0,$F0,$E0,$E0,$C0,$C0
		.byte	$80,$80,$00,$00,$00,$00,$00,$00,$00,$03,$07,$07,$03,$01,$00,$00
		.byte	$C0,$E0,$F0,$F8,$F8,$FC,$FC,$FC

		org		$7ef0
LFEF0: .byte $3C,$3C,$7E,$FF

		org		$7f00

;room 0 (treasure room) display list
LFF00:
		;hmove reset
		dta		$80

		;!! - hidden item sprite: 'W2' half for signature (no longer used)
		dta		%00000000	;$00
		dta		%00000111	;$07
		dta		%00000100	;$04
		dta		%01110111	;$77
		dta		%01110001	;$71
		dta		%01110101	;$75
		dta		%01010111	;$57
		dta		%01010000	;$50
		dta		%00000000	;$00

		;hmove set
		dta		$D6

		dta		$1C,$36,$1C,$49,$7F,$49,$1C,$3E,$00

		dta		$B9
		dta		$8A
		dta		$A1
		dta		$81
		dta		$00,$00,$00,$00,$00,$00,$1C,$70,$07,$70,$0E,$00
		dta		$CF
		dta		$A6
		dta		$00
		dta		$81
		dta		$77,$36,$14,$22
		dta		$AE
		dta		$14,$36,$77,$00
		dta		$BF
		dta		$CE
		dta		$00
		dta		$EF
		dta		$81
		dta		$00,$00,$00,$00,$00,$00,$68,$2F,$0A,$0C,$08,$00
		dta		$80,$81
		dta		$00,$00

		;!! - hidden item sprite: 'HS' half for signature (no longer used)
		dta		%00000111	;$07
		dta		%00000001	;$01
		dta		%01010111	;$57
		dta		%01010100	;$54
		dta		%01110111	;$77
		dta		%01010000	;$50
		dta		%01010000	;$50
		dta		%00000000	;$00
		
		dta		$00,$00
		dta		$00
	
;room 1 (marketplace) display list
LFF51:	;sheik in black clothes
		dta		$80
		dta		$7E
		dta		$86,$80,$A6
		dta		$5A,$7E
		dta		$80
		dta		$7F
		dta		$00

		;flute
		dta		$B1,$F9,$F6
		dta		%00000110	;$06
		dta		%00011110	;$1E
		dta		%00010010	;$12
		dta		%00011110	;$1E
		dta		%00010010	;$12
		dta		%00011110	;$1E
		dta		%01111111	;$7F
		dta		$00

		dta		$B9
		dta		$00
		dta		$D4
		dta		$00

		;basket 1
		dta		$81
		dta		%00011100	;$1C
		dta		%00101010	;$2A
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%00010100	;$14
		dta		%00111110	;$3E
		dta		$00

		;basket 2
		dta		$C1,$E6
		dta		$00,$00,$00,$81
		dta		%01111111	;$7F
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%00111110	;$3E
		dta		$00

		;sheik in white clothes
		dta		$B9,$86,$91,$81
		dta		$7E
		dta		$80,$86,$A6
		dta		$5A,$7E
		dta		$86
		dta		$7F,$00
		dta		$D6

		;draw parachute
		dta		%01110111	;$77
		dta		%01110111	;$77
		dta		$80,$D6
		dta		%01110111	;$77
		dta		$00

		;third basket
		dta		$C1,$B6,$A1,$81

		dta		%00011100	;$1C
		dta		%00101010	;$2A
		dta		%01010101	;$55
		dta		%00101010	;$2A
		dta		%00010100	;$14
		dta		%00111110	;$3E

		dta		$00,$00,$00
		dta		$00
		
;room 2 (entrance room) display list
LFFA1:	dta			$00,$86,$70,$5F,$72,$05,$00,$C1,$00,$81,$84,$1F,$89,$F9,$91
		dta		$F9,$18,$81,$80,$1C,$1F,$F1,$7F,$89,$F9,$F9,$89,$91,$F1,$F9,$89
		dta		$F9,$F9,$89,$F9,$89,$F9,$89,$3F,$91,$81,$70,$40,$84,$89,$7E,$F9
		dta		$91,$F9,$F1,$00,$B9,$84,$00,$00,$89,$38,$78,$7B,$F9,$89,$F9,$6F
		dta		$00,$B1,$92,$E9,$F9,$00,$30,$30,$30,$E9,$30,$30,$30,$10,$00,$00
		dta		$00,$00
LFFF2: .byte $A4,$15,$95,$06,$86,$F7
LFFF8: .byte $00,$00,$00,$F0,$00,$F0,$00,$F0

		run		main

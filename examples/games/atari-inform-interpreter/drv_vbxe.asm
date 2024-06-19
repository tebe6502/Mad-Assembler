;vbxe simple 80x24 driver, shortened example code from KMK
;this more or less emulates standard ANTIC gr.2, just with double the columns

graphics_start_page = $c0

SCREEN_LINES_TOTAL = 24
SCREEN_WIDTH_CHARS = 80
SCREEN_WIDTH_BYTES = SCREEN_WIDTH_CHARS * 2
SCREEN_WIDTH_CHARS_PRINTED = SCREEN_WIDTH_CHARS-1

;WARNING all of these may be used only in vbxe_init as they overlap with interpreter code!
SRCV = $80
DSTV = $82
BPTR = $84

;VBXE MEMAC B bank numbers
MEMAC_B_BANK = $00

;addresses at Atari side
VBXE_AT_SCR_ADDR	= $4000
VBXE_AT_BCB_ADDR	= $5400
VBXE_AT_XDL_ADDR	= $5480
VBXE_AT_FONT_ADDR	= $6000

;adresses at VBXE side
VBXE_INT_SCR_ADDR = VBXE_AT_SCR_ADDR-$4000
VBXE_INT_BCB_ADDR = VBXE_AT_BCB_ADDR-$4000
VBXE_INT_XDL_ADDR = VBXE_AT_XDL_ADDR-$4000
VBXE_INT_FONT_ADDR = VBXE_AT_FONT_ADDR-$4000
VBXE_INT_FONT_OFFS = VBXE_INT_FONT_ADDR/8

; other constants
BCB_SIZE = 21

; VBXE core registers
;
; read
;
VBXE_CR_VERSION		= $40		;core version ($10 = FX)
VBXE_CR_REVISION	= $41		;core revision
VBXE_CR_COLDETECT	= $4a		;collision detect
VBXE_CR_BLT_BUSY	= $53		;blitter status/busy
VBXE_CR_IRQ_STAT	= $54		;IRQ status
;
; write
;
VBXE_CR_VCTL		= $40		;video control
VBXE_CR_XDL_ADR0	= $41		;XDL pointer
VBXE_CR_XDL_ADR1	= $42		;
VBXE_CR_XDL_ADR2	= $43		;

VBXE_CR_CSEL		= $44		;colour select
VBXE_CR_PSEL		= $45		;colour select
VBXE_CR_CR		= $46		;component R
VBXE_CR_CG		= $47		;component G
VBXE_CR_CB		= $48		;component B

VBXE_CR_COLMASK		= $49		;collision mask
VBXE_CR_COLCLR		= $4a		;collision clear
;
VBXE_CR_BLT_ADR0	= $50		;BCB pointer
VBXE_CR_BLT_ADR1	= $51		;
VBXE_CR_BLT_ADR2	= $52		;
VBXE_CR_BLT_START	= $53		;blitter start
VBXE_CR_IRQ_CTL		= $54		;IRQ control
VBXE_CR_PRIOR_0		= $55		;priority 0
VBXE_CR_PRIOR_1		= $56		;priority 1
VBXE_CR_PRIOR_2		= $57		;priority 2
VBXE_CR_PRIOR_3		= $58		;priority 3
;
VBXE_CR_MB_CTL		= $5d		;MEMAC B control
VBXE_CR_MA_CTL		= $5e		;MEMAC A control
VBXE_CR_MA_BSEL		= $5f		;MEMAC A bank selection

;--------------------------------------------------------------------------

graphics_init:
		;VBXE reset by writing to any D080-D0FF addresses
		STA	$d080

		.if EXTMEM
		LDA	#$FF
		STA	PORTB
		.endif

		;enable MEMAC B bank 0
		;window $4000-$7FFF is opened for writing
		LDY	#VBXE_CR_MB_CTL
		LDA	#MEMAC_B_BANK+$80
		JSR	vbxe_write

		;copy all BCB blocks
		LDY	#bcbs_end-bcbs_start-1
?b0:		LDA	bcbs_start,Y
		STA	VBXE_AT_BCB_ADDR,Y
		DEY
		BPL	?b0

		;copy XDL
		LDY	#xdl0_end-xdl0-1
?b1:		LDA	xdl0,Y
		STA	VBXE_AT_XDL_ADDR,Y
		DEY
		BPL	?b1

		;copy font
		LDA	#<VBXE_AT_FONT_ADDR
		STA	dstv
		LDA	#>VBXE_AT_FONT_ADDR
		STA	dstv+1

		LDX	#$00
		STX	srcv

		CLC

?floop:		LDA	CHBAS
		ADC	int2asc,X
		STA	srcv+1

		LDY	#$00
?fp0:		LDA	(srcv),Y
		STA	(dstv),Y
		INY
		BNE	?fp0

		INC	dstv+1

		INX
		CPX	#$04		;atari font is 4 pages
		BCC	?floop

		;disable MEMAC B bank 0
		LDY	#VBXE_CR_MB_CTL
		LDA	#$00
		JSR	vbxe_write

		;make font for ASCII >= 128
		LDX	#[bcb_invert_font-bcbs_start]	;offset to bcb_font
		JSR	vbxe_blitter_execute

		;clear screen (must go before palette initialization)
		JSR	graphics_cls

		;set colors
		LDA	#$00	;col
		LDX	#$01	;pal
		JSR	set_color_white
		LDA	#$80	;col
		LDX	#$01	;pal
		JSR	set_color_blue
		LDA	#$00	;col
		LDX	#$00	;pal
		JSR	set_color_blue

		;initialize display - turns off ANTIC
		LDA	#$00
		STA	SDMCTL

		;install XDL
		LDY	#VBXE_CR_XDL_ADR0
?sxdla:		LDA	vbxe_xdl_v-VBXE_CR_XDL_ADR0,Y
		JSR	vbxe_write
		INY
		CPY	#VBXE_CR_XDL_ADR2+1
		BCC	?sxdla

		;display enable
		;0 - trans15
		;1 - no transparency
		;1 - extra colour
		;1 - xdl enable
		LDA	#%00000111
		LDY	#VBXE_CR_VCTL
		JSR	vbxe_write

		RTS

vbxe_xdl_v:	.LONG	VBXE_INT_XDL_ADDR

;converts blocks of original Atari fonts to map on ASCII (ie. Internal2Ascii conversion)
int2asc:	.BYTE	2,0,1,3


;--------------------------------------------------------------------------
	
		;XDL for standard text mode
xdl0:
		;        76543210
		.BYTE	%01110100		;bit 2 - overlay off, bit 4 - map off, bit 5 - repeat, bit6 - set screen address
		.BYTE	%00001001		;bit 0 - character base, bit 3 - palette/width/priority
		.BYTE	24			;24 empty scanlines at top (ovl off/map off)

		.LONG	VBXE_INT_SCR_ADDR	;ovadr: screen address
		.WORD	160			;line length (80 chars + 80 attributes)

		.BYTE	>VBXE_INT_FONT_OFFS	;character base

		;        76543210
		.BYTE	%00010001		;PF palette 0, OVL palette 1, normal width (640 pixels)
		.BYTE	%11110000		;priority: overlay over PF, under PM

		;new command
		;        76543210
		.BYTE	%00100001		;bit 0 - text mode; bit 5 - repeat
		.BYTE	%10000000		;bit 7 - XDL end, wait for VSYNC
		.BYTE	[SCREEN_LINES_TOTAL*8-1];repeat in 192 consecutive lines
xdl0_end = *

bcbs_start:

bcb_invert_font:
		;copies block of original font, inverted (see xor_mask)
		.long VBXE_INT_FONT_ADDR ;src adr
		.word 512	;src step y
		.byte 1		;src step x
		.long VBXE_INT_FONT_ADDR+$0400 ;dst adr
		.word 512	;dst step y
		.byte 1		;dst step x
		.word 512-1	;width
		.byte 2-1	;height
		.byte $ff	;and mask
		.byte $ff	;xor mask
		.byte $00	;collision mask
		.byte 0		;zoom
		.byte 0		;pattern
		.byte 0		;blitter mode copy

bcb_clear_screen:
		;clear screen and set attributes
		.long VBXE_INT_BCB_ADDR+pattern_clear_screen-bcbs_start	;src adr
		.word 0		;src step y
		.byte 1		;src step x
		.long VBXE_INT_SCR_ADDR ;dst adr
		.word 160	;dst step y
		.byte 1		;dst step x
		.word 160-1	;width
		.byte [SCREEN_LINES_TOTAL-1]	;height
		.byte $FF	;and mask
		.byte $00	;xor mask
		.byte $00	;collision mask
		.byte 0		;zoom
		.byte $81	;pattern ($80 - used, width $1 = 2)
		.byte 0		;blitter mode copy

bcb_scroll_one_line:
		;scroll txt screen up
		.long VBXE_INT_SCR_ADDR+160	;0-1-2 src adr
		.word 160		;3-4 src step y
		.byte 1			;5 src step x
		.long VBXE_INT_SCR_ADDR	;6-7-8 dst adr
		.word 160		;9-10 dst step y
		.byte 1			;11 dst step x
		.word 160-1		;12-13 width
		.byte [SCREEN_LINES_TOTAL-2]	;14 height in lines
		.byte $ff	;and mask
		.byte $00	;xor mask
		.byte $00	;collision mask
		.byte 0		;zoom
		.byte 0		;pattern
		.byte 8		;blitter mode copy + NEXT

		;clear bottom line and set attributes
		.long VBXE_INT_BCB_ADDR+pattern_clear_screen-bcbs_start		;src adr
		.word 0		;src step y
		.byte 1		;src step x
		.long VBXE_INT_SCR_ADDR+((SCREEN_LINES_TOTAL-1)*160) ;dst adr
		.word 160	;dst step y
		.byte 1		;dst step x
		.word 160-1	;width
		.byte 1-1	;height
		.byte $ff	;and mask
		.byte $00	;xor mask
		.byte $00	;collision mask
		.byte 0		;zoom
		.byte $81	;2-byte pattern
		.byte 0		;blitter mode copy

pattern_clear_screen:
		.BYTE	' '	;character
		.BYTE	$00	;attribute
bcbs_end:

line_addr_00 = VBXE_AT_SCR_ADDR + $00 * SCREEN_WIDTH_BYTES
line_addr_01 = VBXE_AT_SCR_ADDR + $01 * SCREEN_WIDTH_BYTES
line_addr_02 = VBXE_AT_SCR_ADDR + $02 * SCREEN_WIDTH_BYTES
line_addr_03 = VBXE_AT_SCR_ADDR + $03 * SCREEN_WIDTH_BYTES
line_addr_04 = VBXE_AT_SCR_ADDR + $04 * SCREEN_WIDTH_BYTES
line_addr_05 = VBXE_AT_SCR_ADDR + $05 * SCREEN_WIDTH_BYTES
line_addr_06 = VBXE_AT_SCR_ADDR + $06 * SCREEN_WIDTH_BYTES
line_addr_07 = VBXE_AT_SCR_ADDR + $07 * SCREEN_WIDTH_BYTES
line_addr_08 = VBXE_AT_SCR_ADDR + $08 * SCREEN_WIDTH_BYTES
line_addr_09 = VBXE_AT_SCR_ADDR + $09 * SCREEN_WIDTH_BYTES
line_addr_0A = VBXE_AT_SCR_ADDR + $0A * SCREEN_WIDTH_BYTES
line_addr_0B = VBXE_AT_SCR_ADDR + $0B * SCREEN_WIDTH_BYTES
line_addr_0C = VBXE_AT_SCR_ADDR + $0C * SCREEN_WIDTH_BYTES
line_addr_0D = VBXE_AT_SCR_ADDR + $0D * SCREEN_WIDTH_BYTES
line_addr_0E = VBXE_AT_SCR_ADDR + $0E * SCREEN_WIDTH_BYTES
line_addr_0F = VBXE_AT_SCR_ADDR + $0F * SCREEN_WIDTH_BYTES
line_addr_10 = VBXE_AT_SCR_ADDR + $10 * SCREEN_WIDTH_BYTES
line_addr_11 = VBXE_AT_SCR_ADDR + $11 * SCREEN_WIDTH_BYTES
line_addr_12 = VBXE_AT_SCR_ADDR + $12 * SCREEN_WIDTH_BYTES
line_addr_13 = VBXE_AT_SCR_ADDR + $13 * SCREEN_WIDTH_BYTES
line_addr_14 = VBXE_AT_SCR_ADDR + $14 * SCREEN_WIDTH_BYTES
line_addr_15 = VBXE_AT_SCR_ADDR + $15 * SCREEN_WIDTH_BYTES
line_addr_16 = VBXE_AT_SCR_ADDR + $16 * SCREEN_WIDTH_BYTES
line_addr_17 = VBXE_AT_SCR_ADDR + $17 * SCREEN_WIDTH_BYTES

videomem_ptrs_lo:
		.BYTE <line_addr_00
		.BYTE <line_addr_01
		.BYTE <line_addr_02
		.BYTE <line_addr_03
		.BYTE <line_addr_04
		.BYTE <line_addr_05
		.BYTE <line_addr_06
		.BYTE <line_addr_07
		.BYTE <line_addr_08
		.BYTE <line_addr_09
		.BYTE <line_addr_0A
		.BYTE <line_addr_0B
		.BYTE <line_addr_0C
		.BYTE <line_addr_0D
		.BYTE <line_addr_0E
		.BYTE <line_addr_0F
		.BYTE <line_addr_10
		.BYTE <line_addr_11
		.BYTE <line_addr_12
		.BYTE <line_addr_13
		.BYTE <line_addr_14
		.BYTE <line_addr_15
		.BYTE <line_addr_16
		.BYTE <line_addr_17

videomem_ptrs_hi:
		.BYTE >line_addr_00 
		.BYTE >line_addr_01 
		.BYTE >line_addr_02 
		.BYTE >line_addr_03 
		.BYTE >line_addr_04 
		.BYTE >line_addr_05 
		.BYTE >line_addr_06 
		.BYTE >line_addr_07 
		.BYTE >line_addr_08 
		.BYTE >line_addr_09 
		.BYTE >line_addr_0A 
		.BYTE >line_addr_0B 
		.BYTE >line_addr_0C 
		.BYTE >line_addr_0D 
		.BYTE >line_addr_0E 
		.BYTE >line_addr_0F 
		.BYTE >line_addr_10 
		.BYTE >line_addr_11 
		.BYTE >line_addr_12 
		.BYTE >line_addr_13 
		.BYTE >line_addr_14 
		.BYTE >line_addr_15 
		.BYTE >line_addr_16 
		.BYTE >line_addr_17


;--------------------------------------------------------------------------

;input: nothing
;output: Z=1 is detected, Z=0 undetected
vbxe_detect:
		.if EXTMEM
		LDA	#$FF
		STA	PORTB
		.endif

		JSR	vbxe_detect_internal
		BCC	?gver
		LDA	#$01
		RTS

		;tests 1.2x core
?gver:		LDX	#$01
getver:		LDA	VBXE_CR_VERSION+$d600,X
		AND	#$70
		CMP	#$20
		RTS

;--------------------------------------------------------------------------

vbxe_detect_internal:
		JSR	?try
		BCC	?fnd

		;patch for $d7
		;there must be all vbxe reg touches
		INC	getver+2

		INC	vbxe_write+2

		INC	vbxe_blitter_wait_for_completion+2

		INC	vbxe_put_char_fix1+2
		INC	vbxe_put_char_fix2+2

?try:		LDX	$4000

		LDY	#VBXE_CR_MB_CTL
		LDA	#$80
		JSR	vbxe_write

		CPX	$4000
		BNE	?fnd
		JSR	?clr
		inx
		STX	$4000

		LDA	#$80
		JSR	vbxe_write
		CPX	$4000
		BNE	?fnd
		SEC
		BCS	?clr
?fnd:		CLC
?clr:		LDA	#$00

vbxe_write:	STA	$D600,y
		RTS

;--------------------------------------------------------------------------

graphics_put_char:
		;A char
		TAX

		.if EXTMEM
		LDA	#$FF
		STA	PORTB
		.endif

		LDY	ROWCRS	;cursor line
		LDA	videomem_ptrs_lo,Y
		STA	vpca+1
		LDA	videomem_ptrs_hi,Y
		STA	vpca+2	;beginning of line

		LDA	COLCRS
		ASL		;cursor offset * 2
		TAY
		TXA

		LDX	#$80	;turn on bank
vbxe_put_char_fix1:
		STX	VBXE_CR_MB_CTL+$d600
vpca:		STA.a	$0000,Y	;store character
		LDX	#$00	;turn off bank
vbxe_put_char_fix2:
		STX	VBXE_CR_MB_CTL+$d600
		RTS

;--------------------------------------------------------------------------

graphics_cls:
		LDX	#0
		LDY	#SCREEN_LINES_TOTAL

;in X first line
;in Y line after
graphics_cls_partial:
		TYA
		PHA

		.if EXTMEM
		LDA	#$FF
		STA	PORTB
		.endif

		;turn on vbxe memory
		LDA	#$80
		LDY	#VBXE_CR_MB_CTL
		JSR	vbxe_write

		LDA	videomem_ptrs_lo,x
		STA	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+6
		LDA	videomem_ptrs_hi,x
		SEC
		SBC	#>VBXE_AT_SCR_ADDR			;converts upper byte to be valid internally
		STA	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+7

		STX	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+14

		PLA
		SEC
		SBC	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+14
		STA	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+14
		DEC	bcb_clear_screen-bcbs_start+VBXE_AT_BCB_ADDR+14

		;turn off vbxe memory
		LDA	#$00
		LDY	#VBXE_CR_MB_CTL
		JSR	vbxe_write

		;execute blitter, clearing the part of the screen
		LDX	#[bcb_clear_screen-bcbs_start]	;offset to bcb_clear_screen
		JMP	vbxe_blitter_execute

;--------------------------------------------------------------------------

;X - palette
;A - color
set_color_white:
		PHA

		LDY	#VBXE_CR_PSEL	;PSEL - palette select
		TXA
		JSR	vbxe_write

		PLA
		LDY	#VBXE_CR_CSEL	;CSEL - color number
		JSR	vbxe_write

		INY
		INY
		LDA	#$B7
		JSR	vbxe_write	;MB1	- R
		INY
		LDA	#$DD
		JSR	vbxe_write	;MB2	- G
		INY
		LDA	#$EE
		JSR	vbxe_write	;MB3	- B
		RTS

;--------------------------------------------------------------------------

;X - palette
;A - color
set_color_blue:
		PHA

		LDY	#VBXE_CR_PSEL	;PSEL - palette select
		TXA
		JSR	vbxe_write

		PLA
		LDY	#VBXE_CR_CSEL	;CSEL - color number
		JSR	vbxe_write

		INY
		INY
		LDA	#$06
		JSR	vbxe_write	;MB1	- R
		INY
		LDA	#$63
		JSR	vbxe_write	;MB2	- G
		INY
		LDA	#$8f
		JSR	vbxe_write	;MB3	- B
		RTS

;--------------------------------------------------------------------------

;X - offset of BCB
vbxe_blitter_execute:

		JSR	vbxe_blitter_wait_for_completion

		;copies internal 3-byte address of BCB to the respective blitter register
		LDY	#VBXE_CR_BLT_ADR0
		TXA
		CLC
		ADC	#<VBXE_INT_BCB_ADDR
		JSR	vbxe_write

		LDA	#>VBXE_INT_BCB_ADDR
		ADC	#00
		LDY	#VBXE_CR_BLT_ADR1
		JSR	vbxe_write

		LDA	#(VBXE_INT_BCB_ADDR/$10000)
		ADC	#00
		LDY	#VBXE_CR_BLT_ADR2
		JSR	vbxe_write

		;starts blitter operation
		INY
		LDA	#1
		JSR	vbxe_write

vbxe_blitter_wait_for_completion:
		LDA	$d600+VBXE_CR_BLT_BUSY
		BNE	vbxe_blitter_wait_for_completion
		RTS

;--------------------------------------------------------------------------

;X - from which line to bottom
graphics_scroll_partially:

		.if EXTMEM
		LDA	#$FF
		STA	PORTB
		.endif

		;turns on memory
		LDA	#$80
		LDY	#VBXE_CR_MB_CTL
		JSR	vbxe_write

		;still X = line	
		LDA	videomem_ptrs_lo,x
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+6
		LDA	videomem_ptrs_hi,x
		SEC
		SBC	#>VBXE_AT_SCR_ADDR
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+7
		LDA	videomem_ptrs_lo+1,x
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR
		LDA	videomem_ptrs_hi+1,x
		SEC
		SBC	#>VBXE_AT_SCR_ADDR
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+1
	
		TXA
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+14
		LDA	#[SCREEN_LINES_TOTAL-2]
		SEC
		SBC	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+14
		STA	bcb_scroll_one_line-bcbs_start+VBXE_AT_BCB_ADDR+14

		;turn off memory
		LDA	#$00
		LDY	#VBXE_CR_MB_CTL
		JSR	vbxe_write

		;and scrolls one line
		LDX	#[bcb_scroll_one_line-bcbs_start]
		JSR	vbxe_blitter_execute
		RTS

;--------------------------------------------------------------------------

inverted_MORE_string:
		DTA '[MORE]'*
		more_length = * - inverted_MORE_string

graphics_display_more:
		LDA	ROWCRS
		PHA
		LDA	COLCRS
		PHA

		LDA	#SCREEN_LINES_TOTAL-1
		STA	ROWCRS
		LDY	#0
		STY	COLCRS

op0nl_1:	TYA
		PHA

		LDA	inverted_MORE_string,Y
		JSR	graphics_put_char
		INC	COLCRS
		PLA
		TAY
		INY
		CPY	#more_length
		BNE	op0nl_1
		PLA
		STA	COLCRS
		PLA
		STA	ROWCRS
		RTS

graphics_erase_more:
		LDA	ROWCRS
		PHA
		LDA	COLCRS
		PHA

		LDA	#SCREEN_LINES_TOTAL-1
		STA	ROWCRS
		LDY	#0
		STY	COLCRS

op0nl_2:	TYA
		PHA

		LDA	#' '
		JSR	graphics_put_char
		INC	COLCRS
		PLA
		TAY
		INY
		CPY	#more_length
		BNE	op0nl_2
		PLA
		STA	COLCRS
		PLA
		STA	ROWCRS

		RTS

;--------------------------------------------------------------------------

graphics_pmg_cursor_on .macro
		LDA	COLCRS		; moves	cursor
		ASL
		CLC
		ADC	#$30
		STA	HPOSM0	;moves cursor based on COLCRS

		LDA	ROWCRS
		ASL
		ASL
		ASL
		CLC
		ADC	#40
		TAY		;converts ROWCRS to byte to display pmg cursor

		LDA	#3
		STA	pmg_cursor_curr_shape_f8
		STA	pmg_missiles_mem,Y
.endm

graphics_pmg_cursor_xor .macro
		LDA	pmg_cursor_curr_shape_f8
		EOR	#3
		STA	pmg_cursor_curr_shape_f8
		STA	pmg_missiles_mem,Y
.endm

graphics_pmg_cursor_off .macro
		LDA	ROWCRS
		ASL
		ASL
		ASL
		CLC
		ADC	#40
		TAY		;converts ROWCRS to byte to display pmg cursor
		LDA	#0
		STA	pmg_missiles_mem,Y
.endm

graphics_pmg_color = $0C
graphics_pmg_size = 0
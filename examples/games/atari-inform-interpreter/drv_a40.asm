;original Atari 40col gr0 driver

SCREEN_LINES_TOTAL = 24
SCREEN_WIDTH_CHARS = 40
SCREEN_WIDTH_BYTES = SCREEN_WIDTH_CHARS
SCREEN_WIDTH_CHARS_PRINTED = SCREEN_WIDTH_CHARS-1
START_OF_LAST_LINE = [video_ram + (SCREEN_LINES_TOTAL-1) * SCREEN_WIDTH_CHARS]

video_ram = $c000 - ( screen_lines_total * screen_width_bytes )
graphics_start_page = >video_ram

; ---------------------------------------------------------------------------
dlist:		.BYTE $70
		.BYTE $70
		.if ZVER = 3
		.BYTE $60
		.else
		.BYTE $70
		.endif

		.BYTE $40+2
		.WORD video_ram

		.if ZVER = 3
		.BYTE $10
		.endif

		:[SCREEN_LINES_TOTAL-1] .BYTE 2	;one line is above in $42 instruction

		.BYTE $41
		.WORD dlist

; ---------------------------------------------------------------------------

line_addr_00 = video_ram + $00 * SCREEN_WIDTH_CHARS
line_addr_01 = video_ram + $01 * SCREEN_WIDTH_CHARS
line_addr_02 = video_ram + $02 * SCREEN_WIDTH_CHARS
line_addr_03 = video_ram + $03 * SCREEN_WIDTH_CHARS
line_addr_04 = video_ram + $04 * SCREEN_WIDTH_CHARS
line_addr_05 = video_ram + $05 * SCREEN_WIDTH_CHARS
line_addr_06 = video_ram + $06 * SCREEN_WIDTH_CHARS
line_addr_07 = video_ram + $07 * SCREEN_WIDTH_CHARS
line_addr_08 = video_ram + $08 * SCREEN_WIDTH_CHARS
line_addr_09 = video_ram + $09 * SCREEN_WIDTH_CHARS
line_addr_0A = video_ram + $0A * SCREEN_WIDTH_CHARS
line_addr_0B = video_ram + $0B * SCREEN_WIDTH_CHARS
line_addr_0C = video_ram + $0C * SCREEN_WIDTH_CHARS
line_addr_0D = video_ram + $0D * SCREEN_WIDTH_CHARS
line_addr_0E = video_ram + $0E * SCREEN_WIDTH_CHARS
line_addr_0F = video_ram + $0F * SCREEN_WIDTH_CHARS
line_addr_10 = video_ram + $10 * SCREEN_WIDTH_CHARS
line_addr_11 = video_ram + $11 * SCREEN_WIDTH_CHARS
line_addr_12 = video_ram + $12 * SCREEN_WIDTH_CHARS
line_addr_13 = video_ram + $13 * SCREEN_WIDTH_CHARS
line_addr_14 = video_ram + $14 * SCREEN_WIDTH_CHARS
line_addr_15 = video_ram + $15 * SCREEN_WIDTH_CHARS
line_addr_16 = video_ram + $16 * SCREEN_WIDTH_CHARS
line_addr_17 = video_ram + $17 * SCREEN_WIDTH_CHARS

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

; ---------------------------------------------------------------------------

graphics_init:
		LDA	#$94
		STA	COLOR2
		STA	COLOR4

		LDA	#<dlist
		STA	SDLSTL
		LDA	#>dlist
		STA	SDLSTH

		RTS

; ---------------------------------------------------------------------------

ASC2INT:	.BYTE %01000000
		.BYTE %00000000
		.BYTE %00100000
		.BYTE %01100000

;in A is atascii character
graphics_put_char:
		TAY
		ROL
		ROL
		ROL
		ROL
		AND	#03
		TAX
		TYA
		AND	#%10011111
		ORA	ASC2INT,X
		;right now we have internal code in hands
		PHA
		LDX	ROWCRS
		LDA	videomem_ptrs_lo,X
		STA	gpc_ptch1+1
		LDA	videomem_ptrs_hi,X
		STA	gpc_ptch1+2
		LDY	COLCRS
		PLA
gpc_ptch1:	STA.a	$0000,Y
		RTS

; ---------------------------------------------------------------------------

;in X is from
graphics_scroll_partially:

loop_over_screen:
		CPX	#[SCREEN_LINES_TOTAL-1]
		BEQ	clear_last_line

		LDA	videomem_ptrs_lo,X
		STA	a4sp_2+1
		LDA	videomem_ptrs_hi,X
		STA	a4sp_2+2

		INX

		LDA	videomem_ptrs_lo,X
		STA	a4sp_1+1
		LDA	videomem_ptrs_hi,X
		STA	a4sp_1+2

		LDY	#[SCREEN_WIDTH_CHARS-1]

loop_over_row:
a4sp_1:		LDA.a	$0000,Y
a4sp_2:		STA.a	$0000,Y
		DEY
		BPL	loop_over_row
		BMI	loop_over_screen

clear_last_line:
		LDX	#SCREEN_WIDTH_CHARS
		LDA	#0

loop_clearing_last_line:
		STA	START_OF_LAST_LINE,X
		DEX
		BPL	loop_clearing_last_line
		RTS

; ---------------------------------------------------------------------------

a40_line:	.BYTE 0
graphics_cls:
		LDX #0
		LDY #SCREEN_LINES_TOTAL

graphics_cls_partial:
		STY	a40_line

a4cp_2:
		LDA	videomem_ptrs_lo,X
		STA	a4cp_1+1
		LDA	videomem_ptrs_hi,X
		STA	a4cp_1+2
		LDY	#SCREEN_WIDTH_CHARS
		LDA	#0
a4cp_1:		STA.a	$0000,Y
		DEY
		BPL 	a4cp_1

		INX
		CPX	a40_line
		BNE	a4cp_2

a4cp_3:		RTS

; ---------------------------------------------------------------------------

inverted_MORE_string:
	.if CZ_LANG
			DTA d 'V)ce$'*
	.else
			DTA d '[MORE]'*
	.endif
	more_length = * - inverted_MORE_string

graphics_display_more:
		LDX	#more_length - 1
loc_1D3A:
		LDA	inverted_MORE_string,X
		STA	START_OF_LAST_LINE,X
		DEX
		BPL	loc_1D3A
		RTS

graphics_erase_more:
		LDX	#more_length - 1
		LDA	#0
loc_1D53:
		STA	START_OF_LAST_LINE,X
		DEX
		BPL	loc_1D53
		RTS

;z3 has different dlist with one empty scanline, hence the difference
.if ZVER = 3
pmg_line_move = 40
.else
pmg_line_move = 39
.endif

graphics_pmg_cursor_on .macro
		LDA	COLCRS			;moves cursor
		ASL
		ASL
		CLC
		ADC	#$30
		STA	HPOSM0			;moves cursor based on COLCRS

		LDA	ROWCRS
		ASL
		ASL
		ASL
		CLC
		ADC	#pmg_line_move
		TAY				;converts ROWCRS to byte to display pmg cursor

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
		ADC	#pmg_line_move
		TAY		;converts ROWCRS to byte to display pmg cursor
		LDA	#0
		STA	pmg_missiles_mem,Y
.endm

graphics_pmg_color = $0C
graphics_pmg_size = 1

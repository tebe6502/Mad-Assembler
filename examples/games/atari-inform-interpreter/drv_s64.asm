;basic s64 driver
;uses fonts with letters in RIGHT 5 bits (ie. 3 left are 0)
;creates gr.8 dlist with LMS every 8th line to speed up scrolling
;font 1 blatantly stolen from SDX CON64.SYS driver

;letter is 5x8 bits

;if offset is <= 3
;masks would be
;0 - 00000111
;1 - 10000011
;2 - 11000001
;3 - 11100000
;and then oring the left-shifted char
;else
;4 - 11110000 01111111
;5 - 11111000 00111111
;6 - 11111100 00011111
;7 - 11111110 00001111
;and then oring the right-shifted char. This would need to be 2 byte operation

;64 chars = 8x5 byte blocks = 40 bytes

;block:
;char 0 -pixels 00-04 - byte 0, shift -3
;char 1 -pixels 05-09 - byte 0-1, shift +2
;char 2 -pixels 10-14 - byte 1, shift -1
;char 3 -pixels 15-19 - byte 1-2, shift +4
;char 4 -pixels 20-24  -byte 2-3, shift +1
;char 5 -pixels 25-29 - byte 3, shift -2
;char 6	-pixels 30-34 - byte 3-4, shift +3
;char 7 -pixels 35-39 - byte 4, shift 0

;0       1       2       3       4
;0123456701234567012345670123456701234567
;XXXXX     XXXXX     XXXXX     XXXXX
;     XXXXX     XXXXX     XXXXX     XXXXX

;rest is completely same as in s80 driver

SCREEN_WIDTH_BYTES = SCREEN_WIDTH_CHARS * 5 / 8
LAST_DLIST_LMS = DLIST + 3 + 23*10 + 1
DLIST = $BF00
GMEM = $A100

SCREEN_LINES_TOTAL = 24
SCREEN_WIDTH_CHARS = 64
SCREEN_WIDTH_CHARS_PRINTED = SCREEN_WIDTH_CHARS-1
graphics_start_page = >GMEM

font1:
	ins "drv_s64_fnt1.fnt"

font3:
	ins "drv_s64_fnt3.fnt"

line_table: :screen_lines_total .BYTE 0

; ---------------------------------------------------------------------------

s64_last_line:	.BYTE 0
graphics_cls:
		LDX #0
		LDY #SCREEN_LINES_TOTAL

graphics_cls_partial:
		STY	s64_last_line

s6cp_2:
		TXA
		PHA

		LDA	line_table,X
		TAY
		LDA	DLIST, Y
		STA	s6cp_1+1
		LDA	DLIST+1, Y
		STA	s6cp_1+2

		LDX	#$01
		LDY	#$40
		LDA	#$00
s6cp_1:		STA.a	$0000
		INC	s6cp_1+1
		BNE	s6cp_4
		INC	s6cp_1+2
s6cp_4:
		DEY
		BNE	s6cp_1
		DEX
		BPL	s6cp_1
	
		PLA
		TAX

		INX
		CPX	s64_last_line
		BNE	s6cp_2

s6cp_3:		RTS

; ---------------------------------------------------------------------------

graphics_init:
		;dlist creation
		LDY	#0
		LDX	#3
		LDA	#$70
dl1:		STA	DLIST, Y
		INY
		DEX
		BNE	dl1

		LDX	#0
dl3:		TXA
		PHA

		LDA	#$40+$F
		STA	DLIST, Y
		INY
		TYA
		STA	line_table,X

gmp1:		LDA	#<GMEM
		STA	DLIST, Y
		INY
gmp2:		LDA	#>GMEM
		STA	DLIST, Y
		INY
		LDA	gmp1+1
		CLC
		ADC	#$40
		STA	gmp1+1
		LDA	gmp2+1
		ADC	#$01
		STA	gmp2+1

		LDX	#7
		LDA	#$F
dl2:		STA	DLIST, Y
		INY
		DEX
		BNE	dl2

		PLA
		TAX
		INX
		CPX	#SCREEN_LINES_TOTAL
		BNE     dl3
		LDA	#$41
		STA	DLIST, Y
		LDA	#<DLIST
		STA	DLIST+1,Y
		LDA	#>DLIST
		STA	DLIST+2,Y

		JSR	graphics_cls

		LDA	#$0C
		STA	COLOR3
		LDA	#$00
		STA	COLOR2

		LDA	#<DLIST
		STA	SDLSTL
		LDA	#>DLIST
		STA	SDLSTH

		RTS

; ---------------------------------------------------------------------------

;A - font number
graphics_set_font:
		CMP	#3
		BEQ	gsf1
		LDA	#<font1
		STA	gpc_ptch1+1
		LDA	#>font1
		STA	gpc_ptch2+1
		RTS
gsf1:		
		LDA	#<font3
		STA	gpc_ptch1+1
		LDA	#>font3
		STA	gpc_ptch2+1
		RTS

; ---------------------------------------------------------------------------

s64col2byte .macro col
		.BYTE [:col*5/8]
.endm

s64_cols:	:64 s64col2byte(:1)

s64_shift_m .macro shift
		.if :shift <= 0
			.BYTE -:shift
		.else
			.BYTE $80 | [:shift-1]
		.endif
.endm

s64_shifts:
		s64_shift_m( -3 )	;char 0 -pix 00-04 - byte 0, shift -3
		s64_shift_m( +2 )	;char 1 -pix 05-09 - byte 0-1, shift +2
		s64_shift_m( -1 )       ;char 2 -pix 10-14 - byte 1, shift -1  
		s64_shift_m( +4 )       ;char 3 -pix 15-19 - byte 1-2, shift +4
		s64_shift_m( +1 )       ;char 4 -pix 20-24  -byte 2-3, shift +1
		s64_shift_m( -2 )       ;char 5 -pix 25-29 - byte 3, shift -2  
		s64_shift_m( +3 )       ;char 6	-pix 30-34 - byte 3-4, shift +3
		s64_shift_m( -0 )       ;char 7 -pix 35-39 - byte 4, shift 0   

s64_mask_l:
		.BYTE %11100000 ;-0
		.BYTE %11000001 ;-1
		.BYTE %10000011 ;-2
		.BYTE %00000111 ;-3

s64_mask_r1:
		.BYTE %11110000 ;+1
		.BYTE %11111000 ;+2
		.BYTE %11111100 ;+3
		.BYTE %11111110 ;+4

s64_mask_r2:
		.BYTE %01111111 ;+1
		.BYTE %00111111 ;+2
		.BYTE %00011111 ;+3
		.BYTE %00001111 ;+4

s64_c1:	.BYTE 0
s64_c2: .BYTE 0

graphics_put_char:
		TAX
		BMI	s6pc4
		LDY	#0
		BEQ	s6pc3
s6pc4:		LDY	#%00011111
s6pc3:		STY	s6_ptch_inv+1

		AND	#$7F

		LDY	#$07
		STY	s6_ptch2+1

		LDY	#00
		STY	temp_gr2_lo

		ASL
		ROL	temp_gr2_lo
		ASL
		ROL	temp_gr2_lo
		ASL
		ROL	temp_gr2_lo

		CLC
gpc_ptch1:	ADC	#<font1
		STA	s6_ptch1+1
		LDA	temp_gr2_lo
gpc_ptch2:	ADC	#>font1
		STA	s6_ptch1+2
		;s6_ptch1 is now pointing to first byte of character data in respective font


		LDX	ROWCRS	;cursor line
		LDA	line_table,X
		TAX

		LDY	COLCRS
		LDA	DLIST, X
		CLC
		ADC	s64_cols,Y
		STA	temp_gr1_lo
		LDA	DLIST+1, X
		ADC	#0
		STA	temp_gr1_hi
		;in temp_gr1 we now have the exact byte address of first graphics memory byte

		LDA	COLCRS
		AND	#$07
		TAY
		LDA	s64_shifts, Y
		STA     s6_ptch3+1

		;this is main char printing loop
s6_ptch1:	LDA.a	$0000
s6_ptch_inv:	EOR	#$00
		STA	s64_c1
		;so right now, we have the character data in s61_c1, with correct inverse

s6_ptch3:	LDA	#$00
		BMI     s6_pn0

		;positive, so we're doing one-byte operation, shifting left
		TAY
		TAX
		CPY	#0
		BEQ	s6_pl2
s6_pl1:		ASL	s64_c1
		DEY
		BNE	s6_pl1
s6_pl2:		LDA	(temp_gr1_lo),Y
		AND	s64_mask_l, X
		ORA	s64_c1
		STA	(temp_gr1_lo),Y
		JMP	s6_nxt_line


s6_pn0:
		;negative, so we're doing two-byte operation, shifting right
		AND	#$7F
		TAY
		TAX
		INY
		LDA	#$00
		STA	s64_c2

s6_nl1:		LSR	s64_c1
                ROR	s64_c2
		DEY
		BNE	s6_nl1
s6_nl2:		LDA	(temp_gr1_lo),Y
		AND	s64_mask_r1,X
		ORA	s64_c1
		STA	(temp_gr1_lo),Y
		INY
		LDA	(temp_gr1_lo),Y		
		AND	s64_mask_r2,X
		ORA	s64_c2
		STA	(temp_gr1_lo),Y

s6_nxt_line:
s6_ptch2:	LDA	#$00
		BNE	s6_nxt_line2
		RTS

s6_nxt_line2:	DEC	s6_ptch2+1

		INC	s6_ptch1+1
		BNE	s6_nl2a
		INC	s6_ptch1+2
s6_nl2a:
		LDA	temp_gr1_lo
		CLC
		ADC	#SCREEN_WIDTH_BYTES
		STA	temp_gr1_lo
		BCC	s6_ptch1
		INC	temp_gr1_hi

		JMP	s6_ptch1

; ---------------------------------------------------------------------------

graphics_scroll:
		LDX	#0

;in X is from
graphics_scroll_partially:

		TXA
		PHA

		;this should clear top line
		TAY
		INY
		JSR	graphics_CLS_PARTIAL

		PLA
		PHA
		TAX

		LDA	line_table,X
		TAX
		LDA	DLIST,X
		STA     s6sp_ptch1+1
		LDA	DLIST+1,X
		STA	s6sp_ptch2+1

		PLA
		TAX

loop_over_screen:
		CPX	#[SCREEN_LINES_TOTAL-1]
		BEQ	s6sp_7
		TXA
		PHA

		LDA	line_table,X
		TAY
		LDA	line_table+1,X
		TAX

		LDA	DLIST,X
		STA	DLIST,Y
		LDA	DLIST+1,X
		STA	DLIST+1,Y

		PLA
		TAX
		INX
		JMP	loop_over_screen
s6sp_7:
s6sp_ptch1:	LDA	#$00
		STA	LAST_DLIST_LMS
s6sp_ptch2:	LDA	#$00
		STA	LAST_DLIST_LMS+1
		RTS

; ---------------------------------------------------------------------------
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
		LDA	#0
		STA	COLCRS
		LDY	#0

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
		LDA	#0
		STA	COLCRS
		LDY	#0

		LDY	#0

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

; ---------------------------------------------------------------------------
graphics_pmg_cursor_on .macro
		LDA	COLCRS		; moves	cursor
		ASL
		ASL
		CLC
		ADC	COLCRS
		LSR
		CLC
		ADC	#$30
		STA	HPOSM0	;moves cursor based on COLCRS

		LDA	ROWCRS
		ASL
		ASL
		ASL
		CLC
		ADC	#39
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
		ADC	#39
		TAY		;converts ROWCRS to byte to display pmg cursor
		LDA	#0
		STA	pmg_missiles_mem,Y
.endm

graphics_pmg_color = $0C
graphics_pmg_size = 0

;basic s80 driver
;uses 1KB font with each character definition in both upper and lower nibble
;creates gr.8 dlist with LMS every 8th line to speed up scrolling

SCREEN_WIDTH_BYTES = SCREEN_WIDTH_CHARS / 2
LAST_DLIST_LMS = DLIST + 3 + 23*10 + 1
DLIST = $BF00
GMEM = $A100

SCREEN_LINES_TOTAL = 24
SCREEN_WIDTH_CHARS = 80
SCREEN_WIDTH_CHARS_PRINTED = SCREEN_WIDTH_CHARS-1
graphics_start_page = >GMEM

font1:
	;from Easy80
	ins "drv_s80_fnt1.fnt"

font3:
	ins "drv_s80_fnt3.fnt"

line_table: :screen_lines_total .BYTE 0

; ---------------------------------------------------------------------------

s80_last_line:	.BYTE 0
graphics_cls:
		LDX #0
		LDY #SCREEN_LINES_TOTAL

graphics_cls_partial:
		STY	s80_last_line

s8cp_2:
		TXA
		PHA

		LDA	line_table,X
		TAY
		LDA	DLIST, Y
		STA	s8cp_1+1
		LDA	DLIST+1, Y
		STA	s8cp_1+2

		LDX	#$01
		LDY	#$40
		LDA	#$00
s8cp_1:		STA.a	$0000
		INC	s8cp_1+1
		BNE	s8cp_4
		INC	s8cp_1+2
s8cp_4:
		DEY
		BNE	s8cp_1
		DEX
		BPL	s8cp_1
	
		PLA
		TAX

		INX
		CPX	s80_last_line
		BNE	s8cp_2

s8cp_3:		RTS

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

graphics_put_char:
		tax
		BMI	s8pc4
		LDY	#0
		BEQ	s8pc3

s8pc4:		LDY	#$FF
s8pc3:		STY	s8pc_ptch1+1

		and	#$7F
		LDY	#0
		STY	s8pc_ptch2+2
		ASL
		ROL	s8pc_ptch2+2
		ASL
		ROL	s8pc_ptch2+2
		ASL
		ROL	s8pc_ptch2+2
		CLC
gpc_ptch1:	ADC	#<font1
		STA	s8pc_ptch2+1
		LDA	s8pc_ptch2+2
gpc_ptch2:	ADC	#>font1
		STA	s8pc_ptch2+2
		
		ldx	ROWCRS	;cursor line
		LDA	line_table,X
		TAX
		LDA	DLIST, X
		STA	s8pc_ptch3+1
		STA	s8pc_ptch6+1
		LDA	DLIST+1, X
		STA	s8pc_ptch3+2
		STA	s8pc_ptch6+2

		LDA	COLCRS
		LSR
		BCS	s8pc5
		;even character
		LDX	#$F0
		LDY	#$0F
		BNE	s8pc6

s8pc5:		;odd character
		LDX	#$0F
		LDY	#$F0
s8pc6:
		STX	s8pc_ptch4+1
		STY	s8pc_ptch5+1

		TAY
		LDX	#0
s8pc7:
s8pc_ptch2:	LDA.a	$0000,X
s8pc_ptch1:	EOR	#$00
s8pc_ptch4:	AND	#$00
		STA	s8pc_ptch7+1
s8pc_ptch3:	LDA.a	$0000,Y
s8pc_ptch5:	AND	#$00
s8pc_ptch7:	ORA	#$00
s8pc_ptch6:	STA.a	$0000,Y
		
		LDA	s8pc_ptch3+1
		CLC
		ADC	#SCREEN_WIDTH_BYTES
		STA	s8pc_ptch3+1
		STA	s8pc_ptch6+1
		BCC	s8pc8
		INC	s8pc_ptch3+2
		INC	s8pc_ptch6+2
s8pc8:		INX
		CPX	#8
		BNE	s8pc7
		rts

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
		STA     s8sp_ptch1+1
		LDA	DLIST+1,X
		STA	s8sp_ptch2+1

		PLA
		TAX

loop_over_screen:
		CPX	#[SCREEN_LINES_TOTAL-1]
		BEQ	s8sp_7
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
s8sp_7:
s8sp_ptch1:	LDA	#$00
		STA	LAST_DLIST_LMS
s8sp_ptch2:	LDA	#$00
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

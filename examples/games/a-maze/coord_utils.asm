;
; Coordinate utilities
;
; Map coordinates from screen coords (PMG hpos and scanline) to maze grid coords
; and vice versa.

.LOCAL coord_utils

row_lut_lo = $4000	; screen row lookup table, lo byte
row_lut_hi = $4100	; screen row lookup table, hi byte

;
; Lookup tables constructed as in http://www.atariarchives.org/agagd/chapter8.php
;
.PROC init_luts
	ldy #0						; lut offset
	lda sm_ptr					; load screen memory lo byte
	ldx sm_ptr+1

store_to_lut
	sta row_lut_lo,y	; Store y coordinate lookup table lo byte
	pha							; Push offset to stack
	txa							; X reg contains the hi byte
	sta row_lut_hi,y
	pla

	iny
	cpy #num_rows				; Have we done all 24 rows already
	beq lut_done
	clc
	adc #bytes_per_row			; Add row width with carry
	bcc store_to_lut
	inx							; Carry set, increase hi byte
	jmp store_to_lut

lut_done
	rts
.ENDP

.PROC map_from_screen_to_grid_coords
	lda p0_y
	lsr
	lsr
	tay
	
	setup_position_from_y_register position
	
	lda p0_x
	lsr
	lsr
	tay
	
	rts
.ENDP

;
; Setup p0_hpos and p0 bitmap so that it corresponds to grid
; coordinates from p0_x and p0_y
;
.PROC set_screen_coords_from_grid_coords
	ldy p0_y

.ENDP

;
; Setup screen memory pointer pos_ptr according to coordinate y
;
.MACRO setup_position_from_y_coord pos_ptr, y
	ldy :y
	mva coord_utils.row_lut_lo,y :pos_ptr
	mva coord_utils.row_lut_hi,y :pos_ptr+1
.ENDM

.MACRO setup_position_from_y_register pos_ptr
	mva coord_utils.row_lut_lo,y :pos_ptr
	mva coord_utils.row_lut_hi,y :pos_ptr+1
.ENDM

.ENDL

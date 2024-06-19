;
; Hunt and kill maze algorithm
; https://github.com/jamis/csmazes
;

.IFDEF ALG_HUNT_AND_KILL

.LOCAL maze_alg

rng		= $d20a		; Random number generator


		ICL "definitions"
		ICL "general_utils"
		OPT R+						; enable macro code optimization

;
; Initialize maze algorithm
; - lookup tables
; - flags
; - random starting cell
;
.PROC init
	coord_utils.init_luts

	lda #0								; Reset maze ready flag
	sta maze_ready
		
	mod rng, #num_rows					; Random starting point, y coord 
	sta coord_y
	mod rng, #num_cols
	sta coord_x

	rts	
.ENDP

;
; Takes one step of maze generation.
; Either continues from current cell, or scans
; for new cell to continue.
;
.PROC step
	.ZPVAR wild_hunt .byte	; did we just hunt

	mva #0 wild_hunt
	check_neighbours
	txa
	bne carve_new_cell
	
	; Start hunt from upper-left corner
	mva #1 wild_hunt
	lda #0
	sta coord_x
	sta coord_y
	coord_utils.setup_position_from_y_coord position, coord_y
	ldy #0
	
hunt
	lda (position),y
	cmp #walled_in
	beq empty_cell			; cell is empty, check neighbours

next_cell
	inc coord_x
	ldy coord_x
	cpy #[num_cols - 1]
	bne hunt
	
	ldy coord_y
	cpy #[num_rows - 1]
	beq maze_done
	inc coord_y
	iny
	coord_utils.setup_position_from_y_register position
	ldy #0
	sty coord_x
	jmp hunt

maze_done
	lda #1
	sta maze_ready
	rts

empty_cell					; we're in empty cell, are there neighbours	
	check_neighbours		; now 0 bit means valid direction and 1 invalid
	txa
	ldy coord_x
	bne check_right_border
	ora #wall_left			; set bits in invalid directions

check_right_border
	cpy #[num_cols - 1]
	bne check_top_border
	ora #wall_right

check_top_border
	ldy coord_y
	bne check_bottom_border
	ora #wall_up

check_bottom_border
	cpy #[num_rows - 1]
	bne is_suitable
	ora #wall_down

is_suitable
	cmp #$F			; if no valid direction, try next cell
	beq next_cell

	connect_to_existing_corridor
	rts	

carve_new_cell
	and rng					; bitwise and the neighbours status with rng

	bit wall_mask
	bne left
	lsr
	bit wall_mask
	bne right
	lsr
	bit wall_mask
	bne up
	lsr
	bit wall_mask
	bne down
	
	txa
	jmp carve_new_cell		; that was bad random number ;), let's try again

left
	ldx #wall_left
	connect_cell
	lda wild_hunt
	bne done				; if we came here from hunt, don't update coords
	dec coord_x
	rts
	
right
	ldx #wall_right
	connect_cell
	lda wild_hunt
	bne done
	inc coord_x
	rts

up
	ldx #wall_up
	connect_cell
	lda wild_hunt
	bne done
	dec coord_y
	rts
	
down
	ldx #wall_down
	connect_cell
	lda wild_hunt
	bne done
	inc coord_y
		
done
	rts
.ENDP

.PROC connect_to_existing_corridor
	bit wall_mask
	bne check_right
	ldx #wall_left
	connect_cell
	rts

check_right
	lsr
	bit wall_mask
	bne check_up
	ldx #wall_right
	connect_cell
	rts

check_up
	lsr
	bit wall_mask
	bne check_down
	ldx #wall_up
	connect_cell
	rts

check_down
	ldx #wall_down
	connect_cell
	rts

.ENDP

;
; Removes walls between current cell and cell in direction in register x.
; Procedure assumes direction has already been checked to be valid.
;
.PROC connect_cell
	coord_utils.setup_position_from_y_coord position, coord_y
	ldy coord_x
	lda (position),y
	
left
	cpx #wall_left
	bne right
	and #[$F - wall_left]
	sta (position),y
	dey
	lda (position),y
	and #[$F - wall_right]
	sta (position),y
	rts
	
right
	cpx #wall_right
	bne up
	and #[$F - wall_right]
	sta (position),y
	iny
	lda (position),y
	and #[$F - wall_left]
	sta (position),y
	rts
	
up
	cpx #wall_up
	bne down
	and #[$F - wall_up]
	sta (position),y
	ldy coord_y
	dey
	coord_utils.setup_position_from_y_register position
	ldy coord_x
	lda (position),y
	and #[$F - wall_down]
	sta (position),y
	rts	

down
	and #[$F - wall_down]
	sta (position),y
	ldy coord_y
	iny
	coord_utils.setup_position_from_y_register position
	ldy coord_x
	lda (position),y
	and #[$F - wall_up]
	sta (position),y
	rts
.ENDP

;
; Check neighbour cells of current cell (coord_x, coord_y).
; Status returned in x register low nybble.
; Bit 1 - free cell, bit 0 - occupied
; 
.PROC check_neighbours
	.ZPVAR check_position .WORD
	
	ldx	#0					; x contains the neighbour bits, 1 - free, 0 - occupied

	lda	coord_y
	beq down				; if coord_y == 0, skip up

up							; check up for neighbours
	tay
	dey
	coord_utils.setup_position_from_y_register check_position
	ldy coord_x
	lda (check_position),y
	cmp #walled_in
	bne down				; if != F, cell is occupied already
	txa
	ora #wall_up
	tax
	
down
	lda coord_y
	cmp #[num_rows - 1]
	beq left
	tay
	iny
	coord_utils.setup_position_from_y_register check_position
	ldy coord_x
	lda (check_position),y
	cmp #walled_in
	bne left
	txa
	ora #wall_down
	tax
	
left
	ldy coord_y
	coord_utils.setup_position_from_y_register check_position
	lda coord_x
	beq right
	tay
	dey
	lda (check_position),y
	cmp #walled_in
	bne right
	txa
	ora #wall_left
	tax
	
right
	lda coord_x
	cmp #[num_cols - 1]
	beq done
	ldy coord_x
	iny
	lda (check_position),y
	cmp #walled_in
	bne done
	txa
	ora #wall_right
	tax
	
done
	rts	
.ENDP

.ENDL

.ENDIF
;
; Player control routines
;

.LOCAL player_control

joystick_0	= $278

joystick_up		= %0001
joystick_down	= %0010
joystick_left	= %0100
joystick_right	= %1000

min_x			= $30
max_x			= $D0
min_y			= $1E
max_y			= $A0

.PROC read_controls
;	coord_utils.map_from_screen_to_grid_coords
	
;	lda #"*"
;	sta (position),y

	move_player
	
	rts	
.ENDP

.PROC move_player
up
	lda #joystick_up
	bit joystick_0
	bne down
	lda #min_y
	cmp p0_y
	beq left
	move_up
	jmp left

down
	lda #joystick_down
	bit joystick_0
	bne left
	lda #max_y
	cmp p0_y
	beq left
	move_down
	
left
	lda #joystick_left
	bit joystick_0
	bne right
	lda #min_x
	cmp p0_x
	beq done
	dec p0_x
	lda p0_x
	sta p0_hpos
	jmp done

right
	lda #joystick_right
	bit joystick_0
	bne done
	lda #max_x
	cmp p0_x
	beq done
	inc p0_x
	lda p0_x
	sta p0_hpos

done
	rts
.ENDP

.PROC move_up
	lda p0_y
	dec p0_y
	sta p0_addr
	ldx #8
	
move_loop
	ldy #1				; stupid logic, think again
	lda (p0_addr),y
	dey
	sta (p0_addr),y
	inc p0_addr
	dex
	bne move_loop

done
	rts
.ENDP

.PROC move_down
	lda p0_y
	cmp max_y
	beq done
	
	lda p0_y
	clc
	adc #8
	sta p0_addr
	
move_loop
	ldy #0
	dec p0_addr
	lda (p0_addr),y
	iny
	sta (p0_addr),y
	lda p0_y
	cmp p0_addr
	bne move_loop

	inc p0_y
	
done	
	rts
.ENDP

.ENDL
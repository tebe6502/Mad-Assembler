; Maze
;
; Maze cell data; 4 bits per cell. 0 - no wall, 1 - wall
; 1 left
; 2 right
; 4 up
; 8 down

jiffies = $14
sm_ptr	= $58		; Screen memory pointer
ramtop	= $6a
ch		= $2f4		; Pointer to high byte of character set
chr		= $2400		; International character set
dmactl	= $22f		; DMA control
dl_ptr	= $230
gfxctl	= $d01d		; Graphics control
pmbase	= $d407		; PMG base pointer
p0_hpos = $d000		; Player 0 hor pos
p1_hpos = $d001		; Player 1 hor pos
p0_color= $2c0
p1_color= $2c1
gprior	= $26f		; Graphics priority
color_reg1	= $2c5
color_reg2	= $2c6
p0_size		= $d008
p0_addr 		= $c4
p1_addr			= $c6

; Zero page variables
		ORG $cb
position 		.word 0		; Screen Position, word, address to screen memory
coord_x			.byte 0		; x coordinate of current cell, 0-39
coord_y			.byte 0		; y coordinate, 0-23
maze_ready		.byte 0		; is maze ready; 0 - false, otherwise true
target_jiffies	.byte 0		; keeps track of target jiffies to wait for
wall_mask		.byte %00000001		; convenience var to check walls

.MACRO SETUP_WAIT
	.IFDEF SLOW_DOWN
	lda jiffies					; check jiffies counters
	clc
	sta target_jiffies
	.ENDIF
.ENDM

.MACRO DO_THE_WAIT
wait_loop
	.IFDEF SLOW_DOWN
	lda target_jiffies
	sec
	sbc jiffies
	bpl wait_loop				; check if negative, as one might actually miss the
								; target if checking for equality
	.ENDIF
.ENDM

	ORG $2000

	.LOCAL display_list
:3	.byte $70
	.byte $42					; ANTIC mode 2 + sm ptr
sm	.word 0			
:23	.byte $02					; ANTIC mode 2
	.byte $41, a(display_list)	; Jump to address and wait for VBL
	.ENDL

	.DEF ALG_HUNT_AND_KILL		; maze_alg points to Hunt-and-Kill
	.DEF SLOW_DOWN				; slow down the maze generation

	ICL "definitions"
	
	; Maze carving
	ICL "sparse_maze"

	; Maze algorithms
	ICL "hunt_and_kill"
	
	; Control schemes
	ICL "player_control"

	; General utility macros and procs
	ICL "general_utils"

	; Coordinate mapping utilities
	ICL "coord_utils"

the_guy_height = 7

the_guy
	.byte %00000000
	.byte %00111000
	.byte %01010100
	.byte %01111100
	.byte %01000100
	.byte %00111000
	.byte %00000000

; Player grid coordinates
p0_x	.byte 1
p0_y 	.byte 1
p1_x	.byte 20
p1_y	.byte 12

.PROC init
	lda #$30					; set PMG 2k memory are from $3000-$37ff 
	sta pmbase
	sta position + 1

	clc
	adc #4						; p0 data starts at pmbase + 1k
	sta p0_addr + 1

	adc #1						; p1 data starts at p1_addr + $100
	sta p1_addr + 1

	lda #0						; reset lo-bytes of addresses
	sta p0_addr
	sta p1_addr
	sta position

	setup_display_list
	
	lda #0							; set black background color
	sta color_reg2
	lda #$f							; max luminance for foreground
	sta color_reg1

	mva #>chr ch					; set character set

	init_and_enable_pmg

	setup_players

	clear_screen_memory
	
	maze_alg.init
	jmp main
.ENDP

.PROC setup_display_list
	lda #0			; disable ANTIC for display list update
	sta dmactl
	
	mwa sm_ptr display_list.sm
	
	mwa #display_list dl_ptr	; set display list address

	lda #$22		; enable ANTIC again
	sta dmactl
	rts
.ENDP

.PROC init_and_enable_pmg
enable_pmg
	; PMG / http://www.hintermueller.de/dereatari-chapter-4
	lda #[46 + 16]					; single line resolution
	sta dmactl

	; clear pmg memory
	ldy #0
	lda #0

clr_loop_pmg
	sta (p0_addr), y	
	iny
	bne clr_loop_pmg

	ldy #0

	; p0 lo byte sets y coordinate (includes borders)
	lda p0_y
	sta p0_addr

p0_loop							; Copy... The Guy
	lda the_guy,y
	sta (p0_addr),y
	iny
	cpy #the_guy_height
	bne p0_loop

	lda #1						; set priority to players, playfield then background
	sta gprior

	lda #2						; enable players
	sta gfxctl
	lda #$BF
	sta p0_color

p1_init
	; set p1
	ldy #0
	lda p1_y
	sta p1_addr

p1_loop
	lda the_guy,y
	sta (p1_addr),y
	iny
	cpy #the_guy_height
	bne p1_loop

	lda #$48
	sta p1_color

	rts
.ENDP

.PROC setup_players
	
.ENDP

.PROC clear_screen_memory
	; Clear screen memory, 40*24 bytes = 3 pages and change
	mwa sm_ptr position
	mwa sm_ptr position+2		; use zero page locations without worries at this point
	inc position+3				; as they are uninitialized anyway. I setup pointers
	mwa position+2 position+4	; to 3 consecutive pages for simpler clearing loop 
	inc position+5

	lda #walled_in
	ldy #0						; Offset

clr_loop	
	sta (position),y
	sta (position+2),y
	sta (position+4),y
	iny
	bne clr_loop

	; Still 192 bytes to go on the fourth page
	ldy	#192
	inc position+5				; increase hi byte for next page

clr_loop2	
	dey
	sta	(position+4),y
	bne clr_loop2
	rts
.ENDP

.PROC main
maze_loop
	maze_alg.step				; run one step of algorithm

	lda #0
	cmp maze_ready				; is maze ready
	beq maze_loop

main_loop
	SETUP_WAIT

	player_control.read_controls
	
	DO_THE_WAIT
	
	jmp main_loop
.ENDP

	; Custom character set
	ORG chr
	INS "maze.chr"
	
	RUN init
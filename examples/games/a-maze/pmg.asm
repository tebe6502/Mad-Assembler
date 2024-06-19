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
gfxctl	= $d01d		; Graphics control
pmbase	= $d407		; PMG base pointer
p0_hpos = $d000		; Player 0 hor pos
p0_color= $2c0
gprior	= $26f		; Graphics priority
color_reg1	= $2c5
color_reg2	= $2c6
p0_size		= $d008

; Zero page variables
position 		= $cb	; Screen Position, word, address to screen memory
coord_x			= $cd	; x coordinate of current cell, 0-39
coord_y			= $ce	; y coordinate, 0-23
maze_ready		= $cf	; is maze ready; 0 - false, otherwise true
target_jiffies	= $d0	; keeps track of target jiffies to wait for
wall_mask		= $d1	; convenience var to check walls
p0_addr 		= $c4

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

	.DEF ALG_HUNT_AND_KILL		; maze_alg points to Hunt-and-Kill
	.DEF SLOW_DOWN				; slow down the maze generation

	ICL "definitions"
	ICL "hunt_and_kill"
	ICL "player_control"

.PROC init
	lda #$30					; set PMG 2k memory are from $3000-$37ff 
	sta pmbase
	sta position + 1

	clc
	adc #4						; p0 data starts at pmbase + 1k
	sta p0_addr + 1

	lda #0						; reset lo-bytes of addresses
	sta p0_addr
	sta position

	set_gfx #2						; text mode 0 - Antic 2
	lda #0							; set black background color
	sta color_reg2
	lda #$f							; max luminance for foreground
	sta color_reg1

	mva #>chr ch					; set character set

enable_pmg
	; PMG / http://www.hintermueller.de/dereatari-chapter-4
	lda #[46 + 16]					; single line resolution
	sta dmactl

	; clear pmg memoryta
	ldy #0
	lda #0

clr_loop_pmg
	sta (p0_addr), y	
	iny
	bne clr_loop_pmg

	ldy #0

	; p0 lo byte sets y coordinate (includes borders)
	lda player_y
	sta p0_addr

p0_loop							; Copy... The Guy
	lda the_guy,y
	sta (p0_addr),y
	iny
	cpy #8
	bne p0_loop

	lda #1						; set priority to players, playfield then background
	sta gprior

	lda #2						; enable players
	sta gfxctl
	lda #60						; set x coordinate
	sta player_x
	sta p0_hpos
	lda #$7f
	sta p0_color

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

setup
	lda #%00000001				; setup wall mask
	sta wall_mask
	
	maze_alg.init
	jmp main
.ENDP

; http://www.atariarchives.org/alp/chapter_10.php
.PROC set_gfx
	PHA           ; Store on stack
	LDX #$60      ; IOCB6 for screen
	LDA #$C       ; CLOSE command
	STA ICCOM,X   ; in command byte
	JSR CIOV      ; Do the CLOSE
	LDX #$60      ; The screen again
	LDA #3        ; OPEN command
	STA ICCOM,X   ; in command byte
	LDA <screen_string ; Name is "S:"
	STA ICBAL,X   ; Low byte
	LDA >screen_string ; High byte
	STA ICBAH,X
	PLA           ; Get GRAPHICS n
	STA ICAX2,X   ; Graphics mode
	AND #$F0      ; Get high 4 bits
	EOR #$10      ; Flip high bit
	ORA #$C       ; Read or write
	STA ICAX1,X   ; n+16, n+32 etc.
	JSR CIOV      ; Setup GRAPHICS n
	RTS           ; All done
.ENDP

screen_string .byte "S:",$9B

the_guy
	.byte %00000000
	.byte %00111100
	.byte %01111110
	.byte %01011010
	.byte %01111110
	.byte %01100110
	.byte %00111100
	.byte %00000000

player_x .byte 0
player_y .byte 40

.PROC main
maze_loop
	SETUP_WAIT

	player_control.move_player

	maze_alg.step				; run one step of algorithm

	DO_THE_WAIT

	lda #0
	cmp maze_ready				; is maze ready
	beq maze_loop

main_loop
	SETUP_WAIT

	player_control.move_player
	
	DO_THE_WAIT
	
	jmp main_loop
.ENDP

	; Custom character set
	ORG chr
	INS "maze.chr"
	
	RUN init
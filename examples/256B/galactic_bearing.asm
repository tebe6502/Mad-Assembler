; "Galactic Bearing"
; Requires OS Rev 2
; Code: Jakub 'Ilmenit' Debski
; Music: Michal 'stRing' Radecki

; size&effects controllers
SAFE_VERSION = 1
SILENCING_ENABLED=0
SHIFTED_BACKGROUND_SFX = 0

; other settings
VERTEXES = 8

NO_ITERATIONS = 180

FRACTALS = 3 ; without black color
;FRACTALS = 4 ; with black color removing

NEXT_ROTATE_STEP = 5

;;;;;; SOUND
AUDF1	equ $D200
AUDF2	equ $D202
AUDC1	equ $D201
AUDC2	equ $D203
AUDCTL	equ $D208
SKCTL   equ $D20F

COLOR0	equ $02c4

; random number generator
RANDOM = $d20a

ROWCRS	equ $54		;Row of cursor, 1 byte
COLCRS	equ $55		;Column of cursor, 2 bytes

OLDROW  equ $5A
OLDCOL  equ $5B     ; 2 bytes

; Aliases, because orig reg names are hard to remember ;)
cursor_y    equ ROWCRS
cursor_x    equ COLCRS
prev_y      equ OLDROW
prev_x      equ OLDCOL

COLOR   equ $2fb	;Color for graphics operations

; OS functions
openmode  equ $ef9c
drawpoint equ $f1d8

	org $80
iteration:
	.ds [1]

fractal_number:
	.ds [1]

draw_angle:
	.ds [1]

value:
	.ds [1]

vertex_x:
	.ds [VERTEXES]
vertex_y:
	.ds [VERTEXES]

.IF SAFE_VERSION = 0
	bvc start
.ENDIF

music:

; we are starting with angle for track2, to have this interesting sound effect on 3rd part
MUSIC_STARTING_PART equ 2
MUSIC_STARTING_ANGLE equ ((256/4)*MUSIC_STARTING_PART)

;Probably we can place music at $80 so "adc #<music" won't be needed

track0:
; string, track 36, 1
	.byte $d7 ;d1
	.byte $b4 ;f1
	.byte $8f ;a1
	.byte $87 ;a#1
	.byte $8f ;a1
	.byte $b4 ;f1
	.byte $6b ;d2 ($6b) ; or f1 ($b4)
	.byte $8f ;a1

track1:
; string, track 36, 2
	.byte $f1 ;c1
	.byte $b4 ;f1
	.byte $8f ;a1
	.byte $87 ;a#1
	.byte $8f ;a1
	.byte $b4 ;f1
	.byte $f1 ;c1
	.byte $b4 ;f1

track2:
	; string Track 34, 1, PAL
	.byte $f1  ; c1
	.byte $a1  ; g1
	.byte $87  ; a#1
	.byte $6b  ; d2
	.byte $65  ; d#2
	.byte $6b  ; d2
	.byte $87  ; a#1
	.byte $a1  ; g1

track3:
	; string Track 34, 2, PAL
	.byte $e3  ; c#1
	.byte $b4  ; f1
	.byte $98  ; g#1
	.byte $87  ; a#1
	.byte $98  ; g#1
	.byte $b4  ; f1
	.byte $e3  ; c#1
	.byte $b4  ; f1

;; MY TEST MUSIC, maybe will use it in some other intro ;)
;
;music1:
;	.byte $f1 ; c1
;	.byte $d7 ; d1
;	.byte $a1 ; g1
;	.byte $8f ; a1
;	.byte $87 ; a#1
;	.byte $8f ; a1
;	.byte $a1 ; g1
;	.byte $d7 ; c1
;music2:
;	.byte $b4 ; f1
;	.byte $a1 ; g1
;	.byte $7f ; b1 / h1
;	.byte $6b ; d2
;	.byte $65 ; d#2
;	.byte $6b ; d2
;	.byte $7f ; b1 / h1
;	.byte $a1 ; g1

.print "music size: ", * - music
.print "play_music_note: ", .len play_note
.print "sine init: ", .len init_sine
.print "init gfx: ", .len init_gfx
.print "drawing stars: ", .len add_stars
.print "drawing fractals: ", .len fractal

; palette initialization colors
colors:
	.byte $fe, $58, $70

start:

.local init_sine

	ldy #$3f
	ldx #$00

	; Accumulate the delta (normal 16-bit addition)
loop:
	lda #0
lvalue	equ *-1
;	clc ; we don't need super accuracy here
	adc #0
ldelta	equ *-1
	sta lvalue
	lda #0
hvalue	equ *-1
	adc #0
hdelta	equ *-1
	sta hvalue

; Reflect the value around for a sine wave
	sta sine+$c0,x
	sta sine+$80,y
	eor #$7f
	sta sine+$40,x
	sta sine+$00,y
angle equ *-2 ; starting angle is taken from lower byte of SINE address (reusing code as data)

; Increase the delta, which creates the "acceleration" for a parabola
	lda ldelta
  	adc #$8   ; this value adds up to the proper amplitude
	sta ldelta
	bcc skip
	inc hdelta
	skip:
; Loop
	inx
	dey
	bpl loop
.endl

.local init_gfx
	lda #15		; 2 bytes
	jsr openmode	; 3 bytes, Changes $7B (SWPFLG) on zero page to zero so we can't load data there
	; A=00 X=0F Y=01
.endl
	sty SKCTL ; init sound for proper loading from DOS

.local add_stars
	lda RANDOM
	sta color
	sta cursor_x
	jsr drawpoint
	lda RANDOM
	sta cursor_y
	; POTENTIAL OPTIMIZATION, REMOVE NEXT LINE
	dec init_sine.ldelta ; reuse guaranted value 0 to draw 256 stars
	bne add_stars
.endl

.if SILENCING_ENABLED=0
	lda #$e8 ; other pure tone is $A8
	sta AUDC1
.endif

main_loop:
	lda #FRACTALS
	sta fractal_number

	lda init_sine.angle ; reusing previous code
	pha
next_fractal:
	ldx fractal_number
	stx color
	lda colors-1,x
	sta color0-1,x

	pla ; angle
	clc
	adc #NEXT_ROTATE_STEP ; angle of next fractal
	pha ; increased angle
	sta draw_angle

; fractal routine which uses a stored array of random numbers
.proc fractal ; manually inlined to save jsr/rts bytes

.local init_angles
;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldy #(VERTEXES-1) ; y vertex number
next_vertex:
	ldx draw_angle
	txa

	adc #(256/VERTEXES) ; angle of next verex
	sta draw_angle

	lda sine,x

	adc #14 ; center X

	; store x
	sta vertex_x, y			; load x coordinate of random vertex into accumulator

	; x still has orignal angle, so we can use it
	txa

	;adc #64 ; cos - for round galaxy
	adc #32+64 ; for diagonal galaxy
	tax
	; read value for angle
	lda sine,x

;	; y *= 1.5
	sta value
	lsr
	adc value

	; store y
	sta vertex_y, y			; load x coordinate of random vertex into accumulator
	dey
	bpl next_vertex
.endl

.local draw_fractal
	; draw galaxy among vertexes
	; using https://en.wikipedia.org/wiki/Chaos_game
	lda #NO_ITERATIONS
	sta iteration
fractal_loop:
	ldy iteration
	; get vertex index from ROM
	lda vertex_index, y
	and #7 ; we have 8 vertexes
	tay
	lda vertex_x, y			; get x of random vertex
	adc cursor_x
	ror
	sta cursor_x
	lda vertex_y, y			; get y
	adc cursor_y
	ror
	sta cursor_y
	jsr drawpoint
	dec iteration
	bne fractal_loop
.endl

.endp

	dec fractal_number

	bne next_fractal

	pla ; increased angle (draw_angle)


.local play_note
; play note
; we play 4xeach of 4 tracks
; we start from draw angle, therefore we have to calculate it properly
; the first track to play is not the first on the list for better sync of music with background effects

	;lda draw_angle ; not needed because of PLA above
; take note

.if SILENCING_ENABLED
	; Y=0 here, we can use it for AUDC1 silencing
	ror ; check if lowest bit of angle is set
	bcc skip
	ldy #$a8 ; other pure tone is $E8
skip:
	sty AUDC1
	rol
.endif
	; %76 54 32 10
	; lsr -  skip bit 0 (slower music)
	; wait time for the next tone, every 2 angles
	lsr
	sta AUDF2
	; % 7 65 43 21
	; AND #$7 (note number 0-7 in bits 321)

	pha

	; we can play with highest 5 bits, because later there is and #$7
	; for partial background noise
	and #%00011111

	; if we want constant background noise
	;ora #%00001000

.if SHIFTED_BACKGROUND_SFX = 1
	; start noise from the second half of this music track
	; this will also not modify the lowest bits
	sec
	sbc #%00010000
.endif
	sta AUDC2

	and #$7
	tax ; x is note in pattern 0-7

	pla

	; now select track for this angle from two highest bits (76)
	; % 7 65 43 21
	; AND #$7 (note number 0-7 in bits 321)


	; the track number must be multiplied by music pattern size, which is 8, therefore we need 2xlsr instead of (5xlsr + 3xasl)
	; however we need to clear the lowest bits
	and #%01100000
	lsr
	lsr

	; add first pattern offset
	adc #<music ; TODO check if we can place music at $80 and just make ORA $80 in calculations
	sta music_part

	lda music,x
music_part equ *-1
	sta AUDF1

.endl
	inc init_sine.angle

.print "Main loop size: ", * - main_loop
	jmp main_loop ; we cannot use branch, because loop size is >$80, jmp needed here


; "random" vertext index, setting it to some ROM location so we do not have to prepare table (thanks to Koala for idea)
	org $E730
vertex_index:
	.DS [256]

; lower byte of this address is used as the "angle" in fractal drawing (code reuse as data)
; music is using in reg A "draw_angle" which is by 15dec bigger than angle (3 fractals * 5 degrees)

; with +15 we will get angle 0 for playing music from start
  	org $7000 + MUSIC_STARTING_ANGLE - (3 * NEXT_ROTATE_STEP)
sine:
	.DS [256]

.IF SAFE_VERSION = 1
	RUN start
.ENDIF


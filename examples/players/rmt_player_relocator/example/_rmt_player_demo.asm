;
; MUSIC init & play
; example by Raster/C.P.U., 2003-2004
;
;
STEREOMODE	equ 0				;0 => compile RMTplayer for mono 4 tracks
;						;1 => compile RMTplayer for stereo 8 tracks
;						;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;						;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;
;
	icl "..\rmt_player.a65"			;include RMT player routine
;
;
MODUL	equ $1000				;address of RMT module

	org MODUL

;*
;* RMT FEATures definitions file
;* For optimizations of RMT player routine to concrete RMT modul only!

	icl "music.feat"

	rmt_relocator 'music.rmt' MODUL		;include music RMT module
			
;
;
VCOUNT	equ $d40b				;vertical screen lines counter address
KEY	equ $2fc				;keypressed code
VLINE	equ 16					;screen line for synchronization
;
	org $3e00
start
;
	ldx #<MODUL				;low byte of RMT module to X reg
	ldy #>MODUL				;hi byte of RMT module to Y reg
	lda #0					;starting song line 0-255 to A reg
	jsr RASTERMUSICTRACKER		;Init
;Init returns instrument speed (1..4 => from 1/screen to 4/screen)
	tay
	lda tabpp-1,y
	sta acpapx2+1				;sync counter spacing
	lda #16+0
	sta acpapx1+1				;sync counter init
;
	lda #255
	sta KEY					;no key pressed
;
loop
acpapx1	lda #$ff				;parameter overwrite (sync line counter value)
	clc
acpapx2	adc #$ff				;parameter overwrite (sync line counter spacing)
	cmp #156
	bcc lop4
	sbc #156
lop4
	sta acpapx1+1
waipap
	cmp VCOUNT				;vertical line counter synchro
	bne waipap
;
	mva #$0f $d01a

	jsr RASTERMUSICTRACKER+3        	;1 play

	mva #$00 $d01a
;
	lda KEY					;keyboard
	cmp #28					;ESCape key?
	bne loop				;no => loop
;
stopmusic
	lda #255
	sta KEY				        ;no key pressed
;
	jsr RASTERMUSICTRACKER+9	        ;all sounds off
;
	jmp (10)			        ;DOSVEC => exit to DOS
;
tabpp  dta 156,78,52,39			        ;line counter spacing table for instrument speed from 1 to 4
;
;
	run start			        ;run addr
;
;that's all... ;-)

	icl '..\rmt_relocator.mac'

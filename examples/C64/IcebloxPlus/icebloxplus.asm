;============================================================
; Iceblox Plus for the C64
; By Karl Hörnell
;============================================================

;============================================================
;    specify output file
;============================================================


;============================================================
; BASIC loader with start address $c000
;============================================================

	opt h-f+
	org [a($801)],$801		; BASIC start address (#2049)

.byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC loader to start at $c000...
.byte $31,$35,$32,$00,$00,$00           ; puts BASIC line 2012 SYS 49152

	org 4096							; The bulk of the code goes here
	icl "code/irq.asm"

	org 14160							; start address for green gradient data
	icl "data/greens.asm"

	org 14304							; Start address for logo data
	icl "data/logodata.asm"


	org 16384							; Sprite data start
	icl "data/sprites.asm"

;============================================================
;  Main routine with IRQ setup and custom IRQ routine
;============================================================

	org 32768							; Character data start

	icl "data/characters.asm" ; Level graphics building blocks
	icl "data/song.asm"
	icl "code/variables.asm"

; 40960 character map (1024 bytes)
; 41984 empty ground map (1024 bytes)
; 43008 block data (192 bytes)
; 43200 block data buffer (192 bytes)
; 43392 mask data (768 bytes)

	org $c000							; start address for 6502 code

	icl "code/main.asm"
	icl "code/help_routines.asm"

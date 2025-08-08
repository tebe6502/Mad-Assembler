*****************************************************************
*								*
*		7800 Base Unit Rom Code				*
*	Modified Asteroids with a bit of O.asm			*
*			16-May-88				*
*								*
*		Dave Staugas, programmer			*
*****************************************************************
;

	opt f+h-m+
*
	icl	"RASTDEF.asm"

	org $C000-128
        .byte    4  			; 0   Header version     - 1 byte
        .by    "ATARI7800       "	; 1..16  "ATARI7800   "  - 16 bytes
        .by    " Mads Asteroid  "	; 17..48 Cart title      - 32 bytes
        .by    "  2025 EAGLE    "	; 2 line
        DTA r	($4000)				; 49..52 data length      - 4 bytes (Big-endian format)
        .byte    $00,$00 			; 53..54 cart type      - 2 bytes
        .byte     1  ; 55   controller 1 type  - 1 byte
        .byte     1  ; 56   controller 2 type  - 1 byte
        .byte    0  ; 57 0 = NTSC 1 = PAL
        .byte    0  ; 58   Save data peripheral - 1 byte (version 2)
        .byte 0,0,0,0	;ORG     HEADER+63
        .byte    0  ; 63   Expansion module
 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .by    "ACTUAL CART DATA STARTS HERE"

	icl	"STAMPS.asm"
	icl	"MAIN.asm"
	icl	"JOY.asm"
	icl	"FSM.asm"
	icl	"EXPLODE.asm"
	icl	"COLLIDE.asm"
	icl	"SCORE.asm"
	icl	"MORESTMP.asm"
	icl	"TUNES.asm"
	icl	"ROCKMOVE.asm"
	icl	"INIT.asm"
	icl	"UFO.asm"
	icl	"UTILS.asm"
	icl	"RASTLOAD.asm"
	icl	"TABLES.asm"
	icl	"os7800.asm"
*
avail	equ	*
*
*
; no encryption (bios version)
	org		$FFFA
	.word	NMI
	.word	Asteroid	;startup	- skipped bios checks (should be .word startup)
	.word	IRQ

// https://atariage.com/forums/topic/318726-7800-assembly-hello-world/?do=findComment&comment=4804033

		icl '..\maria.h'

		opt f+h-

		org $40
dest 	.ds 2 		;2 bytes


          ORG     $8000-128
HEADER       .byte    1  			; 0   Header version     - 1 byte
        .by    "ATARI7800       "	; 1..16  "ATARI7800   "  - 16 bytes
        .by    "Project name    "	; 17..48 Cart title      - 32 bytes
        .by    "Author          "	; 2 line
        DTA r	($8000)				; 49..52 data length      - 4 bytes (Big-endian format)
        .byte    $00,$00  			; 53..54 cart type      - 2 bytes
    ;    bit 0 - pokey at $4000
    ;    bit 1 - supergame bank switched
    ;    bit 2 - supergame ram at $4000
    ;    bit 3 - rom at $4000
    ;    bit 4 - bank 6 at $4000
    ;    bit 5 - supergame banked ram
    ;    bit 6 - pokey at $450
    ;    bit 7 - mirror ram at $4000
    ;    bit 8-15 - Special
    ;   0 = Normal cart
        .byte     1  ; 55   controller 1 type  - 1 byte
        .byte     0  ; 56   controller 2 type  - 1 byte
    ;    0 = None
    ;    1 = Joystick
    ;    2 = Light Gun
        .byte    0  ; 57 0 = NTSC 1 = PAL
        .byte    0  ; 58   Save data peripheral - 1 byte (version 2)
    ;    0 = None / unknown (default)
    ;    1 = High Score Cart (HSC)
    ;    2 = SaveKey
        .byte 0,0,0,0	;ORG     HEADER+63
        .byte    0  ; 63   Expansion module
    ;    0 = No expansion module (default on all currently released games)
    ;    1 = Expansion module required
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     ;   ORG     HEADER+100      ; 100..127 "ACTUAL CART DATA STARTS HERE" - 28 bytes
        .by    "ACTUAL CART DATA STARTS HERE"

	.macro clear_ram
	ldy #$00
	mwa #:1 dest
	lda #$00
@	sta (dest),y
	inw dest
	lda dest+1
	cmp #>[:2+1]
	bne @-
	.endm


            org $8000
fnt		ins 'cmc.fnt'
;
START
		sei					;Disable interrupts
		cld					;Clear decimal mode
		mva #$07 INPTCTRL
		mva	#$7F CTRL
		mva	#$00 OFFSET
		mva #$00 INPTCTRL
		ldx	#$FF			;Reset stack pointer
		txs
;Clear zeropage,stack,RAM
		clear_ram $42,$FF	;skip $40&$41 (dest)
		clear_ram $140,$1FF
		clear_ram $1800,$1FFF
		clear_ram $2200,$27FF

; copy Display List List To RAM
      	ldy #0
copy  	mva .adr(DLLs),y DLLs,y+
	    cpy #.len DLLs
	    bne copy
;
		mva #<DLLs DPPL\ mva #>DLLs DPPH	;set display list list address
		jsr	WaitVBLANK						;wait until no DMA would happen

		mva	#>fnt	CHBASE
		mva	#$40	CTRL
;set colors
		mva	#$00 BACKGRND\ mva #$02 P0C1\ mva #$04 P0C2\ mva #$0c P0C3
jm 		jmp jm

NMI		RTI
IRQ		RTI

WaitVBLANK:
WaitVBoff:
		bit		MSTAT
		bmi		WaitVBoff
WaitVBon:
		bit		MSTAT
		bpl		WaitVBon
		rts

; RAM
		ORG	$1800,*
.local DLLs
	:2	.byte	$0F,>emptyline,<emptyline
		.byte	$07,>line,<line
	:24	.byte	$0F,>emptyline,<emptyline

	.byte 0
line		.byte <text,$60,>text,0,20
emptyline	.byte $00,$00

text	.sb	'Hello, World!                   '
	.endl

;************** Cart reset vector **************************

	 ORG	$fff8
	.byte	$FF		;Region verification
	.byte	$87		;ROM start $8000
	.word	NMI
	.word	START
	.word	IRQ


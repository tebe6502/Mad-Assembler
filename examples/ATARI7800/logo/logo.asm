; Atari 7800 code framework
; Written by Daniel Boris (dboris@home.com)
;
; Assemble with MADS
;

;	processor 6502

		icl '..\maria.h'

	opt f+h-

	ORG	$40
count		.ds 1
dliv		.ds 2


        ORG	$c000

gfx		ins	'logo.raw'	;incbin  LOGO.RAW

sintab		ins	'sintab.bin'	;incbin  SINTAB.BIN

        
WaitVBLANK:
WaitVBoff:
		bit     MSTAT  
		bmi     WaitVBoff
WaitVBon:
		bit     MSTAT
		bpl     WaitVBon
		rts


START
	sei			;Disable interrupts
	cld			;Clear decimal mode

;******** Atari recommended startup procedure

	lda	#$02		; !!! 2 !!!
	sta	INPTCTRL	; Lock into 7800 mode
	lda	#$7F
	sta	CTRL
        sta	BACKGRND	;Disable DMA
	lda	#$00            
	sta	OFFSET
	sta	INPTCTRL
        sta	count
	ldx	#$FF		;Reset stack pointer
	txs

;	mva	#$82	P0C1
;	mva	#$86	P0C2
;	mva	#$8a	P0C3

		ldx	#$00
CopyLoop:
		lda	.adr DLLs,x
		sta	$1800,x
		inx
		bne	CopyLoop

		lda	<DLLogo		;
		sta	DPPL		; setup the pointers for the output
		lda	>DLLogo		; description (DLL) according to
		sta	DPPH		; the PAL/NTSC test to $1840/$184C
		jsr	WaitVBLANK	; wait until no DMA would happen

		mwa	#dli	dliv

		mva	#$40	CTRL

		mva	>gfx	CHBASE

		mva	#$00	BACKGRND

loop
	jsr     WaitVBLANK

	mwa	#dli	dliv

	inc     count
	inc     count

	ldx     count
	lda	sintab,x
	sec
	sbc     #32
	sta     reg3+3
	sta     reg2+3
	sta     reg1+3
	clc
	adc     #124
	sta     reg3+7
	sta     reg2+7
	sta     reg1+7

	jmp	loop


dli
        pha
	sta	WSYNC

	mva	#$82	P0C1
	mva	#$86	P0C2
	mva	#$8a	P0C3

	mwa     #dli2	dliv
	pla
	rti


dli2    pha
	sta	WSYNC

	mva	#$32	P0C1
	mva	#$36	P0C2
	mva	#$3a	P0C3

	mwa	#dli3	dliv
	pla
	rti


dli3    pha
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        sta	WSYNC
        mva	#$aa	P0C3
	sta	WSYNC
	mva	#$3a	P0C3
	pla
	rti


NMI
	jmp    (dliv)
	RTI
	
IRQ
	RTI


; This contains the text data, several DLs and the DLL.
; It gets copied to the RAM at $1800 for DMA timing reasons.

		Align 256

		ORG	$1800,*
DLLs
		.byte   " "				;$1800 - text data
                .byte   "NTSC"
                .byte   "encryption check passed"

		ALIGN   16				;$1820
blank		.byte   <$1800,$60,>$1800,$1f,$00		;DL for the blank lines
                .byte   $00,$00

		Align   8				;$1828
                .byte   <$1805,$60,>$1805,$04,00		;DL for the NTSL/PAL text
                .byte   $00,$00

;logo 3*16 = 48 = 3 regions
		Align 8					;$1830
reg1		.byte	<[gfx    ],$01,>gfx,$00			;DL for the NTSL/PAL text
                .byte	<[gfx+$20],$01,>gfx,124
                .byte	$00,$00

		Align 16				;$1840
reg2		.byte	<[gfx    ],$01,>[gfx+$1000],$00		;DL for the NTSL/PAL text
                .byte	<[gfx+$20],$01,>[gfx+$1000],124
                .byte	$00,$00

		Align 16				;$1850
reg3		.byte	<[gfx    ],$01,>[gfx+$2000],$00		;DL for the NTSL/PAL text
                .byte	<[gfx+$20],$01,>[gfx+$2000],124
		.byte	$00,$00


; The DLL starts here - $1860

//  _______________________________   _______________________________    _______________________________
// |   |   |   |   |               | |                               | |                               |
// |DLI|H16| H8| 0 |  O F F S E T  | |  S T A R S Z Y  B A J T  D L  | |  M £ O D S Z Y  B A J T  D L  |
// |___|___|___|___|___|___|___|___|,|___|___|___|___|___|___|___|___|,|___|___|___|___|___|___|___|___|

		Align   16
DLLogo
                :11	.byte	$07,>blank,<blank	; to center the NTSC display on

                .byte	$8f,>reg3,<reg3
                .byte	$8f,>reg2,<reg2
                .byte	$8f,>reg1,<reg1

                :19	.byte	$07,>blank,<blank	; to center the NTSC display on

                .byte	$00,>blank,<blank	;

;************** Cart reset vector **************************

	 ORG	$fff8
	.byte	$FF		;Region verification
	.byte	$47		;ROM start $4000
	.word	NMI
	.word	START
	.word	IRQ

	opt l-
	icl '..\align7800.mac'

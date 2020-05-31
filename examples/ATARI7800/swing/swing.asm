; Atari 7800 Taquart Intro
; Code by Heaven/TQA, Tebe/Madteam
;
; gfx by Heaven

;coded 12th january 2004, 19.03.2007

; gfx converted with custom turbo basic XL program on atari 8bit

; Atari 7800 code framework
; Written by Daniel Boris (dboris@home.com)
;
; Assemble with MADS
;

;this intro shows 8 32x32x4 sprites swinging on screen. each with its own palette so
;you'll see 24 colors on screen & per scanline. this is not possible on
;Atari XE/XL computers in that way.
;


fast_ram	equ	$1800
postab		equ	$1900

	icl '..\maria.h'

	opt f+h-

	ORG	$c000

fnt		ins	'armfont.raw'


WaitVBLANK
WaitVBoff
		bit	MSTAT  
		bmi	WaitVBoff
WaitVBon
		bit	MSTAT
		bpl	WaitVBon
		rts


;	org	$5000		; Start of cartridge area
START
	sei			; Disable interrupts
	cld			; Clear decimal mode

;******** Atari recommended startup procedure

	lda	#$02		; !!!! $02 !!!!
	sta	INPTCTRL	; Lock into 7800 mode
	lda	#$7F
	sta	CTRL
	sta	BACKGRND	; Disable DMA
	lda	#$00
	sta	OFFSET
	sta	INPTCTRL
	ldx	#$FF		; Reset stack pointer
	txs

	mva	#$02	P0C1	; PALETTE 0 - COLOR 1
	mva	#$06	P0C2	; PALETTE 0 - COLOR 2
	mva	#$0a	P0C3	; PALETTE 0 - COLOR 3

	mva	#$22	P1C1	; PALETTE 1 - COLOR 1
	mva	#$26	P1C2	; PALETTE 1 - COLOR 2
	mva	#$2a	P1C3	; PALETTE 1 - COLOR 3

	mva	#$32	P2C1	; PALETTE 2 - COLOR 1
	mva	#$36	P2C2	; PALETTE 2 - COLOR 2
	mva	#$3a	P2C3	; PALETTE 2 - COLOR 3

	mva	#$42	P3C1	; PALETTE 3 - COLOR 1
	mva	#$46	P3C2	; PALETTE 3 - COLOR 2
	mva	#$4a	P3C3	; PALETTE 3 - COLOR 3

	mva	#$52	P4C1	; PALETTE 4 - COLOR 1
	mva	#$56	P4C2	; PALETTE 4 - COLOR 2
	mva	#$5a	P4C3	; PALETTE 4 - COLOR 3

	mva	#$62	P5C1	; PALETTE 5 - COLOR 1
	mva	#$66	P5C2	; PALETTE 5 - COLOR 2
	mva	#$6a	P5C3	; PALETTE 5 - COLOR 3

	mva	#$72	P6C1	; PALETTE 6 - COLOR 1
	mva	#$76	P6C2	; PALETTE 6 - COLOR 2
	mva	#$7a	P6C3	; PALETTE 6 - COLOR 3

	mva	#$f4	P7C1	; PALETTE 7 - COLOR 1
	mva	#$f8	P7C2	; PALETTE 7 - COLOR 2
	mva	#$fa	P7C3	; PALETTE 7 - COLOR 3


* ---		INITIALIZE MAIN LOOP
		ldx	#$00
CopyLoop
		lda	.adr maria_DLs,x
		sta	fast_ram,x
		inx
		bne	CopyLoop

		lda	#<DLList
		sta	DPPL		; setup the pointers for the output
		lda	#>DLList	; description (DLL) according to
		sta	DPPH	 
		jsr	WaitVBLANK	; wait until no DMA would happen

		lda	#$40		; Enable DMA
		sta	CTRL

		lda	#$00
		sta	BACKGRND

		lda	>fnt
		sta	CHBASE

		jsr	tabinit		; inits sprite_position tables


* ---		MAIN LOOP	
LOOP
		jsr	WaitVBLANK
		ldx	#0
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+3
		sta	dl_logo_2+3
		inx
		ldy	postab,x
		lda	sintab,y
		clc		
		adc	#32
		sta	dl_logo_1+7
		sta	dl_logo_2+7
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+11
		sta	dl_logo_2+11
		clc
		adc	#32
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+15
		sta	dl_logo_2+15
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+19
		sta	dl_logo_2+19
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+23
		sta	dl_logo_2+23
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+27
		sta	dl_logo_2+27
		inx
		ldy	postab,x
		lda	sintab,y
		clc
		adc	#32
		sta	dl_logo_1+31
		sta	dl_logo_2+31


		ldx	#7
loop2		inc	postab,x
		dex
		bpl	loop2

		jmp	LOOP


tabinit		lda	#0
		ldx	#7		; 8 sprites
tabinit0	sta	postab,x
		clc
		adc	#24
		dex
		bpl	tabinit0
		rts
NMI
;	inc BACKGRND
	RTI

IRQ
	RTI


	align $100

logo		ins	'logo.raw'	; incbin  LOGO.RAW

sintab		ins	'sintab.bin'	; incbin  SINTAB.BIN


line1		.byte 'A T A R I  7800'

; This contains the text data, several DLs and the DLL.
; It gets copied to the RAM at $1800 for DMA timing reasons.

	align $100

		ORG	fast_ram,*

maria_DLs

		ALIGN   16
DLBlank
		.byte   $00,$00

// DLLINE1 - DisplayList trybu rozszerzonego, indirect (bit5=1) dla znaków (starszy bajt adresu zestawu znaków CHBASE)
//  _______________________   _______________________   _______________________   _______________________   _______________________
// |                       | |Wr|  |In|              | |                       | |        |              | |                       |
// |  M£ODSZY BAJT ADRESU  | |it|1 |nd|0 |0 |0 |0 |0 | |  STARSZY BAJT ADRESU  | | PALETA |   SZEROKOŒÆ  | |   POZYCJA  POZIOMA    |
// |__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|

DLLine1		.byte   <line1,%01100000,>line1,[7<<5]|8,$20
		.byte   $00,$00


;logo 2 zones, each font has 32x32 pixel = 8x32 bytes
// DL_LOGO_1 - DisplayList trybu bezpoœredniego, gdzie wskazujemy  bezpoœrednio na dane grafiki
//  _______________________   _______________________   _______________________   _______________________
// |                       | |        |              | |                       | |                       |
// |  M£ODSZY BAJT ADRESU  | | PALETA |   SZEROKOŒÆ  | |  STARSZY BAJT ADRESU  | |   POZYCJA  POZIOMA    |
// |__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|

// DL_LOGO_1 wyœwietli 16 linii logosa, 16*256 = 4096 bajtów danych

	?log = logo

		Align 8					;$1830
dl_logo_1	.byte   <[?log+8*0],[0<<5]|24,>[?log+8*0],$00		;T		- raster #0
		.byte	<[?log+8*1],[1<<5]|24,>[?log+8*1],$20		;A		- raster #1
		.byte	<[?log+8*2],[2<<5]|24,>[?log+8*2],$40		;Q		- raster #2
		.byte	<[?log+8*3],[3<<5]|24,>[?log+8*3],$60		;U		- raster #3
		.byte	<[?log+8*4],[4<<5]|24,>[?log+8*4],$80		;A		- raster #4
		.byte	<[?log+8*5],[5<<5]|24,>[?log+8*5],$a0		;R		- raster #5
		.byte	<[?log+8*6],[6<<5]|24,>[?log+8*6],$c0		;T		- raster #6
		.byte	<[?log+8*7],[7<<5]|24,>[?log+8*7],$e0		;atari sign	- raster #7
		.byte   $00,$00

;2nd half
// DL_LOGO_2 - DisplayList trybu bezpoœredniego, gdzie wskazujemy  bezpoœrednio na dane grafiki
//  _______________________   _______________________   _______________________   _______________________
// |                       | |        |              | |                       | |                       |
// |  M£ODSZY BAJT ADRESU  | | PALETA |  SZEROKOŒÆ   | |  STARSZY BAJT ADRESU  | |   POZYCJA  POZIOMA    |
// |__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|,|__|__|__|__|__|__|__|__|

// DL_LOGO_2 wyœwietli nastêpnych 16 linii logosa, 16*256 = 4096 bajtów danych

	?log += $1000

		Align	40				;$1850
dl_logo_2	.byte   <[?log+8*0],[0<<5]|24,>[?log+8*0],$00		;T		- raster #0
		.byte	<[?log+8*1],[1<<5]|24,>[?log+8*1],$20		;A		- raster #1
		.byte	<[?log+8*2],[2<<5]|24,>[?log+8*2],$40		;Q		- raster #2
		.byte	<[?log+8*3],[3<<5]|24,>[?log+8*3],$60		;U		- raster #3
		.byte	<[?log+8*4],[4<<5]|24,>[?log+8*4],$80		;A		- raster #4
		.byte	<[?log+8*5],[5<<5]|24,>[?log+8*5],$a0		;R		- raster #5
		.byte	<[?log+8*6],[6<<5]|24,>[?log+8*6],$c0		;T		- raster #6
		.byte	<[?log+8*7],[7<<5]|24,>[?log+8*7],$e0		;atari sign	- raster #7
		.byte   $00,$00


; The DLL starts here - $1870

// DLList - g³ówny program dla uk³adu MARIA (lista Display List)
// sk³ada siê z odwo³añ do innych programów tworz¹cych obraz (Display List)

//  _______________________________   _______________________________    _______________________________
// |   |   |   |   |               | |                               | |                               |
// |DLI|H16| H8| 0 |  O F F S E T  | |  S T A R S Z Y  B A J T  D L  | |  M £ O D S Z Y  B A J T  D L  |
// |___|___|___|___|___|___|___|___|,|___|___|___|___|___|___|___|___|,|___|___|___|___|___|___|___|___|

		Align   32
DLList		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii

; LOGOS

// wyœwietlane litery logosa maj¹ wysokoœæ 32 linii, ale OFFSET jest tylko 4-bitowy, dlatego musimy tak du¿¹ grafikê 
// podzieliæ na czêœci, czêœci których maksymalna dopuszczalna wysokoœæ wynosi 16 linii

		// 16 górnych linii wyœwietlanej grafiki
		.byte   $0f,>dl_logo_2,<dl_logo_2	;upper part of the gfx

		// 16 dolnych linii wyœwietlanej grafiki
		.byte   $0f,>dl_logo_1,<dl_logo_1	;lower part of the gfx


		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii

		.byte   $07,>DLLine1,<DLLine1		// TEKST
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLLine1,<DLLine1		// TEKST
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLLine1,<DLLine1		// TEKST
		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii
		.byte   $07,>DLLine1,<DLLine1		// TEKST

		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
		.byte   $0f,>DLBlank,<DLBlank		; 16 pustych linii
;		.byte   $07,>DLBlank,<DLBlank		; 8 pustych linii

		.byte   $00,>DLBlank,<DLBlank		;end of DLL


;************** Cart reset vector **************************

	org	$fff8
	.byte	$00	;Region verification
	.byte	$00	;ROM start $4000
	.word	NMI
	.word	START
	.word	IRQ


	opt l-
	icl '..\align7800.mac'

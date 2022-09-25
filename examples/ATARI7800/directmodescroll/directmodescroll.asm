
		icl '..\maria.h'

		opt f+h-

		org $40
dest 	.ds 2 		;2 bytes
sour	.ds 2
temp	.ds 2
adc_temp .ds 1
reg_x	.ds 1
reg_y	.ds 1
reg_a	.ds 1
sin_count	.ds 2
Random	equ $400A
;
tabstart	equ $2600
tab_en		equ tabstart 		;16 bytes
x_en		equ tabstart+16
y_en		equ tabstart+32
spr_count 	equ tabstart+48	 ;16*2bytes
spr_color 	equ tabstart+64
spr_faz		equ tabstart+80

          ORG     $8000-128
HEADER       .byte    1  			; 0   Header version     - 1 byte
        .by    "ATARI7800       "	; 1..16  "ATARI7800   "  - 16 bytes
        .by    "Scroll & Sprites"	; 17..48 Cart title      - 32 bytes
        .by    "  by EAGLE 2022 "	; 2 line
        DTA r	($8000)				; 49..52 data length      - 4 bytes (Big-endian format)
        .byte    $00,$01  			; 53..54 cart type      - 2 bytes
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
@	lda #$00
	sta (dest),y
	inw dest
	lda dest+1
	cmp #>[:2+1]
	bne @-
	.endm


            org $8000
;MADS 256 bytes sinus table
/*********************************************************
SIN(centre,amp,size[,first,last])
where:

centre     is a number which is added to every sine value
amp        is the sine amplitude
size       is the sine period
first,last define range of values in the table. They are optional.
           Default are 0,size-1.

Example: dta a(sin(0,1000,256,0,63))
         defines table of 64 words representing a quarter of sine with
         amplitude of 1000.
*********************************************************/
sinus
	dta b(sin(54,54,128))
	dta b(sin(54,54,128))

	.use DLLs
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
		clear_ram $4000,$7FFF

;Init Pokey - we need Random numbers!
		lda #$03
		sta $400F

; copy Display List List To RAM
		ldx	#$00
CopyLoop:
		lda	.adr DLLs,x
		sta	$1800,x
		lda	.adr DLLs+$100,x
		sta	$1900,x
		lda	.adr DLLs+$200,x
		sta	$1A00,x
		lda	.adr DLLs+$300,x
		sta	$1B00,x
		lda	.adr DLLs+$400,x
		sta	$1C00,x
		lda	.adr DLLs+$500,x
		sta	$1D00,x
		inx
		bne	CopyLoop

		mva #<DLLs DPPL\ mva #>DLLs DPPH	;set display list list address
		jsr	WaitVBLANK						;wait until no DMA would happen

		mva	#$40	CTRL
;set colors
		mva	#$00 BACKGRND\ mva #$08 P0C1\ mva #$14 P0C2\ mva #$0c P0C3
		mva	#$00 BACKGRND\ mva #$28 P1C1\ mva #$24 P1C2\ mva #$2c P1C3
		mva	#$00 BACKGRND\ mva #$48 P2C1\ mva #$44 P2C2\ mva #$4c P2C3
		mva	#$00 BACKGRND\ mva #$68 P3C1\ mva #$64 P3C2\ mva #$6c P3C3
		mva	#$00 BACKGRND\ mva #$88 P4C1\ mva #$84 P4C2\ mva #$8c P4C3
		mva	#$00 BACKGRND\ mva #$a8 P5C1\ mva #$a4 P5C2\ mva #$ac P5C3
		mva	#$00 BACKGRND\ mva #$c8 P6C1\ mva #$c4 P6C2\ mva #$cc P6C3
		mva	#$00 BACKGRND\ mva #$e8 P7C1\ mva #$e4 P7C2\ mva #$ec P7C3
;
;Init sprites - 1 in Tab_en (short from tab_enemy) = sprite ON
		lda #$01
		ldx #$0F
@
		sta tab_en,x
		dex
		bpl @-
; assign random pallets for 16 sprites
		ldx #$0F
@
		lda Random
		and #$E0	;choose random pallet
		ora #$1D	;width = 3bytes (you can change to make smaller or bigger) warrning: wider sprite can crash Maria DMA timing
		sta spr_color,x
		dex
		bpl @-



	mva	#10	x_en
	mva	#20	x_en+1
	mva	#30	x_en+2
	mva	#40	x_en+3
	mva	#50	x_en+4
	mva	#60	x_en+5
	mva	#70	x_en+6
	mva	#80	x_en+7
	mva	#90	x_en+8
	mva	#100	x_en+9
	mva	#110	x_en+10
	mva	#120	x_en+11
	mva	#130	x_en+12
	mva	#140	x_en+13
	mva	#150	x_en+14
	mva	#160	x_en+15

main
		jsr WaitVBLANK
		mva #$0a BACKGRND	;show CPU usage

		jsr update_scroll
		jsr reset_row
		jsr Clear_all_sprites		;delete all srites from previous Vblank (put $00 in second byte after scroll/background data)
		jsr	put_sprites_on_screen
		jsr Sinus_path
		mva #$00 BACKGRND
		jmp main


put_sprites_on_screen
	ldx #$00

loop_put_sprites_on_screen
	lda tab_en,x
	stx reg_x
	beq skip_put_sprite
	jsr put_sprite
skip_put_sprite
	ldx reg_x
	inx
	cpx #16
	bne loop_put_sprites_on_screen
	rts


Sinus_path
	inc sin_count

	lda	sin_count
	tax
	ldy #$0f
loop_sinus
	lda	sinus,x
	clc
	adc #20		;center sprites
	sta x_en,y
	txa
	clc
	adc #25
	tax
	lda	sinus,x
	sta	y_en,y
	txa
	clc
	adc #15
	tax
	dey
	bpl loop_sinus
	rts

;This time we update only DL for scrolling parts
update_scroll
		:16 change_x Line1,#
		:16 change_x Line2,#
		:16 change_x Line3,#
		:16 change_x Line4,#
		:16 change_x Line5,#
		:16 change_x Line6,#
		:16 change_x Line7,#
		:16 change_x Line8,#
		:16 change_x Line9,#
		:16 change_x Line10,#
		rts

reset_row
		mwa #line1 sour
		ldy #$03	;+3 - xpos in DL
		ldx #$00
@
		lda (sour),y
		cmp #$F4
		beq @+
		adw sour #$04
		inx
		cpx #16
		bne @-
		rts

@	:10	write_row 	;write 10 times
		rts

	;parametr :1 - address DL line, +3 (xpos in DL)
	;parametr :2 - #*4 (# - loop counter) skip 4 bytes to next DL
	;to make ?easier? for this example, DL_End is !!!4 bytes!!! instead of 2 bytes (sorry)

		.macro change_x
		dec :1+3+[:2*4]
		.endm

		.macro write_row
		lda #180		;xpos = 180 after tile is disappear on left side
		ldy #$03		;xpos in DL
		sta (sour),y

;don't look down :)
;this is only for draw new tiles
;
;choose random Tile
		lda Random
		and #$0F		;from 0-15
;multiply x3 because Tiles are 3 bytes width
		sta temp		;=*1
		asl @			;=*2
		clc
		adc temp		;=*3
;
		ldy #$00		;update LSB
		sta (sour),y
;get random pallet for Tile
		lda Random
		and #$E0		;we use only highest 3 bits for pallet
		ora #$1D		;ora width of tile (3 bytes)
		ldy #$01		;update pallet
		sta (sour),y
		adw sour #[33*4]	;16 DL*4bytes in one DL line +16 DL*4bytes for sprites + 2 zero ending DL + 2 extra zero to simplify math
		.endm

	.macro	tablica_line
	.word [:1],[:1+4],[:1+8],[:1+12],[:1+16],[:1+20],[:1+24],[:1+28],[:1+32],[:1+36],[:1+40],[:1+44],[:1+48],[:1+52],[:1+56],[:1+60]
	.endm

;Sprite addreses in DL line after scroll DL
tab_line
	tablica_line line1+64
	tablica_line line2+64
	tablica_line line3+64
	tablica_line line4+64
	tablica_line line5+64
	tablica_line line6+64
	tablica_line line7+64
	tablica_line line8+64
	tablica_line line9+64
	tablica_line line10+64


;put $00 in second byte (dl end)
Clear_all_sprites
	lda #$00
	sta Line1+1+64
	sta Line2+1+64
	sta Line3+1+64
	sta Line4+1+64
	sta Line5+1+64
	sta Line6+1+64
	sta Line7+1+64
	sta Line8+1+64
	sta Line9+1+64
	sta Line10+1+64

	ldx #$0F
	lda #$00
loop_spr_count
	sta spr_count,x
	dex
	bpl loop_spr_count
	rts


put_sprite
; I have no idea how this work :) I did this long time ago and now merge with scroll and it's working
; I translate some comments from Ponglish to English :D Enjoy
;
	ldy y_en,x		;Y position
	sty adc_temp	;copy
	lda tab_y,y 	;address dll
	sta reg_a
	ldx tab_spr_count,y
	lda spr_count,x
	inc spr_count,x
	asl @
	clc
	adc reg_a
	tay

	lda tab_line,y
	sta dest
	lda tab_line+1,y
	sta dest+1

	ldy #$00
	ldx reg_x
	lda tab_faz,x 	;sprite address (you can use for sprite animation)
	sta (dest),y
	iny
	lda spr_color,x	;pallet number and width sprite
	sta (dest),y
	iny

	lda adc_temp
	and #$0f
	clc
	adc #>[sprite_data]
	sta (dest),y
	iny
	lda x_en,x		;x sprite
	sta (dest),y
	iny
	iny
	lda #$00		;write $00 to mark end DL
	sta (dest),y

	lda adc_temp
	clc
	adc #16
	sta adc_temp
	tay

	lda tab_y,y ;adres dll
	sta reg_a
	ldx tab_spr_count,y
	lda spr_count,x
	inc spr_count,x
	asl @
	clc
	adc reg_a
	tay

	lda tab_line,y
	sta dest
	lda tab_line+1,y
	sta dest+1
	ldy #$00
	ldx reg_x
	lda tab_faz,x		;sprite address (you can use for sprite animation)
	sta (dest),y
	iny
	lda spr_color,x		;pallet number and width sprite
	sta (dest),y
	iny
	lda adc_temp
	and #$0f
	sec
	sbc #$10
	clc
	adc #>[sprite_data]
	sta (dest),y
	iny
	lda x_en,x		;x sprite
	sta (dest),y
	iny
	iny
	lda #$00	;write $00 to mark end DL
	sta (dest),y
	rts

tab_y
	:16 .byte 0
	:16 .byte $20
	:16 .byte $40
	:16 .byte $60
	:16 .byte $80
	:16 .byte $a0
	:16 .byte $c0
	:16 .byte $e0
tab_spr_count
	:16 .byte 0
	:16 .byte 1
	:16 .byte 2
	:16 .byte 3
	:16 .byte 4
	:16 .byte 5
	:16 .byte 6
	:16 .byte 7
tab_msb
	:8	.byte 0
	:8	.byte 1
	:8	.byte 2
	:8	.byte 3
	:8	.byte 4
	:8	.byte 5
	:8	.byte 6
	:8	.byte 7
	:8	.byte 8
	:8	.byte 9
	:8	.byte 10
	:8	.byte 11
	:8	.byte 12
	:8	.byte 14
	:8	.byte 15

;address of sprites from 0 to 15 in sprite_bank
tab_faz
	.byte 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45

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

;**************************************************
;Maria bank $E000
;**************************************************
;tiles and sprites
		org $E000
;
sprite_data
		ins 'tiles16Maria.raw'


;**************************************************
; RAM
;**************************************************
		ORG	$1800,*
.local DLLs
	:3	.byte	$0F,>emptyline,<emptyline	;3 empty DLL

		.byte	$4F,>line1,<line1
		.byte	$4F,>line2,<line2
		.byte	$4F,>line3,<line3
		.byte	$4F,>line4,<line4
		.byte	$4F,>line5,<line5
		.byte	$4F,>line6,<line6
		.byte	$4F,>line7,<line7
		.byte	$4F,>line8,<line8
		.byte	$4F,>line9,<line9
		.byte	$4F,>line10,<line10

	:7	.byte	$0F,>emptyline,<emptyline	;7 empty DLL

	.byte 0

	.macro DL_4byte
;		  LSB,palette+width,MSB,Xpos
	.byte <$E000,$1d,>$E000,:1*12
	.endm

	.macro Dl_End
	.byte $00,$00
	.byte $00,$00	;extra two zero to simplify program (or not? :D )
	.endm

	.macro Sprites
	.byte $00,$00,$00,$00
	.endm

line1		:16 DL_4byte #
			:16 Sprites
			DL_End
line2		:16 DL_4byte #
			:16 Sprites
			DL_End
line3		:16 DL_4byte #
			:16 Sprites
			DL_End
line4		:16 DL_4byte #
			:16 Sprites
			DL_End
line5		:16 DL_4byte #
			:16 Sprites
			DL_End
line6		:16 DL_4byte #
			:16 Sprites
			DL_End
line7		:16 DL_4byte #
			:16 Sprites
			DL_End
line8		:16 DL_4byte #
			:16 Sprites
			DL_End
line9		:16 DL_4byte #
			:16 Sprites
			DL_End
line10		:16 DL_4byte #
			:16 Sprites
			DL_End


emptyline	.byte $00,$00

	.endl

;************** Cart reset vector **************************

	 ORG	$fff8
	.byte	$FF		;Region verification
	.byte	$87		;ROM start $8000
	.word	NMI
	.word	START
	.word	IRQ


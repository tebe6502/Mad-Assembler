
		icl 'maria.h'

		opt f+h-m+

		org $40
dest 	.ds 2 		;2 bytes
sour	.ds 2
temp	.ds 2
reg_x	.ds 1
reg_y	.ds 1
reg_a	.ds 1
tile1	.ds 1
tile2	.ds 1
tile3	.ds 1
level_complete .ds 1
level_number .ds 1
scr = $1900
buffor = $1a00

          ORG     $8000-128
HEADER       .byte    1  			; 0   Header version     - 1 byte
        .by    "ATARI7800       "	; 1..16  "ATARI7800   "  - 16 bytes
        .by    "  uSokoban      "	; 17..48 Cart title      - 32 bytes
        .by    "  by EAGLE 2022 "	; 2 line
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


            org $8000
;	.use DLLs
START
		sei					;Disable interrupts
		cld					;Clear decimal mode
		mva #$07 INPTCTRL
		mva	#$7F CTRL
		mva	#$00 OFFSET
		mva #$00 INPTCTRL
		ldx	#$FF			;Reset stack pointer
		txs
; copy Display List List To RAM
		ldx	#$00
CopyLoop:
		lda	.adr DLLs,x
		sta	$1800,x
		inx
		bne	CopyLoop		

		mva #<DLLs DPPL\ mva #>DLLs DPPH	;set display list list address
		jsr	WaitVBLANK						;wait until no DMA would happen

		mva #$00 level_complete
		mva	#>sprite_data CHBASE
		mva	#$40+$10	CTRL	;double byte char
;set colors
		mva	#$00 BACKGRND\ mva #$23 P0C1\ mva #$88 P0C2\ mva #$ac P0C3
;
		mva #$00 level_number
;
	.macro Test_tile
		lda scr,x
		sta tile1
		lda scr:1,x
		sta tile2
		lda scr:2,x
		sta tile3
		jsr checktiles
		beq @+
		lda tile1
		sta scr,x
		lda tile2
		sta scr:1,x
		lda tile3
		sta scr:2,x
@		rts		
		.endm

	.macro mulu2 
		clc\ rol temp\ rol temp+1
	.endm		


restart 
		ldy #20		;wait 50 frames
		jsr DelayVB
		mva #$00 level_complete
		jsr copy_level

main 
		jsr Find_Sokoban	;result in X
		jsr Joystick  		;use X from Find_Sokoban
		jsr Check_level_complete
		jsr Put_on_screen
		jsr Console_Switches  
;
		lda Level_complete
		beq Main
;
		inc Level_number  
		jmp Restart  

joystick 
			lda SWCHA
			and #$F0
			cmp #$F0
			bne joy_used 
			rts
joy_used	ldy #12			;wait 12 frames
			jsr DelayVB
			cmp #%10110000	;left
			bne joy_right
			Test_tile -1,-2
joy_right	cmp #%01110000	;right
			bne joy_up
			Test_tile +1,+2
joy_up 		cmp #%11100000	;up
			bne joy_down 
			Test_tile -8,-16
joy_down 	cmp #%11010000	;down
			bne endjoy
			Test_tile +8,+16
endjoy 	rts

;@ player 
;+ player on deck 
;. deck
;$ crate
;* crate on deck
;  floor
;
;2 bytes patterns
pattern	.byte '+ @ +.@.'
replace .byte '.@ @.+ +'
;3 bytes patterns
pattern3	.byte '+$ @$ +* @* +$.@$.+*.@*.'
replace3	.byte '.@$ @$.+$ +$.@* @*.+* +*'
;
checktiles
	ldy #$00
@	lda tile1
	cmp pattern,y
	bne @+
	lda tile2
	cmp pattern+1,y
	bne @+
	mva replace,y Tile1
	mva replace+1,y Tile2
	rts
@	:2 iny
	cpy #8
	bne @-1
;
	ldy #$00
@	lda tile1
	cmp pattern3,y
	bne @+
	lda tile2
	cmp pattern3+1,y
	bne @+
	lda tile3
	cmp pattern3+2,y
	bne @+
	mva replace3,y Tile1
	mva replace3+1,y Tile2
	mva replace3+2,y Tile3
	rts
@	:3 iny
	cpy #24
	bne @-1
	rts

find_sokoban
		ldx #64-1
@		lda scr,x
		cmp #'@'
		beq	found_sokoban 
		cmp #'+'
		beq found_sokoban 
		dex
		bpl @-
found_sokoban 
		rts		;Z=0 - found, X= where is

check_level_complete  
		ldx #64-1
@		lda scr,x
		cmp #'.'
		beq level_not_finish
		cmp #'+'
		beq level_not_finish
		dex
		bpl @-	
		lda #$01			;level completed
		sta level_complete
level_not_finish
		rts

copy_level
		mwa	#lvl sour
		mwa #scr dest
		mva level_number temp
		mva #$00	temp+1
		:6 mulu2 				
		adw sour temp
		ldy #$00
@		lda	(sour),y
		sta (dest),y
		iny
		cpy #64
		bne @-
		rts

put_on_screen 
		mwa #scr sour
		mwa #buffor dest
		ldy #$00
@		lda (sour),y
		tax
		lda tabscr,x
		asl @
		sta (dest),y
		iny
		cpy #64
		bne @-
		rts
tabscr
		.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.byte 0,0,0,1,2,0,0,0,0,0,4,5,0,0,3,0 
		.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.byte 5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DelayVB 
		jsr WaitVBLANK
		dey
		bpl DelayVB
		rts

Console_Switches
			lda SWCHB
			and #$03
			eor #$03
			cmp #$01
			beq start_pb 
			cmp #$02
			beq select_pb
			rts
start_pb	lda SWCHB
			and #$03
			eor #$03
			bne start_pb			
			mva #$01 level_complete
			rts
select_pb
			lda SWCHB
			and #$03
			eor #$03
			bne select_pb			
			dec level_number
			mva #$01 level_complete
			rts

WaitVBLANK:	
WaitVBoff:
			bit		MSTAT
			bmi		WaitVBoff
WaitVBon:	bit		MSTAT
			bpl		WaitVBon
			rts

NMI		RTI
IRQ		RTI


;**************************************************
;All levels
;**************************************************
lvl		ins 'picoban.txt'


;**************************************************
;Maria bank $E000
;**************************************************
;tiles and sprites
		org $E000
;
sprite_data 
		ins 'sokobantiles.raw'



;**************************************************
; RAM
;**************************************************
;
		.macro DLL_entry  
		.byte	$0F,>[line0+[8*:1]],<[line0+[8*:1]]
		.endm 
		.macro one_dll_line 
		;	LSB,Mode,MSB,PalletOraWidth,XPos
		.byte	<[buffor+[:1*8]],$60,>[buffor+[:1*8]],$18,48,0,0,0
		.endm
;
		ORG	$1800,*
.local DLLs
	:3	.byte	$0F,>emptyline,<emptyline	;3 empty DLL

firstline		:8 DLL_entry #

	:7	.byte	$0F,>emptyline,<emptyline	;7 empty DLL

line0	:8	one_dll_line #
emptyline	.byte $00,$00

	.endl

;************** Cart reset vector **************************

	 ORG	$fff8
	.byte	$FF		;Region verification
	.byte	$87		;ROM start $8000
	.word	NMI
	.word	START
	.word	IRQ


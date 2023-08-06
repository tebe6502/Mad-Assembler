;                       /|
;                      //|.
;                     //_| .
;                 __ // /| .
;                /_ \/\__|. 
;                \\_/  _/|_
;                .g.e.n.d.a.
;
;______________________________________________________
;
; Algorytm - 1K glitchy intro by Agenda
; for Forever 2019
; code/msx/gfx: svoy
; gfx: Piesiu
; tomaswoj@gmail.com
; http://pl.linkedin.com/in/tomaswoj
; Nov 2018 - Feb 2019  
; Cracow, Copehagen/Glostrup, Schaumburg, Munich (airport :)), Frankfurt (airport :)).
; BIG KUDOS to Koala for optimization help (50+ cut bytes credit goes to him, lots of valuable suggestions and help)!

; good illegal opcodes cheatsheet:
; https://xxl.atari.pl/sally-6502c/?fbclid=IwAR3OzILLYZpJnamVOBDI--wNp4vY2LQcgmczaggsgr0E0glVCs9L9vWFS88
; but no illegals used here... :P

	opt h+		
	org $6003 ; thanks to this Koala re-org we can reuse lo/hi of VBLK for proper sound initialization

; common constants
FRMCNT	equ $d3
SECTION equ $d4
CHINDEX	equ $d5
FRM4	equ $d6
FRM5	equ $d7
PTRN4	equ $d8
NOISV	equ $d9
JMP_L	equ $20 ; jump vector low 
JMP_H	equ $21
PMG2POS equ $94
VOLUME	equ $d0
SCREEN	equ $9c40

MYBASE	equ $2000 ; 2K boundary
FREQ	equ $3300
MYCBASE	equ $4000 ; charbase

; OS/VBLK constants
VVBLK_L	equ $224
VVBLK_H equ $225 ; shadow of VBLANK interrupt routine
AUDC1	equ $D201
AUDC2	equ $D203
AUDC3	equ $D205
AUDC4	equ $D207
AUDF1	equ $D200
AUDF2	equ $D202
AUDF3	equ $D204
AUDF4	equ $D206
AUDCTL 	equ $D208 ;
SKCTL	equ $D20f;

; fx1 constants
;--------------
PMG3POS equ $95
PMG4POS equ $96
BASIC	equ $a000
SCR_1	equ $803a
SCR_2	equ $809a


; fx2 constants
; -------------
PIX_I	equ $97	
PIX_L	equ $98
PIX_H	equ $99
IMG_L	equ $9a
IMG_H	equ $9b

IMG_TMP	equ $9c
MIR_TMP	equ $9b

PIX_SEL	equ $9d
PIX_REA	equ $9e

OFFSET	equ $9f
IMGADDR equ $a0


PICSTAL	equ $9c40+19*40+20
PICSTAR	equ $9c40+19*40+20+8
PICMIRL	equ $9c40+19*40+11
PICMIRR	equ $9c40+19*40+20

; fx3 constants
; -------------
DLIST	equ $9c20

; main intro loop, run on every VBLANK, plays sound, then switches to main (current) fx code
; at the end of section (FRMCNT = 256=0) it runs the exit fx code, that preps the scene for
; the next fx, all driven by demo flow data table at the end 	
myvbl:
	; SOUND SECTION
	ora FRMCNT	
	sta AUDF1 ; modulate slightly the background beat
	
	lda FRMCNT
	tay
	ldx #$1a	
	and #%00100000
	bne secfreq
	ldx #$da
secfreq:		
	stx AUDF3
	; main beat
	tya ; get FRMCNT from the y register
	and #%00011111
	sta FRM5
	tax
	lda kickbas,x
	lsr	
	sta AUDC3
	;
	tya ; get FRMCNT
	and #%00001111
	tax
	lda sndkick5,x	 
	sta AUDC1	
	; lead sound, but start from section 5
	lda SECTION
	sta CHINDEX
	cmp #5
	bcc skip_lead
	lda sndkick6,x	; x already contains right value?	
	sta AUDC2
	tya
	lsr
	lsr
	lsr
	lsr
	and #%00000111	
	tax
	lda leadnotes,x	
	sta AUDF2
skip_lead:	
	; background lead sound	
	ldx SECTION
	lda seclead-1,x
	sta AUDF4
	lda #%10100010
	sta AUDC4
	; SOUND END
				
	lda #0 ; zero offset for fx run addresses
	jsr jumper ; 5b
		
runback: ; now it is handled by rts from the fx code itself
	
	inc FRMCNT
	; if not the end of the section, continue w/o increasing the section
	bne skipsec
	; now do some section exit stuff
	lda #(EXIT_L-RUN_L) ; calculate offset based on sections count
	jsr jumper	; run the fx exit/next fx prep function, if applicable
	
exitback:	
	; now increase the section
	inc SECTION	
skipsec:	
	jmp $E462 ; return procedure after memory map
 	
 	; program entry point
 	; setup basic and OS ON
	;lda #%00110001
	;sta $D301 ; PORTB
program:	
	lda #3
	sta VVBLK_L ; VBLK init (lo)
	sta SKCTL ; sound init
	
	ldy #%01100000
	sty AUDCTL ; sound init
	sty VVBLK_H ; VBLK init (hi)

		
; fx1 prep procedure
;--------------------------------------------------	
fx1_prep:
	
	lda #8
	jsr $EF9C

	lda #>BASIC
	sta SCR_1+1	
	lda #>(BASIC+600) ; pot 1b? by inx
	sta SCR_2+1 ; used for randomized background content
	
				
	;sei
	lda #>mybase
	sta $D407; set PMBASE, needs to be at 1K boundary for double resoultuon and 2K boundary for single resolution sprites (Every line)

	lda #55
	sta $D008 ; setup pmg0 size to x4	
	ldy #4
pmgposloop:
	asl
	sta PMG2POS-2,y ; for further use
	dey
	bne pmgposloop	

	;ldy #0
fx1black:
	lda #$cc
	sta mybase+640+14,y
	lda #$aa	
	sta mybase+768+14,y
	dey
	bne fx1black
	
; general intro setup
	;ldy #0; - reuse 0 from the above?
	;sty FRMCNT ; not needed??
	;sty SECTION
	
	jsr setpmg
	cli
	

; fx1 prep end	
;--------------------------------------------------

frame
	; play sound here or fx code
	; most of magic done in VBLK
mainjsr:
	jsr empty ; main fx loop, outside of VBLANK (if exists) to be plugged here
	bvc frame
					
; --------------------------------------------------------
; main end
; --------------------------------------------------------


; simple jumper code, used to run the fx function and fx exit function
jumper:
	clc
	adc SECTION
	tax

	;alternative approach to make this jump (thanks for the tip Koala!), 4b less than a 'typical' code:
	lda RUN_H,x
	pha
	lda RUN_L,x
	pha
	rts

; main VBLKed fx functions (run 60FPS):

; fx1 --------------------------------------------------
; random gfx modes (GTIA) changes, central symbol, background PMG bars
fx1_vbl:	
; copy logo to pmg1
	ldy #(4*8)	
fx1logocpy:
	;lda agpmg,y
	tya
	lsr
	lsr
	tax
	lda square3+1-1,x	
	sta mybase+512+14+34,y
	dey
	bne fx1logocpy
	
	lda $D20a
	sta SCR_1
	sta SCR_2

	
	ora #%00000001 ; all upfront ; pot 2bytes, limited visual artifacts
	and #%11000001
	;sei
	;lda #%00000001
	sta $D01b ; GPRIOR and GTIA modes	

	; now move the background PMG lines around
	inc PMG2POS
	dec PMG3POS
	inc PMG4POS

		
	; update their actual positions... with PMG0 standing still
	ldy #4
moveloop:		
	lda PMG2POS-2,y
	sta $D000-1,y
	lda $D20a ; reuse loop for size changes
	sta $D009-1,y ; size
	dey
	bne moveloop
	
	;jmp pmgblink ; can be skipped
	;rts

pmgblink:
	; play with PMG color to the beat
	ldy FRM5
	lda kickbas,y
	sta $D012
	rts

; fx1 end ----------------------------------------------

; fx1 exit function (fx2 prep)--------------------------
fx2_prep:

; clean pmg0
	jsr cleanpmg0
	
; populate filled PMG square at the bottom left
	ldy #7
	sty PTRN4 ; PMG pattern to be used in fx4
	iny	  ; and now use it for the loop counter
	lda #$ff ; full square
black:
	sta mybase+512+111,y ; bottom left
	dey
	bne black

	; populate the data with semirandom (BASIC)
	;ldy #255; reuse 0 from the previous loop
randcpy:
	lda $A000,y
	sta algtext+40,y
	sta SCREEN,y
	dey
	bne randcpy
	rts ; cannot skip this as we are reusing the procedure in another effect (fx3)
	
; fx1 exit end -----------------------------------------

; fx2 --------------------------------------------------
; simple full screen pictures, made of text mode and swapping charsets
; interleaved with pseudorandom, sound synced sections
fx2_vbl:
	
	;calc pmg size based on beat
	ldx FRM5 
	lda kickbas,x
	and #%00000011		 
	sta $D008 ; set pmg size to x1
		
			
	lda frmcnt
	bne skip_gfx_reset
	
	; on 0 frame in section reset GFX so we are displaying the picture
	sei
	;lda #0 ; looks like it is already set to 0, nice :)	
	sta OFFSET ; used in target address drawing, no offset for regular picture
	jsr $EF9C ; reset gfx mode
	;cli; seems not needed here
	
	sta 710 ; set background to black
	sta SCREEN+2 ; cleanup the cursor ; pot 3 bytes savings (if no cursor clear, but not nice)
	
	; now iterate through pictures 0-3		
	lda SECTION ; we can use the section counter as picture selector...
	and #%00000011
	sta PIX_SEL
	tax
	ldy colors,x
	sty 704 ; shadow for PMG0 color
	;sty $D012
			
skip_gfx_reset:
	ldx #0	
	lda frmcnt ; if noise to be drawn, pass through bpl...
	bpl display
drawnoise:
	; PMG setup
	jsr setpmg
	; randomize location/pixel selection
	lda $D20a
	sta OFFSET
	sta PIX_SEL
	inx ; reuse as x=0 (still), and now it will be x=1, so used for colors/charbase/pmgpos selector below
	
display:	
	; assume x contains right data pair index, 0 for picture, 1 for noise
	lda datapar-1,x
	sta $D000 ; set PMG0 pos
	lda datapar+2-1,x
	sta $D409
	lda datapar+4-1,x	
	sta $D017 ; set the foreground color 

	; modify charbase for the picture, depends on the framecount
	lda FRMCNT
	bmi skipcharmod
	lsr
	lsr
	lsr
	lsr
	lsr
	sta CHINDEX
	jsr updlog	
skipcharmod:	

	; calculate offset based on picture selection (PIX_SEL*16+16)
	lda PIX_SEL	
	asl
	asl
	asl
	asl
	adc #16
	tay 	
	ldx #16
copyimgdata: ; copy the image data fo display
	lda imgl-1,y
	sta IMGADDR-1,x
	dey
	dex
	bne copyimgdata
	
	; now display it	
	lda #<PICMIRR
	jsr showerMirror
	lda #<PICMIRL
	;jsr showerMirror ; lovely! 4-foking-bytes less!!!		
	;rts	

showerMirror:
	adc OFFSET	
	sta PIX_L ; moved from outside of JSR
	ldx #>PICMIRL ; does not matter whether its PICMIR or PICMIR, both are $9f
	stx PIX_H ; moved from outside of JSR
	ldx #16 ; amount of lines
imglineMirror:	
	lda IMGADDR-1,x
	sta IMG_TMP
	ldy #8
pixloopMirror:
	lda IMG_TMP
	and #%10000000
	sta (PIX_L),y
	asl IMG_TMP
	ror MIR_TMP	
	dey	
	bne pixloopMirror
	; copy the mirror to the data
	lda MIR_TMP
	sta IMGADDR-1,x
	; now move the line down
	lda PIX_L;
	sec
	sbc #40
	bcs skipdec_h40		
	dec PIX_H
skipdec_h40:	
	sta PIX_L;
	;rts
	dex
	bne imglineMirror	
	rts

; fx2 end ----------------------------------------------

; fx2 exit ---------------------------------------------
; prep for fx 3
fx3_prep:
	;lda #0 ; again, looks like its not needed :)
	jsr $EF9C
	jsr randcpy ; populating there the random content (upper lines of the screen)	
	
; clean pmg0
	jsr cleanpmg0
	; move pmg1 and pmg2 off screen
	;lda #0 ;a=0 already :)
	;sta $D002 ; no need for that, as it looks to be offscreen already, from the previous fx	
	sta $D003
	sta 704 ; set pmg0 to colors
		
; copy square icon to PMG		
	ldy #(16+2)
fx3_logocpy:
	tya
	lsr
	tax
	lda square3-1,x	
	sta mybase+512+14+84-1,y
	dey
	bne fx3_logocpy

	;sizes x 2
	iny ; reuse y=0 above 
	sty $D008
	sty $D009 ; do it for the next fx
				
	;PMG0 horizontal pos
	lda #192
	sta $D000
	
	
	jsr setpmg
	;cli ; seems that it is not needed

;crdlist:
	; $9c20 DL start
	; 70 70 70 42 40 9c
	; 0 - 10 - ... 70 - 8 blank lines
	; 20 x 02 (text mode 0, 0f - text mode 15, hires)
	; 41 20 9c ; jmp back
; the section below not needed after all! :) it will be randomized anyway as part of the frame
;	ldy #20
;emptyline:
;	lda #$70
;	ldx $D20a
;	cpx #128
;	bcs emptyskip
;	lda #$2f
;emptyskip:		
;	sta DLIST,y
;	dey
;	bne emptyline

; end list creation, text copy, colors setup, all in one fat loop
				
	ldy #40
copytxt
	; setup the text line
	lda algtext-1,y
	sta screen-1,y
	; setup end of display list
	lda enddlst-1,y
	sta $9c20+21-1,y
	; setup colors	
	lda coltab-1,y
	sta 708-1,y		
	dey
	bne copytxt	
		
; setup fx3 main frame:
	lda <fx3_frame
	sta mainjsr+1
	;lda >fx3_frame ; assume its 21 for now :)
	;sta mainjsr+2		
	;rts ; pot

; fx2 exit end -----------------------------------------

; fx3 frame --------------------------------------------
; randomized display list + intro title text
; on top of rapid changes of background color - resulting in grayscale like
; gradient, PMG logo blinking to the sound...
fx3_frame:
	lda $D40b
	lsr
	lsr
	lsr
	and $D20a	
	sta $d01a
	rts 	
; fx3 frame end ----------------------------------------

; fx4 frame --------------------------------------------
fx4_frame:
	lda #$c3	;Ensure charset is in ROM area
	ora $d20a	;Random
	sta $d409	;Set charset
	ldx CHINDEX
	and noiscol,x ; modify color of the noise	
	sta $d016	;make some color
empty:
	rts 
; fx4 frame end ----------------------------------------
	
; fx3 vblk ---------------------------------------------
fx3_vbl:

	; mess up display list
	ldy #20	
dlistmess:
	lda $D20a
	and #%00001110
	sta DLIST,y
	dey
	bne dlistmess
	
	;jsr pmgblink	
	;rts - part of pmgblink
	jmp pmgblink ; instead of the 2 lines above :)
; fx3 vblk end -----------------------------------------

; fx4 prep ---------------------------------------------
fx4_prep:
	lda #2
	jsr $EF9C
	stx $26f ; ok here
	
	jsr setpmg
	;cli

	jsr cleanpmg0
		
	sty $D001 ; hide 'end' PMG for now
	lda #66 ; pmg0 position
	sta $D000
	
	
; setup fx4 main frame:
	lda <fx4_frame
	sta mainjsr+1
	lsr
	sta 705 ; use it ($A) for the 'end' PMG color
	;lda >fx4_frame ; assume its 21 for now :)
	;sta mainjsr+2
	;rts			
	
; fx4 prep end -----------------------------------------
; fx4 effect
; randomized charset changes, as quick as possible, resulting
; in nice randomized patterns. On the left side PMG graphics animation
; ending with 'END' PMG shown 
fx4_vbl:
	ldy FRM5
	lda kickbas,y
	sta 712 ; 712/$D01A?

	lda frmcnt	
	ror
	bcs skiprot ; rotate the PMG0 every 2nd frame, so its not too fast
	
	ldy #95 ; very interesting pattern if commented out 
	lda PTRN4	
rotcol:	
	asl
	adc #0		
	sta MYBASE+512+16,y
	dey
	bne rotcol
	sta PTRN4 ; save the 'rotated' pattern for the next iteration (by 1px)

skiprot:
	ldy #(16+2)
fx4_logocpy: ; keep the logo (square) non-rotated, so just copy it, also copy the end string pmg here
	tya
	lsr
	tax
	lda square3-1,x	
	sta mybase+512+14+70-1,y
	lda endstr,x
	sta MYBASE+512+128+14+74-1,y	
	dey
	bne fx4_logocpy
	
	; now modify CHINDEX so it can be used in frame loop, to switch the fx color	
	lda frmcnt
	rol
	rol
	rol
	and #%00000011
	sta CHINDEX
	rts
			
cleanpmg0:
	lda #0
	tay
cleanloop:
	sta mybase+512,y 
	dey
	bne cleanloop	
	rts
	
setpmg:
	sei
	lda #%101110 ; double line, no missle DMA
	;sta $D400; DMACTL - 62 - single line, normal playfield
	sta $22f
	lsr	
	;lda #3 ; can be skipped due to lsr above
	sta $D01D ; GRACTL -set both players and missles	
	rts	
	
	
updlog:
	lda CHINDEX
	asl
	asl
	asl
	adc #8
	tax
	ldy #8
uplogloop:
	lda pics-1,x ; central logo update
	sta square3-1,y
	lda linepat-1,x ; charset update
	sta MYCBASE-1,y 
	dex
	dey
	bne uplogloop
	rts	

showend:
	lda #$56
	sta $D001
	rts					
	
; demo flow....13 x 256 frames sections

RUN_L	dta b(<fx1_vbl-1,	<fx1_vbl-1, 	<fx1_vbl-1,	<fx1_vbl-1,	<fx1_vbl-1,	<fx2_vbl-1,	<fx2_vbl-1,	<fx2_vbl-1,	<fx2_vbl-1,	<fx3_vbl-1,	<fx3_vbl-1, 	<fx4_vbl-1, 	<fx4_vbl-1);
EXIT_L	dta b(<updlog-1,	<updlog-1,	<updlog-1,	<updlog-1,	<fx2_prep-1,	<empty-1,	<empty-1,	<empty-1,	<fx3_prep-1,	<empty-1,	<fx4_prep-1,	<empty-1, 	<showend-1);
RUN_H 	dta b(>fx1_vbl,		>fx1_vbl,	>fx1_vbl,	>fx1_vbl,	>fx1_vbl,	>fx2_vbl,	>fx2_vbl,	>fx2_vbl,	>fx2_vbl,	>fx3_vbl,	>fx3_vbl,	>fx4_vbl,	>fx4_vbl);
EXIT_H  dta b(>updlog,		>updlog, 	>updlog,	>updlog,	>fx2_prep,	>empty,		>empty,		>empty,		>fx3_prep,	>empty,		>fx4_prep,	>empty,		>showend);

; data
; msx - 3 vol envelopes, 
sndkick5 dta b(2,6,4,3,2,1); background percussion envelope
	org sndkick5+16
seclead	dta b(108,80,90,80,108,80,90,80,70,60,50,90,108); background lead sound notes
sndkick6 dta b($c0,$ca,$ca,$c9,$c8,$c7,$c6,$c5,$c4,$c3,$c3,$c2,$c2,$c1,$c1,$c1); melody lead sound vol envelope
kickbas  dta b(2,6,15,15,15,13,13,13,11,9,7,5,4,3,2,1,1,1);
	org kickbas+32
datapar dta b(48,$40,$E0,$0f,$02); used to switch pmg/colors/charsets in fx2
leadnotes dta b(85,71,28,85,72,63,82,254); 7 steps version, main melody
; fx1 
; icon images drawn in fx1
pics:
pic1	dta b($E7,$E7,$66,$66,$66,$66,$7E,$7E); symbol2
pic2	dta b($FF,$FF,$42,$5A,$5A,$42,$FF,$FF); symbol3
pic3	dta b($E7,$E7,$66,$7E,$7E,$18,$FF,$FF); symbol4
pic4	dta b($FF,$FF,$C3,$C3,$C3,$C3,$FF,$FF); square

; fx2
; fullscreen images drawn in fx2
colors	dta b($24,$c4,$ea,$8a);	
imgl 	dta b($0,$D,$D,$D,$D,$D,$D,$D,$D,$1D,$39,$F9,$F1,$E1,$0,$0); // atari logo
circle	dta b($3,$F,$1C,$30,$60,$60,$C0,$C0,$C0,$C0,$60,$60,$30,$1C,$F,$3); // 5 vals
tri   	dta b($1,$1,$3,$3,$6,$6,$C,$C,$18,$18,$30,$30,$60,$60,$FF,$FF); // 4 vals
chip	dta b($0,$0,$F,$18,$8,$18,$8,$18,$8,$18,$8,$18,$8,$18,$F,$0); // 2 vals -> 13 vals
square3 dta b($FF,$FF,$60,$FF,$FF,$3,$FF,$FF,$0,$0) ; symbol1
; charset patterns to be used in icons drawing
linepat		dta b($FF,$FF,$00,$00,$FF,$FF,$00,$00); dithered lines
linepat2 	dta b($FF,$F1,$D5,$F1,$8F,$AB,$8F,$FF); spongy
linepat3	dta b($3c,$7e,$e7,$c3,$c3,$e7,$7e,$3c); good! circles
linepat4	dta b($55,$FE,$43,$DA,$5B,$C2,$7F,$AA); comb + square, nice!

; fx3 
; color scheme for 3rd fx
coltab	dta b($dc,$94, $aa, $9a);
; PMG 'End' string, used in the last fx
endstr	 dta b($C1,$81,$DB,$AD,$EB)
	org endstr+10

enddlst	dta b($42,$40,$9c,$41,$20,$9c);
		
; fx4
;PTRN3	dta b($83,$7,$E,$1C,$38,$70,$E0,$C1); replaced with neat rotations
; color changes on the last fx
noiscol	dta b(%00111111,%10011111,%11111111,%11001111); 

; fx3 but we need empty string later on...
; ALGORYTM by AGENDA
algtext	dta b(33,44,39,47,50,57,52,45,0,98,121,0,33,39,37,46,36,33);

	run program
	end	
		

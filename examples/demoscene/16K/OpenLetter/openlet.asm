STEREOMODE	equ 0				;0 => compile RMTplayer for mono 4 tracks
 icl "rmtplayr.a65"			;include RMT player routine
; p_song;$D1
  org $4000
MODUL
 ins "g0blinish 2024 (opt).rmt",6 ; skip header

 icl "utils.inc"
 icl "decrunch.s"

SYSVBV   equ   $E45F

dliv
 php
 pha
 txa
 pha
 tya
 pha

 jsr RASTERMUSICTRACKER+3
;-----------counter--
countl ;low adr
 ldy #$00
 iny
 bne save_cl
counth ;high adr
 ldx #$00
 inx
 stx counth+1
 stx 89
save_cl
 sty countl+1
 sty 88
;-------------------
;vbi_part jsr stub
 pla
 tay
 pla
 tax
 pla
 plp
 JMP SYSVBV

startd
; BASIC OFF
; https://www.wudsn.com/index.php/productions-atari800/tutorials/tips
	LDA $d301   ;Disable BASIC bit in PORTB for MMU
	ORA #$02
	STA $d301
	LDA #$01    ;Set BASICF for OS, so BASIC remains OFF after RESET
	STA $3f8

	lda #0
	sta 710
	lda #$FF
	sta $2C5

	jsr clear_a0
	lda #$A0
	jsr setfont

;;;;;;;;;;;;;; init RMT ;;;;;;;;;;;;;;
	ldx #<MODUL				;low byte of RMT module to X reg
	ldy #>MODUL				;hi byte of RMT module to Y reg
	lda #0					;starting song line 0-255 to A reg
	jsr RASTERMUSICTRACKER		;Init

SETVBV      equ $E45C
	ldx #dliv/256
	ldy #dliv&255
	lda #$06
	jsr SETVBV

	jsr balls
	jsr spirale
	jsr rotozoom
	jsr greets
	jsr stripes
	jmp finale
;	jmp *
;-----------------------------------------------------------------------------------
balls
	jsr copyfont
	

	ldx #dlgr0&255
	ldy #dlgr0/256
	jsr setdl
;	ldx #<dlgr0
;	ldy #>dlgr0
;	jsr setdl
; draw characters
	ldx #0
	stx $EB
	stx $ED ; sin count
	lda #$A8
	sta $EC
dcylp
	ldy #0
dcxlp
;02468A    0      (X&1)
;13579B    1
;02468A    2
;13579B    3
;
;012345 =Y<<1
	txa
	and #1
	sta dcv1+1
	tya
	asl @
dcv1 ora #0
; +16
	clc
	adc #16
	sta ($EB),y
	iny
	cpy #40
	bne dcxlp
	tya
	jsr ebecplusa
	inx
	cpx #24
	bne dcylp
	
	ldx #ballm1&255
	ldy #ballm1/256
	jsr textout

;	ldx #ballm2&255
;	ldy #ballm2/256
;	jsr textout

ball_mlp
;	jsr wait_frame
bfnt	lda #$A0
	jsr setfont
	eor #4
	sta bfnt+1
;	sta bfp1+1
;	sta bfp2+1
	sta $F1
	sta $F3
	lda $ED
	sta $EE
	
	lda #128
	sta $F0
	lda #144
	sta $F2

	lda #20
	sta $EF
bdlp
	lda $EE
	clc
	adc #4
	sta $EE
	tax
	lda ballsin,X
	and #15
	tax
	ldy #0
bcop
	lda bp1,X
	sta ($F0),y
	lda bp2,X
	sta ($F2),y
	inx
	iny
	cpy #16
	bne bcop
	ldx #0
	jsr add_zpf0
	ldx #2
	jsr add_zpf0
	dec $EF
	bne bdlp
	inc $ED
ballsp jsr ballsub1
	jmp ball_mlp
ballsub1
	lda p_song
	cmp #$C9
	bne exxbs1
	ldx #ballm2&255
	ldy #ballm2/256
	jsr textout
	lda #ballsub2&255
	sta ballsp+1
	lda #ballsub2/256
	sta ballsp+2
exxbs1 rts

ballsub2
	lda p_song
	cmp #$D5
	bne exxbs2
	pla
	pla
	jmp clear_a0
exxbs2
 rts

add_zpf0
	lda $F0,X
	clc
	adc #32
	sta $F0,X
	bcc exzpf0
	inc $F1,X
exzpf0
	rts
copyfont
	ldy #0
copflp
	lda fnt,y
	sta $A000,y
	sta $A400,y
	iny
	bpl copflp
	rts
textout ; X=low byte,Y=high
	stx getchar+1
	sty getchar+2
	jsr getchar
	sta $FE
	jsr getchar
	sta $FF
	jsr getchar
	tax
tolpy
	ldy #0
tolpx
	jsr getchar
	cmp #$80
	beq nexttochar
	sta ($FE),y
nexttochar
	iny
	cpy #40
	bne tolpx
	tya
	clc
	adc $FE
	sta $FE
	bcc tonextline
	inc $FF
tonextline
	dex
	bne tolpy
	rts
getchar lda $1234
	inc getchar+1
	bne exgc
	inc getchar+2
exgc rts

dlgr0
	dta 112,112,112
	dta $42
gr0a dta a($A800)
:23	dta $2
	dta $41
	dta a(dlgr0)
ballm1
	dta a($a800+40*6)
	dta 3
 dta $80,$80,$80,$80,$80,$08,$80,$80,$80,$08,$08,$80,$80,$80,$80,$01,$80,$08,$80,$09,$80,$80,$80,$80,$09,$80,$80,$80,$80,$80,$80,$09,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$0D,$0D,$0A,$0C,$0A,$05,$0B,$80,$0C,$04,$0A,$09,$0C,$09,$80,$09,$0A,$04,$0A,$0C,$09,$80,$0C,$02,$0C,$0A,$0C,$09,$0C,$0A,$0C,$02,$80,$80,$80,$80
 dta $80,$80,$80,$80,$05,$01,$01,$05,$02,$80,$03,$80,$03,$05,$03,$01,$05,$03,$80,$05,$03,$05,$03,$05,$03,$80,$05,$02,$05,$03,$05,$03,$05,$02,$01,$80,$80,$80,$80,$80

ballm2
	dta a($a800+40*10)
	dta 4
 dta $09,$80,$80,$80,$80,$80,$80,$09,$01,$80,$09,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$01,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$08,$01,$80,$80,$80,$80,$80
 dta $09,$0A,$08,$08,$0D,$80,$0C,$09,$09,$0C,$09,$0C,$0A,$01,$0D,$80,$09,$08,$09,$0C,$02,$09,$0D,$0C,$0A,$80,$04,$0A,$0C,$0A,$08,$08,$80,$09,$09,$0C,$0A,$0C,$0A,$0C
 dta $05,$03,$05,$03,$05,$80,$05,$03,$01,$05,$03,$01,$01,$80,$05,$80,$05,$07,$03,$01,$80,$01,$05,$05,$02,$80,$05,$03,$01,$01,$05,$0B,$80,$09,$01,$01,$01,$05,$02,$03
 dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$04,$03,$80,$80,$80,$80,$80,$80,$80,$80

fnt ins "txtchar.fnt"
bp1 ins "ballp1.bin"
bp2 ins "ballp2.bin"
ballsin ins "ballsin.data"
;-----------------------------------------------------------------------------------
spirale
	lda #$A4
	jsr setfont

	ldx #<spirdl
	ldy #>spirdl
	jsr setdl

	ldx >spirdata
	ldy <spirdata
	jsr __decruncher

	lda #$C7
	sta 708
	lda #$CF
	sta 709
	lda #$CD
	sta 710
	lda #$CB
	sta 711

;gen font
web_f	equ $A000
	ldx >plasfont
	ldy <plasfont
	jsr __decruncher


	lda #0
	sta 755
	sta $D401

	lda #>web_f
	jsr setfont


spiral_lp
	lda #0
	sta $EB
	lda #$A8
	sta $EC
	ldx #0
splpy
	ldy #0
splpx
	lda ($EB),y
	clc
	adc #1
	sta ($EB),y
	iny
	cpy #40
	bne splpx
	tya
	jsr ebecplusa
	inx
	cpx #24
	bne splpy

	lda p_song
	cmp #$E5
	bne next_spir
	jmp clear_a0 ; rts
next_spir
	jmp spiral_lp

spirdl
	dta 112,112,112
	dta $44
webdla
	dta a($A800)
:23	dta 4
	dta $41
	dta a(spirdl)

plasfont
	dta a(web_f)
	ins "plasmfnt.pck",2

spirdata
	dta a($A800)
	ins "spiral.pck",2
;-----------------------------------------------------------------------------------
rotozoom
fy equ $F0
fx equ $F2

fy_ equ $F4
fx_ equ $F6

zx equ $F8
zy equ $FA

	lda #0
	sta 710
	lda #$FF
	sta $2C5

; copy DL
	ldy #0
rzcdl lda dlgr8,y
	sta $600,y
	tya
	and #15
	asl @
	asl @
	asl @
	asl @
	sta $9F00,y
	iny
	bne rzcdl
	ldx #0 ; dlgr8&255
	ldy #6 ; dlgr8/256
	jsr setdl

	jsr clear_ab
;
rz_loop
;	inc rzan+1
	inc rzan+1
rzan ldx #$FF
	lda rzsin,x
	sta zx
	lda rzsin+256,x
	sta zx+1

	txa
	clc
	adc #64
	tax
	lda rzsin,x
	sta zy
	lda rzsin+256,x
	sta zy+1
; center
; fx_.w = -((height/2)*(zx+zy))
	lda zx
	clc
	adc zy
	sta fx_
	lda zx+1
	adc zy+1
	sta fx_+1

	asl fx_
	rol fx_+1
	asl fx_
	rol fx_+1
	asl fx_
	rol fx_+1
	asl fx_
	rol fx_+1

	lda fx_+1
	eor #$FF
	sta fx_+1

	lda fx_
	eor #$FF
	clc
	adc #1
	sta fx_
	bcc noincfxh
	inc fx_+1
noincfxh
; fy_.w = -((width/2)*(zx-zy))
	lda zx
	sec
	sbc zy
	sta fy_
	lda zx+1
	sbc zy+1
	sta fy_+1
; *12
	ldx fy_
	ldy fy_+1

	asl fy_
	rol fy_+1 ; !!

	txa
	clc
	adc fy_
	sta fy_
	tya
	adc fy_+1
	sta fy_+1

	asl fy_
	rol fy_+1
	asl fy_
	rol fy_+1

	lda fy_
	eor #$FF
	sta fy_

	lda fy_+1
	eor #$FF
	sta fy_+1

	inc dispv+1
dispv lda #$FF
	and #7
	asl @
	tax
	lda #$50
	clc
	adc disps,x
	sta $EB
	lda #$A1
	adc disps+1,x
	sta $EC
	lda #24
	sta $ED
;for j = 0 to height-1
rzlpy
	ldy #0
;  fx = fx_
	lda fx_
	sta fx
	lda fx_+1
	sta fx+1
;  fy = fy_
	lda fy_
	sta fy
	lda fy_+1
	sta fy+1
; for i = 0 to width-1
rzlpx
;   fx = fx+zx
	lda fx
	clc
	adc zx
	sta fx
	lda fx+1
	adc zx+1
	sta fx+1
	and #15
;	sta rzxv+1
	sta $EE
;   fy = fy-zy
	lda fy
	sec
	sbc zy
	sta fy
	lda fy+1
	sbc zy+1
	sta fy+1
	tax
	lda $9F00,x
	ora $EE
	tax
	lda smile,x
	sta ($EB),y
	iny
	cpy #40
	bne rzlpx
;  fx_ = fx_+zy
	lda fx_
	clc
	adc zy
	sta fx_
	lda fx_+1
	adc zy+1
	sta fx_+1
;  fy_ = fy_+zx
	lda fy_
	clc
	adc zx
	sta fy_
	lda fy_+1
	adc zx+1
	sta fy_+1
; (EB,EC)+320
	lda $EB
	clc
	adc #$40
	sta $EB
	lda $EC
	adc #1
	sta $EC
	
	dec $ED
	beq exrz
	jmp rzlpy
exrz
	lda p_song
	cmp #$F5
	bne rznoexit
	jmp clear_ab
rznoexit
	jmp rz_loop
smile
 dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dta $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
 dta $00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00
 dta $00,$FF,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$00,$00,$00,$FF,$FF,$00,$00,$00,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$00
 dta $00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00
 dta $00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00
 dta $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
 dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
dlgr8 icl "gr8.inc"

disps dta a(0),a(40),a(80),a(120),a(160),a(200),a(240),a(280)
rzsin ins "rzsintable.data"
;-----------------------------------------------------------------------------------
greets
	jsr clear_a0

	lda #$A0
	jsr setfont

	jsr copyfont


	ldx #dlgr0&255
	ldy #dlgr0/256
	jsr setdl

; fill chars
	lda #0
	sta $EB
	lda #$A8
	sta $EC
	ldx #0
ylp ldy #0
xlp
	tya
	and #3
	asl @
	asl @
	sta $ED
	txa
	and #3
	ora $ED
	clc
	adc #16
	sta ($EB),y
	iny
	cpy #40
	bne xlp
	tya
	jsr ebecplusa
	inx
	cpx #24
	bne ylp

stab	equ $B000
; precalc table
	ldy #0
	lda #00
	ldx #$B1
plut
	sta stab,y
	pha
	txa
	sta stab+25,y
	pla
	clc
	adc #128
	bcc noinx
	inx
noinx
	iny
	cpy #24
	bne plut

	ldx >starfont
	ldy <starfont
	jsr __decruncher

greet_lp
	jsr wait_frame
starp	ldx #0
	lda stab,x
	sta $EB
	lda stab+25,x
	sta $EC
	ldy #0
coplp	lda ($EB),y
	sta $A080,y
	iny
	bpl coplp
;next frame
	inx
	cpx #24
	bne nolpx
	ldx #0
nolpx
	stx starp+1
;greets
grd ldx #10
	beq gr_nodelay
;nogreet
	dex
	bne gr_nodelay
grdp ldy #0
	cpy #6
	beq nogreet
	lda grtab,y
	tax
	iny
	lda grtab,y
	iny
	sty grdp+1
	tay
	jsr textout
	ldx #60
gr_nodelay
	stx grd+1
nogreet
	lda p_song
	cmp #$05 ; FD
	bne gr_no_exit
	jmp clear_a0
gr_no_exit
	jmp greet_lp
grtab dta a(greetm1),a(greetm2),a(greetm3)

starfont
	dta a($B100)
	ins "star_o.pck",2

greetm1
	dta a($a800+40*10+5)
	dta 3
 dta $0C,$0A,$0C,$02,$0C,$0A,$0C,$0A,$0D,$00,$0C,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $05,$0B,$01,$00,$05,$02,$05,$02,$05,$02,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $04,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
greetm2
	dta a($a800+40*10+8)
	dta 3
 dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$0C,$08,$08,$04,$0A,$08,$08,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$09,$09,$09,$0C,$03,$05,$0B,$80,$08,$08,$01,$0C,$01,$0D,$80,$0C,$0A,$0C,$02,$0C,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$03,$05,$03,$04,$03,$80,$01,$80,$05,$03,$09,$03,$09,$05,$02,$05,$03,$01,$80,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80

; dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$08,$08,$01,$0C,$01,$0D,$00,$0C,$0A,$0C,$02,$0C,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
; dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$05,$03,$09,$03,$09,$05,$02,$05,$03,$01,$00,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
greetm3
	dta a($a800+40*13+8)
	dta 3
 dta $80,$80,$80,$80,$0C,$0A,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$0D,$0B,$0D,$00,$04,$0A,$0C,$02,$01,$80,$0C,$04,$0A,$0C,$0A,$0C,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$01,$01,$05,$02,$05,$03,$01,$00,$09,$80,$0D,$05,$03,$01,$01,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80

;-----------------------------------------------------------------------------------
stripes
	jsr clear_a0

	lda #$A0
	jsr setfont
	jsr copyfont

	ldx #dlgr0&255
	ldy #dlgr0/256
	jsr setdl
; draw characters
	lda #$A8
	sta $EC
	lda #00
	sta $EB
	ldx #0
dsylp
	ldy #00
	txa
;	and #1
	asl @
	sta $ED
dsxlp
;1,0,1,0
;3,2,3,2
	tya
	and #1
	eor #1
	ora $ED
	clc
	adc #16
	sta ($EB),y
	iny
	cpy #40
	bne dsxlp
	tya
	jsr ebecplusa
	inx
	cpx #24
	bne dsylp

; draw stripe
stripe_lp
strf lda #$A0
	jsr setfont
	eor #4
	sta $EC
	sta $EE

	sta strf+1
	lda #128
	sta $EB

	lda #8+128
	sta $ED

str_va lda #0
	clc
str_vd adc #8
		bne str_br1
	sta $F3
	lda str_vd+1
	eor #$FF
	clc
	adc #1
	sta str_vd+1
	clc
	adc $F3
str_br1
	sta str_va+1
	sta $F3
	lda striped+1
	rol @
	rol striped
	rol striped+1
	lda striped
	sta $F0
	lda striped+1
	sta $F1

	lda #24 ; Y counter
	sta $EF
	lda #$80
sdylp
	ldy #00
sdxlp
	pha
	lda $F0
	sta ($EB),y
	lda $F1
	sta ($ED),y
	iny
	pla
	clc
	adc $F3
	bcc dsbra2
	pha
	lda $F0
	ror @
	ror $F1
	ror $F0
	pla
dsbra2
	cpy #08
	bne sdxlp
	pha
	ldx #0
	jsr sadd_zp
	ldx #2
	jsr sadd_zp
	pla
	dec $EF
	bne sdylp
;display text
stripd ldx #10
	beq str_nodelay
;nogreet
	dex
	bne str_nodelay
stripp ldy #0
	cpy #6
	beq nostripe ; greet
	lda strtab,y
	tax
	iny
	lda strtab,y
	iny
	sty stripp+1
	tay
	jsr textout
	ldx #30
str_nodelay
	stx stripd+1
nostripe
	lda p_song
	cmp #$0D
	bne no_ex_stripe
	jmp clear_a0
no_ex_stripe
	jmp stripe_lp
strtab dta a(stripem1),a(stripem2),a(stripem3)
striped dta $FF,$00
sadd_zp
	lda #16
	clc
	adc $EB,X
	sta $EB,X
	bcc ex_sadd_zp
	inc $EC,X
ex_sadd_zp
	rts
stripem1
	dta a($a800+40*6)
	dta 4
 dta $80,$08,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$08,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $0D,$0D,$0A,$0C,$0A,$08,$08,$80,$0D,$0C,$0A,$04,$0A,$0C,$02,$0D,$0A,$80,$0C,$0A,$0C,$0A,$0C,$0A,$0C,$0B,$80,$0C,$0E,$0A,$04,$0A,$0C,$0A,$0C,$0A,$0C,$0A,$0C,$0C
 dta $05,$01,$01,$05,$02,$05,$0B,$80,$05,$05,$02,$05,$03,$05,$02,$01,$01,$80,$05,$0B,$05,$03,$05,$03,$05,$03,$80,$09,$01,$09,$05,$03,$01,$01,$01,$01,$05,$02,$01,$03
 dta $80,$80,$80,$80,$80,$04,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$04,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80

stripem2
	dta a($a800+40*10)
	dta 2
 dta $80,$80,$80,$80,$80,$80,$80,$80,$0D,$0A,$08,$08,$0D,$80,$04,$0A,$0C,$02,$0D,$80,$09,$01,$08,$80,$0C,$0A,$80,$04,$0A,$0C,$0C,$0C,$0A,$0C,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$80,$05,$03,$05,$03,$05,$80,$05,$03,$05,$02,$05,$80,$09,$09,$0D,$0B,$05,$02,$80,$05,$03,$03,$03,$05,$02,$03,$80,$80,$80,$80,$80,$80

stripem3
	dta a($a800+40*12)
	dta 4
 dta $80,$80,$80,$80,$80,$80,$80,$80,$08,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$0D,$0D,$0A,$0C,$0A,$08,$08,$80,$04,$0A,$0C,$02,$0C,$0A,$80,$0C,$08,$08,$0C,$08,$80,$0C,$0A,$09,$0C,$0B,$0C,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$05,$01,$01,$05,$02,$05,$0B,$80,$05,$03,$01,$80,$05,$02,$80,$05,$05,$03,$05,$0D,$0B,$05,$03,$09,$05,$03,$03,$80,$80,$80,$80,$80,$80
 dta $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$04,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
;-----------------------------------------------------------------------------------
finale
	jsr clear_a0

	ldx #dlgr0&255
	ldy #dlgr0/256
	jsr setdl

	lda #$A0
	jsr setfont

	ldx >ttl
	ldy <ttl
	jsr __decruncher


va	equ $B000
ra	equ va+$200



;build vertical address
	jsr store

	lda #0
	tax
	tay

bv1 lda $ec
	sta va+256,y
	lda $eb
	sta va,y
	lda #40
	jsr ebecplusa
	iny
	bne bv1

;generate rnd(),ra: 0..39,ra+256:0..23
	lda #00 ; ;tya
	ldx #0
genr
	sta ra,y
	clc
	adc #1
	cmp #40
	bne nora1
	lda #0
nora1
	pha
	txa
	sta ra+256,y
	pla
	inx
	cmp #24
	bne nora2
	ldx #0
nora2
	iny
	bne genr
;generate font
	lda #$80
	sta 623 ; GPRIOR
	sta $D01B
	lda #0
genf1 ldx #8
genf2 sta $A000,y
	iny
	dex
;	cpx #8
	bne genf2
;	clc
	adc #$11
	bcc genf1
;fill values
;	jsr store
;	ldx #24
;fvy ldy #0
;fvx jsr RANDOM
;	and #7
;	sta ($eb),y
;	iny
;	cpy #40
;	bne fvx
;	tya
;	clc
;	adc $eb
;	sta $eb
;	bcc noincec
;	inc $ec
;noincec
;	dex
;	bne fvy
;	setup color
	ldy #0
comsc
	lda cmatab,y
	sta 704,y
	sta $D012,y
	iny
	cpy #8
	bne comsc
;	jmp *
	ldy #0
cmdl	jsr wait_frame
	iny
	cpy #$80
	bne cmdl
cmas
	jsr RANDOM
	tax
	lda ra+256,x
	tax
	jsr getadr
	jsr RANDOM
	tay
	lda ra,y
	tay
	lda ($EB),Y

	bne no_black
	jsr RANDOM
	and #07
no_black

	cpy #0
	beq noput1
	dey
	sta ($EB),y
	iny
noput1
	cpy #39
	beq noput2
	iny
	sta ($EB),y
	dey
noput2
	cpx #0
	beq noput3
	dex
	jsr getadr
	sta ($EB),y
	inx
noput3
	cpx #23
	beq noput4
	inx
	jsr getadr
	sta ($EB),y
noput4
	jmp cmas

getadr
	pha
	lda va,x
	sta $eb
	lda va+256,x
	sta $ec
	pla
	rts

store
	lda #00
	sta $eb
	lda #$A8
	sta $ec
	rts
;http://www.apple2.org.za/gswv/a2zine/GS.WorldView/v1999/Nov/Articles.and.Reviews/Apple2RandomNumberGenerator.htm
RANDOM

	   ROR R4           ; Bit 25 to carry
         LDA R3           ; Shift left 8 bits
         STA R4
         LDA R2
         STA R3
         LDA R1
         STA R2
         LDA R4           ; Get original bits 17-24
         ROR @             ; Now bits 18-25 in ACC
         ROL R1           ; R1 holds bits 1-7
         EOR R1           ; Seven bits at once
         ROR R4           ; Shift right by one bit
         ROR R3
         ROR R2
         ROR @
         STA R1
         RTS
R1       dta $4E
R2       dta $4D
R3       dta $4E
R4       dta $4F
cmatab dta 0,31,44,$CF,91,158,191,$F7
;dlgr0
;	dta 112,112,112
;	dta $42
;gr0a dta a($A800)
;:23	dta $2
;	dta $41
;	dta a(dlgr0)
ttl
	dta a($A800)
 ins "theend4.pck",2

;-----------------------------------------------------------------------------------

	run startd

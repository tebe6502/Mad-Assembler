
scr32	= %00111101		; obraz waski    *-screen 32b
;scr40	= %00111110		; obraz normalny *-screen 40b
;scr48	= %00111111		; obraz szeroki	 *-screen 48b

hposp0	= $D000
hposp1	= $D001

hposp2	= $D002
hposp3	= $D003
hposm0	= $D004
hposm1	= $D005
hposm2	= $D006
hposm3	= $D007
sizep0	= $D008
sizep1	= $D009
sizep2	= $D00A
sizep3	= $D00B
sizem	= $D00C

colpm0	= $D012
colpm1	= $D013
colpm2	= $D014
colpm3	= $D015
color0	= $D016
color1	= $D017
color2	= $D018
color3	= $D019
colbak	= $D01A
gtictl	= $D01B

chbase	= $D409

vcount	= $D40B

* --------------------------------------------------------------------------------------

	org $d800

lAdrLine	.ds $100
hAdrLine	.ds $100
data		.ds $300

fnt		= $e000

* --------------------------------------------------------------------------------------

	org $80

timer	.ds 1
regA	.ds 1
tmp	.ds 2

height		.ds 1		; parametry ducha
positionX	.ds 1
positionY	.ds 1
type		.ds 1

positionX_old	.ds 1
positionY_old	.ds 1

temp		.ds 1		; zmienne pomocnicze

ScreenAdr0	.ds 2
ScreenAdr1	.ds 2

* --------------------------------------------------------------------------------------

	opt r+
	org $2000

dlist	dta d'ppp'
	dta $44,a(data),4,4,$84
	:4 dta 4,4,4,$84
	dta 4,4,4,4
	dta $41,a(dlist)

main
	lda:cmp:req 20

	sei
	mva #0	$d40e
	mva #0	$d400
	mva #0	$d20e

	mva #$fe $d301

	mwa #nmi $fffa

	JSR INIT

	mva #$c0 $d40e


	ldy #0
loop	lda data+10*32,y	; wstawiamy invers
	ora #$80
	sta data+10*32,y

	lda $d20a		; troche smieci
	sta fnt+3*$400,y

	lda $d20a
	sta fnt+4*$400,y

	lda $d20a
	sta fnt+5*$400,y

	iny
	bne loop

	

	jmp engine.main


* --------------------------------------------------------------------------------------
* ----	DLI
* --------------------------------------------------------------------------------------

	?old_dli = *

dli	sta regA
	lda >fnt+$400
	sta $d40a
	sta chbase

	dliNEW dli2
	lda regA
	rti


dli2	sta regA
	lda >fnt+$400*2
	sta $d40a
	sta chbase

	dliNEW dli3
	lda regA
	rti


dli3	sta regA
	lda >fnt+$400*3
	sta $d40a
	sta chbase

	dliNEW dli4
	lda regA
	rti


dli4	sta regA
	lda >fnt+$400*4
	sta $d40a
	sta chbase

	dliNEW dli5
	lda regA
	rti


dli5	sta regA
	lda >fnt+$400*5
	sta $d40a
	sta chbase

	lda regA
	rti


* --------------------------------------------------------------------------------------
* ----	NMI
* --------------------------------------------------------------------------------------

NMI	bit $d40f
	bpl vbl

	jmp dli
vdli	equ *-2

vbl	phr
	sta $d40f

	inc timer

	mwa #dlist $d402

	mva #scr32 $d400

	mva >fnt chbase

	mva #$00 $d01a
	mva #$46 $d016
	mva #$ee $d017
	mva #$d8 $d018
	mva #$26 $d019 

	mwa #dli vdli

	plr
	rti


* --------------------------------------------------------------------------------------
* ----	inicjalizacja pola gry DATA
* ----	inicjalizacja tablic lAdrLine, hAdrLine z adresami linii obrazu dla trybu znakowego
* --------------------------------------------------------------------------------------
.proc	init

	.local
	mwa #data tmp

	ldx #3
	ldy #0
loop	tya
	and #$7f
	sta (tmp),y
	iny
	bne loop

	inc tmp+1
	dex
	bne loop
	.end

	.local
	ldx #0

loop	txa
	:3 lsr @

	clc
	adc >fnt
	
	sta hAdrLine,x

	txa
	and #7

	sta lAdrLine,x

	inx
	bne loop
	
	.end

	rts
.endp

	align

.local	engine
	icl 'eor_char_engine.asm'
.endl


* ----
	.print 'end: ',*

	run main


* ----
	opt l-

	icl 'align.mac'

.macro	dliNEW

 .if .hi(?old_dli)==.hi(:1)
   mva <:1 vdli
 .else
   mwa #:1 vdli
 .endif

  .def ?old_dli
.endm

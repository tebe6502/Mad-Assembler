
//---------------------------------------------------------------------
// CHAR ENGINE 1x BUFFER EXAMPLE
//---------------------------------------------------------------------

	pmg = $0

	icl 'atari.hea'

	icl 'CharEngine_1xBuf\Engine_1xBuf.hea'

//---------------------------------------------------------------------

	org $80

zp	.ds 36
regA	.ds 1
regX	.ds 1
regY	.ds 1

	.print 'ZP: $0080..',*-1

//---------------------------------------------------------------------

	org $1000

.macro	@DLIST
	dta d'pp',$70+$80
	dta $44+$80,a(:1)
	:PlayfieldHeight-2 dta $44+$80,a(:1+#*[PlayfieldWidth]+PlayfieldWidth)
	dta $44,a(:1+[PlayfieldHeight-1]*[PlayfieldWidth])
	dta $41,a(:2)
.endm

dlist0	@DLIST PlayfieldBuf+4*PlayfieldWidth+4, dlist0


	.align

	:4 brk			; minimalna liczba zestawow znakowych = 4
Charsets
	dta	>Charset0	; row #0
	dta	>Charset1	; row #1
	dta	>Charset2	; row #2
	dta	>Charset3	; row #3
	dta	>Charset4	; row #4
	dta	>Charset5	; row #5
	dta	>Charset6	; row #6
	dta	>Charset7	; row #7
	dta	>Charset8	; row #8
	dta	>Charset9	; row #9
	dta	>Charset10	; row #10
	dta	>Charset11	; row #11

	dta	>Charset0	; row #12
	dta	>Charset1	; row #13
	dta	>Charset2	; row #14
	dta	>Charset3	; row #15
	dta	>Charset4	; row #16
	dta	>Charset5	; row #17
	dta	>Charset6	; row #18
	dta	>Charset7	; row #19
	dta	>Charset8	; row #20
	dta	>Charset9	; row #21
	dta	>Charset10	; row #22
	dta	>Charset11	; row #23

	:4 brk

	.align
tColor1 :PlayfieldHeight dta $00	; maksymalnie 256 wpisów

	.align
tColor2 :PlayfieldHeight dta $1a	; maksymalnie 256 wpisów

	.align
tColor3 :PlayfieldHeight dta $f6	; maksymalnie 256 wpisów


cloc		.byte
dlist		.word dlist0

tColor1Addr	.word tColor1		; mo¿liwoœæ przemieszczania adresu w przypadku scrolla pionowego
tColor2Addr	.word tColor2		; mo¿liwoœæ przemieszczania adresu w przypadku scrolla pionowego
tColor3Addr	.word tColor3		; mo¿liwoœæ przemieszczania adresu w przypadku scrolla pionowego

//---------------------------------------------------------------------

main	lda:cmp:req 20

	sei
	mva #0 nmien
	sta dmactl

	mva #$fe portb

	mva #3 pmcntl
	mva >pmg pmbase

	ldy #0
	lda #$ff
fpmg	sta pmg+$400,y
	sta pmg+$500,y
	sta pmg+$600,y
	sta pmg+$700,y
	iny
	bne fpmg

	mva #$74 colpm0
	mva #$a4 colpm1
	mva #$24 colpm2
	mva #$d4 colpm3

	lda #3
	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3

	:4 mva #56+#*32 hposp0+#


	ldy #3*8-1
chr	lda #$ff	;$d20a
	sta Charset0+8,y
	sta Charset1+8,y
	sta Charset2+8,y
	sta Charset3+8,y
	sta Charset4+8,y
	sta Charset5+8,y
	sta Charset6+8,y
	sta Charset7+8,y
	sta Charset8+8,y
	sta Charset9+8,y
	sta Charset10+8,y
	sta Charset11+8,y
	dey
	bpl chr

	mwa #nmi nmivec

	mva #$c0 nmien


	ldx #8
	ldy #0
f0	lda #1
a0	sta PlayfieldBuf,y
	iny
	lda #2+$80
a1	sta PlayfieldBuf,y
	iny
	lda $d20a
	and #$3f
a2	sta PlayfieldBuf,y
	iny
	bne f0
	inc a0+2
	inc a1+2
	inc a2+2
	dex
	bne f0


	jsr Engine.reset

	.rept 6,#
	mva #64+:1*12 Sprite:1.y
	mva #33+#*32 Sprite:1.x
	sta Sprite:1.new
	.endr

	mwa #spr0 Sprite0.bitmaps
	mwa #spr0 Sprite3.bitmaps

	mwa #spr1 Sprite1.bitmaps
	mwa #spr1 Sprite4.bitmaps

	mwa #spr2 Sprite2.bitmaps
	mwa #spr2 Sprite5.bitmaps

loop	lda $d20f
	and #4
	beq loop

	lda:cmp:req cloc
	mva #0 cloc

	jsr Engine

	mva cloc $100
	mva vcount $101

	.rept 6,#
	lda Sprite:1.x
	add #1
	sta Sprite:1.x

	ift #<>5&&#<>3&&#<>1
	lda Sprite:1.y
	add #2
	sta Sprite:1.y
	eif
	.endr

	jmp loop


Playfield_Update
	rts

spr0	.word s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11
	dta a(0)

spr1	.word m0,m1,m2,m1
	dta a(0)

spr2	.word b0,b1,b2,b3,b4,b5,b6,b7
	dta a(0)


//---------------------------------------------------------------------

.local	NMI
	bit nmist
	bpl vbl

DLI	sta regA		; DLI
	stx regX
	sty regY

iCh	lda Charsets
iC1	ldx tColor1
iC2	ldy tColor2
	sta wsync

	sta chbase
	stx color1
	sty color2

iC3	lda tColor3
	sta color3

	inc iCh+1
	inc iC1+1
	inc iC2+1
	inc iC3+1

	lda regA
	ldx regX
	ldy regY
	rti	

vbl	phr
	sta nmist

	inc cloc

	mwa dlist dlptr

	ift PlayfieldWidth=40
	lda #scr32
	eli PlayfieldWidth=48
	lda #scr40
	els
	ert 1=1
	eif

	sta dmactl

	mva #4 gtictl

cBak	mva #$06 colbak
c0	mva #$0a color0

	mwa #Charsets iCh+1
	mwa tColor1Addr iC1+1
	mwa tColor2Addr iC2+1
	mwa tColor3Addr iC3+1

	plr
	rti
.endl

//---------------------------------------------------------------------

	.align
; klatka z duchem zajmuje 64 bajty, !!! wyrownujemy do poczatku strony pamieci !!!

	.get 'krakout_sprites.mic'

s0	@@CutMIC 0 0 3 21
s1	@@CutMIC 0 3 3 21
s2	@@CutMIC 0 6 3 21
s3	@@CutMIC 0 9 3 21
s4	@@CutMIC 0 12 3 21
s5	@@CutMIC 0 15 3 21
s6	@@CutMIC 0 18 3 21
s7	@@CutMIC 0 21 3 21
s8	@@CutMIC 0 24 3 21
s9	@@CutMIC 6 0 3 21
s10	@@CutMIC 6 3 3 21
s11	@@CutMIC 6 6 3 21

m0	@@CutMIC 6 21 3 21
m1	@@CutMIC 6 24 3 21
m2	@@CutMIC 6 27 3 21

b0	@@CutMIC 27 0 3 21
b1	@@CutMIC 27 3 3 21
b2	@@CutMIC 27 6 3 21
b3	@@CutMIC 27 9 3 21
b4	@@CutMIC 27 12 3 21
b5	@@CutMIC 27 15 3 21
b6	@@CutMIC 27 18 3 21
b7	@@CutMIC 27 21 3 21


	.align
; !!! koniecznie od pocz¹tku strony pamiêci !!!

EngineProgram
	
	.link 'CharEngine_1xBuf\CharEngine_1xBuf.obx'	


//---------------------------------------------------------------------
//---------------------------------------------------------------------


.macro	@@CutMIC
	opt l-
	.def ?x = :1
	.def ?y = :2*320

	.def ?dst = $4000

	@@CopyLine
	@@CopyLine
	@@CopyLine

	.sav [$4000] 64
	opt l+
.endm


.macro	@@CopyLine
	:+21 .put[?dst+#]=.get[?x+?y+#*40]
	
	.def ?x++
	.def ?dst+=21
.endm


	.print *

	run main
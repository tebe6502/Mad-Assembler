
* rip2max converter v1.0

;Wolne:
;		$DC00-$DFFF

; XL-PAINT 1.9
; by  Stanley!
; poprawka dla 16col by TeBe
; kod okoîo:	$2000-$5c00  $6000

*-----tabele-----

PMG	equ $5800		;$0800	$5800-$5FFF
Bufor1	equ $6000		;$0780	$6000-$677F
Bufor2	equ $6780		;$0780	$6780-$6EFF
DIREC	equ Bufor1		;$0300	oryginalnie bylo $0400-$06ff

Ekran10	equ $70B0		;$1E00	$70B0-$8EAF\
Ekran11 equ $8000		;$0EB0	$8000-$8EAF/
Ln1	equ $8EB0		;$0078	$8EB0-$8F27
AdYLo	equ $8F28		;$00C0	$8F28-$8FE7
;$c7			$8FE8-$90af
Ekran20	equ $90B0		;$1E00	$90B0-$AEAF\
Ekran21 equ $A000		;$0EB0	$A000-$AEAF/
Ln2	equ $AEB0		;$0078  $AEB0-$AF27
AdYHi	equ $AF28		;$00C0	$AF28-$AFE7
;$c7			$AFE8-$b0af
Ek01	equ $B0B0		;$1E00	$B0B0-$CEAF
FONTY	equ $d800		;$0400	$d800-$dbff
;.FONT=$dc00		;$0400	$dc00-$dfff
jas0	equ $dc00
jas1	equ $dd00
jas2	equ $de00
jas3	equ $df00
Ek02	equ $E0B0		;$1E00	$E0B0-$FEAF
;		KEYASCII	$FEB0-$FFAF

*-----zerowa-----

	org $80

OldPMGY		.ds 1
OldPMGX		.ds 1
OldPMGY2	.ds 1
OldPMGX2	.ds 1
Xact		.ds 1
Yact		.ds 1
EndPt		.ds 1
Countr		.ds 1
Countr2		.ds 1
CrX0		.ds 1
CrY0		.ds 1
CrX		.ds 1
CrY		.ds 1

SZER		.ds 1
WYS		.ds 1
BYT		.ds 1
GDZIE		.ds 1

PMGX		.ds 1
PMGY		.ds 1
NrCol0		.ds 1
NrCol		.ds 1
WskCur		.ds 1
kolor1		.ds 1
kolor2		.ds 1

CrF		.ds 2
CrFY		.ds 2
CrFYA		.ds 2
CrXY		.ds 2
POM		.ds 2
POM1		.ds 2
POM2		.ds 2
PomADR1		.ds 2
PomADR2		.ds 2
ILE		.ds 2


*-----------------------------
* dta a($FFFF),a($2E0),a($2E1),a(RUN)
* dta a(start),a(meta-1)
*-----------------------------

;	org $70b0
;	ins 'c640019.rip'
;	ins 'ob1.dat'
;	org $90b0
;	ins 'ob2.dat'


	org $1f00

kol0	:256 brk
kol1	:256 brk
kol2	:256 brk
kol3	:256 brk
tabk	:256 brk		;tablica lokalizacji palet kolorow

;	org $2000

start	equ *

*----------------------------- 8-7
dll0	dta b($a0)		;Ekran glowny
	dta b($44),a(NAG2),b($30),b(4),b($80)
DL0Ek1	dta b($4E),a(Ekran10)
	Dta d'................................'
	Dta d'................................'
	Dta d'.................................'
DL0Ek2	dta b($4E),a(Ekran11)
	Dta d'................................'
	Dta d'................................'
	Dta d'.............'
DL0Sk1	dta d'................'
;	Dta b($00)
;	dta b($4E),a(Panel1)
;	Dta d'..........'
;	dta b($4e),a(Panel1+40),b($4E),a(Panel1)
	Dta b($41),a(DLL0)

*-----------------------------
*- przelaczanie obrazow co 1frame
*-
DLIv0	PHA
	TXA
	PHA
;	STA $D40A

	ldx #4
lp_	sta $d40a    ; jasn
	mva #2 $d016
	mva #4 $d017
	mva #6 $d018
	mva #0 $d01a

	sta $d40a    ; kol
	mva #2 $d016
	mva #4 $d017
	mva #6 $d018
	mva #0 $d01a

	dex
	bne lp_

	ldx #4		;kolory czcionki - pasek menu
	lda defcol,x
	sta $d016,x
	dex
	bpl *-7
;	lda #0
;	sta z00m+1	;DLIV bez ZOOMa czyli normal

;	ldx #192	;ustawienia dla normal screen i zoom screen
;	stx lin1+1
;	inx
;	stx lin2+1
;	lda #0
;	sta tryb+1

tim	LDA #1
	eor #1
	sta tim+1
	ASL @
	TAX

_zoom_	lda #0
	beq normal
	cmp #1
	beq zoom_ON

set_col	LDA TDL1,X				; reszta wartosci
;	STA DL5Ek0+1
;	LDA TDL1+1,X
;	STA DL5Ek0+2
;	LDA TDL5,X
;	STA DL5Sk1+1
;	LDA TDL5+1,X
;	STA DL5Sk1+2
;	lda tdl_dll0,x
;	sta dll5+2
;	lda tdl_dll0+1,x
;	sta dll5+3
	jmp color

normal	LDA TDL1,X		;0
	STA DL0Ek1+1
	LDA TDL1+1,X
	STA DL0Ek1+2
	LDA TDL2,X
	STA DL0Ek2+1
	LDA TDL2+1,X
	STA DL0Ek2+2
;	lda tdl_dll0,x
;	sta dll0+2
;	lda tdl_dll0+1,x
;	sta dll0+3
	jmp color

zoom_ON	equ *

color	ldx #0			;zmiana palet kolor->szarosc, szarosc->kolor

	lda color+1
	eor #1
	sta color+1
	beq _parz

z00m	lda <dliv0c
	ldx >dliv0c
	sta $200
	stx $201
	jmp _out

_parz	lda <dliv0c_
	ldx >dliv0c_
	sta $200
	stx $201

_out	pla
	tax
	pla
	rti
*----
*- zmiana kolorow co linie
*- linie parzyste
*-
dliv0c	pha
	txa
	pha

lin1s	ldx #0
kk_	sta $d40a    ; jasn
	mva jas1,x $d016
	mva jas2,x $d017
	mva jas3,x $d018
	mva jas0,x $d01a

	sta $d40a    ; kol
	mva kol1,x $d016
	mva kol2,x $d017
	mva kol3,x $d018
	mva kol0,x $d01a

	inx
	inx
lin1	cpx #192
	bne kk_

tryb	lda #0
	bne tr_setcolor
	jmp ex_dliv
*----

tr_setcolor jmp r_dlv5

*----
*- linie nieparzyste
*-
dliv0c_	pha
	txa
	pha

lin2s	ldx #1
nn_	sta $d40a    ; kol
	mva kol1,x $d016
	mva kol2,x $d017
	mva kol3,x $d018
	mva kol0,x $d01a

	sta $d40a    ; jasn
	mva jas1,x $d016
	mva jas2,x $d017
	mva jas3,x $d018
	mva jas0,x $d01a

	inx
	inx
lin2	cpx #192+1
	bne nn_

	lda tryb+1
	bne tr_setcolor

ex_dliv	ldx #4		;kolory
	lda defcol,x
	sta $d016,x
	dex
	bpl *-7

	lda <dliv0
	ldx >dliv0
	sta $200
	stx $201

	pla
	tax
	pla
	rti

*-----------------------------
* DLIV dla wybieranie z palety kolorow
* dzieli ekran na polowe
* w dolnej wybieranie kolorow

*--
r_dlv5	jmp ex_dliv

*-----------------------------
SetTabY	lda #$B0
	sta AdYLo
	ldy #0
	sty AdYHi

STY1	lda AdYLo,y
	clc
	adc #40
	sta AdYLo+1,y
	lda AdYHi,y
	adc #0
	sta AdYHi+1,y
	iny
	cpy #$bf
	bne STY1
;	jmp jascol
_rts	RTS

*-----------------------------
SetCol  RTS

*-----------------------------	wskocz do menu na dole ekranu
PutFire lda mvp00+1
	cmp #6
	beq Func3
	lda PMGY
	cmp #192
	bcc Func2
Func1	lda #14		;dolne menu
;	sta wb+1
	jmp WbKol
Func2	jmp _rts
Func3	lda #16		;gorne menu-kolory
;	sta wb+1
	jmp WbKol

*-------------------
SetCurNorm  lda #0
	sta WskCur
	rts
*-------------------
SetCur2Y  lda #1
	sta WskCur
	rts
*-------------------
CursAd  ldx #0
	inx
	txa
	and #3
	sta CursAd+1
	asl @
	tax
	lda TbCur,x
	sta PPG11+1
	lda TbCur+1,x
	sta PPG11+2
	RTS

TbCur	dta a(DatPMG0),a(DatPMG4),a(DatPMG5),a(DatPMG6)
*-------------------
NxCol	ldx NrCol0
	inx
	cpx #16		;max color
	scc
	ldx #0
	txa
	jmp SetCol
*-------------------
SetIO	jsr CLSPMG
	jsr Directory
	cmp #$1B
	beq IOEnd
	LDY PLIKOW
	BEQ IOEnd
	lda AKT_P1
	bne IO2
	JSR LoadFil
	jmp IOEnd
IO2	cmp #1
	bne IO5
	lda #0
	sta sav+1
	JSR SaveCrunch
	JSR CLOSE
	jmp IOEnd
IO5	cmp #2
	bne IO6
	JSR SaveBMP
	JSR CLOSE
	jmp IOEnd
IO6	cmp #3
	bne IO7
	JSR SaveMIC
	JSR CLOSE
	jmp IOEnd
IO7	cmp #4
	bne IOEnd
	sta sav+1
	JSR SaveCrunch	;Save MAX
	JSR CLOSE
IOEnd	jmp SetTabY

*-------------------
*- wybor z palety kolorow
*-
setLin	stx lin1s+1
	inx
	stx lin2s+1
	sty lin1+1
	iny
	sty lin2+1
	rts

SetColor jmp retdl0

TDL1	dta a(Ekran10),a(Ekran20)
TDL1_	dta a(Ekran10),a(Ekran20)
	dta a(Ekran11),a(Ekran21)

*-------------------
WbKol	rts
*-------------------
SetInfo  ldy #0
	sty pom+1
	asl @
	rol pom+1
	asl @
	rol pom+1
	clc
	adc <Koment1
	sta pom
	lda pom+1
	adc >Koment1
	sta pom+1

	ldy #7
	lda (pom),y
	sta Nag+22,y
	dey
	bpl *-6
	jsr CLSCur
;	jsr CopyEkr0
	CLC
	RTS

*------------------

Koment1 equ *

Koment2 equ *

Koment3 equ *

Koment4 equ *

Koment5 equ *

*---------------------------------------
RUN	JSR INIT
	jsr ROMOFF
	jsr MOVE1
	jsr SetTabY
	lda #0
	jsr SetCol
	JSR CLSScreen
;	jsr lrip

	jsr clswsk
	lda #$ff
	sta $2fc
	ldy #17
	jsr TK5
TK0	JSR Wait
	lda $d20f
	and #4
	beq TK1
WskSh	lda #0
	beq TK1
ShSk	jsr _rts
TK1	JSR CLSPMG
	sta $4d
;	JSR PUTPMG
	lda fire+1	;XXX
;	jsr Fire
	bne *+5
	jsr PutFire
	jsr JoyKey1
	bne TK1
TK2	JSR KEY
	bcc TK0
	CMP #$ef ;dC		;Shift+CTRL+Q	-exit
	BEQ END
	jsr TK00
	jmp TK0

END	JSR ROMON
	LDA #$40
	STA $D40E
DD1	LDA <DLL0
	LDX >DLL0
	STA $230
	STX $231
DD2	LDA <DLIv0
	LDX >DLIv0
	STA $200
	STX $201
	lda #0
	sta _zoom_+1
	sta color+1
DD3	LDA <ExitVBL
	LDX >ExitVBL
	STA $224
	STX $225
	lda #0
	sta $d000
	sta $d001
	sta $d002
	sta $d003
	JSR WAIT
	JMP ($0A)

ROMON	JSR WAIT
	LDA #0
	STA $D400
	STA $D40E
	SEI
	lda #$ff
	sta $d301
	lda #$e0
	sta $02f4
	LDA:RNE $D40B

	CLI
	LDA #$C0
	STA $D40E
	RTS

ROMOFF	JSR WAIT
	LDA #0
	STA $D400
	STA $D40E
	SEI
	lda #$fe
	sta $d301
	lda >FONTY
	sta $02f4
	LDA:RNE $D40B

	CLI
	LDA #$C0
	STA $D40E
	RTS

MOVE1	JSR WAIT
	LDA #0
	STA $D400
	STA $D40E
	SEI
	ldy #0
MOVE10	ldx #$ff
	stx $d301
	sta $d40a
	lda $FB51,y
	ldx #$fe
	stx $d301
	sta $d40a
	sta $FEB0,y
	iny
	bne MOVE10
	LDA:RNE $D40B

	CLI
	LDA #$C0
	STA $D40E
	RTS

*-----------------------------
TK00	ldy #KlawSk0-KlawSk2
TK3	cmp KlawSk2,y
	beq TK5
	iny
	cpy #KlawSk1-KlawSk2
	bcc TK3
TK11	ldy #0
TK4	cmp KlawSk1,y
	beq TK41
	iny
	iny
	iny
	iny
	cpy #KlawSk3-KlawSk1
	bcc TK4
	RTS
TK41	jmp TK8

TK22	ldy #KlawSk21-KlawSk2
	cmp KlawSk2,y
	beq TK5
	iny
	cpy #KlawSk0-KlawSk2
	bcc TK22+2
	RTS
TK23	ldy #0
	cmp KlawSk2,y
	beq TK5
	iny
	cpy #KlawSk21-KlawSk2
	bcc TK23+2
	RTS

TK5	cpy #KlawSk21-KlawSk2
	bcc TK6
	cpy #KlawSk01-KlawSk2
	bcs TK7
	tya
TK51	asl @
	tay
	lda KlawSk20,y
	sta Func2+1
	clc
	adc #1
	sta TK5Sk+1
	lda KlawSk20+1,y
	sta Func2+2
	adc #0
	sta TK5Sk+2

	lda #0
	cpy #KlawSk000-KlawSk20
	scs
	lda #1
	sta PtPMG1+1

	lda #0
TK5Sk	sta $ffff
	tya
	jmp SetInfo

TK6	tya
	asl @
	tay

;	mwa KlawSk20,y SkWnd+1

	mwa #Objw Func2+1

	lda #0
	sta Objw+1
	tya
	jmp SetInfo

TK7	tya
	sec
	sbc #KlawSk01-KlawSk2
	asl @
	tay
	lda KlawSk02,y
	sta TKSk+1
	lda KlawSk02+1,y
	sta TKSk+2
	bne TKSk

TK8	lda KlawSk1+2,y
	sta TKSk+1
	lda KlawSk1+3,y
	sta TKSk+2
	lda KlawSk1+1,y
TKSk	jmp $ffff

*-----------------------------
SetLamp rts

mvp00	lda #0		;wskocz do wyboru koloru - gorne menu
	rts

JoyKey1 lda $d300	;ruch joya
	and #$f
	cmp #$f
	bne *+3
	RTS
JoyKy	rts

*-------------------
kolmask0	dta b($00,$55,$AA,$FF)
;		dta b($00,$55,$AA,$FF)

kolmask2	dta b($00,$55,$aa,$ff,$00,$55,$aa,$ff,$00,$55,$aa,$ff,$00,$55,$aa,$ff)
kolmask1	dta b($00,$00,$00,$00,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff)

WskZoom 	dta b($80)
*-------------------

RamkaTxt dta c'QRE|ZC',b($9b)

Ramki
	Dta a(Koment3),b(25),b(08),b(08),b(14),b(0),b(0)	;pen
	Dta a(Koment5),b(05),b(08+48),b(16),b(19-4),b(0),b(0)	;help
	Dta a(Koment2),b(15),b(00),b(08),b(03),b(0),b(0)	;Ob
	Dta a(Koment4),b(01),b(00),b(16+1),b(04),b(0),b(0)	;Inf
	Dta a(Koment1),b(09),b(00),b(08),b(14),b(0),b(0)	;fUnc
	Dta a(IOTxt),b(04),b(00),b(09),b(05),b(0),b(0)		;File
	Dta a(Filename),b(09),b(32),b(20),b(01),b(0),b(0)	;filename

FilWnd	dta a(Bufor2),b(13),b(48),b(12),b(00),b(0),b(0)

*-----------------------------
jascol	ldy #0
rrr	mva jas		jas0,y
	mva jas+1	jas1,y
	mva jas+2	jas2,y
	mva jas+3	jas3,y

	mva kol		kol0,y
	mva kol+1	kol1,y
	mva kol+2	kol2,y
	mva kol+3	kol3,y
	iny
	cpy #193
	bne rrr
	sty block+1
	rts

*-----------------------------
T_I	Dta a($D301),b($FE)
	Dta a($FFFA),l(NMIVEC)
	Dta a($FFFB),h(NMIVEC)
	Dta a($FFFC),l(RESETVEC)
	Dta a($FFFD),h(RESETVEC)
	Dta a($FFFE),l(IRQVEC)
	Dta a($FFFF),h(IRQVEC)
	Dta a($0224),l(ExitVBL)
	Dta a($0225),h(ExitVBL)
	Dta a($0230),l(DLL0)
	Dta a($0231),h(DLL0)
	Dta a($0200),l(DLIv0)
	Dta a($0201),h(DLIv0)
	Dta a($02c0),b($ce)
	Dta a($02c1),b($4a)
	Dta a($02c2),b($ce)
	Dta a($02c3),b($4a)
	Dta a($02C4),b($30)
	Dta a($02C5),b($70)
	Dta a($02C6),b($c2)
	Dta a($02C8),b(0)
	Dta a($d000),b(0)
	Dta a($d001),b(0)
	Dta a($d002),b(0)
	Dta a($d003),b(0)
	Dta a($d004),b(0)
	Dta a($d005),b(0)
	Dta a($d006),b(0)
	Dta a($d007),b(0)
	Dta a($d008),b(0)
	Dta a($022f),b($3a)
	Dta a($d01d),b(2)
	Dta a($026f),b(1)
	Dta a($d407),h(PMG)
	Dta a($02d9),b($10)	;key delay
	Dta a($02da),b($02)	;key repeat
	Dta a(PMGX),b(0),b(0)
	Dta a(PMGY),b(0),b(0)
	Dta a(WskCur),b(0),b(0)

T_EI equ *
*---------------------------------------
*Procedura wlasnych przerwan
*---------------------------------------
ExitVBL PLA
	TAY
	PLA
	TAX
	PLA
	RTI

*przerwania Display List------

NMIVEC	equ *	;$FFFA
	cld
	bit $d40f
	spl
	jmp ($200)
	pha
	txa
	pha
	tya
	pha
	sta $d40f
	jmp MojaVBL

*przerwanie RESET-------------

RESETVEC equ *	;$FFFC
	rti

*przerwanie IRQ---------------

IRQVEC	equ *	;$FFFE

	pha
	lda $d20e
	and #$40
	beq KEYIRQ
	lda #0
	sta $d20e
	sta $11
	lda $10
	sta $d20e
	pla
	rti

KEYIRQ	txa
	pha
	lda #$bf
	sta $d20e
	lda $10
	sta $d20e
	lda $d209
	cmp $02f2
	bne NKY0
	ldx $02f1
	bne NOKY1
NKY0	ldx $026d
	bne NOKY11
	sta $02dc
	sta $02fc
	sta $02f2
	lda #3
	sta $02f1
NOKY1	lda $02d9
	sta $022b
NOKY11	pla
	tax
	pla
	rti

*-----------------------------
WAIT	LDA:CMP:REQ $14
	RTS
*-----------------------------
*Moja procedura VBlank

MojaVBL inc $14		;zegar
	sne
	inc $13

*przepisanie rejestrow
	lda #0
	sta $2c8
	ldx #8		;kolory
	lda $2c0,x
	sta $d012,x
	dex
	bpl *-7

block	lda #0		;blokuja operacje load
	beq _skip

	lda _zoom_+1
	beq noZOM

	lda wys
	clc
	adc pmgy
	tax
	jmp no_

noZOM	ldx pmgy	;przepisuj co ramke kolory z tablic
no_	cpx #192
	scc
	ldx #191
	lda kol0,x
	sta kol
	sta kol+8
	sta $2c8
	lda kol1,x
	sta kol+1
	sta kol+9
	sta $2c4
	lda kol2,x
	sta kol+2
	sta kol+10
	sta $2c5
	lda kol3,x
	sta kol+3
	sta kol+11
	sta $2c6

	lda jas0,x
	sta jas
	lda jas1,x
	sta jas+1
	lda jas2,x
	sta jas+2
	lda jas3,x
	sta jas+3

_skip	lda $230	;pamiec ekranu
	ldx $231
	sta $d402
	stx $d403
	lda $22f	;ekran
	sta $d400
	lda $26f	;pmg
	sta $d01b
	lda $2f4	;znaki
	sta $d409

Firevbl lda Fire+1
	beq fs
	lda $d010
	sta Fire+1

fs	lda $d20f	;klawiatura
	and #4
	beq NKY
	lda $02f1
	beq NKY
	dec $02f1
NKY	lda $022b
	beq NOKY2
	lda $d20f
	and #4
	bne NOKY
	dec $022b
	bne NOKY2
	lda $026d
	bne NOKY2
	lda $02da
	sta $022b
	lda $d209
	and #$3f
	cmp #$11
	beq NOKY2
	lda $d209
	sta $02fc
	jmp NOKY2
NOKY	lda #0
	sta $022b
NOKY2	jmp ($224)

*-----------------------------
* kasuje zawartosc ekranu
*-
CLSScreen
	mwa #Ekran10 POM1

	mwa #Ekran20 POM2

	ldx #192
CLSS1	ldy #39
	lda kolor1
	sta (POM1),Y
	lda kolor2
	sta (POM2),Y
	dey
	bpl CLSS1+2
	jsr AddPom
	dex
CLSS2	ldy #39
	lda kolor2
	sta (POM1),Y
	lda kolor1
	sta (POM2),Y
	dey
	bpl CLSS2+2
	jsr AddPom
	dex
	bne CLSS1
	RTS
*-----------------------------
CLSColor RTS

*-----------------------------
Key	lda $2fc
	cmp #$FF
	bne Key_2
	lda $d300
	and #$f
	cmp #$f
	bne JoyKey
	clc
	RTS
Key_2	PHA
	LDA #$FF
	STA $2FC
	lda #7
	STA $D01f
	PLA
	sec
	RTS

JoyKey  ldx:cpx:req $14

	lsr @
	bcs *+6
	lda #$e
	bne Key_2
	lsr @
	bcs *+6
	lda #$f
	bne Key_2
	lsr @
	bcs *+6
	lda #$6
	bne Key_2
	lda #$7
	bne Key_2
*-------------------
OPEN	STA $354	;adres nazwy
	STX $355
	STY $35A	;komenda
	LDA #35
	STA $358
	LDA #0
	STA $359
	LDA #3
	STA $352
	jsr ROMON
	LDA #$40
	STA $D40E
	LDA #0
	STA $D400
	STA $22F
	LDX #$10
	JMP $E456
*-------------------
READ	STA $354	;adres bufora
	STX $355
	STY $359	;ile stron
	LDA #0
	STA $358
	LDA #7
	STA $352
	LDX #$10
	JMP $E456
*-------------------
READ01	LDA #0
	STA $359
	LDA #1
	STA $358
	LDA #7
	STA $352
	LDX #$10
	JMP $E456
*-------------------
WRITE	STA $354	;adres bufora
	STX $355
	STY $359	;ile stron
;	LDA #0
;	STA $358
	LDA #11
	STA $352
	LDX #$10
	JMP $E456
*-------------------
CLOSE	jsr ROMON
	LDX #$10
	LDA #$C
	sta block+1
	STA $342,X
	JSR $E456
	PHP
	jsr ROMOFF
	LDA #$3A
	STA $22F
	LDA #$C0
	STA $D40E
	PLP
	lda #$ff
	sta $2fc
	RTS
*-----------------------------------------------------------
LFTxt	dta c'XLPBCM'

LInp	lda $358	;czy = 16004 ?
	cmp #$84
	bne null
	lda $359
	cmp #$3e
	bne null

	MWA #Ekran10+8000+$1e00 PomADR1

	MWA #Ekran20+$1e00 PomADR2

	lda #0
	sta block+1
	ldy #3
LInp0	lda Ekran10+16000,y
	sta kol,y
	sta jas,y
	dey
	bpl LInp0
	jsr jascol
	ldx #$3c+1
LInp1_	ldy #$7F
LInp1	lda (pomAdr1),y
	sta (pomAdr2),y
	dey
	bpl LInp1

	sbw pomAdr1 #$80

	sbw pomAdr2 #$80

	dex
	bne LInp1_
	rts
null	jmp LFErr
*--
lrip_q	rts
LRip	jsr clscur
	lda #50
	sta crX0
	jsr wskaz
	lda ekran10+7
	cmp #$10		;tylko ripy 16kolorowe
;	bne lrip_q

	lda  <ekran10+24
	clc
	adc ekran10+17
	sta pom
	lda >ekran10+24
	adc #0
	sta pom+1

	ldy #7
cc_	lda (pom),y
	sta kol,y
	dey
	bpl cc_
	jsr jascol

	mwa #ekran10 pom

	lda <ekran10
	clc
	adc ekran10+11
	sta pom1
	lda >ekran10
	adc ekran10+10
	sta pom1+1

; przepisz pamiec z rip'em o naglowek

	ldx #64
	ldy #0
mv0	lda (pom1),y
	sta (pom),y
	iny
	bne mv0

	inc pom+1
	inc pom1+1
	dex
	bne mv0

; dekompresja pod $4100
	jsr lzss

;przepisz po 8000byte spod $4100 i $4100+8000
	mwa #$4100+16000 pom

	mwa #ekran20+7680 pom1

	jsr move
*-- drugi obraz
	mwa #$4100+8000 pom

	mwa #ekran10+7680 pom1

*--
move	ldx #31
mv01	ldy #$ff
mv02	lda (pom),y
	sta (pom1),y
	dey
	bne mv02
	lda (pom),y	;index = 0
	sta (pom1),y
	dec pom+1
	dec pom1+1
	dex
	bne mv01
	rts
*--
_LInp	jmp LInp
LMic	lda $358	;czy = 7684 ?
	cmp #$04
	bne _LInp
	lda $359
	cmp #$1e
	bne _LInp
	lda #0
	sta block+1
	ldy #2
LMic0	lda Ekran10+7680,y
	sta kol+1,y
	sta jas+1,y
	dey
	bpl LMic0
	lda Ekran10+7680+3
	sta kol
	sta jas
	jsr jascol
	jsr SetPomAdr
	ldx #$1e
	ldy #0
Lmic1	lda (pomAdr1),y		;przepisz Ekran1 do Ekran2 jesli plik=192*40+4
	sta (pomAdr2),y
	iny
	bne LMic1
	inc PomAdr1+1
	inc PomAdr2+1
	dex
	bne Lmic1
	RTS

*-----------------------------

LoadFil	lda <PLIK1
	ldx >PLIK1
	ldy #4
	jsr OPEN
	bmi LFErr
	lda <Ekran10
	ldx >Ekran10
	sta Read1+1
	stx Read1+2
	ldy #$3f
	jsr Read
	bpl *+6
	cpy #136
	bne LFErr
	jsr CLOSE
	jsr Read1
	cmp #'R'
	beq _Lrip
	cmp LFTxt
	bne _LMic
	jsr Read1
	cmp LFTxt+1
	bne _LMic
	jsr Read1
	cmp LFTxt+2
	bne _LMic
	jsr Read1
	cmp LFTxt+3	;load BMP
	beq LBMP
	cmp LFTxt+4	;load XLP
	beq LCrunch
	cmp LFTxt+5
	beq _LCrunchM	;load MAX
_LMic	jmp LMic
_LRip	jmp LRip

*---

LFErr	jsr CLOSE
	LDA #0
	STA $D40E
	STA $22F
	jsr Undo
	LDA #$C0
	STA $D40E
	LDA #$3A
	STA $22F
	RTS

*-----------------------------
LBMP	jsr SetPomAdr2
	ldx #$1e
	ldy #0
Lbmp1	jsr Read1
	sta (pomAdr1),y
	iny
	bne Lbmp1
	inc PomAdr1+1
	dex
	bne Lbmp1
	ldx #$1e
	ldy #0
	sty block+1
Lbmp2	jsr Read1
	sta (pomAdr2),y
	iny
	bne Lbmp2
	inc PomAdr2+1
	dex
	bne Lbmp2
	JSR Read1
;	STA $2C4
	sta kol+1
	sta jas+1
	JSR Read1
;	STA $2C5
	sta kol+2
	sta jas+2
	JSR Read1
;	STA $2C6
	sta kol+3
	sta jas+3
	JSR Read1
;	STA $2C8
	sta kol
	sta jas
	jsr jascol
	jsr UNDO
	RTS

*-----------------------------
_LCrunchM jmp LCrunchM
LCrunch LDA #0		;load XLP
	STA $D40E
	STA $22F
	sta block+1
	jsr DeCrunch0
	jsr UNDO
	LDA #$C0
	STA $D40E
	LDA #$3A
	STA $22F
	jsr jascol
	RTS

LCrunchM LDA #0		;load MAX
	STA $D40E
	STA $22F
	sta block+1
	ldx <kol0
	ldy >kol0
	jsr read2
	ldx <kol1
	ldy >kol1
	jsr read2
	ldx <kol2
	ldy >kol2
	jsr read2
	ldx <kol3
	ldy >kol3
	jsr read2

	ldx <jas0
	ldy >jas0
	jsr read2
	ldx <jas1
	ldy >jas1
	jsr read2
	ldx <jas2
	ldy >jas2
	jsr read2
	ldx <jas3
	ldy >jas3
	jsr read2

	ldx <tabk
	ldy >tabk
	jsr read2

	jsr DeC2
	jsr UNDO
	LDA #$C0
	STA $D40E
	LDA #$3A
	STA $22F
	sta block+1
	RTS

read2	stx rea+1
	sty rea+2
	ldy #0
rea_	jsr read1
rea	sta $ffff,y
	iny
	cpy #192
	bne rea_
	rts

DeCrunch0 JSR Read1
;	STA $2C4
	sta kol+1
	sta jas+1
	JSR Read1
;	STA $2C5
	sta kol+2
	sta jas+2
	JSR Read1
;	STA $2C6
	sta kol+3
	sta jas+3
	JSR Read1
;	STA $2C8
	sta kol
	sta jas
DeC2	JSR SetPomADR2
	LDA #0
	STA GDZIE
	LDA #40
	STA SZER
LCR1
	MWA PomADR1 PUT1+1

	ADW PomADR2 #40 PUT2+1

	LDA #192
	STA WYS
LCR2	JSR Decrunch1
	LDA WYS
	BNE LCR2

	MWA PomADR2 PUT1+1

	ADW PomADR1 #40 PUT2+1

	LDA #192
	STA WYS
LCR3	JSR Decrunch1
	LDA WYS
	BNE LCR3

	INW PomADR1

	INW PomADR2

	DEC SZER
	LDA SZER
	BNE LCR1
	RTS

*-------------------
Decrunch1 LDA GDZIE
	BMI TAK_
	BNE NIE_
	STA ILE
	STA ILE+1
	JSR Read1
	BMI STAK
DC1	CMP #$40
	BCC DC2
	AND #$3F
	STA ILE+1
	JSR Read1
DC2	STA ILE
	LDA #1
	STA GDZIE
	JMP NIE_

STAK	AND #$7F
	CMP #$40
	BCC DC3
	AND #$3F
	STA ILE+1
	JSR Read1
DC3	STA ILE
	JSR Read1
	STA BYT
	LDA #$80
	STA GDZIE
	JMP TAK_
*-------------------
NIE_	DEC ILE
	LDA ILE
	CMP #$FF
	SNE
	DEC ILE+1
	LDA ILE+1
	BMI *+8
	JSR Read1
	JMP PUT
	LDA #0
	STA GDZIE
	JMP Decrunch1
*-------------------
TAK_	DEC ILE
	LDA ILE
	CMP #$FF
	SNE
	DEC ILE+1
	LDA ILE+1
	BMI *+7
	LDA BYT
	JMP PUT
	LDA #0
	STA GDZIE
	JMP Decrunch1
*-------------------
*odczyt 1 bajtu z bufora

Read1	LDA $ffff
	php
	INW Read1+1
	plp
	RTS

*-------------------
PUT	TAX
	DEC WYS
	LDA WYS
	AND #1
	BEQ PUT2
PUT1	STX $ffff
	ADW PUT1+1 #80
	RTS

PUT2	STX $ffff
	ADW PUT2+1 #80
	RTS

*-----------------------------------------------------------
SaveMIC	LDA <plik1
	LDX >plik1
	LDY #8
	JSR OPEN
	spl
	RTS

	LDA #0
	sta $358
	lda <Ekran10
	ldx >Ekran10
	ldy #$1e
	jsr Write
	LDX $2C4
	JSR Write1
	LDX $2C5
	JSR Write1
	LDX $2C6
	JSR Write1
	LDX $2C8
	JSR Write1
	RTS

*-----------------------------
SaveBMP	LDA <plik1
	LDX >plik1
	LDY #8
	JSR OPEN
	spl
	RTS

	ldx LFTxt
	JSR Write1
	ldx LFTxt+1
	JSR Write1
	ldx LFTxt+2
	JSR Write1
	ldx LFTxt+3
	JSR Write1

	LDA #0
	sta $358
	lda <Ekran10
	ldx >Ekran10
	ldy #$1e
	jsr Write
	lda <Ekran20
	ldx >Ekran20
	ldy #$1e
	jsr Write
	LDX $2C4
	JSR Write1
	LDX $2C5
	JSR Write1
	LDX $2C6
	JSR Write1
	LDX $2C8
	JSR Write1
	RTS

*-----------------------------
SaveCrunch ldy #0
	mva jas0,y	bufor1,y
	mva jas1,y	bufor1+$100,y
	mva jas2,y	bufor1+$200,y
	mva jas3,y	bufor1+$300,y
	dey
	bne SaveCrunch+2

	LDA <plik1
	LDX >plik1
	LDY #8
	JSR OPEN
	spl
	RTS

Crunch	ldx LFTxt
	JSR Write1
	ldx LFTxt+1
	JSR Write1
	ldx LFTxt+2
	JSR Write1
sav	lda #0
	beq XLP
	ldx LFTxt+5
	JSR Write1
	lda <kol0
	ldx >kol0
	jsr write2
	lda <kol1
	ldx >kol1
	jsr write2
	lda <kol2
	ldx >kol2
	jsr write2
	lda <kol3
	ldx >kol3
	jsr write2

	lda <bufor1
	ldx >bufor1
	jsr write2
	lda <bufor1+$100
	ldx >bufor1+$100
	jsr write2
	lda <bufor1+$200
	ldx >bufor1+$200
	jsr write2
	lda <bufor1+$300
	ldx >bufor1+$300
	jsr write2

	lda <tabk
	ldx >tabk
	jsr write2
	jmp cru2

XLP	ldx LFTxt+4
	JSR Write1
;	LDX $2C4
	ldx kol+1
	JSR Write1
;	LDX $2C5
	ldx kol+2
	JSR Write1
;	LDX $2C6
	ldx kol+3
	JSR Write1
;	LDX $2C8
	ldx kol
	JSR Write1
cru2	JSR SetPomADR
	LDA #0
	STA GDZIE
	STA ILE
	STA ILE+1

	MWA #Bufor1 BUFS+1

	LDA #40
	STA SZER
CP1	MWA PomADR1 GET1+1

	ADW PomADR2 #40 GET2+1

	LDA #192
	STA WYS
CP2	JSR GET1
	JSR COMP
	JSR GET2
	BCS CP3
	JSR COMP
	JMP CP2
CP3	JSR COMP
	MWA PomADR2 GET1+1

	ADW PomADR1 #40 GET2+1

	LDA #192
	STA WYS
CP4	JSR GET1
	JSR COMP
	JSR GET2
	BCS CP5
	JSR COMP
	JMP CP4
CP5	JSR COMP

	INW PomADR1

	INW PomADR2

	DEC SZER
	LDA SZER
	BNE CP1
	LDA GDZIE
	BMI ETAK
	BNE ENIE
	LDX #1
	JSR Write1
	LDX BYT
	JMP Write1

ENIE	LDX BYT
	JSR Write1

	INW ILE

	JMP SV_NO

ETAK	LDA BYT
	STA Bufor1
	JMP SV_JA

COMP	LDA GDZIE
	BMI TAK_1
	BNE NIE_1
	LDA ILE
	BNE POROW
	LDA #2
	STA ILE
	STX BYT
	RTS
POROW	CPX BYT
	BNE SNIE_1
	LDA #$80
	STA GDZIE
	RTS

SNIE_1	LDA BYT
	STX BYT
	JSR BUFS
	LDA #1
	STA GDZIE
	RTS
NIE_1	CPX BYT
	BEQ NIE__2
	LDA BYT
	STX BYT
	JSR BUFS

	INW ILE
	RTS

NIE__2	JSR SV_NO
	LDX #0
	STX ILE+1
	INX
	INX
	STX ILE
	LDA #$80
	STA GDZIE
	RTS

TAK_1	CPX BYT
	BNE TAK__2

	INW ILE
	RTS

TAK__2	LDA BYT
	STX BYT
	JSR BUFS
	JSR SV_JA
	LDX #0
	STX GDZIE
	STX ILE+1
	INX
	INX
	STX ILE
	RTS

GET1	LDX $ffff
	ADW GET1+1 #80

	DEC WYS
	RTS

GET2	LDX $ffff
	ADW GET2+1 #80

	DEC WYS
	LDA WYS
	BNE *+4
	SEC
	RTS
	CLC
	RTS
*-------------------
Write1	STX BFSAV
	LDA <BFSAV
	LDX >BFSAV
	STA $354
	STX $355
	LDA #1
	LDX #0
	STA $358
	STX $359
	LDA #11
	STA $352
	LDX #$10
	JSR $E456
	RTS

Write2	STA $354
	STX $355
	LDA #192
	LDX #0
	STA $358
	STX $359
	LDA #11
	STA $352
	LDX #$10
	JSR $E456
	RTS

*-------------------
BUFS	STA Bufor1
	INW BUFS+1
	RTS

SV_NO	DEW ILE

	LDA ILE+1
	BNE SN1
	LDA ILE
	CMP #$40
	BCS SN1
	TAX
	JSR Write1
	JMP SN2

SN1	LDA ILE+1
	ORA #$40
	TAX
	JSR Write1
	LDX ILE
	JSR Write1

SN2	MWA #Bufor1 SN3+1

SN3	LDX Bufor1
	JSR Write1
	INW SN3+1

	LDA SN3+1
	CMP BUFS+1
	BNE SN3
	LDA SN3+2
	CMP BUFS+2
	BNE SN3

	MWA #Bufor1 BUFS+1
	RTS

SV_JA	LDA ILE+1
	BNE ST1
	LDA ILE
	CMP #$40
	BCS ST1
	ORA #$80
	TAX
	JSR Write1
	JMP ST2

ST1	LDA ILE+1
	ORA #$C0
	TAX
	JSR Write1
	LDX ILE
	JSR Write1

ST2	LDX Bufor1
	JSR Write1

	MWA #Bufor1 BUFS+1
	RTS

BFSAV	dta b(0)

*-----------------------------
SetPomADR
	MWA #Ekran10 PomADR1
	MWA #Ekran20 PomADR2
	RTS

SetPomADR2
	MWA #Ek01 PomADR1
	MWA #Ek02 PomADR2
	RTS

*-----------------------------------------------------------
PUTZOOM	jsr SetPomAdr
	jsr AdrZm1
*-------
	MWA #Bufor1 PUTZ1+1

	MWA #Bufor2 PUTZ2+1
*--------------
	LDA #48		;ile lini
	STA BYT
	lda WYS
	lsr @
	bcs ZX2

ZX1	lda #39		;ile punktow
	sta Pom
	jsr PutLZ0
	jsr AddPom
	DEC BYT
	BEQ ZX3
ZX2	lda #39		;ile punktow
	sta Pom
	jsr PutLZ1
	jsr AddPom
	DEC BYT
	BNE ZX1
ZX3	RTS

PutLZ0	LDY #0
	LDA (POM1),Y
	jsr PtZ0
	LDA (POM2),Y
	jsr PtZ1
	lda SZER
	and #3
	asl @
	tax
	lda SkokiPZ0,x
	sta SkPZ0+1
	lda SkokiPZ0+1,x
	sta SkPZ0+2
SkPZ0	jmp $ffff

PutLZ1	LDY #0
	LDA (POM1),Y
	jsr PtZ1
	LDA (POM2),Y
	jsr PtZ0
	lda SZER
	and #3
	asl @
	ora #8
	tax
	lda SkokiPZ0,x
	sta SkPZ1+1
	lda SkokiPZ0+1,x
	sta SkPZ1+2
SkPZ1	jmp $ffff

PutLZ2 lda #0
	sta Pom
	ldy #9
	lda SZER
	and #3
	seq
	LDY #10
	stx PLZ22+1
	cpx #0
	bne PLZ20
	LDA (POM1),Y
	jsr PtZ0
	LDA (POM2),Y
	jsr PtZ1
	jmp PLZ21
PLZ20	LDA (POM1),Y
	jsr PtZ1
	LDA (POM2),Y
	jsr PtZ0
PLZ21	lda SZER
	sec
	sbc #1
	and #3
	asl @
PLZ22	ora #0
	tax
	lda SkokiPZ0,x
	sta SkPZ2+1
	lda SkokiPZ0+1,x
	sta SkPZ2+2
SkPZ2	jmp $ffff

PtlZ0	INY
	LDA (POM1),Y
	jsr PtZ0
	LDA (POM2),Y
	jsr PtZ1
PktZ0	jsr P0Z0
	dec Pom
	bmi EndPLZ
PktZ1	jsr P0Z1
	dec Pom
	bmi EndPLZ
PktZ2	jsr P0Z2
	dec Pom
	bmi EndPLZ
PktZ3	jsr P0Z3
	dec Pom
	bpl PtlZ0
	RTS

PtlZ1	INY
	LDA (POM1),Y
	jsr PtZ1
	LDA (POM2),Y
	jsr PtZ0
PktZ4	jsr P0Z0
	dec Pom
	bmi EndPLZ
PktZ5	jsr P0Z1
	dec Pom
	bmi EndPLZ
PktZ6	jsr P0Z2
	dec Pom
	bmi EndPLZ
PktZ7	jsr P0Z3
	dec Pom
	bpl PtlZ1
EndPLZ	RTS

SkokiPZ0
	Dta a(PktZ0),a(PktZ1),a(PktZ2),a(PktZ3)
	Dta a(PktZ4),a(PktZ5),a(PktZ6),a(PktZ7)

*--------------
AddPom	ADW POM1 #40

	ADW POM2 #40
	RTS
*--------------
SecPom  SBW POM1 #40

	SBW POM2 #40
	RTS
*--------------
AdrZm1	equ *		;Oblicz adresy lewego gornego rogu ekranu
	LDY WYS
	LDA SZER
	LSR @
	LSR @
	CLC
	adc AdYLo,Y
	tax
	lda AdYHi,Y
	adc #0
	tay

	STX POM1
	TYA
	CLC
	ADC PomADR1+1
	STA POM1+1
	STX POM2
	TYA
	CLC
	ADC PomADR2+1
	STA POM2+1
	RTS

*--------------
AddPUTZ	ADW PUTZ1+1 #39
	ADW PUTZ2+1 #39
	RTS

*--------------
PUTZ1	STA $ffff
	INC *-2
	BNE *+5
	INC *-6
	RTS
PUTZ2	STA $ffff
	INC *-2
	BNE *+5
	INC *-6
	RTS

*-------------------
PtZ0	sta P0Z0+1
	and #$3F
	sta P0Z1+1
	and #$F
	sta P0Z2+1
	and #$3
	sta P0Z3+1
	RTS
*-------------------
PtZ1	sta P1Z0+1
	and #$3F
	sta P1Z1+1
	and #$F
	sta P1Z2+1
	and #$3
	sta P1Z3+1
	RTS

*-------------------
P0Z0	lda #0
	lsr @
	lsr @
	lsr @
	lsr @
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jsr PUTZ1
P1Z0	lda #0
	lsr @
	lsr @
	lsr @
	lsr @
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jmp PUTZ2

P0Z1	lda #0
	lsr @
	lsr @
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jsr PUTZ1
P1Z1	lda #0
	lsr @
	lsr @
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jmp PUTZ2

P0Z2	lda #0
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jsr PUTZ1
P1Z2	lda #0
	lsr @
	lsr @
	tax
	lda kolmask0,x
	jmp PUTZ2

P0Z3	ldx #0
	lda kolmask0,x
	jsr PUTZ1
P1Z3	ldx #0
	lda kolmask0,x
	jmp PUTZ2

*-----------------------------
new_col	lda pmgy
	beq new_
	cmp #192
	scc
	lda #191
	and #%11111110

	tay		;czy poprzednia wartosc jest taka sama
	lda tabk,y
	cmp tabk-1,y
	bne new_	;aktualna paleta bez zmian
	clc
	adc #1
moz_	sta tabk,y	;ustaw nastepna palete
	iny
	cpy #192
	bne moz_
new_	jmp SetColor

*-----------------------------
ZOOM	RTS
retdl0	rts

*-------------------
SetDlZ	MWA #Bufor1 PomADR1

	MWA #Bufor2 PomADR2

;	MWA #DLAd1	Pom1
;	MWA #DLAd11	Pom2

	ldx #48
SDZ1	jsr PutA1Z
	jsr PutA2Z
	jsr PutA1Z
	jsr PutA2Z
	jsr DodPAD1
	dex
	bne SDZ1
	RTS

*-------------------
PutA1Z	ldy #1
	lda PomAdr1
	sta (pom1),Y
	lda PomAdr2
	sta (pom2),Y
	iny
	lda PomAdr1+1
	sta (pom1),Y
	lda PomAdr2+1
	sta (pom2),Y
	jmp PutA3Z

PutA2Z	ldy #1
	lda PomAdr2
	sta (pom1),Y
	lda PomAdr1
	sta (pom2),Y
	iny
	lda PomAdr2+1
	sta (pom1),Y
	lda PomAdr1+1
	sta (pom2),Y

PutA3Z	ADW Pom1 #3
	ADW Pom2 #3
	RTS

*-------------------
DODPAD1	ADW PomADR1 #40
	ADW PomADR2 #40
	RTS

*---------------------------------------
czyta	ldy #19
przep	lda Filename,y
	sta Plik1,y
	dey
	bpl przep
	lda #1
	sta Plikow
	jmp GetPlk2

DIRECTORY	JSR CopyEkr0
	JSR DRCO
	PHA
	jsr UNDO
	PLA
	RTS
*--------------
DRCO	JSR UNDO
	LDA #5
	JSR PutWinTxt
	LDA #5
	JSR Wybor0
	CMP #$1B	;Esc
	BNE Dire1+3
	RTS
Dire1	jsr CLOSE
	lda #6
	LDX #19
	JSR PobNap
	sta pom1

	ldx #0
	ldy #19		;sprawdz czy w nazwie pliku nie ma '*'
tst_gw	lda filename,y	;jesli nie ma to wczytaj plik o podanej nazwie
	cmp #$a		;*
	beq _cont
	dey
	bpl tst_gw
	jmp czyta

_cont	lda pom1
	CMP #$1B	;Esc
	BEQ DRCO
	LDA <Filename
	LDX >Filename
	JSR ICOD_ASCI0
	LDA <Filename
	LDX >Filename
	LDY #$06
	JSR OPEN
	php
	JSR ASCII_ICODE
	plp
	bmi Dire1
	LDA <Bufor2
	LDX >Bufor2
	STA POM2
	STX POM2+1
	LDY #$05
	JSR READ
	bpl DirOk1
	cpy #136
	bne Dire1
DirOk1	jsr CLOSE
	LDA <DIREC
	LDX >DIREC
	STA POM1
	STX POM1+1
	LDA #0
	STA PLIKOW
	JSR Dire2
	LDA #$9B     ;RETURN
	sta (POM1),y
	LDA <DIREC
	LDX >DIREC
	JSR ASCI0_ICOD
WYBPLK	LDA PLIKOW
	BEQ Dire1
	CMP #1
	BNE SaPlk
	ldx #0
	beq GetPlk
SaPlk	cmp #10
	scc
	lda #10
	sta FilWnd+5
	LDA #7
	JSR Wybor1
	CMP #$1B	;Esc
	BNE GetPlk
	JMP DRCO
GetPlk	LDA <DIREC
	LDY >DIREC
	STA Pom1
	STY Pom1+1
	LDA <PLIK1
	LDY >PLIK1
	STA POM2
	STY POM2+1
	jsr PrzepN
GetPlk2	LDA <PLIK1
	LDX >PLIK1
	JSR ICOD_ASCI0
	lda #0
	RTS

Dire2	JSR AdPOM2
	ldy #0
	lda (pom2),y
	CMP #$20
	BEQ *+3
	RTS
	INC PLIKOW
	JSR AdPOM2
DrName	lda (POM2),y
	sta (POM1),y
	iny
	cpy #8
	bcc DrName
	LDA #$2E     ;.
	sta (POM1),y
	jsr AdPOM1
DrExt	lda (POM2),y
	sta (POM1),y
	iny
	cpy #11
	bcc DrExt

	adw POM1 #11

	adw POM2 #11

	ldy #0
	lda (POM2),y
	jsr AdPOM2
	CMP #$9B	;return(end)
	BNE *-7
	BEQ Dire2

*-----------
AdPOM2	inw POM2
	RTS
*-----------
AdPOM1	INW POM1
	RTS
*-----------
PrzepN	ldy #0
	LDA Filename,y
	sta (POM2),Y
	cmp #$1A	;:
	beq PrzN2
	iny
	bne PrzepN+2
PrzN2	iny
	tya
	clc
	adc POM2
	sta POM2
	bcc PrzN3
	inc POM2+1
PrzN3	CPX #0
	beq E_Nap2-2

	ADW POM1 #12

	DEX
	BNE PrzN3
	ldx #11
E_Nap2	LDY #0
	LDA (POM1),Y
	CMP #0
	BEQ *+7
	STA (POM2),Y
	jsr AdPOM2
	jsr AdPOM1
	DEX
	BPL E_Nap2
	lda #$DB
	sta (POM2),y
	RTS

*-----------
MAX_N1	dta b(0)
POZ_N1	dta b(0)
NR_WND	dta b(0)

PobNap	STA NR_WND
	STX MAX_N1

	MWA #Filename POM1

	LDY #0
PobNN	LDA (POM1),Y
	BEQ PobN0
	CMP #$DB
	BEQ PobN0
	INY
	CPY MAX_N1
	BCC PobNN
PobN0	STY POZ_N1
	LDA #$6
	STA (POM1),Y
PobN1	lda Nr_Wnd
	jsr PutWinTxt

	MWA #Filename POM1

	JSR GET_KEY
	CMP #$1B	;ESC
	BNE *+8
	jsr PobNRt
	lda #$1B
	RTS
	CMP #$7E	;back
	BEQ PobNBk
	CMP #$9B	;return
	BEQ PobNRt
	CMP #$2E	;.
	BEQ PobN2
	CMP #$5F	;_
	BEQ PobN2
	CMP #$2A	;*
	BEQ PobN2
	CMP #$30	;0
	BCC PobN1
	CMP #$3B	;;
	BCC PobN2
	CMP #$61	;a
	BCC PobN1
	CMP #$7B	;z
	BCS PobN1
	AND #$5F
PobN2	LDY POZ_N1
	CPY MAX_N1
	BCS PobN1
	JSR AS_IC
	STA (POM1),Y
	INY
	JMP PobN0

PobNBk	LDY POZ_N1
	BEQ PobN1
	LDA #0
	STA (POM1),Y
	DEY
	JMP PobN0

PobNRt	LDY #0
	LDA (POM1),Y
	CMP #6
	BEQ *+5
	INY
	BNE PobNRt+2
	LDA #$DB
	STA (POM1),Y
	RTS

*-----------------------------
Wybor1	sta Wyb1a+1
	asl @
	asl @
	asl @
	tay
	lda Ramki+2,y
	sta CrX0		;pos X win
	lda Ramki+3,y
	sta Wyb1Y+1		;pos Y win
	lda Ramki+5,y
	sta Maxw1+1		;wys win
	lda #0
	sta AktWyb
	sta AktWyb+1

Wyb11	JSR UstWskaz
Wyb1a	lda #0
	jsr PutWinTxt
Wyb1Y	ldy #0
	sty CrY0
	JSR Wskaz
	JSR GET_KEY
	CMP #$3D		;=
	BNE Wyb13
	LDA AktWyb
	clc
	adc #1
maxw1	CMP #0
	BCS Wyb12
	INC AktWyb
	bne Wyb11
Wyb12	clc
	adc AktWyb+1
	CMP Plikow
	bcs Wyb11
	inc AktWyb+1
	bne Wyb11
Wyb13	CMP #$2D		;-
	BNE Wyb15
	LDA AktWyb
	BEQ Wyb14
	DEC AktWyb
	JMP Wyb11
Wyb14	lda AktWyb+1
	BEQ Wyb11
	DEC AktWyb+1
	JMP Wyb11
Wyb15	CMP #$1B		;ESC
	BNE *+3
	RTS
	CMP #$9B		;RETURN
	BNE Wyb11

	lda AktWyb
	clc
	adc AktWyb+1
	tax
	lda #0
	RTS

UstWskaz
	ldx AktWyb+1

	MWA #DIREC FilWnd

UstWs1	dex
	spl
	RTS

	ADW FilWnd #12

	jmp UstWs1

*-----------------------------
AktWyb	dta b(0),b(0)
AKT_P1	dta b(0)

Wybor0	asl @
	asl @
	asl @
	tay
	lda Ramki+2,y
	sta CrX0		;pos X win
	lda Ramki+3,y
	sta CrY0		;pos Y win
	lda Ramki+5,y
	sta CrXY		;wys win
	lda #0
	sta AktWyb

Wyb1	JSR Wskaz
	JSR GET_KEY
	CMP #$3D		;=
	BNE Wyb2
	LDA AktWyb
	clc
	adc #1
	CMP CrXY
	BCS Wyb1
	INC AktWyb
	bne Wyb1
Wyb2	CMP #$2D		;-
	BNE Wyb3
	LDA AktWyb
	BEQ Wyb1
	DEC AktWyb
	JMP Wyb1
Wyb3	CMP #$1B		;ESC
	SNE
	RTS
	CMP #$9B		;RETURN
	BNE Wyb1

	lda AktWyb
	sta AKT_P1
	RTS

Wskaz	jsr CLSPMG
	lda CrX0
	asl @
	asl @
	sta PMGX
	lda AktWyb
	asl @
	asl @
	asl @
	clc
	adc CrY0
	adc #12
	tay
	sty PMGY
	jmp PtPMG1

*--------------
GET_KEY	LDA #$FF
	STA $2FC
	LDA $14
	CMP $14
	BEQ *-2
GK_1	LDA $D300
	AND #$F
	CMP #$F
	BNE GK_J
	LDA $2FC
	CMP #$FF
	BNE GK_2
	JSR FIRE
	BNE GK_1
	JSR FIRE
	BEQ *-3
	LDA #$9B
	RTS
GK_2	TAY
	LDA #7
	STA $D01F
	LDA $FEB0,Y ;ASCII
	RTS
GK_J	LDY $14
	CPY $14
	BEQ *-2
	LDY $14
	CPY $14
	BEQ *-2
	lsr @
	bcs *+5
	lda #$2D
	RTS
	lsr @
	bcs *+5
	lda #$3D
	RTS
	lsr @
	bcc *+5
	lsr @
	bcs GK_1
	lda #$1B
	RTS

*--------------
*   POM1-Adres ICODE
*   POM2-Adres ASCII
*--------------
ICOD_ASCI0	STA POM1	;zamienia z d'' na c''
	STA POM2
	STX POM1+1
	STX POM2+1

ICODE_ASCII  LDY #0
	LDA (POM1),Y
	JSR IC_AS
	STA (POM2),Y
	CMP #$9B
	BEQ *+5
	INY
	BNE ICODE_ASCII+2
	RTS
*--------------
IC_AS  CMP #$80
	PHP
	AND #$7F
	CMP #$60
	BCS *+12
	CMP #$40
	BCS *+5
	CLC
	ADC #$60
	SEC
	SBC #$40
	PLP
	SCC
	ORA #$80
	RTS
*--------------
*   POM1-Adres ASCII
*   POM2-Adres ICODE
*--------------
ASCI0_ICOD	STA POM1
	STA POM2
	STX POM1+1
	STX POM2+1

ASCII_ICODE  LDY #0
	LDA (POM1),Y
	JSR AS_IC
	STA (POM2),Y
	CMP #$DB
	BEQ ASCII_Q
	INY
	BNE ASCII_ICODE+2
	INC POM1+1
	INC POM2+1
	BNE ASCII_ICODE+2
ASCII_Q	RTS
*--------------
AS_IC  CMP #$80
	PHP
	AND #$7F
	CMP #$60
	BCS *+12
	CMP #$20
	BCS *+5
	CLC
	ADC #$60
	SEC
	SBC #$20
	PLP
	SCC
	ORA #$80
	RTS
*--------------
Plikow	dta b(0)

IOTxt	dta d'LOAD FILE'
	dta d'SAVE .XLP'
	dta d'SAVE .RAW'
	dta d'SAVE .MIC'
	dta d'SAVE .MAX'

Filename dta d'D1:*.*              '
Plik1	dta d'D1:*.*              ',b($DB)

*-----------------------------
CLSPMG	ldy #0
	tya
CPG1	sta PMG+$400,y
	iny
	bne CPG1
	RTS

*-----------------------------
PutPMG	lda WskZoom
	bmi PtPMG1

PtPMG4	lda PMGY	;kursor w ZOOM'ie
	asl @
	asl @
	tay
	ldx #8
PPG41	lda DatPMG0,x
	sta PMG+$410,y
	iny
	lda DatPMG0,x
	sta PMG+$410,y
	iny
	lda DatPMG0,x
	sta PMG+$410,y
	iny
	lda DatPMG0,x
	sta PMG+$410,y
	iny
	dex
	bpl PPG41
	lda #3
	sta $d008
	lda PMGX
	asl @
	asl @
	clc
	adc #36
	sta $d000
	lda PMGY
	clc
	adc WYS
	jsr BtDec
	ldy #39
	jsr PutD10
	lda PMGX
	clc
	adc SZER
	jsr BtDec
	ldy #34
	jsr PutD10
	RTS

PtPMG1	lda #0		;kursor normal
	beq PPMG1
	lda WskCur
	bne PtPMG2
PPMG1	ldy PMGY
	ldx #8
PPG11	lda DatPMG0,x
kursor	sta PMG+$41C,y
	iny
	dex
	bpl PPG11
PPG12	lda #0
	sta $d008
	lda PMGX
	clc
	adc #45
	sta $d000
	lda PMGY
	jsr BtDec
	ldy #39
	jsr PutD10
	lda PMGX
	jsr BtDec
	ldy #34
	jsr PutD10
	RTS

PtPMG2  ldy PMGY
	ldx #8
PPG21	lda DatPMG0,x
	sta PMG+$418,y
	iny
	sta PMG+$418,y
	iny
	dex
	bpl PPG21
	bmi PPG12

CLSCur  ldy #0
	tya
CCr1	sta PMG+$600,y
	iny
	bne CCr1
	RTS

CLSWsk  ldy #0
	tya
CCr2	sta PMG+$500,y
	sta PMG+$700,y
	iny
	bne CCr2
	RTS

PutCur  ldy PMGY
	ldx #8
PCr1	lda DatPMG4,x
	sta PMG+$61C,y
	iny
	dex
	bpl PCr1
	lda #0
	sta $d00A
	lda PMGX
	clc
	adc #45
	sta $d002
	RTS

PutCur2  ldx #8
PCr2	lda DatPMG0,x
	sta PMG+$61C,y
	iny
	dex
	bpl PCr2
	lda #0
	sta $d00A
	lda #161
	sta $d002
	RTS

PMGRamka  ldy PMGY
	ldx #8
PPR1	lda DatPMG2,x
	sta PMG+$51C,y
	lda DatPMG3,x
	sta PMG+$71C,y
	iny
	dex
	bpl PPR1
	ldy OldPMGY
	ldx #0
PPR2	lda DatPMG2,x
	sta PMG+$51C,y
	lda DatPMG3,x
	sta PMG+$71C,y
	iny
	inx
	cpx #9
	bcc PPR2

	lda #0
	sta $d009
	sta $d00B
	lda OldPMGX
	clc
	adc #45
	sta $d001
	lda PMGX
	clc
	adc #45
	sta $d003
	RTS

PutD10  lda Dana10+2
	sta NAG,y
	dey
	lda Dana10+1
	sta NAG,y
	dey
	lda Dana10
	sta NAG,y
	RTS

Dana10	dta b(0),b(0),b(0)

BtDec	sta Dana10+2
	ldy #0
	sty Dana10+1
	ldx #8
	SED
BDec1	asl Dana10+2
	lda Dana10+1
	adc Dana10+1
	sta Dana10+1
	rol Dana10
	dex
	bne BDec1
	CLD
	lda Dana10+1
	and #$0f
	ora #$10
	sta Dana10+2
	lda Dana10+1
	lsr @
	lsr @
	lsr @
	lsr @
	ora #$10
	sta Dana10+1
	lda Dana10
	and #$0f
	ora #$10
	sta Dana10
	RTS

DatPMG0
	dta b(%00000000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00101000)
	dta b(%11000110)
	dta b(%00101000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00000000)

DatPMG1
	dta b(%00000000)
	dta b(%00010000)
	dta b(%00110000)
	dta b(%01101000)
	dta b(%01001000)
	dta b(%01000100)
	dta b(%00000100)
	dta b(%00000010)
	dta b(%00000000)

DatPMG2
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00011110)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)

DatPMG3
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%11110000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)

DatPMG4
	dta b(%00000000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%11101110)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00000000)

DatPMG5
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00101000)
	dta b(%00010000)
	dta b(%00010000)
	dta b(%00000000)
	dta b(%00000000)

DatPMG6
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00010000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)
	dta b(%00000000)

*--------------
* Pixel
*-
WPlot	rts
GPlot	rts
Plot	RTS
plot_2	rts

Plot5	RTS

TbMs1	dta b($c0),b($30),b($0c),b($03)
TbMs2	dta b($3f),b($cf),b($f3),b($fc)

AdrPt	jsr SetPomAdr
	LDA AdYLo,Y
	STA POM1
	STA POM2
	LDA AdYHi,Y
	CLC
	ADC PomADR1+1
	STA POM1+1
	LDA AdYHi,Y
	CLC
	ADC PomADR2+1
	STA POM2+1
	RTS

*-------------------
Window	jsr UCouY
	stx WinX2+1
WinX2	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2

WinSk	jsr _rts

	ldx OldPMGX
	ldy OldPMGY
	jsr WPlot
	ldx OldPMGX
	cpx PMGX
	bcs *+5
	inx
	bcc WinX2+2
	inc OldPMGY
	dec Countr
	bne WinX2
WindEx	jmp _rts

*-------------------
UCouY	lda PMGY
	clc
	adc #2
	sbc OldPMGY
	sta Countr
	ldx OldPMGX
	RTS
*-------------------
Object	RTS
*-------------------
Objw	RTS
*-------------------
HELP	rts
*-------------------
INFO	rts
*-------------------
FUNC	rts
*-------------------
UstCur	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr Fire
*	beq *-3
	jsr wait
	jsr PutCur
	jmp CopyEkr0

*-------------------
PMGSrt	lda OldPMGY
	sta WEY1+1
	lda OldPMGX
	sta WEX1+1
	cmp PMGX
	beq PSEx
	bcc *+10
	ldx OldPMGX
	lda PMGX
	stx PMGX
	sta OldPMGX
	lda OldPMGY
	cmp PMGY
	beq PSEx
	bcc *+10
	ldx OldPMGY
	lda PMGY
	stx PMGY
	sta OldPMGY
PSEx	RTS

*-------------------
WndEx0	jsr WEX1

	mwa #Objw Func2+1

	lda #0
	sta Objw+1
	RTS

WndExt	jsr WEX1

	mwa #Object Func2+1

	lda #0
	sta Object+1
	lda #60
	jmp SetInfo

WEX1	ldx #0
	stx PMGX
WEY1	ldy #0
	sty PMGY
WndEx2	jsr Fire
;	beq *-3
	sta $d001
	sta $d002
	sta $d003
	jsr wait
	lda Object+1
	bne *+5
	jmp CLSCur
	RTS

*-------------------
PutWinTxt asl @
	asl @
	asl @
	tay
	lda Ramki,y
	sta CrF			;<adr txt
	lda Ramki+1,y
	sta CrF+1		;>adr txt
	lda Ramki+2,y
	sta CrX0		;pos X win
	sta CrXY
	lda Ramki+3,y
	sta CrY0		;pos Y win
	sta CrXY+1
	lda Ramki+4,y
	sta PWTxt4		;szer win

	lda Ramki+5,y
	sta PWTxt5		;wys win

	lda RamkaTxt
	jsr PutChar
	ldy #0
	sty CrFY

PWTxt0	lda RamkaTxt+1
	jsr PutChar
	inc CrFY
	ldy CrFY
	cpy PWTxt4
	bcc PWTxt0

	lda RamkaTxt+2
	jsr PutChar
	lda CrY0	;add posY
	clc
	adc #8
	sta CrY0

PWTxt1	ldx CrX0
	ldy CrY0
	jsr PutLinTxt
	lda CrF		;add pos txt
	clc
	adc CrFY
	sta CrF
	lda CrF+1
	adc #0
	sta CrF+1
	dec PWTxt5	;linii
	bne PWTxt1

	ldx CrX0
	stx CrXY
	ldy CrY0
	sty CrXY+1
	lda RamkaTxt+4
	jsr PutChar
	ldy #0
	sty CrFY
PWTxt2	lda RamkaTxt+1
	jsr PutChar
	inc CrFY
	ldy CrFY
	cpy PWTxt4
	bcc PWTxt2
	lda RamkaTxt+5
	jsr PutChar

	RTS

PWTxt4 brk
PWTxt5 brk

*we: CrF=Adr.Text ($9B) X=posX Y=posY

IniLinTxt stx CrX0
	sty CrY0
NxtLinTxt ldx CrX0	;pos X win
	ldy CrY0	;pos Y win
PutLinTxt stx CrXY	;pos X win
	sty CrXY+1	;pos Y win
	lda RamkaTxt+3	;|
	jsr PutChar
	ldy #0
	sty CrFY
PLTxt1  lda (CrF),y	;text
	jsr PutChar
	inc CrFY
	ldy CrFY
	cpy PWTxt4
	bcc PLTxt1
	lda RamkaTxt+3	;|
	jsr PutChar
	lda CrY0	;add posY
	clc
	adc #8
	sta CrY0
	RTS

*we: A-ASCII Chr. Crxy=X Crxy+1=Y

PutChar  ldx #0
	stx Pom+1
	asl @
	rol Pom+1
	asl @
	rol Pom+1
	asl @
	rol Pom+1
	sta Pom
	lda Pom+1
	clc
	adc >Fonty
	sta Pom+1

	ldy CrXY+1	;posY
	jsr AdrPt
	lda #0
	sta PutCh1+1
	lda CrXY	;posX
	sta PutCh2+1
	inc CrXY	;add posX
	jsr PutCh1
	jsr PutCh1
	jsr PutCh1
	jsr PutCh1
	jsr PutCh1
	jsr PutCh1
	jsr PutCh1
PutCh1	ldy #0
	lda (Pom),y
PutCh2	ldy #0
	sta (Pom1),y
	sta (Pom2),y
	inc PutCh1+1

	jmp AddPOM

*-------------------
*We:	---			Wy:	Z=1	-Fire
*					Z=0	-no Fire
*-------------------
Fire	lda #1
	bne fq
	lda $d010
	beq *-3
	lda #1
	sta Fire+1		;ustaw na 1
	lda #0
*	lda $d010
fq	RTS
*-------------------
*We:	X	-poz.x		Wy:	A	-Nr Col
*	Y	-poz.y
*-------------------
Locate2 sty _py+1
	jsr SetPomAdr2
	jsr AdrPt+3
	jmp Loc_skp

Locate sty _py+1
	jsr AdrPt
loc_skp	TXA
	lsr @
	lsr @
	tay
	TXA
	and #3
	tax

_py	lda #0
	lsr @
	bcs _niepa

	lda (Pom2),y	;linia parzysta
	and TbMs1,x
	sta BYT
	lda (Pom1),y
	and TbMs1,x
	jmp nxt

_niepa	lda (Pom1),y	;linia nieparzysta
	and TbMs1,x
	sta BYT
	lda (Pom2),y
	and TbMs1,x

nxt	cpx #0		;przesun bity w prawo
	bne Loc2
	lsr @
	lsr @
	ora byt
	lsr @
	lsr @
	lsr @
	lsr @
	RTS

Loc2	cpx #1
	bne Loc3
	lsr @
	lsr @
	ora byt
	lsr @
	lsr @
	RTS

Loc3	cpx #2
	bne Loc4
	lsr @
	lsr @
	ora byt
	RTS
Loc4	sta byt_+1
	lda byt
	asl @
	asl @
byt_	ora #0
	RTS

*-------------------
CopyEkr0
	mwa #Ekran10 xPOM1+1
	mwa #Ekran20 xPOM2+1

	mwa #Ek01 xPOMAdr1+1
	mwa #Ek02 xPOMAdr2+1

CE00	ldx #$1e
	ldy #0

CE01	equ *
Xpom1		lda *,y
Xpomadr1	sta *,y
Xpom2		lda *,y
Xpomadr2	sta *,y
	iny
	bne CE01

	inc xPOM1+2
	inc xPOM2+2
	inc xPOMAdr1+2
	inc xPOMAdr2+2
	dex
	bne CE01
	RTS

*-------------------
UNDO	mwa #Ekran10 xPOMAdr1+1
	mwa #Ekran20 xPOMAdr2+1
	mwa #Ek01 xPOM1+1
	mwa #Ek02 xPOM2+1
	bne CE00

NAG	Dta d'                               X000 Y000'		;naglowek ukryty - leca smieci
nag2	dta d'Rip2Max V1.0 (2002)  by TeBe+Stanley    '
	dta d'File (Shift+F)                          '

defcol	dta b(6,10,14,0,0)

kol	dta b($00),b($30),b($70),b($d2)
jas	dta b($00),b($02),b($04),b($06)
	dta b($00),b($30),b($70),b($d2)

KlawSk2
	dta b($39) ;Hflip
	dta b($10) ;Vflip
	dta b($12) ;Cflip
	dta b($28) ;Rotate
	dta b($00) ;Light
	dta b($3a) ;Dark
	dta b($23) ;Neg
	dta b($15) ;Blur
	dta b($3e) ;Spill
	dta b($2a) ;Embos
	dta b($3f) ;Antiq
	dta b($38) ;3deFfect
	dta b($2e) ;shadoW
	dta b($16) ;eXch

KlawSk21
	dta b($08) ;cOpy
	dta b($25) ;Move
	dta b($0a) ;Paste

KlawSk0
	dta b($0a) ;Point
	dta b($3f) ;sprAy
	dta b($05) ;Kspray
	dta b($3a) ;Draw
	dta b($00) ;Line
	dta b($0d) ;lInes
	dta b($2b) ;raYs
	dta b($2d) ;Triangle
	dta b($28) ;Rectangle
	dta b($12) ;Circle
	dta b($38) ;Fill
	dta b($15) ;Box
	dta b($3e) ;diSc
	dta b($08) ;Object

KlawSk01
	dta b($4d) ;Sh+I
	dta b($4b) ;Sh+U
	dta b($78) ;Sh+F
	dta b($6c) ;Sh+Tab
	dta b($37) ;Sh+.
	dta b($36) ;Sh+,
	dta b($0b) ;U
	dta b($11) ;HELP
	dta b($0c) ;RETURN
	dta b($76) ;Sh+CLR
	dta b($74) ;Sh+DEL
	dta b($27) ;LOGO
	dta b(033) ;SPACE
	dta b($56) ;Sh+X
	dta b($4c) ;Sh+Return

KlawSk1
	Dta b($32),b(0),a(SetCol)  ;0
	Dta b($1f),b(1),a(SetCol)  ;1
	Dta b($1e),b(2),a(SetCol)  ;2
	Dta b($1a),b(3),a(SetCol)  ;3
	Dta b($18),b(4),a(SetCol)  ;4
	Dta b($1d),b(5),a(SetCol)  ;5
	Dta b($1b),b(6),a(SetCol)  ;6
	Dta b($33),b(7),a(SetCol)  ;7
	Dta b($35),b(8),a(SetCol)  ;8
	Dta b($30),b(9),a(SetCol)  ;9
	Dta b($5f),b(10),a(SetCol) ;Sh+1
	Dta b($75),b(11),a(SetCol) ;Sh+2
	Dta b($5a),b(12),a(SetCol) ;Sh+3
	Dta b($58),b(13),a(SetCol) ;Sh+4
	Dta b($5d),b(14),a(SetCol) ;Sh+5
	Dta b($47),b(15),a(SetCol) ;Sh+6
	Dta b($06),b($b),a(JoyKy)  ;+
	Dta b($07),b($7),a(JoyKy)  ;*
	Dta b($0e),b($e),a(JoyKy)  ;-
	Dta b($0f),b($d),a(JoyKy)  ;=

KlawSk3

*-----------------------------

KlawSk20
	dta a(_rts)	;H
	dta a(_rts)	;V
	dta a(_rts)	;C
	dta a(_rts)	;R
	dta a(_rts)	;L
	dta a(_rts)	;D
	dta a(_rts)	;N
	dta a(_rts)	;B
	dta a(_rts)	;S
	dta a(_rts)	;E
	dta a(_rts)	;A
	dta a(_rts)	;F
	dta a(_rts)	;W
	dta a(_rts)	;X

	dta a(_rts)	;O
	dta a(_rts)	;M
	dta a(_rts)	;P

KlawSk00
	dta a(_rts)	;P
	dta a(_rts)	;A
	dta a(_rts)	;K
	dta a(_rts)	;D
	dta a(_rts)	;L
	dta a(_rts)	;I
	dta a(_rts)	;Y
	dta a(_rts)	;T
	dta a(_rts)	;R

KlawSk000
	dta a(_rts)	;C
	dta a(_rts)	;F
	dta a(_rts)	;B
	dta a(_rts)	;S
	dta a(_rts)	;O

*-------GOTO
KlawSk02
	dta a(INFO)		;Sh+I
	dta a(FUNC)		;Sh+U
	dta a(SetIO)		;Sh+F
	dta a(SetColor)		;Sh+Tab
	dta a(SetCurNorm)	;Sh+.
	dta a(SetCur2Y)		;Sh+,
	dta a(UNDO)		;U
	dta a(HELP)		;HELP
	dta a(PutFire)		;RETURN
	dta a(CLSScreen)	;Sh+CLR
	dta a(CLSColor)		;Sh+DEL
	dta a(Zoom)		;LOGO
	dta a(NxCol)		;Space
	dta a(CursAd)		;Sh+X
	dta a(New_Col)		;Sh+Return
*-----------------------------
TDL2 dta a(Ekran11),a(Ekran21)
*---------------------

*--
meta equ *

*,DLL0,DLL1,DLIv5,DLIv1,DLL11,DLL5,DLL51,DLIv0,DLL52

FNT1	Ins 'NEWXLP.FNT'

INIT	JSR WAIT
	LDA #0
	STA $D400
	STA $D40E
	sta color+1
	SEI
	LDA $230
	LDX $231
	STA DD1+1
	STX DD1+3
	LDA $200
	LDX $201
	STA DD2+1
	STX DD2+3
	LDA $224
	LDX $225
	STA DD3+1
	STX DD3+3

	LDY #0
	LDX #0
InitOS_1  LDA T_I,X
	STA POM
	INX
	LDA T_I,X
	STA POM+1
	INX
	LDA T_I,X
	STA (POM),Y
	INX
	CPX #T_EI-T_I
	BCC InitOS_1

	ldy #0
Ini1	lda FNT1,y
	sta FONTY,y
	lda FNT1+$100,y
	sta FONTY+$100,y
	lda FNT1+$200,y
	sta FONTY+$200,y
	lda FNT1+$300,y
	sta FONTY+$300,y
	iny
	bne Ini1

	ldy #0
	tya
ini2	sta jas0,y
	sta jas1,y
	sta jas2,y
	sta jas3,y
	iny
	bne ini2

	jsr jascol

	LDA:RNE $D40B

	CLI
	LDA #$C0
	STA $D40E
	RTS

*----------------

	org $0400	;od poczatku strony

.proc	lzss

/*
* LZSS depacker V4.1
* kody wstawia do drzewa binarnego
* najszybsza, rozpisany DEP 0,64,320

* dane -zrodlowe- mozna umiescic
* w obszarze -docelowym-

* w naglowku PCK (0..15) bajty 12..13
* okreslaja ofset o jaki maja byc
* przemieszczone dane -zrodlowe-
* wzgledem adresu -docelowego-
*/

buf	equ $70b0	;zrodlowy
out	equ $4100	;docelowy

adl0	equ $b100	;576
adh0	equ adl0+576	;576 1 wg tej
adl1	equ adh0+576	;576 2 kolejnosci
adh1	equ adl1+576	;576 3 w pamieci
tre01	equ adh1+576	;256 lo =0
tre02	equ tre01+256	;256 lo =0

err	equ $a0		;2
mx	equ err+2	;1
l0	equ mx+1	;2
l1	equ l0+2	;2
h0	equ l1+2	;2
h1	equ h0+2	;2
*-
p	equ h1+2	;2
l	equ p+2		;1
nxt	equ l+1		;1
val	equ nxt+1	;1
tmp	equ val+1	;2
pom	equ tmp+2	;16
*-
ind	equ p		;2
lic	equ ind+2	;1
csh	equ lic+1	;1

tand	equ $f8


* Wstep, parametry pliku
* mozna je pominac
*-----------------------

	lda buf+3	; stopien kompresji
	and #$7f
	sta ratio

	lda buf+4	; dlugosc oryginalna
	sta lng
	lda buf+5
	sta lng+1

	lda buf+6	; dlugosc spakowana
	sta lnght
	lda buf+7
	sta lnght+1

* wywolanie Fano dla 3 typow danych
* match_len 64
* ofset     256
* unpack    256
*----------------------------------

	lda <adl0
	ldx >adl0
	jsr set_hv
	lda <buf+16	; match_len
	ldx >buf+16
	ldy #64
	jsr fano

	lda <adl0+64
	ldx >adl0+64
	jsr set_hv
	lda <buf+16+32	; ofset
	ldx >buf+16+32
	ldy #0
	jsr fano

	lda <adl0+320
	ldx >adl0+320
	jsr set_hv
	lda <buf+16+160	; unpack
	ldx >buf+16+160
	ldy #0
	jsr fano

* dekompresja
* glowna proc
*------------

;	lda buf+8	; liczba znacznikow 1bit
;	sta ln
;	lda buf+9
;	sta ln+1

	ldx <buf+16+288	; spakowane dane
	ldy >buf+16+288
	stx stc+1
	sty stc+2

	lda <out	; IND docelowy
	sta ind
	clc		; BUF 4..5 rozmiar
	adc buf+4	; niespakowanych danych
	sta lln+1
	lda >out	; LLN HLN koniec danych
	sta ind+1
	adc buf+5
	sta hln+1

* init licznik LIC
	lda #$ff
	sta lic

*-----------
lop	jsr gbit	;0 - unpack
	bcs dp_ofs	;1 - match_len, ofset

dp_unp	sta $d01a
dep320	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0+320,y
	bne *-9
	lda adl0+320,y
	jmp j1

	lda adh1+320,y
	bne *-20
	lda adl1+320,y


j1	ldy #0
	sta (ind),y

	inw ind

tst	lda ind+1
hln	cmp #0
	bne lop
	lda ind
lln	cmp #0
	bcc lop

exit	equ *		; koniec dekompresji

	rts


dp_ofs	equ *
dep64	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0+64,y
	bne *-9
	lda adl0+64,y
	jmp j2

	lda adh1+64,y
	bne *-20
	lda adl1+64,y


j2	clc		; OFS=OFS+2
	adc #1		; zamiast 'adc #2'
	sta ofs+1

	lda ind		; IND=IND-OFS
	sta _adr+1
;	sec
ofs	sbc #0		; CLC ustawione
	sta adr+1	; czyli doda 1
	lda ind+1
	sta _adr+2
	sbc #0
	sta adr+2


dep0	lda #0
	tay
	jsr gbit
	bcs *+13

	lda adh0,y
	bne *-9
	lda adl0,y
	jmp j3

	lda adh1,y
	bne *-20
	lda adl1,y


j3	tay		; LEN=LEN+2
	iny		; dla BPL -1
	tya
	sec
	adc ind
	sta ind
	scc
	inc ind+1

adr	lda $ffff,y
_adr	sta $ffff,y	; sta (ind),y
	dey
	bpl adr

	jmp tst


*---------

gbit	inc lic
	bne g_
	lda #tand
	sta lic
stc	lda $ffff
	sta csh
	inw stc+1
g_	rol csh
	rts

*------------
set_hv	sta l0
	stx l0+1

	clc
	adc <576
	sta h0
	txa
	adc >576
	sta h0+1

	adw h0 #576 l1

	adw l1 #576 h1
	rts

* generowanie kodow
* Shannon-Fano
*------------------

* TRE01 - stare pozycje
* TRE02 - dlugosci kodow

fano	sty mx
	jsr sort

	ldy #0
	tya
cl	sta (l0),y
	sta (l1),y
	sta (h0),y
	sta (h1),y
	iny
	cpy mx
	bne cl

	sta p		; code
	sta p+1
	sta err		; code increment
	sta err+1
	sta l		; last bit length
	sta nxt

	ldy #0		; tworzymy kod FANO
lp	lda tre02,y	; if TRE02<>0 then SKP
	beq skp

	adw p err	; P=P+ERR

	ldx tre02,y
	cpx l
	beq sp
	stx l

	mva lmsk-1,x err
	mva hmsk-1,x err+1

sp	mwa p tmp

* wstaw do drzewa
*----------------
	lda tre01,y
	sta val
	ldx tre02,y
	sty skp_+1

	lda #0		; next link=0
_l1	dex
	tay
bit	asl tmp
	rol tmp+1
	bcs _1

_0	cpx #0
	bne _s1
	lda val
	sta (l0),y
	jmp skp_
_s1	lda (h0),y
	bne _l1
	inc nxt
	lda nxt
	sta (h0),y
	jmp _l1

_1	cpx #0
	bne _s2
	lda val
	sta (l1),y
	jmp skp_
_s2	lda (h1),y
	bne _l1
	inc nxt
	lda nxt
	sta (h1),y
	jmp _l1

skp_	ldy #0
skp	iny
	cpy mx
	bne lp
	rts

* SORT sortujemy match_len z HUFL+??
* i zapamietujemy stara kolejnosc
* wystepowania danych w TRE01

* VFAST
*------
sort	jsr cnibl

	lda #0
	ldy #15
c1	sta pom,y
	dey
	bpl c1
	sta md+1
	sta md_+1

	tay		; liczymy elementy
c2	ldx tre02,y
	inc pom,x
	iny
	cpy mx
	bne c2

	ldx #0		; pozycje elementow
l2_	ldy #0		; nie posortowanych
l2	txa		; do tablicy TRE01
	cmp tre02,y	; dla celow PCK
	bne s2
md_	sty tre01
	inc md_+1
s2	iny
	cpy mx
	bne l2
	inx
	cpx #16
	bne l2_

	ldx #0		; sortuje
l_	ldy pom,x
	beq s1
md	stx tre02
	inc md+1
	dey
	bne md
s1	inx
	cpx #16
	bne l_
	rts

cnibl	sta ld_bf+1	; zamiana na nible
	stx ld_bf+2	; do TRE02

	ldy #0
	ldx #0
ld_bf	lda $ffff,x
	pha		; starszy nibel
	lsr @
	lsr @
	lsr @
	lsr @
	sta tre02,y
	iny
	pla
	and #$f		; mlodszy nibel
	sta tre02,y
	inx
	iny
	cpy mx
	bne ld_bf
	rts

*-----
lmsk	dta l($8000),l($4000),l($2000)
	dta l($1000),l($800),l($400)
	dta l($200),l($100),l($80)
	dta l($40),l($20),l($10)
	dta l(8),l(4),l(2),l(1)

hmsk	dta h($8000),h($4000),h($2000)
	dta h($1000),h($800),h($400)
	dta h($200),h($100),h($80)
	dta h($40),h($20),h($10)
	dta h(8),h(4),h(2),h(1)

ratio	brk
lng	dta a(0)
lnght	dta a(0)

.endp

;--
	run run


/*
  XLPaint MAX v2.5 (30.07.2007)

- wersja ze zmiana kolorow co linie
- tablice z kolorami i jasnosciami musza miescic sie w obszarze strony pamieci
- Kolmask... - kombinacje bitow dla kolorow
- zmiana ekranow kolor Ekran10 <-> szarosci Ekran20 tablica TDL1 -> modyfikacja DL5Ek0, DL0Ek1

- pamiec obrazu i undo maja indetyczny mlodszy bajt = $B0 (szybsza procedura CopyEkr0)

- sprawdz fire itp

*/

*---------------------------------
* Interlace
* linie parzyste 0.2.4.6.....
* linie nieparzyste 1.3.5.7.9....
*---------------------------------


* XL-PAINT 1.9
* by  Stanley!
* poprawka dla 16col by TeBe
* kod okolo:	$2000-$5c00

*-----stale------

TRIG1	equ $d011
PORTA	equ $d300

XMax	equ 160		;rozmiar ekranu
YMax	equ 192


*-----tabele-----

_tjmp	equ $1f00	; tablica skokow

PMG	equ $5800		;$0800	$5800-$5FFF	pierwszy uzyty to pmg+$400 czyli mamy pamiec do $5c00
Bufor1	equ $6000		;$0780	$6000-$677F	bufor1 przechowuje wartosci jasnosci
Bufor2	equ $6780		;$0780	$6780-$6EFF	bufor2 przechowuje wartosci kolorow
DIREC	equ Bufor1		;$0300	oryginalnie bylo $0400-$06ff	bufor na katalog dyskietki

kol1	equ $6f00		;$C4	$6f00-$6fc3	kolory dla $d016
*.klawsk2=$6fc1		$6FC4-$70AF		
Ekran10 equ $70B0		;$1E00	$70B0-$8EAF\	ekran #1
Ekran11 equ $8000		;$0EB0	$8000-$8EAF/

AdYLo	equ $8F00		;$00C0	$8F00-$8FE7
*$c7			$8FE8-$90AF
;- $9000 - $90af  uzywane podczas wczytywania grafik
Ekran20	equ $90B0		;$1E00	$90B0-$AEAF\	ekran #2
Ekran21 equ $A000		;$0EB0	$A000-$AEAF/

AdYHi	equ $AF00		;$00C0	$AF00-$AFE7
*$c7			$AFE8-$B0AF
;- $b000 - $b0af Clin1...
Ek01	equ $B0B0		;$1E00	$B0B0-$CEAF	undo Ekran10
;kol0	equ $cf00	;$c4	kolory dla $d01a (wlasciwie tylko pierwszy bajt jest znaczacy)
TbMs1	equ $cf00


FONTY	equ $d800		;$0400	$d800-$dbff
*.FONT=$dc00		;$0400	$dc00-$dfff

TbMs2	equ $dc00
;jas0	equ $dc00	; jasnosci dla $d01a	(tylko pierwszy bajt jest znaczacy)
jas1	equ $dd00	; jasnosci dla $d016
jas2	equ $de00	; jasnosci dla $d017
jas3	equ $df00	; jasnosci dla $d018
;- $e000 bar...
NAG	equ $e000
Ek02	equ $E0B0		;$1E00	$E0B0-$FEAF	undo Ekran20

KEYASCII	equ $FEB0	;$feb0-$FFAF

DLL1	= $e400		; program #1 ANTIC-a dla ZOOM-a
DLL11	= $e800		; program #2 ANTIC-a dla ZOOM-a

DLAd1	= DLL1+$10
DLAd11	= DLL11+$10

*-----zerowa-----

	org $80

OldPMGY		.ds 1
OldPMGX		.ds 1
OldPMGY2	.ds 1
OldPMGX2	.ds 1
pom0_		.ds 1
pom1_		.ds 1
Xact		.ds 1
Yact		.ds 1
EndPt		.ds 1
Countr		.ds 1
Countr2		.ds 1
CrX0		.ds 1
CrY0		.ds 1
CrX		.ds 1
PWTxt4		.ds 1
PWTxt5		.ds 1
petla		.ds 1
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

CrY		.ds 2
POM		.ds 2
POM1		.ds 2
POM2		.ds 2
PomADR1 	.ds 2
PomADR2		.ds 2
ILE		.ds 2
CrF		.ds 2
CrFY		.ds 2
CrFYA		.ds 2
CrXY		.ds 2
rA		.ds 2
rX		.ds 2
rY		.ds 2

*-----------------------------
* dta a($FFFF),a($2E0),a($2E1),a(RUN)
* dta a(start),a(meta-1)
*-----------------------------

;---
	org $2000

xinit	jsr printf
	.he 9b
	.he 'XL-Paint 2.5MaX' 9b
	.he '---------------' 9b
	.he 'Press HELP for more info !' 9b
	.he 0

	rts

	.link 'stdio\printf.obx'

	ini	xinit

;	org $70b0
;	ins 'ob1.dat',0,40*192
;	org $90b0
;	ins 'ob2.dat',0,40*192

*------------------------
	org $6fc4
*------------------------
KlawSk2	equ *
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

KlawSk21 equ *
 dta b($08) ;cOpy
 dta b($25) ;Move
 dta b($0a) ;Paste

KlawSk0 equ *
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

KlawSk01 equ *
 dta b($4d) ;Sh+I
 dta b($4b) ;Sh+U
 dta b($78) ;Sh+F
 dta b($6c) ;Sh+Tab
 dta b($37) ;Sh+.	;normalna wysokosc kursora
 dta b($36) ;Sh+,	;podwojna wysokosc kursora
 dta b($0b) ;U
 dta b($11) ;HELP  
 dta b($0c) ;RETURN
 dta b($76) ;Sh+CLR
 dta b($74) ;Sh+DEL
 dta b($27) ;LOGO
 dta b(033) ;SPACE
 dta b(097) ;Shift+Space
 dta b(183) ;insert
 dta b($56) ;Sh+X
 dta b($4c) ;Sh+Return

KlawSk1 equ *
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

KlawSk3 equ *

*-----------------------------

KlawSk20 equ *
 dta a(WHFlip)	;H
 dta a(WVFlip)	;V
 dta a(WCmirr)	;C
 dta a(WRot90)	;R
 dta a(WLight)	;L
 dta a(WDark)	;D
 dta a(Wneg)	;N
 dta a(WBlur)	;B
 dta a(WSpill)	;S
 dta a(WEmbos)	;E
 dta a(WAnt)	;A
 dta a(W3d)	;F
 dta a(WShade)	;W
 dta a(WExch)	;X

 dta a(WCopy)	;O
 dta a(WMove)	;M
 dta a(WPaste)	;P

KlawSk00 equ *
 dta a(Point)	;P
 dta a(Spray)	;A
 dta a(CSpray)	;K
 dta a(Draw)	;D
 dta a(Line)	;L
 dta a(Lines)	;I
 dta a(Rays)	;Y
 dta a(Triang)	;T
 dta a(Square)	;R

KlawSk000 equ *
 dta a(Circle)	;C
 dta a(Fill)	;F
 dta a(Box)	;B
 dta a(Disc)	;S
 dta a(Object)	;O

*-------GOTO
KlawSk02 equ *
 dta a(INFO)		;Sh+I
 dta a(FUNC)		;Sh+U
 dta a(SetIO)		;Sh+F
 dta a(SetColor)	;Sh+Tab
 dta a(SetCurNorm)	;Sh+.
 dta a(SetCur2Y)	;Sh+,
 dta a(UNDO)		;U
 dta a(HELP)		;HELP  
 dta a(PutFire)		;RETURN
 dta a(CLSScreen)	;Sh+CLR
 dta a(CLSColor)	;Sh+DEL
 dta a(Zoom)		;LOGO
 dta a(NxCol)		;Space
 dta a(PrvCol)		;Shift+Space
 dta a(GetCol)		;Insert
 dta a(CursAd)		;Sh+X
 dta a(New_Col)		;Sh+Return

TbCur	dta a(DatPMG0),a(DatPMG4),a(DatPMG5),a(DatPMG6)

	.print '$6FC4..',*
	ert *>=$70b0

;--
	org $b000
;--
Clin1	equ *
	Dta $00,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00	;Clin2-odcien
	Dta $00,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00
	Dta $00,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00
	Dta $00,$00,$00,$55,$55,$aa,$aa,$fF,$FF,$00

Clin2	equ *
Clin3	equ *
	Dta $01,$00,$00,$00,$00,$00,$00,$00,$00,$40	;Clin1-kolor
	Dta $02,$55,$55,$55,$55,$55,$55,$55,$55,$80
	Dta $01,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$40
	Dta $01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$40

Clin4	equ *
	Dta $00,$00,$01,$11,$11,$22,$22,$23,$33,$33
	Dta $44,$44,$45,$55,$55,$66,$66,$67,$77,$77
	Dta $88,$88,$89,$99,$99,$AA,$AA,$AB,$BB,$BB
	Dta $CC,$CC,$CD,$DD,$DD,$EE,$EE,$EF,$FF,$FF

TDL2	dta a(Ekran11,Ekran21)

TDL4	dta a(DLL1,DLL11)
TDL5	dta a(DLL51,DLL52)
tdl_dll0 dta a(panel2,panel2+40)

tbar_wsk dta 2,12,22,32,42,52,62,72
thex	dta d'0123456789ABCDEF'

TDL1	dta a(Ekran10),a(Ekran20)
TDL1_	dta a(Ekran10),a(Ekran20)
	dta a(Ekran11),a(Ekran21)

kol0	brk	; !!! zmienne KOL0 i JAS0 nie moga znajdowac sie pod ROM-em !!!
jas0	brk

	.print '$B000..',*
	ert *>=$b0b0

;-------------
	org $2000

start	equ *

;----------------------------- 8-7
DLL0	dta b($c0),b($4e),a(panel2),d'.......',b($10)		;Ekran glowny
	Dta b($44),a(NAG),b($80)
DL0Ek1	dta b($4E),a(Ekran10)
	Dta d'................................'
	Dta d'................................'
	Dta d'.................................'
DL0Ek2	dta b($4E),a(Ekran11)
	Dta d'................................'
	Dta d'................................'
	Dta d'.............'
DL0Sk1	dta d'................'
dpanel	dta b($00)
	dta b($4E),a(Panel1)
	dta d'..........'
	dta b($4e),a(Panel1+40),b($4E),a(Panel1)
	dta b($41),a(DLL0)

*-------------------
DLL5	dta b($c0),b($4e),a(panel2),d'.......',b($10)		;Ekran z wyborem kolorow
	Dta b($44),a(NAG),b($80)
DL5Ek0	dta b($4E),a(Ekran10)
	Dta d'................................'
	Dta d'................................'
	Dta d'................................',b($00)
	Dta b($00)
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)	;4kolory
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($CE-$80),a(CLin3),b($00)
	Dta b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4)	;16 kolorow
	Dta b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4)
	Dta b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4),b($4f),a(CLin4)
	Dta b($4f),a(CLin4),b($4f),a(CLin4),b($CF-$80),a(CLin4),b($30),b($44),a(bar1),b($30)

	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)	;4jasnosci
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3),b($4e),a(CLin3)
	Dta b($4e),a(CLin3),b($4e),a(CLin3),b($CE-$80),a(CLin3)
DL5Sk1	dta b($01),a(DLL51)

DLL51	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1),b($E)
	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1),b($e)
	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1),b($E)
	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1)
	dta b($30),b($44),a(bar2)
	dta b($41),a(DLL5)
*---
DLL52	dta b($4E),a(CLin2),b($4E),a(CLin1),b($E),b($4E)
	Dta a(CLin1),b($E),b($4E),a(CLin1),b($E)
	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1),b($E)
	dta b($4E),a(CLin1),b($E),b($4E),a(CLin1),b($e)
	dta b($30),b($44),a(bar2)
	dta b($41),a(DLL5)

*-----------------------------
*- przelaczanie obrazow co 1frame
*-
DLIv0
;	STA $D40A
	ldy kol0

	ldx #4			; paleta kolorow

lp_

t1_	lda #0
	sta $d40a    ; jasn
	sta $d016
t2_	lda #0
	sta $d017
t3_	lda #0
	sta $d018
;t4_	lda #0
;	sta $d01a
	sty $d01a

t1	lda #0
	sta $d40a    ; kol
	sta $d016
t2	lda #0
	sta $d017
t3	lda #0
	sta $d018
;t4	lda #0
;	sta $d01a

	dex
	bne lp_

	sta $d40a

	ldx #4				;kolory czcionki - pasek menu
	mva defcol,x $d016,x-
	rpl

	mva	#0	z00m+1		; DLIV bez ZOOMa czyli normal

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

set_col	mwa	TDL1,X	DL5Ek0+1	; reszta wartosci
	mwa	TDL5,X	DL5Sk1+1

	mwa	tdl_dll0,x	dll5+2
	jmp	color

normal	mwa	TDL1,X	DL0Ek1+1	
	mwa	TDL2,X	DL0Ek2+1

	mwa	tdl_dll0,x	dll0+2	
	jmp	color

zoom_ON
	mwa	TDL4,X	$230	;obraz dla ZOOM'a	*1
	sta	z00m+1		;DLIV przelacz na ZOOM

color	ldx #0		;zmiana palet kolor->szarosc, szarosc->kolor

	lda color+1
	eor #1
	sta color+1
	beq _parz

z00m	lda #0
	beq *+8
	lda <dliv0z	; zoom
	ldx >dliv0z
	bne *+6
	lda <dliv0c	; ekran glowny
	ldx >dliv0c

	jmp quit

_parz	lda z00m+1
	beq *+8
	lda <dliv0z_
	ldx >dliv0z_
	bne *+6
	lda <dliv0c_
	ldx >dliv0c_

quit	sta vdli
	stx vdli+1

	jmp ExitDLI

*----
*- zmiana kolorow co linie		DLIST-A DLA EKRANU GLOWNEGO
*- linie parzyste
*-
dliv0c

	ldy kol0

lin1s	ldx #0

kk_	lda jas1,x
	sta $d40a    ; jasn
;	lda jas1,x
	sta $d016
	lda jas2,x
	sta $d017
	lda jas3,x
	sta $d018
;	lda jas0,x
	sty $d01a

	lda kol1,x
	sta $d40a    ; kol
;	lda kol1,x
	sta $d016
	lda kol2,x
	sta $d017
	lda kol3,x
	sta $d018
;	lda kol0,x
;	sta $d01a

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
dliv0c_

	ldy kol0

lin2s	ldx #1

nn_	lda kol1,x
	sta $d40a    ; kol
;	lda kol1,x
	sta $d016
	lda kol2,x
	sta $d017
	lda kol3,x
	sta $d018
;	lda kol0,x
	sty $d01a

	lda jas1,x
	sta $d40a    ; jasn
;	lda jas1,x
	sta $d016
	lda jas2,x
	sta $d017
	lda jas3,x
	sta $d018
;	lda jas0,x	
;	sta $d01a

	inx
	inx
lin2	cpx #192+1
	bne nn_

	lda tryb+1
	bne tr_setcolor

ex_dliv
	sta $d40a

	ldx #4				;kolory czcionki
	mva defcol,x $d016,x-
	rpl

	mwa	#dliv0	vdli

col4	lda #0
	eor #4
	sta col4+1
	tax

;	mva	kol,x	t4+1
	mva	kol+1,x	t1+1
	mva	kol+2,x	t2+1
	mva	kol+3,x	t3+1

;	mva	kol+4,x	t4_+1
	mva	kol+5,x	t1_+1
	mva	kol+6,x	t2_+1
	mva	kol+7,x	t3_+1

	jmp	ExitDLI

*-----------------------------   
* DLIV dla wybieranie z palety kolorow
* dzieli ekran na polowe
* w dolnej wybieranie kolorow

*--
r_dlv5	sta $d40a	;kolory palety - normal
	lda #0
	sta $d01a
	lda $2c8
	ldx $2c4

	sta $d40a
	sta $d01a
	stx $d016
	lda $2c5
	sta $d017
	lda $2c6
	sta $d018
	sta $d40a

	ldx #14
	sta $d40a
	dex
	bne *-4

	sta $d40a	;bar - 16 kolorow w poziomie
	lda #%11000001
	sta $d01b
	ldx NrCol
	bne *+4
	ldx #5
	lda $2c3,x
	and #$f
	sta $d01a

	ldx #15
	sta $d40a
	dex
	bne *-4

	sta $d40a
	lda #%00000001	;zaczynamy palete z odcieniami
	sta $d01b
	lda #0
	sta $d01a	;kolory czcionki bar1
	lda #2
	sta $d016
	lda #4
	sta $d017	
	lda #6
	sta $d018
;	lda #10
;	sta $d019

	sta $d40a

*--
flip	lda #4
	eor #4
	sta flip+1
	sta color3+1

color3	ldx	#0
	mva	kol	t4b+1
	mva	kol+1,x	t1b+1
	mva	kol+2,x	t2b+1
	mva	kol+3,x	t3b+1

	mva	kol+4	t4b_+1
	mva	kol+5,x	t1b_+1
	mva	kol+6,x	t2b_+1
	mva	kol+7,x	t3b_+1
*--
	ldx #4+8+4-2
	sta $d40a
	dex
	bne *-4

;	mva	jas	$d01a
	mva	jas+1	$d016
	mva	jas+2	$d017
	mva	jas+3	$d018

	ldx #15
	sta $d40a
	dex
	bne *-4	

	ldx #8
tt_
t1b_	lda #0
	sta $d40a    ; jasn
;t1b_	lda #100
	sta $d016
t2b_	lda #0
	sta $d017
t3b_	lda #0
	sta $d018
t4b_	lda #0
	sta $d01a

t1b	lda #0
	sta $d40a    ; kol
;t1b	lda #0
	sta $d016
t2b	lda #0
	sta $d017
t3b	lda #0
	sta $d018
t4b	lda #0
	sta $d01a

	dex
	bne tt_
	jmp ex_dliv

*-----------------------------
SetTabY	lda #$B0
	sta AdYLo
	ldy #0
	sty AdYHi
	sty Ust+1

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
	RTS

*-----------------------------
SetCol  sta Nrcol0
	tax
	
	ldy #5
sc_	lda KolMask1,x
	sta panel2+34,y
	sta panel2+34+80,y
	sta panel2+34+160,y
	sta panel2+34+240,y
	sta panel2+34+320,y
	sta kolor2

	lda KolMask2,x
	sta panel2+40+34,y
	sta panel2+40+34+80,y
	sta panel2+40+34+160,y
	sta panel2+40+34+240,y
	sta kolor1
	dey
	bpl sc_
	RTS

*-----------------------------	wskocz do menu na dole ekranu
PutFire lda mvp00+1
	cmp #6
	beq Func3
	lda PMGY
	cmp #Ymax
	bcc Func2
Func1	lda #14		;dolne menu
	sta wb+1
	jmp WbKol
;Func2J	jsr CLSpmg
;	sta Ust+1
Func2	jmp Point
Func3	lda #16		;gorne menu-kolory
	sta wb+1
	jmp WbKol

*-------------------
SetCurNorm  lda #0
	beq SetCur2Y_
;	sta WskCur
;	rts
*-------------------
SetCur2Y lda #1
SetCur2Y_ sta WskCur
	jsr clsPmg
	rts
*-------------------
CursAd  ldx #0
	inx
	txa
	and #3
	sta CursAd+1
	asl @
	tax
	lda TbCur,x	;tutaj adresy zmodyfikujemy i bedziemy mieli nowy ksztalt
	sta PPG11+1
	sta PPG21+1
	sta PPG41+1
	lda TbCur+1,x
	sta PPG11+2
	sta PPG21+2
	sta PPG41+2
_prvQ	RTS

*-------------------
PrvCol	ldx NrCol0	;zmniejsz kolor
	beq _prvQ
	dex
	jmp NxCol_
*-------------------
NxCol	ldx NrCol0	;zwieksz kolor
	cpx #15		;max color
	beq _prvQ
	inx
NxCol_	txa
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

SetColor
	jsr	wait
	mwa	#DLL5	$230
;	lda <DLL5
;	ldx >DLL5
;	sta $230
;	stx $231

	ldx #0
	ldy #96+2
	jsr setLin
	sty tryb+1
	sty _zoom_+1

	ldx #0
	stx col4+1
	stx color+1
	inx
	stx tim+1
	lda #4
	sta flip+1
*-
	lda pmgy	;sprawdz ktora polowa ekranu
	cmp #98
	bcc oki

	ldy	#3
	mva	tdl1_+4,y	TDL1,y-
	rpl

	ldx #98
	ldy #96+2+94+4
	jsr setLin
*-
oki	lda pmgy	;pozycja Y
	cmp #Ymax
	scc
	lda #Ymax-1
	sta set_palete+1

	lda sbar+1	; odswieza wartosci kolorow
	sta pom1
	lda #7
	sta sbar+1
poww	jsr sbar
	jsr sbar_0
	dec sbar+1
	bpl poww
	lda pom1
	sta sbar+1

	mwa	#DLIv0	vdli

;	lda #20
;	sta PMGX
;	lda #106
;	sta PMGY
	lda #0
	sta NrCol
	jsr clspmg

;SC_0	jsr PutWs1
;	jsr PutWs2
;	jsr PutWs3

sc_k	JSR Wait

	jsr sbar

	lda $2fc	; klawisze
	cmp #$ff
	beq _j1_

	cmp #6		; left
	bne _j2_
	ldx sbar+1
	beq _j1_
	jsr sbar_0
	dex
	stx sbar+1
	jsr sbar
	jmp _j1_	

_j2_	cmp #7		; right
	bne _j3_
	ldx sbar+1
	cpx #7
	beq _j1_
	jsr sbar_0
	inx
	stx sbar+1
	jsr sbar
	jmp _j1_	

_j3_	cmp #14		; up2
	bne _j4_
	ldx sbar+1
	ldy kol,x
	iny	
	iny
	tya
	sta kol,x
	jmp _j1_

_j4_	cmp #15		; down2
	bne _j5_
	ldx sbar+1
	ldy kol,x
	dey
	dey
	tya
	sta kol,x
	jmp _j1_

_j5_	cmp #$8e	; up16
	bne _j6_
	ldx sbar+1
	ldy kol,x
	tya
	clc
	adc #16
	sta kol,x
	jmp _j1_	

_j6_	cmp #$1c
	beq set_off

	cmp #$8f	; down16
	bne _j1_
	ldx sbar+1
	ldy kol,x
	tya
	sec
	sbc #16
	sta kol,x

_j1_	lda #$ff
	sta $2fc
	jsr set_palete
	jmp sc_k

set_off	equ *
;	jsr CLSWsk
	jsr wait
	ldy #3
	mva	tdl1_,y	TDL1,y-
	rpl

	ldx #0
	ldy #192
	jsr setLin
	jmp RetDL0	; wylaczenie wybierania kolorow

*---
sbar_0	ldx sbar+1	;usuwa aktualne podswietlenie
	ldy tbar_wsk,x
	lda #0
	sta bar1,y
	sta bar1+4,y
	rts

sbar	ldx #0		;pokazuje wskaznik dla koloru
	ldy tbar_wsk,x

	mva	#">"	bar1,y
	mva	#"<"	bar1+4,y

	lda kol,x
	pha
	and #$f
	tax
	lda thex,x
	sta bar1+3,y
	pla
	lsr @
	lsr @
	lsr @
	lsr @
	tax
	lda thex,x
	sta bar1+2,y
	rts

set_palete ldy #0
	lda tabk,y	;nr palety kolorow z pozycji Y kursora na ekranie
	sta akt_col+1

	ldy #0
akt	lda tabk,y
akt_col cmp #0
	bne dalej

	mva	kol	kol0	;,y
	mva	kol+1	kol1,y
	mva	kol+2	kol2,y
	mva	kol+3	kol3,y

	mva	jas	jas0	;,y
	mva	jas+1	jas1,y
	mva	jas+2	jas2,y
	mva	jas+3	jas3,y

dalej	iny
	cpy #193
	bne akt
	rts

*-------------------
WbKol	lda #1
	sta Fire+1
	lda PMGX
	ldy #0
	cmp T_Wbk1,y
	bcc *+5
	iny
	bne *-6
wb	cpy #14
	scc
	RTS
	lda mvp00+1
	cmp #6
	beq Wbkol2

	tya
	clc
	adc #KlawSk0-KlawSk2
	jmp Tk51
Wbkol2	tya
	jmp SetCol

T_Wbk1	dta b(009),b(017),b(025),b(033),b(041),b(049),b(057),b(065)
	Dta b(073),b(081),b(089),b(097),b(105),b(113)
	dta b(121),b(129)
	dta b(137),b(145),b(153),b(161),b(169),b(177)

;	RTS
*-------------------
SetInfo ldy #0		;pokazuje nazwe wybranej operacji
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
	mva	(pom),y	Nag+22,y-
	rpl

	jsr CLSCur
;	jsr CopyEkr0
	CLC
	RTS

*------------------

Koment1 equ *
 dta d'H-flip  '
 dta d'V-flip  '
 dta d'Centflip'
 dta d'Rotate  '
 dta d'Lighting'
 dta d'Darkness'
 dta d'Negative'
 dta d'Blur    '
 dta d'Spill   '
 dta d'Embos   '
 dta d'Antique '
 dta d'eFfect3d'
 dta d'shadoW  '
 dta d'eXch-col'

Koment2 equ *
 dta d'cOpy    '
 dta d'Move    '
 dta d'Paste   '

Koment3 equ *
 dta d'Point   '
 dta d'sprAy   '
 dta d'Kspray  '
 dta d'Draw    '
 dta d'Line    '
 dta d'lInes   '
 dta d'raYs    '
 dta d'Triangle'
 dta d'Rectangl'
 dta d'Circle  '
 dta d'Fill    '
 dta d'Box     '
 dta d'diSc    '
 dta d'Object  '

Koment4 equ *
 dta d' XL-Paint 2.5MaX '
 dta d' by Stanley/USG  '
 dta d' by TeBe/Madteam '
 dta d' date 09-08-2006 '

Koment5 equ *
 dta d'LOGO   - zoom   '
 dta d'0-9    - col 0-9'
 dta d'Sh 1-6 - col A-F'
 dta d'SPACE  - nxt col'
 dta d'Sh X   - chg cur'
 dta d'Sh .   - 2*Y cur'
 dta d'Sh ,   - 1*Y cur'
 dta d'Sh I   - info   '
 dta d'Sh F   - file   '
 dta d'Sh U   - func   '
 dta d'Sh Tab - chg pal'
 dta d'Sh Ret - new pal'
 dta d'Sh <   - CLS scr'
 dta d'Sh Del - CLS col'
 dta d'CtrShQ - EXIT   '

*---------------------------------------
_RUN	jsr SetTabY
	lda #0
	jsr SetCol
	JSR CLSScreen
	jsr CopyEkr0
	jsr clswsk
	jsr ClsPmg
	lda #$ff
	sta $2fc
	ldy #17
	jsr TK5
TK0
;	JSR Wait
;	jsr CLSPMG
	lda $d20f
	and #4
	beq TK1
WskSh	lda #0
	beq TK1
ShSk	jsr ShLine
TK1
;JSR CLSPMG
;	lda #0
;	sta $4d
	JSR PUTPMG
	lda fire+1	;XXX
;	jsr Fire
	bne Ruch
	jsr PutFire
Ruch	jsr Mouse
	sta Sts+1
	jsr JoyKey1
Sts	ora #0
	bne TK1
TK2	JSR KEY
	bcc TK0
	
	cmp #28
	bne skIp
Ust	lda #0		; undo on/off
	beq sk__
	jsr UNDO
sk__	jsr WndEx2
	lda #$60
	sta RtsJmp
	lda #0
	jsr TK5Sk
	lda #$4c
	sta RtsJmp
	lda #0
	sta WskSh+1
	sta Ust+1
	beq TK0
	
skIp	CMP #$ef ; dC		;Shift+CTRL+Q	-exit
	BEQ _END
	jsr TK00
	jmp TK0

;-----------------------

_END	JSR ROMON
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

TK22	ldy #KlawSk21-KlawSk2	;czy wybral funkcje
	cmp KlawSk2,y
	beq TK5
	iny
	cpy #KlawSk0-KlawSk2	;czy tez cos z Object (O,M,P)
	bcc TK22+2
	RTS
TK23	ldy #0
	cmp KlawSk2,y
	beq TK5
	iny
	cpy #KlawSk21-KlawSk2
	bcc TK23+2
	RTS

TK5	sty Hit+1
	cpy #KlawSk21-KlawSk2
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
	bcs *+4
	lda #1
	sta PtPMG1+1

	lda #0
TK5Sk	sta Point+1
	tya
RtsJmp	jmp SetInfo

TK6	tya
	asl @
	tay

	mwa	KlawSk20,y	SkWnd+1

	mwa	#Objw	Func2+1

	lda #0
	sta Objw+1
	tya
	jmp SetInfo

TK7	tya
	sec
	sbc #KlawSk01-KlawSk2
	asl @
	tay

	mwa	KlawSk02,y	TKSk+1

	bne TKSk

TK8	mwa	KlawSk1+2,y	TKSk+1

	lda KlawSk1+1,y
TKSk	jmp $ffff
*-----------------------------
;	rts

mvp00	lda #0		;wskocz do wyboru koloru - gorne menu
	cmp #6		;zanim wskoczysz do gory odczekaj 6 razy
	beq mvp01
	inc mvp00+1
	jmp MVP11
mvp01	lda <PMG+$41c-16
	sta kursor+1
	jsr CLSPMG
	jmp MVP11	

JoyKey1 lda $d300	;ruch joya
	and #$f
	cmp #$f
	bne JoyKy
	lda #0
	RTS
JoyKy	ldx PMGX
	ldy PMGY
	lsr @
	sta MVP11+1
	bcs MVP11	;w gore
	cpy #0
	beq mvp00
;	beq MVP11
	dey

MVP11	lda #0
	lsr @		;w dol
	sta MVP22+1
	bcs MVP22
	cpy #199
	seq
	iny
	lda mvp00+1	;jesli juz =0 to OK
	beq MVP22
	lda #0
	sta mvp00+1
	lda <PMG+$41c
	sta kursor+1
	jsr CLSPMG
	
MVP22	lda #0
	lsr @		;w lewo
	bcs MVP33
	cpx #0
	beq MVP33
	dex
MVP33	lsr @		;w prawo
	bcs MVP44
	cpx #159
	beq MVP44
	inx
MVP44	cpy #198
	bne MVP55
	jsr CLSPMG
	ldy #191
	bne MVP66
MVP55	cpy #192
	bcc MVP66
	cpy #199
	beq MVP66
	jsr CLSPMG
	ldy #199
MVP66	sty PMGY
	stx PMGX
	jsr wait
	lda #1
	RTS

*-------------------


*-------------------

RamkaTxt dta c'QRE|ZC',b($9b)

Ramki equ *
 Dta a(Koment3),b(25),b(08),b(08),b(14),b(0),b(0)	;pen
 Dta a(Koment5),b(05),b(08+40),b(16),b(19-4),b(0),b(0)	;help
 Dta a(Koment2),b(15),b(00),b(08),b(03),b(0),b(0)	;Ob
 Dta a(Koment4),b(01),b(00),b(16+1),b(04),b(0),b(0)	;Inf
 Dta a(Koment1),b(09),b(00),b(08),b(14),b(0),b(0)	;fUnc
 Dta a(IOTxt),b(04),b(00),b(09),b(05),b(0),b(0)		;File
 Dta a(Filename),b(09),b(32),b(20),b(01),b(0),b(0)	;filename
FilWnd dta a(Bufor2),b(13),b(48),b(12),b(00),b(0),b(0)

*-----------------------------
jascol	ldy #0
rrr	mva	jas	jas0	;,y
	mva	jas+1	jas1,y
	mva	jas+2	jas2,y
	mva	jas+3	jas3,y

	mva	kol	kol0	;,y
	mva	kol+1	kol1,y
	mva	kol+2	kol2,y
	mva	kol+3	kol3,y
	iny
	cpy #193
	bne rrr
	sty block+1
	rts

*---------------------------------------
*Procedura wlasnych przerwan
*---------------------------------------

ExitVBL
	pla
	tay
	pla
	tax
	pla
	rti

ExitDLI
	lda rA
	ldx rX
	ldy rY
	rti

*przerwania Display List------

NMIVEC	equ *	;$FFFA

	cld
	bit $d40f
	bpl vbl

	sta rA
	stx rX
	sty rY

	jmp dliv0
vdli	equ *-2

vbl	pha
	txa
	pha
	tya
	pha

	sta $d40f
	jmp MojaVBL

*przerwanie IRQ---------------

IRQVEC	equ *	;$FFFE

	pha
	txa
	pha

	lda $d20e
	and #$40
	beq KEYIRQ
	lda #0
	sta $d20e
	sta $11
	lda $10
	sta $d20e

	jmp NOKY11

KEYIRQ	lda #$bf
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

*przerwanie RESET-------------
RESETVEC rti

*----------------
WAIT	LDA:CMP:REQ $14
	RTS
*----------------

SkokiPZ0 equ *
	Dta a(PktZ0),a(PktZ1),a(PktZ2),a(PktZ3)
	Dta a(PktZ4),a(PktZ5),a(PktZ6),a(PktZ7)

*----------------

IOTxt equ *
	dta d'LOAD FILE'
	dta d'SAVE .XLP'
	dta d'SAVE .RAW'
	dta d'SAVE .MIC'
	dta d'SAVE .MAX'


Filename dta d'D1:*.*              '
Plik1	dta d'D1:*.*              ',b($DB)

LFTxt	dta c'XLPBCM'

AktWyb	:2 brk
AKT_P1	brk

Dana10	:3 brk

BFSAV	brk

*----------------


*-----------------------------
*Moja procedura VBlank

MojaVBL inc $14		;zegar
	sne
	inc $13

*przepisanie rejestrow

	mva	#$00	$2c8

	ldx	#8		;kolory
	mva	$2c0,x	$d012,x-
	rpl

	mwa	$230	$d402	; pamiec ekranu

	mva	$22f	$d400	; ekran
	mva	$26f	$d01b	; pmg
	mva	$2f4	$d409	; fnt

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
no_	cpx #Ymax
	scc
	ldx #191
	lda kol0	;,x
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

	mva	jas0	jas
	mva	jas1,x	jas+1
	mva	jas2,x	jas+2
	mva	jas3,x	jas+3

_skip

;Firevbl
	lda Fire+1
	beq fs
	lda $d010
	and $d011
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
* wypelnia ekran zadanym kolorem
*-
CLSScreen
	jsr CopyEkr0

	mwa	#Ekran10	POM1
	mwa	#Ekran20	POM2

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

	ldy #0		; czyscimy tabk
	tya
_cl	sta tabk,y
	iny
	cpy #193
	bne _cl

	RTS
*-----------------------------
CLSColor
	jsr CopyEkr0

	ldx PMGX
	ldy PMGY
	jsr Locate
	sta NrCol
	
CLC0	ldy #0
	sty YAct
CLC1	ldx #0		;przegladamy 160 pixli w poziomie
	stx XAct
	ldx XAct
	ldy YAct
	jsr Locate
	cmp NrCol
	bne CLC2
	
	ldx NrCol0
	lda YAct
	lsr @
	bcs _nie
_tak	lda KolMask2,x
	ldy KolMask1,x
	ldx XAct
	jsr Plot_2
	jmp CLC2
_nie	lda KolMask1,x
	ldy KolMask2,x
	ldx XAct
	jsr Plot_2

CLC2	ldx XAct
	inx
	cpx #Xmax
	bne CLC1+2
;	inc YAct
;CLC3	ldx #0		;drugi obraz 160 pixli w poziomie
;	stx XAct
;	ldx XAct
;	ldy YAct
;	jsr Locate
;	cmp NrCol
;	bne CLC4

;	ldx NrCol0
	
;	ldy KolMask1,x
;	lda KolMask2,x
;	ldx XAct
;	jsr Plot_2
;CLC4	ldx XAct
;	inx
;	cpx #XMax
;	bne CLC3+2

	ldy YAct
	iny
	cpy #Ymax
	bcc CLC0+2
	RTS

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
LInp	lda $358	;czy = 16004 ?
	cmp #$84
	bne null
	lda $359
	cmp #$3e
	bne null

	mwa	#Ekran10+8000+$1e00	PomADR1
	mwa	#Ekran20+$1e00		PomADR2

	mva	#0	block+1

	ldy #3
LInp0	lda Ekran10+16000,y
	sta kol,y
	sta jas,y
	dey
	bpl LInp0

	jsr jascol

	ldx #$3c+1
LInp1_	ldy #$7F
	mva	(pomAdr1),y	(pomAdr2),y-
	rpl

	lda pomAdr1
	sec
	sbc <$80
	sta pomAdr1
	scs
	dec pomAdr1+1

	lda pomAdr2
	sec
	sbc <$80
	sta pomAdr2
	scs
	dec pomAdr2+1

	dex
	bne LInp1_
	rts
null	jmp LFErr
*--

LMic	lda $359	;czy = 7684 ?
	cmp #$1e
	bne LInp
	lda $358
	cmp #5
;	bne LInp
	bcs LInp
	
ladujMIC
	mva	#0	block+1

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

	ldx #$1e		;przepisz Ekran1 do Ekran2 jesli plik=192*40+4
	ldy #0
Lmic1	mva:rne	(pomAdr1),y	(pomAdr2),y+

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
	cmp LFTxt
	bne LMic
	jsr Read1
	cmp LFTxt+1
	bne LMic
	jsr Read1
	cmp LFTxt+2
	bne LMic
	jsr Read1
	cmp LFTxt+3	;load BMP
	beq LBMP
	cmp LFTxt+4	;load XLP
	beq LCrunch
	cmp LFTxt+5
	beq _LCrunchM	;load MAX
	jmp LMic

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

	ldx <Ek01	; puszczamy w maliny :)
	ldy >Ek01	; tylko pierwszy bajt nas interesuje
	sty Ust+1	; blokada UNDO
	jsr read2
	mva Ek01 kol0
	
	ldx <kol1
	ldy >kol1
	jsr read2
	ldx <kol2
	ldy >kol2
	jsr read2
	ldx <kol3
	ldy >kol3
	jsr read2
	
	ldx <Ek01	; puszczamy w maliny :)
	ldy >Ek01	; tylko pierwszy bajt nas interesuje
	jsr read2
	mva Ek01 jas0

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
LCR1	LDA PomADR1
	STA PUT1+1
	LDA PomADR1+1
	STA PUT1+2

;	LDA PomADR2
;	CLC
;	ADC #40
;	STA PUT2+1
;	LDA PomADR2+1
;	ADC #0
;	STA PUT2+2

	adw PomADR2 #40 PUT2+1

	LDA #Ymax
	STA WYS
LCR2	JSR Decrunch1
	LDA WYS
	BNE LCR2
	LDA PomADR2
	STA PUT1+1
	LDA PomADR2+1
	STA PUT1+2

;	LDA PomADR1
;	CLC
;	ADC #40
;	STA PUT2+1
;	LDA PomADR1+1
;	ADC #0
;	STA PUT2+2

	adw PomADR1 #40 PUT2+1

	LDA #Ymax
	STA WYS
LCR3	JSR Decrunch1
	LDA WYS
	BNE LCR3
	INC PomADR1
	BNE *+4
	INC PomADR1+1
	INC PomADR2
	BNE *+4
	INC PomADR2+1
	DEC SZER
	LDA SZER
	BNE LCR1
	RTS

*-------------------
Decrunch1	LDA GDZIE
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
	BNE *+4
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
	BNE *+4
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
;	INC Read1+1
;	BNE *+5
;	INC Read1+2

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

;	LDA PUT1+1
;	CLC
;	ADC #80
;	STA PUT1+1
;	BCC *+5
;	INC PUT1+2

	adw PUT1+1 #80

	RTS

PUT2	STX $ffff

;	LDA PUT2+1
;	CLC
;	ADC #80
;	STA PUT2+1
;	BCC *+5
;	INC PUT2+2

	adw PUT2+1 #80

	RTS

*-----------------------------------------------------------
SaveMIC  LDA <plik1
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
SaveBMP  LDA <plik1
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
	lda jas0	;,y
	sta bufor1,y
	lda jas1,y
	sta bufor1+192,y
	lda jas2,y
	sta bufor1+192*2,y
	lda jas3,y
	sta bufor1+192*3,y

	lda kol0	;,y
	sta bufor2,y
	lda kol1,y
	sta bufor2+192,y
	lda kol2,y
	sta bufor2+192*2,y
	lda kol3,y
	sta bufor2+192*3,y
	
	iny
	cpy #192
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

	lda <192*4
	sta savL+1
	lda >192*4
	sta savH+1

	lda <bufor2
	ldx >bufor2
	jsr write2
;	lda <kol0
;	ldx >kol0
;	jsr write2
;	lda <kol1
;	ldx >kol1
;	jsr write2
;	lda <kol2
;	ldx >kol2
;	jsr write2
;	lda <kol3
;	ldx >kol3
;	jsr write2

	lda <bufor1
	ldx >bufor1
	jsr write2
;	lda <bufor1+$100
;	ldx >bufor1+$100
;	jsr write2
;	lda <bufor1+$200
;	ldx >bufor1+$200
;	jsr write2
;	lda <bufor1+$300
;	ldx >bufor1+$300
;	jsr write2

	lda <192
	sta savL+1
	lda >192
	sta savH+1

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
	mwa #Bufor1 BUFS+1
;	LDA <Bufor1
;	STA BUFS+1
;	LDA >Bufor1
;	STA BUFS+2
	LDA #40
	STA SZER
CP1	LDA PomADR1
	STA GET1+1
	LDA PomADR1+1
	STA GET1+2

;	LDA PomADR2
;	CLC
;	ADC #40
;	STA GET2+1
;	LDA PomADR2+1
;	ADC #0
;	STA GET2+2

	adw PomADR2 #40 GET2+1

	LDA #Ymax
	STA WYS
CP2	JSR GET1
	JSR COMP
	JSR GET2
	BCS CP3
	JSR COMP
	JMP CP2
CP3	JSR COMP
	LDA PomADR2
	STA GET1+1
	LDA PomADR2+1
	STA GET1+2

;	LDA PomADR1
;	CLC
;	ADC #40
;	STA GET2+1
;	LDA PomADR1+1
;	ADC #0
;	STA GET2+2

	adw PomADR1 #40 GET2+1

	LDA #Ymax
	STA WYS
CP4	JSR GET1
	JSR COMP
	JSR GET2
	BCS CP5
	JSR COMP
	JMP CP4
CP5	JSR COMP
	INC PomADR1
	BNE *+4
	INC PomADR1+1
	INC PomADR2
	BNE *+4
	INC PomADR2+1
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
	INC ILE
	BNE *+4
	INC ILE+1
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

SNIE_1 LDA BYT
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
	INC ILE
	BNE *+4
	INC ILE+1
	RTS

NIE__2 JSR SV_NO
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
	INC ILE
	BNE *+4
	INC ILE+1
	RTS

TAK__2 LDA BYT
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

;	LDA GET1+1
;	CLC
;	ADC #80
;	STA GET1+1
;	BCC *+5
;	INC GET1+2

	adw GET1+1 #80

	DEC WYS
	RTS

GET2	LDX $ffff

;	LDA GET2+1
;	CLC
;	ADC #80
;	STA GET2+1
;	BCC *+5
;	INC GET2+2

	adw GET2+1 #80

	DEC WYS
	LDA WYS
	BNE *+4
	SEC
	RTS
	CLC
	RTS
*-------------------
Write1  STX BFSAV
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
savL	LDA #192
savH	LDX #0
	STA $358
	STX $359
	LDA #11
	STA $352
	LDX #$10
	JSR $E456
	RTS

*-------------------
BUFS	STA Bufor1
;	INC BUFS+1
;	BNE *+5
;	INC BUFS+2

	INW BUFS+1
	RTS

SV_NO
;	LDA ILE
;	SEC
;	SBC #1
;	STA ILE
;	LDA ILE+1
;	SBC #0
;	STA ILE+1

	DEW ILE

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

SN2	mwa #Bufor1 SN3+1
;	LDA <Bufor1
;	STA SN3+1
;	LDA >Bufor1
;	STA SN3+2

SN3	LDX Bufor1
	JSR Write1
;	INC SN3+1
;	BNE *+5
;	INC SN3+2

	INW SN3+1

	LDA SN3+1
	CMP BUFS+1
	BNE SN3
	LDA SN3+2
	CMP BUFS+2
	BNE SN3

	mwa #Bufor1 BUFS+1
;	LDA <Bufor1
;	STA BUFS+1
;	LDA >Bufor1
;	STA BUFS+2
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
	mwa	#Bufor1	BUFS+1
	RTS

*-----------------------------
SetPomADR
	mwa	#Ekran10	PomADR1
	mwa	#Ekran20	PomADR2
	RTS

SetPomADR2
	mwa	#Ek01	PomADR1
	mwa	#Ek02	PomADR2
	RTS

*-----------------------------------------------------------
PUTZOOM	jsr SetPomAdr
	jsr AdrZm1
*-------
	mwa #Bufor1 PUTZ1+1
	mwa #Bufor2 PUTZ2+1

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
	beq *+4
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

*--------------
AddPom
;	LDA POM1
;	CLC
;	ADC #40
;	STA POM1
;	SCC
;	INC POM1+1

	adw POM1 #40

;	LDA POM2
;	CLC
;	ADC #40
;	STA POM2
;	SCC
;	INC POM2+1

	adw POM2 #40
	RTS
*--------------
AdrZm1 equ *		;Oblicz adresy lewego gornego rogu ekranu
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
AddPUTZ
;	LDA PUTZ1+1
;	CLC
;	ADC #39
;	STA PUTZ1+1
;	SCC
;	INC PUTZ1+2

	adw PUTZ1+1 #39

;	LDA PUTZ2+1
;	CLC
;	ADC #39
;	STA PUTZ2+1
;	SCC
;	INC PUTZ2+2

	adw PUTZ2+1 #39
	RTS

*--------------
PUTZ1	STA	$FFFF
	INW	PUTZ1+1
	RTS

PUTZ2	STA	$FFFF
	INW	PUTZ2+1
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
P0Z0	lda	div6
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jsr PUTZ1
P1Z0	lda	div6
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jmp PUTZ2

P0Z1	lda	div4
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jsr PUTZ1
P1Z1	lda 	div4
;	lsr @
;	lsr @
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jmp PUTZ2

P0Z2	lda	div2
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jsr PUTZ1
P1Z2	lda	div2
;	lsr @
;	lsr @
;	tax
;	lda KolMask0,x
	jmp PUTZ2

P0Z3	ldx #0
	lda KolMask0,x
	jsr PUTZ1
P1Z3	ldx #0
	lda KolMask0,x
	jmp PUTZ2

*-----------------------------
new_col	lda pmgy
	beq new_
	cmp #192
	bcc *+4
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
ZOOM	lda #$0
	sta WskZoom
;	lda #$ff
;	sta TK0+1
	
	lda PMGY
	cmp #192
	bcc Zommm
	ldy #191
	sty PMGY

Zommm	lda PMGX
	sec
	sbc #20
	bcs *+4
	lda #0
	cmp #120
	bcc *+4
	lda #120
	sta SZER
	lda PMGX
	sec
	sbc SZER
	sta PMGX

	lda PMGY
	and #%11111110	;xxx
	sec
	sbc #24
	bcs *+4
	lda #0
	cmp #144
	bcc *+4
	lda #144
	sta WYS
	lda PMGY
	sec
	sbc WYS
	sta PMGY

	jsr CLSPMG
	JSR SETDLZ
	JSR Zom0

	lda WYS
	clc
	adc PMGY
	sta PMGY
	lda SZER
	clc
	adc PMGX
	sta PMGX
	lda #$80
	sta WskZoom
	RTS

NxColJmp jsr NxCol
	jmp oldKey
PrvColJmp jsr PrvCol
	jmp oldKey
CurAdJmp jsr CursAd
	jmp oldKey
;GetColJmp jsr GetCol
;	jmp oldKey
*-----------------------------
Zom0	jsr wait


	ldx #0
	stx tim+1
	stx col4+1
	stx color+1	
	inx
	stx _zoom_+1
	
	JSR	PUTZOOM

Zom	jsr PutPMG

	ldx wys
	stx lz1+1
	inx
	stx lz2+1
	txa
	clc
	adc #47
	tax
	stx lz1m+1
	inx
	stx lz2m+1

*-------------------
Zom1	jsr Fire
	bne Zom11
	jsr wait
	jsr Plot4
Zom11	JSR KEY
	bcc Zom

	sta oldKey+1
	cmp #33			;Space pod Zoomem
	beq NxColJmp
	cmp #97			;Shift+Space
	beq PrvColJmp
	cmp #$56		;Shift+X pod Zoomem
	beq CurAdJmp
;	cmp #183		;Insert pod Zoomem
;	beq GetColJmp

oldKey	lda #0	
skp	cmp #12			;return
	bne Zom2
	jsr wait
	jsr Plot4
	jmp Zom
Zom2	CMP #$6			;w lewo
	BNE Zom3
	ldx PMGX
	beq Zom21
	dex
	stx PMGX
	jsr wait
	jsr wait
	jmp Zom
Zom21	LDX SZER
	DEX
	BMI Zom1
	STX SZER
	JSR ZmLeft
	jmp Zom

Zom3	CMP #$7			;w prawo
	BNE Zom4
	ldx PMGX
	cpx #39
	beq Zom31
	inx
	stx PMGX
	jsr wait
	jsr wait
	jmp Zom
Zom31	LDX SZER
	CPX #120
	BEQ Zom1
	INX
	STX SZER
	JSR ZmRight
	jmp Zom

Zom4	CMP #$E
	BNE Zom5
	ldx PMGY
	beq Zom41
	dex
	stx PMGY
	jsr wait
	jsr wait
	jmp Zom
Zom41	LDY WYS
	BEQ RtZom1
	DEY
	STY WYS
	JSR ZmUp

	ldy wys		;xxx
	dey
	STY WYS
	JSR ZmUp

	jmp Zom

Zom5	CMP #$F
	BNE Zom6
	ldx PMGY
	cpx #47
	bcs Zom51
	inx
	stx PMGY
	jsr wait
	jsr wait
	jmp Zom
Zom51	LDY WYS
	CPY #144
	BEQ RtZom1
	INY
	STY WYS
	JSR ZmDown

	ldy wys		;xxx
	INY
	STY WYS
	JSR ZmDown

	jmp Zom
RtZom1	jmp Zom1
Zom6	CMP #$27
	BEQ RetZm
	jsr TK11
	jmp Zom1


RetZm	lda #0		;wyjscie z ZOOMa
	sta $d000
RetDl0	jsr wait
	jsr CLSPMG

	mwa	#DLL0	$230
	mwa	#DLIv0	vdli

	ldx	#0	;x=0
	stx	_zoom_+1
	stx	color+1
	stx	col4+1

	stx	tryb+1

	inx		;x=1
	stx	tim+1

	ldx	#192	;x=192
	stx	lin1+1
	inx		;x=193
	stx	lin2+1

	jsr CopyEkr0

	jmp	Wait

*-----------------------------
ZmLeft	mwa	#Bufor1+$700	ZmL2+1
	mwa	#Bufor1+$701	ZmL3+1

	mwa	#Bufor2+$700	ZmL4+1
	mwa	#Bufor2+$701	ZmL5+1

	LDX #8
	LDY #$7E
ZmL2	lda $ffff,y
ZmL3	sta $ffff,y
ZmL4	lda $ffff,y
ZmL5	sta $ffff,y
	dey
	cpy #$FF
	bne ZmL2
	dec ZmL2+2
	dec ZmL3+2
	dec ZmL4+2
	dec ZmL5+2
	dex
	bne ZmL2

	jsr	AdrZm1

	mwa	#Bufor1	PUTZ1+1
	mwa	#Bufor2	PUTZ2+1

	lda #48
	sta BYT

	lda WYS
	lsr @
	bcs ZmL8

ZmL7	LDA #0
	STA POM
	jsr PutLZ0
	jsr AddPom
	jsr AddPUTZ
	DEC BYT
	BEQ ZmL9
ZmL8	LDA #0
	STA POM
	jsr PutLZ1
	jsr AddPom
	jsr AddPUTZ
	DEC BYT
	BNE ZmL7
ZmL9	RTS

*-----------------------------
ZmRight	mwa	#Bufor1-$7F	ZmR2+1
	mwa	#Bufor1-$80	ZmR3+1

	mwa	#Bufor2-$7F	ZmR4+1
	mwa	#Bufor2-$80	ZmR5+1

	LDX #8
	LDY #$80
ZmR2	lda $ffff,y
ZmR3	sta $ffff,y
ZmR4	lda $ffff,y
ZmR5	sta $ffff,y
	iny
	bne ZmR2
	inc ZmR2+2
	inc ZmR3+2
	inc ZmR4+2
	inc ZmR5+2
	dex
	bne ZmR2

	jsr AdrZm1

	mwa	#Bufor1+39	PUTZ1+1
	mwa	#Bufor2+39	PUTZ2+1
	
	ldx #0
	lda WYS
	lsr @
	scs
	ldx #8
	stx PLZ22+1

	LDA #48
	STA BYT
ZmR7	lda PLZ22+1
	eor #8
	tax
	jsr PutLZ2
	jsr AddPom
	jsr AddPUTZ
	DEC BYT
	BNE ZmR7
	RTS

*-----------------------------
ZmDown	mwa	#Bufor1-$80	ZmD2+1
	mwa	#Bufor1-$A8	ZmD3+1

	mwa	#Bufor2-$80	ZmD4+1
	mwa	#Bufor2-$A8	ZmD5+1

	LDX #8
	LDY #$A8
ZmD2	lda $ffff,y
ZmD3	sta $ffff,y
ZmD4	lda $ffff,y
ZmD5	sta $ffff,y
	iny
	bne ZmD2
	inc ZmD2+2
	inc ZmD3+2
	inc ZmD4+2
	inc ZmD5+2
	dex
	bne ZmD2

	jsr AdrZm1

;	LDA POM1
;	CLC
;	ADC <1880
;	STA POM1
;	LDA POM1+1
;	ADC >1880
;	STA POM1+1

	adw POM1 #1880

;	LDA POM2
;	CLC
;	ADC <1880
;	STA POM2
;	LDA POM2+1
;	ADC >1880
;	STA POM2+1

	adw POM2 #1880

	mwa	#Bufor1+1880	PUTZ1+1
	mwa	#Bufor2+1880	PUTZ2+1

	lda #39
	sta pom
	lda WYS
	lsr @
	bcc ZmD7
	jmp PutLZ0
ZmD7	jmp PutLZ1

*-----------------------------
ZmUp	mwa	#Bufor1+$700	ZmU2+1
	mwa	#Bufor1+$728	ZmU3+1

	mwa	#Bufor2+$700	ZmU4+1
	mwa	#Bufor2+$728	ZmU5+1	

	LDX #8
	LDY #$57
ZmU2	lda $ffff,y
ZmU3	sta $ffff,y
ZmU4	lda $ffff,y
ZmU5	sta $ffff,y
	dey
	cpy #$ff
	bne ZmU2
	dec ZmU2+2
	dec ZmU3+2
	dec ZmU4+2
	dec ZmU5+2
	dex
	bne ZmU2

	jsr AdrZm1

	mwa	#Bufor1	PUTZ1+1
	mwa	#Bufor2	PUTZ2+1

	lda #39
	sta pom
	lda WYS
	lsr @
	bcs ZmU7
	jmp PutLZ0
ZmU7	jmp PutLZ1

*-------------------
SetDlZ
	mwa	#DLL1	Pom1
	mwa	#DLL11	Pom2
				; tworzymy programy ANTIC-a dla ZOOM-a w obszarze wykorzystywanym przez UNDO
	ldy	#$0f
_cp	mva	DLL0,y	(Pom1),y
	sta	(Pom2),y
	dey
	bpl	_cp

	mwa	#panel2+40	DLL1+2
	mwa	#panel2		DLL11+2

	lda	#$10
	jsr	PutA3Z

	ldx	#192
_lp
	ldy	#$00
	lda	#$4e
	sta	(Pom1),y
	sta	(Pom2),y
	tya
	iny
	sta	(Pom1),y
	sta	(Pom2),y
	iny
	sta	(Pom1),y
	sta	(Pom2),y

	lda	#3
	jsr	PutA3Z
	dex
	bne	_lp

	ldy	#0
	lda	#1
	sta	(Pom1),y
	sta	(Pom2),y

	iny
	lda	<dpanel+1
	sta	(Pom1),y
	sta	(Pom2),y

	iny
	lda	>dpanel+1
	sta	(Pom1),y
	sta	(Pom2),y

/*	

	ldy	#20
_cp2	mva	dpanel,y	(Pom1),y
	sta	(Pom2),y
	dey
	bpl	_cp2

	ldy	#21
	mva	<DLL1	(Pom1),y
	mva	<DLL11	(Pom2),y
	iny
	mva	>DLL1	(Pom1),y
	mva	>DLL11	(Pom2),y
*/

	mwa	#Bufor1	PomADR1
	mwa	#Bufor2	PomADR2
	mwa	#DLAd1	Pom1
	mwa	#DLAd11	Pom2

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

	lda #3
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

	lda #3

PutA3Z	PHA
	ADD Pom1
	STA Pom1
	SCC
	INC Pom1+1

	PLA
	ADD Pom2
	STA Pom2
	SCC
	INC Pom2+1
	RTS

*-------------------
DODPAD1
;	LDA PomADR1
;	CLC
;	ADC #40
;	STA PomADR1
;	scc
;	INC PomADR1+1

	adw PomADR1 #40

;	LDA PomADR2
;	CLC
;	ADC #40
;	STA PomADR2
;	scc
;	INC PomADR2+1

	adw PomADR2 #40
	RTS

*---------------------------------------
czyta	ldy #19
przep	mva	Filename,y	Plik1,y-
	rpl

	mva	#1	Plikow

	jmp GetPlk2

DIRECTORY
	JSR CopyEkr0
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
	bcc *+4
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
	SEQ
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

;	lda POM1
;	clc
;	adc #11
;	sta POM1
;	scc
;	inc POM1+1

	adw POM1 #11

;	lda POM2
;	clc
;	adc #11
;	sta POM2
;	scc
;	inc POM2+1

	adw POM2 #11

	ldy #0
	lda (POM2),y
	jsr AdPOM2
	CMP #$9B	;return(end)
	BNE *-7
	BEQ Dire2

*-----------
AdPOM2	inc POM2
	bne *+4
	inc POM2+1
	RTS
*-----------
AdPOM1	INC POM1
	BNE *+4
	INC POM1+1
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

;	LDA POM1
;	CLC
;	ADC #12
;	STA POM1
;	SCC
;	INC POM1+1

	adw POM1 #12

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
MAX_N1 brk
POZ_N1 brk
NR_WND brk

PobNap	STA NR_WND
	STX MAX_N1
	LDA <Filename
	STA POM1
	LDA >Filename
	STA POM1+1
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
	LDA <Filename
	STA POM1
	LDA >Filename
	STA POM1+1
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
	SNE
	RTS
	CMP #$9B		;RETURN
	BNE Wyb11

	lda AktWyb
	clc
	adc AktWyb+1
	tax
	lda #0
	RTS

UstWskaz  ldx AktWyb+1
	LDA <DIREC
	STA FilWnd
	LDA >DIREC
	STA FilWnd+1
UstWs1	dex
	spl
	RTS

;	LDA FilWnd
;	clc
;	adc #12
;	sta FilWnd
;	scc
;	inc FilWnd+1

	adw FilWnd #12

	jmp UstWs1

*-----------------------------
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
	LDA:CMP:REQ $14

GK_1	LDA $D300
	AND #$F
	CMP #$F
	BNE GK_J
	LDA $2FC
	CMP #$FF
	BNE GK_2
	JSR FIRE
	BNE GK_1
	JSR:REQ FIRE
	LDA #$9B
	RTS
GK_2	TAY
	LDA #7
	STA $D01F
	LDA KEYASCII,Y ;ASCII
	RTS
GK_J	LDY:CPY:REQ $14
	LDY:CPY:REQ $14
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
ICOD_ASCI0
	STA POM1	;zamienia z d'' na c''
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
IC_AS	CMP #$80
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
	BCC *+4
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
AS_IC	CMP #$80
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
	BCC *+4
	ORA #$80
	RTS
*--------------
Plikow	brk

*-----------------------------
CLSPMG	ldy #0
	tya
	sta:rne PMG+$400,y+
	RTS

*-----------------------------
PPG41	lda DatPMG0,x
	sta PMG+$410,y
	iny
	rts
;---	
PutPMG	lda WskZoom
	bmi PtPMG1

PtPMG4	lda PMGY	;kursor w ZOOM'ie
	asl @
	asl @
	tay
	ldx #8
Pt4	:4 jsr PPG41

;	lda DatPMG0,x
;	sta PMG+$410,y
;	iny
;	lda DatPMG0,x
;	sta PMG+$410,y
;	iny
;	lda DatPMG0,x
;	sta PMG+$410,y
;	iny
;	lda DatPMG0,x
;	sta PMG+$410,y
;	iny
	dex
	bpl Pt4
	
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

PtPMG2  ldy PMGY	;podwojna wysokosc
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

;PutCur2  ldx #8
;PCr2	lda DatPMG0,x
;	sta PMG+$61C,y
;	iny
;	dex
;	bpl PCr2
;	lda #0
;	sta $d00A
;	lda #161
;	sta $d002
;	RTS

pmgR	lda DatPMG2,x
	sta PMG+$51C,y
	lda DatPMG3,x
	sta PMG+$71C,y
	iny
	rts

PMGRamka  ldy PMGY
	ldx #8
PPR1	jsr pmgR
;	lda DatPMG2,x
;	sta PMG+$51C,y
;	lda DatPMG3,x
;	sta PMG+$71C,y
;	iny
	dex
	bpl PPR1
	ldy OldPMGY
	ldx #0
PPR2	jsr pmgR
;	lda DatPMG2,x
;	sta PMG+$51C,y
;	lda DatPMG3,x
;	sta PMG+$71C,y
;	iny
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

DatPMG0 equ *
 dta b(%00000000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00101000)
 dta b(%11000110)
 dta b(%00101000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00000000)

DatPMG1 equ *
 dta b(%00000000)
 dta b(%00010000)
 dta b(%00110000)
 dta b(%01101000)
 dta b(%01001000)
 dta b(%01000100)
 dta b(%00000100)
 dta b(%00000010)
 dta b(%00000000)

DatPMG2 equ *
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00011110)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)

DatPMG3 equ *
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00000000)
 dta b(%11110000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)

DatPMG4 equ *
 dta b(%00000000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%11101110)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00000000)

DatPMG5 equ *
 dta b(%00000000)
 dta b(%00000000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00101000)
 dta b(%00010000)
 dta b(%00010000)
 dta b(%00000000)
 dta b(%00000000)

DatPMG6 equ *
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
WPlot	stx WP2+1
	tax
	jsr AdrPt
	tya
	cmp #Ymax
	scc
	RTS
	lsr @
	bcs NieWP
	ldy kolmask1,x
	lda kolmask2,x
	jmp WP2
NieWP	lda kolmask1,x
	ldy kolmask2,x
WP2	ldx #0
	jmp Plot_2
	
GPlot	LDX PMGX
	LDY PMGY
Plot	jsr AdrPt
	TYA
	cmp #Ymax
	scc
	RTS
	lsr @
	bcs Niepa
	lda Kolor1
	ldy Kolor2
	jmp Plot_2
Niepa	lda Kolor2
	ldy Kolor1

Plot_2  sta PlKol1+1
	sty PlKol2+1
;	TXA
	cpx #Xmax
	scc
	RTS
	ldy pdiv2,x		; y=x/4
;	TXA
;	and #3
;	tax
PlKol1  lda #1
	and TbMs1,x
	sta BYT
	lda (Pom1),y
	and TbMs2,x
	ora BYT
	sta (Pom1),y
PlKol2  lda #2
	and TbMs1,x
	sta BYT
	lda (Pom2),y
	and TbMs2,x
	ora BYT
	sta (Pom2),y
	RTS

Plot5	jsr AdrPt
	TYA
	lsr @
	bcs Niepa5
	lda Kolor1
	ldy Kolor2
	jmp Pl5s1
Niepa5  lda Kolor2
	ldy Kolor1
Pl5s1	sta Pl5C0+1
	sty Pl5C1+1
;	TXA
;	lsr @
;	lsr @
	lda pdiv2,x
	sta Pl5Y1+1
;	TXA
;	and #3
;	tax
Pl5C0	lda #0
	and TbMs1,x
	sta Pl5K1+1
Pl5C1	lda #0
	and TbMs1,x
	sta Pl5K2+1
	lda TbMs2,x
	sta Pl5A1+1
	sta Pl5A2+1

Pl5Y1	ldy #0
	lda (Pom1),y
Pl5A1	and #0
Pl5K1	ora #1
	sta (Pom1),y
	lda (Pom2),y
Pl5A2	and #0
Pl5K2	ora #1
	sta (Pom2),y
	RTS

AdrPt
;	jsr SetPomAdr
;SetPomADR
;	mwa	#Ekran10	PomADR1
;	mwa	#Ekran20	PomADR2
;	RTS
	
	LDA AdYLo,Y
	STA POM1
	STA POM2
	LDA AdYHi,Y
	CLC
	ADC >Ekran10	;PomADR1+1
	STA POM1+1
;	LDA AdYHi,Y
;	CLC
	ADC >[Ekran20-Ekran10]	;PomADR2+1
	STA POM2+1
	RTS

*-----------------------------
Plot4	mwa #Bufor1 Pom1
	mwa #Bufor2 Pom2	

	lda #0
	sta BYT
	lda PMGY
	asl @
	rol BYT
	asl @
	rol BYT
	asl @
	rol BYT

	sta Pom
	lda BYT
	sta Pom+1
	lda Pom
	asl @
	rol BYT
	asl @
	rol BYT
	clc
	adc Pom
	sta Pom
	lda BYT
	adc Pom+1
	sta Pom+1

;	lda Pom1
;	clc
;	adc Pom
;	sta Pom1
;	lda Pom1+1
;	adc Pom+1
;	sta Pom1+1

	adw Pom1 Pom

;	lda Pom2
;	clc
;	adc Pom
;	sta Pom2
;	lda Pom2+1
;	adc Pom+1
;	sta Pom2+1

	adw Pom2 Pom

	LDY PMGX
;	lda PMGY
;	lsr @
;	bcs Plt41

	lda Kolor1
	and #3
	tax
	lda KolMask0,x
	sta (pom1),y
	lda Kolor2
	and #3
	tax
	lda KolMask0,x
	sta (pom2),y
;	jmp Plt42
	
;Plt41	lda Kolor1
;	and #3
;	tax
;	lda KolMask0,x
;	sta (pom1),y
;	lda Kolor2
;	and #3
;	tax
;	lda KolMask0,x
;	sta (pom2),y

Plt42	lda PMGX
	clc
	adc SZER
	tax
	lda PMGY
	clc
	adc WYS
	tay
	jmp Plot

*-----------------------------
LosPlot lda $d2ca
	bmi LosP2
	lda $d2ca
	and #3
	jmp LosP3
LosP2	lda $d2ca
	and #3
	eor #$ff
	clc
	adc #1
LosP3	clc
	adc PMGX
	tax
	lda $d20a
	bmi LosP4
	lda $d20a
	and #3
	jmp LosP5
LosP4	lda $d20a
	and #3
	eor #$ff
	clc
	adc #1
LosP5	clc
	adc PMGY
	tay
;	sta $d40a
	lda $ffff
	RTS

*-----------------------------
Spray	lda #0
	bne Spray1
	jsr CopyEkr0
	inc Spray+1
Spray1  lda #3
	sta CrF
Spray2  jsr LosPlot
	stx SprayX+1
	sty SprayY+1
	jsr Plot
	lda WskCur
	beq Spray3
SprayX  ldx #0
SprayY  ldy #0
	iny
	jsr Plot
Spray3	lda $ffff
	lda $ffff
;sta $d40a
	dec CrF
	bne Spray2
	RTS

*-----------------------------
Cspray  lda #0
	bne CSpr1
	jsr CopyEkr0
	inc CSpray+1
CSpr1	lda #3
	sta CrF
CSpr2	jsr LosPlot
	stx CSprX+1
	sty CSprY+1
	lda $d2ca
	and #7
	pha
	jsr WPlot
	pla
	ldx WskCur
	beq CSpr3
CSprX	ldx #0
CSprY	ldy #0
	iny
	jsr WPlot
CSpr3	lda $ffff
	lda $ffff
;sta $d40a
	dec CrF
	bne CSpr2
	RTS

*-----------------------------
Point	lda #0
	bne Poin1
	jsr CopyEkr0
	inc Point+1
Poin1	jsr Fire
;	beq *-3
	jsr GPlot
	lda WskCur
	sne
	RTS
	ldx PMGX
	ldy PMGY
	iny
	jmp Plot

*-----------------------------
Draw	lda #0
	bne Draw1
	jsr CopyEkr0
	inc Draw+1
Draw1	jsr GPlot
;	lda WskCur
;	bne *+3
	RTS
;	ldx PMGX
;	ldy PMGY
;	iny
;	jmp Plot

*-----------------------------
Lines	lda #0
	bne Lines2
	inc Lines+1
	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr CopyEkr0
	jsr Fire
;	beq *-3
	jsr wait
	jmp PutCur
	
Lines2  jsr Line3
	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr Fire
;	beq *-3
	jsr wait
	jsr CLSCur
	jmp PutCur

*-----------------------------
Triang	lda #0
	bmi Triang3
	bne Triang2
	inc Triang+1
	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr CopyEkr0
	jsr Fire
;	beq *-3
	jsr wait
	jmp PutCur

Triang2	jsr Line3
	lda OldPMGX
	sta TrX1+1
	lda OldPMGY
	sta TrY1+1
	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr Fire
;	beq *-3
	lda #$ff
	sta Triang+1
	jsr wait
	jsr CLSCur
	jmp PutCur

Triang3	jsr Line3
	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
TrX1	lda #0
	sta PMGX
TrY1	lda #0
	sta PMGY
	jsr Line3
	jsr Fire
;	beq *-3
	sta $d001
	lda #0
	sta Triang+1
	jsr wait
	jsr CLSPMG
	jmp CLSCur

*-----------------------------
Line	lda #0
	bne Line2
	inc Line+1
	inc WskSh+1

	mwa	#ShLine	ShSk+1

	jmp UstCur
Line2	jsr ShLine
	lda #0
	sta Line+1
	sta WskSh+1
	jmp WndEx2

ShLine  jsr UNDO

Line3	ldx OldPMGX
	ldy OldPMGY
	jsr Plot
	ldy #0
	ldx #1
	sec
	lda pmgy
;	cmp #192
;	bcc *+4
;	lda #191
	sbc oldpmgy
	bcs Dy_1
	eor #$ff	;znak z minusem
	clc
	adc #1
	ldx #$ff
Dy_1	sta DY+1
;	sta $100
	stx Yinc+1
	ldx #1
	sec
	lda pmgx
	sbc oldpmgx
	bcs Dx_1
	eor #$ff
	clc
	adc #1
	ldx #$ff
Dx_1	sta DX+1
	stx Xinc+1
	lda OldPMGX
	sta Xcur+1
	lda OldPMGY
	sta Ycur+1
	lda DX+1
	cmp DY+1
	bcs poX0
	lda DY+1
	sta Countr
	sta EndPt
	lsr @
	sta Xact
	sty Yact
	bne LopDr
	beq LopDr
PoX0	sta Countr
	sta EndPt
	lsr @
	sta Yact
	sty Xact
LopDr	lda Countr
	beq EXITDr
	clc
	lda Yact
DY	adc #0
	sta Yact
	bcs PoY2
	cmp EndPt
	bcc PoX1
PoY2	clc
	lda Ycur+1
Yinc	adc #0
	sta Ycur+1
	sec
	lda Yact
	sbc EndPt
	sta Yact
PoX1	clc
	lda Xact
DX	adc #0
	sta Xact
	bcs PoX2
	cmp EndPt
	bcc Xcur
PoX2	clc
	lda Xcur+1
Xinc	adc #0
	sta Xcur+1
	sec
	lda Xact
	sbc EndPt
	sta Xact
Xcur	ldx #0
Ycur	ldy #0
	jsr Plot
	lda WskCur
	beq Drr2
	ldx Xcur+1
	ldy Ycur+1
	iny
	jsr Plot
Drr2	dec Countr
	bne LopDr
EXITDr	RTS

*-------------------
LineY	sty LY1+1
	LDX OldPMGX
	jsr Plot5
LY1	ldx #0
LY0	inx
	stx LY1+1
	jsr AddPom
	lda Pl5K1+1
	ldy Pl5K2+1
	sta Pl5K2+1
	sty Pl5K1+1
	jsr Pl5Y1
LY2	cpx #0
	bcc LY0
	RTS

*-------------------
Square  lda #0
	bne Squar2
	inc Square+1
	inc WskSh+1
	lda <ShSqr
	sta ShSk+1
	lda >ShSqr
	sta ShSk+2
	jmp UstCur

Squar2  jsr Undo
	jsr Squar3
	lda #0
	sta Square+1
	sta WskSh+1
	jmp Wex1

Squar3  jsr PMGSrt
	ldy PMGY
	cpy #Ymax
	bcc *+4
	ldy #191
	sty LY2+1
	sty SqY2+1
	ldy OldPMGY
	jsr LineY
	ldx OldPMGX
	stx SqX2+1
	ldx PMGX
	stx OldPMGX
	ldy OldPMGY
	sty PMGY
	jsr LineY
SqX2	ldx #0
	stx OldPMGX
	ldy oldpmgy
	jsr Line3
SqY2	ldy #0
	sty OldPMGY
	sty PMGY
	jmp Line3

ShSqr	jsr PutOld
	jsr UNDO
	jsr Squar3
GetOld
SqROX	lda #0
	sta OldPMGX
SqROY	lda #0
	sta OldPMGY
SqRX	lda #0
	sta PMGX
SqRY	lda #0
	sta PMGY
	RTS

PutOld	lda OldPMGX
	sta SqROX+1
	lda OldPMGY
	sta SqROY+1
	lda PMGX
	sta SqRX+1
	lda PMGY
	sta SqRY+1
	rts
	
*-------------------
Rays	lda #0
	bne Rays2
	inc Rays+1
	jmp UstCur
Rays2	jsr Line3
	jsr Fire
;	beq *-3
	RTS

*-------------------
Box	lda #0
	bne Box2
	inc Box+1
	inc WskSh+1
	lda <ShSqr
	sta ShSk+1
	lda >ShSqr
	sta ShSk+2
	jmp UstCur
Box2	jsr PMGSrt
	jsr Box3
BxEx	lda #0
	sta Box+1
	sta WskSh+1
	jmp Wex1

Box3	lda PMGY
	sta LY2+1
	ldx OldPMGX
PtlBx	stx OldPMGX
	ldy OldPMGY
	jsr LineY
	ldx OldPMGX
	cpx PMGX
	bcs *+5
	inx
	bcc PtlBx
	RTS
*---
FilEN	jsr Fire
;	beq *-3
	sta $d001
	jmp wait
*-------------------
Fill	lda #0
	bne Fill1
	jsr CopyEkr0
	inc Fill+1
Fill1	ldx PMGX
	stx OldPMGX
	ldy PMGY
	sty OldPMGY
	jsr Locate
	cmp NrCol0
	beq FilEn
	sta Nrcol
	lda #0
	sta XAct

	mwa	#Bufor1	CrF

Fill2	ldy OldPMGY
	sty CrY
Fill3	ldy CrY
	iny
	sty CrY
	cpy #Ymax
	beq Fill4
	ldx OldPMGX
	jsr Locate
	cmp Nrcol
	beq Fill3
Fill4	ldy CrY
	dey
	sty CrY
	sty LY2+1
Fill5	ldy OldPMGY
	sty CrY0
Fill6	ldy CrY0
	dey
	sty CrY0
	cpy #255
	beq Fill7
	ldx OldPMGX
	jsr Locate
	cmp Nrcol
	beq Fill6
Fill7	ldy CrY0
	iny
	sty CrY0
	cpy CrY
	bcs FilEnd
	jsr LineY
	ldx OldPMGX
	inx
	stx OldPMGX
	cpx #160
	beq Fill9
	ldy CrY0
	sty OldPMGY

Fill8	ldx OldPMGX
	jsr Locate
	cmp NrCol
	bne F1PLA+3
	jsr FilPHA
	lda #1
	sta XAct
	jmp Fill2
F1PLA	jsr FilPLA
	ldy OldPMGY
	iny
	sty OldPMGY
	cpy CrY
	bcc Fill8

Fill9	ldx OldPMGX
	dex
	dex
	stx OldPMGX
	cpx #$FF
	beq FilEND
	ldy CrY0
	sty OldPMGY

FillA	ldx OldPMGX
	jsr Locate
	cmp NrCol
	bne F2PLA+3
	jsr FilPHA
	lda #2
	sta XAct
	jmp Fill2
F2PLA	jsr FilPLA
	ldy OldPMGY
	iny
	sty OldPMGY
	cpy CrY
	bcc FillA

FilEND  lda XAct
	cmp #1
	beq F1PLA
	cmp #2
	beq F2PLA
FlEN	jsr Fire
;	beq *-3
	sta $d001
	jmp wait

FilPHA	ldy #0
	lda OldPMGX
	sta (CrF),y
	iny
	lda OldPMGY
	sta (CrF),y
	iny
	lda CrY0
	sta (CrF),y
	iny
	lda CrY
	sta (CrF),y
	iny
	lda XAct
	sta (CrF),y

;	lda CrF
;	clc
;	adc #5
;	sta CrF
;	bcc *+4
;	inc CrF+1

	adw CrF #5
	RTS

FilPLA lda CrF
	sec
	sbc #5
	sta CrF
	bcs *+4
	dec CrF+1
	ldy #0
	lda (CrF),y
	sta OldPMGX
	iny
	lda (CrF),y
	sta OldPMGY
	iny
	lda (CrF),y
	sta CrY0
	iny
	lda (CrF),y
	sta CrY
	iny
	lda (CrF),y
	sta XAct
	RTS
*-------------------
Circle	lda #0		;maksymalny promien = 128
	bne Circl2_
	inc Circle+1
CirJ	inc WskSh+1
	lda <Circl2
	sta ShSk+1
	lda >Circl2
	sta ShSk+2
	lda PMGX
	sta CrXr+1
;	lda PMGY
;	sta CrYr+1
	jmp UstCur
Circl2_ jsr Circl2
;	jsr wait
	lda #0
	sta Circle+1
	sta WskSh+1
	sta $d001
	jmp WndEx2

Circl2	jsr UNDO

Circl3	jsr PutOld
CrXr	lda #0
	sec
	sbc PMGX
	bcs Crr1
	lda PMGX
	sec
	sbc CrXr+1
Crr1	asl @
	cmp #128
	bcc Crr2
	lda #127
Crr2	sta CrX
	lda OldPMGX
;	sta CrXr+1
	sta CrX0
	lda OldPMGY
;	sta CrYr+1
	sta CrY0
	ldx #0
	stx CrY
	ldy #0
	jsr PtCr
	jmp GetOld
*--	
PtCr	stx CrF
	sty CrF+1
	lda CrY
	cmp CrX
	scc
	RTS
CrSk1	jsr PlotyC
	lda CrX
	asl @
	sta BYT
	
	lda CrY
	asl @
	sec
	adc CrF
	sta CrFY
	tax
	lda CrF+1
	adc #0
	sta CrFY+1
	tay

	txa
	clc
	sbc BYT
	sta CrXY
	scs
	dey
	sty CrXY+1

	lda CrFY+1
	bpl Crr4
	eor #$FF
	tay
	txa
	eor #$ff
	clc
	adc #1
	tax
	tya
	adc #0
Crr4	stx CrFYA
	sta CrFYA+1
	inc CrY
	ldx CrXY
	lda CrXY+1
	bpl Crr5
	eor #$ff
	tay
	txa
	eor #$ff
	clc
	adc #1
	tax
	tya
	adc #0
Crr5	cmp CrFYA+1
	beq *+4
	bcs Crr6
	cpx CrFYA
	beq *+4
	bcs Crr6
	dec CrX
	ldx CrXY
	ldy CrXY+1
	jmp PtCr
Crr6	ldx CrFY
	ldy CrFY+1
	jmp PtCr

*-------------------
PlotyC	lda CrX
	lsr @
	sta CrX1+1
	lda CrY
	lsr @
	sta CrY1+1
	lda CrX
	lsr @
	clc
	adc CrX0
	sta PMGX
	tax
	lda CrY0
	clc
	adc CrY
	bcc *+4
	lda #255
	sta PMGY
	cmp #Ymax
	bcs PlC1
	tay
	cpx #160
	bcs PlC1
	jsr Plot
PlC1	lda CrY0
	sec
	sbc CrY
	bcs *+4
	lda #255
	sta OldPMGY
	cmp #Ymax
	bcs PlC2
	tay
	ldx PMGX
	cpx #Xmax
	bcs PlC2
	jsr Plot
PlC2	lda CrX0
	sec
CrX1	sbc #0
	sta OldPMGX
	bcc PlC3
	tax
	ldy OldPMGY
	cpy #Ymax
	bcs PlC3
	jsr Plot
PlC3	ldx OldPMGX
	cpx #160
	bcs PlC4
	ldy PMGY
	cpy #Ymax
	bcs PlC4
	jsr Plot
PlC4	lda CrY
	lsr @
	clc
	adc CrX0
	sta PMGX
	tax
	lda CrY0
	clc
	adc CrX
	bcc *+4
	lda #255
	sta PMGY
	cmp #Ymax
	bcs PlC5
	tay
	cpx #160
	bcs PlC5
	jsr Plot
PlC5	lda CrY0
	sec
	sbc CrX
	bcs *+4
	lda #255
	sta OldPMGY
	cmp #Ymax
	bcs PlC6
	tay
	ldx PMGX
	cpx #160
	bcs PlC6
	jsr Plot
PlC6	lda CrX0
	sec
CrY1	sbc #0
	sta OldPMGX
	bcc PlC7
	tax
	ldy OldPMGY
	cpy #Ymax
	bcs PlC7
	jsr Plot
PlC7	ldx OldPMGX
	cpx #160
	bcs PlC8
	ldy PMGY
	cpy #Ymax
	bcs PlC8
	jmp Plot
PlC8	RTS

*-------------------
Disc	lda #0
	bne Disc2
	inc Disc+1
	jmp CirJ
;	jmp UstCur
	
Disc2	lda #0
	sta Disc+1
	sta DsLin+1
	lda OldPMGY
	sta DsY1+1
	sta DsY2+1
	lda OldPMGX
	sta DsX1+1
	sta DsX2+1
	lda <DsLin
	ldx >DsLin
	sta CrSk1+1
	stx CrSk1+2
	jsr Circl3
	lda PMGY
	pha
	lda DsY1+1
	sta PMGY
	lda DsY2+1
	sta OldPMGY
	lda DsX1+1
	cmp #160
	bcs *+7
	sta OldPMGX
	jsr LineY0
	lda DsX2+1
	cmp #160
	bcs *+7
	sta OldPMGX
	jsr LineY0
	pla
	sta PMGY
	lda <PlotyC
	ldx >PlotyC
	sta CrSk1+1
	stx CrSk1+2
	lda #0
	sta WskSh+1
	sta $d001
	jmp WndEx2
;	RTS

*-------------------
DsLin	lda #0
	bne DsL2
	lda CrX
	lsr @
	sta DsL1+1
	clc
	adc CrX0
	sta DsX1+1
	lda CrX0
	sec
DsL1	sbc #0
	bcs *+4
	lda #255
	sta DsX2+1
	inc DsLin+1
DsL2	lda CrX
	lsr @
	sta CrX2+1
	lda CrY
	lsr @
	sta CrY2+1
	lda CrX
	lsr @
	clc
	adc CrX0
	cmp DsX1+1
	beq DsL3
	pha
DsY1	lda #0
	sta PMGY
DsY2	lda #0
	sta OldPMGY
DsX1	lda #0
	cmp #160
	bcs DsX2
	sta OldPMGX
	jsr LineY0
DsX2	lda #0
	cmp #160
	bcs *+7
	sta OldPMGX
	jsr LineY0
	pla
	sta DsX1+1
	lda CrX0
	sec
CrX2	sbc #0
	bcs *+4
	lda #255
	sta DsX2+1
DsL3	lda CrY0
	clc
	adc CrY
	bcs *+6
	cmp #Ymax
	bcc *+4
	lda #191
	sta DsY1+1
	lda CrY0
	sec
	sbc CrY
	bcs *+4
	lda #0
	sta DsY2+1
	lda CrY0
	clc
	adc CrX
	bcs *+6
	cmp #Ymax
	bcc *+4
	lda #191
	sta PMGY
	lda CrY0
	sec
	sbc CrX
	bcs *+4
	lda #0
	sta OldPMGY
	lda CrY
	lsr @
	clc
	adc CrX0
	cmp #160
	bcs DsL4
	sta OldPMGX
	jsr LineY0
DsL4	lda CrX0
	sec
CrY2	sbc #0
	scs
	RTS
	sta OldPMGX
LineY0	ldy OldPMGY
	lda PMGY
	cmp OldPMGY
	bcs LY01
	tay
	lda OldPMGY
LY01	sta LY2+1
	jmp LineY

*-------------------
WCopy	lda #0		;zapamieta obszar zrodlowy, wsp XY i wielkosc okna
;	lda #$ff
	sta KolWC+1
	jsr WCopy4
;	jsr WCX2od
	lda CrX
	sta oldCrX+1
	lda CrY
	sta oldCrY+1
	jmp SObjEx

*-------------------
WMove	lda #0		;musi byc lda #0, nastepuje modyfikacja
;	lda #0
;	jsr WCopy4
;	ldx CrX
;	stx PMGX
;	ldy CrY
;	sty PMGY
	
	ldx oldPMGX
	stx oldX+1
	ldy oldPMGY
	sty oldY+1
	
	lda Kolor1
	sta oldKol1+1
	lda Kolor2
	sta oldKol2+1
	lda WCX1od+1
	sta OldPMGX
	lda WCY1od+1
	sta OldPMGY
	lda oldCrX+1
	sta PMGX
	lda oldCrY+1
	sta PMGY
	lda #0
	sta Kolor1
	sta Kolor2
	jsr Box3
	
;	lda #$ff
;	sta KolWC+1
oldX	lda #0
	sta oldPMGX
oldY	lda #0
	sta oldPMGY
oldKol1	lda #0
	sta Kolor1
oldKol2	lda #0
	sta Kolor2
;	jmp Wpaste_
;	jsr WCX2od
;	jmp SObjEx

*-------------------
Wpaste  lda #0
;	lda #$ff
	sta KolWC+1
;	jsr WCopy4
Wpaste_	lda OldPMGX
	sta WCX2od+1
	lda OldPMGY
	sta WCY2od+1
oldCrX	lda #0
	sta crX
oldCrY	lda #0
	sta crY
	jsr WCX2od
	jmp SObjEx

*-------------------
WCopy4  ldx OldPMGX
	stx WCX1od+1
	ldy OldPMGY
	sty WCY1od+1
	ldx PMGX
	stx WCX2od+1
	ldy PMGY
	sty WCY2od+1
	RTS

WCX2od  ldx #0
	stx PMGX
WCX1od  ldx #0
	stx OldPMGX
WCY2od  ldy #0
	sty PMGY
WCY1od  ldy #0
	sty OldPMGY
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2
KolWC	cmp #0		;jesli =0 to omijaj
	beq WC1
	ldx PMGX
	ldy PMGY
	jsr WPlot
WC1	ldy PMGY
	iny
	cpy #Ymax
	bcs WC2
	sty PMGY
	ldy OldPMGY
	cpy CrY
	bcs WC2
	iny
	bcc WCY1od+2
WC2	ldx PMGX
	inx
	cpx #Xmax
	bcs WC3
	stx PMGX
	ldx OldPMGX
	cpx CrX
	bcs WC3
	inx
	bcc WCX1od+2
WC3	RTS

*-------------------
WRot90  ldx OldPMGX
	stx WRX1+1
	lda PMGY
	sec
	sbc OldPMGY
	lsr @
	clc
	adc OldPMGX
	sta CrX
	lda OldPMGY
	sta WRY1+1
WRY1	ldy #0
	sty CrY
WRX1	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2
	sta NrCol
	ldx CrX
	cpx #160
	bcs WR2
	ldy CrY
	cpy #Ymax
	bcs WR2
	jsr WPlot
WR2	inc CrY
	ldx CrX
	cpx #160
	bcs WR3
	ldy CrY
	cpy #Ymax
	bcs WR3
	lda NrCol
	jsr WPlot
WR3	inc CrY
	ldx OldPMGX
	cpx PMGX
	bcs *+5
	inx
	bcc WRX1+2
	dec CrX
	ldy OldPMGY
	iny
	iny
	sty OldPMGY
	cpy PMGY
	bcc WRY1
WrotEx jmp SObjEx

*-------------------
Wspill  jsr UCouY
	stx WSpX2+1
WSpX2	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	dey
	jsr Locate2
	ldx $d20a
	bpl WSpl2
	ldx OldPMGX
	ldy OldPMGY
	jsr WPlot
WSpl2	ldx OldPMGX
	cpx PMGX
	bcs *+5
	inx
	bcc WSpX2+2
	inc OldPMGY
	dec Countr
	bne WSpX2
WsplEx  jmp SObjEx

*-------------------
WVFlip  jsr UCouY
	stx WHM2+1
WHM2	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2
	ldx OldPMGX
	ldy PMGY
	jsr WPlot
	ldx OldPMGX
	cpx PMGX
	beq *+5
	inx
	bne WHM2+2
	inc OldPMGY
	dec PMGY
	dec Countr
	bne WHM2
WHMEx	jmp SObjEx

*-------------------
WHFlip	lda PMGX
	clc
	adc #2
	sbc OldPMGX
	sta Countr
	ldy OldPMGY
	sty WVM2+1
WVM2	ldy #0
	sty OldPMGY
WVM3	ldy OldPMGY
	ldx OldPMGX
	jsr Locate2
	ldx PMGX
	ldy OldPMGY
	jsr WPlot
	ldy OldPMGY
	cpy PMGY
	bcs *+5
	iny
	bcc WVM2+2
	inc OldPMGX
	dec PMGX
	dec Countr
	bne WVM2
WVMEx	jmp SObjEx

*-------------------
WCMirr	ldx PMGX
	stx WCmX1+1
	stx WCmX2+1
	jsr UCouY
	stx WCM2+1
WCM2	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2
WCmX2	ldx #0
	ldy PMGY
	jsr WPlot
	dec WCmX2+1
	ldx OldPMGX
	cpx PMGX
	beq *+5
	inx
	bne WCM2+2
WCmX1	ldx #0
	stx WCmX2+1
	inc OldPMGY
	dec PMGY
	dec Countr
	bne WCM2
WCMEx	jmp SObjEx

*-------------------
WEmbos	lda <Embos0
	ldx >Embos0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Embos0	sta NrCol		;?
	ldx OldPMGX
	inx
	ldy OldPMGY
	iny
	jsr Locate2
	cmp NrCol
	bne Embos1
	lda #4+4
	RTS
Embos1	bcc Embos2
;	lda #6
	lda #15-1
	RTS
Embos2	lda NrCol
;	eor #7
	eor #15
	sec
	sbc #1
	lsr @
	RTS

*-------------------
WLight	lda <Light0
	ldx >Light0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Light0	cmp #15		;#6
	beq *+5
	clc
	adc #1
	RTS

*-------------------
WDark	lda <Dark0
	ldx >Dark0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Dark0	cmp #0
	beq *+5
	sec
	sbc #1
	RTS

*-------------------
WNeg	lda <Negat0
	ldx >Negat0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Negat0	eor #15		7
	sec
	sbc #1
	RTS

*-------------------
WBlur	lda <Blur0
	ldx >Blur0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Blur0	asl @
	sta NrCol
	ldx OldPMGX
	dex
	ldy OldPMGY
	jsr Locate2
	clc
	adc NrCol
	sta NrCol
	ldx OldPMGX
	inx
	ldy OldPMGY
	jsr Locate2
	clc
	adc NrCol
	sta NrCol
	ldx OldPMGX
	ldy OldPMGY
	dey
	jsr Locate2
	clc
	adc NrCol
	sta NrCol
	ldx OldPMGX
	ldy OldPMGY
	iny
	jsr Locate2
	clc
	adc NrCol
	tax
	lsr @
	lsr @
	sta NrCol
	txa
	sec
	sbc NrCol
	lsr @
	lsr @
	RTS

*-------------------
W3d	lda <Eff3d0
	ldx >Eff3d0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Eff3d0	sta NrCol
	ldx OldPMGX
	dex
	ldy OldPMGY
	dey
	jsr Locate2
	cmp NrCol
	bcs Eff3d1
	lda NrCol0
Eff3d1	RTS

*-------------------
WAnt	lda <Antiq0
	ldx >Antiq0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Antiq0	sta NrCol
	ldx OldPMGX
	inx
	ldy OldPMGY
	iny
	jsr Locate2
	cmp NrCol
	bne Antiq1
	lda #15-4	3
	RTS
Antiq1	bcc Antiq2
	lda NrCol
	clc
	adc #19
	lsr @
	lsr @
	RTS
Antiq2	lda NrCol
	eor #15		7
	sec
	sbc #1
	lsr @
	RTS

*-------------------
WShade	lda <Shade0
	ldx >Shade0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Shade0	sta NrCol
	ldx OldPMGX
	inx
	ldy OldPMGY
	iny
	jsr Locate2
	cmp NrCol
	sne
	RTS
	bcc Shade2
;	lda #6
	lda #15
	RTS
Shade2	lda #2
	RTS

*-------------------
WExch	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2
	sta NrCol
	lda <Exch0
	ldx >Exch0
	sta WinSk+1
	stx WinSk+2
	jmp Window

Exch0	cmp NrCol
	bne Exch1
	lda NrCol0
	RTS
Exch1	cmp NrCol0
	bne Exch2
	lda NrCol
Exch2	RTS

*-------------------
Window	jsr UCouY
	stx WinX2+1
WinX2	ldx #0
	stx OldPMGX
	ldx OldPMGX
	ldy OldPMGY
	jsr Locate2

WinSk	jsr Exch0

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
WindEx	jmp SObwEx

*-------------------
UCouY	lda PMGY
	clc
	adc #2
	sbc OldPMGY
	sta Countr
	ldx OldPMGX
	RTS

*-------------------
Object	lda #0
	bne SObj2
	inc Object+1
	inc WskSh+1
	lda <ShSqr
	sta ShSk+1
	lda >ShSqr
	sta ShSk+2
;	lda #1
;	sta ShowObj+1
	jmp UstCur
SObj2	jsr PMGSrt
	beq SObjEx
	lda PMGX
	sta CrX
	lda PMGY
	sta CrY
	jsr CLSCur
	jsr PMGRamka
	lda #0
	sta WskSh+1
	jsr UNDO
SObj3	lda #2
	jsr PutWinTxT

	jsr key_wait		;wybor cOpy, Move, Paste

	pha
	jsr UNDO
	pla
	CMP #$1C		;Esc		-exit
	BEQ SObjEx
	jsr TK22
	bcs SObj3
	RTS
SObjEx	jsr CLSWsk
	jsr WndExt
	CLC
	RTS

*-------------------
Objw	lda #0
	bne SObjw2
	inc Objw+1
	inc WskSh+1
	lda <ShSqr
	sta ShSk+1
	lda >ShSqr
	sta ShSk+2
	jmp UstCur
SObjw2	jsr PMGSrt
	beq SObwEx
	lda PMGX
	sta CrX
	lda PMGY
	sta CrY
	jsr CLSCur
	jsr PMGRamka
	lda #0
	sta WskSh+1
	jsr UNDO
SkWnd	jsr W3d
SObwEx	jsr CLSWsk
	jsr WndEx0
	CLC
	RTS

*-------------------
HELP	jsr CopyEkr0
	lda #0
	jsr PutWinTxT
	lda #1
	jsr PutWinTxT
	lda #3
	jsr PutWinTxt

	jsr key_wait
	jmp UNDO

*-------------------
INFO	jsr CopyEkr0
	lda #3
	jsr PutWinTxT

	jsr key_wait
	jmp UNDO

*-------------------
FUNC	jsr CopyEkr0
	lda #4
	jsr PutWinTxT

	jsr key_wait

	jsr TK23
Hit	lda #0
	asl @
;	jsr SetInfo
	jmp UNDO

*-------------------
UstCur	lda PMGX
	sta OldPMGX
	lda PMGY
	sta OldPMGY
	jsr Fire
;	beq *-3
;	jsr wait
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
	lda <Objw
	sta Func2+1
	lda >Objw
	sta Func2+2
	lda #0
	sta Objw+1
	RTS

WndExt	jsr WEX1
	lda <Object
	sta Func2+1
	lda >Object
	sta Func2+2
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
	jsr CLSPMG
	sta Ust+1
;	jsr wait
	lda Object+1
	bne WndQ
	jmp CLSCur
WndQ	RTS

*-------------------
PutWinTxt
	asl @
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

*we: CrF=Adr.Text ($9B) X=posX Y=posY

IniLinTxt  stx CrX0
	sty CrY0
NxtLinTxt  ldx CrX0	;pos X win
	ldy CrY0	;pos Y win
PutLinTxt  stx CrXY	;pos X win
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

PutChar	.proc

;	and	#$7f
	tax
	lda	l_fnt,x
	sta	_char+1
	lda	h_fnt,x
	sta	_char+2

	ldy CrXY+1	;posY

	LDA AdYLo+8,Y	;<--- przepisany i zmodyfikowany AdrPt
	STA POM1
	STA POM2
	LDA AdYHi+8,Y
	CLC
	ADC >Ekran10	;PomADR1+1
	STA POM1+1
;	LDA AdYHi,Y
;	CLC
	ADC >[Ekran20-Ekran10]	;PomADR2+1
	STA POM2+1

	ldy CrXY	;posX
	inc CrXY	;add posX

	ldx #7		; przepisuje znak z zestawu na ekran
_char	lda $FFFF,x
	sta $FFFF,y
POM1	equ *-2
	sta $FFFF,y
POM2	equ *-2

	TYA
	SEC
	SBC #40
	TAY
	BCS _SKP
	DEC POM1+1
	DEC POM2+1

_SKP
	dex
	bpl _char
	rts

	.endp

*-------------------
CopyEkr0
	mvx:inx	>Ekran10	xPOM1+2
	stx	_xPOM1+2
	mvx:inx	>Ekran20	xPOM2+2
	stx	_xPOM2+2
	mvx:inx	>Ek01		xPOMAdr1+2
	stx	_xPOMAdr1+2
	mvx:inx	>Ek02		xPOMAdr2+2
	stx	_xPOMAdr2+2

	lda #0
	sta Ust+1

CE00	ldx #$1e

CE01	ldy #$7f

Xpom1		lda $FFB0,y
Xpomadr1	sta $FFB0,y
Xpom2		lda $FFB0,y
Xpomadr2	sta $FFB0,y

_Xpom1		lda $FF30,y
_Xpomadr1	sta $FF30,y
_Xpom2		lda $FF30,y
_Xpomadr2	sta $FF30,y

	dey
	bpl	Xpom1

	inc	xPOM1+2
	inc	xPOM2+2
	inc	xPOMAdr1+2
	inc	xPOMAdr2+2

	inc	_xPOM1+2
	inc	_xPOM2+2
	inc	_xPOMAdr1+2
	inc	_xPOMAdr2+2

	dex
	bne CE01
	RTS

*-------------------
UNDO	mvx:inx	>Ekran10	xPOMAdr1+2
	stx	_xPOMAdr1+2
	mvx:inx	>Ekran20	xPOMAdr2+2
	stx	_xPOMAdr2+2	
	mvx:inx	>Ek01		xPOM1+2
	stx	_xPOM1+2
	mvx:inx	>Ek02		xPOM2+2
	stx	_xPOM2+2

	stx	Ust+1
	bne	CE00

*-------------------
*We:	---			Wy:	Z=1	-Fire
*					Z=0	-no Fire
*-------------------
Fire	lda #1
	bne fq
fLop	lda $d010
	and $d011
	beq fLop
	lda #1
	sta Fire+1		;ustaw na 1
	lda #0
;	lda $d010
fq	RTS
*-------------------
*We:	X	-poz.x		Wy:	A	-Nr Col
*	Y	-poz.y
*-------------------
Locate2 sty _py+1
	jsr SetPomAdr2
	jsr AdrPt
	jmp Loc_skp
	
GetCol
;	lda WskZoom
;	bmi GetColN
;	lda PMGY
;	cmp #192
;	bcc *+3
;	rts
;	lda PMGX
;	lsr @
;	lsr @
;	jmp get__

GetColN	lda mvp00+1
	bne _rts
	ldx PMGX
	ldy PMGY
	cpy #192
	bcc get__
_rts	rts
get__	jsr Locate
	jmp SetCol

Locate	sty _py+1
	jsr AdrPt

loc_skp
	ldy pdiv2,x
;	TXA
;	lsr @
;	lsr @
;	tay
;	TXA
;	and #3
;	tax

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

	.pages

nxt	ldy _tjmp,x	; szybsze podejmowanie decyzji w 1 kroku
	sty _jmp+1

_jmp	jmp Loc1

Loc1
;	cpx #0		;przesun bity w prawo
;	bne Loc2
	:2 lsr @
;	lsr @
;	lsr @
	ora byt
	:4 lsr @
;	lsr @
;	lsr @
;	lsr @
;	lsr @
	RTS
Loc2
;	cpx #1
;	bne Loc3
	:2 lsr @
;	lsr @
;	lsr @
	ora byt
	:2 lsr @
;	lsr @
;	lsr @
	RTS
Loc3
;	cpx #2
;	bne Loc4
	:2 lsr @
;	lsr @
;	lsr @
	ora byt
	RTS
Loc4	sta byt_+1
	lda byt
	:2 asl @
;	asl @
;	asl @
byt_	ora #0	
	RTS

	.endpg

*-------------------
*- zmiana kolorow co linie dla ZOOM
*- linie parzyste
*-
dliv0z

	ldy kol0

lz1	ldx #144

zz1	mva #4 petla

zz1_	lda jas1,x
	sta $d40a    ; jasn
;	lda jas1,x
	sta $d016
	lda jas2,x
	sta $d017
	lda jas3,x
	sta $d018
;	lda jas0,x
	sty $d01a

	lda kol1,x
	sta $d40a    ; kol
;	lda kol1,x
	sta $d016
	lda kol2,x
	sta $d017
	lda kol3,x
	sta $d018
;	lda kol0,x
;	sta $d01a

	dec petla
	bne zz1_

	inx
	inx
lz1m	cpx #192
	bne zz1
	jmp ex_dliv

*----
*- linie nieparzyste
*-
dliv0z_	

	ldy kol0

lz2	ldx #144+1

zz2	mva #4 petla

zz2_	lda kol1,x
	sta $d40a    ; kol
;	lda kol1,x
	sta $d016
	lda kol2,x
	sta $d017
	lda kol3,x
	sta $d018
;	lda kol0,x
	sty $d01a

	lda jas1,x
	sta $d40a    ; jasn
;	lda jas1,x
	sta $d016
	lda jas2,x
	sta $d017
	lda jas3,x
	sta $d018
;	lda jas0,x	
;	sta $d01a

	dec petla
	bne zz2_

	inx
	inx
lz2m	cpx #192+1
	bne zz2
	jmp ex_dliv

*---

key_wait
	mva	#$ff	$2fc
	JSR	KEY
	RCC
	rts

* ---	MOUSE

mouse	jsr TstMouse
	tay
	lda TRIG1
	and Fire+1
	sta Fire+1
	tya
mousQ_	rts
	
UpMenu	lda mvp00+1
	cmp #6
	beq mousQ_
	lda <PMG+$41c-16
	sta kursor+1
	lda #6
	sta mvp00+1
	jmp CLSPMG
UpMenu_ jmp UpMenu


TstMouse	lda #$b0
		sta pom1_
		lda PORTA
		and #$30
		tay
		lda PORTA
		and #$c0
		tax
BrakRuchu	lda PORTA
		and #$30
		sta pom0_
		cpy pom0_
		bne RuchPoziomy
		lda PORTA
		and #$c0
		sta pom0_
		cpx pom0_
		bne RuchPionowy
SprawdzajRuch	dec pom1_
		bne BrakRuchu
		lda #0
		rts
RuchPionowy	cpx #$00
		beq UstalKier1
		cpx #$40
		beq UstalKier2
		cpx #$80
		beq UstalKier3
		cmp #$40
		bne Wgore
Wdol	ldy PMGY
	iny
	cpy #198
	bne MVP55_
	jsr CLSPMG
	ldy #191
	bne MVP66_
MVP55_	cpy #192
	bcc MVP66_
	cpy #199
	beq MVP66_
	jsr CLSPMG
	ldy #199
MVP66_	sty PMGY
	lda mvp00+1
	beq mousQ
	lda <PMG+$41c
	sta kursor+1
	lda #0
	sta mvp00+1
	jmp CLSPMG
;	inc PMGY
;		lda #1
;		rts
Wgore	ldy PMGY
	beq UpMenu_
	dey
	sty PMGY
;	dec PMGY
		lda #1
		rts
RuchPoziomy	cpy #$00
		beq UstalKier4
		cpy #$10
		beq UstalKier5
		cpy #$20
		beq UstalKier6
		cmp #$10
		bne Wlewo
Wprawo	ldx PMGX
	cpx #Xmax-1
	beq mousQ
	inx
	stx PMGX
;	inc PMGX
mousQ		lda #1
		rts
Wlewo	ldx PMGX
	beq mousQ
	dex
	stx PMGX
;	dec PMGX
		lda #1
		rts
UstalKier1	cmp #$80
		bne Wgore
		beq Wdol
UstalKier2	cmp #$00
		bne Wgore
		beq Wdol
UstalKier3	cmp #$c0
		bne Wgore
		beq Wdol
UstalKier4	cmp #$20
		beq Wprawo
		bne Wlewo
UstalKier5	cmp #$00
		beq Wprawo
		bne Wlewo
UstalKier6	cmp #$30
		beq Wprawo
		bne Wlewo

*-------------------
Panel1	Ins '..\PANEL.DAT'

	.align

div6	.ds	256
div4	.ds	256
div2	.ds	256
pdiv2	.ds	256
l_fnt	.ds	128
h_fnt	.ds	128

kol2	.ds	$c4


*--
meta	equ *

	ert *>=$5c00

	.print 'INIT $2000..',*


* ---	INITIALIZACJA jest wykonywana tylko po uruchomieniu, potem nie jest potrzebna

;,DLL0,DLL1,DLIv5,DLIv1,DLL11,DLL5,DLL51,DLIv0,DLL52

;FNT1	Ins '..\NEWXLP.FNT'
RLE_FNT	ins '..\newxlp.rle'

_mask	.he 00 55 aa ff

_TbMs1	dta b(%11000000,%00110000,%00001100,%00000011)
_TbMs2	dta b(%00111111,%11001111,%11110011,%11111100)

__tjmp	dta l(loc1,loc2,loc3,loc4)


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


	jsr rle_depacker


	ldy #0
Ini1
;	mva	FNT1,y		FONTY,y
;	mva	FNT1+$100,y	FONTY+$100,y
;	mva	FNT1+$200,y	FONTY+$200,y
;	mva	FNT1+$300,y	FONTY+$300,y

	tya
	:2 lsr @
	sta pdiv2,y
	and #3
	tax
	lda _mask,x
	sta div2,y

	tya
	:4 lsr @
	and #3
	tax
	lda _mask,x
	sta div4,y

	tya
	:6 lsr @
	and #3
	tax
	lda _mask,x
	sta div6,y

	iny
	bne Ini1


	ldy #0		; rozpisujemy tablice TbMs1, TbMs2, _tjmp
_fl	tya
	and #3
	tax
	mva	_TbMs1,x	TbMs1,y
	mva	_TbMs2,x	TbMs2,y
	mva	__tjmp,x	_tjmp,y

	mva	NAG_,y	NAG,y

	tya
	bmi _no
	ldx #0
	stx Pom+1
	asl @
	rol Pom+1
	asl @
	rol Pom+1
	asl @
	rol Pom+1
	sta	l_fnt,y
	lda Pom+1
	clc
	adc >Fonty
	sta	h_fnt,y

_no	lda #0
	sta jas0	;,y
	sta jas1,y
	sta jas2,y
	sta jas3,y

	iny
	bne _fl

	jsr jascol

;	LDA:RNE $D40B

;	CLI
;	LDA #$C0
;	STA $D40E

	lda >FONTY
	sta $02f4

MOVE1
;	JSR WAIT
;	LDA #0
;	STA $D400
;	STA $D40E
;	SEI
	ldy #0
MOVE10	ldx #$ff
	stx $d301
;	sta $d40a
	lda $FB51,y
	ldx #$fe
	stx $d301
;	sta $d40a
	sta KEYASCII,y
	iny
	bne MOVE10

	LDA:RNE $D40B
	CLI
	LDA #$C0
	STA $D40E

	JMP	_RUN	; -> START


zp_src equ pom

rle_depacker
;	mwa #FONTY q1+1
	lda >RLE_FNT-1
	ldy <RLE_FNT-1

        sta zp_src+1

loop    jsr get
        beq stop
        lsr @
        tax
        
q0      jsr get
q1      sta FONTY

        inw q1+1

        dex
	bmi loop

        bcs q0
        bcc q1

get     iny
        sne
        inc zp_src+1

        lda (zp_src),y

stop    rts

*-----------------------------
T_I equ *

 Dta a($D301),b($FE)
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


* ---	NAG_... PRZEPISUJEMY POD ROM -> NAG

NAG_
	org NAG,*

;NAG
	Dta d'Info File fUnc Otch            X000 Y000'

bar1	dta d'   $      '
	dta d'   $      '
	dta d'   $      '
	dta d'   $      '

bar2	dta d'   $      '
	dta d'   $      '
	dta d'   $      '
	dta d'   $      '

defcol	dta b(2,4,6,0,0)

kolmask0	dta b($00,$55,$AA,$FF)
kolmask2	dta b($00,$55,$aa,$ff,$00,$55,$aa,$ff,$00,$55,$aa,$ff,$00,$55,$aa,$ff)
kolmask1	dta b($00,$00,$00,$00,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff)

WskZoom		dta b($80)

	ert *>=Ek02

	.print 'NAG ',NAG,'..',*

;---

	org $0400

kol3	:$c4 brk		;na poczatku strony pamieci	

panel2	dta $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,d'        '
	dta $00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,d'        '
	dta $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,d'        '
	dta $00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,d'        '
	dta $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,d'        '
	dta $00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,d'        '
	dta $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,d'        '
	dta $00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,$00,$00,$55,$55,$aa,$aa,$ff,$ff,d'        '
	dta $00,$00,$00,$00,$00,$00,$00,$00,$55,$55,$55,$55,$55,$55,$55,$55,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,d'        '

tabk	:193 brk		;tablica lokalizacji palet kolorow

kol	dta $00,$30,$70,$d2
jas	dta $00,$02,$04,$06
	dta $00,$30,$70,$d2

	.print '$0400..',*
	ert *>=$700

;---
	run INIT

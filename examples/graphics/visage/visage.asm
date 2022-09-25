/***********************************************
 Visage 2.6_2 by TeBe/Madteam

 od $f500 jest wolne miejsce :)

 v2.6 dodana obsluga TIP-a
 v2.7 naprawione wyswietlanie TIP-a

 ostatnia modyfikacja: 30.07.2007
***********************************************/

info	equ $0600

iocb	equ $340
ciov	equ $e456

fnt	equ $8000

prg	equ $8400

dlicr	equ $d800

lmsk	equ $ff00
hmsk	equ lmsk+16

TipView	equ $f800

o1	equ $2000
o2	equ $5000

szscr	equ 40		; szerokosc ekranu
ofs_	equ 128		; ofset dla dir
ofs2	equ 320		; centrowanie
of_x	equ 2		; ofset x dla scr

b	equ $80   	; 2
x	equ b+2
y	equ x+2

_ant	equ b


* -----------------------------------------------------

	org $2000

init	jsr printf
	.by $9b
tx	.by 'Visage 2.8 by TeBe/Madteam',$9b
	.by '--------------------------',$9b,0

	rts

	.link 'stdio/printf.obx'

	ini init


* -----------------------------------------------------

	org fnt
	ins 'visage.fnt',6

* -----------------------------------------------------


start	jmp buf			; start po wyjsciu do DOS-a

dl	dta d' ',b($4f)
ad	dta a(o1)
m1	:101 brk
	dta b($4f)
adr2	dta a(o1+$1000)
m2	:101 brk
	dta b($4f)
adr3	dta a(o1+$2000)
m3	:32 brk
	dta b($41),a(dl)


men	dta d'p',b($42),a(bar)
	dta b($42),a(titl)
	dta b($42),a(nul)
	dta b($42),a(scr)
mm	:16 brk
	dta b($42),a(nul)
	dta b($42),a(info),d'"""'
	dta b($42),a(bar+40)
	dta b($41),a(men)

*---
go
; jmp buf

	jsr cbuf
	jsr chng
	jsr cinf
	jsr copi
	jsr sys
	ldx #$10
	jsr clos
	jmp dir

sys	lda >fnt
	sta 756

	jsr cinf

	ldx <men
	ldy >men
	stx 560
	sty 561
	lda #%00100010
	sta 559
	lda #0
	sta 623
	sta 712

	mva #$0c 709
	mva #$92 710

	lda #$f
	jsr modf

	lda:cmp:req 20

	mva #$40 $d40e
	jsr son
	rts

ant	sta $26f     ; z parametrem
	lda #%00100010
	sta 559

	mwa #dl $230

	ldy #8
	mva:rpl pal,y $2c0,y-

	lda:cmp:req 20
	rts

mic	lda gfx+1
	and #$f
	jsr modf
	lda gfx+1
	and #$f0
	jsr ant
	jmp kw

;---
tip_jmp	jmp tip

rip	lda #0		; sprawdzenie rodzaju RIP-a
	beq out
gfx	lda #0
	cmp #$80
	beq TIP_jmp

	and #$f0
	cmp #$10
	beq int16	; c64 palette picture

	lda gfx+1
	cmp #$20	; hip, rip
	beq hrp
	cmp #$30	; multi rip
	beq hrp
	and #$f
	cmp #$f
	beq mic
	cmp #$e
	beq mic
	jmp out

int16	lda gfx+1
	and #$f
	tax
	sne
	ldx #$e
	txa
	jsr modf
	lda #0
	jsr ant
	jmp intl

dl_sw	jsr sof
	mwa #nmi $fffa

	stx $200
	sty $201
	lda #$c0
	sta $d40e
	rts

hrp	lda #$80
	jsr ant

	ldx <dli
	ldy >dli
	jsr dl_sw

kw	lda $d209
	sta old+1
kwai	lda $d20f
	and #4
	bne kwai
	lda $d209
old	cmp #$ff
	beq kwai

out	lda #0
	sta $d400
	jsr sys
	ldx #$10
	jsr clos
	jmp kky

open	sty k_op+1
	sta iocb+2,x

	mwa #nam iocb+4,x

k_op	lda #4
	sta iocb+$a,x
	jsr ciov
	bmi error
	rts

a_adr	stx l_adr+1
	sty h_adr+1
	rts

a_len	stx l_len+1
	sty h_len+1
	rts

read	sta iocb+2,x
l_adr	lda #0
	sta iocb+4,x
h_adr	lda #0
	sta iocb+5,x
l_len	lda #0
	sta iocb+8,x
h_len	lda #0
	sta iocb+9,x
	jsr ciov
	bmi error
	rts

clos	lda #$c
	sta iocb+2,x
	jsr ciov
	bmi error
	rts

error	cpy #136
	sne
	rts

	sty _wo
	jsr copi
	jsr cbuf
	jsr chng
	jsr cinf
	lda rip+1
	bne _x
	jsr kopi
	lda #'-'-32
	jsr clal
_x	ldx _wo
	ldy #0
	jsr dec
	dta a(scr+11)

	ldy #8
	mva:rpl io,y scr+1,y-

	pla
	pla
	ldx #$10
	jsr clos
	jmp kky

er_	ldy #5			; HIP z paleta
	mva:rpl buf_,y o1,y-	; 6 bajtow naglowka
				; jako grafike

	lda #0
	sta buf_+6
	sta buf_+7
	ldx <16009
	stx buf_+4
	ldy >16009
	sty buf_+5
	jsr pckinf

	ldx <o1+6+8000
	ldy >o1+6+8000	; pic 1
	jsr a_adr
	ldx <8000-6
	ldy >8000-6
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	ldx <o1		; pic 2
	ldy >o1
	jsr a_adr
	ldx <8000
	ldy >8000
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	ldx <pal
	ldy >pal
	jsr a_adr
	ldx <9
	ldy >9
	jsr a_len
	lda #7
	ldx #$10
	jsr read
	jmp palet

*---- 
tipERR	jmp fatal
LoadTIP	ldx #$10
	ldy #4
	lda #3
	jsr open

	lda #'-'-32	; wyczysc opis pliku
	jsr clal
	jsr kopi	; czysc opis obrazka

	jsr clrscr
	sta rip+1
	ldx <buf_	; naglowek
	ldy >buf_	; pierwsze 9 bajtow z TIP-a
	jsr a_adr
	ldx <9
	ldy >9
	jsr a_len
	lda #7
	ldx #$10
	jsr read
 
	lda buf_+5
	cmp #$a0
	bne tipERR
	tay
	lda buf_+6
	sta wyso

	lda #0
	sta l_sbb+1
	sta h_sbb+1
	sta sze_+1 
 
	ldx #$80
	stx gfx+1
	stx rip+1
	jsr Show_info

	ldx wyso	; wysokosc * 40, tyle wczytaj grafiki
	ldy #40
	jsr mnoz
	stx rob
	sta rob+1

	jsr ldtx	; napis loading TIP picture

	lda cnt+1	; czy centrowac
	bne _tq

	lda #119
	sec
	sbc wyso	; obliczamy ile przesunac, aby obraz byl wycentrowany
	lsr @
	tax
	ldy #40
	jsr mnoz
	stx l_sbb+1
	sta h_sbb+1
 
_tq	lda <o1+$10
	clc
l_sbb	adc #0
	sta a00+1
	lda >o1+$10
h_sbb	adc #0
	sta a01+1
	lda #3
	sta petla+1

petla	lda #0 
a00	ldx <o1+$10	; wczytanie 3 obrazow, 9-A-B
a01	ldy >o1+$10
	jsr a_adr
	ldx rob
	ldy rob+1
	jsr a_len
	lda #7
	ldx #$10
	jsr read
 
	adb a01+1 >$2000
 
	dec petla+1
	bne a00
 
TIP	jsr wai
	jsr sof
	jsr TipView

	jsr son
	jmp out

*----

hip2	jmp er_
lhip	ldx #$10
	ldy #4
	lda #3
	jsr open

	ldy #8
	mva:rpl phip,y pal,y-
	
	jsr clrscr
	sta rip+1

	jsr kopi
	ldx <buf_	; naglowek
	ldy >buf_	; pierwsze 6 bajtow
	jsr a_adr
	ldx <6
	ldy >6
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	lda #$20
	sta gfx+1
	lda #200
	sta wyso
	lda #40
	sta szer
	jsr cent
	jsr ripinf
	jsr ldtx
;	ldy #200+30
;	jsr clin

	ldy #5
_ts	lda buf_,y
	cmp hea_,y
	bne hip2
	dey
	bpl _ts

	lda #0
	sta buf_+6
	sta buf_+7
	ldx <16016
	stx buf_+4
	ldy >16016
	sty buf_+5
	jsr pckinf

	ldx <o1		; pic 1
	ldy >o1
	jsr a_adr
	ldx <8000+6
	ldy >8000+6
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	ldx <o1+8000	; pic 2
	ldy >o1+8000
	jsr a_adr
	ldx <8000
	ldy >8000
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	jmp palet


er	jmp badh
loa	ldx #$10
	ldy #4
	lda #3
	jsr open

	jsr clrscr
	sta rip+1
	ldx <buf_	; naglowek
	ldy >buf_	; pierwsze 20 bajtow
	jsr a_adr
	ldx <20
	ldy >20
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	ldy #2
ts	lda buf_,y
	cmp hea,y
	bne er
	dey
	bpl ts

	jsr ldtx

	lda buf_+7	; tryb gfx
	sta gfx+1
	lda buf_+9	; kompresja
	sta pck+1
	lda buf_+13	; szerokosc
	lsr @
	sta szer
	lda buf_+15	; wysokosc
	cmp #239	; max 238
	scc
	lda #238
	sta wyso
	lda buf_+17	; dlugosc txt
	sta ltxt
	cmp #153	; max 152
	scc
	lda #152
	sta _wo

	lda buf_+11	; pozostale bajty
	sec		; txt i paleta
	sbc #20
	sta rob

	ldx <buf_
	ldy >buf_
	jsr a_adr
	ldx rob
	ldy #0
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	jsr kopi
	ldy ltxt	; opis obrazka
	beq sk
	ldy #0
t_	lda buf_,y
	jsr int
	sta opis,y
	iny
	cpy _wo
	bne t_
sk	ldy ltxt
	lda buf_,y	; liczba kolorow
	sta rob
	ldx #0
cpc	lda buf_+4,y
	sta pal,x
	iny
	inx
	cpx rob
	bne cpc

	jsr vopi
	jsr ripinf

	jsr cent

pck	lda #0
	beq _unp	; brak kompresji
	cmp #1		; depacker pck
	seq
	jmp fatal	; nieznana
	jmp unp

_unp	ldx <out_		; pic 1,2
	ldy >out_
	jsr a_adr
	ldx <24576
	ldy >24576
	jsr a_len
	lda #7
	ldx #$10
	jsr read
	tya
	cmp #136
	beq ok_
	jmp fatal
ok_	jmp palet

run	lda #0		; dir >=$a000
	beq *+7
	lda #0
	sta kky+1

	ldx #$10
	stx rip+1
	jsr clos
	lda gfx+1	; interlace'y
	and #$f0
	cmp #$10
	beq mic_

	lda gfx+1
	and #$f
	cmp #$f
	beq mic_
	cmp #$e
	beq mic_
	jsr cnv
	jmp rip

mic_	jsr move
	jmp rip

cnv	lda #118   ;przeplot
	sta rob
	lda #0
	sta x
	sta y
	mva >o1 x+1
	mva >o2 y+1

	ldy #39
exc	lda (x),y
	tax
	lda (y),y
	sta (x),y
	txa
	sta (y),y
	dey
	bpl exc

	ldy #39

	adw x #80
	adw y #80

	dec rob
	bpl exc

move	ldx <o1+$2ff0-1
	ldy >o1+$2ff0-1
	lda >o1+$eea
	jsr mov
	ldx <o2+$2ff0-1
	ldy >o2+$2ff0-1
	lda >o2+$eea
	jsr mov

	ldx <o1+$2ff0-1
	ldy >o1+$2ff0-1
	lda >o1+$1eea
	jsr mov
	ldx <o2+$2ff0-1
	ldy >o2+$2ff0-1
	lda >o2+$1eea
;	jsr mov
;	rts

mov	stx x
	sty x+1
	sta cm+1
mv	ldy #0
	lda (x),y
	ldy #16
	sta (x),y

	dew x

	lda x
	cmp #$ea
	lda x+1
cm	sbc >o1+$1000
	bne mv
	rts

clrscr	lda >o1
	jsr clr
	lda >o2
;	jsr clr
;	rts

clr	sta cl1+2
	ldx #48
	ldy #0
	tya
cl1	sta $ff00,y
	iny
	bne cl1
	inc cl1+2
	dex
	bne cl1
	rts

mnoz	stx mk
	sty ma
	lda #0
	sta b
	ldx #8
cykl	lsr mk
	bcc nied
	clc
	adc ma
nied	ror @
	ror b
	dex
	bne cykl
	sta b+1
	ldx b
	rts

key	lda #$ff
	sta 764

	lda 764
	cmp #$ff
	beq *-5
	rts

badh	jmp fatal	; zly naglowek

modf	ldy #100	; z parametrem
	sta m1,y
	sta m2,y
	dey
	bpl *-7

	ldy #31
	sta:rpl m3,y-

	ora #$40
	sta dl+1
	sta m1+101
	sta m2+101
	rts

ldtx	ldy #18
	mva:rpl load,y	scr+600+19,y-
	rts

ripinf	lda #0
	sta sze_+1
	lda #'-'-32
	jsr clal

	lda gfx+1
	and #$f
	cmp #$f
	bne _r1
	ldx #8
	ldy >320
	sty sze_+1
	ldy <320
_r1	cmp #$e
	bne *+6
	ldx #$f
	ldy #160

	lda gfx+1
	and #$f0
	beq _r2
	ldy #0
	sty sze_+1
	ldy #80
_r2	cmp #$40
	sne
	ldx #9
	cmp #$80
	sne
	ldx #10
	cmp #$c0
	sne
	ldx #11
	cmp #$30
	bne *+5
	tax
	ldy #160
	cmp #$20
	bne *+5
	tax
	ldy #160
	cmp #$10
	bne *+5
	tax
	ldy #160

	lda gfx+1
	cmp #$1f
	bne _r3
	tax
	ldy >320
	sty sze_+1
	ldy <320
_r3	cmp #$1e
	bne *+5
	tax
	ldy #160

Show_info
	stx mk
	sty sze+1
	ldy #40+30
	jsr clin
	ldx mk
	ldy #0
	jsr dec
	dta a(scr+280+40+30)

	ldy #80+30
	jsr clin
sze	ldx #0
sze_	ldy #0
	jsr dec
	dta a(scr+280+80+30)

 	ldy #120+30
	jsr clin
	ldx wyso
	ldy #0
	jsr dec
	dta a(scr+280+120+30)

	rts

cinf	lda #0
	ldy #18
	sta:rpl scr+600+19,y-
	rts

copi	lda #0    ;usun opis z ekranu
	ldy #37
	sta info+1,y
	sta info+41,y
	sta info+81,y
	sta info+121,y
	dey
	bpl *-13
	rts

kopi	ldy #0  ;wyczysc bufor opisu
	tya
	sta:rne opis,y+
	rts

vopi	lda inf+1 ;pokaz opis
	beq vs
	jsr copi
	rts

vs	ldy #37
	mva opis,y	info+1,y
	mva opis+38,y	info+41,y
	mva opis+76,y	info+81,y
	mva opis+114,y	info+121,y
	dey
	bpl *-25
	rts

int	cmp #96
	bcc *+6
	cmp #128
	bcc *+21
	cmp #224
	bcs *+17
	cmp #32
	bcc *+17
	cmp #128
	bcc *+6
	cmp #160
	bcc *+9
	sec
	sbc #32
	sta b
	rts
	adc #64
	sta b
	rts

fatal	jsr kopi
	jmp go

nmi	bit $d40f
	bpl vbl

	jmp ($200)

vbl	sta $d40f
	inc 20
	rti

cent	ldx wyso
	ldy szer
	jsr mnoz
	stx rob
	sta rob+1

	lda #0		; czy centrowac Y/N
	sta ofs
	sta ofs+1
	sta palc+1
	lda cnt+1
	bne _cq

	lda #238	; centruj w pionie
	sec
	sbc wyso
	lsr @
	and #$fe
	tax
	lsr @
	sta palc+1
	ldy szer
	jsr mnoz
	stx ofs
	sta ofs+1
_cq	rts

clal	ldy #70
	jsr clin+2
	ldy #110
	jsr clin+2
	ldy #150
	jsr clin+2
	ldy #190
	jsr clin+2
	ldy #230
	jsr clin+2
	rts

clin	lda #0
	ldx #4
	sta scr+280,y
	iny
	dex
	bpl *-5
	rts

;- DEC
;	ldx <65    ; mlodszy bajt
;	ldy >65    ; starszy bajt
;	lda #10    ; system liczbowy
;	jsr hexdec
;t_	dta a(0)   ; adres docelowy
;	rts

dec	lda #10
	stx help
	sty help+1
	sta ile
	lda #0
	sta ile+1

	pla
	sta he_+1
	pla
	sta he_+2

	ldy #1
he_	lda $8000,y
	sta docel,y
	iny
	cpy #3
	bne he_

	lda he_+1
	clc
	adc #2
	sta he_+1
	bcc h_e
	inc he_+2

h_e	lda he_+2
	pha
	lda he_+1
	pha

h_d_c	lda #0
	sta i_losc
	sta i_losc+1

konw	lda help+1
	bne cont
	lda help
	cmp ile
	bcs cont

	ldx i_losc
	ldy i_losc+1
	stx help
	sty help+1
	tay
	ldx ile+1
	lda _tab,y
	sta ob_mem,x

	inc ile+1
	lda help
	ora help+1
	bne h_d_c

	ldx ile+1

	ldy #0
doc_	lda ob_mem-1,x
docel	sta $8000,y
	iny
	dex
	bne doc_
	rts

cont	sec
	lda help
	sbc ile
	sta help
	bcs co_1
	dec help+1

co_1	inw i_losc
	jmp konw

i_losc	dta a(0)
help	dta a(0)
ile	dta a(0)
ob_mem	dta d'                '
_tab	dta d'0123456789ABCDEF'


;- DLI

dli3	pha	; dli dla int16
	tya
	pha

	ldy #118

kk_	sta $d40a	; jasn

k1_	mva #0 $d016
k2_	mva #0 $d017
k3_	mva #0 $d018
k4_	mva #0 $d01a

	sta $d40a	; kol
k1	mva #0 $d016
k2	mva #0 $d017
k3	mva #0 $d018
k4	mva #0 $d01a

	dey
	bne kk_

	pla
	tay
	pla
dli4	rti


dli	pha
	jsr dlicr+13

	mva >o1		ad+1
	mva >o1+$1000	adr2+1
	mva >o1+$2000	adr3+1

	mwa #dli2 $200
	pla
	rti

dli2	pha
	jsr dlicr

	mva >o2		ad+1
	mva >o2+$1000	adr2+1
	mva >o2+$2000	adr3+1

	mwa #dli $200
	pla
	rti


_dli	stx _ant
	sty _ant+1
	sta adpal+1
	lda #0
	sta _b+1
	jsr sof

_b	lda #0
	ldy #0
_a	lda xtmp,y
	sta (_ant),y
	iny
	cpy #21+40
	bne _a

	ldy #13+1
	ldx #3
	jsr r_adr
	jsr r_adr
	jsr r_adr
	jsr r_adr
	tya
	clc
	adc #8
	tay
	ldx #7
	jsr r_adr
	jsr r_adr
	jsr r_adr
	jsr r_adr

	lda #21+40
	clc
	adc _ant
	sta _ant
	scc
	inc _ant+1

	lda _b+1
	cmp palc+1
	bcs _s
	jmp _p

_s	lda _adr+1
	clc
adpal	adc #8
	sta _adr+1
	scc
	inc _adr+2

_p	inc _b+1
	lda _b+1
	cmp #119
	bne _b
	ldy #0
	lda #$60
	sta (_ant),y
	jsr son
	rts

r_adr	lda _b+1
palc	cmp #0
	bcs _adr
	lda #0
	seq
_adr	lda $ff00,x
	sta (_ant),y
	iny
	iny
	iny
	iny
	iny
	dex
	rts

*--
xtmp	lda #$40
	sta $d40a
	sta $d01b

	mva #$00 $d01a
	mva #$ed $d016
	mva #$f4 $d015
	mva #$fc $d014
	mva #$f8 $d013

	lda #$80
	sta $d40a
	sta $d01b

	mva #$fa $d01a
	mva #$21 $d019
	mva #$f6 $d018
	mva #$d9 $d017

;- PCK
out_	equ o1        ;docelowy
bfcp	equ $a000

adl0	equ $a500	;576
adh0	equ adl0+576	;576 1 wg tej
adl1	equ adh0+576	;576 2 kolejnosci
adh1	equ adl1+576	;576 3 w pamieci
tre01	equ adh1+576	;256 lo =0
tre02	equ tre01+256	;256 lo =0

err	equ $80		;2
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


unp	ldx <buf_	; naglowek PCK
	ldy >buf_
	jsr a_adr
	ldx <16
	ldy >16
	jsr a_len
	lda #7
	ldx #$10
	jsr read

	lda buf_+12	; ofset danych
	clc
	adc <o1		; skad
	sta bf
	tax
	lda buf_+13
	adc >o1
	sta bf+1
	tay

	txa		; + 16 byte dla naglowka
	clc		; ktory wczytalismy
	adc #16		; wczesniej
	tax		; bf=...-16 byte
	tya
	adc #0
	tay

	jsr a_adr
	lda <24576	; 24KB - ofset
	sec
	sbc buf_+12
	tax
	lda >24576
	sbc buf_+13
	tay
	jsr a_len
	lda #7
	ldx #$10
	jsr read
	tya
	cmp #136	; musi wystapic blad 136
	beq un
	jmp fatal	; za dlugi plik

un	jsr sof
	lda #0
	sta $d400
	jsr lzss

palet	lda gfx+1
	cmp #$20
	bne _si

	mwa #pal+1 _adr+1

	ldx <dlicr
	ldy >dlicr
	lda #0
	jsr _dli
	jmp cop

_si	cmp #$30
	bne cop
	ldx wyso	; adres palety
	ldy szer	; na koncu RIP'a
	jsr mnoz
	stx x
	sta x+1
	lda x		; omin 2 obrazki
	clc
	adc <out_
	tax
	lda x+1
	adc >out_
	tay
	txa
	clc
	adc x
	sta _adr+1	; adres konca obrazkow
	tya		; = adres palety
	adc x+1
	sta _adr+2

	ldx <dlicr	; generuje DLI
	ldy >dlicr
	lda #8
	jsr _dli
	lda #0		; tlo czarne
	sta pal

*--
cop	lda <o1		; adres pic2
	clc		; kopiuje do bufora
	adc rob		; zapasowego bfcp
	tax		; i przepisuje
	lda >o1		; do wlasciwego
	adc rob+1	; obszaru obrazu
	tay
	lda >bfcp	; pic2 >> bfcp
	jsr cp
	lda >o2		; clr o2
	jsr clr
	lda <o2
	clc
	adc ofs
	tax
	lda >o2
	adc ofs+1
	tay
	jsr cplin

	lda wyso	; omin pic1 gdy wyso=max
	cmp #238
	beq omn
	ldx <o1
	ldy >o1
	lda >bfcp
	jsr cp
	lda >o1
	jsr clr
	lda <o1
	clc
	adc ofs
	tax
	lda >o1
	adc ofs+1
	tay
	jsr cplin
omn	jmp run

cplin	stx pl2+1
	sty pl2+2
	lda >bfcp
	sta pl1+2
	lda #0
	sta pl1+1
	jsr sof
	ldx wyso
pl	ldy #39
pl1	lda $ff00,y
pl2	sta $ffff,y
	dey
	bpl pl1

	adw pl1+1 #40

	adw pl2+1 #40

	dex
	bne pl
	jsr son
	rts

cp	stx p1+1
	sty p1+2
	sta p2+2
	jsr sof
	ldx #48
	ldy #0
p1	lda $ff00,y
p2	sta $ff00,y
	iny
	bne p1
	inc p1+2
	inc p2+2
	dex
	bne p1
	jsr son
	rts

sof	sei
	mva #$00 $d40e
	mva #$fe $d301
	rts

son	mva #$ff $d301
	mva #$40 $d40e
	cli
	rts

pckinf	ldy #200+30
	jsr clin
	ldx buf_+4	; dlugosc oryginalna
	ldy buf_+5
	jsr dec
	dta a(scr+280+200+30)

	lda buf_+6
	ora buf_+7
	beq pq

	ldy #160+30
 	jsr clin
	ldx buf_+6	; dlugosc spakowana
	ldy buf_+7
	jsr dec
	dta a(scr+280+160+30)
pq	rts

* Wstep, parametry pliku
* mozna je pominac
*-----------------------
lzss	equ *
* lda buf_+3   ;stopien kompresji
* and #$7f
* sta ratio

	jsr pckinf

* wywolanie Fano dla 3 typow danych
* match_len 64
* ofset     256
* unpack    256
*----------------------------------

	lda <adl0
	ldx >adl0
	jsr set_hv
	lda bf
	clc
	adc #16
	pha
	lda bf+1
	adc #0
	tax
	pla
* lda <bf+16    ;match_len
* ldx >bf+16
	ldy #64
	jsr fano

	lda <adl0+64
	ldx >adl0+64
	jsr set_hv
	lda bf
	clc
	adc #16+32
	pha
	lda bf+1
	adc #0
	tax
	pla
* lda <bf+16+32  ;ofset
* ldx >bf+16+32
	ldy #0
	jsr fano

	lda <adl0+320
	ldx >adl0+320
	jsr set_hv
	lda bf
	clc
	adc #16+160
	pha
	lda bf+1
	adc #0
	tax
	pla
* lda <bf+16+160 ;unpack
* ldx >bf+16+160
	ldy #0
	jsr fano

* dekompresja
* glowna proc
*------------

* lda bf+8   ;liczba znacznikow 1bit
* sta ln
* lda bf+9
* sta ln+1

	lda bf
	clc
	adc <16+288
	tax
	lda bf+1
	adc >16+288
	tay
* ldx <bf+16+288  ;spakowane dane
* ldy >bf+16+288
	stx stc+1
	sty stc+2

	ldy #4
	lda <out_	; IND docelowy
	sta ind
	clc		; bf 4..5 rozmiar
	adc buf_,y	; niespakowanych danych
	iny
	sta lln+1
	lda >out_	; LLN HLN koniec danych
	sta ind+1
	adc buf_,y
	sta hln+1

* init licznik LIC
	lda #$ff
	sta lic

*-----------
lop	sty $d01a

	jsr gbit	; 0 - unpack
	bcs dp_ofs	; 1 - match_len, ofset

dp_unp	equ *
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
	sta of+1

	lda ind		; IND=IND-OFS
	sta __adr+1
;	sec
of	sbc #0		; CLC ustawione
	sta adr+1	; czyli doda 1
	lda ind+1
	sta __adr+2
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
__adr	sta $ffff,y	; sta (ind),y
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
lp_	lda tre02,y	; if TRE02<>0 then SKP
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

	lda #0       ;next link=0
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
	bne lp_
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

bf	dta a(0)
;ratio brk
;lng   dta a(0)
;lnght dta a(0)

*-----

dir	ldy #3
	mva:rpl kat,y	nam+3,y-

	jsr cbuf
	lda #$ff
	sta mfil+1

	ldx #$10
	ldy #6
	lda #3
	jsr open

	ldx <buf+ofs_	; dla wycentrowania
	ldy >buf+ofs_
	stx x
	sty x+1

	lda #0
	sta rob

lp	ldx x		; pliki jako rekordy
	ldy x+1		; po 32 bajty
	jsr a_adr
	ldx <32
	ldy >32
	jsr a_len
	lda #5
	ldx #$10
	jsr read
	tya
	bmi stp

	jsr header	; <>HIP,RIP
	lda ofs
	bmi lp
	jsr x32
	inc rob
	bne lp

stp	ldy #31		; zapamietaj - FREE
fr	lda (x),y
	sta free,y
	lda #32
	sta (x),y
	dey
	bpl fr

	ldy rob
	dey
	sty mfil+1
	ldx #$10
	jsr clos

	lda x+1		; dir powyzej $9f00
	cmp #$9f
	scc
	sta run+1

shw	jsr chng
	jsr vopi

	lda mfil+1
	cmp #$ff
	beq kky

	ldy #10
inv	lda scr+ofs2+of_x,y     ;invers
	ora #$80
	sta scr+ofs2+of_x,y
	dey
	bpl inv

kky	lda #$9b
	bne kq
	lda #$9b
	sta kky+1
	lda:cmp:req 20
	jmp dir

kq	jsr key
	cmp #14
	beq up
	cmp #15
	beq dw
	cmp #12
	beq ok
	cmp #33
	beq new
	cmp #156
	beq esc
	cmp #44
	beq tab
	cmp #13
	beq inf_
	cmp #18
	beq cnt_

; cmp #62
; beq sys_

	cmp #31
	beq drv
	cmp #30
	beq drv
	cmp #29
	beq drv
	cmp #27
	beq drv
	cmp #26
	beq drv
	cmp #24
	beq drv
	cmp #51
	beq drv
	cmp #53
	beq drv
	jmp kky

inf_	jmp inf
cnt_	jmp cnt
;sys_ jmp cyf

esc	jmp ($a)

tab	jmp rip

drv	tay
	lda $fb51,y
	sta nam+1
	sec
	sbc #32
	sta titl+3

new	lda #0
	sta up+1
	jmp dir

up	lda #0
	beq upq
	dec up+1
upq	jmp shw

dw	lda mfil+1	; nie przesuwaj jesli
	cmp #$ff	; brak plikow
	beq dwq

	lda up+1
mfil	cmp #0
	beq dwq
	inc up+1
dwq	jmp shw

ok	ldx up+1
	ldy #32-16
	jsr mnoz
	pha
	txa
	clc
	adc <buf+ofs_
	sta x
	pla
	adc >buf+ofs_
	sta x+1
	ldy #2
	ldx #0
ps	lda (x),y
	sta nam+3,x
	cmp #32
	beq hl
	iny
	inx
	cpx #8
	bne ps
hl	lda #'.'
	sta nam+3,x
	inx
	ldy #10
	lda (x),y
	sta nam+3,x
	iny
	lda (x),y
	sta nam+4,x
	iny
	lda (x),y
	sta nam+5,x
	lda #$9b
	sta nam+6,x

	jsr header

	ldx #0
	ldy ofs
nag	lda hea,y
	sec
	sbc #32
	sta load+8,x
	iny
	inx
	cpx #3
	bne nag

	jsr copi
	lda ofs
; cmp #0
	beq rip_
	cmp #3
	beq hip_
	cmp #6
	beq tip_
	jmp fatal

rip_	jmp loa
hip_	jmp lhip
tip_	jmp LoadTIP

header	lda #0		; sprawdzanie ext
	sta ofs
nh	ldx ofs
	ldy #10
hh	lda hea,x
	cmp (x),y
	bne nx
	inx
	iny
	cpy #12
	bne hh
	rts

nx	lda ofs
	clc
	adc #3
	sta ofs
	cmp #6+3
	bne nh
	lda #$80
	sta ofs
	rts

cyf	lda #2
	eor #1
	sta cyf+1
	ldx #10
	cmp #2
	seq
	ldx #16
	stx dec+1
	ldx #80
	jsr yesno
	lda rip+1
	beq *+8
	jsr ripinf
	jsr pckinf
	jmp kky

inf	lda #1
	eor #1
	sta inf+1
	ldx #0
	jsr yesno
	jmp kky

cnt	lda #0
	eor #1
	sta cnt+1
	ldx #40
	jsr yesno
	jmp kky

yesno	sta dod3+1
	asl @
	clc
dod3	adc #0
	tay
	mva yn,y	scr+160+34,x
	mva yn+1,y	scr+160+34+1,x
	mva yn+2,y	scr+160+34+2,x
	jsr vopi
	rts

*---
* pliki na ekran
*---
chng	ldy #12		; kasuje komunikat i/o
	lda #0
	sta:rpl scr+1,y-

	lda #17		; ile plikow
	sta rob

	ldx up+1	; ruch w gore, w dol
	ldy #32-16
	jsr mnoz
	pha
	txa
	clc
	adc <buf
	sta x
	pla
	adc >buf
	sta x+1

	ldx <scr+of_x
	ldy >scr+of_x
	stx sy+1
	sty sy+2

ch	ldy #2
	ldx #0
c_	lda (x),y
	sec
	sbc #32
sy	sta $ff00,x
	cmp #$9b
	iny
	inx
	cpx #11
	bne c_

	jsr x32

	adw sy+1 #szscr

	dec rob
	bne ch
	rts

x32	adw x #32-16
	rts

cbuf	mwa #buf cb+1

	ldx #32		; czysc buf dla dir...
	txa
	ldy #0
cb	sta buf,y
	iny
	bne cb
	inc cb+2
	dex
	bne cb
	rts

;---	INT
intl	ldx <dli3
	ldy >dli3
	lda gfx+1
	and #$f
	beq d1
	ldx <dli4
	ldy >dli4

d1	jsr dl_sw

	lda $d209
	sta old_+1

klik	jsr wai
	mva >o2		ad+1
	mva >o2+$1000	adr2+1
	mva >o2+$2000	adr3+1
	ldx #4
	ldy #0
	jsr kl

	jsr wai
	mva >o1		ad+1
	mva >o1+$1000	adr2+1
	mva >o1+$2000	adr3+1
	ldx #0
	ldy #4
	jsr kl

	lda $d20f
	and #4
	bne klik
	lda $d209
old_	cmp #$ff
	beq klik

	jmp out

wai	lda:cmp:req 20
	rts

kl	mva 704,x k4+1
	mva 705,x k1+1
	mva 706,x k2+1
	mva 707,x k3+1

	mva 704,y k4_+1
	mva 705,y k1_+1
	mva 706,y k2_+1
	mva 707,y k3_+1
	rts

*---

pal	:9 brk
ltxt	brk
wyso	brk
szer	brk
_wo	dta a(0)
mk	brk
ma	brk
rob	dta a(0)
ofs	dta a(0)
phip	dta a(0),b(2),b(4),b(6),b(8)
	dta b($a),b($c),b($e)
hea	dta c'RIPHIPTIP'
hea_	dta a($ffff),a($6010),a($7f4f)
kat	dta c'*.*',b($9b)
nam	dta c'D1:'
	:13 brk
titl	dta b($56),d' D1:*.*  '
ver	:28 brk
	dta d' ',b($42)
load	dta d'LOADING     PICTURE'
io	dta d'i/o error'
yn	dta d'YesNo DecHex'

bar	:80 brk
free	:40 brk
nul	:40 brk
;info :160 brk
opis	:256 brk
	
scr	:680 brk

*---
buf_	:256 brk
buf	equ *

	lda $301
	cmp #0
	sne
	lda #8
	clc
	adc #16
	sta titl+3
	adc #32
	sta nam+1

	ldx #5
	ldy #0
	tya
cls	sta:rne bar,y+
	inc cls+2
	dex
	bne cls

	ldx <scr
	ldy >scr
	lda #17
	stx x
	sty x+1
	sta rob

ek	lda #$56	; kody znakow ramki wpisywane na sztywno
	ldy #0
	sta (x),y
	lda #$42
	ldy #39
	sta (x),y

	adw x #40

	dec rob
	bne ek

	ldy #39
bb	mva #$4d bar,y
	mva #$4e bar+40,y
	dey
	bpl bb

	lda #$56
	sta nul
	sta info
	sta info+40
	sta info+80
	sta info+120

	lda #$42
	sta nul+39
	sta info+39
	sta info+79
	sta info+119
	sta info+159

	mva #$51 bar
	mva #$45 bar+39
	mva #$5a bar+40
	mva #$43 bar+79

	ldy #15

tt	mva txt,y	scr+22,y
	mva txt+16,y	scr+40+22,y
	mva txt+32,y	scr+80+22,y

	mva txt+48,y	scr+160+22,y
	mva txt+64,y	scr+200+22,y
	mva txt+80,y	scr+240+22,y

	mva txu,y	scr+320+22,y
	mva txu+16,y	scr+360+22,y
	mva txu+32,y	scr+400+22,y
	mva txu+48,y	scr+440+22,y
	mva txu+64,y	scr+480+22,y

	mva #2		mm,y

	dey
	bpl tt

	ldy #27-2
kk	lda tx,y
	jsr int
	sta ver+2,y
	dey
	bpl kk

	lda #$0d
	jsr clal
	lda #0
	sta inf+1      ;info Yes

;---	kopiuj pod ROM

	jsr wai
	jsr sof
 
	ldy #$f
cp_	mva _lmsk,y lmsk,y
	mva _hmsk,y hmsk,y
	dey
	bpl cp_
 
	ldy #0
cp__	lda .adr mv00,y
	sta TipView,y
	lda .adr(mv00)+$100,y
	sta TipView+$100,y
	iny
	bne cp__

	jsr son

	mwa #go start+1
	jmp go

*---

txt	dta d'      TAB - VIEW'
	dta d'1-8,SPACE - DIR '
	dta d' CTRL+ESC - QUIT'

	dta d' I - INFO   Yes '
	dta d' C - CENTER Yes '
;	dta d' S - SYSTEM Dec '
	dta d'                '

txu	dta d'  Mode:         '
	dta d' Width:         '
	dta d'Height:         '
	dta d'  Pack:         '
	dta d'Unpack:         '

_lmsk	dta l($8000),l($4000),l($2000)
	dta l($1000),l($800),l($400)
	dta l($200),l($100),l($80)
	dta l($40),l($20),l($10)
	dta l(8),l(4),l(2),l(1)

_hmsk	dta h($8000),h($4000),h($2000)
	dta h($1000),h($800),h($400)
	dta h($200),h($100),h($80)
	dta h($40),h($20),h($10)
	dta h(8),h(4),h(2),h(1)


.local	mv00,TipView

hlp	equ $80

ant1	equ $d800
ant2	equ ant1+$400

gr9     equ $2010
gra     equ gr9+$2000
grb     equ gra+$2000

*---

	mwa #nmi	$fffa
	mwa #ant2	$230

	mva #$80	tip_+1

	jsr create

	lda #$40	; normalnie jest wartosc $40
	sta $d40e	; ok moze dzialac przerwanie DLI
	
	lda $d209
	sta old_+1

klik    lda $d40b
        cmp #4
        bne klik

	ldy #119
tip_	lda #$40
	ldx #$c0

	sta $d40a
	sta $d01b

	sta $d40a
	stx $d01b

	eor #$c0
	sta tip_+1

	dey
	bne tip_

	lda $231
	eor >ant1^ant2
	sta $231

	mva #$00 $d012
	sta $d01a

	mva #$02 $d013
	mva #$04 $d014
	mva #$06 $d015
	mva #$08 $d016
	mva #$0a $d017
	mva #$0c $d018
	mva #$0e $d019

	lda $d20f
	and #4
	bne klik
	lda $d209
old_	cmp #$ff
	bne quit

	jmp klik
quit	rts		; wyjscie

*---
wai	lda:cmp:req 20
	rts
*---

nmi	pha
	sta $d40f
 
	inc $14
	mwa $230 $d402

	pla
	rti

;---
	
create	mwa #gr9	g9
	mwa #gra+40	ga
	mwa #grb	gb
	mwa #ant1	hlp

	lda #60
	sta ile
cr	jsr get_b
	jsr get_9
	jsr get_b
	jsr get_a
	dec ile
	bne cr

	ldx >ant2
	jsr ant_end

;---
	mwa #gr9+40	g9
	mwa #gra	ga
	mwa #grb	gb
	mwa #ant2	hlp
	
	lda #60
	sta ile
cr_	jsr get_b
	jsr get_a
	jsr get_b
	jsr get_9
	dec ile
	bne cr_

	ldx >ant1

ant_end	sbw hlp #3

        ldy #0
	lda #$41
	sta (hlp),y
	tya
	iny
	sta (hlp),y
	iny
	txa
	sta (hlp),y
	rts

;---
	
get_9	ldx g9
	lda g9+1
	jsr _crea

	adw g9 #80
	rts
	
get_b	ldx gb
	lda gb+1
	jsr _crea

	adw gb #40
	rts
	
get_a	ldx ga
	lda ga+1
	jsr _crea

	adw ga #80
	rts

_crea	ldy #2
	sta (hlp),y
	dey
	txa
	sta (hlp),y
	dey
	lda #$4f
	sta (hlp),y
	
	adw hlp #3
	rts

;---
g9	:2 brk
ga	:2 brk
gb	:2 brk
ile	brk
;---

.endl

*---
	run start

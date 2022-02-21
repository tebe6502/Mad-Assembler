
	org $8000
tvol	ins 'mod8.tab'


mem    equ $600
tadcl  equ $FF00
tadch  equ tadcl+48
tapat  equ tadch+48
kod    equ tapat+48
tab_1  equ kod+96

patno  equ 0        ;(1)
patend equ patno+1  ;(1)
pataed equ patend+1 ;(1)
patadr equ pataed+1 ;(2)
cnts   equ patadr+2 ;(1)
pause  equ cnts+1   ;(1)
nr0    equ pause+1  ;(1)
nr1    equ nr0+1    ;(1)
nr2    equ nr1+1    ;(1)
nr3    equ nr2+1    ;(1)

vbl    equ $d8

sng    equ $400
tivol  equ sng+$80	;glosnosc sampla

tstrl  equ tivol+$20
trepl  equ tstrl+$20
tendl  equ trepl+$20	;lsb dl. sampla

tstrh  equ tendl+$20
treph  equ tstrh+$20
tendh  equ treph+$20	;msb dl. sampla

tlenl  equ tendh+$20
tab_3  equ tlenl+$20
tlng   equ tab_3+$20
tlen   equ tlng+$20
tadr   equ tlen+16
tbnk   equ tadr+16

tse    equ $80		;(2)
hlp    equ tse+2	;(2)
ad     equ hlp+2	;(2)
tmp    equ ad+2		;(4)
nr_ins equ tmp+4	;(1)
nr_bnk equ nr_ins+1	;(1)
lic    equ nr_bnk+1	;(1)
link   equ lic+1	;(2)
pse    equ link+2	;(2)
_by    equ pse+2	;(1)
_wo    equ _by+2	;(2)

vl     equ $d800	; tablica glosnosci VOLUME

*---

mod37	equ $2000	; adres tymczasowy dla programu playera
strt	equ $0700	; adres docelowy dla programu playera (koniecznie od poczatku strony pamieci)

*---
	org strt,mod37


* ---	MOD PLAYER

player			; <--- koniecznie od poczatku strony pamieci

.proc	play	, $0000	; <--- PLAY asemblujemy od adresu $0000

 dta d'           '	; <--- troche danych aby przesunac calosc do granicy strony zerowej
inf3 dta d'SPACE-play  ESC-exiô'
s_pl dta d' samples-'
memo dta d'No memorů'

pmain	equ *
bank0	lda #$fe
	sta $d301

ist_0	lda #0
iad0_m	adc #0
	sta ist_0+1
	lda p_0c+1
iad0_s	adc #0
	sta p_0c+1
	bcc p_0c
	inc p_0c+2
	lda p_0c+2
ien0_s	cmp #0
	bcc p_0c

ire0_m	lda #0
	sta p_0c+1
ire0_s	lda #0
	sta p_0c+2
	jmp bank1

p_0c	ldx $ffff
ivol10	lda vl,x
ch0	sta $d600

bank1	lda #$fe
	sta $d301

ist_1	lda #0
iad1_m	adc #0
	sta ist_1+1
	lda p_1c+1
iad1_s	adc #0
	sta p_1c+1
	bcc p_1c
	inc p_1c+2
	lda p_1c+2
ien1_s	cmp #0
	bcc p_1c

ire1_m	lda #0
	sta p_1c+1
ire1_s	lda #0
	sta p_1c+2
	jmp bank2

p_1c	ldx $ffff
ivol11	lda vl,x
ch1	sta $d601

bank2	lda #$fe
	sta $d301

ist_2	lda #0
iad2_m	adc #0
	sta ist_2+1
	lda p_2c+1
iad2_s	adc #0
	sta p_2c+1
	bcc p_2c
	inc p_2c+2
	lda p_2c+2
ien2_s	cmp #0
	bcc p_2c

ire2_m	lda #0
	sta p_2c+1
ire2_s	lda #0
	sta p_2c+2
	jmp bank3

p_2c	ldx $ffff
ivol12	lda vl,x
ch2	sta $d602

bank3	lda #$fe
	sta $d301

ist_3	lda #0
iad3_m	adc #0
	sta ist_3+1
	lda p_3c+1
iad3_s	adc #0
	sta p_3c+1
	bcc p_3c
	inc p_3c+2
	lda p_3c+2
ien3_s	cmp #0
	bcc p_3c

ire3_m	lda #0
	sta p_3c+1
ire3_s	lda #0
	sta p_3c+2
	jmp p_e

p_3c	ldx $ffff
ivol13	lda vl,x
ch3	sta $d603

p_e	dey
	beq pat
	jmp pmain

*-----------------
*requests

pat	ldy #vbl

	dec cnts
	beq pre
	jmp pmain	; <--- petla PMAIN koniecznie w obszarze strony zerowej, tutaj jej koniec

pre	lda #0		; <--- to poza strona zerowa
	sta patend

	lda #$fe
	sta $d301

*---------------------------
* track  0

i_0	ldy #1
	lda (patadr),y
	tax
	and #$1f
	beq i_0c
	tay
	sta nr0
	lda tivol-1,y
	sta ivol10+2

i_0c	txa
	and #$c0
	beq i_0f
	tax
	cpx #$40
	bne *+8
	ldy #2
	lda (patadr),y
	sta ivol10+2
	cpx #$c0
	bne *+8
	ldy #2
	lda (patadr),y
	sta pause
	cpx #$80
	bne *+4
	stx patend

i_0f	ldy #0
	lda (patadr),y
	beq i_1
	tax
	lda tadcl-1,x
	sta iad0_m+1
	lda tadch-1,x
	sta iad0_s+1

	ldy nr0
	lda tab_3-1,y
	sta bank0+1

	lda tstrl-1,y
	sta p_0c+1
	lda tstrh-1,y
	sta p_0c+2

	lda tendh-1,y
	sta ien0_s+1

	lda trepl-1,y
	sta ire0_m+1
	lda treph-1,y
	sta ire0_s+1

* track 1

i_1	ldy #4
	lda (patadr),y
	tax
	and #$1f
	beq i_1c
	tay
	sta nr1
	lda tivol-1,y
	sta ivol11+2

i_1c	txa
	and #$c0
	beq i_1f
	tax
	cpx #$40
	bne *+8
	ldy #5
	lda (patadr),y
	sta ivol11+2
	cpx #$c0
	bne *+8
	ldy #5
	lda (patadr),y
	sta pause
	cpx #$80
	bne *+4
	stx patend

i_1f	ldy #3
	lda (patadr),y
	beq i_2
	tax
	lda tadcl-1,x
	sta iad1_m+1
	lda tadch-1,x
	sta iad1_s+1

	ldy nr1
	lda tab_3-1,y
	sta bank1+1

	lda tstrl-1,y
	sta p_1c+1
	lda tstrh-1,y
	sta p_1c+2

	lda tendh-1,y
	sta ien1_s+1

	lda trepl-1,y
	sta ire1_m+1
	lda treph-1,y
	sta ire1_s+1

* track 2

i_2	ldy #7
	lda (patadr),y
	tax
	and #$1f
	beq i_2c
	tay
	sta nr2
	lda tivol-1,y
	sta ivol12+2

i_2c	txa
	and #$c0
	beq i_2f
	tax
	cpx #$40
	bne *+8
	ldy #8
	lda (patadr),y
	sta ivol12+2
	cpx #$c0
	bne *+8
	ldy #8
	lda (patadr),y
	sta pause
	cpx #$80
	bne *+4
	stx patend

i_2f	ldy #6
	lda (patadr),y
	beq i_3
	tax
	lda tadcl-1,x
	sta iad2_m+1
	lda tadch-1,x
	sta iad2_s+1

	ldy nr2
	lda tab_3-1,y
	sta bank2+1

	lda tstrl-1,y
	sta p_2c+1
	lda tstrh-1,y
	sta p_2c+2

	lda tendh-1,y
	sta ien2_s+1

	lda trepl-1,y
	sta ire2_m+1
	lda treph-1,y
	sta ire2_s+1

* track 3

i_3	ldy #10
	lda (patadr),y
	tax
	and #$1f
	beq i_3c
	tay
	sta nr3
	lda tivol-1,y
	sta ivol13+2

i_3c	txa
	and #$c0
	beq i_3f
	tax
	cpx #$40
	bne *+8
	ldy #11
	lda (patadr),y
	sta ivol13+2
	cpx #$c0
	bne *+8
	ldy #11
	lda (patadr),y
	sta pause
	cpx #$80
	bne *+4
	stx patend

i_3f	ldy #9
	lda (patadr),y
	beq i_e
	tax
	lda tadcl-1,x
	sta iad3_m+1
	lda tadch-1,x
	sta iad3_s+1

	ldy nr3
	lda tab_3-1,y
	sta bank3+1

	lda tstrl-1,y
	sta p_3c+1
	lda tstrh-1,y
	sta p_3c+2

	lda tendh-1,y
	sta ien3_s+1

	lda trepl-1,y
	sta ire3_m+1
	lda treph-1,y
	sta ire3_s+1

i_e	lda patend
	bne i_en

	lda patadr
	clc
	adc #12
	sta patadr
	lda patadr+1
	adc #0
	sta patadr+1
	cmp pataed
	bcc i_end

i_en	inc patno
	ldx patno
patmax	cpx #0
	bcc i_ens

	lda #6
	sta pause
	ldx #0
	stx patno

i_ens	lda sng,x
	sta patadr+1
	clc
	adc #3
	sta pataed
	lda #0
	sta patadr

i_end	lda $d01f
	beq r_qu

	lda pause
	sta cnts
	ldy #vbl
_ret	jmp pmain

r_qu	jmp mov


inf2 dta d'-move cursor  RETURN-loaä'
inf1 dta d'SPACE-directorů'
erro dta d'Erroň'

	.endp		; <--- caly player miesci sie w granicy 3 pelnych stron !!! KONIECZNIE !!! co do bajta

	ert *<>player+$300

* ---	MAIN PROGRAM

mov			; <--- przepisujemy PLAYER na strone zerowa, !!! NIE MOZEMY KORZYSTAC ZE STOSU !!!
 sta cg+1		; <--- strone zerowa zapisujemy w miejsce PLAYER-a
 lda >player
 sta s3+2
 sta s4+2
 ldy #0
 sty d3+2
 sty d4+2
 ldx #3
s3 lda $ff00,y  ;$2400
 sta m2+1
d3 lda $ff00,y  ;$0000
s4 sta $ff00,y  ;$2400
m2 lda #0
d4 sta $ff00,y  ;$0000
 iny
 bne s3
 inc s3+2
 inc s4+2
 inc d3+2
 inc d4+2
 dex
 bne s3
cg lda #0
 beq r_quit
 jmp pl

r_quit jsr of
 jsr zkey

r_qt lda 764
 cmp #33
 beq _pl
 cmp #28
 beq _qui
 jmp r_qt
_qui jmp quit

_pl jsr on

 jmp mov

pl lda >vl		;graj cisze
 sta play.ivol10+2
 sta play.ivol11+2
 sta play.ivol12+2
 sta play.ivol13+2

 lda #0
 sta $d400
 sta patno
 sta patadr

 lda #6
 sta pause
 sta cnts

 lda sng
 sta patadr+1
 clc
 adc #3
 sta pataed
 jmp play.pre

quit jsr of

w_it jsr zkey
 jsr cle
 lda #0
 ldx #19
pus sta nam+7,x
 dex
 bpl pus

 p_inf	#player+play.inf1
 jsr wait_k

 jsr kat
 jmp _mod

_cn
 p_inf	#player+play.inf3
 jmp r_quit

cle ldx #0
 lda #7
 sta pse
cls_ ldy #0
cls lda nam-32,y
 sta ekran,x
 inx
 iny
 cpy #32
 bne cls
 dec pse
 bne cls_
 rts

* wczytanie MOD'a
*----------------
_e

 p_inf	#vali

 jsr wait_k
 jmp quit

_mod

 p_inf	#inf4

 ldy #127
 lda >vl
 sta tivol,y-
 rpl

 ldy #$5f
no_
 lda <vl
 sta tstrl,y
 lda >vl
 sta tstrh,y
 dey
 bpl no_

 ldy #$1f
 lda #$fe
 sta tab_3,y-
 rpl

 ldx <1084
 ldy >1084
 jsr len
 jsr _ad
 jsr adr
 jsr rea

 ldy #3
chk lda title,y		;title=M.K.
 cmp _bf+1080,y
 bne _e
 dey
 bpl chk

name ldx #19
_nam lda _bf,x
 beq _z
 jsr int
_z sta nam+7,x
 dex
 bpl _nam

 jsr _ad
 stx pse
 sty pse+1
 lda #0
 sta _co+1
_co ldx #0
_1 ldy #42		;rozmiar sampla
 lda (pse),y
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta tendl,x
 tya
 sta tendh,x
 ldy #45		;glosnosc sampla
 lda (pse),y
* cmp #65
* bcc _vk
* lda #0
_vk lsr @
 clc
 adc >vl
 sta tivol,x
 iny			;y=46
 lda (pse),y		;petla sampla
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta trepl,x
 tya
 sta treph,x
 ldy #48
 lda (pse),y		;petla sampla
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta tlenl,x
 tya
 ora tlenl,x
 sta tlenl,x

 lda pse
 clc
 adc #30
 sta pse
 scc
 inc pse+1

 inc _co+1
 lda _co+1
 cmp #31
 bne _1

 lda _bf+950		;dlugosc songu
 sta player+play.patmax+1

 lda _bf+952		;szukanie najwiekszego
 sta _mx+1		;numeru paternu
 ldy #0
 sty _mor+1
_se lda _bf+952,y
_mx cmp #0
 bcc _sk
 sta _mx+1
_sk iny
 cpy #128
 bne _se
 ldy _mx+1
 iny
 sty tse		;ilosc paternow

 cpy #48
 bcc cn

 p_inf	#much
 jsr wait_k
 jmp quit

cn ldy #15		;incjowanie tablic
 lda #$40
__o sta tadr,y		;adresu bufora
 sta tlen,y		;dlugosci bufora
 sta tbnk,y		;zajetosci bufora
 dey
 bpl __o

 iny
 sty tse+1		;liczba sampli=0
 ldy #30		;Dlugosci sampli
__e ldx tendh,y		;w stronach pamieci+1
 lda tendl,y
 beq __k
 inx
__k txa
 beq __p
 inx
__p txa
 sta tlng,y
 beq _ze
 inc tse+1
_ze dey
 bpl __e
 jsr inf_m

 jsr on
 ldy tse
 dey
 cpy #24
 bcs j0
 ldx #$14		;od $1400-$d000
 lda >$d000-$1400
 jmp bb
j0 lda tapat,y
 cmp #$3e
 bne j1
 lda #$d0		;od $4000-$d000
 jmp ba
j1 bcs ba		;od $????-$d000
 clc
 adc #3
 sta tadr
 lda #$d0
 sec
 sbc tadr
 jmp bc

ba ldx #$40
 sec
 sbc #$40
bb stx tadr
bc sta tlen
 sta tbnk

 ldy #127		;numery kolejnych
_pz ldx _bf+952,y	;patternow w songu
 lda tapat,x
 sta sng,y
 dey
 bpl _pz

_mor ldy #0		;adres paternu w pamieci
 jsr on
 lda tapat,y
 sta hlp+1
 jsr of
 lda #0
 sta hlp
 sta tse+1

_thi
 ldx <4		;konwersja patternow
 ldy >4
 jsr len		;x,y -> ile wczytac
 ldx <tmp
 ldy >tmp
 jsr adr
 jsr rea

 jsr on
 jsr cnv
 jsr of

 lda hlp		;hlp=hlp+3
 clc
 adc #3
 sta hlp
 scc
 inc hlp+1

 dec tse+1
 bne _thi
 inc _mor+1
 ldx tse
 dex
 jsr bcd
 stx ekran+29
 sty ekran+30
 dec tse
 bne _mor

 ldx #0
bmax ldy #0
 lda tlng,x
 beq __s
l_p lda tbnk,y
 cmp tlng,x
 bcs in
 dey
 bpl l_p

 p_inf	#player+play.memo
 jsr wait_k
 jmp n_x22

__s txa
 pha
smp ldx #0
 jsr bcd
 stx ekran+61
 sty ekran+62
 pla
 tax
 inx
 cpx #31
 bne bmax
 jmp n_x22

in dec smp+1
 stx nr_ins
 sty nr_bnk
 lda tlen,y
 sec
 sbc tbnk,y
 clc
 adc tadr,y
 sta tstrh,x
 sta ___b+1
 lda #0
 sec
 sbc tendl,x
 sta tstrl,x
 sta ___a+1

 jsr on
 lda tab_1,y
 and #$fe
 sta $d301
 sta tab_3,x

 ldy tlng,x
 lda ___b+1
 sta cis+2
 ldx #0
 txa
cis sta $ff00,x
 dex
 bne cis
 inc cis+2
 dey
 bne cis

 jsr ofs
 ldx nr_ins
 ldy tendh,x
 lda tendl,x		;load sampl
 tax
 jsr len
___a ldx #0
___b ldy #0
 stx hlp
 sty hlp+1
 jsr adr
 jsr rea

 jsr ons
 ldx nr_ins
 ldy #0
 sty pse
 sty pse+1
clr lda (hlp),y
 clc
 adc #$80
 sta (hlp),y
 iny
 bne __sk
 inc hlp+1
__sk inc pse
 bne __sp
 inc pse+1
__sp lda pse
 cmp tendl,x
 lda pse+1
 sbc tendh,x
 bcc clr

 ldy nr_bnk
 lda tbnk,y
 sec
 sbc tlng,x
 sta tbnk,y

 lda tlen,y
 sec
 sbc tbnk,y
 clc
 adc tadr,y
 sec
 sbc #1
 sta tendh,x
 sbc #1
 sta pse+1
 tay
 lda #0
 sta tendl,x
 sta tlng,x

 iny			;wypeln ostatnia
 sty hlp+1		;wartoscia
 lda #$ff
 sta pse
 ldy #0
 sty hlp
 lda (pse),y
wyp sta (hlp),y
 dey
 bne wyp
 jsr ofs

 ldy nr_bnk
 lda tlenl,x
 beq no_lop
 cmp #2
 beq no_lop

 lda tstrl,x
 clc
 adc trepl,x
 sta trepl,x
 lda tstrh,x
 adc treph,x
 sta treph,x
 jmp lp_

no_lop lda #0
 sta trepl,x
 lda hlp+1
 sta treph,x
lp_ jmp __s

n_x22 lda #0
 sta tse+1
ptt lda #0
 sta tse
 jsr inf_m
 jmp _cn

cnv lda tmp
 and #$f
 ora tmp+1
 beq _sil

 ldy #0
_tst lda kod,y
 cmp tmp+1
 bne pls
 lda tmp		;kod dzwieku
 and #$f
 cmp kod+1,y
 bne pls
 iny
 iny
 tya
 lsr @
 ldy #0
 sta (hlp),y		;czestotliwosc

 lda tmp+2		;oblicz nr instr
 lsr @
 lsr @
 lsr @
 lsr @
 sta or_+1
 lda tmp
 and #$f0
or_ ora #0
 and #$1f
 ldy #1
_con sta (hlp),y	;numer instrumentu

 ldy #2
 lda #0
 sta (hlp),y
 dey			;A=1
 lda tmp+2
 and #$f
 cmp #$c
 beq _vol		;nowa glosnosc
 cmp #$f
 beq _tmp		;nowe tempo
 cmp #$d
 beq _break
 rts

_sil tay
 sta (hlp),y
 iny
 jmp _con

_break lda #$80
 ora (hlp),y
 sta (hlp),y
 rts

_vol lda #$40
 ora (hlp),y
 sta (hlp),y
 ldy #2
 lda tmp+3		;parametr komendy
* cmp #65
* bcc _vo
* lda #0
_vo lsr @
 clc
 adc >vl
 sta (hlp),y
 rts

_tmp lda tmp+3
 cmp #$20
 bcs _tq
 lda #$c0
 ora (hlp),y
 sta (hlp),y
 ldy #2
 lda tmp+3		;parametr komendy
 and #$1f
 sta (hlp),y
_tq rts

pls iny
 iny
 cpy #96
 bne j_tst
 rts

j_tst jmp _tst

ons sei
 lda #0
 sta $d40e
 lda $d301
 and #$fe
 jmp jon

on sei
 lda #0
 sta $d40e
 lda #$fe
jon sta $d301
 rts

ofs lda $d301
 ora #1
 jmp jof

of lda #$ff
jof sta $d301
 lda #$40
 sta $d40e
 cli
 rts

_mot stx hlp
 asl @
 rol hlp
 ldy hlp
 rts

_ad	ldx <_bf
	ldy >_bf
	rts


p_inf	.proc	(.word yx) .reg

	stx pf_+1
	sty pf_+2

	ldy #31
sc	mva	nam-32,y	info,y-
	rpl

	iny
pf_	lda $ffff,y
	bmi p_q
	sta info+1,y
	iny
	jmp pf_
p_q	and #$7f
	sta info+1,y
	rts

	.endp


wait_k
	lda 764
	cmp #33
	bne wait_k
zkey	lda #$ff
	sta 764
	rts

inf_m jsr cle
 ldx #0
in_5 lda patt,x
 sta ekran+20,x
 lda player+play.s_pl,x
 sta ekran+52,x
 lda trck,x
 sta ekran+84,x
 inx
 cpx #9
 bne in_5

 ldx tse		;patterny
 stx ptt+1
 jsr bcd
 stx ekran+29
 sty ekran+30

 ldx tse+1		;sample
 stx smp+1
 stx n_x22+1
 jsr bcd
 stx ekran+61
 sty ekran+62

 ldx player+play.patmax+1	;dlugosc sng
 jsr bcd
 stx ekran+93
 sty ekran+94
 rts

bcd stx _by
 lda #0
 sta _wo
 sta _wo+1
 ldx #8
 sed
_c1 asl _by
 lda _wo
 adc _wo
 sta _wo
 rol _wo+1
 dex
 bne _c1
 cld
 pha
 lsr @
 lsr @
 lsr @
 lsr @
 ora #$10
 tax
 pla
 and #$f
 ora #$10
 tay
 lda _wo+1
 and #$f
 ora #$10
 rts

int cmp #96
 bcc *+6
 cmp #128
 bcc *+21

 cmp #224
 bcs *+17

 cmp #32
 bcc *+14

 cmp #128
 bcc *+6
 cmp #160
 bcc *+6

 sec
 sbc #32
 rts

 adc #64
ovr rts			;wyjscie

rea lda #0
 sta k+1
 sta k_+1

s1 equ *
k  lda #0
d  cmp #0
k_ lda #0
d_ sbc #0
 bcs ovr

 jsr ons
 ldy i+1
 lda mem,y
m  sta $ffff
 jsr ofs

 inc m+1	;m=m+1
 sne
 inc m+2

 inc k+1	;k=k+1
 sne
 inc k_+1

 inc i+1	;i=i+1

i lda #0
 cmp rx+1
 bne s1

r_sec lda link		;czytanie sektora
 sta $30a		;< nr sektora
 lda link+1
 sta $30b		;> nr sektora
 ldx <mem
 ldy >mem
 jsr sio		;wczytaj
rx ldx #0
 lda mem,x
 and #%00000011
 sta link+1		;link nastepny sektor
 lda mem+1,x
 sta link

 lda #0
 sta i+1
rt jmp s1

bf sta $ffff,x
 rts

len stx d+1
 sty d_+1
 rts

adr stx m+1
 sty m+2
 rts

set sta cod+1 ;kod operacji
 stx lng+1    ;< dlugosc sektora
 sty lng+6    ;> dlugosc sektora
 rts

sio stx $304  ;< adres bufora
 sty $305     ;> adres bufora
cod lda #$4e  ;$4e konifguracja
 sta $302
 lda #$40   ;$40 odczyt
 sta $303
lng lda #0  ;< dlugosc bufora
 sta $308
 lda #0     ;> dlugosc bufora
 sta $309
 jsr $e459  ;wywolanie procedury
 bmi err
 rts

err pla
 pla
 pla
 pla
 jsr cle

 p_inf	#player+play.erro
 ldx $303
 jsr bcd
 sta info+7
 stx info+8
 sty info+9
 jsr wait_k
 jmp w_it

neg lda up+1
 asl @
 asl @
 asl @
 asl @
 asl @
 tay
dlg ldx #12
ng lda ekran+1,y
 eor #$80
 sta ekran+1,y
 iny
 dex
 bpl ng
 rts

kat jsr cle
 lda #$31 ;nr stacji+$30
 sta $300
 jsr _ad
 stx bf+1
 sty bf+2
 ldx #1   ;nr stacji
 stx $301
 dex
 stx file+1 ;liczba plikow=0
 stx up+1   ;wskaznik pliku=0
 lda #32    ;wyczysc
cl jsr bf
 dex
 bne cl

 lda #7
 sta $306 ;timeout

* Density
 lda #$53  ;odczyt statusu stacji
 sta $302
 jsr $e453
 ldx <256  ;256 bajtow
 ldy >256  ;w sektorze
 lda $2ea
 and #%00100000
 bne rd
 ldx <128  ;128 bajtow
 ldy >128  ;w sektorze

* Directory
rd lda #$52  ;$52 odczyt sektora
 jsr set
 ldx <$169 ;pierwszy nr sektora
 ldy >$169 ;z katalogiem dysku
 stx $30a
 sty $30b
 jsr _ad
 stx ad
 sty ad+1
 stx bf+1
 sty bf+2
 lda #4
 sta lic
l_ jsr sio
 lda $304
 clc
 adc lng+1
 sta $304
 tax
 lda $305
 adc lng+6
 sta $305
 tay
 inc $30a
 dec lic
 bne l_

* Create directory
 lda #4
 sta lic
a_ ldy #0
b_ lda (ad),y
 bpl _a

da tya
 clc
 adc #16
 tay
 jmp sk

_a ldx #2
 tya
 pha
 clc
 adc ad
 sta ts+1
 lda ad+1
 adc #0
 sta ts+2
 ldy #13
ts lda $ffff,y
 cmp tmod,x
 bne fail
 iny
 dex
 bpl ts

 pla
 tay
 jmp cc

fail pla
 tay
 jmp da

cc ldx #0
c_ lda (ad),y
 jsr bf
 iny
 inx
 cpx #16
 bne c_

 inc file+1
 lda bf+1
 clc
 adc #16
 sta bf+1
 bcc sk
 inc bf+2
sk cpy #$80
 bne b_
 lda ad
 clc
 adc lng+1
 sta ad
 lda ad+1
 adc lng+6
 sta ad+1
 dec lic
 bne a_

* Change file
cre jsr _ad
 stx bu+1
 sty bu+2

 ldx <ekran-3
 ldy >ekran-3
 stx ek+1
 sty ek+2

 ldx file+1
 bne _b
 pla
 pla
 jmp w_it
_b ldy #5
bu lda $ffff,y
 sec
 sbc #32
ek sta $ffff,y
 iny
 cpy #16
 bne bu
 lda bu+1
 clc
 adc #16
 sta bu+1
 bcc sp
 inc bu+2
sp lda ek+1
 clc
 adc #32
 sta ek+1
 bcc si
 inc ek+2
si dex
 bne _b
 dec file+1

 txa     ;A=0
 jsr neg
key jsr zkey
ee lda 764
 cmp #255
 beq ee
 cmp #15
 beq up
 cmp #14
 beq do
 cmp #33
 beq new
 cmp #12
 beq loa
 jmp key

new jmp kat
up lda #0
file cmp #0
 beq d_q
 jsr neg
 inc up+1
 jmp ss

do lda up+1
 beq d_q
 jsr neg
 dec up+1
ss jsr neg
d_q jmp key

* Load file
loa lda up+1
 asl @
 asl @
 asl @
 asl @
 clc
 adc <_bf
 sta ad
 lda >_bf
 adc #0
 sta ad+1

 lda lng+1
 sec
 sbc #3
 sta rx+1  ;dlugosc sektora-3

 ldy #3    ;pierwszy sektor
 lda (ad),y
 sta link
 iny
 lda (ad),y
 sta link+1
 lda #$60
 sta rt
 jsr r_sec
 lda #$4c
 sta rt
 rts

inf4 dta d'Loadinç'
patt dta d'patterns-'
trck dta d'  tracks-'
much dta d'Only 48 patternó'
vali dta d'Valid MOD filĺ'
tmod dta c'DO'
title dta c'M.K.'

dl dta d'ppppppp',b($42),a(obr)
 dta d'""',b($70),b($42),a(obr)
 dta b($42),a(ekran),d'"""""""""'
 dta b($42),a(obr+64),b($41),a(dl)

obr dta d'‰••••••••••••••••••••••••••••••Ź'
 dta d'INERTIA ver 3.7 by Madteam ',b(7),d'96™'
 dta d'‹Ś'
ekran dta d'                              ™'
 dta d'                              ™'
 dta d'                              ™'
 dta d'                              ™'
 dta d'                              ™'
 dta d'                              ™'
 dta d'                              ™'
nam dta d'Name:                         ™'
 dta d'                              ™'
info dta d'                              ™'


* ---	BUFOR
; przy pierwszych uruchomieniu zostanie wykonana n/w procedura inicjalizacji playera
; potem obszar ten zostanie zamazany przez wczytywane MOD-y

_bf ldy #0
 sty $d208
 ldx #3
 stx $d20f
o1 lda player,y
o2 sta strt,y
 dey
 bne o1
 inc o1+2
 inc o2+2
 dex
 bne o1

; lda <dl
; sta 560
; lda >dl
; sta 561
	mwa #dl 560

 lda #$21
 sta 559
 lda #1
 sta 580

 lda #$82
 sta 710
 lda #$0c
 sta 709

sr ldy #0		; detekcja pamieci dodatkowej
 tya
 sta _bnk,y-
 rne

 ldy #0
 tya
 ora #%00000001
 and #%11101111
 sta $d301
 sta $4000
 iny
 bne *-12

 ldy #0
tst tya
 ora #%00000001
 and #%11101111
 sta $d301
 ldx $4000
 lda $4000
 eor #$ff
 sta $4000
 cmp $4000
 bne _ty
 eor #$ff
 sta $4000
 cmp $4000
 bne _ty
 lda #1
 sta _bnk,x
_ty iny
 bne tst

 ldy #0
 ldx #0
sav lda _bnk,y
 beq *+11
 tya
 sta tb_1,x
 inx
 cpx #16
 beq *+5
 iny
 bne sav
 dex
 stx bmax+1
 bne sl

 p_inf	#xms
 jsr wait_k
 jmp sr

sl
 lda >tvol
 sta hlp+1
 lda >vl
 sta pse+1
 lda #0
 sta hlp
 sta pse

 p_inf	#cfg

 ldx #5
cb lda ban,x
 sta ekran+23,x
 dex
 bpl cb

 ldx #16
cf lda cov,x
 sta ekran+2,x
 lda pok,x
 sta ekran+34,x
 dex
 bpl cf

 ldx bmax+1
 inx
 jsr bcd
 stx ekran+29
 sty ekran+30

 lda #18
 sta dlg+1
 lda #0
 sta up+1
 jsr neg
wi lda 764
 cmp #$ff
 beq wi
 cmp #14
 beq u_p
 cmp #15
 beq d_n
 cmp #12
 beq r_t
wi_ jsr zkey
 jmp wi

u_p jsr neg
 lda #0
 sta up+1
 jsr neg
 jmp wi_

d_n jsr neg
 lda #1
 sta up+1
 jsr neg
 jmp wi_

r_t jsr on
 lda #12
 sta dlg+1
 lda up+1
 bne poky
 lda #$ea		; jesli COVOX to "remujemy" rozkazy "LSR @"
 sta md
 sta md+1
 sta md+2
 sta md+3
 sta md+4
 sta md+5
 jmp po_

poky lda #$d2
 sta player+play.ch0+2
 sta player+play.ch1+2
 sta player+play.ch2+2
 sta player+play.ch3+2
 lda #1
 sta player+play.ch0+1
 lda #3
 sta player+play.ch1+1
 lda #5
 sta player+play.ch2+1
 lda #7
 sta player+play.ch3+1

po_ ldx #33		; przepisanie tablicy glosnosci pod ROM i jej ewentualna modyfikacja dla POKEY-a
 ldy #0
or lda (hlp),y
md lsr @
 lsr @
 lsr @
 lsr @
 ora #$10
 sta (pse),y
 dey
 bne or
 inc hlp+1
 inc pse+1
 dex
 bne or

 ldy #0
rel lda tidl,y
 sta tadcl,y
 iny
 bne rel
 jsr of
 jsr cle
 jmp quit

cfg dta d'-change configuratioî'
xms dta d'I need extra memorů'
cov dta d'COVOX-8bit sample'
pok dta d'POKEY-4bit sample'
ban dta d'banks-'

tidl dta l(51),l(54),l(57),l(60),l(64)
 dta l(68),l(72),l(76),l(81)
 dta l(85),l(91),l(96),l(102)
 dta l(108),l(114),l(121),l(128)
 dta l(136),l(144),l(152),l(161)
 dta l(171),l(181),l(192),l(203)
 dta l(215),l(228),l(242),l(256)
 dta l(271),l(287),l(304),l(323)
 dta l(342),l(362),l(384),l(406)
 dta l(431),l(456),l(483),l(512)
 dta l(542),l(575),l(609),l(645)
 dta l(683),l(724),l(767)

tidh dta h(51),h(54),h(57),h(60),h(64)
 dta h(68),h(72),h(76),h(81)
 dta h(85),h(91),h(96),h(102)
 dta h(108),h(114),h(121),h(128)
 dta h(136),h(144),h(152),h(161)
 dta h(171),h(181),h(192),h(203)
 dta h(215),h(228),h(242),h(256)
 dta h(271),h(287),h(304),h(323)
 dta h(342),h(362),h(384),h(406)
 dta h(431),h(456),h(483),h(512)
 dta h(542),h(575),h(609),h(645)
 dta h(683),h(724),h(767)

tpt dta b($f9),b($fc),b($41),b($44)
 dta b($47),b($4a),b($4d),b($50)
 dta b($53),b($56),b($59),b($5c)
 dta b($5f),b($62),b($65),b($68)
 dta b($6b),b($6e),b($71),b($74)
 dta b($77),b($7a),b($7d),b($14)
 dta b($17),b($1a),b($1d),b($20)
 dta b($23),b($26),b($29),b($2c)
 dta b($2f),b($32),b($35),b($38)
 dta b($3b),b($3e),b($cd),b($ca)
 dta b($c7),b($c4),b($c1),b($be)
 dta b($bb),b($b8),b($b5),b($b2)

kd dta a($6b0),a($650),a($5f4),a($5a0)
 dta a($54c),a($500),a($4b8),a($474)
 dta a($434),a($3f8),a($3c0),a($380)

 dta a($358),a($328),a($2fa),a($2d0)
 dta a($2a6),a($280),a($25c),a($23a)
 dta a($21a),a($1fc),a($1e0),a($1c5)

 dta a($1ac),a($194),a($17d),a($168)
 dta a($153),a($140),a($12e),a($11d)
 dta a($10d),a($fe),a($f0),a($e2)

 dta a($d6),a($ca),a($be),a($b4)
 dta a($aa),a($a0),a($97),a($8f)
 dta a($87),a($7f),a($78),a($71)

tb_1 dta d'                '

_bnk equ *


* ---	START
; obszar pamieci o adresie MOD37 zostanie przepisany pod adres STRT
; na koncu nastapi skok do inicjalizacji playera 'JMP _BF'

	org $0600

start	.proc

	ldx #18
	ldy #0
s	lda mod37,y
d	sta strt,y
	iny
	bne s
	inc s+2
	inc d+2
	dex
	bne s

	jmp _bf

	.endp

* ---
	run start

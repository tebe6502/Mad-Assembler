/*
  wszystkie skoki warunkowe typu *+??, *-?? zastapione zostaly przez odpowiednie etykiety

  makro rozkazy XASM'a zostaly uzyte oszczednie aby nie "zaciemniac" kodu
  najczesciej dotycza one "SNE" dla zastapienia "BNE *+5"

  ostatnie zmiany: 24.12.2005
*/

filndn	equ $e0
filord	equ filndn+2
patno	equ filord+2
patend	equ patno+1
pataed	equ patend+1
patadr	equ pataed+1
cnts	equ patadr+2
pause	equ cnts+1
istr_4	equ pause+1
tse	equ istr_4+3
_ol	equ tse+2
_sc	equ _ol+2
_sr	equ _sc+2
fpisz	equ _sr+2
_dx	equ fpisz+2
lop	equ _dx+2
hlp	equ lop+2
pse	equ hlp+2

_bnk	equ $bb00
_bf	equ $bb00

 icl 'icl/PM.ASM'

 opt h-o+
 
 ins 'tracker.fnt'	;$2000
 ins 'volume.tab'	;$8800
 ins '_pmain.obx'	;$4528

 opt h+
 org $2400

dl dta b($50),b($42),a(skr)
 dta d'""""""""""""""""""',b($82),b($82)
 dta d'""""""""'
 dta b($41),a(dl)

init jsr move
 lda #0
 ldx #3
lp0
 sta _offst,x
 dex
 bpl lp0

 sta _clpat._5+1
 sta _a2+1
 sta _clall._n5+1
 sta winpoz
 sta p_pat

 lda #$40
 sta _atmp+2
 lda #0
 sta _atmp
 sta _atmp+1
 sta n_pat
 sta p_pat
 sta winpoz
 sta fi_0+1
 sta p_trk
 sta okt
 sta o_win
 sta o_licz
 sta p_ord
 sta patno
 lda #1
 sta n_inst
 sta instr
 jsr filneg
 jsr neg
 jsr cl_k

 tsx         ;zapamietaj wskaznik
 stx status  ;stosu

 jmp _clws

.local keybd

 jsr wait
 lda 764
 cmp #231
 sne	;bne *+5
 jmp _exit   ;opusc program
 cmp #173
 sne	;bne *+5
 jmp _trans  ;transpozycja
 cmp #150
 sne	;bne *+5
 jmp _exchg  ;zmiana instrumentu
 cmp #71
 sne	;bne *+5
 jmp inc_p   ;zwieksz nr. patternu
 cmp #70
 sne	;bne *+5
 jmp dec_p   ;zmniejsz nr.patternu
 cmp #15
 sne	;bne *+5
 jmp dn_p    ;przes. w dol patt.
 cmp #14
 sne	;bne *+5
 jmp up_p    ;przes. w gore patt.
 cmp #7
 sne	;bne *+5
 jmp i_p     ;przes. w prawo patt.
 cmp #6
 sne	;bne *+5
 jmp d_p     ;przes. w lewo patt.
 cmp #135
 sne	;bne *+5
 jmp i_in    ;zwieksz nr. sampla
 cmp #134
 sne	;bne *+5
 jmp d_in    ;zmniejsz nr.sampla
 cmp #136
 sne	;bne *+5
 jmp o_jmp   ;skocz do proc. orders
 cmp #39
 sne	;bne *+5
 jmp _play  ;odgrywaj modul
 cmp #172
 sne	;bne *+5
 jmp l_io   ;procedury i/o
 cmp #165
 sne	;bne *+5
 jmp p_ply  ;odgrywaj pattern
 cmp #54
 sne	;bne *+5
 jmp p_cli  ;pattern do bufora
 cmp #55
 sne	;bne *+5
 jmp p_ilc  ;pattern z bufora
 cmp #244
 sne	;bne *+5
 jmp _clws  ;wyczysc cala pamiec
 cmp #218
 sne	;bne *+5
 jmp _coptr ;track do bufora
 cmp #216
 sne	;bne *+5
 jmp _buptr ;track z bufora
 cmp #119
 sne	;bne *+5
 jmp _movi  ;insert pos. track
 cmp #116
 sne	;bne *+5
 jmp _movd  ;delete pos. track
 cmp #219
 beq _j18
 cmp #243
 beq _j18+5
 cmp #245
 beq _j18+10
 cmp #240
 beq _j18+15
 jsr _offtrack
 jsr _pput
 jsr _ppoz
 jmp keybd

.endl


.local _j18

 lda #0
 jmp _skp	;skok do poz 00
 lda #$10
 jmp _skp       ;skok do poz 10
 lda #$20
 jmp _skp       ;skok do poz 20
 lda #$30       ;skok do poz 30

_skp
 sta winpoz
 jsr srt2
 jsr neg
 jsr cl_k
 jmp keybd

.endl
 

.local i_in

 lda n_inst
 cmp #31
 beq _skp
 inc n_inst
_skp
 jsr p_ins
 jsr cl_k
 jmp keybd

.endl


.local d_in

 lda n_inst
 cmp #1
 beq _skp
 dec n_inst
_skp
 jsr p_ins
 jsr cl_k
 jmp keybd

.endl


.local i_p

 lda p_trk
 cmp #3
 bne _skp
 jsr s_eor
 jsr s_trk
 jsr s_eor
 jsr cl_k
 jmp keybd

_skp
 inc p_trk
 jsr s_eor
 jsr s_trk
 jsr s_eor
 jsr cl_k
 jmp keybd

.endl


.local d_p

 lda p_trk
 bne _skp
 jsr s_eor
 jsr s_trk
 jsr s_eor
 jsr cl_k
 jmp keybd

_skp
 dec p_trk
 jsr s_eor
 jsr s_trk
 jsr s_eor
 jsr cl_k
 jmp keybd

.endl

inc_p lda n_pat
 cmp #33        ;patternow jest 34
 beq in_1
 inc n_pat
 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor
in_1 jsr cl_k
 jmp keybd

dec_p lda n_pat
 beq in_2
 dec n_pat
 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor
in_2 jsr cl_k
 jmp keybd

dn_p lda winpoz
 cmp #63
 beq tam2
 inc winpoz
 jsr cl_k
 jsr srt2
 jsr neg
 jmp tam2

up_p lda winpoz
 beq tam2
 dec winpoz
 jsr cl_k
 jsr srt2   ;wyrzuc pattern na ekran
 jsr neg
 jmp keybd

tam2 jsr cl_k
 jmp keybd

filneg lda <scr+284	;ustaw adres na
 sta filndn		;ekranie
 lda >scr+284
 sta filndn+1
 clc
 lda filndn
fi_0 adc #0		;w ktorym track'u jest
 sta filndn		;kursor
 scc	;bcc *+4
 inc filndn+1
 rts

s_eor jsr filneg	;eor na pozycji
 jsr fneg
 rts

fneg ldy #7		;eor 8 komorek
lp1
 lda (filndn),y		;pamieci ekranu
 eor #$80
 sta (filndn),y
 dey
 bpl lp1
 rts

neg ldx #7		;srodkowa linia
ng_2 lda scr+284,x	;okna patt.
 eor #$80
ng_3 sta scr+284,x
 dex
 bpl ng_2
 rts

srt2 jsr set_h0
 lda winpoz
 tax
 sec
 sbc #7
 bpl skp0
 ldx #0
 jmp _sr3

skp0
 lda winpoz
 sec
 sbc #7
 tax
_sr3 beq skp2

skp1
 clc
 lda hlp
 adc #12
 sta hlp
 bcc skp3
 inc hlp+1

skp3
 dex
 bne skp1

skp2
 jsr set_sc
 lda #15
 sta licznik
 lda winpoz
 sta p_pat
 sec
 sbc #7
 bpl skp4
 lda #0
 jmp skp5

skp4
 lda winpoz
 sec
 sbc #7

skp5
 sta p_pat
 jsr start
 jsr cl_k
 rts

s_trk ldx p_trk ;ustawia adres
 lda _tn2,x
 sta ng_2+1
 sta ng_3+1
 lda _tn3,x
 sta ng_2+2
 sta ng_3+2

 lda _tn4,x
 sta fi_0+1
 rts

_put0 stx pomoc
 ldx #7
 lda #' '-32
lp2
 sta bf_tmp,x
 dex
 bpl lp2

 ldy #11
 jsr writ2
 ldy #20
 jsr writ2
 ldy #29
 jsr writ2
 ldy #38
 jsr writ2
 ldy #1
 lda #' '-32
 sta (pse),y
 iny
 sta (pse),y
 ldx pomoc
 rts

writ2 ldx #7
lp3
 lda bf_tmp,x
 sta (pse),y
 dey
 dex
 bpl lp3
 rts

start lda winpoz
 sec
 sbc #7
 bpl _st0
 tax

lp4
 jsr _put0
 jsr in_pse
 dec licznik
 inx
 bne lp4
 jmp _st2

_st0 lda winpoz
 cmp #56
 bcc _st2
 beq _st2
 lda #56
 sec
 sbc winpoz       ;A=56-winpoz
 clc
 adc licznik
 sta licznik
 tay
 tax
 jsr set_sc

lp5
 jsr in_pse
 dey
 bne lp5

lp6
 jsr _put0
 jsr in_pse
 inx
 cpx #15
 bne lp6

 jsr set_sc

_st2 ldx p_pat   ;wyswietla pattern
 jsr p_hex       ;na ekranie
 ldx cf_1
 lda hex,x
 ldy #1
 sta (pse),y
 iny
 ldx cf_1+1
 lda hex,x
 sta (pse),y

 jsr y_0
 ldy #4
 jsr write
 jsr n_hlp

 jsr y_0
 ldy #13
 jsr write
 jsr n_hlp

 jsr y_0
 ldy #22
 jsr write
 jsr n_hlp

 jsr y_0
 ldy #31
 jsr write
 jsr n_hlp
 jsr in_pse

 inc p_pat
 dec licznik
 bne _st2
 ldx n_pat
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e2+10
 ldx cf_1+1
 lda hex,x
 sta _e2+11
 rts

write ldx nuta ;wyswietla w danym
 lda t_nut,x   ;tracku nute,instrument
 sta (pse),y   ;komende
 iny
 lda t_okt,x
 sta (pse),y
 iny
 lda _hash,x
 sta (pse),y
 iny

 ldx instr
 beq zer0
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta (pse),y
 iny
 ldx cf_1+1
 lda hex,x
 sta (pse),y
 iny

_w1 ldx komend
 beq zer1
 lda hex,x
 sta (pse),y
 iny

 ldx kom
 beq zer2
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta (pse),y
 iny
 ldx cf_1+1
 lda hex,x
 sta (pse),y
 rts

zer0 lda #'-'-32
 sta (pse),y
 iny
 sta (pse),y
 iny
 jmp _w1

zer1 lda #'0'-32
 sta (pse),y
 iny
 sta (pse),y
 iny
 sta (pse),y
 rts

zer2 lda #'0'-32
 sta (pse),y
 iny
 sta (pse),y

skp15
 rts

set_h0 jsr set_hl ;ustawia adres pocz.
 ldx n_pat    ;wyswietlania patternu
 beq skp15

lp7
 clc
 lda hlp
 adc <$300
 sta hlp
 lda hlp+1
 adc >$300
 sta hlp+1
 dex
 bne lp7
 rts

set_hl lda #0
 sta hlp
 lda tapat
 sta hlp+1
 rts

set_sc lda <scr
 sta pse
 lda >scr
 sta pse+1
 rts

n_hlp clc
 lda hlp
 adc #3
 sta hlp
 scc	;bcc *+4
 inc hlp+1
 rts

in_pse clc
 lda pse
 adc <40
 sta pse
 scc	;bcc *+4
 inc pse+1
 rts

p_hex stx pomoc
 txa
 jsr _h
 sta cf_1
 lda pomoc
 and #$f
 sta cf_1+1
 rts

*-----------------------------------*
*  wyslij dane z patternu na ekran  *
*-----------------------------------*
y_0 ldy #1
 lda (hlp),y
 and #$1f
 beq y_0c
 sta instr

 ldy #0
 lda (hlp),y
 and #$3f
 sta nuta
 jmp y_4

y_0c sta instr
 lda #36
 sta nuta


.local y_4

 ldy #1
 lda (hlp),y
 and #$e0
 cmp #$20
 beq _skp
 cmp #$40
 beq y_vol
 cmp #$80
 beq y_tmp
 jmp y_1

_skp
 lda #$d
 sta komend
 lda #0
 sta kom
 rts

.endl


y_vol ldy #2
 lda (hlp),y
 ldx #0

lp8
 cmp tab_a1,x
 beq skp16
 inx
 cpx #33
 bne lp8

 ldx #0

skp16
 txa
 asl @
 sta kom
 lda #$c
 sta komend
 rts

y_tmp ldy #2
 lda (hlp),y
 sta kom
 lda #$f
 sta komend
 rts

y_1 lda #0
 sta komend
 sta kom
 rts

*-----------------------*
*   edycja nut,komend   *
*-----------------------*

s_vol ldx #$c   ;volume
 ldy #$40
 jmp j_kom
s_brk ldx #$d   ;break
 ldy #$20
 jmp j_kom
s_tmp ldx #$f   ;tempo
 ldy #$80
 jmp j_kom

skp17
 jmp _up    ;obsluga klawiszy

skp18
 jmp _dn    ;(zmiana oktaw)

_pput sta pomoc ;wpisywanie nut
 cmp #142       ;i komend
 beq skp17
 cmp #143
 beq skp18
 cmp #146
 beq s_vol    ;volume
 cmp #186
 beq s_brk    ;break
 cmp #184
 beq s_tmp    ;tempo
 ldx #0
 cmp #33
 bne _s0

 lda #'-'-32
lp9
 sta bf_tmp,x
 inx
 cpx #5
 bne lp9

 lda #'0'-32
lp10
 sta bf_tmp,x
 inx
 cpx #8
 bne lp10

 lda #0
 sta nuta
 sta instr
 jmp _s3
_s0 lda n_inst
 sta instr
 lda pomoc
 cmp t_klw,x
 bne _s1
 jsr _pr
 txa
 clc
 adc przes
 tax
 stx nuta
 lda t_nut,x
 sta bf_tmp
 lda t_okt,x
 sta bf_tmp+1
 lda _hash,x
 sta bf_tmp+2
 lda #'0'-32
 sta bf_tmp+5
 sta bf_tmp+6
 sta bf_tmp+7
 jsr play_sampl
 jsr _ondli
_s3 jsr set_in
 jsr _pscr

.local 

 lda winpoz
 cmp #63
 beq _skp
 inc winpoz
 jsr srt2

_skp
 jsr neg
 jsr cl_k
 rts

.endl


_s1 inx
 cpx #24
 sne	;bne *+3
 rts

 jmp _s0

_up lda okt   ;podnies oktawe 1 wyzej
 cmp #2
 beq _up1
 inc okt
 inc okt
 ldx okt
 lda oktawa,x
 sta _e1+9
 inx
 lda oktawa,x
 sta _e1+10
 inx
 lda oktawa,x
 sta _e1+11
 jsr _pr
_up1 jsr cl_k
 rts

_dn lda okt   ;opusc oktawe nizej
 beq _up1

 dec okt
 dec okt
 ldx okt
 lda oktawa,x
 sta _e1+9
 inx
 lda oktawa,x
 sta _e1+10
 inx
 lda oktawa,x
 sta _e1+11
 jsr _pr
 jsr cl_k

skp19
 rts

_pr lda #0
 sta przes
 lda okt
 beq skp19
 lsr @
 tay

lp11
 clc
 lda przes
 adc #12
 sta przes
 dey
 bne lp11
 rts

_pscr ldy #7     ;wypisz na ekran
lp12
 lda bf_tmp,y    ;i do pamieci to co
 sta (filndn),y  ;wklepales z kla-
 dey             ;wiatury
 bpl lp12

 ldx n_pat
 lda tapat,x
 sta hlp+1
 lda #0
 sta hlp

 ldx winpoz
 beq skp20

lp13
 clc
 lda hlp
 adc <12
 sta hlp
 bcc skp21
 inc hlp+1

skp21
 dex
 bne lp13

skp20
 ldx p_trk
 lda _tn5,x

 clc
 adc hlp
 sta hlp
 lda hlp+1
 adc #0
 sta hlp+1

 lda nuta
 ldy #0
 sta (hlp),y
 iny
 lda instr
 sta (hlp),y
 rts

_ppoz ldx patno  ;wypisz pozycje w
 jsr p_hex       ;orders
 ldx cf_1
 lda hex,x
 sta _e3+10
 ldx cf_1+1
 lda hex,x
 sta _e3+11
 rts


set_in
 ldx instr
 beq zer_in     ;ustaw nr. instrumentu
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta bf_tmp+3
 ldx cf_1+1
 lda hex,x
 sta bf_tmp+4
 rts

zer_in lda #'-'-32
 sta bf_tmp+3
 sta bf_tmp+4
 rts


*----------------------------------*
*    wypisz dane o instrumencie    *
*----------------------------------*
p_ins ldx n_inst
 stx instr
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+8
 ldx cf_1+1
 lda hex,x
 sta _e4+9

 ldx n_inst
 lda tivol,x
 sec
 sbc #$d8
 asl @
 tax
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+48
 ldx cf_1+1
 lda hex,x
 sta _e4+49

 ldx n_inst
 lda tendl,x
 sec
 sbc tstrl,x
 sta pomoc1
 lda tendh,x
 sbc tstrh,x
 tax
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+88
 ldx cf_1+1
 lda hex,x
 sta _e4+89

 ldx pomoc1
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+90
 ldx cf_1+1
 lda hex,x
 sta _e4+91

 ldx n_inst
 lda trepl,x
 sec
 sbc tstrl,x
 sta pomoc1
 lda treph,x
 sbc tstrh,x
 tax
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+128
 ldx cf_1+1
 lda hex,x
 sta _e4+129

 ldx pomoc1
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+130
 ldx cf_1+1
 lda hex,x
 sta _e4+131

 ldx n_inst
 lda tendl,x
 sec
 sbc trepl,x
 sta pomoc1
 lda tendh,x
 sbc treph,x
 tax
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+168
 ldx cf_1+1
 lda hex,x
 sta _e4+169

 ldx pomoc1
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _e4+170
 ldx cf_1+1
 lda hex,x
 sta _e4+171

 jsr _stname

 lda #0
 ldx #22
lp14
 sta _e1+13,x
 dex
 bpl lp14

 jsr on

 ldy #21
lp15
 lda (hlp),y
 bne skp22
 dey
 bpl lp15

skp22
 iny
 sty _clall._n5+1

 ldy #21        ;wypisz nazwe sampla
lp16
 lda (hlp),y
 tax
 lda chg,x
 sta _e1+13,y
 dey
 bpl lp16
 jsr of
 rts

_kill lda tapat ;wykiluj RAM
 sta hlp+1
 lda #0
 sta _a2+1
 sta _clpat._5+1
 sta _clall._n5+1
 tay
 sta hlp
lp17
 sta (hlp),y
 iny
 bne lp17
 
 ldy #0
 inc hlp+1
 ldx hlp+1
 cpx #$ac
 bne lp17

 lda #$ff
lp18
 sta sng,y
 iny
 cpy #128
 bne lp18
 lda tapat
 sta sng

 jsr on
 lda #0
 tax
lp19
 sta $c600,x
 sta $c700,x
 sta $c800,x
 sta $480,x
 sta $4c0,x
 inx
 bne lp19
 jsr of

 ldy #31
 lda #$d8

lp20
 sta tivol,y
 dey
 bpl lp20
 rts


o_jmp jsr s_eor
 jsr orders
 jmp keybd


*--------------------*
*    zagraj MOD'a    *
*--------------------*
_play jsr _volmv

_mst ldx #0    ;od ktorej pozycji
 stx patno     ;grac utwor

 lda #6
 sta pause
 lda sng,x
 sta patadr+1
 clc
 adc #3
 sta pataed

 lda #$ea
 sta _type
 sta _type+1
 sta _type+2

 ldx #0
 stx patadr
 stx $d400


.local lp21

 lda sng,x
 cmp #$ff
 beq _skp
 inx
 cpx #128
 bne lp21
 jmp skp23

_skp

.endl


 stx patmax+1

skp23
 jsr _p0rom
 jsr cl_ram
 ldy #0
 sty $d200
 sty $d202
 sty $d204
 sty $d206
 sty $d208
 jsr pre
 jsr _ondli
 jmp keybd


*----------------------*
*    zagraj pattern    *
*----------------------*
p_ply jsr _volmv
 ldx n_pat
 lda tapat,x
 sta patadr+1
 clc
 adc #3
 sta pataed
 lda #0
 sta patadr

 lda #1
 sta patmax+1

 lda #6
 sta pause


.local 

 ldx winpoz
 beq _skp
_lp
 clc
 lda patadr
 adc #12
 sta patadr
 scc	;bcc *+4
 inc patadr+1
 dex
 bne _lp

_skp

.endl


 lda #$4c
 sta _type
 lda <_prod0
 sta _type+1
 lda >_prod0
 sta _type+2

 jsr _p0rom
 jsr cl_ram
 ldy #0
 sty $d200
 sty $d202
 sty $d204
 sty $d206
 sty $d208
 sty patno
 sty $d400
 jsr pre
 jsr _ondli
 jmp keybd


*-----------------------*
*    wczytanie MOD'a    *
*-----------------------*
_rmod jsr _kill
 jsr _mod
 jsr _null
 lda #1
 sta n_inst
 sta instr
 jsr p_ins
 lda #0
 sta winpoz
 sta o_licz
 sta o_win
 sta n_pat
 sta p_pat
 lda #5
 sta _licz2
 jsr s_pse
 jsr _shlp
 lda o_licz
 sta p_ord
 jsr _ost
 jsr set_hl
 jsr set_sc
 lda #15
 sta licznik
 jsr start
 jsr fneg
 rts

*-------------------------*
*    wpisywanie komend    *
*-------------------------*
j_kom sty komend
 jsr fneg
 lda hex,x
 sta bf_tmp+5
 ldy #5
 eor #$80
 sta (filndn),y
 lda #0
 sta bf_tmp+6
 sta bf_tmp+7
 iny
 lda #'?'-32
 eor #$80
 sta (filndn),y
 iny
 lda #'-'-32
 eor #$80
 sta (filndn),y
 jsr cl_k

skp8
 lda 764
 cmp #$ff
 beq skp8
 ldy #6
 ldx #0

skp6
 cmp o_klw,x
 bne skp7
 stx _yp
 lda hex,x
 sta bf_tmp,y
 jmp _h2

skp7
 inx
 cpx #16
 bne skp6
 jsr cl_k
 rts

_h2 lda #'?'-32
 eor #$80
 ldy #7
 sta (filndn),y
 dey
 lda bf_tmp+6
 eor #$80
 sta (filndn),y
 jsr cl_k

skp11
 lda 764
 cmp #$ff
 beq skp11
 ldy #7
 ldx #0

skp9
 cmp o_klw,x
 bne skp10
 stx _yp+1
 lda hex,x
 sta bf_tmp,y
 jmp _h4
 
skp10 
 inx
 cpx #16
 bne skp9
 jsr cl_k
 rts


.local _h4

 jsr cl_k
 ldy #5
_lp
 lda bf_tmp,y
 sta (filndn),y
 iny
 cpy #8
 bne _lp

.endl


 lda _yp
 jsr _q
 ora _yp+1
 sta param

 ldx n_pat
 lda tapat,x
 sta hlp+1
 lda #0
 sta hlp


.local 

 ldx winpoz
 beq _skp
_lp
 clc
 lda hlp
 adc <12
 sta hlp
 scc	;bcc *+4
 inc hlp+1
 dex
 bne _lp

_skp

.endl


 ldx p_trk
 lda _tn5,x

 clc
 adc hlp
 sta hlp
 lda hlp+1
 adc #0
 sta hlp+1

 ldy #1
 lda (hlp),y
 and #$1f
 ora komend
 sta (hlp),y
 lda komend
 cmp #$40     ;kod komendy volume
 bne skp12
 lda param
 lsr @
 tax
 lda tab_a1,x
 ldy #2
 sta (hlp),y
 jmp skp13

skp12
 lda param
 ldy #2
 sta (hlp),y

skp13
 lda winpoz
 cmp #63
 beq skp14
 inc winpoz
 jsr srt2

skp14
 jsr neg
 jsr cl_k
 rts

 icl 'icl/_VOLMV.ASM'
 icl 'icl/LOA_MOD.ASM'
 icl 'icl/PMAIN.ASM'
 icl 'icl/IO.ASM'

t_klw dta b(23),b(62),b(22),b(58)
 dta b(18),b(16),b(61),b(21)
 dta b(57),b(35),b(01),b(37)

 dta b(47),b(30),b(46),b(26)
 dta b(42),b(40),b(29),b(45)
 dta b(27),b(43),b(51),b(11)

bf_tmp dta d'   _____'
tmp dta d'    '
pomoc brk
pomoc1 brk
licznik brk
instr brk
nuta brk
n_pat brk
komend brk
kom brk
cf_1 dta a(0)
winpoz brk
p_trk brk
p_pat brk
okt brk
przes brk
n_inst brk  ;numer sampla
status brk  ;stan wskaznika stosu
param brk
l_poz brk
n_ins brk
n_bnk brk
il_bnk brk
pom_1 dta d'  '
tab_1 dta d'                                '

oktawa dta d'1:2:3'
t_nut dta d'ccddeffggaahccddeffggaahccddeffggaah-'
t_okt dta d'111111111111222222222222333333333333-'
_hash dta d'-#-#--#-#-#--#-#--#-#-#--#-#--#-#-#--'


tapat dta b($46),b($49),b($4c)
 dta b($4f),b($52),b($55),b($58)
 dta b($5b),b($5e),b($61),b($64)
 dta b($67),b($6a),b($6d),b($70)
 dta b($73),b($76),b($79),b($7c)
 dta b($7f),b($82),b($85),b($88)
 dta b($8b),b($8e),b($91),b($94)
 dta b($97),b($9a),b($9d),b($a0)
 dta b($a3),b($a6),b($a9)

kod equ *
 dta a($358),a($328),a($2fa),a($2d0)
 dta a($2a6),a($280),a($25c),a($23a)
 dta a($21a),a($1fc),a($1e0),a($1c5)

 dta a($1ac),a($194),a($17d),a($168)
 dta a($153),a($140),a($12e),a($11d)
 dta a($10d),a($fe),a($f0),a($e2)

 dta a($d6),a($ca),a($be),a($b4)
 dta a($aa),a($a0),a($97),a($8f)
 dta a($87),a($7f),a($78),a($71)
 dta a($00) ;kod 37 nuty

_tn2 dta l(scr+284),l(scr+293),l(scr+302),l(scr+311)
_tn3 dta h(scr+284),h(scr+293),h(scr+302),h(scr+311)
_tn4 dta b(0),b(9),b(18),b(27)
_tn5 dta b(0),b(3),b(6),b(9)

sng equ $400
tivol equ sng+128
tstrl equ tivol+32
tstrh equ tstrl+32
trepl equ tstrh+32
treph equ trepl+32
tendl equ treph+32
tendh equ tendl+32
tlenl equ tendh+32
tlenh equ tlenl+32
tab_3 equ tlenh+32

tab_a1 dta b($d8),b($d9),b($da),b($db)
 dta b($dc),b($dd),b($de),b($df)
 dta b($e0),b($e1),b($e2),b($e3)
 dta b($e4),b($e5),b($e6),b($e7)
 dta b($e8),b($e9),b($ea),b($eb)
 dta b($ec),b($ed),b($ee),b($ef)
 dta b($f0),b($f1),b($f2),b($f3)
 dta b($f4),b($f5),b($f6),b($f7)
 dta b($f7)

_txt0 dta c'QMMMMMMMMMMMMME'
      dta b($56),d'i/o error    ',$42
      dta c'ZNNNNNNNNNNNNNC'

_txt1 dta c'QMMMMMMMMMMMMME'
      dta b($56),d'out of memory',$42
      dta c'ZNNNNNNNNNNNNNC'

_txt2 dta c'QMMMMMMMMMMMMMMMME'
      dta b($56),d'd1:noname**.mod ',$42
      dta c'ZNNNNNNNNNNNNNNNNC'

_txt3 dta c'QMMMMMMMMMMMMMMMMME'
      dta b($56),d'too many patterns',$42
      dta c'ZNNNNNNNNNNNNNNNNNC'

_txt4 dta c'QMMMMMMMMMMMMMMME'
      dta b($56),d'sample too long',$42
      dta c'ZNNNNNNNNNNNNNNNC'

_txt6 dta c'QMMMMMMMMMMMMMMME'
      dta b($56),d'transpose 00-00',$42
      dta c'ZNNNNNNNNNNNNNNNC'

_txt7 dta c'QMMMMMMMMMMMMMME'
      dta b($56),d'exchange 00-00',$42
      dta c'ZNNNNNNNNNNNNNNC'

_loa dta d'                '

 icl 'icl/FUNC2.ASM'
 icl 'icl/ORDERS.ASM'
 icl 'icl/XCHG.ASM'
 icl 'icl/TRANS.ASM'

*-----------------*
*  out of memory  *
*-----------------*

.local _oomem

 jsr n_12
 lda #15
 sta pom_1
 ldx <_txt1
 ldy >_txt1
 jsr _wname
 jsr cl_k
_lp
 lda 764
 cmp #28
 bne _lp
 lda #15
 sta pom_1
 ldx <_txt1
 ldy >_txt1
 jsr _wname
 ldx status
 txs
 jmp keybd

.endl


*--------------------------*
*   kopiowanie patternow   *
*--------------------------*

.local p_cli

 jsr _setcli
 ldy #0
_lp
 lda (pse),y
 sta (hlp),y
 lda #0
 sta (pse),y
 iny
 bne _lp
 inc pse+1
 inc hlp+1
 lda hlp+1
 cmp #$c3
 bne _lp
 jsr _offcli
 jsr cl_k
 jmp keybd

.endl


.local p_ilc

 jsr _setcli
 ldy #0
_lp
 lda (hlp),y
 sta (pse),y
 iny
 bne _lp
 inc pse+1
 inc hlp+1
 lda hlp+1
 cmp #$c3
 bne _lp
 jsr _offcli
 jmp keybd

.endl


_offcli jsr of
 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor
 jsr cl_k
 rts

_setcli ldx n_pat
 lda tapat,x
 sta pse+1
 lda #$c0
 sta hlp+1
 lda #0
 sta pse
 sta hlp
 jsr wait
 jsr on
 rts


*---------------------------------*
*   wykiluj caly RAM i wskazniki  *
*---------------------------------*

.local _clws

 jsr _kill

 ldx #15
 lda #' '-32
_lp
 sta _txt2+19,x
 sta _clpat._nam,x
 dex
 bpl _lp

 ldx #22
_lp2
 sta _e1+13,x
 dex
 bpl _lp2

 ldx #20
_lp3
 sta _e1-22,x
 dex
 bpl _lp3

 ldx #0
 stx _clpat._5+1
 stx _a2+1
 stx _clall._n5+1

 lda #$ff
_lp4
 sta sng,x
 inx
 cpx #128
 bne _lp4
 lda tapat
 sta sng

.endl


 lda #0       ;ustaw wskazniki bufora
 sta _atmp    ;na jego poczatek
 sta _atmp+1
 lda #$40
 sta _atmp+2

 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor

 lda #0
 sta o_licz
 sta o_win
 lda #5
 sta _licz2
 jsr s_pse
 jsr _shlp
 lda o_licz
 sta p_ord
 jsr _ost
 jsr p_ins
 jsr cl_k

 jsr wait
 lda <dl
 sta $230
 lda >dl
 sta $231
 lda >$2000
 sta 756

 jsr _ondli

 lda <$c09e  ;wektor klawisza break
 sta $236
 lda >$c09e
 sta $237

 ldy #2
 sty $2c6
 dey
 sty $2da
 dey
 sty $2c8
 lda #8
 sta $2c5
 lda #20
 sta $2d9
 jmp keybd


*------------------------*
*   kopiowanie track'u   *
*------------------------*

.local _coptr

 jsr _strk
 ldy #2
_lp
 lda (pse),y
 sta (hlp),y
 lda #0
 sta (pse),y
 dey
 bpl _lp
 ldy #2
 jsr _a12pse
 lda hlp+1
 cmp #$c6
 bne _lp
 jsr _offcli
 jmp keybd

.endl


.local _buptr

 jsr _strk
 ldy #2
_lp
 lda (hlp),y
 sta (pse),y
 dey
 bpl _lp
 ldy #2
 jsr _a12pse
 lda hlp+1
 cmp #$c6
 bne _lp
 jsr _offcli
 jmp keybd

.endl


_strk ldx n_pat
 lda tapat,x
 sta pse+1
 ldx p_trk
 lda _tn5,x
 sta pse
 lda #$c3
 sta hlp+1
 lda #0
 sta hlp
 jsr wait
 jsr on
 rts

_ofdli ldx <$c0ce
 ldy >$c0ce
 stx $200
 sty $201
 rts

wait lda 20
 cmp 20
 req	;beq *-2
 rts


 org $b678
skr dta d' protracker 1.5  by profi/madteam  1997 '
    dta c'QMMMMMMMMMMMWMMMMMMMMMMMMMMMMMMMMMMMMMME'
    dta b($56),$5c,d'1 ',$5c,d'2 ',$5c,d'3 ',$5c,d'4|name:                     ',$42
_e1 dta b($56),d'oct     1:2|                          ',$42
_e2 dta b($56),d'pattern: 00',c'HRRRRRGRRRRRRRRRRRGRRRRRRRRD'
_e3 dta b($56),d'position:00|order|load module|        ',$42
    dta c'ARRRRRRRRRRR',c'I',d'     |save module|        ',$42
_e4 dta b($56),d'sample:01  |00 00|load sample|        ',$42
    dta b($56),d'volume:00  |00 00|save sample|        ',$42
    dta b($56),d'length:0000|00 00|samplename |        ',$42
    dta b($56),d'repeat:0000|00 00|songname   |        ',$42
    dta b($56),d'replen:0000|00 00|clear inst.|        ',$42
    dta c'ARRGRRRRRRRRSRRRRRFRRGRRRRRRRRSRRRRRRRRD'
scr dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta b($56),d'  |        |        |        |        ',$42
    dta c'ZNNXNNNNNNNNXNNNNNNNNXNNNNNNNNXNNNNNNNNC'

 org $ac00

_p0rom ldx #0
_pp1 lda $4528,x
 tay
 lda $0000,x
 sta $4528,x
 tya
 sta $0000,x
 inx
 cpx #$d8
 bne _pp1
 rts
     
_txt5 dta c'QMMMMMMMMMMMMMME'
      dta b($56),d'unknown format',$42
      dta c'ZNNNNNNNNNNNNNNC'      

hex dta d'0123456789abcdef'

 icl 'icl/FUNCTION.ASM'


 org $a800
 icl 'icl/MOVE.ASM'
 icl 'icl/TIDL.ASM'


 org $5c0

*--------------------------------*
*  insert pos. in window orders  *
*--------------------------------*

.local _inr

 clc
 lda o_licz
 adc o_win
 sta patno
 cmp #$7f
 bne _skp
 jsr cl_k
 jmp key2

_skp
 ldx #$7e
 ldy #$7f
_lp
 lda sng,x
 sta sng,y
 dex
 dey
 cpy patno
 bne _lp
 lda #$ff
 sta sng,y
 jmp orders

.endl


*--------------------------------*
*  delete pos. in window orders  *
*--------------------------------*

.local _der

 clc
 lda o_licz
 adc o_win
 sta patno
 cmp #$7f
 bne _skp
 jsr cl_k
 jmp key2

_skp
 lda patno
 tay
 iny
 tya
 tax
 dey
_lp
 lda sng,x
 sta sng,y
 inx
 iny
 cpy #$7f
 bne _lp
 lda #$ff
 sta sng,y
 jmp orders

.endl


_a12pse clc
 lda pse
 adc #12
 sta pse
 scc	;bcc *+4
 inc pse+1
 clc
 lda hlp
 adc #12
 sta hlp
 scc	;bcc *+4
 inc hlp+1
 rts

_h lsr @
 lsr @
 lsr @
 lsr @
 rts

_q asl @
 asl @
 asl @
 asl @
 rts

cl_k lda #$ff
 sta 764
 rts

dliv pha
 lda #$14
 sta $d40a
 sta $d018
 lda <dliv2
 sta $200
 pla
 rti

dliv2 pha
 lda #$02
 sta $d40a
 sta $d018
 lda <dliv
 sta $200
 pla
 rti

_ondli jsr wait
 lda <dliv
 sta $200
 lda >dliv
 sta $201
 lda #$c0
 sta $d40e
 rts

_ad ldx <_bf
 ldy >_bf
 stx pse
 sty pse+1
 rts

 org $8000
 icl 'icl/SELECT.ASM'

 run select

 end of file


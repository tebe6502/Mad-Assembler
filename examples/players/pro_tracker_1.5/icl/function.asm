
*------------------------*
*  insert pos. in track  *
*------------------------*

.local _movi

 ldx n_pat
 clc
 lda tapat,x
 adc #3
 sta pse+1
 ldx p_trk
 lda _tn5,x
 sec
 sbc #12
 sta pse
 bcs _skp
 dec pse+1

_skp
 sec
 lda pse
 sbc <12
 sta hlp
 lda pse+1
 sbc >12
 sta hlp+1
 ldx #63
 cpx winpoz
 beq _dh1

 ldy #2
_ds lda (hlp),y
 sta (pse),y
 dey
 bpl _ds
 ldy #2

 sec
 lda pse
 sbc #12
 sta pse
 bcs _skp2
 dec pse+1

_skp2
 sec
 lda hlp
 sbc #12
 sta hlp
 bcs _skp3
 dec hlp+1

_skp3
 dex
 cpx winpoz
 bne _ds

 lda #0
_lp
 sta (pse),y
 dey
 bpl _lp

_dh1 jmp _movd._dh0

.endl


*------------------------*
*  delete pos. in track  *
*------------------------*

.local _movd

 ldx n_pat
 lda tapat,x
 sta pse+1
 ldx p_trk
 lda _tn5,x
 sta pse
 ldx winpoz
 beq _dh3
 cpx #63
 beq _dh0

_dh2 clc
 lda pse
 adc #12
 sta pse
 bcc _skp
 inc pse+1
_skp
 dex
 bne _dh2

_dh3 clc
 lda pse
 adc <12
 sta hlp
 lda pse+1
 adc >12
 sta hlp+1

 ldx winpoz
 ldy #2
_ds1 lda (hlp),y
 sta (pse),y
 dey
 bpl _ds1

 ldy #2
 clc
 lda pse
 adc #12
 sta pse
 bcc _skp2
 inc pse+1
_skp2
 clc
 lda hlp
 adc #12
 sta hlp
 bcc _skp3
 inc hlp+1

_skp3
 inx
 cpx #63
 bne _ds1

 lda #0
_lp0
 sta (pse),y
 dey
 bpl _lp0

_dh0 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor
 jsr cl_k
 jmp keybd

.endl


*---------------------------*
*  wpisywanie nazwy sampla  *
*---------------------------*
.local _clall

 jsr _stname
 jsr on
 ldx #21
 ldy #21
_lp0
 lda (hlp),y
 sta _snam,x
 dey
 dex
 bpl _lp0
 jsr of

 ldy _n5+1
 lda #' '-32
 sta _e1+13,y
 jsr cl_k

_n6 jsr $f2f8
 cmp #$1b
 beq _endn
 cmp #$9b
 beq _endn
 cmp #$7e
 beq _del2
 bmi _skp
 eor #$80

_skp
 ldy _n5+1
 cpy #22
 beq _n6
_n5 ldy #0
 cmp #$40
 bcc _skp2
 clc
 adc #32
 sta _snam,y
 jmp _skp3

_skp2
 sta _snam,y
 sec
 sbc #32
 jmp _skp4

_skp3
 sec
 sbc #64

_skp4
 sta _e1+13,y
 lda #' '-32
 sta _e1+14,y
 inc _n5+1
 jmp _n6

_del2 ldy _n5+1
 lda #' '-32
 sta _snam,y
 sta _e1+13,y
 cpy #0
 beq _n6
 dec _n5+1
_n7 lda #' '-32
 sta _e1+12,y
 jmp _n6

_endn ldy _n5+1
 lda #' '-32
 sta _e1+13,y
 sta _snam,y
 jsr _stname
 jsr on
 ldx #21
 ldy #21
_lp1
 lda _snam,x
 sta (hlp),y
 dey
 dex
 bpl _lp1
 jsr of
 jsr cl_k
 rts

_snam dta c'                       '

.endl


*---------------------------*
*  wpisywanie nazwy utworu  *
*---------------------------*

.local _clpat

 ldy _5+1
 lda #' '-32
 sta _e1-22,y
 jsr cl_k

_6 jsr $f2f8
 cmp #$1b
 beq _endq
 cmp #$9b
 beq _endq
 cmp #$7e
 beq _del1
 bmi _skp
 eor #$80

_skp
 ldy _5+1
 cpy #20
 beq _6
_5 ldy #0
 cmp #$40
 bcc _skp2
 clc
 adc #32
 sta _nam,y
 jmp _10

_skp2
 sta _nam,y
 sec
 sbc #32
 jmp _skp3

_10 sec
 sbc #64

_skp3
 sta _e1-22,y
 lda #' '-32
 sta _e1-21,y
 inc _5+1
 jmp _6

_del1 ldy _5+1
 lda #' '-32
 sta _nam,y
 sta _e1-22,y
 cpy #0
 beq _6
 dec _5+1
_7 lda #' '-32
 sta _e1-23,y
 jmp _6

_endq ldy _5+1
 lda #' '-32
 sta _e1-22,y
 jsr cl_k
 rts

_nam dta c'                     '

.endl


*----------------------------*
*   wpisywanie nazwy pliku   *
*----------------------------*

.local _name

 jsr cl_k

 lda #18
 sta pom_1
 ldx <_txt2
 ldy >_txt2
 jsr _wname

 lda #0
 sta _a2+1
 tax
_lp0
 sta _loa,x
 sta _e4+61,x
 inx
 cpx #15
 bne _lp0

 lda #' '-32
 sta _e4+61

.endl


.local _a1

 jsr $f2f8
 cmp #$1b
 beq krzoki
 cmp #$9b
 beq _end
 cmp #$7e
 beq _del
 bmi _skp
 eor #$80

_skp
 ldy _a2+1
 cpy #15
 beq _a1

.endl


.local _a2

 ldy #0
 sta _loa,y
 sec
 sbc #32
 sta _e4+61,y
 lda #' '-32
 sta _e4+62,y
 inc _a2+1
 jmp _a1

.endl


.local _del

 ldy _a2+1
 lda #' '-32
 sta _loa,y
 sta _e4+61,y
 cpy #0
 beq _a1
 dec _a2+1
_a4 lda #' '-32
 sta _e4+60,y
 jmp _a1

.endl


.local _end

 ldy _a2+1
 sta _loa,y
 lda #' '-32
 sta _e4+61,y
 lda #18
 sta pom_1
 ldx <_txt2
 ldy >_txt2
 jsr _wname
 rts

.endl


.local krzoki

 ldy _a2+1
 lda #' '-32
 sta _e4+61,y
 lda #18
 sta pom_1
 ldx <_txt2
 ldy >_txt2
 jsr _wname
 ldx status  ;przywroc stary stan
 txs         ;wskaznika stosu
 jmp keybd

.endl


.local _wname

 stx hlp
 sty hlp+1
 lda <_e4+20
 sta pse
 lda >_e4+20      ;w x,y podaj adres
 sta pse+1        ;komunikatu
 lda #2
 sta pomoc
 ldy #0
_wi0 lda (hlp),y
 tax
 lda (pse),y
 sta (hlp),y
 txa
 sta (pse),y
 iny
 cpy pom_1  ;szerokosc textu
 bne _wi0
 ldy #0
 clc
 lda pse
 adc #40
 sta pse
 bcc _skp
 inc pse+1

_skp
 clc
 lda hlp
 adc pom_1  ;szerokosc
 sta hlp
 bcc _skp2
 inc hlp+1

_skp2
 dec pomoc
 bpl _wi0
 jsr _ondli
 rts

.endl


*-----------------------*
*   zapis instrumentu   *
*-----------------------*

.local _ssamp

 ldy n_inst
 lda tendl,y
 ora tendh,y
 bne _skp
 jsr cl_k
 rts

_skp
 jsr _name
 jsr _cl
 ldx <_loa
 ldy >_loa
 lda #8
 sta __k+1
 lda #3
 jsr _op

 ldy n_inst      ;stworz naglowek
 sec
 lda tendl,y
 sbc tstrl,y
 sta $680
 lda tendh,y
 sbc tstrh,y
 sta $681

 sec
 lda tivol,y
 sbc #$d8
 asl @
 sta $682

 sec
 lda trepl,y
 sbc tstrl,y
 sta $683
 lda treph,y
 sbc tstrh,y
 sta $684

 jsr _stname
 jsr on
 ldx #21
 ldy #21
_lp0
 lda (hlp),y
 sta $685,x
 dey
 dex
 bpl _lp0
 jsr of

 ldx <27
 ldy >27
 jsr _le
 ldx <$680
 ldy >$680
 lda #11
 jsr _re

 ldy n_inst   ;przygotuj sampla
 lda tendl,y  ;do zgrania
 sec
 sbc tstrl,y
 tax
 lda tendh,y
 sbc tstrh,y
 tay
 jsr _le

 ldy n_inst
 lda tab_3,y
 ora #1
 sta $d301
 ldx tstrl,y
 lda tstrh,y
 tay
 lda #11
 jsr _re
 jsr _cl
 jsr n_12
 jsr _ondli
 jsr cl_k
 rts

.endl


*----------------------*
*     zapis utworu     *
*----------------------*

.local _sdir

 jsr _name
 jsr bufclr

 ldx #0
_lp0
 lda _clpat._nam,x
 sta _bf,x
 inx
 cpx #20
 bne _lp0

 lda <$c600
 sta patadr
 lda >$c600
 sta patadr+1

 jsr _ad
 lda #1
 sta _go+1

_go ldx #0
_13 lda tendh,x
 bne _skp	;skok do lda tendl,x
 ldy #42
_lp1
 sta (pse),y
 iny
 cpy #49
 bne _lp1

 lda #1
 sta (pse),y
 jmp _rew

_skp
 lda tendl,x	;dlug. sampla
 sec
 sbc tstrl,x
 tay
 lda tendh,x
 sbc tstrh,x
 jsr _intel
 ldy #42
 sta (pse),y
 txa
 iny
 sta (pse),y
 ldx _go+1    ;glosnosc sampla
 lda tivol,x
 sec
 sbc #$d8
 asl @
 ldy #45
 sta (pse),y

 ldx _go+1    ;czy sampl jest
 lda tendh,x  ;zapetlony
 cmp treph,x
 beq _rer

 ldx _go+1    ;pocz petli sampla
 lda trepl,x
 sec
 sbc tstrl,x
 tay
 lda treph,x
 sbc tstrh,x
 jsr _intel
 ldy #46
 sta (pse),y
 txa
 iny
 sta (pse),y
 ldx _go+1
 lda tendl,x
 sec
 sbc trepl,x
 tay
 lda tendh,x
 sbc treph,x
 jsr _intel
 ldy #48
 sta (pse),y
 txa
 iny
 sta (pse),y
 jmp _rew

.endl


.local _rer

 ldy #46
 lda #0
_lp
 sta (pse),y
 iny
 cpy #49
 bne _lp
 lda #1
 sta (pse),y

.endl


.local _rew

 jsr on
 ldy #0
 ldx #0
_lp
 lda (patadr),y
 sta $680,x
 iny
 inx
 cpx #22
 bne _lp
 jsr of

.endl


.local

 ldx #0
 ldy #20
_lp
 lda $680,x
 sta (pse),y
 iny
 inx
 cpx #22
 bne _lp

 clc
 lda pse
 adc #30
 sta pse
 bcc _skp
 inc pse+1

_skp
 clc
 lda patadr
 adc #22
 sta patadr
 bcc _skp2
 inc patadr+1

_skp2
 inc _sdir._go+1
 lda _sdir._go+1
 cmp #32
 bne j_13
 beq _skp3

j_13 jmp _sdir._go

_skp3

.endl


.local

 ldx #0
_lp
 lda sng,x
 cmp #$ff
 beq _skp
 inx
 cpx #128
 bne _lp
 ldx #0

_skp
 stx _bf+950    ;dlugosc songu

.endl 


 lda #127
 sta _bf+951


.local

 lda tapat      ;najw. num. patternu
 sta _m1+1
 ldy #0

_lp
 lda sng,y
 cmp #$ff
 beq _skp
_m1 cmp #0
 bcc _skp2
 sta _m1+1

_skp2
 iny
 cpy #128
 bne _lp

_skp
 ldy _m1+1
 tya

 ldx #1
_m5 cmp tapat,x
 bne _skp3
 stx il_pt
 jmp _m6

_skp3
 inx
 jmp _m5

.endl


_m6 ldx #0
 ldy #0
_z5 lda sng,y
 cmp #$ff
 beq _z6
_z3 cmp tapat,x
 bne _z4
 txa
 sta _bf+952,y
 ldx #0
 iny
 jmp _z5

_z4 inx
 jmp _z3


.local _z6

 ldx #0
_lp
 lda title,x
 sta _bf+1080,x
 inx
 cpx #4
 bne _lp

.endl


 jsr _cl
 ldx <_loa   ;zapis naglowka
 ldy >_loa
 lda #8
 sta __k+1
 lda #3
 jsr _op
 ldx <1084
 ldy >1084
 jsr _le
 ldx <_bf
 ldy >_bf
 lda #11
 jsr _re

 lda tapat   ;zapis patternow
 sta pse+1
 lda #0
 sta pse

_more lda #0
 sta tse+1
 lda <_bf
 sta hlp
 lda >_bf
 sta hlp+1

_kg jsr _scnv


.local

 ldy #3
_lp
 lda tmp,y
 sta (hlp),y
 dey
 bpl _lp

 clc
 lda hlp
 adc #4
 sta hlp
 bcc _skp
 inc hlp+1

_skp
 clc
 lda pse
 adc #3
 sta pse
 bcc _skp2
 inc pse+1

_skp2

.endl


 inc tse+1
 bne _kg

 ldx <1024
 ldy >1024
 jsr _le      ;x,y -> ile zapisac
 ldx <_bf
 ldy >_bf
 lda #11
 jsr _re

 dec il_pt
 bpl _more

 lda #1
 sta _lip+1

_lip ldy #1    ;czy zapisac
 lda tstrl,y
 ora tstrh,y
 beq _jd

 ldy _lip+1
 lda tab_3,y
 ora #1
 sta $d301

 ldy _lip+1
 lda tendl,y
 sec
 sbc tstrl,y
 tax
 lda tendh,y
 sbc tstrh,y
 tay
 jsr _le
 ldy _lip+1
 ldx tstrl,y
 lda tstrh,y
 tay
 lda #11
 jsr _re

_jd inc _lip+1
 lda _lip+1
 cmp #32
 bne _lip
 jsr _cl
 jsr n_12
 jsr _ondli
 jsr cl_k
 jsr of
 rts


.local _scnv

 lda #0
 ldy #3
_lp
 sta tmp,y
 dey
 bpl _lp

 ldy #1
 lda (pse),y
 and #$1f
 beq _sc1

 ldy #0
 lda (pse),y
 and #$3f

_sc0 asl @
 tax
 lda kod,x
 sta tmp+1
 lda kod+1,x
 sta tmp

 ldy #1
 lda (pse),y
 and #$1f
 sta pomoc
 and #$f
 jsr _q
 sta tmp+2
 lda pomoc
 and #$f0
 ora tmp
 sta tmp

_sc1 ldy #1
 lda (pse),y
 and #$e0
 cmp #$80
 beq _speed
 cmp #$40
 beq _volum
 cmp #$20
 beq _brkx
 rts

.endl


_speed lda #$f
 ora tmp+2
 sta tmp+2
 ldy #2
 lda (pse),y
 sta tmp+3
 rts

_volum lda #$c
 ora tmp+2
 sta tmp+2
 ldy #2
 lda (pse),y
 sec
 sbc #$d8
 asl @
 sta tmp+3
 rts

_brkx lda #$d
 ora tmp+2
 sta tmp+2
 lda #0
 sta tmp+3
 rts

_intel sty hlp
 lsr @
 ror hlp
 ldx hlp
 rts


*------------------------*
*   wykasuj instrument   *
*------------------------*
.local _clsmp

 ldx n_inst
 lda #$d8
 sta tivol,x
 lda #0
 sta tstrl,x
 sta tstrh,x
 sta trepl,x
 sta treph,x
 sta tendl,x
 sta tendh,x

 jsr _stname
 jsr on
 lda #0
 ldy #21
_lp
 sta (hlp),y
 dey
 bpl _lp
 jsr of

 lda #0
 ldx #22
_lp2
 sta _e1+13,x
 dex
 bpl _lp2

 jsr p_ins
 jsr cl_k
 rts

.endl


*------------------------*
*   wczytywanie utworu   *
*------------------------*

.local _ldir

 ldx #14
_lp
 lda _mload,x
 sta _loa,x
 dex
 bpl _lp

 ldx #2
_lp2
 lda _mload+12,x
 sta _dir+5,x
 dex
 bpl _lp2

 jsr katalog
 jsr _ofdli
 jsr _rmod
 jsr _ondli
 jsr cl_k
 jsr of
 rts

.endl


*------------------------*
*   wczytywanie sampla   *
*------------------------*

.local _lsamp

 ldx #14
_lp
 lda _sload,x
 sta _loa,x
 dex
 bpl _lp

 ldx #2
_lp2
 lda _sload+12,x
 sta _dir+5,x
 dex
 bpl _lp2

 jsr katalog
 jsr _ofdli
 jsr _rsmp
 jsr _ondli
 jsr cl_k
 jsr of
 rts

.endl


*---------------------*
*   odczyt katalogu   *
*---------------------*

.proc katalog

 jsr _ofdli
 jsr bufclr
 jsr _cl
 ldx <_dir
 ldy >_dir
 lda #6
 sta __k+1
 lda #3
 jsr _op
 ldx <$500
 ldy >$500
 jsr _le
 ldx <_bf
 ldy >_bf
 lda #7
 jsr _re
 jsr _cl
 jsr src
 jsr _ondli

 lda #0
 sta d_licz
 sta d_il
 sta d_win
 lda #7
 sta d_co
 jsr obl
 jsr _wdth
 lda d_il
 cmp #1
 beq _escd
 jsr _clnx
 jsr src
 jsr setsrc
 jsr _wrt2
 jsr _x3neg
 jsr cl_k
 jsr of


.local _dexit

 lda 764
 cmp #12
 beq _dpisz
 cmp #33
 beq ___kat
 cmp #15
 beq ___dxt
 cmp #14
 beq ___dpv
 cmp #28
 beq _escd
 jmp _dexit

___dxt
 jmp _dxt

___dpv
 jmp _dpv

___kat
 jmp katalog

.endl


_escd jsr cl_k
 jsr bufclr
 ldx status
 txs
 jmp keybd


.local _dpisz

 jsr _x4neg
 ldy #0
 ldx #3

_lp
 lda (fpisz),y
 eor #$80
 beq _skp
 clc
 adc #$20
 sta _loa,x
 inx
 iny
 cpy #8
 bne _lp

_skp
 jsr bufclr
 jsr cl_k
 rts

.endl


.local _dxt

 ldx d_il
 dex
 stx pomoc
 lda d_win
 cmp #6
 beq _skp
 inc d_win
 lda d_win
 cmp pomoc
 beq _ta0
 cmp #7
 bne _yn1

_skp
 inc d_licz
 lda d_licz
 clc
 adc #7
 cmp d_il
 beq _yn3
 jsr src
 jsr setsrc
 jsr cl_k
 lda #7
 sta d_co
 jsr _wrt2
 jsr _x2neg
 jmp _dexit

.endl


_ta0 dec d_win
 jsr cl_k
 jmp _dexit

_yn1 jsr _x6neg
 jsr cl_k
 jmp _dexit


.local _dpv

 lda d_win
 beq _skp
 dec d_win
 jmp _yn2

_skp
 lda d_licz
 beq _yn4
 dec d_licz
 jsr src
 jsr setsrc
 jsr cl_k
 lda #7
 sta d_co
 jsr _wrt2
 jsr _x3neg
 jmp _dexit

.endl


_yn2 jsr _x5neg
 jsr cl_k
_yn4 jmp _dexit

_yn3 dec d_licz
 jmp _dexit

_x0neg lda <_e3+31
 sta _dx
 lda >_e3+31
 sta _dx+1
 rts


.local _x6neg

 jsr _x0neg
 ldx d_win
 dex
 beq _skp

_lp
 jsr _adcdn
 dex
 bne _lp

_skp
 jsr _x1neg
 jsr _adcdn
 jsr _x1neg
 rts

.endl


.local _x5neg

 jsr _x0neg
 ldx d_win
 inx

_lp
 jsr _adcdn
 dex
 bne _lp
 jsr _x1neg
 sec
 lda _dx
 sbc #40
 sta _dx
 bcs _skp
 dec _dx+1

_skp
 jsr _x1neg
 rts

.endl



.local _x2neg

 ldx #7
_lp
 lda _e3+271,x
 eor #$80
 sta _e3+271,x
 dex
 bpl _lp
 rts

.endl


.local _x3neg

 ldx #7
_lp
 lda _e3+31,x
 eor #$80
 sta _e3+31,x
 dex
 bpl _lp
 rts

.endl


.local _wrt2

 ldx d_il
 dex
 stx pomoc
 ldy #2
_lp
 lda (_sr),y
 cpy #10
 beq end2
 sec
 sbc #$20
 dey
 dey
 sta (_sc),y
 iny
 iny
 iny
 bne _lp

end2 jsr incadr
 jsr incsrc
 dec pomoc
 beq _skp
 dec d_co
 bne _wrt2

_skp
 rts

.endl


.local setsrc

 ldx d_licz
 beq _wrt2._skp
_lp
 clc
 lda _sr
 adc pom_1
 sta _sr
 bcc _skp
 inc _sr+1

_skp
 dex
 bne _lp

_rts
 rts

.endl


.local _x4neg

 lda <_e3+31
 sta fpisz
 lda >_e3+31
 sta fpisz+1
 ldx d_win
 beq setsrc._rts

_lp2
 clc
 lda fpisz
 adc #40
 sta fpisz
 bcc _skp
 inc fpisz+1

_skp
 dex
 bne _lp2
 rts

.endl


.local incadr

 clc
 lda _sc
 adc #40
 sta _sc
 bcc _skp
 inc _sc+1

_skp
 rts

.endl


.local incsrc

 clc
 lda _sr
 adc pom_1
 sta _sr
 bcc _skp
 inc _sr+1

_skp
 rts

.endl


src
 lda <_bf
 sta _sr
 lda >_bf
 sta _sr+1
 lda <_e3+31
 sta _sc
 lda >_e3+31
 sta _sc+1
 rts


.local _wdth

 ldx #0
 ldy #1
_lp
 lda _bf,x
 cmp #$9b
 beq _skp
 iny
 inx
 jmp _lp

_skp
 sty pom_1
 rts

.endl
 

.local obl

 lda <_bf
 sta lop
 lda >_bf
 sta lop+1
 ldy #0

_lp
 lda (lop),y
 cmp #$9b
 bne _skp
 inc d_il

_skp
 iny
 bne _lp

 inc lop+1
 lda lop+1
 cmp >_bf+$500
 bne _lp

_rts
 rts

.endl


.local _clnx

 jsr _ad
 ldx d_il
 cpx #7
 bcs obl._rts
 dex

_lp
 clc
 lda pse
 adc pom_1
 sta pse
 bcc _skp
 inc pse+1

_skp
 dex
 bne _lp

 ldy #0
 lda #32
_lp2
 sta (pse),y
 iny
 bne _lp2
 rts

.endl


.local _adcdn

 clc
 lda _dx
 adc #40
 sta _dx
 bcc _skp
 inc _dx+1

_skp
 rts

.endl

.endp

_dir dta c'D1:*.***',b($9b)


*------------------------*
*  efekt  "sample zero"  *
*------------------------*

.proc _null

 ldx #0
 jsr _pc
 ldx #3
 jsr _pc
 ldx #6
 jsr _pc
 ldx #9
 jsr _pc
 rts

_pc stx hlp
 lda tapat
 sta hlp+1
 lda #$21
 sta pse
_lp
 lda #0
 sta instr
 ldx #63
 jsr g_0
 dec pse
 bpl _lp
 rts

g_0 ldy #1
 lda (hlp),y
 and #$1f
 beq _skp3
 sta instr
 jmp _skp2

g_1 ldy #1
 lda (hlp),y
 and #%11100000
 ora instr
 sta (hlp),y
 jmp _skp2

_skp3
 ldy #0
 lda (hlp),y
 and #$3f
 cmp #36
 beq _skp2
 jmp g_1

_skp2
 clc
 lda hlp
 adc #12
 sta hlp
 bcc _skp
 inc hlp+1
_skp
 dex
 bpl g_0
 rts

.endp


_mot stx hlp
 asl @
 rol hlp
 ldy hlp
 rts

title dta c'M.K.'

*------------------------*
*  opuszczenie programu  *
*------------------------*
_exit jmp $e474




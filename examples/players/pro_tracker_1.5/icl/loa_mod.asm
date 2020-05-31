* odczyt utworu

_mod
 lda <$c600
 sta patadr
 lda >$c600
 sta patadr+1
 ldx <_loa
 ldy >_loa
 lda #4
 sta __k+1
 lda #3
 jsr _op	;odczyt naglowka
 ldx <1084
 ldy >1084
 jsr _le
 ldx <_bf
 ldy >_bf
 lda #7
 jsr _re

.local

 ldx #3
_lp
 lda _bf+1080,x
 cmp title,x
 bne _skp
 dex
 bpl _lp
 jmp _omvl
_skp

 jsr _cl
 lda #16
 sta pom_1
 ldx <_txt5
 ldy >_txt5
 jsr _wname

lop
 lda 764
 cmp #28
 bne lop

 lda #16
 sta pom_1
 ldx <_txt5
 ldy >_txt5
 jsr _wname
 ldx status
 txs
 jmp keybd

_omvl ldx #19	;odczyt nazwy utworu
_lp1
 lda _bf,x
 sta _clpat._nam,x
 dex
 bpl _lp1

 ldx #19	;oblicz dlugosc nazwy
_lp2
 lda _clpat._nam,x
 bne _skp1
 dex
 bpl _lp2
_skp1

 inx
 stx _clpat._5+1

 ldx #19	;wpisz na ekran
_lp3
 lda _clpat._nam,x
 tay
 lda chg,y
 sta _e1-22,x
 dex
 bpl _lp3

 jsr _ad
 lda #1
 sta _co+1
_co ldx #0
_1 ldy #42	;dlug. sampla
 lda (pse),y
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta tendl,x
 tya
 sta tendh,x
 cmp #$40
 bcc _skp2
 jmp _long

_skp2
 ldy #45	;glosnosc sampla
 lda (pse),y

 cmp #64
 bne _skp3
 sec
 sbc #1
 jmp _skp4

_skp3
 lda (pse),y
 and #$3f
 
_skp4
 lsr @
 clc
 adc #$d8
 sta tivol,x

 ldy #46
 lda (pse),y	;pocz. petli sampla
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta trepl,x
 tya
 sta treph,x
 ldy #48
 lda (pse),y	;dlug. petli sampla
 tax
 iny
 lda (pse),y
 jsr _mot
 ldx _co+1
 sta tlenl,x
 tya
 sta tlenh,x

 ldx #0		;czytaj nazwy sampli
 ldy #20
_lp4
 lda (pse),y
 sta $680,x
 iny
 inx
 cpx #22
 bne _lp4

 jsr on		;wpisz do pamieci
 ldy #21	;nazwe sampla
 ldx #21
_lp5
 lda $680,x
 sta (patadr),y
 dey
 dex
 bpl _lp5
 jsr of

 clc
 lda pse
 adc #30
 sta pse
 bcc _skp5
 inc pse+1

_skp5
 clc
 lda patadr
 adc #22
 sta patadr
 bcc _skp6
 inc patadr+1

_skp6
 inc _co+1
 lda _co+1
 cmp #32
 beq _skp7
 jmp _1

_skp7
 lda _bf+950	;dl. utworu
 sta patmax+1

 lda _bf+952	;najw. num. patternu
 sta _mx+1
 ldy #0
 sty _mor+1
_lp6
 lda _bf+952,y
_mx cmp #0       
 bcc _skp8
 sta _mx+1

_skp8
 iny
 cpy #128
 bne _lp6

 ldy _mx+1
 iny
 sty tse

 cpy #35
 bcc _skp9
 jmp _optrn

_skp9

 ldy #127	;orders
_lp7
 ldx _bf+952,y
 lda tapat,x
 sta sng,y
 dey
 bpl _lp7

 ldx _bf+950
 lda #$ff
_lp8
 sta sng,x
 inx
 cpx #128
 bne _lp8

.endl


*--------------------*
*  odczyt patternow  *
*--------------------*
_mor ldy #0	;adres paternu w pamieci
 lda tapat,y
 sta hlp+1
 lda #0
 sta hlp
 ldx <1024
 ldy >1024
 jsr _le	;x,y -> ile wczytac
 jsr _ad	;_bf -> pse,pse+1
 lda #7
 jsr _re

.local

 lda #0
 sta tse+1
_thi ldy #3	;czytanie 4 bajtow
_lp
 lda (pse),y
 sta tmp,y
 dey
 bpl _lp

 jsr e_cnv

 clc
 lda hlp
 adc <3
 sta hlp
 bcc _skp
 inc hlp+1

_skp
 clc
 lda pse
 adc <4
 sta pse
 bcc _skp1
 inc pse+1

_skp1

 dec tse+1
 bne _thi
 inc _mor+1
 dec tse
 bne _mor

 lda #1
 sta lic+1
 lda #0
 sta n_ins
 sta n_bnk
 jsr s_hl

.endl


*-----------------*
*  odczyt sampli  *
*-----------------*
lic ldy #1	;czy wczytac
 lda tendl,y
 ora tendh,y
 beq _jm

 ldy lic+1	;czy zmiesci sie w banku
 clc
 lda _atmp+2
 adc tendh,y
 cmp #$7f
 bcc _nz

 inc n_bnk
 lda n_bnk
 clc
 adc #1
 cmp il_bnk
 beq _sdq
 jsr s_hl
 jmp _nz

_sdq jmp _oomem

_nz jsr set_b
 jsr st_adr
 ldx tendl,y	;odczyt sampla
 lda tendh,y
 tay
 jsr _le
 ldx hlp
 ldy hlp+1
 lda #7
 jsr _re
 jsr real_a
 jsr cnv_sm
 jsr _pam

 lda #0
 sta hlp
 lda _atmp+2
 sta hlp+1

_jm inc lic+1
 lda lic+1
 cmp #32
 bne lic
 jmp n_12

real_a ldy lic+1
 clc
 lda tstrl,y
 adc trepl,y
 sta trepl,y
 lda tstrh,y
 adc treph,y
 sta treph,y

 clc
 lda tstrl,y
 adc tendl,y
 sta tendl,y
 lda tstrh,y
 adc tendh,y
 sta tendh,y

 lda tlenl,y
 ora tlenh,y
 beq no_lop
 cmp #2
 beq no_lop
 rts

no_lop lda #0
 sta trepl,y
 lda tendh,y
 sta treph,y
 rts

s_hl lda #0
 sta hlp
 sta _atmp+1
 lda #$40
 sta hlp+1
 lda #$41
 sta _atmp+2
 rts

_pam lda n_bnk
 sta _atmp
 ldy lic+1
 lda tendl,y
 sta _atmp+1
 lda tendh,y
 clc
 adc #1
 sta _atmp+2
 rts

st_adr lda #0
 sec
 sbc tendl,y
 sta hlp
 sta tstrl,y
 lda hlp+1
 sta tstrh,y
 rts

set_b ldy lic+1
 ldx n_bnk
 lda tab_1,x
 sta $d301
 lda tab_1,x
 sec
 sbc #1
 sta tab_3,y
 rts


.proc cnv_sm

 ldy lic+1
 lda tendh,y
 sta pse+1
 lda #0
 sta pse
 tay
_lp
 sta (pse),y
 iny
 bne _lp
 rts

.endp


n_12 lda #$ff
 sta $d301
 rts


cl_ram lda #0
 sta rep0_m+1
 sta rep0_s+1
 sta rep1_m+1
 sta rep1_s+1
 sta rep2_m+1
 sta rep2_s+1
 sta rep3_m+1
 sta rep3_s+1
 sta iad0_m+1
 sta iad1_m+1
 sta iad2_m+1
 sta iad3_m+1
 sta iad0_s+1
 sta iad1_s+1
 sta iad2_s+1
 sta iad3_s+1
 sta ien0_s+1
 sta ien1_s+1
 sta ien2_s+1
 sta ien3_s+1
 sta p_0c+1
 sta p_1c+1
 sta p_2c+1
 sta p_3c+1
 sta cm_0+1
 sta cm_1+1
 sta cm_2+1
 sta cm_3+1
 lda #$40
 sta p_0c+2
 sta p_1c+2
 sta p_2c+2
 sta p_3c+2
 lda #$d8
 sta ivol10+2
 sta ivol11+2
 sta ivol12+2
 sta ivol13+2
 rts

e_cnv lda tmp
 and #$f
 ora tmp+1
 bne _nl

 lda #36
 ldy #0
 sta (hlp),y
 iny
 lda #0
 sta (hlp),y
 jmp f_2

_nl ldy #0
_tst lda kod,y
 cmp tmp+1
 bne pls
 lda tmp
 and #$f
 cmp kod+1,y
 bne pls
 tya
 lsr @
f_1 ldy #0
 sta (hlp),y
 jmp f_2

pls iny
 iny
 cpy #72
 bne _tst
 lda #36
 jmp f_1

f_2 lda tmp+2
 jsr _h
 sta pomoc
 lda tmp
 and #$10
 clc
 adc pomoc
 ldy #1
 sta (hlp),y

 ldy #2
 lda #0
 sta (hlp),y
 ldy #1
 lda tmp+2
 and #$f
 cmp #$c
 beq _vol
 cmp #$f
 beq _tmp
 cmp #$d
 beq _break
 rts


.PROC		_break
 lda #$20
 ora (hlp),y
 sta (hlp),y
 rts
.ENDP


.PROC		_vol
 lda #$40
 ora (hlp),y
 sta (hlp),y
 ldy #2
 lda tmp+3
 cmp #64
 bne _skp
 sec
 sbc #1
 jmp _skp1

_skp
 lda tmp+3
 and #$3f

_skp1
 clc
 lsr @
 adc #$d8
 sta (hlp),y

_ext
 rts
.ENDP


.PROC		_tmp
 lda tmp+3
 cmp #$20
 bcs _vol._ext

 lda #$80
 ora (hlp),y
 sta (hlp),y
 ldy #2
 lda tmp+3
 and #$1f
 sta (hlp),y
 rts
.ENDP


.PROC		_optrn
 jsr _cl
 lda #19
 sta pom_1
 ldx <_txt3
 ldy >_txt3
 jsr _wname
 jsr cl_k

_lp
 lda 764
 cmp #28
 bne _lp

 lda #19
 sta pom_1
 ldx <_txt3
 ldy >_txt3
 jsr _wname
 ldx status
 txs
 jmp keybd
.ENDP


.PROC		_long
 jsr _cl
 lda #17
 sta pom_1
 ldx <_txt4
 ldy >_txt4
 jsr _wname
 jsr cl_k

_lp
 lda 764
 cmp #28
 bne _lp

 lda #17
 sta pom_1
 ldx <_txt4
 ldy >_txt4
 jsr _wname
 ldx status
 txs
 jmp keybd
.ENDP


_op stx _n+1
 sty __n+1
 ldx #$10
 sta $342,x
_n lda #0
 sta $344,x
__n lda #0
 sta $345,x
__k lda #4
 sta $34a,x
 jsr $e456
 bmi _er1
 rts


.PROC		_er1
 jsr n_12
 sty byte
 cpy #136
 bne _skp
 rts

_skp
 lda #15
 sta pom_1
 ldx <_txt0
 ldy >_txt0
 jsr _wname
 jsr _errkd
 jsr cl_k

_lp
 lda 764
 cmp #28
 bne _lp

 lda #15
 sta pom_1
 ldx <_txt0
 ldy >_txt0
 jsr _wname
 ldx status
 txs
 jmp keybd
.ENDP


_cl ldx #$10
 lda #$c
 sta $342,x
 jsr $e456
 bmi _er1
 rts


_le stx _l+1
 sty __l+1
 rts


_re stx _a+1
 sty __a+1
 ldx #$10
 sta $342,x
_a lda #0
 sta $344,x
__a lda #0
 sta $345,x
_l lda #0
 sta $348,x
__l lda #0
 sta $349,x
 jsr $e456
 bmi _er1
 rts


on sei
 lda #0
 sta $d40e
 lda #$fe
 sta $d301
 rts

of jsr n_12
 lda #$40
 sta $d40e
 cli
 jsr _ondli
 rts

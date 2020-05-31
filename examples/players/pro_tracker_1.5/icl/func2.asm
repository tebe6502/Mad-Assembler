
*--------------------------------*
*    wczytanie jednego sampla    *
*--------------------------------*

.proc _rsmp

 jsr _cl
 ldx <_loa
 ldy >_loa
 lda #4
 sta __k+1
 lda #3
 jsr _op
 ldx <27
 ldy >27
 jsr _le
 
 ldx <$680	;_btmp
 ldy >$680
 lda #7
 jsr _re

 lda $681
 cmp #$40
 bcc _skp
 jmp _long

_skp
 lda _atmp
 sta n_bnk
 clc		;czy zmiesci sie w tym
 lda $680	;banku
 adc _atmp+1
 lda $681
 adc _atmp+2
 adc #1
 cmp #$7f
 bcc _lg0

 ldy n_inst
 lda #$40
 sta hlp+1
 sta tstrh,y
 lda #0
 sec
 sbc $680
 sta hlp
 sta tstrl,y
 inc n_bnk
 lda n_bnk
 clc
 adc #1
 cmp il_bnk
 beq _lg2
 jmp _lg1

_lg2 jmp _oomem

_lg0 ldy n_inst
 lda _atmp+2
 clc
 adc #1
 sta hlp+1
 sta tstrh,y
 lda #0
 sec
 sbc $680
 sta hlp
 sta tstrl,y

_lg1 ldy n_inst   ;ustaw bank
 ldx n_bnk
 lda tab_1,x
 sta $d301
 sec
 sbc #1
 sta tab_3,y

 ldx $680        ;wczytanie sampla
 ldy $681
 jsr _le
 ldx hlp
 ldy hlp+1
 lda #7
 jsr _re
 jsr _cl

 ldy n_inst
 lda $682
 lsr @
 tax
 lda tab_a1,x
 sta tivol,y

 clc
 lda tstrl,y
 adc $680
 sta tendl,y
 lda tstrh,y
 adc $681
 sta tendh,y

 clc
 lda tstrl,y
 adc $683
 sta trepl,y
 lda tstrh,y
 adc $684
 sta treph,y

 lda n_inst
 sta lic+1
 jsr _pam
 jsr cnv_sm

 jsr _stname
 jsr on
 ldx #21
 ldy #21
_lp
 lda $685,x
 sta (hlp),y
 dey
 dex
 bpl _lp

 jsr of
 jsr n_12
 jsr p_ins
 jsr cl_k
 rts
 
.endp


_errkd jsr convr
 ldy #3
 lda word
 jsr disp_2
 lda word+1
 jsr disp_1
 rts


.proc convr

 lda #0
 sta word
 sta word+1
 ldx #8
 sed
_lp
 asl byte
 lda word
 adc word
 sta word
 rol word+1
 dex
 bne _lp
 cld
 rts

.endp


disp_1 and #$f
 ora #'0'-32
 sta _e4+70,y
 dey
 rts

disp_2 pha
 jsr disp_1
 pla
 jsr _h
 jsr disp_1
 rts


*------------------------*
*   wylaczanie kanalow   *
*------------------------*
_off3 jsr _p0rom
 lda _offst+2
 eor #1
 sta _offst+2
 beq _of3

 lda #$5d
 sta _e1-33
 lda #$ff
 sta ch_2+1
 lda #$23
 sta ch_2+2
 jsr cl_k
 jsr _p0rom
 rts

_of3 lda #2
 sta ch_2+1
_df3 lda #$d6
 sta ch_2+2
 lda #$5c
 sta _e1-33
 jsr cl_k
 jsr _p0rom
 rts


_off4 jsr _p0rom
 lda _offst+3
 eor #1
 sta _offst+3
 beq _of4

 lda #$5d
 sta _e1-30
 lda #$ff
 sta ch_3+1
 lda #$23
 sta ch_3+2
 jsr cl_k
 jsr _p0rom
 rts

_of4 lda #3
 sta ch_3+1
_df4 lda #$d6
 sta ch_3+2
 lda #$5c
 sta _e1-30
 jsr cl_k
 jsr _p0rom
 rts

_offtrack cmp #95
 beq _off1
 cmp #94
 beq _off2
 cmp #90
 beq _off3
 cmp #88
 beq _off4
 rts

_off1 jsr _p0rom
 lda _offst
 eor #1
 sta _offst
 beq _of1

 lda #$5d
 sta _e1-39
 lda #$ff
 sta ch_0+1
 lda #$23
 sta ch_0+2
 jsr cl_k
 jsr _p0rom
 rts

_of1 lda #0
 sta ch_0+1
_df1 lda #$d6
 sta ch_0+2
 lda #$5c
 sta _e1-39
 jsr cl_k
 jsr _p0rom
 rts

_off2 jsr _p0rom
 lda _offst+1
 eor #1
 sta _offst+1
 beq _of2

 lda #$5d
 sta _e1-36
 lda #$ff
 sta ch_1+1
 lda #$23
 sta ch_1+2
 jsr cl_k
 jsr _p0rom
 rts

_of2 lda #1
 sta ch_1+1
_df2 lda #$d6
 sta ch_1+2
 lda #$5c
 sta _e1-36
 jsr cl_k
 jsr _p0rom
 rts


*----------------------------*
*  ustaw adres nazwy sampla  *
*----------------------------*
.proc _stname

 lda <$c600	;ustaw adres nazwy sampla
 sta hlp
 lda >$c600
 sta hlp+1
 ldx n_inst
 cpx #1
 beq _ext
 dex
_lp
 clc
 lda hlp
 adc #22
 sta hlp
 bcc _skp
 inc hlp+1

_skp
 dex
 bne _lp

_ext
 rts

.endp


*-------------------------------*
*  graj sampla w czasie edycji  *
*-------------------------------*
.proc play_sampl

 sei
 ldy #0
 sty $d40e

 ldx n_inst
 lda tivol,x
 cmp #$d8
 bne _skp

 jsr n_12
 lda #$40
 sta $d40e
 cli
 rts

_skp
 ldx n_inst

 lda tab_3,x
 sta $d301

 lda tendh,x
 sta ien4_s+1

 lda tstrl,x
 sta istr_4+1
 lda tstrh,x
 sta istr_4+2

 ldx nuta
 lda $fe00,x
 sta iad4_m+1
 lda $fe25,x
 sta iad4_s+1
 clc

 lda istr_4
iad4_m adc #0
 sta istr_4
 lda istr_4+1
iad4_s adc #0
 sta istr_4+1
 bcc p_4c
 inc istr_4+2
 lda istr_4+2
ien4_s cmp #0
 bcc p_4c

 jsr n_12
 lda #$40
 sta $d40e
 cli
 rts

p_4c lda (istr_4+1),y
 eor #$80
 ldx $d40b
_lp
 cpx $d40b
 beq _lp

ch_4 sta $d600
 jmp iad4_m-2

.endp


_atmp dta d'    '
_mload dta c'D1:********.MOD',b($9b)
_sload dta c'D1:********.SMP',b($9b)
_offst dta d'    '

chg	
 dta 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82
 dta 83,84,85,86,87,88,89,90,91,92,93,94,95,0,1,2,3,4,5,6,7,8
 dta 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
 dta 28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46
 dta 47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,96,97
 dta 98,99,100,101,102,103,104,105,106,107,108,109,110,111,112
 dta 113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

d_win	brk
d_licz	brk
d_co	brk
d_il	brk
ppm	brk
ble	brk
il_pt	brk
byte	brk
word	dta a(0)

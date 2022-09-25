
orders jsr cl_k
 lda o_licz
 sta p_ord
 lda #5
 sta _licz2
 jsr s_pse
 jsr _shlp
 jsr _ost
 jsr _olneg
 jsr o_eor

key2 lda 764
 cmp #15
 beq _dnx
 cmp #14
 beq _upx
 cmp #28
 beq _eord
 cmp #119
 beq _skp0
 cmp #116
 beq _skp1
 ldy #0
 jsr _oput
 jmp key2

_skp0
 jmp _inr

_skp1
 jmp _der
_dnx jmp _dno
_upx jmp _upo

_eord jsr cl_k
 jsr _olneg
 ldx o_win
 beq _skp2

_lp0
 jsr _iord
 dex
 bne _lp0

_skp2
 jsr _neg
 jsr s_eor
 clc
 lda o_licz
 adc o_win
 sta _mst+1
 rts

_dno lda o_win
 cmp #4
 beq _skp3
 inc o_win
 lda o_win
 cmp #5
 bne _skp4

_skp3
 inc o_licz
 lda o_licz
 cmp #124
 beq _skp5
 jsr cl_k
 lda #5
 sta _licz2
 jsr s_pse
 jsr _shlp
 lda o_licz
 sta p_ord
 jsr _ost
 jsr _on5
 jmp key2

_skp5
 dec o_licz
 jmp key2

_skp4
 jsr _odn
 jsr cl_k
 jmp key2

_upo lda o_win
 beq _skp6
 dec o_win
 jmp _otam2
 
_skp6 
 lda o_licz
 beq _skp7
 dec o_licz
 jsr cl_k
 lda #5
 sta _licz2
 jsr s_pse
 jsr _shlp
 lda o_licz
 sta p_ord
 jsr _ost
 jsr _onp
 jmp key2

_otam2 jsr _oup
 jsr cl_k

_skp7
 jmp key2

_olneg lda <_e4+13
 sta filord
 lda >_e4+13
 sta filord+1
 rts

o_eor jsr _olneg
 ldx o_win
 beq _skp8

_lp1
 jsr _iord
 dex
 bne _lp1

_skp8
 jsr _neg
 rts

_neg ldy #4

_lp2
 lda (filord),y
 eor #$80
 sta (filord),y
 dey
 bpl _lp2
 clc
 lda o_licz
 adc o_win
 sta patno
 jsr _ppoz
 rts

_odn jsr _olneg
 ldx o_win
 dex
 beq _skp9

_lp3
 jsr _iord
 dex
 bne _lp3

_skp9
 jsr _neg
 jsr _iord
 jsr _neg
 rts

_oup jsr _olneg
 ldx o_win
 inx

_lp4
 jsr _iord
 dex
 bne _lp4

 jsr _neg
 sec
 lda filord
 sbc <40
 sta filord
 bcs _skp10
 dec filord+1

_skp10
 jsr _neg
 rts

_on5 ldx #4

_lp6
 lda _e4+173,x
 eor #$80
 sta _e4+173,x
 dex
 bpl _lp6
 rts

_onp ldx #4

_lp5
 lda _e4+13,x
 eor #$80
 sta _e4+13,x
 dex
 bpl _lp5
 rts

_osr jsr _sh
 ldx o_licz
 beq _skp11

_lp7
 clc
 lda hlp
 adc #1
 sta hlp
 dex
 bne _lp7

_skp11
 lda #5
 sta _licz2
 lda o_licz
 sta p_ord
 jsr _ost
 jsr cl_k
 rts

_ost clc
 lda o_licz
 adc o_win
 sta patno
 jsr _ppoz
 ldx p_ord
 jsr p_hex
 ldx cf_1
 lda hex,x
 ldy #0
 sta (pse),y
 iny
 ldx cf_1+1
 lda hex,x
 sta (pse),y

 ldy #0
 lda (hlp),y

 ldx #0

_lp8
 cmp tapat,x
 beq _sk0
 inx
 cpx #128
 bne _lp8

 lda #'-'-32
 ldy #3
 sta (pse),y
 iny
 sta (pse),y
 jmp _cn2

_sk0
 jsr p_hex
 ldx cf_1
 lda hex,x
 ldy #3
 sta (pse),y
 ldy #4
 ldx cf_1+1
 lda hex,x
 sta (pse),y

_cn2 lda #0
 ldy #2
 sta (pse),y

 jsr i_pse
 inc hlp
 inc p_ord
 dec _licz2
 bne _ost
 rts

i_pse clc
 lda pse
 adc <40
 sta pse
 bcc i_pse_skp
 inc pse+1
i_pse_skp
 rts

_shlp jsr _sh
 ldx o_licz
 beq _shlp_q

_lp9
 inc hlp
 dex
 bne _lp9

_shlp_q
 rts

s_pse lda <_e4+13
 sta pse
 lda >_e4+13
 sta pse+1
 rts

_oput ldx #0
 cmp #33
 bne _sk1
 lda #'-'-32
 sta _obf+3
 sta _obf+4
 lda #$f
 sta _yp
 sta _yp+1
 jmp _op4

_sk1
 cmp o_klw,x
 bne _sk2
 stx _yp
 lda hex,x
 sta _obf+3,y
 jmp _op2

_sk2
 inx
 cpx #16
 bne _sk1
 rts

_op2 jsr cl_k

_sk4
 lda 764
 cmp #$ff
 beq _sk4

 ldy #1
 ldx #0

_lp11
 cmp o_klw,x
 bne _sk3
 stx _yp+1
 lda hex,x
 sta _obf+3,y
 jmp _op4

_sk3
 inx
 cpx #16
 bne _lp11
 rts

_op4 jsr _adc
 jsr p_hex
 ldx cf_1
 lda hex,x
 sta _obf
 ldx cf_1+1
 lda hex,x
 sta _obf+1

 jsr _olneg
 ldx o_win
 beq _sk5

_l0
 jsr _iord
 dex
 bne _l0

_sk5
 ldy #4

_l1
 lda _obf,y
 sta (filord),y
 dey
 bpl _l1

 jsr _sh
 jsr _adc
 beq _sk6

_l3
 inc hlp
 dex
 bne _l3

_sk6
 lda _yp
 jsr _q
 ora _yp+1
 ldy #0
 cmp #$ff
 beq _sk7
 tax
 lda tapat,x

_sk7
 sta (hlp),y

 lda o_win
 cmp #4
 beq _sk8
 inc o_win
 lda o_win
 cmp #5
 bne _op12

_sk8
 inc o_licz
 lda o_licz
 cmp #124
 beq _op13
 jsr cl_k
 lda #5
 sta _licz2
 jsr s_pse
 lda o_licz
 sta p_ord
 jsr _shlp
 jsr _ost
 jsr _on5
 rts

_op13 jsr cl_k
 dec o_licz
 jsr _on5
 rts

_op12 jsr _olneg
 ldx o_win
 beq _sk9

_op12_lp
 jsr _iord
 dex
 bne _op12_lp

_sk9
 jsr cl_k
 lda #5
 sta _licz2
 jsr s_pse
 lda o_licz
 sta p_ord
 jsr _shlp
 jsr _ost
 jsr _neg
 rts

_sh lda <$400
 sta hlp
 lda >$400
 sta hlp+1
 rts

_adc clc
 lda o_licz
 adc o_win
 tax
 rts

_iord clc
 lda filord
 adc <40
 sta filord
 bcc _iord_s
 inc filord+1

_iord_s
 rts


.proc bufclr

 lda #0
 tax

_lp
 sta _bf,x
 sta _bf+$100,x
 sta _bf+$200,x
 sta _bf+$300,x
 sta _bf+$400,x
 inx
 bne _lp

 ldx #7

_lp2
 sta _e3+31,x
 sta _e3+71,x
 sta _e3+111,x
 sta _e3+151,x
 sta _e3+191,x
 sta _e3+231,x
 sta _e3+271,x
 dex
 bpl _lp2
 rts

.endp


.proc _x1neg

 ldy #7

_lp
 lda (_dx),y
 eor #$80
 sta (_dx),y
 dey
 bpl _lp
 rts

.endp

o_klw dta 50,31,30,26,24,29,27,51,53,48,63,21,18,58,42,56

o_win	brk
o_licz	brk
p_ord	brk
_licz2	brk
_obf	dta d'     '
_yp	dta a(0)

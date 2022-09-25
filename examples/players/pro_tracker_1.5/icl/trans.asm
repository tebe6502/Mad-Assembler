
.proc _trans

 jsr cl_k
 lda #0
 sta $2d9

 ldx #4
 lda #'?'-32
_lp
 sta _txt6+28,x
 dex
 bpl _lp

 lda #'_'-32
 sta _txt6+30

 lda #17
 sta pom_1
 ldx <_txt6
 ldy >_txt6
 jsr _wname

_lp2
 lda 764
 cmp #$ff
 beq _lp2
 
 cmp #28
 bne _skp0

 lda #17
 sta pom_1
 ldx <_txt6
 ldy >_txt6
 jmp _ex9

lop
 jsr cl_k

_lp0
 lda 764
 cmp #$ff
 beq _lp0

_skp0
 ldx #0

_lp1
 cmp o_klw,x
 bne _skp2
 stx _yp
 lda hex,x
 sta _e4+71
 jmp _tp2

_skp2
 inx
 cpx #2
 bne _lp1
 jmp lop

_tp2 jsr cl_k

_lp3
 lda 764
 cmp #$ff
 beq _lp3

 ldx #0
_lp8
 cmp o_klw,x
 bne _skp3
 stx _yp+1
 lda hex,x
 sta _e4+72
 jmp _skp4

_skp3
 inx
 cpx #16
 bne _lp8
 jmp _tp2

_skp4
 lda _yp
 jsr _q
 ora _yp+1
 sta komend

_tp4 jsr cl_k

_lp4
 lda 764
 cmp #$ff
 beq _lp4

 ldx #0
_lp9
 cmp o_klw,x
 bne _skp5
 stx _yp
 lda hex,x
 sta _e4+74
 jmp _tp5

_skp5
 inx
 cpx #16
 bne _lp9
 jmp _tp4

_tp5 jsr cl_k

_lp5
 lda 764
 cmp #$ff
 beq _lp5

 ldx #0
_lp10
 cmp o_klw,x
 bne _skp6
 stx _yp+1
 lda hex,x
 sta _e4+75
 jmp _skp7

_skp6
 inx
 cpx #16
 bne _lp10
 jmp _tp5

_skp7
 lda _yp
 jsr _q
 ora _yp+1
 sta param

 ldx n_pat
 lda tapat,x
 sta hlp+1
 ldx p_trk
 lda _tn5,x
 sta hlp

 ldx #0
_tpx2 ldy #1
 lda (hlp),y
 and #$1f
 cmp komend
 bne _tpx
 ldy #0
 lda (hlp),y
 and #$3f
 clc
 adc param
 cmp #36
 bcc _skp8

 lda #17
 sta pom_1
 ldx <_txt6
 ldy >_txt6
 jmp _ex9

_skp8

 sta (hlp),y
_tpx clc
 lda hlp
 adc #12
 sta hlp
 bcc _skp9
 inc hlp+1

_skp9
 inx
 cpx #64
 bne _tpx2

 jsr cl_k

_lp6
 lda 764
 cmp #12
 bne _lp6

 lda #17
 sta pom_1
 ldx <_txt6
 ldy >_txt6
 jmp _ex9

.endp


.local _exchg

 jsr cl_k
 lda #0
 sta $2d9

 ldx #4
 lda #'?'-32

_skp0
 sta _txt7+26,x
 dex
 bpl _skp0

 lda #'_'-32
 sta _txt7+28

 lda #16
 sta pom_1
 ldx <_txt7
 ldy >_txt7
 jsr _wname

_skp1
 lda 764
 cmp #$ff
 beq _skp1

 cmp #28
 bne _skp2

 lda #16
 sta pom_1
 ldx <_txt7
 ldy >_txt7
 jmp _ex9

_loop
 jsr cl_k

_skp3
 lda 764
 cmp #$ff
 beq _skp3

_skp2
 ldx #0

_skp5
 cmp o_klw,x
 bne _skp4
 stx _yp
 lda hex,x
 sta _e4+70
 jmp _ex2

_skp4
 inx
 cpx #2
 bne _skp5
 jmp _loop

.endl


_ex2 jsr cl_k


.local

_skp
 lda 764
 cmp #$ff
 beq _skp

 ldx #0

_loop
 cmp o_klw,x
 bne _skp1

 stx _yp+1
 lda hex,x
 sta _e4+71
 jmp _skp3

_skp1
 inx
 cpx #16
 bne _loop
 jmp _ex2

_skp3

.endl


 lda _yp
 jsr _q
 ora _yp+1
 sta komend


_eq4 jsr cl_k


.local

_skp
 lda 764
 cmp #$ff
 beq _skp

 ldx #0

_loop
 cmp o_klw,x
 bne _skp0
 stx _yp
 lda hex,x
 sta _e4+73
 jmp _ex5

_skp0
 inx
 cpx #2
 bne _loop
 jmp _eq4

.endl


_ex5 jsr cl_k


.local

_skp
 lda 764
 cmp #$ff
 beq _skp

 ldx #0

_loop
 cmp o_klw,x
 bne _skp0
 stx _yp+1
 lda hex,x
 sta _e4+74
 jmp _ex6

_skp0
 inx
 cpx #16
 bne _loop
 jmp _ex6

.endl


_ex6 lda _yp
 jsr _q
 ora _yp+1
 sta param

 ldx n_pat
 lda tapat,x
 sta hlp+1
 ldx p_trk
 lda _tn5,x
 sta hlp


.local

 ldx #0
 ldy #1
_xx0 lda (hlp),y
 and #$1f
 cmp komend
 bne _skp0
 lda (hlp),y
 and #$e0
 ora param
 sta (hlp),y

_skp0
 clc
 lda hlp
 adc #12
 sta hlp
 bcc _skp1
 inc hlp+1

_skp1
 inx
 cpx #64
 bne _xx0

.endl


 jsr cl_k


.local

_skp
 lda 764
 cmp #12
 bne _skp

.endl


 lda #16
 sta pom_1
 ldx <_txt7
 ldy >_txt7
_ex9 jsr _wname

 jsr set_h0
 jsr set_sc
 lda #15
 sta licznik
 lda #0
 sta p_pat
 jsr srt2
 jsr s_eor
 jsr cl_k
 lda #20
 sta $2d9
 jmp keybd

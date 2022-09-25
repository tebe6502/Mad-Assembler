
*---------------------*
*    procedury i/o    *
*---------------------*

.proc l_io

 lda #0
 sta l_poz
 jsr cl_k
 jsr _xneg

 ldx #10
_lp
 lda _e3+19,x
 eor #$80
 sta _e3+19,x
 dex
 bpl _lp

exit
 lda 764
 cmp #12
 beq j_pi
 cmp #15
 beq _nt
 cmp #14
 beq _pv
 cmp #28
 beq _skp
 jmp exit

_skp
 jsr _lneg
 jsr cl_k
 jmp keybd

j_pi jsr _lneg
 jsr cl_k
 ldx l_poz

 lda _jtab_l,x
 sta _gproc+1

 lda _jtab_h,x
 sta _gproc+2

_gproc jsr $a000
 jmp keybd


_nt
 lda l_poz
 cmp #6
 beq _nt_s
 inc l_poz
 jsr _ng0
_nt_s
 jsr cl_k
 jmp exit

_pv
 lda l_poz
 beq _pv_s
 dec l_poz
 jsr _ng1
_pv_s
 jsr cl_k
 jmp exit

_xneg
 lda <_e3+19
 sta _ol
 lda >_e3+19
 sta _ol+1
 rts

_lneg
 ldy #10
_lp1
 lda (_ol),y
 eor #$80
 sta (_ol),y
 dey
 bpl _lp1
 rts

_ng0
 jsr _xneg
 ldx l_poz
 dex
 beq _ng0_s
_lp2
 jsr ol_adc
 dex
 bne _lp2
_ng0_s
 jsr _lneg
 jsr ol_adc
 jsr _lneg
 rts

_ng1
 jsr _xneg
 ldx l_poz
 inx
_lp3
 jsr ol_adc
 dex
 bne _lp3
 jsr _lneg
 sec
 lda _ol
 sbc <40
 sta _ol
 bcs _skp4
 dec _ol+1
_skp4
 jsr _lneg
 rts

ol_adc
 clc
 lda _ol
 adc <40
 sta _ol
 bcc _skp5
 inc _ol+1
_skp5
 rts

_jtab_l dta l( _ldir , _sdir , _lsamp , _ssamp , _clall , _clpat , _clsmp )
_jtab_h dta h( _ldir , _sdir , _lsamp , _ssamp , _clall , _clpat , _clsmp )

.endp

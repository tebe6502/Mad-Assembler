
.proc _volmv

 sei
 lda #0
 sta $22f
 sta $d400
 sta $d40e

 ldx <$4000
 ldy >$4000
 stx hlp
 sty hlp+1

 ldx <$d800
 ldy >$d800
 stx pse
 sty pse+1

 ldx il_bnk
 dex
 lda tab_1,x
 sec
 sbc #1
 sta $d301

 ldy #0
_lp
 lda (hlp),y
 sta (pse),y
 iny
 bne _lp

 inc hlp+1
 inc pse+1
 lda pse+1
 cmp #$f8
 bne _lp

_lp1
 lda $f700,y
 sta $f800,y
 iny
 bne _lp1

 lda #$fe
 sta $d301
 rts

.endp

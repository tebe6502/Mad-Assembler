

*--------------
* track  0

.local i_0

 ldy #1
 lda (patadr),y
 and #$1f
 beq i_0c

 tax
 lda tab_3,x
 sta bank0+1

 lda tendh,x
 sta ien0_s+1

 lda tstrl,x
 sta p_0c+1
 lda tstrh,x
 sta p_0c+2

 lda trepl,x
 sta rep0_m+1
 lda treph,x
 sta rep0_s+1

 lda tivol,x
 sta ivol10+2

 ldy #0
 lda (patadr),y
 and #$3f
 tax
 lda $ff00,x
 sta iad0_m+1
 lda $ff25,x
 sta iad0_s+1

i_0c ldy #1
 lda (patadr),y
 and #$e0
 cmp #$20
 beq _skp
 cmp #$40
 beq _skp2
 cmp #$80
 beq _tmp0
 jmp i_1

_skp
 inc patend
 jmp i_1

_skp2
 ldy #2
 lda (patadr),y
 sta ivol10+2
 jmp i_1
_tmp0 ldy #2
 lda (patadr),y
 sta pause

.endl


*--------------
* track  1

.local i_1

 ldy #4
 lda (patadr),y
 and #$1f
 beq i_1c

 tax
 lda tab_3,x
 sta bank1+1

 lda tendh,x
 sta ien1_s+1

 lda tstrl,x
 sta p_1c+1
 lda tstrh,x
 sta p_1c+2

 lda trepl,x
 sta rep1_m+1
 lda treph,x
 sta rep1_s+1

 lda tivol,x
 sta ivol11+2

 ldy #3
 lda (patadr),y
 and #$3f
 tax
 lda $ff00,x
 sta iad1_m+1
 lda $ff25,x
 sta iad1_s+1

i_1c ldy #4
 lda (patadr),y
 and #$e0
 cmp #$20
 beq _skp
 cmp #$40
 beq _skp2
 cmp #$80
 beq _tmp1
 jmp i_2

_skp
 inc patend
 jmp i_2

_skp2
 ldy #5
 lda (patadr),y
 sta ivol11+2
 jmp i_2
_tmp1 ldy #5
 lda (patadr),y
 sta pause

.endl


*--------------
* track  2

.local i_2

 ldy #7
 lda (patadr),y
 and #$1f
 beq i_2c

 tax
 lda tab_3,x
 sta bank2+1

 lda tendh,x
 sta ien2_s+1

 lda tstrl,x
 sta p_2c+1
 lda tstrh,x
 sta p_2c+2

 lda trepl,x
 sta rep2_m+1
 lda treph,x
 sta rep2_s+1

 lda tivol,x
 sta ivol12+2

 ldy #6
 lda (patadr),y
 and #$3f
 tax
 lda $ff00,x
 sta iad2_m+1
 lda $ff25,x
 sta iad2_s+1

i_2c ldy #7
 lda (patadr),y
 and #$e0
 cmp #$20
 beq _skp
 cmp #$40
 beq _skp2
 cmp #$80
 beq _tmp2
 jmp i_3

_skp
 inc patend
 jmp i_3

_skp2
 ldy #8
 lda (patadr),y
 sta ivol12+2
 jmp i_3
_tmp2 ldy #8
 lda (patadr),y
 sta pause

.endl


*--------------
* track  3

.local i_3

 ldy #10
 lda (patadr),y
 and #$1f
 beq i_3c

 tax
 lda tab_3,x
 sta bank3+1

 lda tendh,x
 sta ien3_s+1

 lda tstrl,x
 sta p_3c+1
 lda tstrh,x
 sta p_3c+2

 lda trepl,x
 sta rep3_m+1
 lda treph,x
 sta rep3_s+1

 lda tivol,x
 sta ivol13+2

 ldy #9
 lda (patadr),y
 and #$3f
 tax
 lda $ff00,x
 sta iad3_m+1
 lda $ff25,x
 sta iad3_s+1

i_3c ldy #10
 lda (patadr),y
 and #$e0
 cmp #$20
 beq _skp
 cmp #$40
 beq _skp2
 cmp #$80
 beq _tmp3
 jmp i_e

_skp
 inc patend
 jmp i_e

_skp2
 ldy #11
 lda (patadr),y
 sta ivol13+2
 jmp i_e
_tmp3 ldy #11
 lda (patadr),y
 sta pause

.endl


i_e lda patend
 bne i_en

 clc
 lda patadr
 adc <12
 sta patadr
 lda patadr+1
 adc >12
 sta patadr+1
 cmp pataed
 bcc i_end

i_en inc patno
 ldx patno

patmax cpx #0
 bcc i_ens

_type jmp _prod0

 lda #6
 sta pause
 ldx #0
 stx patno

i_ens lda sng,x
 sta patadr+1
 clc
 adc #3
 sta pataed
 lda #0
 sta patadr

i_end lda $d20f
 and #8
 beq quit

 lda pause
 sta cnts
 clc
 ldy #vbl
 jmp $0000


quit jsr _p0rom
 jsr of
 jsr wait
 lda #$22
 sta $d400
 sta $22f
 lda <dl
 sta $230
 lda >dl
 sta $231
 lda >$2000
 sta 756
 lda #2
 sta $2c6
 lda #8
 sta $2c5
 jsr cl_k
 lda patno
 cmp o_win
 bcs _skp
 lda o_win

_skp
 sec
 sbc o_win
 sta o_licz
 jsr _ppoz
 rts

_prod0 ldx n_pat
 lda tapat,x
 sta patadr+1
 clc
 adc #3
 sta pataed
 lda #0
 sta patno
 sta patadr
 lda #1
 sta patmax+1
 lda pause
 sta cnts
 clc
 ldy #vbl
 jmp $0000

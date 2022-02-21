
*-----------------------------------*
* rozpoznaj ilosc dodatkowego RAM'u *
* i wypisz to na ekranie            *
*-----------------------------------*

.proc select

 jsr wait
 ldx >$c0e2
 ldy <$c0e2
 lda #6
 jsr $e45c

 jsr on
 ldx #9
 ldy #0
 tya
_cl_ sta $c000,y
 dey
 bne _cl_
 inc _cl_+2
 dex
 bne _cl_
 jsr of

 jsr wait

 jsr cl_k
 lda <deelka
 sta $230
 lda >deelka
 sta $231
 lda #10
 sta $2c5
 lda #0
 sta $2c6
 lda >$2000
 sta 756

 ldy #0
 tya
_lp0
 sta _bnk,y
 dey
 bne _lp0

 ldy #0
_lp1
 tya
 ora #%10000011
 and #%11101111
 sta $d301
 sta $4000
 iny
 bne _lp1

 ldy #0
_lp2
 tya
 ora #%10000011
 and #%11101111
 sta $d301
 ldx $4000
 lda #1
 sta _bnk,x
 iny
 bne _lp2

 ldy #0
 ldx #0
_sv lda _bnk,y
 beq _skp0
 tya
 sta tab_1,x
 inx
 cpx #32
 beq _skp1

_skp0
 iny
 bne _sv

_skp1
 stx il_bnk
 jsr n_12

 lda #0
 sta $23fd
 sta $23fe
 sta $23ff

 ldx il_bnk
 cpx #1
 bne _ok

 ldx #0
_lp3
 lda ek3+160,x
 sta ek3+120,x
 inx
 cpx #39
 bne _lp3
 jsr cl_k

_skp2
 lda 764
 cmp #33
 bne _skp2
 jmp ($a)

_ok
 sed
 clc
 lda $23fd
 adc #$84
 sta $23fd
 lda $23fe
 adc #$63
 sta $23fe
 lda $23ff
 adc #$01
 sta $23ff
 cld
 dex
 bne _ok

 lda $23fd
 tax
 and #$f
 ora #'0'-32
 sta ek3+146

 txa
 jsr _h
 ora #'0'-32
 sta ek3+145

 lda $23fe
 tax
 and #$f
 ora #'0'-32
 sta ek3+144

 txa
 jsr _h
 ora #'0'-32
 sta ek3+143

 lda $23ff
 tax
 and #$f
 ora #'0'-32
 sta ek3+142

 txa
 jsr _h
 ora #'0'-32
 sta ek3+141

 jsr cl_k

_skp3
 lda 764
 cmp #10
 beq _pokey
 cmp #18
 beq _covox
 jmp _skp3

_pokey jsr wait
 jsr _p0rom
 lda #1
 sta ch_0+1
 sta play_sampl.ch_4+1
 sta _of1+1

 lda #3
 sta ch_1+1
 sta _of2+1

 lda #5
 sta ch_2+1
 sta _of3+1

 lda #7
 sta ch_3+1
 sta _of4+1

 lda #$d2
 sta ch_0+2
 sta ch_1+2
 sta ch_2+2
 sta ch_3+2
 sta play_sampl.ch_4+2
 sta _df1+1
 sta _df2+1
 sta _df3+1
 sta _df4+1
 jsr _p0rom
 jmp init

_covox
 lda <dlk
 sta $230
 lda >dlk
 sta $231

 lda #$ea		; modyfikacja procedury MOVE
 sta move.pocz+3
 sta move.pocz+4
 sta move.pocz+5
 sta move.pocz+6
 sta move.pocz+7
 lda #0
 sta move._eo+1		; koniec modyfikacji procedury MOVE

_loop
 lda 764
 cmp #31
 beq _skp4
 cmp #30
 beq _skp5
 cmp #26
 beq _skp6
 jmp _loop

_skp4
 lda #$d5
 jmp _exit

_skp5
 lda #$d6
 jmp _exit

_skp6
 lda #$d7

_exit
 pha
 jsr _p0rom
 pla
 sta _df1+1
 sta _df2+1
 sta _df3+1
 sta _df4+1
 sta ch_0+2
 sta ch_1+2
 sta ch_2+2
 sta ch_3+2
 sta play_sampl.ch_4+2
 jsr _p0rom
 jsr cl_k
 jmp init

deelka dta d'ppppppppppp'
 dta b($42),a(ek3),b(2),b(2)
 dta b($50),b(2)
 dta b($41),a(deelka)

dlk dta d'ppppppppppp'
 dta b($42),a(ek4)
 dta b($50),b(2),b(2)
 dta b(2),b($41),a(dlk)

ek3 dta d'             select device:             '
    dta d'             Đ-pokey 4-bit              '
    dta d'             Ă-covox 8-bit              '
    dta d'      extended RAM - 000000 bytes       '
    dta d'          i need extended RAM           '

ek4 dta d'             select adress:             '
    dta d'               ±-page $d5               '
    dta d'               ˛-page $d6               '
    dta d'               ł-page $d7               '

.endp
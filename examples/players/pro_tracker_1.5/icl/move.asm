
*-----------------------------------*
* rozpoznaj ilosc dodatkowego RAM'u *
*-----------------------------------*

.proc move

 jsr wait

 ldx il_bnk
 dex
 lda tab_1,x
 sta $d301

 ldx #0
pocz lda $8800,x
 lsr @
 lsr @
 lsr @
 lsr @
 lsr @
_eo eor #$10
kon sta $4000,x
 inx
 bne pocz
 inc pocz+2
 inc kon+2
 lda pocz+2
 cmp #$a8
 bne pocz

 jsr on
 lda #0
 sta $22f
 sta $d400

 ldy #0

_loop
 lda tidl,y
 sta $ff00,y
 lda tid2,y
 sta $fe00,y
 iny
 bne _loop

 jsr of
 jsr wait
 lda #$22
 sta $22f
 rts

.endp

; Title: Green Mile
; Prod type: 128b intro
; nick: goblinish

COLBK = $D01A
WSYNC = $D40A
VCOUNT = $D40B

 org $600

waits
 lda VCOUNT
 bne waits
 sta 559; turn playfield for wide green colors
 tay

 inc $CF ; delay speed
 lda $CF
 and #1
 beq skipy

 inc $CC
 lda $CC
 cmp #$10
 bne br1
 lda #$00
br1
 sta $CC
skipy
 lda $CC
 sta $CB

lp0 sty $CE
 ldy #$00
pass_2 lda $CB
 tax
 clc
 adc #$0A
 sta $CD
putc lda colors,X
 ora #$B0 ;setup color
 sta WSYNC
 sta COLBK
 inx
 cpx $CD
 bne putc

 iny
 cpy #$02
 bne pass_2

 inc $CB
 ldy $CE
 iny
 cpy #$0D
 bne lp0

 beq waits


colors .byte $00,$02,$04,$06,$08,$0A,$0C,$0E
 .byte $0C,$0A,$08,$06,$04,$02,$00,$00
 .byte $02,$04,$06,$08,$0A,$0C,$0E,$0C
 .byte $0A,$08,$06,$04,$02,$00,$00,$02
 .byte $04,$06,$08,$0A,$0C,$0E

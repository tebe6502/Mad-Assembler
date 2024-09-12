	org $2000

fnt
 ins "dots.bin"

start
 lda #fnt/256
 sta 756

 lda 88
 sta drw+1
 lda 89
 sta drw+2
 ldx #24
 lda #0
xlp
 ldy #0
 pha
drw sta 0,y
 jsr inc_1

 iny
 cpy #40
 bne drw
 lda drw+1
 clc
 adc #40
 sta drw+1
 bcc no_down_h
 inc drw+2
no_down_h
 pla
 jsr inc_1
 dex
 bne xlp

dots
 jsr wait_frame

 lda 88
 sta dtv1+1
 sta dtv2+1

 lda 89
 sta dtv1+2
 sta dtv2+2

 lda #23
 sta $CB
lpy
 ldy #39
lpx
dtv1 ldx $1234
 lda inc_t,x
dtv2 sta $1234

 inc dtv2+1
 inc dtv1+1
 bne noinc1
 inc dtv1+2
 inc dtv2+2
noinc1

 dey
 bpl lpx
 dec $CB
 bpl lpy

 jmp dots
;-----------------
wait_frame
RTCLOK      equ $0012
      lda RTCLOK+2
waits
      cmp RTCLOK+2
       beq waits
 rts

inc_t
 dta 1 ; 0
 dta 2 ; 1
 dta 3 ; 2
 dta 4 ; 3
 dta 5 ; 4
 dta 6 ; 5
 dta 7 ; 6
 dta 8 ; 7
 dta 9 ; 8
 dta $A ; 9
 dta $B ; A
 dta 0 ; $C ; B
; dta 0 ; C

inc_1
 clc
 adc #1
 cmp #$0D-1
 bne no_char
 lda #1
no_char
 rts
demoend
	run start

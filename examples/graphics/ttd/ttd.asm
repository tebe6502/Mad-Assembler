* TExTurEs Projector
* All code by SERO/SAMAR
* Last change (2): 30.09.1997
*----------------------------

         org $5000

*----------------------
texture  equ $9d00

coldrw   equ $e6
byte1    equ $e7
kasjer   equ $e8
c        equ $e9
x        equ $ea
y        equ $eb
word1    equ $ec
texadr   equ $ee

*----------------------
start    equ *
 jsr makedl
 ldx <dlist
 ldy >dlist
 stx $230
 sty $231

 lda #%100001
 sta $22f

 lda #%1000001
 sta $26f

 lda #4
 sta $2c6

wait ldy $d40b
 bne wait

 ldx <dli
 ldy >dli
 stx $200
 sty $201

 lda #$c0
 sta $d40e

 ldx <sm+33
 ldy >sm+33
 stx word1
 sty word1+1
 ldy #0
i001 clc
 lda word1
 sta tab_l,y
 adc #21
 sta word1
 lda word1+1
 sta tab_h,y
 adc #0
 sta word1+1
 iny
 cpy #16
 bne i001

 lda #0
 sta x
 sta y
 sta coldrw

loop ldy $d40b
 bne loop
 jsr showtext
 jsr showmrk
 jsr showvals
 lda $14
 and #3
 bne loop

 lda $284
 bne l021

 lda y
 asl @
 asl @
 asl @
 sta byte1

 lda x
 lsr @
 php
 clc
 adc byte1
 tay

 lda coldrw
 plp
 bcs l020
 asl @
 asl @
 asl @
 asl @

l020 sta byte1

 lda (texadr),y
 and kasjer
 ora byte1
 sta (texadr),y

l021 lda $278
 and #1
 bne l001
 dec y

l001 lda $278
 and #2
 bne l002
 inc y

l002 lda $278
 and #4
 bne l003
 dec x

l003 lda $278
 and #8
 bne l004
 inc x

l004 lda x
 and #$f
 sta x
 lda y
 and #$f
 sta y

 ldx 764
 cpx #7
 bne l005
 clc
 lda showtext+1
 adc #16
 sta showtext+1
 bcc l005
 inc showtext+3

l005 cpx #6
 bne l006
 sec
 lda showtext+1
 sbc #16
 sta showtext+1
 bcs l006
 dec showtext+3

l006 cpx #15
 bne l007
 dec showtext+3

l007 cpx #14
 bne l008
 inc showtext+3

l008 cpx #54
 bne l010
 ldy #0
l009 lda (texadr),y
 sta bufor,y
 iny
 bpl l009

l010 cpx #55
 bne l012
 ldy #0
l011 lda bufor,y
 sta (texadr),y
 iny
 bpl l011

l012 cpx #12		; return
 bne l031
 ldy #0
l030 lda (texadr),y
 sta texture,y
 iny
 bpl l030

l031 cpx #33		; space
 bne l013
 lda <texture
 sta showtext+1
 lda >texture
 sta showtext+3
 jmp loop


l013 cpx #56+$80	; cntl+f
 bne l015
 lda coldrw
 asl @
 asl @
 asl @
 asl @
 ora coldrw
 ldy #0
l014 sta (texadr),y
 iny
 bpl l014

l015 cpx #28		; esc
 bne l016
 lda #$40
 sta $d40e
 lda #1
 sta $26f
 jmp $2000

l016 ldy #15		; 0..9 q...y
 txa
l017 cmp tabkey,y
 beq l018
 dey
 bpl l017
 jmp l019
l018 sty coldrw

l019 lda #$ff
 sta 764
 jmp loop

tabkey dta b(50),b(31),b(30),b(26)
 dta b(24),b(29),b(27),b(51),b(53)
 dta b(48),b(47),b(46),b(42),b(40)
 dta b(45),b(43)

*----------------------------
showvals equ *
 ldx #14
 lda showtext+3
 jsr showhex
 lda showtext+1
 jsr showhex
 ldy coldrw
 lda nmbrs,y
 sta texts+32+28
 rts

*----------------------------
showhex  equ *
 sta byte1
 lsr @
 lsr @
 lsr @
 lsr @
 tay
 lda nmbrs,y
 sta texts+35,x
 inx
 lda byte1
 and #$f
 tay
 lda nmbrs,y
 sta texts+35,x
 inx
 rts

nmbrs dta d'0123456789abcdef'

*----------------------------
showtext equ *
 ldx <texture
 ldy >texture
 stx word1
 sty word1+1
 stx texadr
 sty texadr+1

 ldx #0
t000 lda tab_l,x
 sta t002+1
 lda tab_h,x
 sta t002+2

 ldy #7
t001 lda (word1),y
t002 sta sm+33,y
 dey
 bpl t001
 clc
 lda word1
 adc #8
 sta word1
 lda word1+1
 adc #0
 sta word1+1
 inx
 cpx #16
 bne t000
 rts

*----------------------------
showmrk  equ *
 inc c

 ldy y
 lda tab_l,y
 sta word1
 lda tab_h,y
 sta word1+1

 lda x
 lsr @
 tay
 bcs s003

 lda c
 asl @
 asl @
 asl @
 asl @
 sta byte1
 lda #$0f
 jmp s004

s003 lda c
 and #$f
 sta byte1
 lda #$f0

s004 sta kasjer
 and (word1),y
 ora byte1
 sta (word1),y
 rts

*----------------------------
dli      equ *
 pha
 lda #1
 sta $d01b
 pla
 rti

*----------------------------
makedl   equ *
 ldx <sm
 ldy >sm
 stx word1
 sty word1+1
 ldx #18

 lda #$70
 jsr putbyte
 jsr putbyte
 jsr putbyte

m001 ldy #4
m002 lda #$4f
 jsr putbyte
 lda word1
 jsr putbyte
 lda word1+1
 jsr putbyte
 dey
 bne m002
 clc
 lda word1
 adc #21
 sta word1
 bcc m003
 inc word1+1
m003 dex
 bne m001

 lda #1
 jsr putbyte
 lda <dlist2
 jsr putbyte
 lda >dlist2
 jsr putbyte

 rts

putbyte  equ *
 sta dlist
 inc putbyte+1
 bne ptrt
 inc putbyte+2
ptrt rts

*--------------------------
dlist2   equ *
 dta d'–ppp',b($42),a(texts)
 dta d'p"   " " " " " " " " "'
 dta b($41),a(dlist)

*--------------------------
texts    equ *
 dta d'Textures Projector by SERO/SAMAR'
 dta d'   Block adress:$9d00 Color:0   '
 dta d'  Use joystick#1 and keyboard:  '
 dta d'0'*,d'..',d'9'*,d',',d'Q'*,d'..',d'Y'*,d' - choose a color 0..F '
 dta d'û,ü,ù,ú   - set block adress    '
 dta d'Control'*,d'+',d'F'*,d' - fill block          '
 dta d'Clear'*,d'     - block in bufor      '
 dta d'Insert'*,d'    - block from bufor    '
 dta d'Space'*,d'     - show texture        '
 dta d'Return'*,d'    - copy block to text. '
 dta d'Esc'*,d'       - quit program        '


*--------------------------
tab_l    org *+16
tab_h    org *+16
bufor    org *+128

*--------------------------
sm       equ *
 dta d'           $§§§§§§§§',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (        ',$40
 dta d'           $        ',$80
 dta d'           (',c'HHHHHHHH',$40,d'            '

*--------------------------
dlist	equ *

	run start

* Changer od Delta's data format
* By Konop/Shadows in 14.08.95r
* Relocating version 27.03.96r

code   equ $6000
module equ $7000

patts0 equ $2000
trax0  equ $4000
instr0 equ $4400
trax1  equ module
instr1 equ module+$0400

td208  equ module+$0a00
tdelay equ module+$0a20
tfadd  equ module+$0a40
trdela equ module+$0a60
vbdela equ module+$0a80
tsynth equ module+$0aa0
insadl equ module+$0ac0
insadh equ module+$0ae0
tdata  equ module+$0b00
frqtab equ module+$0c00
locs   equ module+$0c80
patadl equ module+$0d00
patadh equ module+$0d40
patts1 equ module+$0d80

wre0   equ $80
wre1   equ $82

pom0   equ $c0
pom1   equ $c1
patnum equ $c2
byte0  equ $c3
byte1  equ $c4
patpos equ $c5
ilepus equ $c7
pom2   equ $c8
pom3   equ $c9
index  equ $ca
instr  equ $cb
pomadd equ $cc

maxpos equ $40
maxpat equ $40
maxslp equ $10
maxins equ $20

 org code

main cld
 nop
 jsr initmem
 jsr pckpat
 lda wre1
 sta $600
 lda wre1+1
 sta $601
 jsr coptrx
 jsr copins
 rts

copins lda #0
 sta instr

_c3 lda instr
 sta pom0
 lda #0
 sta pom1
 ldx #6
_c0 asl pom0
 rol pom1
 dex
 bne _c0
 lda pom0
 clc
 adc <instr0
 sta wre0
 lda pom1
 adc >instr0
 sta wre0+1

 lda instr
 sta pom0
 lda #0
 sta pom1
 ldx #4
_c1 asl pom0
 rol pom1
 dex
 bne _c1
 lda pom0
 sta pom2
 lda pom1
 sta pom3

 asl pom0
 rol pom1

 lda pom0
 clc
 adc pom2
 sta pom0
 lda pom1
 adc pom3
 sta pom1

 lda pom0
 clc
 adc <instr1
 sta wre1
 lda pom1
 adc >instr1
 sta wre1+1

 lda #$00
 sta index
_c2 lda #$0f
 sec
 sbc index
 tay
 lda (wre0),y
 ldy index
 sta (wre1),y
 lda #$1f
 sec
 sbc index
 tay
 lda (wre0),y
 pha
 lda index
 clc
 adc #$10
 tay
 pla
 sta (wre1),y
 lda #$2f
 sec
 sbc index
 tay
 lda (wre0),y
 pha
 lda index
 clc
 adc #$20
 tay
 pla
 sta (wre1),y

 inc index
 lda index
 cmp #maxslp
 bne _c2

 inc instr
 lda instr
 cmp #maxins
 beq _c4
 jmp _c3
_c4 ldx <instr1
 ldy >instr1
 stx wre1
 sty wre1+1

 ldy #0
_c5 lda wre1
 sta insadl,y
 lda wre1+1
 sta insadh,y
 lda wre1
 clc
 adc #$30
 sta wre1
 bcc *+4
 inc wre1+1
 iny
 cpy #maxins
 bne _c5

 ldx <instr0
 ldy >instr0
 stx wre0
 sty wre0+1
 ldx #0
_c6 ldy #$30
 lda (wre0),y
 sta td208,x
 ldy #$31
 lda (wre0),y
 sta tdelay,x
 ldy #$32
 lda (wre0),y
 sta tfadd,x
 ldy #$33
 lda (wre0),y
 bpl _om1
 and #127
 sta vbdela,x
 lda #1
 sta trdela,x
 lda #$80
 sta pomadd
 jmp _om2
_om1 sta trdela,x
 lda #1
 sta vbdela,x
 lda #$00
 sta pomadd
_om2 ldy #$20
 lda (wre0),y
 sta tsynth,x

 stx pom0
 txa
 asl @
 asl @
 clc
 adc pomadd
 tax
 ldy #$34
 lda (wre0),y
 sta tdata+0,x
 ldy #$35
 lda (wre0),y
 sta tdata+1,x
 ldy #$36
 lda (wre0),y
 sta tdata+2,x
 ldy #$37
 lda (wre0),y
 sta tdata+3,x
 ldx pom0

 lda wre0
 clc
 adc #$40
 sta wre0
 bcc *+4
 inc wre0+1
 inx
 cpx #maxins
 bne _c6

 rts

coptrx ldx #0
_b0 lda trax0+$0000,x
 jsr check0
 sta trax1+$0000,x
 lda trax0+$0080,x
*jsr check0
 sta trax1+$0080,x
 lda trax0+$0100,x
*jsr check0
 sta trax1+$0100,x
 lda trax0+$0180,x
*jsr check0
 sta trax1+$0180,x
 lda trax0+$0200,x
*jsr check0
 sta trax1+$0200,x
 lda trax0+$0280,x
*jsr check0
 sta trax1+$0280,x
 lda trax0+$0300,x
*jsr check0
 sta trax1+$0300,x
 lda trax0+$0380,x
*jsr check0
 sta trax1+$0380,x
 inx
 cpx #$80
 bne _b0
 rts

check0 cmp #$40
 beq _up0
 cmp #$41
 beq _up0
 cmp #$42
 beq _up0
 rts
_up0 clc
 adc #$40
 rts

pckpat ldx <patts1
 ldy >patts1
 stx wre1
 sty wre1+1

 lda #0
 sta patnum

_a1 ldy patnum
 lda wre1
 sta patadl,y
 lda wre1+1
 sta patadh,y

 lda patnum
 sta pom0
 lda #0
 sta pom1
 ldx #7
_a0 asl pom0
 rol pom1
 dex
 bne _a0

 lda pom0
 clc
 adc <patts0
 sta wre0
 lda pom1
 adc >patts0
 sta wre0+1

_a2 lda #0
 sta patpos

 lda #0
 sta ilepus

_a3 jsr take0
 jsr end
 jsr puste
 jsr note

 inc patpos
 lda patpos
 cmp #maxpos
 bne _a3

_a5 lda ilepus
 beq _om0
 clc
 adc #$7f
 jsr output
 ldx #1
 jsr add

_om0 lda #$00
 jsr output
 ldx #1
 jsr add

_a4 inc patnum
 lda patnum
 cmp #maxpat
 bne _a1
 rts

puste lda byte0
 ora byte1
 beq _cnt2
 rts
_cnt2 inc ilepus
 rts

note lda byte0
 bmi _cnt1
 rts
_cnt1 lda ilepus
 beq _cnt3
 clc
 adc #$7f
 jsr output
 ldx #1
 jsr add
_cnt3 lda #0
 sta ilepus
 lda byte0
 sec
 sbc #$80
 clc
 adc #$01
 jsr output
 ldx #1
 jsr add
 lda byte1
 jsr output
 ldx #1
 jsr add
 rts

end lda byte1
 cmp #$80
 beq _cnt0
 rts
_cnt0 pla
 pla
 jmp _a5

add txa
 clc
 adc wre1
 sta wre1
 bcc *+4
 inc wre1+1
 rts

output ldy #0
 sta (wre1),y
 rts

take0 lda patpos
 asl @
 tay
 lda (wre0),y
 sta byte0
 iny
 lda (wre0),y
 sta byte1
 rts

initmem ldy #0
 lda #0
_in00 sta tdata,y
 iny
 bne _in00
 rts

 run main

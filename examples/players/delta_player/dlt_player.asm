* THE DELTA PLAYER ROUTINE
* BY KONOP/SHADOWS
* RELOCATING VERSION
* Wymagania:
* 1 kanal zawsze aktywny
* kanal nieaktywny=$ff 

code   equ $af00
module equ $7000
trax1  equ module
insts1 equ module+$0400
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

ilepu0 equ module+$0c80
ilepu1 equ module+$0c81
ilepu2 equ module+$0c82
ilepu3 equ module+$0c83
d200   equ module+$0c84
d201   equ module+$0c85
d202   equ module+$0c86
d203   equ module+$0c87
d204   equ module+$0c88
d205   equ module+$0c89
d206   equ module+$0c8a
d207   equ module+$0c8b
d20810 equ module+$0c8c
d20811 equ module+$0c8d
d20812 equ module+$0c8e
d20813 equ module+$0c8f
note0  equ module+$0c90
note1  equ module+$0c91
note2  equ module+$0c92
note3  equ module+$0c93
instr0 equ module+$0c94
instr1 equ module+$0c95
instr2 equ module+$0c96
instr3 equ module+$0c97
trans0 equ module+$0c98
trans1 equ module+$0c99
trans2 equ module+$0c9a
trans3 equ module+$0c9b
slup0  equ module+$0c9c
slup1  equ module+$0c9d
slup2  equ module+$0c9e
slup3  equ module+$0c9f
delay0 equ module+$0ca0
delay1 equ module+$0ca1
delay2 equ module+$0ca2
delay3 equ module+$0ca3
fadd0  equ module+$0ca4
fadd1  equ module+$0ca5
fadd2  equ module+$0ca6
fadd3  equ module+$0ca7
trdel0 equ module+$0ca8
trdel1 equ module+$0ca9
trdel2 equ module+$0caa
trdel3 equ module+$0cab
vbdel0 equ module+$0cac
vbdel1 equ module+$0cad
vbdel2 equ module+$0cae
vbdel3 equ module+$0caf
synth0 equ module+$0cb0
synth1 equ module+$0cb1
synth2 equ module+$0cb2
synth3 equ module+$0cb3
trpom0 equ module+$0cb4
trpom1 equ module+$0cb5
trpom2 equ module+$0cb6
trpom3 equ module+$0cb7
vbpom0 equ module+$0cb8
vbpom1 equ module+$0cb9
vbpom2 equ module+$0cba
vbpom3 equ module+$0cbb
tindx0 equ module+$0cbc
tindx1 equ module+$0cbd
tindx2 equ module+$0cbe
tindx3 equ module+$0cbf
vindx0 equ module+$0cc0
vindx1 equ module+$0cc1
vindx2 equ module+$0cc2
vindx3 equ module+$0cc3
d20800 equ module+$0cc4
d20801 equ module+$0cc5
d20802 equ module+$0cc6
d20803 equ module+$0cc7
volpm0 equ module+$0cc8
volpm1 equ module+$0cc9
volpm2 equ module+$0cca
volpm3 equ module+$0ccb
k0     equ module+$0ccc
k1     equ module+$0ccd
k2     equ module+$0cce
k3     equ module+$0ccf
ntpom0 equ module+$0cd0
ntpom1 equ module+$0cd1
ntpom2 equ module+$0cd2
ntpom3 equ module+$0cd3
fpm0   equ module+$0cd4
fpm1   equ module+$0cd5
fpm2   equ module+$0cd6
fpm3   equ module+$0cd7
accst0 equ module+$0cd8
accst1 equ module+$0cd9
accst2 equ module+$0cda
accst3 equ module+$0cdb
stat0  equ module+$0cdc
stat1  equ module+$0cdd
stat2  equ module+$0cde
stat3  equ module+$0cdf
plst0  equ module+$0ce0
plst1  equ module+$0ce1
plst2  equ module+$0ce2
plst3  equ module+$0ce3

tempom equ module+$0ce4
tempo  equ module+$0ce5
status equ module+$0ce6
trxpos equ module+$0ce7
patpos equ module+$0ce8

patadl equ module+$0d00
patadh equ module+$0d40
patts1 equ module+$0d80

zeropg equ $f0
ptt0   equ zeropg+$00
ptt1   equ zeropg+$02
ptt2   equ zeropg+$04
ptt3   equ zeropg+$06
ins0   equ zeropg+$08
ins1   equ zeropg+$0a
ins2   equ zeropg+$0c
ins3   equ zeropg+$0e

 org code

main jsr init
go lda 20
 cmp 20
 beq *-2
 jsr player
 jmp go

init ldy #0
_in00 lda #$00
 sta ilepu0,y
 sta d20810,y
 sta note0,y
 sta instr0,y
 sta trans0,y
 sta slup0,y
 sta delay0,y
 sta fadd0,y
 sta trdel0,y
 sta vbdel0,y
 sta synth0,y
 sta trpom0,y
 sta vbpom0,y
 sta tindx0,y
 sta vindx0,y
 sta d20800,y
 sta volpm0,y
 sta k0,y
 sta accst0,y
 iny
 cpy #4
 bne _in00

 lda #$00
 sta trxpos
 lda #$00
 sta tempo
 sec
 sbc #1
 sta tempom
 lda #$ff
 sta status

 ldy #8
 lda #0
_cnt0 sta $d200,y
 sta d200,y
 dey
 bpl _cnt0
 lda #$03
 sta $d20f
 jsr nxtrax
 rts


player lda status
 bne _cont
 rts
_cont inc tempom
 lda tempom
 cmp tempo
 bne _a0
 lda #0
 sta tempom
_b0 inc patpos
 jsr takeb0
 jsr takeb1
 jsr takeb2
 jsr takeb3
_a0 jsr play0
 jsr play1
 jsr play2
 jsr play3

_c0 lda accst0
 bne _d1
 ldx ntpom0
 lda frqtab,x
 clc
 adc fpm0
 sta d200
 lda d20810
 and #4
 beq _d1
 txa
 clc
 adc synth0
 tax
 lda frqtab,x
 clc
 adc fpm0
 clc
 adc #$ff
 sta d204
_d1 equ *

 lda accst1
 bne _d3
 ldx ntpom1
 lda frqtab,x
 clc
 adc fpm1
 sta d202
 lda d20811
 and #2
 beq _d3
 txa
 clc
 adc synth1
 tax
 lda frqtab,x
 clc
 adc fpm1
 clc
 adc #$ff
 sta d206
_d3 equ *

 lda accst2
 bne _d4
 lda d20810
 and #4
 bne _d4
 ldx ntpom2
 lda frqtab,x
 clc
 adc fpm2
 sta d204

_d4 lda accst3
 bne _d5
 lda d20811
 and #2
 bne _d5
 ldx ntpom3
 lda frqtab,x
 clc
 adc fpm3
 sta d206

_d5 equ *
 lda d200
 sta $d200
 lda d201
 sta $d201
 lda d202
 sta $d202
 lda d203
 sta $d203
 lda d204
 sta $d204
 lda d205
 sta $d205
 lda d206
 sta $d206
 lda d207
 sta $d207
 lda d20810
 ora d20811
 ora d20812
 ora d20813
 sta $d208
 rts

takeb0 lda stat0
 beq _k0
 rts
_k0 lda ilepu0
 beq _tk00
 dec ilepu0
 rts
_tk00 ldy #0
 lda (ptt0),y
 beq _end0
 bpl _nut0
 and #127
 sta ilepu0
 inc ptt0
 bne _tk01
 inc ptt0+1
_tk01 rts
_end0 inc trxpos
 jsr nxtrax
 jsr takeb0
 rts
_nut0 clc
 adc trans0
 sta note0
 iny
 lda (ptt0),y
 sta instr0
 tax
 lda insadl,x
 sta ins0
 lda insadh,x
 sta ins0+1
 lda td208,x
*and #%11010101
 sta d20800
 lda tdelay,x
 sta delay0
 lda tfadd,x
 sta fadd0
 lda trdela,x
 sta trdel0
 lda vbdela,x
 sta vbdel0
 lda tsynth,x
 sta synth0
 lda #0
 sta plst0
 sta volpm0
 sta trpom0
 sta vbpom0
 sta slup0
 sta k0
 sta tindx0
 sta vindx0
 lda ptt0
 clc
 adc #2
 sta ptt0
 bcc _tk02
 inc ptt0+1
_tk02 rts

takeb1 lda stat1
 beq _k1
 rts
_k1 lda ilepu1
 beq _tk10
 dec ilepu1
 rts
_tk10 ldy #0
 lda (ptt1),y
 beq _end1
 bpl _nut1
 and #127
 sta ilepu1
 inc ptt1
 bne _tk11
 inc ptt1+1
_tk11 rts
_end1 inc trxpos
 jsr nxtrax
 jsr takeb1
 rts
_nut1 clc
 adc trans1
 sta note1
 iny
 lda (ptt1),y
 sta instr1
 tax
 lda insadl,x
 sta ins1
 lda insadh,x
 sta ins1+1
 lda td208,x
*and #%10000011
 sta d20801
 lda tdelay,x
 sta delay1
 lda tfadd,x
 sta fadd1
 lda trdela,x
 sta trdel1
 lda vbdela,x
 sta vbdel1
 lda tsynth,x
 sta synth1
 lda #0
 sta plst1
 sta volpm1
 sta trpom1
 sta vbpom1
 sta slup1
 sta k1
 sta tindx1
 sta vindx1
 lda ptt1
 clc
 adc #2
 sta ptt1
 bcc _tk12
 inc ptt1+1
_tk12 rts

takeb2 lda stat2
 beq _k2
 rts
_k2 lda ilepu2
 beq _tk20
 dec ilepu2
 rts
_tk20 ldy #0
 lda (ptt2),y
 beq _end2
 bpl _nut2
 and #127
 sta ilepu2
 inc ptt2
 bne _tk21
 inc ptt2+1
_tk21 rts
_end2 inc trxpos
 jsr nxtrax
 jsr takeb2
 rts
_nut2 clc
 adc trans2
 sta note2
 iny
 lda (ptt2),y
 sta instr2
 tax
 lda insadl,x
 sta ins2
 lda insadh,x
 sta ins2+1
 lda td208,x
*and #%10101001
 sta d20802
 lda tdelay,x
 sta delay2
 lda tfadd,x
 sta fadd2
 lda trdela,x
 sta trdel2
 lda vbdela,x
 sta vbdel2
*lda tsynth,x
*sta synth2
 lda #0
 sta plst2
 sta volpm2
 sta trpom2
 sta vbpom2
 sta slup2
 sta k2
 sta tindx2
 sta vindx2
 lda ptt2
 clc
 adc #2
 sta ptt2
 bcc _tk22
 inc ptt2+1
_tk22 rts

takeb3 lda stat3
 beq _k3
 rts
_k3 lda ilepu3
 beq _tk30
 dec ilepu3
 rts
_tk30 ldy #0
 lda (ptt3),y
 beq _end3
 bpl _nut3
 and #127
 sta ilepu3
 inc ptt3
 bne _tk31
 inc ptt3+1
_tk31 rts
_end3 inc trxpos
 jsr nxtrax
 jsr takeb3
 rts
_nut3 clc
 adc trans3
 sta note3
 iny
 lda (ptt3),y
 sta instr3
 tax
 lda insadl,x
 sta ins3
 lda insadh,x
 sta ins3+1
 lda td208,x
*and #%10000001
 sta d20803
 lda tdelay,x
 sta delay3
 lda tfadd,x
 sta fadd3
 lda trdela,x
 sta trdel3
 lda vbdela,x
 sta vbdel3
*lda tsynth,x
*sta synth3
 lda #0
 sta plst3
 sta volpm3
 sta trpom3
 sta vbpom3
 sta slup3
 sta k3
 sta tindx3
 sta vindx3
 lda ptt3
 clc
 adc #2
 sta ptt3
 bcc _tk32
 inc ptt3+1
_tk32 rts

nxtrax lda #0
 sta patpos
 sta ilepu0
 sta ilepu1
 sta ilepu2
 sta ilepu3
 sta d20810
 sta d20811
 sta d20812
 sta d20813
 sta d20800
 sta d20801
 sta d20802
 sta d20803
 lda #$ff
 sta stat0
 sta stat1
 sta stat2
 sta stat3
 sta plst0
 sta plst1
 sta plst2
 sta plst3
 ldx trxpos
 ldy trax1+$0000,x
 bpl _nxpat
 cpy #$82
 beq _tempo
 cpy #$81
 beq _jmp
_stop lda #0
 sta status
 pla
 pla
 pla
 pla
 rts
_tempo ldy trax1+$0080,x
 sty tempo
 inc trxpos
 jsr nxtrax
 rts
_jmp lda trax1+$0080,x
 sta trxpos
 jsr nxtrax
 rts
_nxpat lda patadl,y
 sta ptt0
 lda patadh,y
 sta ptt0+1
 lda trax1+$0080,x
 sta trans0
 lda #0
 sta stat0

 ldy trax1+$0100,x
 bmi _nx0
 lda patadl,y
 sta ptt1
 lda patadh,y
 sta ptt1+1
 lda trax1+$0180,x
 sta trans1
 lda #0
 sta stat1

_nx0 ldy trax1+$0200,x
 bmi _nx1
 lda patadl,y
 sta ptt2
 lda patadh,y
 sta ptt2+1
 lda trax1+$0280,x
 sta trans2
 lda #0
 sta stat2

_nx1 ldy trax1+$0300,x
 bmi _nx2
 lda patadl,y
 sta ptt3
 lda patadh,y
 sta ptt3+1
 lda trax1+$0380,x
 sta trans3
 lda #0
 sta stat3
_nx2 rts

play0 lda stat0
 ora plst0
 beq _po0
 lda d201
 and #$0f
 bne _po0
 lda #$ff
 sta plst0
 rts
_po0 lda #0
 sta accst0
 lda d20800
 sta d20810
 lda instr0
 asl @
 asl @
 tay
 clc
 adc tindx0
 tax
 lda tdata,x
 clc
 adc note0
 and #$7f
 sta ntpom0
 tya
 clc
 adc vindx0
 tax
 lda tdata+$80,x
 clc
 adc k0
 sta fpm0
 lda k0
 clc
 adc fadd0
 sta k0
 inc trpom0
 lda trpom0
 cmp trdel0
 bne _pl00
 lda #0
 sta trpom0
 inc tindx0
 lda tindx0
 and #3
 sta tindx0
_pl00 inc vbpom0
 lda vbpom0
 cmp vbdel0
 bne _pl01
 lda #0
 sta vbpom0
 inc vindx0
 lda vindx0
 and #3
 sta vindx0
_pl01 equ *
 ldy slup0
 cpy #16
 bcc _pl02
 lda delay0
 beq _no00
 inc volpm0
 lda volpm0
 cmp delay0
 bne _no00
 lda #0
 sta volpm0
 lda d201
 tax
 and #$0f
 beq _no00
 dex
 stx d201
_no00 rts
_pl02 inc slup0
 lda (ins0),y
 sta d201
 tya
 clc
 adc #16
 tay
 lda (ins0),y
 bne _acc0
 rts
_acc0 cmp #1
 beq _a01
 cmp #2
 beq _a02
_a03 tya
 clc
 adc #16
 tay
 lda (ins0),y
 clc
 adc ntpom0
 sta ntpom0
 lda #0
 sta d20810
 rts
_a01 tya
 clc
 adc #16
 tay
 lda (ins0),y
 sta d200
 lda #$ff
 sta accst0
 lda #0
 sta d20810
 rts
_a02 tya
 clc
 adc #16
 tay
 lda (ins0),y
 clc
 adc fpm0
 sta fpm0
 lda #0
 sta d20810
 rts

play1 lda stat1
 ora plst1
 beq _p10
 lda d203
 and #$0f
 bne _p10
 lda #$ff
 sta plst1
 rts
_p10 lda #0
 sta accst1
 lda d20801
 sta d20811
 lda instr1
 asl @
 asl @
 tay
 clc
 adc tindx1
 tax
 lda tdata,x
 clc
 adc note1
 and #$7f
 sta ntpom1
 tya
 clc
 adc vindx1
 tax
 lda tdata+$80,x
 clc
 adc k1
 sta fpm1
 lda k1
 clc
 adc fadd1
 sta k1
 inc trpom1
 lda trpom1
 cmp trdel1
 bne _pl10
 lda #0
 sta trpom1
 inc tindx1
 lda tindx1
 and #3
 sta tindx1
_pl10 inc vbpom1
 lda vbpom1
 cmp vbdel1
 bne _pl11
 lda #0
 sta vbpom1
 inc vindx1
 lda vindx1
 and #3
 sta vindx1
_pl11 equ *
 ldy slup1
 cpy #16
 bcc _pl12
 lda delay1
 beq _no10
 inc volpm1
 lda volpm1
 cmp delay1
 bne _no10
 lda #0
 sta volpm1
 lda d203
 tax
 and #$0f
 beq _no10
 dex
 stx d203
_no10 rts
_pl12 inc slup1
 lda (ins1),y
 sta d203
 tya
 clc
 adc #16
 tay
 lda (ins1),y
 bne _acc1
 rts
_acc1 cmp #1
 beq _a11
 cmp #2
 beq _a12
_a13 tya
 clc
 adc #16
 tay
 lda (ins1),y
 clc
 adc ntpom1
 sta ntpom1
 lda #0
 sta d20811
 rts
_a11 tya
 clc
 adc #16
 tay
 lda (ins1),y
 sta d202
 lda #$ff
 sta accst1
 lda #0
 sta d20811
 rts
_a12 tya
 clc
 adc #16
 tay
 lda (ins1),y
 clc
 adc fpm1
 sta fpm1
 lda #0
 sta d20811
 rts

play2 lda stat2
 ora plst2
 beq _p20
 lda d20810
 and #4
 beq _j2
 lda #0
 sta d205
_j2 lda d205
 and #$0f
 bne _p20
 lda #$ff
 sta plst2
 rts
_p20 lda #0
 sta accst2
 lda d20802
 sta d20812
 lda instr2
 asl @
 asl @
 tay
 clc
 adc tindx2
 tax
 lda tdata,x
 clc
 adc note2
 and #$7f
 sta ntpom2
 tya
 clc
 adc vindx2
 tax
 lda tdata+$80,x
 clc
 adc k2
 sta fpm2
 lda k2
 clc
 adc fadd2
 sta k2
 inc trpom2
 lda trpom2
 cmp trdel2
 bne _pl20
 lda #0
 sta trpom2
 inc tindx2
 lda tindx2
 and #3
 sta tindx2
_pl20 inc vbpom2
 lda vbpom2
 cmp vbdel2
 bne _pl21
 lda #0
 sta vbpom2
 inc vindx2
 lda vindx2
 and #3
 sta vindx2
_pl21 equ *
 ldy slup2
 cpy #16
 bcc _pl22
 lda delay2
 beq _no20
 inc volpm2
 lda volpm2
 cmp delay2
 bne _no20
 lda #0
 sta volpm2
 lda d205
 tax
 and #$0f
 beq _no20
 dex
 stx d205
_no20 rts
_pl22 inc slup2
 lda (ins2),y
 sta d205
 tya
 clc
 adc #16
 tay
 lda (ins2),y
 bne _acc2
 rts
_acc2 cmp #1
 beq _a21
 cmp #2
 beq _a22
_a23 tya
 clc
 adc #16
 tay
 lda (ins2),y
 clc
 adc ntpom2
 sta ntpom2
 lda #0
 sta d20812
 rts
_a21 tya
 clc
 adc #16
 tay
 lda (ins2),y
 sta d204
 lda #$ff
 sta accst2
 rts
_a22 tya
 clc
 adc #16
 tay
 lda (ins2),y
 clc
 adc fpm2
 sta fpm2
 rts

play3 lda stat3
 ora plst3
 beq _p30
 lda d20811
 and #2
 beq _j3
 lda #0
 sta d207
_j3 lda d207
 and #$0f
 bne _p30
 lda #$ff
 sta plst3
 rts
_p30 lda #0
 sta accst3
 lda d20803
 sta d20813
 lda instr3
 asl @
 asl @
 tay
 clc
 adc tindx3
 tax
 lda tdata,x
 clc
 adc note3
 and #$7f
 sta ntpom3
 tya
 clc
 adc vindx3
 tax
 lda tdata+$80,x
 clc
 adc k3
 sta fpm3
 lda k3
 clc
 adc fadd3
 sta k3
 inc trpom3
 lda trpom3
 cmp trdel3
 bne _pl30
 lda #0
 sta trpom3
 inc tindx3
 lda tindx3
 and #3
 sta tindx3
_pl30 inc vbpom3
 lda vbpom3
 cmp vbdel3
 bne _pl31
 lda #0
 sta vbpom3
 inc vindx3
 lda vindx3
 and #3
 sta vindx3
_pl31 equ *
 ldy slup3
 cpy #16
 bcc _pl32
 lda delay3
 beq _no30
 inc volpm3
 lda volpm3
 cmp delay3
 bne _no30
 lda #0
 sta volpm3
 lda d207
 tax
 and #$0f
 beq _no30
 dex
 stx d207
_no30 rts
_pl32 inc slup3
 lda (ins3),y
 sta d207
 tya
 clc
 adc #16
 tay
 lda (ins3),y
 bne _acc3
 rts
_acc3 cmp #1
 beq _a31
 cmp #2
 beq _a32
_a33 tya
 clc
 adc #16
 tay
 lda (ins3),y
 clc
 adc ntpom3
 sta ntpom3
 lda #0
 sta d20813
 rts
_a31 tya
 clc
 adc #16
 tay
 lda (ins3),y
 sta d206
 lda #$ff
 sta accst3
 rts
_a32 tya
 clc
 adc #16
 tay
 lda (ins3),y
 clc
 adc fpm3
 sta fpm3
 rts

 org frqtab
 dta 0,255,241,228,215,203,192,181,170,161,152,143,135,127,121,114,107,101,95
 dta 90,85,80,75,71,67,63,60,56,53,50,47,44,42,39,37,35,33,31,29,28,26,24,23
 dta 22,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,255,241,228,0,242,233,218
 dta 206,191,182,170,161,152,143,137,128,122,113,107,101,95,92,86,80,103,96,90
 dta 85,81,76,72,67,63,61,57,52,51,48,45,42,40,37,36,33,31,30,28,27,25,0,22,21
 dta 0,10,9,8,7,6,5,4,3,2,1,0,242,233,218

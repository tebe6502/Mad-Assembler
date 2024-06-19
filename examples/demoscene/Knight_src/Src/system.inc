
OS_BANKSTD = $FF
OS_BANK0   = $E3
OS_BANK1   = $E7
OS_BANK2   = $EB
OS_BANK3   = $EF

BANKSTD = $FE
BANK0   = $E2
BANK1   = $E6
BANK2   = $EA
BANK3   = $EE

STD_CHARS_DEF_ADR = $E000

IOCB0			= $0340
ICCOM			= IOCB0 + $02
ICBAL			= IOCB0 + $04
ICBAH			= IOCB0 + $05
ICBLL			= IOCB0 + $08
ICBLH			= IOCB0 + $09
ICAX1			= IOCB0 + $0A
ICAX2			= IOCB0 + $0B

iocb6 = 928
soundr = $41
critic = $42
atract = $4D
savmsc = 88
ramtop = $6A
dliv    = $200
sdslst	= $230
dlptrs  = $230
sdmctl	= $22F
dmactls = $22F ;559
gtiactls = $26F ;623
colpm0s = 704
colpm1s = 705
colpm2s = 706
colpm3s = 707
colpf0s = 708
colpf1s = 709
colpf2s = 710
colpf3s = 711
colbaks = 712
memlo   = $2E7
chact   = $2F3
kbcodes = 764
eol = 155
adr0 = 203
adr1 = 205
scr = 207
licz = 203
byte0 = 204
crscol = 85
crsrow = 84
oldcol = 95
oldrow = 94
adress = 212
music = $5000
replayer = $5496
setvblv = 58460
exitvblv = 58466
rtclock = $12

dosvec   =   $000A
dosini   =   $000C
pokmsk   =   $0010
runad    =   $02E0
initad   =   $02E2
vvblki   =   $0222

bankMem    = $4000
bankMemEnd = $7FFF


; hardware registers
;
; GTIA
;
hposp0  = $d000
hposp1  = $d001
hposp2  = $d002
hposp3  = $d003
hposm0  = $d004
hposm1  = $d005
hposm2  = $d006
hposm3  = $d007
sizep0  = $d008
sizep1  = $d009
sizep2  = $d00a
sizep3  = $d00b
sizem   = $d00c
grafp0  = $d00d
grafp1  = $d00e
grafp2  = $d00f
grafp3  = $d010
grafm   = $d011
colpm0  = $d012
colpm1  = $d013
colpm2  = $d014
colpm3  = $d015
colpf0  = $d016
colpf1  = $d017
colpf2  = $d018
colpf3  = $d019
colbak  = $d01a
gtiactl = $d01b
vdelay  = $d01c
pmctl   = $d01d
gractl  = $d01d
hitclr  = $d01e
consol  = $d01f
p0pf    = $d004
trig0   = $d010
trig1   = $d011
trig2   = $d012
trig3   = $d013
pal     = $d014
;
; POKEY
;
audf1   = $d200
audc1   = $d201
audf2   = $d202
audc2   = $d203
audf3   = $d204
audc3   = $d205
audf4   = $d206
audc4   = $d207
audctl  = $d208
kbcode  = $d209
stimer  = $d209
random  = $d20a
skrest  = $d20a
potgo   = $d20b
serout  = $d20d
irqen   = $d20e
irqst   = $d20e
skctl   = $d20f
skstat  = $d20f
;
; PIA
;
porta   = $d300
portb   = $d301
pactl   = $d302
pbctl   = $d303
;
; ANTIC
;
dmactl  = $d400
chrctl  = $d401
dlptr   = $d402
hscrol  = $d404
vscrol  = $d405
pmbase  = $d407
chbase  = $d409
wsync   = $d40a
vcount  = $d40b
penh    = $d40c
penv    = $d40d
nmien   = $d40e
nmires  = $d40f
nmist   = $d40f

;
; ROM VECTORS
;
DSKINV   =   $E453
CIOV     =   $E456
SIOV     =   $E459
SETVBV   =   $E45C
SYSVBV   =   $E45F
XITVBV   =   $E462
SIOINV   =   $E465
SENDEV   =   $E468
INTINV   =   $E46B
CIOINV   =   $E46E
SELFSV   =   $E471
WARMSV   =   $E474
COLDSV   =   $E477
RBLOKV   =   $E47A
CSOPIV   =   $E47D
PUPDIV   =   $E480
SELFTSV  =   $E483
PENTV    =   $E486
PHUNLV   =   $E489
PHINIV   =   $E48C
GPDVV    =   $E48F
;
;interrupt vectors
;
nmivec   =   $FFFA
resetvec =   $FFFC
irqvec   =   $FFFE


KEY_SPACE = $21
KEY_ESCAPE = $1C
KEY_A = $3F
KEY_B = $15
KEY_C = $12
KEY_D = $3A
KEY_E = $2A
KEY_F = $38
KEY_G = $3D
KEY_H = $39
KEY_I = $0D
KEY_J = $01
KEY_K = $05
KEY_L = $00
KEY_M = $25
KEY_N = $23
KEY_O = $08
KEY_P = $0A
KEY_Q = $2F
KEY_R = $28
KEY_S = $3E
KEY_T = $2D
KEY_U = $0B
KEY_V = $10
KEY_W = $2E
KEY_X = $16
KEY_Y = $2B
KEY_Z = $17
KEY_1 = $1F
KEY_2 = $1E
KEY_3 = $1A
KEY_4 = $18
KEY_5 = $1D
KEY_6 = $1B
KEY_7 = $33
KEY_8 = $35
KEY_9 = $30
KEY_0 = $32
KEY_COMMA = $20
KEY_DOT = $22
KEY_CONTROL_E = $AA
KEY_CONTROL_N = $A3
KEY_CONTROL_Q = $AF
KEY_CONTROL_S = $BE
KEY_CONTROL_T = $AD
KEY_CONTROL_W = $AE

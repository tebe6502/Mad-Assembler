
ptr0	= $D0		; temporary bytes
ptr1	= $D2		; temporary bytes

fr0	= $D4		; float reg 0
fr1	= $E0		; float reg 1
flptr	= $FC		; pointer to a fp num
cix	= $F2		; index          
inbuff	= $F3		; pointer to ascii num
lbuff	= $580

zfr0	= $DA44		; fr0 = 0
fld0r	= $DD89		; (X:Y) -> fr0
fld1r	= $DD98		; (X:Y) -> fr1
fst0r	= $DDA7		; fr0 -> (X:Y)
fst0p	= $DDAB		; fr0 -> (FLPTR)

afp	= $D800		; ascii -> float
ifp	= $D9AA		; int in fr0 -> float in fr0
fpi	= $D9D2		; float in fr0 -> int in fr0
fasc	= $D8E6		; fr0 -> (inbuff)
fadd	= $DA66		; fr0 + fr1  -> fr0
fsub	= $DA60		; fr0 - fr1  -> fr0
fmul	= $DADB		; fr0 * fr1  -> fr0
fdiv	= $DB28		; fr0 / fr1  -> fr0
fexp	= $DDC0		; e ^ fr0    -> fr0
fexp10	= $DDCC		; 10 ^ fr0   -> fr0
fln	= $DECD		; ln(fr0)    -> fr0
flog10	= $DED1		; log10(fr0) -> fr0

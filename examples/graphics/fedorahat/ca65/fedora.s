.include "atari.inc"
.include "macros.inc"

.export _start
.exportzp tmp1, tmp2

; Imports from plot.s
.import plot, gr8
; Imports from math.s
.import sqrt, sine, initSine

; Constants
        cx     = 160    ; sx / 2
        cy     = 90     ; sy * 15/32
        stepZp = 1      ; sx/320
        startXs = 224   ; sx/5 + cx
        startYs = 154   ; sx/5 + cy
        numZi   = 128   ; (-64+64)

        initAZt = $FF02 ; FP (1/64)^2 - 2/64
        initZt2 = 8192  ; FP 1
        stepZt2 = 4     ; FP 2 * (1/64)^2
        initAXf = 102   ; FP 256 * (20/(9*sx))^2 = 256 * (1/144)^2
        stepXf2 = 204   ; FP 256 * 2*(20/(9*sx))^2 = 256 * 2*(1/144)^2

.data

.zeropage
zt2:    .res    2
azt:    .res    2
xs:     .res    1
ys:     .res    1
zi:     .res    1

x1:     .res    2
x2:     .res    2
y1:     .res    1
xf2:    .res    3
axf:    .res    2
di:     .res    2
tmp1:   .res    2
tmp2:   .res    2

.code

_start:
        ; Clear RT clock before start
        lda #0
        sta RTCLOK+2
        sta RTCLOK+1
        sta RTCLOK

        jsr gr8
        jsr initSine

        mvax zt2, #initZt2
        mvax azt, #initAZt
        mva xs, #startXs
        mva ys, #startYs
        mva zi, #numZi

        ; Outer for loop:

loopZi:
        ; x1 = x2 = xs
        lda xs
        ldx #0
        stax x1
        stax x2
        ; xf2 = 0
        stx xf2
        stx xf2+1
        stx xf2+2
        ; axf = initAXf
        ldax #initAXf
        stax axf

        ; Inner loop:

loopX:
        ; AX = xf^2 = xf2 >> 8
        ldax xf2+1
        ; tmp1 = xf*xf + zt*zt
        addax tmp1, zt2
        ; di = sqrt(tmp1)
        ldax tmp1
        jsr sqrt
        stax di
        ; tmp1 = di * 3; di = di * 2
        asl di
        rol di+1
        addax tmp1, di
        ; tmp2 = sin(tmp1)
        ldax tmp1
        jsr sine
        stax tmp2
        ; AX = tmp1 * 3
        ldax tmp1
        asl tmp1
        rol tmp1+1
        addax tmp1
        ; AX = sin(AX) = sin(9*di)
        jsr sine

        ; AX = (1/2 - 1/8 + 1/32) * AX = 0.40625 * sin(9*di)
        stx tmp1+1
        cpx #128
        ror tmp1+1
        ror a
        ldx tmp1+1
        sta tmp1
        cpx #128
        ror tmp1+1
        ror a
        cpx #128
        ror tmp1+1
        ror a

        pha
        sec
        eor #255
        adc tmp1
        sta tmp1
        txa
        sbc tmp1+1
        tax
        pla

        cpx #128
        ror tmp1+1
        ror a
        cpx #128
        ror tmp1+1
        ror a

        clc
        adc tmp1
        pha
        txa
        adc tmp1+1
        tax
        pla

        ; tmp2 += AX = sin(3*di) + 0.375 * sin(9*di)
        addax tmp2, tmp2

        ; tmp2 * 320 * 7 / 40 = tmp2 * 56 = tmp2 * 64 - tmp2 * 8
        ;                     = (t2<<6 - t2<<3)>>13
        ;                     = (t2<<1 - t2>>2)>>8
        tax
        lda tmp2  ; NOTE: AX holds tmp2
        ; tmp2 = tmp2 >> 2
        cpx #128
        ror tmp2+1
        ror tmp2
        cpx #128
        ror tmp2+1
        ror tmp2
        ; tmp1/A = AX << 1 ()
        stx tmp1+1
        asl a
        rol tmp1+1
        ; A = (t2<<1 - t2>>2) >> 8
        sec
        sbc tmp2
        lda tmp1+1
        sbc tmp2+1
        ; y1 = -A + ys
        eor #255
        clc
        adc ys
        sta y1

        ; plot x1, y1
        ldax x1
        ldy y1
        jsr plot

        ; plot x2, y1
        ldax x2
        ldy y1
        jsr plot

        ; Condition: if(2*di>=2.0) break;
        lda di+1
        cmp #64
        bcs endLoopX

        ; End of inner loop: x1++, x2--, xf2+=axf, axf+=stepXf2
        inc x1
        bne @ninc1
        inc x1+1
@ninc1: dec x2
        lda xf2
        clc
        adc axf
        sta xf2
        lda xf2+1
        adc axf+1
        sta xf2+1
        bcc @ninc2
        inc xf2+2
@ninc2: lda axf
        clc
        adc #stepXf2
        sta axf
        bcc @noinc1
        inc axf+1
@noinc1:
        jmp loopX

endLoopX:
        ; End of outer loop: zt2+=azt, azt+=stepZt2, xs--, ys--
        dec xs
        dec ys

        lda zt2
        clc
        adc azt
        sta zt2
        lda zt2+1
        adc azt+1
        sta zt2+1

        lda azt
        clc
        adc #stepZt2
        sta azt
        bcc @noadd
        inc azt+1
@noadd:
        ; Condition: zi--; if( zi<0 ) break;
        dec zi
        bmi @skip
        jmp loopZi
@skip:


        ; Read clock
@rdClk: lda RTCLOK+2
        ldx RTCLOK+1
        ldy RTCLOK
        cmp RTCLOK+2
        bne @rdClk

        ; End of program
@end:
        jmp @end


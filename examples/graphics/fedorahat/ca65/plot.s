.include "atari.inc"
.include "macros.inc"

.export plot, gr8
.importzp tmp1, tmp2

.zeropage

.code

.proc plot
        stax tmp1

        clc
        adc #<lastY
        sta @lyPtr+1
        sta @lyPtr2+1
        txa
        adc #>lastY
        sta @lyPtr+2
        sta @lyPtr2+2

@lyPtr:
        cpy lastY

        bcs @end

@lyPtr2:
        sty lastY

        lda grLinL,y
        ldx grLinH,y

        dec tmp1+1
        bmi @ok
        bne @end

        clc
        adc #32
        bcc @ok
        inx
@ok:
        stax tmp2
        ldx  tmp1
        ldy  grPos0, x
        lda  grMask, x

        ora (tmp2),y
        sta (tmp2),y

@end:
        rts

.endproc

.bss
.align 256
grLinL: .res 192
.align 256
grLinH: .res 192
.align 256
grPos0: .res 256
grMask: .res 256
lastY : .res 320

.code

.proc gr8
        ldx #$60
        lda #CLOSE
        sta ICCOM,x
        jsr CIOV

        ldx #$60
        lda #8+16
        sta ICAX2,x
        lda #0
        sta ICAX1,x
        lda #>devstr
        sta ICBAH,x
        lda #<devstr
        sta ICBAL,x
        lda #OPEN
        sta ICCOM,x
        jsr CIOV

        ldax SAVMSC
        ldy #0

loop:
        sta grLinL,y
        clc
        adc #40
        pha
        txa
        sta grLinH,y
        adc #0
        tax
        pla

        iny
        cpy #192
        bne loop

        ldy #0
        lda #128
        ldx #0

loop2:
        pha
        txa
        sta grPos0,y
        pla
        sta grMask,y
        iny
        lsr a
        bcc loop2
        lda #128
        inx
        cpy #0
        bne loop2

outLoop2:
        lda #192
        ldy #160
loop3:
        sta lastY-1,y
        sta lastY+160-1,y
        dey
        bne loop3


        rts

.rodata
devstr:
        .byte "S:", ATEOL
.code

.endproc


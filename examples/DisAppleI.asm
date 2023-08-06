
;    opt h-
                          org $0800
L0800     LDA #$13
 STA $86
L0804     JSR L0812
 JSR L08EF
 STA $84
 STY $85
 DEC $86
 BNE L0804
L0812     JSR L08D3
 LDA ($84,X)
 TAY
 LSR @
 BCC L0826
 LSR @
 BCS L0835
 CMP #$22
 BEQ L0835
 AND #$07
 ORA #$80
L0826     LSR @
 TAX
 LDA L08FE,X
 BCS L0831
 LSR @
 LSR @
 LSR @
 LSR @
L0831     AND #$0F
 BNE L0839
L0835     LDY #$80
 LDA #$00
L0839     TAX
 LDA L0942,X
 STA $80
 AND #$03
 STA $81
 TYA
 AND #$8F
 TAX
 TYA
 LDY #$03
 CPX #$8A
 BEQ L0859
L084E     LSR @
 BCC L0859
 LSR @
L0852     LSR @
 ORA #$20
 DEY
 BNE L0852
 INY
L0859     DEY
 BNE L084E
 PHA
L085D     LDA ($84),Y
 JSR L_FFDC
 LDX #$01
L0864     JSR L08E6
 CPY $81
 INY
 BCC L085D
 LDX #$03
 CPY #$04
 BCC L0864
 PLA
 TAY
 LDA L095C,Y
 STA $82
 LDA L099C,Y
 STA $83
L087E     LDA #$00
 LDY #$05
L0882     ASL $83
 ROL $82
 ROL @
 DEY
 BNE L0882
 ADC #$BF
 JSR L_FFEF
 DEX
 BNE L087E
 JSR L08E4
 LDX #$06
L0897     CPX #$03
 BNE L08AD
 LDY $81
 BEQ L08AD
L089F     LDA $80
 CMP #$E8
 LDA ($84),Y
 BCS L08C3
 JSR L_FFDC
 DEY
 BNE L089F
L08AD     ASL $80
 BCC L08BF
 LDA L094F,X
 JSR L_FFEF
 LDA L0955,X
 BEQ L08BF
 JSR L_FFEF
L08BF     DEX
 BNE L0897
 RTS
L08C3     JSR L08F2
 TAX
 INX
 BNE L08CB
 INY
L08CB     TYA
L08CC     JSR L_FFDC
 TXA
 JMP L_FFDC
L08D3     LDA #$8D
 JSR L_FFEF
 LDA $85
 LDX $84
 JSR L08CC
 LDA #$AD
 JSR L_FFEF
L08E4     LDX #$03
L08E6     LDA #$A0
 JSR L_FFEF
L08EB     DEX
 BNE L08E6
 RTS
L08EF     LDA $81
 SEC
L08F2     LDY $85
 TAX
 BPL L08F8
 DEY
L08F8     ADC $84
 BCC L08FD
 INY
L08FD     RTS

L08FE
.HE 40 02 45 03 D0 08 40 09 30 22 45 33 D0 08 40 09 40 02 45 33 D0 08 40 09 40 00 40 B0 D0 00 40 00 00 22 44 33 D0 8C 44 00 11 22 44 33 D0 8C 44 9A 10 22 44 33 D0 08 40 09 10 22 44 33 D0 08 40 09 62 13 78 A9
L0942
.HE 00 21 81 82 00 00 59 4D 91 92 86 4A 85
L094F
.HE 9D AC A9 AC A3 A8
L0955
.HE A4 D9 00 D8 A4 A4 00
L095C
.HE 1C 8A 1C 23 5D 8B 1B A1 9D 8A 1D 23 9D 8B 1D A1 00 29 19 AE 69 A8 19 23 24 53 1B 23 24 53 19 A1 00 1A 5B 5B A5 69 24 24 AE AE A8 AD 29 00 7C 00 15 9C 6D 00 A5 69 29 53 84 13 34 11 A5 69 23 A0
L099C
.HE D8 62 5A 48 26 62 94 88 54 44 C8 54 68 44 E8 94 00 B4 08 84 74 B4 28 6E 74 F4 CC 4A 72 F2 A4 8A 00 AA A2 A2 74 74 74 72 44 68 B2 32 B2 00 22 00 1A 1A 26 00 72 72 88 C8 C4 CA 26 48 44 44 A2 C8

; .HE FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 20 00 08 4C 1F FF FF FF FF FF FF FF FF FF FF FF

;dsp     equ $d012     ; write ascii

; $ffdc
; print A as 2 hex digits
L_FFDC
prbyte:
        pha
        lsr
        lsr
        lsr
        lsr               ; high nybble first (shift into low nybble)
        jsr prnybble
        pla               ; fall thru to print low nybble

; $ffe5
; print the low nybble of A as '0'-'9' or 'A'-'F'
prnybble:
        and #$0f
        ora #$b0          ; '0'
        cmp #$ba          ; '9'+1
        bcc cout          ; <='9'
        adc #6            ; $BA+6+carry = $C1 'A'

; $ffef
; print the ascii char in A to the display
L_FFEF
cout:
        bit dsp
        bmi cout          ; wait for the display to be not-busy
        sta dsp
;        rts

; Atari
TIMVEC2 equ $0228
TIMCNT2 equ $021A
        lda #1
        sta TIMCNT2
        rts

dsp        brk
dspi    equ $87
outp    equ $88

init
 lda <L0800
 sta $84
 lda >L0800
 sta $85
 ldy <print
 ldx >print
 lda #9
 jmp $E45C

isa lda $58
 sta outp
 lda $59
 sta outp+1
 lda #40
 sta dspi
 rts

start
 jsr init
 jsr isa
 jsr L0800
@ lda dsp
 bmi @-
 ldx #2
 lda #$8D
 jsr print+5
 bne start+3

print
 lda dsp
 bpl printx
 cmp #$8D
 clc
 bne @+
 lda #$A0
 sec
@ rol @
 sbc #$40
 lsr @
@ sta (outp-2,x)
 sta dsp
 inc outp
 bne @+
 inc outp+1
@ dec dspi
 bcc printx
 bne @-1
 lda #$28
 sta dspi
printx rts

 run start

        end

^[\dA-F]{4}\s+([\dA-F]{2}\s){1,3}\s+(?=\s|L\d)
\bA(?=\n)

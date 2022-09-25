;    Divide by 10 (Sixteen bit)
;    By Omegamatrix
;
;    Rev 2
;    last update May 27, 2014

      processor 6502
      include vcs.h




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      SWITCHES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;1 = first routine (111 cycles max, 96 bytes)
;0 = second routine (126 cycles max, 79 bytes)
ORIGINAL_ROUTINE = 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U variables
        ORG $80

counterHigh       ds 1
counterLow        ds 1

accurateTensHigh  ds 1
accurateTensLow   ds 1

highTen           ds 1
lowTen            ds 1

tensCounter       ds 1
temp              ds 1

badResultFlag     ds 1


loopCount        ds 1
breakPoint       ds 1
screenFlag       ds 1
showNumFlag      ds 1
badValueFlag     ds 1
gfxPtrs          ds 12



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      MAIN PROGRAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG code
        ORG $F000

START:
    cld
    ldx    #0
    txa
.loopClear:
    dex
    txs
    pha
    bne    .loopClear

    sta    WSYNC
;---------------------------------------
    sta    CTRLPF                ;3  @3
    lda    #$0F                  ;2  @5     white
    sta    COLUP0                ;3  @8
    sta    COLUP1                ;3  @11
    sta    VDELP0                ;3  @14    delay
    sta    VDELP1                ;3  @17
    lda    #$03                  ;2  @19
    sta    NUSIZ0                ;3  @22    3 copies close
    sta    NUSIZ1                ;3  @25
    lda    #$B0                  ;2  @27    right 5
    sta    HMP0                  ;3  @30
    lda    #$C0                  ;2  @32    right 4
    sta    HMP1                  ;3  @35
    sta    RESP0                 ;3  @38
    sta    RESP1                 ;3  @41
    lda    #>Zero                ;2  @43    store high nibble
    sta    gfxPtrs+1             ;3  @46
    sta    gfxPtrs+3             ;3  @49
    sta    gfxPtrs+5             ;3  @52
    sta    gfxPtrs+7             ;3  @55
    sta    gfxPtrs+9             ;3  @58
    sta    gfxPtrs+11            ;3  @61
    ldy    #40                   ;2  @63

    sta    WSYNC                 ;3
;---------------------------------------
    sta    HMOVE


;hammer VSYNC a bunch of times, stop Stella from auto-detecting "PAL" format

.loopForceStellaToNTSC:
    lda    #$0E
.loopVsync:
    sta    WSYNC
;---------------------------------------
    sta    VSYNC
    lsr
    bne    .loopVsync
    dey
    bpl    .loopForceStellaToNTSC
    jmp    .startBigDivide        ; start the test



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      TESTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.innerLoop:
    inc    tensCounter
    lda    tensCounter
    cmp    #10
    bne    .increaseMainCount

;reload
    lda    #0
    sta    tensCounter

;increase 10's
    lda    accurateTensLow
    clc
    adc    #1
    sta    accurateTensLow
    lda    accurateTensHigh
    adc    #0
    sta    accurateTensHigh


.increaseMainCount:
    lda    counterLow
    clc
    adc    #1
    sta    counterLow
    lda    counterHigh
    adc    #0
    sta    counterHigh
                                 ; is counter = $0000 ?
    bne    .gotoBigDivide        ; - no
    lda    counterLow            ; check lower half...
    bne    .gotoBigDivide        ; - no
    jmp    DisplayResult         ; - yes, all done

.gotoBigDivide:
    jmp    .startBigDivide




    align 256


  IF ORIGINAL_ROUTINE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    UNSIGNED DIVIDE BY 10 (16 BIT)
;    111 cycles (max), 96 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TensRemaining:
    .byte 0,25,51,76,102,128,153,179,204,230
ModRemaing:
    .byte 0,6,2,8,4,0,6,2,8,4


.overflowFound:
    cmp    #4                    ;2  @74  We have overflowed, but we can apply a shortcut.
    lda    #25                   ;2  @76  Divide by 10 will be at least 25, and the
    bne    .finishLowTen         ;3  @79  carry is set when higher for the next addition.
                                 ; always branch

.startBigDivide:
    lda    counterHigh           ;3  @3

    sta    temp                  ;3  @6
    lsr                          ;2  @8
    adc    #13                   ;2  @10
    adc    temp                  ;3  @13
    ror                          ;2  @15
    lsr                          ;2  @17
    lsr                          ;2  @19
    adc    temp                  ;3  @22
    ror                          ;2  @24
    adc    temp                  ;3  @27
    ror                          ;2  @29
    lsr                          ;2  @31
    and    #$7C                  ;2  @33   AND'ing here...
    sta    temp                  ;3  @36   and saving result as highTen (times 4)
    lsr                          ;2  @38
    lsr                          ;2  @40
    sta    highTen               ;3  @43

    adc    temp                  ;3  @46   highTen (times 5)
    asl                          ;2  @48   highTen (times 10)
    sbc    counterHigh           ;3  @51
    eor    #$FF                  ;2  @53
    tay                          ;2  @55   mod 10 result!

    lda    TensRemaining,Y       ;4  @59   Fill the low byte with the tens it should
    sta    lowTen                ;3  @62   have at this point from the high byte divide.
    lda    counterLow            ;3  @65
    adc    ModRemaing,Y          ;4  @69
    bcs    .overflowFound        ;2³ @71/72
    sta    temp                  ;3  @74
    lsr                          ;2  @76
    adc    #13                   ;2  @78
    adc    temp                  ;3  @81
    ror                          ;2  @83
    lsr                          ;2  @85
    lsr                          ;2  @87
    adc    temp                  ;3  @90
    ror                          ;2  @92
    adc    temp                  ;3  @95
    ror                          ;2  @97
    lsr                          ;2  @99
    lsr                          ;2  @101
    lsr                          ;2  @103
    clc                          ;2  @105
.finishLowTen:
    adc    lowTen                ;3  @108
    sta    lowTen                ;3  @111



  ELSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    UNSIGNED DIVIDE BY 10 (16 BIT)
;    126 cycles (max), 79 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TensRemaining:
    .byte 0,25,51,76,102,128,153,179,204,230
ModRemaing:
    .byte 0,6,2,8,4,0,6,2,8,4

.startBigDivide:
    ldy    #-2                   ;2  @2   skips a branch the first time through
    lda    counterHigh           ;3  @5
.do8bitDiv:
    sta    temp                  ;3  @8
    lsr                          ;2  @10
    adc    #13                   ;2  @12
    adc    temp                  ;3  @15
    ror                          ;2  @17
    lsr                          ;2  @19
    lsr                          ;2  @21
    adc    temp                  ;3  @24
    ror                          ;2  @26
    adc    temp                  ;3  @29
    ror                          ;2  @31
    lsr                          ;2  @33
    and    #$7C                  ;2  @35   AND'ing here...
    sta    temp                  ;3  @38   and saving result as highTen (times 4)
    lsr                          ;2  @40
    lsr                          ;2  @42
    iny                          ;2  @44
    bpl    .finishLowTen         ;2³ @46/47...120

    sta    highTen               ;3  @49
    adc    temp                  ;3  @52   highTen (times 5)
    asl                          ;2  @54   highTen (times 10)
    sbc    counterHigh           ;3  @57
    eor    #$FF                  ;2  @59
    tay                          ;2  @61   mod 10 result!

    lda    TensRemaining,Y       ;4  @65   Fill the low byte with the tens it should
    sta    lowTen                ;3  @68   have at this point from the high byte divide.
    lda    counterLow            ;3  @71
    adc    ModRemaing,Y          ;4  @75
    bcc    .do8bitDiv            ;2³ @77/78

.overflowFound:
    cmp    #4                    ;2  @79   We have overflowed, but we can apply a shortcut.
    lda    #25                   ;2  @81   Divide by 10 will be at least 25, and the
                                 ;         carry is set when higher for the next addition.
.finishLowTen:
    adc    lowTen                ;3  @123
    sta    lowTen                ;3  @126  routine ends at either 87 or 126 cycles

  ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       END DIVIDE BY 10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda    lowTen
    cmp    accurateTensLow       ; verify result
    bne    .setBadFlag
    lda    highTen
    cmp    accurateTensHigh
    bne    .setBadFlag
    jmp    .innerLoop

.setBadFlag:
    lda    #$FF
    sta    badResultFlag
;     jmp    .innerLoop

DisplayResult:
    lda    badResultFlag
    bne    .badResult



.goodResult:
    lda    #$C4              ; green
    sta    COLUBK
    bne    LoopKernel        ; always branch

.showBadResult:
    inc    showNumFlag
.badResult:
    lda    #$42              ; red
    sta    COLUBK
    inc    screenFlag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      KERNEL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoopKernel:
    lda    #$0E
.loopKernelVsync:
    sta    WSYNC             ; do three lines of Vsync
;---------------------------------------
    sta    VSYNC
    lsr
    bne    .loopKernelVsync

    lda    #46
    sta    TIM64T
.loopVBLANK
    lda    INTIM
    bne    .loopVBLANK
    sta    WSYNC
    sta    VBLANK            ; Vblank ends
    lda    screenFlag
    bne    .doFailedScreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      PASSED SCREEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldy    #93
.loopPassedPtrs:
    sta    WSYNC
;---------------------------------------
    lda    #<PassedOne           ;2  @2
    sta    gfxPtrs               ;3  @5
    lda    #<PassedTwo           ;3  @8
    sta    gfxPtrs+2             ;3  @11
    lda    #<PassedThree         ;3  @14
    sta    gfxPtrs+4             ;3  @17
    lda    #<PassedFour          ;3  @20
    sta    gfxPtrs+6             ;3  @23
    lda    #<PassedFive          ;3  @26
    sta    gfxPtrs+8             ;3  @29
    lda    #<PassedSix           ;3  @32
    sta    gfxPtrs+10            ;3  @35
    dey                          ;2  @37
    bne    .loopPassedPtrs       ;2³ @39/40
    beq    .finishScreen         ;3  @41   always branch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      FAILED SCREEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.doFailedScreen:
    ldy    #93
.loopFailedPtrs:
    sta    WSYNC
;---------------------------------------
    lda    #<FailedOne           ;2  @2
    sta    gfxPtrs               ;3  @5
    lda    #<FailedTwo           ;3  @8
    sta    gfxPtrs+2             ;3  @11
    lda    #<FailedThree         ;3  @14
    sta    gfxPtrs+4             ;3  @17
    lda    #<FailedFour          ;3  @20
    sta    gfxPtrs+6             ;3  @23
    lda    #<FailedFive          ;3  @26
    sta    gfxPtrs+8             ;3  @29
    lda    #<FailedSix           ;3  @32
    sta    gfxPtrs+10            ;3  @35
    dey                          ;2  @37
    bne    .loopFailedPtrs       ;2³ @39/40

.finishScreen:
    jsr    SixByteDisplay
    jsr    MidPointReload
    jsr    SixByteDisplay


    ldy    #86
.loopBottom:
    sta    WSYNC
;---------------------------------------
    dey                          ;2  @2
    bne    .loopBottom           ;2³ @4/5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      OVERSCAN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda    #$02
    sta    VBLANK
    lda    #25
    sta    TIM64T
.loopOVERSCAN:
    lda    INTIM
    bne    .loopOVERSCAN
    jmp    LoopKernel








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      SUBROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ORG $F800

SixByteDisplay SUBROUTINE
    ldy    #7
    sty    loopCount
.loopSixByteDisplay:
    ldy    loopCount             ;3  @64
    lda    (gfxPtrs+10),Y        ;5  @69
    sta    temp                  ;3  @72    6th
    sta    WSYNC                 ;3
;---------------------------------------
    lda    (gfxPtrs),Y           ;5  @5     1st
    sta    GRP0                  ;3  @8
    lda    (gfxPtrs+2),Y         ;5  @13    2nd
    sta    GRP1                  ;3  @16
    lda    (gfxPtrs+4),Y         ;5  @21    3rd
    sta    GRP0                  ;3  @24
    lda    (gfxPtrs+8),Y         ;5  @29    5th
    tax                          ;2  @31
    lda    (gfxPtrs+6),Y         ;5  @36    4th
    ldy    temp                  ;3  @39
    nop                          ;2  @41
    sta    GRP1                  ;3  @44
    stx    GRP0                  ;3  @47
    sty    GRP1                  ;3  @50
    sta    GRP0                  ;3  @53
    dec    loopCount             ;5  @58
    bpl    .loopSixByteDisplay   ;2³ @60/61
    lda    #0                    ;2  @62
    sta    GRP1                  ;3  @65
    sta    GRP0                  ;3  @68
    sta    GRP1                  ;3  @71
    sta    GRP0                  ;3  @74
;---------------------------------------
    rts                          ;6  @4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MidPointReload SUBROUTINE
    sta    WSYNC
;---------------------------------------
    lda    showNumFlag           ;3  @3
    bne    .showGFX              ;2³ @5/6
.hideGFX:
    lda    #<BlankDigit          ;2  @7
    sta    gfxPtrs+10            ;3  @10
    sta    gfxPtrs+8             ;3  @13
    sta    gfxPtrs+6             ;3  @16
    sta    gfxPtrs+4             ;3  @19
    sta    gfxPtrs+2             ;3  @22
    sta    gfxPtrs               ;3  @25
    bne    .endMidRoutine        ;3  @28   always branch

.showGFX
    ldx    breakPoint            ;3  @9
    lda    OnesTable,X           ;4  @13
    sta    gfxPtrs+10            ;3  @16
    lda    TensTable,X           ;4  @20
    sta    gfxPtrs+8             ;3  @23
    lda    HundredsTable,X       ;4  @27
    sta    gfxPtrs+6             ;3  @30
    lda    #<BlankDigit          ;2  @32
    sta    gfxPtrs+4             ;3  @35
    sta    gfxPtrs               ;3  @38
    lda    #<AtSymbol            ;2  @40
    sta    gfxPtrs+2             ;3  @43
.endMidRoutine:
    sta    WSYNC
;---------------------------------------
    rts                          ;6  @6


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      DATA AND GFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



        ORG $FC00

;1's digit low pointers, note all digits are LEFT aligned

OnesTable:
     .byte <BlankDigit  ; 0
     .byte <BlankDigit  ; 1
     .byte <BlankDigit  ; 2
     .byte <BlankDigit  ; 3
     .byte <BlankDigit  ; 4
     .byte <BlankDigit  ; 5
     .byte <BlankDigit  ; 6
     .byte <BlankDigit  ; 7
     .byte <BlankDigit  ; 8
     .byte <BlankDigit  ; 9
     .byte <BlankDigit  ; 10
     .byte <BlankDigit  ; 11
     .byte <BlankDigit  ; 12
     .byte <BlankDigit  ; 13
     .byte <BlankDigit  ; 14
     .byte <BlankDigit  ; 15
     .byte <BlankDigit  ; 16
     .byte <BlankDigit  ; 17
     .byte <BlankDigit  ; 18
     .byte <BlankDigit  ; 19
     .byte <BlankDigit  ; 20
     .byte <BlankDigit  ; 21
     .byte <BlankDigit  ; 22
     .byte <BlankDigit  ; 23
     .byte <BlankDigit  ; 24
     .byte <BlankDigit  ; 25
     .byte <BlankDigit  ; 26
     .byte <BlankDigit  ; 27
     .byte <BlankDigit  ; 28
     .byte <BlankDigit  ; 29
     .byte <BlankDigit  ; 30
     .byte <BlankDigit  ; 31
     .byte <BlankDigit  ; 32
     .byte <BlankDigit  ; 33
     .byte <BlankDigit  ; 34
     .byte <BlankDigit  ; 35
     .byte <BlankDigit  ; 36
     .byte <BlankDigit  ; 37
     .byte <BlankDigit  ; 38
     .byte <BlankDigit  ; 39
     .byte <BlankDigit  ; 40
     .byte <BlankDigit  ; 41
     .byte <BlankDigit  ; 42
     .byte <BlankDigit  ; 43
     .byte <BlankDigit  ; 44
     .byte <BlankDigit  ; 45
     .byte <BlankDigit  ; 46
     .byte <BlankDigit  ; 47
     .byte <BlankDigit  ; 48
     .byte <BlankDigit  ; 49
     .byte <BlankDigit  ; 50
     .byte <BlankDigit  ; 51
     .byte <BlankDigit  ; 52
     .byte <BlankDigit  ; 53
     .byte <BlankDigit  ; 54
     .byte <BlankDigit  ; 55
     .byte <BlankDigit  ; 56
     .byte <BlankDigit  ; 57
     .byte <BlankDigit  ; 58
     .byte <BlankDigit  ; 59
     .byte <BlankDigit  ; 60
     .byte <BlankDigit  ; 61
     .byte <BlankDigit  ; 62
     .byte <BlankDigit  ; 63
     .byte <BlankDigit  ; 64
     .byte <BlankDigit  ; 65
     .byte <BlankDigit  ; 66
     .byte <BlankDigit  ; 67
     .byte <BlankDigit  ; 68
     .byte <BlankDigit  ; 69
     .byte <BlankDigit  ; 70
     .byte <BlankDigit  ; 71
     .byte <BlankDigit  ; 72
     .byte <BlankDigit  ; 73
     .byte <BlankDigit  ; 74
     .byte <BlankDigit  ; 75
     .byte <BlankDigit  ; 76
     .byte <BlankDigit  ; 77
     .byte <BlankDigit  ; 78
     .byte <BlankDigit  ; 79
     .byte <BlankDigit  ; 80
     .byte <BlankDigit  ; 81
     .byte <BlankDigit  ; 82
     .byte <BlankDigit  ; 83
     .byte <BlankDigit  ; 84
     .byte <BlankDigit  ; 85
     .byte <BlankDigit  ; 86
     .byte <BlankDigit  ; 87
     .byte <BlankDigit  ; 88
     .byte <BlankDigit  ; 89
     .byte <BlankDigit  ; 90
     .byte <BlankDigit  ; 91
     .byte <BlankDigit  ; 92
     .byte <BlankDigit  ; 93
     .byte <BlankDigit  ; 94
     .byte <BlankDigit  ; 95
     .byte <BlankDigit  ; 96
     .byte <BlankDigit  ; 97
     .byte <BlankDigit  ; 98
     .byte <BlankDigit  ; 99
     .byte <Zero        ; 100
     .byte <One         ; 101
     .byte <Two         ; 102
     .byte <Three       ; 103
     .byte <Four        ; 104
     .byte <Five        ; 105
     .byte <Six         ; 106
     .byte <Seven       ; 107
     .byte <Eight       ; 108
     .byte <Nine        ; 109
     .byte <Zero        ; 110
     .byte <One         ; 111
     .byte <Two         ; 112
     .byte <Three       ; 113
     .byte <Four        ; 114
     .byte <Five        ; 115
     .byte <Six         ; 116
     .byte <Seven       ; 117
     .byte <Eight       ; 118
     .byte <Nine        ; 119
     .byte <Zero        ; 120
     .byte <One         ; 121
     .byte <Two         ; 122
     .byte <Three       ; 123
     .byte <Four        ; 124
     .byte <Five        ; 125
     .byte <Six         ; 126
     .byte <Seven       ; 127
     .byte <Eight       ; 128
     .byte <Nine        ; 129
     .byte <Zero        ; 130
     .byte <One         ; 131
     .byte <Two         ; 132
     .byte <Three       ; 133
     .byte <Four        ; 134
     .byte <Five        ; 135
     .byte <Six         ; 136
     .byte <Seven       ; 137
     .byte <Eight       ; 138
     .byte <Nine        ; 139
     .byte <Zero        ; 140
     .byte <One         ; 141
     .byte <Two         ; 142
     .byte <Three       ; 143
     .byte <Four        ; 144
     .byte <Five        ; 145
     .byte <Six         ; 146
     .byte <Seven       ; 147
     .byte <Eight       ; 148
     .byte <Nine        ; 149
     .byte <Zero        ; 150
     .byte <One         ; 151
     .byte <Two         ; 152
     .byte <Three       ; 153
     .byte <Four        ; 154
     .byte <Five        ; 155
     .byte <Six         ; 156
     .byte <Seven       ; 157
     .byte <Eight       ; 158
     .byte <Nine        ; 159
     .byte <Zero        ; 160
     .byte <One         ; 161
     .byte <Two         ; 162
     .byte <Three       ; 163
     .byte <Four        ; 164
     .byte <Five        ; 165
     .byte <Six         ; 166
     .byte <Seven       ; 167
     .byte <Eight       ; 168
     .byte <Nine        ; 169
     .byte <Zero        ; 170
     .byte <One         ; 171
     .byte <Two         ; 172
     .byte <Three       ; 173
     .byte <Four        ; 174
     .byte <Five        ; 175
     .byte <Six         ; 176
     .byte <Seven       ; 177
     .byte <Eight       ; 178
     .byte <Nine        ; 179
     .byte <Zero        ; 180
     .byte <One         ; 181
     .byte <Two         ; 182
     .byte <Three       ; 183
     .byte <Four        ; 184
     .byte <Five        ; 185
     .byte <Six         ; 186
     .byte <Seven       ; 187
     .byte <Eight       ; 188
     .byte <Nine        ; 189
     .byte <Zero        ; 190
     .byte <One         ; 191
     .byte <Two         ; 192
     .byte <Three       ; 193
     .byte <Four        ; 194
     .byte <Five        ; 195
     .byte <Six         ; 196
     .byte <Seven       ; 197
     .byte <Eight       ; 198
     .byte <Nine        ; 199
     .byte <Zero        ; 200
     .byte <One         ; 201
     .byte <Two         ; 202
     .byte <Three       ; 203
     .byte <Four        ; 204
     .byte <Five        ; 205
     .byte <Six         ; 206
     .byte <Seven       ; 207
     .byte <Eight       ; 208
     .byte <Nine        ; 209
     .byte <Zero        ; 210
     .byte <One         ; 211
     .byte <Two         ; 212
     .byte <Three       ; 213
     .byte <Four        ; 214
     .byte <Five        ; 215
     .byte <Six         ; 216
     .byte <Seven       ; 217
     .byte <Eight       ; 218
     .byte <Nine        ; 219
     .byte <Zero        ; 220
     .byte <One         ; 221
     .byte <Two         ; 222
     .byte <Three       ; 223
     .byte <Four        ; 224
     .byte <Five        ; 225
     .byte <Six         ; 226
     .byte <Seven       ; 227
     .byte <Eight       ; 228
     .byte <Nine        ; 229
     .byte <Zero        ; 230
     .byte <One         ; 231
     .byte <Two         ; 232
     .byte <Three       ; 233
     .byte <Four        ; 234
     .byte <Five        ; 235
     .byte <Six         ; 236
     .byte <Seven       ; 237
     .byte <Eight       ; 238
     .byte <Nine        ; 239
     .byte <Zero        ; 240
     .byte <One         ; 241
     .byte <Two         ; 242
     .byte <Three       ; 243
     .byte <Four        ; 244
     .byte <Five        ; 245
     .byte <Six         ; 246
     .byte <Seven       ; 247
     .byte <Eight       ; 248
     .byte <Nine        ; 249
     .byte <Zero        ; 250
     .byte <One         ; 251
     .byte <Two         ; 252
     .byte <Three       ; 253
     .byte <Four        ; 254
     .byte <Five        ; 255

        ORG $FD00

;10's digit low pointers, note all digits are LEFT aligned

TensTable:
     .byte <BlankDigit  ; 0
     .byte <BlankDigit  ; 1
     .byte <BlankDigit  ; 2
     .byte <BlankDigit  ; 3
     .byte <BlankDigit  ; 4
     .byte <BlankDigit  ; 5
     .byte <BlankDigit  ; 6
     .byte <BlankDigit  ; 7
     .byte <BlankDigit  ; 8
     .byte <BlankDigit  ; 9
     .byte <Zero        ; 10
     .byte <One         ; 11
     .byte <Two         ; 12
     .byte <Three       ; 13
     .byte <Four        ; 14
     .byte <Five        ; 15
     .byte <Six         ; 16
     .byte <Seven       ; 17
     .byte <Eight       ; 18
     .byte <Nine        ; 19
     .byte <Zero        ; 20
     .byte <One         ; 21
     .byte <Two         ; 22
     .byte <Three       ; 23
     .byte <Four        ; 24
     .byte <Five        ; 25
     .byte <Six         ; 26
     .byte <Seven       ; 27
     .byte <Eight       ; 28
     .byte <Nine        ; 29
     .byte <Zero        ; 30
     .byte <One         ; 31
     .byte <Two         ; 32
     .byte <Three       ; 33
     .byte <Four        ; 34
     .byte <Five        ; 35
     .byte <Six         ; 36
     .byte <Seven       ; 37
     .byte <Eight       ; 38
     .byte <Nine        ; 39
     .byte <Zero        ; 40
     .byte <One         ; 41
     .byte <Two         ; 42
     .byte <Three       ; 43
     .byte <Four        ; 44
     .byte <Five        ; 45
     .byte <Six         ; 46
     .byte <Seven       ; 47
     .byte <Eight       ; 48
     .byte <Nine        ; 49
     .byte <Zero        ; 50
     .byte <One         ; 51
     .byte <Two         ; 52
     .byte <Three       ; 53
     .byte <Four        ; 54
     .byte <Five        ; 55
     .byte <Six         ; 56
     .byte <Seven       ; 57
     .byte <Eight       ; 58
     .byte <Nine        ; 59
     .byte <Zero        ; 60
     .byte <One         ; 61
     .byte <Two         ; 62
     .byte <Three       ; 63
     .byte <Four        ; 64
     .byte <Five        ; 65
     .byte <Six         ; 66
     .byte <Seven       ; 67
     .byte <Eight       ; 68
     .byte <Nine        ; 69
     .byte <Zero        ; 70
     .byte <One         ; 71
     .byte <Two         ; 72
     .byte <Three       ; 73
     .byte <Four        ; 74
     .byte <Five        ; 75
     .byte <Six         ; 76
     .byte <Seven       ; 77
     .byte <Eight       ; 78
     .byte <Nine        ; 79
     .byte <Zero        ; 80
     .byte <One         ; 81
     .byte <Two         ; 82
     .byte <Three       ; 83
     .byte <Four        ; 84
     .byte <Five        ; 85
     .byte <Six         ; 86
     .byte <Seven       ; 87
     .byte <Eight       ; 88
     .byte <Nine        ; 89
     .byte <Zero        ; 90
     .byte <One         ; 91
     .byte <Two         ; 92
     .byte <Three       ; 93
     .byte <Four        ; 94
     .byte <Five        ; 95
     .byte <Six         ; 96
     .byte <Seven       ; 97
     .byte <Eight       ; 98
     .byte <Nine        ; 99
     .byte <Zero        ; 100
     .byte <Zero        ; 101
     .byte <Zero        ; 102
     .byte <Zero        ; 103
     .byte <Zero        ; 104
     .byte <Zero        ; 105
     .byte <Zero        ; 106
     .byte <Zero        ; 107
     .byte <Zero        ; 108
     .byte <Zero        ; 109
     .byte <One         ; 110
     .byte <One         ; 111
     .byte <One         ; 112
     .byte <One         ; 113
     .byte <One         ; 114
     .byte <One         ; 115
     .byte <One         ; 116
     .byte <One         ; 117
     .byte <One         ; 118
     .byte <One         ; 119
     .byte <Two         ; 120
     .byte <Two         ; 121
     .byte <Two         ; 122
     .byte <Two         ; 123
     .byte <Two         ; 124
     .byte <Two         ; 125
     .byte <Two         ; 126
     .byte <Two         ; 127
     .byte <Two         ; 128
     .byte <Two         ; 129
     .byte <Three       ; 130
     .byte <Three       ; 131
     .byte <Three       ; 132
     .byte <Three       ; 133
     .byte <Three       ; 134
     .byte <Three       ; 135
     .byte <Three       ; 136
     .byte <Three       ; 137
     .byte <Three       ; 138
     .byte <Three       ; 139
     .byte <Four        ; 140
     .byte <Four        ; 141
     .byte <Four        ; 142
     .byte <Four        ; 143
     .byte <Four        ; 144
     .byte <Four        ; 145
     .byte <Four        ; 146
     .byte <Four        ; 147
     .byte <Four        ; 148
     .byte <Four        ; 149
     .byte <Five        ; 150
     .byte <Five        ; 151
     .byte <Five        ; 152
     .byte <Five        ; 153
     .byte <Five        ; 154
     .byte <Five        ; 155
     .byte <Five        ; 156
     .byte <Five        ; 157
     .byte <Five        ; 158
     .byte <Five        ; 159
     .byte <Six         ; 160
     .byte <Six         ; 161
     .byte <Six         ; 162
     .byte <Six         ; 163
     .byte <Six         ; 164
     .byte <Six         ; 165
     .byte <Six         ; 166
     .byte <Six         ; 167
     .byte <Six         ; 168
     .byte <Six         ; 169
     .byte <Seven       ; 170
     .byte <Seven       ; 171
     .byte <Seven       ; 172
     .byte <Seven       ; 173
     .byte <Seven       ; 174
     .byte <Seven       ; 175
     .byte <Seven       ; 176
     .byte <Seven       ; 177
     .byte <Seven       ; 178
     .byte <Seven       ; 179
     .byte <Eight       ; 180
     .byte <Eight       ; 181
     .byte <Eight       ; 182
     .byte <Eight       ; 183
     .byte <Eight       ; 184
     .byte <Eight       ; 185
     .byte <Eight       ; 186
     .byte <Eight       ; 187
     .byte <Eight       ; 188
     .byte <Eight       ; 189
     .byte <Nine        ; 190
     .byte <Nine        ; 191
     .byte <Nine        ; 192
     .byte <Nine        ; 193
     .byte <Nine        ; 194
     .byte <Nine        ; 195
     .byte <Nine        ; 196
     .byte <Nine        ; 197
     .byte <Nine        ; 198
     .byte <Nine        ; 199
     .byte <Zero        ; 200
     .byte <Zero        ; 201
     .byte <Zero        ; 202
     .byte <Zero        ; 203
     .byte <Zero        ; 204
     .byte <Zero        ; 205
     .byte <Zero        ; 206
     .byte <Zero        ; 207
     .byte <Zero        ; 208
     .byte <Zero        ; 209
     .byte <One         ; 210
     .byte <One         ; 211
     .byte <One         ; 212
     .byte <One         ; 213
     .byte <One         ; 214
     .byte <One         ; 215
     .byte <One         ; 216
     .byte <One         ; 217
     .byte <One         ; 218
     .byte <One         ; 219
     .byte <Two         ; 220
     .byte <Two         ; 221
     .byte <Two         ; 222
     .byte <Two         ; 223
     .byte <Two         ; 224
     .byte <Two         ; 225
     .byte <Two         ; 226
     .byte <Two         ; 227
     .byte <Two         ; 228
     .byte <Two         ; 229
     .byte <Three       ; 230
     .byte <Three       ; 231
     .byte <Three       ; 232
     .byte <Three       ; 233
     .byte <Three       ; 234
     .byte <Three       ; 235
     .byte <Three       ; 236
     .byte <Three       ; 237
     .byte <Three       ; 238
     .byte <Three       ; 239
     .byte <Four        ; 240
     .byte <Four        ; 241
     .byte <Four        ; 242
     .byte <Four        ; 243
     .byte <Four        ; 244
     .byte <Four        ; 245
     .byte <Four        ; 246
     .byte <Four        ; 247
     .byte <Four        ; 248
     .byte <Four        ; 249
     .byte <Five        ; 250
     .byte <Five        ; 251
     .byte <Five        ; 252
     .byte <Five        ; 253
     .byte <Five        ; 254
     .byte <Five        ; 255

        ORG $FE00

;100's digit low pointers, note all digits are LEFT aligned

HundredsTable:
     .byte <Zero        ; 0
     .byte <One         ; 1
     .byte <Two         ; 2
     .byte <Three       ; 3
     .byte <Four        ; 4
     .byte <Five        ; 5
     .byte <Six         ; 6
     .byte <Seven       ; 7
     .byte <Eight       ; 8
     .byte <Nine        ; 9
     .byte <One         ; 10
     .byte <One         ; 11
     .byte <One         ; 12
     .byte <One         ; 13
     .byte <One         ; 14
     .byte <One         ; 15
     .byte <One         ; 16
     .byte <One         ; 17
     .byte <One         ; 18
     .byte <One         ; 19
     .byte <Two         ; 20
     .byte <Two         ; 21
     .byte <Two         ; 22
     .byte <Two         ; 23
     .byte <Two         ; 24
     .byte <Two         ; 25
     .byte <Two         ; 26
     .byte <Two         ; 27
     .byte <Two         ; 28
     .byte <Two         ; 29
     .byte <Three       ; 30
     .byte <Three       ; 31
     .byte <Three       ; 32
     .byte <Three       ; 33
     .byte <Three       ; 34
     .byte <Three       ; 35
     .byte <Three       ; 36
     .byte <Three       ; 37
     .byte <Three       ; 38
     .byte <Three       ; 39
     .byte <Four        ; 40
     .byte <Four        ; 41
     .byte <Four        ; 42
     .byte <Four        ; 43
     .byte <Four        ; 44
     .byte <Four        ; 45
     .byte <Four        ; 46
     .byte <Four        ; 47
     .byte <Four        ; 48
     .byte <Four        ; 49
     .byte <Five        ; 50
     .byte <Five        ; 51
     .byte <Five        ; 52
     .byte <Five        ; 53
     .byte <Five        ; 54
     .byte <Five        ; 55
     .byte <Five        ; 56
     .byte <Five        ; 57
     .byte <Five        ; 58
     .byte <Five        ; 59
     .byte <Six         ; 60
     .byte <Six         ; 61
     .byte <Six         ; 62
     .byte <Six         ; 63
     .byte <Six         ; 64
     .byte <Six         ; 65
     .byte <Six         ; 66
     .byte <Six         ; 67
     .byte <Six         ; 68
     .byte <Six         ; 69
     .byte <Seven       ; 70
     .byte <Seven       ; 71
     .byte <Seven       ; 72
     .byte <Seven       ; 73
     .byte <Seven       ; 74
     .byte <Seven       ; 75
     .byte <Seven       ; 76
     .byte <Seven       ; 77
     .byte <Seven       ; 78
     .byte <Seven       ; 79
     .byte <Eight       ; 80
     .byte <Eight       ; 81
     .byte <Eight       ; 82
     .byte <Eight       ; 83
     .byte <Eight       ; 84
     .byte <Eight       ; 85
     .byte <Eight       ; 86
     .byte <Eight       ; 87
     .byte <Eight       ; 88
     .byte <Eight       ; 89
     .byte <Nine        ; 90
     .byte <Nine        ; 91
     .byte <Nine        ; 92
     .byte <Nine        ; 93
     .byte <Nine        ; 94
     .byte <Nine        ; 95
     .byte <Nine        ; 96
     .byte <Nine        ; 97
     .byte <Nine        ; 98
     .byte <Nine        ; 99
     .byte <One         ; 100
     .byte <One         ; 101
     .byte <One         ; 102
     .byte <One         ; 103
     .byte <One         ; 104
     .byte <One         ; 105
     .byte <One         ; 106
     .byte <One         ; 107
     .byte <One         ; 108
     .byte <One         ; 109
     .byte <One         ; 110
     .byte <One         ; 111
     .byte <One         ; 112
     .byte <One         ; 113
     .byte <One         ; 114
     .byte <One         ; 115
     .byte <One         ; 116
     .byte <One         ; 117
     .byte <One         ; 118
     .byte <One         ; 119
     .byte <One         ; 120
     .byte <One         ; 121
     .byte <One         ; 122
     .byte <One         ; 123
     .byte <One         ; 124
     .byte <One         ; 125
     .byte <One         ; 126
     .byte <One         ; 127
     .byte <One         ; 128
     .byte <One         ; 129
     .byte <One         ; 130
     .byte <One         ; 131
     .byte <One         ; 132
     .byte <One         ; 133
     .byte <One         ; 134
     .byte <One         ; 135
     .byte <One         ; 136
     .byte <One         ; 137
     .byte <One         ; 138
     .byte <One         ; 139
     .byte <One         ; 140
     .byte <One         ; 141
     .byte <One         ; 142
     .byte <One         ; 143
     .byte <One         ; 144
     .byte <One         ; 145
     .byte <One         ; 146
     .byte <One         ; 147
     .byte <One         ; 148
     .byte <One         ; 149
     .byte <One         ; 150
     .byte <One         ; 151
     .byte <One         ; 152
     .byte <One         ; 153
     .byte <One         ; 154
     .byte <One         ; 155
     .byte <One         ; 156
     .byte <One         ; 157
     .byte <One         ; 158
     .byte <One         ; 159
     .byte <One         ; 160
     .byte <One         ; 161
     .byte <One         ; 162
     .byte <One         ; 163
     .byte <One         ; 164
     .byte <One         ; 165
     .byte <One         ; 166
     .byte <One         ; 167
     .byte <One         ; 168
     .byte <One         ; 169
     .byte <One         ; 170
     .byte <One         ; 171
     .byte <One         ; 172
     .byte <One         ; 173
     .byte <One         ; 174
     .byte <One         ; 175
     .byte <One         ; 176
     .byte <One         ; 177
     .byte <One         ; 178
     .byte <One         ; 179
     .byte <One         ; 180
     .byte <One         ; 181
     .byte <One         ; 182
     .byte <One         ; 183
     .byte <One         ; 184
     .byte <One         ; 185
     .byte <One         ; 186
     .byte <One         ; 187
     .byte <One         ; 188
     .byte <One         ; 189
     .byte <One         ; 190
     .byte <One         ; 191
     .byte <One         ; 192
     .byte <One         ; 193
     .byte <One         ; 194
     .byte <One         ; 195
     .byte <One         ; 196
     .byte <One         ; 197
     .byte <One         ; 198
     .byte <One         ; 199
     .byte <Two         ; 200
     .byte <Two         ; 201
     .byte <Two         ; 202
     .byte <Two         ; 203
     .byte <Two         ; 204
     .byte <Two         ; 205
     .byte <Two         ; 206
     .byte <Two         ; 207
     .byte <Two         ; 208
     .byte <Two         ; 209
     .byte <Two         ; 210
     .byte <Two         ; 211
     .byte <Two         ; 212
     .byte <Two         ; 213
     .byte <Two         ; 214
     .byte <Two         ; 215
     .byte <Two         ; 216
     .byte <Two         ; 217
     .byte <Two         ; 218
     .byte <Two         ; 219
     .byte <Two         ; 220
     .byte <Two         ; 221
     .byte <Two         ; 222
     .byte <Two         ; 223
     .byte <Two         ; 224
     .byte <Two         ; 225
     .byte <Two         ; 226
     .byte <Two         ; 227
     .byte <Two         ; 228
     .byte <Two         ; 229
     .byte <Two         ; 230
     .byte <Two         ; 231
     .byte <Two         ; 232
     .byte <Two         ; 233
     .byte <Two         ; 234
     .byte <Two         ; 235
     .byte <Two         ; 236
     .byte <Two         ; 237
     .byte <Two         ; 238
     .byte <Two         ; 239
     .byte <Two         ; 240
     .byte <Two         ; 241
     .byte <Two         ; 242
     .byte <Two         ; 243
     .byte <Two         ; 244
     .byte <Two         ; 245
     .byte <Two         ; 246
     .byte <Two         ; 247
     .byte <Two         ; 248
     .byte <Two         ; 249
     .byte <Two         ; 250
     .byte <Two         ; 251
     .byte <Two         ; 252
     .byte <Two         ; 253
     .byte <Two         ; 254
     .byte <Two         ; 255


        ORG $FF00

Zero:
    .byte $3C ; |  XXXX  | $FF00
    .byte $66 ; | XX  XX | $FF01
    .byte $66 ; | XX  XX | $FF02
    .byte $66 ; | XX  XX | $FF03
    .byte $66 ; | XX  XX | $FF04
    .byte $66 ; | XX  XX | $FF05
    .byte $66 ; | XX  XX | $FF06
    .byte $3C ; |  XXXX  | $FF07
One:
    .byte $7E ; | XXXXXX | $FF08
    .byte $18 ; |   XX   | $FF09
    .byte $18 ; |   XX   | $FF0A
    .byte $18 ; |   XX   | $FF0B
    .byte $18 ; |   XX   | $FF0C
    .byte $18 ; |   XX   | $FF0D
    .byte $38 ; |  XXX   | $FF0E
    .byte $08 ; |    X   | $FF0F
Two:
    .byte $7E ; | XXXXXX | $FF10
    .byte $60 ; | XX     | $FF11
    .byte $60 ; | XX     | $FF12
    .byte $3C ; |  XXXX  | $FF13
    .byte $06 ; |     XX | $FF14
    .byte $06 ; |     XX | $FF15
    .byte $46 ; | X   XX | $FF16
    .byte $3C ; |  XXXX  | $FF17
Three:
    .byte $3C ; |  XXXX  | $FF18
    .byte $46 ; | X   XX | $FF19
    .byte $06 ; |     XX | $FF1A
    .byte $0C ; |    XX  | $FF1B
    .byte $0C ; |    XX  | $FF1C
    .byte $06 ; |     XX | $FF1D
    .byte $46 ; | X   XX | $FF1E
    .byte $3C ; |  XXXX  | $FF1F
Four:
    .byte $0C ; |    XX  | $FF20
    .byte $0C ; |    XX  | $FF21
    .byte $0C ; |    XX  | $FF22
    .byte $7E ; | XXXXXX | $FF23
    .byte $4C ; | X  XX  | $FF24
    .byte $2C ; |  X XX  | $FF25
    .byte $1C ; |   XXX  | $FF26
    .byte $0C ; |    XX  | $FF27
Five:
    .byte $3C ; |  XXXX  | $FF28
    .byte $46 ; | X   XX | $FF29
    .byte $06 ; |     XX | $FF2A
    .byte $06 ; |     XX | $FF2B
    .byte $7C ; | XXXXX  | $FF2C
    .byte $60 ; | XX     | $FF2D
    .byte $60 ; | XX     | $FF2E
    .byte $7E ; | XXXXXX | $FF2F
Six:
    .byte $3C ; |  XXXX  | $FF30
    .byte $66 ; | XX  XX | $FF31
    .byte $66 ; | XX  XX | $FF32
    .byte $66 ; | XX  XX | $FF33
    .byte $7C ; | XXXXX  | $FF34
    .byte $60 ; | XX     | $FF35
    .byte $62 ; | XX   X | $FF36
    .byte $3C ; |  XXXX  | $FF37
Seven:
    .byte $18 ; |   XX   | $FF38
    .byte $18 ; |   XX   | $FF39
    .byte $18 ; |   XX   | $FF3A
    .byte $18 ; |   XX   | $FF3B
    .byte $0C ; |    XX  | $FF3C
    .byte $06 ; |     XX | $FF3D
    .byte $46 ; | X   XX | $FF3E
    .byte $7E ; | XXXXXX | $FF3F
Eight:
    .byte $3C ; |  XXXX  | $FF40
    .byte $66 ; | XX  XX | $FF41
    .byte $66 ; | XX  XX | $FF42
    .byte $3C ; |  XXXX  | $FF43
    .byte $3C ; |  XXXX  | $FF44
    .byte $66 ; | XX  XX | $FF45
    .byte $66 ; | XX  XX | $FF46
    .byte $3C ; |  XXXX  | $FF47
Nine:
    .byte $3C ; |  XXXX  | $FF48
    .byte $46 ; | X   XX | $FF49
    .byte $06 ; |     XX | $FF4A
    .byte $3E ; |  XXXXX | $FF4B
    .byte $66 ; | XX  XX | $FF4C
    .byte $66 ; | XX  XX | $FF4D
    .byte $66 ; | XX  XX | $FF4E
    .byte $3C ; |  XXXX  | $FF4F
BlankDigit:
    .byte $00 ; |        | $FF50
    .byte $00 ; |        | $FF51
    .byte $00 ; |        | $FF52
    .byte $00 ; |        | $FF53
    .byte $00 ; |        | $FF54
    .byte $00 ; |        | $FF55
    .byte $00 ; |        | $FF56
    .byte $00 ; |        | $FF57
AtSymbol:
    .byte $3E ; |  XXXXX | $FF58
    .byte $41 ; | X     X| $FF59
    .byte $9C ; |X  XXX  | $FF5A
    .byte $A6 ; |X X  XX | $FF5B
    .byte $A5 ; |X X  X X| $FF5C
    .byte $99 ; |X  XX  X| $FF5D
    .byte $42 ; | X    X | $FF5E
    .byte $3C ; |  XXXX  | $FF5F
PassedOne:
    .byte $00 ; |        | $FF60
    .byte $0C ; |    XX  | $FF61
    .byte $0C ; |    XX  | $FF62
    .byte $0C ; |    XX  | $FF63
    .byte $0F ; |    XXXX| $FF64
    .byte $0C ; |    XX  | $FF65
    .byte $0C ; |    XX  | $FF66
    .byte $0F ; |    XXXX| $FF67
PassedTwo:
    .byte $00 ; |        | $FF68
    .byte $19 ; |   XX  X| $FF69
    .byte $19 ; |   XX  X| $FF6A
    .byte $19 ; |   XX  X| $FF6B
    .byte $9F ; |X  XXXXX| $FF6C
    .byte $D9 ; |XX XX  X| $FF6D
    .byte $D9 ; |XX XX  X| $FF6E
    .byte $8F ; |X   XXXX| $FF6F
PassedThree:
    .byte $00 ; |        | $FF70
    .byte $9E ; |X  XXXX | $FF71
    .byte $A3 ; |X X   XX| $FF72
    .byte $83 ; |X     XX| $FF73
    .byte $9E ; |X  XXXX | $FF74
    .byte $B0 ; |X XX    | $FF75
    .byte $B1 ; |X XX   X| $FF76
    .byte $1E ; |   XXXX | $FF77
PassedFour:
    .byte $00 ; |        | $FF78
    .byte $3C ; |  XXXX  | $FF79
    .byte $46 ; | X   XX | $FF7A
    .byte $06 ; |     XX | $FF7B
    .byte $3C ; |  XXXX  | $FF7C
    .byte $60 ; | XX     | $FF7D
    .byte $62 ; | XX   X | $FF7E
    .byte $3C ; |  XXXX  | $FF7F
PassedFive:
    .byte $00 ; |        | $FF80
    .byte $FD ; |XXXXXX X| $FF81
    .byte $C1 ; |XX     X| $FF82
    .byte $C1 ; |XX     X| $FF83
    .byte $F1 ; |XXXX   X| $FF84
    .byte $C1 ; |XX     X| $FF85
    .byte $C1 ; |XX     X| $FF86
    .byte $FD ; |XXXXXX X| $FF87
PassedSix:
    .byte $00 ; |        | $FF88
    .byte $E0 ; |XXX     | $FF89
    .byte $F0 ; |XXXX    | $FF8A
    .byte $10 ; |   X    | $FF8B
    .byte $10 ; |   X    | $FF8C
    .byte $10 ; |   X    | $FF8D
    .byte $F0 ; |XXXX    | $FF8E
    .byte $E0 ; |XXX     | $FF8F
FailedOne:
    .byte $00 ; |        | $FF90
    .byte $03 ; |      XX| $FF91
    .byte $03 ; |      XX| $FF92
    .byte $03 ; |      XX| $FF93
    .byte $03 ; |      XX| $FF94
    .byte $03 ; |      XX| $FF95
    .byte $03 ; |      XX| $FF96
    .byte $03 ; |      XX| $FF97
FailedTwo:
    .byte $00 ; |        | $FF98
    .byte $06 ; |     XX | $FF99
    .byte $06 ; |     XX | $FF9A
    .byte $C6 ; |XX   XX | $FF9B
    .byte $07 ; |     XXX| $FF9C
    .byte $06 ; |     XX | $FF9D
    .byte $F6 ; |XXXX XX | $FF9E
    .byte $F3 ; |XXXX  XX| $FF9F
FailedThree:
    .byte $00 ; |        | $FFA0
    .byte $6D ; | XX XX X| $FFA1
    .byte $6D ; | XX XX X| $FFA2
    .byte $6D ; | XX XX X| $FFA3
    .byte $ED ; |XXX XX X| $FFA4
    .byte $6D ; | XX XX X| $FFA5
    .byte $6D ; | XX XX X| $FFA6
    .byte $CD ; |XX  XX X| $FFA7
FailedFour:
    .byte $00 ; |        | $FFA8
    .byte $FB ; |XXXXX XX| $FFA9
    .byte $FB ; |XXXXX XX| $FFAA
    .byte $83 ; |X     XX| $FFAB
    .byte $83 ; |X     XX| $FFAC
    .byte $83 ; |X     XX| $FFAD
    .byte $83 ; |X     XX| $FFAE
    .byte $83 ; |X     XX| $FFAF
FailedFive:
    .byte $00 ; |        | $FFB0
    .byte $F7 ; |XXXX XXX| $FFB1
    .byte $07 ; |     XXX| $FFB2
    .byte $06 ; |     XX | $FFB3
    .byte $C6 ; |XX   XX | $FFB4
    .byte $06 ; |     XX | $FFB5
    .byte $07 ; |     XXX| $FFB6
    .byte $F7 ; |XXXX XXX| $FFB7
FailedSix:
    .byte $00 ; |        | $FFB8
    .byte $C0 ; |XX      | $FFB9
    .byte $E0 ; |XXX     | $FFBA
    .byte $20 ; |  X     | $FFBB
    .byte $20 ; |  X     | $FFBC
    .byte $20 ; |  X     | $FFBD
    .byte $E0 ; |XXX     | $FFBE
    .byte $C0 ; |XX      | $FFBF




        ORG $FFFC

    .word START,START
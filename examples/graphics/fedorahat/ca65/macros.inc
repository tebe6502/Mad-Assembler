
.macro instLO inst, src
    .if (.match (.left (1, {src}), #))
        inst #<(.right (.tcount ({src})-1, {src}))
    .else
        inst src
    .endif
.endmacro

.macro instHI inst, src
    .if (.match (.left (1, {src}), #))
        inst #>(.right (.tcount ({src})-1, {src}))
    .else
        inst src+1
    .endif
.endmacro

.macro ldax src
        instLO lda, src
        instHI ldx, src
.endmacro

.macro stax dst
        sta dst
        stx dst+1
.endmacro

.macro mvax dst, src
        ldax src
        stax dst
.endmacro

.macro mva dst, src
        lda src
        sta dst
.endmacro

.macro addax dst, add
    .ifnblank add
        clc
        instLO adc, add
        instLO sta, dst
        txa
        instHI adc, add
        instHI sta, dst
    .else
        clc
        instLO adc, dst
        pha
        txa
        instHI adc, dst
        tax
        pla
    .endif
.endmacro


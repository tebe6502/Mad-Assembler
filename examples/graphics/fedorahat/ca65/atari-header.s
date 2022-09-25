
; ------------------------------------------------------------------------
; EXE header and trailer
;
        .import __CODE_LOAD__, __BSS_LOAD__
        .import _start
        .export __ATARI_HDR__ : absolute = 1       ; Referenced by the linker

        .segment "EXEHDR"
        .word   $FFFF
        .word   __CODE_LOAD__
        .word   __BSS_LOAD__ - 1

        .segment "AUTOSTRT"
        .word   $02E0
        .word   $02E1
        .word   _start


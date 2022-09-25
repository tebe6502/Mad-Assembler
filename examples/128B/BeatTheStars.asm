
; Beat The STARS

; System: Atari 800XL PAL (with original OS (important))
; Author: Ivo van Poorten
; Date: 2018-04-17

; Additional optimizations: DMSC
; http://atariage.com/forums/topic/279648-my-128b-entries-from-outline-2k18/

    org $80

; INIT

fillrandom
    lda $d20a
    pha
    tsx
    bne fillrandom

    stx $d40e       ; To use stack, we need to disable NMIs
knt=*+2             ; For the envelope counter, reuse the $00
    stx $d400

; ENDINIT


; BEAT

newframe
    dey
    lsr knt
    lsr knt
    bne noreset

    dec knt
pos=*+1
    ldx #0
    ldy song,x
    dex
    bpl noreset2

    ldx #7

noreset2
    stx pos

noreset
    ldx hatenv+3,y
    stx $d201
    ldx hatfreq+3,y
    stx $d200

; ENDBEAT

; STARS
    ldx #256-157       ; PAL stars speed
;    ldx #256-132       ; NTSC stars speed
;    ldx $D40B           ; Works in PAL or NTSC, but stars don't move vertically!
reload_spd
    lda #4
    sta $d00d
    sta spd
next
    stx $d012
    txs
    pla
    sta $d000
    sta $d40a
    sta $d40a
spd=*+1
    adc #0
    pha
    inx
    beq newframe

    dec spd
    bne next
    beq reload_spd

; ENDSTARS

song
    dta <kickenv-hatenv, <hatenv-hatenv, <kickenv-hatenv, <hatenv-hatenv
    dta <snareenv-hatenv, <hatenv-hatenv, <hatenv-hatenv,  <hatenv-hatenv

hatenv=*-2      ; Two previous bytes are 0, last values of hat envelope = silent
snareenv
    dta $82, $84, $a7, $0a
kickenv
    dta $c4, $a7, $a9, $0a

hatfreq=*-2     ; Two previous bytes are any value, as envelope is silent
snarefreq
    dta $03, $04, $95, $13
kickfreq
    dta $bf, $ef, $df, $0c

signature
    dta "IVO"


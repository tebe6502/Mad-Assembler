; sparta_detect.asm
; (c) idea by KMK, code: mikey
;
; $Id: sparta_detect.asm,v 1.2 2006/09/27 22:59:27 mikey Exp $
; 

p0      = $f0
fsymbol = $07EB

	org $2000
                   
sparta_detect

; if peek($700) = 'S' and bit($701) sets V then we're SDX

                lda $0700
                cmp #$53         ; 'S'
                bne no_sparta
                lda $0701
                cmp #$40
                bcc no_sparta
                cmp #$44
                bcc _oldsdx

; we're running 4.4 - the old method is INVALID as of 4.42

                lda #<sym_t
                ldx #>sym_t
                jsr fsymbol
                sta p0
                stx p0+1
                ldy #$06
                bne _fv

; we're running SDX, find (DOSVEC)-$150 

_oldsdx         lda $a
                sec
                sbc #<$150
                sta p0
                lda $b
                sbc #>$150
                sta p0+1

; ok, hopefully we have established the address. 
; now peek at it. return the value. 

                ldy #0
_fv             lda (p0),y
                rts
no_sparta       lda #$ff 
                rts

sym_t           .byte 'T_      '

; if A=$FF -> No SDX :(
; if A=$FE -> SDX is in OSROM mode
; if A=$00 -> SDX doesn't use any XMS banks
; if A=anything else -> BANKED mode, and A is the bank number 

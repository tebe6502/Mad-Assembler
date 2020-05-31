
eol equ $9b

info
 ldx <_text1
 ldy >_text1
 jsr $c642
 ldx <_text2
 ldy >_text2
 jsr $c642
 ldx <_text3
 ldy >_text3
 jsr $c642
 rts

_text1 dta b(eol)
_text2 dta c'ProTracker 1.5 by Profi/Madteam',b(eol)
_text3 dta c'-------------------------------',b(eol)

 ini info


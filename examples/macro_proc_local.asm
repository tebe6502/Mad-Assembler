
// Przyklad struktury .MACRO i .PROC zagniezdzonych w strukturze .LOCAL

	opt h-
	org $2000

main	.local

test	.local

 nop
 lda _skip  ;< - - - -
                    ;|
bum                 ;|
                    ;|
 mak.test bum       ;|
 mak.test bum       ;|
                    ;|
 mak2.test          ;|
 mak2.test          ;|
                    ;|
_skip   ;< - - - - - -

	.endl

	.endl


mak .local
      
test .macro             ; MAK.TEST

wow .local              ; MAK.TEST??.WOW

 lda :1
 
 .endl
 
 .endm

 .endl



mak2 .local
      
test .macro             ; MAK2.TEST

_skip nop   ;< - -	; MAK2.TEST??._SKIP
            ;    |
 lda _skip  ;< - -
 
 .endm

 .endl



prc .local

test .proc              ; PRC.TEST

bajt                    ; PRC.TEST.BAJT

 mak2.test              ; PRC.TEST.MAK2.TEST??

.endp

.endl
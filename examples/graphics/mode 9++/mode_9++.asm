/*
  MODE 9++
*/

 org $2000

 lda <dli
 sta $200
 lda >dli
 sta $201

 lda #$22
 sta $22f
 
 lda <dl
 sta $230
 lda >dl
 sta $231

 lda #$40
 sta $26f

 lda #$c0
 sta $d40e

 jmp *


dli pha
 sta $d40a
 
 lda #13
 sta $d405

 lda #3
 sta $d405

 pla
 rti


dl
; 2 puste linie, 1 linia trybu
 dta $90,$6f,a($f000)
; $8f,$2f powtorzone 29 razy => 58 linii
 :29 dta a($2f8f)
 
 dta $41,a(dl)

 opt h-
 org $2000

b equ 'W'


 ift b='B'
  lda #'B'

 eli b='W'
  lda #'W'

 eli b='L'
  lda #'L'
 
 els
  lda #'D'

 eif




   ift b='B'
     lda #'B'
   els

    ift b='W'
      lda #'W'
    els
      lda #'D'
    eif

   eif


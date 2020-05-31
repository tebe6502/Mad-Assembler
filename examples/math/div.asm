; Unsigned Integer Division Routines
; by Omegamatrix


;Divide by 2
;1 byte, 2 cycles
  lsr


;Divide by 3
;18 bytes, 30 cycles
  sta  temp
  lsr
  adc  #21
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr


;Divide by 4
;2 bytes, 4 cycles
  lsr
  lsr


;Divide by 5
;18 bytes, 30 cycles
  sta  temp
  lsr
  adc  #13
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr


;Divide by 6
;17 bytes, 30 cycles
  lsr
  sta  temp
  lsr
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr


;Divide by 7 (From December '84 Apple Assembly Line)
;15 bytes, 27 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr


;Divide by 8
;3 bytes, 6 cycles
  lsr
  lsr
  lsr


;Divide by 9
;17 bytes, 30 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 10
;17 bytes, 30 cycles
  lsr
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr


;Divide by 11
;20 bytes, 35 cycles
  sta  temp
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 12
;17 bytes, 30 cycles
  lsr
  lsr
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr


; Divide by 13
; 21 bytes, 37 cycles
  sta  temp
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  clc
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 14
;1/14 = 1/7 * 1/2
;16 bytes, 29 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 15
;14 bytes, 24 cycles
  sta  temp
  lsr
  adc  #4
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 16
;4 bytes, 8 cycles
  lsr
  lsr
  lsr
  lsr


;Divide by 17
;18 bytes, 30 cycles
  sta  temp
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  adc  #0
  lsr
  lsr
  lsr
  lsr


;Divide by 18 = 1/9 * 1/2
;18 bytes, 32 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 19
;17 bytes, 30 cycles
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 20
;18 bytes, 32 cycles
  lsr
  lsr
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr


;Divide by 21
;20 bytes, 36 cycles
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 22
;21 bytes, 34 cycles
   lsr
   cmp  #33
   adc  #0
   sta  temp
   lsr
   adc  temp
   ror
   adc  temp
   ror
   lsr
   adc  temp
   ror
   lsr
   lsr
   lsr


;Divide by 23
;19 bytes, 34 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 24
;15 bytes, 27 cycles
   lsr
   lsr
   lsr
   sta   temp
   lsr
   lsr
   adc   temp
   ror
   lsr
   adc   temp
   ror
   lsr


;Divide by 25
;16 bytes, 29 cycles
  sta  temp
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 26
;21 bytes, 37 cycles
  lsr
  sta  temp
  lsr
  adc  temp
  ror
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr


;Divide by 27
;15 bytes, 27 cycles
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 28
;14 bytes, 24 cycles
  lsr
  lsr
  sta  temp
  lsr
  adc  #2
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr


;Divide by 29
;20 bytes, 36 cycles
  sta  temp
  lsr
  lsr
  adc  temp
  ror
  adc  temp
  ror
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 30
;14 bytes, 26 cycles
  sta  temp
  lsr
  lsr
  lsr
  lsr
  sec
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 31
;14 bytes, 26 cycles
  sta  temp
  lsr
  lsr
  lsr
  lsr
  lsr
  adc  temp
  ror
  lsr
  lsr
  lsr
  lsr


;Divide by 32
  lsr
  lsr
  lsr
  lsr
  lsr

;Divide by 40
;20 bytes, 32 cycles
  sta  temp
  lsr
  adc  temp
  ror
  lsr
  lsr
  adc  temp
  ror
  adc  #1
  adc  temp
  and  #$C0
  rol
  rol
  rol



;Divide by and Mod 40 combined
;38 bytes, 45 cycles
;Y = value to be divided

InterlacedMultiplyByFortyTable:
  lda  #0        ; dummy load, #0 used in LUT
  lda  #0
  cpy  #40
  adc  #0
  cpy  #80
  adc  #0
  cpy  #120
  adc  #0
  cpy  #160
  adc  #0
  cpy  #200
  adc  #0
  cpy  #240
  adc  #0
  
  sta  divideResult      ; Integer divide 40
  
  asl
  asl
  tax
  tya
  sec
  sbc  InterlacedMultiplyByFortyTable+1,X
                         ; A = Mod 40
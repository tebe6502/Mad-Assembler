;Mod 6
;28 bytes, 43 cycles
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
  and  #$FC
  sta  temp2
  lsr
  adc  temp2
  sbc  temp
  eor  #$FF


;Mod 40
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
  and  #$E0
  sta  temp2  ;x32
  lsr
  lsr         ;x8
  adc  temp2  ;x40
  sbc  temp
  eor  #$FF

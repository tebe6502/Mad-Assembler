  org $2000
 
main

  lda #9	; select OS mode 9 (80x192, 16 shades of one colour)
  jsr $ef9c	; call OS graphics routine
l jsr $f18f	; call OS locate routine
  cmp #15	; check if the color have maximum value
  bcs *+7	; yes, so skip the brightness inceremt
  adc #1	; no , so increment brightness
  sta 763	; set the OS color value
  jsr $f1d8	; call OS plot routine
  ldx #84	; select Y pos. location
  jsr r		; call add random value routine
  jsr r		; the same with X pos.
  jmp l		; infinity loop!
r lda $d20a	; get random byte
  and #7	; mask value (only values 0-7 allowed)
  lsr @		; shift left one bit (bit #0 is now in Carry bit)
  sbc #1	; substract 0 or 1 (depends on Carry bit value)
  clc		; clear carry
  adc 0,x	; add to X or Y position (depends on X reg. value)
  and m-84,x	; mask out the coordinates (fit in visibility window)
s sta 0,x	; store in selected coordinate location 
  inx		; next location
  rts		; return

m .word $3f7f	; coordinates mask table

 run main

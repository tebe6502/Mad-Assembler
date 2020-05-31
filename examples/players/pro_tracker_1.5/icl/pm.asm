
 opt h-o-

vbl equ 216
lda equ $a5
sta equ $85
stx equ $86
inc equ $e6
jmp equ $4c

 org $0000

pmain equ *

bank0 lda #0
 sta $d301

cm_0 lda #0
iad0_m adc #0
 dta b(sta),b(cm_0+1)
 dta b(lda),b(p_0c+1)
iad0_s adc #0
 dta b(sta),b(p_0c+1)
 bcc p_0c
 dta b(inc),b(p_0c+2)
 dta b(lda),b(p_0c+2)
ien0_s cmp #0
 bcc p_0c

rep0_m lda #0
 dta b(sta),b(p_0c+1)
rep0_s lda #0
 dta b(sta),b(p_0c+2)
 dta b(jmp),a(bank1)

p_0c ldx $4000
ivol10 lda $d800,x
ch_0 sta $d600

bank1 lda #0
 sta $d301

cm_1 lda #0
iad1_m adc #0
 dta b(sta),b(cm_1+1)
 dta b(lda),b(p_1c+1)
iad1_s adc #0
 dta b(sta),b(p_1c+1)
 bcc p_1c
 dta b(inc),b(p_1c+2)
 dta b(lda),b(p_1c+2)
ien1_s cmp #0
 bcc p_1c

rep1_m lda #0
 dta b(sta),b(p_1c+1)
rep1_s lda #0
 dta b(sta),b(p_1c+2)
 dta b(jmp),a(bank2)

p_1c ldx $4000
ivol11 lda $d800,x
ch_1 sta $d601

bank2 lda #0
 sta $d301

cm_2 lda #0
iad2_m adc #0
 dta b(sta),b(cm_2+1)
 dta b(lda),b(p_2c+1)
iad2_s adc #0
 dta b(sta),b(p_2c+1)
 bcc p_2c
 dta b(inc),b(p_2c+2)
 dta b(lda),b(p_2c+2)
ien2_s cmp #0
 bcc p_2c

rep2_m lda #0
 dta b(sta),b(p_2c+1)
rep2_s lda #0
 dta b(sta),b(p_2c+2)
 dta b(jmp),a(bank3)

p_2c ldx $4000
ivol12 lda $d800,x
ch_2 sta $d602

bank3 lda #0
 sta $d301

cm_3 lda #0
iad3_m adc #0
 dta b(sta),b(cm_3+1)
 dta b(lda),b(p_3c+1)
iad3_s adc #0
 dta b(sta),b(p_3c+1)
 bcc p_3c
 dta b(inc),b(p_3c+2)
 dta b(lda),b(p_3c+2)
ien3_s cmp #0
 bcc p_3c

rep3_m lda #0
 dta b(sta),b(p_3c+1)
rep3_s lda #0
 dta b(sta),b(p_3c+2)
 dta b(jmp),a(p_e)

p_3c ldx $4000
ivol13 lda $d800,x
ch_3 sta $d603

p_e dey
 beq pat
 jmp $0000

pat dec cnts
 beq pre
 ldy #vbl
 jmp $0000

pre lda #0
 sta patend
 lda #$fe
 sta $d301
 jmp i_0



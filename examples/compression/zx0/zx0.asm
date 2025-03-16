;
; CODE: xxl
; ENTRY: destination adress store in ZX0_OUTPUT, ( no stream? source in ZX0_INPUT )
;
; zx0.exe input_filename output_filename
;
; FORMAT V2 !!! (last update: 10/10/21)
;
; https://xxl.atari.pl/zx0-decompressor/
;

ZX0_OUTPUT      equ ZP
copysrc         equ ZP+2

            mwa #packed_data ZX0_INPUT
            mwa #destination ZX0_OUTPUT
            jsr unZX0

dzx0_standard
              lda   #$ff
              sta   offsetL
              sta   offsetH
              ldy   #$00
              sty   lenL
              sty   lenH
              lda   #$80

dzx0s_literals
              jsr   dzx0s_elias
              pha
cop0          jsr   get_byte
              ldy   #$00
              sta   (ZX0_OUTPUT),y
              inw   ZX0_OUTPUT
              lda   #$ff
lenL          equ   *-1
              bne   @+
              dec   lenH
@             dec   lenL
              bne   cop0
              lda   #$ff
lenH          equ   *-1
              bne   cop0
              pla
              asl   @
              bcs   dzx0s_new_offset
              jsr   dzx0s_elias
dzx0s_copy    pha
              lda   ZX0_OUTPUT
              clc
              adc   #$ff
offsetL       equ   *-1
              sta   copysrc
              lda   ZX0_OUTPUT+1
              adc   #$ff
offsetH       equ   *-1
              sta   copysrc+1
              ldy   #$00
              ldx   lenH
              beq   Remainder
Page          lda   (copysrc),y
              sta   (ZX0_OUTPUT),y
              iny
              bne   Page
              inc   copysrc+1
              inc   ZX0_OUTPUT+1
              dex
              bne   Page
Remainder     ldx   lenL
              beq   copyDone
copyByte      lda   (copysrc),y
              sta   (ZX0_OUTPUT),y
              iny
              dex
              bne   copyByte
              tya
              clc
              adc   ZX0_OUTPUT
              sta   ZX0_OUTPUT
              bcc   copyDone
              inc   ZX0_OUTPUT+1
copyDone      stx   lenH
              stx   lenL
              pla
              asl   @
              bcc   dzx0s_literals
dzx0s_new_offset
              ldx   #$fe
              stx   lenL
              jsr   dzx0s_elias_loop
              pha
; php ; stream
              ldx   lenL
              inx
              stx   offsetH
              bne   @+
; plp ; stream
              pla
              rts           ; koniec
@             jsr   get_byte
; plp ; stream
              sta   offsetL
              ror   offsetH
              ror   offsetL
              ldx   #$00
              stx   lenH
              inx
              stx   lenL
              pla
              bcs   @+
              jsr   dzx0s_elias_backtrack
@             inc   lenL
              bne   @+
              inc   lenH
@             jmp   dzx0s_copy
dzx0s_elias   inc   lenL
dzx0s_elias_loop
              asl   @
              bne   dzx0s_elias_skip
              jsr   get_byte
; sec ; stream
              rol   @
dzx0s_elias_skip
              bcc   dzx0s_elias_backtrack
              rts
dzx0s_elias_backtrack
              asl   @
              rol   lenL
              rol   lenH
              jmp   dzx0s_elias_loop

GET_BYTE          lda    $ffff
ZX0_INPUT         equ    *-2
                  inw    ZX0_INPUT
                  rts

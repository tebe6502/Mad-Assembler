; De-compressor for ZX02 files
; ----------------------------
;
; Decompress ZX02 data (6502 optimized format), optimized for minimal size:
;  121 bytes code, 81.5 cycles/byte in test file.
;
; Compress with:
;    zx02 input.bin output.zx0
;
; (c) 2022 DMSC
; Code under MIT license, see LICENSE file.


ZP=$80

offset          equ ZP+0
bitr            equ ZP+2
ZX0_dst         equ ZP+3
ZX0_src         equ ZP+5
pntr            equ ZP+7
setx            equ ZP+9

            ; Initial values for offset, source, destination and bitr
zx0_ini_block
            .by $00, $00, $80, <out_addr, >out_addr, <comp_data, >comp_data

;--------------------------------------------------
; Decompress ZX0 data (6502 optimized format)

full_decomp
              ; Get initialization block
              ldx #6

copy_init     lda zx0_ini_block,x
              sta offset,x
              dex
              bpl copy_init

              ; Init: X = -2
              dex

; Decode literal: Ccopy next N bytes from compressed file
;    Elias(length)  byte[1]  byte[2]  ...  byte[N]
decode_literal
              ldy   #1
              jsr   get_elias
              jsr   put_byte
              bcs   dzx0s_new_offset

; Copy from last offset (repeat N bytes from last offset)
;    Elias(length)
              iny
              jsr   get_elias
dzx0s_copy
              ; C=0 from get_elias
sbc1          lda   ZX0_dst+2,x
              sbc   offset+2,x
              sta   pntr+2,x
              inx
              bne   sbc1

              jsr   put_byte
              bcc   decode_literal

; Copy from new offset (repeat N bytes from new offset)
;    Elias(MSB(offset))  LSB(offset)  Elias(length-1)
dzx0s_new_offset
              ; Read elias code for high part of offset
              iny
              jsr   get_elias
              beq   exit  ; Read a 0, signals the end
              ; Decrease and divide by 2
              dey
              tya
              lsr   @
              sta   offset+1

              ; Get low part of offset, a literal 7 bits
              jsr   get_byte

              ; Divide by 2
              ror   @
              sta   offset

              ; And get the copy length.
              ; Start elias reading with the bit already in carry:
              ldy   #1
              jsr   elias_skip1

              iny
              bcc   dzx0s_copy

; Read an elias-gamma interlaced code.
; ------------------------------------
elias_loop    ; Read next data bit to result
              asl   bitr
              rol   @
              tay

get_elias     ; Get one bit
              asl   bitr
              bne   elias_skip1

              ; Read new bit from stream
              jsr   get_byte
              ;sec   ; not needed, C=1 guaranteed from last bit
              rol   @
              sta   bitr

elias_skip1   tya
              bcs   elias_loop
              ; Got ending bit, stop reading
              rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_byte
              lda   (ZX0_src+2,x)
              inc   ZX0_src+2,x
              bne   @+
              inc   ZX0_src+3,x
exit
@             rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_byte      stx   setx
ploop         ldx   setx
              jsr   get_byte
              ldx   #$FE
              sta   (ZX0_dst+2,x)
              inc   ZX0_dst
              bne   @+
              inc   ZX0_dst+1
@             dey
              bne   ploop
              asl   bitr
              rts


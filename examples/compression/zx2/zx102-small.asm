; De-compressor for ZX02 "-1" files
; ---------------------------------
;
; Decompress ZX02 data in ZX1 mode (6502 optimized format), optimized for
; minimal size: 131 bytes code, 70.6 cycles/byte in test file.
;
; Compress with:
;    zx02 -1 input.bin output.zx1
;
; (c) 2022 DMSC
; Code under MIT license, see LICENSE file.


ZP=$80

offset          equ ZP+0
ZX0_src         equ ZP+2
ZX0_dst         equ ZP+4
bitr            equ ZP+6
pntr            equ ZP+7

            ; Initial values for offset, source, destination and bitr
zx0_ini_block
            .by $00, $00, <comp_data, >comp_data, <out_addr, >out_addr, $80

;--------------------------------------------------
; Decompress ZX0 data (6502 optimized format)

full_decomp
              ; Get initialization block
              ldy #7

copy_init     lda zx0_ini_block-1, y
              sta offset-1, y
              dey
              bne copy_init

; Decode literal: Ccopy next N bytes from compressed file
;    Elias(length)  byte[1]  byte[2]  ...  byte[N]
decode_literal
              jsr   get_elias

cop0          jsr   get_byte
              jsr   put_byte
              bne   cop0

              asl   bitr
              bcs   dzx0s_new_offset

; Copy from last offset (repeat N bytes from last offset)
;    Elias(length)
              jsr   get_elias
dzx0s_copy
              lda   ZX0_dst
              sbc   offset  ; C=0 from get_elias
              sta   pntr
              lda   ZX0_dst+1
              sbc   offset+1
              sta   pntr+1

cop1
              lda   (pntr), y
              inc   pntr
              bne   @+
              inc   pntr+1
@             jsr   put_byte
              bne   cop1

              asl   bitr
              bcc   decode_literal

; Copy from new offset (repeat N bytes from new offset)
;    MSB(offset>127)  LSB(offset>127)  Elias(length-1)
;    LSB(offset<128)                   Elias(length-1)
dzx0s_new_offset
              sty   offset+1    ; Clear offset MSB

              ; Get low part of offset, a literal 7 bits
              jsr   get_byte
              lsr
              bcc   offset_ok
              cmp   #$7F
              beq   exit  ; Read a 127, signals the end

              sta   offset+1 ; This is now the "high" part

              ; Get low part of offset, a literal 8 bits
              jsr   get_byte
offset_ok
              sta   offset

              ; And get the copy length.
              jsr   get_elias

              inx
              bcc   dzx0s_copy

; Read an elias-gamma interlaced code.
; ------------------------------------
get_elias
              ; Initialize return value to #1
              ldx   #1
              bne   elias_start

elias_get     ; Read next data bit to result
              txa
              asl   bitr
              rol   @
              tax

elias_start
              ; Get one bit
              asl   bitr
              bne   elias_skip1

              ; Read new bit from stream
              jsr   get_byte
              ;sec   ; not needed, C=1 guaranteed from last bit
              rol   @
              sta   bitr

elias_skip1
              bcs   elias_get
              ; Got ending bit, stop reading
              rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_byte
              lda   (ZX0_src), y
              inc   ZX0_src
              bne   @+
              inc   ZX0_src+1
exit
@             rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_byte
              sta   (ZX0_dst),y
              inc   ZX0_dst
              bne   @+
              inc   ZX0_dst+1
@             dex
              rts


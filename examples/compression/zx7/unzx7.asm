ZX7 decompressor. (last update: 12/10/21)

CODE: xxl
ENTRY: 
              mwa #packed_data ZX7_INPUT
              mwa #destination ZX7_OUTPUT
              jsr unZX7

packed_data
              ins 'conan.zx7'

destination     equ $A150
unZX7     lda     #$80
          sta     token
copyby	  jsr     GET_BYTE
          jsr     PUT_BYTE
mainlo	  jsr     getbits
          bcc     copyby
          lda     #$01
          sta     lenL
lenval    jsr     getbits
          rol     lenL
          bcs     _ret           ; koniec
          jsr     getbits
          bcc     lenval
          jsr     GET_BYTE
          sta     offsL
	  lda     ZX7_OUTPUT
	  clc                   ; !!!! C=0
	  sbc     #$ff
offsL     equ     *-1
	  sta     copysrc
	  lda     ZX7_OUTPUT+1
	  sbc     #$00
	  sta     copysrc+1
cop0      lda     $ffff
copysrc   equ     *-2
          inw     copysrc
          jsr     PUT_BYTE
          dec     lenL
          bne     cop0
	  jmp     mainlo

getbits   asl     token               ; bez c
	  bne     _ret
	  jsr     GET_BYTE
          rol     @                   ; c
	  sta     token
_ret	  rts

token     .HE 00
lenL      .HE 00

GET_BYTE  lda     $ffff
ZX7_INPUT         equ *-2
          inw     ZX7_INPUT
          rts

PUT_BYTE  sta     $ffff
ZX7_OUTPUT        equ *-2
          inw     ZX7_OUTPUT
          rts

zobacz: https://github.com/antoniovillena/zx7mini

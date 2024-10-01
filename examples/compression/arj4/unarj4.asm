// https://xxl.atari.pl/arj4-decompressor/

/*
ARJ4 decompressor. (last update: 20/10/21)

CODE: Konop, Rastan, xxl
ENTRY:
*/
	org $2000

destination       equ $a010

ARJ4_INPUT        equ $80
ARJ4_OUTPUT       equ $82
copysrc           equ $84
bitcount          equ $86
bitbuf            equ $87
ARJ4_LENGTH       equ $88
lenL              equ $8A
offs              equ $8B  ;2
temp              equ $8D

	org $2000

dl	dta d'ppp'
	dta $4e,a(destination)
	:101 dta $e
	dta $4e,0,h(destination+$1000)
	:95 dta $e
	dta $41,a(dl)


main	mwa #dl $230

	lda #111
	sta destination+7680

        mwa #packed_data ARJ4_INPUT
        mwa #destination ARJ4_OUTPUT
        mwa #7680 ARJ4_LENGTH
        jsr unARJ4


lp	lda $d20a
	sta $d01a
	jmp lp


unARJ4        ldy     #$00        ; przez cala procke = 0
              lda     #$80
              sta     bitcount

countLoop     lda     ARJ4_LENGTH
              ora     ARJ4_LENGTH+1
              bne     cont
              rts                 ; koniec
cont          jsr     getBit
              bcs     startSld
              ldx     #$08
              jsr     getBits     ; pobierz bajt
              lda     offs
              jsr     PUT_BYTE
              bcc     countLoop   ; zawsze


startSld      jsr     getLengthBits        ; mamy w C bit
              lda     offs
              sec                          ; +1
              adc     lenL
              sta     lenL
              inc     lenL                 ; +1    w sumie +2

              jsr     getOffsBits          ; offset
              lda     offs+1
              adc     temp                 ; c=0
              sta     offs+1

   	      lda     ARJ4_OUTPUT
	      sbc     offs                ; c=0    -1
	      sta     copysrc
	      lda     ARJ4_OUTPUT+1
	      sbc     offs+1
	      sta     copysrc+1
copyLoop      jsr     copy
              dec     lenL
              bne     copyLoop
	      beq     countLoop

getLengthBits
              ldx     #$06    ; 7 bitow, pierwszy juz jest
              lda     #$01    ; pierwsze C
              sta     lenL
getLBLoop     jsr     getBit
              bcc     correctL
              rol     lenL
              dex
              bne     getLBLoop
correctL      lda     #$07+1
              bcc     setOffs ; C=1

getOffsBits   ldx     #$03
              sty     temp
getOBLoop     jsr     getBit
              bcc     correctO
              rol     temp
              dex
              bne     getOBLoop
              jsr     getBit
correctO      rol     temp     ; max 4 bity hi
              lda     #$0c+1   ;c=0
setOffs       stx     offs
              sbc     offs
              tax
getBits       sty     offs
              sty     offs+1
getbLoop      jsr     getBit
              rol     offs
              rol     offs+1
              dex
              bne     getbLoop
              rts

getbit        asl     bitcount
	      bne     @+
 	      rol     bitcount      ; c=1 wiec ustawi najmlodszy bit
GET_BYTE      lda     (ARJ4_INPUT),y
              inw     ARJ4_INPUT
              sta     bitbuf
@             asl     bitbuf
 	      rts

copy          lda     (copysrc),y
              inw     copysrc

PUT_BYTE      sta     (ARJ4_OUTPUT),y
              inw     ARJ4_OUTPUT
              dew     ARJ4_LENGTH
              rts


packed_data       ins 'wins.arj4',8,.FILESIZE 'wins.arj4'-8

	run main
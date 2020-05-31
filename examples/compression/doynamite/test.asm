!cpu 6510

;EXAMPLE FOR OFFICIAL VERSION

count = $cffe

lz_match       = $f9
lz_dst         = $fb
lz_bits        = $fd

lz_scratch     = $fe

lz_sector      = $0400

         * = $0900
!src "decrunch.asm"

         * = $0801
         ;basicline 1 SYS2061
         !byte $0b,$08,$39,$05,$9e,$32
         !byte $30,$36,$31,$00,$00,$00

         sei
         lda #$35
         sta $01
         lda #$00
         sta count
         sta count+1
         lda #$01
         sta $d019
         sta $d01a
         lda #$7f
         sta $dc0d
         lda $dc0d
         lda $d011
         and #$7f
         sta $d011
         lda #$fa
         sta $d012
         lda #<irq
         sta $fffe
         lda #>irq
         sta $ffff
         cli
         jsr go
         sei
         inc $d020
         jmp *
irq
         dec $d019
         inc count
         bne +
         inc count+1
+
         rti
go
         ldx #<data
         ldy #>data

         jsr lz_decrunch
         inc $d020
         sei
         jmp *

*=$4a00
data
         !bin "b.lz",,2
;*=$6a38
;data
;         !bin "d.lz",,2
;*=$3804
;data
;         !bin "ras.lz",,2
;*=$4c74
;data
;         !bin "c.lz",,2


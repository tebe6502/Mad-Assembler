; Pixel data
ice_characters
.byte $55,$66,$5a,$69,$66,$59,$65,$56
.byte $55,$99,$65,$96,$5a,$6a,$a9,$a6
.byte $56,$6a,$aa,$a6,$9a,$6a,$aa,$aa
.byte $5a,$6a,$69,$66,$5a,$6a,$6a,$6a
.byte $9a,$6a,$aa,$aa,$aa,$a9,$a6,$9a
.byte $aa,$aa,$a6,$9a,$6a,$aa,$aa,$aa
.byte $a9,$66,$9a,$6a,$a9,$66,$9a,$6a
.byte $a9,$a6,$9a,$6a,$aa,$aa,$aa,$aa
.byte $aa,$aa,$aa,$aa,$a6,$9a,$6a,$aa
.byte $fd,$b7,$9f,$bf,$ad,$bf,$af,$bb
.byte $55,$66,$5a,$69,$67,$5d,$65,$57
.byte $55,$99,$65,$d7,$5f,$7f,$fd,$f7
.byte $56,$6a,$aa,$a6,$da,$7a,$fa,$fe
.byte $5f,$7f,$7d,$77,$5f,$7f,$7f,$6f
.byte $9a,$6a,$aa,$aa,$aa,$a9,$a6,$9a
.byte $fe,$fe,$f6,$de,$7e,$fe,$fe,$fa
.byte $f9,$76,$de,$7f,$fd,$77,$df,$7f
.byte $a9,$a6,$9a,$6a,$ff,$ff,$ff,$ff
.byte $af,$bf,$bf,$ff,$f7,$df,$7f,$ff
.byte $f9,$b6,$9f,$bf,$ad,$bf,$af,$bb


; Buffer, to be filled with level-specific data
buf_pixels
.byte 0,0,0,0,0,0,0,0 ; Top decoration
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

.byte 0,0,0,0,0,0,0,0 ; Block
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

.byte 0,0,0,0,0,0,0,0 ; Ground
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

dirt_pixels
.byte $f,$2f,$3f,$3d,$35,$14,$90,$a4
.byte $d1,$d3,$59,$68,$a5,$2f,$3d,$3d
.byte $d8,$6b,$1,$16,$3d,$3d,$7d,$f5
.byte $d8,$f4,$de,$55,$95,$a1,$0,$10
.byte $bd,$bf,$9d,$17,$5,$9,$1,$42
.byte $37,$37,$97,$9f,$6d,$4d,$6,$4
.byte $d5,$d6,$56,$5a,$49,$81,$0,$0
.byte $b4,$b4,$fe,$fd,$7d,$5d,$55,$15
.byte $f7,$db,$ee,$7b,$ee,$6b,$fa,$6e
.byte $aa,$59,$95,$56,$65,$55,$55,$55
.byte $fe,$b9,$aa,$a9,$aa,$a9,$aa,$a9
.byte $ea,$fb,$ea,$6a,$ee,$ea,$ea,$ea
.byte $55,$55,$55,$55,$55,$55,$65,$55
.byte $aa,$a9,$aa,$a9,$aa,$ad,$ba,$a9
.byte $95,$95,$94,$94,$94,$94,$95,$95
.byte $55,$55,$14,$24,$14,$24,$95,$54
.byte $55,$54,$15,$24,$15,$24,$95,$44
.byte $55,$15,$54,$14,$4,$14,$5,$11
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $5,$11,$5,$11,$5,$11,$5,$11
.byte $aa,$96,$5a,$58,$68,$28,$82,$aa
.byte $5,$15,$51,$50,$44,$10,$0,$11
.byte $9a,$62,$8a,$aa,$a6,$98,$98,$a2
.byte $2a,$22,$a,$22,$6,$28,$8,$22
.byte $aa,$9a,$a2,$aa,$6a,$8a,$a6,$a8
.byte $5,$15,$5,$11,$5,$11,$5,$14

lego_pixels
.byte $2d,$69,$6a,$7a,$e6,$e2,$e2,$86
.byte $95,$95,$95,$95,$55,$55,$54,$54
.byte $2f,$6e,$ae,$ae,$68,$2a,$5a,$4a
.byte $65,$65,$29,$29,$65,$a5,$95,$95
.byte $a9,$a9,$69,$19,$6,$4b,$2e,$ae
.byte $56,$5e,$7b,$ba,$b8,$a1,$ea,$99
.byte $56,$92,$a5,$68,$65,$95,$55,$56
.byte $54,$54,$50,$21,$64,$a9,$b9,$e5
.byte $af,$ba,$eb,$af,$ef,$b4,$f5,$ff
.byte $bb,$ff,$7e,$1e,$1e,$5f,$7f,$ff
.byte $ff,$ad,$b7,$f1,$f1,$45,$57,$fd
.byte $bf,$fa,$eb,$ef,$ef,$f4,$f5,$ff
.byte $ff,$ff,$7e,$1e,$1e,$5f,$7f,$fd
.byte $ff,$ad,$b7,$f1,$f1,$45,$57,$dd
.byte $95,$95,$95,$95,$95,$95,$95,$95
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $55,$54,$55,$54,$55,$54,$55,$54
.byte $55,$15,$55,$15,$5,$11,$5,$11
.byte $55,$5f,$7d,$75,$75,$58,$5a,$55
.byte $2a,$a5,$1a,$9a,$2a,$a0,$28,$a9
.byte $55,$55,$97,$27,$27,$a5,$95,$55
.byte $55,$f5,$d9,$52,$52,$8a,$a9,$55

beach_pixels
.byte $51,$50,$41,$11,$44,$55,$55,$55
.byte $aa,$ae,$ea,$ab,$aa,$aa,$9a,$5e
.byte $b5,$dd,$f7,$ba,$aa,$aa,$aa,$ae
.byte $eb,$7a,$be,$ea,$aa,$aa,$aa,$aa
.byte $b9,$a5,$9d,$f5,$ae,$bb,$aa,$aa
.byte $77,$5f,$66,$eb,$ba,$aa,$aa,$aa
.byte $55,$a6,$99,$65,$55,$55,$44,$55
.byte $65,$55,$56,$55,$45,$5,$11,$45
.byte $5f,$7b,$ee,$77,$d9,$6a,$7a,$ea
.byte $bf,$ea,$aa,$aa,$ee,$a6,$9a,$6a
.byte $ba,$be,$f9,$aa,$aa,$aa,$a9,$ee
.byte $fa,$6b,$6b,$aa,$ea,$ba,$ea,$fe
.byte $6a,$9a,$ea,$aa,$bf,$6b,$9a,$6a
.byte $bd,$aa,$aa,$a9,$a6,$e9,$fa,$ba
.byte $94,$95,$95,$99,$a6,$95,$95,$95
.byte $65,$45,$49,$51,$55,$59,$95,$54
.byte $55,$54,$51,$44,$55,$54,$51,$44
.byte $54,$15,$45,$15,$6,$11,$5,$11
.byte $56,$95,$59,$55,$55,$99,$55,$65
.byte $aa,$e9,$ae,$b9,$aa,$ed,$aa,$b9
.byte $55,$65,$55,$96,$55,$65,$55,$59
.byte $95,$55,$65,$55,$56,$95,$59,$55
.byte $56,$95,$59,$55,$55,$99,$55,$65
.byte $ea,$a9,$ae,$e9,$aa,$ad,$ea,$b9
.byte $55,$56,$55,$95,$59,$55,$65,$59
.byte $95,$55,$65,$55,$56,$95,$59,$55
.byte $aa,$96,$5b,$5b,$6b,$6f,$be,$aa
.byte $aa,$99,$5b,$6b,$ab,$af,$be,$a9
.byte $ba,$a6,$95,$77,$5d,$95,$a6,$ba
.byte $aa,$ad,$bf,$ce,$f3,$bf,$ae,$a9
.byte $aa,$9a,$56,$9e,$ba,$a6,$95,$a7
.byte $aa,$b9,$fe,$b1,$8a,$ad,$bf,$ae

grass_pixels
.byte $1d,$3d,$f5,$f6,$d8,$42,$a,$a
.byte $9e,$bd,$3d,$35,$1d,$86,$a4,$a2
.byte $1d,$b5,$9d,$26,$4,$20,$a2,$a2
.byte $75,$b6,$1e,$14,$84,$a2,$aa,$aa
.byte $3f,$ce,$3e,$ce,$39,$f9,$25,$e5
.byte $bf,$af,$bf,$6f,$bf,$ef,$bf,$bf
.byte $b3,$ec,$b0,$ac,$98,$ec,$98,$9c
.byte $ef,$eb,$fb,$2e,$fb,$26,$f9,$3d
.byte $55,$66,$9a,$65,$56,$6a,$af,$7f
.byte $65,$aa,$aa,$59,$a6,$fe,$fb,$aa
.byte $96,$ab,$99,$6b,$aa,$af,$fe,$eb
.byte $ba,$69,$95,$5a,$ab,$6e,$a9,$96
.byte $aa,$55,$aa,$ff,$ea,$99,$aa,$aa
.byte $aa,$a6,$5a,$aa,$fb,$6a,$97,$aa
.byte $6a,$6a,$69,$56,$69,$62,$6a,$6a
.byte $a2,$59,$aa,$aa,$a9,$96,$22,$aa
.byte $a,$a8,$a6,$58,$82,$28,$a6,$58
.byte $aa,$2a,$89,$26,$9,$22,$a,$22
.byte $55,$59,$56,$55,$95,$55,$59,$56
.byte $a9,$a5,$ab,$a9,$69,$a9,$a5,$ab
.byte $55,$59,$56,$55,$95,$55,$59,$56
.byte $56,$66,$95,$55,$65,$96,$56,$55
.byte $65,$55,$56,$99,$69,$65,$55,$56
.byte $99,$a9,$ab,$65,$95,$99,$a9,$ab
.byte $95,$55,$55,$66,$65,$55,$99,$55
.byte $55,$59,$65,$55,$55,$99,$66,$55
.byte $aa,$9a,$76,$9a,$aa,$a6,$9d,$a6
.byte $a9,$99,$55,$99,$a9,$a5,$97,$a5
.byte $aa,$9a,$96,$76,$7d,$7d,$96,$9a
.byte $a9,$99,$95,$75,$7f,$5f,$95,$99
.byte $aa,$ab,$9a,$76,$76,$9a,$aa,$ae
.byte $a9,$ab,$99,$55,$55,$99,$a9,$a5

weird_pixels
.byte $9c,$1c,$96,$14,$b6,$b7,$2d,$c7
.byte $8f,$87,$27,$a6,$2e,$1e,$3e,$2c
.byte $89,$1,$89,$8d,$2d,$85,$27,$27
.byte $e0,$c0,$e0,$c0,$88,$3,$89,$27
.byte $8d,$8b,$23,$a2,$28,$ba,$38,$3a
.byte $2a,$c8,$60,$f0,$f8,$de,$bc,$3e
.byte $27,$af,$b7,$bf,$9e,$3e,$9e,$3e
.byte $4a,$29,$64,$14,$11,$4a,$6,$15
.byte $55,$55,$7a,$4a,$4f,$42,$4f,$49
.byte $55,$55,$aa,$aa,$ff,$aa,$59,$6d
.byte $55,$56,$a9,$aa,$fd,$ae,$6d,$be
.byte $4e,$49,$4e,$49,$4e,$4a,$55,$66
.byte $5d,$6d,$5d,$6d,$5d,$aa,$55,$66
.byte $4d,$b2,$41,$b2,$41,$a2,$55,$66
.byte $aa,$65,$a6,$6a,$aa,$6a,$ab,$aa
.byte $aa,$e9,$e9,$ea,$ea,$ea,$ea,$aa
.byte $ab,$7b,$bb,$bb,$bb,$bb,$fb,$ab
.byte $ea,$e5,$f6,$3a,$fa,$3e,$cf,$32
.byte $15,$fa,$e9,$66,$95,$55,$4,$25
.byte $1,$56,$55,$12,$41,$1,$0,$11
.byte $3,$a7,$97,$66,$56,$56,$2,$12
.byte $d0,$a2,$95,$61,$95,$51,$90,$51
.byte $3d,$7a,$79,$66,$69,$65,$29,$25
.byte $15,$16,$15,$12,$15,$11,$15,$11
.byte $1,$2f,$5e,$16,$59,$15,$0,$12
.byte $50,$ea,$99,$65,$55,$55,$40,$51

dice_pixels
.byte $51,$42,$51,$42,$59,$49,$59,$45
.byte $a0,$8e,$1a,$9a,$bb,$aa,$d8,$ae
.byte $9,$5,$49,$45,$49,$5,$49,$5
.byte $a3,$82,$a3,$b8,$6a,$6a,$ee,$a8
.byte $ac,$8b,$a0,$8e,$9a,$1a,$3b,$2a
.byte $18,$ae,$38,$2e,$b8,$ae,$b8,$2e
.byte $80,$e,$9a,$1a,$bb,$2a,$9a,$2e
.byte $62,$b8,$a2,$88,$82,$28,$82,$38
.byte $55,$5f,$7f,$7e,$7b,$79,$79,$7f
.byte $55,$ff,$ff,$bf,$7f,$5f,$5f,$7f
.byte $57,$fe,$fe,$fe,$fe,$fe,$fe,$fe
.byte $6a,$6a,$aa,$6a,$6a,$aa,$6a,$aa
.byte $ff,$fe,$fb,$f9,$f9,$ff,$ff,$ff
.byte $fe,$be,$7e,$5e,$5e,$7e,$fe,$fe
.byte $95,$97,$97,$95,$95,$97,$97,$95
.byte $55,$96,$96,$55,$55,$96,$96,$55
.byte $55,$94,$95,$54,$55,$94,$95,$54
.byte $55,$16,$56,$15,$5,$16,$6,$11
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $a9,$a9,$a9,$a9,$a9,$a9,$a9,$a9
.byte $55,$55,$7d,$ff,$ff,$fe,$be,$69
.byte $a9,$a9,$b9,$ef,$bb,$ee,$3a,$81
.byte $aa,$96,$55,$55,$57,$d4,$be,$aa
.byte $fe,$d2,$45,$11,$47,$10,$c2,$fe
.byte $69,$aa,$aa,$ab,$e8,$7d,$55,$55
.byte $e1,$8a,$22,$8b,$20,$c1,$fd,$fd

boxes_pixels
.byte $55,$55,$a9,$55,$55,$55,$aa,$55
.byte $55,$57,$55,$fe,$55,$55,$ff,$55
.byte $5c,$f8,$56,$83,$62,$58,$f3,$5a
.byte $55,$55,$1f,$55,$55,$2f,$55,$bd
.byte $55,$55,$aa,$57,$55,$5f,$f5,$55
.byte $55,$5f,$d5,$aa,$55,$d7,$55,$55
.byte $54,$eb,$50,$80,$52,$a9,$78,$5e
.byte $55,$55,$2a,$55,$fd,$55,$a9,$55
.byte $55,$6a,$7e,$7e,$7e,$6a,$6a,$6a
.byte $55,$66,$9a,$6a,$a9,$a5,$96,$59
.byte $56,$ab,$ab,$ab,$ab,$ab,$ab,$ab
.byte $6a,$6a,$aa,$6a,$6a,$aa,$6a,$aa
.byte $66,$9a,$6a,$aa,$aa,$aa,$aa,$aa
.byte $56,$56,$56,$42,$56,$42,$56,$56
.byte $6a,$6a,$6a,$6a,$40,$6a,$42,$6a
.byte $aa,$aa,$96,$55,$55,$55,$55,$55
.byte $55,$54,$55,$54,$55,$54,$55,$44
.byte $56,$16,$55,$15,$1,$15,$5,$11
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $11,$45,$11,$45,$11,$45,$11,$45
.byte $55,$95,$a5,$e9,$7a,$5e,$57,$55
.byte $11,$85,$a1,$29,$a,$42,$13,$45
.byte $9a,$96,$55,$55,$55,$55,$d7,$b7
.byte $3a,$be,$fd,$fd,$fd,$fd,$3f,$8c
.byte $55,$55,$59,$6a,$aa,$aa,$eb,$6d
.byte $11,$45,$1d,$7e,$fe,$fe,$3c,$71
.byte $57,$65,$55,$d6,$55,$65,$56,$5d
.byte $13,$45,$11,$86,$11,$45,$12,$49

apples_pixels
.byte $2b,$36,$37,$6,$fb,$c6,$f9,$c9
.byte $6,$85,$26,$26,$9a,$16,$9a,$6a
.byte $23,$3e,$3b,$ce,$c1,$c1,$d,$ce
.byte $6a,$a8,$62,$aa,$65,$96,$6a,$a8
.byte $a,$3d,$ce,$f1,$c2,$f2,$f2,$f3
.byte $aa,$6a,$9a,$6a,$5a,$68,$5a,$68
.byte $d,$ca,$9,$ca,$6,$ca,$6,$ca
.byte $60,$a8,$60,$a8,$a2,$a8,$a2,$a2
.byte $f7,$dd,$57,$5f,$5e,$7e,$5e,$7e
.byte $5f,$ff,$2b,$e,$8b,$83,$a3,$a3
.byte $f7,$fd,$ff,$fd,$ff,$ef,$af,$af
.byte $de,$7f,$df,$f7,$dd,$ff,$ff,$ff
.byte $5f,$77,$df,$fe,$ff,$fb,$ff,$ff
.byte $bf,$fd,$bf,$fd,$f7,$fd,$f5,$dd
.byte $9d,$b5,$95,$f5,$d5,$d5,$d5,$d5
.byte $55,$55,$55,$55,$55,$55,$55,$55
.byte $55,$54,$55,$54,$51,$54,$51,$44
.byte $59,$25,$45,$15,$5,$11,$5,$1
.byte $56,$66,$95,$55,$65,$96,$56,$55
.byte $aa,$8a,$29,$aa,$89,$2a,$aa,$a9
.byte $56,$95,$65,$55,$56,$59,$95,$95
.byte $55,$59,$56,$55,$95,$55,$59,$56
.byte $55,$59,$65,$55,$55,$99,$66,$55
.byte $a9,$a1,$8a,$a9,$aa,$21,$8a,$a9
.byte $65,$55,$56,$99,$69,$65,$55,$56
.byte $95,$55,$55,$66,$65,$55,$99,$55
.byte $95,$a5,$a9,$9a,$a7,$ab,$6d,$75
.byte $bd,$ad,$ab,$ba,$af,$ab,$e1,$cd
.byte $56,$5a,$6b,$ae,$aa,$aa,$6b,$7d
.byte $fe,$fa,$eb,$2e,$8a,$22,$c3,$fd
.byte $d5,$79,$7d,$fd,$fe,$bf,$7f,$5b
.byte $bd,$eb,$c9,$2b,$8a,$22,$ca,$f2


; Mid color data
ice_midcolor
.byte $13,$13,$13,$13,$13,$13,$1e,$1e
.byte $1e,$16,$13,$13,$13,$13,$18,$13
.byte $18,$18,$18,$16

; Buffer, to be filled with level-specific data
buf_midcolor
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

dirt_midcolor
.byte $5b,$5b,$5b,$5b,$5b,$5b,$5b,$5b
.byte $1c,$cf,$bc,$1c,$cf,$bc,$bc,$bc
.byte $bc,$b0,$90,$90,$89,$90,$89,$89
.byte $89,$90

lego_midcolor
.byte $6e,$6e,$6e,$6e,$6e,$6e,$6e,$6e
.byte $27,$27,$27,$27,$27,$27,$2a,$20
.byte $20,$20,$5b,$5b,$5b,$5b

beach_midcolor
.byte $60,$36,$36,$36,$36,$36,$6e,$6e
.byte $1c,$bc,$bc,$1c,$bc,$bc,$bc,$bc
.byte $b0,$bc,$78,$78,$78,$78,$78,$78
.byte $78,$78,$17,$78,$57,$78,$57,$78

grass_midcolor
.byte $59,$59,$59,$59,$78,$78,$78,$78
.byte $78,$78,$78,$78,$78,$78,$89,$89
.byte $89,$89,$5d,$5b,$5d,$5d,$5d,$5b
.byte $5d,$5d,$15,$5b,$15,$5b,$15,$5b

weird_midcolor
.byte $12,$12,$12,$12,$12,$12,$12,$2a
.byte $78,$78,$78,$78,$78,$78,$78,$78
.byte $78,$78,$6e,$6e,$6e,$6e,$6e,$6e
.byte $6e,$6e

dice_midcolor
.byte $6e,$16,$6e,$16,$16,$16,$16,$16
.byte $12,$12,$12,$1a,$12,$12,$2a,$2c
.byte $2c,$2c,$50,$5b,$5b,$5b,$25,$25
.byte $56,$56

boxes_midcolor
.byte $1f,$1c,$1c,$1c,$1c,$1c,$1c,$1c
.byte $18,$1f,$78,$78,$1f,$89,$89,$9c
.byte $90,$9c,$40,$40,$47,$48,$14,$14
.byte $47,$47,$4b,$4b

apples_midcolor
.byte $78,$89,$78,$89,$78,$89,$78,$89
.byte $12,$12,$27,$12,$27,$27,$27,$20
.byte $20,$2a,$5b,$5b,$5b,$5b,$5b,$5b
.byte $5b,$5b,$57,$58,$58,$58,$58,$59


; FG color data
ice_fgcolor
.byte $0,$0,$0,$0,$0,$0,$0,$0
.byte $0,$e,$8,$8,$8,$8,$0,$8
.byte $e,$e,$e,$e

; Buffer, to be filled with level-specific data
buf_fgcolor
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

dirt_fgcolor
.byte $d,$d,$d,$d,$d,$d,$d,$d
.byte $f,$0,$f,$f,$0,$f,$0,$0
.byte $0,$0,$0,$0,$0,$0,$0,$0
.byte $0,$0

lego_fgcolor
.byte $f,$0,$f,$0,$f,$f,$0,$f
.byte $a,$a,$a,$a,$a,$a,$0,$0
.byte $0,$0,$d,$0,$d,$d

beach_fgcolor
.byte $0,$e,$e,$e,$e,$e,$0,$0
.byte $f,$f,$f,$f,$f,$f,$0,$0
.byte $0,$0,$0,$9,$0,$0,$0,$9
.byte $0,$0,$8,$9,$8,$b,$8,$b

grass_fgcolor
.byte $d,$d,$d,$d,$9,$9,$9,$9
.byte $9,$9,$9,$9,$9,$9,$0,$0
.byte $0,$0,$0,$d,$0,$0,$0,$d
.byte $0,$0,$d,$d,$d,$d,$d,$d

weird_fgcolor
.byte $a,$a,$a,$a,$a,$a,$a,$0
.byte $9,$9,$9,$9,$9,$9,$9,$9
.byte $9,$9,$f,$0,$f,$f,$f,$0
.byte $f,$f

dice_fgcolor
.byte $0,$e,$0,$e,$e,$e,$e,$e
.byte $a,$a,$a,$0,$a,$a,$c,$0
.byte $0,$0,$0,$0,$f,$f,$b,$b
.byte $b,$b

boxes_fgcolor
.byte $0,$f,$f,$f,$f,$f,$f,$f
.byte $f,$0,$9,$0,$0,$0,$0,$0
.byte $0,$0,$0,$0,$b,$b,$b,$c
.byte $b,$8,$f,$f

apples_fgcolor
.byte $9,$0,$9,$0,$9,$0,$9,$0
.byte $a,$a,$a,$a,$a,$a,$a,$0
.byte $0,$0,$0,$0,$0,$0,$0,$0
.byte $0,$0,$b,$b,$b,$b,$9,$b

*         2010    201283
*
** STAMPS.S **
** ASTEROIDS FOR THE ATARI 3600 **
** UNCONVERTED GRAPHICS DATA. **
** SWITCHED NOW FOR MARIA2. **


* START OF GRAPHICS DATA *
	ORG	$C000
GRAPHICS  EQU	*

STAMPS    EQU     GRAPHICS-$1000	;ODD 4K PAGE BOUNDARY FOR HOLY DMA

				;1
********************************************************************************
	.byte	$03,$FC,$00	;ROCK1L
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00	;ROCK2L
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$03,$FC,$00
	.byte	$00,$F0,$00	;ROCK3L
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$F0,$00
	.byte	$00,$00,$00	;ROCKEL
	.byte	$00,$23,$00
	.byte	$00,$10,$00
	.byte	$00,$08,$00
	.byte	$00,$20,$00
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK1M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK2M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK3M
	.byte	0,0,0,0,0,0,0,0,0,0		;ROCKEM
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;SHIP
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;SHIPE
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;UFO
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$100			;2
********************************************************************************
	.byte	$0F,$AA,$00	;ROCK1L
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$AB,$00
	.byte	$0F,$AF,$00
	.byte	$0F,$B6,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$6A,$00
	.byte	$0F,$AB,$00
	.byte	$0F,$AD,$00
	.byte	$0F,$AD,$00
	.byte	$0F,$B5,$00
	.byte	$0F,$EA,$00	;ROCK2L
	.byte	$0F,$DA,$00
	.byte	$0F,$E9,$00
	.byte	$0F,$E9,$00
	.byte	$0F,$EA,$00
	.byte	$0F,$F5,$00
	.byte	$0F,$B9,$00
	.byte	$0F,$EB,$00
	.byte	$0F,$FA,$00
	.byte	$0F,$E9,$00
	.byte	$0F,$E9,$00
	.byte	$0F,$EA,$00
	.byte	$0F,$FF,$00	;ROCK3L
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FE,$00
	.byte	$0F,$BF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$0F,$FF,$00
	.byte	$00,$00,$00	;ROCKEL
	.byte	$00,$10,$00
	.byte	$00,$08,$00
	.byte	$08,$10,$40
	.byte	$23,$04,$00
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK1M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK2M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK3M
	.byte	0,0,0,0,0,0,0,0,0,0		;ROCKEM
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;SHIP
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;SHIPE
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;UFO
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$200			;3
********************************************************************************
	.byte	$0F,$F6,$00	;ROCK1L
	.byte	$0F,$A5,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$AF,$00
	.byte	$0F,$BF,$00
	.byte	$0F,$D5,$00
	.byte	$0D,$A5,$00
	.byte	$0F,$99,$00
	.byte	$0E,$9D,$00
	.byte	$0F,$B5,$00
	.byte	$0F,$B7,$00
	.byte	$0F,$A5,$00	;ROCK2L
	.byte	$0F,$A5,$00
	.byte	$0F,$A9,$00
	.byte	$0F,$A9,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$B9,$00
	.byte	$0F,$AD,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$A9,$00
	.byte	$0F,$A6,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$95,$00
	.byte	$0F,$AA,$00	;ROCK3L
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$A6,$C0
	.byte	$0F,$DE,$00
	.byte	$0F,$BA,$00
	.byte	$0E,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$0F,$AA,$00
	.byte	$00,$01,$00	;ROCKEL
	.byte	$00,$10,$90
	.byte	$00,$20,$08
	.byte	$08,$10,$40
	.byte	$00,$00,$00
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK1M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK2M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK3M
	.byte	0,0,0,0,0,0,0,0,0,0		;ROCKEM
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;SHIP
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;SHIPE
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;UFO
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$300			;4
********************************************************************************
	.byte	$3F,$55,$80	;ROCK1L
	.byte	$3E,$95,$40
	.byte	$3E,$95,$80
	.byte	$3E,$95,$40
	.byte	$3E,$A5,$40
	.byte	$3E,$BD,$40
	.byte	$3E,$FD,$40
	.byte	$3F,$56,$40
	.byte	$3E,$95,$40
	.byte	$3E,$A5,$C0
	.byte	$3E,$B5,$40
	.byte	$3E,$D6,$80
	.byte	$3F,$99,$40	;ROCK2L
	.byte	$3F,$69,$40
	.byte	$3E,$A5,$40
	.byte	$3E,$95,$40
	.byte	$3E,$95,$40
	.byte	$3E,$A5,$40
	.byte	$3E,$ED,$40
	.byte	$3E,$95,$C0
	.byte	$3E,$A5,$40
	.byte	$3F,$A5,$40
	.byte	$3E,$A5,$40
	.byte	$3E,$95,$40
	.byte	$3E,$96,$80	;ROCK3L
	.byte	$3E,$96,$80
	.byte	$3E,$96,$80
	.byte	$3E,$96,$80
	.byte	$3E,$95,$C0
	.byte	$3E,$9F,$C0
	.byte	$3E,$75,$80
	.byte	$3F,$D6,$80
	.byte	$3B,$96,$80
	.byte	$3E,$96,$80
	.byte	$3E,$96,$80
	.byte	$3E,$96,$80
	.byte	$00,$20,$00	;ROCKEL
	.byte	$04,$14,$40
	.byte	$01,$29,$10
	.byte	$01,$04,$48
	.byte	$00,$40,$00
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK1M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK2M
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;ROCK3M
	.byte	0,0,0,0,0,0,0,0,0,0		;ROCKEM
	.byte	$01,$00				;SHIP
	.byte	$04,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$40
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;SHIPE
	.byte	0,0,0,0,0,0,0,0,0,0,0,0		;UFO
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$400	;5
********************************************************************************
	.byte	$3F,$75,$40	;ROCK1L
	.byte	$3F,$99,$40
	.byte	$3E,$95,$40
	.byte	$3E,$65,$40
	.byte	$3E,$95,$40
	.byte	$3E,$55,$40
	.byte	$3E,$F6,$40
	.byte	$3F,$F5,$40
	.byte	$3E,$55,$40
	.byte	$3E,$95,$40
	.byte	$3E,$57,$C0
	.byte	$3E,$D6,$80
	.byte	$3E,$A5,$40	;ROCK2L
	.byte	$3F,$A5,$40
	.byte	$3F,$99,$40
	.byte	$3E,$65,$40
	.byte	$3E,$55,$40
	.byte	$3E,$95,$40
	.byte	$3E,$95,$80
	.byte	$3E,$55,$C0
	.byte	$3E,$55,$40
	.byte	$3F,$95,$40
	.byte	$3E,$D5,$40
	.byte	$3E,$55,$40
	.byte	$3E,$95,$40	;ROCK3L
	.byte	$3E,$55,$40
	.byte	$3E,$55,$80
	.byte	$3E,$55,$C0
	.byte	$3A,$55,$80
	.byte	$3A,$D7,$40
	.byte	$3A,$95,$40
	.byte	$39,$D5,$40
	.byte	$2E,$55,$40
	.byte	$3E,$55,$40
	.byte	$3E,$55,$40
	.byte	$3E,$55,$40
	.byte	$00,$38,$80	;ROCKEL
	.byte	$10,$94,$80
	.byte	$80,$51,$50
	.byte	$03,$49,$00
	.byte	$00,$01,$00
	.byte	$03,$F0		;ROCK1M
	.byte	$00,$F0
	.byte	$00,$F0
	.byte	$00,$F0
	.byte	$03,$F0
	.byte	$03,$F0
	.byte	$03,$F0
	.byte	$00,$F0
	.byte	$0F,$F0		;ROCK2M
	.byte	$0F,$F0
	.byte	$0E,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$03,$F0
	.byte	$03,$F0
	.byte	$03,$F0
	.byte	$0F,$F0		;ROCK3M
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$0F,$F0
	.byte	$00,$00		;ROCKEM
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$04,$20
	.byte	$01,$00		;SHIP
	.byte	$04,$80
	.byte	$02,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$02,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$02,$00
	.byte	$08,$40
	.byte	$00,$00		;SHIPE
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$02
	.byte	$00,$00
	.byte	$00,$00
	.byte	0,0,0,0,0,0,0,0	;UFOL
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$500	;6
********************************************************************************
	.byte	$FD,$6D,$50	;ROCK1L
	.byte	$FD,$55,$50
	.byte	$FE,$65,$50
	.byte	$FE,$55,$50
	.byte	$FE,$55,$50
	.byte	$FE,$95,$50
	.byte	$FE,$95,$50
	.byte	$FB,$D5,$50
	.byte	$FF,$D9,$D0
	.byte	$FE,$55,$50
	.byte	$FE,$95,$D0
	.byte	$FE,$9F,$D0
	.byte	$FE,$65,$50	;ROCK2L
	.byte	$FF,$95,$50
	.byte	$FF,$95,$50
	.byte	$FE,$D6,$50
	.byte	$FE,$95,$50
	.byte	$FA,$65,$50
	.byte	$FF,$55,$50
	.byte	$FF,$5D,$D0
	.byte	$FE,$55,$70
	.byte	$FE,$A5,$50
	.byte	$FF,$D5,$50
	.byte	$FF,$75,$50
	.byte	$FA,$65,$60	;ROCK3L
	.byte	$FA,$95,$60
	.byte	$FA,$55,$60
	.byte	$FA,$5D,$70
	.byte	$FA,$76,$F0
	.byte	$FA,$59,$60
	.byte	$FE,$55,$60
	.byte	$FF,$55,$60
	.byte	$FA,$55,$60
	.byte	$FA,$55,$60
	.byte	$FA,$5D,$60
	.byte	$F9,$B5,$60
	.byte	$02,$25,$80	;ROCKEL
	.byte	$05,$69,$04
	.byte	$26,$99,$40
	.byte	$00,$62,$00
	.byte	$01,$04,$08
	.byte	$03,$F0		;ROCK1M
	.byte	$0F,$F0
	.byte	$0B,$F0
	.byte	$0E,$F0
	.byte	$0F,$B0
	.byte	$0F,$EC
	.byte	$0F,$F8
	.byte	$03,$FC
	.byte	$2F,$FC		;ROCK2M
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$BC
	.byte	$0F,$FC
	.byte	$03,$FC
	.byte	$03,$FC
	.byte	$03,$FC
	.byte	$3F,$FC		;ROCK3M
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$3F,$FC
	.byte	$00,$00		;ROCKEM
	.byte	$00,$00
	.byte	$05,$20
	.byte	$04,$08
	.byte	$00,$00
	.byte	$20,$20		;SHIP
	.byte	$03,$80
	.byte	$42,$00
	.byte	$08,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$80
	.byte	$02,$00
	.byte	$08,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$80
	.byte	$02,$04
	.byte	$0B,$00
	.byte	$00,$00		;SHIPE
	.byte	$00,$20
	.byte	$00,$08
	.byte	$01,$00
	.byte	$00,$00
	.byte	$00,$08
	.byte	0,0,0,0,0,0,0,0	;UFOL
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$600	;7
********************************************************************************
	.byte	$FD,$6D,$50	;ROCK1L
	.byte	$FF,$55,$70
	.byte	$FF,$55,$50
	.byte	$FA,$55,$50
	.byte	$FA,$95,$50
	.byte	$FA,$55,$50
	.byte	$FA,$55,$50
	.byte	$F9,$55,$50
	.byte	$FF,$65,$50
	.byte	$FF,$95,$50
	.byte	$F9,$55,$50
	.byte	$F9,$67,$50
	.byte	$FA,$D5,$50	;ROCK2L
	.byte	$FA,$99,$50
	.byte	$FA,$D5,$50
	.byte	$F6,$E5,$50
	.byte	$FA,$95,$90
	.byte	$FE,$96,$50
	.byte	$FA,$95,$50
	.byte	$FB,$65,$D0
	.byte	$F9,$97,$70
	.byte	$FA,$95,$50
	.byte	$FF,$55,$50
	.byte	$FF,$F5,$50
	.byte	$F9,$D5,$50	;ROCK3L
	.byte	$FD,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$55,$70
	.byte	$FA,$56,$D0
	.byte	$F9,$55,$50
	.byte	$F9,$55,$50
	.byte	$FA,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$57,$50
	.byte	$F9,$5A,$50
	.byte	$FA,$59,$50
	.byte	$0A,$57,$00	;ROCKEL
	.byte	$02,$75,$80
	.byte	$01,$55,$10
	.byte	$02,$02,$18
	.byte	$06,$00,$C2
	.byte	$0F,$FC		;ROCK1M
	.byte	$0F,$FC
	.byte	$0F,$FC
	.byte	$0F,$F0
	.byte	$0F,$F8
	.byte	$0F,$FF
	.byte	$0F,$FC
	.byte	$0F,$FF
	.byte	$3F,$D8		;ROCK2M
	.byte	$3B,$D8
	.byte	$3E,$A8
	.byte	$3E,$A8
	.byte	$3E,$A8
	.byte	$3E,$98
	.byte	$3F,$A8
	.byte	$3F,$D8
	.byte	$3E,$A8		;ROCK3M
	.byte	$3E,$A8
	.byte	$3E,$A8
	.byte	$3E,$A8
	.byte	$3E,$A8
	.byte	$3E,$E8
	.byte	$3D,$A8
	.byte	$3E,$A8
	.byte	$00,$00		;ROCKEM
	.byte	$00,$30
	.byte	$01,$40
	.byte	$09,$10
	.byte	$C0,$08
	.byte	$2F,$E0		;SHIP
	.byte	$02,$80
	.byte	$0E,$00
	.byte	$0A,$00
	.byte	$2C,$00
	.byte	$00,$00
	.byte	$00,$E0
	.byte	$02,$80
	.byte	$02,$00
	.byte	$0A,$00
	.byte	$2C,$00
	.byte	$00,$00
	.byte	$00,$E0
	.byte	$02,$80
	.byte	$02,$C0
	.byte	$0A,$00
	.byte	$01,$04		;SHIPE
	.byte	$04,$10
	.byte	$00,$A0
	.byte	$02,$40
	.byte	$02,$80
	.byte	$02,$00
	.byte	0,0,0,0,0,0,0,0	;UFOL
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$700	;8
********************************************************************************
	.byte	$F9,$5D,$50	;ROCK1L
	.byte	$F5,$D5,$50
	.byte	$FD,$55,$D0
	.byte	$F9,$55,$50
	.byte	$FA,$55,$50
	.byte	$FA,$65,$50
	.byte	$F9,$65,$50
	.byte	$F5,$95,$50
	.byte	$F9,$55,$50
	.byte	$FD,$5D,$50
	.byte	$FD,$96,$50
	.byte	$FA,$55,$50
	.byte	$FA,$F7,$50	;ROCK2L
	.byte	$FA,$95,$50
	.byte	$F9,$D6,$50
	.byte	$FA,$B5,$50
	.byte	$F9,$9D,$50
	.byte	$F6,$95,$50
	.byte	$FB,$95,$50
	.byte	$FF,$D5,$50
	.byte	$F9,$75,$70
	.byte	$FA,$55,$D0
	.byte	$FA,$95,$50
	.byte	$FB,$D9,$50
	.byte	$FD,$D5,$50	;ROCK3L
	.byte	$FF,$55,$50
	.byte	$F9,$55,$90
	.byte	$F9,$65,$70
	.byte	$F9,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$59,$50
	.byte	$F9,$65,$50
	.byte	$FA,$56,$50
	.byte	$F9,$55,$90
	.byte	$F9,$66,$50
	.byte	$FE,$6D,$50
	.byte	$00,$B5,$80	;ROCKEL
	.byte	$00,$96,$60
	.byte	$00,$75,$60
	.byte	$01,$08,$88
	.byte	$80,$00,$80
	.byte	$0E,$E8		;ROCK1M
	.byte	$3F,$BC
	.byte	$3F,$AC
	.byte	$3E,$A8
	.byte	$3B,$A8
	.byte	$3E,$F4
	.byte	$0F,$BF
	.byte	$0F,$AF
	.byte	$FB,$FB		;ROCK2M
	.byte	$FB,$FB
	.byte	$FA,$FB
	.byte	$FA,$5B
	.byte	$FA,$5B
	.byte	$FA,$97
	.byte	$FA,$9B
	.byte	$FB,$DB
	.byte	$FA,$5B		;ROCK3M
	.byte	$FA,$5B
	.byte	$F9,$5B
	.byte	$FA,$5F
	.byte	$FB,$58
	.byte	$FA,$AB
	.byte	$F6,$9F
	.byte	$FA,$6F
	.byte	$00,$00		;ROCKEM
	.byte	$01,$00
	.byte	$01,$40
	.byte	$00,$62
	.byte	$20,$30
	.byte	$3A,$B0		;SHIP
	.byte	$EA,$80
	.byte	$0A,$C0
	.byte	$4A,$80
	.byte	$2A,$00
	.byte	$2A,$C0
	.byte	$02,$A0
	.byte	$0E,$80
	.byte	$0E,$C0
	.byte	$0A,$00
	.byte	$2A,$00
	.byte	$0E,$A0
	.byte	$02,$A0
	.byte	$0A,$84
	.byte	$0E,$80
	.byte	$0A,$AC
	.byte	$01,$04		;SHIPE
	.byte	$0A,$90
	.byte	$02,$10
	.byte	$00,$A0
	.byte	$03,$88
	.byte	$00,$00
	.byte	0,0,0,0,0,0,0,0	;UFOL
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$800	;9
********************************************************************************
	.byte	$F9,$75,$50	;ROCK1L
	.byte	$F9,$D5,$50
	.byte	$F7,$55,$50
	.byte	$F6,$57,$50
	.byte	$FA,$55,$50
	.byte	$F9,$55,$50
	.byte	$FA,$55,$50
	.byte	$F9,$55,$50
	.byte	$FA,$55,$50
	.byte	$FA,$55,$50
	.byte	$FA,$55,$50
	.byte	$FA,$59,$50
	.byte	$FA,$FF,$50	;ROCK2L
	.byte	$FE,$9D,$50
	.byte	$FB,$95,$50
	.byte	$F9,$75,$90
	.byte	$FA,$5D,$50
	.byte	$F9,$95,$60
	.byte	$FA,$95,$50
	.byte	$FD,$95,$50
	.byte	$FA,$75,$50
	.byte	$FA,$9D,$50
	.byte	$FA,$55,$70
	.byte	$FA,$95,$50
	.byte	$FA,$E5,$50	;ROCK3L
	.byte	$FB,$55,$90
	.byte	$FD,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$95,$50
	.byte	$FA,$56,$50
	.byte	$F9,$56,$50
	.byte	$F9,$59,$90
	.byte	$F9,$95,$D0
	.byte	$FA,$55,$D0
	.byte	$F9,$67,$50
	.byte	$F9,$AD,$50
	.byte	$00,$64,$80	;ROCKEL
	.byte	$04,$5D,$28
	.byte	$10,$15,$62
	.byte	$20,$50,$00
	.byte	$00,$52,$00
	.byte	$2F,$98		;ROCK1M
	.byte	$3A,$BB
	.byte	$3E,$AF
	.byte	$3E,$97
	.byte	$3F,$A4
	.byte	$3E,$D6
	.byte	$3F,$B6
	.byte	$3E,$B4
	.byte	$FA,$F6		;ROCK2M
	.byte	$FA,$FD
	.byte	$F9,$FE
	.byte	$FD,$7E
	.byte	$F9,$96
	.byte	$FE,$56
	.byte	$F9,$56
	.byte	$F9,$56
	.byte	$F9,$56		;ROCK3M
	.byte	$F9,$5A
	.byte	$F9,$74
	.byte	$FD,$5C
	.byte	$F9,$54
	.byte	$F9,$76
	.byte	$F9,$7F
	.byte	$F9,$5E
	.byte	$02,$00		;ROCKEM
	.byte	$09,$80
	.byte	$06,$C8
	.byte	$11,$10
	.byte	$00,$00
	.byte	$0A,$80		;SHIP
	.byte	$2A,$80
	.byte	$3A,$80
	.byte	$0E,$B0
	.byte	$0A,$B0
	.byte	$3A,$A8
	.byte	$3A,$B0
	.byte	$0A,$80
	.byte	$0A,$80
	.byte	$0A,$80
	.byte	$3A,$B0
	.byte	$AA,$B0
	.byte	$3A,$80
	.byte	$3A,$C0
	.byte	$0A,$B0
	.byte	$0A,$A0
	.byte	$02,$54	;SHIPE
	.byte	$09,$60
	.byte	$06,$10
	.byte	$0A,$12
	.byte	$00,$20
	.byte	$00,$80
	.byte	$0,0,0,0,0,0,0,0	;UFOL
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$900	;10
********************************************************************************
	.byte	$FA,$55,$50	;ROCK1L
	.byte	$FF,$D5,$70
	.byte	$F7,$65,$70
	.byte	$FE,$65,$70
	.byte	$FD,$5D,$50
	.byte	$FA,$55,$50
	.byte	$FA,$95,$50
	.byte	$FA,$55,$50
	.byte	$F9,$65,$50
	.byte	$FA,$55,$50
	.byte	$FA,$D5,$50
	.byte	$F9,$55,$50
	.byte	$FE,$7D,$50	;ROCK2L
	.byte	$FE,$5F,$70
	.byte	$FB,$57,$50
	.byte	$FA,$D5,$50
	.byte	$FA,$9D,$60
	.byte	$FA,$55,$D0
	.byte	$FA,$59,$50
	.byte	$FA,$95,$50
	.byte	$FA,$FD,$50
	.byte	$FA,$5D,$50
	.byte	$FA,$57,$50
	.byte	$FA,$55,$50
	.byte	$FF,$D5,$50	;ROCK3L
	.byte	$FB,$95,$50
	.byte	$EE,$59,$50
	.byte	$F9,$59,$50
	.byte	$F9,$55,$50
	.byte	$F9,$55,$90
	.byte	$F9,$55,$50
	.byte	$F9,$55,$70
	.byte	$F9,$56,$D0
	.byte	$F9,$56,$D0
	.byte	$F9,$6F,$50
	.byte	$F9,$B6,$50
	.byte	$00,$44,$00	;ROCKEL
	.byte	$00,$E5,$00
	.byte	$02,$46,$40
	.byte	$00,$62,$C0
	.byte	$00,$10,$00
	.byte	$3E,$B4		;ROCK1M
	.byte	$FE,$5C
	.byte	$FE,$57
	.byte	$FF,$94
	.byte	$3D,$D6
	.byte	$3E,$75
	.byte	$3E,$9E
	.byte	$3E,$94
	.byte	$E9,$55		;ROCK2M
	.byte	$E9,$7E
	.byte	$E6,$7C
	.byte	$FD,$7C
	.byte	$EB,$5C
	.byte	$ED,$96
	.byte	$FB,$55
	.byte	$E9,$56
	.byte	$E9,$56		;ROCK3M
	.byte	$E5,$DE
	.byte	$F9,$7C
	.byte	$EA,$5C
	.byte	$E9,$D5
	.byte	$E9,$FF
	.byte	$E9,$76
	.byte	$EA,$56
	.byte	$02,$40		;ROCKEM
	.byte	$01,$60
	.byte	$15,$A0
	.byte	$88,$80
	.byte	$00,$40
	.byte	$0A,$80		;SHIP
	.byte	$3A,$80
	.byte	$AA,$80
	.byte	$0A,$AC
	.byte	$4A,$A8
	.byte	$0A,$AC
	.byte	$AA,$80
	.byte	$3A,$80
	.byte	$0A,$80
	.byte	$0A,$B0
	.byte	$0A,$A8
	.byte	$EA,$80
	.byte	$AA,$84
	.byte	$EA,$80
	.byte	$0A,$A8
	.byte	$0A,$B0
	.byte	$00,$54		;SHIPE
	.byte	$01,$50
	.byte	$01,$98
	.byte	$04,$60
	.byte	$02,$08
	.byte	$00,$00
	.byte	$0A,$A0		;UFOL
	.byte	$0A,$A0
	.byte	$0A,$A0
	.byte	$0A,$A0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ORG     GRAPHICS+$A00	;11
********************************************************************************
	.byte	$FE,$95,$40	;ROCK1L
	.byte	$FF,$55,$70
	.byte	$FF,$55,$F0
	.byte	$FE,$55,$F0
	.byte	$FE,$95,$D0
	.byte	$FD,$55,$70
	.byte	$FE,$55,$50
	.byte	$FE,$55,$50
	.byte	$FE,$55,$70
	.byte	$FD,$55,$50
	.byte	$FD,$55,$50
	.byte	$FF,$55,$50
	.byte	$FE,$95,$70	;ROCK2L
	.byte	$FE,$9F,$F0
	.byte	$FE,$57,$D0
	.byte	$FE,$D5,$D0
	.byte	$FA,$7D,$50
	.byte	$FE,$55,$D0
	.byte	$FE,$55,$70
	.byte	$FA,$55,$90
	.byte	$FE,$D5,$50
	.byte	$FA,$BF,$50
	.byte	$FD,$97,$50
	.byte	$FE,$95,$D0
	.byte	$FF,$55,$60	;ROCK3L
	.byte	$FB,$56,$60
	.byte	$ED,$55,$60
	.byte	$B9,$55,$60
	.byte	$F9,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$55,$50
	.byte	$F9,$55,$B0
	.byte	$F9,$57,$D0
	.byte	$F9,$5B,$50
	.byte	$FA,$6D,$50
	.byte	$FE,$55,$50
	.byte	$01,$08,$00	;ROCKEL
	.byte	$02,$44,$04
	.byte	$01,$14,$10
	.byte	$81,$04,$10
	.byte	$81,$80,$08
	.byte	$FE,$56		;ROCK1M
	.byte	$FD,$54
	.byte	$FD,$55
	.byte	$FE,$55
	.byte	$FB,$D5
	.byte	$F9,$F5
	.byte	$FA,$7D
	.byte	$F9,$5B
	.byte	$E9,$55		;ROCK2M
	.byte	$E5,$56
	.byte	$A9,$5C
	.byte	$FD,$5C
	.byte	$EF,$5C
	.byte	$EA,$D6
	.byte	$EF,$55
	.byte	$ED,$D6
	.byte	$E7,$76		;ROCK3M
	.byte	$E5,$FC
	.byte	$E9,$7C
	.byte	$E5,$54
	.byte	$EB,$FE
	.byte	$E5,$D5
	.byte	$E9,$56
	.byte	$E9,$56
	.byte	$01,$80		;ROCKEM
	.byte	$0B,$40
	.byte	$02,$40
	.byte	$31,$18
	.byte	$00,$01
	.byte	$0A,$80		;SHIP
	.byte	$0A,$80
	.byte	$3A,$B0
	.byte	$3A,$A8
	.byte	$0A,$B0
	.byte	$0E,$B0
	.byte	$3A,$80
	.byte	$2A,$80
	.byte	$0A,$80
	.byte	$0A,$A0
	.byte	$0A,$B0
	.byte	$3A,$C0
	.byte	$3A,$80
	.byte	$AA,$B0
	.byte	$3A,$B0
	.byte	$0A,$80
	.byte	$00,$64		;SHIPE
	.byte	$03,$42
	.byte	$02,$50
	.byte	$00,$10
	.byte	$00,$80
	.byte	$00,$00
	.byte	$3A,$A8		;UFOL
	.byte	$2F,$A8
	.byte	$2A,$F8
	.byte	$2A,$BC
	.byte	$00		;UFOS
	.byte	$00
	.byte	$00
	.byte	$00
	.byte	$3C		;ROCK1S
	.byte	$3C
	.byte	$3C
	.byte	$3C
	.byte	$3C		;ROCK2S
	.byte	$3C
	.byte	$3C
	.byte	$3C
	.byte	$3C		;ROCK3S
	.byte	$3C
	.byte	$3C
	.byte	$3C
	.byte	$00		;ROCKES
	.byte	$08
	.byte	$08
	.byte	$08
	.byte	$08
	.byte	$00		;SHOT
	.byte	$00

	ORG     GRAPHICS+$B00	;12
********************************************************************************
	.byte	$3E,$55,$40	;ROCK1L
	.byte	$3E,$95,$40
	.byte	$3D,$65,$40
	.byte	$3E,$95,$C0
	.byte	$3E,$57,$C0
	.byte	$3E,$57,$40
	.byte	$3E,$D5,$40
	.byte	$3D,$A5,$40
	.byte	$3E,$95,$40
	.byte	$3E,$65,$40
	.byte	$3E,$55,$40
	.byte	$3E,$95,$40
	.byte	$3E,$65,$40	;ROCK2L
	.byte	$3E,$57,$C0
	.byte	$3E,$97,$C0
	.byte	$3E,$D5,$C0
	.byte	$3E,$B5,$40
	.byte	$3E,$55,$C0
	.byte	$3E,$95,$40
	.byte	$3D,$55,$40
	.byte	$3D,$5D,$40
	.byte	$3E,$75,$40
	.byte	$3A,$5F,$C0
	.byte	$3E,$55,$C0
	.byte	$3A,$95,$40	;ROCK3L
	.byte	$3E,$55,$40
	.byte	$3E,$56,$40
	.byte	$2E,$55,$40
	.byte	$3A,$55,$D0
	.byte	$3A,$55,$40
	.byte	$3A,$55,$C0
	.byte	$3A,$55,$C0
	.byte	$3A,$5B,$40
	.byte	$3A,$55,$40
	.byte	$3E,$55,$80
	.byte	$3E,$55,$40
	.byte	$00,$08,$00	;ROCKEL
	.byte	$08,$08,$00
	.byte	$04,$04,$04
	.byte	$06,$00,$42
	.byte	$10,$08,$00
	.byte	$FB,$55		;ROCK1M
	.byte	$3A,$D5
	.byte	$39,$75
	.byte	$3E,$5D
	.byte	$EA,$54
	.byte	$F9,$54
	.byte	$FA,$54
	.byte	$F9,$55
	.byte	$EB,$75		;ROCK2M
	.byte	$E9,$56
	.byte	$E5,$54
	.byte	$EA,$54
	.byte	$EF,$58
	.byte	$EB,$D4
	.byte	$E5,$74
	.byte	$EB,$D6
	.byte	$EB,$FE		;ROCK3M
	.byte	$E5,$FC
	.byte	$E5,$5D
	.byte	$ED,$56
	.byte	$EB,$56
	.byte	$E9,$56
	.byte	$E9,$56
	.byte	$ED,$D6
	.byte	$00,$80		;ROCKEM
	.byte	$06,$50
	.byte	$05,$4C
	.byte	$01,$43
	.byte	$81,$30
	.byte	$0E,$C0		;SHIP
	.byte	$02,$80
	.byte	$02,$A0
	.byte	$2A,$C0
	.byte	$2A,$00
	.byte	$4A,$80
	.byte	$0A,$C0
	.byte	$EA,$80
	.byte	$3A,$B0
	.byte	$0A,$AC
	.byte	$0E,$80
	.byte	$0A,$84
	.byte	$02,$A0
	.byte	$0E,$A0
	.byte	$2A,$00
	.byte	$0A,$00
	.byte	$06,$14		;SHIPE
	.byte	$05,$D0
	.byte	$24,$00
	.byte	$00,$80
	.byte	$00,$00
	.byte	$80,$00
	.byte	$AA,$AA		;UFOL
	.byte	$AA,$AA
	.byte	$AA,$AA
	.byte	$AA,$AA
	.byte	$38		;UFOS
	.byte	$3C
	.byte	$2C
	.byte	$28
	.byte	$38		;ROCK1S
	.byte	$3B
	.byte	$38
	.byte	$F8
	.byte	$3B		;ROCK2S
	.byte	$FB
	.byte	$FB
	.byte	$FB
	.byte	$FB		;ROCK3S
	.byte	$F7
	.byte	$FF
	.byte	$F7
	.byte	$08		;ROCKES
	.byte	$10
	.byte	$10
	.byte	$00
	.byte	$00
	.byte	$00		;SHOT
	.byte	$00

	ORG     GRAPHICS+$C00	;13
********************************************************************************
	.byte	$3E,$A5,$40	;ROCK1L
	.byte	$3E,$55,$40
	.byte	$3E,$55,$40
	.byte	$3E,$97,$40
	.byte	$3E,$5F,$40
	.byte	$3E,$5F,$40
	.byte	$3F,$55,$40
	.byte	$3F,$95,$40
	.byte	$3E,$65,$40
	.byte	$3E,$55,$40
	.byte	$3E,$67,$40
	.byte	$3E,$55,$40
	.byte	$3E,$95,$00	;ROCK2L
	.byte	$3E,$55,$40
	.byte	$3E,$55,$C0
	.byte	$3F,$65,$C0
	.byte	$3E,$B9,$40
	.byte	$3E,$A7,$C0
	.byte	$3E,$95,$40
	.byte	$3E,$A5,$40
	.byte	$3E,$55,$40
	.byte	$3E,$97,$40
	.byte	$3E,$5D,$40
	.byte	$3E,$65,$C0
	.byte	$3E,$55,$80	;ROCK3L
	.byte	$3E,$56,$40
	.byte	$3E,$55,$40
	.byte	$3E,$55,$40
	.byte	$2E,$55,$40
	.byte	$3E,$55,$40
	.byte	$3E,$55,$C0
	.byte	$3E,$56,$C0
	.byte	$3E,$55,$40
	.byte	$3E,$55,$40
	.byte	$3E,$55,$80
	.byte	$3E,$95,$80
	.byte	$00,$08,$00	;ROCKEL
	.byte	$00,$08,$00
	.byte	$20,$04,$C0
	.byte	$00,$00,$00
	.byte	$00,$00,$20
	.byte	$3A,$96		;ROCK1M
	.byte	$39,$64
	.byte	$39,$54
	.byte	$3A,$54
	.byte	$39,$54
	.byte	$39,$54
	.byte	$39,$54
	.byte	$3A,$54
	.byte	$F5,$F6		;ROCK2M
	.byte	$F5,$DE
	.byte	$F5,$56
	.byte	$F9,$54
	.byte	$FD,$58
	.byte	$FB,$D4
	.byte	$F9,$F4
	.byte	$F9,$5E
	.byte	$F7,$FE		;ROCK3M
	.byte	$F9,$76
	.byte	$F9,$55
	.byte	$FF,$D6
	.byte	$F9,$56
	.byte	$F9,$56
	.byte	$FB,$56
	.byte	$FF,$F6
	.byte	$00,$00		;ROCKEM
	.byte	$01,$00
	.byte	$04,$50
	.byte	$09,$10
	.byte	$00,$00
	.byte	$02,$00		;SHIP
	.byte	$02,$80
	.byte	$00,$E0
	.byte	$00,$00
	.byte	$2C,$00
	.byte	$0A,$00
	.byte	$0E,$00
	.byte	$02,$80
	.byte	$2F,$E0
	.byte	$0A,$00
	.byte	$02,$C0
	.byte	$02,$80
	.byte	$00,$E0
	.byte	$00,$00
	.byte	$2C,$00
	.byte	$0A,$00
	.byte	$05,$10		;SHIPE
	.byte	$25,$04
	.byte	$1A,$22
	.byte	$28,$00
	.byte	$88,$20
	.byte	$20,$00
	.byte	$39,$54		;UFOL
	.byte	$39,$54
	.byte	$39,$54
	.byte	$39,$54
	.byte	$AA		;UFOS
	.byte	$AA
	.byte	$AA
	.byte	$AA
	.byte	$E5		;ROCK1S
	.byte	$35
	.byte	$F5
	.byte	$EC
	.byte	$E5		;ROCK2S
	.byte	$F5
	.byte	$DD
	.byte	$E5
	.byte	$D4		;ROCK3S
	.byte	$15
	.byte	$D6
	.byte	$D5
	.byte	$24		;ROCKES
	.byte	$B6
	.byte	$02
	.byte	$0C
	.byte	$0C
	.byte	$00		;SHOT
	.byte	$00

	ORG     GRAPHICS+$D00	;14
********************************************************************************
	.byte	$0E,$95,$00	;ROCK1L
	.byte	$0E,$A5,$00
	.byte	$0E,$65,$00
	.byte	$0E,$95,$00
	.byte	$0E,$9D,$00
	.byte	$0E,$BC,$00
	.byte	$0E,$BD,$00
	.byte	$0E,$96,$00
	.byte	$0E,$A5,$00
	.byte	$0E,$95,$00
	.byte	$0D,$97,$00
	.byte	$0E,$9D,$00
	.byte	$0E,$95,$00	;ROCK2L
	.byte	$0E,$95,$00
	.byte	$0E,$95,$00
	.byte	$0E,$55,$00
	.byte	$0F,$55,$00
	.byte	$0E,$A7,$00
	.byte	$0E,$95,$00
	.byte	$0E,$55,$00
	.byte	$0E,$55,$00
	.byte	$0E,$95,$00
	.byte	$0E,$95,$00
	.byte	$0E,$97,$00
	.byte	$0E,$F5,$00	;ROCK3L
	.byte	$0E,$E5,$00
	.byte	$0E,$F5,$00
	.byte	$0E,$F5,$00
	.byte	$0E,$F5,$00
	.byte	$0E,$F7,$00
	.byte	$0E,$F7,$00
	.byte	$0E,$F5,$00
	.byte	$0E,$F5,$00
	.byte	$0E,$F5,$00
	.byte	$0F,$F5,$00
	.byte	$0F,$F5,$00
	.byte	$00,$00,$00	;ROCKEL
	.byte	$00,$08,$00
	.byte	$00,$40,$00
	.byte	$08,$10,$00
	.byte	$00,$10,$00
	.byte	$39,$54	;ROCK1M
	.byte	$39,$54
	.byte	$0E,$54
	.byte	$3A,$94
	.byte	$3A,$50
	.byte	$3E,$90
	.byte	$3D,$60
	.byte	$3E,$58
	.byte	$39,$54	;ROCK2M
	.byte	$39,$7C
	.byte	$39,$74
	.byte	$39,$58
	.byte	$39,$58
	.byte	$3B,$58
	.byte	$39,$F8
	.byte	$39,$5C
	.byte	$39,$D4	;ROCK3M
	.byte	$39,$54
	.byte	$3F,$54
	.byte	$39,$54
	.byte	$39,$54
	.byte	$3E,$54
	.byte	$3F,$D8
	.byte	$3F,$F8
	.byte	$00,$00	;ROCKEM
	.byte	$00,$00
	.byte	$10,$80
	.byte	$04,$08
	.byte	$00,$00
	.byte	$02,$00	;SHIP
	.byte	$00,$80
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$08,$00
	.byte	$42,$00
	.byte	$03,$80
	.byte	$20,$20
	.byte	$0B,$00
	.byte	$02,$04
	.byte	$00,$80
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$08,$00
	.byte	$06,$00	;SHIPE
	.byte	$17,$00
	.byte	$9A,$00
	.byte	$A8,$20
	.byte	$E0,$00
	.byte	$00,$08
	.byte	$0E,$50	;UFOL
	.byte	$0E,$50
	.byte	$0E,$50
	.byte	$0E,$50
	.byte	$75		;UFOS
	.byte	$75
	.byte	$75
	.byte	$75
	.byte	$D5		;ROCK1S
	.byte	$F5
	.byte	$DD
	.byte	$E7
	.byte	$F5		;ROCK2S
	.byte	$D5
	.byte	$DD
	.byte	$D7
	.byte	$D4		;ROCK3S
	.byte	$D5
	.byte	$D5
	.byte	$DD
	.byte	$18		;ROCKES
	.byte	$04
	.byte	$88
	.byte	$02
	.byte	$02
	.byte	$00		;SHOT
	.byte	$00

	ORG     GRAPHICS+$E00	;15
********************************************************************************
	.byte	$0F,$A9,$00	;ROCK1L
	.byte	$0F,$95,$00
	.byte	$0F,$95,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$B5,$00
	.byte	$0F,$F5,$00
	.byte	$0F,$F5,$00
	.byte	$0F,$E9,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$AD,$00
	.byte	$0F,$A5,$00	;ROCK2L
	.byte	$0F,$A5,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$95,$00
	.byte	$0F,$A5,$00
	.byte	$0F,$FE,$00
	.byte	$0F,$E5,$00
	.byte	$0F,$E5,$00
	.byte	$0F,$D5,$00
	.byte	$0F,$D5,$00
	.byte	$0F,$D5,$00
	.byte	$0F,$D5,$00
	.byte	$0F,$96,$00	;ROCK3L
	.byte	$0F,$96,$00
	.byte	$0F,$96,$00
	.byte	$0F,$96,$00
	.byte	$0F,$96,$00
	.byte	$0F,$96,$00
	.byte	$0F,$E6,$00
	.byte	$0F,$D6,$00
	.byte	$0F,$D6,$00
	.byte	$0F,$D6,$00
	.byte	$0F,$96,$00
	.byte	$0F,$D6,$00
	.byte	$00,$00,$00	;ROCKEL
	.byte	$00,$00,$00
	.byte	$00,$08,$00
	.byte	$00,$04,$30
	.byte	$0C,$00,$00
	.byte	$0A,$50	;ROCK1M
	.byte	$0A,$50
	.byte	$0D,$50
	.byte	$0D,$50
	.byte	$0E,$50
	.byte	$0E,$50
	.byte	$0F,$50
	.byte	$0D,$50
	.byte	$3A,$5C	;ROCK2M
	.byte	$3A,$54
	.byte	$3A,$5C
	.byte	$3A,$6C
	.byte	$3A,$6C
	.byte	$39,$5C
	.byte	$3A,$E8
	.byte	$3A,$7C
	.byte	$3A,$58	;ROCK3M
	.byte	$3E,$58
	.byte	$3A,$58
	.byte	$3A,$58
	.byte	$0A,$58
	.byte	$0F,$5C
	.byte	$0F,$DB
	.byte	$3B,$58
	.byte	$00,$00	;ROCKEM
	.byte	$00,$00
	.byte	$00,$00
	.byte	$40,$80
	.byte	$20,$03
	.byte	$02,$00	;SHIP
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$02,$00
	.byte	$04,$80
	.byte	$01,$00
	.byte	$08,$40
	.byte	$02,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$00,$00
	.byte	$07,$00	;SHIPE
	.byte	$20,$00
	.byte	$00,$00
	.byte	$24,$80
	.byte	$28,$08
	.byte	$00,$00
	.byte	$02,$40	;UFOL
	.byte	$02,$40
	.byte	$02,$40
	.byte	$02,$40
	.byte	$3C		;UFOS
	.byte	$28
	.byte	$28
	.byte	$28
	.byte	$E6		;ROCK1S
	.byte	$E4
	.byte	$D6
	.byte	$E5
	.byte	$D6		;ROCK2S
	.byte	$DD
	.byte	$E5
	.byte	$E4
	.byte	$D5		;ROCK3S
	.byte	$15
	.byte	$35
	.byte	$DD
	.byte	$20		;ROCKES
	.byte	$1E
	.byte	$02
	.byte	$00
	.byte	$00
	.byte	$00		;SHOT
STAR2:
	.byte	$0C

	ORG     GRAPHICS+$F00	;16
********************************************************************************
ROCK1L1:
	.byte	$03,$F8,$00
ROCK1L2:
	.byte	$03,$E8,$00
ROCK1L3:
	.byte	$03,$E8,$00
ROCK1L4:
	.byte	$03,$E8,$00
ROCK1L5:
	.byte	$03,$E8,$00
ROCK1L6:
	.byte	$03,$E8,$00
ROCK1L7:
	.byte	$03,$D8,$00
ROCK1L8:
	.byte	$03,$E8,$00
ROCK1L9:
	.byte	$03,$E8,$00
ROCK1L10:
	.byte	$03,$E8,$00
ROCK1L11:
	.byte	$03,$E8,$00
ROCK1L12:
	.byte	$03,$E8,$00
ROCK2L1:
	.byte	$03,$F8,$00
ROCK2L2:
	.byte	$03,$E8,$00
ROCK2L3:
	.byte	$03,$E8,$00
ROCK2L4:
	.byte	$03,$F8,$00
ROCK2L5:
	.byte	$03,$F8,$00
ROCK2L6:
	.byte	$03,$F8,$00
ROCK2L7:
	.byte	$03,$FC,$00
ROCK2L8:
	.byte	$03,$FC,$00
ROCK2L9:
	.byte	$03,$F8,$00
ROCK2L10:
	.byte	$03,$F8,$00
ROCK2L11:
	.byte	$03,$F8,$00
ROCK2L12:
	.byte	$03,$F8,$00
ROCK3L1:
	.byte	$00,$E0,$00
ROCK3L2:
	.byte	$00,$E0,$00
ROCK3L3:
	.byte	$00,$E0,$00
ROCK3L4:
	.byte	$00,$E0,$00
ROCK3L5:
	.byte	$00,$E0,$00
ROCK3L6:
	.byte	$00,$E0,$00
ROCK3L7:
	.byte	$00,$E0,$00
ROCK3L8:
	.byte	$00,$E0,$00
ROCK3L9:
	.byte	$00,$E0,$00
ROCK3L10:
	.byte	$00,$E0,$00
ROCK3L11:
	.byte	$00,$E0,$00
ROCK3L12:
	.byte	$00,$E0,$00
ROCKEL1:
	.byte	$00,$00,$00
ROCKEL2:
	.byte	$00,$00,$00
ROCKEL3:
	.byte	$00,$00,$00
ROCKEL4:
	.byte	$00,$04,$00
ROCKEL5:
	.byte	$00,$20,$00
ROCK1M1:
	.byte	$02,$80
ROCK1M2:
	.byte	$00,$80
ROCK1M3:
	.byte	$00,$80
ROCK1M4:
	.byte	$02,$80
ROCK1M5:
	.byte	$00,$80
ROCK1M6:
	.byte	$02,$00
ROCK1M7:
	.byte	$02,$80
ROCK1M8:
	.byte	$03,$40
ROCK2M1:
	.byte	$0E,$B0
ROCK2M2:
	.byte	$0E,$A0
ROCK2M3:
	.byte	$0D,$A0
ROCK2M4:
	.byte	$0E,$A0
ROCK2M5:
	.byte	$0E,$A0
ROCK2M6:
	.byte	$0E,$A0
ROCK2M7:
	.byte	$0E,$A0
ROCK2M8:
	.byte	$0E,$B0
ROCK3M1:
	.byte	$0E,$A0
ROCK3M2:
	.byte	$0E,$A0
ROCK3M3:
	.byte	$0E,$A0
ROCK3M4:
	.byte	$0E,$A0
ROCK3M5:
	.byte	$02,$A0
ROCK3M6:
	.byte	$00,$A0
ROCK3M7:
	.byte	$02,$A0
ROCK3M8:
	.byte	$0E,$A0
ROCKEM1:
	.byte	$00,$00
ROCKEM2:
	.byte	$00,$00
ROCKEM3:
	.byte	$00,$00
ROCKEM4:
	.byte	$00,$00
ROCKEM5:
	.byte	$42,$00
SHIP1:
	.byte	$00,$00
SHIP2:
	.byte	$00,$00
SHIP3:
	.byte	$00,$00
SHIP4:
	.byte	$00,$00
SHIP5:
	.byte	$00,$00
SHIP6:
	.byte	$00,$00
SHIP7:
	.byte	$00,$00
SHIP8:
	.byte	$04,$00
SHIP9:
	.byte	$01,$00
SHIP10:
	.byte	$00,$40
SHIP11:
	.byte	$00,$00
SHIP12:
	.byte	$00,$00
SHIP13:
	.byte	$00,$00
SHIP14:
	.byte	$00,$00
SHIP15:
	.byte	$00,$00
SHIP16:
	.byte	$00,$00
SHIPE1:
	.byte	$04,$00
SHIPE2:
	.byte	$00,$00
SHIPE3:
	.byte	$00,$00
SHIPE4:
	.byte	$00,$00
SHIPE5:
	.byte	$00,$20
SHIPE6:
	.byte	$20,$00
UFOL1:
	.byte	$02,$40
UFOL2:
	.byte	$02,$40
UFOL3:
	.byte	$02,$40
UFOL4:
	.byte	$02,$40
UFOS1:
	.byte	$34
UFOS2:
	.byte	$34
UFOS3:
	.byte	$34
UFOS4:
	.byte	$34
ROCK1S1:
	.byte	$34
ROCK1S2:
	.byte	$34
ROCK1S3:
	.byte	$34
ROCK1S4:
	.byte	$34
ROCK2S1:
	.byte	$34
ROCK2S2:
	.byte	$38
ROCK2S3:
	.byte	$34
ROCK2S4:
	.byte	$38
ROCK3S1:
	.byte	$34
ROCK3S2:
	.byte	$04
ROCK3S3:
	.byte	$04
ROCK3S4:
	.byte	$34
ROCKES1:
	.byte	$00
ROCKES2:
	.byte	$20
ROCKES3:
	.byte	$20
ROCKES4:
	.byte	$20
ROCKES5:
	.byte	$20
SHOT1:
	.byte	$40
	.byte	$00

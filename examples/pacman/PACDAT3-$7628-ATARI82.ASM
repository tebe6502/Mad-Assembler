;	@com.wudsn.ide.asm.mainsourcefile=PACMAN.ASM

	.BY $00,$00
	
	STA $0614
	JSR $BC41
	LDA #$01
	STA $BF
	JSR $BC58
	LDA $C4
	STA $0600
	LDA PORTA
	CMP #$F7
	BEQ $7657
	CMP #$F6
	BNE $764B
	LDA #$00
	BEQ $764D
	LDA #$01
	STA $BF
	JSR $BC7C
	LDA $C3
	STA $0608
	RTS
	LDX #$00
	LDA #$00
	STA $0600,X
	INX
	CPX #$47
	BNE $765C
	LDX #$00
	LDA #$00
	STA HPOSP0,X
	INX
	CPX #$0C
	BNE $7668
	LDA #$00
	TAX
ILOOP	STA $0B00,X
	STA $0C00,X
	STA $0D00,X
	STA $0E00,X
	STA $0F00,X
	INX
	BNE ILOOP
	LDA #$08
	STA $2F0
	STA PMBASE
	LDA #$00
	STA HITCLR
	STA $C5
	LDA #$01
	STA $0620
	STA $0621
	STA $0622
	LDA #$00
	STA COLOR2
	STA $0619
	STA $00,X
	
	.byte $00,$00,$40,$40,$40,$40,$C0,$57,$7D,$D5,$75,$D5,$D5,$71,$C0
	.byte $40,$40,$40,$40,$40,$40,$40,$40,$54,$95,$A5,$A5,$A9,$A5,$A5,$95
	.byte $00,$00,$00,$40,$40,$40,$40,$C0,$57,$5F,$75,$D5,$75,$D5,$35,$04
	.byte $40,$40,$40,$40,$40,$40
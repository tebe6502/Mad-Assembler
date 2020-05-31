
RTCLOK = $12
SKCTL = $d20f
AUDCTL = $d208
AUDF1 = $d200
AUDC1 = $d201
AUDF2 = $d202
AUDC2 = $d203
AUDF3 = $d204
AUDC3 = $d205
AUDF4 = $d206
AUDC4 = $d207

	ORG $600

start	LDX #$00
	STX SKCTL	; why turn of keyboard debounce here...
	STX AUDCTL
	LDA #$01	; when turning it on just two lines later again?
	STA SKCTL
nextnote JSR loadnote	; loads X-indexed notes in Y and stores them
	STY AUDF1	; to POKEY's frequence registers
	JSR loadnote
	STY AUDF2
	JSR loadnote
	STY AUDF3
	JSR loadnote
	LDA #$00	; reset the clock
	STA RTCLOK+2
	ORA #$CA	; LDA #$CA should work the same way, shouldn't it?
	STA AUDC4	; because it basically always stores $CA in AUDC4, doesn't it?
	STY AUDF4	; Y still set by loadnote routine
incvol	LDA RTCLOK+2	; starts from zero
	BMI nextnote	; count until 128
	LSR		; makes sure that high nibble is always zero
	LSR		; and low nibble changes only every 8 increments of RTCLOK
	LSR		; resulting in a volume change every 8/50 seconds (PAL)
	EOR #$A3	; sets distortion nibble to $A, counts lowest two bits (0-1) from 3 down to 0 for four times (bits 2-3), thereby decreasing the volume in each cycle while increasing the base volume with each cycle
	STA AUDC1	; set distortions
	STA AUDC2
	STA AUDC3
	BNE incvol	; next cycle

loadnote LDY data,X
	BEQ start
	INX
	RTS

data	.byte $79,$5B,$A2,$C5
	.byte $79,$60,$A2,$C5
	.byte $80,$6C,$A2,$83
	.byte $88,$6C,$B6,$DA
	.byte $90,$79,$B6,$92
	.byte $79,$60,$51,$C5
	.byte $80,$6C,$51,$83
	.byte $44,$6C,$B6,$DA
	.byte $48,$79,$B6,$92
	.byte $90,$6C,$5B,$B0
	.byte $88,$6C,$5B,$DA
	.byte $79,$60,$A2,$C5
	.byte $90,$72,$60,$E6
	.byte $90,$6C,$51,$B0
	.byte $90,$6C,$5B,$B0
	.byte $A2,$6C,$5B,$B9

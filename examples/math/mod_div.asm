; mod and div implemented in 6502 asm
; https://gist.github.com/hausdorff/5993556

	; load some data up

	LDA #$7
	STA $00    ; memory addr A
	LDA #$05
	STA $01    ; memory addr B
	JMP Divide
 
	;modulus, returns in register A

Mod:
		LDA $00		; memory addr A
		SEC
Modulus:	SBC $01		; memory addr B
		BCS Modulus
		ADC $01

		RTS
 
	;division, rounds up, returns in reg A

Division:
		LDA $00
		LDX #0
		SEC
Divide:		INX
		SBC $01
		BCS Divide
		TXA		;get result into accumulator 

		RTS
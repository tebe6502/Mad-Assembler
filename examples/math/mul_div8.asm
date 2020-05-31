
/*

 8 bit multiply and divide routines.
 Three 8 bit locations
 ACC, AUX and EXT must be set up,
 preferably on zero page.

 MULTIPLY ROUTINE

 ACC*AUX -> ACC,EXT (low,hi) 16 bit result

*/

acc	equ $80
aux	equ acc+1
ext	equ aux+1

.proc mul8 (.byte acc,aux) .var	; ~185 cycle

	LDA #0
	LDY #$09
	CLC
LOOP	ROR @
	ROR ACC
	BCC MUL2
	CLC		;DEC AUX above to remove CLC
	ADC AUX
MUL2	DEY
	BNE LOOP
	STA EXT

	RTS
.endp


.proc mul8_ (.byte acc,aux) .var	; ~175 cycle

	LDA #$00
	LDY #$08
	CLC
LOOP	ROR ACC
	BCC MUL2
	CLC
	ADC AUX
MUL2	ROR @
	DEY
	BNE LOOP
	ROR ACC
	STA EXT

	rts
.endp


/*

 DIVIDE ROUTINE

 ACC/AUX -> ACC, remainder in EXT

*/

.proc div8 (.byte acc,aux) .var

	LDA #0
	LDY #$08
LOOP	ASL ACC
	ROL @
	CMP AUX
	BCC DIV2
	SBC AUX
	INC ACC
DIV2
	DEY
	BNE LOOP
	STA EXT
	RTS

.endp

/*

 16 bit multiply and divide routines.
 Three 16 bit (two-byte) locations
 ACC, AUX and EXT must be set up,
 preferably on zero page.

 MULTIPLY ROUTINE

 ACC*AUX -> [ACC,EXT] (low,hi) 32 bit result

*/

acc	equ $80
aux	equ acc+2
ext	equ aux+2

.proc mul16 (.word acc,aux) .var

	LDA #0
	STA EXT+1
	LDY #$11
	CLC
LOOP	ROR EXT+1
	ROR @
	ROR ACC+1
	ROR ACC
	BCC MUL2
	CLC
	ADC AUX
	PHA
	LDA AUX+1
	ADC EXT+1
	STA EXT+1
	PLA
MUL2	DEY
	BNE LOOP
	STA EXT
	RTS

.endp


/*

 DIVIDE ROUTINE

 ACC/AUX -> ACC, remainder in EXT

*/

.proc div16 (.word acc,aux) .var

	LDA #0
	STA EXT+1
	LDY #$10
LOOP	ASL ACC
	ROL ACC+1
	ROL @
	ROL EXT+1
	PHA
	CMP AUX
	LDA EXT+1
	SBC AUX+1
	BCC DIV2
	STA EXT+1
	PLA
	SBC AUX
	PHA
	INC ACC
DIV2	PLA
	DEY
	BNE LOOP
	STA EXT
	RTS

.endp

	run test
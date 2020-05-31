
; ----------------------------- ZP RAM Variables ------------------------------

N	= $80	; 7 bytes of ZP for input, output, and scratchpad
CARRY	= N+7	; 1 byte  of ZP for 17th bit (Could be called N+7)

/*

 N & N+1 could be called "DIVISOR" (and DIVISOR+1).  Since the answer ends up
 in the same bytes that originally held the 32-bit dividend, it becomes a
 little harder to come up with good variable names for other bytes of N unless
 you have more than one name for the same locations and remember that they are
 indeed the same locations.

 This was originally for my 65C02 Forth kernel, where the input and output is
 through the data stack, which is in ZP and indexed by X.  This shows how you'd
 do the actual division if you moved it to the Forth ZP scratchpad area for
 primitives (ie, code definitions).  This area is often simply called N.  In
 Forth, we don't normally move all this to and from this area for division,
 because the time needed to move it is greater than the time saved by not
 having to index by X; but the division process itself takes a little less
 explaining this way, and you don't need to know anything about Forth to use
 this routine.  Refer to the diagrams above for what is in N to N+6.

*/

; ----------------------------------- CODE ------------------------------------

	org $2000

START	SEC		; Detect overflow or /0 condition.
	LDA	N+2	; Divisor must be more than high cell of dividend.  To
	SBC	N	; find out, subtract divisor from high cell of dividend;
	LDA	N+3	; if carry flag is still set at the end, the divisor was
	SBC	N+1	; not big enough to avoid overflow. This also takes care
	BCS	oflo	; of any /0 condition.  Branch if overflow or /0 error.
			; We will loop 16 times; but since we shift the dividend
	LDX	#$11	; over at the same time as shifting the answer in, the
			; operation must start AND finish with a shift of the
			; low cell of the dividend (which ends up holding the
			; quotient), so we start with 17 (11H) in X.
loop	ROL	N+4	; Move low cell of dividend left one bit, also shifting
        ROL	N+5	; answer in. The 1st rotation brings in a 0, which later
			; gets pushed off the other end in the last rotation.
	DEX
	BEQ	_end	; Branch to the end if finished.

	ROL	N+2     ; Shift high cell of dividend left one bit, also
	ROL	N+3     ; shifting next bit in from high bit of low cell.

;	STZ	CARRY   ; Zero old bits of CARRY so subtraction works right.
	mvy #0 carry

	ROL	CARRY   ; Store old high bit of dividend in CARRY.  (For STZ
                        ; one line up, NMOS 6502 will need LDA #0, STA CARRY.)
	SEC		; See if divisor will fit into high 17 bits of dividend
	LDA	N+2	; by subtracting and then looking at carry flag.
	SBC	N	; First do low byte.
	STA	N+6	; Save difference low byte until we know if we need it.
	LDA	N+3
	SBC	N+1	; Then do high byte.
	TAY		; Save difference high byte until we know if we need it.
	LDA	CARRY	; Bit 0 of CARRY serves as 17th bit.
	SBC	#0	; Complete the subtraction by doing the 17th bit before
	BCC	loop	; determining if the divisor fit into the high 17 bits
			; of the dividend.  If so, the carry flag remains set.
	LDA	N+6	; If divisor fit into dividend high 17 bits, update
	STA	N+2	; dividend high cell to what it would be after
	STY	N+3	; subtraction.
	BCS	loop	; Always branch.  NMOS 6502 could use BCS here

oflo	LDA     #$FF	; If overflow occurred, put FF
	STA	N+2	; in remainder low byte
	STA	N+3	; and high byte,
	STA	N+4	; and in quotient low byte
	STA	N+5	; and high byte.

_end	RTS


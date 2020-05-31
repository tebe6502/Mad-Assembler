
/*        
; Example1: Computing the CRC-8 of 256 bytes of data in $1000-$10FF. 

	JSR crc8.MAKECRCTABLE
	LDY #0
	TYA			; Initialize CRC
LOOP	EOR $1000,Y		; EOR old CRC with data
	TAX			; and index into table
	LDA crc8.CRCTBL,X	; to get the new CRC
	INY
	BNE LOOP

	jmp *			; Accumulator contains the CRC-8


; Example2:

	jsr crc8.MAKECRCTABLE
	lda #0
	sta crc8.crc
        
	lda #'J'
	jsr crc8.updCRC
	lda #'C'
	jsr crc8.updCRC
	lda #'L'
	jsr crc8.updCRC

	jmp *
*/


.proc crc8

CRC	EQU $80		; 1 byte in ZP (unneeded if you inline)
CRCTBL	EQU $8000	; One 256-byte table for quick lookup


MAKECRCTABLE
	LDX #0
LOOP	TXA		; A contains the CRC-8
	LDY #8
BITLOOP	ASL @		; Shift CRC left
	BCC NOADD	; If no overflow, do nothing
	EOR #$07	; else add CRC-8 polynomial $07
NOADD	DEY
	BNE BITLOOP	; Do next bit
	STA CRCTBL,X	; All bits done, store in table
	INX
	BNE LOOP	; Do next byte
	RTS

UPDCRC	EOR CRC		; You really should inline this,
	TAX		; in which case you don't even need
	LDA CRCTBL,X	; the CRC zero page location. See
	STA CRC		; example below.
	RTS
.endp

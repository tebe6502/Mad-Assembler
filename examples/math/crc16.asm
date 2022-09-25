
/*
; Example1: Computing the CRC-16 of 256 bytes of data in $1000-$10FF. 

	JSR crc16.MAKECRCTABLE
	LDY #$FF
	STY crc16.CRC
	STY crc16.CRC+1
	INY
LOOP	LDA $1000,Y
	JSR crc16.UPDCRC
	INY
	BNE LOOP

	jmp *


; Example 2:

	jsr crc16.MAKECRCTABLE
	mwa #$ffff crc16.CRC

	lda #'B'
	jsr crc16.updCRC
	lda #'N'
	jsr crc16.updCRC
	lda #'E'
	jsr crc16.updCRC

	jmp *

*/


.proc crc16

CRC	EQU $80		; 2 bytes in ZP
CRCLO	EQU $8000	; Two 256-byte tables for quick lookup
CRCHI	EQU $8100	; (should be page-aligned for speed)      

MAKECRCTABLE
	LDX #0		; X counts from 0 to 255
LOOP	LDA #0		; A contains the low 8 bits of the CRC-16
	STX CRC		; and CRC contains the high 8 bits
	LDY #8		; Y counts bits in a byte
BITLOOP	ASL @
	ROL CRC		; Shift CRC left
	BCC NOADD	; Do nothing if no overflow
	EOR #$21	; else add CRC-16 polynomial $1021
	PHA		; Save low byte
	LDA CRC		; Do high byte
	EOR #$10
	STA CRC
	PLA		; Restore low byte
NOADD	DEY
	BNE BITLOOP	; Do next bit
	STA CRCLO,X	; Save CRC into table, low byte
	LDA CRC		; then high byte
	STA CRCHI,X
	INX
	BNE LOOP	; Do next byte
	RTS

UPDCRC	EOR CRC+1	; Quick CRC computation with lookup tables
	TAX
	LDA CRC
	EOR CRCHI,X
	STA CRC+1
	LDA CRCLO,X
	STA CRC
	RTS
.endp

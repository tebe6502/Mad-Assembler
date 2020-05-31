/*
	org $2000

	mwa #$ffff crc16.crc

        lda #'B'
        jsr crc16.updCRC
        lda #'N'
        jsr crc16.updCRC
        lda #'E'
        jsr crc16.updCRC

	jmp *
*/


.proc crc16

crc	equ $80

updCRC
	EOR CRC+1	; A contained the data
	STA CRC+1	; XOR it into high byte
	LSR @		; right shift A 4 bits
	LSR @		; to make top of x^12 term
	LSR @		; ($1...)
	LSR @
	TAX		; save it
	ASL @		; then make top of x^5 term
	EOR CRC		; and XOR that with low byte
	STA CRC		; and save
	TXA		; restore partial term
	EOR CRC+1	; and update high byte
	STA CRC+1	; and save
	ASL @		; left shift three
	ASL @		; the rest of the terms
	ASL @		; have feedback from x^12
	TAX		; save bottom of x^12
	ASL @		; left shift two more
	ASL @		; watch the carry flag
	EOR CRC+1	; bottom of x^5 ($..2.)
	TAY		; save high byte
	TXA		; fetch temp value
	ROL @		; bottom of x^12, middle of x^5!
	EOR CRC		; finally update low byte
	STA CRC+1	; then swap high and low bytes
	STY CRC
	RTS
.endp
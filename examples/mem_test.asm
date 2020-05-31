
; memTest v1.0 03.08.2007

@TAB_MEM_BANKS	= $600

CRCT0	EQU $8000	; Four 256-byte tables
CRCT1	EQU $8100	; (should be page-aligned for speed)
CRCT2	EQU $8200
CRCT3	EQU $8300


	org $80

crc	.ds 4
crc_old	.ds 4


	org $2000
main
	JSR CRC32.MAKECRCTABLE

	ldy #0
	tya
	sta:rne @TAB_MEM_BANKS,y+

	@MEM_DETECT

	sta ile

	jsr printf
	.by $9b
	.by 'BANKS: %' $9b 0
	.wo ile

	lda ile
	sne:rts

	.var ile .word idx err .byte

	ldy #0
	sty idx

loop	ldy idx
	lda @TAB_MEM_BANKS+1,y

	@HEX @

	stx hex
	sta hex+1

	lda idx
	and #7
	bne skp

	jsr printf
	.by $9b 0
skp
	jsr printf
hex	.by 'ff ',0

	inc idx
	lda idx
	cmp ile
	bne loop

* ---------------------------------------------
* -	TEST #1
* ---------------------------------------------

test1	.local

	jsr printf
	.by $9b $9b
	.by 'PASS 1' $9b 0

	mva #0 idx
	sta err

loop	ldy idx
	lda @TAB_MEM_BANKS+1,y

	sta $d301


	@HEX @
	stx hex
	sta hex+1

	jsr printf
hex	.by 'ff ' 0

	LDA #$FF
	STA CRC
	STA CRC+1
	STA CRC+2
	STA CRC+3

	mva >$4000 a0+2

	ldx #64
	ldy #0
fil	tya
a0	sta $4000,y

	jsr CRC32.UPDCRC
	iny
	bne fil
	inc a0+2
	dex
	bne fil

	LDY #3
COMPL	LDA CRC,Y
	EOR #$FF
	STA CRC_OLD,Y
	DEY
	BPL COMPL
*---
	LDA #$FF
	STA CRC
	STA CRC+1
	STA CRC+2
	STA CRC+3

	mva >$4000 a1+2

	ldx #64
	ldy #0
a1	lda $4000,y

	jsr CRC32.UPDCRC
	iny
	bne a1
	inc a1+2
	dex
	bne a1

	LDY #3
COMPL1	LDA CRC,Y
	EOR #$FF

	cmp CRC_OLD,Y
	bne false
	
	DEY
	BPL COMPL1

	jmp true

false	jsr printf
	.by 'ERROR' $9b 0

	inc err

	jmp nxt
*---

true	jsr printf
	.by 'OK' $9b 0

nxt	inc idx
	lda idx
	cmp ile
	jne loop

	lda err
	seq
	rts

	.end


* ---------------------------------------------
* -	TEST #2
* ---------------------------------------------

test2	.local

	jsr printf
	.by $9b
	.by 'PASS 2' $9b 0

	mva #0 idx
	sta err

loop	ldy idx
	lda @TAB_MEM_BANKS+1,y

	sta $d301


	@HEX @
	stx hex
	sta hex+1

	jsr printf
hex	.by 'ff ' 0

	LDA #$FF
	STA CRC
	STA CRC+1
	STA CRC+2
	STA CRC+3

	mva >$4000 a0+2
	sta b0+2
	sta b1+2
	sta b2+2
	sta b3+2

	ldy #64
	ldx #0
fil	lda $d20a
a0	sta $4000,x

b0	asl $4000,x
b1	ror $4000,x
b2	inc $4000,x

b3	lda $4000,x

	jsr CRC32.UPDCRC

	inx
	bne fil

	inc a0+2

	inc b0+2
	inc b1+2
	inc b2+2
	inc b3+2

	dey
	bne fil

	LDY #3
COMPL	LDA CRC,Y
	EOR #$FF
	STA CRC_OLD,Y
	DEY
	BPL COMPL

;	inc $7fff
*---
	LDA #$FF
	STA CRC
	STA CRC+1
	STA CRC+2
	STA CRC+3

	mva >$4000 a1+2

	ldx #64
	ldy #0
a1	lda $4000,y

	jsr CRC32.UPDCRC
	iny
	bne a1
	inc a1+2
	dex
	bne a1

	LDY #3
COMPL1	LDA CRC,Y
	EOR #$FF

	cmp CRC_OLD,Y
	bne false
	
	DEY
	BPL COMPL1

	jmp true

false	jsr printf
	.by 'ERROR' $9b 0

	inc err

	jmp nxt
*---

true	jsr printf
	.by 'OK' $9b 0

nxt	inc idx
	lda idx
	cmp ile
	jne loop

	lda err
	seq
	rts

	.end



* ---------------------------------------------
* -	TEST #3
* ---------------------------------------------

test3	.local

	jsr printf
	.by $9b
	.by 'PASS 3' $9b 0

	mva #0 idx

loop	ldy idx
	lda @TAB_MEM_BANKS+1,y

	sta $d301


	@HEX @
	stx hex
	sta hex+1

	jsr printf
hex	.by 'ff ' 0

	lda >$4000
	sta b0+2
	sta b1+2

	ldy #64
	ldx #0
fil	lda $d20a
	sta test

b0	sta $4000,x
b1	lda $4000,x
	cmp #0
test	equ *-1
	bne false

	inx
	bne fil

	inc b0+2
	inc b1+2

	dey
	bne fil

true	jsr printf
	.by 'OK' $9b 0

	jmp nxt
*---
false	jsr printf
	.by 'ERROR' $9b 0

*---
nxt	inc idx
	lda idx
	cmp ile
	jne loop

	.end

	rts

*---
*---

@HEX	.proc (.byte a) .reg
	pha

	:4 lsr @
	jsr hex
	tax

	pla		; zdejmujemy ze stosu zapamietana wczesniej zawartosc akumulatora
	and #$0f
hex
	SED
	CMP #$0A
	ADC #'0'
	CLD

	rts
	.endp


/*
;Example: Computing the CRC-32 of 256 bytes of data in $1000-$10FF. 

	org $2000

	JSR CRC32.MAKECRCTABLE

	LDY #$FF
	STY CRC32.CRC
	STY CRC32.CRC+1
	STY CRC32.CRC+2
	STY CRC32.CRC+3
	INY
LOOP	LDA $1000,Y
	JSR CRC32.UPDCRC
	INY
	BNE LOOP
	LDY #3
COMPL	LDA CRC32.CRC,Y
	EOR #$FF
	STA CRC32.CRC,Y
	DEY
	BPL COMPL

	JMP *
*/


.proc CRC32

MAKECRCTABLE
	LDX #0		; X counts from 0 to 255
LOOP	LDA #0		; A contains the high byte of the CRC-32
	STA CRC+2	; The other three bytes are in memory
	STA CRC+1
	STX CRC
	LDY #8		; Y counts bits in a byte
BITLOOP	LSR @		; The CRC-32 algorithm is similar to CRC-16
	ROR CRC+2	; except that it is reversed (originally for
	ROR CRC+1	; hardware reasons). This is why we shift
	ROR CRC		; right instead of left here.
	BCC NOADD	; Do nothing if no overflow
	EOR #$ED	; else add CRC-32 polynomial $EDB88320
	PHA		; Save high byte while we do others
	LDA CRC+2
	EOR #$B8	; Most reference books give the CRC-32 poly
	STA CRC+2	; as $04C11DB7. This is actually the same if
	LDA CRC+1	; you write it in binary and read it right-
	EOR #$83	; to-left instead of left-to-right. Doing it
	STA CRC+1	; this way means we won't have to explicitly
	LDA CRC		; reverse things afterwards.
	EOR #$20
	STA CRC
	PLA		; Restore high byte
NOADD	DEY
	BNE BITLOOP	; Do next bit
	STA CRCT3,X	; Save CRC into table, high to low bytes
	LDA CRC+2
	STA CRCT2,X
	LDA CRC+1
	STA CRCT1,X
	LDA CRC
	STA CRCT0,X
	INX
	BNE LOOP	; Do next byte
	RTS

UPDCRC	stx oldX+1

	EOR CRC		; Quick CRC computation with lookup tables
	TAX
	LDA CRC+1
	EOR CRCT0,X
	STA CRC
	LDA CRC+2
	EOR CRCT1,X
	STA CRC+1
	LDA CRC+3
	EOR CRCT2,X
	STA CRC+2
	LDA CRCT3,X
	STA CRC+3

oldX	ldx #0
	RTS
.endp

* ---
	icl 'proc\@mem_detect.asm'

	.link 'stdio\printf.obx'

	.print 'end: ',*

	run main

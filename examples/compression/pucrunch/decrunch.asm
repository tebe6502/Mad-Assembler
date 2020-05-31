; SHORT+IRQLOAD 	354 bytes
; no rle =~		-83 bytes -> 271
; fixed params =~	-48 bytes -> 306
;			223 bytes

SHORT		= 0		;1 assume file is ok
IRQLOAD		= 0		;1

LZPOS		EQU $fe		; 2 ZeroPage temporaries
bitstr		EQU $fd		; 1 temporary (does not need to be ZP)


			ORG $2000

			ldx >packed+$02		; skip 2 first bytes
			ldy <packed+$02
			jsr __decruncher

			MVA #$0f 710		; it's done!
			jmp *

__decruncher	EQU *
	; Call with X = HI of packed data, Y = LO of packed data
	; Returns exec address in X = HI and Y = LO
	; Carry will be set for error, cleared for OK
;#if SHORT == 0
;	sei
;	lda #$35
;	sta 1
;#endif
;#if IRQLOAD
;	jsr initloader
;#else
; Setup read pointer
				sty INPOS+1
				stx INPOS+2
;#endif

;#if SHORT
;	ldx #5
;222$	jsr getbyt	; skip 'p', 'u', endAddr HI&LO, leave starting escape in A
;	dex
;	bne 222$
;#else
				jsr __getByt	; 'p'
				cmp #112
				beq __decruncherJ1
				sec				; error
				jmp eof2
__decruncherJ1	EQU *
				jsr __getByt	; 'u'
				cmp #117
				beq __decruncherJ2
				sec				; error
				jmp eof2
__decruncherJ2	EQU *
				jsr __getByt	; skip endAddr
				jsr __getByt
				jsr __getByt
;#endif
				sta esc+1		; starting escape

				jsr __getByt	; read startAddr
				sta OUTPOS+1
				jsr __getByt
				sta OUTPOS+2
				jsr __getByt	; read # of escape bits
				sta escB0+1
				sta escB1+1
				lda #8
				sec
				sbc escB1+1
				sta noesc+1		; 8-escBits

				jsr __getByt
				sta mg+1		; maxGamma + 1
				lda #9
				sec
				sbc mg+1		; 8 - maxGamma == (8 + 1) - (maxGamma + 1)
				sta longrle+1
				jsr __getByt
				sta mg1+1		; (1<<maxGamma)
				asl @
				clc
				sbc #0
				sta mg21+1		; (2<<maxGamma) - 1
				jsr __getByt
				sta elzpb+1

				jsr __getByt	; skip exec address defined by cruncher hi & lo
;				sta lo+1		; lo
				jsr __getByt
;				sta hi+1		; hi

				jsr __getByt	; rleUsed
				ldx #0
				tay
__decruncherJ3	EQU *
				beq __decruncherJ4		; Y == 0 ?
				jsr __getByt
				sta table,x
				inx
				dey
				bne __decruncherJ3
__decruncherJ4	EQU *	; setup bit store - $80 means empty
				lda #$80
				sta bitstr
				jmp main

__getByt		EQU *
				jsr __getNew
				;sta COLPF2
				lda bitstr
				ror @
				rts

newesc			ldy esc+1	; remember the old code (top bits for escaped byte)
escB0			ldx #2		; ** PARAMETER	0..8
				jsr getchkf	; get & save the new escape code
				sta esc+1
				tya			; pre-set the bits
; Fall through and get the rest of the bits.
noesc			ldx #6		; ** PARAMETER	8..0
				jsr getchkf
				jsr __putCh	; output the escaped/normal byte
; Fall through and check the escape bits again
main			ldy #0		; Reset to a defined state
				tya			; A = 0
escB1			ldx #2		; ** PARAMETER	0..8
				jsr getchkf	; X = 0
esc				cmp #0
				bne noesc
; Fall through to packed code

				jsr __getVal	; X = 0
				sta LZPOS	; xstore - save the length for a later time
				lsr	@		; cmp #1	; LEN == 2 ? (A is never 0)
				bne lz77	; LEN != 2	-> LZ77
;tya		; A = 0
				jsr get1bit	; X = 0
				lsr	@	; bit -> C, A = 0
				bcc lz77_2	; A=0 -> LZPOS+1
;***FALL THRU***
; e..e01
				jsr get1bit	; X = 0
				lsr @	; bit -> C, A = 0
				bcc newesc	; e..e010
;***FALL THRU***
; e..e011
srle			iny		; Y is 1 bigger than MSB loops
				jsr __getVal	; Y is 1, get len, X = 0
				sta LZPOS	; xstore - Save length LSB
mg1				cmp #64		; ** PARAMETER 63-64 -> C clear, 64-64 -> C set..
				bcc __chrCode	; short RLE, get bytecode
				
longrle			ldx #2		; ** PARAMETER	111111xxxxxx
				jsr getbits	; get 3/2/1 more bits to get a full byte, X = 0
				sta LZPOS	; xstore - Save length LSB

				jsr __getVal	; length MSB, X = 0
				tay		; Y is 1 bigger than MSB loops

__chrCode		EQU *
				jsr __getVal	; Byte Code, X = 0
				tax		; this is executed most of the time anyway
				lda table-1,x	; Saves one jump if done here (loses one txa)

				cpx #32		; 31-32 -> C clear, 32-32 -> C set..
				bcc __chrCodeJ1		; 1..31, we got the right byte from the table

; Ranks 32..64 (11111°xxxxx), get byte..
				txa		; get back the value (5 valid bits)
				ldx #3
				jsr getbits	; get 3 more bits to get a full byte, X = 0

__chrCodeJ1		EQU *
				ldx LZPOS	; xstore - get length LSB
				inx		; adjust for cpx#$ff;bne -> bne
dorle			jsr __putCh
				dex
				bne dorle	; xstore 0..255 -> 1..256
				dey
				bne dorle	; Y was 1 bigger than wanted originally
mainbeq			beq main	; reverse condition -> jump always
				
lz77			jsr __getVal	; X = 0
mg21			cmp #127	; ** PARAMETER	Clears carry (is maximum value)
				bne noeof
; EOF
;eof
;#if SHORT == 0
; EOF
eof				clc
eof2;			lda #$37
;				sta 1
;				cli
;#endif
;#if IRQLOAD
	;jsr endloader
;lo = .+1
;hi = .+2
;				jmp $aaaa
;#else
;hi				ldx #0
;lo				ldy #0
				rts
;#endif

noeof			sbc #0		; C is clear -> subtract 1  (1..126 -> 0..125)
elzpb			ldx #0		; ** PARAMETER (more bits to get)
				jsr getchkf	; clears Carry, X = 0

lz77_2			sta LZPOS+1	; offset MSB
				jsr __getByte	; clears Carry, X = 0
				; Note: Already eor:ed in the compressor..
				;eor #255	; offset LSB 2's complement -1 (i.e. -X = ~X+1)
				adc OUTPOS+1	; -offset -1 + curpos (C is clear)
				ldx LZPOS	; xstore = LZLEN (read before it's overwritten)
				sta LZPOS
				lda OUTPOS+1+1
				sbc LZPOS+1	; takes C into account
				sta LZPOS+1	; copy X+1 number of chars from LZPOS to OUTPOS
				;ldy #0		; Y was 0 originally, we don't change it
				inx			; adjust for cpx#$ff;bne -> bne
lzloop			lda (LZPOS),y	; using abs,y is 3 bytes longer, only 1 cycle/byte faster
				jsr __putCh	; Note: must be copied forwards!
				iny			; Y does not wrap because X=0..255 and Y initially 0
				dex
				bne lzloop	; X loops, (256,1..255)
				beq mainbeq	; jump through another beq (-1 byte, +3 cycles)

__getNew		EQU *
				pha			; 1 Byte/3 cycles
;#if IRQLOAD
; jsr READBYTE	; should not change X or Y, return byte in A
; An implementation would first check if any bytes are available
; and if not, transfer a block from drive.
;#else
INPOS 			lda $ffff	; ** PARAMETER
				INW INPOS+$01
				sec
				rol	@		; Shift out the next bit and	; shift in C=1 (last bit marker)
				sta bitstr	; bitstr initial value = $80 == empty
				pla			; 1 Byte/4 cycles
				rts
; 25+12 = 37

; getval : Gets a 'static huffman coded' value
; ** Scratches X, returns the value in A **
__getVal		EQU *
				inx		; X <- 1
				txa		; set the top bit (value is 1..255)
gv0				asl bitstr
				bne __getValJ1
				jsr __getNew
__getValJ1		EQU *
				bcc getchk	; got 0-bit
				inx
mg				cpx #7		; ** PARAMETER unary code maximum length + 1
				bne gv0
				beq getchk	; inverse condition -> jump always
; getval: 18 bytes
; 15 + 17*n + 6+15*n+12 + 36*n/8 = 33 + 32*n + 36*n/8 cycles

; getbits: Gets X bits from the stream
; ** Scratches X, returns the value in A **
__getByte		EQU *
				ldx #7
get1bit			inx		;2
getbits			asl bitstr
				bne __getByteJ1
				jsr __getNew
__getByteJ1		rol	@	;2
getchk			dex		;2		more bits to get ?
getchkf			bne getbits	;2/3
				clc		;2		return carry cleared
				rts		;6+6

; = *+1		; ZP
__putCh			EQU *
OUTPOS			sta $ffff	; parameter
				INW OUTPOS+$01
				rts

table			EQU *
				DTA b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
				DTA b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
				DTA b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
				DTA b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)

packed

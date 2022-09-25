!cpu 6510

;EXAMPLE FOR OFFICIAL VERSION

lz_sector      = ($ffff - (data_end-data) + 1) & $ff00

decruncher = $00c2

		* = $0801
		;basicline 1 SYS2061
		!byte $0b,$08,$39,$05,$9e,$32
		!byte $30,$36,$31,$00,$00,$00

		sei
		inc $01

		ldx #$ff
		txs

		inx
-
		lda copy_start,x
		sta decruncher,x
		inx
		bne -

		ldy #(>(data_end-data)) + 1
-
		;src should be data + packed_size
		dex
src		lda data_end-$100,x
dst		sta $ff00,x
		txa
		bne -

		dec src+2
		dec dst+2
		dey
		bne -

		ldx #<($ffff - (data_end-copy_end) + 1)
		jmp go

copy_start
!pseudopc decruncher {
		;fetch depack addr (use --add-depack-addr on lz)
lz_match       !byte $00,$00
lz_bits        !byte $00
lz_scratch     !byte $00

go
		;******** Start the next match/literal run ********
lz_decrunch
		;XXX TODO lz_bist auch gleich passend füllen bei sfx, nicht in stream schreiben?
		sec			;This is the main entry point. Forcibly
_lz_type_refill	jsr _lz_refill_bits	;fill up the the bit buffer on entry
		bne _lz_type_cont	;(BRA)

		;Wrap the high-byte of the destination pointer.
_lz_mfinish	bcc *+4
_lz_maximum	inc+1 lz_dst+1		;This is also used by maximum length
					;literals needing an explicit type bit

		;Literal or match to follow?
		asl lz_bits
_lz_type_cont	bcc _lz_do_match
		beq _lz_type_refill

		;******** Process literal run ********

		lda #%00000000		;Decode run length
_lz_lrun_loop	rol
		asl lz_bits
		bcs _lz_lrun_test
_lz_lrun_back	asl lz_bits
		bne _lz_lrun_loop

		jsr _lz_refill_bits
		bne _lz_lrun_loop	;(BRA)

_lz_lrun_test	bne _lz_lrun_gotten
		jsr _lz_refill_bits
		bcc _lz_lrun_back

_lz_lrun_gotten
		sta+1 _lz_copy_cnt+1	;Store LSB of run-length
                ldy #$00
_lz_lcopy
lz_sector_ptr2	= *+1			;Copy the literal data.
		lda lz_sector,x
		inx
		bne *+5
		jsr lz_fetch_sector
lz_dst = * + 1
		sta $4000,y
		iny
_lz_copy_cnt	cpy #$00
		bne _lz_lcopy

		;Time to advance the destination pointer.
		;Maximum run length literals exit here as a type-bit needs
		;to be fetched afterwards
		tya
		beq _lz_maximum		;maximum literal run, bump sector pointers and so on
		clc
		adc+1 lz_dst+0
		sta+1 lz_dst+0
		bcc _lz_do_match
		inc+1 lz_dst+1

		;******** Process match ********

_lz_do_match	lda #%00100000		;Determine offset length by a two-bit
_lz_moff_range	asl lz_bits		;prefix combined with the first run
		bne *+5			;length bit (where a one identifies
		jsr _lz_refill_bits	;a two-byte match).
		rol			;The rest of the length bits will
		bcc _lz_moff_range	;then follow *after* the offset data

		tay
		lda _lz_moff_length,y
		beq _lz_moff_far

_lz_moff_loop	asl lz_bits		;Load partial offset byte
		bne *+9
		sty lz_scratch
		jsr _lz_refill_bits
		ldy lz_scratch

		rol
		bcc _lz_moff_loop

		bmi _lz_moff_near

_lz_moff_far	sta lz_scratch		;Save the bits we just read as the
					;high-byte

lz_sector_ptr3	= *+1
		lda lz_sector,x		;For large offsets we can load the
		inx			;low-byte straight from the stream
		bne *+5			;without going throught the shift
		jsr lz_fetch_sector	;register

;		sec
		adc _lz_moff_adjust_lo,y ;y .. 2 .. 5? ?! necessary with a full lowbyte?!?!
		bcs _lz_moff_pageok
		dec lz_scratch
		sec
_lz_moff_pageok	adc+1 lz_dst+0
		sta lz_match+0

		lda lz_scratch
		adc _lz_moff_adjust_hi,y
		sec
		bcs _lz_moff_join	;(BRA)

_lz_moff_near
;		sec			;Special case handling of <8 bit offsets.
	 	adc _lz_moff_adjust_lo,y;We may can safely ignore the MSB from
;		sec			;the base adjustment table as the
		adc+1 lz_dst+0		;maximum base (for a 4/5/6/7 bit
		sta lz_match+0		;length sequence) is 113
		lda #$ff
_lz_moff_join	adc+1 lz_dst+1
		sta lz_match+1

		cpy #$04		;Get any remaning run length bits
		lda #%00000001
		bcs _lz_mrun_start      ;Sentinel check can be skipped in that case

_lz_mrun_loop	asl lz_bits
		bne *+5
		jsr _lz_refill_bits
		rol
		asl lz_bits
		bcc _lz_mrun_loop
		bne _lz_mrun_gotten
		jsr _lz_refill_bits
		bcc _lz_mrun_loop

		;XXX TODO only needed on near matches as offset = 1 in that case
_lz_mrun_gotten	tay			;A 257-byte (=>$00) run serves as a
		beq _lz_end_of_file	;sentinel
_lz_mrun_start
		sta _lz_mcopy_len

		ldy #$ff		;The copy loop. This needs to be run
					;forwards since RLE-style matches can overlap the destination
_lz_mcopy
		iny
		lda (lz_match),y	;Copy one byte
		sta (lz_dst),y
_lz_mcopy_len	= *+1
		cpy #$ff
		bne _lz_mcopy

		tya			;Advance destination pointer
;		sec
		adc+1 lz_dst+0
		sta+1 lz_dst+0
		jmp _lz_mfinish

lz_sector_ptr1	= *+1
_lz_refill_bits	ldy lz_sector,x
		sty lz_bits
;		sec
		rol lz_bits
		inx
		bne +

lz_fetch_sector
		inc lz_sector_ptr1+1
		inc lz_sector_ptr2+1
		inc lz_sector_ptr3+1
+
		rts

_lz_end_of_file

		dec $01
		cli
		!byte $4c

_lz_moff_length = * + 2
_lz_moff_adjust_lo = _lz_moff_length + 8
_lz_moff_adjust_hi = _lz_moff_length + 16

}
copy_end = * + 26
data
;!bin "d.lz",,2
data_end

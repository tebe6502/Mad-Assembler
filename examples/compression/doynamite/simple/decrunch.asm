;those will make the depacker ~5% faster but bloat it:
;FAST_LITERAL_COPY = 1			;will increase size by 11 bytes
;FAST_MATCH_COPY = 1			;will increase size by 11 bytes

;-------------------------------------------------------------------------------
;Regular version of the Lempel-Ziv decompressor
;-------------------------------------------------------------------------------
;lz_match	= $f9			;Match source pointer
;lz_dst		= $fb			;Decompression destination pointer.
;					;Initialize this to whatever address
;					;you want to decompress to
;
;lz_bits	= $fd			;Internal shift register
;
;lz_sector	= $0400			;The one-page buffer from which the
;					;compressed data is actually read,
;					;and which gets refilled by
;					;lz_fetch_sector


;-------------------------------------------------------------------------------
;This is the user's hook to replenish the sector buffer with some new bytes.
;
;A and Y are expected to be preserved while carry must remain set on exit.
;X should point to the first byte of the new data, e.g. zero for a full 256-byte
;page of data or two to skip past the sector and track links.
;
;When fetching from a larger in-memory array rather than a single sector buffer
;the lz_sector_ptr1..3 pointers will need to be patched up
;-------------------------------------------------------------------------------
;lz_fetch_sector
;		inc lz_sector_ptr1+1
;		inc lz_sector_ptr2+1
;		inc lz_sector_ptr3+1
;		rts


;-------------------------------------------------------------------------------
;Typical usage
;-------------------------------------------------------------------------------
;		ldx #>source
;		ldy #<source
;		jsr lz_decrunch


;-------------------------------------------------------------------------------
;This is the main lz_decrunch function which may be called to decompress an
;entire file.
;
;On entry and exit the X register points to the next available byte in the
;sector buffer, in ascending order from $00 to $ff.
;This implies that the initial sector must have already been fetched, and that a
;file ending with X wrapped to $00 will have needlessly fetched an extra sector
;(which may be taken advantage of when decoding a contiguous set of files.)
;-------------------------------------------------------------------------------

		;******** Start the next match/literal run ********

lz_decrunch
		sty lz_sector_ptr1+1
		sty lz_sector_ptr2+1
		sty lz_sector_ptr3+1

		;fetch depack addr
		jsr _lz_refill_bits
		sty lz_dst
		jsr _lz_refill_bits
		sty lz_dst+1

		sec			;This is the main entry point. Forcibly
_lz_type_refill	jsr _lz_refill_bits	;fill up the the bit buffer on entry
		bne _lz_type_cont	;(BRA)

		;Wrap the high-byte of the destination pointer.
_lz_mfinish	bcc *+4
_lz_maximum	inc lz_dst+1		;This is also used by maximum length
					;literals needing an explicit type bit
_lz_type_check
		;Literal or match to follow?
		asl lz_bits
_lz_type_cont	bcc _lz_do_match
		beq _lz_type_refill	;no more bits left, fetch new bits and reevaluate

		;******** Process literal run ********

		lda #$00
-
		rol
		asl lz_bits
		bne *+5
		jsr _lz_refill_bits
		bcc _lz_lrun_gotten

		asl lz_bits
		bne -
		jsr _lz_refill_bits
		bne -

_lz_lrun_gotten
		sta _lz_copy_cnt+1	;Store LSB of run-length
		ldy #$00
_lz_lcopy
lz_sector_ptr2	= *+1			;Copy the literal data.
		lda lz_sector,x
		inx
		bne *+5
		jsr lz_fetch_sector
		sta (lz_dst),y
		iny
_lz_copy_cnt	cpy #$00
		bne _lz_lcopy

		;Time to advance the destination pointer.
		;Maximum run length literals exit here as a type-bit needs
		;to be fetched afterwards
		tya
		beq _lz_maximum		;maximum literal run, bump sector pointers and so on
		clc
		adc lz_dst+0
		sta lz_dst+0
		bcc _lz_do_match
		inc lz_dst+1

		;One literal run following another only makes sense if the
		;first run is of maximum length and had to be split. As that
		;case has been taken care of we can safely omit the type bit
		;here


		;******** Process match ********

		;check bit -> 1 -> short match (len 2)
		;else long match
_lz_do_match
		lda #$01		;this could be made shorter by using the last bitfetch of the upcoming loop and restoring the carry again by a cmp #$02. Saves bytes, but makes things slower, as eof check is also done with all short matches then
		asl lz_bits		;first length bit (where a one identifies
		bne *+5			;a two-byte match)
		jsr _lz_refill_bits
		bcc lz_get_offs		;all done, length is 2, skip further bitfetches
-
		asl lz_bits
		bne *+5
		jsr _lz_refill_bits
		rol
		asl lz_bits
		bne *+5
		jsr _lz_refill_bits
		bcc -

		tay			;A 257-byte (=>$00) run serves as a
		beq _lz_end_of_file	;sentinel
lz_get_offs
		sta _lz_mcopy_len	;store length at final destination
		lda #%11000000		;fetch 2 more prefix bits
		rol			;previous bit is still in carry \o/
-
		asl lz_bits		;XXX TODO in ultra slim variant this could be a subroutine
		bne *+5			;XXX TODO this code could also be called twice
		jsr _lz_refill_bits
		rol
		bcs -

		tay
		lda lentab,y
		beq lz_far		;XXX TODO currently 8 and 9 bit long offsets carry teh same value here, so if one wants to use both, one has to set the value for 8 bit long offsets
					;to $ff and check things here with a cmp #$ff. Including teh eor #$ff in lz_far or not will then solvet he problem. This is faster though.
-
		asl lz_bits
		bne *+5
		jsr _lz_refill_bits
		rol
		bcs -
		bmi lz_short
lz_far
		eor #$ff		;negate
		tay
lz_sector_ptr3	= *+1
		lda lz_sector,x		;For large offsets we can load the
		inx			;low-byte straight from the stream
		bne lz_join		;without going throught the shift
		jsr lz_fetch_sector	;register
		!byte $2c		;skip next two bytes
lz_short
		ldy #$ff		;XXX TODO GNAAA y is set twice to $ff in the case of short matches
lz_join
		adc lz_dst		;subtract offset from lz_dst
		sta lz_match
		tya			;hibyte
		adc lz_dst+1
		sta lz_match+1
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
		adc lz_dst+0
		sta lz_dst+0
		jmp _lz_mfinish

		;******** Fetch some more bits to work with ********

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
_lz_end_of_file	rts

lentab
		;XXX TODO combine tables so that values used twice are eliminated? -> more classes can be used?
		;XXX TODO best rearrange tables by using lookup table?

		;short offset init values
		!byte %11011111
		!byte %11111011
		!byte %00000000
		!byte %10000000

		;long offset init values
		!byte %11101111
		!byte %11111101
		!byte %10000000
		!byte %11110000

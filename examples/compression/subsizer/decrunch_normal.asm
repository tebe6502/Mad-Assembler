
;**************************************************************************
;*
;* FILE  decrunch_normal.asm
;* Copyright (c) 2015, 2017 Daniel Kahlin <daniel@kahlin.net>
;* Written by Daniel Kahlin <daniel@kahlin.net>
;*
;* DESCRIPTION
;*   subsizer 0.6 decruncher - stand alone version
;*
;*   usage:
;*     You need to provide a function to get a byte from the input
;*     stream. (must preserve X,Y and C)
;*
;*     typical function:
;*
;*       dc_get_byte:
;*           lda   dcgb_ptr
;*           bne   dcgb_skp1
;*           dec   dcgb_ptr+1
;*       dcgb_skp1:
;*           dec   dcgb_ptr
;*       dcgb_ptr  equ    . + 1
;*           lda   data_end
;*           rts
;*
;*     To decrunch just do:
;*
;*	 jsr decrunch
;*
;*     The decruncher will use a temporary area of 188 bytes during
;*     decrunching.
;*
;******


;**************************************************************************
;*
;* Configuration options
;*
;******
HAVE_LONG_PARTS		=	1

subsizer_zp		=	$f8		; 8 bytes
subsizer_data		=	$0400		; 188 bytes
subsizer_main		=	$2000

destination		=	$8010


	ift HAVE_LONG_PARTS
PART_MASK	equ	%00001111
N_PARTS		equ	16
	els
PART_MASK	equ	%00000111
N_PARTS		equ	8
	eif


	org	subsizer_zp

len_zp		.ds	1
copy_zp		.ds	2
hibits_zp	.ds	1
buf_zp		.ds	1
dest_zp		.ds	2
endm_zp		.ds	1

	org	subsizer_main

dl	dta d'ppp'
	dta $4e,a($8010)
	:101 dta $e
	dta $4e,a($9000)
	:91 dta $e
	dta $41,a(dl)

main
	mwa #dl 560

;	lda data_end-3
;	add <destination
;	sta data_end-3
;	lda data_end-2
;	adc >destination
;	sta data_end-2
;
;	lda data_end-1
;	add >destination
;	sta data_end-1

	jsr decrunch

	jmp *

;**************************************************************************
;*
;* NAME  fast macros
;*
;******

;******
;* get bit macro
.macro	get_bit
	asl	buf_zp
	bne	gb_skp1
; C=1 (because the marker bit was just shifted out)
	jsr	dc_get_byte
	rol
	sta	buf_zp
gb_skp1
.endm


;******
;* get bits max8 macro
.macro	get_bits_max8
gb_lp1
	asl	buf_zp
	bne	gb_skp1
; C=1 (because the marker bit was just shifted out)
	pha
	jsr	dc_get_byte
	rol
	sta	buf_zp
	pla
gb_skp1
	rol
	dey
	bne	gb_lp1
.endm


;******
;* get bits max8 masked macro
.macro	get_bits_max8_masked
gb_lp1
	asl	buf_zp
	bne	gb_skp1
; C=1 (because the marker bit was just shifted out)
	tay
	jsr	dc_get_byte
	rol
	sta	buf_zp
	tya
gb_skp1
	rol
	bcs	gb_lp1
.endm


;******
;* get bits max16 macro
.macro	get_bits_max16
gb_lp1
	asl	buf_zp
	bne	gb_skp1
; C=1 (because the marker bit was just shifted out)
	pha
	jsr	dc_get_byte
	rol
	sta	buf_zp
	pla
gb_skp1
	rol
	rol	hibits_zp
	dey
	bne	gb_lp1		; C=0 for all Y!=0
.endm


;**************************************************************************
;*
;* NAME  decrunch
;*
;******
decrunch:
	ldx	#4
; Get dest_zp, endm_zp and buf_zp
dc_lp00:
	jsr	dc_get_byte
	sta	buf_zp-1,x
	dex
	bne	dc_lp00

; X = 0

;	ldx	#0
dc_lp01:

;******
;* get 4 bits
	lda	#%11100000
dcg_lp1:
	asl	buf_zp
	bne	dcg_skp1
; C=1 (because the marker bit was just shifted out)
	tay
	jsr	dc_get_byte
	rol
	sta	buf_zp
	tya
dcg_skp1:
	rol
	bcs	dcg_lp1
; Acc = 4 bits.

	sta	bits,x

	txa
	and	#PART_MASK
	tay
	beq	dc_skp01

	lda	#0
	sta	hibits_zp
	ldy	bits-1,x
	sec
dc_lp02:
	rol
	rol	hibits_zp
	dey
	bpl	dc_lp02
; C = 0
;	clc
	adc	base_l-1,x
	tay
	lda	hibits_zp
	adc	base_h-1,x

dc_skp01:
	sta	base_h,x
	tya
	sta	base_l,x
	inx
	cpx	#N_PARTS*4+4
	bne	dc_lp01

; perform decrunch
	ldy	#0
	beq	decrunch_entry	; always taken

; we could optimize this by falling through into the dc_literal routine as
; the first byte must always be a literal anyway (maybe even a literal run?)


;**************************************************************************
;*
;* NAME  decruncher
;*
;* DESCRIPTION
;*   decruncher
;*
;******

;******
;* single literal byte
;*
dc_literal:
	lda	dest_zp
	bne	dc_skp5
	dec	dest_zp+1
dc_skp5:
	dec	dest_zp
	jsr	dc_get_byte
;	ldy	#0
dc_common:
	sta	(dest_zp),y
	; fall through

decrunch_entry:
;------
; perform actual decrunch
dc_lp1:
	get_bit
	bcs	dc_literal

; get length as bits/base.
	ldx	#$80-N_PARTS
dc_lp2:
	inx
	bmi	dc_skp0
	get_bit
	bcc	dc_lp2
	clc
dc_skp0:
; C = 0, Y = 0
;	lda	#0
	tya
	ldy	bits_len-$80+N_PARTS-1,x
	beq	dcb1_skp2
	get_bits_max8
dcb1_skp2:
; C = 0
	adc	base_len-$80+N_PARTS-1,x
	sta	len_zp
; C = 0

;******
;* IN: len = $01..$100 (Acc = $00..$ff)
;* OUT: dest_zp = dest_zp - len,  X = len-1
;*
	tax
;	clc
	eor	#$ff
	adc	dest_zp
	sta	dest_zp
	bcs	dc_skp22
	dec	dest_zp+1
dc_skp22:

; check end marker here to avoid thrashing carry earlier
	cpx	endm_zp
	beq	done

;******
;* Get selector bits depending on length.
;*
;* IN: len = $01..$100 (X = $00..$ff)
;* OUT:
;*
	cpx	#4
	bcc	dc_skp2
	ldx	#3
dc_skp2:

; get offset as bits/base.
	lda	tabb,x
	get_bits_max8_masked
	tax
; C = 0

	lda	#0
	sta	hibits_zp
	ldy	bits_offs,x
	beq	dcb3_skp2
	get_bits_max16
dcb3_skp2:
; C = 0,  Acc/hibits_zp + base_offs,x = offset - 1

; perform: copy_zp = Acc/hibits_zp + base_offs,x + 1 + dest_zp
; result:  copy_zp = dest_zp + offset
	adc	base_offs_l,x
	bcc	dcb3_skp3
	inc	hibits_zp
dcb3_skp3:
	sec
	adc	dest_zp
	sta	copy_zp
	lda	hibits_zp
	adc	base_offs_h,x
; C = 0
	adc	dest_zp+1
	sta	copy_zp+1

;******
;* Reverse fast copy
;*
;* IN: len = $01..$100 (len_zp = $00..$ff), C = 0
;*
copy:
	ldy	len_zp
	beq	dc_skp4
dc_lp4:
	lda	(copy_zp),y
	sta	(dest_zp),y
	dey
	bne	dc_lp4
dc_skp4:
	lda	(copy_zp),y
;	sta	(dest_zp),y
	jmp	dc_common
;	bcc	dc_common		; always taken

;******
;* exit out
done:
	rts

	ift	HAVE_LONG_PARTS
tabb:
	dta	%10000000 | [48 >> 2]	; 2 bits
	dta	%11100000 | [0  >> 4]	; 4 bits
	dta	%11100000 | [16 >> 4]	; 4 bits
	dta	%11100000 | [32 >> 4]	; 4 bits
	els
tabb:
	dta	%10000000 | [24 >> 2]	; 2 bits
	dta	%11000000 | [0  >> 3]	; 3 bits
	dta	%11000000 | [8  >> 3]	; 3 bits
	dta	%11000000 | [16 >> 3]	; 3 bits
	eif



;	ift	0
;**************************************************************************
;*
;* NAME  dc_get_byte
;*
;* DESCRIPTION
;*   Get byte from the packed stream.
;*
;******
dc_get_byte:
	dew dc_ptr
dc_ptr	equ	*+1
	lda	data_end
	rts
;	eif


end_decruncher:

	org	subsizer_data
begin_tables:
;**************************************************************************
;*
;* NAME  base_l, base_h, bits
;*
;* DESCRIPTION
;*   Data for bits/base decoding.
;*
;******
base_l:
base_len:
	:N_PARTS	brk
base_offs_l:
	:N_PARTS*3+4	brk
base_h	equ	*-N_PARTS
;	:N_PARTS	brk
base_offs_h:
	:N_PARTS*3+4	brk

bits:
bits_len:
	:N_PARTS	brk
bits_offs:
	:N_PARTS*3+4	brk

end_tables:

; eof

	org $1000		; taki adres jest w naglowku 'a.out'
data	ins 'pc\a.out',2
data_end

	run main
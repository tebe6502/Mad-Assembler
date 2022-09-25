
; --------------------------------------------------------------------------------------------------------------------------
; -- EXOMIZER sfx sys -t 168 -Di_ram_enter=0xfe -Di_ram_exit=0xff -Di_table_addr=0xbc40 -c -x "sta $d01a" infile -o outfile
; -- EXOMIZER mem -c infile -o outfile
; --------------------------------------------------------------------------------------------------------------------------

i_load_addr	= $2000
i_depack_addr	= $0100

i_table_addr	= $bc40

i_zp_addr	= $f7

tabl_bi		= i_table_addr
tabl_lo		= i_table_addr + 52
tabl_hi		= i_table_addr + 104

	org	i_zp_addr

zp_lo_len	.ds 1
zp_hi_bits	.ds 1
zp_src_addr	.ds 4

zp_bitbuf	.ds 3
zp_dest_lo	= zp_bitbuf + 1		; dest addr lo
zp_dest_hi	= zp_bitbuf + 2		; dest addr hi

	opt h-

	dta $ff,$ff,a(main),a(file1end-1)

	org	i_load_addr

main

.get "plik_mem.dat",0,2
v_safety_addr = .get[0]+.get[1]<<8

; -------------------------------------------------------------------
; -- convert $0 to $10000 but leave $1 - $ffff ----------------------
; -------------------------------------------------------------------
.get "plik_mem.dat",-2
v_highest_addr = ((.get[0]+.get[1]<<8) + 65535)%65536 + 1

; -------------------------------------------------------------------
; -- start of stage 1 -----------------------------------------------
; -------------------------------------------------------------------
max_transfer_len = .LEN "plik_mem.dat"-5

	ldy #transfer_len%256

	enter_hook

//	.IF(.DEFINED(enter_hook))
//	  .INCLUDE("enter_hook")
//	.ENDIF

	.get "plik_mem.dat", max_transfer_len + 2, 1

	mva #.get[0]			zp_bitbuf
	mwa #(v_highest_addr %65536)	zp_bitbuf+1

	ldx #stage3end-stage3start

cploop:
	lda stage2end - 1,x
	sta.w i_depack_addr - 1,x
	dex
	bne cploop

.IF(transfer_len > 256)
	ldx #transfer_len / 256
.ENDIF
.IF(transfer_len != max_transfer_len)
	jmp stage2start
.ENDIF
stage1end:
	
; -------------------------------------------------------------------
; -- end of stage 1 -------------------------------------------------
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; -- start of file part 2 -------------------------------------------
; -------------------------------------------------------------------
file2start:

    .IF(v_safety_addr < file2start)
c_effect_char = v_safety_addr
raw_transfer_len = file2start - c_effect_char
lowest_addr = c_effect_char
    .ENDIF

.IFNDEF raw_transfer_len
  .IF(v_safety_addr > file2start)
raw_transfer_len = 0
lowest_addr = file2start
  .ELSE
raw_transfer_len = file2start - v_safety_addr
lowest_addr = v_safety_addr
  .ENDIF
.ENDIF

.IF(raw_transfer_len > max_transfer_len)
transfer_len = max_transfer_len
.ELSE
transfer_len = raw_transfer_len
.ENDIF

	ins "plik_mem.dat", transfer_len + 2, max_transfer_len - transfer_len

;i_literal_sequences_used

file2end:
; -------------------------------------------------------------------
; -- end of file part 2 ---------------------------------------------
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; -- start of stage 2 -----------------------------------------------
; -------------------------------------------------------------------
.IF(transfer_len == 0)
stage2start:
.ELIF(transfer_len < 257)
stage2start:
copy1_loop:
  .IF(transfer_len == 256)
	lda file1start,y
	sta lowest_addr,y
  .ELSE
	lda file1start - 1,y
	sta lowest_addr - 1,y
  .ENDIF
	dey
	bne copy1_loop
.ELSE
	bne copy2_loop1
copy2_loop2:
	dex
	dec lda_fixup + 2
	dec sta_fixup + 2
copy2_loop1:
	dey
lda_fixup:
	lda file1start + transfer_len / 256*256,y
sta_fixup:
	sta lowest_addr + transfer_len / 256*256,y
stage2start:
	tya
	bne copy2_loop1
	txa
	bne copy2_loop2
.ENDIF
; -------------------------------------------------------------------
table_gen:
	inx
	tya
	and #$0f
	beq shortcut		; start a new sequence

	txa			; this clears reg a
	lsr			; and sets the carry flag
	ldx tabl_bi-1,y
rolle:
	rol
	rol zp_hi_bits
	dex
	bpl rolle		; c = 0 after this (rol zp_hi_bits)

	adc tabl_lo-1,y
	tax

	lda zp_hi_bits
	adc tabl_hi-1,y
shortcut:
	sta tabl_hi,y
	txa
	sta tabl_lo,y

	ldx #4
	jsr get_bits		; clears x-reg.
	sta tabl_bi,y
	iny
	cpy #52
	bne table_gen
	ldy #0

	.IFDEF stage2_exit_hook
		stage2_exit_hook
	.ENDIF
	jmp begin
; -------------------------------------------------------------------
; -- end of stage 2 -------------------------------------------------
; -------------------------------------------------------------------
;	ins "plik_mem.dat", max_transfer_len + 2, 1
;	.WORD(v_highest_addr %65536)
stage2end:


	ORG	i_depack_addr
; -------------------------------------------------------------------
; -- start of stage 3 -----------------------------------------------
; -------------------------------------------------------------------
stage3start:
; -------------------------------------------------------------------
; get bits (29 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   z = 1
;   zp_hi_bits = #bits_hi
; notes:
;   y is untouched
; -------------------------------------------------------------------
get_bits:
	lda #$00
	sta zp_hi_bits
	cpx #$01
	bcc bits_done
bits_next:
	lsr zp_bitbuf
	bne ok
	pha
literal_get_byte:

	effect_hook

//	.IF(.DEFINED(fast_effect_hook))
//	  .INCLUDE("effect_hook")
//	.ENDIF
	lda get_byte_fixup + 1
	bne get_byte_skip_hi
	dec get_byte_fixup + 2
//	.IF(.DEFINED(slow_effect_hook))
//	  .INCLUDE("effect_hook")
//	.ENDIF
get_byte_skip_hi:
	dec get_byte_fixup + 1
get_byte_fixup:
	lda lowest_addr + max_transfer_len
	bcc literal_byte_gotten
	ror
	sta zp_bitbuf
	pla
ok:
	rol
	rol zp_hi_bits
	dex
	bne bits_next
bits_done:
//	.IF(!.DEFINED(exit_hook))
//decr_exit:
//	.ENDIF
	rts
; -------------------------------------------------------------------
; main copy loop (16 bytes)
;
copy_next_hi:
	dex
	dec zp_dest_hi
	dec zp_src_addr + 1
copy_next:
	dey
.IFDEF	i_literal_sequences_used
	bcc literal_get_byte
.ENDIF
	lda (zp_src_addr),y
literal_byte_gotten:
	sta (zp_dest_lo),y
copy_start:
	tya
	bne copy_next
begin:
	txa
	bne copy_next_hi
; -------------------------------------------------------------------
; decruncher entry point, needs calculated tables (15 bytes)
; x and y must be #0 when entering
;
.IFDEF	i_literal_sequences_used
	inx
	jsr get_bits
	tay
	bne literal_start1
.ELSE
	dey
.ENDIF
begin2:
	inx
	jsr bits_next
	lsr
	iny
	bcc begin2
.IFNDEF	i_literal_sequences_used
	beq literal_start
.ENDIF
	cpy #$11
.IFDEF	i_literal_sequences_used
	bcc sequence_start
	beq decr_exit
; -------------------------------------------------------------------
; literal sequence handling
;
	ldx #$10
	jsr get_bits
literal_start1:
	sta zp_lo_len
	ldx zp_hi_bits
	ldy #0
	bcc literal_start
sequence_start:
.ELSE
	bcs decr_exit
.ENDIF
; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (11 bytes)
;
	ldx tabl_bi - 1,y
	jsr get_bits
	adc tabl_lo - 1,y	; we have now calculated zp_lo_len
	sta zp_lo_len
; -------------------------------------------------------------------
; now do the hibyte of the sequence length calculation (6 bytes)
	lda zp_hi_bits
	adc tabl_hi - 1,y	; c = 0 after this.
	pha
; -------------------------------------------------------------------
; here we decide what offset table to use (20 bytes)
; x is 0 here
;
	bne nots123
	ldy zp_lo_len
	cpy #$04
	bcc size123
nots123:
	ldy #$03
size123:
	ldx tabl_bit - 1,y
	jsr get_bits
	adc tabl_off - 1,y	; c = 0 after this.
	tay			; 1 <= y <= 52 here
; -------------------------------------------------------------------
; Here we do the dest_lo -= len_lo subtraction to prepare zp_dest
; but we do it backwards:	a - b == (b - a - 1) ^ ~0 (C-syntax)
; (14 bytes)
	lda zp_lo_len
literal_start:			; literal enters here with y = 0, c = 1
	sbc zp_dest_lo
	bcc noborrow
	dec zp_dest_hi
noborrow:
	eor #$ff
	sta zp_dest_lo
	cpy #$01		; y < 1 then literal
.IFDEF	i_literal_sequences_used
	bcc pre_copy
.ELSE
	bcc literal_get_byte
.ENDIF
; -------------------------------------------------------------------
; calulate absolute offset (zp_src) (27 bytes)
;
	ldx tabl_bi,y
	jsr get_bits;
	adc tabl_lo,y
	bcc skipcarry
	inc zp_hi_bits
	clc
skipcarry:
	adc zp_dest_lo
	sta zp_src_addr
	lda zp_hi_bits
	adc tabl_hi,y
	adc zp_dest_hi
	sta zp_src_addr + 1
; -------------------------------------------------------------------
; prepare for copy loop (6 bytes)
;
	pla
	tax
.IFDEF	i_literal_sequences_used
	sec
pre_copy:
	ldy zp_lo_len
	jmp copy_start
.ELSE
	ldy zp_lo_len
	bcc copy_start
.ENDIF
//	.IF(.DEFINED(exit_hook))
decr_exit:
	
	exit_hook

//	  .INCLUDE("exit_hook")
//	.ENDIF
; -------------------------------------------------------------------
; two small static tables (6 bytes)
;
tabl_bit:
	.BYTE(2, 4, 4)
tabl_off:
	.BYTE(48, 32, 16)
stage3end:
; -------------------------------------------------------------------
; -- end of stage 3 -------------------------------------------------
; -------------------------------------------------------------------

        ORG(stage2end + stage3end - stage3start)
; -------------------------------------------------------------------
; -- start of file part 1 -------------------------------------------
; -------------------------------------------------------------------
file1start:
	ins "plik_mem.dat", 2, transfer_len
file1end:
; -------------------------------------------------------------------
; -- end of file part 1 ---------------------------------------------
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; -- End of the actual decruncher -----------------------------------
; -------------------------------------------------------------------

	opt h+
	run main

.macro	enter_hook
	sei
;	lda #$00
;	sta $d40e
.endm


.macro	exit_hook
	lda #$ff
	sta $d301
;	lda #$40
;	sta $d40e
	rts
.endm


.macro	effect_hook
	sta $d01a
.endm

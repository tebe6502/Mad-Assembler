; Show Atari ST/Falcon graphics file:
; *.PI1 = "DEGAS", 320x200, 16 colors from 4096
; *.PI2 = "DEGAS", 640x200, 4 colors from 4096
; *.PI3 = "DEGAS", 640x400, black and white
; *.DOO = "Doodle", 640x400, black and white
; *.NEO = "NEOchrome", any of the above resolutions
; *.PI4, *.PI9 = "Fuckpaint", 320x200, 256 colors from 262144
; *.DG1 = "DuneGraph", 320x200, 256 colors from 262144
; Filename must be passed in command line.

; 400 lines would be doable using the interlace trick revealed in 2009 by Rybags.
; Unfortunately, Rybags' trick doesn't work on all TVs (especially the LCDs) and emulators.
; Therefore, I reduce ST high to ST medium, using gray pixels if mixing black and white.

; "THE BEER-WARE LICENSE" (Revision 42):
; Piotr Fusik <fox@scene.pl> wrote this file.
; As long as you retain this notice you can do whatever you want with this stuff.
; If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.

; <commercial-break>
; To view ST pictures on Windows, Android, macOS and Linux, visit http://recoil.sourceforge.net/
; </commercial-break>

; How many picture lines to read from disk at once?
; 10 is a quick compromise between performance, memory usage
; and visible progress when reading from floppy.
BUFFER_STLINES	equ	10
	ert	200%BUFFER_STLINES!=0
	ert	BUFFER_STLINES%2!=0
BUFFER_LEN	equ	BUFFER_STLINES*160

; Addresses in VBXE memory
xdl_vbxe	equ	$10000
scr_vbxe	equ	$10100

; Zero-page variables
fx_ptr	equ	$80	; 2
arg_str	equ	$82	; 2
st_resolution	equ	$82
y	equ	$83
arg_len	equ	$84
arg_idx	equ	$85
scr_ptr	equ	$84	; 2
vbxe_bank	equ	$86
cnt	equ	$87
buf_ptr	equ	$88	; 2
bitplane	equ	$8a	; 8

	org	$8000	; we'll map VBXE memory into $4000-$7fff
main
; Detect VBXE
	jsr	fx_detect
	beq	found_vbxe
	lda	<vbxe_not_found_txt
	ldx	>vbxe_not_found_txt
	jmp	print
found_vbxe

; Get filename from SpartaDOS...
	lda	11
	cmp	#$c0
	bcs	no_sparta
	ldy	#3
	lda	(10),y
	cmp	#{jmp a:}
	bne	no_sparta
	iny
	mva	(10),y	sparta_jsr+1
	iny
	mva	(10),y	sparta_jsr+2
sparta_jsr
	jsr	$2020
	beq	no_filename_error
	ldy	#33
sparta_copy
	mva	(10),y	filename-33,y+
	cmp	#$9b
	bne	sparta_copy
	jmp	filename_ok
no_sparta

; ... or channel #0
	lda	$342	; command
	cmp	#5	; read line
	bne	no_filename_error
	lda	$343	; status
	bmi	no_filename_error
; don't assume the line is EOL-terminated
; DOS II+/D overwrites the EOL with ".COM"
; that's why we rely on the length
	lda	$349	; length hi
	bne	no_filename_error
	ldx	$348	; length lo
	beq	no_filename_error
	inx:inx
	stx	arg_len
; give access to three bytes before the input buffer
; in DOS II+/D the device prompt ("D1:") is there
	lda	$344
	sub	#3
	sta	arg_str
	lda	$345
	sbc	#0
	sta	arg_str+1
; first skip ST2VBXE.COM
; it's space-terminated on DOS II+/D,
; NUL-terminated on MyDOS
	ldy	#3
	lda	#' '
arg_skip_exe
	cmp	(arg_str),y
	bcs	arg_space_1
	iny
	cpy	arg_len
	bcc	arg_skip_exe
	bcs	no_filename_error	;!
; then skip spaces/NULs
arg_space
	cmp	(arg_str),y
	bcc	arg_arg
arg_space_1
	iny
	cpy	arg_len
	bcc	arg_space
no_filename_error
	lda	<no_filename_txt
	ldx	>no_filename_txt
	jmp	print
; now we have the filename
arg_arg
	sty	arg_idx
	jsr	arg_is_device
	bcc	arg_default_device
	cpy	arg_len
	bcs	arg_default_device
; filename with device, congratulations, we can use it
	ldx	#0
	beq	arg_copy	;!
; filename without device
arg_default_device
	ldy	#0
	jsr	arg_is_device
	bcc	arg_d_device
; device = DOS II+/D prompt
	tya
	tax
	inx
	mva:rpl	(arg_str),y	filename,y-
	bmi	arg_copy	;!
; device = "D:"
arg_d_device
	mva	#'D'	filename
	mva	#':'	filename+1
	ldx	#2
; copy filename
arg_copy
	ldy	arg_idx
arg_copy_loop
	mva	(arg_str),y+	filename,x+
	cpy	arg_len
	bcc	arg_copy_loop
	mva	#$9b	filename,x

filename_ok

; Identify format by extension
	ldy	#-1
	lda	#$9b
filename_strlen
	iny
	cmp	filename,y
	bne	filename_strlen
	cpy	#4
	bcc	unknown_format_error
	lda	filename-4,y
	cmp	#'.'
	bne	unknown_format_error
	ldx	#format_count-1
filename_find_ext
	lda	filename-3,y
	ora	#$20
	cmp	format_ext1,x
	bne	filename_find_ext_next
	lda	filename-2,y
	ora	#$20
	cmp	format_ext2,x
	bne	filename_find_ext_next
	lda	filename-1,y
	ora	#$20
	cmp	format_ext3,x
	beq	filename_found_ext
filename_find_ext_next
	dex
	bpl	filename_find_ext

unknown_format_error
	lda	<unknown_format_txt
	ldx	>unknown_format_txt
	jmp	print

; Open file and call format-specific routine
filename_found_ext
	mva	format_lo,x	format_jmp+1
	mva	format_hi,x	format_jmp+2

	lda	<filename
	ldx	>filename
	jsr	open

format_jmp
	jmp	$4c4c

; NEO
neo_header
	lda	#2
	jsr	read_short
	lda	buffer
	ora	buffer+1
	bne	format_error
	lda	#126
	bne	neo1	; jmp

; PI1, PI2, PI3
degas_header
	lda	#34
neo1
	jsr	read_short

	lda	buffer
	bne	format_error
	lda	buffer+1
	cmp	#3
	bcc	format_ok
format_error
	lda	<format_error_txt
	ldx	>format_error_txt
	jmp	print

; DOO
doodle_header
	lda	#2
	bne	format_ok	; jmp

; DG1
dunegraph_header
	lda	#8
	jsr	read_short
	ldy	#7
dunegraph_check_header
	lda	buffer,y
	cmp	dunegraph_expected_header,y
	bne	format_error
	dey
	bpl	dunegraph_check_header

; PI4, PI9
fuckpaint_header
	lda	<1024
	ldx	>1024
	jsr	read
	lda	#3

; Setup VBXE and palette
format_ok
	sta	st_resolution
	tax
	mva	stres2vbxe,x	xdl_1+1
	mva	stres2decode_lo,x	decode_ptr
	mva	stres2decode_hi,x	decode_ptr+1

	jsr	set_palette

; Read & decode loop
	mwa	#$4000+[scr_vbxe&$3fff]	scr_ptr
	mva	#$80+[scr_vbxe>>14]	vbxe_bank
	mva	#0	y
read_1
	lda	<BUFFER_LEN
	ldx	>BUFFER_LEN
	jsr	read
	jsr	decode
	lda	y
	bne	vbxe_set_up
	jsr	setup_vbxe
	lda	#0
vbxe_set_up
	ldx	st_resolution
	add	stres2lines,x
	sta	y
; Make VBXE display as many lines as we have drawn
	tax:dex
	ldy	#$5d	; MEMB
	mva	#$80+[[xdl_vbxe+xdl_2-xdl]>>14]	(fx_ptr),y	; mbce
	stx	$4000+[[xdl_vbxe+xdl_2-xdl]&$3fff]
; unmap VBXE memory so that it doesn't conflict with SpartaDOS X I/O
	mva	#0	(fx_ptr),y
	cpx	#199
	bcc	read_1

	jsr	close
	jsr	getchar

; Return to DOS
	jsr	reset_vbxe
	ldy	#1
	rts

; Detect VBXE
fx_detect
	mwa	#$d600	fx_ptr
	jsr	fx_detect_1
	beq	fx_detect_exit
	inc	fx_ptr+1
fx_detect_1
	ldy	#$40	; CORE_VERSION
	lda	(fx_ptr),y
	cmp	#$10	; FX 1.xx
	bne	fx_detect_exit
	iny	; MINOR_VERSION
	lda	(fx_ptr),y
	and	#$70
	cmp	#$20	; 1.2x
fx_detect_exit
	rts

; Set ST/Falcon palette in VBXE
set_palette
	ldy	#$44
	mva	#0	(fx_ptr),y+	; CSEL
	mva	#1	(fx_ptr),y	; PSEL
	ldx	#0
	lda	st_resolution
	cmp	#2
	bcc	set_palette_st
	beq	set_palette_hires

set_palette_falcon
	mwa	#buffer	buf_ptr
set_palette_falcon_1
	ldy #0
	lda	(buf_ptr),y
	ldy	#$46	; CR
	sta	(fx_ptr),y
	ldy	#1
	lda	(buf_ptr),y
	ldy	#$47	; CG
	sta	(fx_ptr),y
	ldy	#3
	lda	(buf_ptr),y
	ldy	#$48	; CB
	sta	(fx_ptr),y
	lda	#4
	add:sta	buf_ptr
	scc:inc	buf_ptr+1
	inx
	bne	set_palette_falcon_1
	rts

set_palette_st
; Each STE color is %xxxxrRRR %gGGGbBBB
	lda	st_palette,x+
	and	#$f
	tay
	lda	set_palette_st2vbxe,y
	ldy	#$46	; CR
	sta	(fx_ptr),y
	lda	st_palette,x
:4	lsr	@
	tay
	lda	set_palette_st2vbxe,y
	ldy	#$47	; CG
	sta	(fx_ptr),y
	lda	st_palette,x+
	and	#$f
	tay
	lda	set_palette_st2vbxe,y
	ldy	#$48	; CB
	sta	(fx_ptr),y
	cpx	#32
	bcc	set_palette_st
	rts

set_palette_hires
; white, gray, gray, black
	lda	#$ff
	jsr	set_palette_gray
	lsr	@
	jsr	set_palette_gray
	jsr	set_palette_gray
	lda	#0
set_palette_gray
	ldy	#$46	; CR
	sta	(fx_ptr),y+
	sta	(fx_ptr),y+
	sta	(fx_ptr),y
	rts

; Enable VBXE display
setup_vbxe
	ldy	#$5d	; MEMB
	mva	#$80+[xdl_vbxe>>14]	(fx_ptr),y	; mbce
	ldy	#xdl_len-1
	mva:rpl	xdl,y	$4000+[xdl_vbxe&$3fff],y-
	mva	#0	$22f	; disable ANTIC graphics
	sta	$2c8	; black border
	lda	20
	cmp:req	20	; wait for vblank
	ldy	#$40	; VIDEO_CONTROL
	mva	#5	(fx_ptr),y+	; no_trans|xdl_enabled
	mva	#xdl_vbxe&$ff	(fx_ptr),y+	; XDL_ADR0
	mva	#[xdl_vbxe>>8]&$ff	(fx_ptr),y+	; XDL_ADR1
	mva	#xdl_vbxe>>16	(fx_ptr),y	; XDL_ADR2
	rts

; Disable VBXE display
reset_vbxe
	ldy	#$5d	; MEMB
	mva	#0	(fx_ptr),y
	ldy	#$40	; VIDEO_CONTROL
	mva	#0	(fx_ptr),y

	ldy	#12	; close
	jsr	cio0
	mva	#12	$34a	; open for read/write
	mva	#0	$34b
	lda	<editor_device
	ldx	>editor_device
	ldy	#3	; open
	bne	cio0addr	;!

; Returns C=1 if (arg_str),y looks like
; Atari OS device name: /[A-Z][1-9]?:/
arg_is_device
	lda	(arg_str),y
	cmp	#'A'
	bcc	arg_is_device_ret
	cmp	#'Z'+1
	bcs	arg_is_device_no
	iny
	lda	(arg_str),y
	cmp	#'1'
	bcc	arg_is_device_ret
;	ert	'9'+1!=':'
	cmp	#':'
	bcs	arg_is_device_end
	iny
	lda	(arg_str),y
	cmp	#':'
arg_is_device_end
	beq	arg_is_device_ret
arg_is_device_no
	clc
arg_is_device_ret
	rts

; Print a message
print
	mvy	>1024	$349	; just don't print more than 1k characters ;)
	ldy	#9	; write line
cio0addr
	sta	$344
	stx	$345
cio0
	sty	$342
	ldx	#0
	jmp	$e456

; Wait for a key
; Doesn't return the char actually
getchar
	lda	<keyboard_device
	ldx	>keyboard_device
	jsr	open
	lda	#0
	jsr	read_short
	jmp	close

; Open file or keyboard
open
	sta	$354
	stx	$355
	mva	#4	$35a	; open for read
	mva	#0	$35b
	lda	#3	; open
cio
	sta	$352
	ldx	#$10	; channel #1
	jsr	$e456
	bmi	io_error
	rts

io_error
	pla:pla
	jsr	reset_vbxe
	jsr	close
	lda	<io_error_txt
	ldx	>io_error_txt
	jmp	print

; Read from file up to 255 bytes
read_short
	ldx	#0
; Read from file
read
	sta	$358
	stx	$359
	mwa	#buffer	$354
	lda	#7	; read binary
	bne	cio	;!

; Close file
close
	lda	#12	; close
	bne	cio	;!

; Decode ST/Falcon bitmap
decode
	mwa	#buffer	buf_ptr
	ldy	#$5d	; MEMB
	mva	vbxe_bank	(fx_ptr),y	; mbce
decode_1
	jsr	$2020
decode_ptr	equ	*-2
	add:sta	buf_ptr
	scc:inc	buf_ptr+1
	cmp	<buffer+BUFFER_LEN
	lda	buf_ptr+1
	sbc	>buffer+BUFFER_LEN
	bcc	decode_1
	rts

; Decode ST low
decode_low_16pixels
; 16-color Atari ST mode is B0 B0 B1 B1 B2 B2 B3 B3 B0 B0 B1 B1 ...
; where B0 are bytes of the least-significant bitplane
; and B3 are bytes of the most-significant bitplane.
; For each pixel we need to get one bit from each bitplane.
	jsr	decode_low_8pixels	; B0 -- B1 -- B2 -- B3 --
	inw	buf_ptr
	jsr	decode_low_8pixels	; -- B0 -- B1 -- B2 -- B3
	lda	#7                	; advance here -----------^^
	rts

decode_low_8pixels
	ldy	#0
	mva	(buf_ptr),y	bitplane
	ldy	#2
	mva	(buf_ptr),y	bitplane+1
	ldy	#4
	mva	(buf_ptr),y	bitplane+2
	ldy	#6
	mva	(buf_ptr),y	bitplane+3
	ldx	#8
decode_low_1pixel
	lda	#0
	asl	bitplane+3
	rol	@
	asl	bitplane+2
	rol	@
	asl	bitplane+1
	rol	@
	asl	bitplane
	rol	@
	jsr	put_vbxe_byte
	dex
	bne	decode_low_1pixel
	rts

; Decode ST medium
decode_medium_16pixels
; 4-color Atari ST mode is B0 B0 B1 B1 B0 B0 B1 B1 B0 ...
	jsr	decode_medium_8pixels ; B0 -- B1 --
	inw	buf_ptr
	jsr	decode_medium_8pixels ; -- B0 -- B1
	lda	#3                    ; advance here ^^
	rts

decode_medium_8pixels
	ldy	#2
decode_medium_8pixels_offset
	mva	(buf_ptr),y	bitplane+1
	ldy	#0
	mva	(buf_ptr),y	bitplane
	ldx	#4
decode_medium_2pixels
; for 640-pixel VBXE mode need to pack pixels in nibbles
	lda	#0
	asl	bitplane+1
	rol	@
	asl	bitplane
	rol	@
	asl:asl	@
	asl	bitplane+1
	rol	@
	asl	bitplane
	rol	@
	jsr	put_vbxe_byte
	dex
	bne	decode_medium_2pixels
	rts

; Decode ST high
decode_high_line
; 640x400 - convert to 640x200
	mva	#80	bitplane+2
decode_high_8pixels
	ldy	#80
	jsr	decode_medium_8pixels_offset
	inw	buf_ptr
	dec	bitplane+2
	bne	decode_high_8pixels
	lda	#80
	rts

; Decode Falcon 256-color
decode_falcon_16pixels
	jsr	decode_falcon_8pixels
	inw	buf_ptr
	jsr	decode_falcon_8pixels
	lda	#15
	rts

decode_falcon_8pixels
	ldx	#7
	ldy	#14
decode_falcon_8pixels_load
	mva	(buf_ptr),y	bitplane,x
	dey:dey
	dex
	bpl	decode_falcon_8pixels_load
	mva	#8	cnt
decode_falcon_1pixel
	ldx	#7
decode_falcon_1bit
	asl	bitplane,x
	rol	@
	dex
	bpl	decode_falcon_1bit
	jsr	put_vbxe_byte
	dec	cnt
	bne	decode_falcon_1pixel
	rts

put_vbxe_byte
	ldy	#0
	sta	(scr_ptr),y
	inc	scr_ptr
	bne	put_vbxe_byte_ret
	inc	scr_ptr+1
	bpl	put_vbxe_byte_ret
	lsr	scr_ptr+1
	ldy	#$5d	; MEMB
	inc:lda	vbxe_bank
	sta (fx_ptr),y
put_vbxe_byte_ret
	rts

format_ext1	dta	c'pppdnppd'
format_ext2	dta	c'iiioeiig'
format_ext3	dta	c'123oo491'
format_lo
	dta	l(degas_header,degas_header,degas_header,doodle_header,neo_header,fuckpaint_header,fuckpaint_header,dunegraph_header)
format_hi
	dta	h(degas_header,degas_header,degas_header,doodle_header,neo_header,fuckpaint_header,fuckpaint_header,dunegraph_header)
format_count	equ	*-format_hi

stres2vbxe
	dta	h($8000,$9000,$9000,$8000) ; XDLC_END,XDLC_END|XDLC_HR

stres2decode_lo
	dta	l(decode_low_16pixels,decode_medium_16pixels,decode_high_line,decode_falcon_16pixels)

stres2decode_hi
	dta	h(decode_low_16pixels,decode_medium_16pixels,decode_high_line,decode_falcon_16pixels)

stres2lines
	dta	BUFFER_STLINES,BUFFER_STLINES,BUFFER_STLINES,BUFFER_STLINES/2

set_palette_st2vbxe
:8	dta	$22*#
:8	dta	$22*#+$11

dunegraph_expected_header
	dta	c'DGU',1,h(320),l(320),h(200),l(200)

xdl
	dta	a($24)	; XDLC_OVOFF|XDLC_RTPL
	dta	b(19)	; 20 lines top border (VBXE screen is 240 lines)
xdl_1
	dta	a($8062) ; XDLC_GMON|XDLC_RTPL|XDLC_OVADR|XDLC_END
xdl_2
	dta	b(0)	; goes up to 199 (200 lines)
	dta	a(scr_vbxe&$ffff),b(scr_vbxe>>16),a(320)
xdl_len	equ	*-xdl

vbxe_not_found_txt
	dta	c'This program requires VBXE FX v1.2x!',$9b
no_filename_txt
	dta	c'Specify filename in the command line',$9b
unknown_format_txt
	dta	c'Unknown file format',$9b
io_error_txt
	dta	c'I/O error',$9b
format_error_txt
	dta	c'Invalid file',$9b

keyboard_device
	dta	c'K:',$9b
editor_device
	dta	c'E:',$9b
filename
;	dta	c'H:STPAD.PI1',$9b
;	dta	c'H:BG_PIC.PI2',$9b
;	dta	c'H:DEVGEM7.PI3',$9b
;	dta	c'H:ELMRSESN.DOO',$9b
;	dta	c'H:14TOURN.NEO',$9b
;	dta	c'H:ELMRSESN.NEO',$9b
;	dta	c'H:MEDRES.NEO',$9b
;	dta	c'H:CHEERS.PI9',$9b
;	dta	c'H:ONE_MAN.DG1',$9b

buffer	org	*+BUFFER_LEN
st_palette	equ	buffer+2

	run	main
	end

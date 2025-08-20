; Mandelbr8 (6502 version).
; DDT's fixed-point Mandelbrot 8-bit generator.
;
; https://github.com/0x444454/mandelbr8
;
; Use MADS Assembler.
;
; Revision history [authors in square brackets]:
;   2024-11-07: First simple test loop. [DDT]
;   2024-11-10: Added Q5.9 squares table for speedup. [DDT]
;   2024-12-02: Minor bugs fixed. [DDT]
;   2025-02-13: Changed format to Q5.11 for increased zoom range. Fixed comments. [DDT]

	org $1800   ; Atari XL/XE

main:
        ; Disable interrupts.
        SEI

        ; Disable IRQs.
        ;LDA #$00
        ;STA $D20E           ; IRQEN
        ; Disable NMIs
        LDA #$00
        STA $D40E           ; NMIEN

        ; Copy charset ($E000–$E3FF) from ROM to RAM.
        LDX #0
@       LDA $E000,X
        STA $1000,X
        LDA $E100,X
        STA $1100,X
        LDA $E200,X
        STA $1200,X
        LDA $E300,X
        STA $1300,X
        INX
        BNE @-

        ; Point to copied charset.
        LDA #$10
        STA $D409           ; CHBASE

        ; Now disable ROMs.
        LDA $D301           ; PORTB
        AND #%11111110      ; Clear bit 0 to disable OS ROM.
        ORA #%10000010      ; Set bits 1 to disable BASIC ROM. Set bit 7 ti disable Self-Test ROM.
        STA $D301
        ; All system ROMs disabled. We still have hw regs at $D000-D7FF.

        ; Replace NMI vector.
        LDA #<atari_NMI
        STA $FFFA
        LDA #>atari_NMI
        STA $FFFB
        ; Replace IRQ vector.
        LDA #<atari_IRQ
        STA $FFFE
        LDA #>atari_IRQ
        STA $FFFF

        ;LDA #$00            ; Clear Pokey SKCTL
        ;STA $D20F           ; SKCTL
        ;LDA #$03            ; Then Set to $03
        ;STA $D20F           ; SKCTL

        ; Disable ANTIC DMA
        LDA #$00            ; Disable display list DMA.
        STA $D400           ; DMACTL

        ; Copy new display list for text (lo-res).
        LDX #0
@       LDA atari_DL_text,X
        STA $1400,X
        INX
        CMP #$41            ; This is the jump.
        BNE @-
        LDA #$00            ; Set jump address.
        STA $1400,X
        LDA #$14
        STA $1401,X

        ; Copy new display list for bitmap (hi-res).
        LDX #0
@       LDA atari_DL_bitmap,X
        STA $1500,X
        CMP #$0F            ; Do we need to expand the template ?
        BEQ @+
        INX
        CMP #$41            ; Stop at the ANTIC jump (end), in case we don't find the expansion point.
        BNE @-
        BEQ done_expansion  ; If we are here, we did not find the expansion point.
@       ; Expand template and complete display list.
        LDA #$0F
        LDY #99             ; Define 99 lines before we need a LMS to hop the 4 KB boundary.
exp_0:  STA $1500,X
        INX
        DEY
        BNE exp_0
        LDA #$4F             ; Line 100: Time for a LMS.
        STA $1500,X
        INX
        LDA #$00             ; Line 100 ptr LO
        STA $1500,X
        INX
        LDA #(>BITMAP_START)+$10 ; Line 100 ptr HI
        STA $1500,X
        INX
        LDA #$0F
        LDY #99             ; Other 99 lines for a total of 200.
exp_1:  STA $1500,X
        INX
        DEY
        BNE exp_1
done_expansion:
        LDA #$41            ; ANTIC Jump
        STA $1500,X
        LDA #$00            ; Set jump address.
        STA $1501,X
        LDA #$15
        STA $1502,X

        ; Set new display list for text (lo-res).
        LDA #$00            ; Low byte of display list address
        STA $D402           ; Store in DLISTL
        LDA #$14            ; High byte of display list address
        STA $D403           ; Store in DLISTH
        ; Enable ANTIC DMA
        LDA #$22            ; Enable display list DMA (and set normal playfield mode).
        STA $D400           ; DMACTL

        ; Enable NMIs
        LDA #$C0
        STA $D40E           ; NMIEN

        ; Enable IRQs
        ;LDA #$F7
        ;STA $D20E           ; IRQEN

        ; Set border color.
        LDA #$00
        STA COL_BORDER


        ; Initialize unsigned mul tables. This is required also by "`", so do it now.
        JSR mulu_init

        ; Print intro message (first message printed must start with $93=CLS).
        LDA #<str_intro
        STA str_ptr
        LDA #>str_intro
        STA str_ptr+1
        JSR print_str

no_C128:

        ; Print wait msg.
        LDA #<str_wait
        STA str_ptr
        LDA #>str_wait
        STA str_ptr+1
        JSR print_str


        ; Only build squares table if we have at least 64 KB RAM.

        ; Initialize Q4.10 squares table.
        JSR init_squares_q4_10

        ; Enable special GTIA mode (16 luma).
        LDA $D01B
        AND #$3F
        ORA #%01000000       ; Set the GTIA mode bits (7-6) for 1 color / 16 luma.
        STA $D01B            ; PRIOR

        ; Customize the first 16 characters to display solid luma patterns (2x8 pixels).
        LDA #%00000000
        LDX #$00
nxt_char_pattern:
        LDY #8               ; Fill all 8 char lines.
@       STA $1000,X
        INX
        DEY
        BNE @-
        CLC
        ADC #%00010001       ; Go to next pattern (2 pixels per char line).
        BCC nxt_char_pattern

        ; Enter main Mandelbrot code.
        JSR Mandelbrot
exit:
        ; We'll never get back to here.
        ; We can't return to BASIC, as we have messed up the system quite good.
        ; Besides, there is no QUIT button ;-)
        RTS


;==============================================================
; Strings
str_intro:
        .byte $93 ;Clear screen.
        ;dta c $0D, '..!? 012349 ABC abcdefghijklmnop' ; Used for testing.
        dta $0D
        dta c 'ddt''s fixed-point mandelbrot', $0D
        dta c 'version 2025-03-29', $0D
        ;dta c 'https://github.com/0x444454/mandelbr8', $0D
        .byte $00

str_wait:
        dta c 'please wait...', $0D
        .byte $00

str_press_space:
        dta  $0D, c'press ''c'' to switch mono/color mode.', $0D
        dta c 'press ''space'' to start...', $0D
        .byte $00

;==============================================================
; Atari stuff

; Atari display list for text mode (lo-res).
atari_DL_text:
    :3 dta $70              ; Blank 8 lines.
    .byte      $42              ; ANTIC mode 2 (40x25), 1 line + set ptr.
    .byte      <SCR_RAM         ; SCR_RAM LO
    .byte      >SCR_RAM         ; SCR_RAM HI
    :24 dta $02              ; ANTIC mode 2 (40x25), 24 more lines.
    .byte      $41              ; Jump and wait for vertical blank.
    .byte      <atari_DL_text   ; Jump address LO
    .byte      >atari_DL_text   ; Jump address HI

; Atari display list for text mode (hi-res).
atari_DL_bitmap:
    :3 dta $70              ; Blank 8 lines.
    .byte      $4F              ; ANTIC mode F.1 (80x200), 1 line + set ptr.
    .byte      <BITMAP_START    ; bitmap LO
    .byte      >BITMAP_START    ; bitmap HI
    dta $0F              ; ANTIC mode F.1 (80x200), 199 more lines.
                                ; NOTE: Just one line in this template. We'll expand it during copy.
    .byte      $41              ; Jump and wait for vertical blank.
    .byte      <atari_DL_bitmap ; Jump address LO
    .byte      >atari_DL_bitmap ; Jump address HI

; Atari NMI routine.
atari_NMI:
        INC frame_couter
        RTI

frame_couter: .byte 0

; Atari IRQ routine.
atari_IRQ:
        INC $401
        RTI

;------------- system & configs -------------

  SCR_RAM      = $0400 ; Video matrix.
  COL_RAM      = $0400 ; ?
  COL_BORDER   = $D01A ; COLBK (border is same as background).
  COL_BGND     = $D01A ; ?
  LORES_W      = 40
  LORES_H      = 25
  HIRES_W      = 80
  HIRES_H      = 200
  HIRES_TILE_W = 2
  HIRES_TILE_H = 8
  BITMAP_START = $2060 ; Bitmap starts at $2060 to allow hitting $3000 exactly in the middle of the screen (ANTIC 4KB limitation).


; The following is a bitmask, for faster checks.
MODE_VIC      =   $01       ; VIC-like video. E.g. VIC, VIC-II, TED, PET, et cetera.
MODE_KAWARI   =   $02
MODE_VDC      =   $04
MODE_BEEB     =   $08

mode:           .byte MODE_VIC  ; Default to VIC mode.
res:            .byte 0         ; 0 if text/lo-res, 1 if hi-res. Default to text/lo-res.

;------------- print routine (no Kernal was harmed in the making of this routine) -------------
; Print zero-terminated string pointed to by (str_ptr), max 255 chars.
; This routine trashes registers and changes (str_ptr).
print_str:

pr_ch:
        LDY #0             ; Clear index.
        LDA (str_ptr),Y    ; Load the next char from the message.
        BNE pr_no_EOS
        ; If character is 0 (end of string), return.
        RTS

pr_no_EOS:
        CMP #$0D           ; <CR>
        BNE pr_no_CR
        LDA #0
        STA cursor_x
        INC cursor_y
        JSR calc_scr_addr
        JMP done_char
pr_no_CR:
        CMP #$93           ; <CLS>
        BNE pr_no_CLS

        JSR clear_screen

        ; End clear screen. Reset cursor.
        LDA #$00
        STA cursor_x
        STA cursor_y
        JSR calc_scr_addr
        JMP done_char

pr_no_CLS:

        asl		; atascii to internal
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror

        LDY #$00

        ; Other machines.
        STA (scr_ptr),Y


done_char_move_pos:
        INC cursor_x
        INC scr_ptr
        BNE @+
        INC scr_ptr+1
@
done_char:
        INC str_ptr         ; Increase char*.
        BNE @+
        INC str_ptr+1
@       JMP pr_ch
pr_end:
        RTS


calc_scr_addr:
        ; Default to 40 columns. Mul by 40.
        LDA #40
        STA x0

        LDA cursor_y
        STA y0
        LDA #$00           ; 256x256 chars will be enough for everyone...
        STA x1
        STA y1
        JSR multiply_16bit_unsigned
        ; Y-offset is in [z0..z1].
        LDA z0
        CLC
        ADC cursor_x
        STA scr_ptr
        LDA #$00
        ADC z1
        ADC #>SCR_RAM
        STA scr_ptr+1
        RTS

cursor_x:   .byte 0
cursor_y:   .byte 0


;------------- clear screen -------------
clear_screen:

        LDA mode
        AND #MODE_VIC | MODE_KAWARI
        BEQ no_vic2_or_kawari
        LDX #$00

        LDA #$20 ; Use spaces.

@       STA SCR_RAM,X
        STA SCR_RAM+$100,X
        STA SCR_RAM+$200,X
        STA SCR_RAM+$300,X

        INX
        BNE @- ; Print till zero term or max 256 chars.
        ; Clear attribs (and some more) to white.
        LDX #$00
        LDA #$00 ; Atari: Black.

@       STA COL_RAM,X
        STA COL_RAM+$100,X
        STA COL_RAM+$200,X
        STA COL_RAM+$300,X
        INX
        BNE @- ; Print till zero term or max 256 chars.

        RTS

no_vic2_or_kawari:
        RTS

;------------- Switch lo/hi res -------------
; Note: Not all platforms support switching.
; Output: Z = 0 if mode switch succeeded (use BNE to branch on success).
; Clobbered: A, X
switch_res:
        LDA res
        TAX             ; Save to revert on error.
        EOR #$01        ; Toggle resolution.
        STA res
        JSR apply_mode
        BNE @+          ; Success.
        STX res         ; ERROR: Revert res.
@       RTS

;------------- Apply mode -------------
; Configure machine based on current mode and resolution setting.
; Output: Z = 0 if mode switch succeeded (use BNE to branch on success).
; Clobbered: A, X
apply_mode:
        LDA #$14            ; High byte of display list address (default to lo-res).
        LDX res
        BNE @+
        JMP switch_display_list
@       ; ATARI hi-res
        ; Copy lo-res image to hi-res.
        LDA #40
        STA num_tiles_w
        LDA #25
        STA num_tiles_h
        LDA #<SCR_RAM
        STA scr_ptr
        LDA #>SCR_RAM
        STA scr_ptr+1
        LDA #<BITMAP_START
        STA bmp_ptr
        LDA #>BITMAP_START
        STA bmp_ptr+1
        LDY #0
        LDA #0
        STA tiley
cpy_nxt_lr_tile_row:
        LDA #0
        STA tilex
cpy_nxt_lr_tile:
        LDA (scr_ptr),Y
        ROL
        ROL
        ROL
        ROL
        AND #$F0
        STA (bmp_ptr),Y
        LDA (scr_ptr),Y
        AND #$0F
        ORA (bmp_ptr),Y
        STA (bmp_ptr),Y
        STA tmp_bmp_line   ; Save value to store in this tile.
        LDA bmp_ptr
        PHA
        LDA bmp_ptr+1
        PHA
        LDX #7              ; Write value to the remaining 7 tile lines.
cpy_t_line:
        LDA bmp_ptr
        CLC
        ADC num_tiles_w     ; This is a linear buffer, skip down one line.
        STA bmp_ptr
        LDA bmp_ptr+1
        ADC #0
        STA bmp_ptr+1
        LDA tmp_bmp_line
        STA (bmp_ptr),Y
        DEX
        BNE cpy_t_line
        PLA
        STA bmp_ptr+1
        PLA
        STA bmp_ptr
        INC scr_ptr
        BNE @+
        INC scr_ptr+1
@       TXA
        PHA
        INC tilex
        JSR bmp_to_next_tile
        PLA
        TAX
        LDA tilex
        CMP num_tiles_w
        BNE cpy_nxt_lr_tile
        ; Copied a tile row.
        INC bmp_ptr
        BNE @+
        INC bmp_ptr+1
@       INC tiley
        LDA tiley
        CMP num_tiles_h
        BNE cpy_nxt_lr_tile_row
        ; Done copying. Reset tilex and tiley.
        LDA #$00
        STA tilex
        STA tiley
        ; Set hi-res display list.
        LDA #$15
switch_display_list:
        ; Disable ANTIC DMA
        LDX #$00            ; Disable display list DMA.
        STX $D400           ; DMACTL
        ; Switch display list.
        STA $D403           ; Store in DLISTH
        ; Enable ANTIC DMA
        LDA #$22            ; Disable display list DMA.
        STA $D400           ; DMACTL
        LDA #1              ; Return OK
        JMP end_applymode

end_applymode:
;ee: LDA res
;    BNE ee
        RTS

tmp_bmp_line: .byte 0


;------------- Clear bitmap -------------
; Clear the bitmap ($2000 to $3FFF). That works for Atari too (bitmap starts at $2060).
; Clobbered: A, X
clear_bitmap:
        LDA #$20
        STA str_ptr+1
        LDA #$00
        STA str_ptr
        LDX #$00
@
        STA (str_ptr,X)
        INC str_ptr
        BNE @-
        INC str_ptr+1
        LDA str_ptr+1
        CMP #$40
        BNE @-
        RTS

;------------- Clear iters histogram -------------
clear_histogram:
        LDA #$00
        LDX #16       ; Colors histogram is 16 bytes.
@       STA b_hist,X
        DEX
        BNE @-
        RTS

;------------- Build histogram -------------
; Build the color histogram from the content of iterations buffer.
; Only the first 4 bits of iter are used (mod16), so the histogram takes 16 bytes.
build_histogram:
        JSR clear_histogram
        LDA #<buf_iters_hr
        STA buf_it_ptr
        LDA #>buf_iters_hr
        STA buf_it_ptr+1
        LDY #0
@       LDA (buf_it_ptr),Y
        AND #$0F          ; Mod16.
        TAX
        INC b_hist,X
        INY
        CPY buf_tile_size
        BNE @-
        RTS

;------------- Scan histogram -------------
; Find the 4 most used colors (mod16), and store them sorted in h_top_idx (higher to lower).
; NOTE: Black (color 0) is not counted, as it is the fixed background color (and always available).
; NOTE: This is probably overkill, as we only need 3 colors + black (fixed background).
scan_histogram:
        ; Clear results.
        LDA #$00
        ; Clear top counts.
        STA h_top_cnt
        STA h_top_cnt+1
        STA h_top_cnt+2
        STA h_top_cnt+3
        ; Y is the result index (0 to 4).
        LDY #0
find_next:
        ; Scan all 16 entries.
        LDA #0
        STA h_top_cnt,Y         ; Highest count found.
        STA h_top_idx,Y         ; Index of highest found.
        LDX #15                 ; Start with color 15 (down to 1).
@       LDA b_hist,X            ; Fetch color count.
        CMP h_top_cnt,Y         ; Is this color more used than current most used ?
        BCC @+                   ; BLT.
        ; Higher or equal found.
        STA h_top_cnt,Y         ; Update highest count.
        STX h_top_idx,Y         ; Update index of highest count.
@       DEX
        BNE @-1                   ; Stop at color 1, avoiding 0 (black) as the background color is always available.
        ; Found the index. Zero its histogram count, so we won't parse it again.
        LDA h_top_idx,Y
        TAX
        LDA #$00
        STA b_hist,X
        ; Find next.
        INY
        CPY #4
        BNE find_next
        RTS


;------------- Render tile (ATARI version) -------------
; Render a hi-res tile in ATARI mode F.1 (2x8 pixels per tile).
; Note that this is a linear format (40 bytes per line).
;
render_tile_ATARI:
        ; Save bmp_ptr
        LDA bmp_ptr
        PHA
        LDA bmp_ptr+1
        PHA
        ; Simply use the 2x8 iters buffer as colors (Mod16).
        ; bmp_ptr contains the current tile bitmap line (2 pixels, 4 bits each).
        ; buf_it_ptr is the per-pixel iterations buffer.
        LDA #<buf_iters_hr
        STA buf_it_ptr
        LDA #>buf_iters_hr
        STA buf_it_ptr+1
        LDY #0           ; Current tile pixel [0..16].
        LDX #0
nxt_tile_line_A:
        ; Each tile line contains two pixels.
        ; Fetch pixel iters and convert to color.
        LDA (buf_it_ptr),Y
        ROL @
        ROL @
        ROL @
        ROL @
        AND #$F0
        STA (bmp_ptr,X)
        INY
        LDA (buf_it_ptr),Y
        AND #$0F         ; Mask.
        ORA (bmp_ptr,X)
        STA (bmp_ptr,X)
        INY
        ; End of tile bitmap line (2 pixels).
        CLC
        LDA bmp_ptr
        ADC num_tiles_w   ; This is a linear buffer, skip down one line.
        STA bmp_ptr
        LDA bmp_ptr+1
        ADC #0
        STA bmp_ptr+1
        CPY #HIRES_TILE_W*HIRES_TILE_H
        BNE nxt_tile_line_A
        ; Retreive bmp_ptr.
        PLA
        STA bmp_ptr+1
        PLA
        STA bmp_ptr
        JSR bmp_to_next_tile
        RTS

halves_countdown:   .byte 0
line_countdown:     .byte 0
tmp_conv:           .byte 0


;==============================================================


;------------- Mandelbrot calculation -------------

        org $4000

Mandelbrot:
        FPREC = 11          ; Fixed-point precision.

        ; Max iters
        LDA #16
        STA max_iter


	; All other machines.
	; Default coordinates.
        start_ax = 61030	;-2.2*(1<<FPREC)
        ; Center vertically for 200 lines displays.
        start_ay = 2560		; 1.25*(1<<FPREC)


        LDA #<start_ax
        STA ax
        LDA #>start_ax
        STA ax+1

        LDA #<start_ay
        STA ay
        LDA #>start_ay
        STA ay+1

        ; Set default lo-res increments, depending on mode.
        LDA #0
        STA incx_lr+1
        STA incy_lr+1
        LDA mode
        AND #MODE_VIC | MODE_KAWARI | MODE_BEEB
        BEQ @+
        LDA #192            ; Must be a multiple of 8 to keep lo-res and hi-res aligned.
        STA incx_lr
        STA incy_lr

        JMP done_incs
@       LDA mode
        CMP #MODE_VDC
        BNE @+
        LDA #96            ; Must be a multiple of 8 to keep lo-res and hi-res aligned.
        STA incx_lr
        STA incy_lr
        JMP done_incs
@       ; Unknown/unhandled mode.
done_incs:


first_pass:
        ; First pass is lo-res.
        ; Configure incs for first pass depending on video mode.
        LDA #0
        STA res           ; lo-res
        STA buf_tile_size ; 0 means screen size or none (depending on video mode).

calc_image:
        LDA #0
        STA res
        STA tilex
        STA tiley
        ; Configure graphics subystem.
        JSR apply_mode
        JSR clear_screen

nxt_pass:
        ; Preset incs for lo-res.
        LDA incx_lr
        STA incx
        LDA incx_lr+1
        STA incx+1
        LDA incy_lr
        STA incy
        LDA incy_lr+1
        STA incy+1
        ; Reset tile num.
        LDA #0
        STA tile_num
        STA tile_num+1
        STA screenw+1
        STA screenh+1
        ; Handle mode-dependent params.
        LDA mode
        AND #MODE_VIC | MODE_KAWARI | MODE_BEEB ; Check for VIC2 and similar chips.
        BNE @+
        JMP no_VIC2ish_setup

        ;------ VIC2
@       LDA res
        BNE hi_res
        ; Lo-res. One single (LORES_W x LORES_H) tile.
        LDA #1
        STA num_tiles_w
        STA num_tiles_h
        LDA #LORES_W

        STA screenw
        STA tilew
        LDA #LORES_H
        STA screenh
        STA tileh
        ; In low-res we might want to also set Screen RAM (e.g. PET machines).
        LDA #<SCR_RAM
        STA sram_ptr
        LDA #>SCR_RAM
        STA sram_ptr+1
        ; In lo-res we write directly to Color RAM after calculating a pixel.
        LDA #<COL_RAM
        STA cram_ptr
        LDA #>COL_RAM
        STA cram_ptr+1
        JMP first_tile

hi_res:
        ; Hi-res mode second-pass.
        ; Set tile width and height.
        LDA #<BITMAP_START
        STA bmp_ptr
        LDA #>BITMAP_START
        STA bmp_ptr+1
        LDA #HIRES_W
        STA screenw
        LDA #HIRES_H
        STA screenh
        LDA #0
        STA screenw+1
        STA screenh+1
        LDA #LORES_W
        STA num_tiles_w
        LDA #LORES_H
        STA num_tiles_h
        LDA #HIRES_TILE_W
        STA tilew
        LDA #HIRES_TILE_H
        STA tileh
        LDA #HIRES_TILE_W*HIRES_TILE_H ; Pixels per tile.
        STA buf_tile_size
        ; Update incs for second-pass.

        LDX #1        ; Rotate twice to divide lo-res incx by 2.

@       CLC
        ROR incx+1
        ROR incx
        DEX
        BNE @-
        LDX #3        ; Rotate thrice to divide lo-res incy by 8.
@       CLC
        ROR incy+1
        ROR incy
        DEX
        BNE @-
        LDA incy
        BNE @+
        ; Zoomed-in too much, set minimum incs.
        LDA #1
        STA incy
        ASL
        STA incx
@
        ; Sub|add half lo-res pixel to ax|ay, to use previously calculated lo-res iter as centroid iter.
        LDA incx_lr
        TAX
        CLC
        ROR incx_lr
        LDA ax
        SEC
        SBC incx_lr
        STA ax
        LDA ax+1
        SBC #0
        STA ax+1
        STX incx_lr
        LDA incy_lr
        CLC
        ROR
        CLC
        ADC ay
        STA ay
        LDA ay+1
        ADC #0
        STA ay+1
        JMP first_tile

no_VIC2ish_setup:

first_tile:
        LDA ax
        STA t_ax
        LDA ax+1
        STA t_ax+1
        LDA ay
        STA t_ay
        LDA ay+1
        STA t_ay+1

nxt_tile:       ; A tile is the entire screen if not using a tiled hi-res video mode.
        ; Check if we can skip this tile.
        LDA res
        BEQ no_skip         ; Can't skip in lo-res.
        JSR check_skippable ; Sets Z if skippable.
        BNE no_skip
        ; Skip tile.
        JSR bmp_to_next_tile   ; Update bmp_ptr to point to next tile.
        JMP go_to_next_tile    ; Skip this tile.

no_skip:
        LDA #0              ; Reset cur pixel pos in tile.
        STA pixelx
        STA pixely

        ; (cx, cy) is our current point to calculate.
        ; Start with upper left point of tile (t_ax, t_ay).
        LDA t_ax
        STA cx
        LDA t_ax+1
        STA cx+1

        LDA t_ay
        STA cy
        LDA t_ay+1
        STA cy+1

        ; Setup the iterations buffer for this tile.
        LDA res
        BNE @+
        ; Use lo-res iterations buffer.
        LDA #<buf_iters_lr
        STA buf_it_ptr
        LDA #>buf_iters_lr
        STA buf_it_ptr+1
        JMP done_it_buf
@       ; Use hi-res iterations buffer.
        LDA #<buf_iters_hr
        STA buf_it_ptr
        LDA #>buf_iters_hr
        STA buf_it_ptr+1
        JMP done_it_buf
done_it_buf:

; Calculate current point (cx, cy).
calc_point:
    ;INC $D020
        LDA #0   ; Reset iteration counter.
        STA iter
        STA zx   ; Reset (zx, zy)
        STA zx+1
        STA zy
        STA zy+1

nxt_iter:
        JSR check_userinput
        BNE no_recalc    ; No recalculation needed.
        ; User input requires image recalc.
        JMP first_pass
no_recalc:
        ;   zx = zx + cx
        CLC
        LDA zx
        ADC cx
        STA zx
        LDA zx+1
        ADC cx+1
        STA zx+1

        ;   zy = zy + cy
        CLC
        LDA zy
        ADC cy
        STA zy
        LDA zy+1
        ADC cy+1
        STA zy+1

zx2_sw:
        LDA zx
        STA x0
        STA y0
        LDA zx+1
        STA x1
        STA y1

        ; Use squares table.
        JSR square_Q5_11

        LDA z1
        STA zx2
        LDA z2
        STA zx2+1
zx2_done:

        ; zy2 = zy * zy
        LDA zy
        STA x0
        STA y0
        LDA zy+1
        STA x1
        STA y1

        JSR square_Q5_11

        LDA z1
        STA zy2
        LDA z2
        STA zy2+1

        ; Check for divergence (zx2 + zy2 > 4.000).
        ; Note: In Q5.11 the number 4.000 = $2000. Check only zy2.
        CLC
        LDA zx2   ; Maybe not needed.
        ADC zy2   ; Maybe not needed.
        LDA zx2+1
        ADC zy2+1
        CMP #$20  ; Just check high byte.
        BCC @+     ; BLT
        JMP found_color ; Early exit (not black if >= 4.000).
@
        ; Before overwriting zx, set it for the next muls operation.
        LDA zx
        STA x0
        LDA zx+1
        STA x1

        ; zx = zx2 - zy2
        SEC
        LDA zx2
        SBC zy2
        STA zx
        LDA zx2+1
        SBC zy2+1
        STA zx+1

        ; zy = 2 * zx * zy
        LDA mode
        AND #MODE_KAWARI
        BEQ zxzy_sw
        ; Use Kawari hardware muls.
        LDA x0
        STA $D030       ; OP_1_LO
        LDA x1
        STA $D02F       ; OP_1_HI
        LDA y0
        STA $D032       ; OP_2_LO
        LDA y1
        STA $D031       ; OP_2_HI
        LDA #2          ; Kawari S_MULT operator.
        STA $D033       ; This triggers the operation.
        ; Result is immediately available.
        LDA $D031       ; RESULT_LH
        STA z1
        LDA $D030       ; RESULT_HL
        STA z2
        LDA $D02F       ; RESULT_HH
        STA z3
        JMP zxzy_done

zxzy_sw:
        ; No need to setup zx [x0,x1] and zy [y0,y1]. They are already there.
        JSR multiply_16bit_signed ; [z0..z3] = zx*zy <<22

zxzy_done:
        LDA z3       ; We need Q5.11, so discard z0 (8 bits) and shift-r twice (2 bits) to get 2*result <<11.
        CMP #$80     ; Set carry if result is negative.
        ROR z3
        ROR z2
        ROR z1
        CMP #$80     ; Set carry if result is negative.
        ROR z3
        ROR z2
        ROR z1       ; [z1..z2] = 2*zx*zy
        LDA z1
        STA zy
        LDA z2
        STA zy+1

        ; Inc iter and check max_iter.
        INC iter
        LDA iter
        CMP max_iter
        BEQ found_color_black ; Max iters reached.
        JMP nxt_iter

found_color_black:
        LDA #0              ; Max iters is always black
        STA iter
found_color:
        LDA iter
        LDY enable_buf_it
        BEQ skip_buf_it
        LDY #0
        STA (buf_it_ptr),Y  ; Save iters to pixel iterations buffer.
        INC buf_it_ptr
        BNE @+
        INC buf_it_ptr+1
@
skip_buf_it:

        ; If we are in hi-res mode, we do not set Color RAM here.
        LDA res
        BNE skip_ColorRAM

        ; Lo-res.
        LDA mode
        AND #MODE_VIC | MODE_KAWARI
        BEQ no_VIC2
        ; MODE_VIC
        LDA iter
        AND #$0F

        LDY #0
        STA (cram_ptr),Y  ; Set color
        INC cram_ptr
        BNE @+
        INC cram_ptr+1
@       JMP nxt_point
no_CRAM:
no_VIC2:



skip_ColorRAM:


; Go to nxt point in tile.
nxt_point:
        ; cx = cx + incx
        CLC
        LDA cx
        ADC incx
        STA cx
        LDA cx+1
        ADC incx+1
        STA cx+1

        ; Point to next pixel and check end of rows.
        INC pixelx
        LDA pixelx
        CMP tilew       ; WARNING: This currently requires tile width < 256.
        BEQ nxt_row     ; End of tile row.
        JMP calc_point

        ; Jump to next pixel row in tile.
nxt_row:
        ; cy = cy + incy
        SEC
        LDA cy
        SBC incy
        STA cy
        LDA cy+1
        SBC incy+1
        STA cy+1

        ; cx = t_ax
        LDA t_ax
        STA cx
        LDA t_ax+1
        STA cx+1

        LDA #0
        STA pixelx
        INC pixely
        LDA pixely
        CMP tileh      ; NOTE: This works only with tile height < 256.
        BEQ end_tile
        JMP calc_point

end_tile:
        ; End of tile.
        ; Check if we need to switch to hi-res mode (lo-res uses a single tile).
        LDA res
        BNE @+
        JMP switch_to_hires
@

        ; We have completed a hi-res tile, render it.

        JSR render_tile_ATARI


go_to_next_tile:
        ; Calc next tile.
        INC tile_num
        BNE @+
        INC tile_num+1
@       INC tilex
        LDA tilex
        CMP num_tiles_w
        BNE nxt_tile_in_row
        ; End of tile row, advance to next row.

        JSR bmp_to_next_tile    ; Needed on Atari to update linear bitmap pointer.

        INC tiley
        LDA tiley
        CMP num_tiles_h
        BEQ no_more_passes      ; Hi-res pass done. Image completed.

        LDA #0
        STA tilex
        LDA ax
        STA t_ax
        LDA ax+1
        STA t_ax+1

no_eotH_VDC:
        LDX #HIRES_TILE_H       ; Sub HIRES_TILE_H*incy to t_ay.
find_next_t_ay:
        SEC
        LDA t_ay
        SBC incy
        STA t_ay
        LDA t_ay+1
        SBC incy+1
        STA t_ay+1
        DEX
        BNE find_next_t_ay
        JMP done_tile_advance

nxt_tile_in_row:
        ; Advance to next tile in row.

no_eotW_VDC:
        LDX #HIRES_TILE_W         ; Add HIRES_TILE_W*incx to t_ax.
find_next_t_ax:
        CLC
        LDA t_ax
        ADC incx
        STA t_ax
        LDA t_ax+1
        ADC incx+1
        STA t_ax+1
        DEX
        BNE find_next_t_ax
done_tile_advance:

        JMP nxt_tile

;----------------- Switch to hires -----------------
; After lo-res pass, switch to hi-res for second pass.
switch_to_hires:
        JSR switch_res
        BEQ no_more_passes  ; Switch mode failed.
        JMP nxt_pass
no_more_passes:
        JSR check_userinput ; Check userinput.
        BNE wait_ui
        JMP first_pass      ; Recalculate new image.
wait_ui:
        JMP no_more_passes  ; Loop checking user input.

        RTS ; EXIT

; Variables in page 0 for faster access.
var_bytes   = $a0
iter        = var_bytes +  0
max_iter    = var_bytes +  1
num_tiles_w = var_bytes +  2  ; Number of tile on screen (horizontal).
num_tiles_h = var_bytes +  3  ; Number of tile on screen (vertical).
tilex       = var_bytes +  4  ; Current tile x position on screen.
tiley       = var_bytes +  5  ; Current pixel y position on screen.
pixelx      = var_bytes +  6  ; Current pixel x position in tile.
pixely      = var_bytes +  7  ; Current pixel y position in tile.
b_hist      = var_bytes +  8  ; Color histogram table start (indices are iters mod16).
b_hist_last = b_hist    + 16  ; Color histogram table end.
h_top_cnt   = b_hist_last     ; Color histogram top counts, max 4 entries (pixels).
h_top_idx   = h_top_cnt + 4   ; Color histogram top indices, max 4 entries (iters mod16).
b_END       = h_top_idx + 4   ; --------------


; Words
var_words   = b_END            ; Start of words.
;
buf_it_ptr  = var_words +  0   ; Pixel iterations buffer.
ax          = var_words +  2   ; Screen plane upper-left corner x (Q5.11).
ay          = var_words +  4   ; Screen plane upper-left corner y (Q5.11).
cx          = var_words +  6   ; Current plane point x (Q5.11).
cy          = var_words +  8   ; Current plane point x (Q5.11).
incx_lr     = var_words + 10   ; Lo-res pixel increment x (Q5.11).
incy_lr     = var_words + 12   ; Lo-res pixel increment y (Q5.11).
incx        = var_words + 14   ; Current pixel increment x (Q5.11).
incy        = var_words + 16   ; Current pixel increment y (Q5.11).
zx          = var_words + 18   ; zx (Q5.11).
zy          = var_words + 20   ; zy (Q5.11).
zx2         = var_words + 22   ; Squared zx (Q5.11).
zy2         = var_words + 24   ; Squared zy (Q5.11).
screenw     = var_words + 26   ; Screen width (pixels).
screenh     = var_words + 28   ; Screen height (pixels).
tilew       = var_words + 30   ; Tile width (pixels).
tileh       = var_words + 32   ; Tile height (pixels).
tile_num    = var_words + 34   ; Tile number (sequential).
squares     = var_words + 36   ; Squares table pointers (Q4.10*Q4.10 = Q5.11).
str_ptr     = var_words + 38   ; Current char of string to print.
scr_ptr     = var_words + 40   ; Curren screen pointer of string print routine.
bmp_ptr     = var_words + 42   ; Curren bitmap pointer (hi-res).
sram_ptr    = var_words + 44   ; Screen RAM ptr.
cram_ptr    = var_words + 46   ; Color RAM ptr.
t_ax        = var_words + 48   ; Current tile ax (upper-left corner x).
t_ay        = var_words + 50   ; Current tile ay (upper-left corner y).
;tmp_ptr     = var_words + 52   ; Temp pointer.



;------------- Check if the current hi-res tile is skippable -------------
; buf_it_ptr must point to the lo-res pixel to check in buf_iters_lr.
; Output: Set Z flag if tile is skippable (e.g. "BEQ skip").
check_skippable:
        ; Can't skip first tile in a row.
	LDX tilex
        BNE @+
        LDA #1      ; Reset Z flag.
        RTS
@       ; Can't skip last tile in a row.
        INX
        CPX num_tiles_w
        BNE @+
        LDA #1      ; Reset Z flag.
        RTS
@       ; Can't skip first tile in a col.
        LDX tiley
        BNE @+
        LDA #1      ; Reset Z flag.
        RTS
@       ; Can't skip last tile in a col.
        INX
        CPX num_tiles_h
        BNE @+
        LDA #1      ; Reset Z flag.
        RTS
@       ; Run skip heuristics.
        CLC
        LDA #<buf_iters_lr
        ADC tile_num
        STA buf_it_ptr
        LDA #>buf_iters_lr
        ADC tile_num+1
        STA buf_it_ptr+1
        LDY #0
        ; Get reference lo-res iters in this point.
    ;SEC
    ;SBC #>buf_iters_lr
    ;CLC
    ;ADC #$04
    ;JSR print_A_hex
    ;LSR
    ;LSR
    ;STA $03
    ;LDA buf_it_ptr
    ;ROR
    ;STA $02
        LDA (buf_it_ptr),Y
    ;STA ($02),Y
        TAX                ; Save iters.
        ; Dec buf_it_ptr, as indirect-indexed does not allow negative offsets.
        LDA buf_it_ptr
        BNE @+
        DEC buf_it_ptr+1
@       DEC buf_it_ptr
        TXA                ; Restore iters.
        ; Now compare to iters in other lo-res pixels at cardinal directions.
        ; Check WEST
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check EAST
        INY
        INY
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check northern neighbors.
        LDA buf_it_ptr
        SEC
        SBC num_tiles_w
        STA buf_it_ptr
        BCS @+
        DEC buf_it_ptr+1
@       TXA                 ; Restore iters.
        ; Check NORTH-EAST
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check NORTH
        DEY
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check NORTH-WEST
        DEY
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check southern neighbors.
        LDA num_tiles_w
        ASL                 ; num_tiles_w *= 2
        CLC
        ADC buf_it_ptr
        STA buf_it_ptr
        BCC @+
        INC buf_it_ptr+1
@       TXA                 ; Restore iters.
        ; Check SOUTH-WEST
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check SOUTH
        INY
        CMP (buf_it_ptr),Y
        BEQ @+
        RTS
@       ; Check SOUTH-EAST
        INY
        CMP (buf_it_ptr),Y
        ; Final check done. Z flag is set with final result.
        RTS


;------------- Set bitmap pointer to next tile -------------
; Clobbered: A, X
;
bmp_to_next_tile:

        LDX tilex
        CPX num_tiles_w
        BEQ b_end_of_row
        INC bmp_ptr
        BNE @+
        INC bmp_ptr+1
@
        RTS

b_end_of_row:
        LDX #HIRES_TILE_H-1
@       LDA bmp_ptr
        CLC
        ADC num_tiles_w
        STA bmp_ptr
        LDA bmp_ptr+1
        ADC #0
        STA bmp_ptr+1
        DEX
        BNE @-
        RTS

;=========================================================================
; Check for user input.
; We read the machine's main joystick signals and put them in A using this format:
;   A=[xxxFRLDU] : All bits are active low: Fire, Right, Left, Down, Up.
;
; Output: Set Z flag if image must be recalculated (e.g. BEQ recalc).
; Clobbered: A, X, Y
check_userinput:
        ; Read joy inputs and translate to common format.

        ; Atari joystick input.
        LDA $D300           ; PIA:PORTA[3..0] is joy-1 directions [R,L,D,U]. Active low.
        AND #$0F
        LDX $D010           ; GTIA:TRIG0[0] is joy-1 trigger. Active low.
        BEQ @+              ; We can do this because TRIG0[7..1] is always 0.
        ORA #$10
@
        CMP #$1F
        BNE yes_input
        ; No input.
        LDA #$01          ; Clear zero flag to signal no recalculation needed, and return.
        RTS

yes_input:
        TAX               ; Save joy input to X.
        ; Only process input at "human" time intervals.

        LDA frame_couter  ; Get

        AND #$F0          ; Time mask.
        CMP prev_timer    ; Compare to last-input masked time.
        BNE process_input
        RTS               ; Too soon.

process_input:
        ; We have some input.
        TAY				  ; Save masked time.
        ;INC COL_BORDER    ; Debug only.

        ; If any directions are pressed, then we have some action.
        TXA
        AND #$0F
        CMP #$0F
        BNE directions_pressed
        LDA #$01          ; Clear zero flag to signal no recalculation needed, and return.
        RTS


directions_pressed:
        STY prev_timer    ; Remember last-input masked time.
        TXA               ; Retrieve joy input from X.
        AND #$10
        BEQ fire          ; If bit 4 is 0, then fire is pressed.
        JMP no_fire

fire:
        ; Fire button pressed. Handle zoom.
        ; Note: We have almost no checks for precision underflow.
        ;       Let's call underflow a "user error" :-)
chk_zoom_IN:

    INCX_ZOOM_STEP = 4
    INCY_ZOOM_STEP = 4

        TXA                 ; Retreive joy input from X.
        AND #$01            ; Up
        BNE chk_zoom_OUT

        ; ZOOM IN.
        ; X
        LDA incx_lr+1
        STA incx_lr_prev+1
        LDA incx_lr
        STA incx_lr_prev
        SEC
        SBC #INCX_ZOOM_STEP
        STA incx_lr
        BCS @+
        ; Borrow.
        LDA incx_lr+1
        BEQ set_min_step    ; Negative step.
        DEC incx_lr+1
@       BNE @+
        ; incx_lr+1 == 0. Enforce min zoom-in step.
        LDA incx_lr
        CMP #INCX_ZOOM_STEP
        BCC set_min_step    ; BLT
@
        ; Y
        LDA incy_lr+1
        STA incy_lr_prev+1
        LDA incy_lr
        STA incy_lr_prev
        SEC
        SBC #INCY_ZOOM_STEP
        STA incy_lr
        BCS @+
        ; Borrow.
        LDA incy_lr+1
        BEQ set_min_step    ; Negative step.
        DEC incy_lr+1
@       BNE @+
        ; incy_lr+1 == 0. Enforce min zoom-in step.
        LDA incy_lr
        CMP #INCY_ZOOM_STEP
        BCC set_min_step    ; BLT
@
        JMP zoomin_recenter

set_min_step:
        LDA #0
        STA incx_lr+1
        STA incy_lr+1
        LDA #INCX_ZOOM_STEP
        STA incx_lr
        LDA #INCY_ZOOM_STEP
        STA incy_lr

zoomin_recenter:
        JSR recenter        ; This clobbers X.
        LDA incx_lr
        JSR print_A_hex
        JMP end_input

chk_zoom_OUT:
        TXA                 ; Retrieve input.
        AND #$02            ; Down
        BNE chk_iters_more

        ; ZOOM OUT
        LDA incx_lr+1
        STA incx_lr_prev+1
        LDA incx_lr
        STA incx_lr_prev
        CMP #241            ; Max zoom-out reached ?
        BCC @+              ; No, increase step.
        JMP end_input       ; Yes. Do nothing.

@       CLC
        ADC #INCX_ZOOM_STEP
        STA incx_lr
        BCC @+
        INC incx_lr+1
        CLC
@       LDA incy_lr+1
        STA incy_lr_prev+1
        LDA incy_lr
        STA incy_lr_prev
        ADC #INCY_ZOOM_STEP
        STA incy_lr
        BCC @+
        INC incy_lr+1
@       JSR print_A_hex
        JSR recenter        ; This clobbers X.
        JMP end_input

chk_iters_more:
        TXA                 ; Retrieve input.
        AND #$08            ; Right
        BNE chk_iters_less
        LDA max_iter
        CMP #255            ; Max 255 iters.
        BEQ end_zoomiters
        INC max_iter
        LDA max_iter
        JSR print_A_hex

chk_iters_less:
        TXA                 ; Retrieve input.
        AND #$04            ; Left
        BNE end_zoomiters
        DEC max_iter
        BNE @+
        LDA #2              ; Min iters is 2.
        STA max_iter
@       LDA max_iter
        JSR print_A_hex

end_zoomiters:
        ; Set zero flag if image must be recalculated.
        TXA
        AND #$0F
        CMP #$0F            ; Check if a joystick direction was pressed.
        BEQ no_dir
        LDA #$00
        RTS
no_dir:
        LDA #$FF
        RTS

no_fire: ;----- no fire button pressed
        ; Handle pan.
chk_pan_U:
        TXA                 ; Retrieve input from X.
        AND #$01            ; Up
        BNE chk_pan_D
        CLC
        LDA ay
        ADC incy
        STA ay
        LDA ay+1
        ADC incy+1
        STA ay+1
chk_pan_D:
        TXA                 ; Retrieve input.
        AND #$02            ; Down
        BNE chk_pan_L
        SEC
        LDA ay
        SBC incy
        STA ay
        LDA ay+1
        SBC incy+1
        STA ay+1
chk_pan_L:
        TXA                 ; Retrieve input.
        AND #$04            ; Left
        BNE chk_pan_R
        SEC
        LDA ax
        SBC incx
        STA ax
        LDA ax+1
        SBC incx+1
        STA ax+1
chk_pan_R:
        TXA                 ; Retrieve input.
        AND #$08            ; Right
        BNE end_input
        CLC
        LDA ax
        ADC incx
        STA ax
        LDA ax+1
        ADC incx+1
        STA ax+1


end_input:
        ;JSR print_A_hex
        ; Set zero flag to signal image must be recalculated.
        LDA #$00
        RTS

prev_timer:     .byte 0
input_scratch:  .byte 0

;===================================================================
; Recenter mandelbrot based on newly changed incx and incy.
; This will readjust ax and ay.
;
; Inputs:
;   prev_incx : Previous incx
;   prev_incy : Previous incy
;
; Outputs:
;   ax : New upper-left x coord bnased on current incx
;   ay : New upper-left y coord bnased on current incy

recenter:
        ; Calculate current complex plane width.
        LDA screenw
        STA x0
        LDA screenw+1
        STA x1
        LDA incx_lr
        STA y0
        LDA incx_lr+1
        STA y1
        JSR multiply_16bit_unsigned
        LDA z0
        STA pw_cur
        LDA z1
        STA pw_cur+1
        ; Calculate previous complex plane width.
        LDA incx_lr_prev
        STA y0
        LDA incx_lr_prev+1
        STA y1
        JSR multiply_16bit_unsigned
        LDA z0
        STA pw_prev
        LDA z1
        STA pw_prev+1

        ; Calculate current complex plane height.
        LDA screenh
        STA x0
        LDA screenh+1
        STA x1
        LDA incy_lr
        STA y0
        LDA incy_lr+1
        STA y1
        JSR multiply_16bit_unsigned
        LDA z0
        STA ph_cur
        LDA z1
        STA ph_cur+1
        ; Calculate previous complex plane height.
        LDA incy_lr_prev
        STA y0
        LDA incy_lr_prev+1
        STA y1
        JSR multiply_16bit_unsigned
        LDA z0
        STA ph_prev
        LDA z1
        STA ph_prev+1

        ; Compute diff.
        SEC
        LDA pw_prev
        SBC pw_cur
        STA pw_diff
        LDA pw_prev+1
        SBC pw_cur+1
        STA pw_diff+1
        SEC
        LDA ph_prev
        SBC ph_cur
        STA ph_diff
        LDA ph_prev+1
        SBC ph_cur+1
        STA ph_diff+1
        ; Divide diff by two.
        CMP #$80        ; Set carry if negative.
        ROR pw_diff+1
        ROR pw_diff
        CMP #$80        ; Set carry if negative.
        ROR ph_diff+1
        ROR ph_diff
        ; Add halved diff to ax.
        CLC
        LDA ax
        ADC pw_diff
        STA ax
        LDA ax+1
        ADC pw_diff+1
        STA ax+1
        ; Sub halved diff from ay (pixel vs plane coords are opposite on y-axis).
        SEC
        LDA ay
        SBC ph_diff
        STA ay
        LDA ay+1
        SBC ph_diff+1
        STA ay+1

        RTS

incx_lr_prev: .word 0
incy_lr_prev: .word 0
pw_cur:       .word 0
ph_cur:       .word 0
pw_prev:      .word 0
ph_prev:      .word 0
pw_diff:      .word 0
ph_diff:      .word 0


;===========================================================
; Print A as a hex number on the upper-left corner of the screen.
; NOTE: Registers are preserved.

print_A_hex:
        PHA        ; Save A.
        PHA        ; Save A.

        LSR
        LSR
        LSR
        LSR
        CMP #$0A
        BCS pA_alpha_0
        ; Not alpha, i.e. [0..9]
        ADC #$30 + 9
pA_alpha_0:
        SEC
        SBC #9
        STA nibble_char_h

nxt_nibble:
        PLA        ; Restore A.
        AND #$0F
        CMP #$0A
        BCS pA_alpha_1
        ; Not alpha, i.e. [0..9]
        ADC #$30 + 9
pA_alpha_1:
        SEC
        SBC #9
        STA nibble_char_l

        ; Output.
        LDA nibble_char_h
        STA SCR_RAM
        LDA nibble_char_l
        STA SCR_RAM+1

end_pAh:
        PLA        ; Restore A.
        RTS

nibble_char_h: .byte 0
nibble_char_l: .byte 0


;=============================================================
; Description: Signed Q4.10 fixed-point squares table.
; This is a 32KB table containing 16384 Q4.10 numbers (two bytes each).
; Only positive Q4.10 with even lowest bit are present.
; Table starts at $5000 and ends at $cfff

init_squares_q4_10:
        LDA #$00
        STA squares     ; Use a page 0 address.
        LDA #$50
        STA squares+1
        LDY #$00        ; Used for indirect indexed.
        STY x0          ; Start from 0.
        STY x1
        STY y0
        STY y1

@       JSR multiply_Q5_11_signed
        ; Result is in [z1..z2].
        LDA z1
        LDY #$00
        STA (squares),Y
        INC squares
        LDA z2
        STA (squares),Y
        INC squares
        BNE @+
        INC squares+1
@       INC x0      ; Skip odd numbers.
        INC x0
        INC y0
        INC y0
        BNE @-1
        INC x1
        INC y1
        LDA x1
        CMP #$80    ; Last entry is for number $7FFF.
        BNE @-1

squares_tab_complete:
        RTS

;===========================================================
; Description: Get the square of the given signed Q5.11 number using the signed Q4.10 squares table.
; NOTE: The square will be an approximation if the last bit is odd.
;
; Input: Q5.11 signed value in x0,x1
;
; Output: Approximated Q5.11 signed squared value in z1,z2

square_Q5_11:
        ; Check if negative.
        LDA x1
        BPL not_neg

        ; Convert to positive (exact).
        SEC
        LDA #$00
        SBC x0
        AND #$FE            ; Make even.
        STA squares
        LDA #$00
        SBC x1
        STA squares+1
        BPL fetch_square   ; Always positive (i.e. branch always).
not_neg:
        LDA x0
        AND #$FE            ; Make even.
        STA squares
        LDA x1
        STA squares+1
fetch_square:
        ; Fetch from table.
        CLC
        LDA squares+1
        ADC #$50            ; Table offset
        STA squares+1
        LDY #$00
        LDA (squares),Y
        STA z1
        INY
        LDA (squares),Y
        STA z2
        RTS

;==============================================================
; Description: Signed Q5.11 fixed-point multiplication with signed Q5.11 result.
; This uses the multiply_16bit_unsigned routine.
;
; Revision history [authors in square brackets]:
; 2024-11-07: First simple test loop. [DDT]
; 2025-02-13: Changed to Q5.11 [DDT]
;
; Input: Q5.11 signed value in x0,x1
;        Q5.11 signed value in y0,y1
;
; Output: Q5.11 signed value z1,z2
;
; Clobbered: X, A, C
multiply_Q5_11_signed:

        ; Step 1: signed multiply
        JSR multiply_16bit_signed
        ; Result is in z1,z2.

        ; Perform fixed point adjustment.
        ; We need to shift it right 11 bits, so just ignore z0 and shift right thrice the 24 bit value in z1,z2,z3.
        LDA z3
        CMP #$80        ; Set carry if result is negative.
        ROR z3
        ROR z2
        ROR z1

        CMP #$80        ; Set carry if result is negative.
        ROR z3
        ROR z2
        ROR z1

        CMP #$80        ; Set carry if result is negative.
        ROR z3
        ROR z2
        ROR z1

        RTS

buf_tile_size:  .byte 0      ; 0 means screen size or none (depending on mode).

enable_buf_it:  .byte 1

; Tile iterations buffers (lo-res and hi-res).

buf_iters_lr = $E000
buf_iters_hr = $E800



; ---------------- Signed 16x16=32 bits ----------------
; Revision history [authors in square brackets]:
;   2024-11-07: Original smult12 code taken from:
;    https://github.com/TobyLobster/multiply_test
;   2024-11-07: Adapted to TASS and Commodore 64. [DDT];
;
; smult12.a
; from smult3, but tweaked to use mult86 as a base
;
; 16 bit x 16 bit signed multiplication, 32 bit result
; Average cycles: 234.57
; 2210 bytes (including init routine)

; pointers to tables of squares
p_sqr_lo1    = $8b   ; 2 bytes
p_sqr_hi1    = $8d   ; 2 bytes
p_neg_sqr_lo = $8f   ; 2 bytes
p_neg_sqr_hi = $91   ; 2 bytes
p_sqr_lo2    = $93   ; 2 bytes
p_sqr_hi2    = $95   ; 2 bytes

; the inputs and outputs
x0  = p_sqr_lo1      ; multiplier, 2 bytes
x1  = p_sqr_lo2      ; [WARNING: note non-consecutive bytes!]
y0  = $04            ; multiplicand, 2 bytes
y1  = $05
z0  = $06            ; product, 4 bytes
z1  = $07            ;
z2  = $08            ;
z3  = $09            ;


;========================== MULTIPLICATION TABLES ==========================
; Must be aligned to page boundary.
;
MULT_TAB_ADDR = $4700

; First, check that code assembled didn't go past MULT_TAB_ADDR.
.if (Mandelbrot < MULT_TAB_ADDR) && (* > MULT_TAB_ADDR)
    .error 'Assembled code overrun over mult tab.'
.endif

; Note - the last byte of each table is never referenced, as a+b<=510
        org mult_tab_addr
sqrlo
	:512 .byte <((#*#)/4)

        org mult_tab_addr + $200
sqrhi
	:512 .byte >((#*#)/4)

        org mult_tab_addr + $400
negsqrlo
	:512 .byte <(((255-#)*(255-#))/4)

        org mult_tab_addr + $600
negsqrhi
	:512 .byte >(((255-#)*(255-#))/4)


; Description: Signed 16-bit multiplication with signed 32-bit result.
;
; Input: 16-bit signed value in x0,x1
;        16-bit signed value in y0,y1
;
; Output: 32-bit signed value in z0,z1,z2,z3
;
; Clobbered: X, A, C
multiply_16bit_signed:

    ; Step 1: unsigned multiply
    jsr multiply_16bit_unsigned

    ; Step 2: Apply sign (See C=Hacking16 for details).
    bit x1
    bpl x1_pos
    sec
;    lda z2
    sbc y0
    sta z2
    lda z3
    sbc y1
    sta z3
x1_pos:
    bit y1
    bpl y1_pos
    sec
    lda z2
    sbc x0
    sta z2
    lda z3
    sbc x1
    sta z3
y1_pos:

    rts


; mult86.a
; from 6502.org, by Repose: http://forum.6502.org/viewtopic.php?p=106519#p106519
;
; 16 bit x 16 bit unsigned multiply, 32 bit result
; Average cycles: 193.07 (including z1 and z2 results being saved to memory locations)

; How to use:
; call jsr init, before first use
; put numbers in (x0,x1) and (y0,y1) and result is (z3, z2 (also A), z1 (also Y), z0)

; Diagram of the additions
;                 y1    y0
;              x  x1    x0
;                 --------
;              x0y0h x0y0l
; +      x0y1h x0y1l
; +      x1y0h x1y0l
; +x1y1h x1y1l
; ------------------------
;     z3    z2    z1    z0

multiply_16bit_unsigned:
    ; set multiplier as x1
    lda x1
    sta p_sqr_hi1
    eor #$ff
    sta p_neg_sqr_lo
    sta p_neg_sqr_hi

    ; set multiplicand as y0
    ldy y0

    ; x1y0l =  low(x1*y0)
    ; x1y0h = high(x1*y0)
    sec
    lda (p_sqr_lo2),y
    sbc (p_neg_sqr_lo),y
    sta x1y0l+1
    lda (p_sqr_hi1), y
    sbc (p_neg_sqr_hi),y
    sta x1y0h+1

    ; set multiplicand as y1
    ldy y1

    ; x1y1l =  low(x1*y1)
    ; z3    = high(x1*y1)
    lda (p_sqr_lo2),y
    sbc (p_neg_sqr_lo),y
    sta x1y1l+1
    lda (p_sqr_hi1),y
    sbc (p_neg_sqr_hi),y
    sta z3

    ; set multiplier as x0
    lda x0
    sta p_sqr_hi2
    eor #$ff
    sta p_neg_sqr_lo
    sta p_neg_sqr_hi

    ; x0y1l =  low(x0*y1)
    ; X     = high(x0*y1)
    lda (p_sqr_lo1),y
    sbc (p_neg_sqr_lo),y
    sta x0y1l+1
    lda (p_sqr_hi2),y
    sbc (p_neg_sqr_hi),y
    tax

    ; set multiplicand as y0
    ldy y0

    ; z0    =  low(x0*y0)
    ; A     = high(x0*y0)
    lda (p_sqr_lo1),y
    sbc (p_neg_sqr_lo),y
    sta z0
    lda (p_sqr_hi2),y
    sbc (p_neg_sqr_hi),y

    clc
do_adds:
    ; add the first two numbers of column 1
x0y1l:
    adc #0      ; x0y0h + x0y1l
    tay

    ; continue to first two numbers of column 2
    txa
x1y0h:
    adc #0      ; x0y1h + x1y0h
    tax         ; X=z2 so far
    bcc @+
    inc z3      ; column 3
    clc

    ; add last number of column 1
@
    tya
x1y0l:
    adc #0      ; + x1y0l
    tay         ; Y=z1

    ; add last number of column 2
    txa
x1y1l:
    adc #0      ; + x1y1l
    bcc fin     ; A=z2
    inc z3      ; column 3
fin:
    sta z2      ; Added: save middle byte results from registers A,Y
    sty z1      ;
    rts

; Once only initialization
; (TODO: this could set up the pointer values in a loop to save memory
; it could also generate the square tables in code rather than load them)
mulu_init:
    lda #>sqrlo
    sta p_sqr_lo2+1
    sta p_sqr_lo1+1

    lda #>sqrhi
    sta p_sqr_hi1+1
    sta p_sqr_hi2+1

    lda #>negsqrlo
    sta p_neg_sqr_lo+1

    lda #>negsqrhi
    sta p_neg_sqr_hi+1
    rts

END_ADDRESS:

; -*- text -*-
;
; VBI and Display List Interrupts
;

@init_vbi
     lda VVBLKI
     sta store_vvblki
     lda VVBLKI+1
     sta store_vvblki+1

     jsr @stop_displaylist_interrupts

     LDA #6           ; use inferred(6) VBI
     LDY #<GAME_VBI
     LDX #>GAME_VBI
     JMP SETVBV

@stop_displaylist_interrupts
    lda #$40
    sta nmien_value
    rts


@start_displaylist_interrupts
    lda #$c0
    sta nmien_value
    rts

nmien_value
 .byte 0

store_vvblki
 .word 0

@deinit_vbi
     LDA #6         ; use inferred(6) VBI
     LDY store_vvblki
     LDX store_vvblki+1
     JMP SETVBV

;
; OO   OO OOOOO  OOOO
; OO   OO OO  OO  OO
; OO   OO OO  OO  OO
; OO   OO OOOOO   OO
; OO   OO OO  OO  OO
;  OO OO  OO  OO  OO
;   OOO   OOOOO  OOOO
;


GAME_VBI
     LDA #0
     STA 77              ; no colorswitch

     LDA #$0
     STA NMIEN           ; Displaylist Interrupt must not occur

     lda #3
     sta meter

; Show Game Screen
     LDA #<@displaylist  ; Game Screen
     STA SDLSTL
     LDA #>@displaylist
     STA SDLSTL+1

     LDA #<DLI
     STA VDSLST
     LDA #>DLI
     STA VDSLST+1

     LDA nmien_value
     STA NMIEN           ; Displaylist Interrupt are possible
     JMP SYSVBV


; OOOOO  OO     OOOO
; OO  OO OO      OO
; OO  OO OO      OO
; OO  OO OO      OO
; OO  OO OO      OO
; OO  OO OO      OO
; OOOOO  OOOOOO OOOO

DLI
 pha
 
 ift DEBUG

 lda #8               ; shows a gray line
 sta colbk
 
 eif


; Multi sprite interrupt, must be called every 8 screen lines (in gr.0 or gr.12 every Displaylist line!)

			stx regX


			ldx meter: #$00                 ; y position div 8

			lda block_x0,x			;player 0
			beq no_sprite0

			sta hposp0

			lda block_c0,x
			sta colpm0

no_sprite0
			lda block_x1,x			;player 1
			beq no_sprite1

			sta hposp1

			lda block_c1,x
			sta colpm1

no_sprite1
			lda block_x2,x			;player 2
			beq no_sprite2

			sta hposp2

			lda block_c2,x
			sta colpm2

no_sprite2
			lda block_x3,x			;player 3
			beq no_sprite3

			sta hposp3

			lda block_c3,x
			sta colpm3

no_sprite3
			lda #0			        ; clear the current block
			sta block_x0,x
			sta block_x1,x
			sta block_x2,x
			sta block_x3,x
			sta block_status,x

			inc meter

dli_end

	ldx regX: #$00

 ift DEBUG

 lda #0
 sta colbk

 eif

 pla
 rti

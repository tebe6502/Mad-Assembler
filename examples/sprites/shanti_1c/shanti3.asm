
	icl 'hardware.inc'
	icl 'variable.inc'

DEBUG = 1

MAX_SPRITES = 16

PM_X_OFFSET = 48
PM_Y_OFFSET = 32


	org $2000


; this Display list corresponds to a normal Graphics 0 display list, only with a lot of extra DLIs

@displaylist
 .byte DL_E8
 .byte DL_E8|DL_DLI
 .byte DL_E8|DL_DLI
 .byte DL_ADDRES|DL_GR0|DL_DLI
 .word $BC40
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI
 .byte DL_GR0|DL_DLI

; .byte DL_E8|DL_DLI
 .byte DL_LOOP
 .word @displaylist


main
	lda:cmp:req 20

	jsr @init_vbi
	jsr @start_displaylist_interrupts

	mva #scr40 sdmctl


	mva #$01 gprior

	mva #3 gractl

	mva >pmadr pmbase


	jsr @init_sprites


	.rept MAX_SPRITES
	lda #$0a+#*16
	sta @sprite_color+#

	lda #[#]
	sta @sprite_shape+#

	lda #PM_Y_OFFSET+#*8
	sta @sprite_y+#

	lda #PM_X_OFFSET+#*9
	sta @sprite_x+#
	.endr


lp	lda:cmp:req 20

	jsr @show_sprites
	
	lda 20
	and #3
	jne skp

	.rept 16
	
	inc @sprite_shape+#
	lda @sprite_shape+#
	and #$0f
	sta @sprite_shape+#
	
	.endr

skp
	;:16 inc @sprite_y+#


	jmp lp


	icl 'dli.asm'

	icl 'multi-sprite-multiplexer.asm'


	.align

data	ins 'shape\shape.bin'


.print 'end: ',*

	run main

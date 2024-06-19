
 .local

; a Atari Display list must be within a 1k range
 .align 1024

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

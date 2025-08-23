// https://github.com/sidneycadot/sam

; List of Atari addresses used in the Atari version of SAM.

; First half of page zero (0x00..0x7F): Operating System zero page addresses

         WARMST = $08           ; WARMSTART flag.
         POKMSK = $10           ; IRQEN shadow register.
         RTCLOK = $12           ; VBLANK clock (50/60 Hz).

; Second half of page zero (0x80..0xFF): BASIC zero page addresses

         VNTP   = $82           ; BASIC variable name table.
         VNTD   = $84           ; BASIC variable name table end.
         VVTP   = $86           ; BASIC variable value table.
         STARP  = $8C           ; BASIC string and array table.

; Pages two to five (0x200..0x5FF): operating system variables

         RUNAD  = $2E0          ; DOS run address.
         INITAD = $2E2          ; DOS initialization address.
         MEMLO  = $2E7          ; OS memory-low-boundary pointer.

; CARTRIDGE A (0xA000..0xBFFF): Atari BASIC

         BASIC  = $A000          ; BASIC entry point.

; CTIA / GTIA (0xD000 .. 0xD01F)

         CONSOL = $D01F         ; Speaker click.

; POKEY (0xD200..0xD20F)

         AUDC1 = $D201          ; Audio Channel #1 control.
         IRQEN = $D20E          ; IRQ enabled mask.

; ANTIC (0xD400..0xD40F)

         DMACTL = $D400         ; DMA enabled mask.
         NMIEN  = $D40E         ; NMI enabled mask.

; ----------------------------------------------------------------------------

	org $2000
	
	.link 'mads\sam_reloc.obx'

	.link 'mads\reciter_reloc.obx'

; ----------------------------------------------------------------------------

	org $0600

main
	jsr SAM_RUN_SAM_FROM_MACHINE_LANGUAGE

	ldy #0
cp	lda txt,y
	sta SAM_BUFFER,y
	cmp #$9b
	beq stop
	iny
	bne cp
stop
	jsr RECITER_VIA_SAM_FROM_MACHINE_LANGUAGE

loop	inc $d01a
	jmp loop

txt	dta c'SAM VERSION FOR MAD ASSEMBLER',$9b


	run main

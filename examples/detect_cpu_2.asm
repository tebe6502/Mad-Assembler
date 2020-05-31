* changes: 14.03.2005

/*

How to detect on which CPU the assembler code is running

(This information is from Draco, the author of SYSINFO 2.0)

You can test on plain 6502-Code if there is a 65c816 CPU, the 16-Bit processor avaible
in some XLs as a turbo-board, avaible. Draco told me how to do this:

First we make sure, whether we are running on NMOS-CPU (6502) or CMOS (65c02,65c816).
I will just show the "official" way which doesn`t uses "illegal opcodes":

*/

	opt c+
	org $2000

	jsr DetectCPU

	cim
	rts

;detekcja zainstalowanego procesora
DetectCPU
	lda #$99
	clc
	sed
	adc #$01
	cld
	beq DetectCPU_CMOS

DetectCPU_02
	printf
	.by '6502' $9b 0

	lda #0
        rts

DetectCPU_CMOS
	lda #0
	rep #%00000010		;wyzerowanie bitu Z
	bne DetectCPU_C816

DetectCPU_C02
        printf
        .by '65c02' $9b 0

	lda #1
        rts

DetectCPU_C816
        printf
        .by '65816' $9b 0

	lda #$80
        rts

	.link 'libraries/stdio/lib/printf.obx'

.proc InitConsole
		lda		#8
		sta		consol
		lda		#$ff
		sta		swchb
		sta		swcha
		rts
.endp

.proc UpdateConsole
		;copy start and select directly
		lda		consol
		eor		swchb
		and		#$03
		eor		swchb
		sta		swchb

		;use option to toggle B&W
		lda		consol
		tax
		and		#$04
		eor		#$04
		and		consol_prev
		stx		consol_prev
		beq		no_option

		lda		swchb
		eor		#$08
		sta		swchb

no_option:
		;check for keypress
		bit		irqst
		bvs		no_key

		lda		#0
		sta		irqen
		lda		#$40
		sta		irqen

		;get scan code
		lda		kbcode

		;1 -> toggle difficulty A
		cmp		#$1f
		bne		not_1
		lda		swchb
		eor		#$40
		sta		swchb
		jmp		no_key
not_1:
		;2 -> toggle difficulty B
		cmp		#$1e
		bne		not_2
		lda		swchb
		eor		#$80
		sta		swchb
		jmp		no_key
not_2:
no_key:
		;translate joysticks
		lda		porta
		lsr
		ror
		ror
		ror
		tax
		and		#$0f
		sta		temp
		txa
		ror
		and		#$f0
		ora		temp
		sta		swcha

		lda		trig0
		lsr
		ror
		sta		inpt4
		lda		trig1
		lsr
		ror
		sta		inpt5
		rts
.endp

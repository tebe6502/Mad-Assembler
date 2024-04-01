// MCP 160x200

// AUDF4 = 1 -> IRQ line x2

// IRQ split colors  (~14982 free proc cycles) !!! FAST !!!

// 07.06.2015 / 12.06.2018


	icl 'atari.hea'


height	 = 100

buf0	= $2010
buf1	= $4010

/*-------------------------------------------------------------------------------------------------*/

	org $80

regA	.ds 1
regX	.ds 1
regY	.ds 1
cnt	.ds 1
time	.ds 2

/*-------------------------------------------------------------------------------------------------*/

	.get 'monster.dat',-9		; palette

/*-------------------------------------------------------------------------------------------------*/

	org buf0
	ins 'monster.dat',0,8000

	org buf1
	ins 'monster.dat',$2800,8000

/*-------------------------------------------------------------------------------------------------*/

		.align $100
	dlist0:	dta d'pp',$10+$80
		dta $10				; 2 linie dla pierwszej zmiany koloru przez IRQ
		:200 dta $4e,a(buf0+#*40)
		dta $41,a(dlist1)

		.align $200
	dlist1:	dta d'pp',$10+$80
		dta $10
		:200 dta $4e,a(buf1+#*40)
		dta $41,a(dlist0)

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

main	lda:cmp:req 20

	sei

	mva	#$00	nmien
	sta	irqen

	sta time
	sta time+1
	
	mva	#$fe	portb

	mwa	#dlist0	dlptr		; poczatkowa klatka, potem juz ANTIC bedzie przelaczal katki

	mwa	#NMI	nmivec
	mwa	#IRQ1	irqvec		; setup custom IRQ handler

	mva	#0	SKCTL
	mva	#1	SKCTL

	mva	#1	AUDCTL		; 0=POKEY 64KHz, 1=15KHz

	mva	#0	AUDC4		; test - no polycounters + volume only
	mva	#1	AUDF4		; ~64KHz clock 16 = ~4Khz timer, ~15KHz clock 4 = ~4KHz

	mva	#$c0	nmien
	cli


loop	jsr delay	; 12

	lda time	; 3
	clc		; 2
	adc #1		; 2
	sta time	; 3
	lda time+1	; 3
	adc #0		; 2
	sta time+1	; 3

	jmp loop	; 3	= 33 cycle

delay	rts


/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

	.align

IRQ1	.local
	sta regA

_1	mva #.get[5] color0
	mva #.get[6] color1
	mva #.get[7] color2

	inc IRQEN
	
	#cycle #17

	mva #.get[1] color0
	mva #.get[2] color1
	mva #.get[3] color2

	lda regA
	rti
	.endl


IRQstop	mva #0 IRQEN

	lda regA
	rti


IRQ2	.local
	sta regA

_1	mva #.get[1] color0
	mva #.get[2] color1
	mva #.get[3] color2

	inc IRQEN

	#cycle #17

	mva #.get[5] color0
	mva #.get[6] color1
	mva #.get[7] color2

	lda regA
	rti
	.endl


NMI	bit nmist
	bpl vbl

dli0	sta ra
	stx rx
	
	lda vcount
	cmp #$6b
	bcc @+

	lda #0
	jmp IRQstp	
@
	;set IRQ position in scanline for consistency and disable keyboard scan
	mva		#0 skctl
	sta		wsync

	ldx		#20
	dex:rne
	sta		skctl
	sta		stimer
	lda		#1
	sta		skctl

	lda #4

IRQstp	sta IRQEN

	lda #0
ra	equ *-1
	ldx #0
rx	equ *-1

	rti

vbl	sta nmist
	sta regA
	stx regX
	sty regY

	mva #scr40	dmactl

	lda <IRQ1
irq	equ *-1
	eor #[<IRQ1]^[<IRQ2]
	sta irq
	sta irqvec

	mwa time $600
	mwa #0 time

	lda regA
	ldx regX
	ldy regY
	rti

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

	run main

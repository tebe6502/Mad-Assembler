
	icl 'atari.hea'

	org $80

regA	.ds 1


	org $2000

t6bit	ins 'draco_6bit.dat'

table1 = t6bit
table2 = table1 + $100
table3 = table2 + $100

main
	lda VCOUNT
	bmi *-3
	lda VCOUNT
	bpl *-3

	sei
	lda #0
	sta nmien
	sta dmactl
	sta irqen

	lda #$fe
	sta portb

	lda <irq
	sta irqvec
	lda >irq
	sta irqvec+1

	cli



	lda #%01000000
	sta AUDCTL

	mva #1 SKCTL				; init POKEY
	sta wsync
	sta wsync

;	mva	#52	AUDF1			; 32000

	mva	#36	AUDF1			; 44100

	mva	#$01	IRQEN			; enable timer

	sta	STIMER				; start timers

	jmp *



.local	irq
	sta regA

	lda #0
	sta IRQEN
	lda #1
	sta IRQEN

	lda table1
v1	equ *-2
	sta audc1

	lda table2
v2	equ *-2
	sta audc2

	lda table3
v3	equ *-2
	sta audc3


	lda data
smp	equ *-2
	sta v1
	sta v2
	sta v3

	inw smp

	lda regA

	rti
.endl


data	ins 'sfx.dat',1024


	run main



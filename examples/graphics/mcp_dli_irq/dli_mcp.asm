// Atari Interlaced Studio

// free cycle $01f7

// 255*23 + 27  (256*) = 5892 + 5681 = 11573 free CPU cycle

.enum	__ftype
mic, inp, ist, raw, mcp, mcpp, hip, rip, cin, hci, gr8, gr9, gr9p, g10, g11, plm, pzm, tip
.ende

ftype	= __ftype(RAW)

buf0	= $2010
buf1	= $4010
buf2	= $6000
buf3	= buf2+$600

colpm0	= $d012
colpm1	= $d013
colpm2	= $d014
colpm3	= $d015

color0	= $d016
color1	= $d017
color2	= $d018
color3	= $d019
colbak	= $d01a
gtictl	= $d01b

skctl	= $d20f

portb	= $d301

dmactl	= $d400
dlptr	= $d402
wsync	= $d40a
vcount	= $d40b
nmien	= $d40e
nmist	= $d40f

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

	.align	$100

	ift	ftype=__ftype.gr8	; GR8

	dlist0:	dta d'ppp'
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:89 dta $f
		dta $41,a(dlist0)

	eli	ftype=__ftype.mic	; MIC

	dlist0:	dta d'ppp'
		dta $4e,a(buf0)
		:101 dta $e
		dta $4e,0,h(buf0+$1000)
		:89 dta $e
		dta $41,a(dlist0)

	eli	ftype=__ftype.gr9p	; GR9+

	dlist0:	dta $90,$6f,a(buf0)
		:29 dta a($2f8f)
		dta $41,a(dlist0)

	eli	(ftype=__ftype.gr9)||(ftype=__ftype.g10)||(ftype=__ftype.g11)		; GR9,G10,G11

	dlist0:	dta d'ppp'
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:89 dta $f
		dta $41,a(dlist0)


	eli	ftype=__ftype.hip	; HIP

	dlist0:	dta d'pp',$30+$80
		dta $4f,a(buf1)
		:101 dta $f
		dta $4f,0,h(buf1+$1000)
		:97 dta $f
		dta $41,a(dlist1)

	dlist1:	dta d'pp',$30+$80
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:97 dta $f
		dta $41,a(dlist0)

	eli	(ftype=__ftype.rip)||(ftype=__ftype.tip)	; RIP, TIP

	dlist0:	dta $80
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:97 dta $f
		dta $4f,a(buf2)
		:37 dta $f
		dta $41,a(dlist1)

	dlist1:	dta $80
		dta $4f,a(buf1)
		:101 dta $f
		dta $4f,0,h(buf1+$1000)
		:97 dta $f
		dta $4f,a(buf3)
		:37 dta $f
		dta $41,a(dlist0)

	eli	ftype=__ftype.cin	; CIN

	dlist0:	dta d'pp',$70+$80
		dta $4e,a(buf0)
		:50 dta $f,$e
		dta $f
		dta $4e,0,h(buf0+$1000)
		:44 dta $f,$e
		dta $f
		dta $41,a(dlist1)

	dlist1:	dta d'pp',$70+$80
		dta $4f,a(buf1)
		:50 dta $e,$f
		dta $e
		dta $4f,0,h(buf1+$1000)
		:44 dta $e,$f
		dta $e
		dta $41,a(dlist0)

	eli	ftype=__ftype.hci	; HCI

	dlist0:	dta d'pp',$30+$80
		dta $4e,a(buf1)
		:50 dta $f,$e
		dta $f
		dta $4e,0,h(buf1+$1000)
		:48 dta $f,$e
		dta $f
		dta $41,a(dlist1)

	dlist1:	dta d'pp',$30+$80
		dta $4f,a(buf0)
		:50 dta $e,$f
		dta $e
		dta $4f,0,h(buf0+$1000)
		:48 dta $e,$f
		dta $e
		dta $41,a(dlist0)


	eli	ftype=__ftype.plm	; PLM

	dlist0:	dta d'pp',$70+$80
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:97 dta $f
		dta $41,a(dlist0)

	eli	ftype=__ftype.pzm	; PZM

	dlist0:	dta d'pp',$70+$80
		dta $4f,a(buf0)
		:101 dta $f
		dta $4f,0,h(buf0+$1000)
		:97 dta $f
		dta $41,a(dlist1)

	dlist1:	dta d'pp',$70+$80
		dta $4f,a(buf1)
		:101 dta $f
		dta $4f,0,h(buf1+$1000)
		:97 dta $f
		dta $41,a(dlist0)

	eli	ftype=__ftype.mcpp	; MCP+

	dlist0:	dta d'p',$f0
		dta $4e,a(buf0)
		:101 dta $e
		dta $4e,0,h(buf0+$1000)
		:97 dta $e
		dta $41,a(dlist0)

	els				; INP, IST, RAW, MCP

	dlist0:	dta d'pp',$30+$80
		dta $4e,a(buf0)
		:101 dta $e
		dta $4e,0,h(buf0+$1000)
		:96 dta $e
		dta $e
		dta $41,a(dlist1)

	dlist1:	dta d'pp',$30+$80
		dta $4e,a(buf1)
		:101 dta $e
		dta $4e,0,h(buf1+$1000)
		:96 dta $e
		dta $e
		dta $41,a(dlist0)

	eif

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

main	lda:cmp:req 20

	sei
	mva	#$00	nmien
	
	sta time
	sta time+1

	mva	#$fe	portb

	mwa	#dlist0	dlptr
	mwa	#dli0	vdli


	ift	ftype=__ftype.cin

	lda	#$c0
	sta	mode+1
	sta	loop+1

	eli	(ftype=__ftype.plm)||(ftype=__ftype.pzm)

	lda	#$40
	sta	mode+1
	lda	#$80
	sta	loop+1

	eif


	mwa	#NMI	$fffa

	mva	#$c0	nmien


loop	jsr delay
	inw time
	jmp loop

delay	rts


	lda:rne vcount

wait	lda skctl			; press any key
	and #4
	bne wait

	lda:rne vcount

	mva	#$ff	portb
	mva	#$40	nmien
	cli

	mva #$ff 764			; clear info about pressed key
	rts				; exit

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

	ift (ftype=__ftype.mic)||(ftype=__ftype.gr8)||(ftype=__ftype.inp)||(ftype=__ftype.ist)||(ftype=__ftype.gr9)||(ftype=__ftype.g10)||(ftype=__ftype.g11)	; MIC, GR8, INP, IST, GR9, G10, G11

	dli0:	rti	

	eli ftype=__ftype.mcpp		; MCP+

	dli0:	sta regA
		stx regX
		sty regY

		mva #99 cnt

	loop0:	lda #.get[1]
		ldx #.get[2]
		ldy #.get[3]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[0]
		sta colbak

		lda #.get[5]
		ldx #.get[6]
		ldy #.get[7]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[4]
		sta colbak

		dec cnt
		bpl loop0

		mva #0 colbak

		lda regA
		ldx regX
		ldy regY
		rti


	eli (ftype=__ftype.raw)||(ftype=__ftype.mcp)		; RAW, MCP

	dli0:	sta regA
		stx regX
		sty regY

		mva #99 cnt

	loop0:	lda #.get[1]
		ldx #.get[2]
		ldy #.get[3]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[0]
		sta colbak

		lda #.get[5]
		ldx #.get[6]
		ldy #.get[7]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[4]
		sta colbak

		dec cnt
		bpl loop0

		mva #0 colbak

		mwa #dli1 vdli

		lda regA
		ldx regX
		ldy regY
		rti

	dli1:	sta regA
		stx regX
		sty regY

		mva #99 cnt

	loop1:	lda #.get[5]
		ldx #.get[6]
		ldy #.get[7]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[4]
		sta colbak

		lda #.get[1]
		ldx #.get[2]
		ldy #.get[3]
		sta wsync
		sta color0
		stx color1
		sty color2
		lda #.get[0]
		sta colbak

		dec cnt
		bpl loop1

		mva #0 colbak

		mwa #dli0 vdli

		lda regA
		ldx regX
		ldy regY
		rti


	eli ftype=__ftype.hip		; HIP

	dli0:	sta regA
		stx regX

		ldx #100

	loop0:	lda #$40
		sta wsync
		sta gtictl
		lda #0
		sta colbak
		lda #$80
		sta wsync
		sta gtictl
		lda #.get[8]
		sta colbak
		dex
		bne loop0

		mwa #dli1 vdli

		lda regA
		ldx regX
		rti

	dli1:	sta regA
		stx regX

		ldx #100

	loop1:	lda #$80
		sta wsync
		sta gtictl
		lda #.get[8]
		sta colbak
		lda #$40
		sta wsync
		sta gtictl
		lda #0
		sta colbak
		dex
		bne loop1

		mwa #dli0 vdli

		lda regA
		ldx regX
		rti


	eli ftype=__ftype.rip		; RIP

	dli0:	sta regA
		stx regX

		ldx #119

	loop0:	lda #$40
		sta wsync
		sta gtictl
		lda #0
		sta colbak
		lda #$80
		sta wsync
		sta gtictl
		lda #.get[8]
		sta colbak
		dex
		bne loop0

		mwa #dli1 vdli

		lda regA
		ldx regX
		rti

	dli1:	sta regA
		stx regX

		ldx #119

	loop1:	lda #$80
		sta wsync
		sta gtictl
		lda #.get[8]
		sta colbak
		lda #$40
		sta wsync
		sta gtictl
		lda #0
		sta colbak
		dex
		bne loop1

		mwa #dli0 vdli

		lda regA
		ldx regX
		rti

	eli (ftype=__ftype.tip)		; TIP

	dli0:	sta regA
		stx regX
		sty regY

		ldx #$c0
		ldy #119
		lda #$40

	loop0:	sta wsync
		stx gtictl
		sta wsync
		sta gtictl
		eor #$40^$80
		dey
		bne loop0

		mwa #dli1 vdli

		lda regA
		ldx regX
		ldy regY
		rti

	dli1:	sta regA
		stx regX
		sty regY

		ldx #$c0
		ldy #119
		lda #$80

	loop1:	sta wsync
		stx gtictl
		sta wsync
		sta gtictl
		eor #$40^$80
		dey
		bne loop1

		mwa #dli0 vdli

		lda regA
		ldx regX
		ldy regY
		rti

	eli ftype=__ftype.gr9p			; GR9+

	dli0:	sta regA
		sta $d40a
 
		lda #13
		sta $d405

		lda #3
		sta $d405

		lda regA
		rti
		
	eli ftype=__ftype.hci			; HCI

	dli0:	sta regA
		stx regX
		sty regY

		ldx #100

	loop0:	lda #.get[6]
		ldy #.get[7]		
		sta wsync
		sta color1
		sty color2
		lda #.get[1]
		ldy #.get[0]
		sta wsync
		sta color1
		sty color2
		dex
		bne loop0

		mwa #dli1 vdli

		lda regA
		ldx regX
		ldy regY
		rti

	dli1:	sta regA
		stx regX
		sty regY

		ldx #100

	loop1:	lda #.get[1]
		ldy #.get[0]
		sta wsync
		sta color1
		sty color2
		lda #.get[6]
		ldy #.get[7]
		sta wsync
		sta color1
		sty color2
		dex
		bne loop1

		mwa #dli0 vdli

		lda regA
		ldx regX
		ldy regY
		rti

	els					; CIN, PLM, PZM

	dli0:	sta regA
		stx regX

		ldx #192
	mode:	lda #$c0

	loop:	eor #$c0
		sta wsync
		sta gtictl
		dex
		bne loop

		ift ftype=__ftype.cin

		eor #$c0
		sta mode+1

		eli ftype=__ftype.pzm

		eor #$80
		sta mode+1

		eif

		lda regA
		ldx regX
		rti

	eif

/*-------------------------------------------------------------------------------------------------*/

NMI	bit nmist
	bpl vbl

	jmp dli0
vdli	equ *-2

vbl	sta nmist
	phr

	mva #$22	dmactl


	ift (ftype=__ftype.gr9)||(ftype=__ftype.gr9p)

	mva #$40 gtictl		; graphics 9

	eli ftype=__ftype.g10

	mva #$80 gtictl		; graphics 10

	eli ftype=__ftype.g11

	mva #$c0 gtictl		; graphics 11

	eif


	ift (ftype=__ftype.hip)||(ftype=__ftype.rip)
	
	mva #.get[0]	colpm0
	mva #.get[1]	colpm1
	mva #.get[2]	colpm2
	mva #.get[3]	colpm3
	mva #.get[4]	color0
	mva #.get[5]	color1
	mva #.get[6]	color2
	mva #.get[7]	color3

	eli ftype=__ftype.tip

	mva #$00	colpm0
	mva #$02	colpm1
	mva #$04	colpm2
	mva #$06	colpm3
	mva #$08	color0
	mva #$0a	color1
	mva #$0c	color2
	mva #$0e	color3
	mva #$00	colbak

	eli ftype=__ftype.g10

	mva #.get[0]	colpm0
	mva #.get[1]	colpm1
	mva #.get[2]	colpm2
	mva #.get[3]	colpm3
	mva #.get[4]	color0
	mva #.get[5]	color1
	mva #.get[6]	color2
	mva #.get[7]	color3
	mva #.get[8]	colbak

	eli ftype=__ftype.gr8

	mva #0		colbak
	mva #.get[0]	color1
	mva #.get[1]	color2


	eli ftype=__ftype.hci

	mva #.get[4]	colbak
	mva #.get[5]	color0
	mva #.get[6]	color1
	mva #.get[7]	color2	

	els

	mva #.get[0]	colbak
	mva #.get[1]	color0
	mva #.get[2]	color1
	mva #.get[3]	color2	

	eif

	mwa time $600
	mwa #0 time

	plr
	rti

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/

	run main

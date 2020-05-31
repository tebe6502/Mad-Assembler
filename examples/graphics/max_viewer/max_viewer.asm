
/*

SIMPLE XLP MAX PICTURE VIEWER (24.07.2007)

wycinamy z XLPaint MAX-a:

pic1	$70B0..$8EAF
pic2	$90B0..$AEAF

kol1	equ $6F00	; kolory dla $d016
kol2	equ $5b00	; kolory dla $d017
kol3	equ $0400	; kolory dla $d018

jas1	equ $DD00	; jasnosci dla $d016
jas2	equ $DE00	; jasnosci dla $d017
jas3	equ $DF00	; jasnosci dla $d018

*/

	.get [$000] 'kol1.dat'
	.get [$100] 'kol2.dat'
	.get [$200] 'kol3.dat'

	.get [$300] 'jas1.dat'
	.get [$400] 'jas2.dat'
	.get [$500] 'jas3.dat'

pic1	= $40b0
pic2	= $60b0


	org $80

regA	.ds 1
regX	.ds 1
regY	.ds 1


	org pic1
	ins	'pic1.dat'

	org pic2
	ins	'pic2.dat'

* ---
	org $2000

ant1	@cant	pic1	ant2

	align

ant2	@cant	pic2	ant1


dli1	pha

	.rept 96
	sta	$d40a

	mva	#.get[$300+#*2+1]	$d016
	mva	#.get[$400+#*2+1]	$d017
	mva	#.get[$500+#*2+1]	$d018

	sta	$d40a

	mva	#.get[$000+#*2+1]	$d016
	mva	#.get[$100+#*2+1]	$d017
	mva	#.get[$200+#*2+1]	$d018
	.end

	mwa	#dli2	vdli+1
	pla
	rti


dli2	pha

	.rept 96
	sta	$d40a

	mva	#.get[$000+#*2]	$d016
	mva	#.get[$100+#*2]	$d017
	mva	#.get[$200+#*2]	$d018

	sta	$d40a

	mva	#.get[$300+#*2]	$d016
	mva	#.get[$400+#*2]	$d017
	mva	#.get[$500+#*2]	$d018
	.end

	mwa	#dli1	vdli+1
	pla
	rti


* ---	MAIN PROGRAM
main	lda:cmp:req	$14


* ---	ROM OFF, OS OFF
	sei:cld
	mva	#$00	$d40e
	mva	#$fe	$d301

	mwa	#ant1	$d402

	mwa	#nmi	$fffa

	mva	#$c0	$d40e


* ---	PRESS ANY KEY
loop	lda	$d20f
	and	#$04
	bne	loop


* ---	EXIT TO DOS
	lda:cmp:req	$14

	mva	#$ff	$d301
	mva	#$40	$d40e
	cli

	jmp	($a)


* ---	NMI PROGRAM
nmi	bit	$d40f
	bpl	vbl

vdli	jmp	dli1

vbl	phr

	inc	$14

	mva	#$00	$d01a

	mva	#%00100010	$d400

	plr
	rti


	.print 'end: ',*

* ---	START
	run	main


* ---	CREATE ANTIC PROGRAM
@cant	.macro

	dta	d'pp' , $f0 , $4e , a(:1)
	:+97	dta	$e
	dta	$4e , 0 , h(:1+$1000)
	:+93	dta	$e
	dta	$41 , a(:2)

	.endm


	icl 'align.mac'

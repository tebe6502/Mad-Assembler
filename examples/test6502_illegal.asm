// 15.10.2010
// 09.02.2014 rozdzielenie NPO: NPO DOP TOP
// rozkazy nielegalne 6502 (bez SBB)

abs	equ	$89AB
zp	equ	$7F
imm	equ	$F7

	org	$8000

	aso	(zp,x)	; 03 nn
	aso	zp	; 07 nn
	aso	abs	; 0F nn nn
	aso	(zp),y	; 13 nn
	aso	zp,x	; 17 nn
	aso	abs,x	; 1F nn nn
	aso	abs,y	; 1B nn nn

	rln	abs	; 2F nn nn
	rln	abs,x	; 3F nn nn
	rln	abs,y	; 3B nn nn
	rln	zp	; 27 nn   
	rln	zp,x	; 37 nn   
	rln	zp,y	; 3B nn nn
	rln	(zp,x)	; 23 nn   
	rln	(zp),y	; 33 nn   

	lse	abs	; 4F nn nn
	lse	abs,x	; 5F nn nn
	lse	abs,y	; 5B nn nn
	lse	zp	; 47 nn   
	lse	zp,x	; 57 nn   
	lse	zp,y	; 5B nn nn
	lse	(zp,x)	; 43 nn   
	lse	(zp),y	; 53 nn   

	rrd	abs	; 6F nn nn
	rrd	abs,x	; 7F nn nn
	rrd	abs,y	; 7B nn nn
	rrd	zp	; 67 nn   
	rrd	zp,x	; 77 nn   
	rrd	zp,y	; 7B nn nn
	rrd	(zp,x)	; 63 nn   
	rrd	(zp),y	; 73 nn   

	sax	abs	; 8F nn nn
	sax	zp	; 87 nn
	sax	zp,y	; 97 nn
	sax	(zp,x)	; 83 nn   

	lax	abs	; AF nn nn
	lax	abs,y	; BF nn nn
	lax	zp	; A7 nn
	lax	zp,y	; B7 nn   
	lax	(zp,x)	; A3 nn   
	lax	(zp),y	; B3 nn

	dcp	abs	; CF nn nn
	dcp	abs,x	; DF nn nn
	dcp	abs,y	; DB nn nn
	dcp	zp	; C7 nn   
	dcp	zp,x	; D7 nn   
	dcp	zp,y	; DB nn nn
	dcp	(zp,x)	; C3 nn   
	dcp	(zp),y	; D3 nn   

	isb	abs	; EF nn nn
	isb	abs,x	; FF nn nn
	isb	abs,y	; FB nn nn
	isb	zp	; E7 nn   
	isb	zp,x	; F7 nn   
	isb	zp,y	; FB nn nn
	isb	(zp,x)	; E3 nn   
	isb	(zp),y	; F3 nn   

	anc	#imm	; 0B nn

	alr	#imm	; 4B nn

	arr	#imm	; 6B nn

	ane	#imm	; 8B nn

	anx	#imm	; AB nn

	sbx	#imm	; CB nn

;	sbb	#imm	; EB nn

	las	abs,y	; BB nn nn

	sha	abs,y	; 9F nn nn
	sha	(zp),y	; 93 nn

	shs	abs,y	; 9B nn nn

	shx	abs,y	; 9E nn nn

	shy	abs,x	; 9C nn nn

	npo		; 1A

	dop #imm	; 80 nn
	dop zp		; 44 nn
	dop zp,x	; 54 nn

	top	abs	; 0C nn nn
	top	abs,x	; 1C nn nn

	cim		; 02

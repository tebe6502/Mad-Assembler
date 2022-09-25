
/*
	Fraktal Mandelbrot'a
	by Konop, Tebe, Fox (07.06.2006, 29.07.2008)
*/

	screen	= $a000


	PRECISION   =	5
	ONE	 =	1 << PRECISION

	MinX =	-2*ONE
	MaxX =	+2*ONE

	MinY =	-2*ONE
	MaxY =	+2*ONE

	dx   =  [MaxX-MinX] & $FFFF
	dy   =  [MaxY-MinY] & $FFFF

	sze  =	128
	wys  =	112
		
	MAX_ITERATION = 16		// higher value -> better quality


	.zpvar ACC AUX EXT .word = $70

;---
	org $2000
;---

dlist	dta d'p'
	dta $4d,a(screen)
	:wys-1 dta $d
	dta $41,a(dlist)


init	jsr MUL.init
	jsr MULU.init

	mwa #dlist	560
	mva #%00100001	559

main	.local

	.zpvar tmpX, tmpY, x, y, color .byte

//      for y:=0 to wys-1 do begin
	ldy #-1
forY	iny
	cpy #wys-1
	sne
	jmp repeat

//	for x:=0 to sze-1 do begin
	ldx #0
forX	stx x	   // saves 'x', 'y'
	sty y

	cpx #sze-1
	beq forY

//	    color:=calcPixel(MinX+((x*dx) div sze), MinY+((y*dy) div wys));
	mulu x , #dx

	div #sze

	adb #MinX&$FF ACC tmpX

	mulu y , #dy

	div #wys

	adb #MinY&$FF ACC tmpY

	calcPixel tmpX,tmpY
	sta color

//	  PutPixel(x, y, color);
	PutPixel x,y,color

	ldx x	   // restore 'x', 'y'
	ldy y

	inx
	jmp forX		    

repeat
	mva	#$d4	708
	mva	#$28	709
	mva	#$7c	710

	jmp	repeat

	.endl


* ----------- *
*  PUT PIXEL  *
* ----------- *
putPixel .proc (.byte x,y,a) .reg

	.zpvar scr .word  y .byte

	sty y

	and #3
	tay
	lda atcol,y
	sta _col+2

	ldy y
	lda lscr,y
	sta scr
	lda hscr,y
	sta scr+1

	txa
	:2 lsr @
	tay

_col	lda tcol0,x
	ora (scr),y
	sta (scr),y

	rts

atcol	dta h(tcol0,tcol1,tcol2,tcol3)

// zwiekszamy adres do poczatku nowej strony
	.ALIGN
        
tcol0	:64 dta %00000000,%00000000,%00000000,%00000000
tcol1	:64 dta %01000000,%00010000,%00000100,%00000001
tcol2	:64 dta %10000000,%00100000,%00001000,%00000010
tcol3	:64 dta %11000000,%00110000,%00001100,%00000011

lscr	:wys dta l(screen+#*32)
hscr	:wys dta h(screen+#*32)

.endp


* ------------ *
*  CALC PIXEL  *
* ------------ *
calcPixel .proc (.byte a , x) .reg    // CA = real value, CBi = imaginary

/*
tmpA      = zp_calcPixel  ;(2)
tmpB      = tmpA+2        ;(2)
length	  = tmpB+2 	  ;(2)  length of Z, sqrt(length_z)>2 => Z->infinity
old_a	  = length+2      ;(1)  just a variable to keep 'a' from being destroyed
a	  = old_a+1	  ;(1)  function Z divided in real
b         = a+1           ;(1)  and imaginary parts
iteration = b+1 	  ;(1)  the iteration-counter
*/
	.zpvar tmpA tmpB length .word  old_a a b iteration ca cbi .byte
	
	sta ca
	stx cbi

	lda #0   		// initialize Z(0) = 0
	sta a

	sta b

	sta iteration	   // initialize iteration

repeat
	lda a		   // saves the 'a'  (Will be destroyed in next line)
	sta old_a

//		a:=(((a*a)-(b*b)) div ONE)+ca;
	mul b , b
	sta tmpB+1
	sty tmpB

	mul a , a

	sbw ACC tmpB

	div #ONE

	adb ACC ca a

//		b:=((2*old_a*b) div ONE)+cbi;
	mul old_a , b

	asl ACC
	rol ACC+1

	div #ONE

	adb ACC cbi b

//		length:=((a*a)+(b*b)) div ONE;	{note: We do not perform the squareroot here}
	mul a , a
	sta tmpA+1
	sty tmpA

	mul b , b

	adw ACC tmpA

	div #ONE

	inc iteration

//	until (length > (4 shl PRECISION)) or (iteration > MAX_ITERATION);

	lda ACC+1
	bmi skip_

	bne stop

	lda ACC
	cmp #4<<PRECISION
	bcs stop
skip_

	lda iteration
	cmp #MAX_ITERATION
	bcs stop

	jmp repeat

stop

//	calcPixel:=iteration;
	lda iteration
	rts

.endp


* -------------------------------- *
* Unsigned multiplication          *
* A*X -> A:Y (A-high byte, Y-low)  *
* b. Fox/Tqa                       *
* -------------------------------- *
.proc MULU (.byte a,x) .reg

	sta l1+1
	sta h1+1
	eor #$ff
	sta l2+1
	sta h2+1
	sec
l1	lda sq1l,x
l2	sbc sq2l,x
	tay
h1	lda sq1h,x
h2	sbc sq2h,x

	sty ACC
	sta ACC+1

	rts

init	ldx #0
	stx sq1l
	stx sq1h
	stx sq2l+$ff
	stx sq2h+$ff
	ldy #$ff
msq1	txa
	lsr @
	adc sq1l,x
	sta sq1l+1,x
	sta sq2l-1,y
	sta sq2l+$100,x
	lda #0
	adc sq1h,x
	sta sq1h+1,x
	sta sq2h-1,y
	sta sq2h+$100,x
	inx
	dey
	bne msq1
msq2	tya
	sbc #0
	ror @
	adc sq1l+$ff,y
	sta sq1l+$100,y
	lda #0
	adc sq1h+$ff,y
	sta sq1h+$100,y
	iny
	bne msq2
	rts

// od poczatku nowej strony
	.ALIGN

sq1l	.ds $200
sq1h	.ds $200
sq2l	.ds $200
sq2h	.ds $200

.endp


* --------------------------------- *
*  Signed multiplication            *
*  A*X -> A:Y (A-high byte, Y-low)  *
*  b. Fox/Tqa                       *
* --------------------------------- *
.proc MUL (.byte a,x) .reg

	eor #$80
	sta l1+1
	sta h1+1
	eor #$ff
	sta l2+1
	sta h2+1
	txa
	eor #$80
	tax
	sec
l1	lda sq1l,x
l2	sbc sq2l,x
	tay
h1	lda sq1h,x
h2	sbc sq2h,x

	sty ACC
	sta ACC+1

	rts

init	ldx #0
	stx sq1l+$100
	stx sq1h+$100
	stx sq2l+$ff
	stx sq2h+$ff
	ldy #$ff
msqr	txa
	lsr @
	adc sq1l+$100,x
	sta sq1l,y
	sta sq1l+$101,x
	sta sq2l-1,y
	sta sq2l+$100,x
	lda #0
	adc sq1h+$100,x
	sta sq1h,y
	sta sq1h+$101,x
	sta sq2h-1,y
	sta sq2h+$100,x
	inx
	dey
	bne msqr
	rts

// od poczatku nowej strony
	.ALIGN

sq1l	.ds $200
sq1h	.ds $200
sq2l	.ds $200
sq2h	.ds $200

.endp


* ----- *
*  DIV  *
* ----- *
.proc DIV (.byte a) .reg

	sta AUX

	lda ACC+1
	and #$80
	sta znak+1

	LDA #0
	STA EXT+1
	LDY #$10
LOOP	ASL ACC
	ROL ACC+1
	ROL @
	ROL EXT+1
	PHA
	CMP AUX
	LDA EXT+1
	SBC #0
	BCC DIV2
	STA EXT+1
	PLA
	SBC AUX
	PHA
	INC ACC
DIV2	PLA
	DEY
	BNE LOOP
;	STA EXT

	lda ACC+1
znak	eor #0
	sta ACC+1

	RTS
.endp

;---
	run init
;---

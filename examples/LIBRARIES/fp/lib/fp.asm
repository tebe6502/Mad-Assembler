
/*
   Przykladowa biblioteka wykorzystujaca pakiet matematyczny XE/XL

   _ATOFP (ascii,fp)	- zamienia ciag znakow ASCII na liczbe FP, pierwszy parametr to adres ciagu ASCII ktory bedzie
			  zamieniany na FP, drugi parametr to adres pod którym odlozona zostanie liczba FP
   			  zamieniany ciag ASCII musi byc zakonczony znakiem innym niz cyfra, np. EOL $9B

   _FPTOA (fp,ascii)	- zamienia liczbe FP na ciag znakow ASCII, pierwszy parametr to adres pod którym znajduje
			  sie liczba FP, drugi parametr to adres pod ktory odlozony zostanie ciag znaków ASCII
			  ciag ASCII bedzie zakonczony znakiem EOL $9b

   _ITOFP (int,fp)	- zamienia liczbe typu 'unsigned int' (word) na liczbe FP, pierwszym parametrem jest wartosc
			  bez znaku z zakresu 0..$FFFF, drugim parametrem jest adres pod którym zostanie zapisana
			  liczba FP

   _FPTOI (fp)		- zamienia liczbe FP na liczbe typu 'unsigned int' (word), parametrem jest adres pod
			  ktorym znajduje sie liczba FP, wynik zwracany jest przez rejestry CPU X,Y
			  X - mlodszy bajt liczby WORD
			  Y - starszy bajt liczby WORD

   _FPADD (fp0,fp1,fp2)	- FP2=FP0+FP1	suma dwóch liczb

   _FPSUB (fp0,fp1,fp2)	- FP2=FP0-FP1	róznica dwóch liczb

   _FPMUL (fp0,fp1,fp2)	- FP2=FP0*FP1	iloczyn dwóch liczb

   _FPDIV (fp0,fp1,fp2)	- FP2=FP0/FP1	iloraz dwóch liczb

   LOADFR0 (fp)		- przepisuje liczbe FP do rejestru pakietu zmiennoprzecinkowego FR0, parametrem
   			  jest adres pod ktorym znajduje sie liczba FP do przepisania

   LOADFR1 (fp)		- przepisuje liczbe FP do rejestru pakietu zmiennoprzecinkowego FR1, parametrem
   			  jest adres pod ktorym znajduje sie liczba FP do przepisania

*/

	icl 'global.asm'

loadfr0.adr	= ptr0
loadfr1.adr	= ptr1

	.public	loadfr1

	.reloc

;------------------------------------
	.globl _atofp
;atofp(ascii,float)
_atofp	.proc	(.word inbuff, flptr) .var

	lda     #0
	sta     cix
	jsr     afp

	jmp	fst0p

	.endp

;------------------------------------
       .globl _fptoa
;      fptoa(float,ascii)
_fptoa	.proc	(.word loadfr0.adr, ptr1) .var

	jsr	loadfr0

	lda     #0
	sta     cix

	mwa	#lbuff	inbuff	; COPY ADDRESS OF LBUFF INTO INBUFF
	
	jsr     fasc
	ldy     #$FF
loop:	iny
	lda     (inbuff),y
	sta     (ptr1),y
	bpl     loop
	and     #$7F
	sta     (ptr1),y
	iny
	lda     #$9b
	sta     (ptr1),y
	rts

	.endp

;------------------------------------
       .globl _itofp
;          itofp(int,float)
_itofp	.proc	(.word fr0, flptr) .var

	jsr     ifp
	jmp	fst0p

	.endp

;------------------------------------
       .globl _fptoi
;      int=fptoi(float)
_fptoi	.proc	(.word yx) .reg

	jsr	fld0r

	jsr	fpi

	ldx	fr0
	ldy	fr0+1
	rts

	.endp

;------------------------------------
       .globl _fpadd
;      fpadd(fp a,fp b,fp c)
;              a+b=c
_fpadd	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	jsr	loadfr0
	jsr	loadfr1

	jsr	fadd
	jmp	fst0p

       .endp

;------------------------------------
       .globl _fpsub
;      fpsub(fp a,fp b,fp c)
;              a-b=c
_fpsub	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	jsr	loadfr0
	jsr	loadfr1

	jsr     fsub
	jmp	fst0p

	.endp

;------------------------------------
       .globl _fpmul
;      fpmul(fp a,fp b,fp c)
;              a*b=c
_fpmul	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	jsr	loadfr0
	jsr	loadfr1

	jsr     fmul
	jmp	fst0p

	.endp

;------------------------------------
       .globl _fpdiv
;      fpdiv(fp a,fp b,fp c)
;              a/b=c
_fpdiv	.proc	(.word loadfr0.adr, loadfr1.adr, flptr) .var

	jsr	loadfr0
	jsr	loadfr1

	jsr     fdiv
	jmp	fst0p

	.endp

;------------------------------------
       .globl _fpgrt, _fples, _fpneq, _fpleq, _fpgeq, _fpequ
;
_fpgrt	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	bmi	false	; >
	beq	false
	bpl	true
	.endp

_fples	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	bmi	true	; <
	bpl	false
	.endp

_fpneq	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	beq	false	; <>
	bne	true
	.endp

_fpleq	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	bmi	true	; <=
	beq	true
	bpl	false
	.endp
	
_fpgeq	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	bmi	false	; >=
	bpl	true
	.endp

_fpequ	.proc	(.word loadfr0.adr, loadfr1.adr) .var
	jsr	_cmpvar
	beq	true	; =
	.endp

false	lda	#0
	rts

true	lda	#1
	rts

_cmpvar	jsr	loadfr0
	jsr	loadfr1

	jsr	fsub

	lda	fr0
	rts

;------------------------------------
loadfr0	.proc	(.word loadfr0.adr) .var

	ldy	#5
	mva	(loadfr0.adr),y		fr0,y-
	rpl

	rts

	.endp

;------------------------------------
loadfr1	.proc	(.word loadfr1.adr) .var

	ldy	#5
	mva	(loadfr1.adr),y		fr1,y-
	rpl

	rts

	.endp

;------------------------------------
	.globl	_fst0r
;	fr0 -> fp
_fst0r	.proc	(.word yx) .reg

	jmp	fst0r

	.endp

;------------------------------------
	.globl	_fld0r
;	fp -> fr1
_fld0r	.proc	(.word yx) .reg

	jmp	fld0r

	.endp

;------------------------------------
	.globl	_fld1r
;	fp -> fr1
_fld1r	.proc	(.word yx) .reg

	jmp	fld1r

	.endp


// 04.10.2010

cnt	.enum
	a=5,b,c
	.ende

.enum	counter
	a=1, b=2, c		; a=1, b=2, c=3
	d=10, e,f,g		; d=10, e=11, f=12, g=13
.ende

stmp	.struct
	a .byte
	.ends

.struct	temp
	x counter		; x = .byte
	counter y		; y = .byte
.ends


	org $2000

.var	tmpv	temp
.var	tmp2	:2 temp = $a000

.zpvar	zp0	counter

.zpvar	zp1	temp

	ldx tmp.x
	ldy tmp.y

	lda tmps[6].y

	ldx tmpv.x
	ldy tmpv.y

	lda tmp2[2].x

	jmp *

tmp	temp

tmps	dta temp [12]

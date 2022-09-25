
/*
znaki formatuj¹ce tekst

#	- adres tekstu zakoñczonego znakiem $9b
@	- adres wartoœci typu ATARI FLOAT
%	- adres wartoœci typu WORD

po bajcie koñcz¹cym $00 wystêpuj¹ adresy do poszczególnych obs³ugiwanych w/w typów

np.

 jsr printf
 dta c'tekst #@%',$9b,0
 dta a(_string)
 dta a(_float)
 dta a(_word)

 jmp *

_string dta c'    ',$9b
_float .fl -12.33
_Word  dta a(1985)


*/

	icl 'fpequ.mae'

?off	=	$15
?strv	=	$32
?vecv	=	$34
?dtav	=	$36
?soff	=	$38
?aux	=	$39

	.reloc

	.public	printf

printf	.proc
	clc
	pla
	adc #$01
	sta ?strv
	pla
	adc #$00
	sta ?strv+1

	ldy #$FF
?cnt	iny
	lda (?strv),Y
	bne ?cnt

	tya
	adc ?strv
	sta ?vecv
	lda #$00
	tay
	adc ?strv+1
	sta ?vecv+1

?prt	lda (?strv),Y
	beq ?ext
	iny
	sty ?off
	cmp #'%'
	beq ?spc
	cmp #'@'
	beq _float
	cmp #'#'
	beq _string
	jsr putchr
?nxt	ldy ?off
	bne ?prt

?ext	lda ?vecv+1
	pha
	lda ?vecv
	pha
	rts

_float	jmp float
_string	jmp string


?spc	
	jsr _word

	lda (?dtav),Y
	sta fr0
	iny
	lda (?dtav),Y
	sta fr0+1
	jsr IFP
	jsr FASC

insert
	ldy #$00

?pnd	lda (inbufp),y
	bmi ?chr
	sty ?aux
	jsr putchr
	inc ?aux
	ldy ?aux
	bne ?pnd
?chr	and #$7F
	jsr putchr
	bpl ?nxt

putchr	tax
	lda $347	;ICPUTB+1
	pha
	lda $346	;ICPUTB
	pha
	txa
	rts

	.endp


float	.proc	

	jsr	_word

	ldx	?dtav
	ldy	?dtav+1
	jsr	fld0r
	jsr	FASC

	jmp	printf.insert

	.endp


string	.proc	

	jsr	_word

	ldy	#$ff
_lp	iny
	lda	(?dtav),y
	sta	lbuff,y
	bpl	_lp

	mwa	#lbuff	inbufp

	jmp	printf.insert

	.endp


_word
	ldy	#$02
?lp1	lda	(?vecv),Y
	sta	?vecv+1,Y
	dey
	bne	?lp1

	ldy	#$02
?lp2	inw	?vecv
	dey
	bne	?lp2
	rts
